using Microsoft.EntityFrameworkCore;

namespace Jobito.Api.Data;

public static class SqlBootstrapper
{
    public static async Task EnsureTablesAsync(AppDbContext db)
    {
        // ─── 1. CREATE tables if they don't exist (full correct schema) ───
        const string createSql = """
IF OBJECT_ID(N'[Users]', N'U') IS NULL
BEGIN
    CREATE TABLE [Users](
        [Id]        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Email]     NVARCHAR(256)     NOT NULL,
        [Password]  NVARCHAR(128)     NULL,
        [Role]      NVARCHAR(32)      NOT NULL DEFAULT 'user',
        [Name]      NVARCHAR(128)     NOT NULL DEFAULT '',
        [GoogleId]  NVARCHAR(256)     NULL,
        [PhotoUrl]  NVARCHAR(MAX)     NULL,
        [About]     NVARCHAR(MAX)     NULL,
        [Staff]     NVARCHAR(64)      NULL,
        [Classification] NVARCHAR(128) NULL,
        [LocationHeadquarters] NVARCHAR(256) NULL,
        [LocationsCsv]  NVARCHAR(MAX) NULL,
        [BenefitsCsv]   NVARCHAR(MAX) NULL,
        [TechStackCsv]  NVARCHAR(MAX) NULL,
        [FoundedDay]    INT NOT NULL DEFAULT 0,
        [FoundedMonth]  INT NOT NULL DEFAULT 0,
        [FoundedYear]   INT NOT NULL DEFAULT 0,
        [Website]       NVARCHAR(256) NULL,
        [Industry]      NVARCHAR(128) NULL,
        [CommercialRegister] NVARCHAR(128) NULL,
        [NationalNumber] NVARCHAR(128) NULL,
        [ContactsJson]  NVARCHAR(MAX) NULL,
        [Phone]         NVARCHAR(32)  NULL,
        [Gender]        NVARCHAR(32)  NULL,
        [Dob]           NVARCHAR(32)  NULL,
        [Address]       NVARCHAR(256) NULL,
        [Title]         NVARCHAR(128) NULL,
        [SkillsCsv]     NVARCHAR(MAX) NULL,
        [EducationJson] NVARCHAR(MAX) NULL,
        [ExperienceJson] NVARCHAR(MAX) NULL,
        [SocialLinksJson] NVARCHAR(MAX) NULL,
        [PortfolioImagesJson] NVARCHAR(MAX) NULL
    );
    CREATE UNIQUE INDEX [IX_Users_Email] ON [Users]([Email]);
END;

IF OBJECT_ID(N'[Jobs]', N'U') IS NULL
BEGIN
    CREATE TABLE [Jobs](
        [Id]                   NVARCHAR(64)    NOT NULL PRIMARY KEY,
        [CompanyId]            INT             NOT NULL DEFAULT 0,
        [Title]                NVARCHAR(256)   NOT NULL,
        [CompanyName]          NVARCHAR(256)   NOT NULL,
        [Location]             NVARCHAR(128)   NOT NULL DEFAULT 'Remote',
        [SalaryRange]          NVARCHAR(128)   NOT NULL DEFAULT 'Negotiable',
        [Type]                 NVARCHAR(64)    NOT NULL DEFAULT 'Full-time',
        [Description]          NVARCHAR(MAX)   NOT NULL DEFAULT '',
        [ResponsibilitiesCsv]  NVARCHAR(MAX)   NOT NULL DEFAULT '',
        [QualificationsCsv]    NVARCHAR(MAX)   NOT NULL DEFAULT '',
        [NiceToHavesCsv]       NVARCHAR(MAX)   NOT NULL DEFAULT '',
        [BenefitsCsv]          NVARCHAR(MAX)   NOT NULL DEFAULT '',
        [Classification]       NVARCHAR(128)   NOT NULL DEFAULT '',
        [TagsCsv]              NVARCHAR(1000)  NOT NULL DEFAULT '',
        [CreatedAt]            DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
        [ApplicationCount]     INT             NOT NULL DEFAULT 0,
        [RequiredCount]        INT             NOT NULL DEFAULT 1,
        [AcceptedCount]        INT             NOT NULL DEFAULT 0,
        [Deadline]             DATETIME2       NULL,
        [Status]               NVARCHAR(64)    NOT NULL DEFAULT 'Open',
        [ViewsCount]           INT             NOT NULL DEFAULT 0
    );
END;

IF OBJECT_ID(N'[Applications]', N'U') IS NULL
BEGIN
    CREATE TABLE [Applications](
        [Id]        NVARCHAR(64)    NOT NULL PRIMARY KEY,
        [UserId]    INT             NOT NULL DEFAULT 0,
        [UserName]  NVARCHAR(128)   NOT NULL,
        [JobId]     NVARCHAR(64)    NOT NULL,
        [Status]    NVARCHAR(64)    NOT NULL DEFAULT 'Applied',
        [UpdatedAt] DATETIME2       NOT NULL DEFAULT GETUTCDATE()
    );
END;

IF OBJECT_ID(N'[Messages]', N'U') IS NULL
BEGIN
    CREATE TABLE [Messages](
        [Id]          NVARCHAR(64)    NOT NULL PRIMARY KEY,
        [FromCompany] BIT             NOT NULL DEFAULT 0,
        [Text]        NVARCHAR(2000)  NOT NULL,
        [CreatedAt]   DATETIME2       NOT NULL DEFAULT GETUTCDATE()
    );
END;

IF OBJECT_ID(N'[Notifications]', N'U') IS NULL
BEGIN
    CREATE TABLE [Notifications](
        [Id]        NVARCHAR(64)    NOT NULL PRIMARY KEY,
        [Type]      NVARCHAR(64)    NOT NULL,
        [Text]      NVARCHAR(2000)  NOT NULL,
        [CreatedAt] DATETIME2       NOT NULL DEFAULT GETUTCDATE()
    );
END;
""";

        await db.Database.ExecuteSqlRawAsync(createSql);

        // ─── 2. ALTER existing tables to add any missing columns ───────────
        const string alterSql = """
-- Users: add missing columns
IF COL_LENGTH('Users', 'GoogleId') IS NULL
    ALTER TABLE [Users] ADD [GoogleId] NVARCHAR(256) NULL;

IF COL_LENGTH('Users', 'PhotoUrl') IS NULL
    ALTER TABLE [Users] ADD [PhotoUrl] NVARCHAR(MAX) NULL;

IF COL_LENGTH('Users', 'PhotoUrl') IS NOT NULL
    ALTER TABLE [Users] ALTER COLUMN [PhotoUrl] NVARCHAR(MAX) NULL;

IF COL_LENGTH('Users', 'Password') IS NOT NULL
    ALTER TABLE [Users] ALTER COLUMN [Password] NVARCHAR(128) NULL;

-- Company Details for Users
IF COL_LENGTH('Users', 'About') IS NULL ALTER TABLE [Users] ADD [About] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'LocationHeadquarters') IS NULL ALTER TABLE [Users] ADD [LocationHeadquarters] NVARCHAR(256) NULL;
IF COL_LENGTH('Users', 'LocationsCsv') IS NULL ALTER TABLE [Users] ADD [LocationsCsv] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'BenefitsCsv') IS NULL ALTER TABLE [Users] ADD [BenefitsCsv] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'TechStackCsv') IS NULL ALTER TABLE [Users] ADD [TechStackCsv] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'FoundedDay') IS NULL ALTER TABLE [Users] ADD [FoundedDay] INT NOT NULL DEFAULT 0;
IF COL_LENGTH('Users', 'FoundedMonth') IS NULL ALTER TABLE [Users] ADD [FoundedMonth] INT NOT NULL DEFAULT 0;
IF COL_LENGTH('Users', 'FoundedYear') IS NULL ALTER TABLE [Users] ADD [FoundedYear] INT NOT NULL DEFAULT 0;
IF COL_LENGTH('Users', 'Website') IS NULL ALTER TABLE [Users] ADD [Website] NVARCHAR(256) NULL;
IF COL_LENGTH('Users', 'Industry') IS NULL ALTER TABLE [Users] ADD [Industry] NVARCHAR(128) NULL;
IF COL_LENGTH('Users', 'CommercialRegister') IS NULL ALTER TABLE [Users] ADD [CommercialRegister] NVARCHAR(128) NULL;
IF COL_LENGTH('Users', 'NationalNumber') IS NULL ALTER TABLE [Users] ADD [NationalNumber] NVARCHAR(128) NULL;
IF COL_LENGTH('Users', 'ContactsJson') IS NULL ALTER TABLE [Users] ADD [ContactsJson] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'Phone') IS NULL ALTER TABLE [Users] ADD [Phone] NVARCHAR(32) NULL;
IF COL_LENGTH('Users', 'Gender') IS NULL ALTER TABLE [Users] ADD [Gender] NVARCHAR(32) NULL;
IF COL_LENGTH('Users', 'Dob') IS NULL ALTER TABLE [Users] ADD [Dob] NVARCHAR(32) NULL;
IF COL_LENGTH('Users', 'Address') IS NULL ALTER TABLE [Users] ADD [Address] NVARCHAR(256) NULL;
IF COL_LENGTH('Users', 'Title') IS NULL ALTER TABLE [Users] ADD [Title] NVARCHAR(128) NULL;
IF COL_LENGTH('Users', 'SkillsCsv') IS NULL ALTER TABLE [Users] ADD [SkillsCsv] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'EducationJson') IS NULL ALTER TABLE [Users] ADD [EducationJson] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'ExperienceJson') IS NULL ALTER TABLE [Users] ADD [ExperienceJson] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'SocialLinksJson') IS NULL ALTER TABLE [Users] ADD [SocialLinksJson] NVARCHAR(MAX) NULL;
IF COL_LENGTH('Users', 'PortfolioImagesJson') IS NULL ALTER TABLE [Users] ADD [PortfolioImagesJson] NVARCHAR(MAX) NULL;

-- Rename Users.Classification to Staff if it exists (old name for employee count)
IF COL_LENGTH('Users', 'Classification') IS NOT NULL AND COL_LENGTH('Users', 'Staff') IS NULL
    EXEC sp_rename 'Users.Classification', 'Staff', 'COLUMN';
-- Handle case where it was already renamed to Stuff
IF COL_LENGTH('Users', 'Stuff') IS NOT NULL AND COL_LENGTH('Users', 'Staff') IS NULL
    EXEC sp_rename 'Users.Stuff', 'Staff', 'COLUMN';
IF COL_LENGTH('Users', 'Staff') IS NULL
    ALTER TABLE [Users] ADD [Staff] NVARCHAR(64) NULL;

-- Rename Users.Category to Classification if it exists (old name for tech/non-tech)
IF COL_LENGTH('Users', 'Category') IS NOT NULL AND COL_LENGTH('Users', 'Classification') IS NULL
    EXEC sp_rename 'Users.Category', 'Classification', 'COLUMN';
IF COL_LENGTH('Users', 'Classification') IS NULL
    ALTER TABLE [Users] ADD [Classification] NVARCHAR(128) NULL;

-- Jobs: add missing columns
IF COL_LENGTH('Jobs', 'ApplicationCount') IS NULL
    ALTER TABLE [Jobs] ADD [ApplicationCount] INT NOT NULL DEFAULT 0;

IF COL_LENGTH('Jobs', 'RequiredCount') IS NULL
    ALTER TABLE [Jobs] ADD [RequiredCount] INT NOT NULL DEFAULT 1;

IF COL_LENGTH('Jobs', 'AcceptedCount') IS NULL
    ALTER TABLE [Jobs] ADD [AcceptedCount] INT NOT NULL DEFAULT 0;

IF COL_LENGTH('Jobs', 'Description') IS NULL
    ALTER TABLE [Jobs] ADD [Description] NVARCHAR(MAX) NOT NULL DEFAULT '';

IF COL_LENGTH('Jobs', 'ResponsibilitiesCsv') IS NULL
    ALTER TABLE [Jobs] ADD [ResponsibilitiesCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

IF COL_LENGTH('Jobs', 'QualificationsCsv') IS NULL
    ALTER TABLE [Jobs] ADD [QualificationsCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

IF COL_LENGTH('Jobs', 'NiceToHavesCsv') IS NULL
    ALTER TABLE [Jobs] ADD [NiceToHavesCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

IF COL_LENGTH('Jobs', 'BenefitsCsv') IS NULL
    ALTER TABLE [Jobs] ADD [BenefitsCsv] NVARCHAR(MAX) NOT NULL DEFAULT '';

-- Rename Jobs.Category to Classification
IF COL_LENGTH('Jobs', 'Category') IS NOT NULL AND COL_LENGTH('Jobs', 'Classification') IS NULL
    EXEC sp_rename 'Jobs.Category', 'Classification', 'COLUMN';
IF COL_LENGTH('Jobs', 'Classification') IS NULL
    ALTER TABLE [Jobs] ADD [Classification] NVARCHAR(128) NOT NULL DEFAULT '';

IF COL_LENGTH('Jobs', 'Deadline') IS NULL
    ALTER TABLE [Jobs] ADD [Deadline] DATETIME2 NULL;

IF COL_LENGTH('Jobs', 'Status') IS NULL
    ALTER TABLE [Jobs] ADD [Status] NVARCHAR(64) NOT NULL DEFAULT 'Open';

IF COL_LENGTH('Jobs', 'ViewsCount') IS NULL
    ALTER TABLE [Jobs] ADD [ViewsCount] INT NOT NULL DEFAULT 0;
""";

        await db.Database.ExecuteSqlRawAsync(alterSql);
    }
}
