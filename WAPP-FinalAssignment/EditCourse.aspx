<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditCourse.aspx.cs" Inherits="WAPP_FinalAssignment.EditCourse" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Edit Course — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        /* ==========================================================
           Page-local styles for Edit Course
           ========================================================== */
        .char-count { font-size: 11px; color: var(--ink-400); text-align: right; margin-top: 3px; }
        .char-count.warn   { color: var(--brand-amber); }
        .char-count.danger { color: var(--brand-red); }

        /* Course hero strip — shows current header image and stats */
        .course-hero {
            position: relative;
            border-radius: var(--radius-xl);
            overflow: hidden;
            min-height: 220px;
            margin-bottom: 32px;
            isolation: isolate;
            background: var(--ink-900);
        }
        .course-hero img {
            position: absolute; inset: 0;
            width: 100%; height: 100%;
            object-fit: cover;
            opacity: 0.45;
        }
        .course-hero .hero-overlay-grad {
            position: absolute; inset: 0;
            background: linear-gradient(105deg, rgba(10,10,20,0.92) 0%, rgba(10,10,20,0.4) 100%);
        }
        .course-hero .hero-inner {
            position: relative; z-index: 1;
            padding: 36px 40px;
            color: #fff;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .course-hero .hero-eyebrow-row {
            display: flex; align-items: center; gap: 10px;
            font-size: 11px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 1px;
            color: rgba(255,255,255,0.65);
        }
        .course-hero h2 {
            font-size: 28px; font-weight: 700;
            letter-spacing: -0.5px;
            color: #fff;
            margin: 0;
        }
        .course-hero .hero-stats {
            display: flex; gap: 24px;
            margin-top: 8px;
            flex-wrap: wrap;
        }
        .course-hero .hero-stat .label {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: rgba(255,255,255,0.55);
        }
        .course-hero .hero-stat .value {
            font-size: 18px;
            font-weight: 700;
            color: #fff;
        }

        /* Category chip selector (matches CreateCourse pattern) */
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 10px;
            margin-top: 4px;
        }
        .category-chip {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 14px 12px;
            border: 1.5px solid var(--ink-200);
            border-radius: var(--radius-md);
            background: var(--surface-0);
            font-size: 13px; font-weight: 600;
            color: var(--ink-700);
            cursor: pointer;
            transition: all var(--transition);
            user-select: none; text-align: center;
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
        .cat-radio { display: none; }

        /* Header image preview */
        .header-image-preview {
            width: 100%;
            aspect-ratio: 2 / 1;
            background: linear-gradient(135deg, #e8f0fe 0%, #c2d9fb 100%);
            border-radius: var(--radius-md);
            overflow: hidden; position: relative;
            border: 1.5px dashed var(--ink-200);
            display: flex; align-items: center; justify-content: center;
            margin-top: 12px;
            transition: border-color var(--transition);
        }
        .header-image-preview.has-image { border-style: solid; border-color: var(--ink-100); }
        .header-image-preview img {
            width: 100%; height: 100%; object-fit: cover; display: none;
        }
        .header-image-preview img.loaded { display: block; }
        .header-image-placeholder {
            text-align: center; color: var(--ink-400); padding: 20px;
        }
        .header-image-placeholder .icon { font-size: 40px; margin-bottom: 8px; opacity: 0.6; }

        /* Content list rows for lessons & quizzes (mirrors educator dashboard) */
        .content-list {
            display: flex;
            flex-direction: column;
        }
        .content-row {
            display: flex; align-items: center; gap: 12px;
            padding: 14px 0;
            border-bottom: 1px solid var(--ink-50);
        }
        .content-row:last-child { border-bottom: none; }

        .content-row-icon {
            width: 36px; height: 36px;
            border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 16px; flex-shrink: 0;
        }

        .content-row-meta {
            font-size: 12px; color: var(--ink-400);
            display: flex; gap: 8px; flex-wrap: wrap;
            margin-top: 2px;
        }

        .content-row-actions {
            display: flex; gap: 6px;
            flex-shrink: 0;
        }

        .empty-content {
            text-align: center;
            padding: 32px 16px;
            border: 1.5px dashed var(--ink-200);
            border-radius: var(--radius-md);
            color: var(--ink-400);
        }
        .empty-content .icon { font-size: 32px; margin-bottom: 8px; opacity: 0.7; }
        .empty-content p { font-size: 13px; margin-bottom: 12px; color: var(--ink-600); }

        /* Tab pills for the content manager */
        .pill-tabs {
            display: inline-flex;
            background: var(--ink-50);
            border-radius: var(--radius-full);
            padding: 4px;
            margin-bottom: 16px;
            gap: 2px;
        }
        .pill-tab {
            padding: 8px 18px;
            font-size: 13px; font-weight: 600;
            border: none; background: transparent;
            border-radius: var(--radius-full);
            cursor: pointer;
            color: var(--ink-600);
            font-family: 'DM Sans', sans-serif;
            transition: all var(--transition);
        }
        .pill-tab:hover { color: var(--ink-900); }
        .pill-tab.active {
            background: var(--surface-0);
            color: var(--brand-blue);
            box-shadow: var(--shadow-xs);
        }

        .pill-tab .pill-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 20px; height: 20px;
            padding: 0 6px;
            margin-left: 6px;
            background: var(--ink-200);
            color: var(--ink-700);
            border-radius: var(--radius-full);
            font-size: 11px;
            font-weight: 700;
        }
        .pill-tab.active .pill-count { background: var(--brand-blue-light); color: var(--brand-blue-dark); }

        /* Danger zone */
        .danger-zone {
            border: 1px solid #ef9a9a;
            background: var(--brand-red-light);
            border-radius: var(--radius-lg);
            padding: 24px 28px;
            margin-top: 24px;
        }
        .danger-zone h3 {
            font-size: 15px; font-weight: 700;
            color: var(--brand-red);
            margin-bottom: 6px;
        }
        .danger-zone p {
            font-size: 13px; color: #8a2723;
            margin-bottom: 14px; line-height: 1.5;
        }

        /* Sticky save-bar at bottom of form */
        .save-bar {
            position: sticky;
            bottom: 16px;
            background: var(--surface-0);
            border: 1px solid var(--ink-100);
            border-radius: var(--radius-lg);
            padding: 14px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            box-shadow: var(--shadow-md);
            margin-top: 20px;
            flex-wrap: wrap;
        }
        .save-bar .save-bar-text {
            font-size: 13px; color: var(--ink-600);
        }
        .save-bar .save-bar-text strong { color: var(--ink-900); }

        .form-hero-eyebrow {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 6px 14px;
            background: var(--brand-amber-light);
            color: #c47d00;
            border-radius: var(--radius-full);
            font-size: 12px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            margin-bottom: 14px;
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
                <a href="#" id="aCourseLink" runat="server"><asp:Label ID="lblBreadcrumbCourseName" runat="server" Text="Course"></asp:Label></a>
                <span class="breadcrumb-sep">›</span>
                <span class="breadcrumb-current">Edit</span>
            </nav>

            <!-- Hidden id field -->
            <asp:HiddenField ID="hfCourseID" runat="server" Value="" />
            <asp:HiddenField ID="hfCategory" runat="server" Value="" />

            <!-- Course Hero — shows live image + name -->
            <div class="course-hero" id="courseHero">
                <img id="heroImg" src="" alt="" onerror="this.style.display='none'" />
                <div class="hero-overlay-grad"></div>
                <div class="hero-inner">
                    <div class="hero-eyebrow-row">
                        <span>📚 Editing Course</span>
                        <span style="opacity:0.6;">·</span>
                        <span id="heroCategory">—</span>
                    </div>
                    <h2 id="heroTitle">Course Name</h2>
                    <div class="hero-stats">
                        <div class="hero-stat">
                            <div class="label">Lessons</div>
                            <div class="value"><asp:Label ID="lblStatLessons" runat="server" Text="0"></asp:Label></div>
                        </div>
                        <div class="hero-stat">
                            <div class="label">Quizzes</div>
                            <div class="value"><asp:Label ID="lblStatQuizzes" runat="server" Text="0"></asp:Label></div>
                        </div>
                        <div class="hero-stat">
                            <div class="label">Enrolled</div>
                            <div class="value"><asp:Label ID="lblStatEnrolled" runat="server" Text="0"></asp:Label></div>
                        </div>
                        <div class="hero-stat">
                            <div class="label">Created</div>
                            <div class="value" style="font-size:14px;font-weight:600;"><asp:Label ID="lblStatCreated" runat="server" Text="—"></asp:Label></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Page heading row -->
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-bottom:6px;">
                <div>
                    <span class="form-hero-eyebrow">✏️ Course Editor</span>
                    <h1 class="page-title" style="margin-bottom:0;">Edit Course Details</h1>
                </div>
                <div style="display:flex;gap:8px;flex-shrink:0;">
                    <a href="#" id="aViewCourse" runat="server" class="btn btn-secondary btn-sm" target="_blank">↗ View Live</a>
                </div>
            </div>
            <p class="page-subtitle">Tweak the basics, manage content below, and save when ready.</p>

            <!-- Server messages -->
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-success"><span>✓</span><asp:Label ID="lblSuccess" runat="server" Text="Course saved successfully."></asp:Label></div>
            </asp:Panel>
            <asp:Panel ID="pnlError" runat="server" Visible="false" style="margin-bottom:20px;">
                <div class="alert alert-error"><span>⚠</span><asp:Label ID="lblError" runat="server" Text=""></asp:Label></div>
            </asp:Panel>

            <!-- ============================================================
                 SECTION 1 — Course Identity
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title">📘 Course Identity</div>

                <div class="form-group">
                    <label class="form-label">Course Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtCourseName" runat="server" CssClass="form-control"
                        MaxLength="50"
                        oninput="countChars(this,'titleCount',50); document.getElementById('heroTitle').textContent = this.value.trim() || 'Course Name';"></asp:TextBox>
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
                 SECTION 2 — Category & Pacing
                 ============================================================ -->
            <div class="form-section">
                <div class="form-section-title">🏷️ Category & Pacing</div>

                <div class="form-group">
                    <label class="form-label">Category <span class="required">*</span></label>
                    <span class="form-hint" style="display:block;margin-bottom:8px;">Choose the area that best describes this course.</span>

                    <div class="category-grid">
                        <input type="radio" name="catRadio" id="catProgramming" value="Programming" class="cat-radio" />
                        <label for="catProgramming" class="category-chip" data-cat="Programming"><span class="cat-emoji">💻</span> Programming</label>

                        <input type="radio" name="catRadio" id="catDesign" value="Design" class="cat-radio" />
                        <label for="catDesign" class="category-chip" data-cat="Design"><span class="cat-emoji">🎨</span> Design</label>

                        <input type="radio" name="catRadio" id="catBusiness" value="Business" class="cat-radio" />
                        <label for="catBusiness" class="category-chip" data-cat="Business"><span class="cat-emoji">💼</span> Business</label>

                        <input type="radio" name="catRadio" id="catData" value="Data Science" class="cat-radio" />
                        <label for="catData" class="category-chip" data-cat="Data Science"><span class="cat-emoji">📊</span> Data Science</label>

                        <input type="radio" name="catRadio" id="catMarketing" value="Marketing" class="cat-radio" />
                        <label for="catMarketing" class="category-chip" data-cat="Marketing"><span class="cat-emoji">📣</span> Marketing</label>

                        <input type="radio" name="catRadio" id="catCloud" value="Cloud" class="cat-radio" />
                        <label for="catCloud" class="category-chip" data-cat="Cloud"><span class="cat-emoji">☁️</span> Cloud</label>

                        <input type="radio" name="catRadio" id="catSecurity" value="Security" class="cat-radio" />
                        <label for="catSecurity" class="category-chip" data-cat="Security"><span class="cat-emoji">🔒</span> Security</label>

                        <input type="radio" name="catRadio" id="catOther" value="Other" class="cat-radio" />
                        <label for="catOther" class="category-chip" data-cat="Other"><span class="cat-emoji">✨</span> Other</label>
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
                        Style="max-width:240px;"></asp:TextBox>
                    <span class="form-hint">Estimated total time learners need to complete the entire course.</span>
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
                        MaxLength="255"
                        oninput="updateImagePreview(this.value); countChars(this,'imgCount',255);"></asp:TextBox>
                    <div class="char-count" id="imgCount">0 / 255</div>
                    <span class="form-hint">Direct image URL. Wide aspect ratio (≈2:1) works best.</span>
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

                    <div class="header-image-preview" id="imgPreviewBox">
                        <img id="imgPreview" src="" alt="" onload="this.classList.add('loaded'); document.getElementById('imgPreviewBox').classList.add('has-image'); document.getElementById('imgPlaceholder').style.display='none';" onerror="this.classList.remove('loaded'); document.getElementById('imgPreviewBox').classList.remove('has-image'); document.getElementById('imgPlaceholder').style.display='block';" />
                        <div class="header-image-placeholder" id="imgPlaceholder">
                            <div class="icon">🖼️</div>
                            <p style="font-size:13px;">Paste a URL above to preview your header.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sticky Save Bar — saves the details above -->
            <div class="save-bar">
                <div class="save-bar-text">Editing <strong><asp:Label ID="lblSaveBarName" runat="server" Text="course"></asp:Label></strong> — changes apply on save.</div>
                <div style="display:flex;gap:10px;">
                    <button type="button" class="btn btn-secondary" onclick="window.location.href='EducatorDashboard.aspx'">Cancel</button>
                    <asp:Button ID="btnSaveCourse" runat="server"
                        Text="Save Changes"
                        CssClass="btn btn-primary"
                        OnClick="btnSaveCourse_Click"
                        OnClientClick="return prepareSubmit();" />
                </div>
            </div>

            <!-- ============================================================
                 SECTION 4 — Course Content (Lessons & Quizzes)
                 This is the hub for create/edit/delete of child content.
                 ============================================================ -->
            <div class="form-section" style="margin-top:32px;">
                <div class="form-section-title" style="justify-content:space-between;">
                    <span>📦 Course Content</span>
                    <div style="display:flex;gap:8px;">
                        <a href="#" id="aAddLesson" runat="server" class="btn btn-primary btn-sm">+ New Lesson</a>
                        <a href="#" id="aAddQuiz" runat="server" class="btn btn-secondary btn-sm">+ New Quiz</a>
                    </div>
                </div>

                <p style="font-size:13px;color:var(--ink-600);margin-bottom:16px;">
                    Lessons and quizzes only live inside this course. Add as many as you need — an empty course is fine while you're still planning.
                </p>

                <!-- Pill tabs to switch between Lessons / Quizzes -->
                <div class="pill-tabs">
                    <button type="button" class="pill-tab active" id="tabLessons" onclick="switchTab('lessons')">
                        📝 Lessons <span class="pill-count" id="lessonCount">0</span>
                    </button>
                    <button type="button" class="pill-tab" id="tabQuizzes" onclick="switchTab('quizzes')">
                        🧠 Quizzes <span class="pill-count" id="quizCount">0</span>
                    </button>
                </div>

                <!-- LESSONS panel -->
                <div id="panelLessons">
                    <asp:ListView ID="rptLessons" runat="server"
                        OnItemCommand="rptLessons_ItemCommand">
                        <LayoutTemplate>
                            <div class="content-list">
                                <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                            </div>
                        </LayoutTemplate>

                        <ItemTemplate>
                            <div class="content-row">
                                <div class="content-row-icon" style="background:var(--brand-blue-light);color:var(--brand-blue);">📝</div>
                                <div style="flex:1;min-width:0;">
                                    <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><%# Eval("lessonTitle") %></div>
                                    <div class="content-row-meta">
                                        <span class="badge badge-blue" style="font-size:10px;"><%# Eval("level") %></span>
                                        <span>·</span>
                                        <span><%# Eval("duration") %> min</span>
                                        <span>·</span>
                                        <span>Created <%# Eval("dateCreated", "{0:MMM d, yyyy}") %></span>
                                    </div>
                                </div>
                                <div class="content-row-actions">
                                    <a href='LessonPage.aspx?lessonID=<%# Eval("lessonID") %>' class="btn btn-ghost btn-sm" target="_blank">View</a>
                                    <a href='EditLesson.aspx?lessonID=<%# Eval("lessonID") %>' class="btn btn-secondary btn-sm">✏ Edit</a>
                                    <asp:LinkButton ID="btnDeleteLesson" runat="server"
                                        CssClass="btn btn-danger btn-sm"
                                        CommandName="DeleteLesson"
                                        CommandArgument='<%# Eval("lessonID") %>'
                                        OnClientClick="return confirm('Delete this lesson? This cannot be undone.');">🗑</asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>

                        <EmptyDataTemplate>
                            <div class="empty-content">
                                <div class="icon">📝</div>
                                <p>No lessons yet — add the first one to start filling out your course.</p>
                                <a href="#" id="aAddLessonEmpty" runat="server" class="btn btn-primary btn-sm">+ Add First Lesson</a>
                            </div>
                        </EmptyDataTemplate>
                    </asp:ListView>
                </div>

                <!-- QUIZZES panel -->
                <div id="panelQuizzes" style="display:none;">
                    <asp:ListView ID="rptQuizzes" runat="server"
                        OnItemCommand="rptQuizzes_ItemCommand">
                        <LayoutTemplate>
                            <div class="content-list">
                                <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                            </div>
                        </LayoutTemplate>

                        <ItemTemplate>
                            <div class="content-row">
                                <div class="content-row-icon" style="background:var(--brand-amber-light);color:#c47d00;">🧠</div>
                                <div style="flex:1;min-width:0;">
                                    <div style="font-size:14px;font-weight:600;color:var(--ink-900);"><%# Eval("quizTitle") %></div>
                                    <div class="content-row-meta">
                                        <span class="badge badge-amber" style="font-size:10px;">Pass <%# Eval("passingScore") %>%</span>
                                        <span>·</span>
                                        <span><%# Eval("questionCount") %> questions</span>
                                        <span>·</span>
                                        <span>Created <%# Eval("dateCreated", "{0:MMM d, yyyy}") %></span>
                                    </div>
                                </div>
                                <div class="content-row-actions">
                                    <a href='QuizPage.aspx?quizID=<%# Eval("quizID") %>' class="btn btn-ghost btn-sm" target="_blank">View</a>
                                    <a href='EditQuiz.aspx?quizID=<%# Eval("quizID") %>' class="btn btn-secondary btn-sm">✏ Edit</a>
                                    <asp:LinkButton ID="btnDeleteQuiz" runat="server"
                                        CssClass="btn btn-danger btn-sm"
                                        CommandName="DeleteQuiz"
                                        CommandArgument='<%# Eval("quizID") %>'
                                        OnClientClick="return confirm('Delete this quiz and all its questions? This cannot be undone.');">🗑</asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>

                        <EmptyDataTemplate>
                            <div class="empty-content">
                                <div class="icon">🧠</div>
                                <p>No quizzes yet — quizzes help learners check what they've absorbed.</p>
                                <a href="#" id="aAddQuizEmpty" runat="server" class="btn btn-primary btn-sm">+ Add First Quiz</a>
                            </div>
                        </EmptyDataTemplate>
                    </asp:ListView>
                </div>
            </div>

            <!-- ============================================================
                 DANGER ZONE
                 ============================================================ -->
            <div class="danger-zone">
                <h3>🗑 Delete Course</h3>
                <p>Permanently removes this course along with every lesson, quiz, question, attempt, and enrolment record tied to it. This cannot be undone.</p>
                <asp:Button ID="btnDeleteCourse" runat="server"
                    Text="Delete this course"
                    CssClass="btn btn-danger"
                    OnClick="btnDeleteCourse_Click"
                    CausesValidation="false"
                    OnClientClick="return confirm('PERMANENTLY delete this course and ALL its content (lessons, quizzes, enrolments, attempts)? This cannot be undone.');" />
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
        const heroCat = document.getElementById('heroCategory');
        if (heroCat) heroCat.textContent = value;
    }

    document.querySelectorAll('.category-chip').forEach(chip => {
        chip.addEventListener('click', function (e) {
            e.preventDefault();
            selectCategory(this.dataset.cat);
        });
    });

    function validateCategory(source, args) {
        const cat = document.getElementById('<%= hfCategory.ClientID %>').value;
        args.IsValid = !!cat;
    }

    // ── Header image preview ─────────────────────────────────────────────
    function updateImagePreview(url) {
        const img = document.getElementById('imgPreview');
        const heroImg = document.getElementById('heroImg');
        url = (url || '').trim();
        if (!url) {
            img.src = '';
            img.classList.remove('loaded');
            document.getElementById('imgPreviewBox').classList.remove('has-image');
            document.getElementById('imgPlaceholder').style.display = 'block';
            heroImg.style.display = '';
            heroImg.src = '';
            return;
        }
        img.src = url;
        heroImg.style.display = '';
        heroImg.src = url;
    }

    // ── Tab switcher (Lessons / Quizzes) ─────────────────────────────────
    function switchTab(which) {
        const isLessons = which === 'lessons';
        document.getElementById('tabLessons').classList.toggle('active', isLessons);
        document.getElementById('tabQuizzes').classList.toggle('active', !isLessons);
        document.getElementById('panelLessons').style.display = isLessons ? 'block' : 'none';
        document.getElementById('panelQuizzes').style.display = isLessons ? 'none' : 'block';
    }

    // ── On submit: ensure category hidden field is set ───────────────────
    function prepareSubmit() {
        const cat = document.getElementById('<%= hfCategory.ClientID %>').value;
        return !!cat || false;
    }

    // ── Init counts in the pill tabs from rendered DOM ───────────────────
    function refreshContentCounts() {
        const lc = document.querySelectorAll('#panelLessons .content-row').length;
        const qc = document.querySelectorAll('#panelQuizzes .content-row').length;
        document.getElementById('lessonCount').textContent = lc;
        document.getElementById('quizCount').textContent = qc;
    }

    // ── Init on load ─────────────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', function () {
        // Restore selected category from postback / server-prefilled value
        const saved = document.getElementById('<%= hfCategory.ClientID %>').value;
        if (saved) selectCategory(saved);

        // Init counters for any pre-filled values
        const t = document.getElementById('<%= txtCourseName.ClientID %>');
        const d = document.getElementById('<%= txtDescription.ClientID %>');
        const i = document.getElementById('<%= txtHeaderImageURL.ClientID %>');
        if (t) {
            countChars(t, 'titleCount', 50);
            const heroTitle = document.getElementById('heroTitle');
            if (heroTitle) heroTitle.textContent = t.value.trim() || 'Course Name';
        }
        if (d) countChars(d, 'descCount', 200);
        if (i) {
            countChars(i, 'imgCount', 255);
            if (i.value.trim()) updateImagePreview(i.value);
        }

        refreshContentCounts();
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
