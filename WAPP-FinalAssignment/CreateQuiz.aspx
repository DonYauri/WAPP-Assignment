<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateQuiz.aspx.cs" Inherits="WAPP_FinalAssignment.CreateQuiz" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Quiz — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .question-builder {
            border: 1.5px solid var(--ink-200);
            border-radius: var(--radius-md);
            background: var(--surface-1);
            margin-bottom: 16px;
            overflow: hidden;
        }
        .question-builder-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 20px;
            background: var(--surface-0);
            border-bottom: 1px solid var(--ink-100);
        }
        .question-builder-body {
            padding: 20px;
        }
        .option-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }
        .option-letter-badge {
            width: 28px;
            height: 28px;
            border-radius: var(--radius-xs);
            background: var(--ink-100);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            color: var(--ink-600);
            flex-shrink: 0;
        }
        .correct-radio {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: var(--ink-600);
            cursor: pointer;
            padding: 4px 10px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--ink-200);
            transition: all var(--transition);
        }
        .correct-radio input { accent-color: var(--brand-green); }
        .correct-radio:has(input:checked) {
            background: var(--brand-green-light);
            border-color: #a5d6a7;
            color: var(--brand-green);
            font-weight: 600;
        }
        .question-count-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            background: var(--brand-blue);
            color: #fff;
            border-radius: 50%;
            font-size: 12px;
            font-weight: 700;
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
                <li><a href="EducatorDashboard.aspx">Dashboard</a></li>
            </ul>
            <div class="nav-right">
                <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                    <div class="nav-avatar" style="background:var(--brand-green);"><asp:Label ID="lblNavInitial" runat="server" Text="E"></asp:Label></div>
                    <div><div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="Educator"></asp:Label></div></div>
                    <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                        <a href="EducatorDashboard.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">📋 Dashboard</a>
                        <div style="height:1px;background:var(--ink-100);margin:4px 0;"></div>
                        <button type="button" onclick="doLogout()" style="display:block;width:100%;text-align:left;padding:10px 16px;font-size:13px;color:var(--brand-red);border:none;background:transparent;cursor:pointer;font-family:'DM Sans',sans-serif;">Sign out</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- ====== MAIN ====== -->
