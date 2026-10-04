<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditQuiz.aspx.cs" Inherits="WAPP_FinalAssignment.EditQuiz" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Edit Quiz — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .char-count { font-size: 11px; color: var(--ink-400); text-align: right; margin-top: 3px; }
        .char-count.warn   { color: var(--brand-amber); }
        .char-count.danger { color: var(--brand-red); }

        .question-builder {
            border: 1.5px solid var(--ink-200);
            border-radius: var(--radius-md);
            background: var(--surface-1);
            margin-bottom: 16px;
            overflow: hidden;
            transition: border-color var(--transition);
        }
        .question-builder:focus-within { border-color: var(--brand-blue); }

        .question-builder-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 20px;
            background: var(--surface-0);
            border-bottom: 1px solid var(--ink-100);
            gap: 12px;
            flex-wrap: wrap;
        }

        .question-builder-body { padding: 20px; }

        .option-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }

        .option-letter-badge {
            width: 28px; height: 28px;
            border-radius: var(--radius-xs);
            background: var(--ink-100);
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; font-weight: 700;
            color: var(--ink-600);
            flex-shrink: 0;
        }

        .correct-radio {
            display: flex; align-items: center; gap: 6px;
            font-size: 12px; color: var(--ink-600);
            cursor: pointer;
            padding: 4px 10px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--ink-200);
            transition: all var(--transition);
            user-select: none;
            white-space: nowrap;
        }
        .correct-radio input { accent-color: var(--brand-green); }
        .correct-radio:has(input:checked) {
            background: var(--brand-green-light);
            border-color: #a5d6a7;
            color: var(--brand-green);
            font-weight: 600;
        }

        .q-num-badge {
            width: 24px; height: 24px;
            border-radius: 50%;
            background: var(--brand-blue);
            color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; font-weight: 700;
            flex-shrink: 0;
        }

        .existing-q-badge {
            font-size: 10px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            padding: 2px 8px; border-radius: var(--radius-full);
            background: var(--brand-blue-light);
            color: var(--brand-blue-dark);
        }

        .new-q-badge {
            font-size: 10px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            padding: 2px 8px; border-radius: var(--radius-full);
            background: var(--brand-green-light);
            color: var(--brand-green);
        }

        .deleted-q-badge {
            font-size: 10px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            padding: 2px 8px; border-radius: var(--radius-full);
            background: var(--brand-red-light);
            color: var(--brand-red);
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
                    <div class="nav-avatar" style="background:var(--brand-green);">
                        <asp:Label ID="lblNavInitial" runat="server" Text="E"></asp:Label>
                    </div>
                    <div>
                        <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="Educator"></asp:Label></div>
                        <div class="chip-role">Educator</div>
                    </div>
                    <svg width="12" height="8" viewBox="0 0 12 8" fill="none">
                        <path d="M1 1l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/>
                    </svg>
                    <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                        <a href="EducatorDashboard.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">📋 Dashboard</a>
                        <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">👤 My Profile</a>
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
        <div class="form-page">

            <!-- Breadcrumb -->
            <nav class="breadcrumb">
                <a href="EducatorDashboard.aspx">Dashboard</a>
                <span class="breadcrumb-sep">›</span>
                <a href="#" id="aCourseLink" runat="server">
                    <asp:Label ID="lblCourseName" runat="server" Text="Course"></asp:Label>
                </a>
                <span class="breadcrumb-sep">›</span>
                <a href="#" id="aQuizLink" runat="server">
                    <asp:Label ID="lblQuizName" runat="server" Text="Quiz"></asp:Label>
                </a>
                <span class="breadcrumb-sep">›</span>
                <span class="breadcrumb-current">Edit</span>
            </nav>

            <!-- Page heading row -->
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-bottom:6px;">
                <h1 class="page-title" style="margin-bottom:0;">Edit Quiz</h1>
                <div style="display:flex;gap:8px;flex-shrink:0;">
                    <a href="#" id="aViewQuiz" runat="server" class="btn btn-secondary btn-sm" target="_blank">↗ View Live</a>
                    <asp:Button ID="btnDeleteQuiz" runat="server" Text="🗑 Delete Quiz"
                        CssClass="btn btn-danger btn-sm"
                        OnClientClick="return confirm('Permanently delete this quiz and all its questions and attempt records?');"
                        OnClick="btnDeleteQuiz_Click" />
                </div>
            </div>
            <p class="page-subtitle">Edit the quiz details and manage its questions. Changes are saved when you click Save.</p>

            <!-- Messages -->
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-success">
                    <span>✓</span>
                    <asp:Label ID="lblSuccess" runat="server" Text="Quiz saved successfully."></asp:Label>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlError" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-error">
                    <span>⚠</span>
                    <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                </div>
            </asp:Panel>

            <!-- Hidden fields -->
            <asp:HiddenField ID="hfQuizID" runat="server" Value="" />
            <!-- Stores full question state as JSON for server-side processing -->
            <asp:HiddenField ID="hfQuestionsData" runat="server" Value="[]" />
            <!-- Stores IDs of questions flagged for deletion -->
            <asp:HiddenField ID="hfDeletedQuestionIDs" runat="server" Value="[]" />

            <!-- ============================================================
                 SECTION 1 — Quiz Info
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title">🧠 Quiz Details</div>

                <div class="form-group">
                    <label class="form-label">Quiz Title <span class="required">*</span></label>
                    <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control"
                        MaxLength="50"
                        oninput="countChars(this,'titleCount',50)"></asp:TextBox>
                    <div class="char-count" id="titleCount">0 / 50</div>
                    <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                        ControlToValidate="txtQuizTitle"
                        ErrorMessage="Quiz title is required."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">Description <span class="required">*</span></label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                        TextMode="MultiLine" Rows="3" MaxLength="200"
                        oninput="countChars(this,'descCount',200)"></asp:TextBox>
                    <div class="char-count" id="descCount">0 / 200</div>
                    <asp:RequiredFieldValidator ID="rfvDesc" runat="server"
                        ControlToValidate="txtDescription"
                        ErrorMessage="Description is required."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RequiredFieldValidator>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Passing Score (%) <span class="required">*</span></label>
                        <asp:TextBox ID="txtPassingScore" runat="server" CssClass="form-control"
                            TextMode="Number" placeholder="e.g. 70"></asp:TextBox>
                        <span class="form-hint">Learners must reach or exceed this score to pass.</span>
                        <asp:RequiredFieldValidator ID="rfvPassingScore" runat="server"
                            ControlToValidate="txtPassingScore"
                            ErrorMessage="Passing score is required."
                            Display="Dynamic" CssClass="form-error" Style="display:block;">
                        </asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rvPassingScore" runat="server"
                            ControlToValidate="txtPassingScore"
                            MinimumValue="1" MaximumValue="100" Type="Integer"
                            ErrorMessage="Score must be between 1 and 100."
                            Display="Dynamic" CssClass="form-error" Style="display:block;">
                        </asp:RangeValidator>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Video URL (Optional)</label>
                        <asp:TextBox ID="txtVideoURL" runat="server" CssClass="form-control"
                            placeholder="https://www.youtube.com/embed/…"></asp:TextBox>
                        <span class="form-hint">Optional intro video shown on the quiz page.</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Quiz Introduction / README (Optional)</label>
                    <asp:TextBox ID="txtReadme" runat="server" CssClass="form-control"
                        TextMode="MultiLine" Rows="4"
                        placeholder="Optional context or instructions for learners before they start."
                        style="font-family:'DM Mono',monospace;font-size:13px;resize:vertical;"></asp:TextBox>
                </div>
            </div>

            <!-- ============================================================
                 SECTION 2 — Questions
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title" style="justify-content:space-between;">
                    <span>
                        ❓ Questions
                        &nbsp;<span id="questionCountBadge"
                            style="display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:50%;background:var(--brand-blue);color:#fff;font-size:12px;font-weight:700;">
                            0
                        </span>
                    </span>
                    <button type="button" class="btn btn-primary btn-sm" onclick="addQuestion()">+ Add Question</button>
                </div>

                <p style="font-size:13px;color:var(--ink-600);margin-bottom:20px;">
                    Existing questions are loaded below. Add new ones, edit any field, or remove questions you no longer need.
                    Removals only take effect when you save.
                </p>

                <!-- Legend -->
                <div style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:16px;font-size:12px;color:var(--ink-600);">
                    <span><span class="existing-q-badge">Existing</span> — saved in database</span>
                    <span><span class="new-q-badge">New</span> — will be inserted on save</span>
                    <span><span class="deleted-q-badge">Marked for deletion</span> — removed on save</span>
                </div>

                <!-- Questions are injected here by JS from server-provided JSON -->
                <div id="questionsContainer"></div>

                <div id="noQuestionsHint" style="display:none;text-align:center;padding:32px;color:var(--ink-400);border:1.5px dashed var(--ink-200);border-radius:var(--radius-md);">
                    <div style="font-size:32px;margin-bottom:8px;">❓</div>
                    <p style="font-size:14px;font-weight:500;color:var(--ink-600);">All questions removed</p>
                    <p style="font-size:13px;">Click "+ Add Question" to add new ones, or save to apply deletions.</p>
                </div>
            </div>

            <!-- Action buttons -->
            <div style="display:flex;gap:12px;justify-content:flex-end;margin-top:8px;flex-wrap:wrap;">
                <button type="button" class="btn btn-secondary" onclick="history.back()">Discard Changes</button>
                <asp:Button ID="btnSaveQuiz" runat="server" Text="Save Changes"
                    CssClass="btn btn-primary"
                    OnClick="btnSaveQuiz_Click"
                    OnClientClick="return collectAllQuestions();" />
            </div>

        </div><!-- /form-page -->
    </div><!-- /container -->
</main>

<!-- ====== FOOTER ====== -->
<footer>
    <div class="container">
        <div class="footer-grid">
            <div class="footer-brand">
                <a href="HomePage.aspx" class="nav-logo"
                    style="color:#fff;margin-bottom:12px;display:inline-flex;align-items:center;gap:8px;text-decoration:none;font-size:16px;font-weight:700;">
                    <div class="nav-logo-icon">⚡</div>ASP.NET Bootcamp
                </a>
                <p>Hands-on ASP.NET learning platform — APU Group 14.</p>
            </div>
            <div class="footer-col">
                <h4>Create</h4>
                <a href="EducatorDashboard.aspx">My Dashboard</a>
            </div>
            <div class="footer-col">
                <h4>Account</h4>
                <a href="ProfilePage.aspx">My Profile</a>
            </div>
            <div class="footer-col">
                <h4>Platform</h4>
                <a href="#">APU Group 14</a>
            </div>
        </div>
        <div class="footer-bottom">
            <span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span>
        </div>
    </div>
</footer>

</form>

<script>
    // ── Existing questions loaded from server via hidden field ──────────────
    // The codebehind must serialise existing questions into hfQuestionsData
    // as JSON: [{questionID, questionText, questionsScore, optionA, optionB,
    //            optionC, optionD, correctAnswer}, ...]
    // questionID = 0 means a newly added (client-side) question.

    const LETTERS = ['A', 'B', 'C', 'D'];
    let clientIdx = 1000; // ids for new (client-side) questions; won't clash with DB ids

    // Track deletions separately so the server knows which DB rows to DELETE
    const pendingDeletes = new Set();

    // ── Render all questions from the server JSON on page load ──────────────
    window.addEventListener('DOMContentLoaded', function () {
        // Init char counters from already-filled values
        const titleEl = document.getElementById('<%= txtQuizTitle.ClientID %>');
        const descEl  = document.getElementById('<%= txtDescription.ClientID %>');
        if (titleEl) countChars(titleEl, 'titleCount', 50);
        if (descEl)  countChars(descEl,  'descCount',  200);

        // Parse existing questions from server hidden field
        let existing = [];
        try {
            const raw = document.getElementById('<%= hfQuestionsData.ClientID %>').value;
            existing = JSON.parse(raw) || [];
        } catch (e) { existing = []; }

        existing.forEach(q => renderQuestion(q, false));
        refreshCounter();
    });

    // ── Render one question block ──────────────────────────────────────────
    function renderQuestion(data, isNew) {
        const qid   = data.questionID || (clientIdx++);
        const score = data.questionsScore || 10;
        const correct = data.correctAnswer || 'A';

        const container = document.getElementById('questionsContainer');
        const div = document.createElement('div');
        div.className = 'question-builder';
        div.id = 'qblock_' + qid;
        div.dataset.qid    = qid;
        div.dataset.isnew  = isNew ? '1' : '0';
        div.dataset.deleted = '0';

        const statusBadge = isNew
            ? '<span class="new-q-badge">New</span>'
            : '<span class="existing-q-badge">Existing</span>';

        div.innerHTML = `
        <div class="question-builder-header">
            <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
                <span class="q-num-badge">?</span>
                <span class="q-num-label" style="font-size:14px;font-weight:700;color:var(--ink-900);">Question</span>
                ${statusBadge}
            </div>
            <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
                <label style="font-size:12px;color:var(--ink-600);display:flex;align-items:center;gap:6px;">
                    Points:
                    <input type="number" class="q-score form-control"
                        value="${score}" min="1" max="100"
                        style="width:70px;padding:4px 8px;" />
                </label>
                <button type="button" class="btn btn-danger btn-sm"
                    onclick="markForDelete('${qid}', this)">✕ Remove</button>
            </div>
        </div>
        <div class="question-builder-body">
            <div class="form-group" style="margin-bottom:16px;">
                <label class="form-label">Question Text <span class="required">*</span></label>
                <textarea class="q-text form-control" rows="2"
                    placeholder="Type your question here…"
                    style="resize:vertical;">${escHtml(data.questionText || '')}</textarea>
            </div>
            <div>
                <label class="form-label" style="margin-bottom:10px;">Options &amp; Correct Answer</label>
                ${LETTERS.map(letter => `
                <div class="option-row">
                    <div class="option-letter-badge">${letter}</div>
                    <input type="text"
                        class="q-opt-${letter} form-control"
                        placeholder="Option ${letter}…"
                        value="${escHtml(data['option' + letter] || '')}"
                        style="flex:1;" />
                    <label class="correct-radio">
                        <input type="radio" name="correct_${qid}" value="${letter}"
                            ${correct === letter ? 'checked' : ''} />
                        Correct
                    </label>
                </div>`).join('')}
            </div>
        </div>`;

        container.appendChild(div);
        refreshCounter();
    }

    // ── Mark a question for deletion (soft-delete in the UI) ───────────────
    function markForDelete(qid, btn) {
        const block = document.getElementById('qblock_' + qid);
        if (!block) return;

        const isNew = block.dataset.isnew === '1';

        if (isNew) {
            // New question — just remove it from the DOM; nothing in DB to delete
            block.remove();
        } else {
            // Existing DB question — toggle deleted state visually, track id
            const alreadyDeleted = block.dataset.deleted === '1';
            if (alreadyDeleted) {
                // Undelete
                block.dataset.deleted = '0';
                block.style.opacity = '1';
                block.style.pointerEvents = '';
                // Replace badge
                const badge = block.querySelector('.existing-q-badge, .deleted-q-badge');
                if (badge) { badge.className = 'existing-q-badge'; badge.textContent = 'Existing'; }
                btn.textContent = '✕ Remove';
                btn.className = 'btn btn-danger btn-sm';
                pendingDeletes.delete(String(qid));
            } else {
                // Mark as deleted
                block.dataset.deleted = '1';
                block.style.opacity = '0.45';
                block.style.pointerEvents = 'none';
                const badge = block.querySelector('.existing-q-badge, .deleted-q-badge');
                if (badge) { badge.className = 'deleted-q-badge'; badge.textContent = 'Marked for deletion'; }
                btn.textContent = '↩ Undo';
                btn.className = 'btn btn-secondary btn-sm';
                btn.style.pointerEvents = 'auto'; // allow undo even when block is dimmed
                block.style.pointerEvents = 'none';
                // Re-enable just the undo button
                btn.parentElement.style.pointerEvents = 'auto';
                pendingDeletes.add(String(qid));
            }
        }

        refreshCounter();
    }

    // ── Add a brand-new blank question ────────────────────────────────────
    function addQuestion() {
        renderQuestion({ questionID: 0 }, true);
        refreshCounter();
    }

    // ── Update the question counter badge and number labels ────────────────
    function refreshCounter() {
        const blocks = document.querySelectorAll('.question-builder');
        let visible = 0;
        blocks.forEach((b, i) => {
            const deleted = b.dataset.deleted === '1';
            if (!deleted) {
                visible++;
                const numEl = b.querySelector('.q-num-label');
                const badge = b.querySelector('.q-num-badge');
                if (numEl) numEl.textContent = 'Question ' + visible;
                if (badge) badge.textContent = visible;
            }
        });
        document.getElementById('questionCountBadge').textContent = visible;
        document.getElementById('noQuestionsHint').style.display =
            visible === 0 ? 'block' : 'none';
    }

    // ── Collect all data before server submit ──────────────────────────────
    function collectAllQuestions() {
        const blocks = document.querySelectorAll('.question-builder');
        const questions = [];
        let valid = true;
        let qNum = 0;

        blocks.forEach(block => {
            if (block.dataset.deleted === '1') return; // skip – flagged for deletion on server
            qNum++;
            const text  = block.querySelector('.q-text').value.trim();
            const score = parseFloat(block.querySelector('.q-score').value) || 10;
            const qid   = block.dataset.qid;
            const isNew = block.dataset.isnew === '1';

            if (!text) {
                alert('Question ' + qNum + ' is missing its question text.');
                valid = false;
                return;
            }

            const opts = LETTERS.map(l => block.querySelector('.q-opt-' + l).value.trim());
            const nonEmpty = opts.filter(o => o).length;
            if (nonEmpty < 2) {
                alert('Question ' + qNum + ' must have at least two options filled in.');
                valid = false;
                return;
            }

            const correctRadio = block.querySelector('input[type="radio"]:checked');
            const correct = correctRadio ? correctRadio.value : 'A';

            questions.push({
                questionID:     isNew ? 0 : parseInt(qid),
                questionText:   text,
                questionsScore: score,
                optionA: opts[0],
                optionB: opts[1],
                optionC: opts[2],
                optionD: opts[3],
                correctAnswer: correct
            });
        });

        if (!valid) return false;

        document.getElementById('<%= hfQuestionsData.ClientID %>').value =
            JSON.stringify(questions);
        document.getElementById('<%= hfDeletedQuestionIDs.ClientID %>').value =
            JSON.stringify(Array.from(pendingDeletes));

        return true;
    }

    // ── Helpers ────────────────────────────────────────────────────────────
    function escHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function countChars(el, countId, max) {
        const len = el.value.length;
        const counter = document.getElementById(countId);
        if (!counter) return;
        counter.textContent = len + ' / ' + max;
        counter.className = 'char-count' +
            (len > max * 0.9 ? (len >= max ? ' danger' : ' warn') : '');
    }

    function toggleUserDropdown() {
        const d = document.getElementById('userDropdown');
        if (d) d.style.display = d.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function (e) {
        const chip = document.querySelector('.nav-user-chip');
        const dd   = document.getElementById('userDropdown');
        if (dd && chip && !chip.contains(e.target)) dd.style.display = 'none';
    });
    function doLogout() { window.location.href = 'HomePage.aspx?action=logout'; }
</script>
</body>
</html>
