using System;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;

namespace WAPP_FinalAssignment
{
    public partial class CoursePage : System.Web.UI.Page
    {
        private int CourseID
        {
            get
            {
                int v;
                return int.TryParse(Request.QueryString["courseID"], out v) ? v : 0;
            }
        }

        private int _courseOwnerId;
        private int _totalLessons;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CourseID <= 0)
            {
                Response.Redirect("HomePage.aspx?msg=courseNotFound", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ApplyNavState();

            if (!IsPostBack)
            {
                LoadCourse();
                LoadLessons();
                LoadQuizzes();
                ApplyActionBar();
                LoadProgress();
            }
        }

        // ── Nav state ─────────────────────────────────────────────────────
        private void ApplyNavState()
        {
            bool loggedIn = SessionHelper.IsLoggedIn;
            phNavLoggedOut.Visible = !loggedIn;
            phNavUser.Visible = loggedIn;
            phNavLoggedIn.Visible = loggedIn;
            if (loggedIn)
            {
                lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
                lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
                lblNavRole.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentRole);
                aNavDashboard.HRef = SessionHelper.DashboardUrl();
            }
        }

        // ── Load course details ───────────────────────────────────────────
        private void LoadCourse()
        {
            try
            {
                const string sql = @"
                    SELECT c.courseID, c.courseName, c.description, c.category,
                           c.duration, c.headerPictureURL, c.dateCreated, c.userID,
                           u.name AS instructorName,
                           (SELECT COUNT(*) FROM dbo.Lessons    WHERE courseID = c.courseID) AS lessonCount,
                           (SELECT COUNT(*) FROM dbo.Quizzes    WHERE courseID = c.courseID) AS quizCount,
                           (SELECT COUNT(*) FROM dbo.Enrolments WHERE courseID = c.courseID) AS enrolmentCount
                      FROM dbo.Courses c
                      LEFT JOIN dbo.Users u ON u.userID = c.userID
                     WHERE c.courseID = @c;";
                var row = Db.QueryOne(sql, Db.P("@c", CourseID));
                if (row == null)
                {
                    Response.Redirect("HomePage.aspx?msg=courseNotFound", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                string courseName = Db.ToStr(row["courseName"]);
                string desc = Db.ToStr(row["description"]);
                string category = Db.ToStr(row["category"]);
                double duration = Db.ToDouble(row["duration"]);
                string image = Db.ToStr(row["headerPictureURL"]);
                DateTime created = Db.ToDate(row["dateCreated"]);
                _courseOwnerId = Db.ToInt(row["userID"]);
                string instructor = Db.ToStr(row["instructorName"], "Unknown educator");
                int lessons = Db.ToInt(row["lessonCount"]);
                int quizzes = Db.ToInt(row["quizCount"]);
                int enrolled = Db.ToInt(row["enrolmentCount"]);
                _totalLessons = lessons;

                litPageTitle.Text = HttpUtility.HtmlEncode(courseName);
                lblCourseName.Text = HttpUtility.HtmlEncode(courseName);
                lblCourseTitleHero.Text = HttpUtility.HtmlEncode(courseName);
                lblCourseCategory.Text = HttpUtility.HtmlEncode(string.IsNullOrEmpty(category) ? "General" : category);
                lblCourseDesc.Text = HttpUtility.HtmlEncode(desc);
                if (!string.IsNullOrEmpty(image)) imgCourseHero.ImageUrl = image;
                lblInstructor.Text = HttpUtility.HtmlEncode(instructor);
                lblInstructorSidebar.Text = HttpUtility.HtmlEncode(instructor);
                lblInstructorInitial.Text = string.IsNullOrEmpty(instructor)
                    ? "E"
                    : instructor.Trim().Substring(0, 1).ToUpperInvariant();
                lblDuration.Text = duration.ToString("0.#");
                lblDateCreated.Text = created.ToString("MMM d, yyyy");
                lblLessonCount.Text = lessons.ToString();
                lblQuizCount.Text = quizzes.ToString();
                lblSidebarLessons.Text = lessons.ToString();
                lblSidebarQuizzes.Text = quizzes.ToString();
                lblSidebarDuration.Text = duration.ToString("0.#");
                lblEnrolmentCount.Text = enrolled.ToString();
                lblOverview.Text = HttpUtility.HtmlEncode(desc);

                // Wire up educator action links
                aEditCourse.HRef = "EditCourse.aspx?courseID=" + CourseID;
                aCreateLesson.HRef = "CreateLesson.aspx?courseID=" + CourseID;
                aCreateQuiz.HRef = "CreateQuiz.aspx?courseID=" + CourseID;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                Flash("Could not load this course right now.");
            }
        }

        // ── Lessons / Quizzes ─────────────────────────────────────────────
        private void LoadLessons()
        {
            try
            {
                rptLessons.ItemDataBound += RptLessons_ItemDataBound;
                rptLessons.DataSource = Db.Query(@"
                    SELECT lessonID, lessonTitle, level, duration, dateCreated
                      FROM dbo.Lessons WHERE courseID = @c
                  ORDER BY dateCreated;",
                    Db.P("@c", CourseID));
                rptLessons.DataBind();
            }
            catch
            {
                rptLessons.DataSource = null;
                rptLessons.DataBind();
            }
        }

        private void LoadQuizzes()
        {
            try
            {
                rptQuizzes.ItemDataBound += RptQuizzes_ItemDataBound;
                rptQuizzes.DataSource = Db.Query(@"
                    SELECT quizID, quizTitle, passingScore, dateCreated
                      FROM dbo.Quizzes WHERE courseID = @c
                  ORDER BY dateCreated;",
                    Db.P("@c", CourseID));
                rptQuizzes.DataBind();
            }
            catch
            {
                rptQuizzes.DataSource = null;
                rptQuizzes.DataBind();
            }
        }

        private void RptLessons_ItemDataBound(object sender, ListViewItemEventArgs e)
        {
            if (e.Item.ItemType != ListViewItemType.DataItem) return;
            var ph = e.Item.FindControl("phLessonEdit") as PlaceHolder;
            if (ph != null) ph.Visible = CanEdit();
        }

        private void RptQuizzes_ItemDataBound(object sender, ListViewItemEventArgs e)
        {
            if (e.Item.ItemType != ListViewItemType.DataItem) return;
            var ph = e.Item.FindControl("phQuizEdit") as PlaceHolder;
            if (ph != null) ph.Visible = CanEdit();
        }

        // ── Action bar visibility ────────────────────────────────────────
        private void ApplyActionBar()
        {
            bool isLoggedIn = SessionHelper.IsLoggedIn;
            bool isOwner = isLoggedIn && _courseOwnerId == SessionHelper.CurrentUserId;
            bool isAdmin = SessionHelper.IsAdmin;

            // Educator actions for owner or admin
            phEducatorActions.Visible = isOwner || isAdmin;
            phAdminActions.Visible = isAdmin && !isOwner; // hide redundant delete if educator already sees Edit

            if (!isLoggedIn)
            {
                phLoginPrompt.Visible = true;
                phEnrolled.Visible = false;
                phEnrolButton.Visible = false;
                return;
            }

            if (SessionHelper.IsLearner)
            {
                bool enrolled = false;
                try
                {
                    enrolled = Db.ExecuteScalar<int>(@"
                        SELECT COUNT(*) FROM dbo.Enrolments
                         WHERE userID = @u AND courseID = @c;",
                        Db.P("@u", SessionHelper.CurrentUserId),
                        Db.P("@c", CourseID)) > 0;
                }
                catch { /* assume not enrolled on error */ }

                phEnrolled.Visible = enrolled;
                phEnrolButton.Visible = !enrolled;
            }
            else
            {
                // Educators / admins viewing courses don't see enrol buttons
                phEnrolled.Visible = false;
                phEnrolButton.Visible = false;
            }
        }

        // ── Learner progress block ───────────────────────────────────────
        private void LoadProgress()
        {
            if (!SessionHelper.IsLearner) return;

            try
            {
                int uid = SessionHelper.CurrentUserId;

                var enrol = Db.QueryOne(@"
                    SELECT status FROM dbo.Enrolments
                     WHERE userID = @u AND courseID = @c;",
                    Db.P("@u", uid),
                    Db.P("@c", CourseID));
                if (enrol == null) return;

                phProgressBlock.Visible = true;
                lblEnrolStatus.Text = HttpUtility.HtmlEncode(Db.ToStr(enrol["status"], "Active"));

                int doneLessons = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*)
                      FROM dbo.LessonCompletions lc
                     INNER JOIN dbo.Lessons l ON l.lessonID = lc.lessonID
                     WHERE lc.userID = @u AND l.courseID = @c;",
                    Db.P("@u", uid),
                    Db.P("@c", CourseID));

                int pct = (_totalLessons <= 0) ? 0
                    : (int)Math.Min(100, Math.Round((double)doneLessons * 100 / _totalLessons));
                lblProgressPct.Text = pct.ToString();
                pnlProgressBar.Style["width"] = pct + "%";
                if (pct >= 100) pnlProgressBar.CssClass = "progress-bar green";

                // Quiz progress: how many distinct quizzes in this course the learner has passed at least once
                int totalQuizzes = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Quizzes WHERE courseID = @c;",
                    Db.P("@c", CourseID));
                int passedQuizzes = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(DISTINCT q.quizID)
                      FROM dbo.QuizAttempts qa
                     INNER JOIN dbo.Quizzes q ON q.quizID = qa.quizID
                     WHERE qa.userID = @u AND q.courseID = @c
                       AND qa.score >= q.passingScore;",
                    Db.P("@u", uid),
                    Db.P("@c", CourseID));

