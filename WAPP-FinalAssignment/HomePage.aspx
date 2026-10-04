<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomePage.aspx.cs" Inherits="WAPP_FinalAssignment.HomePage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>ASP.NET Architecture Bootcamp</title>
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
                <li><a href="HomePage.aspx" class="active">Home</a></li>
                <li><a href="HomePage.aspx#all-courses">Courses</a></li>
                <asp:PlaceHolder ID="phNavLoggedInLinks" runat="server" Visible="false">
                    <li><a href="#" id="aNavDashboard" runat="server">Dashboard</a></li>
                </asp:PlaceHolder>
            </ul>
            <div class="nav-right">
                <!-- Shown when logged out -->
                <asp:PlaceHolder ID="phNavLoggedOut" runat="server" Visible="true">
                    <button type="button" class="btn btn-secondary btn-sm" onclick="openModal('loginModal')">Sign in</button>
                    <button type="button" class="btn btn-primary btn-sm" onclick="openModal('registerModal')">Get started</button>
                </asp:PlaceHolder>
                <!-- Shown when logged in -->
                <asp:PlaceHolder ID="phNavLoggedIn" runat="server" Visible="false">
                    <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                        <div class="nav-avatar">
                            <asp:Label ID="lblNavInitial" runat="server" Text="U"></asp:Label>
                        </div>
                        <div>
                            <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="User"></asp:Label></div>
                            <div class="chip-role"><asp:Label ID="lblNavRole" runat="server" Text="Learner"></asp:Label></div>
                        </div>
                        <svg width="12" height="8" viewBox="0 0 12 8" fill="none"><path d="M1 1l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/></svg>
                        <!-- Dropdown -->
                        <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                            <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">👤 My Profile</a>
                            <div style="height:1px;background:var(--ink-100);margin:4px 0;"></div>
                            <button type="button" onclick="doLogout()" style="display:block;width:100%;text-align:left;padding:10px 16px;font-size:13px;color:var(--brand-red);border:none;background:transparent;cursor:pointer;font-family:'DM Sans',sans-serif;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">Sign out</button>
                        </div>
                    </div>
                </asp:PlaceHolder>
            </div>
        </div>
    </div>
</nav>

