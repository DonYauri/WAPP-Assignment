<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProfilePage.aspx.cs" Inherits="WAPP_FinalAssignment.ProfilePage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .profile-layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 32px;
            align-items: start;
        }

        .profile-sidebar {
            position: sticky;
            top: calc(var(--nav-height) + 20px);
        }

        .profile-card {
            background: var(--surface-0);
            border: 1px solid var(--ink-100);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }

        .profile-card-top {
            background: linear-gradient(135deg, var(--ink-900) 0%, #1a2744 100%);
            padding: 32px 24px 24px;
            text-align: center;
            position: relative;
        }

        .profile-avatar-ring {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: var(--brand-blue);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 800;
            color: #fff;
            margin: 0 auto 14px;
            border: 3px solid rgba(255,255,255,0.25);
            letter-spacing: -1px;
        }

        .profile-card-top h2 {
            font-size: 18px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 4px;
            letter-spacing: -0.3px;
        }

        .profile-card-top p {
            font-size: 13px;
            color: rgba(255,255,255,0.55);
        }

        .profile-card-meta {
            padding: 0;
        }

        .profile-meta-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 13px 20px;
            border-bottom: 1px solid var(--ink-100);
            font-size: 13px;
        }
        .profile-meta-row:last-child { border-bottom: none; }

        .profile-meta-label {
            color: var(--ink-400);
            font-weight: 500;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .profile-meta-value {
            color: var(--ink-800);
            font-weight: 600;
            text-align: right;
            max-width: 160px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .sidenav-link-profile {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 11px 20px;
            font-size: 14px;
            font-weight: 500;
            color: var(--ink-600);
            cursor: pointer;
            transition: all var(--transition);
            text-decoration: none;
            border-left: 3px solid transparent;
            border-bottom: 1px solid var(--ink-50);
        }
        .sidenav-link-profile:last-child { border-bottom: none; }
        .sidenav-link-profile:hover { background: var(--ink-50); color: var(--ink-900); }
        .sidenav-link-profile.active {
            background: var(--brand-blue-light);
            color: var(--brand-blue);
            border-left-color: var(--brand-blue);
            font-weight: 600;
        }

        .strength-bar {
            height: 4px;
            border-radius: var(--radius-full);
            background: var(--ink-100);
            margin-top: 8px;
            overflow: hidden;
        }
        .strength-fill {
            height: 100%;
            border-radius: var(--radius-full);
            transition: width 0.3s, background 0.3s;
        }
        .strength-label {
            font-size: 11px;
            margin-top: 4px;
            font-weight: 600;
        }

        .toggle-pw {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--ink-400);
            padding: 4px;
            font-size: 16px;
            line-height: 1;
            transition: color var(--transition);
        }
        .toggle-pw:hover { color: var(--ink-700); }

        .input-wrap { position: relative; }
        .input-wrap .form-control { padding-right: 40px; }

        @media (max-width: 768px) {
            .profile-layout { grid-template-columns: 1fr; }
            .profile-sidebar { position: static; }
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
                <li><a href="#" id="aNavDashboard" runat="server">Dashboard</a></li>
                <li><a href="ProfilePage.aspx" class="active">Profile</a></li>
            </ul>
            <div class="nav-right">
                <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                    <div class="nav-avatar">
                        <asp:Label ID="lblNavInitial" runat="server" Text="U"></asp:Label>
                    </div>
                    <div>
                        <div class="chip-name">
                            <asp:Label ID="lblNavName" runat="server" Text="User"></asp:Label>
                        </div>
                        <div class="chip-role">
                            <asp:Label ID="lblNavRole" runat="server" Text="Learner"></asp:Label>
                        </div>
                    </div>
                    <svg width="12" height="8" viewBox="0 0 12 8" fill="none">
                        <path d="M1 1l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/>
                    </svg>
                    <div id="userDropdown" style="display:none;position:absolute;top:calc(100%+8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
                        <a href="ProfilePage.aspx" style="display:block;padding:10px 16px;font-size:13px;color:var(--brand-blue);font-weight:600;text-decoration:none;background:var(--brand-blue-light);">👤 My Profile</a>
                        <a href="#" id="aDropdownDashboard" runat="server" style="display:block;padding:10px 16px;font-size:13px;color:var(--ink-700);text-decoration:none;" onmouseover="this.style.background='var(--ink-50)'" onmouseout="this.style.background=''">📋 Dashboard</a>
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

        <!-- Breadcrumb -->
        <nav class="breadcrumb">
            <a href="HomePage.aspx">Home</a>
            <span class="breadcrumb-sep">›</span>
            <a href="#" id="aBreadcrumbDashboard" runat="server">Dashboard</a>
            <span class="breadcrumb-sep">›</span>
            <span class="breadcrumb-current">My Profile</span>
        </nav>

        <div class="profile-layout">

            <!-- ===== LEFT SIDEBAR ===== -->
            <div class="profile-sidebar">

                <!-- Profile card -->
                <div class="profile-card" style="margin-bottom:16px;">
                    <div class="profile-card-top">
                        <div class="profile-avatar-ring" id="avatarRing">
                            <asp:Label ID="lblAvatarInitials" runat="server" Text="U"></asp:Label>
                        </div>
                        <h2><asp:Label ID="lblSidebarName" runat="server" Text="User Name"></asp:Label></h2>
                        <p>@<asp:Label ID="lblSidebarUsername" runat="server" Text="username"></asp:Label></p>
                    </div>
                    <div class="profile-card-meta">
                        <div class="profile-meta-row">
                            <span class="profile-meta-label">Role</span>
                            <span class="profile-meta-value">
                                <asp:Label ID="lblSidebarRole" runat="server" Text="Learner"></asp:Label>
                            </span>
                        </div>
                        <div class="profile-meta-row">
                            <span class="profile-meta-label">Member since</span>
                            <span class="profile-meta-value">
                                <asp:Label ID="lblSidebarJoined" runat="server" Text="—"></asp:Label>
                            </span>
                        </div>
                        <div class="profile-meta-row">
                            <span class="profile-meta-label">Email</span>
                            <span class="profile-meta-value" title="">
                                <asp:Label ID="lblSidebarEmail" runat="server" Text="—"></asp:Label>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Side nav -->
                <div class="profile-card">
                    <a href="#section-info" class="sidenav-link-profile active" onclick="scrollToSection('section-info',this);return false;">
                        <span>👤</span> Personal Info
                    </a>
                    <a href="#section-security" class="sidenav-link-profile" onclick="scrollToSection('section-security',this);return false;">
                        <span>🔒</span> Security
                    </a>
                    <a href="#section-account" class="sidenav-link-profile" onclick="scrollToSection('section-account',this);return false;">
                        <span>ℹ️</span> Account Info
                    </a>
                </div>

            </div><!-- /sidebar -->

            <!-- ===== RIGHT MAIN ===== -->
            <div>

                <!-- Global success / error banners -->
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" style="margin-bottom:20px;">
                    <div class="alert alert-success">
                        <span>✓</span>
                        <asp:Label ID="lblSuccess" runat="server" Text="Changes saved successfully."></asp:Label>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlError" runat="server" Visible="false" style="margin-bottom:20px;">
                    <div class="alert alert-error">
                        <span>⚠</span>
                        <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                    </div>
                </asp:Panel>

                <!-- ── SECTION 1: Personal Information ── -->
                <div id="section-info" class="form-section" style="scroll-margin-top:84px;">
                    <div class="form-section-title">👤 Personal Information</div>
                    <p style="font-size:13px;color:var(--ink-600);margin-bottom:20px;">
                        Update your display name, username, and email address.
                        Your username must be unique across the platform.
                    </p>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Full Name <span class="required">*</span></label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control"
                                placeholder="Your full name" MaxLength="50"
                                oninput="syncAvatar(this.value)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvName" runat="server"
                                ControlToValidate="txtName"
                                ErrorMessage="Full name is required."
                                ValidationGroup="vgInfo"
                                Display="Dynamic" CssClass="form-error" Style="display:block;">
                            </asp:RequiredFieldValidator>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Username <span class="required">*</span></label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"
                                placeholder="e.g. cooldev123" MaxLength="50"></asp:TextBox>
                            <span class="form-hint">Lowercase letters, numbers, underscores only.</span>
                            <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                                ControlToValidate="txtUsername"
                                ErrorMessage="Username is required."
                                ValidationGroup="vgInfo"
                                Display="Dynamic" CssClass="form-error" Style="display:block;">
                            </asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Address <span class="required">*</span></label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                            TextMode="Email" placeholder="you@example.com" MaxLength="50"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                            ControlToValidate="txtEmail"
                            ErrorMessage="Email is required."
                            ValidationGroup="vgInfo"
                            Display="Dynamic" CssClass="form-error" Style="display:block;">
                        </asp:RequiredFieldValidator>
                        <asp:RegularExpressionValidator ID="revEmail" runat="server"
                            ControlToValidate="txtEmail"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                            ErrorMessage="Please enter a valid email address."
                            ValidationGroup="vgInfo"
                            Display="Dynamic" CssClass="form-error" Style="display:block;">
                        </asp:RegularExpressionValidator>
                    </div>

                    <div style="display:flex;justify-content:flex-end;margin-top:8px;">
                        <asp:Button ID="btnSaveInfo" runat="server"
                            Text="Save Personal Info"
                            CssClass="btn btn-primary"
                            ValidationGroup="vgInfo"
                            OnClick="btnSaveInfo_Click" />
                    </div>
                </div>

                <!-- ── SECTION 2: Security ── -->
                <div id="section-security" class="form-section" style="scroll-margin-top:84px;">
                    <div class="form-section-title">🔒 Change Password</div>
                    <p style="font-size:13px;color:var(--ink-600);margin-bottom:20px;">
                        Leave all fields blank if you do not want to change your password.
                        New password must be at least 8 characters.
                    </p>

                    <asp:Panel ID="pnlPasswordError" runat="server" Visible="false" style="margin-bottom:16px;">
                        <div class="alert alert-error">
                            <span>⚠</span>
                            <asp:Label ID="lblPasswordError" runat="server" Text=""></asp:Label>
                        </div>
                    </asp:Panel>
                    <asp:Panel ID="pnlPasswordSuccess" runat="server" Visible="false" style="margin-bottom:16px;">
                        <div class="alert alert-success">
                            <span>✓</span>
                            <asp:Label ID="lblPasswordSuccess" runat="server" Text="Password updated successfully."></asp:Label>
                        </div>
                    </asp:Panel>

                    <div class="form-group">
                        <label class="form-label">Current Password <span class="required">*</span></label>
                        <div class="input-wrap">
                            <asp:TextBox ID="txtCurrentPassword" runat="server"
                                CssClass="form-control" TextMode="Password"
                                placeholder="Enter your current password"></asp:TextBox>
                            <button type="button" class="toggle-pw" onclick="togglePw('<%= txtCurrentPassword.ClientID %>', this)" tabindex="-1">👁</button>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">New Password <span class="required">*</span></label>
                            <div class="input-wrap">
                                <asp:TextBox ID="txtNewPassword" runat="server"
                                    CssClass="form-control" TextMode="Password"
                                    placeholder="Min. 8 characters"
                                    oninput="checkStrength(this.value)"></asp:TextBox>
                                <button type="button" class="toggle-pw" onclick="togglePw('<%= txtNewPassword.ClientID %>', this)" tabindex="-1">👁</button>
                            </div>
                            <div class="strength-bar">
                                <div class="strength-fill" id="strengthFill" style="width:0%;background:var(--ink-200);"></div>
                            </div>
                            <div class="strength-label" id="strengthLabel" style="color:var(--ink-400);">Enter a password</div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Confirm New Password <span class="required">*</span></label>
                            <div class="input-wrap">
                                <asp:TextBox ID="txtConfirmPassword" runat="server"
                                    CssClass="form-control" TextMode="Password"
                                    placeholder="Repeat new password"
                                    oninput="checkMatch()"></asp:TextBox>
                                <button type="button" class="toggle-pw" onclick="togglePw('<%= txtConfirmPassword.ClientID %>', this)" tabindex="-1">👁</button>
                            </div>
                            <div id="matchMsg" style="font-size:12px;margin-top:4px;display:none;"></div>
                        </div>
                    </div>

                    <div style="display:flex;justify-content:flex-end;margin-top:8px;">
                        <asp:Button ID="btnChangePassword" runat="server"
                            Text="Update Password"
                            CssClass="btn btn-primary"
                            ValidationGroup="vgPassword"
                            OnClick="btnChangePassword_Click"
                            OnClientClick="return validatePassword();" />
                    </div>
                </div>

                <!-- ── SECTION 3: Account Info (read-only) ── -->
                <div id="section-account" class="form-section" style="scroll-margin-top:84px;">
                    <div class="form-section-title">ℹ️ Account Information</div>
                    <p style="font-size:13px;color:var(--ink-600);margin-bottom:20px;">
                        Read-only account details. Contact an administrator to change your role.
                    </p>

                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                        <div style="background:var(--surface-1);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:16px 20px;">
                            <div style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:6px;">User ID</div>
                            <div style="font-size:16px;font-weight:700;color:var(--ink-900);font-family:'DM Mono',monospace;">
                                #<asp:Label ID="lblAccountID" runat="server" Text="—"></asp:Label>
                            </div>
                        </div>
                        <div style="background:var(--surface-1);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:16px 20px;">
                            <div style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:6px;">Account Role</div>
                            <div style="font-size:15px;font-weight:700;">
                                <asp:Label ID="lblAccountRole" runat="server" Text="Learner"></asp:Label>
                            </div>
                        </div>
                        <div style="background:var(--surface-1);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:16px 20px;">
                            <div style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:6px;">Registered On</div>
                            <div style="font-size:15px;font-weight:700;color:var(--ink-900);">
                                <asp:Label ID="lblAccountJoined" runat="server" Text="—"></asp:Label>
                            </div>
                        </div>
                        <div style="background:var(--surface-1);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:16px 20px;">
                            <div style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.6px;color:var(--ink-400);margin-bottom:6px;">Platform</div>
                            <div style="font-size:15px;font-weight:700;color:var(--ink-900);">ASP.NET Bootcamp</div>
                        </div>
                    </div>

                    <!-- Danger zone -->
                    <div style="margin-top:28px;padding:20px;background:var(--brand-red-light);border:1px solid #ef9a9a;border-radius:var(--radius-md);">
                        <h4 style="font-size:14px;font-weight:700;color:var(--brand-red);margin-bottom:6px;">⚠ Danger Zone</h4>
                        <p style="font-size:13px;color:var(--ink-700);margin-bottom:14px;line-height:1.6;">
                            Deleting your account is permanent and irreversible. All your enrolments,
                            lesson progress, and quiz attempts will be permanently removed.
                        </p>
                        <button type="button" class="btn btn-danger btn-sm" onclick="confirmDeleteAccount()">
                            Delete my account
                        </button>
                    </div>
                </div>

            </div><!-- /right main -->
        </div><!-- /profile-layout -->
    </div><!-- /container -->
</main>

<!-- Delete account confirmation modal -->
<div id="deleteAccountModal" class="modal-backdrop" onclick="closeModalOutside(event,'deleteAccountModal')">
    <div class="modal-box" style="max-width:420px;">
        <button type="button" class="modal-close" onclick="closeModal('deleteAccountModal')">✕</button>
        <div class="modal-header">
            <h2 style="color:var(--brand-red);">Delete Account</h2>
            <p>This action is permanent and cannot be undone.</p>
        </div>
        <div class="alert alert-error" style="margin-bottom:16px;">
            <span>⚠</span>
            <span>All your courses, progress, and quiz attempts will be deleted forever.</span>
        </div>
        <div class="form-group">
            <label class="form-label">Type your username to confirm</label>
            <input type="text" id="deleteConfirmInput" class="form-control"
                placeholder="Enter your username"
                oninput="checkDeleteConfirm(this.value)" />
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeModal('deleteAccountModal')">Cancel</button>
            <asp:Button ID="btnDeleteAccount" runat="server" Text="Yes, delete my account"
                CssClass="btn btn-danger"
                OnClientClick="return checkFinalDelete();"
                OnClick="btnDeleteAccount_Click"
                Style="opacity:0.4;pointer-events:none;" />
        </div>
    </div>
</div>

<!-- Store username for delete confirmation check -->
<asp:HiddenField ID="hfUsername" runat="server" Value="" />

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
                <h4>Learn</h4>
                <a href="HomePage.aspx#all-courses">All Courses</a>
            </div>
            <div class="footer-col">
                <h4>Account</h4>
                <a href="ProfilePage.aspx">My Profile</a>
                <a href="#" id="aFooterDashboard" runat="server">Dashboard</a>
            </div>
            <div class="footer-col">
                <h4>Platform</h4>
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
    /* ── Nav dropdown ─────────────────────────────────────────── */
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

    /* ── Smooth scroll to section + active state ──────────────── */
    function scrollToSection(id, link) {
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        document.querySelectorAll('.sidenav-link-profile')
            .forEach(a => a.classList.remove('active'));
        if (link) link.classList.add('active');
    }

    /* Highlight sidebar link based on scroll position */
    window.addEventListener('scroll', function () {
        const sections = ['section-info', 'section-security', 'section-account'];
        let current = sections[0];
        sections.forEach(id => {
            const el = document.getElementById(id);
            if (el && window.scrollY >= el.offsetTop - 100) current = id;
        });
        document.querySelectorAll('.sidenav-link-profile').forEach(link => {
            link.classList.toggle('active', link.getAttribute('href') === '#' + current);
        });
    });

    /* ── Avatar initials live sync ────────────────────────────── */
    function syncAvatar(name) {
        const parts   = name.trim().split(/\s+/).filter(Boolean);
        const initials = parts.length >= 2
            ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
            : (parts[0] ? parts[0].slice(0, 2).toUpperCase() : '?');
        document.getElementById('avatarRing').querySelector('span, label').textContent = initials;
    }

    /* ── Password visibility toggle ──────────────────────────── */
    function togglePw(fieldId, btn) {
        const field = document.getElementById(fieldId);
        if (!field) return;
        const isText = field.type === 'text';
        field.type = isText ? 'password' : 'text';
        btn.textContent = isText ? '👁' : '🙈';
    }

    /* ── Password strength meter ──────────────────────────────── */
    function checkStrength(pw) {
        const fill  = document.getElementById('strengthFill');
        const label = document.getElementById('strengthLabel');
        if (!fill || !label) return;

        let score = 0;
        if (pw.length >= 8)               score++;
        if (pw.length >= 12)              score++;
        if (/[A-Z]/.test(pw))             score++;
        if (/[0-9]/.test(pw))             score++;
        if (/[^A-Za-z0-9]/.test(pw))      score++;

        const levels = [
            { pct: '0%',   color: 'var(--ink-200)',    text: 'Enter a password',   textColor: 'var(--ink-400)' },
            { pct: '20%',  color: 'var(--brand-red)',  text: 'Very weak',          textColor: 'var(--brand-red)' },
            { pct: '40%',  color: 'var(--brand-red)',  text: 'Weak',               textColor: 'var(--brand-red)' },
            { pct: '60%',  color: 'var(--brand-amber)',text: 'Fair',               textColor: '#c47d00' },
            { pct: '80%',  color: 'var(--brand-blue)', text: 'Good',               textColor: 'var(--brand-blue)' },
            { pct: '100%', color: 'var(--brand-green)',text: 'Strong ✓',           textColor: 'var(--brand-green)' },
        ];
        const lvl = pw.length === 0 ? levels[0] : levels[Math.min(score, 5)];
        fill.style.width      = lvl.pct;
        fill.style.background = lvl.color;
        label.textContent     = lvl.text;
        label.style.color     = lvl.textColor;

        checkMatch();
    }

    /* ── Confirm password match indicator ────────────────────── */
    function checkMatch() {
        const np  = document.getElementById('<%= txtNewPassword.ClientID %>');
        const cp  = document.getElementById('<%= txtConfirmPassword.ClientID %>');
        const msg = document.getElementById('matchMsg');
        if (!np || !cp || !msg) return;
        if (!cp.value) { msg.style.display = 'none'; return; }
        const match = np.value === cp.value;
        msg.style.display = 'block';
        msg.style.color   = match ? 'var(--brand-green)' : 'var(--brand-red)';
        msg.style.fontWeight = '600';
        msg.textContent   = match ? '✓ Passwords match' : '✗ Passwords do not match';
    }

    /* ── Client-side password validation before postback ─────── */
    function validatePassword() {
        const cur = document.getElementById('<%= txtCurrentPassword.ClientID %>').value.trim();
        const np  = document.getElementById('<%= txtNewPassword.ClientID %>').value;
        const cp  = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;

        if (!cur) { showInlineError('Current password is required.'); return false; }
        if (!np)  { showInlineError('New password is required.');     return false; }
        if (np.length < 8) { showInlineError('New password must be at least 8 characters.'); return false; }
        if (np !== cp)     { showInlineError('Passwords do not match.');                     return false; }
        return true;
    }

    function showInlineError(msg) {
        const panel = document.getElementById('<%= pnlPasswordError.ClientID %>');
        const lbl   = document.getElementById('<%= lblPasswordError.ClientID %>');
        if (panel && lbl) {
            lbl.textContent = msg;
            panel.style.display = 'block';
        }
    }

    /* ── Delete account modal ─────────────────────────────────── */
    function confirmDeleteAccount() {
        document.getElementById('deleteConfirmInput').value = '';
        const btn = document.getElementById('<%= btnDeleteAccount.ClientID %>');
        if (btn) { btn.style.opacity = '0.4'; btn.style.pointerEvents = 'none'; }
        openModal('deleteAccountModal');
    }

    function checkDeleteConfirm(val) {
        const expected = document.getElementById('<%= hfUsername.ClientID %>').value;
        const btn = document.getElementById('<%= btnDeleteAccount.ClientID %>');
        if (!btn) return;
        const match = val.trim().toLowerCase() === expected.trim().toLowerCase();
        btn.style.opacity       = match ? '1'    : '0.4';
        btn.style.pointerEvents = match ? 'auto' : 'none';
    }

    function checkFinalDelete() {
        const val      = document.getElementById('deleteConfirmInput').value.trim();
        const expected = document.getElementById('<%= hfUsername.ClientID %>').value.trim();
        if (val.toLowerCase() !== expected.toLowerCase()) {
            alert('Username does not match. Account deletion cancelled.');
            return false;
        }
        return confirm('Are you absolutely sure? This cannot be undone.');
    }

    /* ── Modal helpers ────────────────────────────────────────── */
    function openModal(id) {
        const m = document.getElementById(id);
        if (m) { m.classList.add('show'); document.body.style.overflow = 'hidden'; }
    }
    function closeModal(id) {
        const m = document.getElementById(id);
        if (m) { m.classList.remove('show'); document.body.style.overflow = ''; }
    }
    function closeModalOutside(e, id) {
        if (e.target === document.getElementById(id)) closeModal(id);
    }

    /* ── Init on load ─────────────────────────────────────────── */
    window.addEventListener('DOMContentLoaded', function () {
        /* Pre-populate the avatar ring with server-rendered initials via the
           label already rendered inside it — nothing extra needed. */

        /* If URL has #section-security or similar, scroll to it */
        if (window.location.hash) {
            const target = window.location.hash.replace('#', '');
            const el = document.getElementById(target);
            if (el) setTimeout(() => el.scrollIntoView({ behavior: 'smooth' }), 200);
        }
    });
</script>
</body>
</html>
