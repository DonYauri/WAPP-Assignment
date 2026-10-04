using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace WAPP_FinalAssignment
{
    public partial class HomePage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Handle ?action=logout from anywhere in the site
            if (string.Equals(Request.QueryString["action"], "logout", StringComparison.OrdinalIgnoreCase))
            {
                SessionHelper.SignOut();
                Response.Redirect("HomePage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Pass-through messages (e.g. ?msg=accessDenied)
            string msg = Request.QueryString["msg"];
            if (!string.IsNullOrEmpty(msg))
            {
                ShowToast(MapQueryMessage(msg, out string type), type);
            }

            ApplyNavState();

            if (!IsPostBack)
            {
                LoadFeaturedCourses();
                LoadAllCourses();
                LoadCategories();
            }
        }

        // ── Auth-aware nav rendering ─────────────────────────────────────
        private void ApplyNavState()
        {
            bool loggedIn = SessionHelper.IsLoggedIn;
            phNavLoggedOut.Visible = !loggedIn;
            phNavLoggedIn.Visible = loggedIn;
            phNavLoggedInLinks.Visible = loggedIn;
            phHeroCTA.Visible = !loggedIn;

            if (loggedIn)
            {
                lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
                lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
                lblNavRole.Text = HttpUtility.HtmlEncode(FriendlyRole(SessionHelper.CurrentRole));
                aNavDashboard.HRef = SessionHelper.DashboardUrl();
            }
        }

        private static string FriendlyRole(string role)
        {
            switch (role)
            {
                case SessionHelper.RoleAdmin: return "Administrator";
                case SessionHelper.RoleEducator: return "Educator";
                case SessionHelper.RoleLearner: return "Learner";
                default: return string.IsNullOrWhiteSpace(role) ? "User" : role;
            }
        }

        // ── Featured / All courses ───────────────────────────────────────
        private void LoadFeaturedCourses()
        {
            try
            {
                const string sql = @"
                    SELECT TOP 6
                           c.courseID, c.courseName, c.description, c.category,
                           c.duration, c.headerPictureURL, c.dateCreated,
                           u.name AS instructorName
                      FROM dbo.Courses c
                      LEFT JOIN dbo.Users u ON u.userID = c.userID
                  ORDER BY c.dateCreated DESC;";
                rptFeaturedCourses.DataSource = Db.Query(sql);
                rptFeaturedCourses.DataBind();
            }
            catch (Exception ex)
            {
                rptFeaturedCourses.DataSource = null;
                rptFeaturedCourses.DataBind();
                LogAndToast("Could not load featured courses.", ex);
            }
        }

        private void LoadAllCourses()
        {
            try
            {
                const string sql = @"
                    SELECT c.courseID, c.courseName, c.description, c.category,
                           c.duration, c.headerPictureURL, c.dateCreated,
                           u.name AS instructorName
                      FROM dbo.Courses c
                      LEFT JOIN dbo.Users u ON u.userID = c.userID
                  ORDER BY c.courseName ASC;";
                rptAllCourses.DataSource = Db.Query(sql);
                rptAllCourses.DataBind();
            }
            catch (Exception ex)
            {
                rptAllCourses.DataSource = null;
                rptAllCourses.DataBind();
                LogAndToast("Could not load courses.", ex);
            }
        }

        private void LoadCategories()
        {
            try
            {
                const string sql = @"
                    SELECT DISTINCT category
                      FROM dbo.Courses
                     WHERE category IS NOT NULL AND LEN(category) > 0
                  ORDER BY category;";
                rptCategories.DataSource = Db.Query(sql);
                rptCategories.DataBind();
            }
            catch
            {
                rptCategories.DataSource = null;
                rptCategories.DataBind();
            }
        }

        // ── Sign in ──────────────────────────────────────────────────────
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = (txtLoginEmail.Text ?? "").Trim();
            string password = txtLoginPassword.Text ?? "";

            if (email.Length == 0 || password.Length == 0)
            {
                ShowToast("Please enter both your email and password.", "error");
                return;
            }
            if (email.Length > 50)
            {
                ShowToast("Email is too long.", "error");
                return;
            }

            try
            {
                string hash = Db.HashPassword(password);
                const string sql = @"
                    SELECT TOP 1 userID, username, name, email, role
                      FROM dbo.Users
                     WHERE email = @email AND passwordHash = @hash;";
                var row = Db.QueryOne(sql,
                    Db.P("@email", email),
                    Db.P("@hash", hash));

                if (row == null)
                {
                    ShowToast("Invalid email or password.", "error");
                    return;
                }

                int userId = Db.ToInt(row["userID"]);
                string username = Db.ToStr(row["username"]);
                string name = Db.ToStr(row["name"]);
                string roleVal = Db.ToStr(row["role"]);
                string emailVal = Db.ToStr(row["email"]);

                SessionHelper.SignIn(userId, username, name, emailVal, roleVal);
                Response.Redirect(SessionHelper.DashboardUrl(), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                LogAndToast("Sign-in failed. Please try again.", ex);
            }
        }

        // ── Register ─────────────────────────────────────────────────────
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string username = (txtRegUsername.Text ?? "").Trim();
            string name = (txtRegName.Text ?? "").Trim();
            string email = (txtRegEmail.Text ?? "").Trim();
            string password = txtRegPassword.Text ?? "";
            string role = (ddlRegRole.SelectedValue ?? "").Trim();

            // Validation guards
            if (username.Length == 0 || name.Length == 0 || email.Length == 0 || password.Length == 0)
            {
                ShowToast("Please fill in every required field.", "error");
                return;
            }
            if (username.Length > 50 || name.Length > 50 || email.Length > 50)
            {
                ShowToast("Username, name and email must be 50 characters or fewer.", "error");
                return;
            }
            if (password.Length < 8)
            {
                ShowToast("Password must be at least 8 characters.", "error");
                return;
            }
            if (!email.Contains("@") || !email.Contains("."))
            {
                ShowToast("Please enter a valid email address.", "error");
                return;
            }
            if (role != SessionHelper.RoleLearner
                && role != SessionHelper.RoleEducator
                && role != SessionHelper.RoleAdmin)
            {
                ShowToast("Please choose a valid role.", "error");
                return;
            }

            try
            {
                // Uniqueness checks (username + email)
                const string dupSql = @"
                    SELECT
                       SUM(CASE WHEN username = @u THEN 1 ELSE 0 END) AS uHits,
                       SUM(CASE WHEN email    = @e THEN 1 ELSE 0 END) AS eHits
                      FROM dbo.Users;";
                var dupRow = Db.QueryOne(dupSql,
                    Db.P("@u", username),
                    Db.P("@e", email));
                int uHits = Db.ToInt(dupRow?["uHits"]);
                int eHits = Db.ToInt(dupRow?["eHits"]);
                if (uHits > 0)
                {
                    ShowToast("That username is already taken.", "error");
                    return;
                }
                if (eHits > 0)
                {
                    ShowToast("An account with that email already exists.", "error");
                    return;
                }

                string hash = Db.HashPassword(password);

                const string insertSql = @"
                    INSERT INTO dbo.Users
                        (username, name, email, passwordHash, role, dateRegistered)
                    VALUES
                        (@u, @n, @e, @h, @r, @d);";

                int newId = Db.ExecuteInsertReturnId(insertSql,
                    Db.P("@u", username),
                    Db.P("@n", name),
                    Db.P("@e", email),
                    Db.P("@h", hash),
                    Db.P("@r", role),
                    Db.P("@d", DateTime.Today));

                if (newId <= 0)
                {
                    ShowToast("Could not create your account. Please try again.", "error");
                    return;
                }

                SessionHelper.SignIn(newId, username, name, email, role);
                Response.Redirect(SessionHelper.DashboardUrl(), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (SqlException sx)
            {
                LogAndToast("Registration failed. " + sx.Message, sx);
            }
            catch (Exception ex)
            {
                LogAndToast("Registration failed. Please try again.", ex);
            }
        }

        // ── Toast / messaging via hidden fields ──────────────────────────
        private void ShowToast(string message, string type)
        {
            hfServerMessage.Value = message ?? string.Empty;
            hfServerMessageType.Value = string.IsNullOrEmpty(type) ? "info" : type;
        }

        private void LogAndToast(string userMessage, Exception ex)
        {
            try { System.Diagnostics.Debug.WriteLine(ex?.ToString()); } catch { /* ignore */ }
            ShowToast(userMessage, "error");
        }

        private static string MapQueryMessage(string code, out string type)
        {
            type = "info";
            switch (code)
            {
                case "logout": type = "success"; return "You have signed out.";
                case "accessDenied": type = "error"; return "You do not have permission to view that page.";
                case "courseDeleted": type = "success"; return "Course deleted.";
                default: return "";
            }
        }
    }
}
