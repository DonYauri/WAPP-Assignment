using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web;
using System.Web.Script.Serialization;

namespace WAPP_FinalAssignment
{
    public partial class CreateQuiz : System.Web.UI.Page
    {
        private int CourseID
        {
            get
            {
                int v;
                if (int.TryParse(Request.QueryString["courseID"], out v) && v > 0) return v;
                if (int.TryParse(hfCourseID.Value, out v) && v > 0) return v;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireRole(this, SessionHelper.RoleEducator, SessionHelper.RoleAdmin))
                return;
            if (CourseID <= 0)
            {
                Response.Redirect("EducatorDashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);

            if (!IsPostBack)
            {
                hfCourseID.Value = CourseID.ToString();

                var row = Db.QueryOne(
                    "SELECT courseName, userID FROM dbo.Courses WHERE courseID = @c;",
                    Db.P("@c", CourseID));
                if (row == null)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=courseNotFound", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                int ownerId = Db.ToInt(row["userID"]);
                if (!SessionHelper.IsAdmin && ownerId != SessionHelper.CurrentUserId)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=accessDenied", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                string courseName = Db.ToStr(row["courseName"]);
                lblCourseName.Text = HttpUtility.HtmlEncode(courseName);
                lblCourseNameSub.Text = HttpUtility.HtmlEncode(courseName);
                aCourseLink.HRef = "EditCourse.aspx?courseID=" + CourseID;
            }
        }

        protected void btnSaveQuiz_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (CourseID <= 0) { ShowError("Course id missing."); return; }

            string title = (txtQuizTitle.Text ?? "").Trim();
            string desc = (txtDescription.Text ?? "").Trim();
            string videoURL = (txtVideoURL.Text ?? "").Trim();
            string readme = txtReadme.Text ?? "";

            if (title.Length == 0 || title.Length > 50) { ShowError("Quiz title is required (≤ 50 chars)."); return; }
            if (desc.Length == 0 || desc.Length > 200) { ShowError("Description is required (≤ 200 chars)."); return; }
            if (videoURL.Length > 255) { ShowError("Video URL is too long."); return; }

            double pass;
            if (!double.TryParse((txtPassingScore.Text ?? "").Trim(),
                NumberStyles.Float, CultureInfo.InvariantCulture, out pass)
                || double.IsNaN(pass) || double.IsInfinity(pass)
                || pass < 1 || pass > 100)
            { ShowError("Passing score must be between 1 and 100."); return; }

            // Decode questions JSON
            var questions = ParseQuestions(hfQuestionsData.Value);
            if (questions == null || questions.Count == 0)
            {
                ShowError("Add at least one question before publishing.");
                return;
            }

            try
            {
                int newQuizId = 0;
                Db.RunInTransaction((conn, tx) =>
                {
                    using (var cmd = new System.Data.SqlClient.SqlCommand(@"
                        INSERT INTO dbo.Quizzes
                            (courseID, quizTitle, description, readme, videoURL, passingScore, dateCreated)
                        VALUES
                            (@c, @t, @d, @r, @v, @p, @dt);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@c", CourseID);
                        cmd.Parameters.AddWithValue("@t", title);
                        cmd.Parameters.AddWithValue("@d", desc);
                        cmd.Parameters.AddWithValue("@r",
                            string.IsNullOrEmpty(readme) ? (object)DBNull.Value : readme);
                        cmd.Parameters.AddWithValue("@v",
                            string.IsNullOrEmpty(videoURL) ? (object)DBNull.Value : videoURL);
                        cmd.Parameters.AddWithValue("@p", pass);
                        cmd.Parameters.AddWithValue("@dt", DateTime.Today);
                        var raw = cmd.ExecuteScalar();
                        newQuizId = raw == null ? 0 : Db.ToInt(raw);
                    }

                    if (newQuizId <= 0)
                        throw new InvalidOperationException("Quiz INSERT did not return an id.");

                    foreach (var q in questions)
                    {
                        Db.ExecuteNonQueryTx(conn, tx, @"
                            INSERT INTO dbo.QuizQuestions
                                (quizID, questionsScore, questionText,
                                 optionA, optionB, optionC, optionD, correctAnswer)
                            VALUES
                                (@q, @s, @t, @a, @b, @c, @d, @cor);",
                            Db.P("@q", newQuizId),
                            Db.P("@s", q.Score),
                            Db.P("@t", q.Text),
                            Db.P("@a", q.A),
                            Db.P("@b", q.B),
                            Db.P("@c", q.C),
                            Db.P("@d", q.D),
                            Db.P("@cor", q.Correct));
                    }
                });

                Response.Redirect("EditCourse.aspx?courseID=" + CourseID + "&msg=quizCreated", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not save the quiz. Please try again.");
            }
        }

        // ── Question parsing helpers ──────────────────────────────────────
        internal class QuestionDraft
        {
            public string Text;
            public double Score;
            public string A, B, C, D, Correct;
        }

        internal static List<QuestionDraft> ParseQuestions(string json)
        {
            if (string.IsNullOrWhiteSpace(json) || json == "[]") return new List<QuestionDraft>();
            var result = new List<QuestionDraft>();
            try
            {
                var ser = new JavaScriptSerializer();
                var arr = ser.Deserialize<List<Dictionary<string, object>>>(json);
                if (arr == null) return result;
                foreach (var q in arr)
                {
                    var draft = new QuestionDraft
                    {
                        Text = ToStr(q, "questionText"),
                        Score = ToScore(q, "questionsScore"),
                        A = ToStr(q, "optionA"),
                        B = ToStr(q, "optionB"),
                        C = ToStr(q, "optionC"),
                        D = ToStr(q, "optionD"),
                        Correct = NormalizeAnswer(ToStr(q, "correctAnswer"))
                    };
                    if (!string.IsNullOrWhiteSpace(draft.Text))
                        result.Add(draft);
                }
            }
            catch
            {
                // returns empty list — caller surfaces a friendly error
            }
            return result;
        }

        private static string ToStr(Dictionary<string, object> d, string key)
        {
            if (d == null || !d.TryGetValue(key, out var v) || v == null) return null;
            string s = v.ToString().Trim();
            return s.Length == 0 ? null : s;
        }

        private static double ToScore(Dictionary<string, object> d, string key)
        {
            object v;
            if (d == null || !d.TryGetValue(key, out v) || v == null) return 1d;
            double parsed;
            if (double.TryParse(v.ToString(), NumberStyles.Float,
                CultureInfo.InvariantCulture, out parsed)
                && !double.IsNaN(parsed) && !double.IsInfinity(parsed)
                && parsed > 0)
                return parsed;
            return 1d;
        }

        private static string NormalizeAnswer(string v)
        {
            if (string.IsNullOrEmpty(v)) return "A";
            v = v.Trim().ToUpperInvariant();
            return (v == "A" || v == "B" || v == "C" || v == "D") ? v : "A";
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            lblError.Text = HttpUtility.HtmlEncode(msg);
        }
    }
}
