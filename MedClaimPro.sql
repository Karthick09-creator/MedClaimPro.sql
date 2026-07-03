CREATE DATABASE MedClaimPro;
GO
USE MedClaimPro;
GO


CREATE TABLE Patients (
    PatientID       INT PRIMARY KEY IDENTITY(1,1),
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    DOB             DATE         NOT NULL,
    Gender          CHAR(1)      CHECK (Gender IN ('M','F','O')),
    InsuranceID     VARCHAR(30)  UNIQUE,
    Phone           VARCHAR(15),
    Address         VARCHAR(200),
    CreatedDate     DATETIME     DEFAULT GETDATE()
);


CREATE TABLE Payers (
    PayerID         INT PRIMARY KEY IDENTITY(1,1),
    PayerName       VARCHAR(100) NOT NULL,
    PayerType       VARCHAR(50)  CHECK (PayerType IN ('Medicare','Medicaid','Commercial','Self-Pay')),
    ContactNumber   VARCHAR(15),
    ContractRate    DECIMAL(5,2)  
);


CREATE TABLE Providers (
    ProviderID      INT PRIMARY KEY IDENTITY(1,1),
    ProviderName    VARCHAR(100) NOT NULL,
    NPI             VARCHAR(20)  UNIQUE NOT NULL,  
    Specialty       VARCHAR(100),
    Facility        VARCHAR(100)
);


CREATE TABLE CPTCodes (
    CPTID           INT PRIMARY KEY IDENTITY(1,1),
    CPTCode         VARCHAR(10)  UNIQUE NOT NULL,
    Description     VARCHAR(200),
    StandardCharge  DECIMAL(10,2) NOT NULL
);


CREATE TABLE ICDCodes (
    ICDID           INT PRIMARY KEY IDENTITY(1,1),
    ICDCode         VARCHAR(15)  UNIQUE NOT NULL,
    Description     VARCHAR(200) NOT NULL,
    Category        VARCHAR(100)
);


CREATE TABLE Claims (
    ClaimID         INT PRIMARY KEY IDENTITY(1,1),
    PatientID       INT          NOT NULL REFERENCES Patients(PatientID),
    PayerID         INT          NOT NULL REFERENCES Payers(PayerID),
    ProviderID      INT          NOT NULL REFERENCES Providers(ProviderID),
    CPTID           INT          NOT NULL REFERENCES CPTCodes(CPTID),
    ICDID           INT          NOT NULL REFERENCES ICDCodes(ICDID),
    ServiceDate     DATE         NOT NULL,
    SubmittedDate   DATE,
    TotalCharge     DECIMAL(10,2) NOT NULL,
    AllowedAmount   DECIMAL(10,2),
    PaidAmount      DECIMAL(10,2) DEFAULT 0,
    ClaimStatus     VARCHAR(30)  CHECK (ClaimStatus IN 
                        ('Submitted','Pending','Paid','Denied','Partial','Appealed','Closed')),
    DenialReason    VARCHAR(200),
    CreatedDate     DATETIME     DEFAULT GETDATE()
);


CREATE TABLE ARFollowUpLog (
    LogID           INT PRIMARY KEY IDENTITY(1,1),
    ClaimID         INT          NOT NULL REFERENCES Claims(ClaimID),
    FollowUpDate    DATE         NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CallerName      VARCHAR(100),
    ActionTaken     VARCHAR(300),
    NextFollowUpDate DATE,
    Remarks         VARCHAR(500)
);


CREATE TABLE Payments (
    PaymentID       INT PRIMARY KEY IDENTITY(1,1),
    ClaimID         INT          NOT NULL REFERENCES Claims(ClaimID),
    PaymentDate     DATE         NOT NULL,
    PaymentAmount   DECIMAL(10,2) NOT NULL,
    PaymentMode     VARCHAR(50)  CHECK (PaymentMode IN ('EFT','Check','Credit Card','Cash')),
    ERA_Number      VARCHAR(50),   
    PostedBy        VARCHAR(100),
    PostedDate      DATETIME     DEFAULT GETDATE()
);


