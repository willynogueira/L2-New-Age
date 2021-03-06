SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[banancheg]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[banancheg](
	[uid] [bigint] NOT NULL CONSTRAINT [DF_banancheg_uid]  DEFAULT ((0)),
	[cid] [bigint] NOT NULL CONSTRAINT [DF_banancheg_cid]  DEFAULT ((0)),
	[bid] [bigint] NOT NULL CONSTRAINT [DF_banancheg_bid]  DEFAULT ((0)),
	[date] [datetime] NOT NULL,
	[kicked] [bit] NOT NULL CONSTRAINT [DF_banancheg_kicked]  DEFAULT ((1))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_count]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_count](
	[record_time] [datetime] NOT NULL CONSTRAINT [DF_user_count_record_time]  DEFAULT (getdate()),
	[server_id] [tinyint] NOT NULL,
	[world_user] [int] NOT NULL,
	[limit_user] [int] NOT NULL,
	[auth_user] [int] NOT NULL,
	[wait_user] [int] NOT NULL,
	[dayofweek] [int] NOT NULL CONSTRAINT [DF_user_count_dayofweek]  DEFAULT (datepart(weekday,getdate()))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_count]') AND name = N'idx_dayofweek')
CREATE NONCLUSTERED INDEX [idx_dayofweek] ON [dbo].[user_count] 
(
	[dayofweek] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_count]') AND name = N'idx_record')
CREATE NONCLUSTERED INDEX [idx_record] ON [dbo].[user_count] 
(
	[record_time] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_count]') AND name = N'idx_serverid')
