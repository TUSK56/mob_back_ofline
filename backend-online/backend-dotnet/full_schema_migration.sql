-- =====================================================================
--  Jobito - Full Schema Migration Script
--  Database : db49878.databaseasp.net  (MSSQL)
--  Update Date: 2026-05-03 (Terminology Refactor: Staff & Classification)
--  Run this script once; it is fully idempotent (safe to re-run).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- TABLE: Users
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'[Users]', N'U') IS NULL
BEGIN
    CREATE TABLE [Users] (
        [Id]        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Email]     NVARCHAR(256)     NOT NULL,
        [Password]  NVARCHAR(128)     NULL, -- Nullable for Google login
        [Role]      NVARCHAR(32)      NOT NULL DEFAULT 'user',
        [Name]      NVARCHAR(128)     NOT NULL DEFAULT '',
        [GoogleId]  NVARCHAR(256)     NULL,
        [PhotoUrl]  NVARCHAR(MAX)     NULL,
        
        -- User/Tradesman profile details
        [Phone]                NVARCHAR(32)   NULL,
        [Gender]               NVARCHAR(16)   NULL,
        [Dob]                  NVARCHAR(32)   NULL,
        [Address]              NVARCHAR(256)  NULL,
        [Title]                NVARCHAR(128)  NULL,
        [SkillsCsv]            NVARCHAR(MAX)  NULL,
        [EducationJson]        NVARCHAR(MAX)  NULL,
        [ExperienceJson]       NVARCHAR(MAX)  NULL,
        [SocialLinksJson]      NVARCHAR(MAX)  NULL,
        [PortfolioImagesJson]  NVARCHAR(MAX)  NULL,

        -- Company specific details
        [About]                NVARCHAR(MAX)  NULL,
        [Staff]                NVARCHAR(64)   NULL, -- Replaces EmployeeCount/Stuff
        [Classification]       NVARCHAR(128)  NULL, -- Replaces Category (Technical/Non-Technical)
        [LocationHeadquarters] NVARCHAR(256)  NULL,
        [LocationsCsv]         NVARCHAR(MAX)  NULL,
        [BenefitsCsv]          NVARCHAR(MAX)  NULL,
        [TechStackCsv]         NVARCHAR(MAX)  NULL,
        [FoundedDay]           INT            NOT NULL DEFAULT 0,
        [FoundedMonth]         INT            NOT NULL DEFAULT 0,
        [FoundedYear]          INT            NOT NULL DEFAULT 0,
        [Website]              NVARCHAR(256)  NULL,
        [Industry]             NVARCHAR(128)  NULL,
        [CommercialRegister]   NVARCHAR(128)  NULL,
        [NationalNumber]       NVARCHAR(128)  NULL,
        [ContactsJson]         NVARCHAR(MAX)  NULL
    );
    CREATE UNIQUE INDEX [IX_Users_Email] ON [Users]([Email]);
    PRINT 'TABLE [Users] created.';
