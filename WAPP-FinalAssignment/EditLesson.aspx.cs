using System;
using System.Globalization;
using System.Web;

namespace WAPP_FinalAssignment
{
    public partial class EditLesson : System.Web.UI.Page
    {
        private int LessonID
        {
            get
            {
                int v;
                if (int.TryParse(Request.QueryString["lessonID"], out v) && v > 0) return v;
                if (int.TryParse(hfLessonID.Value, out v) && v > 0) return v;
                return 0;
            }
        }

        private int _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireRole(this, SessionHelper.RoleEducator, SessionHelper.RoleAdmin))
                return;
            if (LessonID <= 0)
            {
                Response.Redirect("EducatorDashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);

            if (!IsPostBack) LoadLesson();
        }

        private void LoadLesson()
        {
            try
            {
                const string sql = @"
                    SELECT l.lessonID, l.courseID, l.lessonTitle, l.description,
                           l.level, l.readme, l.videoURL, l.duration,
                           c.courseName, c.userID AS ownerID
                      FROM dbo.Lessons l
                     INNER JOIN dbo.Courses c ON c.courseID = l.courseID
                     WHERE l.lessonID = @id;";
                var row = Db.QueryOne(sql, Db.P("@id", LessonID));
                if (row == null)
                {
                    Response.Redirect("EducatorDashboard.aspx?msg=lessonNotFound", false);
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
                hfLessonID.Value = LessonID.ToString();

                string title = Db.ToStr(row["lessonTitle"]);
                lblLessonName.Text = HttpUtility.HtmlEncode(title);
                lblCourseName.Text = HttpUtility.HtmlEncode(Db.ToStr(row["courseName"], "Course"));
                aCourseLink.HRef = "EditCourse.aspx?courseID=" + _courseId;
                aLessonLink.HRef = "LessonPage.aspx?lessonID=" + LessonID;
                aViewLesson.HRef = "LessonPage.aspx?lessonID=" + LessonID;

                txtTitle.Text = title;
                txtDescription.Text = Db.ToStr(row["description"]);
                txtDuration.Text = Db.ToDouble(row["duration"]).ToString("0.#", CultureInfo.InvariantCulture);
                txtReadme.Text = Db.ToStr(row["readme"]);
                txtVideoURL.Text = Db.ToStr(row["videoURL"]);
                hfLevel.Value = Db.ToStr(row["level"], "Beginner");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not load this lesson.");
            }
        }

        protected void btnSaveLesson_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = (txtTitle.Text ?? "").Trim();
            string desc = (txtDescription.Text ?? "").Trim();
            string level = NormalizeLevel(hfLevel.Value);
            string videoURL = (txtVideoURL.Text ?? "").Trim();
            string readme = txtReadme.Text ?? "";

            if (title.Length == 0 || title.Length > 50) { ShowError("Title is required (≤ 50 chars)."); return; }
            if (desc.Length == 0 || desc.Length > 200) { ShowError("Description is required (≤ 200 chars)."); return; }
            if (videoURL.Length > 255) { ShowError("Video URL is too long."); return; }
            if (videoURL.Length > 0 && !videoURL.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            { ShowError("Video URL must start with http:// or https://."); return; }

            double dur;
            if (!double.TryParse((txtDuration.Text ?? "").Trim(),
                NumberStyles.Float, CultureInfo.InvariantCulture, out dur)
                || double.IsNaN(dur) || double.IsInfinity(dur))
            { ShowError("Duration must be a number."); return; }
            if (dur < 1 || dur > 600) { ShowError("Duration must be between 1 and 600 minutes."); return; }

            try
            {
                int affected = Db.ExecuteNonQuery(@"
                    UPDATE dbo.Lessons
                       SET lessonTitle = @t, description = @d, level = @lv,
                           readme = @r, videoURL = @v, duration = @dur
                     WHERE lessonID = @id
                       AND (@isAdmin = 1 OR courseID IN (SELECT courseID FROM dbo.Courses WHERE userID = @u));",
                    Db.P("@t", title),
                    Db.P("@d", desc),
                    Db.P("@lv", level),
                    Db.P("@r", string.IsNullOrEmpty(readme) ? (object)DBNull.Value : readme),
                    Db.P("@v", string.IsNullOrEmpty(videoURL) ? (object)DBNull.Value : videoURL),
                    Db.P("@dur", dur),
                    Db.P("@id", LessonID),
                    Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                    Db.P("@u", SessionHelper.CurrentUserId));

                if (affected == 0) { ShowError("No changes were saved (lesson not found or not yours)."); return; }
                ShowSuccess("Lesson saved.");
                LoadLesson();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not save lesson. Please try again.");
            }
        }

        protected void btnDeleteLesson_Click(object sender, EventArgs e)
        {
            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.LessonCompletions WHERE lessonID = @id;",
                        Db.P("@id", LessonID));

                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.Lessons
                         WHERE lessonID = @id
                           AND (@isAdmin = 1 OR courseID IN (SELECT courseID FROM dbo.Courses WHERE userID = @u));",
                        Db.P("@id", LessonID),
                        Db.P("@isAdmin", SessionHelper.IsAdmin ? 1 : 0),
                        Db.P("@u", SessionHelper.CurrentUserId));
                });

                Response.Redirect("EditCourse.aspx?courseID=" + _courseId + "&msg=lessonDeleted", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not delete lesson.");
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