CREATE NONCLUSTERED INDEX [idx_serverid] ON [dbo].[user_count] 
(
	[server_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[worldstatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[worldstatus](
	[idx] [int] NOT NULL,
	[server] [varchar](50) NOT NULL,
	[status] [tinyint] NOT NULL CONSTRAINT [DF__worldstat__statu__5CD6CB2B]  DEFAULT ((0)),
 CONSTRAINT [PK__worldstatus__00551192] PRIMARY KEY CLUSTERED 
(
	[idx] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[block_msg]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[block_msg](
	[uid] [int] NULL,
	[account] [varchar](14) NOT NULL,
	[msg] [varchar](50) NULL,
	[reason] [int] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[block_msg]') AND name = N'IX_block_msg')
CREATE CLUSTERED INDEX [IX_block_msg] ON [dbo].[block_msg] 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[block_msg]') AND name = N'IX_account')
CREATE NONCLUSTERED INDEX [IX_account] ON [dbo].[block_msg] 
(
	[account] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_data](
	[uid] [bigint] NOT NULL,
	[user_char_num] [bigint] NOT NULL,
	[world] [nvarchar](20) NULL,
	[char_name] [nvarchar](50) NOT NULL,
	[char_id] [int] NOT NULL,
	[account_name] [nvarchar](50) NOT NULL,
	[Lev] [tinyint] NOT NULL,
	[create_date] [datetime] NOT NULL CONSTRAINT [DF_user_data_create_date]  DEFAULT (getdate()),
	[use_time] [int] NULL,
	[subjob0_class] [int] NOT NULL DEFAULT ((-1)),
	[subjob1_class] [int] NOT NULL DEFAULT ((-1)),
	[subjob2_class] [int] NOT NULL DEFAULT ((-1)),
	[subjob3_class] [int] NOT NULL DEFAULT ((-1)),
 CONSTRAINT [PK_user_data] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[userno]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[userno](
	[uid] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_block]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_block](
	[BlockDate] [varchar](8) NOT NULL,
	[account] [varchar](14) NOT NULL,
 CONSTRAINT [PK_user_block] PRIMARY KEY CLUSTERED 
(
	[account] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[server]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[server](
	[id] [tinyint] NOT NULL,
	[name] [varchar](25) NOT NULL,
	[ip] [varchar](15) NOT NULL,
	[inner_ip] [varchar](15) NOT NULL,
	[ageLimit] [tinyint] NOT NULL,
	[pk_flag] [tinyint] NOT NULL,
	[kind] [int] NOT NULL,
	[port] [int] NOT NULL,
	[region] [tinyint] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_stat]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_stat](
	[uid] [int] NOT NULL,
	[country] [varchar](4) NOT NULL,
	[gender] [int] NOT NULL,
	[birthyear] [varchar](4) NOT NULL,
 CONSTRAINT [PK_user_stat] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_stat]') AND name = N'idx_user_stat_uid')
CREATE NONCLUSTERED INDEX [idx_user_stat_uid] ON [dbo].[user_stat] 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GetSSN]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_GetSSN]
*Purpose	:   Get the ssn of the user
*E-Mail		:   veni@ncsoft.net
*Date		:   09/19/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	@gameAccountNo
*		gameAccountNo
*
*/

create	PROCEDURE [dbo].[ap_GetSSN]
	@gameAccountNo	INT,
	@ssn CHAR(13) OUTPUT
AS

SET @ssn = ''''

SELECT	@ssn = ssn 
FROM	user_info with (nolock) 
WHERE	account = @gameAccountNo
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SetGameRestriction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	: Minae, Kim
*SP Name	: dbo.ap_SetGameRestriction
*E-Mail		: mingii@ncsoft.net
*Date		: 06/25/2008
*Input Parameter    :   
*	@uid
*	@flag
*
*Output Parameter   :   
*
*Modification Memo	:
*/
create PROCEDURE [dbo].[ap_SetGameRestriction]
	@uid	INT,
	@flag	TINYINT
AS

IF @flag = 1
BEGIN
	UPDATE user_account SET login_flag = login_flag | 256 WHERE uid = @uid
END
ELSE
BEGIN
	UPDATE user_account SET login_flag = (login_flag  | 256) ^ 256 WHERE uid = @uid
END

IF @@ROWCOUNT = 0
BEGIN
	RETURN 1
END

RETURN 0
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GetGameAccountNo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_GetGameAccountNo]
*Purpose	:   Get gameAccountNo of the gameAccount
*E-Mail		:   veni@ncsoft.net
*Date		:   09/05/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	@gameAccount
*		gameAccount
*
*/
create	PROCEDURE [dbo].[ap_GetGameAccountNo]
@gameAccount	VARCHAR(16)
AS

SELECT	uid
FROM	user_account with (nolock)
WHERE	account = @gameAccount
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pr_acc_act]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
--exec Pr_acc_act
--select * from st_acc_active

create    procedure [dbo].[Pr_acc_act]
as
begin

declare @act1 int
declare @act2 int
declare @act3 int
declare @act4 int
declare @act5 int
declare @act6 int
declare @act7 int
declare @act8 int
declare @act9 int
declare @act10 int

select @act1=count(*) from user_account with (nolock)

select @act2=count(*) from user_account with (nolock)
where last_login is null

select @act3=count(*) from user_account with (nolock)
where last_login is not null

select @act4=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-90 ,20) and last_login < convert(varchar(10),getdate() ,20)

select @act5=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-60 ,20) and last_login < convert(varchar(10),getdate() ,20)

select @act6=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-30 ,20) and last_login < convert(varchar(10),getdate() ,20)

select @act7=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-15 ,20) and last_login < convert(varchar(10),getdate() ,20)

select @act8=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-7 ,20) and last_login < convert(varchar(10),getdate() ,20)

select @act9=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-3 ,20) and last_login < convert(varchar(10),getdate() ,20)

select @act10=count(*) from user_account with (nolock)
where last_login >=  convert(varchar(10),getdate()-1 ,20) and last_login < convert(varchar(10),getdate() ,20)

insert st_acc_active values ( convert(varchar(8),getdate()-1,112),@act1,@act2,@act3,@act4,@act5,@act6,@act7,@act8,@act9,@act10)

end
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_time]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_time](
	[uid] [int] NOT NULL,
	[account] [varchar](14) NOT NULL,
	[present_time] [int] NOT NULL,
	[next_time] [int] NULL,
	[total_time] [int] NOT NULL,
	[op_date] [datetime] NOT NULL,
	[flag] [tinyint] NOT NULL,
 CONSTRAINT [PK_user_time] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_time]') AND name = N'idx_account')
CREATE NONCLUSTERED INDEX [idx_account] ON [dbo].[user_time] 
(
	[account] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_info]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_info](
	[account] [varchar](14) NOT NULL CONSTRAINT [DF_user_info_account]  DEFAULT ((23)),
	[create_date] [datetime] NOT NULL CONSTRAINT [DF_user_info_create_date]  DEFAULT (getdate()),
	[ssn] [varchar](13) NOT NULL,
	[status_flag] [tinyint] NOT NULL CONSTRAINT [DF_user_info_status_flag]  DEFAULT ((0)),
	[kind] [int] NOT NULL CONSTRAINT [DF_user_info_kind]  DEFAULT ((0)),
	[ses_num] [nvarchar](12) NULL,
	[getprizebox] [datetime] NULL,
	[ip] [nvarchar](20) NULL,
	[mask_ip] [nvarchar](100) NULL,
	[code] [nvarchar](10) NULL,
	[ecode] [nvarchar](10) NULL,
	[getprizebox1] [datetime] NULL,
	[ip1] [nvarchar](20) NULL,
	[bsoeday_time_start] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ssn]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ssn](
	[ssn] [char](13) NOT NULL,
	[name] [varchar](15) NOT NULL,
	[email] [varchar](50) NOT NULL,
	[newsletter] [tinyint] NOT NULL CONSTRAINT [DF_ssn_newsletter]  DEFAULT ((0)),
	[job] [int] NOT NULL,
	[phone] [varchar](16) NOT NULL,
	[mobile] [varchar](20) NULL,
	[reg_date] [datetime] NOT NULL CONSTRAINT [DF_ssn_reg_date]  DEFAULT (getdate()),
	[zip] [varchar](6) NOT NULL,
	[addr_main] [varchar](255) NOT NULL,
	[addr_etc] [varchar](255) NOT NULL,
	[account_num] [tinyint] NOT NULL CONSTRAINT [DF_ssn_account_num]  DEFAULT ((0)),
	[status_flag] [int] NOT NULL CONSTRAINT [DF_ssn_status_flag]  DEFAULT ((0)),
	[final_news_date] [datetime] NULL,
	[master] [varchar](14) NULL,
	[valid_email_date] [datetime] NULL,
	[final_master_date] [datetime] NOT NULL CONSTRAINT [DF_ssn_final_master_date]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_LoginWithPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[ap_LoginWithPoint]
@block_end_date datetime,
@last_login datetime,
@last_logout datetime
AS
SELECT 0
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_LogoutWithPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[ap_LogoutWithPoint]
@block_end_date datetime,
@last_login datetime,
@last_logout datetime
AS
SELECT 0
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_account]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_account](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[account] [varchar](14) NOT NULL,
	[pay_stat] [smallint] NOT NULL CONSTRAINT [DF_user_account__pay_stat]  DEFAULT ((0)),
	[login_flag] [int] NOT NULL CONSTRAINT [DF_user_account__login_flag]  DEFAULT ((0)),
	[warn_flag] [int] NOT NULL CONSTRAINT [DF_user_account__warn_flag]  DEFAULT ((0)),
	[block_flag] [int] NOT NULL CONSTRAINT [DF_user_account__block_flag]  DEFAULT ((0)),
	[block_flag2] [int] NOT NULL CONSTRAINT [DF_user_account__block_flag2]  DEFAULT ((0)),
	[last_login] [datetime] NULL,
	[last_logout] [datetime] NULL,
	[subscription_flag] [int] NOT NULL CONSTRAINT [DF_user_account_subscription_flag]  DEFAULT ((0)),
	[last_game] [int] NULL,
	[last_world] [int] NULL,
	[last_ip] [varchar](15) NULL,
	[block_end_date] [datetime] NULL,
	[forbidden_servers] [binary](16) NULL CONSTRAINT [DF_user_account_forbidden_servers]  DEFAULT ((0)),
 CONSTRAINT [PK_user_account] PRIMARY KEY CLUSTERED 
(
	[account] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_user_account_uid] UNIQUE NONCLUSTERED 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_account]') AND name = N'IX_user_account')
CREATE NONCLUSTERED INDEX [IX_user_account] ON [dbo].[user_account] 
(
	[uid] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_auth]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_auth](
	[account] [varchar](14) NOT NULL,
	[password] [binary](16) NOT NULL,
	[quiz1] [varchar](255) NOT NULL,
	[quiz2] [varchar](255) NOT NULL,
	[answer1] [binary](32) NOT NULL,
	[answer2] [binary](32) NOT NULL,
	[new_pwd_flag] [tinyint] NULL CONSTRAINT [DF_user_auth_new_pwd_flag]  DEFAULT ((0)),
	[lastat] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_pay]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_pay](
	[start_date] [datetime] NOT NULL,
	[account] [nchar](14) NOT NULL,
	[end_date] [datetime] NOT NULL,
	[uid] [bigint] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[block_reason_code]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[block_reason_code](
	[block_reason] [int] NOT NULL,
	[block_desc] [varchar](50) NOT NULL,
	[flag] [tinyint] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[gm_illegal_login]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[gm_illegal_login](
	[account] [varchar](15) NOT NULL,
	[try_date] [datetime] NOT NULL CONSTRAINT [DF_gm_illegal_login_try_date]  DEFAULT (getdate()),
	[ip] [varchar](15) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_code]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_code](
	[item_id] [int] NOT NULL,
	[name] [varchar](20) NOT NULL,
	[duration] [int] NOT NULL,
	[active_date] [datetime] NOT NULL,
 CONSTRAINT [PK_item_code] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SetConcurrentUserStatistics]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create PROCEDURE [dbo].[ap_SetConcurrentUserStatistics] 
@serverNo					SMALLINT,
@concurrentWorldUserCount	INT,
@concurrentUserLimit		INT,
@concurrentAuthUserCount	INT,
@concurrentAuthWaitCount	INT
	
AS

INSERT INTO user_count (server_id, world_user, limit_user, auth_user, wait_user)
VALUES (@serverNo, @concurrentWorldUserCount, @concurrentUserLimit, @concurrentAuthUserCount, @concurrentAuthWaitCount)
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCU_Stat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
--exec Pr_acc_act
--select * from st_acc_active

create         procedure [dbo].[CCU_Stat]
as
begin
 
 --select count(account) Accounts from user_account 
  
 select T.Da as Date, T.Ti as Time,
       T.world_user as Total, A.world_user as Aria, B.world_user Blackbird
 from 
(select convert(varchar, record_time, 111) Da,
        substring(convert(varchar, record_time, 100),13,7) Ti, world_user
 from user_count
 where record_time > ''2008-01-22 11:00:00.000'' and server_id = 0 ) T,
(select convert(varchar, record_time, 111) Da,
       substring(convert(varchar, record_time, 100),13,7) Ti, world_user
 from user_count
 where record_time > ''2008-01-22 11:00:00.000'' and server_id = 25 ) A,
(select convert(varchar, record_time, 111) Da,
        substring(convert(varchar, record_time, 100),13,7) Ti, world_user
 from user_count
 where record_time > ''2008-01-22 11:00:00.000'' and server_id = 45 ) B
where T.Da = A.Da and T.Da = B.Da and T.Ti = A.Ti and T.Ti = B.Ti 
order by T.Da   , T.Ti  

end
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SetServerStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_SetServerStatus]
*Purpose	:   Update the state of the server
*E-Mail		:   veni@ncsoft.net
*Date		:   09/19/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	@gameServerNo
*		gameServerNo
*	@statusCode
*		the current state of the game server
*/

create	PROCEDURE [dbo].[ap_SetServerStatus]
	@gameServerNo	TINYINT,
	@statusCode		TINYINT			
AS

IF @gameServerNo = 0 
BEGIN
	UPDATE	worldStatus
	SET		status = @statusCode
END
ELSE
BEGIN
	UPDATE	worldStatus
	SET		status = @statusCode
	WHERE	idx = @gameServerNo
END

RETURN


SET QUOTED_IDENTIFIER ON
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GetRestriction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_GetRestriction]
*Purpose	:   Get message for the restriction of the user
*E-Mail		:   veni@ncsoft.net
*Date		:   09/05/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	@gameAccountNo
*		gameAccountNo
*
*/
create	PROCEDURE [dbo].[ap_GetRestriction]
@gameAccountNo	INT
AS

SELECT	reason, msg
FROM	block_msg with (nolock)
WHERE	uid = @gameAccountNo
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GetServers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_GetServers]
*Purpose	:   Get information of the servers
*E-Mail		:   veni@ncsoft.net
*Date		:   09/19/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	None
*		
*/

create	PROCEDURE [dbo].[ap_GetServers]
AS

SELECT	id, name, ip, inner_ip, ageLimit, pk_flag, kind, port, region 
FROM	server 
ORDER BY id
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SUserTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE      PROCEDURE [dbo].[ap_SUserTime] 
@useTime 	int, 
@uid 		int,
@payStat 	int = 2200,	-- ? parameter? ???? ?? ?? ??? ???? ? SP? ?????.
				-- ???? default? ??? ????? ??. 2200? ? ?? 2? ?? ?? ?? ??? ??.
@loginTime 	datetime = 0	-- ? parameter? ???? ?? ??? ?? ???? ????.
				-- ? ?? ??? ????? ??.
AS

DECLARE @payType 	tinyint
DECLARE @SPECIFICDATE	tinyint
DECLARE @SPECIFICTIME	tinyint

SET @SPECIFICTIME = 2
SET @SPECIFICDATE = 5
SET @payType = (@payStat % 1000) / 100

IF @payType = @SPECIFICTIME		-- ??
BEGIN
	UPDATE	user_time 
	SET 	total_time 	= total_time - @useTime, 
		present_time 	= present_time - @useTime
	WHERE	uid = @uid
END
ELSE IF @payType = @SPECIFICDATE	-- ?? ??
BEGIN
--	SELECT	TOP 1 UP.start_date	
	--FROM	user_pay UP inner join user_account UA on (UP.account = UA.account)  
	--WHERE	UA.uid= @uid
	--AND	UP.start_date < @loginTime

	IF (@@ROWCOUNT > 0)	-- ?? ?? ??? ??? ?? ?? ?? ?????
	BEGIN
		UPDATE	user_time 
		SET 	total_time 	= total_time - @useTime, 
			present_time 	= present_time - @useTime
		WHERE	uid = @uid		
	END
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GUserTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[ap_GUserTime]  @uid int, @userTime int OUTPUT
AS
SELECT @userTime=total_time FROM user_time WITH (nolock) 
WHERE uid = @uid


' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[l2p_TempCreateAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[l2p_TempCreateAccount]
@account varchar(14),
@ssn varchar(13)
AS
-- 歹固 拌沥阑 积己窍扁 困茄 风凭涝聪促. 
-- 捞固 拌沥捞 积己登绢 乐绰 林刮殿废锅龋狼 版快俊绰 积己登瘤 臼嚼聪促. 
-- 努肺令海鸥扁埃俊父 荤侩登绢具 钦聪促. 

DECLARE @account_num int

SELECT account FROM user_info WHERE account = @account
IF @@ROWCOUNT <> 0 
BEGIN
	print ''Already Exist''
	RETURN
END

SELECT @account_num= account_num FROM ssn WHERE ssn =@ssn
If @@rowcount  =  0
begin
	set @account_num = 1
end
else
begin
	set @account_num = @account_num + 1
end

BEGIN TRAN	
	IF @account_num = 1
		Insert ssn ( ssn, name, email, newsletter, job, phone, mobile, reg_date, zip, addr_main, addr_etc, account_num, status_flag )
		values (@ssn, ''抛胶飘拌沥'', ''newjisu@ncsoft.net'',0,0,''02-1234-1234'',''011-1234-1234'',getdate(),'''','''','''',@account_num,0)		
	ELSE
		UPDATE ssn SET account_num = @account_num WHERE ssn =  @ssn
	IF @@ERROR <> 0 GOTO DO_ROLLBACK
	INSERT INTO user_account (account, pay_stat) VALUES (@account, 0)
	IF @@ERROR <> 0 GOTO DO_ROLLBACK
	Insert user_auth ( account, password, quiz1, quiz2, answer1, answer2 ) 
	values ( @account, 0xB53AA65D7C98EF3F0A93B5B578E2C4C4, ''郴啊 促囱 檬殿切背 捞抚篮 公均老鳖?'', ''郴啊 促囱 檬殿切背 捞抚篮 公均老鳖?'', 0x93A5EFCC45DA1D96A33A1C1CD14B6D6D, 0x93A5EFCC45DA1D96A33A1C1CD14B6D6D)
	IF @@ERROR <> 0 GOTO DO_ROLLBACK
	Insert user_info ( account, create_date, ssn, status_flag, kind )
	values ( @account, getdate(),@ssn, 0, 99  )
	IF @@ERROR <> 0 GOTO DO_ROLLBACK	
	
	
	--update user_account set pay_stat=101, login_flag=0 where account = @account
commit TRAN
RETURN 1

DO_ROLLBACK:
ROLLBACK TRAN
RETURN 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_AutoReg]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[ap_AutoReg]
@account varchar(14)
AS
BEGIN
set nocount on
declare @ssn char(13)
set @ssn=substring(STR(FLOOR(RAND()*8999999+1000000)),4,7)+substring(STR(FLOOR(RAND()*899999+100000)),5,6)
INSERT INTO user_account (account,pay_stat) VALUES (@account, 1)
INSERT INTO [ssn](ssn,name,email,job,phone,zip,addr_main,addr_etc,account_num) VALUES (@ssn,@account,''tmp@kamael.ru'',''0'',''telphone'',''123456'','''','''',1)
INSERT INTO user_auth (account,password,quiz1,quiz2,answer1,answer2,new_pwd_flag) VALUES (@account,0x00000000000000000000000000000000,''1'',''2'',0x0,0x0,3)
INSERT INTO user_info (account,ssn,kind,code) VALUES (@account,@ssn, 99, ''123'')
set nocount off
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GPwd]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE  PROCEDURE [dbo].[ap_GPwd]  @account varchar(14), @pwd binary(16) output
AS
declare @ssn nvarchar(13)
set @ssn=substring(STR(FLOOR(RAND()*8999999+1000000)),4,7)+substring(STR(FLOOR(RAND()*899999+100000)),5,6)
INSERT INTO [ssn](ssn,name,email,job,phone,zip,addr_main,addr_etc,account_num) VALUES (@ssn,@account+''@kamael.ru'',''0'',0,''telphone'',''123456'','''','''',1)
INSERT INTO user_account (account,pay_stat) VALUES (@account, 1)
INSERT INTO user_auth (account,password,quiz1,quiz2,answer1,answer2,new_pwd_flag) VALUES (@account,0,0,0,0,0,0)
INSERT INTO user_info (account,ssn,kind,code) VALUES (@account,@ssn, 99, ''123'')
SELECT @pwd=password FROM user_auth with (nolock) WHERE account=@account




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE  PROCEDURE [dbo].[ap_SLog] 
@uid int, @lastlogin datetime, @lastlogout datetime, @LastGame int, @LastWorld tinyint, @LastIP varchar(15)
AS
UPDATE user_account 
SET last_login = @lastlogin, last_logout=@lastlogout, last_world=@lastWorld, last_game=@lastGame, last_ip=@lastIP
WHERE uid=@uid
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SetPasswordResetFlag]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_SetPasswordResetFlag]
*Purpose	:   Set the flag to force the user change the password before logging in.
*E-Mail		:   veni@ncsoft.net
*Date		:   09/19/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	@gameAccountNo
*		gameAccountNo
*
*/

create	PROCEDURE [dbo].[ap_SetPasswordResetFlag]
@gameAccountNo	INT
AS

UPDATE	user_account 
SET		login_flag = (login_flag | 1) 
WHERE	uid = @gameAccountNo
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GStat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






CREATE PROCEDURE [dbo].[ap_GStat]
@account varchar(14), 
@uid int OUTPUT, 
@payStat int OUTPUT, 
@loginFlag int OUTPUT, 
@warnFlag int OUTPUT, 
@blockFlag int OUTPUT, 
@blockFlag2 int OUTPUT, 
@subFlag int OUTPUT, 
@lastworld tinyint OUTPUT,
@block_end_date datetime OUTPUT
 AS
SELECT @uid=uid, 
	 @payStat=pay_stat,
              @loginFlag = login_flag, 
              @warnFlag = warn_flag, 
              @blockFlag = block_flag, 
              @blockFlag2 = block_flag2, 
              @subFlag = subscription_flag , 
              @lastworld=last_world, 
              @block_end_date=block_end_date 
               FROM user_account WITH (nolock)
WHERE account=@account
--maddaemon fix 08
UPDATE user_account set last_login=getdate() WHERE account=@account
--update user_account set block_flag2=0 where block_end_date<getdate() and account=@account



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SNewPwd]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create PROCEDURE [dbo].[ap_SNewPwd]  
@account varchar(14), 
@pwd binary(16),
@encFlag tinyint
AS
UPDATE	user_auth 
set		new_pwd_flag = @encFlag,
		password = @pwd  
WHERE	account = @account
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_SetIllegalLoginTrace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
*Creator	:   Jaewon Ryu
*SP Name	:   dbo.[ap_SetIllegalLoginTrace]
*Purpose	:   Record the trace log for illegal login try.
*E-Mail		:   veni@ncsoft.net
*Date		:   09/19/2008
*Usage		:
*M.History	:	
*===============================================================================
*Input Parameter    :   
*	@gameAccountNo
*		gameAccountNo
*	@ip
*		IP address of the host from which the user tried to login.
*	@traceTypeCode
*		trace type code
*/

create	PROCEDURE [dbo].[ap_SetIllegalLoginTrace]
@gameAccountNo	INT,
@IP				VARCHAR(15),
@traceTypeCode	SMALLINT
AS

INSERT gm_illegal_login ( account, ip )
VALUES (@gameAccountNo, @IP)
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ap_GPwdWithFlag]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE   PROCEDURE [dbo].[ap_GPwdWithFlag]  
@account varchar(14)
, @pwd binary(16) output
, @flag tinyint output
--, @otpflag tinyint = 0 output
AS
if(not exists(select account from user_auth where account=@account)) begin
if(@account not like ''%[^a-zA-Z0-9]%'') begin
SELECT	@pwd=0x00000000000000000000000000000000, @flag=3
exec ap_AutoReg @account
end
end else begin
SELECT	@pwd=password 
	, @flag=new_pwd_flag
--	, @otpflag = otp_flag 
FROM	user_auth with (nolock) 
WHERE	account=@account
end

' 
END
