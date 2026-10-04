<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateCourse.aspx.cs" Inherits="WAPP_FinalAssignment.CreateCourse" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Course — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        /* ==========================================================
           Page-local styles for Create Course
           ========================================================== */
        .char-count { font-size: 11px; color: var(--ink-400); text-align: right; margin-top: 3px; }
        .char-count.warn   { color: var(--brand-amber); }
        .char-count.danger { color: var(--brand-red); }

        /* Category chip-style selector */
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 10px;
            margin-top: 4px;
        }
        .category-chip {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 14px 12px;
            border: 1.5px solid var(--ink-200);
            border-radius: var(--radius-md);
            background: var(--surface-0);
            font-size: 13px;
            font-weight: 600;
            color: var(--ink-700);
            cursor: pointer;
            transition: all var(--transition);
            user-select: none;
            text-align: center;
        }
        .category-chip:hover {
            border-color: var(--brand-blue);
            color: var(--brand-blue);
            background: var(--brand-blue-light);
            transform: translateY(-1px);
        }
        .category-chip.selected {
            border-color: var(--brand-blue);
            background: var(--brand-blue-light);
            color: var(--brand-blue-dark);
            box-shadow: 0 0 0 3px rgba(26,115,232,0.10);
        }
        .category-chip .cat-emoji { font-size: 18px; line-height: 1; }

        /* Header image preview area */
        .header-image-preview {
            width: 100%;
            aspect-ratio: 2 / 1;
            background: linear-gradient(135deg, #e8f0fe 0%, #c2d9fb 100%);
            border-radius: var(--radius-md);
            overflow: hidden;
            position: relative;
            border: 1.5px dashed var(--ink-200);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: 12px;
            transition: border-color var(--transition);
        }
        .header-image-preview.has-image { border-style: solid; border-color: var(--ink-100); }
        .header-image-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: none;
        }
        .header-image-preview img.loaded { display: block; }
        .header-image-placeholder {
            text-align: center;
            color: var(--ink-400);
            padding: 20px;
        }
        .header-image-placeholder .icon { font-size: 40px; margin-bottom: 8px; opacity: 0.6; }
        .header-image-placeholder p { font-size: 13px; }

        /* Hero strip preview that mimics how the course will look on CoursePage */
        .live-mini-preview {
            margin-top: 16px;
            background: var(--ink-900);
            border-radius: var(--radius-md);
            overflow: hidden;
            position: relative;
            isolation: isolate;
            min-height: 140px;
        }
        .live-mini-preview img {
            position: absolute; inset: 0;
            width: 100%; height: 100%;
            object-fit: cover;
            opacity: 0.4;
        }
        .live-mini-preview .lmp-overlay {
            position: absolute; inset: 0;
            background: linear-gradient(105deg, rgba(10,10,20,0.92) 0%, rgba(10,10,20,0.4) 100%);
        }
        .live-mini-preview .lmp-content {
            position: relative; z-index: 1;
            padding: 24px 28px;
            color: #fff;
        }
        .live-mini-preview .lmp-eyebrow {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: rgba(255,255,255,0.6);
            margin-bottom: 6px;
        }
        .live-mini-preview .lmp-title {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 4px;
            letter-spacing: -0.3px;
        }
        .live-mini-preview .lmp-desc {
            font-size: 13px;
            color: rgba(255,255,255,0.7);
            line-height: 1.5;
            max-width: 480px;
        }

        /* Hint chip row above title */
        .form-hero-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: var(--brand-blue-light);
            color: var(--brand-blue-dark);
            border-radius: var(--radius-full);
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            margin-bottom: 14px;
        }

        /* Empty hidden radio inputs for category */
        .cat-radio { display: none; }
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
                <span class="breadcrumb-current">Create Course</span>
            </nav>

            <span class="form-hero-eyebrow">📚 New Course</span>
            <h1 class="page-title">Build a course your learners will love</h1>
            <p class="page-subtitle">Outline the essentials now. You can add lessons and quizzes once the course is created. Fields marked <span style="color:var(--brand-red);">*</span> are required.</p>

            <!-- Server validation message -->
            <asp:Panel ID="pnlError" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-error">
                    <span>⚠</span>
                    <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                </div>
            </asp:Panel>

            <!-- Hidden field stores selected category for postback -->
            <asp:HiddenField ID="hfCategory" runat="server" Value="" />

            <!-- ============================================================
                 SECTION 1 — Course Identity
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title">📘 Course Identity</div>

                <div class="form-group">
                    <label class="form-label">Course Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtCourseName" runat="server" CssClass="form-control"
                        placeholder="e.g. Intro to ASP.NET Web Forms"
                        MaxLength="50"
                        oninput="countChars(this,'titleCount',50)"></asp:TextBox>
                    <div class="char-count" id="titleCount">0 / 50</div>
                    <asp:RequiredFieldValidator ID="rfvCourseName" runat="server"
                        ControlToValidate="txtCourseName"
                        ErrorMessage="Course name is required."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RequiredFieldValidator>
                </div>

                <div class="form-group">
                    <label class="form-label">Short Description <span class="required">*</span></label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                        TextMode="MultiLine" Rows="3"
                        placeholder="In a sentence or two, tell learners what they'll get out of this course."
                        MaxLength="200"
                        oninput="countChars(this,'descCount',200)"></asp:TextBox>
                    <div class="char-count" id="descCount">0 / 200</div>
                    <asp:RequiredFieldValidator ID="rfvDescription" runat="server"
                        ControlToValidate="txtDescription"
                        ErrorMessage="Description is required."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RequiredFieldValidator>
                </div>
            </div>

            <!-- ============================================================
                 SECTION 2 — Classification & Pacing
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title">🏷️ Category & Pacing</div>

                <div class="form-group">
                    <label class="form-label">Category <span class="required">*</span></label>
                    <span class="form-hint" style="display:block;margin-bottom:8px;">Pick the area that best describes this course.</span>

                    <div class="category-grid" id="categoryGrid">
                        <input type="radio" name="catRadio" id="catProgramming" value="Programming" class="cat-radio" />
                        <label for="catProgramming" class="category-chip" data-cat="Programming">
                            <span class="cat-emoji">💻</span> Programming
                        </label>

                        <input type="radio" name="catRadio" id="catDesign" value="Design" class="cat-radio" />
                        <label for="catDesign" class="category-chip" data-cat="Design">
                            <span class="cat-emoji">🎨</span> Design
                        </label>

                        <input type="radio" name="catRadio" id="catBusiness" value="Business" class="cat-radio" />
                        <label for="catBusiness" class="category-chip" data-cat="Business">
                            <span class="cat-emoji">💼</span> Business
                        </label>

                        <input type="radio" name="catRadio" id="catData" value="Data Science" class="cat-radio" />
                        <label for="catData" class="category-chip" data-cat="Data Science">
                            <span class="cat-emoji">📊</span> Data Science
                        </label>

                        <input type="radio" name="catRadio" id="catMarketing" value="Marketing" class="cat-radio" />
                        <label for="catMarketing" class="category-chip" data-cat="Marketing">
                            <span class="cat-emoji">📣</span> Marketing
                        </label>

                        <input type="radio" name="catRadio" id="catCloud" value="Cloud" class="cat-radio" />
                        <label for="catCloud" class="category-chip" data-cat="Cloud">
                            <span class="cat-emoji">☁️</span> Cloud
                        </label>

                        <input type="radio" name="catRadio" id="catSecurity" value="Security" class="cat-radio" />
                        <label for="catSecurity" class="category-chip" data-cat="Security">
                            <span class="cat-emoji">🔒</span> Security
                        </label>

                        <input type="radio" name="catRadio" id="catOther" value="Other" class="cat-radio" />
                        <label for="catOther" class="category-chip" data-cat="Other">
                            <span class="cat-emoji">✨</span> Other
                        </label>
                    </div>
                    <asp:CustomValidator ID="cvCategory" runat="server"
                        ErrorMessage="Please select a category."
                        ClientValidationFunction="validateCategory"
                        ValidateEmptyText="true"
                        Display="Dynamic" CssClass="form-error" Style="display:block;margin-top:8px;">
                    </asp:CustomValidator>
                </div>

                <div class="form-group" style="margin-top:24px;">
                    <label class="form-label">Total Course Duration (hours) <span class="required">*</span></label>
                    <asp:TextBox ID="txtDuration" runat="server" CssClass="form-control"
                        TextMode="Number"
                        placeholder="e.g. 12"
                        Style="max-width:240px;"></asp:TextBox>
                    <span class="form-hint">Estimated total time learners need to complete every lesson and quiz in this course.</span>
                    <asp:RequiredFieldValidator ID="rfvDuration" runat="server"
                        ControlToValidate="txtDuration"
                        ErrorMessage="Duration is required."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RequiredFieldValidator>
                    <asp:RangeValidator ID="rvDuration" runat="server"
                        ControlToValidate="txtDuration"
                        MinimumValue="1" MaximumValue="500" Type="Integer"
                        ErrorMessage="Duration must be between 1 and 500 hours."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RangeValidator>
                </div>
            </div>

            <!-- ============================================================
                 SECTION 3 — Header Image
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title">🖼️ Course Header Image</div>

                <div class="form-group" style="margin-bottom:0;">
                    <label class="form-label">Header Image URL <span class="required">*</span></label>
                    <asp:TextBox ID="txtHeaderImageURL" runat="server" CssClass="form-control"
                        placeholder="https://images.unsplash.com/photo-…"
                        MaxLength="255"
                        oninput="updateImagePreview(this.value); countChars(this,'imgCount',255);"></asp:TextBox>
                    <div class="char-count" id="imgCount">0 / 255</div>
                    <span class="form-hint">Direct image URL. Wide aspect ratio (≈2:1) works best — recommended 1200×600 px.</span>
                    <asp:RequiredFieldValidator ID="rfvHeaderImage" runat="server"
                        ControlToValidate="txtHeaderImageURL"
                        ErrorMessage="Header image URL is required."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ID="revHeaderImage" runat="server"
                        ControlToValidate="txtHeaderImageURL"
                        ValidationExpression="^(https?:\/\/).+$"
                        ErrorMessage="Please enter a valid http:// or https:// URL."
                        Display="Dynamic" CssClass="form-error" Style="display:block;">
                    </asp:RegularExpressionValidator>

                    <!-- Visual preview -->
                    <div class="header-image-preview" id="imgPreviewBox">
                        <img id="imgPreview" src="" alt="" onload="this.classList.add('loaded'); document.getElementById('imgPreviewBox').classList.add('has-image'); document.getElementById('imgPlaceholder').style.display='none';" onerror="this.classList.remove('loaded'); document.getElementById('imgPreviewBox').classList.remove('has-image'); document.getElementById('imgPlaceholder').style.display='block';" />
                        <div class="header-image-placeholder" id="imgPlaceholder">
                            <div class="icon">🖼️</div>
                            <p>Paste a URL above to preview your header.</p>
                        </div>
                    </div>

                    <!-- Mini course-page-style preview, populated live -->
                    <div class="live-mini-preview" id="liveMiniPreview" style="display:none;">
                        <img id="liveMiniImg" src="" alt="" />
                        <div class="lmp-overlay"></div>
                        <div class="lmp-content">
                            <div class="lmp-eyebrow">Course Preview</div>
                            <div class="lmp-title" id="liveMiniTitle">Your Course Name</div>
                            <div class="lmp-desc"  id="liveMiniDesc">Your course description will appear here once you start typing.</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action buttons -->
            <div style="display:flex;gap:12px;justify-content:flex-end;margin-top:8px;flex-wrap:wrap;">
                <button type="button" class="btn btn-secondary" onclick="window.location.href='EducatorDashboard.aspx'">Cancel</button>
                <asp:Button ID="btnCreateCourse" runat="server"
                    Text="Create Course →"
                    CssClass="btn btn-primary btn-lg"
                    OnClick="btnCreateCourse_Click"
                    OnClientClick="return prepareSubmit();" />
            </div>

            <!-- Tip card under the form -->
            <div class="card" style="margin-top:32px;background:var(--brand-blue-light);border-color:#90caf9;padding:20px 24px;">
                <div style="display:flex;gap:14px;align-items:flex-start;">
                    <div style="font-size:24px;line-height:1;">💡</div>
                    <div>
                        <div style="font-size:14px;font-weight:700;color:var(--brand-blue-dark);margin-bottom:4px;">Next steps after creating</div>
                        <div style="font-size:13px;color:var(--ink-700);line-height:1.6;">
                            Once your course is saved, you'll be taken to the editor where you can add lessons,
                            create quizzes, and tweak details. An empty course is fine — learners just won't see
                            content until you publish at least one lesson.
                        </div>
                    </div>
                </div>
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
                <p>Hands-on ASP.NET learning platform — APU Group 14.</p>
            </div>
            <div class="footer-col"><h4>Create</h4><a href="EducatorDashboard.aspx">My Dashboard</a><a href="CreateCourse.aspx">New Course</a></div>
            <div class="footer-col"><h4>Account</h4><a href="ProfilePage.aspx">My Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a></div>
        </div>
        <div class="footer-bottom"><span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span></div>
    </div>
