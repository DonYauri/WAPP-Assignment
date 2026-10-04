<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CoursePage.aspx.cs" Inherits="WAPP_FinalAssignment.CoursePage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><asp:Literal ID="litPageTitle" runat="server" Text="Course"></asp:Literal> — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .course-hero {
            position: relative;
            background: var(--ink-900);
            border-radius: var(--radius-xl);
            overflow: hidden;
            min-height: 320px;
            display: flex;
            align-items: flex-end;
            margin-bottom: 36px;
        }
        .course-hero-bg {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.4;
        }
        .course-hero-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(to top, rgba(5,5,15,0.95) 0%, rgba(5,5,15,0.5) 60%, transparent 100%);
        }
        .course-hero-content {
            position: relative;
            z-index: 1;
            padding: 40px 48px;
            width: 100%;
        }
        .course-meta-bar {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 32px;
        }
        .content-item {
            background: var(--surface-0);
            border: 1px solid var(--ink-100);
            border-radius: var(--radius-md);
            padding: 18px 20px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 16px;
            cursor: pointer;
            transition: all var(--transition);
            text-decoration: none;
        }
        .content-item:hover {
            box-shadow: var(--shadow-sm);
            border-color: var(--ink-200);
            transform: translateX(2px);
        }
        .content-item-icon {
            width: 40px;
            height: 40px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .content-item-icon.lesson { background: var(--brand-blue-light); }
        .content-item-icon.quiz { background: var(--brand-amber-light); }
        .content-item-body { flex: 1; }
        .content-item-title { font-size: 15px; font-weight: 600; color: var(--ink-900); margin-bottom: 2px; }
        .content-item-meta { font-size: 12px; color: var(--ink-400); }
        .content-item-arrow { color: var(--ink-300); font-size: 20px; margin-left: auto; }

        .course-info-sidebar {
            position: sticky;
            top: calc(var(--nav-height) + 20px);
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
                <li><a href="HomePage.aspx#all-courses">Courses</a></li>
                <asp:PlaceHolder ID="phNavLoggedIn" runat="server" Visible="false">
                    <li><a href="#" id="aNavDashboard" runat="server">Dashboard</a></li>
                </asp:PlaceHolder>
            </ul>
            <div class="nav-right">
                <asp:PlaceHolder ID="phNavLoggedOut" runat="server" Visible="true">
                    <a href="HomePage.aspx" class="btn btn-secondary btn-sm">Sign in</a>
                    <a href="HomePage.aspx" class="btn btn-primary btn-sm">Get started</a>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phNavUser" runat="server" Visible="false">
                    <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                        <div class="nav-avatar"><asp:Label ID="lblNavInitial" runat="server" Text="U"></asp:Label></div>
                        <div>
                            <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="User"></asp:Label></div>
                            <div class="chip-role"><asp:Label ID="lblNavRole" runat="server" Text="Learner"></asp:Label></div>
                        </div>
                        <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                            <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">👤 My Profile</a>
                            <div style="height:1px;background:var(--ink-100);margin:4px 0;"></div>
                            <button type="button" onclick="doLogout()" style="display:block;width:100%;text-align:left;padding:10px 16px;font-size:13px;color:var(--brand-red);border:none;background:transparent;cursor:pointer;font-family:'DM Sans',sans-serif;">Sign out</button>
                        </div>
                    </div>
                </asp:PlaceHolder>
            </div>
        </div>
    </div>
</nav>

<!-- ====== MAIN CONTENT ====== -->
<main class="page-content">
    <div class="container">

        <!-- Breadcrumb -->
        <nav class="breadcrumb">
            <a href="HomePage.aspx">Home</a>
            <span class="breadcrumb-sep">›</span>
            <a href="HomePage.aspx#all-courses">Courses</a>
            <span class="breadcrumb-sep">›</span>
            <span class="breadcrumb-current"><asp:Label ID="lblCourseName" runat="server" Text="Course"></asp:Label></span>
        </nav>

        <!-- Course Hero Banner -->
        <div class="course-hero">
            <asp:Image ID="imgCourseHero" runat="server" CssClass="course-hero-bg" AlternateText="Course banner" />
            <div class="course-hero-overlay"></div>
            <div class="course-hero-content">
                <div style="margin-bottom:12px;">
                    <span class="badge badge-blue" style="background:rgba(66,133,244,0.25);color:rgba(255,255,255,0.9);border:1px solid rgba(66,133,244,0.4);">
                        <asp:Label ID="lblCourseCategory" runat="server" Text="Category"></asp:Label>
                    </span>
                </div>
                <h1 style="font-size:clamp(22px,3vw,36px);font-weight:700;color:#fff;letter-spacing:-0.5px;margin-bottom:10px;">
                    <asp:Label ID="lblCourseTitleHero" runat="server" Text="Course Title"></asp:Label>
                </h1>
                <p style="font-size:15px;color:rgba(255,255,255,0.75);max-width:600px;line-height:1.6;">
                    <asp:Label ID="lblCourseDesc" runat="server" Text=""></asp:Label>
                </p>
                <div style="display:flex;align-items:center;gap:20px;margin-top:20px;flex-wrap:wrap;">
                    <span style="font-size:13px;color:rgba(255,255,255,0.6);">
                        By <strong style="color:rgba(255,255,255,0.9);"><asp:Label ID="lblInstructor" runat="server" Text="Instructor"></asp:Label></strong>
                    </span>
                    <span style="font-size:13px;color:rgba(255,255,255,0.6);">
                        ⏱ <asp:Label ID="lblDuration" runat="server" Text="0"></asp:Label> hours
                    </span>
                    <span style="font-size:13px;color:rgba(255,255,255,0.6);">
                        📅 Created <asp:Label ID="lblDateCreated" runat="server" Text="--"></asp:Label>
                    </span>
                </div>
            </div>
        </div>

        <!-- Main two-column layout -->
        <div style="display:grid;grid-template-columns:1fr 300px;gap:32px;align-items:start;">

            <!-- LEFT: Tabs content -->
            <div>
                <!-- Action bar (enrol / educator options) -->
                <div class="course-meta-bar">
                    <asp:PlaceHolder ID="phEnrolled" runat="server" Visible="false">
                        <span class="badge badge-green" style="padding:8px 16px;font-size:13px;">✓ Enrolled</span>
                        <asp:Button ID="btnUnenrol" runat="server" Text="Unenrol" CssClass="btn btn-secondary btn-sm" OnClick="btnUnenrol_Click" />
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phEnrolButton" runat="server" Visible="false">
                        <asp:Button ID="btnEnrol" runat="server" Text="Enrol now — it's free" CssClass="btn btn-primary" OnClick="btnEnrol_Click" />
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phEducatorActions" runat="server" Visible="false">
                        <a href="#" id="aEditCourse" runat="server" class="btn btn-secondary btn-sm">✏ Edit Course</a>
                        <a href="#" id="aCreateLesson" runat="server" class="btn btn-primary btn-sm">+ Add Lesson</a>
                        <a href="#" id="aCreateQuiz" runat="server" class="btn btn-secondary btn-sm">+ Add Quiz</a>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phAdminActions" runat="server" Visible="false">
                        <asp:Button ID="btnAdminDelete" runat="server" Text="🗑 Delete Course" CssClass="btn btn-danger btn-sm" OnClientClick="return confirm('Delete this course and all its content?');" OnClick="btnAdminDelete_Click" />
                    </asp:PlaceHolder>
                    <asp:PlaceHolder ID="phLoginPrompt" runat="server" Visible="false">
                        <a href="HomePage.aspx" class="btn btn-primary">Sign in to enrol</a>
                    </asp:PlaceHolder>
                </div>

                <!-- Server messages -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
                    <div class="alert alert-success"><asp:Label ID="lblMessage" runat="server" Text=""></asp:Label></div>
                </asp:Panel>

                <!-- Tab navigation -->
                <div class="tab-nav">
                    <button type="button" class="tab-nav-item active" onclick="switchTab('lessons', this)">
                        📖 Lessons (<asp:Label ID="lblLessonCount" runat="server" Text="0"></asp:Label>)
                    </button>
                    <button type="button" class="tab-nav-item" onclick="switchTab('quizzes', this)">
                        🧠 Quizzes (<asp:Label ID="lblQuizCount" runat="server" Text="0"></asp:Label>)
                    </button>
                    <button type="button" class="tab-nav-item" onclick="switchTab('overview', this)">
                        ℹ Overview
                    </button>
                </div>

                <!-- LESSONS TAB -->
                <div id="tab-lessons" class="tab-panel active">
                    <asp:ListView ID="rptLessons" runat="server">
                        <LayoutTemplate>
                            <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                        </LayoutTemplate>
                        <ItemTemplate>
                            <a href='LessonPage.aspx?lessonID=<%# Eval("lessonID") %>' class="content-item">
                                <div class="content-item-icon lesson">📝</div>
                                <div class="content-item-body">
                                    <div class="content-item-title"><%# Eval("lessonTitle") %></div>
                                    <div class="content-item-meta">
                                        <span class="badge badge-neutral" style="font-size:10px;padding:2px 8px;"><%# Eval("level") %></span>
                                        &nbsp;·&nbsp; <%# Eval("duration") %> min
                                        &nbsp;·&nbsp; <%# Eval("dateCreated", "{0:MMM d, yyyy}") %>
                                    </div>
                                </div>
                                <asp:PlaceHolder ID="phLessonEdit" runat="server" Visible="false">
                                    <a href='EditLesson.aspx?lessonID=<%# Eval("lessonID") %>' class="btn btn-secondary btn-sm" onclick="event.stopPropagation();">Edit</a>
                                </asp:PlaceHolder>
                                <span class="content-item-arrow">›</span>
                            </a>
                        </ItemTemplate>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-state-icon">📝</div>
                                <h3>No lessons yet</h3>
                                <p>The educator hasn't added lessons to this course yet.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:ListView>
                </div>

                <!-- QUIZZES TAB -->
                <div id="tab-quizzes" class="tab-panel">
                    <asp:ListView ID="rptQuizzes" runat="server">
                        <LayoutTemplate>
                            <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                        </LayoutTemplate>
                        <ItemTemplate>
                            <a href='QuizPage.aspx?quizID=<%# Eval("quizID") %>' class="content-item">
                                <div class="content-item-icon quiz">🧠</div>
                                <div class="content-item-body">
                                    <div class="content-item-title"><%# Eval("quizTitle") %></div>
                                    <div class="content-item-meta">
                                        Passing score: <%# Eval("passingScore") %>%
                                        &nbsp;·&nbsp; <%# Eval("dateCreated", "{0:MMM d, yyyy}") %>
                                    </div>
                                </div>
                                <asp:PlaceHolder ID="phQuizEdit" runat="server" Visible="false">
                                    <a href='EditQuiz.aspx?quizID=<%# Eval("quizID") %>' class="btn btn-secondary btn-sm" onclick="event.stopPropagation();">Edit</a>
                                </asp:PlaceHolder>
                                <span class="content-item-arrow">›</span>
                            </a>
                        </ItemTemplate>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <div class="empty-state-icon">🧠</div>
                                <h3>No quizzes yet</h3>
                                <p>Quizzes will appear here once the educator adds them.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:ListView>
                </div>

                <!-- OVERVIEW TAB -->
                <div id="tab-overview" class="tab-panel">
                    <div class="card-flat" style="padding:32px;">
                        <h3 style="font-size:17px;font-weight:700;color:var(--ink-900);margin-bottom:16px;">About this course</h3>
                        <div id="overviewContent" style="line-height:1.8;color:var(--ink-700);">
                            <asp:Label ID="lblOverview" runat="server" Text=""></asp:Label>
                        </div>
                        <div class="separator"></div>
                        <h3 style="font-size:17px;font-weight:700;color:var(--ink-900);margin-bottom:16px;">What you'll learn</h3>
                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                            <div style="display:flex;align-items:flex-start;gap:8px;font-size:14px;color:var(--ink-700);">
                                <span style="color:var(--brand-green);font-weight:700;flex-shrink:0;">✓</span>
                                Build ASP.NET web applications from scratch
                            </div>
                            <div style="display:flex;align-items:flex-start;gap:8px;font-size:14px;color:var(--ink-700);">
                                <span style="color:var(--brand-green);font-weight:700;flex-shrink:0;">✓</span>
                                Connect and query SQL Server databases
                            </div>
                            <div style="display:flex;align-items:flex-start;gap:8px;font-size:14px;color:var(--ink-700);">
                                <span style="color:var(--brand-green);font-weight:700;flex-shrink:0;">✓</span>
                                Implement authentication and authorization
                            </div>
                            <div style="display:flex;align-items:flex-start;gap:8px;font-size:14px;color:var(--ink-700);">
                                <span style="color:var(--brand-green);font-weight:700;flex-shrink:0;">✓</span>
                                Apply CRUD operations with ADO.NET
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- RIGHT: Info Sidebar -->
            <div class="course-info-sidebar">
                <div class="card-flat" style="overflow:hidden;padding:0;">
                    <!-- Enrolment stats header -->
                    <div style="padding:20px 20px 16px;border-bottom:1px solid var(--ink-100);">
                        <div style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:14px;">Course info</div>
                        <div style="display:flex;flex-direction:column;gap:12px;">
                            <div style="display:flex;justify-content:space-between;align-items:center;font-size:13px;">
                                <span style="color:var(--ink-600);">Lessons</span>
                                <span style="font-weight:700;color:var(--ink-900);"><asp:Label ID="lblSidebarLessons" runat="server" Text="0"></asp:Label></span>
                            </div>
                            <div style="display:flex;justify-content:space-between;align-items:center;font-size:13px;">
                                <span style="color:var(--ink-600);">Quizzes</span>
                                <span style="font-weight:700;color:var(--ink-900);"><asp:Label ID="lblSidebarQuizzes" runat="server" Text="0"></asp:Label></span>
                            </div>
                            <div style="display:flex;justify-content:space-between;align-items:center;font-size:13px;">
                                <span style="color:var(--ink-600);">Duration</span>
                                <span style="font-weight:700;color:var(--ink-900);"><asp:Label ID="lblSidebarDuration" runat="server" Text="0"></asp:Label> hrs</span>
                            </div>
                            <div style="display:flex;justify-content:space-between;align-items:center;font-size:13px;">
                                <span style="color:var(--ink-600);">Enrolments</span>
                                <span style="font-weight:700;color:var(--ink-900);"><asp:Label ID="lblEnrolmentCount" runat="server" Text="0"></asp:Label></span>
                            </div>
                        </div>
                    </div>
                    <!-- Instructor info -->
                    <div style="padding:16px 20px;border-bottom:1px solid var(--ink-100);">
                        <div style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:10px;">Instructor</div>
                        <div style="display:flex;align-items:center;gap:10px;">
                            <div style="width:36px;height:36px;border-radius:50%;background:var(--brand-blue);color:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;flex-shrink:0;">
                                <asp:Label ID="lblInstructorInitial" runat="server" Text="E"></asp:Label>
                            </div>
                            <div>
                                <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><asp:Label ID="lblInstructorSidebar" runat="server" Text="Educator"></asp:Label></div>
                                <div style="font-size:12px;color:var(--ink-400);">Course Instructor</div>
                            </div>
                        </div>
                    </div>
                    <!-- Learner enrolment progress (shown if enrolled) -->
                    <asp:PlaceHolder ID="phProgressBlock" runat="server" Visible="false">
                        <div style="padding:16px 20px;">
                            <div style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:10px;">Your progress</div>

                            <!-- Lessons -->
                            <div style="display:flex;justify-content:space-between;font-size:12px;color:var(--ink-600);margin-bottom:6px;">
                                <span>Lessons completed</span>
                                <span><asp:Label ID="lblProgressPct" runat="server" Text="0"></asp:Label>%</span>
                            </div>
                            <div class="progress-track" style="margin-bottom:14px;">
                                <asp:Panel ID="pnlProgressBar" runat="server" CssClass="progress-bar"></asp:Panel>
                            </div>

                            <!-- Quizzes -->
                            <div style="display:flex;justify-content:space-between;font-size:12px;color:var(--ink-600);margin-bottom:6px;">
                                <span>Quizzes passed</span>
                                <span><asp:Label ID="lblQuizProgressPct" runat="server" Text="0"></asp:Label>%</span>
                            </div>
                            <div class="progress-track">
                                <asp:Panel ID="pnlQuizProgressBar" runat="server" CssClass="progress-bar"></asp:Panel>
                            </div>

                            <div style="margin-top:14px;font-size:12px;color:var(--ink-400);">
                                <asp:Label ID="lblQuizProgressDetail" runat="server" Text="0 / 0 quizzes"></asp:Label>
                            </div>
                            <div style="margin-top:8px;font-size:12px;color:var(--ink-400);">
                                Status: <span class="badge badge-blue" style="font-size:10px;"><asp:Label ID="lblEnrolStatus" runat="server" Text="Active"></asp:Label></span>
                            </div>
                        </div>
                    </asp:PlaceHolder>
                </div>
            </div>

        </div><!-- /grid -->
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
                <p>A hands-on, database-driven Learning Management System built with ASP.NET.</p>
            </div>
            <div class="footer-col"><h4>Learn</h4><a href="HomePage.aspx#all-courses">All Courses</a></div>
            <div class="footer-col"><h4>Account</h4><a href="HomePage.aspx">Sign in</a><a href="ProfilePage.aspx">Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a><a href="#">WAPP CT050-3-2</a></div>
        </div>
        <div class="footer-bottom">
            <span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span>
        </div>
    </div>
</footer>

</form>
<script>
    function switchTab(name, btn) {
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.tab-nav-item').forEach(b => b.classList.remove('active'));
        document.getElementById('tab-' + name).classList.add('active');
        btn.classList.add('active');
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
