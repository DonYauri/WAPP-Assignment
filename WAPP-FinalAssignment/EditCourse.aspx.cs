using System;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;

namespace WAPP_FinalAssignment
{
    public partial class EditCourse : System.Web.UI.Page
    {
        protected int CourseID
        {
            get
            {
                int parsed;
                if (int.TryParse(Request.QueryString["courseID"], out parsed)) return parsed;
                if (int.TryParse(hfCourseID.Value, out parsed)) return parsed;
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

            // Wire up nav links + nav chip
            string id = CourseID.ToString();
            aCourseLink.HRef = "CoursePage.aspx?courseID=" + id;
            aViewCourse.HRef = "CoursePage.aspx?courseID=" + id;
            aAddLesson.HRef = "CreateLesson.aspx?courseID=" + id;
            aAddQuiz.HRef = "CreateQuiz.aspx?courseID=" + id;
            if (aAddLessonEmpty != null) aAddLessonEmpty.HRef = "CreateLesson.aspx?courseID=" + id;
            if (aAddQuizEmpty != null) aAddQuizEmpty.HRef = "CreateQuiz.aspx?courseID=" + id;

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);

            // Surface flash messages from create/edit lesson/quiz redirects
            string flash = Request.QueryString["msg"];
            if (!string.IsNullOrEmpty(flash))
            {
                string text = MapFlash(flash);
                if (!string.IsNullOrEmpty(text))
                {
                    pnlSuccess.Visible = true;
                    lblSuccess.Text = HttpUtility.HtmlEncode(text);
                }
            }

            if (!IsPostBack)
            {
                hfCourseID.Value = id;
                if (!LoadCourse()) return;
                LoadContent();
            }
        }

        // ── Load course details ───────────────────────────────────────────
        private bool LoadCourse()
        {
            try
            {
                const string sql = @"
                    SELECT c.courseID, c.userID, c.courseName, c.description,
                           c.category, c.duration, c.headerPictureURL, c.dateCreated
                      FROM dbo.Courses c
                     WHERE c.courseID = @c;";
                var row = Db.QueryOne(sql, Db.P("@c", CourseID));
                if (row == null)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=courseNotFound", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return false;
                }

                int ownerId = Db.ToInt(row["userID"]);
                if (!SessionHelper.IsAdmin && ownerId != SessionHelper.CurrentUserId)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=accessDenied", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return false;
                }

                string name = Db.ToStr(row["courseName"]);
                txtCourseName.Text = name;
                txtDescription.Text = Db.ToStr(row["description"]);
                hfCategory.Value = Db.ToStr(row["category"]);
                txtDuration.Text = Db.ToDouble(row["duration"]).ToString("0.#", CultureInfo.InvariantCulture);
                txtHeaderImageURL.Text = Db.ToStr(row["headerPictureURL"]);

