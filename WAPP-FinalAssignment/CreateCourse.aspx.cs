using System;
using System.Globalization;
using System.Web;

namespace WAPP_FinalAssignment
{
    public partial class CreateCourse : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireRole(this, SessionHelper.RoleEducator, SessionHelper.RoleAdmin))
                return;

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
        }

        protected void btnCreateCourse_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = (txtCourseName.Text ?? "").Trim();
            string desc = (txtDescription.Text ?? "").Trim();
            string category = (hfCategory.Value ?? "").Trim();
            string headerImage = (txtHeaderImageURL.Text ?? "").Trim();

            // Field-level guards (server-side mirrors of client validators)
            if (name.Length == 0 || name.Length > 50)
            {
                ShowError("Course name is required (≤ 50 characters).");
                return;
            }
            if (desc.Length == 0 || desc.Length > 200)
            {
                ShowError("Description is required (≤ 200 characters).");
                return;
            }
            if (string.IsNullOrEmpty(category))
            {
                ShowError("Please pick a category for this course.");
                return;
            }
            if (category.Length > 50)
            {
                ShowError("Category name is too long.");
                return;
            }
            if (headerImage.Length == 0)
            {
                ShowError("Header image URL is required.");
                return;
            }
            if (headerImage.Length > 255)
            {
                ShowError("Header image URL is too long.");
                return;
            }
            if (!headerImage.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
                && !headerImage.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                ShowError("Header image URL must start with http:// or https://.");
                return;
            }

            double duration;
            if (!double.TryParse((txtDuration.Text ?? "").Trim(),
                NumberStyles.Float, CultureInfo.InvariantCulture, out duration)
                || double.IsNaN(duration) || double.IsInfinity(duration))
            {
                ShowError("Duration must be a number.");
                return;
            }
            if (duration < 1 || duration > 500)
            {
                ShowError("Duration must be between 1 and 500 hours.");
                return;
            }

            try
            {
                int newId = Db.ExecuteInsertReturnId(@"
                    INSERT INTO dbo.Courses
                        (userID, courseName, description, category, duration, headerPictureURL, dateCreated)
                    VALUES
                        (@u, @n, @d, @cat, @dur, @img, @dt);",
                    Db.P("@u", SessionHelper.CurrentUserId),
                    Db.P("@n", name),
                    Db.P("@d", desc),
                    Db.P("@cat", category),
                    Db.P("@dur", duration),
                    Db.P("@img", headerImage),
                    Db.P("@dt", DateTime.Today));

                if (newId <= 0)
                {
                    ShowError("Course could not be created. Please try again.");
                    return;
                }

                // Off to the editor for adding lessons / quizzes
                Response.Redirect("EditCourse.aspx?courseID=" + newId + "&msg=courseCreated", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                ShowError("Could not create course: " + ex.Message);
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = HttpUtility.HtmlEncode(message);
            pnlError.Visible = true;
        }
    }
}