                int qpct = (totalQuizzes <= 0) ? 0
                    : (int)Math.Min(100, Math.Round((double)passedQuizzes * 100 / totalQuizzes));
                lblQuizProgressPct.Text = qpct.ToString();
                pnlQuizProgressBar.Style["width"] = qpct + "%";
                if (qpct >= 100) pnlQuizProgressBar.CssClass = "progress-bar green";
                lblQuizProgressDetail.Text = string.Format("{0} / {1} quiz{2} passed",
                    passedQuizzes, totalQuizzes, totalQuizzes == 1 ? "" : "zes");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
            }
        }

        // ── Enrol / unenrol ──────────────────────────────────────────────
        protected void btnEnrol_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsLearner)
            {
                Flash("Only learners can enrol.");
                return;
            }
            try
            {
                int uid = SessionHelper.CurrentUserId;
                int already = Db.ExecuteScalar<int>(
                    "SELECT COUNT(*) FROM dbo.Enrolments WHERE userID = @u AND courseID = @c;",
                    Db.P("@u", uid),
                    Db.P("@c", CourseID));
                if (already > 0)
                {
                    Flash("You are already enrolled.");
                    return;
                }

                Db.ExecuteNonQuery(@"
                    INSERT INTO dbo.Enrolments (userID, courseID, enrollDate, status)
                    VALUES (@u, @c, @d, 'Active');",
                    Db.P("@u", uid),
                    Db.P("@c", CourseID),
                    Db.P("@d", DateTime.Today));

                Flash("Enrolment confirmed. Welcome aboard!");
            }
            catch (Exception ex)
            {
                LogAndFlash("Could not enrol you in this course.", ex);
            }

            LoadCourse();
            ApplyActionBar();
            LoadProgress();
        }

        protected void btnUnenrol_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsLoggedIn) return;

            try
            {
                int affected = Db.ExecuteNonQuery(@"
                    DELETE FROM dbo.Enrolments WHERE userID = @u AND courseID = @c;",
                    Db.P("@u", SessionHelper.CurrentUserId),
                    Db.P("@c", CourseID));
                Flash(affected > 0 ? "You have unenrolled from this course." : "You were not enrolled.");
            }
            catch (Exception ex)
            {
                LogAndFlash("Could not unenrol.", ex);
            }

            LoadCourse();
            ApplyActionBar();
            phProgressBlock.Visible = false;
        }

        // ── Admin delete course ──────────────────────────────────────────
        protected void btnAdminDelete_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsAdmin)
            {
                Flash("Only administrators can delete courses from this page.");
                return;
            }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                    ProfilePage.CascadeDeleteCourse(conn, tx, CourseID));
                Response.Redirect("AdminDashboard.aspx?msg=courseDeleted", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                LogAndFlash("Could not delete course.", ex);
            }
        }

        // ── Helpers ──────────────────────────────────────────────────────
        private bool CanEdit()
        {
            return SessionHelper.IsAdmin
                || (SessionHelper.IsEducator && _courseOwnerId == SessionHelper.CurrentUserId);
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
    }
}
