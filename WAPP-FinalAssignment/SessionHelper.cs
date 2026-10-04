using System;
using System.Web;

namespace WAPP_FinalAssignment
{
    /// <summary>
    /// Session-based authentication helper. Stores the signed-in user's id,
    /// username, name, and role in Session and exposes role-aware checks.
    /// All accessors are safe when Session is null.
    /// </summary>
    internal static class SessionHelper
    {
        private const string KeyUserId = "auth.userID";
        private const string KeyUsername = "auth.username";
        private const string KeyName = "auth.name";
        private const string KeyEmail = "auth.email";
        private const string KeyRole = "auth.role";

        public const string RoleAdmin = "Admins";
        public const string RoleEducator = "Educator";
        public const string RoleLearner = "Learners";

        public static bool IsLoggedIn
        {
            get
            {
                var s = HttpContext.Current?.Session;
                if (s == null) return false;
                return s[KeyUserId] is int id && id > 0;
            }
        }

        public static int CurrentUserId
        {
            get
            {
                var s = HttpContext.Current?.Session;
                if (s == null) return 0;
                return s[KeyUserId] is int id ? id : 0;
            }
        }

        public static string CurrentUsername =>
            HttpContext.Current?.Session?[KeyUsername] as string ?? "";

        public static string CurrentName =>
            HttpContext.Current?.Session?[KeyName] as string ?? "";

        public static string CurrentEmail =>
            HttpContext.Current?.Session?[KeyEmail] as string ?? "";

        public static string CurrentRole =>
            HttpContext.Current?.Session?[KeyRole] as string ?? "";

        public static bool IsAdmin => CurrentRole == RoleAdmin;
        public static bool IsEducator => CurrentRole == RoleEducator;
        public static bool IsLearner => CurrentRole == RoleLearner;

        /// <summary>
        /// Persist authenticated user details in session.
        /// </summary>
        public static void SignIn(int userId, string username, string name, string email, string role)
        {
            var s = HttpContext.Current?.Session;
            if (s == null) return;
            s[KeyUserId] = userId;
            s[KeyUsername] = username ?? "";
            s[KeyName] = name ?? "";
            s[KeyEmail] = email ?? "";
            s[KeyRole] = role ?? RoleLearner;
        }

        /// <summary>
        /// Refresh the cached display name / email after profile edits.
        /// </summary>
        public static void UpdateProfile(string name, string email, string username)
        {
            var s = HttpContext.Current?.Session;
            if (s == null) return;
            if (name != null) s[KeyName] = name;
            if (email != null) s[KeyEmail] = email;
            if (username != null) s[KeyUsername] = username;
        }

        public static void SignOut()
        {
            var s = HttpContext.Current?.Session;
            if (s == null) return;
            s.Clear();
            s.Abandon();
        }

        /// <summary>
        /// Returns the dashboard URL appropriate for the current user's role.
        /// Falls back to HomePage for signed-out users.
        /// </summary>
        public static string DashboardUrl()
        {
            if (!IsLoggedIn) return "HomePage.aspx";
            switch (CurrentRole)
            {
                case RoleAdmin: return "AdminDashboard.aspx";
                case RoleEducator: return "EducatorDashboard.aspx";
                case RoleLearner: return "LearnerDashboard.aspx";
                default: return "HomePage.aspx";
            }
        }

        /// <summary>
        /// Returns the first letter of the user's name (uppercased) for avatar display.
        /// Always returns at least one safe character.
        /// </summary>
        public static string Initial()
        {
            var n = CurrentName;
            if (!string.IsNullOrWhiteSpace(n)) return n.Trim().Substring(0, 1).ToUpperInvariant();
            var u = CurrentUsername;
            if (!string.IsNullOrWhiteSpace(u)) return u.Trim().Substring(0, 1).ToUpperInvariant();
            return "U";
        }

        /// <summary>
        /// Redirect to home + sign-in modal if the user is not signed in.
        /// </summary>
        public static bool RequireLogin(System.Web.UI.Page page)
        {
            if (page == null) return IsLoggedIn;
            if (IsLoggedIn) return true;
            page.Response.Redirect("HomePage.aspx", false);
            HttpContext.Current?.ApplicationInstance?.CompleteRequest();
            return false;
        }

        /// <summary>
        /// Redirect to home if the user does not have one of the required roles.
        /// </summary>
        public static bool RequireRole(System.Web.UI.Page page, params string[] allowedRoles)
        {
            if (!RequireLogin(page)) return false;
            if (allowedRoles == null || allowedRoles.Length == 0) return true;
            foreach (var r in allowedRoles)
                if (string.Equals(CurrentRole, r, StringComparison.Ordinal)) return true;
            page.Response.Redirect("HomePage.aspx?msg=accessDenied", false);
            HttpContext.Current?.ApplicationInstance?.CompleteRequest();
            return false;
        }
    }
}