                lblBreadcrumbCourseName.Text = HttpUtility.HtmlEncode(name);
                lblSaveBarName.Text = HttpUtility.HtmlEncode(name);
                lblStatCreated.Text = Db.ToDate(row["dateCreated"]).ToString("MMM d, yyyy");
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not load this course.");
                return false;
            }
        }

        // ── Lessons + quizzes + counters ──────────────────────────────────
        private void LoadContent()
        {
            try
            {
                rptLessons.DataSource = Db.Query(@"
                    SELECT lessonID, lessonTitle, level, duration, dateCreated
                      FROM dbo.Lessons WHERE courseID = @c
                  ORDER BY dateCreated;",
                    Db.P("@c", CourseID));
                rptLessons.DataBind();

                rptQuizzes.DataSource = Db.Query(@"
                    SELECT q.quizID, q.quizTitle, q.passingScore, q.dateCreated,
                           (SELECT COUNT(*) FROM dbo.QuizQuestions WHERE quizID = q.quizID) AS questionCount
                      FROM dbo.Quizzes q WHERE q.courseID = @c
                  ORDER BY q.dateCreated;",
                    Db.P("@c", CourseID));
                rptQuizzes.DataBind();

                int lessons = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Lessons WHERE courseID = @c;",
                    Db.P("@c", CourseID));
                int quizzes = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Quizzes WHERE courseID = @c;",
                    Db.P("@c", CourseID));
                int enrolled = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Enrolments WHERE courseID = @c;",
                    Db.P("@c", CourseID));

                lblStatLessons.Text = lessons.ToString();
                lblStatQuizzes.Text = quizzes.ToString();
                lblStatEnrolled.Text = enrolled.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                lblStatLessons.Text = "0";
                lblStatQuizzes.Text = "0";
                lblStatEnrolled.Text = "0";
                rptLessons.DataSource = null;
                rptLessons.DataBind();
                rptQuizzes.DataSource = null;
                rptQuizzes.DataBind();
            }
        }

        // ── Save course ───────────────────────────────────────────────────
        protected void btnSaveCourse_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = (txtCourseName.Text ?? "").Trim();
            string desc = (txtDescription.Text ?? "").Trim();
            string category = (hfCategory.Value ?? "").Trim();
            string headerImage = (txtHeaderImageURL.Text ?? "").Trim();

            if (name.Length == 0 || name.Length > 50)
            { ShowError("Course name is required (≤ 50 chars)."); return; }
            if (desc.Length == 0 || desc.Length > 200)
            { ShowError("Description is required (≤ 200 chars)."); return; }
            if (string.IsNullOrEmpty(category))
            { ShowError("Please pick a category."); return; }
            if (headerImage.Length == 0 || headerImage.Length > 255)
            { ShowError("Header image URL is required (≤ 255 chars)."); return; }
            if (!headerImage.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
                && !headerImage.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            { ShowError("Header image URL must start with http:// or https://."); return; }

            double duration;
            if (!double.TryParse((txtDuration.Text ?? "").Trim(),
                NumberStyles.Float, CultureInfo.InvariantCulture, out duration)
                || double.IsNaN(duration) || double.IsInfinity(duration)
                || duration < 1 || duration > 500)
            { ShowError("Duration must be between 1 and 500 hours."); return; }

            try
            {
                int affected = Db.ExecuteNonQuery(@"
                    UPDATE dbo.Courses
                       SET courseName = @n, description = @d, category = @cat,
                           duration = @dur, headerPictureURL = @img
                     WHERE courseID = @c
                       AND (@isAdmin = 1 OR userID = @u);",
                    Db.P("@n", name),
                    Db.P("@d", desc),
                    Db.P("@cat", category),
                    Db.P("@dur", duration),
                    Db.P("@img", headerImage),
                    Db.P("@c", CourseID),
                    Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                    Db.P("@u", SessionHelper.CurrentUserId));

                if (affected == 0)
                { ShowError("Course not found or you do not have permission."); return; }

                ShowSuccess("Course saved successfully.");
                LoadCourse();
                LoadContent();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not save course: " + ex.Message);
            }
        }

        // ── Delete course ─────────────────────────────────────────────────
        protected void btnDeleteCourse_Click(object sender, EventArgs e)
        {
            if (CourseID <= 0)
            {
                ShowError("No course id available.");
                return;
            }

            // Re-check ownership
            try
            {
                int allowed = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Courses
                     WHERE courseID = @c
                       AND (@isAdmin = 1 OR userID = @u);",
                    Db.P("@c", CourseID),
                    Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                    Db.P("@u", SessionHelper.CurrentUserId));
                if (allowed == 0) { ShowError("You do not have permission to delete this course."); return; }

                Db.RunInTransaction((conn, tx) =>
                    ProfilePage.CascadeDeleteCourse(conn, tx, CourseID));

                Response.Redirect("EducatorDashboard.aspx?msg=courseDeleted", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not delete course. Please try again.");
            }
        }

        // ── Lesson row delete ─────────────────────────────────────────────
        protected void rptLessons_ItemCommand(object source, ListViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteLesson") return;

            int lessonId = Db.ToInt(e.CommandArgument);
            if (lessonId <= 0) { ShowError("Invalid lesson selected."); return; }

            try
            {
                int affected = 0;
                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.LessonCompletions WHERE lessonID = @id;",
                        Db.P("@id", lessonId));
                    affected = Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.Lessons
                         WHERE lessonID = @id
                           AND courseID = @c
                           AND (@isAdmin = 1 OR courseID IN (SELECT courseID FROM dbo.Courses WHERE userID = @u));",
                        Db.P("@id", lessonId),
                        Db.P("@c", CourseID),
                        Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                        Db.P("@u", SessionHelper.CurrentUserId));
                });
                if (affected == 0) { ShowError("Lesson not found or not yours."); return; }
                ShowSuccess("Lesson deleted.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not delete lesson.");
            }
            LoadContent();
        }

        // ── Quiz row delete (cascade through attempts) ────────────────────
        protected void rptQuizzes_ItemCommand(object source, ListViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteQuiz") return;

            int quizId = Db.ToInt(e.CommandArgument);
            if (quizId <= 0) { ShowError("Invalid quiz selected."); return; }

            try
            {
                int allowed = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Quizzes q
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                     WHERE q.quizID = @id AND q.courseID = @c
                       AND (@isAdmin = 1 OR c.userID = @u);",
                    Db.P("@id", quizId),
                    Db.P("@c", CourseID),
                    Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                    Db.P("@u", SessionHelper.CurrentUserId));
                if (allowed == 0) { ShowError("Quiz not found or not yours."); return; }

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

                ShowSuccess("Quiz deleted.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not delete quiz.");
            }
            LoadContent();
        }

        // ── Helpers ───────────────────────────────────────────────────────
        private static string MapFlash(string code)
        {
            switch (code)
            {
                case "lessonCreated": return "Lesson created.";
                case "lessonDeleted": return "Lesson deleted.";
                case "quizCreated":   return "Quiz created.";
                case "quizDeleted":   return "Quiz deleted.";
                case "courseUpdated": return "Course updated.";
                default: return "";
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = HttpUtility.HtmlEncode(message);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }

        private void ShowSuccess(string message)
        {
            lblSuccess.Text = HttpUtility.HtmlEncode(message);
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }
    }
}
