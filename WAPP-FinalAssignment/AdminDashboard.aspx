<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="WAPP_FinalAssignment.AdminDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard — ASP.NET Bootcamp</title>
    <link href="styles.css" rel="stylesheet" type="text/css" />
    <style>
        .admin-welcome {
            background: linear-gradient(115deg, #0d0d1a 0%, #1a0a2e 100%);
            border-radius: var(--radius-xl);
            padding: 32px 40px;
            margin-bottom: 32px;
            position: relative;
            overflow: hidden;
        }
        .admin-welcome::after {
            content: '⚙️';
            position: absolute;
            right: 40px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 80px;
            opacity: 0.12;
        }

        .admin-table-wrapper {
            background: var(--surface-0);
            border: 1px solid var(--ink-100);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }

        .admin-table-header {
            padding: 16px 20px;
            border-bottom: 1px solid var(--ink-100);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
        }

        .admin-table-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--ink-900);
        }

        .role-pill {
            display: inline-flex;
            align-items: center;
            padding: 2px 10px;
            border-radius: var(--radius-full);
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .role-admin   { background: var(--brand-purple-light); color: var(--brand-purple); }
        .role-educator{ background: var(--brand-green-light); color: var(--brand-green); }
        .role-learner { background: var(--brand-blue-light); color: var(--brand-blue-dark); }

        /* Quick inline search */
        .inline-search {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            border: 1px solid var(--ink-200);
            border-radius: var(--radius-sm);
            background: var(--surface-0);
        }
        .inline-search input {
            border: none;
            outline: none;
            font-size: 13px;
            font-family: 'DM Sans', sans-serif;
            color: var(--ink-900);
            background: transparent;
            width: 180px;
        }
        .inline-search input::placeholder { color: var(--ink-400); }

        /* Quiz attempt score colour classes (used in attempts table) */
        .score-pass { color: var(--brand-green); }
        .score-fail { color: var(--brand-red); }
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
                <li><a href="AdminDashboard.aspx" class="active">Admin Panel</a></li>
                <li><a href="ProfilePage.aspx">Profile</a></li>
            </ul>
            <div class="nav-right">
                <div class="nav-user-chip" onclick="toggleUserDropdown()" style="position:relative;">
                    <div class="nav-avatar" style="background:var(--brand-purple);"><asp:Label ID="lblNavInitial" runat="server" Text="A"></asp:Label></div>
                    <div>
                        <div class="chip-name"><asp:Label ID="lblNavName" runat="server" Text="Admin"></asp:Label></div>
                        <div class="chip-role">Administrator</div>
                    </div>
                    <svg width="12" height="8" viewBox="0 0 12 8" fill="none"><path d="M1 1l5 5 5-5" stroke="var(--ink-400)" stroke-width="1.5" stroke-linecap="round"/></svg>
                    <div id="userDropdown" style="display:none;position:absolute;top:calc(100% + 8px);right:0;background:var(--surface-0);border:1px solid var(--ink-100);border-radius:var(--radius-md);padding:8px 0;min-width:180px;box-shadow:var(--shadow-lg);z-index:200;">
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

        <!-- Welcome bar -->
        <div class="admin-welcome">
            <p style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:1px;color:rgba(255,255,255,0.45);margin-bottom:6px;">Administrator Panel</p>
            <h1 style="font-size:26px;font-weight:700;color:#fff;letter-spacing:-0.4px;margin-bottom:4px;">
                Platform Overview
            </h1>
            <p style="font-size:14px;color:rgba(255,255,255,0.55);">Full control over users, courses, enrolments, and quiz records.</p>
        </div>

        <!-- Server message -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:20px;">
            <div class="alert alert-success"><asp:Label ID="lblMessage" runat="server" Text=""></asp:Label></div>
        </asp:Panel>

        <!-- Platform stats -->
        <div class="stat-grid" style="margin-bottom:40px;">
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">👥</div>
                <div class="stat-number"><asp:Label ID="lblStatUsers" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">📚</div>
                <div class="stat-number"><asp:Label ID="lblStatCourses" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Total Courses</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">✏️</div>
                <div class="stat-number"><asp:Label ID="lblStatEnrolments" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Enrolments</div>
            </div>
            <div class="stat-card">
                <div style="font-size:22px;margin-bottom:4px;">🧠</div>
                <div class="stat-number"><asp:Label ID="lblStatAttempts" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Quiz Attempts</div>
            </div>
        </div>

        <!-- Tabs -->
        <div class="tab-nav">
            <button type="button" class="tab-nav-item active" onclick="switchTab('users', this)">👥 Users</button>
            <button type="button" class="tab-nav-item" onclick="switchTab('courses', this)">📚 Courses</button>
            <button type="button" class="tab-nav-item" onclick="switchTab('enrolments', this)">✏️ Enrolments</button>
            <button type="button" class="tab-nav-item" onclick="switchTab('attempts', this)">🧠 Quiz Attempts</button>
        </div>

        <!-- ===== TAB: USERS ===== -->
        <div id="tab-users" class="tab-panel active">
            <div class="admin-table-wrapper">
                <div class="admin-table-header">
                    <span class="admin-table-title">All Users (<asp:Label ID="lblUserCount" runat="server" Text="0"></asp:Label>)</span>
                    <div class="inline-search">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--ink-400)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                        <input type="text" placeholder="Search users…" oninput="filterTable('usersTable', this.value)" />
                    </div>
                </div>
                <div style="overflow-x:auto;">
                    <table class="data-table" id="usersTable">
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Registered</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:ListView ID="rptUsers" runat="server">
                                <LayoutTemplate>
                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div style="display:flex;align-items:center;gap:10px;">
                                                <div style="width:32px;height:32px;border-radius:50%;background:var(--brand-blue);color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;flex-shrink:0;">
                                                    <%# Eval("name").ToString().Substring(0,1).ToUpper() %>
                                                </div>
                                                <span style="font-weight:600;font-size:14px;"><%# Eval("name") %></span>
                                            </div>
                                        </td>
                                        <td style="font-size:13px;color:var(--ink-600);">@<%# Eval("username") %></td>
                                        <td style="font-size:13px;color:var(--ink-600);"><%# Eval("email") %></td>
                                        <td>
                                            <span class='role-pill <%# Eval("role").ToString() == "Admins" ? "role-admin" : Eval("role").ToString() == "Educator" ? "role-educator" : "role-learner" %>'>
                                                <%# Eval("role") %>
                                            </span>
                                        </td>
                                        <td style="font-size:13px;color:var(--ink-400);"><%# Eval("dateRegistered", "{0:MMM d, yyyy}") %></td>
                                        <td>
                                            <div class="action-group">
                                                <asp:Button ID="btnChangeRole" runat="server" Text="Change Role"
                                                    CssClass="btn btn-secondary btn-sm"
                                                    CommandArgument='<%# Eval("userID") %>'
                                                    OnClick="btnChangeRole_Click" />
                                                <asp:Button ID="btnDeleteUser" runat="server" Text="🗑"
                                                    CssClass="btn btn-danger btn-sm"
                                                    CommandArgument='<%# Eval("userID") %>'
                                                    OnClick="btnDeleteUser_Click"
                                                    OnClientClick="return confirm('Delete user and all their data?');" />
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <EmptyDataTemplate>
                                    <tr><td colspan="6" style="text-align:center;padding:40px;color:var(--ink-400);">No users found.</td></tr>
                                </EmptyDataTemplate>
                            </asp:ListView>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ===== TAB: COURSES ===== -->
        <div id="tab-courses" class="tab-panel">
            <div class="admin-table-wrapper">
                <div class="admin-table-header">
                    <span class="admin-table-title">All Courses (<asp:Label ID="lblCourseCount" runat="server" Text="0"></asp:Label>)</span>
                    <div class="inline-search">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--ink-400)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                        <input type="text" placeholder="Search courses…" oninput="filterTable('coursesTable', this.value)" />
                    </div>
                </div>
                <div style="overflow-x:auto;">
                    <table class="data-table" id="coursesTable">
                        <thead>
                            <tr>
                                <th>Course</th>
                                <th>Category</th>
                                <th>Instructor</th>
                                <th>Duration</th>
                                <th>Enrolments</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:ListView ID="rptCourses" runat="server">
                                <LayoutTemplate>
                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div style="display:flex;align-items:center;gap:10px;">
                                                <div style="width:40px;height:28px;border-radius:4px;overflow:hidden;background:var(--ink-100);flex-shrink:0;">
                                                    <img src='<%# Eval("headerPictureURL") %>' alt="" style="width:100%;height:100%;object-fit:cover;" onerror="this.style.display='none'" />
                                                </div>
                                                <div>
                                                    <a href='CoursePage.aspx?courseID=<%# Eval("courseID") %>' style="font-size:14px;font-weight:600;color:var(--ink-900);text-decoration:none;"><%# Eval("courseName") %></a>
                                                </div>
                                            </div>
                                        </td>
                                        <td><span class="badge badge-neutral" style="font-size:11px;"><%# Eval("category") %></span></td>
                                        <td style="font-size:13px;color:var(--ink-600);"><%# Eval("instructorName") %></td>
                                        <td style="font-size:13px;color:var(--ink-600);"><%# Eval("duration") %> hrs</td>
                                        <td style="font-size:13px;font-weight:600;color:var(--ink-900);"><%# Eval("enrolmentCount") %></td>
                                        <td style="font-size:13px;color:var(--ink-400);"><%# Eval("dateCreated", "{0:MMM d, yyyy}") %></td>
                                        <td>
                                            <div class="action-group">
                                                <a href='EditCourse.aspx?courseID=<%# Eval("courseID") %>' class="btn btn-secondary btn-sm">✏ Edit</a>
                                                <asp:Button ID="btnAdminDeleteCourse" runat="server" Text="🗑"
                                                    CssClass="btn btn-danger btn-sm"
                                                    CommandArgument='<%# Eval("courseID") %>'
                                                    OnClick="btnAdminDeleteCourse_Click"
                                                    OnClientClick="return confirm('Delete this course and all its content?');" />
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <EmptyDataTemplate>
                                    <tr><td colspan="7" style="text-align:center;padding:40px;color:var(--ink-400);">No courses found.</td></tr>
                                </EmptyDataTemplate>
                            </asp:ListView>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ===== TAB: ENROLMENTS ===== -->
        <div id="tab-enrolments" class="tab-panel">
            <div class="admin-table-wrapper">
                <div class="admin-table-header">
                    <span class="admin-table-title">All Enrolments (<asp:Label ID="lblEnrolmentCount" runat="server" Text="0"></asp:Label>)</span>
                    <div class="inline-search">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--ink-400)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                        <input type="text" placeholder="Search…" oninput="filterTable('enrolmentsTable', this.value)" />
                    </div>
                </div>
                <div style="overflow-x:auto;">
                    <table class="data-table" id="enrolmentsTable">
                        <thead>
                            <tr>
                                <th>Learner</th>
                                <th>Course</th>
                                <th>Enrolled</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:ListView ID="rptEnrolments" runat="server">
                                <LayoutTemplate>
                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td style="font-size:14px;font-weight:500;"><%# Eval("learnerName") %><div style="font-size:12px;color:var(--ink-400);">@<%# Eval("username") %></div></td>
                                        <td>
                                            <a href='CoursePage.aspx?courseID=<%# Eval("courseID") %>' style="font-size:14px;color:var(--brand-blue);text-decoration:none;font-weight:500;"><%# Eval("courseName") %></a>
                                        </td>
                                        <td style="font-size:13px;color:var(--ink-400);"><%# Eval("enrollDate", "{0:MMM d, yyyy}") %></td>
                                        <td>
                                            <span class='badge <%# Eval("status").ToString() == "Completed" ? "badge-green" : "badge-blue" %>'><%# Eval("status") %></span>
                                        </td>
                                        <td>
                                            <asp:Button ID="btnRemoveEnrolment" runat="server" Text="Remove"
                                                CssClass="btn btn-danger btn-sm"
                                                CommandArgument='<%# Eval("enrolmentID") %>'
                                                OnClick="btnRemoveEnrolment_Click"
                                                OnClientClick="return confirm('Remove this enrolment?');" />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <EmptyDataTemplate>
                                    <tr><td colspan="5" style="text-align:center;padding:40px;color:var(--ink-400);">No enrolments found.</td></tr>
                                </EmptyDataTemplate>
                            </asp:ListView>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ===== TAB: QUIZ ATTEMPTS ===== -->
        <div id="tab-attempts" class="tab-panel">
            <div class="admin-table-wrapper">
                <div class="admin-table-header">
                    <span class="admin-table-title">All Quiz Attempts (<asp:Label ID="lblAttemptCount" runat="server" Text="0"></asp:Label>)</span>
                    <div class="inline-search">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--ink-400)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                        <input type="text" placeholder="Search…" oninput="filterTable('attemptsTable', this.value)" />
                    </div>
                </div>
                <div style="overflow-x:auto;">
                    <table class="data-table" id="attemptsTable">
                        <thead>
                            <tr>
                                <th>Learner</th>
                                <th>Quiz</th>
                                <th>Course</th>
                                <th>Score</th>
                                <th>Pass / Fail</th>
                                <th>Attempted</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:ListView ID="rptAttempts" runat="server">
                                <LayoutTemplate>
                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td style="font-size:14px;font-weight:500;"><%# Eval("learnerName") %></td>
                                        <td style="font-size:14px;color:var(--ink-700);"><%# Eval("quizTitle") %></td>
                                        <td style="font-size:13px;color:var(--ink-600);"><%# Eval("courseName") %></td>
                                        <td>
                                            <span class='<%# (double)Eval("score") >= (double)Eval("passingScore") ? "score-pass" : "score-fail" %>' style="font-size:16px;font-weight:800;">
                                                <%# Math.Round((double)Eval("score")).ToString() %>%
                                            </span>
                                        </td>
                                        <td>
                                            <span class='badge <%# (double)Eval("score") >= (double)Eval("passingScore") ? "badge-green" : "badge-red" %>'>
                                                <%# (double)Eval("score") >= (double)Eval("passingScore") ? "Passed" : "Failed" %>
                                            </span>
                                        </td>
                                        <td style="font-size:13px;color:var(--ink-400);"><%# Eval("attemptDate", "{0:MMM d, yyyy}") %></td>
                                        <td>
                                            <asp:Button ID="btnDeleteAttempt" runat="server" Text="🗑 Delete"
                                                CssClass="btn btn-danger btn-sm"
                                                CommandArgument='<%# Eval("attemptID") %>'
                                                OnClick="btnDeleteAttempt_Click"
                                                OnClientClick="return confirm('Delete this quiz attempt record?');" />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <EmptyDataTemplate>
                                    <tr><td colspan="7" style="text-align:center;padding:40px;color:var(--ink-400);">No quiz attempts found.</td></tr>
                                </EmptyDataTemplate>
                            </asp:ListView>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div><!-- /container -->