<!-- ====== MAIN CONTENT ====== -->
<main class="page-content" style="padding-top:32px;">
    <div class="container">

        <!-- HERO SECTION -->
        <section class="hero-section" style="margin-bottom:56px;">
            <img class="hero-bg" src="https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=1600&q=80&auto=format&fit=crop" alt="Developer coding" />
            <div class="hero-overlay"></div>
            <div class="hero-content">
                <div class="hero-eyebrow">
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor"><circle cx="6" cy="6" r="6"/></svg>
                    ASP.NET Architecture Bootcamp
                </div>
                <h1 class="hero-title">Learn what<br/>matters most</h1>
                <p class="hero-subtitle">Master ASP.NET, C#, and modern web architecture at your own pace. Structured learning paths for every level.</p>

                <!-- Inline search bar inside hero -->
                <div class="hero-search-bar">
                    <input type="text" class="hero-search-input" id="heroSearch" placeholder="Search for a course, topic, or skill…" />
                    <button type="button" class="btn btn-primary" onclick="performSearch()" style="flex-shrink:0;background:rgba(255,255,255,0.2);border:1.5px solid rgba(255,255,255,0.4);backdrop-filter:blur(4px);">Search</button>
                </div>

                <div class="hero-actions">
                    <button type="button" class="btn btn-primary btn-lg" onclick="scrollToSection('all-courses')" style="background:#fff;color:var(--ink-900);">Explore courses</button>
                    <asp:PlaceHolder ID="phHeroCTA" runat="server" Visible="true">
                        <button type="button" class="btn btn-lg" onclick="openModal('registerModal')" style="background:rgba(255,255,255,0.15);color:#fff;border:1.5px solid rgba(255,255,255,0.4);backdrop-filter:blur(4px);">Create free account</button>
                    </asp:PlaceHolder>
                </div>
            </div>
        </section>

        <!-- HOW IT WORKS -->
        <section style="margin-bottom:64px;text-align:center;">
            <p style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:1.2px;color:var(--brand-blue);margin-bottom:10px;">How it works</p>
            <h2 style="font-size:26px;font-weight:700;letter-spacing:-0.4px;color:var(--ink-900);margin-bottom:8px;">Get started in four simple steps</h2>
            <p style="color:var(--ink-600);font-size:15px;margin-bottom:40px;">Your journey to .NET mastery begins here.</p>

            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px;text-align:left;">
                <div class="card" style="border-top:3px solid var(--brand-blue);">
                    <div style="font-size:28px;margin-bottom:12px;">📚</div>
                    <div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;color:var(--brand-blue);margin-bottom:6px;">Step 1</div>
                    <h3 style="font-size:16px;font-weight:700;color:var(--ink-900);margin-bottom:6px;">Browse courses</h3>
                    <p style="font-size:13px;color:var(--ink-600);line-height:1.6;">Explore hundreds of structured courses across ASP.NET topics and difficulty levels.</p>
                </div>
                <div class="card" style="border-top:3px solid var(--brand-blue);">
                    <div style="font-size:28px;margin-bottom:12px;">✏️</div>
                    <div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;color:var(--brand-blue);margin-bottom:6px;">Step 2</div>
                    <h3 style="font-size:16px;font-weight:700;color:var(--ink-900);margin-bottom:6px;">Enrol and learn</h3>
                    <p style="font-size:13px;color:var(--ink-600);line-height:1.6;">Access lessons with videos and reading material, tracking progress through each course.</p>
                </div>
                <div class="card" style="border-top:3px solid var(--brand-blue);">
                    <div style="font-size:28px;margin-bottom:12px;">🧠</div>
                    <div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;color:var(--brand-blue);margin-bottom:6px;">Step 3</div>
                    <h3 style="font-size:16px;font-weight:700;color:var(--ink-900);margin-bottom:6px;">Take quizzes</h3>
                    <p style="font-size:13px;color:var(--ink-600);line-height:1.6;">Test your knowledge with interactive assessments and get immediate feedback on answers.</p>
                </div>
                <div class="card" style="border-top:3px solid var(--brand-blue);">
                    <div style="font-size:28px;margin-bottom:12px;">🏅</div>
                    <div style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;color:var(--brand-blue);margin-bottom:6px;">Step 4</div>
                    <h3 style="font-size:16px;font-weight:700;color:var(--ink-900);margin-bottom:6px;">Earn achievement</h3>
                    <p style="font-size:13px;color:var(--ink-600);line-height:1.6;">Complete courses to earn completion badges, tracked on your personal dashboard.</p>
                </div>
            </div>
        </section>

        <!-- FEATURED COURSES -->
        <section style="margin-bottom:56px;">
            <div class="section-header-row">
                <div class="section-header" style="margin-bottom:0;">
                    <p style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:1.2px;color:var(--brand-blue);margin-bottom:4px;">Featured</p>
                    <h2 style="font-size:22px;font-weight:700;color:var(--ink-900);letter-spacing:-0.3px;">Popular courses</h2>
                </div>
                <a href="HomePage.aspx#all-courses" style="font-size:14px;font-weight:600;color:var(--brand-blue);text-decoration:none;">View all →</a>
            </div>
            <p style="font-size:14px;color:var(--ink-600);margin-bottom:24px;">Chosen by our community of developers.</p>

            <div class="course-grid">
                <asp:ListView ID="rptFeaturedCourses" runat="server">
                    <LayoutTemplate>
                        <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                    </LayoutTemplate>
                    <ItemTemplate>
                        <a class="course-card" href='CoursePage.aspx?courseID=<%# Eval("courseID") %>' style="text-decoration:none;color:inherit;">
                            <div class="course-card-thumb">
                                <img src='<%# Eval("headerPictureURL") %>' alt='<%# Eval("courseName") %>' onerror="this.outerHTML='&lt;div class=&quot;course-card-thumb-placeholder&quot;&gt;📖&lt;/div&gt;'" />
                            </div>
                            <div class="course-card-body">
                                <div class="course-card-category"><%# Eval("category") %></div>
                                <div class="course-card-title"><%# Eval("courseName") %></div>
                                <div class="course-card-desc"><%# Eval("description") %></div>
                                <div class="course-card-meta">
                                    <span><%# Eval("duration") %> hrs</span>
                                    <span class="dot"></span>
                                    <span>By <%# Eval("instructorName") %></span>
                                </div>
                            </div>
                        </a>
                    </ItemTemplate>
                    <EmptyDataTemplate>
                        <div style="grid-column:1/-1;" class="empty-state">
                            <div class="empty-state-icon">📚</div>
                            <h3>No courses yet</h3>
                            <p>Educators are preparing content. Check back soon!</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:ListView>
            </div>
        </section>

        <!-- SEARCH + FILTER + ALL COURSES -->
        <section id="all-courses" style="scroll-margin-top:80px;">
            <div class="section-header-row" style="margin-bottom:16px;">
                <div>
                    <h2 style="font-size:22px;font-weight:700;color:var(--ink-900);letter-spacing:-0.3px;">All courses</h2>
                </div>
                <!-- Inline search on courses section -->
                <div class="search-bar" style="max-width:340px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink-400)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                    <input type="text" id="courseSearch" placeholder="Search courses…" oninput="filterCourses()" />
                </div>
            </div>

            <!-- Category filter chips -->
            <div class="filter-row" id="categoryFilters">
                <button type="button" class="chip active" data-cat="" onclick="setCategory(this, '')">All</button>
                <asp:Repeater ID="rptCategories" runat="server">
                    <ItemTemplate>
                        <button type="button" class="chip" data-cat='<%# Eval("category") %>' onclick="setCategory(this, this.getAttribute('data-cat'))"><%# Eval("category") %></button>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="course-grid" id="allCoursesGrid">
                <asp:ListView ID="rptAllCourses" runat="server">
                    <LayoutTemplate>
                        <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                    </LayoutTemplate>
                    <ItemTemplate>
                        <a class="course-card" data-name='<%# Eval("courseName").ToString().ToLower() %>' data-cat='<%# Eval("category") %>' href='CoursePage.aspx?courseID=<%# Eval("courseID") %>' style="text-decoration:none;color:inherit;">
                            <div class="course-card-thumb">
                                <img src='<%# Eval("headerPictureURL") %>' alt='<%# Eval("courseName") %>' onerror="this.outerHTML='&lt;div class=&quot;course-card-thumb-placeholder&quot;&gt;📖&lt;/div&gt;'" />
                            </div>
                            <div class="course-card-body">
                                <div class="course-card-category"><%# Eval("category") %></div>
                                <div class="course-card-title"><%# Eval("courseName") %></div>
                                <div class="course-card-desc"><%# Eval("description") %></div>
                                <div class="course-card-meta">
                                    <span><%# Eval("duration") %> hrs</span>
                                    <span class="dot"></span>
                                    <span>By <%# Eval("instructorName") %></span>
                                </div>
                            </div>
                        </a>
                    </ItemTemplate>
                    <EmptyDataTemplate>
                        <div style="grid-column:1/-1;" class="empty-state">
                            <div class="empty-state-icon">🔍</div>
                            <h3>No courses found</h3>
                            <p>Try adjusting your search or check back later.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:ListView>
            </div>

            <!-- No results message (hidden by default) -->
            <div id="noResults" style="display:none;text-align:center;padding:48px 24px;color:var(--ink-400);">
                <div style="font-size:36px;margin-bottom:12px;">🔍</div>
                <p style="font-size:16px;font-weight:600;color:var(--ink-600);">No courses match your search</p>
                <p style="font-size:14px;margin-top:4px;">Try different keywords or browse all categories.</p>
            </div>
        </section>

    </div><!-- /container -->
