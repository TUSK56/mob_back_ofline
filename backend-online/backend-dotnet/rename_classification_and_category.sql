-- Renaming columns to match new requirements
-- Classification (Employee Count) -> Stuff
-- Category (Technical/Non-Technical) -> Classification

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = 'Classification')
BEGIN
    EXEC sp_rename 'Users.Classification', 'Stuff', 'COLUMN';
    PRINT 'Renamed [Users].[Classification] to [Stuff].';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Users]') AND name = 'Category')
BEGIN
    EXEC sp_rename 'Users.Category', 'Classification', 'COLUMN';
    PRINT 'Renamed [Users].[Category] to [Classification].';
END
