using System;
using System.Web;

namespace WAPP_FinalAssignment
{
    public partial class CreateLesson : System.Web.UI.Page
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
                hfLevel.Value = "Beginner";

                // Load + ownership check
                var row = Db.QueryOne(@"
                    SELECT courseName, userID FROM dbo.Courses WHERE courseID = @c;",
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

        protected void btnSaveLesson_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (CourseID <= 0) { ShowError("Course id missing."); return; }

            string title = (txtTitle.Text ?? "").Trim();
            string desc = (txtDescription.Text ?? "").Trim();
            string level = NormalizeLevel(hfLevel.Value);
            string videoURL = (txtVideoURL.Text ?? "").Trim();
            string readme = txtReadme.Text ?? "";

            if (title.Length == 0) { ShowError("Lesson title is required."); return; }
            if (title.Length > 50) { ShowError("Title must be 50 characters or fewer."); return; }
            if (desc.Length == 0) { ShowError("Description is required."); return; }
            if (desc.Length > 200) { ShowError("Description must be 200 characters or fewer."); return; }
            if (videoURL.Length > 255) { ShowError("Video URL is too long."); return; }
            if (videoURL.Length > 0 && !videoURL.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            { ShowError("Video URL must start with http:// or https://."); return; }

            // Duration
            double dur;
            if (!double.TryParse((txtDuration.Text ?? "").Trim(),
                System.Globalization.NumberStyles.Float,
                System.Globalization.CultureInfo.InvariantCulture, out dur)
                || double.IsNaN(dur) || double.IsInfinity(dur))
            {
                ShowError("Duration must be a number.");
                return;
            }
            if (dur < 1 || dur > 600) { ShowError("Duration must be between 1 and 600 minutes."); return; }

            try
            {
                int newId = Db.ExecuteInsertReturnId(@"
                    INSERT INTO dbo.Lessons
                        (courseID, lessonTitle, description, level, readme, videoURL, duration, dateCreated)
                    VALUES
                        (@c, @t, @d, @lv, @r, @v, @dur, @dt);",
                    Db.P("@c", CourseID),
                    Db.P("@t", title),
                    Db.P("@d", desc),
                    Db.P("@lv", level),
                    Db.P("@r", string.IsNullOrEmpty(readme) ? (object)DBNull.Value : readme),
                    Db.P("@v", string.IsNullOrEmpty(videoURL) ? (object)DBNull.Value : videoURL),
                    Db.P("@dur", dur),
                    Db.P("@dt", DateTime.Today));

                if (newId <= 0) { ShowError("Lesson could not be saved."); return; }

                Response.Redirect("EditCourse.aspx?courseID=" + CourseID + "&msg=lessonCreated", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not save the lesson. Please try again.");
            }
        }

        private static string NormalizeLevel(string v)
        {
            switch ((v ?? "").Trim())
            {
                case "Advanced": return "Advanced";
                case "Intermediate": return "Intermediate";
                default: return "Beginner";
            }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            lblError.Text = HttpUtility.HtmlEncode(msg);
        }
    }
}