</footer>

</form>

<script>
    // ── Char counter ─────────────────────────────────────────────────────
    function countChars(el, countId, max) {
        const len = el.value.length;
        const counter = document.getElementById(countId);
        if (!counter) return;
        counter.textContent = len + ' / ' + max;
        counter.className = 'char-count' + (len > max * 0.9 ? (len >= max ? ' danger' : ' warn') : '');
    }

    // ── Category chip selection ──────────────────────────────────────────
    function selectCategory(value) {
        document.querySelectorAll('.category-chip').forEach(chip => chip.classList.remove('selected'));
        const target = document.querySelector('.category-chip[data-cat="' + value + '"]');
        if (target) target.classList.add('selected');
        document.getElementById('<%= hfCategory.ClientID %>').value = value;
    }

    document.querySelectorAll('.category-chip').forEach(chip => {
        chip.addEventListener('click', function (e) {
            e.preventDefault();
            selectCategory(this.dataset.cat);
        });
    });

    // ASP.NET CustomValidator: returns whether category is set
    function validateCategory(source, args) {
        const cat = document.getElementById('<%= hfCategory.ClientID %>').value;
        args.IsValid = !!cat;
    }

    // ── Header image preview ─────────────────────────────────────────────
    function updateImagePreview(url) {
        const img = document.getElementById('imgPreview');
        const lmp = document.getElementById('liveMiniPreview');
        const lmpImg = document.getElementById('liveMiniImg');
        url = (url || '').trim();
        if (!url) {
            img.src = '';
            img.classList.remove('loaded');
            document.getElementById('imgPreviewBox').classList.remove('has-image');
            document.getElementById('imgPlaceholder').style.display = 'block';
            lmp.style.display = 'none';
            return;
        }
        img.src = url;
        lmpImg.src = url;
        lmp.style.display = 'block';
    }

    // Live update of mini-preview text
    function bindLivePreview() {
        const titleEl = document.getElementById('<%= txtCourseName.ClientID %>');
        const descEl  = document.getElementById('<%= txtDescription.ClientID %>');
        const liveTitle = document.getElementById('liveMiniTitle');
        const liveDesc  = document.getElementById('liveMiniDesc');
        if (titleEl) titleEl.addEventListener('input', () => {
            liveTitle.textContent = titleEl.value.trim() || 'Your Course Name';
        });
        if (descEl) descEl.addEventListener('input', () => {
            liveDesc.textContent = descEl.value.trim() || 'Your course description will appear here once you start typing.';
        });
    }

    // ── On submit: ensure category hidden field is set ───────────────────
    function prepareSubmit() {
        const cat = document.getElementById('<%= hfCategory.ClientID %>').value;
        if (!cat) {
            // CustomValidator will display the error; abort submit
            return false;
        }
        return true;
    }

    // ── Init on load ─────────────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', function () {
        bindLivePreview();
        // Restore selected category if postback
        const saved = document.getElementById('<%= hfCategory.ClientID %>').value;
        if (saved) selectCategory(saved);
        // Init counters for any pre-filled values
        const t = document.getElementById('<%= txtCourseName.ClientID %>');
        const d = document.getElementById('<%= txtDescription.ClientID %>');
        const i = document.getElementById('<%= txtHeaderImageURL.ClientID %>');
        if (t) countChars(t, 'titleCount', 50);
        if (d) countChars(d, 'descCount', 200);
        if (i) {
            countChars(i, 'imgCount', 255);
            if (i.value.trim()) updateImagePreview(i.value);
        }
    });

    // ── Topnav user dropdown ─────────────────────────────────────────────
    function toggleUserDropdown() {
        const d = document.getElementById('userDropdown');
        if (d) d.style.display = d.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function (e) {
        const chip = document.querySelector('.nav-user-chip');
        const dd = document.getElementById('userDropdown');
        if (dd && chip && !chip.contains(e.target)) dd.style.display = 'none';
    });
    function doLogout() { window.location.href = 'HomePage.aspx?action=logout'; }
</script>
</body>
</html>
