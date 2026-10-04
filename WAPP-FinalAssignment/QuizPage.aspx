<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizPage.aspx.cs" Inherits="WAPP_FinalAssignment.QuizPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><asp:Literal ID="litPageTitle" runat="server" Text="Quiz"></asp:Literal> — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
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
                        <div><div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="User"></asp:Label></div></div>
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

<!-- ====== MAIN ====== -->
<main class="page-content">
    <div class="container">
        <div class="quiz-container">

            <!-- Breadcrumb -->
            <nav class="breadcrumb">
                <a href="HomePage.aspx">Home</a>
                <span class="breadcrumb-sep">›</span>
                <a href="#" id="aCourseBreadcrumb" runat="server"><asp:Label ID="lblCourseName" runat="server" Text="Course"></asp:Label></a>
                <span class="breadcrumb-sep">›</span>
                <span class="breadcrumb-current"><asp:Label ID="lblQuizTitle" runat="server" Text="Quiz"></asp:Label></span>
            </nav>

            <!-- ===== QUIZ INTRO (always shown — title, description, video, readme) ===== -->
            <div style="margin-bottom:24px;">
                <h1 style="font-size:28px;font-weight:700;color:var(--ink-900);letter-spacing:-0.5px;margin-bottom:8px;">
                    <asp:Label ID="lblQuizTitleIntro" runat="server" Text="Quiz Title"></asp:Label>
                </h1>
                <p style="font-size:15px;color:var(--ink-600);line-height:1.6;margin-bottom:18px;">
                    <asp:Label ID="lblQuizDescIntro" runat="server" Text=""></asp:Label>
                </p>
                <asp:PlaceHolder ID="phIntroVideo" runat="server" Visible="false">
                    <div style="width:100%;aspect-ratio:16/9;border-radius:var(--radius-md);overflow:hidden;background:var(--ink-900);margin-bottom:18px;">
                        <asp:Literal ID="litIntroVideo" runat="server"></asp:Literal>
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phIntroReadme" runat="server" Visible="false">
                    <div class="lesson-body" style="margin-bottom:18px;padding:32px 40px;">
                        <div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:12px;">Instructions</div>
                        <div class="readme-content">
                            <asp:Literal ID="litIntroReadme" runat="server"></asp:Literal>
                        </div>
                    </div>
                </asp:PlaceHolder>
            </div>

            <!-- ===== RESULT PANEL (shown after submit) ===== -->
            <asp:PlaceHolder ID="phResult" runat="server" Visible="false">
                <div id="resultPanel" class="quiz-result-panel">
                    <asp:Panel ID="pnlResultInner" runat="server">
                        <div class="quiz-score-big"><asp:Label ID="lblFinalScore" runat="server" Text="0"></asp:Label>%</div>
                        <h2 style="font-size:22px;font-weight:700;margin-bottom:8px;">
                            <asp:Label ID="lblResultTitle" runat="server" Text=""></asp:Label>
                        </h2>
                        <p style="font-size:14px;color:var(--ink-600);">
                            You answered <strong><asp:Label ID="lblCorrectCount" runat="server" Text="0"></asp:Label></strong>
                            out of <strong><asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label></strong> questions correctly.
                            Passing score: <strong><asp:Label ID="lblPassingScoreResult" runat="server" Text="0"></asp:Label>%</strong>.
                        </p>
                        <div style="display:flex;gap:12px;justify-content:center;margin-top:20px;flex-wrap:wrap;">
                            <a href="#" id="aRetakeQuiz" runat="server" class="btn btn-primary">Retake Quiz</a>
                            <a href="#" id="aBackToCourse" runat="server" class="btn btn-secondary">Back to Course</a>
                        </div>
                    </asp:Panel>
                </div>

                <!-- Answer review -->
                <h3 style="font-size:18px;font-weight:700;color:var(--ink-900);margin-bottom:20px;">Answer Review</h3>
                <asp:Repeater ID="rptAnswerReview" runat="server">
                    <ItemTemplate>
                        <div class="question-card" style="margin-bottom:20px;">
                            <div class="question-number">Question <%# Container.ItemIndex + 1 %></div>
                            <div class="question-text"><%# Eval("questionText") %></div>
                            <div style="display:flex;flex-direction:column;gap:8px;">
                                <div class='option-label<%# Eval("correctAnswer").ToString() == "A" ? " correct" : (Eval("userAnswer").ToString() == "A" && Eval("userAnswer").ToString() != Eval("correctAnswer").ToString() ? " incorrect" : "") %>'>
                                    <div class="option-letter">A</div>
                                    <span><%# Eval("optionA") %></span>
                                    <%# Eval("correctAnswer").ToString() == "A" ? "<span style='margin-left:auto;font-weight:700;'>✓</span>" : "" %>
                                </div>
                                <div class='option-label<%# Eval("correctAnswer").ToString() == "B" ? " correct" : (Eval("userAnswer").ToString() == "B" && Eval("userAnswer").ToString() != Eval("correctAnswer").ToString() ? " incorrect" : "") %>'>
                                    <div class="option-letter">B</div>
                                    <span><%# Eval("optionB") %></span>
                                    <%# Eval("correctAnswer").ToString() == "B" ? "<span style='margin-left:auto;font-weight:700;'>✓</span>" : "" %>
                                </div>
                                <div class='option-label<%# Eval("correctAnswer").ToString() == "C" ? " correct" : (Eval("userAnswer").ToString() == "C" && Eval("userAnswer").ToString() != Eval("correctAnswer").ToString() ? " incorrect" : "") %>'>
                                    <div class="option-letter">C</div>
                                    <span><%# Eval("optionC") %></span>
                                    <%# Eval("correctAnswer").ToString() == "C" ? "<span style='margin-left:auto;font-weight:700;'>✓</span>" : "" %>
                                </div>
                                <div class='option-label<%# Eval("correctAnswer").ToString() == "D" ? " correct" : (Eval("userAnswer").ToString() == "D" && Eval("userAnswer").ToString() != Eval("correctAnswer").ToString() ? " incorrect" : "") %>'>
                                    <div class="option-letter">D</div>
                                    <span><%# Eval("optionD") %></span>
                                    <%# Eval("correctAnswer").ToString() == "D" ? "<span style='margin-left:auto;font-weight:700;'>✓</span>" : "" %>
                                </div>
                            </div>
                            <div style="margin-top:12px;font-size:13px;color:var(--ink-600);">
                                Your answer: <strong><%# Eval("userAnswer") %></strong>
                                <%# (bool)Eval("isCorrect") ? " — <span style='color:var(--brand-green);font-weight:600;'>Correct ✓</span>" : " — <span style='color:var(--brand-red);font-weight:600;'>Incorrect ✗</span>" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:PlaceHolder>

            <!-- ===== QUIZ FORM (shown before submit) ===== -->
            <asp:PlaceHolder ID="phQuizForm" runat="server" Visible="true">

                <!-- Quiz Header Card -->
                <div class="quiz-header-card">
                    <h1>
                        <asp:Label ID="lblQuizTitleHeader" runat="server" Text="Quiz Title"></asp:Label>
                    </h1>
                    <p><asp:Label ID="lblQuizDesc" runat="server" Text=""></asp:Label></p>
                    <div class="quiz-meta-row">
                        <div class="quiz-meta-item">
                            <span class="label">Questions</span>
                            <span class="value"><asp:Label ID="lblTotalQuestions" runat="server" Text="0"></asp:Label></span>
                        </div>
                        <div class="quiz-meta-item">
                            <span class="label">Passing Score</span>
                            <span class="value"><asp:Label ID="lblPassingScore" runat="server" Text="0"></asp:Label>%</span>
                        </div>
                        <div class="quiz-meta-item">
                            <span class="label">Points Each</span>
                            <span class="value">Varies</span>
                        </div>
                    </div>
                </div>

                <!-- Educator / Admin options -->
                <asp:PlaceHolder ID="phEducatorOptions" runat="server" Visible="false">
                    <div style="margin-bottom:20px;display:flex;gap:10px;padding:16px 20px;background:var(--brand-amber-light);border:1px solid #ffe082;border-radius:var(--radius-md);align-items:center;">
                        <span style="font-size:14px;color:#c47d00;font-weight:500;">📋 Educator view — learners will answer these questions</span>
                        <div style="margin-left:auto;display:flex;gap:8px;">
                            <a href="#" id="aEditQuizBtn" runat="server" class="btn btn-secondary btn-sm">✏ Edit Quiz</a>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <!-- Login gate -->
                <asp:PlaceHolder ID="phLoginGate" runat="server" Visible="false">
                    <div class="alert alert-info">
                        <span>ℹ</span>
                        <span>You must be signed in and enrolled to attempt this quiz. <a href="HomePage.aspx" style="font-weight:600;">Sign in</a></span>
                    </div>
                </asp:PlaceHolder>

                <!-- Not enrolled gate -->
                <asp:PlaceHolder ID="phEnrolGate" runat="server" Visible="false">
                    <div class="alert alert-warning">
                        <span>⚠</span>
                        <span>Enrol in this course first to attempt the quiz. <a href="#" id="aEnrolLink" runat="server" style="font-weight:600;">Enrol now</a></span>
                    </div>
                </asp:PlaceHolder>

                <!-- Questions -->
                <asp:ListView ID="rptQuestions" runat="server">
                    <LayoutTemplate>
                        <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                    </LayoutTemplate>
                    <ItemTemplate>
                        <div class="question-card" id='q_<%# Eval("questionID") %>'>
                            <div class="question-number">Question <%# Container.DataItemIndex + 1 %></div>
                            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;gap:12px;flex-wrap:wrap;">
                                <div class="question-text" style="margin-bottom:0;flex:1;"><%# Eval("questionText") %></div>
                                <span class="badge badge-blue" style="white-space:nowrap;flex-shrink:0;"><%# Eval("questionsScore") %> pts</span>
                            </div>
                            <div style="display:flex;flex-direction:column;gap:10px;">
                                <label class="option-label">
                                    <input type="radio" name='q_<%# Eval("questionID") %>' value="A" />
                                    <div class="option-indicator"><span></span></div>
                                    <div class="option-letter">A</div>
                                    <span><%# Eval("optionA") %></span>
                                </label>
                                <label class="option-label">
                                    <input type="radio" name='q_<%# Eval("questionID") %>' value="B" />
                                    <div class="option-indicator"><span></span></div>
                                    <div class="option-letter">B</div>
                                    <span><%# Eval("optionB") %></span>
                                </label>
                                <label class="option-label">
                                    <input type="radio" name='q_<%# Eval("questionID") %>' value="C" />
                                    <div class="option-indicator"><span></span></div>
                                    <div class="option-letter">C</div>
                                    <span><%# Eval("optionC") %></span>
                                </label>
                                <label class="option-label">
                                    <input type="radio" name='q_<%# Eval("questionID") %>' value="D" />
                                    <div class="option-indicator"><span></span></div>
                                    <div class="option-letter">D</div>
                                    <span><%# Eval("optionD") %></span>
                                </label>
                            </div>
                        </div>
                    </ItemTemplate>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <div class="empty-state-icon">❓</div>
                            <h3>No questions available</h3>
                            <p>This quiz doesn't have any questions yet.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:ListView>

                <!-- Store answers as hidden field for server submit -->
                <asp:HiddenField ID="hfAnswers" runat="server" Value="" />

                <!-- Progress bar -->
                <div style="position:sticky;bottom:0;background:var(--surface-0);border-top:1px solid var(--ink-100);padding:16px 0;margin-top:8px;">
                    <div style="max-width:720px;margin:0 auto;display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
                        <div style="flex:1;">
                            <div style="display:flex;justify-content:space-between;font-size:12px;color:var(--ink-600);margin-bottom:6px;">
                                <span>Answered: <strong id="answeredCount">0</strong> / <asp:Label ID="lblQCount" runat="server" Text="0"></asp:Label></span>
                                <span id="progressPct">0%</span>
                            </div>
                            <div class="progress-track"><div id="quizProgressBar" class="progress-bar" style="width:0%;"></div></div>
                        </div>
                        <div style="display:flex;gap:10px;">
                            <button type="button" class="btn btn-secondary" onclick="history.back()">Cancel</button>
                            <asp:PlaceHolder ID="phSubmitButton" runat="server" Visible="true">
                                <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" CssClass="btn btn-primary" OnClick="btnSubmitQuiz_Click" OnClientClick="return collectAnswers();" />
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </div>

            </asp:PlaceHolder>

        </div><!-- /quiz-container -->
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
            <div class="footer-col"><h4>Account</h4><a href="HomePage.aspx">Sign in</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a></div>
        </div>
        <div class="footer-bottom"><span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span></div>
    </div>
</footer>

</form>
<script>
    const totalQ = parseInt(document.getElementById('<%= lblQCount.ClientID %>').textContent) || 0;

    function updateProgress() {
        const answered = document.querySelectorAll('input[type="radio"]:checked').length;
        document.getElementById('answeredCount').textContent = answered;
        const pct = totalQ > 0 ? Math.round((answered / totalQ) * 100) : 0;
        document.getElementById('progressPct').textContent = pct + '%';
        document.getElementById('quizProgressBar').style.width = pct + '%';
    }

    document.addEventListener('change', function(e) {
        if (e.target.type === 'radio') updateProgress();
    });

    function collectAnswers() {
        const radios = document.querySelectorAll('input[type="radio"]:checked');
        if (radios.length < totalQ && totalQ > 0) {
            const unanswered = totalQ - radios.length;
            if (!confirm('You have ' + unanswered + ' unanswered question(s). Submit anyway?')) return false;
        }
        const answers = {};
        radios.forEach(r => {
            const qId = r.name.replace('q_', '');
            answers[qId] = r.value;
        });
        document.getElementById('<%= hfAnswers.ClientID %>').value = JSON.stringify(answers);
        return true;
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