CREATE TABLE ClaimAuditLog (
    AuditID         INT PRIMARY KEY IDENTITY(1,1),
    ClaimID         INT,
    OldStatus       VARCHAR(30),
    NewStatus       VARCHAR(30),
    ChangedBy       VARCHAR(100) DEFAULT SYSTEM_USER,
    ChangedOn       DATETIME     DEFAULT GETDATE(),
    Remarks         VARCHAR(300)
);
GO



INSERT INTO Payers (PayerName, PayerType, ContactNumber, ContractRate) VALUES
('Medicare Part B',     'Medicare',    '1-800-633-4227', 80.00),
('UnitedHealthCare',    'Commercial',  '1-866-270-5588', 75.00),
('Aetna',               'Commercial',  '1-800-872-3862', 72.00),
('BlueCross BlueShield','Commercial',  '1-800-521-2227', 78.00),
('Medicaid TN',         'Medicaid',    '1-800-342-3145', 65.00);

INSERT INTO Providers (ProviderName, NPI, Specialty, Facility) VALUES
('Dr. Anand Raj',       '1234567890', 'Internal Medicine',   'City Health Clinic'),
('Dr. Priya Nair',      '0987654321', 'Cardiology',          'Heart Care Center'),
('Dr. Samuel George',   '1122334455', 'Orthopedics',         'Bone & Joint Hospital');

INSERT INTO CPTCodes (CPTCode, Description, StandardCharge) VALUES
('99213', 'Office Visit – Established Patient (Level 3)',   150.00),
('99214', 'Office Visit – Established Patient (Level 4)',   200.00),
('93000', 'Electrocardiogram (ECG) with Interpretation',    125.00),
('27447', 'Total Knee Replacement',                        8500.00),
('71046', 'Chest X-Ray – 2 Views',                          110.00);

INSERT INTO ICDCodes (ICDCode, Description, Category) VALUES
('J18.9',  'Pneumonia, Unspecified',              'Respiratory'),
('I10',    'Essential Hypertension',              'Cardiovascular'),
('M17.11', 'Primary Osteoarthritis, Right Knee',  'Musculoskeletal'),
('E11.9',  'Type 2 Diabetes without Complication','Endocrine'),
('Z12.31', 'Encounter for Screening for Lung Cancer','Preventive');

INSERT INTO Patients (FirstName, LastName, DOB, Gender, InsuranceID, Phone, Address) VALUES
('Ramesh',   'Kumar',    '1965-04-12', 'M', 'MCR-001-2024', '9876543210', 'Chennai, TN'),
('Lakshmi',  'Devi',     '1978-09-25', 'F', 'UCH-002-2024', '9845612300', 'Coimbatore, TN'),
('John',     'Stephen',  '1952-01-08', 'M', 'AET-003-2024', '9901122334', 'Madurai, TN'),
('Meena',    'Selvam',   '1990-07-30', 'F', 'BCB-004-2024', '9988776655', 'Salem, TN'),
('Vijay',    'Raj',      '1983-11-15', 'M', 'MCD-005-2024', '9765432198', 'Trichy, TN');

INSERT INTO Claims 
  (PatientID, PayerID, ProviderID, CPTID, ICDID, ServiceDate, SubmittedDate, TotalCharge, AllowedAmount, PaidAmount, ClaimStatus) 
VALUES
(1, 1, 1, 1, 1, '2024-01-10', '2024-01-12',  150.00, 120.00,  120.00, 'Paid'),
(2, 2, 2, 3, 2, '2024-01-15', '2024-01-17',  125.00, 100.00,    0.00, 'Denied'),
(3, 3, 3, 4, 3, '2024-02-05', '2024-02-07', 8500.00,7000.00, 5000.00, 'Partial'),
(4, 4, 1, 2, 4, '2024-02-20', '2024-02-22',  200.00, 160.00,  160.00, 'Paid'),
(5, 5, 1, 5, 5, '2024-03-01', '2024-03-03',  110.00,  75.00,    0.00, 'Pending'),
(1, 1, 2, 3, 2, '2024-03-10', '2024-03-12',  125.00, 100.00,    0.00, 'Appealed'),
(2, 2, 1, 1, 4, '2024-03-18', '2024-03-20',  150.00, 110.00,   55.00, 'Partial');

