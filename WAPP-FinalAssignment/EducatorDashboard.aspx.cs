using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WAPP_FinalAssignment
{
    public partial class EducatorDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireRole(this, SessionHelper.RoleEducator, SessionHelper.RoleAdmin))
                return;

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
            lblWelcomeName.Text = HttpUtility.HtmlEncode(FirstName(SessionHelper.CurrentName));

            // Bind nested repeaters as each course row binds
            rptCourses.ItemDataBound += rptCourses_ItemDataBound;

            string flash = Request.QueryString["msg"];
            if (!string.IsNullOrEmpty(flash))
            {
                pnlMessage.Visible = true;
                lblMessage.Text = HttpUtility.HtmlEncode(MapFlash(flash));
            }

            if (!IsPostBack)
            {
                LoadStats();
                LoadCourses();
            }
        }

        private void LoadStats()
        {
            try
            {
                int uid = SessionHelper.CurrentUserId;
                lblStatCourses.Text = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Courses WHERE userID = @u;",
                    Db.P("@u", uid)).ToString();

                lblStatLessons.Text = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Lessons l
                     INNER JOIN dbo.Courses c ON c.courseID = l.courseID
                     WHERE c.userID = @u;",
                    Db.P("@u", uid)).ToString();

                lblStatQuizzes.Text = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Quizzes q
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE c.userID = @u;",
                    Db.P("@u", uid)).ToString();

                lblStatLearners.Text = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Enrolments e
                     INNER JOIN dbo.Courses c ON c.courseID = e.courseID
                     WHERE c.userID = @u;",
                    Db.P("@u", uid)).ToString();
            }
            catch
            {
                lblStatCourses.Text = "0";
                lblStatLessons.Text = "0";
                lblStatQuizzes.Text = "0";
                lblStatLearners.Text = "0";
            }
        }

        private void LoadCourses()
        {
            try
            {
                int uid = SessionHelper.CurrentUserId;
                const string sql = @"
                    SELECT c.courseID, c.courseName, c.description, c.category,
                           c.duration, c.headerPictureURL, c.dateCreated,
                           (SELECT COUNT(*) FROM dbo.Lessons    WHERE courseID = c.courseID) AS lessonCount,
                           (SELECT COUNT(*) FROM dbo.Quizzes    WHERE courseID = c.courseID) AS quizCount,
                           (SELECT COUNT(*) FROM dbo.Enrolments WHERE courseID = c.courseID) AS enrolmentCount
                      FROM dbo.Courses c
                     WHERE c.userID = @u
                  ORDER BY c.dateCreated DESC;";
                rptCourses.DataSource = Db.Query(sql, Db.P("@u", uid));
                rptCourses.DataBind();
            }
            catch
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();
            }
        }

        // ── Bind nested rptCourseLessons / rptCourseQuizzes for each course ──
        protected void rptCourses_ItemDataBound(object sender, ListViewItemEventArgs e)
        {
            if (e.Item.ItemType != ListViewItemType.DataItem) return;
            var dataItem = e.Item as ListViewDataItem;
            if (dataItem == null) return;

            int courseId = Db.ToInt(DataBinder.Eval(dataItem.DataItem, "courseID"));
            if (courseId <= 0) return;

            var rptLessons = e.Item.FindControl("rptCourseLessons") as ListView;
            var rptQuizzes = e.Item.FindControl("rptCourseQuizzes") as ListView;

            if (rptLessons != null)
            {
                try
                {
                    rptLessons.DataSource = Db.Query(@"
                        SELECT lessonID, lessonTitle, level, duration
                          FROM dbo.Lessons WHERE courseID = @c
                      ORDER BY dateCreated DESC;",
                        Db.P("@c", courseId));
                    rptLessons.DataBind();
                }
                catch { /* leave list empty */ }
            }

            if (rptQuizzes != null)
            {
                try
                {
                    rptQuizzes.DataSource = Db.Query(@"
                        SELECT q.quizID, q.quizTitle, q.passingScore,
                               (SELECT COUNT(*) FROM dbo.QuizQuestions WHERE quizID = q.quizID) AS questionCount
                          FROM dbo.Quizzes q WHERE q.courseID = @c
                      ORDER BY q.dateCreated DESC;",
                        Db.P("@c", courseId));
                    rptQuizzes.DataBind();
                }
                catch { /* leave list empty */ }
            }
        }

        // ── Delete course (top-level button on each card) ────────────────
        protected void btnDeleteCourse_Click(object sender, EventArgs e)
        {
            int courseId = ParseArg(sender);
            if (courseId <= 0) { Flash("Invalid course id."); return; }
            if (!OwnsCourse(courseId)) { Flash("You can only delete your own courses."); return; }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                    ProfilePage.CascadeDeleteCourse(conn, tx, courseId));
                Flash("Course deleted.");
            }
            catch (Exception ex) { LogAndFlash("Could not delete course.", ex); }

            LoadStats();
            LoadCourses();
        }

        protected void btnDeleteLesson_Click(object sender, EventArgs e)
        {
            int lessonId = ParseArg(sender);
            if (lessonId <= 0) { Flash("Invalid lesson id."); return; }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.LessonCompletions WHERE lessonID = @id;",
                        Db.P("@id", lessonId));
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.Lessons
                         WHERE lessonID = @id
                           AND courseID IN (SELECT courseID FROM dbo.Courses WHERE userID = @u);",
                        Db.P("@id", lessonId),
                        Db.P("@u", SessionHelper.CurrentUserId));
                });
                Flash("Lesson deleted.");
            }
            catch (Exception ex) { LogAndFlash("Could not delete lesson.", ex); }

            LoadStats();
            LoadCourses();
        }

        protected void btnDeleteQuiz_Click(object sender, EventArgs e)
        {
            int quizId = ParseArg(sender);
            if (quizId <= 0) { Flash("Invalid quiz id."); return; }

            try
            {
                // Confirm ownership before cascading
                int owned = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Quizzes q
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE q.quizID = @id AND c.userID = @u;",
                    Db.P("@id", quizId),
                    Db.P("@u", SessionHelper.CurrentUserId));
                if (owned == 0) { Flash("Quiz not found or not owned."); return; }

                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.AttemptSummaries
                         WHERE attemptID IN (SELECT attemptID FROM dbo.QuizAttempts WHERE quizID = @id);",
                        Db.P("@id", quizId));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.QuizAttempts WHERE quizID = @id;",
                        Db.P("@id", quizId));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.QuizQuestions WHERE quizID = @id;",
                        Db.P("@id", quizId));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.Quizzes WHERE quizID = @id;",
                        Db.P("@id", quizId));
                });
                Flash("Quiz deleted.");
            }
            catch (Exception ex) { LogAndFlash("Could not delete quiz.", ex); }

            LoadStats();
            LoadCourses();
        }

        // ── Helpers ───────────────────────────────────────────────────────
        private bool OwnsCourse(int courseId)
        {
            try
            {
                int hits = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Courses WHERE courseID = @c AND userID = @u;",
                    Db.P("@c", courseId),
                    Db.P("@u", SessionHelper.CurrentUserId));
                return hits > 0 || SessionHelper.IsAdmin;
            }
            catch { return false; }
        }

        private static int ParseArg(object sender)
        {
            var btn = sender as Button;
            return btn == null ? 0 : Db.ToInt(btn.CommandArgument);
        }

        private void Flash(string message)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = HttpUtility.HtmlEncode(message);
        }

        private void LogAndFlash(string message, Exception ex)
        {
            try { System.Diagnostics.Debug.WriteLine(ex?.ToString()); } catch { }
            Flash(message);
        }

        private static string MapFlash(string code)
        {
            switch (code)
            {
                case "courseDeleted": return "Course deleted.";
                case "courseCreated": return "Course created.";
                case "courseUpdated": return "Course updated.";
                default: return "";
            }
        }

        private static string FirstName(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "Educator";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return parts.Length > 0 ? parts[0] : fullName;
        }
    }
}