END
ELSE
BEGIN
    PRINT 'TABLE [Users] already exists – checking for missing columns...';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'GoogleId')
        ALTER TABLE [Users] ADD [GoogleId] NVARCHAR(256) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'PhotoUrl')
        ALTER TABLE [Users] ADD [PhotoUrl] NVARCHAR(MAX) NULL;
    ELSE
        ALTER TABLE [Users] ALTER COLUMN [PhotoUrl] NVARCHAR(MAX) NULL;

    -- User/Tradesman Details
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Phone')
        ALTER TABLE [Users] ADD [Phone] NVARCHAR(32) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Gender')
        ALTER TABLE [Users] ADD [Gender] NVARCHAR(16) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Dob')
        ALTER TABLE [Users] ADD [Dob] NVARCHAR(32) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Address')
        ALTER TABLE [Users] ADD [Address] NVARCHAR(256) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Title')
        ALTER TABLE [Users] ADD [Title] NVARCHAR(128) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'SkillsCsv')
        ALTER TABLE [Users] ADD [SkillsCsv] NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'EducationJson')
        ALTER TABLE [Users] ADD [EducationJson] NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'ExperienceJson')
        ALTER TABLE [Users] ADD [ExperienceJson] NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'SocialLinksJson')
        ALTER TABLE [Users] ADD [SocialLinksJson] NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'PortfolioImagesJson')
        ALTER TABLE [Users] ADD [PortfolioImagesJson] NVARCHAR(MAX) NULL;

    -- Company Details
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'About')
        ALTER TABLE [Users] ADD [About] NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'LocationHeadquarters')
        ALTER TABLE [Users] ADD [LocationHeadquarters] NVARCHAR(256) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'LocationsCsv')
        ALTER TABLE [Users] ADD [LocationsCsv] NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'BenefitsCsv')
        ALTER TABLE [Users] ADD [BenefitsCsv] NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'TechStackCsv')
        ALTER TABLE [Users] ADD [TechStackCsv] NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'FoundedDay')
        ALTER TABLE [Users] ADD [FoundedDay] INT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'FoundedMonth')
        ALTER TABLE [Users] ADD [FoundedMonth] INT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'FoundedYear')
        ALTER TABLE [Users] ADD [FoundedYear] INT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Website')
        ALTER TABLE [Users] ADD [Website] NVARCHAR(256) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Industry')
        ALTER TABLE [Users] ADD [Industry] NVARCHAR(128) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'CommercialRegister')
        ALTER TABLE [Users] ADD [CommercialRegister] NVARCHAR(128) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'NationalNumber')
        ALTER TABLE [Users] ADD [NationalNumber] NVARCHAR(128) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'ContactsJson')
        ALTER TABLE [Users] ADD [ContactsJson] NVARCHAR(MAX) NULL;

    -- RENAMING LOGIC for Users
    -- 1. Classification (Old name for employee count) -> Staff
    IF COL_LENGTH('Users', 'Classification') IS NOT NULL AND COL_LENGTH('Users', 'Staff') IS NULL
        EXEC sp_rename 'Users.Classification', 'Staff', 'COLUMN';
    
    -- 2. Stuff (Temporary name) -> Staff
    IF COL_LENGTH('Users', 'Stuff') IS NOT NULL AND COL_LENGTH('Users', 'Staff') IS NULL
        EXEC sp_rename 'Users.Stuff', 'Staff', 'COLUMN';

    -- 3. Category (Old name for tech/non-tech) -> Classification
    IF COL_LENGTH('Users', 'Category') IS NOT NULL AND COL_LENGTH('Users', 'Classification') IS NULL
        EXEC sp_rename 'Users.Category', 'Classification', 'COLUMN';

    -- Final safety check to add columns if they still don't exist
    IF COL_LENGTH('Users', 'Staff') IS NULL
        ALTER TABLE [Users] ADD [Staff] NVARCHAR(64) NULL;
    
    IF COL_LENGTH('Users', 'Classification') IS NULL
        ALTER TABLE [Users] ADD [Classification] NVARCHAR(128) NULL;
END
GO


-- ─────────────────────────────────────────────────────────────────────
-- TABLE: Jobs
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'[Jobs]', N'U') IS NULL
BEGIN
    CREATE TABLE [Jobs] (
        [Id]                   NVARCHAR(64)   NOT NULL PRIMARY KEY,
        [CompanyId]            INT            NOT NULL DEFAULT 0,
        [Title]                NVARCHAR(256)  NOT NULL,
        [CompanyName]          NVARCHAR(256)  NOT NULL,
        [Location]             NVARCHAR(128)  NOT NULL DEFAULT 'Remote',
        [SalaryRange]          NVARCHAR(128)  NOT NULL DEFAULT 'Negotiable',
        [Type]                 NVARCHAR(64)   NOT NULL DEFAULT 'Full-time',
        [Description]          NVARCHAR(MAX)  NOT NULL DEFAULT '',
        [ResponsibilitiesCsv]  NVARCHAR(MAX)  NOT NULL DEFAULT '',
        [QualificationsCsv]    NVARCHAR(MAX)  NOT NULL DEFAULT '',
        [NiceToHavesCsv]       NVARCHAR(MAX)  NOT NULL DEFAULT '',
        [BenefitsCsv]          NVARCHAR(MAX)  NOT NULL DEFAULT '',
        [Classification]       NVARCHAR(128)  NOT NULL DEFAULT '', -- Replaces Category
        [TagsCsv]              NVARCHAR(1000) NOT NULL DEFAULT '',
        [CreatedAt]            DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
        [ApplicationCount]     INT            NOT NULL DEFAULT 0,
        [RequiredCount]        INT            NOT NULL DEFAULT 1,
        [AcceptedCount]        INT            NOT NULL DEFAULT 0,
        [Deadline]             DATETIME2      NULL,
        [Status]               NVARCHAR(64)   NOT NULL DEFAULT 'Open',
        [ViewsCount]           INT            NOT NULL DEFAULT 0
    );
    PRINT 'TABLE [Jobs] created.';
