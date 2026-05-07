-- =====================================================================
--  Jobito - Add Company Details to Users Table
-- =====================================================================

IF OBJECT_ID(N'[Users]', N'U') IS NOT NULL
BEGIN
    PRINT 'Adding company columns to [Users] table...';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'About')
        ALTER TABLE [Users] ADD [About] NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Classification')
        ALTER TABLE [Users] ADD [Classification] NVARCHAR(64) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'LocationHeadquarters')
        ALTER TABLE [Users] ADD [LocationHeadquarters] NVARCHAR(256) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'LocationsCsv')
        ALTER TABLE [Users] ADD [LocationsCsv] NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = N'Category')
        ALTER TABLE [Users] ADD [Category] NVARCHAR(128) NULL;

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

    PRINT 'Company columns added successfully.';
END
GO
