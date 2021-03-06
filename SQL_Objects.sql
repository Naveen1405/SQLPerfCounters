USE [DBAInternal]
GO

/****** Object:  Table [PerfMon].[InstanceStats]    Script Date: 15/03/2021 11:12:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [PerfMon].[InstanceStats](
	[InstanceID] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [int] NOT NULL,
	[ServerNm] [varchar](30) NOT NULL,
	[InstanceNm] [varchar](30) NOT NULL,
	[PerfDate] [datetime] NOT NULL,
	[FwdRecSec] [decimal](10, 4) NOT NULL,
	[PgSpltSec] [decimal](10, 4) NOT NULL,
	[BufCchHit] [decimal](10, 4) NOT NULL,
	[PgLifeExp] [int] NOT NULL,
	[LogGrwths] [int] NULL,
	[BlkProcs] [int] NOT NULL,
	[BatReqSec] [decimal](10, 4) NOT NULL,
	[SQLCompSec] [decimal](10, 4) NOT NULL,
	[SQLRcmpSec] [decimal](10, 4) NOT NULL,
	[LzyWrtSec] [decimal](10, 4) NULL,
	[CptPgsSec] [int] NULL,
	[LckWtsSec] [decimal](10, 4) NULL,
	[MemGrtPend] [int] NULL,
	[TgtSvrMemKB] [int] NULL,
	[TotSvrMemKB] [int] NULL,
	[TotTableScans] [decimal](8, 2) NULL,
	[TotTableSeeks] [decimal](8, 2) NULL,
 CONSTRAINT [PK_InstanceStats] PRIMARY KEY NONCLUSTERED 
(
	[InstanceID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [PerfMon].[InstanceStats]  WITH NOCHECK ADD  CONSTRAINT [FX_InstanceStats] FOREIGN KEY([ServerID])
REFERENCES [PerfMon].[ServerStats] ([ServerID])
GO

ALTER TABLE [PerfMon].[InstanceStats] CHECK CONSTRAINT [FX_InstanceStats]
GO

/*=====================================================================================================================*/
USE [DBAInternal]
GO

/****** Object:  Table [PerfMon].[ServerStats]    Script Date: 15/03/2021 11:12:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [PerfMon].[ServerStats](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerNm] [varchar](30) NOT NULL,
	[PerfDate] [datetime] NOT NULL,
	[PctProc] [decimal](10, 4) NOT NULL,
	[Memory] [bigint] NOT NULL,
	[PgFilUse] [decimal](10, 4) NOT NULL,
	[DskRdsSec] [decimal](10, 4) NOT NULL,
	[DskWrtSec] [decimal](10, 4) NOT NULL,
	[ProcQueLn] [int] NOT NULL,
	[PctPriv] [decimal](10, 4) NULL,
	[SQLPctProc] [decimal](10, 4) NULL,
	[SQLPctPriv] [decimal](10, 4) NULL,
	[AvgDskSecRds] [decimal](10, 4) NULL,
	[AvgDskbytesRds] [decimal](10, 4) NULL,
	[AvgDskSecWrt] [decimal](10, 4) NULL,
	[AvgDskbytesWrt] [decimal](10, 4) NULL,
	[PctIdleTm] [decimal](10, 4) NULL,
	[CurDskQueLn] [int] NULL,
 CONSTRAINT [PK_ServerStats] PRIMARY KEY NONCLUSTERED 
(
	[ServerID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/*=====================================================================================================================*/

