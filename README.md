# ASP.NET Bootcamp — LMS Final Assignment

A database-driven Learning Management System built end-to-end on ASP.NET Web Forms (.NET Framework 4.7.2), SQL Server LocalDB, and ADO.NET. Designed as a hands-on project for the **WAPP CT050-3-2** module — APU Group 11.

The platform itself is the demo: educators publish courses, lessons, and quizzes; learners enrol, mark lessons complete, take quizzes, and track progress; administrators manage everything from a dedicated panel.

---

## Table of contents
- [Tech stack](#tech-stack)
- [Roles and what each can do](#roles-and-what-each-can-do)
- [Prerequisites](#prerequisites)
- [Run with IIS Express (Visual Studio)](#run-with-iis-express-visual-studio)
- [Database](#database)
  - [First run](#first-run)
  - [Recover from a corrupted log file](#recover-from-a-corrupted-log-file)
- [Project layout](#project-layout)
- [Routes / pages](#routes--pages)
- [Schema](#schema)
- [Configuration](#configuration)
- [Common dev tasks](#common-dev-tasks)
- [Known caveats](#known-caveats)
- [Credits](#credits)

---

## Tech stack
| Layer | Choice |
|------|--------|
| Runtime | .NET Framework 4.7.2 |
| Framework | ASP.NET Web Forms |
| Server | IIS Express (HTTPS on port `44330`) |
| Data | SQL Server LocalDB (`(LocalDB)\MSSQLLocalDB`) attached via `AttachDbFilename` |
| Data access | ADO.NET via a small `Db` helper (parameterised `SqlCommand`s, transactions, NaN/null safe converters) |
| Auth | Server-side session, SHA-256 password hashing |
| Frontend | Hand-written HTML/CSS in `styles.css` (DM Sans + DM Mono via Google Fonts), Google-Skills inspired styling |
| Markdown | Lightweight server-side renderer for lesson / quiz readmes |

No client-side frameworks, no jQuery (`UnobtrusiveValidationMode` is disabled in `Web.config`), no NuGet runtime packages beyond the Roslyn compiler shim.

---

## Roles and what each can do

| Capability | Learner | Educator | Admin |
|---|---|---|---|
| Browse course catalogue | ✓ | ✓ | ✓ |
| Enrol / unenrol in courses | ✓ | — | — |
| Mark lessons as complete | ✓ | — | — |
| Take quizzes (scored server-side) | ✓ | — | — |
| Create / edit / delete own courses | — | ✓ | ✓ |
| Create / edit / delete lessons inside own courses | — | ✓ | ✓ |
| Create / edit / delete quizzes inside own courses | — | ✓ | ✓ |
| Edit any course / lesson / quiz | — | — | ✓ |
| Manage users (change role, delete) | — | — | ✓ |
| Remove enrolments and quiz attempts | — | — | ✓ |

Roles are stored as `Admins` / `Educator` / `Learners` in `dbo.Users.role`. Self-registration supports all three; only admins can change another user's role afterwards.

---

## Prerequisites
- **Visual Studio 2022** (Community is fine) with the **ASP.NET and web development** workload
- **.NET Framework 4.7.2 Developer Pack** (usually bundled with the workload)
- **SQL Server LocalDB** (also bundled; verify with `sqllocaldb info`)

---

## Run with IIS Express (Visual Studio)

1. Clone:
   ```
   git clone <your-fork-url>
   cd WAPP-FinalAssignment
   ```
2. Open `WAPP-FinalAssignment.slnx` in Visual Studio.
3. The `.csproj` is already wired to use IIS Express on `https://localhost:44330/`. No port editing required.
4. **First time only**: trust the IIS Express SSL certificate when Visual Studio prompts.
5. Press <kbd>F5</kbd> (or <kbd>Ctrl</kbd>+<kbd>F5</kbd> for run-without-debug).
6. The browser opens `https://localhost:44330/HomePage.aspx`. Register an account and start clicking around.

> **Don't see the site?** Make sure no other process is using port `44330` (`netstat -ano | findstr 44330`) and that LocalDB is running (`sqllocaldb start MSSQLLocalDB`).

---

## Database

The app ships with a pre-seeded `Databases.mdf` under `WAPP-FinalAssignment/App_Data/`. The connection string in `Web.config` uses `AttachDbFilename=|DataDirectory|\Databases.mdf;Integrated Security=True`, so LocalDB auto-attaches it the first time the app touches the DB.

| File | Tracked in git | Purpose |
|---|---|---|
| `WAPP-FinalAssignment/App_Data/Databases.mdf` | yes | Pre-seeded LocalDB data file (eight `dbo.*` tables + sample rows) |
| `WAPP-FinalAssignment/App_Data/Databases_log.ldf` | no (re-created on attach) | LocalDB transaction log for the above |
| `WAPP-FinalAssignment/dbosinmdf.txt` | yes | Original eight-table schema reference (mirrored in [Schema](#schema)) |

The full set of `CREATE TABLE` statements is reproduced under [Schema](#schema) below — copy-pasteable if you ever need to rebuild the DB from scratch.

### First run
- The `.mdf` is committed; the `.ldf` and `.ldf.bak` are git-ignored. LocalDB will (re)create the log automatically when the database is first opened.
- A `LessonCompletions` table is created at install time by a one-shot SQL script — see *Recover from a corrupted log file* if you need to reattach manually.

### Recover from a corrupted log file

If you see this server error after pulling fresh code or moving the project between machines:

> The log scan number (…) passed to log scan in database '…\\Databases.mdf' is not valid. … An attempt to attach an auto-named database for file …\\Databases.mdf failed. A database with the same name exists, or specified file cannot be opened, or it is located on UNC share.

run these PowerShell commands from the repo root. They detach any phantom registration in LocalDB, delete the broken log, and rebuild it from the `.mdf`:

```powershell
sqllocaldb stop MSSQLLocalDB
sqllocaldb start MSSQLLocalDB

$mdf = "$PWD\WAPP-FinalAssignment\App_Data\Databases.mdf"
$ldf = "$PWD\WAPP-FinalAssignment\App_Data\Databases_log.ldf"

# Detach any phantom 'Databases' registration
$cn = New-Object System.Data.SqlClient.SqlConnection("Server=(LocalDB)\MSSQLLocalDB;Database=master;Integrated Security=True")
$cn.Open()
$cmd = $cn.CreateCommand()
$cmd.CommandText = @"
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Databases')
BEGIN
    ALTER DATABASE [Databases] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    EXEC master.dbo.sp_detach_db @dbname = N'Databases', @skipchecks = N'true';
END
"@
$cmd.ExecuteNonQuery() | Out-Null

# Remove stale log + rebuild
if (Test-Path $ldf) { Remove-Item $ldf -Force }
$cmd.CommandText = "CREATE DATABASE [Databases] ON (FILENAME = N'$mdf') FOR ATTACH_REBUILD_LOG;"
$cmd.ExecuteNonQuery() | Out-Null

# Detach again so the web app can auto-attach via the connection string
$cmd.CommandText = "ALTER DATABASE [Databases] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; EXEC master.dbo.sp_detach_db @dbname = N'Databases', @skipchecks = N'true';"
$cmd.ExecuteNonQuery() | Out-Null
$cn.Close()
```

After that, hit <kbd>F5</kbd> again — the next request will re-attach cleanly.

---

## Project layout

```
WAPP-FinalAssignment/
├── README.md
├── WAPP-FinalAssignment.slnx          ← solution
└── WAPP-FinalAssignment/              ← web project
    ├── Web.config                     ← connection string + globalization + validation mode
    ├── App_Data/
    │   └── Databases.mdf              ← LocalDB data file (committed)
    ├── styles.css                     ← global stylesheet (DM Sans / DM Mono / Google-Skills inspired)
    ├── Db.cs                          ← ADO.NET helper (parameterised commands, transactions, type coercion, SHA-256 hash)
    ├── SessionHelper.cs               ← auth/session façade with role helpers (RequireRole, DashboardUrl, Initial)
    ├── HomePage.aspx                  ← public landing + sign-in / register modals
    ├── LearnerDashboard.aspx          ← learner stats, enrolments, completed lessons, quiz attempts
    ├── EducatorDashboard.aspx         ← per-course accordion with nested lessons & quizzes
    ├── AdminDashboard.aspx            ← Users / Courses / Enrolments / Attempts tables
    ├── ProfilePage.aspx               ← edit info, change password, delete account (cascade)
    ├── CoursePage.aspx                ← course detail with role-aware action bar + progress
    ├── CreateCourse.aspx + EditCourse.aspx
    ├── LessonPage.aspx                ← markdown readme + video iframe + Mark Complete
    ├── CreateLesson.aspx + EditLesson.aspx
    ├── QuizPage.aspx                  ← attempt form + result panel + answer review
    └── CreateQuiz.aspx + EditQuiz.aspx
```

Every ASPX has a matching `.aspx.cs` (server-side logic) and `.aspx.designer.cs` (auto-generated control declarations).

---

## Routes / pages

| URL | Who can see it | Purpose |
|---|---|---|
| `/HomePage.aspx` | everyone | Hero, course catalogue, sign-in & register modals |
| `/CoursePage.aspx?courseID=N` | everyone | Course detail, enrol button, lesson + quiz tabs |
| `/LessonPage.aspx?lessonID=N` | enrolled learners + course owner + admins | Markdown readme, embedded video, mark complete |
| `/QuizPage.aspx?quizID=N` | enrolled learners + course owner + admins | Attempt the quiz, see scored result |
| `/LearnerDashboard.aspx` | learners | Enrolled courses + progress, completed lessons, quiz attempts |
| `/EducatorDashboard.aspx` | educators + admins | Manage own courses + nested lessons / quizzes |
| `/AdminDashboard.aspx` | admins | Platform-wide tables (users / courses / enrolments / attempts) |
| `/CreateCourse.aspx` / `/EditCourse.aspx?courseID=N` | educators (own) + admins | Course CRUD |
| `/CreateLesson.aspx?courseID=N` / `/EditLesson.aspx?lessonID=N` | educators (own) + admins | Lesson CRUD |
| `/CreateQuiz.aspx?courseID=N` / `/EditQuiz.aspx?quizID=N` | educators (own) + admins | Quiz CRUD with question editor |
| `/ProfilePage.aspx` | any signed-in user | Profile / password / delete account |
| `/HomePage.aspx?action=logout` | any signed-in user | Clears session and redirects home |

---

## Schema

### `dbo.Users`

```sql
CREATE TABLE [dbo].[Users] (
    [userID]         INT          IDENTITY (1, 1) NOT NULL,
    [username]       VARCHAR (50) NOT NULL,
    [name]           VARCHAR (50) NOT NULL,
    [email]          VARCHAR (50) NOT NULL,
    [passwordHash]   VARCHAR (64) NOT NULL,
    [role]           VARCHAR (20) NOT NULL,
    [dateRegistered] DATE         NOT NULL,
    PRIMARY KEY CLUSTERED ([userID] ASC),
    UNIQUE NONCLUSTERED ([username] ASC),
    CONSTRAINT [CHK_Users_role] CHECK
        ([role]='Admins' OR [role]='Educator' OR [role]='Learners')
);
```

### `dbo.Courses`

```sql
CREATE TABLE [dbo].[Courses] (
    [courseID]         INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [userID]           INT          NOT NULL, -- the educator who created it
    [courseName]       VARCHAR(50)  NOT NULL,
    [description]      VARCHAR(200) NOT NULL,
    [category]         VARCHAR(50)  NOT NULL,
    [duration]         FLOAT        NOT NULL,
    [headerPictureURL] VARCHAR(255) NOT NULL,
    [dateCreated]      DATE         NOT NULL,
    CONSTRAINT [FK_Courses_Users]
        FOREIGN KEY ([userID]) REFERENCES [dbo].[Users] ([userID])
);
```

### `dbo.Enrolments`

```sql
CREATE TABLE [dbo].[Enrolments] (
    [enrolmentID] INT         IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [userID]      INT         NOT NULL,
    [courseID]    INT         NOT NULL,
    [enrollDate]  DATE        NOT NULL,
    [status]      VARCHAR(20) NOT NULL
        CONSTRAINT [CHK_Enrolments_status]
            CHECK ([status] IN ('Active', 'Completed')),
    CONSTRAINT [FK_Enrolments_Users]
        FOREIGN KEY ([userID])   REFERENCES [dbo].[Users]   ([userID]),
    CONSTRAINT [FK_Enrolments_Courses]
        FOREIGN KEY ([courseID]) REFERENCES [dbo].[Courses] ([courseID])
);
```

### `dbo.Lessons`

```sql
CREATE TABLE [dbo].[Lessons] (
    [lessonID]    INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [courseID]    INT          NOT NULL,
    [lessonTitle] VARCHAR(50)  NOT NULL,
    [description] VARCHAR(200) NOT NULL,
    [level]       VARCHAR(20)  NOT NULL
        CONSTRAINT [CHK_Lessons_level]
            CHECK ([level] IN ('Beginner', 'Intermediate', 'Advanced')),
    [readme]      TEXT         NULL,
    [videoURL]    VARCHAR(255) NULL,
    [duration]    FLOAT        NOT NULL,
    [dateCreated] DATE         NOT NULL,
    CONSTRAINT [FK_Lessons_Courses]
        FOREIGN KEY ([courseID]) REFERENCES [dbo].[Courses] ([courseID])
);
```

### `dbo.Quizzes`

```sql
CREATE TABLE [dbo].[Quizzes] (
    [quizID]       INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [courseID]     INT          NOT NULL,
    [quizTitle]    VARCHAR(50)  NOT NULL,
    [description]  VARCHAR(200) NOT NULL,
    [readme]       TEXT         NULL,
    [videoURL]     VARCHAR(255) NULL,
    [passingScore] FLOAT        NOT NULL,
    [dateCreated]  DATE         NOT NULL,
    CONSTRAINT [FK_Quizzes_Courses]
        FOREIGN KEY ([courseID]) REFERENCES [dbo].[Courses] ([courseID])
);
```

### `dbo.QuizQuestions`

```sql
CREATE TABLE [dbo].[QuizQuestions] (
    [questionID]     INT   IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [quizID]         INT   NOT NULL,
    [questionsScore] FLOAT NOT NULL,
    [questionText]   TEXT  NOT NULL,
    [optionA]        TEXT  NULL,
    [optionB]        TEXT  NULL,
    [optionC]        TEXT  NULL,
    [optionD]        TEXT  NULL,
    [correctAnswer]  TEXT  NULL,
    CONSTRAINT [FK_QuizQuestions_Quizzes]
        FOREIGN KEY ([quizID]) REFERENCES [dbo].[Quizzes] ([quizID])
);
```

### `dbo.QuizAttempts`

```sql
CREATE TABLE [dbo].[QuizAttempts] (
    [attemptID]   INT   IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [userID]      INT   NOT NULL,
    [quizID]      INT   NOT NULL,
    [score]       FLOAT NOT NULL,
    [attemptDate] DATE  NOT NULL,
    CONSTRAINT [FK_QuizAttempts_Users]
        FOREIGN KEY ([userID]) REFERENCES [dbo].[Users]   ([userID]),
    CONSTRAINT [FK_QuizAttempts_Quizzes]
        FOREIGN KEY ([quizID]) REFERENCES [dbo].[Quizzes] ([quizID])
);
```

### `dbo.AttemptSummaries`

```sql
CREATE TABLE [dbo].[AttemptSummaries] (
    [summaryID]     INT  IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [attemptID]     INT  NOT NULL,
    [questionID]    INT  NOT NULL,
    [answer]        TEXT NULL,
    [isCorrect]     BIT  NULL, -- SQL Server uses BIT for true/false boolean logic
    [correctAnswer] TEXT NULL,
    CONSTRAINT [FK_AttemptSummaries_QuizAttempts]
        FOREIGN KEY ([attemptID])  REFERENCES [dbo].[QuizAttempts]  ([attemptID]),
    CONSTRAINT [FK_AttemptSummaries_QuizQuestions]
        FOREIGN KEY ([questionID]) REFERENCES [dbo].[QuizQuestions] ([questionID])
);
```

### `dbo.LessonCompletions`

```sql
CREATE TABLE [dbo].[LessonCompletions] (
    [completionID]  INT  IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [userID]        INT  NOT NULL,
    [lessonID]      INT  NOT NULL,
    [dateCompleted] DATE NOT NULL,
    CONSTRAINT [FK_LC_Users]
        FOREIGN KEY ([userID])   REFERENCES [dbo].[Users]   ([userID]),
    CONSTRAINT [FK_LC_Lessons]
        FOREIGN KEY ([lessonID]) REFERENCES [dbo].[Lessons] ([lessonID]),
    CONSTRAINT [UQ_LC_UserLesson] UNIQUE ([userID], [lessonID])
);
```

### Build the whole DB from these scripts

If `Databases.mdf` is missing or corrupt and you'd rather rebuild from scratch instead of using `ATTACH_REBUILD_LOG`, drop into the LocalDB master, create an empty database, then run every script above:

```powershell
$mdf = "$PWD\WAPP-FinalAssignment\App_Data\Databases.mdf"

$cn = New-Object System.Data.SqlClient.SqlConnection("Server=(LocalDB)\MSSQLLocalDB;Database=master;Integrated Security=True")
$cn.Open()
$cmd = $cn.CreateCommand()
$cmd.CommandText = @"
CREATE DATABASE [Databases] ON PRIMARY
   (NAME = N'Databases', FILENAME = N'$mdf', SIZE = 8MB, FILEGROWTH = 8MB);
"@
$cmd.ExecuteNonQuery() | Out-Null
$cn.Close()
```

Then connect to the new DB (`Database=Databases`) and execute the eight `CREATE TABLE` blocks above in this order: `Users → Courses → Enrolments → Lessons → Quizzes → QuizQuestions → QuizAttempts → AttemptSummaries → LessonCompletions`.

### Cascade behaviour
- Deleting a **course** removes its `AttemptSummaries → QuizAttempts → QuizQuestions → Quizzes → LessonCompletions → Lessons → Enrolments → Courses` rows in a single transaction.
- Deleting a **user** also cascades through their `LessonCompletions`, attempt records, enrolments, and (if they're an educator) every course they authored.

All cascades run inside a `Db.RunInTransaction` block so partial failures roll back.

---

## Configuration

Everything that can be tuned lives in `Web.config`:

```xml
<connectionStrings>
  <add name="DatabasesConnectionString"
       connectionString="Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=|DataDirectory|\Databases.mdf;Integrated Security=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>
<system.web>
  <compilation debug="true" targetFramework="4.7.2" />
  <httpRuntime targetFramework="4.7.2" />
  <globalization fileEncoding="utf-8" requestEncoding="utf-8" responseEncoding="utf-8" />
  <pages validateRequest="false">
    <controls />
  </pages>
</system.web>
<appSettings>
  <add key="ValidationSettings:UnobtrusiveValidationMode" value="None" />
</appSettings>
```

Why each setting matters:
- **UnobtrusiveValidationMode = None** — ASP.NET 4.5+ defaults to `WebForms` mode which requires a registered jQuery script mapping. We use plain server-side validators with classic inline JS instead, no jQuery dependency.
- **globalization … utf-8** — forces every aspx to be parsed and emitted as UTF-8 regardless of byte-order-mark presence. Without this, files saved without a BOM render emojis as Mojibake on Windows.
- **validateRequest = "false"** — quiz / lesson readmes accept arbitrary user-entered content (markdown, code samples), so request validation is opted out at page level. All such content is HTML-encoded at render time via `Db.SafeHtml`.

---

## Common dev tasks

### Reset the database
Delete `WAPP-FinalAssignment/App_Data/Databases_log.ldf` and run the recovery script in *Recover from a corrupted log file*. To wipe data entirely, additionally `TRUNCATE TABLE` each table in dependency order (or recreate the `.mdf` from `dbosinmdf.txt`).

### Add a new role
Update the `CHK_Users_role` constraint and the `SessionHelper.Role*` constants together. Don't forget to add a friendly label in `FriendlyRole` (`HomePage.cs` / `ProfilePage.cs`) and an entry in the `<asp:DropDownList ID="ddlRegRole">` on `HomePage.aspx`.

### Inspect SQL at runtime
The `Db` helper writes exception details via `System.Diagnostics.Debug.WriteLine(...)`. Watch the **Output** window in Visual Studio while running under the debugger to see them.

### Run without Visual Studio
You can host on a local IIS instance instead — point an application to `WAPP-FinalAssignment\` and ensure the application pool runs under an account that can read/write `App_Data`. The connection string is portable as long as LocalDB is installed.

---

## Known caveats

- **YouTube watch URLs are auto-converted** to embed URLs at render time (`youtube.com/watch?v=…`, `youtu.be/…`, `youtube.com/shorts/…`). Other providers should be supplied as direct embed URLs.
- **Password hashing is SHA-256** (single-pass, no salt) so the hash fits the schema's `VARCHAR(64)` column. This is fine for an academic project — for production, switch to PBKDF2 / bcrypt with a wider column.
- **Sessions are InProc** (the default). Recycling the app pool signs everyone out.
- **Static `.mdf` in App_Data** means the database moves with the project — no migration tooling. Schema drift between the `.txt` spec and the live `.mdf` is rebuilt on attach by `ATTACH_REBUILD_LOG` when needed.

---

## Credits

Built by **APU Group 11** for **WAPP CT050-3-2** — Web Applications module, Asia Pacific University.

Course schema, design language, and all server-side code authored by the team. Stylistic inspiration drawn from Google Skillshop and Google's Material Design.
