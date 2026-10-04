<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LessonPage.aspx.cs" Inherits="WAPP_FinalAssignment.LessonPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><asp:Literal ID="litPageTitle" runat="server" Text="Lesson"></asp:Literal> — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .lesson-level-dot {
            display: inline-block;
            width: 8px; height: 8px;
            border-radius: 50%;
            margin-right: 4px;
        }
        .level-beginner { background: var(--brand-green); }
        .level-intermediate { background: var(--brand-amber); }
        .level-advanced { background: var(--brand-red); }

        .readme-content h1, .readme-content h2, .readme-content h3 {
            color: var(--ink-900);
            font-weight: 700;
            margin: 28px 0 12px;
            letter-spacing: -0.3px;
        }
        .readme-content h1 { font-size: 24px; }
        .readme-content h2 { font-size: 20px; }
        .readme-content h3 { font-size: 17px; }
        .readme-content h1:first-child, .readme-content h2:first-child { margin-top: 0; }
        .readme-content p { color: var(--ink-700); line-height: 1.78; margin-bottom: 16px; }
        .readme-content ul, .readme-content ol { padding-left: 22px; margin-bottom: 16px; color: var(--ink-700); line-height: 1.8; }
        .readme-content li { margin-bottom: 4px; }
        .readme-content pre {
            background: var(--ink-900);
            color: #e8e8e8;
            border-radius: var(--radius-md);
            padding: 20px 24px;
            overflow-x: auto;
            font-family: 'DM Mono', monospace;
            font-size: 13px;
            line-height: 1.6;
            margin: 20px 0;
        }
        .readme-content code {
            font-family: 'DM Mono', monospace;
            background: var(--ink-100);
            color: var(--brand-purple);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 13px;
        }
        .readme-content pre code { background: transparent; color: #e8e8e8; padding: 0; }
        .readme-content blockquote {
            border-left: 3px solid var(--brand-blue);
            padding: 12px 20px;
            margin: 20px 0;
            background: var(--brand-blue-light);
            border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
            color: var(--ink-700);
            font-style: italic;
        }
        .readme-content table { width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px; }
        .readme-content th { background: var(--ink-50); text-align: left; padding: 10px 12px; font-weight: 600; border-bottom: 2px solid var(--ink-200); }
        .readme-content td { padding: 10px 12px; border-bottom: 1px solid var(--ink-100); }
        .readme-content hr { border: none; border-top: 1px solid var(--ink-100); margin: 28px 0; }
    </style>
</head>
<body>
<form id="mainForm" runat="server">

<!-- ====== TOPNAV ====== -->
<nav class="topnav">
    <div class="container">
        <div class="topnav-inner">
            <a href="HomePage.aspx" class="nav-logo">
                <div class="nav-logo-icon">⚡</div>
                ASP.NET Bootcamp
            </a>
            <ul class="nav-links">
                <li><a href="HomePage.aspx">Home</a></li>
                <asp:PlaceHolder ID="phNavLoggedIn" runat="server" Visible="false">
                    <li><a href="#" id="aNavDashboard" runat="server">Dashboard</a></li>
                </asp:PlaceHolder>
            </ul>
            <div class="nav-right">
                <asp:PlaceHolder ID="phNavUser" runat="server" Visible="false">
                    <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                        <div class="nav-avatar"><asp:Label ID="lblNavInitial" runat="server" Text="U"></asp:Label></div>
                        <div>
                            <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="User"></asp:Label></div>
                        </div>
                        <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                            <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">👤 My Profile</a>
                            <div style="height:1px;background:var(--ink-100);margin:4px 0;"></div>
                            <button type="button" onclick="doLogout()" style="display:block;width:100%;text-align:left;padding:10px 16px;font-size:13px;color:var(--brand-red);border:none;background:transparent;cursor:pointer;font-family:'DM Sans',sans-serif;">Sign out</button>
                        </div>
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phNavLoggedOut" runat="server" Visible="true">
                    <a href="HomePage.aspx" class="btn btn-primary btn-sm">Sign in</a>
                </asp:PlaceHolder>
            </div>
        </div>
    </div>
</nav>

<!-- ====== MAIN CONTENT ====== -->
<main class="page-content">
    <div class="container">
        <div class="lesson-layout">

            <!-- ===== LEFT: LESSON BODY ===== -->
            <div>
                <!-- Breadcrumb -->
                <nav class="breadcrumb">
                    <a href="HomePage.aspx">Home</a>
                    <span class="breadcrumb-sep">›</span>
                    <a href="#" id="aCourseLink" runat="server"><asp:Label ID="lblCourseBreadcrumb" runat="server" Text="Course"></asp:Label></a>
                    <span class="breadcrumb-sep">›</span>
                    <span class="breadcrumb-current"><asp:Label ID="lblLessonTitle" runat="server" Text="Lesson"></asp:Label></span>
                </nav>

                <!-- Lesson title block -->
                <div style="margin-bottom:24px;">
                    <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;flex-wrap:wrap;">
                        <asp:Label ID="lblLevelBadge" runat="server">
                            <!-- set via codebehind based on level value -->
                        </asp:Label>
                        <span style="font-size:13px;color:var(--ink-400);">⏱ <asp:Label ID="lblDuration" runat="server" Text="0"></asp:Label> min</span>
                        <span style="font-size:13px;color:var(--ink-400);">📅 <asp:Label ID="lblDateCreated" runat="server" Text="--"></asp:Label></span>
                    </div>
                    <h1 style="font-size:28px;font-weight:700;color:var(--ink-900);letter-spacing:-0.5px;margin-bottom:8px;">
                        <asp:Label ID="lblLessonTitleMain" runat="server" Text="Lesson Title"></asp:Label>
                    </h1>
                    <p style="font-size:15px;color:var(--ink-600);line-height:1.6;">
                        <asp:Label ID="lblDescription" runat="server" Text=""></asp:Label>
                    </p>
                </div>

                <!-- Video player (hidden if no video URL) -->
                <asp:PlaceHolder ID="phVideo" runat="server" Visible="false">
                    <div class="video-wrapper">
                        <asp:Literal ID="litVideoEmbed" runat="server"></asp:Literal>
                    </div>
                </asp:PlaceHolder>

                <!-- Lesson README / Main content -->
                <div class="lesson-body">
                    <asp:PlaceHolder ID="phReadme" runat="server" Visible="true">
                        <div class="readme-content">
                            <asp:Literal ID="litReadmeContent" runat="server"></asp:Literal>
                        </div>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phNoContent" runat="server" Visible="false">
                        <div class="empty-state" style="padding:40px 0;">
                            <div class="empty-state-icon">📄</div>
                            <h3>No content yet</h3>
                            <p>The educator hasn't added detailed content for this lesson.</p>
                        </div>
                    </asp:PlaceHolder>
                </div>

                <!-- Actions -->
                <div style="display:flex;gap:12px;margin-top:24px;flex-wrap:wrap;align-items:center;">
                    <asp:PlaceHolder ID="phMarkComplete" runat="server" Visible="false">
                        <asp:Button ID="btnMarkComplete" runat="server" Text="✓ Mark as Complete" CssClass="btn btn-success" OnClick="btnMarkComplete_Click" />
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phCompleted" runat="server" Visible="false">
                        <span class="badge badge-green" style="padding:10px 16px;font-size:13px;">✓ Completed</span>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phEditLesson" runat="server" Visible="false">
                        <a href="#" id="aEditLesson" runat="server" class="btn btn-secondary btn-sm">✏ Edit Lesson</a>
                    </asp:PlaceHolder>
                    <a href="#" id="aBackToCourse" runat="server" class="btn btn-secondary">← Back to Course</a>

                    <!-- Prev / Next nav -->
                    <div style="margin-left:auto;display:flex;gap:8px;">
                        <asp:PlaceHolder ID="phPrevLesson" runat="server" Visible="false">
                            <a href="#" id="aPrevLesson" runat="server" class="btn btn-secondary btn-sm">← Previous</a>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phNextLesson" runat="server" Visible="false">
                            <a href="#" id="aNextLesson" runat="server" class="btn btn-primary btn-sm">Next →</a>
                        </asp:PlaceHolder>
                    </div>
                </div>
            </div><!-- /lesson body -->

            <!-- ===== RIGHT: SIDEBAR ===== -->
            <div class="lesson-sidebar">
                <div class="lesson-sidebar-header">Course Content</div>
                <asp:Repeater ID="rptCourseLessons" runat="server">
                    <ItemTemplate>
                        <a href='LessonPage.aspx?lessonID=<%# Eval("lessonID") %>' class='lesson-nav-item<%# (bool)Eval("isCurrent") ? " current" : "" %><%# (bool)Eval("isCompleted") ? " done" : "" %>'>
                            <div class="lesson-nav-dot"></div>
                            <span style="flex:1;line-height:1.4;"><%# Eval("lessonTitle") %></span>
                            <span style="font-size:11px;color:var(--ink-400);flex-shrink:0;"><%# Eval("duration") %>m</span>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
                <div style="padding:16px 20px;border-top:1px solid var(--ink-100);">
                    <a href="#" id="aCourseBackSidebar" runat="server" class="btn btn-secondary btn-sm" style="width:100%;justify-content:center;">← Back to Course</a>
                </div>
            </div>

        </div><!-- /lesson-layout -->
    </div><!-- /container -->
</main>

<!-- ====== FOOTER ====== -->
<footer>
    <div class="container">
        <div class="footer-grid">
            <div class="footer-brand">
                <a href="HomePage.aspx" class="nav-logo" style="color:#fff;margin-bottom:12px;display:inline-flex;align-items:center;gap:8px;text-decoration:none;font-size:16px;font-weight:700;">
                    <div class="nav-logo-icon">⚡</div>ASP.NET Bootcamp
                </a>
                <p>Hands-on ASP.NET learning platform.</p>
            </div>
            <div class="footer-col"><h4>Learn</h4><a href="HomePage.aspx#all-courses">All Courses</a></div>
            <div class="footer-col"><h4>Account</h4><a href="HomePage.aspx">Sign in</a><a href="ProfilePage.aspx">Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a></div>
        </div>
        <div class="footer-bottom"><span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span></div>
    </div>
</footer>

</form>
<script>
    function toggleUserDropdown() {
        const d = document.getElementById('userDropdown');
        if (d) d.style.display = d.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(e) {
        const chip = document.querySelector('.nav-user-chip');
        const dd = document.getElementById('userDropdown');
        if (dd && chip && !chip.contains(e.target)) dd.style.display = 'none';
    });
    function doLogout() { window.location.href = 'HomePage.aspx?action=logout'; }
</script>
</body>
</html>