END
ELSE
BEGIN
    PRINT 'TABLE [Jobs] already exists – checking for missing columns...';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'Description')
        ALTER TABLE [Jobs] ADD [Description] NVARCHAR(MAX) NOT NULL DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'ResponsibilitiesCsv')
        ALTER TABLE [Jobs] ADD [ResponsibilitiesCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'QualificationsCsv')
        ALTER TABLE [Jobs] ADD [QualificationsCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'NiceToHavesCsv')
        ALTER TABLE [Jobs] ADD [NiceToHavesCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'BenefitsCsv')
        ALTER TABLE [Jobs] ADD [BenefitsCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'TagsCsv')
        ALTER TABLE [Jobs] ADD [TagsCsv] NVARCHAR(1000) NOT NULL DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'ApplicationCount')
        ALTER TABLE [Jobs] ADD [ApplicationCount] INT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'RequiredCount')
        ALTER TABLE [Jobs] ADD [RequiredCount] INT NOT NULL DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'AcceptedCount')
        ALTER TABLE [Jobs] ADD [AcceptedCount] INT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'Status')
        ALTER TABLE [Jobs] ADD [Status] NVARCHAR(64) NOT NULL DEFAULT 'Open';
    
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'Deadline')
        ALTER TABLE [Jobs] ADD [Deadline] DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Jobs]') AND name = N'ViewsCount')
        ALTER TABLE [Jobs] ADD [ViewsCount] INT NOT NULL DEFAULT 0;
    
    -- RENAMING LOGIC for Jobs
    -- Category -> Classification
    IF COL_LENGTH('Jobs', 'Category') IS NOT NULL AND COL_LENGTH('Jobs', 'Classification') IS NULL
        EXEC sp_rename 'Jobs.Category', 'Classification', 'COLUMN';
    
    IF COL_LENGTH('Jobs', 'Classification') IS NULL
        ALTER TABLE [Jobs] ADD [Classification] NVARCHAR(128) NOT NULL DEFAULT '';
END
GO


-- ─────────────────────────────────────────────────────────────────────
-- TABLE: Applications
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'[Applications]', N'U') IS NULL
BEGIN
    CREATE TABLE [Applications] (
        [Id]        NVARCHAR(64)  NOT NULL PRIMARY KEY,
        [UserId]    INT           NOT NULL DEFAULT 0,
        [UserName]  NVARCHAR(128) NOT NULL,
        [JobId]     NVARCHAR(64)  NOT NULL,
        [Status]    NVARCHAR(64)  NOT NULL DEFAULT 'Applied',
        [UpdatedAt] DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'TABLE [Applications] created.';
END
GO


-- ─────────────────────────────────────────────────────────────────────
-- TABLE: Messages
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'[Messages]', N'U') IS NULL
BEGIN
    CREATE TABLE [Messages] (
        [Id]          NVARCHAR(64)   NOT NULL PRIMARY KEY,
        [FromCompany] BIT            NOT NULL DEFAULT 0,
        [Text]        NVARCHAR(2000) NOT NULL,
        [CreatedAt]   DATETIME2      NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'TABLE [Messages] created.';
END
GO


-- ─────────────────────────────────────────────────────────────────────
-- TABLE: Notifications
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'[Notifications]', N'U') IS NULL
BEGIN
    CREATE TABLE [Notifications] (
        [Id]        NVARCHAR(64)   NOT NULL PRIMARY KEY,
        [Type]      NVARCHAR(64)   NOT NULL,
        [Text]      NVARCHAR(2000) NOT NULL,
        [CreatedAt] DATETIME2      NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'TABLE [Notifications] created.';
END
GO


-- =====================================================================
--  Final validation – lists all tables and column counts.
-- =====================================================================
SELECT
    t.name             AS TableName,
    COUNT(c.column_id) AS ColumnCount
FROM sys.tables  t
JOIN sys.columns c ON c.object_id = t.object_id
WHERE t.name IN ('Users','Jobs','Applications','Messages','Notifications')
GROUP BY t.name
ORDER BY t.name;
GO