USE [DBAInternal]
GO
/****** Object:  StoredProcedure [PerfMon].[insInstanceStats]    Script Date: 15/03/2021 11:10:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [PerfMon].[insInstanceStats]
           (@InstanceID		int OUTPUT
           ,@ServerID		int = NULL
           ,@ServerNm		varchar(30) = NULL
           ,@InstanceNm		varchar(30) = NULL
           ,@PerfDate		varchar(20) = NULL
           ,@FwdRecSec		decimal(10,4) = NULL
           ,@PgSpltSec		decimal(10,4) = NULL
		   ,@TotTblScn		decimal(10,4) = NULL
		   ,@TotTblSks		decimal(10,4) = NULL
           ,@BufCchHit		decimal(10,4) = NULL
           ,@PgLifeExp		int = NULL
           ,@LogGrwths		int = NULL
           ,@BlkProcs		int = NULL
           ,@BatReqSec		decimal(10,4) = NULL
           ,@SQLCompSec		decimal(10,4) = NULL
           ,@SQLRcmpSec		decimal(10,4) = NULL
		   ,@LzyWrtSec		DECIMAL(10,4) = NULL
		   ,@CptPgsSec		INT = NULL
		   ,@LckWtsSec		decimal(10,4) = NULL
		   ,@MemGrtPend		INT = NULL
		   ,@TgtSvrMemKB	INT = NULL
		   ,@TotSvrMemKB	INT = NULL)
AS
	SET NOCOUNT ON
	
	DECLARE @InstanceOut table( InstanceID int);

	INSERT INTO [PerfMon].[InstanceStats]
           ([ServerID]
           ,[ServerNm]
           ,[InstanceNm]
           ,[PerfDate]
           ,[FwdRecSec]
           ,[PgSpltSec]
		   ,[TotTableScans]
		   ,[TotTableSeeks]
           ,[BufCchHit]
           ,[PgLifeExp]
           ,[LogGrwths]
           ,[BlkProcs]
           ,[BatReqSec]
           ,[SQLCompSec]
           ,[SQLRcmpSec]
		   ,[LzyWrtSec]
		   ,[CptPgsSec]
		   ,[LckWtsSec]
		   ,[MemGrtPend]
		   ,[TgtSvrMemKB]
		   ,[TotSvrMemKB])
	OUTPUT INSERTED.InstanceID INTO @InstanceOut
	VALUES
           (@ServerID
           ,@ServerNm
           ,@InstanceNm
		   ,GETDATE()		-- @PerfDate get the sql server datetime
		   ,@FwdRecSec
           ,@PgSpltSec
		   ,@TotTblScn
		   ,@TotTblSks
           ,@BufCchHit
           ,@PgLifeExp
           ,@LogGrwths
           ,@BlkProcs
           ,@BatReqSec
           ,@SQLCompSec
           ,@SQLRcmpSec
		   ,@LzyWrtSec
		   ,@CptPgsSec
		   ,@LckWtsSec
		   ,@MemGrtPend
		   ,@TgtSvrMemKB
		   ,@TotSvrMemKB)

	SELECT @InstanceID = InstanceID FROM @InstanceOut
	
	RETURN

/*=====================================================================================================================*/
USE [DBAInternal]
GO

/****** Object:  StoredProcedure [PerfMon].[insServerStats]    Script Date: 15/03/2021 11:11:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [PerfMon].[insServerStats]
           (@ServerID		INT OUTPUT
           ,@ServerNm		VARCHAR(30) = NULL
           ,@PerfDate		VARCHAR(20) = NULL
           ,@PctProc		DECIMAL(10,4) = NULL
		   ,@PctPriv		DECIMAL(10,4) = NULL
		   ,@SQLPctProc		DECIMAL(10,4) = NULL
		   ,@SQLPctPriv		DECIMAL(10,4) = NULL
           ,@Memory		BIGINT = NULL
           ,@PgFilUse		DECIMAL(10,4) = NULL
           ,@DskRdsSec		DECIMAL(10,4) = NULL
           ,@DskWrtSec		DECIMAL(10,4) = NULL
		   ,@AvgDskSecRds		DECIMAL(10,4) = NULL
		   ,@AvgDskbytesRds		DECIMAL(10,4) = NULL
		   ,@AvgDskSecWrt		DECIMAL(10,4) = NULL
		   ,@AvgDskbytesWrt		DECIMAL(10,4) = NULL
		   ,@PctIdleTm		DECIMAL(10,4) = NULL
		   ,@CurDskQueLn		INT = NULL
           ,@ProcQueLn		INT = NULL)
AS
	SET NOCOUNT ON
	
	DECLARE @ServerOut TABLE( ServerID INT);

	INSERT INTO [PerfMon].[ServerStats]
           ([ServerNm]
           ,[PerfDate]
           ,[PctProc]
		   ,[PctPriv]
		   ,[SQLPctProc]
		   ,[SQLPctPriv]
           ,[Memory]
           ,[PgFilUse]
           ,[DskRdsSec]
           ,[DskWrtSec]
		   ,[AvgDskSecRds]
		   ,[AvgDskbytesRds]
		   ,[AvgDskSecWrt]
		   ,[AvgDskbytesWrt]
		   ,[PctIdleTm]
		   ,[CurDskQueLn]
           ,[ProcQueLn])
	OUTPUT INSERTED.ServerID INTO @ServerOut
     	VALUES
           (@ServerNm
		   ,GETDATE()			-- @PerfDate get the sql server datetime   
           ,@PctProc
		   ,@PctPriv
		   ,@SQLPctProc
		   ,@SQLPctPriv
           ,@Memory
           ,@PgFilUse
           ,@DskRdsSec
           ,@DskWrtSec
		   ,@AvgDskSecRds
		   ,@AvgDskbytesRds
		   ,@AvgDskSecWrt
		   ,@AvgDskbytesWrt
		   ,@PctIdleTm
		   ,@CurDskQueLn
           ,@ProcQueLn)

	SELECT @ServerID = ServerID FROM @ServerOut
	
	RETURN


GO




