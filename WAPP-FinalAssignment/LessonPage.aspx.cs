using System;
using System.Data;
using System.Web;

namespace WAPP_FinalAssignment
{
    public partial class LessonPage : System.Web.UI.Page
    {
        private int LessonID
        {
            get
            {
                int v;
                return int.TryParse(Request.QueryString["lessonID"], out v) ? v : 0;
            }
        }

        private int _courseId;
        private int _courseOwnerId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (LessonID <= 0)
            {
                Response.Redirect("HomePage.aspx?msg=lessonNotFound", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ApplyNavState();

            // Always load lesson metadata (so _courseId/_courseOwnerId are populated on postbacks too)
            if (!LoadLesson()) return;

            if (!IsPostBack)
            {
                LoadSidebarLessons();
                ApplyActionButtons();
            }
        }

        private void ApplyNavState()
        {
            bool loggedIn = SessionHelper.IsLoggedIn;
            phNavLoggedIn.Visible = loggedIn;
            phNavUser.Visible = loggedIn;
            phNavLoggedOut.Visible = !loggedIn;
            if (loggedIn)
            {
                lblNavInitial.Text = HttpUtility.HtmlEncode(SessionHelper.Initial());
                lblNavName.Text = HttpUtility.HtmlEncode(SessionHelper.CurrentName);
                aNavDashboard.HRef = SessionHelper.DashboardUrl();
            }
        }

        private bool LoadLesson()
        {
            try
            {
                const string sql = @"
                    SELECT l.lessonID, l.courseID, l.lessonTitle, l.description,
                           l.level, l.readme, l.videoURL, l.duration, l.dateCreated,
                           c.courseName, c.userID AS ownerID
                      FROM dbo.Lessons l
                     INNER JOIN dbo.Courses c ON c.courseID = l.courseID
                     WHERE l.lessonID = @id;";
                var row = Db.QueryOne(sql, Db.P("@id", LessonID));
                if (row == null)
                {
                    Response.Redirect("HomePage.aspx?msg=lessonNotFound", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return false;
                }

                _courseId = Db.ToInt(row["courseID"]);
                _courseOwnerId = Db.ToInt(row["ownerID"]);
                string title = Db.ToStr(row["lessonTitle"]);
                string desc = Db.ToStr(row["description"]);
                string level = Db.ToStr(row["level"], "Beginner");
                string readme = Db.ToStr(row["readme"]);
                string videoURL = Db.ToStr(row["videoURL"]);
                double dur = Db.ToDouble(row["duration"]);
                DateTime created = Db.ToDate(row["dateCreated"]);
                string courseName = Db.ToStr(row["courseName"], "Course");

                litPageTitle.Text = HttpUtility.HtmlEncode(title);
                lblLessonTitle.Text = HttpUtility.HtmlEncode(title);
                lblLessonTitleMain.Text = HttpUtility.HtmlEncode(title);
                lblDescription.Text = HttpUtility.HtmlEncode(desc);
                lblDuration.Text = ((int)Math.Round(dur)).ToString();
                lblDateCreated.Text = created.ToString("MMM d, yyyy");
                lblCourseBreadcrumb.Text = HttpUtility.HtmlEncode(courseName);
                aCourseLink.HRef = "CoursePage.aspx?courseID=" + _courseId;
                aCourseBackSidebar.HRef = "CoursePage.aspx?courseID=" + _courseId;
                aBackToCourse.HRef = "CoursePage.aspx?courseID=" + _courseId;

                lblLevelBadge.Text = LevelBadgeHtml(level);

                if (!string.IsNullOrEmpty(videoURL))
                {
                    phVideo.Visible = true;
                    string embedUrl = ToEmbedUrl(videoURL);
                    string safe = HttpUtility.HtmlAttributeEncode(embedUrl);
                    litVideoEmbed.Text =
                        $"<iframe src=\"{safe}\" allowfullscreen></iframe>";
                }

                if (string.IsNullOrEmpty(readme))
                {
                    phReadme.Visible = false;
                    phNoContent.Visible = true;
                }
                else
                {
                    litReadmeContent.Text = RenderMarkdown(readme);
                }

                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                Response.Redirect("HomePage.aspx?msg=lessonNotFound", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
        }

        private void LoadSidebarLessons()
        {
            try
            {
                const string sql = @"
                    SELECT l.lessonID, l.lessonTitle, l.duration,
                           CASE WHEN lc.completionID IS NULL THEN 0 ELSE 1 END AS done
                      FROM dbo.Lessons l
                      LEFT JOIN dbo.LessonCompletions lc
                             ON lc.lessonID = l.lessonID AND lc.userID = @u
                     WHERE l.courseID = @c
                  ORDER BY l.dateCreated;";
                var dt = Db.Query(sql,
                    Db.P("@c", _courseId),
                    Db.P("@u", SessionHelper.CurrentUserId));

                if (!dt.Columns.Contains("isCurrent")) dt.Columns.Add("isCurrent", typeof(bool));
                if (!dt.Columns.Contains("isCompleted")) dt.Columns.Add("isCompleted", typeof(bool));

                int? prevId = null, nextId = null;
                bool foundCurrent = false;

                foreach (DataRow r in dt.Rows)
                {
                    int id = Db.ToInt(r["lessonID"]);
                    bool isCurrent = id == LessonID;
                    r["isCurrent"] = isCurrent;
                    r["isCompleted"] = Db.ToInt(r["done"]) == 1;

                    if (!foundCurrent && !isCurrent) prevId = id;
                    if (foundCurrent && nextId == null) nextId = id;
                    if (isCurrent) foundCurrent = true;
                }

                rptCourseLessons.DataSource = dt;
                rptCourseLessons.DataBind();

                if (prevId.HasValue)
                {
                    phPrevLesson.Visible = true;
                    aPrevLesson.HRef = "LessonPage.aspx?lessonID=" + prevId.Value;
                }
                if (nextId.HasValue)
                {
                    phNextLesson.Visible = true;
                    aNextLesson.HRef = "LessonPage.aspx?lessonID=" + nextId.Value;
                }
            }
            catch
            {
                rptCourseLessons.DataSource = null;
                rptCourseLessons.DataBind();
            }
        }

        private void ApplyActionButtons()
        {
            // Edit button for course owner / admin
            if (SessionHelper.IsAdmin
                || (SessionHelper.IsEducator && _courseOwnerId == SessionHelper.CurrentUserId))
            {
                phEditLesson.Visible = true;
                aEditLesson.HRef = "EditLesson.aspx?lessonID=" + LessonID;
            }

            if (SessionHelper.IsLearner)
            {
                bool alreadyDone = false;
                try
                {
                    alreadyDone = Db.ExecuteScalar<int>(@"
                        SELECT COUNT(*) FROM dbo.LessonCompletions
                         WHERE userID = @u AND lessonID = @l;",
                        Db.P("@u", SessionHelper.CurrentUserId),
                        Db.P("@l", LessonID)) > 0;
                }
                catch { /* show button on read failure */ }

                phMarkComplete.Visible = !alreadyDone;
                phCompleted.Visible = alreadyDone;
            }
        }

        protected void btnMarkComplete_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsLearner) return;

            try
            {
                int uid = SessionHelper.CurrentUserId;
                // Only allow if enrolled in the parent course
                int enrolled = Db.ExecuteScalar<int>(@"
                    SELECT COUNT(*) FROM dbo.Enrolments WHERE userID = @u AND courseID = @c;",
                    Db.P("@u", uid),
                    Db.P("@c", _courseId));
                if (enrolled == 0)
                {
                    phMarkComplete.Visible = false;
                    return;
                }

                // Idempotent insert (UNIQUE constraint covers double-clicks)
                Db.ExecuteNonQuery(@"
                    IF NOT EXISTS (SELECT 1 FROM dbo.LessonCompletions
                                    WHERE userID = @u AND lessonID = @l)
                        INSERT INTO dbo.LessonCompletions (userID, lessonID, dateCompleted)
                        VALUES (@u, @l, @d);",
                    Db.P("@u", uid),
                    Db.P("@l", LessonID),
                    Db.P("@d", DateTime.Today));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
            }

            phMarkComplete.Visible = false;
            phCompleted.Visible = true;
        }

        // ── Helpers ───────────────────────────────────────────────────────
        /// <summary>
        /// Convert a YouTube watch / shorts / youtu.be URL into the embeddable form.
        /// Other URLs are returned unchanged.
        /// </summary>
        internal static string ToEmbedUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return url ?? "";
            url = url.Trim();
            // youtu.be/<id>
            var m = System.Text.RegularExpressions.Regex.Match(
                url, @"^https?://youtu\.be/([\w-]{6,})", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            if (m.Success) return "https://www.youtube.com/embed/" + m.Groups[1].Value;
            // youtube.com/watch?v=<id>
            if (url.IndexOf("youtube.com", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                m = System.Text.RegularExpressions.Regex.Match(url, @"[?&]v=([\w-]{6,})");
                if (m.Success) return "https://www.youtube.com/embed/" + m.Groups[1].Value;
                // shorts/<id>
                m = System.Text.RegularExpressions.Regex.Match(
                    url, @"youtube\.com/shorts/([\w-]{6,})", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (m.Success) return "https://www.youtube.com/embed/" + m.Groups[1].Value;
            }
            return url;
        }

        private static string LevelBadgeHtml(string level)
        {
            string cls;
            switch ((level ?? "").Trim())
            {
                case "Advanced":     cls = "badge badge-red";   break;
                case "Intermediate": cls = "badge badge-amber"; break;
                default:             cls = "badge badge-green"; break;
            }
            return $"<span class=\"{cls}\">{HttpUtility.HtmlEncode(level)}</span>";
        }

        // Tiny markdown→HTML renderer matching the editor's preview
        internal static string RenderMarkdownPublic(string md) => RenderMarkdown(md);

        // Tiny markdown→HTML renderer matching the editor's preview
        private static string RenderMarkdown(string md)
        {
            if (string.IsNullOrEmpty(md)) return "";
            string html = HttpUtility.HtmlEncode(md);

            // code fences
            html = System.Text.RegularExpressions.Regex.Replace(
                html, @"```([\s\S]*?)```", m =>
                    "<pre><code>" + m.Groups[1].Value + "</code></pre>");

            // inline code
            html = System.Text.RegularExpressions.Regex.Replace(
                html, "`([^`]+)`", "<code>$1</code>");

            // headings
            html = System.Text.RegularExpressions.Regex.Replace(
                html, "^### (.+)$", "<h3>$1</h3>", System.Text.RegularExpressions.RegexOptions.Multiline);
            html = System.Text.RegularExpressions.Regex.Replace(
                html, "^## (.+)$", "<h2>$1</h2>", System.Text.RegularExpressions.RegexOptions.Multiline);
            html = System.Text.RegularExpressions.Regex.Replace(
                html, "^# (.+)$", "<h1>$1</h1>", System.Text.RegularExpressions.RegexOptions.Multiline);

            // emphasis
            html = System.Text.RegularExpressions.Regex.Replace(
                html, @"\*\*([^*]+)\*\*", "<strong>$1</strong>");
            html = System.Text.RegularExpressions.Regex.Replace(
                html, @"\*([^*]+)\*", "<em>$1</em>");

            // bullets
            html = System.Text.RegularExpressions.Regex.Replace(
                html, @"^- (.+)$", "<li>$1</li>", System.Text.RegularExpressions.RegexOptions.Multiline);
            html = System.Text.RegularExpressions.Regex.Replace(
                html, @"(<li>[\s\S]*?</li>)", "<ul>$1</ul>");
            html = System.Text.RegularExpressions.Regex.Replace(html, @"</ul>\s*<ul>", "");

            // paragraphs from lone non-tag lines
            var paras = html.Split(new[] { "\r\n\r\n", "\n\n" }, StringSplitOptions.None);
            for (int i = 0; i < paras.Length; i++)
            {
                var p = paras[i].Trim();
                if (p.Length == 0) continue;
                if (p.StartsWith("<")) continue;
                paras[i] = "<p>" + p.Replace("\n", "<br/>") + "</p>";
            }
            return string.Join("\n", paras);
        }
    }
}
