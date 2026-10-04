using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;

namespace WAPP_FinalAssignment
{
    public partial class LearnerDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireLogin(this)) return;

            // Admins / Educators land on their own dashboards
            if (!SessionHelper.IsLearner)
            {
                Response.Redirect(SessionHelper.DashboardUrl(), false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
            lblWelcomeName.Text = HttpUtility.HtmlEncode(FirstName(SessionHelper.CurrentName));

            if (!IsPostBack)
            {
                int uid = SessionHelper.CurrentUserId;
                LoadStats(uid);
                LoadEnrolments(uid);
                LoadCompletedLessons(uid);
                LoadAttempts(uid);
            }
        }

        // ── Top-row stats ─────────────────────────────────────────────────
        private void LoadStats(int uid)
        {
            try
            {
                lblStatEnrolled.Text = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Enrolments WHERE userID = @u;",
                    Db.P("@u", uid)).ToString();

                lblStatCompleted.Text = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.LessonCompletions WHERE userID = @u;",
                    Db.P("@u", uid)).ToString();

                lblStatAttempts.Text = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.QuizAttempts WHERE userID = @u;",
                    Db.P("@u", uid)).ToString();

                double avg = Db.ExecuteScalar<double>(
                    "SELECT AVG(CAST(score AS FLOAT)) FROM dbo.QuizAttempts WHERE userID = @u;",
                    Db.P("@u", uid));
                lblStatAvgScore.Text = double.IsNaN(avg) || avg == 0
                    ? "—"
                    : Math.Round(avg).ToString(CultureInfo.InvariantCulture) + "%";
            }
            catch
            {
                lblStatEnrolled.Text = "0";
                lblStatCompleted.Text = "0";
                lblStatAttempts.Text = "0";
                lblStatAvgScore.Text = "—";
            }
        }

        // ── Enrolled courses with progress ────────────────────────────────
        private void LoadEnrolments(int uid)
        {
            try
            {
                const string sql = @"
                    SELECT
                        c.courseID, c.courseName, c.category, c.headerPictureURL,
                        e.enrollDate, e.status,
                        (SELECT COUNT(*) FROM dbo.Lessons l WHERE l.courseID = c.courseID) AS totalLessons,
                        ISNULL((
                           SELECT COUNT(*)
                             FROM dbo.LessonCompletions lc
                            INNER JOIN dbo.Lessons l ON l.lessonID = lc.lessonID
                            WHERE lc.userID = e.userID AND l.courseID = c.courseID
                        ), 0) AS lessonsDone
                      FROM dbo.Enrolments e
                     INNER JOIN dbo.Courses c ON c.courseID = e.courseID
                     WHERE e.userID = @u
                  ORDER BY e.enrollDate DESC;";

                var dt = Db.Query(sql, Db.P("@u", uid));

                if (!dt.Columns.Contains("progressPct"))
                    dt.Columns.Add("progressPct", typeof(int));

                foreach (DataRow r in dt.Rows)
                {
                    int total = Db.ToInt(r["totalLessons"]);
                    int done = Db.ToInt(r["lessonsDone"]);
                    int pct = (total <= 0) ? 0 : (int)Math.Min(100, Math.Round((double)done * 100 / total));
                    r["progressPct"] = pct;
                }

                rptEnrolledCourses.DataSource = dt;
                rptEnrolledCourses.DataBind();
            }
            catch
            {
                rptEnrolledCourses.DataSource = null;
                rptEnrolledCourses.DataBind();
            }
        }

        // ── Completed lessons (real, from LessonCompletions) ─────────────
        private void LoadCompletedLessons(int uid)
        {
            try
            {
                const string sql = @"
                    SELECT TOP 100
                        l.lessonID, l.lessonTitle, l.level,
                        c.courseName,
                        lc.dateCompleted
                      FROM dbo.LessonCompletions lc
                     INNER JOIN dbo.Lessons l ON l.lessonID = lc.lessonID
                     INNER JOIN dbo.Courses c ON c.courseID = l.courseID
                     WHERE lc.userID = @u
                  ORDER BY lc.dateCompleted DESC, lc.completionID DESC;";
                rptCompletedLessons.DataSource = Db.Query(sql, Db.P("@u", uid));
                rptCompletedLessons.DataBind();
            }
            catch
            {
                rptCompletedLessons.DataSource = null;
                rptCompletedLessons.DataBind();
            }
        }

        // ── Quiz attempts + JSON for the modal ────────────────────────────
        private void LoadAttempts(int uid)
        {
            try
            {
                const string sql = @"
                    SELECT
                        qa.attemptID, qa.score, qa.attemptDate,
                        q.quizTitle, q.passingScore,
                        c.courseName
                      FROM dbo.QuizAttempts qa
                     INNER JOIN dbo.Quizzes q ON q.quizID = qa.quizID
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE qa.userID = @u
                  ORDER BY qa.attemptDate DESC;";
                var dt = Db.Query(sql, Db.P("@u", uid));
                rptQuizAttempts.DataSource = dt;
                rptQuizAttempts.DataBind();

                // Build a JSON object the frontend can consume in showAttemptDetail
                hfAttemptData.Value = BuildAttemptJson(uid, dt);
            }
            catch
            {
                rptQuizAttempts.DataSource = null;
                rptQuizAttempts.DataBind();
                hfAttemptData.Value = "{}";
            }
        }

        private static string BuildAttemptJson(int uid, DataTable attemptsTable)
        {
            var sb = new StringBuilder();
            sb.Append("{");
            bool first = true;
            foreach (DataRow r in attemptsTable.Rows)
            {
                int aid = Db.ToInt(r["attemptID"]);
                if (aid <= 0) continue;
                if (!first) sb.Append(",");
                first = false;

                sb.Append("\"").Append(aid).Append("\":{");
                AppendJson(sb, "quizTitle", Db.ToStr(r["quizTitle"])); sb.Append(",");
                AppendJson(sb, "passingScore", Db.ToDouble(r["passingScore"]).ToString(CultureInfo.InvariantCulture), raw: true); sb.Append(",");
                AppendJson(sb, "score", Db.ToDouble(r["score"]).ToString(CultureInfo.InvariantCulture), raw: true); sb.Append(",");
                AppendJson(sb, "attemptDate", Db.ToDate(r["attemptDate"]).ToString("MMM d, yyyy")); sb.Append(",");

                // Pull per-question detail
                sb.Append("\"answers\":[");
                try
                {
                    const string qSql = @"
                        SELECT q.questionText, s.answer AS userAnswer, s.correctAnswer, s.isCorrect
                          FROM dbo.AttemptSummaries s
                         INNER JOIN dbo.QuizQuestions q ON q.questionID = s.questionID
                         WHERE s.attemptID = @a
                      ORDER BY s.summaryID;";
                    var qDt = Db.Query(qSql, Db.P("@a", aid));
                    bool firstQ = true;
                    foreach (DataRow qr in qDt.Rows)
                    {
                        if (!firstQ) sb.Append(",");
                        firstQ = false;
                        sb.Append("{");
                        AppendJson(sb, "questionText", Db.ToStr(qr["questionText"])); sb.Append(",");
                        AppendJson(sb, "userAnswer", Db.ToStr(qr["userAnswer"])); sb.Append(",");
                        AppendJson(sb, "correctAnswer", Db.ToStr(qr["correctAnswer"])); sb.Append(",");
                        sb.Append("\"isCorrect\":").Append(Db.ToBool(qr["isCorrect"]) ? "true" : "false");
                        sb.Append("}");
                    }
                }
                catch { /* don't break the page over a single attempt */ }

                sb.Append("]}");
            }
            sb.Append("}");
            return sb.ToString();
        }

        private static void AppendJson(StringBuilder sb, string name, string value, bool raw = false)
        {
            sb.Append("\"").Append(name).Append("\":");
            if (raw)
            {
                sb.Append(string.IsNullOrEmpty(value) ? "0" : value);
            }
            else
            {
                sb.Append("\"").Append(EscapeJson(value ?? "")).Append("\"");
            }
        }

        private static string EscapeJson(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return "";
            var sb = new StringBuilder(raw.Length + 4);
            foreach (char c in raw)
            {
                switch (c)
                {
                    case '\\': sb.Append("\\\\"); break;
                    case '\"': sb.Append("\\\""); break;
                    case '\b': sb.Append("\\b"); break;
                    case '\f': sb.Append("\\f"); break;
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

        private static string FirstName(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "Learner";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return parts.Length > 0 ? parts[0] : fullName;
        }
    }
}
