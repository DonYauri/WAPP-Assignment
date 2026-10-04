using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WAPP_FinalAssignment
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.RequireRole(this, SessionHelper.RoleAdmin)) return;

            lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
            lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);

            if (!IsPostBack)
            {
                LoadStats();
                LoadUsers();
                LoadCourses();
                LoadEnrolments();
                LoadAttempts();
            }
        }

        // ── Stats ─────────────────────────────────────────────────────────
        private void LoadStats()
        {
            try
            {
                lblStatUsers.Text = Db.ExecuteScalar<int>("SELECT COUNT(*) FROM dbo.Users;").ToString();
                lblStatCourses.Text = Db.ExecuteScalar<int>("SELECT COUNT(*) FROM dbo.Courses;").ToString();
                lblStatEnrolments.Text = Db.ExecuteScalar<int>("SELECT COUNT(*) FROM dbo.Enrolments;").ToString();
                lblStatAttempts.Text = Db.ExecuteScalar<int>("SELECT COUNT(*) FROM dbo.QuizAttempts;").ToString();
            }
            catch
            {
                lblStatUsers.Text = "0";
                lblStatCourses.Text = "0";
                lblStatEnrolments.Text = "0";
                lblStatAttempts.Text = "0";
            }
        }

        private void LoadUsers()
        {
            try
            {
                const string sql = @"
                    SELECT userID, username, name, email, role, dateRegistered
                      FROM dbo.Users
                  ORDER BY dateRegistered DESC, userID DESC;";
                var dt = Db.Query(sql);
                rptUsers.DataSource = dt;
                rptUsers.DataBind();
                lblUserCount.Text = dt.Rows.Count.ToString();
            }
            catch
            {
                rptUsers.DataSource = null;
                rptUsers.DataBind();
                lblUserCount.Text = "0";
            }
        }

        private void LoadCourses()
        {
            try
            {
                const string sql = @"
                    SELECT c.courseID, c.courseName, c.category, c.duration,
                           c.headerPictureURL, c.dateCreated,
                           u.name AS instructorName,
                           (SELECT COUNT(*) FROM dbo.Enrolments WHERE courseID = c.courseID) AS enrolmentCount
                      FROM dbo.Courses c
                      LEFT JOIN dbo.Users u ON u.userID = c.userID
                  ORDER BY c.dateCreated DESC;";
                var dt = Db.Query(sql);
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
                lblCourseCount.Text = dt.Rows.Count.ToString();
            }
            catch
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();
                lblCourseCount.Text = "0";
            }
        }

        private void LoadEnrolments()
        {
            try
            {
                const string sql = @"
                    SELECT e.enrolmentID, e.enrollDate, e.status,
                           u.name AS learnerName, u.username,
                           c.courseID, c.courseName
                      FROM dbo.Enrolments e
                     INNER JOIN dbo.Users u ON u.userID = e.userID
                     INNER JOIN dbo.Courses c ON c.courseID = e.courseID
                  ORDER BY e.enrollDate DESC;";
                var dt = Db.Query(sql);
                rptEnrolments.DataSource = dt;
                rptEnrolments.DataBind();
                lblEnrolmentCount.Text = dt.Rows.Count.ToString();
            }
            catch
            {
                rptEnrolments.DataSource = null;
                rptEnrolments.DataBind();
                lblEnrolmentCount.Text = "0";
            }
        }

        private void LoadAttempts()
        {
            try
            {
                const string sql = @"
                    SELECT a.attemptID, a.score, a.attemptDate,
                           u.name  AS learnerName,
                           q.quizTitle, q.passingScore,
                           c.courseName
                      FROM dbo.QuizAttempts a
                     INNER JOIN dbo.Users u   ON u.userID  = a.userID
                     INNER JOIN dbo.Quizzes q ON q.quizID  = a.quizID
                     INNER JOIN dbo.Courses c ON c.courseID = q.courseID
                  ORDER BY a.attemptDate DESC;";
                var dt = Db.Query(sql);
                rptAttempts.DataSource = dt;
                rptAttempts.DataBind();
                lblAttemptCount.Text = dt.Rows.Count.ToString();
            }
            catch
            {
                rptAttempts.DataSource = null;
                rptAttempts.DataBind();
                lblAttemptCount.Text = "0";
            }
        }

        // ── Change role flow ──────────────────────────────────────────────
        protected void btnChangeRole_Click(object sender, EventArgs e)
        {
            int userId = ParseArg(sender);
            if (userId <= 0) { Flash("Invalid user.", false); return; }

            // Cache id and current role into the modal, then open it via a small JS injection
            hfRoleChangeUserID.Value = userId.ToString();
            try
            {
                string current = Db.ExecuteScalar<string>(
                    "SELECT role FROM dbo.Users WHERE userID = @u;",
                    Db.P("@u", userId)) ?? SessionHelper.RoleLearner;

                var item = ddlNewRole.Items.FindByValue(current);
                if (item != null) { ddlNewRole.ClearSelection(); item.Selected = true; }
            }
            catch { /* default to first item */ }

            ScriptManager.RegisterStartupScript(this, GetType(), "openRoleModal",
                "openModal('changeRoleModal');", true);
        }

        protected void btnConfirmRoleChange_Click(object sender, EventArgs e)
        {
            int userId = Db.ToInt(hfRoleChangeUserID.Value);
            string newRole = ddlNewRole.SelectedValue;
            if (userId <= 0 || string.IsNullOrEmpty(newRole))
            {
                Flash("Could not change role — invalid input.", false);
                return;
            }
            if (newRole != SessionHelper.RoleAdmin
                && newRole != SessionHelper.RoleEducator
                && newRole != SessionHelper.RoleLearner)
            {
                Flash("Invalid role selected.", false);
                return;
            }

            // Don't let an admin demote themselves into a non-admin role accidentally
            if (userId == SessionHelper.CurrentUserId && newRole != SessionHelper.RoleAdmin)
            {
                Flash("You cannot change your own role away from Administrator.", false);
                return;
            }

            try
            {
                int affected = Db.ExecuteNonQuery(
                    "UPDATE dbo.Users SET role = @r WHERE userID = @u;",
                    Db.P("@r", newRole),
                    Db.P("@u", userId));
                Flash(affected > 0 ? "Role updated." : "User not found.", affected > 0);
            }
            catch (Exception ex) { LogAndFlash("Could not change role.", ex); }

            LoadUsers();
        }

        // ── Delete user (cascade) ─────────────────────────────────────────
        protected void btnDeleteUser_Click(object sender, EventArgs e)
        {
            int userId = ParseArg(sender);
            if (userId <= 0) { Flash("Invalid user.", false); return; }

            if (userId == SessionHelper.CurrentUserId)
            {
                Flash("Use the profile page to delete your own account.", false);
                return;
            }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx, @"
                        DELETE FROM dbo.AttemptSummaries
                         WHERE attemptID IN (SELECT attemptID FROM dbo.QuizAttempts WHERE userID = @u);",
                        Db.P("@u", userId));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.QuizAttempts WHERE userID = @u;",
                        Db.P("@u", userId));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.Enrolments WHERE userID = @u;",
                        Db.P("@u", userId));

                    // Cascade their authored courses
                    var ids = new System.Collections.Generic.List<int>();
                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT courseID FROM dbo.Courses WHERE userID = @u;", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        using (var rdr = cmd.ExecuteReader())
                            while (rdr.Read()) ids.Add(Db.ToInt(rdr[0]));
                    }
                    foreach (int cid in ids) ProfilePage.CascadeDeleteCourse(conn, tx, cid);

                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.Users WHERE userID = @u;",
                        Db.P("@u", userId));
                });
                Flash("User deleted.", true);
            }
            catch (Exception ex) { LogAndFlash("Could not delete user.", ex); }

            LoadStats();
            LoadUsers();
            LoadCourses();
            LoadEnrolments();
            LoadAttempts();
        }

        // ── Course / Enrolment / Attempt deletes ──────────────────────────
        protected void btnAdminDeleteCourse_Click(object sender, EventArgs e)
        {
            int courseId = ParseArg(sender);
            if (courseId <= 0) { Flash("Invalid course.", false); return; }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                    ProfilePage.CascadeDeleteCourse(conn, tx, courseId));
                Flash("Course deleted.", true);
            }
            catch (Exception ex) { LogAndFlash("Could not delete course.", ex); }

            LoadStats();
            LoadCourses();
            LoadEnrolments();
            LoadAttempts();
        }

        protected void btnRemoveEnrolment_Click(object sender, EventArgs e)
        {
            int enrolmentId = ParseArg(sender);
            if (enrolmentId <= 0) { Flash("Invalid enrolment.", false); return; }

            try
            {
                int affected = Db.ExecuteNonQuery(
                    "DELETE FROM dbo.Enrolments WHERE enrolmentID = @id;",
                    Db.P("@id", enrolmentId));
                Flash(affected > 0 ? "Enrolment removed." : "Enrolment not found.", affected > 0);
            }
            catch (Exception ex) { LogAndFlash("Could not remove enrolment.", ex); }

            LoadStats();
            LoadEnrolments();
        }

        protected void btnDeleteAttempt_Click(object sender, EventArgs e)
        {
            int attemptId = ParseArg(sender);
            if (attemptId <= 0) { Flash("Invalid attempt.", false); return; }

            try
            {
                Db.RunInTransaction((conn, tx) =>
                {
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.AttemptSummaries WHERE attemptID = @id;",
                        Db.P("@id", attemptId));
                    Db.ExecuteNonQueryTx(conn, tx,
                        "DELETE FROM dbo.QuizAttempts WHERE attemptID = @id;",
                        Db.P("@id", attemptId));
                });
                Flash("Attempt deleted.", true);
            }
            catch (Exception ex) { LogAndFlash("Could not delete attempt.", ex); }

            LoadStats();
            LoadAttempts();
        }

        // ── Helpers ───────────────────────────────────────────────────────
        private static int ParseArg(object sender)
        {
            var btn = sender as Button;
            return btn == null ? 0 : Db.ToInt(btn.CommandArgument);
        }

        private void Flash(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = HttpUtility.HtmlEncode(message);
            // Re-style the alert based on success vs error
            pnlMessage.CssClass = "";
            // Inline style: keep success green by default; override for errors
            pnlMessage.Attributes["style"] = "margin-bottom:20px;";
            // Replace inner alert classes
            string alertClass = success ? "alert alert-success" : "alert alert-error";
            string emoji = success ? "✓" : "⚠";
            pnlMessage.Controls.Clear();
            var html = new LiteralControl(
                $"<div class=\"{alertClass}\"><span>{emoji}</span> {HttpUtility.HtmlEncode(message)}</div>");
            pnlMessage.Controls.Add(html);
        }

        private void LogAndFlash(string message, Exception ex)
        {
            try { System.Diagnostics.Debug.WriteLine(ex?.ToString()); } catch { }
            Flash(message, false);
        }
    }
}