</main>

<!-- ====== LOGIN MODAL ====== -->
<div id="loginModal" class="modal-backdrop" onclick="closeModalOutside(event, 'loginModal')">
    <div class="modal-box">
        <button type="button" class="modal-close" onclick="closeModal('loginModal')">✕</button>
        <div class="modal-header">
            <h2>Welcome back</h2>
            <p>Sign in to continue your learning journey.</p>
        </div>

        <div id="loginError" class="alert alert-error" style="display:none;">
            <span>⚠</span>
            <span id="loginErrorMsg">Invalid email or password.</span>
        </div>

        <div class="form-group">
            <label class="form-label">Email address</label>
            <asp:TextBox ID="txtLoginEmail" runat="server" CssClass="form-control" placeholder="you@example.com" TextMode="Email"></asp:TextBox>
        </div>
        <div class="form-group">
            <label class="form-label">Password</label>
            <asp:TextBox ID="txtLoginPassword" runat="server" CssClass="form-control" placeholder="Enter your password" TextMode="Password"></asp:TextBox>
        </div>

        <div class="modal-footer" style="margin-top:8px;padding-top:0;border-top:none;flex-direction:column;gap:12px;">
            <asp:Button ID="btnLogin" runat="server" Text="Sign in" CssClass="btn btn-primary" Style="width:100%;padding:12px;" OnClick="btnLogin_Click" />
            <div class="modal-divider">or</div>
            <p style="font-size:13px;color:var(--ink-600);text-align:center;">
                Don't have an account? <a href="#" onclick="switchModal('loginModal','registerModal');return false;" style="font-weight:600;">Create one</a>
            </p>
        </div>
    </div>
