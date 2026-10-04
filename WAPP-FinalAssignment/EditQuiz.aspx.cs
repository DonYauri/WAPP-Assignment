using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace WAPP_FinalAssignment
{
    public partial class EditQuiz : System.Web.UI.Page
    {
        private int QuizID
        {
            get
            {
                int v;
                if (int.TryParse(Request.QueryString["quizID"], out v) && v > 0) return v;
                if (int.TryParse(hfQuizID.Value, out v) && v > 0) return v;
                return 0;
            }
        }

        private int _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireRole(this, SessionHelper.RoleEducator, SessionHelper.RoleAdmin))
                return;
            if (QuizID <= 0)
            {
                Response.Redirect("EducatorDashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);

            if (!IsPostBack) LoadQuiz();
        }

        private void LoadQuiz()
        {
            try
            {
                const string sql = @"
                    SELECT q.quizID, q.courseID, q.quizTitle, q.description,
                           q.readme, q.videoURL, q.passingScore,
                           c.courseName, c.userID AS ownerID
                      FROM dbo.Quizzes q
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE q.quizID = @id;";
                var row = Db.QueryOne(sql, Db.P("@id", QuizID));
                if (row == null)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=quizNotFound", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                int ownerId = Db.ToInt(row["ownerID"]);
                if (!SessionHelper.IsAdmin && ownerId != SessionHelper.CurrentUserId)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=accessDenied", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                _courseId = Db.ToInt(row["courseID"]);
                hfQuizID.Value = QuizID.ToString();

                string title = Db.ToStr(row["quizTitle"]);
                lblQuizName.Text = HttpUtility.HtmlEncode(title);
                lblCourseName.Text = HttpUtility.HtmlEncode(Db.ToStr(row["courseName"], "Course"));
                aCourseLink.HRef = "EditCourse.aspx?courseID=" + _courseId;
                aQuizLink.HRef = "QuizPage.aspx?quizID=" + QuizID;
                aViewQuiz.HRef = "QuizPage.aspx?quizID=" + QuizID;

                txtQuizTitle.Text = title;
                txtDescription.Text = Db.ToStr(row["description"]);
                txtReadme.Text = Db.ToStr(row["readme"]);
                txtVideoURL.Text = Db.ToStr(row["videoURL"]);
                txtPassingScore.Text = Db.ToDouble(row["passingScore"]).ToString("0.#", CultureInfo.InvariantCulture);

                hfQuestionsData.Value = SerializeQuestions(QuizID);
                hfDeletedQuestionIDs.Value = "[]";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not load quiz.");
            }
        }

        private static string SerializeQuestions(int quizId)
        {
            try
            {
                const string sql = @"
                    SELECT questionID, questionText, questionsScore,
                           optionA, optionB, optionC, optionD, correctAnswer
                      FROM dbo.QuizQuestions
                     WHERE quizID = @q
                  ORDER BY questionID;";
                var dt = Db.Query(sql, Db.P("@q", quizId));
                var sb = new StringBuilder();
                sb.Append("[");
                bool first = true;
                foreach (DataRow r in dt.Rows)
                {
                    if (!first) sb.Append(",");
                    first = false;
                    sb.Append("{");
                    sb.Append("\"questionID\":").Append(Db.ToInt(r["questionID"])).Append(",");
                    sb.Append("\"questionsScore\":").Append(Db.ToDouble(r["questionsScore"], 1d).ToString(CultureInfo.InvariantCulture)).Append(",");
                    sb.Append("\"questionText\":\"").Append(EscapeJson(Db.ToStr(r["questionText"]))).Append("\",");
                    sb.Append("\"optionA\":\"").Append(EscapeJson(Db.ToStr(r["optionA"]))).Append("\",");
                    sb.Append("\"optionB\":\"").Append(EscapeJson(Db.ToStr(r["optionB"]))).Append("\",");
                    sb.Append("\"optionC\":\"").Append(EscapeJson(Db.ToStr(r["optionC"]))).Append("\",");
                    sb.Append("\"optionD\":\"").Append(EscapeJson(Db.ToStr(r["optionD"]))).Append("\",");
                    sb.Append("\"correctAnswer\":\"").Append(EscapeJson(Db.ToStr(r["correctAnswer"], "A"))).Append("\"");
                    sb.Append("}");
                }
                sb.Append("]");
                return sb.ToString();
            }
            catch
            {
                return "[]";
            }
        }

        private static string EscapeJson(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return "";
            var sb = new StringBuilder();
            foreach (char c in raw)
            {
                switch (c)
                {
                    case '\\': sb.Append("\\\\"); break;
                    case '\"': sb.Append("\\\""); break;
                    case '\n': sb.Append("\\n"); break;
                    case '\r': sb.Append("\\r"); break;
                    case '\t': sb.Append("\\t"); break;
                    default:
                        if (c < 0x20) sb.AppendFormat("\\u{0:x4}", (int)c);
                        else sb.Append(c);
                        break;
                }
            }
            return sb.ToString();
        }

        protected void btnSaveQuiz_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (QuizID <= 0) { ShowError("Quiz id missing."); return; }

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

            var incoming = ParseQuestions(hfQuestionsData.Value);
            var deleted = ParseDeletedIds(hfDeletedQuestionIDs.Value);

            if (incoming.Count == 0)
            {
                ShowError("A quiz must have at least one question.");
                return;
            }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    // Update the quiz row
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        UPDATE dbo.Quizzes
                           SET quizTitle = @t, description = @d,
                               readme = @r, videoURL = @v,
                               passingScore = @p
                         WHERE quizID = @id
                           AND (@isAdmin = 1 OR courseID IN (SELECT courseID FROM dbo.Courses WHERE userID = @u));",
                        Db.P("@t", title),
                        Db.P("@d", desc),
                        Db.P("@r", string.IsNullOrEmpty(readme) ? (object)DBNull.Value : readme),
                        Db.P("@v", string.IsNullOrEmpty(videoURL) ? (object)DBNull.Value : videoURL),
                        Db.P("@p", pass),
                        Db.P("@id", QuizID),
                        Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                        Db.P("@u", SessionHelper.CurrentUserId));

                    // Apply deletions: cascade through AttemptSummaries first
                    foreach (int qid in deleted)
                    {
                        Db.ExecuteNonQueryTx(conn, tx,
                            "DELETE FROM dbo.AttemptSummaries WHERE questionID = @qid;",
                            Db.P("@qid", qid));
                        Db.ExecuteNonQueryTx(conn, tx,
                            "DELETE FROM dbo.QuizQuestions WHERE questionID = @qid AND quizID = @qz;",
                            Db.P("@qid", qid),
                            Db.P("@qz", QuizID));
                    }

                    // Upserts
                    foreach (var q in incoming)
                    {
                        if (q.QuestionID > 0)
                        {
                            Db.ExecuteNonQueryTx(conn, tx, @"
                                UPDATE dbo.QuizQuestions
                                   SET questionsScore = @s, questionText = @t,
                                       optionA = @a, optionB = @b, optionC = @c, optionD = @d,
                                       correctAnswer = @cor
                                 WHERE questionID = @qid AND quizID = @qz;",
                                Db.P("@s", q.Score),
                                Db.P("@t", q.Text),
                                Db.P("@a", q.A),
                                Db.P("@b", q.B),
                                Db.P("@c", q.C),
                                Db.P("@d", q.D),
                                Db.P("@cor", q.Correct),
                                Db.P("@qid", q.QuestionID),
                                Db.P("@qz", QuizID));
                        }
                        else
                        {
                            Db.ExecuteNonQueryTx(conn, tx, @"
                                INSERT INTO dbo.QuizQuestions
                                    (quizID, questionsScore, questionText,
                                     optionA, optionB, optionC, optionD, correctAnswer)
                                VALUES
                                    (@qz, @s, @t, @a, @b, @c, @d, @cor);",
                                Db.P("@qz", QuizID),
                                Db.P("@s", q.Score),
                                Db.P("@t", q.Text),
                                Db.P("@a", q.A),
                                Db.P("@b", q.B),
                                Db.P("@c", q.C),
                                Db.P("@d", q.D),
                                Db.P("@cor", q.Correct));
                        }
                    }
                });

                ShowSuccess("Quiz saved.");
                LoadQuiz();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not save quiz changes.");
            }
        }

        protected void btnDeleteQuiz_Click(object sender, EventArgs e)
        {
            try
            {
                int owned = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Quizzes q
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE q.quizID = @id
                       AND (@isAdmin = 1 OR c.userID = @u);",
                    Db.P("@id", QuizID),
                    Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                    Db.P("@u", SessionHelper.CurrentUserId));
                if (owned == 0) { ShowError("Quiz not found or not owned."); return; }

                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.AttemptSummaries
                         WHERE attemptID IN (SELECT attemptID FROM dbo.QuizAttempts WHERE quizID = @id);",
                        Db.P("@id", QuizID));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.QuizAttempts WHERE quizID = @id;",
                        Db.P("@id", QuizID));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.QuizQuestions WHERE quizID = @id;",
                        Db.P("@id", QuizID));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.Quizzes WHERE quizID = @id;",
                        Db.P("@id", QuizID));
                });

                Response.Redirect("EditCourse.aspx?courseID=" + _courseId + "&msg=quizDeleted", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not delete quiz.");
            }
        }

        // ── Question parsing ──────────────────────────────────────────────
        private class QuestionEdit
        {
            public int QuestionID;
            public string Text;
            public double Score;
            public string A, B, C, D, Correct;
        }

        private static List<QuestionEdit> ParseQuestions(string json)
        {
            var list = new List<QuestionEdit>();
            if (string.IsNullOrWhiteSpace(json) || json == "[]") return list;
            try
            {
                var ser = new JavaScriptSerializer();
                var arr = ser.Deserialize<List<Dictionary<string, object>>>(json);
                if (arr == null) return list;

                foreach (var q in arr)
                {
                    var draft = new QuestionEdit
                    {
                        QuestionID = ToInt(q, "questionID"),
                        Text = ToStr(q, "questionText"),
                        Score = ToScore(q, "questionsScore"),
                        A = ToStr(q, "optionA"),
                        B = ToStr(q, "optionB"),
                        C = ToStr(q, "optionC"),
                        D = ToStr(q, "optionD"),
                        Correct = NormalizeAnswer(ToStr(q, "correctAnswer"))
                    };
                    if (!string.IsNullOrWhiteSpace(draft.Text))
                        list.Add(draft);
                }
            }
            catch { /* return whatever parsed */ }
            return list;
        }

        private static List<int> ParseDeletedIds(string json)
        {
            var list = new List<int>();
            if (string.IsNullOrWhiteSpace(json) || json == "[]") return list;
            try
            {
                var ser = new JavaScriptSerializer();
                var arr = ser.Deserialize<List<object>>(json);
                if (arr == null) return list;
                foreach (var v in arr)
                {
                    int parsed;
                    if (int.TryParse(v?.ToString(), out parsed) && parsed > 0)
                        list.Add(parsed);
                }
            }
            catch { /* ignore */ }
            return list;
        }

        private static int ToInt(Dictionary<string, object> d, string key)
        {
            object v;
            if (d == null || !d.TryGetValue(key, out v) || v == null) return 0;
            int parsed;
            return int.TryParse(v.ToString(), out parsed) ? parsed : 0;
        }

        private static string ToStr(Dictionary<string, object> d, string key)
        {
            object v;
            if (d == null || !d.TryGetValue(key, out v) || v == null) return null;
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
                && !double.IsNaN(parsed) && !double.IsInfinity(parsed) && parsed > 0)
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
            pnlSuccess.Visible = false;
        }

        private void ShowSuccess(string msg)
        {
            pnlSuccess.Visible = true;
            lblSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = false;
        }
    }
}