UPDATE Claims SET DenialReason = 'Service not covered under plan' WHERE ClaimID = 2;

INSERT INTO ARFollowUpLog (ClaimID, FollowUpDate, CallerName, ActionTaken, NextFollowUpDate, Remarks) VALUES
(2, '2024-01-25', 'Karthick', 'Called UnitedHealthCare IVR – Claim denied. Reason: not covered. Initiating appeal.', '2024-02-01', 'Need clinical notes from provider'),
(3, '2024-02-20', 'Karthick', 'Spoke to Aetna rep – partial payment processed. Balance pending COB.', '2024-02-28', 'COB secondary payer follow-up needed'),
(5, '2024-03-15', 'Karthick', 'Claim in processing queue. Rep confirmed 30-day adjudication window.', '2024-03-30', 'Follow up if no ERA received'),
(6, '2024-03-25', 'Karthick', 'Appeal submitted with medical records. Tracking reference #AP-9921.', '2024-04-10', 'Awaiting appeal decision');

INSERT INTO Payments (ClaimID, PaymentDate, PaymentAmount, PaymentMode, ERA_Number, PostedBy) VALUES
(1, '2024-01-20', 120.00, 'EFT',   'ERA-2024-001', 'Karthick'),
(3, '2024-03-01',5000.00, 'Check', 'ERA-2024-002', 'Karthick'),
(4, '2024-03-05', 160.00, 'EFT',   'ERA-2024-003', 'Karthick'),
(7, '2024-04-01',  55.00, 'EFT',   'ERA-2024-004', 'Karthick');
GO


CREATE VIEW vw_ClaimsDashboard AS
SELECT
    c.ClaimID,
    p.FirstName + ' ' + p.LastName  AS PatientName,
    py.PayerName,
    py.PayerType,
    pr.ProviderName,
    pr.Specialty,
    cpt.CPTCode,
    cpt.Description                  AS ProcedureDescription,
    icd.ICDCode,
    icd.Description                  AS DiagnosisDescription,
    c.ServiceDate,
    c.SubmittedDate,
    c.TotalCharge,
    c.AllowedAmount,
    c.PaidAmount,
    c.TotalCharge - c.PaidAmount     AS BalanceDue,
    c.ClaimStatus,
    c.DenialReason
FROM Claims c
INNER JOIN Patients  p   ON c.PatientID  = p.PatientID
INNER JOIN Payers    py  ON c.PayerID    = py.PayerID
INNER JOIN Providers pr  ON c.ProviderID = pr.ProviderID
INNER JOIN CPTCodes  cpt ON c.CPTID      = cpt.CPTID
INNER JOIN ICDCodes  icd ON c.ICDID      = icd.ICDID;
GO


CREATE VIEW vw_ARAgingReport AS
SELECT
    c.ClaimID,
    p.FirstName + ' ' + p.LastName  AS PatientName,
    py.PayerName,
    c.TotalCharge,
    c.PaidAmount,
    c.TotalCharge - c.PaidAmount     AS BalanceDue,
    c.SubmittedDate,
    DATEDIFF(DAY, c.SubmittedDate, GETDATE()) AS AgeDays,
    CASE
        WHEN DATEDIFF(DAY, c.SubmittedDate, GETDATE()) <= 30  THEN '0-30 Days'
        WHEN DATEDIFF(DAY, c.SubmittedDate, GETDATE()) <= 60  THEN '31-60 Days'
        WHEN DATEDIFF(DAY, c.SubmittedDate, GETDATE()) <= 90  THEN '61-90 Days'
        WHEN DATEDIFF(DAY, c.SubmittedDate, GETDATE()) <= 120 THEN '91-120 Days'
        ELSE '120+ Days (Critical)'
    END AS AgingBucket,
    c.ClaimStatus
