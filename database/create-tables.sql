-- Script untuk membuat database dan tabel EquipmentImages
-- Jalankan script ini di SQL Server Management Studio atau Azure Data Studio

-- 1. Buat database (jika belum ada)
-- CREATE DATABASE EquipmentManagement;
-- GO

-- 2. Gunakan database
-- USE EquipmentManagement;
-- GO

-- 3. Buat tabel EquipmentImages
CREATE TABLE EquipmentImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Equipment NVARCHAR(50) NOT NULL,
    ImageFront NVARCHAR(MAX) NULL,
    ImageBehind NVARCHAR(MAX) NULL,
    ImageKanan NVARCHAR(MAX) NULL,
    ImageLeft NVARCHAR(MAX) NULL,
    LastUpdate DATETIME2 DEFAULT GETDATE(),
    UpdateBy NVARCHAR(50) NOT NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    
    -- Index untuk performa
    INDEX IX_Equipment (Equipment),
    INDEX IX_LastUpdate (LastUpdate)
);

-- 4. Insert sample data
INSERT INTO EquipmentImages (Equipment, UpdateBy) VALUES
('Excavator CAT 320D', 'admin'),
('Bulldozer Komatsu D65', 'operator'),
('Crane Liebherr LTM 1050', 'user1');

-- 5. Stored Procedures untuk CRUD operations

-- Get all equipments
CREATE PROCEDURE sp_GetAllEquipments
AS
BEGIN
    SELECT 
        Id,
        Equipment,
        ImageFront,
        ImageBehind,
        ImageKanan,
        ImageLeft,
        LastUpdate,
        UpdateBy,
        -- Count non-empty images
        (CASE WHEN ImageFront IS NOT NULL AND ImageFront != '' THEN 1 ELSE 0 END +
         CASE WHEN ImageBehind IS NOT NULL AND ImageBehind != '' THEN 1 ELSE 0 END +
         CASE WHEN ImageKanan IS NOT NULL AND ImageKanan != '' THEN 1 ELSE 0 END +
         CASE WHEN ImageLeft IS NOT NULL AND ImageLeft != '' THEN 1 ELSE 0 END) as ImageCount
    FROM EquipmentImages
    ORDER BY LastUpdate DESC;
END;

-- Get equipment by ID
CREATE PROCEDURE sp_GetEquipmentById
    @Id INT
AS
BEGIN
    SELECT 
        Id,
        Equipment,
        ImageFront,
        ImageBehind,
        ImageKanan,
        ImageLeft,
        LastUpdate,
        UpdateBy
    FROM EquipmentImages
    WHERE Id = @Id;
END;

-- Add new equipment
CREATE PROCEDURE sp_AddEquipment
    @Equipment NVARCHAR(50),
    @ImageFront NVARCHAR(MAX) = NULL,
    @ImageBehind NVARCHAR(MAX) = NULL,
    @ImageKanan NVARCHAR(MAX) = NULL,
    @ImageLeft NVARCHAR(MAX) = NULL,
    @UpdateBy NVARCHAR(50)
AS
BEGIN
    -- Check if equipment already exists
    IF EXISTS (SELECT 1 FROM EquipmentImages WHERE Equipment = @Equipment)
    BEGIN
        RAISERROR('Equipment already exists', 16, 1);
        RETURN;
    END
    
    INSERT INTO EquipmentImages (Equipment, ImageFront, ImageBehind, ImageKanan, ImageLeft, UpdateBy)
    VALUES (@Equipment, @ImageFront, @ImageBehind, @ImageKanan, @ImageLeft, @UpdateBy);
    
    SELECT SCOPE_IDENTITY() as NewId;
END;

-- Update equipment
CREATE PROCEDURE sp_UpdateEquipment
    @Id INT,
    @ImageFront NVARCHAR(MAX) = NULL,
    @ImageBehind NVARCHAR(MAX) = NULL,
    @ImageKanan NVARCHAR(MAX) = NULL,
    @ImageLeft NVARCHAR(MAX) = NULL,
    @UpdateBy NVARCHAR(50)
AS
BEGIN
    UPDATE EquipmentImages 
    SET 
        ImageFront = COALESCE(@ImageFront, ImageFront),
        ImageBehind = COALESCE(@ImageBehind, ImageBehind),
        ImageKanan = COALESCE(@ImageKanan, ImageKanan),
        ImageLeft = COALESCE(@ImageLeft, ImageLeft),
        LastUpdate = GETDATE(),
        UpdateBy = @UpdateBy
    WHERE Id = @Id;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Equipment not found', 16, 1);
    END
END;

PRINT 'Database setup completed successfully!';
