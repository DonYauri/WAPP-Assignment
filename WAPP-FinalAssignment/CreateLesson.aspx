<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateLesson.aspx.cs" Inherits="WAPP_FinalAssignment.CreateLesson" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Lesson — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .char-count { font-size: 11px; color: var(--ink-400); text-align: right; margin-top: 3px; }
        .char-count.warn { color: var(--brand-amber); }
        .char-count.danger { color: var(--brand-red); }

        .preview-panel {
            background: var(--ink-900);
            border-radius: var(--radius-md);
            padding: 20px 24px;
            color: #e8e8e8;
            font-family: 'DM Mono', monospace;
            font-size: 12px;
            line-height: 1.7;
            max-height: 300px;
            overflow-y: auto;
            white-space: pre-wrap;
        }

        .level-selector { display: flex; gap: 10px; flex-wrap: wrap; }
        .level-option { display: none; }
        .level-label {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 18px;
            border: 1.5px solid var(--ink-200);
            border-radius: var(--radius-full);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition);
            color: var(--ink-700);
            user-select: none;
        }
        .level-option:checked + .level-label {
            border-color: var(--brand-blue);
            background: var(--brand-blue-light);
            color: var(--brand-blue-dark);
        }
        .level-label:hover { border-color: var(--brand-blue); color: var(--brand-blue); }
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
                <span class="breadcrumb-current">Create Lesson</span>
            </nav>

            <h1 class="page-title">Create a New Lesson</h1>
            <p class="page-subtitle">Add a lesson to <strong><asp:Label ID="lblCourseNameSub" runat="server" Text="this course"></asp:Label></strong>. Fields marked <span style="color:var(--brand-red);">*</span> are required.</p>

            <!-- Server validation message -->
            <asp:Panel ID="pnlError" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-error">
                    <span>⚠</span>
                    <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                </div>
            </asp:Panel>

            <!-- Hidden courseID -->
            <asp:HiddenField ID="hfCourseID" runat="server" Value="" />

            <!-- SECTION 1: Basic Info -->
            <div class="form-section">
                <div class="form-section-title">📝 Lesson Details</div>

                <div class="form-group">
                    <label class="form-label">Lesson Title <span class="required">*</span></label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g. Introduction to ASP.NET MVC" MaxLength="50" oninput="countChars(this, 'titleCount', 50)"></asp:TextBox>
                    <div class="char-count" id="titleCount">0 / 50</div>
                    <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ErrorMessage="Lesson title is required." CssClass="form-error" Display="Dynamic" Style="display:block;"></asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">Short Description <span class="required">*</span></label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Briefly describe what this lesson covers (max 200 characters)." MaxLength="200" oninput="countChars(this, 'descCount', 200)"></asp:TextBox>
                    <div class="char-count" id="descCount">0 / 200</div>
                    <asp:RequiredFieldValidator ID="rfvDescription" runat="server" ControlToValidate="txtDescription" ErrorMessage="Description is required." CssClass="form-error" Display="Dynamic" Style="display:block;"></asp:RequiredFieldValidator>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Duration (minutes) <span class="required">*</span></label>
                        <asp:TextBox ID="txtDuration" runat="server" CssClass="form-control" placeholder="e.g. 30" TextMode="Number"></asp:TextBox>
                        <span class="form-hint">Estimated time to complete this lesson.</span>
                        <asp:RequiredFieldValidator ID="rfvDuration" runat="server" ControlToValidate="txtDuration" ErrorMessage="Duration is required." CssClass="form-error" Display="Dynamic" Style="display:block;"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rvDuration" runat="server" ControlToValidate="txtDuration" MinimumValue="1" MaximumValue="600" Type="Integer" ErrorMessage="Duration must be between 1 and 600 minutes." CssClass="form-error" Display="Dynamic" Style="display:block;"></asp:RangeValidator>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Difficulty Level <span class="required">*</span></label>
                        <div class="level-selector" style="margin-top:4px;">
                            <input type="radio" name="lessonLevel" id="lvlBeg" value="Beginner" class="level-option" checked="checked" />
                            <label for="lvlBeg" class="level-label">🟢 Beginner</label>
                            <input type="radio" name="lessonLevel" id="lvlInt" value="Intermediate" class="level-option" />
                            <label for="lvlInt" class="level-label">🟡 Intermediate</label>
                            <input type="radio" name="lessonLevel" id="lvlAdv" value="Advanced" class="level-option" />
                            <label for="lvlAdv" class="level-label">🔴 Advanced</label>
                        </div>
                        <!-- Hidden field to post selected level -->
                        <asp:HiddenField ID="hfLevel" runat="server" Value="Beginner" />
                    </div>
                </div>
            </div>

            <!-- SECTION 2: Media -->
            <div class="form-section">
                <div class="form-section-title">🎬 Media (Optional)</div>
                <div class="form-group">
                    <label class="form-label">Video URL</label>
                    <asp:TextBox ID="txtVideoURL" runat="server" CssClass="form-control" placeholder="https://www.youtube.com/embed/VIDEO_ID"></asp:TextBox>
                    <span class="form-hint">Paste a YouTube embed URL (e.g. https://www.youtube.com/embed/dQw4w9WgXcQ). Leave blank if no video.</span>
                </div>
                <!-- Preview -->
                <div id="videoPreviewWrap" style="display:none;margin-top:8px;">
                    <div style="width:100%;aspect-ratio:16/9;border-radius:var(--radius-md);overflow:hidden;background:var(--ink-900);">
                        <iframe id="videoPreviewFrame" src="" style="width:100%;height:100%;border:none;" allowfullscreen></iframe>
                    </div>
                </div>
                <button type="button" class="btn btn-secondary btn-sm" style="margin-top:10px;" onclick="previewVideo()">Preview Video</button>
            </div>

            <!-- SECTION 3: Lesson Content / README -->
            <div class="form-section">
                <div class="form-section-title" style="justify-content:space-between;">
                    <span>📄 Lesson Content (Markdown supported)</span>
                    <div style="display:flex;gap:8px;">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="switchEditor('write')">Write</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="switchEditor('preview')">Preview</button>
                    </div>
                </div>
                <div id="writePane">
                    <asp:TextBox ID="txtReadme" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="20"
                        placeholder="Write the lesson content in Markdown or plain text.&#10;&#10;## Introduction&#10;Welcome to this lesson...&#10;&#10;## Key Concepts&#10;- Concept 1&#10;- Concept 2&#10;&#10;```csharp&#10;// Example code block&#10;var app = WebApplication.Create();&#10;```"
                        style="font-family:'DM Mono',monospace;font-size:13px;line-height:1.7;resize:vertical;min-height:360px;"
                        oninput="updatePreview(this.value)"></asp:TextBox>
                </div>
                <div id="previewPane" style="display:none;">
                    <div style="background:var(--surface-0);border:1px solid var(--ink-200);border-radius:var(--radius-sm);padding:24px;min-height:360px;">
                        <div id="markdownPreviewContent" class="readme-content" style="color:var(--ink-700);line-height:1.75;"></div>
                    </div>
                </div>
                <span class="form-hint" style="margin-top:6px;display:block;">Markdown is supported: **bold**, *italic*, # headings, ```code blocks```, - lists, etc.</span>
            </div>

            <!-- Action buttons -->
            <div style="display:flex;gap:12px;justify-content:flex-end;margin-top:8px;flex-wrap:wrap;">
                <button type="button" class="btn btn-secondary" onclick="history.back()">Cancel</button>
                <asp:Button ID="btnSaveDraft" runat="server" Text="Save Draft" CssClass="btn btn-secondary" OnClick="btnSaveLesson_Click" />
                <asp:Button ID="btnPublish" runat="server" Text="Publish Lesson →" CssClass="btn btn-primary" OnClick="btnSaveLesson_Click" />
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
    // ---- Char counter ----
    function countChars(el, countId, max) {
        const len = el.value.length;
        const counter = document.getElementById(countId);
        counter.textContent = len + ' / ' + max;
        counter.className = 'char-count' + (len > max * 0.9 ? (len >= max ? ' danger' : ' warn') : '');
    }

    // ---- Level selection syncs to hidden field ----
    document.querySelectorAll('input[name="lessonLevel"]').forEach(radio => {
        radio.addEventListener('change', function() {
            document.getElementById('<%= hfLevel.ClientID %>').value = this.value;
        });
    });

    // On load, set default from hidden field (useful in edit scenario)
    window.addEventListener('DOMContentLoaded', function() {
        const savedLevel = document.getElementById('<%= hfLevel.ClientID %>').value;
        const radio = document.querySelector('input[name="lessonLevel"][value="' + savedLevel + '"]');
        if (radio) radio.checked = true;
    });

    // ---- Video preview ----
    function toEmbed(url) {
        if (!url) return url;
        url = url.trim();
        // youtu.be/<id>
        var m = url.match(/^https?:\/\/youtu\.be\/([\w-]{6,})/i);
        if (m) return 'https://www.youtube.com/embed/' + m[1];
        // youtube.com/watch?v=<id>
        m = url.match(/[?&]v=([\w-]{6,})/);
        if (m && /youtube\.com/i.test(url)) return 'https://www.youtube.com/embed/' + m[1];
        // youtube.com/shorts/<id>
        m = url.match(/youtube\.com\/shorts\/([\w-]{6,})/i);
        if (m) return 'https://www.youtube.com/embed/' + m[1];
        return url;
    }

    function previewVideo() {
        const url = document.getElementById('<%= txtVideoURL.ClientID %>').value.trim();
        if (!url) { alert('Please enter a video URL first.'); return; }
        document.getElementById('videoPreviewFrame').src = toEmbed(url);
        document.getElementById('videoPreviewWrap').style.display = 'block';
    }

    // ---- Write / Preview editor toggle ----
    function switchEditor(mode) {
        const writePane = document.getElementById('writePane');
        const previewPane = document.getElementById('previewPane');
        if (mode === 'preview') {
            const raw = document.getElementById('<%= txtReadme.ClientID %>').value;
            document.getElementById('markdownPreviewContent').innerHTML = simpleMarkdown(raw);
            writePane.style.display = 'none';
            previewPane.style.display = 'block';
        } else {
            writePane.style.display = 'block';
            previewPane.style.display = 'none';
        }
    }

    // ---- Minimal Markdown renderer for preview ----
    function simpleMarkdown(text) {
        if (!text) return '<p style="color:var(--ink-400);font-style:italic;">Nothing to preview yet.</p>';
        let html = text
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/```[\w]*\n([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
            .replace(/`([^`]+)`/g, '<code>$1</code>')
            .replace(/^#{3} (.+)$/gm, '<h3>$1</h3>')
            .replace(/^#{2} (.+)$/gm, '<h2>$1</h2>')
            .replace(/^#{1} (.+)$/gm, '<h1>$1</h1>')
            .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
            .replace(/\*(.+?)\*/g, '<em>$1</em>')
            .replace(/^- (.+)$/gm, '<li>$1</li>')
            .replace(/(<li>[\s\S]*?<\/li>)/g, '<ul>$1</ul>')
            .replace(/^(?!<[huplicode])(.*\S.*)$/gm, '<p>$1</p>')
            .replace(/<\/ul>\s*<ul>/g, '');
        return html;
    }

    function updatePreview(val) { /* live preview is opt-in via button */ }

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
