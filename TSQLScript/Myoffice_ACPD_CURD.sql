CREATE PROCEDURE [dbo].[usp_Myoffice_ACPD_CRUD]
    @Action NVARCHAR(10),    -- 指定操作類型：INSERT/UPDATE/DELETE/SELECT
    @JsonData NVARCHAR(MAX)  -- 接收 JSON 格式的資料
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @SID NVARCHAR(20);

	IF @Action = 'INSERT'
    BEGIN
        -- 新增資料
        -- 調用 NEWSID 生成唯一的 ACPD_SID
        EXEC [dbo].[NEWSID] 
            @TableName = 'MyOffice_ACPD',
            @ReturnSID = @SID OUTPUT;


        INSERT INTO [dbo].[MyOffice_ACPD] (
            ACPD_SID, ACPD_Cname, ACPD_Ename, ACPD_Sname, ACPD_Email, 
            ACPD_Status, ACPD_Stop, ACPD_StopMemo, ACPD_LoginID, ACPD_LoginPWD,
            ACPD_Memo, ACPD_NowDateTime, ACPD_NowID, ACPD_UPDDateTime, ACPD_UPDID
        )
        SELECT
            @SID, 
            j.ACPD_Cname, j.ACPD_Ename, j.ACPD_Sname, j.ACPD_Email, 
            j.ACPD_Status, j.ACPD_Stop, j.ACPD_StopMemo, j.ACPD_LoginID, j.ACPD_LoginPWD,
            j.ACPD_Memo, GETDATE(), j.ACPD_NowID, NULL, NULL
        FROM OPENJSON(@JsonData)
        WITH (
            ACPD_SID CHAR(20),
            ACPD_Cname NVARCHAR(60),
            ACPD_Ename NVARCHAR(40),
            ACPD_Sname NVARCHAR(40),
            ACPD_Email NVARCHAR(60),
            ACPD_Status TINYINT,
            ACPD_Stop BIT,
            ACPD_StopMemo NVARCHAR(60),
            ACPD_LoginID NVARCHAR(30),
            ACPD_LoginPWD NVARCHAR(60),
            ACPD_Memo NVARCHAR(600),
            ACPD_NowDateTime DATETIME,
            ACPD_NowID NVARCHAR(20),
            ACPD_UPDDateTime DATETIME,
            ACPD_UPDID NVARCHAR(20)
        ) AS j;

    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        -- 更新資料
        UPDATE [dbo].[MyOffice_ACPD]
        SET
            ACPD_Cname = j.ACPD_Cname,
            ACPD_Ename = j.ACPD_Ename,
            ACPD_Sname = j.ACPD_Sname,
            ACPD_Email = j.ACPD_Email,
            ACPD_Status = j.ACPD_Status,
            ACPD_Stop = j.ACPD_Stop,
            ACPD_StopMemo = j.ACPD_StopMemo,
            ACPD_LoginID = j.ACPD_LoginID,
            ACPD_LoginPWD = j.ACPD_LoginPWD,
            ACPD_Memo = j.ACPD_Memo,
            ACPD_UPDDateTime = GETDATE(),
            ACPD_UPDID = j.ACPD_UPDID
        FROM OPENJSON(@JsonData)
        WITH (
            ACPD_SID NVARCHAR(20),
            ACPD_Cname NVARCHAR(60),
            ACPD_Ename NVARCHAR(40),
            ACPD_Sname NVARCHAR(40),
            ACPD_Email NVARCHAR(60),
            ACPD_Status TINYINT,
            ACPD_Stop BIT,
            ACPD_StopMemo NVARCHAR(60),
            ACPD_LoginID NVARCHAR(30),
            ACPD_LoginPWD NVARCHAR(60),
            ACPD_Memo NVARCHAR(600),
            ACPD_UPDID NVARCHAR(20)
        ) AS j
        WHERE [MyOffice_ACPD].ACPD_SID = j.ACPD_SID;

        SET @SID = (SELECT ACPD_SID FROM OPENJSON(@JsonData) WITH (ACPD_SID NVARCHAR(20)) AS j);
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        -- 刪除資料

        DELETE FROM [dbo].[MyOffice_ACPD]
        WHERE ACPD_SID IN (
            SELECT ACPD_SID
            FROM OPENJSON(@JsonData)
            WITH (ACPD_SID NVARCHAR(20))
        );

        SET @SID = (SELECT ACPD_SID FROM OPENJSON(@JsonData) WITH (ACPD_SID NVARCHAR(20)) AS j);
    END
    ELSE IF @Action = 'SELECT'
    BEGIN
        -- 查詢資料並返回 JSON 格式
        SELECT 
            ACPD_SID, ACPD_Cname, ACPD_Ename, ACPD_Sname, ACPD_Email, 
            ACPD_Status, ACPD_Stop, ACPD_StopMemo, ACPD_LoginID, ACPD_LoginPWD,
            ACPD_Memo, ACPD_NowDateTime, ACPD_NowID, ACPD_UPDDateTime, ACPD_UPDID
        FROM [dbo].[MyOffice_ACPD]
        WHERE ACPD_SID IN (
            SELECT ACPD_SID
            FROM OPENJSON(@JsonData)
            WITH (ACPD_SID NVARCHAR(20))
        )
        FOR JSON AUTO;  -- 返回 JSON 格式結果

        SET @SID = (SELECT ACPD_SID FROM OPENJSON(@JsonData) WITH (ACPD_SID NVARCHAR(20)) AS j);
    END

    -- 紀錄操作插入到 Log
    DECLARE @LogReturnValues NVARCHAR(MAX);
	DECLARE @GroupID UNIQUEIDENTIFIER;
	DECLARE @ActionJSON NVARCHAR(MAX);		
	SET @GroupID = NEWID();
	SET @ActionJSON = CONCAT(@Action, ' record with ACPD_SID: ', @SID)

    EXEC [dbo].[usp_AddLog] 
        @_InBox_ReadID = 0, -- 預設為 0 
        @_InBox_SPNAME = 'usp_MyOffice_ACPD_CRUD', 
        @_InBox_GroupID = @GroupID, -- 暫設NEWID()作為群組ID
        @_InBox_ExProgram = @Action, -- 操作類型
        @_InBox_ActionJSON = @ActionJSON,	-- 預設要為JSON字串，暫設一普通字串
        @_OutBox_ReturnValues = @LogReturnValues OUTPUT;

    -- 紀錄操作結果 (回傳的 log 資訊)
    PRINT @LogReturnValues;
END;