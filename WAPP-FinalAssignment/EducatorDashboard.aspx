<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EducatorDashboard.aspx.cs" Inherits="WAPP_FinalAssignment.EducatorDashboard" %>

!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Educator Dashboard — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .course-manage-card {
            background: var(--surface-0);
            border: 1px solid var(--ink-100);
            border-radius: var(--radius-lg);
            margin-bottom: 24px;
            overflow: hidden;
            transition: box-shadow var(--transition);
        }
        .course-manage-card:hover { box-shadow: var(--shadow-md); }

        .course-manage-header {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 20px 24px;
            border-bottom: 1px solid var(--ink-100);
            cursor: pointer;
            user-select: none;
        }

        .course-manage-header:hover { background: var(--ink-50); }

        .course-manage-thumb {
            width: 64px;
            height: 44px;
            border-radius: var(--radius-sm);
            background: var(--ink-100);
            overflow: hidden;
            flex-shrink: 0;
        }
        .course-manage-thumb img { width: 100%; height: 100%; object-fit: cover; }

        .course-manage-body {
            display: none;
            padding: 0 24px 20px;
        }
        .course-manage-body.open { display: block; }

        .content-row {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid var(--ink-50);
        }
        .content-row:last-child { border-bottom: none; }

        .content-row-icon {
            width: 32px;
            height: 32px;
            border-radius: var(--radius-xs);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .welcome-bar-educator {
            background: linear-gradient(115deg, #1a2744 0%, #0d4f3c 100%);
            border-radius: var(--radius-xl);
            padding: 32px 40px;
            margin-bottom: 32px;
            position: relative;
            overflow: hidden;
        }
        .welcome-bar-educator::after {
            content: '📋';
            position: absolute;
            right: 40px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 80px;
            opacity: 0.12;
        }
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
                <li><a href="EducatorDashboard.aspx" class="active">Dashboard</a></li>
                <li><a href="ProfilePage.aspx">Profile</a></li>
            </ul>
            <div class="nav-right">
                <a href="CreateCourse.aspx" class="btn btn-primary btn-sm">+ New Course</a>
                <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                    <div class="nav-avatar" style="background:var(--brand-green);"><asp:Label ID="lblNavInitial" runat="server" Text="E"></asp:Label></div>
                    <div>
                        <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="Educator"></asp:Label></div>
                        <div class="chip-role">Educator</div>
                    </div>
                    <svg width="12" height="8" viewBox="0 0 12 8" fill="none"><path d="M1 1l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/></svg>
                    <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                        <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">👤 My Profile</a>
                        <a href="CreateCourse.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">📚 Create Course</a>
                        <div style="height:1px;background:var(--ink-100);margin:4px 0;"></div>
                        <button type="button" onclick="doLogout()" style="display:block;width:100%;text-align:left;padding:10px 16px;font-size:13px;color:var(--brand-red);border:none;background:transparent;cursor:pointer;font-family:'DM Sans',sans-serif;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">Sign out</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- ====== MAIN ====== -->
<main class="page-content">
    <div class="container">

        <!-- Welcome bar -->
        <div class="welcome-bar-educator">
            <p style="font-size:13px;font-weight:500;color:rgba(255,255,255,0.55);text-transform:uppercase;letter-spacing:0.8px;margin-bottom:6px;">Educator Dashboard</p>
            <h1 style="font-size:26px;font-weight:700;color:#fff;letter-spacing:-0.4px;margin-bottom:6px;">
                Hello, <asp:Label ID="lblWelcomeName" runat="server" Text="Educator"></asp:Label> 👋
            </h1>
            <p style="font-size:14px;color:rgba(255,255,255,0.6);margin-bottom:20px;">Manage your courses, lessons, and quizzes from here.</p>
            <div style="display:flex;gap:10px;flex-wrap:wrap;">
                <a href="CreateCourse.aspx" class="btn btn-sm" style="background:rgba(255,255,255,0.2);border:1.5px solid rgba(255,255,255,0.35);color:#fff;backdrop-filter:blur(4px);">+ New Course</a>
            </div>
        </div>

        <!-- Stats -->
        <div class="stat-grid" style="margin-bottom:40px;">
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">📚</div>
                <div class="stat-number"><asp:Label ID="lblStatCourses" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Courses Created</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">📝</div>
                <div class="stat-number"><asp:Label ID="lblStatLessons" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Lessons Published</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">🧠</div>
                <div class="stat-number"><asp:Label ID="lblStatQuizzes" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Quizzes Published</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">👥</div>
                <div class="stat-number"><asp:Label ID="lblStatLearners" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Total Enrolments</div>
            </div>
        </div>

        <!-- Server message -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:20px;">
            <div class="alert alert-success"><asp:Label ID="lblMessage" runat="server" Text=""></asp:Label></div>
        </asp:Panel>

        <!-- Courses section -->
        <div class="section-header-row" style="margin-bottom:20px;">
            <h2 style="font-size:20px;font-weight:700;color:var(--ink-900);letter-spacing:-0.3px;">Your Courses</h2>
            <a href="CreateCourse.aspx" class="btn btn-primary btn-sm">+ New Course</a>
        </div>

        <!-- Per-course accordion -->
        <asp:ListView ID="rptCourses" runat="server">
            <LayoutTemplate>
                <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
            </LayoutTemplate>
            <ItemTemplate>
                <div class="course-manage-card">

                    <!-- Course header (clickable toggle) -->
                    <div class="course-manage-header" data-course-id='<%# Eval("courseID") %>' onclick="toggleCourse(this)">
                        <div class="course-manage-thumb">
                            <img src='<%# Eval("headerPictureURL") %>' alt="" onerror="this.style.display='none'" />
                        </div>
                        <div style="flex:1;">
                            <div style="font-size:15px;font-weight:700;color:var(--ink-900);"><%# Eval("courseName") %></div>
                            <div style="font-size:12px;color:var(--ink-400);margin-top:2px;">
                                <span class="badge badge-neutral" style="font-size:10px;"><%# Eval("category") %></span>
                                &nbsp;·&nbsp; <%# Eval("lessonCount") %> lessons
                                &nbsp;·&nbsp; <%# Eval("quizCount") %> quizzes
                                &nbsp;·&nbsp; <%# Eval("enrolmentCount") %> enrolled
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;" onclick="event.stopPropagation()">
                            <a href='EditCourse.aspx?courseID=<%# Eval("courseID") %>' class="btn btn-secondary btn-sm">✏ Edit</a>
                            <a href='CreateLesson.aspx?courseID=<%# Eval("courseID") %>' class="btn btn-primary btn-sm">+ Lesson</a>
                            <a href='CreateQuiz.aspx?courseID=<%# Eval("courseID") %>' class="btn btn-secondary btn-sm">+ Quiz</a>
                            <asp:Button ID="btnDeleteCourse" runat="server" Text="🗑" CssClass="btn btn-danger btn-sm"
                                CommandArgument='<%# Eval("courseID") %>'
                                OnClick="btnDeleteCourse_Click"
                                OnClientClick="return confirm('Delete this course and ALL its content? This cannot be undone.');" />
                        </div>
                        <svg id='chevron_<%# Eval("courseID") %>' width="16" height="16" viewBox="0 0 16 16" fill="none" style="transition:transform 0.2s;flex-shrink:0;margin-left:8px;"><path d="M3 5l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/></svg>
                    </div>

                    <!-- Expandable body: lessons + quizzes -->
                    <div class="course-manage-body" id='course_<%# Eval("courseID") %>'>

                        <!-- View on site link -->
                        <div style="padding:16px 0 8px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--ink-100);margin-bottom:12px;">
                            <a href='CoursePage.aspx?courseID=<%# Eval("courseID") %>' style="font-size:13px;color:var(--brand-blue);font-weight:600;text-decoration:none;">View course page ↗</a>
                        </div>

                        <!-- Lessons sub-list -->
                        <div style="margin-bottom:16px;">
                            <div style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:8px;padding-top:4px;">📝 Lessons</div>
                            <asp:ListView ID="rptCourseLessons" runat="server">
                                <LayoutTemplate>
                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <div class="content-row">
                                        <div class="content-row-icon" style="background:var(--brand-blue-light);">📝</div>
                                        <div style="flex:1;">
                                            <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><%# Eval("lessonTitle") %></div>
                                            <div style="font-size:12px;color:var(--ink-400);"><%# Eval("level") %> · <%# Eval("duration") %> min</div>
                                        </div>
                                        <div style="display:flex;gap:6px;">
                                            <a href='LessonPage.aspx?lessonID=<%# Eval("lessonID") %>' class="btn btn-ghost btn-sm">View</a>
                                            <a href='EditLesson.aspx?lessonID=<%# Eval("lessonID") %>' class="btn btn-secondary btn-sm">✏ Edit</a>
                                            <asp:Button ID="btnDeleteLesson" runat="server" Text="🗑" CssClass="btn btn-danger btn-sm"
                                                CommandArgument='<%# Eval("lessonID") %>'
                                                OnClick="btnDeleteLesson_Click"
                                                OnClientClick="return confirm('Delete this lesson?');" />
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <EmptyDataTemplate>
                                    <div style="font-size:13px;color:var(--ink-400);padding:10px 0;font-style:italic;">No lessons yet — use the <strong>+ Lesson</strong> button above to add the first one.</div>
                                </EmptyDataTemplate>
                            </asp:ListView>
                        </div>

                        <!-- Quizzes sub-list -->
                        <div>
                            <div style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:8px;">🧠 Quizzes</div>
                            <asp:ListView ID="rptCourseQuizzes" runat="server">
                                <LayoutTemplate>
                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <div class="content-row">
                                        <div class="content-row-icon" style="background:var(--brand-amber-light);">🧠</div>
                                        <div style="flex:1;">
                                            <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><%# Eval("quizTitle") %></div>
                                            <div style="font-size:12px;color:var(--ink-400);">Passing: <%# Eval("passingScore") %>% · <%# Eval("questionCount") %> questions</div>
                                        </div>
                                        <div style="display:flex;gap:6px;">
                                            <a href='QuizPage.aspx?quizID=<%# Eval("quizID") %>' class="btn btn-ghost btn-sm">View</a>
                                            <a href='EditQuiz.aspx?quizID=<%# Eval("quizID") %>' class="btn btn-secondary btn-sm">✏ Edit</a>
                                            <asp:Button ID="btnDeleteQuiz" runat="server" Text="🗑" CssClass="btn btn-danger btn-sm"
                                                CommandArgument='<%# Eval("quizID") %>'
                                                OnClick="btnDeleteQuiz_Click"
                                                OnClientClick="return confirm('Delete this quiz and all its questions?');" />
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <EmptyDataTemplate>
                                    <div style="font-size:13px;color:var(--ink-400);padding:10px 0;font-style:italic;">No quizzes yet — use the <strong>+ Quiz</strong> button above to create the first one.</div>
                                </EmptyDataTemplate>
                            </asp:ListView>
                        </div>

                    </div><!-- /course body -->
                </div><!-- /course card -->
            </ItemTemplate>
            <EmptyDataTemplate>
                <div class="empty-state" style="padding:60px 0;">
                    <div class="empty-state-icon">📚</div>
                    <h3>No courses yet</h3>
                    <p>Create your first course to start sharing knowledge with learners.</p>
                    <a href="CreateCourse.aspx" class="btn btn-primary" style="margin-top:8px;">Create first course</a>
                </div>
            </EmptyDataTemplate>
        </asp:ListView>

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
                <p>Hands-on ASP.NET learning platform — APU Group 14.</p>
            </div>
            <div class="footer-col"><h4>Create</h4><a href="CreateCourse.aspx">New Course</a><a href="EducatorDashboard.aspx">My Dashboard</a></div>
            <div class="footer-col"><h4>Account</h4><a href="ProfilePage.aspx">My Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a></div>
        </div>
        <div class="footer-bottom"><span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span></div>
    </div>
</footer>

</form>
<script>
    function toggleCourse(header) {
        const id = header.getAttribute('data-course-id');
        const body = document.getElementById('course_' + id);
        const chevron = document.getElementById('chevron_' + id);
        if (!body) return;
        const isOpen = body.classList.contains('open');
        body.classList.toggle('open');
        if (chevron) chevron.style.transform = isOpen ? '' : 'rotate(180deg)';
    }

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