<main class="page-content">
    <div class="container">
        <div class="form-page">

            <!-- Breadcrumb -->
            <nav class="breadcrumb">
                <a href="EducatorDashboard.aspx">Dashboard</a>
                <span class="breadcrumb-sep">›</span>
                <a href="#" id="aCourseLink" runat="server"><asp:Label ID="lblCourseName" runat="server" Text="Course"></asp:Label></a>
                <span class="breadcrumb-sep">›</span>
                <span class="breadcrumb-current">Create Quiz</span>
            </nav>

            <h1 class="page-title">Create a New Quiz</h1>
            <p class="page-subtitle">Add a quiz to <strong><asp:Label ID="lblCourseNameSub" runat="server" Text="this course"></asp:Label></strong>. You can add as many questions as needed.</p>

            <!-- Error panel -->
            <asp:Panel ID="pnlError" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-error">
                    <span>⚠</span>
                    <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                </div>
            </asp:Panel>

            <asp:HiddenField ID="hfCourseID" runat="server" Value="" />

            <!-- SECTION 1: Quiz Info -->
            <div class="form-section">
                <div class="form-section-title">🧠 Quiz Details</div>

                <div class="form-group">
                    <label class="form-label">Quiz Title <span class="required">*</span></label>
                    <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control" placeholder="e.g. ASP.NET Fundamentals Quiz" MaxLength="50" oninput="countChars(this, 'titleCount', 50)"></asp:TextBox>
                    <div class="char-count" id="titleCount">0 / 50</div>
                    <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtQuizTitle" ErrorMessage="Quiz title is required." Display="Dynamic" CssClass="form-error" Style="display:block;"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">Description <span class="required">*</span></label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Describe what this quiz covers (max 200 characters)." MaxLength="200" oninput="countChars(this, 'descCount', 200)"></asp:TextBox>
                    <div class="char-count" id="descCount">0 / 200</div>
                    <asp:RequiredFieldValidator ID="rfvDesc" runat="server" ControlToValidate="txtDescription" ErrorMessage="Description is required." Display="Dynamic" CssClass="form-error" Style="display:block;"></asp:RequiredFieldValidator>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Passing Score (%) <span class="required">*</span></label>
                        <asp:TextBox ID="txtPassingScore" runat="server" CssClass="form-control" placeholder="e.g. 70" TextMode="Number"></asp:TextBox>
                        <span class="form-hint">Learners must score at or above this percentage to pass.</span>
                        <asp:RequiredFieldValidator ID="rfvPassingScore" runat="server" ControlToValidate="txtPassingScore" ErrorMessage="Passing score is required." Display="Dynamic" CssClass="form-error" Style="display:block;"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rvPassingScore" runat="server" ControlToValidate="txtPassingScore" MinimumValue="1" MaximumValue="100" Type="Integer" ErrorMessage="Score must be between 1 and 100." Display="Dynamic" CssClass="form-error" Style="display:block;"></asp:RangeValidator>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Video URL (Optional)</label>
                        <asp:TextBox ID="txtVideoURL" runat="server" CssClass="form-control" placeholder="https://www.youtube.com/embed/…"></asp:TextBox>
                        <span class="form-hint">Optional intro video for the quiz overview page.</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Quiz Introduction / README (Optional)</label>
                    <asp:TextBox ID="txtReadme" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5"
                        placeholder="Optional: provide instructions or context for learners before they start."
                        style="font-family:'DM Mono',monospace;font-size:13px;resize:vertical;"></asp:TextBox>
                </div>
            </div>

            <!-- SECTION 2: Questions Builder -->
            <div class="form-section">
                <div class="form-section-title" style="justify-content:space-between;">
                    <span>❓ Questions &nbsp;<span id="questionCountBadge" class="question-count-badge">0</span></span>
                    <button type="button" class="btn btn-primary btn-sm" onclick="addQuestion()">+ Add Question</button>
                </div>
                <p style="font-size:13px;color:var(--ink-600);margin-bottom:20px;">Add at least one question. Each question has four options (A–D) and one correct answer.</p>

                <!-- Questions container — populated by JS -->
                <div id="questionsContainer"></div>

                <div id="noQuestionsHint" style="text-align:center;padding:32px;color:var(--ink-400);border:1.5px dashed var(--ink-200);border-radius:var(--radius-md);">
                    <div style="font-size:32px;margin-bottom:8px;">❓</div>
                    <p style="font-size:14px;font-weight:500;color:var(--ink-600);">No questions yet</p>
                    <p style="font-size:13px;">Click "+ Add Question" above to start building your quiz.</p>
                </div>

                <!-- Hidden field stores all question data as JSON for server processing -->
                <asp:HiddenField ID="hfQuestionsData" runat="server" Value="[]" />
            </div>

            <!-- Action buttons -->
            <div style="display:flex;gap:12px;justify-content:flex-end;margin-top:8px;flex-wrap:wrap;">
                <button type="button" class="btn btn-secondary" onclick="history.back()">Cancel</button>
                <asp:Button ID="btnSaveQuiz" runat="server" Text="Publish Quiz →" CssClass="btn btn-primary" OnClick="btnSaveQuiz_Click" OnClientClick="return collectQuestions();" />
            </div>

        </div><!-- /form-page -->
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
            <div class="footer-col"><h4>Create</h4><a href="EducatorDashboard.aspx">My Dashboard</a></div>
            <div class="footer-col"><h4>Account</h4><a href="ProfilePage.aspx">My Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a></div>
        </div>
        <div class="footer-bottom"><span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span></div>
    </div>
</footer>