</div>

<!-- ====== REGISTER MODAL ====== -->
<div id="registerModal" class="modal-backdrop" onclick="closeModalOutside(event, 'registerModal')">
    <div class="modal-box">
        <button type="button" class="modal-close" onclick="closeModal('registerModal')">✕</button>
        <div class="modal-header">
            <h2>Create your account</h2>
            <p>Join thousands of developers mastering ASP.NET.</p>
        </div>

        <div id="regError" class="alert alert-error" style="display:none;">
            <span>⚠</span>
            <span id="regErrorMsg">Please check your details.</span>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Username <span class="required">*</span></label>
                <asp:TextBox ID="txtRegUsername" runat="server" CssClass="form-control" placeholder="cooldev123"></asp:TextBox>
            </div>
            <div class="form-group">
                <label class="form-label">Full name <span class="required">*</span></label>
                <asp:TextBox ID="txtRegName" runat="server" CssClass="form-control" placeholder="Jane Smith"></asp:TextBox>
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">Email address <span class="required">*</span></label>
            <asp:TextBox ID="txtRegEmail" runat="server" CssClass="form-control" placeholder="you@example.com" TextMode="Email"></asp:TextBox>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Password <span class="required">*</span></label>
                <asp:TextBox ID="txtRegPassword" runat="server" CssClass="form-control" placeholder="Min. 8 characters" TextMode="Password"></asp:TextBox>
            </div>
            <div class="form-group">
                <label class="form-label">I am a</label>
                <asp:DropDownList ID="ddlRegRole" runat="server" CssClass="form-control">
                    <asp:ListItem Value="Learners" Text="Learner — I want to learn"></asp:ListItem>
                    <asp:ListItem Value="Educator" Text="Educator — I want to teach"></asp:ListItem>
                    <asp:ListItem Value="Admins" Text="Administrator — I manage the platform"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <div class="modal-footer" style="margin-top:8px;padding-top:0;border-top:none;flex-direction:column;gap:12px;">
            <asp:Button ID="btnRegister" runat="server" Text="Create account" CssClass="btn btn-primary" Style="width:100%;padding:12px;" OnClick="btnRegister_Click" />
            <div class="modal-divider">or</div>
            <p style="font-size:13px;color:var(--ink-600);text-align:center;">
                Already have an account? <a href="#" onclick="switchModal('registerModal','loginModal');return false;" style="font-weight:600;">Sign in</a>
            </p>
        </div>
    </div>
</div>

<!-- ====== SERVER MESSAGES ====== -->
<asp:HiddenField ID="hfServerMessage" runat="server" Value="" />
<asp:HiddenField ID="hfServerMessageType" runat="server" Value="" />

<!-- ====== FOOTER ====== -->
<footer>
    <div class="container">
        <div class="footer-grid">
            <div class="footer-brand">
                <a href="HomePage.aspx" class="nav-logo" style="color:#fff;margin-bottom:12px;display:inline-flex;align-items:center;gap:8px;">
                    <div class="nav-logo-icon">⚡</div>
                    ASP.NET Bootcamp
                </a>
                <p>A hands-on, database-driven Learning Management System built with ASP.NET — where the platform itself teaches the technology it runs on.</p>
            </div>
            <div class="footer-col">
                <h4>Learn</h4>
                <a href="HomePage.aspx#all-courses">All Courses</a>
                <a href="HomePage.aspx">Browse Topics</a>
                <a href="HomePage.aspx">Learning Paths</a>
            </div>
            <div class="footer-col">
                <h4>Account</h4>
                <a href="#" onclick="openModal('registerModal');return false;">Register</a>
                <a href="#" onclick="openModal('loginModal');return false;">Sign in</a>
                <a href="ProfilePage.aspx">My Profile</a>
            </div>
            <div class="footer-col">
                <h4>Platform</h4>
                <a href="#">About</a>
                <a href="#">APU Group 14</a>
                <a href="#">WAPP CT050-3-2</a>
            </div>
        </div>
        <div class="footer-bottom">
            <span>&copy; 2026 ASP.NET Architecture Bootcamp — APU Group 14</span>
            <span>Built with ASP.NET &amp; SQL Server</span>
        </div>
    </div>
