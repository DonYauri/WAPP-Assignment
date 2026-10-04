<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearnerDashboard.aspx.cs" Inherits="WAPP_FinalAssignment.LearnerDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Dashboard — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .enrolment-card { text-decoration: none; color: inherit; }
        .enrolment-card:hover { color: inherit; }

        .quiz-attempt-row {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 14px 0;
            border-bottom: 1px solid var(--ink-100);
            cursor: pointer;
            transition: background var(--transition);
        }
        .quiz-attempt-row:last-child { border-bottom: none; }
        .quiz-attempt-row:hover { background: var(--ink-50); margin: 0 -24px; padding-left: 24px; padding-right: 24px; border-radius: var(--radius-sm); }

        .lesson-done-row {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid var(--ink-100);
            cursor: pointer;
            text-decoration: none;
        }
        .lesson-done-row:last-child { border-bottom: none; }
        .lesson-done-row:hover { opacity: 0.8; }

        .score-ring {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 800;
            flex-shrink: 0;
        }
        .score-ring.pass { background: var(--brand-green-light); color: var(--brand-green); border: 2px solid #a5d6a7; }
        .score-ring.fail { background: var(--brand-red-light); color: var(--brand-red); border: 2px solid #ef9a9a; }

        .welcome-bar {
            background: linear-gradient(115deg, var(--ink-900) 0%, #1a2744 100%);
            border-radius: var(--radius-xl);
            padding: 32px 40px;
            margin-bottom: 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            overflow: hidden;
            position: relative;
        }
        .welcome-bar::after {
            content: '🎓';
            position: absolute;
            right: 40px;
            font-size: 90px;
            opacity: 0.12;
            top: 50%;
            transform: translateY(-50%);
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
                <li><a href="LearnerDashboard.aspx" class="active">Dashboard</a></li>
                <li><a href="ProfilePage.aspx">Profile</a></li>
            </ul>
            <div class="nav-right">
                <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                    <div class="nav-avatar"><asp:Label ID="lblNavInitial" runat="server" Text="U"></asp:Label></div>
                    <div>
                        <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="User"></asp:Label></div>
                        <div class="chip-role">Learner</div>
                    </div>
                    <svg width="12" height="8" viewBox="0 0 12 8" fill="none"><path d="M1 1l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/></svg>
                    <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                        <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">👤 My Profile</a>
                        <a href="HomePage.aspx#all-courses" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">📚 Browse Courses</a>
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
        <div class="welcome-bar">
            <div>
                <p style="font-size:13px;font-weight:500;color:rgba(255,255,255,0.55);text-transform:uppercase;letter-spacing:0.8px;margin-bottom:6px;">Learner Dashboard</p>
                <h1 style="font-size:26px;font-weight:700;color:#fff;letter-spacing:-0.4px;margin-bottom:6px;">
                    Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="Learner"></asp:Label> 👋
                </h1>
                <p style="font-size:14px;color:rgba(255,255,255,0.6);">Keep going — your progress is being saved automatically.</p>
            </div>
            <a href="HomePage.aspx#all-courses" class="btn btn-primary" style="background:rgba(255,255,255,0.15);border:1.5px solid rgba(255,255,255,0.3);color:#fff;flex-shrink:0;backdrop-filter:blur(4px);">
                Browse more courses →
            </a>
        </div>

        <!-- Stats grid -->
        <div class="stat-grid" style="margin-bottom:40px;">
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">📚</div>
                <div class="stat-number"><asp:Label ID="lblStatEnrolled" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Enrolled Courses</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">✅</div>
                <div class="stat-number"><asp:Label ID="lblStatCompleted" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Lessons Completed</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">🧠</div>
                <div class="stat-number"><asp:Label ID="lblStatAttempts" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Quiz Attempts</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">🏆</div>
                <div class="stat-number"><asp:Label ID="lblStatAvgScore" runat="server" Text="—"></asp:Label></div>
                <div class="stat-label">Average Score</div>
            </div>
        </div>

        <!-- Tabs -->
        <div class="tab-nav">
            <button type="button" class="tab-nav-item active" onclick="switchTab('courses', this)">📚 My Courses</button>
            <button type="button" class="tab-nav-item" onclick="switchTab('lessons', this)">✅ Completed Lessons</button>
            <button type="button" class="tab-nav-item" onclick="switchTab('quizzes', this)">🧠 Quiz Attempts</button>
        </div>

        <!-- ===== TAB: ENROLLED COURSES ===== -->
        <div id="tab-courses" class="tab-panel active">
            <asp:ListView ID="rptEnrolledCourses" runat="server">
                <LayoutTemplate>
                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                </LayoutTemplate>
                <ItemTemplate>
                    <a href='CoursePage.aspx?courseID=<%# Eval("courseID") %>' class="enrolment-card" style="display:grid;grid-template-columns:120px 1fr auto;gap:20px;align-items:center;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-lg);padding:20px;margin-bottom:16px;transition:all var(--transition);text-decoration:none;color:inherit;" onmouseover="this.style.boxShadow='var(--shadow-md)';this.style.borderColor='var(--ink-200)'" onmouseout="this.style.boxShadow='';this.style.borderColor='var(--ink-100)'">
                        <div style="width:120px;height:80px;border-radius:var(--radius-sm);overflow:hidden;background:var(--ink-100);flex-shrink:0;">
                            <img src='<%# Eval("headerPictureURL") %>' alt='<%# Eval("courseName") %>' style="width:100%;height:100%;object-fit:cover;" onerror="this.style.display='none'" />
                        </div>
                        <div>
                            <div style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.8px;color:var(--brand-blue);margin-bottom:4px;"><%# Eval("category") %></div>
                            <div style="font-size:16px;font-weight:700;color:var(--ink-900);margin-bottom:4px;"><%# Eval("courseName") %></div>
                            <div style="font-size:13px;color:var(--ink-600);margin-bottom:12px;">Enrolled <%# Eval("enrollDate", "{0:MMM d, yyyy}") %></div>
                            <div style="margin-top:10px;">
                                <div style="display:flex;justify-content:space-between;font-size:12px;color:var(--ink-600);margin-bottom:5px;">
                                    <span>Progress</span>
                                    <span style="font-weight:600;"><%# Eval("progressPct") %>%</span>
                                </div>
                                <div class="progress-track">
                                    <div class='progress-bar <%# (int)Eval("progressPct") >= 100 ? "green" : "" %>' style='width:<%# Eval("progressPct") %>%;'></div>
                                </div>
                            </div>
                        </div>
                        <div style="text-align:center;flex-shrink:0;">
                            <span class='badge <%# Eval("status").ToString() == "Completed" ? "badge-green" : "badge-blue" %>' style="margin-bottom:12px;display:inline-block;"><%# Eval("status") %></span>
                            <div style="font-size:12px;color:var(--ink-400);"><%# Eval("lessonsDone") %> / <%# Eval("totalLessons") %> lessons</div>
                        </div>
                    </a>
                </ItemTemplate>
                <EmptyDataTemplate>
                    <div class="empty-state">
                        <div class="empty-state-icon">📚</div>
                        <h3>No courses yet</h3>
                        <p>You haven't enrolled in any courses. Browse the catalogue to get started.</p>
                        <a href="HomePage.aspx#all-courses" class="btn btn-primary" style="margin-top:8px;">Browse courses</a>
                    </div>
                </EmptyDataTemplate>
            </asp:ListView>
        </div>

        <!-- ===== TAB: COMPLETED LESSONS ===== -->
        <div id="tab-lessons" class="tab-panel">
            <div class="card-flat">
                <asp:ListView ID="rptCompletedLessons" runat="server">
                    <LayoutTemplate>
                        <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                    </LayoutTemplate>
                    <ItemTemplate>
                        <a href='LessonPage.aspx?lessonID=<%# Eval("lessonID") %>' class="lesson-done-row">
                            <div style="width:32px;height:32px;border-radius:50%;background:var(--brand-green-light);display:flex;align-items:center;justify-content:center;color:var(--brand-green);font-weight:700;font-size:14px;flex-shrink:0;">✓</div>
                            <div style="flex:1;">
                                <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><%# Eval("lessonTitle") %></div>
                                <div style="font-size:12px;color:var(--ink-400);">
                                    <%# Eval("courseName") %> · Completed <%# Eval("dateCompleted", "{0:MMM d, yyyy}") %>
                                </div>
                            </div>
                            <span class="badge badge-neutral" style="font-size:10px;"><%# Eval("level") %></span>
                            <span style="color:var(--ink-300);font-size:18px;">›</span>
                        </a>
                    </ItemTemplate>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="padding:40px 0;">
                            <div class="empty-state-icon">✅</div>
                            <h3>No completed lessons yet</h3>
                            <p>Start a lesson to track your progress here.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:ListView>
            </div>
        </div>

        <!-- ===== TAB: QUIZ ATTEMPTS ===== -->
        <div id="tab-quizzes" class="tab-panel">
            <div class="card-flat">
                <asp:ListView ID="rptQuizAttempts" runat="server">
                    <LayoutTemplate>
                        <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                    </LayoutTemplate>
                    <ItemTemplate>
                        <div class="quiz-attempt-row" data-attempt-id='<%# Eval("attemptID") %>' onclick="showAttemptDetail(this)">
                            <div class='score-ring <%# (double)Eval("score") >= (double)Eval("passingScore") ? "pass" : "fail" %>'>
                                <%# Math.Round((double)Eval("score")).ToString() %>%
                            </div>
                            <div style="flex:1;">
                                <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><%# Eval("quizTitle") %></div>
                                <div style="font-size:12px;color:var(--ink-400);">
                                    <%# Eval("courseName") %> · <%# Eval("attemptDate", "{0:MMM d, yyyy}") %>
                                </div>
                            </div>
                            <div style="text-align:right;">
                                <span class='badge <%# (double)Eval("score") >= (double)Eval("passingScore") ? "badge-green" : "badge-red" %>'>
                                    <%# (double)Eval("score") >= (double)Eval("passingScore") ? "Passed" : "Failed" %>
                                </span>
                                <div style="font-size:11px;color:var(--ink-400);margin-top:4px;">
                                    Pass: <%# Eval("passingScore") %>%
                                </div>
                            </div>
                            <span style="color:var(--ink-300);font-size:18px;">›</span>
                        </div>
                    </ItemTemplate>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="padding:40px 0;">
                            <div class="empty-state-icon">🧠</div>
                            <h3>No quiz attempts yet</h3>
                            <p>Complete a quiz in one of your enrolled courses to see results here.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:ListView>
            </div>
        </div>

    </div><!-- /container -->
</main>

<!-- ===== ATTEMPT DETAIL MODAL ===== -->
<div id="attemptModal" class="modal-backdrop" onclick="closeAttemptModal(event)">
    <div class="modal-box modal-lg" style="max-height:85vh;overflow-y:auto;">
        <button type="button" class="modal-close" onclick="document.getElementById('attemptModal').classList.remove('show')">✕</button>
        <div class="modal-header">
            <h2>Quiz Attempt Summary</h2>
            <p id="attemptModalSubtitle">Detailed breakdown of your answers.</p>
        </div>
        <div id="attemptModalBody" style="min-height:120px;display:flex;align-items:center;justify-content:center;">
            <div style="text-align:center;color:var(--ink-400);">
                <div style="font-size:32px;margin-bottom:8px;">⏳</div>
                <p style="font-size:14px;">Loading attempt details…</p>
            </div>
        </div>
    </div>
</div>

<!-- Hidden field to pass attempt data from server -->
<asp:HiddenField ID="hfAttemptData" runat="server" Value="" />

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
            <div class="footer-col"><h4>Learn</h4><a href="HomePage.aspx#all-courses">All Courses</a><a href="LearnerDashboard.aspx">My Dashboard</a></div>
            <div class="footer-col"><h4>Account</h4><a href="ProfilePage.aspx">My Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a><a href="#">WAPP CT050-3-2</a></div>
        </div>
        <div class="footer-bottom"><span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span></div>
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

    // Attempt detail modal — data is pre-loaded as JSON in hidden field
    function showAttemptDetail(rowOrId) {
        const attemptId = (rowOrId && rowOrId.getAttribute)
            ? rowOrId.getAttribute('data-attempt-id')
            : rowOrId;
        const raw = document.getElementById('<%= hfAttemptData.ClientID %>').value;
        let allAttempts = {};
        try { allAttempts = JSON.parse(raw); } catch(e) { allAttempts = {}; }

        const attempt = allAttempts[attemptId];
        const modal = document.getElementById('attemptModal');
        modal.classList.add('show');

        if (!attempt) {
            document.getElementById('attemptModalBody').innerHTML = '<p style="color:var(--ink-400);text-align:center;padding:24px;">Could not load attempt details.</p>';
            return;
        }

        document.getElementById('attemptModalSubtitle').textContent = attempt.quizTitle + ' — ' + attempt.attemptDate;

        const passPct = parseFloat(attempt.passingScore) || 70;
        const score = parseFloat(attempt.score) || 0;
        const passed = score >= passPct;

        let html = `
        <div style="background:${passed ? 'var(--brand-green-light)' : 'var(--brand-red-light)'};border:1px solid ${passed ? '#a5d6a7' : '#ef9a9a'};border-radius:var(--radius-md);padding:20px;text-align:center;margin-bottom:24px;">
            <div style="font-size:44px;font-weight:800;color:${passed ? 'var(--brand-green)' : 'var(--brand-red)'};letter-spacing:-2px;">${Math.round(score)}%</div>
            <div style="font-size:16px;font-weight:600;color:${passed ? 'var(--brand-green)' : 'var(--brand-red)'};margin-top:4px;">${passed ? '🎉 Passed' : '❌ Failed'}</div>
            <div style="font-size:13px;color:var(--ink-600);margin-top:6px;">Passing score: ${passPct}%</div>
        </div>`;

        if (attempt.answers && attempt.answers.length > 0) {
            html += '<h4 style="font-size:15px;font-weight:700;color:var(--ink-900);margin-bottom:16px;">Answer Breakdown</h4>';
            attempt.answers.forEach((q, i) => {
                const correct = q.isCorrect;
                html += `
                <div style="padding:14px;border:1px solid ${correct ? '#a5d6a7' : '#ef9a9a'};border-radius:var(--radius-md);margin-bottom:10px;background:${correct ? 'var(--brand-green-light)' : 'var(--brand-red-light)'};">
                    <div style="font-size:12px;font-weight:600;color:var(--ink-400);margin-bottom:4px;">Question ${i+1}</div>
                    <div style="font-size:14px;font-weight:600;color:var(--ink-900);margin-bottom:8px;">${q.questionText}</div>
                    <div style="font-size:13px;color:var(--ink-700);">
                        Your answer: <strong>${q.userAnswer || 'Not answered'}</strong>
                        — ${correct ? '<span style="color:var(--brand-green);font-weight:600;">Correct ✓</span>' : '<span style="color:var(--brand-red);font-weight:600;">Incorrect ✗ (Correct: ' + q.correctAnswer + ')</span>'}
                    </div>
                </div>`;
            });
        }

        document.getElementById('attemptModalBody').innerHTML = html;
    }

    function closeAttemptModal(e) {
        if (e.target === document.getElementById('attemptModal')) {
            document.getElementById('attemptModal').classList.remove('show');
        }
    }
</script>
</body>
</html>