FROM Claims c
INNER JOIN Patients p  ON c.PatientID = p.PatientID
INNER JOIN Payers   py ON c.PayerID   = py.PayerID
WHERE c.ClaimStatus NOT IN ('Paid', 'Closed');
GO


CREATE VIEW vw_DenialAnalysis AS
SELECT
    py.PayerName,
    py.PayerType,
    c.DenialReason,
    COUNT(c.ClaimID)             AS TotalDenials,
    SUM(c.TotalCharge)           AS TotalDeniedAmount,
    AVG(c.TotalCharge)           AS AvgDeniedAmount
FROM Claims c
INNER JOIN Payers py ON c.PayerID = py.PayerID
WHERE c.ClaimStatus IN ('Denied', 'Appealed')
GROUP BY py.PayerName, py.PayerType, c.DenialReason;
GO


CREATE FUNCTION fn_GetClaimBalance (@ClaimID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Balance DECIMAL(10,2);
    SELECT @Balance = TotalCharge - PaidAmount
    FROM Claims
    WHERE ClaimID = @ClaimID;
    RETURN ISNULL(@Balance, 0);
END;
GO


CREATE FUNCTION fn_GetAgingBucket (@SubmittedDate DATE)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE @Days INT = DATEDIFF(DAY, @SubmittedDate, GETDATE());
    RETURN
        CASE
            WHEN @Days <= 30  THEN '0-30 Days'
            WHEN @Days <= 60  THEN '31-60 Days'
            WHEN @Days <= 90  THEN '61-90 Days'
            WHEN @Days <= 120 THEN '91-120 Days'
            ELSE '120+ Days'
        END;
END;
GO


CREATE FUNCTION fn_GetPatientClaims (@PatientID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.ClaimID,
        cpt.CPTCode,
        cpt.Description  AS Procedure,
        c.ServiceDate,
        c.TotalCharge,
        c.PaidAmount,
        c.TotalCharge - c.PaidAmount AS Balance,
        c.ClaimStatus
    FROM Claims c
    INNER JOIN CPTCodes cpt ON c.CPTID = cpt.CPTID
    WHERE c.PatientID = @PatientID
);
GO



CREATE PROCEDURE sp_SubmitClaim
    @PatientID    INT,
    @PayerID      INT,
    @ProviderID   INT,
    @CPTID        INT,
    @ICDID        INT,
    @ServiceDate  DATE,
    @TotalCharge  DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Claims
            (PatientID, PayerID, ProviderID, CPTID, ICDID, ServiceDate, SubmittedDate, TotalCharge, ClaimStatus)
        VALUES
            (@PatientID, @PayerID, @ProviderID, @CPTID, @ICDID, @ServiceDate, CAST(GETDATE() AS DATE), @TotalCharge, 'Submitted');

        PRINT 'Claim submitted successfully. ClaimID: ' + CAST(SCOPE_IDENTITY() AS VARCHAR);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


CREATE PROCEDURE sp_PostPayment
    @ClaimID       INT,
    @PaymentAmount DECIMAL(10,2),
    @PaymentMode   VARCHAR(50),
    @ERA_Number    VARCHAR(50),
    @PostedBy      VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TotalCharge DECIMAL(10,2), @AlreadyPaid DECIMAL(10,2);

        SELECT @TotalCharge = TotalCharge, @AlreadyPaid = PaidAmount
        FROM Claims WHERE ClaimID = @ClaimID;

        IF @AlreadyPaid + @PaymentAmount > @TotalCharge
        BEGIN
            RAISERROR('Payment exceeds total charge. Possible overpayment.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO Payments (ClaimID, PaymentDate, PaymentAmount, PaymentMode, ERA_Number, PostedBy)
        VALUES (@ClaimID, CAST(GETDATE() AS DATE), @PaymentAmount, @PaymentMode, @ERA_Number, @PostedBy);

        UPDATE Claims
        SET PaidAmount  = PaidAmount + @PaymentAmount,
            ClaimStatus = CASE
                              WHEN PaidAmount + @PaymentAmount >= TotalCharge THEN 'Paid'
                              ELSE 'Partial'
                          END
        WHERE ClaimID = @ClaimID;

        PRINT 'Payment posted successfully for ClaimID: ' + CAST(@ClaimID AS VARCHAR);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


CREATE PROCEDURE sp_UpdateClaimStatus
    @ClaimID       INT,
    @NewStatus     VARCHAR(30),
    @DenialReason  VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Claims
    SET ClaimStatus  = @NewStatus,
        DenialReason = CASE WHEN @NewStatus IN ('Denied','Appealed') THEN @DenialReason ELSE DenialReason END
    WHERE ClaimID = @ClaimID;

    PRINT 'Claim ' + CAST(@ClaimID AS VARCHAR) + ' status updated to ' + @NewStatus;
END;
GO


CREATE PROCEDURE sp_ARAgingByPayer
    @PayerID INT = NULL    
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        py.PayerName,
        SUM(CASE WHEN DATEDIFF(DAY,c.SubmittedDate,GETDATE()) <= 30
                 THEN c.TotalCharge - c.PaidAmount ELSE 0 END) AS [0-30],
        SUM(CASE WHEN DATEDIFF(DAY,c.SubmittedDate,GETDATE()) BETWEEN 31 AND 60
                 THEN c.TotalCharge - c.PaidAmount ELSE 0 END) AS [31-60],
        SUM(CASE WHEN DATEDIFF(DAY,c.SubmittedDate,GETDATE()) BETWEEN 61 AND 90
                 THEN c.TotalCharge - c.PaidAmount ELSE 0 END) AS [61-90],
        SUM(CASE WHEN DATEDIFF(DAY,c.SubmittedDate,GETDATE()) BETWEEN 91 AND 120
                 THEN c.TotalCharge - c.PaidAmount ELSE 0 END) AS [91-120],
        SUM(CASE WHEN DATEDIFF(DAY,c.SubmittedDate,GETDATE()) > 120
                 THEN c.TotalCharge - c.PaidAmount ELSE 0 END) AS [120+],
        SUM(c.TotalCharge - c.PaidAmount)                       AS TotalOutstanding
    FROM Claims c
    INNER JOIN Payers py ON c.PayerID = py.PayerID
    WHERE c.ClaimStatus NOT IN ('Paid','Closed')
      AND (@PayerID IS NULL OR c.PayerID = @PayerID)
    GROUP BY py.PayerName
    ORDER BY TotalOutstanding DESC;
END;
GO


CREATE PROCEDURE sp_AddFollowUp
    @ClaimID         INT,
    @CallerName      VARCHAR(100),
    @ActionTaken     VARCHAR(300),
    @NextFollowUpDate DATE,
    @Remarks         VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ARFollowUpLog (ClaimID, FollowUpDate, CallerName, ActionTaken, NextFollowUpDate, Remarks)
    VALUES (@ClaimID, CAST(GETDATE() AS DATE), @CallerName, @ActionTaken, @NextFollowUpDate, @Remarks);
    PRINT 'Follow-up logged for ClaimID: ' + CAST(@ClaimID AS VARCHAR);
END;
GO

CREATE TRIGGER trg_ClaimStatusAudit
ON Claims
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(ClaimStatus)
    BEGIN
        INSERT INTO ClaimAuditLog (ClaimID, OldStatus, NewStatus, Remarks)
        SELECT
            d.ClaimID,
            d.ClaimStatus,
            i.ClaimStatus,
            'Status changed from ' + d.ClaimStatus + ' to ' + i.ClaimStatus
        FROM deleted d
        INNER JOIN inserted i ON d.ClaimID = i.ClaimID
        WHERE d.ClaimStatus <> i.ClaimStatus;
    END
END;
GO


CREATE TRIGGER trg_PreventClaimDelete
ON Claims
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM Payments p
        INNER JOIN deleted d ON p.ClaimID = d.ClaimID
    )
    BEGIN
        RAISERROR('Cannot delete claim with existing payment records. Close the claim instead.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Claims WHERE ClaimID IN (SELECT ClaimID FROM deleted);
        PRINT 'Claim deleted successfully.';
    END
END;
GO


CREATE TRIGGER trg_SetSubmittedDate
ON Claims
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE c
    SET c.SubmittedDate = CAST(GETDATE() AS DATE)
    FROM Claims c
    INNER JOIN inserted i ON c.ClaimID = i.ClaimID
    INNER JOIN deleted  d ON c.ClaimID = d.ClaimID
    WHERE i.ClaimStatus = 'Submitted'
      AND d.ClaimStatus <> 'Submitted'
      AND c.SubmittedDate IS NULL;
END;
GO

CREATE ROLE BillingStaff;
CREATE ROLE ARCallers;
CREATE ROLE BillingManager;
GO


GRANT SELECT ON Claims         TO ARCallers;
GRANT SELECT ON Patients       TO ARCallers;
GRANT SELECT ON Payers         TO ARCallers;
GRANT INSERT ON ARFollowUpLog  TO ARCallers;
GRANT EXECUTE ON sp_AddFollowUp TO ARCallers;
GRANT EXECUTE ON sp_UpdateClaimStatus TO ARCallers;


GRANT SELECT, INSERT ON Claims   TO BillingStaff;
GRANT INSERT ON Payments         TO BillingStaff;
GRANT EXECUTE ON sp_SubmitClaim  TO BillingStaff;
GRANT EXECUTE ON sp_PostPayment  TO BillingStaff;


GRANT SELECT ON SCHEMA::dbo     TO BillingManager;
GRANT EXECUTE ON sp_ARAgingByPayer TO BillingManager;


DENY DELETE ON Claims TO BillingStaff;
DENY DELETE ON Claims TO ARCallers;
GO


SELECT
    py.PayerName,
    py.PayerType,
    COUNT(c.ClaimID)                                      AS TotalClaims,
    SUM(c.TotalCharge)                                    AS TotalBilled,
    SUM(c.PaidAmount)                                     AS TotalCollected,
    SUM(c.TotalCharge) - SUM(c.PaidAmount)                AS TotalOutstanding,
    ROUND(SUM(c.PaidAmount) * 100.0 / SUM(c.TotalCharge), 2) AS CollectionRate_Pct
FROM Claims c
INNER JOIN Payers py ON c.PayerID = py.PayerID
GROUP BY py.PayerName, py.PayerType
ORDER BY TotalBilled DESC;


SELECT
    py.PayerName,
    COUNT(c.ClaimID)                                          AS TotalClaims,
    SUM(CASE WHEN c.ClaimStatus = 'Denied' THEN 1 ELSE 0 END) AS DeniedClaims,
    ROUND(SUM(CASE WHEN c.ClaimStatus = 'Denied' THEN 1 ELSE 0 END) * 100.0
          / COUNT(c.ClaimID), 2)                               AS DenialRate_Pct
FROM Claims c
INNER JOIN Payers py ON c.PayerID = py.PayerID
GROUP BY py.PayerName
HAVING COUNT(c.ClaimID) > 0
ORDER BY DenialRate_Pct DESC;


SELECT
    cpt.CPTCode,
    cpt.Description,
    COUNT(c.ClaimID)    AS TimesBilled,
    SUM(c.TotalCharge)  AS TotalCharged,
    SUM(c.PaidAmount)   AS TotalPaid
FROM Claims c
INNER JOIN CPTCodes cpt ON c.CPTID = cpt.CPTID
GROUP BY cpt.CPTCode, cpt.Description
ORDER BY TotalCharged DESC;


SELECT
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    COUNT(c.ClaimID)               AS TotalClaims,
    SUM(dbo.fn_GetClaimBalance(c.ClaimID)) AS TotalBalance
FROM Patients p
INNER JOIN Claims c ON p.PatientID = c.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName
HAVING SUM(dbo.fn_GetClaimBalance(c.ClaimID)) > 0
ORDER BY TotalBalance DESC;


SELECT
    c.ClaimID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    py.PayerName,
    c.ClaimStatus,
    c.SubmittedDate
FROM Claims c
INNER JOIN Patients p  ON c.PatientID = p.PatientID
INNER JOIN Payers   py ON c.PayerID   = py.PayerID
LEFT JOIN  ARFollowUpLog ar ON c.ClaimID = ar.ClaimID
WHERE ar.LogID IS NULL
  AND c.ClaimStatus NOT IN ('Paid', 'Closed');


SELECT * FROM vw_ARAgingReport ORDER BY AgeDays DESC;


SELECT * FROM vw_ClaimsDashboard ORDER BY ServiceDate DESC;


SELECT
    YEAR(c.ServiceDate)  AS ServiceYear,
    MONTH(c.ServiceDate) AS ServiceMonth,
    DATENAME(MONTH, c.ServiceDate) AS MonthName,
    COUNT(c.ClaimID)     AS ClaimsCount,
    SUM(c.TotalCharge)   AS TotalBilled,
    SUM(c.PaidAmount)    AS TotalCollected
FROM Claims c
GROUP BY YEAR(c.ServiceDate), MONTH(c.ServiceDate), DATENAME(MONTH, c.ServiceDate)
ORDER BY ServiceYear, ServiceMonth;


SELECT
    pr.ProviderName,
    pr.Specialty,
    COUNT(c.ClaimID)    AS TotalClaims,
    SUM(c.TotalCharge)  AS TotalCharged,
    SUM(c.PaidAmount)   AS TotalPaid,
    ROUND(AVG(DATEDIFF(DAY, c.SubmittedDate, GETDATE())), 0) AS AvgDaysInAR
FROM Claims c
INNER JOIN Providers pr ON c.ProviderID = pr.ProviderID
GROUP BY pr.ProviderName, pr.Specialty
ORDER BY TotalCharged DESC;

    
SELECT
    a.AuditID,
    a.ClaimID,
    a.OldStatus,
    a.NewStatus,
    a.ChangedBy,
    a.ChangedOn,
    a.Remarks
FROM ClaimAuditLog a
ORDER BY a.ChangedOn DESC;
GO


EXEC sp_SubmitClaim
    @PatientID   = 3,
    @PayerID     = 3,
    @ProviderID  = 2,
    @CPTID       = 2,
    @ICDID       = 2,
    @ServiceDate = '2024-04-10',
    @TotalCharge = 200.00;


EXEC sp_PostPayment
    @ClaimID       = 5,
    @PaymentAmount = 75.00,
    @PaymentMode   = 'EFT',
    @ERA_Number    = 'ERA-2024-005',
    @PostedBy      = 'Karthick';


EXEC sp_UpdateClaimStatus
    @ClaimID      = 5,
    @NewStatus    = 'Denied',
    @DenialReason = 'Non-covered preventive service – plan year limit reached';

    
EXEC sp_AddFollowUp
    @ClaimID          = 5,
    @CallerName       = 'Karthick',
    @ActionTaken      = 'Spoke to Medicaid rep. Denial confirmed. Evaluating appeal eligibility.',
    @NextFollowUpDate = '2024-04-20',
    @Remarks          = 'Appeal deadline is 30 days from denial date';


EXEC sp_ARAgingByPayer;


EXEC sp_ARAgingByPayer @PayerID = 1;

SELECT * FROM dbo.fn_GetPatientClaims(1);
ś

SELECT dbo.fn_GetClaimBalance(3) AS OutstandingBalance;
SELECT dbo.fn_GetAgingBucket('2024-01-12') AS AgingBucket;
GO


