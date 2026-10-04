using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Web;
using System.Web.Script.Serialization;

namespace WAPP_FinalAssignment
{
    public partial class QuizPage : System.Web.UI.Page
    {
        private int QuizID
        {
            get
            {
                int v;
                return int.TryParse(Request.QueryString["quizID"], out v) ? v : 0;
            }
        }

        private int _courseId;
        private int _courseOwnerId;
        private double _passingScore;
        private DataTable _questionsCache; // cached so submit handler can re-read

        protected void Page_Load(object sender, EventArgs e)
        {
            if (QuizID <= 0)
            {
                Response.Redirect("HomePage.aspx?msg=quizNotFound", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ApplyNavState();

            if (!LoadQuiz()) return;
            ApplyGateAndOptions();
            LoadQuestions();
        }

        // ── Nav state ─────────────────────────────────────────────────────
        private void ApplyNavState()
        {
            bool loggedIn = SessionHelper.IsLoggedIn;
            phNavLoggedIn.Visible = loggedIn;
            phNavUser.Visible = loggedIn;
            phNavLoggedOut.Visible = !loggedIn;
            if (loggedIn)
            {
                lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
                lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
                aNavDashboard.HRef = SessionHelper.DashboardUrl();
            }
        }

        private bool LoadQuiz()
        {
            try
            {
                const string sql = @"
                    SELECT q.quizID, q.quizTitle, q.description, q.passingScore, q.dateCreated,
                           q.readme, q.videoURL,
                           q.courseID, c.courseName, c.userID AS ownerID
                      FROM dbo.Quizzes q
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE q.quizID = @id;";
                var row = Db.QueryOne(sql, Db.P("@id", QuizID));
                if (row == null)
                {
                    Response.Redirect("HomePage.aspx?msg=quizNotFound", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return false;
                }

                _courseId = Db.ToInt(row["courseID"]);
                _courseOwnerId = Db.ToInt(row["ownerID"]);
                _passingScore = Db.ToDouble(row["passingScore"], 70d);

                string title = Db.ToStr(row["quizTitle"]);
                string desc = Db.ToStr(row["description"]);
                string readme = Db.ToStr(row["readme"]);
                string videoUrl = Db.ToStr(row["videoURL"]);
                string courseName = Db.ToStr(row["courseName"], "Course");

                litPageTitle.Text = HttpUtility.HtmlEncode(title);
                lblQuizTitle.Text = HttpUtility.HtmlEncode(title);
                lblQuizTitleHeader.Text = HttpUtility.HtmlEncode(title);
                lblQuizTitleIntro.Text = HttpUtility.HtmlEncode(title);
                lblQuizDesc.Text = HttpUtility.HtmlEncode(desc);
                lblQuizDescIntro.Text = HttpUtility.HtmlEncode(desc);
                lblPassingScore.Text = ((int)Math.Round(_passingScore)).ToString();
                lblPassingScoreResult.Text = lblPassingScore.Text;

                lblCourseName.Text = HttpUtility.HtmlEncode(courseName);
                aCourseBreadcrumb.HRef = "CoursePage.aspx?courseID=" + _courseId;
                aBackToCourse.HRef = "CoursePage.aspx?courseID=" + _courseId;
                aRetakeQuiz.HRef = "QuizPage.aspx?quizID=" + QuizID;
                aEnrolLink.HRef = "CoursePage.aspx?courseID=" + _courseId;

                if (!string.IsNullOrWhiteSpace(videoUrl))
                {
                    phIntroVideo.Visible = true;
                    string embed = LessonPage.ToEmbedUrl(videoUrl);
                    string safe = HttpUtility.HtmlAttributeEncode(embed);
                    litIntroVideo.Text =
                        $"<iframe src=\"{safe}\" style=\"width:100%;height:100%;border:none;\" allowfullscreen></iframe>";
                }

                if (!string.IsNullOrWhiteSpace(readme))
                {
                    phIntroReadme.Visible = true;
                    litIntroReadme.Text = LessonPage.RenderMarkdownPublic(readme);
                }

                if (CanEdit())
                {
                    phEducatorOptions.Visible = true;
                    aEditQuizBtn.HRef = "EditQuiz.aspx?quizID=" + QuizID;
                }

                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                Response.Redirect("HomePage.aspx?msg=quizNotFound", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
        }

        private bool CanEdit()
        {
            return SessionHelper.IsAdmin
                || (SessionHelper.IsEducator && _courseOwnerId == SessionHelper.CurrentUserId);
        }

        private void ApplyGateAndOptions()
        {
            // Educators / admins: bypass the enrolment gate
            if (CanEdit()) return;

            if (!SessionHelper.IsLoggedIn)
            {
                phLoginGate.Visible = true;
                phSubmitButton.Visible = false;
                return;
            }
            try
            {
                int hits = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Enrolments
                     WHERE userID = @u AND courseID = @c;",
                    Db.P("@u", SessionHelper.CurrentUserId),
                    Db.P("@c", _courseId));
                if (hits == 0)
                {
                    phEnrolGate.Visible = true;
                    phSubmitButton.Visible = false;
                }
            }
            catch
            {
                phEnrolGate.Visible = true;
                phSubmitButton.Visible = false;
            }
        }

        // ── Load questions ────────────────────────────────────────────────
        private void LoadQuestions()
        {
            try
            {
                const string sql = @"
                    SELECT questionID, questionText, questionsScore,
                           optionA, optionB, optionC, optionD, correctAnswer
                      FROM dbo.QuizQuestions
                     WHERE quizID = @q
                  ORDER BY questionID;";
                _questionsCache = Db.Query(sql, Db.P("@q", QuizID));
                rptQuestions.DataSource = _questionsCache;
                rptQuestions.DataBind();
                lblTotalQuestions.Text = _questionsCache.Rows.Count.ToString();
                lblQCount.Text = _questionsCache.Rows.Count.ToString();
            }
            catch
            {
                rptQuestions.DataSource = null;
                rptQuestions.DataBind();
                lblTotalQuestions.Text = "0";
                lblQCount.Text = "0";
            }
        }

        // ── Submit & score ────────────────────────────────────────────────
        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsLoggedIn)
            {
                Response.Redirect("HomePage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            int uid = SessionHelper.CurrentUserId;

            // Decode answers JSON {questionID:"A", ...}
            Dictionary<string, string> answers = new Dictionary<string, string>(StringComparer.Ordinal);
            string raw = hfAnswers.Value ?? "";
            if (!string.IsNullOrEmpty(raw))
            {
                try
                {
                    var serializer = new JavaScriptSerializer();
                    var obj = serializer.Deserialize<Dictionary<string, object>>(raw);
                    if (obj != null)
                        foreach (var kv in obj)
                            answers[kv.Key] = (kv.Value ?? "").ToString();
                }
                catch
                {
                    // Fall through with empty dict — every answer counted as wrong
                }
            }

            // Re-read questions from DB to score authoritatively (don't trust client)
            DataTable questions;
            try
            {
                questions = Db.Query(@"
                    SELECT questionID, questionsScore, correctAnswer
                      FROM dbo.QuizQuestions WHERE quizID = @q;",
                    Db.P("@q", QuizID));
            }
            catch
            {
                Response.Redirect("HomePage.aspx?msg=quizError", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (questions.Rows.Count == 0)
            {
                Response.Redirect("CoursePage.aspx?courseID=" + _courseId, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            double earned = 0d;
            double total = 0d;
            int correctCount = 0;
            var summaries = new List<(int qid, string user, string correct, bool ok)>();

            foreach (DataRow r in questions.Rows)
            {
                int qid = Db.ToInt(r["questionID"]);
                double pts = Db.ToDouble(r["questionsScore"], 1d);
                if (double.IsNaN(pts) || pts <= 0) pts = 1d;
                total += pts;

                string correct = Db.ToStr(r["correctAnswer"]);
                string userAns;
                answers.TryGetValue(qid.ToString(), out userAns);
                userAns = (userAns ?? "").Trim().ToUpperInvariant();
                bool ok = !string.IsNullOrEmpty(correct)
                          && string.Equals(userAns, correct.Trim().ToUpperInvariant(), StringComparison.Ordinal);
                if (ok) { earned += pts; correctCount++; }
                summaries.Add((qid, userAns, correct, ok));
            }

            double pct = total <= 0 ? 0d : (earned * 100d / total);
            if (double.IsNaN(pct) || double.IsInfinity(pct)) pct = 0d;

            int attemptId = 0;
            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    using (var cmd = new System.Data.SqlClient.SqlCommand(@"
                        INSERT INTO dbo.QuizAttempts (userID, quizID, score, attemptDate)
                        VALUES (@u, @q, @s, @d);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@u", uid);
                        cmd.Parameters.AddWithValue("@q", QuizID);
                        cmd.Parameters.AddWithValue("@s", Math.Round(pct, 2));
                        cmd.Parameters.AddWithValue("@d", DateTime.Today);
                        var raw2 = cmd.ExecuteScalar();
                        attemptId = raw2 == null ? 0 : Db.ToInt(raw2);
                    }

                    foreach (var s in summaries)
                    {
                        Db.ExecuteNonQueryTx(conn, tx, @"
                            INSERT INTO dbo.AttemptSummaries
                                (attemptID, questionID, answer, isCorrect, correctAnswer)
                            VALUES
                                (@a, @qid, @ans, @ok, @cor);",
                            Db.P("@a", attemptId),
                            Db.P("@qid", s.qid),
                            Db.P("@ans", string.IsNullOrEmpty(s.user) ? null : (object)s.user),
                            Db.P("@ok", s.ok ? 1 : 0),
                            Db.P("@cor", s.correct));
                    }

                    // Mark enrolment completed if learner passed and not already completed
                    if (pct >= _passingScore)
                    {
                        Db.ExecuteNonQueryTx(conn, tx, @"
                            UPDATE dbo.Enrolments
                               SET status = 'Completed'
                             WHERE userID = @u AND courseID = @c AND status <> 'Completed';",
                            Db.P("@u", uid),
                            Db.P("@c", _courseId));
                    }
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                // Show result page anyway so the user sees their score
            }

            // Render result panel
            phQuizForm.Visible = false;
            phResult.Visible = true;

            bool passed = pct >= _passingScore;
            lblFinalScore.Text = ((int)Math.Round(pct)).ToString(CultureInfo.InvariantCulture);
            lblResultTitle.Text = passed ? "🎉 You passed!" : "Not yet — keep practising.";
            lblCorrectCount.Text = correctCount.ToString();
            lblTotalCount.Text = questions.Rows.Count.ToString();
            pnlResultInner.CssClass = passed ? "" : "failed";

            // Bind detailed review
            try
            {
                const string reviewSql = @"
                    SELECT q.questionText, q.optionA, q.optionB, q.optionC, q.optionD,
                           s.correctAnswer, s.answer AS userAnswer, s.isCorrect
                      FROM dbo.AttemptSummaries s
                     INNER JOIN dbo.QuizQuestions q ON q.questionID = s.questionID
                     WHERE s.attemptID = @a
                  ORDER BY s.summaryID;";
                rptAnswerReview.DataSource = Db.Query(reviewSql, Db.P("@a", attemptId));
                rptAnswerReview.DataBind();
            }
            catch
            {
                rptAnswerReview.DataSource = null;
                rptAnswerReview.DataBind();
            }
        }
    }
}
