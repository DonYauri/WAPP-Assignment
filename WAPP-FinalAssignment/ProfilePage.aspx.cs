using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WAPP_FinalAssignment
{
    public partial class ProfilePage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireLogin(this)) return;

            string dash = SessionHelper.DashboardUrl();
            aNavDashboard.HRef = dash;
            aDropdownDashboard.HRef = dash;
            aBreadcrumbDashboard.HRef = dash;
            aFooterDashboard.HRef = dash;

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
            lblNavRole.Text = HttpUtility.HtmlEncode(FriendlyRole(SessionHelper.CurrentRole));

            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        // ── Load current user's profile fields ────────────────────────────
        private void LoadProfile()
        {
            try
            {
                int uid = SessionHelper.CurrentUserId;
                if (uid <= 0) return;

                const string sql = @"
                    SELECT userID, username, name, email, role, dateRegistered
                      FROM dbo.Users
                     WHERE userID = @uid;";
                var row = Db.QueryOne(sql, Db.P("@uid", uid));
                if (row == null)
                {
                    ShowError("Could not load your profile. Try signing in again.");
                    return;
                }

                string name = Db.ToStr(row["name"]);
                string username = Db.ToStr(row["username"]);
                string email = Db.ToStr(row["email"]);
                string role = Db.ToStr(row["role"]);
                DateTime joined = Db.ToDate(row["dateRegistered"]);

                txtName.Text = name;
                txtUsername.Text = username;
                txtEmail.Text = email;

                hfUsername.Value = username;

                // Sidebar + read-only blocks
                lblAvatarInitials.Text = ComputeInitials(name, username);
                lblSidebarName.Text = HttpUtility.HtmlEncode(name);
                lblSidebarUsername.Text = HttpUtility.HtmlEncode(username);
                lblSidebarRole.Text = HttpUtility.HtmlEncode(FriendlyRole(role));
                lblSidebarJoined.Text = joined.ToString("MMM d, yyyy");
                lblSidebarEmail.Text = HttpUtility.HtmlEncode(email);

                lblAccountID.Text = uid.ToString();
                lblAccountRole.Text = HttpUtility.HtmlEncode(FriendlyRole(role));
                lblAccountJoined.Text = joined.ToString("MMM d, yyyy");
            }
            catch (Exception ex)
            {
                LogAndError("Could not load your profile.", ex);
            }
        }

        // ── Save personal info ────────────────────────────────────────────
        protected void btnSaveInfo_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (!SessionHelper.IsLoggedIn) return;

            string name = (txtName.Text ?? "").Trim();
            string username = (txtUsername.Text ?? "").Trim();
            string email = (txtEmail.Text ?? "").Trim();

            if (name.Length == 0 || username.Length == 0 || email.Length == 0)
            {
                ShowError("Name, username and email are all required.");
                return;
            }
            if (name.Length > 50 || username.Length > 50 || email.Length > 50)
            {
                ShowError("Each field must be 50 characters or fewer.");
                return;
            }
            if (!email.Contains("@") || !email.Contains("."))
            {
                ShowError("Please enter a valid email address.");
                return;
            }

            try
            {
                int uid = SessionHelper.CurrentUserId;

                // Username uniqueness (allow current user's existing username)
                const string dupSql = @"
                    SELECT TOP 1 userID FROM dbo.Users
                     WHERE username = @u AND userID <> @uid;";
                var dup = Db.QueryOne(dupSql,
                    Db.P("@u", username),
                    Db.P("@uid", uid));
                if (dup != null)
                {
                    ShowError("That username is already taken.");
                    return;
                }

                const string updSql = @"
                    UPDATE dbo.Users
                       SET username = @u, name = @n, email = @e
                     WHERE userID = @uid;";
                int affected = Db.ExecuteNonQuery(updSql,
                    Db.P("@u", username),
                    Db.P("@n", name),
                    Db.P("@e", email),
                    Db.P("@uid", uid));

                if (affected == 0)
                {
                    ShowError("No changes were saved (account not found).");
                    return;
                }

                SessionHelper.UpdateProfile(name, email, username);
                hfUsername.Value = username;
                ShowSuccess("Profile updated.");
                LoadProfile();
            }
            catch (Exception ex)
            {
                LogAndError("Could not save your profile.", ex);
            }
        }

        // ── Change password ───────────────────────────────────────────────
        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsLoggedIn) return;

            string current = txtCurrentPassword.Text ?? "";
            string @new = txtNewPassword.Text ?? "";
            string confirm = txtConfirmPassword.Text ?? "";

            if (current.Length == 0 || @new.Length == 0 || confirm.Length == 0)
            {
                ShowPasswordError("All password fields are required.");
                return;
            }
            if (@new.Length < 8)
            {
                ShowPasswordError("New password must be at least 8 characters.");
                return;
            }
            if (@new != confirm)
            {
                ShowPasswordError("New password and confirmation do not match.");
                return;
            }
            if (@new == current)
            {
                ShowPasswordError("Your new password must be different from your current one.");
                return;
            }

            try
            {
                int uid = SessionHelper.CurrentUserId;
                string currentHash = Db.HashPassword(current);
                string newHash = Db.HashPassword(@new);

                const string verifySql = @"
                    SELECT TOP 1 userID FROM dbo.Users
                     WHERE userID = @uid AND passwordHash = @h;";
                var ok = Db.QueryOne(verifySql,
                    Db.P("@uid", uid),
                    Db.P("@h", currentHash));
                if (ok == null)
                {
                    ShowPasswordError("Current password is incorrect.");
                    return;
                }

                const string updSql = @"
                    UPDATE dbo.Users SET passwordHash = @h WHERE userID = @uid;";
                int affected = Db.ExecuteNonQuery(updSql,
                    Db.P("@h", newHash),
                    Db.P("@uid", uid));

                if (affected == 0)
                {
                    ShowPasswordError("Could not update password.");
                    return;
                }

                txtCurrentPassword.Text = "";
                txtNewPassword.Text = "";
                txtConfirmPassword.Text = "";
                pnlPasswordSuccess.Visible = true;
                lblPasswordSuccess.Text = "Password updated successfully.";
                pnlPasswordError.Visible = false;
            }
            catch (Exception ex)
            {
                LogAndPasswordError("Could not change password.", ex);
            }
        }

        // ── Delete own account (cascade) ──────────────────────────────────
        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsLoggedIn) return;
            int uid = SessionHelper.CurrentUserId;
            if (uid <= 0) return;

            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    // 1) Lesson completions for this user
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.LessonCompletions WHERE userID = @uid;",
                        Db.P("@uid", uid));

                    // 2) AttemptSummaries for this user's quiz attempts
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.AttemptSummaries
                         WHERE attemptID IN (SELECT attemptID FROM dbo.QuizAttempts WHERE userID = @uid);",
                        Db.P("@uid", uid));

                    // 3) QuizAttempts
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.QuizAttempts WHERE userID = @uid;",
                        Db.P("@uid", uid));

                    // 4) Enrolments
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.Enrolments WHERE userID = @uid;",
                        Db.P("@uid", uid));

                    // 5) If the user is also an educator, cascade their courses too
                    var courseIdsTbl = new System.Collections.Generic.List<int>();
                    using (var pickCmd = new SqlCommand(
                        "SELECT courseID FROM dbo.Courses WHERE userID = @uid;", conn, tx))
                    {
                        pickCmd.Parameters.AddWithValue("@uid", uid);
                        using (var rdr = pickCmd.ExecuteReader())
                            while (rdr.Read()) courseIdsTbl.Add(Db.ToInt(rdr[0]));
                    }
                    foreach (int cid in courseIdsTbl) CascadeDeleteCourse(conn, tx, cid);

                    // 6) Finally remove the user row
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.Users WHERE userID = @uid;",
                        Db.P("@uid", uid));
                });

                SessionHelper.SignOut();
                Response.Redirect("HomePage.aspx?msg=accountDeleted", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                LogAndError("Could not delete your account. Please try again.", ex);
            }
        }

        // ── Helpers ───────────────────────────────────────────────────────
        internal static void CascadeDeleteCourse(SqlConnection conn, SqlTransaction tx, int courseId)
        {
            // Cascade order: AttemptSummaries → QuizAttempts → QuizQuestions → Quizzes
            //              → LessonCompletions (per lesson) → Lessons → Enrolments → Courses
            Db.ExecuteNonQueryTx(conn, tx, @"
                DELETE FROM dbo.AttemptSummaries
                 WHERE attemptID IN (
                    SELECT a.attemptID FROM dbo.QuizAttempts a
                     INNER JOIN dbo.Quizzes q ON q.quizID = a.quizID
                     WHERE q.courseID = @cid);",
                Db.P("@cid", courseId));

            Db.ExecuteNonQueryTx(conn, tx, @"
                DELETE FROM dbo.QuizAttempts
                 WHERE quizID IN (SELECT quizID FROM dbo.Quizzes WHERE courseID = @cid);",
                Db.P("@cid", courseId));

            Db.ExecuteNonQueryTx(conn, tx, @"
                DELETE FROM dbo.QuizQuestions
                 WHERE quizID IN (SELECT quizID FROM dbo.Quizzes WHERE courseID = @cid);",
                Db.P("@cid", courseId));

            Db.ExecuteNonQueryTx(conn, tx, @"DELETE FROM dbo.Quizzes  WHERE courseID = @cid;",
                Db.P("@cid", courseId));

            Db.ExecuteNonQueryTx(conn, tx, @"
                DELETE FROM dbo.LessonCompletions
                 WHERE lessonID IN (SELECT lessonID FROM dbo.Lessons WHERE courseID = @cid);",
                Db.P("@cid", courseId));

            Db.ExecuteNonQueryTx(conn, tx, @"DELETE FROM dbo.Lessons  WHERE courseID = @cid;",
                Db.P("@cid", courseId));
            Db.ExecuteNonQueryTx(conn, tx, @"DELETE FROM dbo.Enrolments WHERE courseID = @cid;",
                Db.P("@cid", courseId));
            Db.ExecuteNonQueryTx(conn, tx, @"DELETE FROM dbo.Courses  WHERE courseID = @cid;",
                Db.P("@cid", courseId));
        }

        private static string ComputeInitials(string name, string username)
        {
            var src = string.IsNullOrWhiteSpace(name) ? username : name;
            if (string.IsNullOrWhiteSpace(src)) return "U";
            var parts = src.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpperInvariant();
            return src.Substring(0, Math.Min(2, src.Length)).ToUpperInvariant();
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

        private void ShowError(string msg)
        {
            lblError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }

        private void ShowSuccess(string msg)
        {
            lblSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowPasswordError(string msg)
        {
            lblPasswordError.Text = HttpUtility.HtmlEncode(msg);
            pnlPasswordError.Visible = true;
            pnlPasswordSuccess.Visible = false;
        }

        private void LogAndError(string msg, Exception ex)
        {
            try { System.Diagnostics.Debug.WriteLine(ex?.ToString()); } catch { }
            ShowError(msg);
        }

        private void LogAndPasswordError(string msg, Exception ex)
        {
            try { System.Diagnostics.Debug.WriteLine(ex?.ToString()); } catch { }
            ShowPasswordError(msg);
        }
    }
}