</footer>

</form>

<script>
    // ---- Modal helpers ----
    function openModal(id) {
        document.getElementById(id).classList.add('show');
        document.body.style.overflow = 'hidden';
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
        document.body.style.overflow = '';
    }
    function closeModalOutside(e, id) {
        if (e.target === document.getElementById(id)) closeModal(id);
    }
    function switchModal(from, to) {
        closeModal(from);
        setTimeout(() => openModal(to), 150);
    }

    // ---- User dropdown ----
    function toggleUserDropdown() {
        const d = document.getElementById('userDropdown');
        d.style.display = d.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(e) {
        const chip = document.querySelector('.nav-user-chip');
        const dd = document.getElementById('userDropdown');
        if (dd && chip && !chip.contains(e.target)) dd.style.display = 'none';
    });

    // ---- Scroll to section ----
    function scrollToSection(id) {
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: 'smooth' });
    }

    // ---- Search / filter ----
    let activeCategory = '';

    function performSearch() {
        const term = document.getElementById('heroSearch').value.trim();
        document.getElementById('courseSearch').value = term;
        scrollToSection('all-courses');
        filterCourses();
    }

    function setCategory(btn, cat) {
        activeCategory = cat;
        document.querySelectorAll('#categoryFilters .chip').forEach(c => c.classList.remove('active'));
        btn.classList.add('active');
        filterCourses();
    }

    function filterCourses() {
        const term = document.getElementById('courseSearch').value.toLowerCase();
        const cards = document.querySelectorAll('#allCoursesGrid .course-card');
        let visible = 0;
        cards.forEach(card => {
            const name = card.dataset.name || '';
            const cat = card.dataset.cat || '';
            const matchName = term === '' || name.includes(term);
            const matchCat = activeCategory === '' || cat === activeCategory;
            card.style.display = (matchName && matchCat) ? '' : 'none';
            if (matchName && matchCat) visible++;
        });
        document.getElementById('noResults').style.display = visible === 0 ? 'block' : 'none';
    }

    // ---- Logout ----
    function doLogout() {
        window.location.href = 'HomePage.aspx?action=logout';
    }

    // ---- Server message handling ----
    window.addEventListener('DOMContentLoaded', function () {
        const msg = document.getElementById('<%= hfServerMessage.ClientID %>');
        const type = document.getElementById('<%= hfServerMessageType.ClientID %>');
        if (msg && msg.value) {
            showToast(msg.value, type.value || 'info');
        }
    });

    function showToast(message, type) {
        const toast = document.createElement('div');
        const colors = {
            success: { bg: 'var(--brand-green-light)', color: 'var(--brand-green)', border: '#a5d6a7' },
            error: { bg: 'var(--brand-red-light)', color: 'var(--brand-red)', border: '#ef9a9a' },
            info: { bg: 'var(--brand-blue-light)', color: 'var(--brand-blue-dark)', border: '#90caf9' }
        };
        const c = colors[type] || colors.info;
        toast.style.cssText = `position:fixed;bottom:24px;right:24px;z-index:9999;padding:14px 20px;border-radius:10px;background:${c.bg};color:${c.color};border:1px solid ${c.border};font-size:14px;font-weight:500;font-family:'DM Sans',sans-serif;max-width:360px;box-shadow:0 8px 24px rgba(0,0,0,0.12);animation:slideUp 0.25s ease;`;
        toast.textContent = message;
        document.body.appendChild(toast);
        setTimeout(() => { toast.style.opacity = '0'; toast.style.transition = 'opacity 0.3s'; setTimeout(() => toast.remove(), 300); }, 3500);
    }
</script>
</body>
</html>