</main>

<!-- Change Role Modal -->
<div id="changeRoleModal" class="modal-backdrop" onclick="closeModalOutside(event, 'changeRoleModal')">
    <div class="modal-box">
        <button type="button" class="modal-close" onclick="closeModal('changeRoleModal')">✕</button>
        <div class="modal-header">
            <h2>Change User Role</h2>
            <p>Select a new role for this user.</p>
        </div>
        <div class="form-group">
            <label class="form-label">New Role</label>
            <asp:DropDownList ID="ddlNewRole" runat="server" CssClass="form-control">
                <asp:ListItem Value="Learners" Text="Learner"></asp:ListItem>
                <asp:ListItem Value="Educator" Text="Educator"></asp:ListItem>
                <asp:ListItem Value="Admins" Text="Administrator"></asp:ListItem>
            </asp:DropDownList>
            <asp:HiddenField ID="hfRoleChangeUserID" runat="server" Value="" />
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeModal('changeRoleModal')">Cancel</button>
            <asp:Button ID="btnConfirmRoleChange" runat="server" Text="Save Role" CssClass="btn btn-primary" OnClick="btnConfirmRoleChange_Click" />
        </div>
    </div>
</div>

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
            <div class="footer-col"><h4>Admin</h4><a href="AdminDashboard.aspx">Dashboard</a></div>
            <div class="footer-col"><h4>Account</h4><a href="ProfilePage.aspx">My Profile</a></div>
            <div class="footer-col"><h4>Platform</h4><a href="#">APU Group 14</a></div>
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

    function filterTable(tableId, term) {
        const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
        const lower = term.toLowerCase();
        rows.forEach(row => {
            row.style.display = row.textContent.toLowerCase().includes(lower) ? '' : 'none';
        });
    }

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

    // Called from codebehind via ClientScript to open change role modal pre-filled
    function openChangeRoleModal(userId) {
        document.getElementById('<%= hfRoleChangeUserID.ClientID %>').value = userId;
        openModal('changeRoleModal');
    }
</script>
</body>
</html>