</form>
<script>
    let questionIndex = 0;
    const letters = ['A', 'B', 'C', 'D'];

    function updateQuestionCount() {
        const count = document.querySelectorAll('.q-block').length;
        document.getElementById('questionCountBadge').textContent = count;
        document.getElementById('noQuestionsHint').style.display = count === 0 ? 'block' : 'none';
        // Re-number all question headers
        document.querySelectorAll('.q-block').forEach((block, i) => {
            block.querySelector('.q-num-label').textContent = 'Question ' + (i + 1);
        });
    }

    function addQuestion(data) {
        // data = optional pre-fill object { questionText, questionsScore, optionA, optionB, optionC, optionD, correctAnswer }
        const idx = questionIndex++;
        const d = data || {};
        const container = document.getElementById('questionsContainer');
        const qDiv = document.createElement('div');
        qDiv.className = 'question-builder q-block';
        qDiv.dataset.idx = idx;

        const scoreVal = d.questionsScore || 10;
        const correctVal = d.correctAnswer || 'A';

        qDiv.innerHTML = `
        <div class="question-builder-header">
            <div style="display:flex;align-items:center;gap:10px;">
                <span class="question-count-badge" style="background:var(--ink-600);">${document.querySelectorAll('.q-block').length + 1}</span>
                <span class="q-num-label" style="font-size:14px;font-weight:700;color:var(--ink-900);">Question</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <label style="font-size:12px;color:var(--ink-600);">Points:
                    <input type="number" class="q-score form-control" value="${scoreVal}" min="1" max="100"
                        style="width:70px;display:inline-block;padding:4px 8px;margin-left:6px;" />
                </label>
                <button type="button" class="btn btn-danger btn-sm" onclick="removeQuestion(this)">✕ Remove</button>
            </div>
        </div>
        <div class="question-builder-body">
            <div class="form-group" style="margin-bottom:16px;">
                <label class="form-label">Question Text <span class="required">*</span></label>
                <textarea class="q-text form-control" rows="2" placeholder="Type your question here…" style="resize:vertical;">${escHtml(d.questionText || '')}</textarea>
            </div>
            <div style="margin-bottom:12px;">
                <label class="form-label" style="margin-bottom:10px;">Answer Options &amp; Correct Answer</label>
                ${letters.map(letter => `
                <div class="option-row">
                    <div class="option-letter-badge">${letter}</div>
                    <input type="text" class="q-opt-${letter} form-control" placeholder="Option ${letter}…" value="${escHtml(d['option' + letter] || '')}" style="flex:1;" />
                    <label class="correct-radio">
                        <input type="radio" name="correct_${idx}" value="${letter}" ${correctVal === letter ? 'checked' : ''} />
                        Correct
                    </label>
                </div>`).join('')}
            </div>
        </div>`;

        container.appendChild(qDiv);
        updateQuestionCount();
    }

    function removeQuestion(btn) {
        const block = btn.closest('.q-block');
        block.remove();
        updateQuestionCount();
    }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function collectQuestions() {
        const blocks = document.querySelectorAll('.q-block');
        if (blocks.length === 0) {
            alert('Please add at least one question before publishing the quiz.');
            return false;
        }
        const questions = [];
        let valid = true;
        blocks.forEach((block, i) => {
            const text = block.querySelector('.q-text').value.trim();
            if (!text) { alert('Question ' + (i+1) + ' is missing its question text.'); valid = false; return; }
            const opts = ['A','B','C','D'].map(l => block.querySelector('.q-opt-' + l).value.trim());
            const emptyOpts = opts.filter(o => !o).length;
            if (emptyOpts === 4) { alert('Question ' + (i+1) + ' must have at least one option filled in.'); valid = false; return; }
            const correctRadio = block.querySelector('input[type="radio"]:checked');
            const correct = correctRadio ? correctRadio.value : 'A';
            const score = parseFloat(block.querySelector('.q-score').value) || 10;
            questions.push({
                questionText: text,
                questionsScore: score,
                optionA: opts[0],
                optionB: opts[1],
                optionC: opts[2],
                optionD: opts[3],
                correctAnswer: correct
            });
        });
        if (!valid) return false;
        document.getElementById('<%= hfQuestionsData.ClientID %>').value = JSON.stringify(questions);
        return true;
    }

    function countChars(el, countId, max) {
        const len = el.value.length;
        const counter = document.getElementById(countId);
        counter.textContent = len + ' / ' + max;
        counter.className = 'char-count' + (len > max * 0.9 ? (len >= max ? ' danger' : ' warn') : '');
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

    // Auto-add one question on page load for convenience
    window.addEventListener('DOMContentLoaded', function() { addQuestion(); });
</script>
</body>
</html>
