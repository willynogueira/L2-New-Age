SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDominion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveDominion] 
(
	@dominion_id int,
	@dominion_status int,
	@residence_status int
)
AS

SET NOCOUNT ON

UPDATE dominion SET dominion_status = @dominion_status, residence_status = @residence_status 
WHERE dominion_id = @dominion_id

IF @@rowcount = 0
BEGIN
	INSERT INTO dominion (dominion_id, dominion_status, residence_status) 
	VALUES (@dominion_id, @dominion_status, @residence_status) 
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSiegeRelatedAlliancePledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetSiegeRelatedAlliancePledge    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetSiegeRelatedAlliancePledge
	
INPUT	
	@alliance_id	int

OUTPUT
	castle_id,
	pledge_id, 
	type 
return
made by
	bert
********************************************/
CREATE PROCEDURE [dbo].[lin_GetSiegeRelatedAlliancePledge]
(
	@alliance_id	int
)
AS
SET NOCOUNT ON

SELECT castle_id, pledge_id, type 
FROM castle_war
WHERE pledge_id IN (SELECT pledge_id FROM pledge WHERE alliance_id = @alliance_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CharLogin]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CharLogin    Script Date: 2003-09-20 오전 11:51:56 ******/
/********************************************
lin_CharLogin
	log character login
INPUT
	char_id
OUTPUT
return
made by
	carrot
date
	2002-06-11
change
********************************************/
CREATE PROCEDURE [dbo].[lin_CharLogin]
(
	@char_id	INT
)
AS

SET NOCOUNT ON

UPDATE user_data SET login = GETDATE() WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveNRMemo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveNRMemo
desc:	save NR Memo
exam:	exec lin_SaveNRMemo
history:	2008-03-19	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_SaveNRMemo] 
(
	@char_id int,
	@quest_id int,
	@state1 int,
	@state2 int,
	@journal int
)
AS

SET NOCOUNT ON

/*
IF (@point < 0)
BEGIN            
    RAISERROR (''Not valid parameter : char id[%d] point[%d]'', @char_id,  @point)
    RETURN -1            
END            

*/

UPDATE user_nr_memo SET state1 = @state1, state2 = @state2, journal = @journal
WHERE char_id = @char_id AND quest_id = @quest_id

IF @@rowcount = 0
BEGIN
	INSERT INTO user_nr_memo (char_id, quest_id, state1, state2, journal) 
	VALUES (@char_id, @quest_id, @state1, @state2, @journal)
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetTempMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetTempMail
	get temp mail 
INPUT
	@char_id		int,
	@mail_id		int
OUTPUT
return
made by
	kks
date
	2004-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_GetTempMail]
(
	@char_id		int,
	@mail_id		int
)
AS
SET NOCOUNT ON

SELECT
	m.id, s.receiver_name_list, m.title, m.content
FROM user_mail m (nolock), user_mail_sender s(nolock)
WHERE m.id = @mail_id
	AND s.mail_id = m.id

/*AND (m.id IN (SELECT mail_id FROM user_mail_receiver(nolock) WHERE receiver_id = @char_id)
OR m.id IN (SELECT mail_id FROM user_mail_sender(nolock) WHERE sender_id = @char_id))
*/

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pledge_master_transfer]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pledge_master_transfer](
	[pledge_id] [int] NOT NULL,
	[new_master_id] [int] NOT NULL,
	[status] [int] NOT NULL,
	[status_time] [datetime] NOT NULL CONSTRAINT [DF__pledge_ma__statu__02BE139F]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pledge_master_transfer]') AND name = N'IX_pledge_master_transfer')
CREATE NONCLUSTERED INDEX [IX_pledge_master_transfer] ON [dbo].[pledge_master_transfer] 
(
	[pledge_id] ASC,
	[status] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WithdrawPremiumItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_WithdrawPremiumItem]
(
@item_dbid	INT,
@char_id	INT,
@warehouse_no	BIGINT,
@amount		BIGINT
)
AS
SET NOCOUNT ON

BEGIN TRAN
DECLARE @item_remain INT

SELECT @item_remain = item_remain FROM user_premium_item (NOLOCK) WHERE warehouse_no = @warehouse_no

IF @item_remain < @amount
BEGIN
	RAISERROR(''Remained amount[%d] is below than request[%d]'', 16, 1, @item_remain, @amount)
	ROLLBACK TRAN
	SELECT 0
	RETURN
END

UPDATE user_premium_item
SET item_remain = item_remain - @amount
WHERE warehouse_no = @warehouse_no

INSERT INTO user_premium_item_receive (warehouse_no, real_recipient_char_id, item_dbid, item_amount, receive_date)
VALUES (@warehouse_no, @char_id, @item_dbid, @amount, GETDATE())

IF @@ERROR = 0
BEGIN
	COMMIT TRAN
	SELECT 1
END
ELSE
BEGIN
	ROLLBACK TRAN
	SELECT 0
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AllianceWarChallengeRejected]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_AllianceWarChallengeRejected
	
INPUT	
	@challenger int, 
	@challenger_name nvarchar(50),
	@challengee int, 
	@challengee_name nvarchar(50),
	@begin_time int, 
	@status int
OUTPUT
return
made by
	bert
date
	2003-11-04
********************************************/
create PROCEDURE [dbo].[lin_AllianceWarChallengeRejected]
(
	@challenger int, 
	@challenger_name nvarchar(50),
	@challengee int, 
	@challengee_name nvarchar(50),
	@begin_time int, 
	@status int
)
AS
SET NOCOUNT ON

INSERT INTO alliance_war (challenger, challenger_name,  challengee, challengee_name, begin_time, status) 
VALUES (@challenger, @challenger_name,  @challengee, @challengee_name, @begin_time, @status)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateNpcBossVariable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- kuooo
CREATE PROCEDURE [dbo].[lin_UpdateNpcBossVariable]
(
	@npc_name 	nvarchar(50),
	@i0		int
)
AS
SET NOCOUNT ON
UPDATE npc_boss	
SET 
i0 = @i0
where npc_db_name = @npc_name

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSSQTopPointUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_LoadSSQTopPointUser
  * @brief SSQ top point user를 로드.
  *
  * @date 2004/12/08
  * @author sonai  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_LoadSSQTopPointUser] 
(
@ssq_round INT
)
AS

SELECT ssq_round, record_id, ssq_point, rank_time, char_id, char_name, ssq_part, ssq_position, seal_selection_no
			FROM ssq_top_point_user  WHERE ssq_round  = @ssq_round

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pledge_Crest]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Pledge_Crest](
	[crest_id] [int] IDENTITY(1,1) NOT NULL,
	[bitmap_size] [smallint] NOT NULL CONSTRAINT [DF_Pledge_Crest_bitmap_size]  DEFAULT ((0)),
	[bitmap] [varbinary](3072) NULL,
 CONSTRAINT [PK_Pledge_Crest] PRIMARY KEY CLUSTERED 
(
	[crest_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitAuctionPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitAuctionPrice]
	@auction_price	bigint,
	@agit_id	int
as
set nocount on

UPDATE agit SET auction_price = @auction_price WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FlushQuestName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_FlushQuestName    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_FlushQuestName
	delete Quest name data
INPUT
OUTPUT
return
made by
	carrot
date
	2002-10-8
********************************************/
CREATE PROCEDURE [dbo].[lin_FlushQuestName]
AS
SET NOCOUNT ON

TRUNCATE TABLE QuestData

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DecayBotReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [dbo].[lin_DecayBotReport]
(
	@char_id int,
	@minus int,
	@reported_date int
)
as
SET NOCOUNT ON

UPDATE bot_report
SET reported = reported - @minus, reported_date = @reported_date
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bossrecord_round]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[bossrecord_round](
	[round_number] [int] NOT NULL,
	[start_time] [int] NOT NULL,
	[end_time] [int] NOT NULL,
 CONSTRAINT [PK_bossrecord_round] PRIMARY KEY CLUSTERED 
(
	[round_number] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CheckCharMove]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CheckCharMove
	check char move
INPUT

OUTPUT

return
made by
	young, kks
date
	2004-09-13
	2004-10-19
********************************************/
CREATE PROCEDURE [dbo].[lin_CheckCharMove]
	@old_char_name	nvarchar(50),
	@new_char_name	nvarchar(50),
	@old_char_id		int,
	@account_name	nvarchar(50),
	@account_id		int,
	@old_world_id		int,
	@new_world_id		int

AS
SET NOCOUNT ON

declare @req_new_count	int
declare @req_old_count		int
declare @old_quota_over 	int
declare @request_old_quota	int
declare @new_quota_over 	int
declare @request_new_quota	int
declare @pc_account_id		int

-- check pc-bang account id
set @pc_account_id = 0

select @pc_account_id = account_id from pc_account_move (nolock) where account_id = @account_id


if (@pc_account_id = 0)
begin
	-- check quota_over field
	-- old world quota
	set @request_old_quota = 500
	set @old_quota_over = 1

	select top 1 @old_quota_over = quota_over, @request_old_quota = quota_count from request_old_quota  (nolock) where old_world_id = @old_world_id

	if ( @old_quota_over = 1 ) 
	begin
	-- world quota is over
		select -3
		return -1
	end

	-- new world quota
	set @request_new_quota = 12000
	set @new_quota_over = 1

	select top 1 @new_quota_over = quota_over, @request_new_quota = quota_count from request_new_quota  (nolock) where new_world_id = @new_world_id

	if ( @new_quota_over = 1 ) 
	begin
	-- world quota is over
		select -3
		return -1
	end
end else 
if (not exists( select top 1 quota_over from request_old_quota  (nolock) where old_world_id = @old_world_id))
begin
-- not char movable old world
	select -3
	return -1
end

-- check req_charmove table
if ( exists( select new_char_name from req_charmove (nolock) where account_id = @account_id    ) ) 
begin
--	already requested
	select -2
	RETURN -1	
end


if (@pc_account_id = 0) 
begin
	select @req_old_count =  count(*) from req_charmove (nolock) where old_world_id = @old_world_id
	if ( @req_old_count >= @request_old_quota)
	begin
		select -3

		return -1
	end

	set @req_new_count = 0
	set @req_old_count = 0

	select @req_new_count =  count(*) from req_charmove (nolock) where new_world_id = @new_world_id
	if ( @req_new_count >= @request_new_quota)
	begin
		select -3

		return -1
	end
end

-- check new_char_name string can be used
IF @new_char_name LIKE N'' '' 
BEGIN
--	this char name is prohibited word
	select -1
	RETURN -1
END

-- check new_char_name string can be used
if exists(select char_name from user_prohibit (nolock) where char_name = @new_char_name)
begin
--	this char name is prohibited word
	select -1
	RETURN -1	
end

-- check new_char_name string can be used
if ( exists ( select words from user_prohibit_word (nolock) where @new_char_name like ''%'' +  words  + ''%'' ) ) 
begin
--	this char name contain  prohibited word
	select -1
	RETURN -1	
end


-- check wheather new_char_name string is already requested or not
if ( exists( select new_char_name from req_charmove (nolock) where new_char_name = @new_char_name  and new_world_id = @new_world_id  ) ) 
begin
--	this char name, new world id has been requested
	select -1
	RETURN -1	
end


select 1
return

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetCharByAccountId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetCharByAccountId    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetCharByAccountId

INPUT
	@account_id	INT
OUTPUT
return
made by
	young
date
	2003-09-17
********************************************/
CREATE PROCEDURE [dbo].[lin_GetCharByAccountId]
(
@account_id	INT
)
AS
SET NOCOUNT ON

IF @account_id > 0
	SELECT char_id, account_id, char_name , account_name  FROM User_data WHERE account_id = @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharClear]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************************
#Name:	lin_MoveCharClear
#Desc:	clear moved characters

#Argument:
	Input:	@world_id	int
	Output:	
#Return:
#Result Set:

#Remark:
#Example:	exec lin_MoveCharClear 3
#See:

#History:
	Create	btwinuni	2005-12-14
******************************************************************************/
CREATE PROCEDURE [dbo].[lin_MoveCharClear]
	@world_id	int
AS

SET NOCOUNT ON

-- change character''s info to moved character
update user_data set account_id = -3
where account_id in ( select account_id from dbo.req_account_move (nolock) where old_world_id = @world_id and is_deleted = 0 )
	and account_id > 0

exec lin_CleanUpGhostData

SET  NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[control_tower]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[control_tower](
	[name] [varchar](256) NOT NULL,
	[residence_id] [int] NOT NULL,
	[control_level] [int] NULL CONSTRAINT [DF__control_t__contr__33F57C80]  DEFAULT ((0)),
	[hp] [int] NOT NULL,
	[status] [int] NOT NULL,
 CONSTRAINT [PK__control_tower__12B3B8EF] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_StopPledgeWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_StopPledgeWar    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_StopPledgeWar
-- by bert

CREATE PROCEDURE
[dbo].[lin_StopPledgeWar] (@proposer_pledge_id INT, @proposee_pledge_id INT, @war_id INT,  @war_end_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

UPDATE Pledge_War
SET status = 1,	-- WAR_END_STOP
winner = 0,
end_time = @war_end_time
WHERE
id = @war_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = @war_id
END
ELSE
BEGIN
	SELECT @ret = 0
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_nobless]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_nobless](
	[char_id] [int] NOT NULL,
	[nobless_type] [tinyint] NULL CONSTRAINT [DF__user_nobl__noble__4BCD0611]  DEFAULT ((0)),
	[hero_type] [tinyint] NULL CONSTRAINT [DF__user_nobl__hero___4CC12A4A]  DEFAULT ((0)),
	[win_count] [int] NULL CONSTRAINT [DF__user_nobl__win_c__4DB54E83]  DEFAULT ((0)),
	[previous_point] [int] NULL CONSTRAINT [DF__user_nobl__previ__4EA972BC]  DEFAULT ((0)),
	[olympiad_point] [int] NULL CONSTRAINT [DF__user_nobl__olymp__4F9D96F5]  DEFAULT ((0)),
	[match_count] [int] NULL CONSTRAINT [DF__user_nobl__match__5091BB2E]  DEFAULT ((0)),
	[words] [varchar](128) NULL,
	[olympiad_win_count] [int] NULL CONSTRAINT [DF__user_nobl__olymp__5185DF67]  DEFAULT ((0)),
	[olympiad_lose_count] [int] NULL CONSTRAINT [DF__user_nobl__olymp__527A03A0]  DEFAULT ((0)),
	[history_open] [tinyint] NULL CONSTRAINT [DF__user_nobl__histo__536E27D9]  DEFAULT ((0)),
	[trade_point] [int] NOT NULL CONSTRAINT [DF__user_nobl__trade__18AD54BE]  DEFAULT ((0)),
 CONSTRAINT [PK__user_nobless__23E9FD40] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetItemAuctionStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SetItemAuctionStatus
desc:	set auction status

history:	2007-04-23	created by btwinuni
*/
create procedure [dbo].[lin_SetItemAuctionStatus]
	@auction_id int,
	@auction_status int
as
set nocount on

update item_auction
set auction_status = @auction_status
where auction_id = @auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_comment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_comment](
	[char_name] [nvarchar](50) NULL,
	[char_id] [int] NULL,
	[comment_id] [int] IDENTITY(1,1) NOT NULL,
	[comment] [nvarchar](200) NULL,
	[comment_date] [datetime] NULL CONSTRAINT [DF_user_comment_comment_date]  DEFAULT (getdate()),
	[writer] [nvarchar](50) NULL,
	[deleted] [tinyint] NULL CONSTRAINT [DF_user_comment_deleted]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_comment]') AND name = N'IX_user_comment')
CREATE CLUSTERED INDEX [IX_user_comment] ON [dbo].[user_comment] 
(
	[char_id] ASC,
	[deleted] ASC,
	[comment_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_comment]') AND name = N'IX_user_comment_1')
CREATE NONCLUSTERED INDEX [IX_user_comment_1] ON [dbo].[user_comment] 
(
	[comment_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Alliance]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Alliance](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[master_pledge_id] [int] NOT NULL CONSTRAINT [DF__alliance__master__2B6A5820]  DEFAULT ((0)),
	[oust_time] [int] NOT NULL CONSTRAINT [DF__alliance__oust_t__2C5E7C59]  DEFAULT ((0)),
	[crest_id] [int] NOT NULL CONSTRAINT [DF__alliance__crest___443605EA]  DEFAULT ((0)),
 CONSTRAINT [PK_Alliance] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_premium_item](
	[warehouse_no] [bigint] NOT NULL,
	[buyer_id] [int] NOT NULL,
	[buyer_char_id] [int] NULL,
	[buyer_char_name] [nvarchar](50) NULL,
	[recipient_id] [int] NOT NULL,
	[recipient_char_id] [int] NULL,
	[recipient_char_name] [nvarchar](50) NULL,
	[server_receive_date] [datetime] NOT NULL CONSTRAINT [DF_premium_service_server_receive_date]  DEFAULT (getdate()),
	[item_id] [int] NOT NULL,
	[item_amount] [bigint] NOT NULL,
	[item_remain] [bigint] NOT NULL,
	[ibserver_delete_date] [datetime] NULL,
 CONSTRAINT [PK_user_premium_item] PRIMARY KEY CLUSTERED 
(
	[warehouse_no] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item]') AND name = N'IX_user_premium_item_recipient_id')
CREATE NONCLUSTERED INDEX [IX_user_premium_item_recipient_id] ON [dbo].[user_premium_item] 
(
	[recipient_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddProhibit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_AddProhibit    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_AddProhibit
	
INPUT	
	@char_name	nvarchar(50)
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
CREATE PROCEDURE [dbo].[lin_AddProhibit]
(
	@char_name	nvarchar(50),
	@noption	int
)
AS
SET NOCOUNT ON

if ( @noption = 1) 
	insert into user_prohibit values (@char_name)
else if ( @noption = 3)
	insert into user_prohibit_word values (@char_name)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModifyTempMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModifyTempMail
	modify temp mail 
INPUT
	@char_id		int,
	@mail_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
OUTPUT
return
made by
	kks
date
	2004-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_ModifyTempMail]
(
	@char_id		int,
	@mail_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
)
AS
SET NOCOUNT ON

UPDATE user_mail
SET title = @title,
	content = @content,
	created_date = GETDATE()
WHERE id = @mail_id

UPDATE user_mail_sender
SET receiver_name_list = @receiver_name_list,
	send_date = GETDATE()
WHERE 
	mail_id = @mail_id AND 
	sender_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[field_cycle]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[field_cycle](
	[field_id] [int] NOT NULL,
	[point] [int] NOT NULL,
	[step] [int] NOT NULL,
	[step_changed_time] [int] NOT NULL,
	[point_changed_time] [int] NOT NULL,
	[accumulated_point] [int] NOT NULL,
 CONSTRAINT [PK__field_cycle__6D849645] PRIMARY KEY CLUSTERED 
(
	[field_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateCharWithSubjob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_CreateCharWithSubjob
desc:	create user_data, quest, user_slot with subjob

history:	2005-07-28	created by btwinuni
	2005-09-07	modified by btwinuni	main_class -> subjob0_class
	2005-11-17	modified by btwinuni
	2006-01-25	modified by btwinuni	exp: int -> bigint
	2007-03-30	modified by btwinuni
*/
create procedure [dbo].[lin_CreateCharWithSubjob]  
(  
	@char_name	nvarchar(24),
	@account_name	nvarchar(24),
	@account_id	int,
	@pledge_id	int,
	@builder		tinyint,
	@gender	tinyint,
	@race		tinyint,
	@class		tinyint,
	@world		smallint,
	@xloc		int,
	@yloc		int,
	@zloc		int,
	@HP		float,
	@MP		float,
	@SP		int,
	@Exp		bigint,
	@Lev		tinyint,
	@align		smallint,
	@PK		int,
	@Duel		int,
	@PKPardon	int,
	@FaceIndex	int = 0,
	@HairShapeIndex	int = 0,
	@HairColorIndex	int = 0,
	@SubjobID	int = -1,
	@MainClass	int = -1,
	@CP	float = 0
)
as

set nocount on

declare @char_id int
exec @char_id = lin_CreateChar @char_name, @account_name, @account_id, @pledge_id, @builder, @gender,
	@race, @class, @world, @xloc, @yloc, @zloc, @HP, @MP, @SP, @Exp, @Lev, @align, @PK, @Duel,
	@PKPardon, @FaceIndex, @HairShapeIndex, @HairColorIndex

if @char_id > 0
begin
	update user_data
	set subjob_id = @SubjobID,
		subjob0_class = @MainClass,
		cp = @CP,
		max_cp = @CP
	where char_id = @char_id
end

select @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateCursedWeapon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE    procedure [dbo].[lin_UpdateCursedWeapon]
(
	@item_id		int,
	@kill_point	int,
	@last_kill_date	int,
	@expired_date	int,
	@char_id	int,
	@total_pk	int
)
as
set nocount on
update cursed_weapon
	set kill_point=@kill_point, last_kill_date=@last_kill_date, expired_date=@expired_date, char_id=@char_id, total_pk=@total_pk
	where item_id=@item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_rank]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbl_rank](
	[char_id] [int] NULL,
	[rank] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetTeamBattleStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetTeamBattleStatus]
(
@agit_id INT,
@new_team_battle_status INT
)
AS
SET NOCOUNT ON
UPDATE agit SET team_battle_status = @new_team_battle_status WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAirShip]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadAirShip]
AS
SET NOCOUNT ON

SELECT airship_id, airship_type, owner_id, airship_fuel, airship_typeid
FROM airship (nolock)
WHERE deleted = 0

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveSSQTopPointUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_SaveSSQTopPointUser
  * @brief 타임 어택 정보 저장.
  *
  * @date 2004/12/09
  * @author Seongeun Park  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_SaveSSQTopPointUser] 
(
@ssq_round INT,
@record_id INT,

@ssq_point INT,
@rank_time INT,
@char_id  INT,
@char_name NVARCHAR(50),
@ssq_part TINYINT,
@ssq_position TINYINT,
@seal_selection_no TINYINT
)
AS

SET NOCOUNT ON

UPDATE ssq_top_point_user  SET  ssq_point = @ssq_point,
				    rank_time = @rank_time,
				    char_id = @char_id,
				    char_name = @char_name,
				    ssq_part = @ssq_part,
				    ssq_position = @ssq_position,
				    seal_selection_no = @seal_selection_no,
				    last_changed_time = GETDATE()
				                       
  	                   WHERE record_id = @record_id AND ssq_round = @ssq_round

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetInitBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetInitBoard    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetInitBoard
	
INPUT
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_GetInitBoard]
--(
--	@account_name	nvarchar(50)
--)
AS
SET NOCOUNT ON

select 
	board_id, board_name, board_desc, board_order 
from 
	bbs_board (nolock) 
where 
	viewable = 1 
order by 
	board_order desc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monrace_mon]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[monrace_mon](
	[runner_id] [int] NULL,
	[initial_win] [smallint] NULL CONSTRAINT [DF_monrace_mon_initial_win]  DEFAULT ((0)),
	[run_count] [int] NULL CONSTRAINT [DF_monrace_mon_run_count]  DEFAULT ((0)),
	[win_count] [int] NULL CONSTRAINT [DF_monrace_mon_win_count]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_newbie]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_newbie](
	[account_id] [int] NOT NULL,
	[char_id] [int] NOT NULL CONSTRAINT [DF_user_newbie_char_id]  DEFAULT ((0)),
	[newbie_stat] [smallint] NOT NULL,
 CONSTRAINT [PK_user_newbie] PRIMARY KEY CLUSTERED 
(
	[account_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadCastleCrop]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadCastleCrop    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadCastleCrop
	
INPUT	
	@castle_id	int,
OUTPUT
	item_type, 
	droprate, 
	price, 
	level 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_LoadCastleCrop]
(
	@castle_id	int
)
AS
SET NOCOUNT ON

SELECT 
	item_type, droprate, price, level 
from 
	castle_crop (nolock)  
WHERE 
	castle_id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPledgeCastleSiegeDefenceCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE
[dbo].[lin_SetPledgeCastleSiegeDefenceCount] (
	@pledge_id		int,
	@siege_count int
)
AS

update pledge
set castle_siege_defence_count = @siege_count
where pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPetitionMsg]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetPetitionMsg    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetPetitionMsg
	store Petition Msg
INPUT
	@char_id	int,
	@msg	nvarchar(500)
OUTPUT

return
made by
	carrot
date
	2003-02-27
********************************************/
CREATE PROCEDURE [dbo].[lin_SetPetitionMsg]
(
	@char_id	int,
	@msg	nvarchar(500)
)
AS
SET NOCOUNT ON

if exists(select * from PetitionMsg where char_id =@char_id)
begin
	update PetitionMsg set msg = @msg where char_id = @char_id
end 
else 
begin
	insert into PetitionMsg  (char_id, msg) 
	values( @char_id, @msg)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[class_by_race]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[class_by_race](
	[class] [int] NOT NULL,
	[race] [int] NOT NULL,
	[sex] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SavePCCafePoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_SavePCCafePoint   
 INPUT            
 @char_id INT
 @nPoint  INT            
OUTPUT            
return            
           
made by            
	mgpark
date            
 2006-01-16    

********************************************/            
CREATE PROCEDURE [dbo].[lin_SavePCCafePoint]    
(            
 @char_id INT,
 @point INT
)            
AS            
            
SET NOCOUNT ON            

IF (@point < 0)            
BEGIN            
    RAISERROR (''Not valid parameter : char id[%d] point[%d]'',  @char_id,  @point)
    RETURN -1            
END            



IF EXISTS(SELECT * FROM  user_pccafe_point WHERE char_id = @char_id)
BEGIN
	UPDATE  user_pccafe_point SET point = @point
	WHERE char_id = @char_id
END
ELSE
BEGIN
	INSERT INTO user_pccafe_point (char_id, point) 
	VALUES (@char_id, @point)    	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteMasterRelatedCastleWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE  [dbo].[lin_DeleteMasterRelatedCastleWar] 
(
	@pledge_id INT
)  
AS  
  
SET NOCOUNT ON  

IF EXISTS(SELECT * FROM castle_war WHERE pledge_id = @pledge_id) 
BEGIN
	DELETE  
	FROM castle_war  
	WHERE pledge_id = @pledge_id  
END
ELSE
BEGIN
	RAISERROR (''pledge id is not exist in castle_war.[%d]'', 16, 1, @pledge_id)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteNRMemo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteNRMemo] 
(
	@char_id int,
	@quest_id int
)
AS

SET NOCOUNT ON

DELETE FROM user_nr_memo
WHERE char_id = @char_id AND quest_id = @quest_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RPSnapSSQData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RPSnapSSQData
Snap SSQDataTable from world DB

#argument	@db_server	varchar(30)	name of database server
#argument	@user_id	varchar(30)	user id
#argument	@user_pass	varchar(30)	user password
#argument	@table_to	varchar(60)	report table to be a destination
#return
#result_set
#remark
#example	lin_RPSnapSSQData ''db_server'', ''gamma'', '''', RP_SNAPSSQDATA_8
#history	create	zzangse		2005-03-03
#see
********************************************/

CREATE            PROCEDURE [dbo].[lin_RPSnapSSQData]
	@db_server	varchar(30),
	@user_id	varchar(30),
	@user_pass	varchar(30),
	@table_to	varchar(60)

AS
SET NOCOUNT ON

declare @sql varchar(4000)
declare @dttoday datetime
declare @log_datetime_today varchar(12)

set @dttoday = getdate()

set @log_datetime_today = cast(convert(varchar(8), @dttoday , 112 ) as varchar(8)) 

-- check table whether @table_to exists or not
set @sql = ''select * from lin2report.dbo.sysobjects (nolock) where name = '''''' + @table_to + ''''''''
exec (@sql)

if (@@ROWCOUNT = 0)
begin
	set @sql = ''CREATE TABLE dbo.'' + @table_to + '' ('' 
		+ '' log_datetime		int,''
		+ '' round_number		int, ''
		+ '' status		tinyint, ''
		+ '' winner		tinyint, ''
		+ '' event_start_time	int, ''
		+ '' seal_effect_time	int, ''
		+ '' event_end_time	int, ''
		+ '' seal_effect_end_time	int, ''
		+ '' seal1			tinyint, ''
		+ '' seal2			tinyint, ''
		+ '' seal3			tinyint, ''
		+ '' seal4			tinyint, ''
		+ '' seal5			tinyint, ''
		+ '' seal6			tinyint, ''
		+ '' seal7			tinyint, ''
		+ '' last_changed_time	datetime, ''
		+ '' castle_snapshot_time	int, ''
		+ '' can_drop_guard	int ''
		+ '' ) ''
	exec (@sql)

	set @sql = ''CREATE clustered INDEX IX_'' + @table_to + ''_1 on dbo.'' + @table_to + '' (log_datetime desc) with fillfactor = 90 ''
	exec (@sql)
end
else begin
	set @sql = ''delete from dbo.'' + @table_to + '' where log_datetime = '' + @log_datetime_today
	exec (@sql)
end

-- insert into report table
set @sql = ''insert into '' + RTRIM(@table_to) +  
	+ '' select '' + @log_datetime_today  + '', * ''
	+ ''from OPENROWSET ( ''''SQLOLEDB'''', '''''' + @db_server + '''''';'''''' + @user_id + '''''';'''''' + @user_pass  + '''''',  ''''select * from lin2world.dbo.ssq_data (nolock) where round_number in (select max(round_number) from lin2world.dbo.ssq_data (nolock))'''') '' 
	+ '' option (MAXDOP 1 ) ''
exec (@sql )

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ssq_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ssq_data](
	[round_number] [int] NOT NULL,
	[status] [tinyint] NOT NULL,
	[winner] [tinyint] NOT NULL,
	[event_start_time] [int] NOT NULL,
	[seal_effect_time] [int] NOT NULL,
	[event_end_time] [int] NOT NULL,
	[seal_effect_end_time] [int] NOT NULL,
	[seal1] [tinyint] NOT NULL,
	[seal2] [tinyint] NOT NULL,
	[seal3] [tinyint] NOT NULL,
	[seal4] [tinyint] NOT NULL,
	[seal5] [tinyint] NOT NULL,
	[seal6] [tinyint] NOT NULL,
	[seal7] [tinyint] NOT NULL,
	[last_changed_time] [datetime] NOT NULL,
	[castle_snapshot_time] [int] NULL,
	[can_drop_guard] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Academy]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Academy](
	[pledge_id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[created_date] [datetime] NOT NULL CONSTRAINT [DF__Academy__created__6715F92A]  DEFAULT (getdate()),
 CONSTRAINT [PK_Academy] PRIMARY KEY CLUSTERED 
(
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[req_pledge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[req_pledge](
	[server_id] [int] NULL,
	[pledge_id] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllAuction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadAllAuction
desc:	load all auction

history:	2007-04-10	created by btwinuni
*/
create procedure [dbo].[lin_LoadAllAuction]
	@limit_time int
as
set nocount on

select auction_id, auction_type, auction_status, extend_status, auction_npc, start_time, end_time, init_price, immediate_price, item_type, item_id, item_amount, item_owner
from item_auction(nolock) 
where start_time > @limit_time

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadCursedWeaponList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE      PROCEDURE [dbo].[lin_LoadCursedWeaponList]
AS

SET NOCOUNT ON

select item_id, create_date, last_kill_date, expired_date, kill_point, char_id, item_class_id, original_pk, total_pk
	from cursed_weapon

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[itemData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[itemData](
	[item_type] [int] NOT NULL,
	[can_move] [bit] NOT NULL DEFAULT ((0)),
	[is_stackable] [bit] NOT NULL DEFAULT ((0)),
	[is_period] [bit] NOT NULL DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateAcademy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateAcademy
	create pledge academy
INPUT
	@pledge_id		int
	@name			nvarchar(50)
OUTPUT

return

date
	2006-03-02	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_CreateAcademy] (
@pledge_id INT,
@name NVARCHAR(50)
)
AS

SET NOCOUNT ON

BEGIN TRAN

IF @name LIKE N'' ''   
BEGIN  
 RAISERROR (''academy name has space : name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END  
  
-- check user_prohibit   
IF EXISTS(SELECT char_name FROM user_prohibit (nolock) WHERE char_name = @name)  
BEGIN
 RAISERROR (''academy name is prohibited: name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END

DECLARE @user_prohibit_word NVARCHAR(20)  
SELECT TOP 1 @user_prohibit_word = words FROM user_prohibit_word (nolock) WHERE PATINDEX(''%'' + words + ''%'', @name) > 0   
IF @user_prohibit_word IS NOT NULL
BEGIN
 RAISERROR (''academy name has prohibited word: name = [%s], word[%s]'', 16, 1, @name, @user_prohibit_word)  
 GOTO EXIT_TRAN
END

INSERT INTO Academy (pledge_id, name) VALUES (@pledge_id, @name)

EXIT_TRAN:
IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_data_ex]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_data_ex](
	[char_id] [int] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dismiss_penalty_reserved] [int] NULL,
 CONSTRAINT [PK_user_data_ex] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fishing_event_time]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[fishing_event_time](
	[starttime] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_list]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_list](
	[id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RequestCharMove]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RequestCharMove
	request char move
INPUT

OUTPUT

return
made by
	young, kks
date
	2003-07-25
	2004-08-23
	2004-10-19
********************************************/
CREATE PROCEDURE [dbo].[lin_RequestCharMove]
	@old_char_name	nvarchar(50),
	@new_char_name	nvarchar(50),
	@old_char_id		int,
	@account_name	nvarchar(50),
	@account_id		int,
	@old_world_id		int,
	@new_world_id		int

AS
SET NOCOUNT ON

declare @req_new_count	int
declare @req_old_count		int
declare @old_quota_over 	int
declare @request_old_quota	int
declare @new_quota_over 	int
declare @request_new_quota	int
declare @pc_account_id		int

-- check pc-bang account id
set @pc_account_id = 0

select @pc_account_id = account_id from pc_account_move (nolock) where account_id = @account_id


if (@pc_account_id = 0)
begin

	-- check quota_over field
	-- old world quota
	set @request_old_quota = 500
	set @old_quota_over = 1

	select top 1 @old_quota_over = quota_over, @request_old_quota = quota_count from request_old_quota  (nolock) where old_world_id = @old_world_id

	if ( @old_quota_over = 1 ) 
	begin
	-- world quota is over
		select -3
		return -1
	end

	-- new world quota
	set @request_new_quota = 12000
	set @new_quota_over = 1

	select top 1 @new_quota_over = quota_over, @request_new_quota = quota_count from request_new_quota  (nolock) where new_world_id = @new_world_id

	if ( @new_quota_over = 1 ) 
	begin
	-- world quota is over
		select -3
		return -1
	end
end else 
if (not exists( select top 1 quota_over from request_old_quota  (nolock) where old_world_id = @old_world_id))
begin
-- not char movable old world
	select -3
	return -1
end

-- check req_charmove table
if ( exists( select new_char_name from req_charmove (nolock) where account_id = @account_id    ) ) 
begin
--	already requested
	select -2
	RETURN -1	
end

if (@pc_account_id = 0)
begin
	select @req_old_count =  count(*) from req_charmove (nolock) where old_world_id = @old_world_id and is_pc_bang = 0
	if ( @req_old_count >= @request_old_quota)
	begin
		select -3

		update request_old_quota set quota_over  = 1 where old_world_id = @old_world_id

		return -1
	end

	set @req_new_count = 0
	set @req_old_count = 0

	select @req_new_count =  count(*) from req_charmove (nolock) where new_world_id = @new_world_id and is_pc_bang = 0
	if ( @req_new_count >= @request_new_quota)
	begin
		select -3

		update request_new_quota set quota_over  = 1 where new_world_id = @new_world_id

		return -1
	end
end

-- check new_char_name string can be used
IF @new_char_name LIKE N'' '' 
BEGIN
--	this char name is prohibited word
	select -1
	RETURN -1
END

-- check new_char_name string can be used
if exists(select char_name from user_prohibit (nolock) where char_name = @new_char_name)
begin
--	this char name is prohibited word
	select -1
	RETURN -1	
end

-- check new_char_name string can be used
if ( exists ( select words from user_prohibit_word (nolock) where @new_char_name like ''%'' +  words  + ''%'' ) ) 
begin
--	this char name contain  prohibited word
	select -1
	RETURN -1	
end


-- check wheather new_char_name string is already requested or not
if ( exists( select new_char_name from req_charmove (nolock) where new_char_name = @new_char_name  and new_world_id = @new_world_id  ) ) 
begin
--	this char name, new world id has been requested
	select -1
	RETURN -1	
end

if (@pc_account_id = 0) 
begin
	insert into req_charmove ( old_char_name, old_char_id, account_name, account_id, old_world_id, new_world_id, new_char_name, is_pc_bang)
	values ( @old_char_name, @old_char_id, @account_name, @account_id, @old_world_id, @new_world_id , @new_char_name, 0 )
end else
begin
	insert into req_charmove ( old_char_name, old_char_id, account_name, account_id, old_world_id, new_world_id, new_char_name, is_pc_bang)
	values ( @old_char_name, @old_char_id, @account_name, @account_id, @old_world_id, @new_world_id , @new_char_name, 1 )
end

select 1
return

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CheckPreviousWarHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CheckPreviousWarHistory    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_CheckPreviousWarHistory
	
INPUT	
	@residence_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_CheckPreviousWarHistory]
(
	@challenger1		int,
	@challengee1		int,
	@challengee2		int,
	@challenger2		int
)
AS
SET NOCOUNT ON

SELECT 
	id, challenger, challengee, status, begin_time 
FROM 
	pledge_war (nolock)  
WHERE 
	(challenger = @challenger1 AND challengee = @challengee1) 
	OR (challengee = @challengee2 AND challenger = @challenger2) 
ORDER BY 
	begin_time DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelSkillCoolTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  PROCEDURE [dbo].[lin_DelSkillCoolTime]
(
	@char_id	INT,
	@subjob_id	INT,
	@skill_id		INT
)
AS
SET NOCOUNT ON

DELETE FROM user_skill_reuse_delay WHERE char_id = @char_id AND skill_id = @skill_id AND ISNULL(subjob_id, 0) = @subjob_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBotReportTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadBotReportTime] 
(
	@char_id int
)
AS

SET NOCOUNT ON

select reported_date
from bot_report T(nolock)
where char_id = @char_id

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateUserItemDuration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_UpdateUserItemDuration
	Update user''s total item duration
INPUT  
	@char_id	int,
	@duration	int,
OUTPUT  
 
return  
made by  
 kks
date  
 2006-10-31  
********************************************/  
CREATE   PROCEDURE [dbo].[lin_UpdateUserItemDuration]  
(
	@char_id	int,
	@duration	int
)
AS  
SET NOCOUNT ON  

UPDATE user_data
SET item_duration = @duration
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[team_battle_agit_member]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[team_battle_agit_member](
	[agit_id] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[propose_time] [int] NOT NULL,
 CONSTRAINT [tbam_uniq] UNIQUE NONCLUSTERED 
(
	[agit_id] ASC,
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveAirShip]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveAirShip]
	@airship_id int,
	@fuel int
AS
SET NOCOUNT ON

UPDATE airship
SET airship_fuel = @fuel
WHERE airship_id = @airship_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WithdrawItemAuctionBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_WithdrawItemAuctionBid
desc:	withdraw bidding adena

history:	2007-04-16	created by btwinuni
*/
create procedure [dbo].[lin_WithdrawItemAuctionBid]
	@auction_id int,
	@bidder int,
	@flag int
as
set nocount on

declare @adena_sum bigint
set @adena_sum = 0

if @flag = 1
begin
	select @adena_sum = isnull(sum(isnull(bidding_price, 0)),0)
	from item_auction_bid (nolock)
	where auction_id = @auction_id
		and char_id = @bidder
		and withdraw = 0
end

update item_auction_bid
set withdraw = @flag
where auction_id = @auction_id
	and char_id = @bidder

if @@rowcount = 0
begin
	select 0
end
else
begin
	select @adena_sum
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetCancelServiceList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetCancelServiceList
desc:	copy applier list for cancel service from L2EventDB to world DB
exam:	exec lin_GetCancelServiceList ''''''server'''';''''login_id'''';''''password'''''', 1

history:	2006-08-29	created by btwinuni
*/
create procedure [dbo].[lin_GetCancelServiceList]
	@db_info	varchar(64),
	@server_id	int
as

set nocount on

declare @sql varchar(4000)

set @sql = ''insert into CancelServiceList (idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2)''
	+ '' select *''
	+ '' from openrowset(''''sqloledb'''', ''+@db_info+'',''
	+ ''	''''select idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2''
	+ ''	from L2EventDB.dbo.L2AddedService_temp (nolock)''
	+ ''	where fromServer = ''+cast(@server_id as varchar)+'''''')''
exec (@sql)

set nocount off

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[manor_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[manor_data](
	[manor_id] [int] NOT NULL,
	[data_index] [int] NOT NULL,
	[seed_id] [int] NOT NULL,
	[seed_price] [bigint] NOT NULL,
	[seed_sell_count] [bigint] NOT NULL,
	[seed_remain_count] [bigint] NOT NULL,
	[crop_id] [int] NOT NULL,
	[crop_buy_count] [bigint] NOT NULL,
	[crop_price] [bigint] NOT NULL,
	[crop_type] [int] NOT NULL,
	[crop_remain_count] [bigint] NOT NULL,
	[crop_deposit] [bigint] NOT NULL,
 CONSTRAINT [PK_manor_data] PRIMARY KEY CLUSTERED 
(
	[manor_id] ASC,
	[data_index] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ClearGroupPoint ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ClearGroupPoint
	
INPUT	
OUTPUT
return
made by
	young
date
	2004-07-15
********************************************/
create PROCEDURE [dbo].[lin_ClearGroupPoint ]

AS
SET NOCOUNT ON


delete from event_point

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Lin_GetSummary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.Lin_GetSummary    Script Date: 2003-09-20 오전 11:51:56 ******/
CREATE PROCEDURE [dbo].[Lin_GetSummary] 
AS

SET NOCOUNT ON

Select count(id) as Total from BBS_All

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCropData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SaveCropData    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SaveCropData
	create  or update castle crop data
INPUT
	@castle_id	INT,
	@item_type 	INT,
	@droprate 	INT,
	@price 	INT
OUTPUT
return
made by
	carrot
date
	2003-05-06
change 2003-06-11
	add level
********************************************/
CREATE PROCEDURE [dbo].[lin_SaveCropData]
(
	@castle_id	INT,
	@item_type 	INT,
	@droprate 	INT,
	@price 		INT,
	@level 		INT
)
AS
SET NOCOUNT ON

if exists(select item_type from castle_crop where castle_id = @castle_id and item_type = @item_type)
begin
	update castle_crop set droprate =@droprate, price = @price , level = @level where castle_id = @castle_id and item_type = @item_type
end
else
begin
	insert into  castle_crop (castle_id, item_type, droprate, price, level) values (@castle_id,@item_type,@droprate ,@price,@level )
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSendMailCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetSendMailCount
	get send mail count
INPUT
	@char_id		int

OUTPUT
return
made by
	kks
date
	2004-12-23
********************************************/
CREATE PROCEDURE [dbo].[lin_GetSendMailCount]
(
	@char_id		int
)
AS
SET NOCOUNT ON

SELECT COUNT(*)
FROM user_mail_sender(NOLOCK)
WHERE sender_id IN (SELECT char_id FROM user_data(nolock) WHERE account_id = (SELECT account_id FROM user_data (nolock) WHERE char_id = @char_id))
	AND mailbox_type = 1
	AND send_date BETWEEN CONVERT(DATETIME, CONVERT(NVARCHAR(10), GETDATE(), 120) + '' 00:00:00'') AND
		CONVERT(DATETIME, CONVERT(NVARCHAR(10), GETDATE(), 120) + '' 23:59:59'')

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadItemByItemId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadItemByItemId 
	
INPUT
	@item_id		INT
OUTPUT
return
made by
	carrot
date
	2002-06-10
modified by 
	kernel0
modified date 
	2006-10-16	
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadItemByItemId]
(
	@item_id		INT
)
AS
SET NOCOUNT ON

SELECT
	ui.char_id, ui.item_type, ui.amount, ui.enchant, ui.eroded, ui.bless, ui.ident, ui.wished, ui.warehouse, 
	isnull(ui.variation_opt1, 0),
	isnull(ui.variation_opt2, 0),
	isnull(ui.intensive_item_type, 0),
	isnull(ui.inventory_slot_index, -1),
	isnull(uia.attack_attribute_type, -2),
	isnull(uia.attack_attribute_value, 0),
	isnull(uia.defend_attribute_0, 0),
	isnull(uia.defend_attribute_1, 0),
	isnull(uia.defend_attribute_2, 0),
	isnull(uia.defend_attribute_3, 0),
	isnull(uia.defend_attribute_4, 0),
	isnull(uia.defend_attribute_5, 0)
FROM (select * from user_item (nolock) where item_id = @item_id) ui
	left join (select * from user_item_attribute where item_id = @item_id) uia on ui.item_id = uia.item_id
WHERE item_type > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitStatus]
	@status	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET status = @status WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_item_duration]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_item_duration](
	[item_id] [int] NOT NULL,
	[duration] [int] NOT NULL,
 CONSTRAINT [PK_user_item_duration] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteAcademyMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DeleteAcademyMember
	delete academy member
INPUT
	char_id		int,
	pledge_id	int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_DeleteAcademyMember] (
	@char_id		int,
	@pledge_id	int
)
AS

DELETE FROM academy_member
WHERE user_id = @char_id AND pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ReduceBotReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [dbo].[lin_ReduceBotReport]
(
	@reported_date int
)
as
SET NOCOUNT ON

UPDATE bot_report
SET reported = case 
	when reported <= 5 then 0 
	else reported-5 
	end
WHERE reported_date = @reported_date

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadTeamBattleAgitStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadTeamBattleAgitStatus]
(
	@agit_id INT
)
AS
SET NOCOUNT ON
SELECT ISNULL(team_battle_status, 0) FROM agit WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_EnableChar2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_EnableChar2
	Enable character
INPUT
	@char_id int,
	@account_id int
OUTPUT

return
made by
	kks
date
	2004-08-07
	enable character
********************************************/
CREATE PROCEDURE [dbo].[lin_EnableChar2]
(
@char_id int,
@account_id int
)
AS

SET NOCOUNT ON

declare @old_account_id int

select @old_account_id = account_id from user_data (nolock) where char_id = @char_id

if @old_account_id < 0
begin
	update user_data set account_id = @account_id where char_id = @char_id
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetItemData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetItemData    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetItemData
	
INPUT
	@id	int
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_GetItemData]
(
	@id	int
)
AS
SET NOCOUNT ON

select top 1 1

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPCCafePoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPCCafePoint
	
INPUT	
	@char_id int
OUTPUT
return
made by
	mgpark
date
	2006-01-16
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPCCafePoint]
(
	@char_id int
)
AS
SET NOCOUNT ON

SELECT point FROM user_pccafe_point  WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CheckAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CheckAccount
	check account
INPUT

OUTPUT

return
made by
	kks
date
	2004-10-19
********************************************/
CREATE PROCEDURE [dbo].[lin_CheckAccount]
(
	@account_id INT
)
AS
SET NOCOUNT ON

SELECT account_id  FROM req_charmove (nolock) WHERE account_id = @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ssq_user_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ssq_user_data](
	[char_id] [int] NOT NULL,
	[round_number] [int] NOT NULL,
	[ssq_part] [tinyint] NOT NULL,
	[ssq_position] [tinyint] NOT NULL,
	[seal_selection_no] [tinyint] NOT NULL,
	[ssq_join_time] [int] NOT NULL,
	[ssq_point] [bigint] NOT NULL,
	[twilight_a_item_num] [bigint] NOT NULL,
	[twilight_b_item_num] [bigint] NOT NULL,
	[twilight_c_item_num] [bigint] NOT NULL,
	[dawn_a_item_num] [bigint] NOT NULL,
	[dawn_b_item_num] [bigint] NOT NULL,
	[dawn_c_item_num] [bigint] NOT NULL,
	[ticket_buy_count] [tinyint] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ssq_user_data]') AND name = N'ix_ssq_user_data_1')
CREATE CLUSTERED INDEX [ix_ssq_user_data_1] ON [dbo].[ssq_user_data] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ssq_user_data]') AND name = N'ix_ssq_user_data_2')
CREATE NONCLUSTERED INDEX [ix_ssq_user_data_2] ON [dbo].[ssq_user_data] 
(
	[round_number] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddDbConnectionInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_AddDbConnectionInfo 
desc:   add db connection info to temp table for added server
exam:   exec lin_AddDbConnectionInfo 1, ''server'', ''user_id'', ''password''
 
history:        2007-01-24      created by neo 

*/ 
CREATE procedure [dbo].[lin_AddDbConnectionInfo] 
        @server_id       int,   -- Server ID
        @server        nvarchar(64),   
        @user_id      nvarchar(64),
        @password        nvarchar(64)
as 
 
set nocount on 
 
declare 
        @db_info        nvarchar(64),
        @sql                nvarchar(1000),
        @check_sql        nvarchar(1000)
 
if not exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[tmp_db_connections]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) 
begin
        create table[dbo]. tmp_db_connections (
                server_id	int        primary key,
                db_info        nvarchar(128)
        )
end

set @db_info = '''''''' + @server + '''''';'''''' + @user_id + '''''';'''''' + @password + ''''''''
set @check_sql = ''select top 1 char_id from lin2world.dbo.user_data''

set @sql = ''select ''''Connection is valid'''' from openrowset(''''sqloledb'''', ''+@db_info+'','' 
                                + ''     ''''''+ @check_sql +'''''')'' 
exec(@sql) 
if @@error <> 0
begin
        RAISERROR(''Invalid Connection Info!!'', 1, 1)
end
else
begin
        insert into [dbo].tmp_db_connections (server_id, db_info)
        values(@server_id, @db_info)
        if @@error <> 0
        RAISERROR(''Duplecated Connection Info!!'', 1, 1)
end

set nocount off

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[team_battle_agit_pledge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[team_battle_agit_pledge](
	[agit_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[propose_time] [int] NOT NULL,
	[color] [int] NOT NULL,
	[npc_type] [int] NOT NULL,
 CONSTRAINT [tbap_uniq] UNIQUE NONCLUSTERED 
(
	[agit_id] ASC,
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveKillDeath]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveKillDeath]
(
@pledge_id INT,
@kill_no INT,
@death_no INT
)
AS
SET NOCOUNT ON

UPDATE pledge
SET siege_kill = @kill_no, siege_death = @death_no
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddSubJobHenna]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_AddSubJobHenna
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@henna	int

OUTPUT
return
made by
	kks
date
	2005-01-18
********************************************/
CREATE PROCEDURE [dbo].[lin_AddSubJobHenna]
(
	@char_id	int,
	@subjob_id	int,
	@henna	int
)
AS
SET NOCOUNT ON

declare @henna1 int
declare @henna2 int
declare @henna3 int

set @henna1 = 0
set @henna2 = 0
set @henna3 = 0

select @henna1 = isnull(henna_1, 0), @henna2 = isnull(henna_2, 0), @henna3 = isnull(henna_3, 0) from user_subjob where char_id = @char_id and subjob_id = @subjob_id

if (@henna1 = 0)
begin
	update user_subjob set henna_1 = @henna where char_id = @char_id and subjob_id = @subjob_id
end
else if  (@henna2 = 0)
begin
	update user_subjob set henna_2 = @henna where char_id = @char_id and subjob_id = @subjob_id
end
else if (@henna3 = 0)
begin
	update user_subjob set henna_3 = @henna where char_id = @char_id and subjob_id = @subjob_id
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitStove]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitStove]
	@stove	int,
	@expire	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET hp_stove = @stove, hp_stove_expire = @expire WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[find_invalid_skill]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[find_invalid_skill](
	[char_id] [int] NULL,
	[char_name] [nvarchar](50) NULL,
	[subjob_id] [int] NULL,
	[subjob_class] [int] NULL,
	[skill_id] [int] NULL,
	[skill_lev] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteCastleWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeleteCastleWar    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_DeleteCastleWar
-- by kks

CREATE PROCEDURE
[dbo].[lin_DeleteCastleWar] (@pledge_id INT,  @castle_id INT)
AS
SET NOCOUNT ON

Delete from castle_war where pledge_id = @pledge_id and castle_id = @castle_id

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateItemAuctionBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_CreateItemAuctionBid
desc:	create item auction bid

history:	2007-04-16	created by btwinuni
*/
create procedure [dbo].[lin_CreateItemAuctionBid]
	@auction_id int,
	@bidder int,
	@price bigint
as
set nocount on

declare @bid_id int
declare @max_price bigint

select @max_price = isnull(max(bidding_price), 0)
from item_auction_bid (nolock)
where auction_id = @auction_id
	and withdraw = 0

if @max_price = 0 or @max_price < @price
begin
	insert into item_auction_bid(auction_id,char_id,bidding_price) values (@auction_id,@bidder,@price)
	if (@@error = 0)
	begin
		set @bid_id = @@identity
	end
end
else
begin
	set @bid_id = 0
end

select @bid_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadNRMemo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadNRMemo
desc:	Load NR Memo
exam:	exec lin_LoadNRMemo
history:	2008-03-19	created by Phyllion
*/
CREATE procedure [dbo].[lin_LoadNRMemo]
(
	@char_id int
)
as
SET NOCOUNT ON

select quest_id, state1, state2, journal
from user_nr_memo T(nolock)
where char_id = @char_id

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharSvr]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- drop procedure lin_MoveCharSvr

/********************************************
lin_MoveCharSvr
	move char
INPUT
	@world_id	int
OUTPUT

return
made by
	young
date
	2003-7-30
	2003-10-06
	2004-1-6
********************************************/
CREATE PROCEDURE [dbo].[lin_MoveCharSvr]
(
	@old_world_id		int,
	@new_world_id		int,
	@conn_str		varchar(100)
)
AS

SET NOCOUNT ON

declare @sql varchar(4000)

--	& '' OPENROWSET ( ''SQLOLEDB'', ''l2world01'';''dbid'';''password'', '' 


-- make user_data 

set @sql = '' insert into user_data ( '' 
	+ '' char_name, pledge_id, account_name, account_id, builder, gender, race, class, world, xloc, yloc, zloc,  '' 
	+ '' IsInVehicle, HP, MP, SP, Exp, Lev, align, PK, PKpardon, Duel, ST_underware, ST_right_ear, ST_left_ear, '' 
	+ '' ST_neck, ST_right_finger, ST_left_finger, ST_head, ST_right_hand, ST_left_hand, ST_gloves, ST_chest,  '' 
	+ '' ST_feet, ST_back, ST_both_hand, ST_legs, create_date, login, logout, quest_flag, power_flag, max_hp, max_mp, '' 
	+ '' quest_memo, face_index, hair_color_index,  hair_shape_index, use_time, drop_exp,  '' 
	+ '' surrender_war_id, pledge_withdraw_time, pledge_ousted_time, pledge_leave_status, pledge_leave_time, '' 
	+ '' pledge_dismiss_time , old_pledge_id, old_char_id '' 
	+ '' ) '' 
	+ '' select R2.new_char_name, 0, account_name, R1.account_id, builder, gender, race, class, world, xloc, yloc, zloc,  '' 
	+ '' IsInVehicle, HP, MP, SP, Exp, Lev, align, PK, PKpardon, Duel, 0, 0, 0, '' 
	+ '' 0, 0, 0, 0, 0, 0, 0, 0,  '' 
	+ '' 0, 0, 0, 0,  create_date, login, logout, quest_flag, power_flag, max_hp, max_mp, '' 
	+ '' quest_memo, face_index, hair_color_index, hair_shape_index, use_time, drop_exp,  '' 
	+ '' 0, 0, 0, 0, 0, '' 
	+ ''  0 , pledge_id, char_id '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select pledge_id, char_id, account_name, account_id, builder, gender, race, class, world, xloc, yloc, zloc,  '' 
	+ '' IsInVehicle, HP, MP, SP, Exp, Lev, align, PK, PKpardon, Duel, ST_underware, ST_right_ear, ST_left_ear, '' 
	+ '' ST_neck, ST_right_finger, ST_left_finger, ST_head, ST_right_hand, ST_left_hand, ST_gloves, ST_chest,  '' 
	+ '' ST_feet, ST_back, ST_both_hand, ST_legs,  create_date, login, logout, quest_flag, power_flag, max_hp, max_mp, '' 
	+ '' quest_memo, face_index, hair_color_index, hair_shape_index, use_time, drop_exp,  '' 
	+ '' surrender_war_id, pledge_withdraw_time, pledge_ousted_time, pledge_leave_status, pledge_leave_time, '' 
	+ '' pledge_dismiss_time '' 
	+ '' from '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.user_data (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' + CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_name, account_id, old_char_id from req_charmove (nolock) where old_world_id = '' + CAST ( @old_world_id as varchar) + '' and new_world_id = '' + cast ( @new_world_id  as varchar ) + '' )  '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 

select @sql

exec (@sql)

-- update char_id
set @sql = '' update r ''
	+ '' set r.new_char_id = u.char_id ''
	+ '' from req_charmove as r  inner join user_data as u ''
	+ '' on r.new_char_name = u.char_name ''
	+ '' where r.old_world_id = '' +  CAST ( @old_world_id as VARCHAR)  + '' and r.new_world_id = '' + CAST ( @new_world_id as varchar)   + ''  and u.account_id > 0  ''

exec (@sql)

-- update pledge in user_data table
set @sql = '' update r ''
	+ '' set r.pledge_id = u.pledge_id ''
	+ '' from user_data as r  inner join pledge as u ''
	+ '' on r.old_pledge_id = u.old_pledge_id ''
	+ '' where r.char_name like ''''%-'' +  CAST ( @old_world_id as VARCHAR)  + ''''''  and u.pledge_id is not null  ''
select @sql

exec (@sql)


-- update pledge owner in pledge table
set @sql = '' update r ''
	+ '' set r.ruler_id = u.char_id''
	+ '' from pledge as r  inner join user_data as u ''
	+ '' on r.old_ruler_id = u.old_char_id ''
	+ '' where r.old_world_id = '' +  CAST ( @old_world_id as VARCHAR)  + ''  and u.char_id is not null  ''

exec (@sql)


-- copy user_item
set @sql = '' insert into user_item (char_id, item_type, amount, enchant, eroded, bless,  ident, wished, warehouse, old_world_id, old_item_id ) ''
	+ '' select R2.new_char_id, R1.item_type, R1.amount, R1.enchant, R1.eroded, R1.bless, R1. ident, R1.wished, R1.warehouse, '' + CAST ( @old_world_id as varchar ) + '' , R1.item_id ''
	+ '' from ''
	+ '' ( ''
	+ '' select * from ''
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', ''
	+ '' '''' select * from lin2world.dbo.user_item (nolock) '''' ) ''
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +  CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + ''  ) ''
	+ '' ) as R1 ''
	+ '' left join ( select new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) ''
	+ '' as R2 ''
	+ '' on R1.char_id = R2.old_char_id ''
	+ '' where new_char_id is not null ''

exec (@sql)


-- copy user_skill
set @sql = '' insert into user_skill ( char_id, skill_id, skill_lev, to_end_time) ''
	+ '' select R2.new_char_id, R1.skill_id, R1.skill_lev, R1.to_end_time '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.user_skill (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +  CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 
	+ '' where new_char_id is not null '' 
exec (@sql)


-- copy quest
set @sql = '' insert into quest ( char_id, q1, s1, q2, s2, q3, s3, q4, s4, q5, s5, q6, s6, q7, s7, q8, s8, q9, s9, q10, s10, q11, s11, q12, s12, q13, s13, q14, s14, q15, s15, q16, s16) '' 
	+ '' select R2.new_char_id, q1, s1, q2, s2, q3, s3, q4, s4, q5, s5, q6, s6, q7, s7, q8, s8, q9, s9, q10, s10, q11, s11, q12, s12, q13, s13, q14, s14, q15, s15, q16, s16 '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.quest (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +  CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +  CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 
	+ '' where new_char_id is not null '' 

exec (@sql)


-- copy user_history
set @sql = '' insert into user_history( char_name, char_id, log_date, log_action, account_name, create_date) '' 
	+ '' select R2.new_char_name, R2.new_char_id, R1.log_date, R1.log_action, R1.account_name, R1.create_date '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.user_history (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_name, new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 
	+ '' where new_char_id is not null '' 

exec (@sql)


-- copy user_log
set @sql = '' insert into user_log  ( char_id, log_id, log_date, log_from, log_to, use_time ) ''
	+ '' select R2.new_char_id, log_id, log_date, log_from, log_to, use_time  '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.user_log  (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar)  + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR) + ''  and new_world_id = '' + CAST ( @new_world_id as varchar)  + ''  ) '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 
	+ '' where new_char_id is not null '' 
exec (@sql)


-- shortcut_data
set @sql = '' insert into shortcut_data ( char_id, slotnum, shortcut_type, shortcut_id, shortcut_macro ) '' 
	+ '' select R2.new_char_id, slotnum, shortcut_type, shortcut_id, shortcut_macro '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.shortcut_data (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR)  + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +  CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar)  + '' ) '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 
	+ '' where new_char_id is not null '' 
exec (@sql)


-- user_comment
set @sql = '' insert into user_comment ( char_name, char_id, comment, comment_date, writer, deleted ) '' 
	+ '' select R2.new_char_name, R2.new_char_id, comment, comment_date, writer, deleted  '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.user_comment  (nolock) '''' ) '' 
	+ '' where char_id in ( select old_char_id from req_charmove (nolock) where old_world_id = '' +   CAST ( @old_world_id as VARCHAR)  + '' and new_world_id = '' + CAST ( @new_world_id as varchar) + '' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ( select new_char_name, new_char_id , old_char_id from req_charmove (nolock) where old_world_id = '' +  CAST ( @old_world_id as VARCHAR) + '' and new_world_id = '' + CAST ( @new_world_id as varchar)  + '' ) '' 
	+ '' as R2 '' 
	+ '' on R1.char_id = R2.old_char_id '' 
	+ '' where new_char_id is not null '' 
exec (@sql)


-- pet_data
set @sql = '' insert into pet_data ( pet_id, npc_class_id, expoint, nick_name, hp, mp, sp, meal  ) '' 
	+ '' select item_id, npc_class_id, expoint, null, hp, mp, sp, meal   '' 
	+ '' from '' 
	+ '' ( select * from user_item (nolock) where item_type = 2375 and old_world_id = '' + CAST ( @old_world_id as varchar ) + '' ) as R1 ''
	+ '' left join ''
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select pet_id, npc_class_id, expoint, hp, mp, sp, meal  from lin2world.dbo.pet_data (nolock) '''' ) '' 
	+ '' ) as R2 '' 
	+ '' on R1.old_item_id = R2.pet_id ''
	+ '' where R2.npc_class_id is not null '' 
exec (@sql)



-- user_item owned by pet
set @sql = '' insert into user_item( char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse  ) '' 
	+ '' select R2.item_id, R1.item_type, R1.amount, R1.enchant, R1.eroded, R1.bless, R1.ident, R1.wished, R1.warehouse  '' 
	+ '' from '' 
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select * from lin2world.dbo.user_item (nolock) where warehouse = 5 '''' ) '' 
	+ '' ) as R1 '' 
	+ '' left join ''
	+ '' ( select * from user_item (nolock) where old_world_id = '' + CAST ( @old_world_id as varchar ) + '' ) as R2 ''
	+ '' on R1.char_id = R2.old_item_id ''
	+ '' where R2.item_id is not null ''

exec (@sql)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[account_ch2]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[account_ch2](
	[account] [varchar](50) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveClancommTransferResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveClancommTransferResult
desc:	save clancomm transfer result
exam:	exec lin_SaveClancommTransferResult @pledge_id, @result

history:	2006-06-15	created by btwinuni
*/
CREATE PROCEDURE [dbo].[lin_SaveClancommTransferResult]
	@pledge_id	int,
	@result		int
AS

SET NOCOUNT ON

-- if @result = 10 then success else if @result = 11 then failure
update pledge_master_transfer
set status = @result,
	status_time = getdate()
where status = 1
	and pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddCursedWeapon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE       procedure [dbo].[lin_AddCursedWeapon]
(
	@item_id		int,
	@create_date	int,
	@last_kill_date	int,
	@expired_date	int,
	@kill_point	float,
	@char_id	int,
	@item_class_id	int,
	@original_pk	int,
	@total_pk	int
)
as
set nocount on

select item_id from cursed_weapon
where item_id = @item_id

if(@@ROWCOUNT > 0)
	begin
		delete from cursed_weapon
		where item_id = @item_id
	end

insert into cursed_weapon(item_id, create_date, last_kill_date, expired_date, kill_point, char_id, item_class_id, original_pk, total_pk)
values (@item_id, @create_date, @last_kill_date, @expired_date, @kill_point, @char_id, @item_class_id, @original_pk, @total_pk)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetLastStartTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetLastStartTime
desc:	load last auction start time

history:	2007-04-16	created by btwinuni
*/
create procedure [dbo].[lin_GetLastStartTime]
	@auction_type int,
	@item_owner int
as
set nocount on

select isnull(max(start_time), 0)
from item_auction (nolock)
where item_owner = @item_owner
	and auction_type = @auction_type

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ReadBbsTGS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ReadBbsTGS    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_ReadBbsTGS] 
(
	@nId	INT
)
AS

SET NOCOUNT ON

select id, title, contents, writer, cast( cdate as smalldatetime)
from bbs_tgs (nolock)
where id = @nId

update bbs_tgs set nRead = nRead + 1 where id = @nId

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_name_color]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_name_color](
	[char_id] [int] NOT NULL,
	[color_rgb] [int] NOT NULL CONSTRAINT [DF__user_name_color_color_rgb]  DEFAULT (0xFFFFFF),
	[nickname_color_rgb] [int] NULL CONSTRAINT [DF__user_name__nickn__17B93085]  DEFAULT (0xECF9A2),
 CONSTRAINT [PK_user_name_color] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_slot]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_slot](
	[char_id] [int] NOT NULL,
	[ST_underwear] [int] NULL CONSTRAINT [DF_user_slot_underwear]  DEFAULT ((0)),
	[ST_right_ear] [int] NULL CONSTRAINT [DF_user_slot_right_ear]  DEFAULT ((0)),
	[ST_left_ear] [int] NULL CONSTRAINT [DF_user_slot_left_ear]  DEFAULT ((0)),
	[ST_neck] [int] NULL CONSTRAINT [DF_user_slot_neck]  DEFAULT ((0)),
	[ST_right_finger] [int] NULL CONSTRAINT [DF_user_slot_right_finger]  DEFAULT ((0)),
	[ST_left_finger] [int] NULL CONSTRAINT [DF_user_slot_left_finger]  DEFAULT ((0)),
	[ST_head] [int] NULL CONSTRAINT [DF_user_slot_head]  DEFAULT ((0)),
	[ST_right_hand] [int] NULL CONSTRAINT [DF_user_slot_right_hand]  DEFAULT ((0)),
	[ST_left_hand] [int] NULL CONSTRAINT [DF_user_slot_left_hand]  DEFAULT ((0)),
	[ST_gloves] [int] NULL CONSTRAINT [DF_user_slot_gloves]  DEFAULT ((0)),
	[ST_chest] [int] NULL CONSTRAINT [DF_user_slot_chest]  DEFAULT ((0)),
	[ST_legs] [int] NULL CONSTRAINT [DF_user_slot_legs]  DEFAULT ((0)),
	[ST_feet] [int] NULL CONSTRAINT [DF_user_slot_feet]  DEFAULT ((0)),
	[ST_back] [int] NULL CONSTRAINT [DF_user_slot_back]  DEFAULT ((0)),
	[ST_both_hand] [int] NULL CONSTRAINT [DF_user_slot_both_hand]  DEFAULT ((0)),
	[ST_hair] [int] NULL CONSTRAINT [DF_user_slot_hair]  DEFAULT ((0)),
	[ST_hair2] [int] NULL CONSTRAINT [DF_user_slot_hair2]  DEFAULT ((0)),
	[ST_right_bracelet] [int] NULL CONSTRAINT [DF_user_slot_right_bracelet]  DEFAULT ((0)),
	[ST_left_bracelet] [int] NULL CONSTRAINT [DF_user_slot_left_bracelet]  DEFAULT ((0)),
	[ST_deco1] [int] NULL CONSTRAINT [DF_user_slot_deco1]  DEFAULT ((0)),
	[ST_deco2] [int] NULL CONSTRAINT [DF_user_slot_deco2]  DEFAULT ((0)),
	[ST_deco3] [int] NULL CONSTRAINT [DF_user_slot_deco3]  DEFAULT ((0)),
	[ST_deco4] [int] NULL CONSTRAINT [DF_user_slot_deco4]  DEFAULT ((0)),
	[ST_deco5] [int] NULL CONSTRAINT [DF_user_slot_deco5]  DEFAULT ((0)),
	[ST_deco6] [int] NULL CONSTRAINT [DF_user_slot_deco6]  DEFAULT ((0)),
	[ST_waist] [int] NULL,
 CONSTRAINT [PK__user_slot__21043A4B] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetSkillCoolTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetSkillCoolTime]
(
	@char_id	INT,
	@subjob_id	INT,
	@skill_id		INT,
	@nToEndTime	INT,
	@nDelay INT
)
AS
SET NOCOUNT ON
UPDATE user_skill_reuse_delay SET to_end_time = @nToEndTime, skill_delay = @nDelay WHERE char_id = @char_id AND skill_id = @skill_id AND ISNULL(subjob_id, 0) = @subjob_id

if @@rowcount = 0
begin
	insert into user_skill_reuse_delay (char_id, subjob_id, skill_id, to_end_time, skill_delay) values  (@char_id, @subjob_id, @skill_id, @nToEndTime, @nDelay)
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateGroupPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateGroupPoint

INPUT
OUTPUT

return
made by
	young
date
	2004-07-15
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateGroupPoint]
(
	@group_id	int,
	@group_point	float
)
AS
SET NOCOUNT ON

insert into event_point ( group_id, group_point) values ( @group_id, @group_point)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetCastleList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetCastleList
	get castle list
INPUT

OUTPUT

return
made by
	kks
date
	2004-01-13
********************************************/
CREATE PROCEDURE [dbo].[lin_GetCastleList]

AS

SET NOCOUNT ON

SELECT 
	C.id, isnull(C.pledge_id, 0) pledge_id , isnull(P.name, '''') pledge_name, isnull(P.ruler_id, 0) ruler_id, 
	isnull(U.char_name, '''') ruler_name, isnull(P.alliance_id, 0) alliance_id, isnull(A.name, '''') alliance_name, 
	C.tax_rate,
	CASE WHEN C.tax_rate_to_change = -1	THEN 0 ELSE C.tax_rate_to_change	END next_tax_rate, 
	next_war_time
FROM ( 
	SELECT * 
	FROM 
		castle	(nolock)) as C 
	LEFT JOIN (	
		SELECT pledge_id, name,	ruler_id, alliance_id 
		FROM pledge	(nolock)) as P 
		ON C.pledge_id = P.pledge_id 
	LEFT JOIN (	
		SELECT char_id,	char_name 
		FROM user_data (nolock)) as	U 
		ON P.ruler_id =	U.char_id 
	LEFT JOIN (	
		SELECT id, name	
		FROM alliance (nolock))	as A 
		ON P.alliance_id = A.id	
ORDER BY 
	C.id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SavePCCafePointRelative]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_SavePCCafePointRelative   
 INPUT            
 @char_id INT
 @nPoint  INT            
OUTPUT            
return            
           
made by            
	btwinuni
date            
 2006-03-03    

********************************************/            
CREATE PROCEDURE [dbo].[lin_SavePCCafePointRelative]    
(            
 @char_id INT,
 @point INT
)            
AS            
            
SET NOCOUNT ON            

IF EXISTS(SELECT * FROM  user_pccafe_point WHERE char_id = @char_id)
BEGIN
	UPDATE  user_pccafe_point SET point = point + @point
	WHERE char_id = @char_id

	IF (SELECT top 1 point from user_pccafe_point where char_id = @char_id) <= 0
	BEGIN
		update user_pccafe_point set point = 0
		where char_id = @char_id
	END
END
ELSE
BEGIN
	IF @point >= 0
	BEGIN
		INSERT INTO user_pccafe_point (char_id, point) 
		VALUES (@char_id, @point)
	END
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_bookmark]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_bookmark](
	[char_id] [int] NOT NULL,
	[slot_id] [int] NOT NULL,
	[pos_x] [int] NOT NULL CONSTRAINT [DF_user_bookmark_pos_x]  DEFAULT ((0)),
	[pos_y] [int] NOT NULL CONSTRAINT [DF_user_bookmark_pos_y]  DEFAULT ((0)),
	[pos_z] [int] NOT NULL CONSTRAINT [DF_user_bookmark_pos_z]  DEFAULT ((0)),
	[slot_title] [nvarchar](100) NOT NULL,
	[icon_id] [int] NOT NULL CONSTRAINT [DF_user_bookmark_icon_id]  DEFAULT ((0)),
	[icon_title] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_user_bookmark] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[slot_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateSubPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateSubPledge
	create subpledge
INPUT
	@pledge_id		int
	@pledge_type	int
	@name			nvarchar(50)
	@master_id		int
OUTPUT

return

date
	2006-03-28	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_CreateSubPledge] (
	@pledge_id		int,
	@pledge_type	int,
	@name			nvarchar(50),
	@master_id		int
)
AS

SET NOCOUNT ON

BEGIN TRAN

IF @name LIKE N'' ''   
BEGIN  
 RAISERROR (''subpledge name has space : name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END  
  
-- check user_prohibit   
IF EXISTS(SELECT char_name FROM user_prohibit (nolock) WHERE char_name = @name)  
BEGIN
 RAISERROR (''subpledge name is prohibited: name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END

DECLARE @user_prohibit_word NVARCHAR(20)  
SELECT TOP 1 @user_prohibit_word = words FROM user_prohibit_word (nolock) WHERE PATINDEX(''%'' + words + ''%'', @name) > 0   
IF @user_prohibit_word IS NOT NULL
BEGIN
 RAISERROR (''subpledge name has prohibited word: name = [%s], word[%s]'', 16, 1, @name, @user_prohibit_word)  
 GOTO EXIT_TRAN
END

INSERT INTO sub_pledge (pledge_id, master_id, type, name) VALUES (@pledge_id, @master_id, @pledge_type, @name)

EXIT_TRAN:
IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_reward]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbl_reward](
	[rank] [int] NULL,
	[reward] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_acc_mlev]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_acc_mlev](
	[account_name] [nvarchar](50) NOT NULL,
	[char_name] [nvarchar](50) NOT NULL,
	[lev] [tinyint] NOT NULL,
	[race] [tinyint] NOT NULL,
	[class] [tinyint] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBotReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadBotReport
desc:	load bot report
exam:	exec lin_LoadBotReport
history:	2008-06-18	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_LoadBotReport] 
(
	@char_id int
)
AS

SET NOCOUNT ON

select reported
from bot_report T(nolock)
where char_id = @char_id

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_BAN]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_BAN](
	[char_id] [bigint] NOT NULL,
	[char_name] [nvarchar](20) NOT NULL,
	[unban] [tinyint] NOT NULL CONSTRAINT [DF_A_BAN_unban]  DEFAULT ((0)),
	[desc] [nvarchar](100) NOT NULL,
	[data] [datetime] NOT NULL CONSTRAINT [DF_A_BAN_data]  DEFAULT (getdate()),
	[unbandate] [datetime] NOT NULL CONSTRAINT [DF_A_BAN_unbandate]  DEFAULT ('2020-01-01'),
	[unbantype] [tinyint] NOT NULL,
	[ban_gm] [nvarchar](20) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveHomePCCafePoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveHomePCCafePoint
desc:	save home pc cafe point
exam:	exec lin_SaveHomePCCafePoint
history:	2007-11-15	created by Phyllion
*/
CREATE PROCEDURE [dbo].[lin_SaveHomePCCafePoint] 
(
	@char_id int,
	@point int,
	@saved_day int
)
AS

SET NOCOUNT ON

IF (@point < 0)
BEGIN            
    RAISERROR (''Not valid parameter : char id[%d] point[%d]'',  16, 1, @char_id,  @point)
    RETURN -1            
END            

UPDATE  user_home_pccafe_point SET point = @point, saved_day = @saved_day
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO user_home_pccafe_point (char_id, point, saved_day) 
	VALUES (@char_id, @point, @saved_day)    	
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMailCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMailCount
	get mail count
INPUT
	@char_id		int,

OUTPUT
return
made by
	kks
date
	2004-12-17
********************************************/
CREATE PROCEDURE [dbo].[lin_GetMailCount]
(
	@char_id		int
)
AS
SET NOCOUNT ON

SELECT
	(SELECT COUNT(*) 
	FROM user_mail_receiver(NOLOCK)
	WHERE receiver_id = @char_id
		AND deleted = 0
		AND mailbox_type = 0) incomming_mail,
	(SELECT COUNT(*)
	FROM user_mail_sender(NOLOCK)
	WHERE sender_id = @char_id
		AND deleted = 0
		AND mailbox_type = 1) sent_mail,
	(SELECT COUNT(*) 
	FROM user_mail_receiver(NOLOCK)
	WHERE receiver_id = @char_id
		AND deleted = 0
		AND mailbox_type = 2)
	+
	(SELECT COUNT(*)
	FROM user_mail_sender(NOLOCK)
	WHERE sender_id = @char_id
		AND deleted = 0
		AND mailbox_type = 2) archived_mail,
	(SELECT COUNT(*)
	FROM user_mail_sender(NOLOCK)
	WHERE sender_id = @char_id
		AND deleted = 0
		AND mailbox_type = 3) temp_mail

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAssociatedInZone]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:	lin_SetAssociatedInZone
desc:	
exam:	exec lin_SetAssociatedInZone @char_id, @inzone_id
 
history:	2007-08-02	btwinuni
*/ 
CREATE procedure [dbo].[lin_SetAssociatedInZone]
	@char_id int,
	@inzone_id int
as 
 
set nocount on 

update user_data set associated_inzone = @inzone_id where char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RequestCharMoveDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RequestCharMoveDelete
	request char move delete
INPUT

OUTPUT

return
made by
	young
date
	2004-08-23
********************************************/
CREATE PROCEDURE [dbo].[lin_RequestCharMoveDelete]
	@account_id		int

AS
SET NOCOUNT ON


declare @old_char_id		int
declare @old_char_name	nvarchar(50)
declare @account_name	nvarchar(50)
declare @old_world_id		int
declare @new_world_id		int
declare @is_pc_bang			int

set @old_world_id	= 0
set @new_world_id	= 0

select top 1 @old_char_id = old_char_id, @old_char_name = old_char_name, @account_name = account_name , @old_world_id = old_world_id, @new_world_id = new_world_id, @is_pc_bang = is_pc_bang from req_charmove (nolock)
where account_id = @account_id

if (@@ROWCOUNT > 0)
begin

	delete from req_charmove where account_id = @account_id

	if (@is_pc_bang = 0)
	begin
		-- check quota
		update request_old_quota set quota_over = 0 where quota_over = 1 and old_world_id = @old_world_id
		update request_new_quota set quota_over = 0 where quota_over = 1 and new_world_id = @new_world_id
	end

	insert into req_charmove_deleted ( old_char_id, old_char_name, account_id, account_name, is_pc_bang)
	values 
	( @old_char_id, @old_char_name, @account_id, @account_name, @is_pc_bang )

end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitAuctionProce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitAuctionProce]
	@auction_price	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET auction_price = @auction_price WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitAuctionData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitAuctionData]
	@auction_date	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET auction_date = @auction_date WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMail
	get mail 
INPUT
	@char_id		int,
	@mail_id		int
OUTPUT
return
made by
	kks
date
	2004-12-10
********************************************/
CREATE PROCEDURE [dbo].[lin_GetMail]
(
	@char_id		int,
	@mail_id		int
)
AS
SET NOCOUNT ON

UPDATE user_mail_receiver
SET read_date = GETDATE(),
read_status = 1
WHERE mail_id = @mail_id
AND receiver_id = @char_id
AND read_status = 0
AND deleted = 0

SELECT
	m.id, s.sender_id, s.sender_name, s.receiver_name_list, m.title, m.content, datediff( ss, ''1970/1/1 0:0:0'' , s.send_date ), s.mail_type
FROM user_mail m (nolock), user_mail_sender s(nolock)
WHERE m.id = @mail_id
	AND s.mail_id = m.id

/*AND (m.id IN (SELECT mail_id FROM user_mail_receiver(nolock) WHERE receiver_id = @char_id)
OR m.id IN (SELECT mail_id FROM user_mail_sender(nolock) WHERE sender_id = @char_id))
*/

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RequestPledgeMasterTransfer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RequestPledgeMasterTransfer
	
INPUT
	@pledge_id		int
	@new_master_id	int
OUTPUT
return
	@success_flag		int
made by
	kks
date
	2006-05-12
********************************************/
CREATE PROCEDURE [dbo].[lin_RequestPledgeMasterTransfer]
(
	@pledge_id		int,
	@new_master_id	int
)
AS
SET NOCOUNT ON

if (exists(select pledge_id from pledge_master_transfer where pledge_id = @pledge_id and status = 0))
begin
	select 0
end
else
begin
	insert into pledge_master_transfer(pledge_id, new_master_id, status) values (@pledge_id, @new_master_id, 0)
	select @@rowcount
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetItemAuctionEndTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SetItemAuctionEndTime
desc:	set end time

history:	2007-04-20	created by btwinuni
*/
create procedure [dbo].[lin_SetItemAuctionEndTime]
	@auction_id int,
	@end_time int,
	@extend_status int
as
set nocount on

update item_auction
set end_time = @end_time,
	extend_status = @extend_status
where auction_id = @auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateUserItemAttribute]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateUserItemAttribute]
(
	@item_id		int,
	@attack_attr_type	smallint,
	@attack_attr_value	smallint,
	@defend_attr0	smallint,
	@defend_attr1	smallint,
	@defend_attr2	smallint,
	@defend_attr3	smallint,
	@defend_attr4	smallint,
	@defend_attr5	smallint
)
as

set nocount on

update user_item_attribute
set attack_attribute_type = @attack_attr_type,
	attack_attribute_value = @attack_attr_value,
	defend_attribute_0 = @defend_attr0,
	defend_attribute_1 = @defend_attr1,
	defend_attribute_2 = @defend_attr2,
	defend_attribute_3 = @defend_attr3,
	defend_attribute_4 = @defend_attr4,
	defend_attribute_5 = @defend_attr5
where item_id = @item_id

if @@rowcount = 0
begin
	insert into user_item_attribute (item_id, attack_attribute_type, attack_attribute_value, defend_attribute_0, defend_attribute_1, defend_attribute_2, defend_attribute_3, defend_attribute_4, defend_attribute_5)
	values (@item_id, @attack_attr_type, @attack_attr_value, @defend_attr0, @defend_attr1, @defend_attr2, @defend_attr3, @defend_attr4, @defend_attr5)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GraduateAcademyMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GraduateAcademyMember
	graduate academy member
INPUT
	@user_id		int
	@pledge_id		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_GraduateAcademyMember] (
	@user_id		int,
	@pledge_id		int
)
AS

UPDATE academy_member
SET status = 1, status_time = getdate()
WHERE user_id = @user_id AND pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadHomePCCafePoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadHomePCCafePoint
desc:	load home pc cafe point
exam:	exec lin_LoadHomePCCafePoint
history:	2007-11-15	created by Phyllion
*/
CREATE PROCEDURE [dbo].[lin_LoadHomePCCafePoint] 
(
	@char_id int
)
AS

SET NOCOUNT ON

SELECT point, saved_day FROM user_home_pccafe_point(nolock)  WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddedServiceListEvent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AddedServiceListEvent](
	[idx] [int] NOT NULL,
	[postDate] [datetime] NOT NULL,
	[serviceType] [tinyint] NOT NULL,
	[fromUid] [int] NOT NULL,
	[toUid] [int] NULL,
	[fromAccount] [nvarchar](24) NULL,
	[toAccount] [nvarchar](24) NULL,
	[fromServer] [tinyint] NOT NULL,
	[toServer] [tinyint] NULL,
	[fromCharacter] [nvarchar](24) NOT NULL,
	[toCharacter] [nvarchar](24) NULL,
	[changeGender] [bit] NULL,
	[serviceFlag] [smallint] NOT NULL,
	[applyDate] [datetime] NULL CONSTRAINT [DF__AddedServ__apply__123123]  DEFAULT (getdate()),
	[reserve1] [varchar](200) NULL,
	[reserve2] [varchar](100) NULL,
	[subjobId] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertQuestName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_InsertQuestName    Script Date: 2003-09-20 오전 11:51:59 ******/

/********************************************
lin_InsertQuestName
	insert Quest name data
INPUT
	@id	INT,
	@name 	nvarchar(50),
	@data 	nvarchar(50)
OUTPUT
return
made by
	carrot
date
	2002-10-8
********************************************/
CREATE PROCEDURE [dbo].[lin_InsertQuestName]
(
@id	INT,
@name 	nvarchar(50),
@data 	nvarchar(50)
)
AS
SET NOCOUNT ON


INSERT INTO QuestData
	(id, name, data) 
	values 
	(@id, @name, @data)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelProhibit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DelProhibit    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DelProhibit
	
INPUT	
	@char_name	nvarchar(50)
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
CREATE PROCEDURE [dbo].[lin_DelProhibit]
(
	@char_name	nvarchar(50),
	@noption	int
)
AS
SET NOCOUNT ON

if @noption = 2  
	delete from  user_prohibit 
	where  char_name = @char_name
else if @noption = 4 
	delete from  user_prohibit_word 
	where words = @char_name

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InitPledgeEmblem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_InitPledgeEmblem
	
INPUT	
	@pledge_id	int
OUTPUT

return
made by
	kks
date
	2005-07-22
********************************************/
create PROCEDURE [dbo].[lin_InitPledgeEmblem]
(
	@pledge_id	int
)
AS
SET NOCOUNT ON

UPDATE Pledge SET emblem_id = 0 WHERE pledge_id = @pledge_id	-- update tuple from pledge table

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadLastLogout]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadLastLogout
	load char last logout
INPUT
	char_id	int

OUTPUT
return
made by
	carrot
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadLastLogout]
(
@char_id		INT

)
AS
SET NOCOUNT ON


select Year(logout), Month(logout), Day(logout), DATEPART(HOUR, logout), DATEPART(mi, logout), DATEPART(s, logout),
Year(login), Month(login), Day(login), DATEPART(HOUR, login), DATEPART(mi, login), DATEPART(s, login),
Year(create_date), Month(create_date), Day(create_date), DATEPART(HOUR, create_date), DATEPART(mi, create_date), DATEPART(s, create_date)
from user_data (nolock) where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SelectTop200BuilderAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_SelectTop200BuilderAccount]
as
set nocount on

select distinct top 200 account_name from builder_account (nolock)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[olympiad_result]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[olympiad_result](
	[season] [int] NOT NULL,
	[class] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[point] [int] NOT NULL,
	[match_count] [int] NOT NULL,
	[olympiad_win_count] [int] NOT NULL CONSTRAINT [DF__olympiad___olymp__387018DA]  DEFAULT ((0)),
	[olympiad_lose_count] [int] NOT NULL CONSTRAINT [DF__olympiad___olymp__39643D13]  DEFAULT ((0)),
	[team_win_count] [int] NOT NULL CONSTRAINT [DF_olympiad_result_team_win_count]  DEFAULT ((0)),
	[ranking] [int] NOT NULL CONSTRAINT [DF_olympiad_result_ranking]  DEFAULT ((0)),
 CONSTRAINT [PK_olympiad_result] PRIMARY KEY CLUSTERED 
(
	[season] ASC,
	[class] ASC,
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetUserDataByCharId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetUserDataByCharId
desc:	get user_data

history:	2007-03-30	modified by btwinuni
	2007-05-16	modified by neo		add tutorial_flag
*/
create procedure [dbo].[lin_GetUserDataByCharId]
(
	@char_id	int
)
as

set nocount on

if @char_id > 0
select
	RTRIM(ud.char_name), ud.char_id, RTRIM(ud.account_name), ud.account_id, ud.pledge_id, ud.builder,
	ud.gender, ud.race, ud.class, ud.world, ud.xloc, ud.yloc, ud.zloc, ud.IsInVehicle,
	ud.HP, ud.MP, ud.Max_HP, ud.Max_MP, ud.CP, ud.Max_CP, ud.SP, ud.Exp, ud.Lev,
	ud.align, ud.PK, ud.duel, ud.pkpardon,
	ISNULL(usl.ST_underwear, 0), ISNULL(usl.ST_right_ear, 0), ISNULL(usl.ST_left_ear, 0),
	ISNULL(usl.ST_neck, 0), ISNULL(usl.ST_right_finger, 0), ISNULL(usl.ST_left_finger, 0),
	ISNULL(usl.ST_head, 0), ISNULL(usl.ST_right_hand, 0), ISNULL(usl.ST_left_hand, 0),
	ISNULL(usl.ST_gloves, 0), ISNULL(usl.ST_chest, 0), ISNULL(usl.ST_legs, 0), ISNULL(usl.ST_feet, 0),
	ISNULL(usl.ST_back, 0), ISNULL(usl.ST_both_hand, 0), ISNULL(usl.ST_hair, 0), ISNULL(usl.ST_hair2, 0),
	ISNULL(usl.ST_right_bracelet, 0), ISNULL(usl.ST_left_bracelet, 0),
	ISNULL(usl.ST_deco1, 0), ISNULL(usl.ST_deco2, 0), ISNULL(usl.ST_deco3, 0),
	ISNULL(usl.ST_deco4, 0), ISNULL(usl.ST_deco5, 0), ISNULL(usl.ST_deco6, 0),
	ISNULL(usl.ST_waist, 0),
	ISNULL(YEAR(temp_delete_date),0), ISNULL(MONTH(temp_delete_date),0), ISNULL(DAY(temp_delete_date),0),
	ISNULL(DATEPART(HOUR, temp_delete_date),0), ISNULL(DATEPART(mi, temp_delete_date),0), ISNULL(DATEPART(s, temp_delete_date),0),
	ISNULL(uas.s1, 0), ISNULL(uas.l1, 0), ISNULL(uas.d1, 0), ISNULL(uas.c1, 0),
	ISNULL(uas.s2, 0), ISNULL(uas.l2, 0), ISNULL(uas.d2, 0), ISNULL(uas.c2, 0),
	ISNULL(uas.s3, 0), ISNULL(uas.l3, 0), ISNULL(uas.d3, 0), ISNULL(uas.c3, 0),
	ISNULL(uas.s4, 0), ISNULL(uas.l4, 0), ISNULL(uas.d4, 0), ISNULL(uas.c4, 0),
	ISNULL(uas.s5, 0), ISNULL(uas.l5, 0), ISNULL(uas.d5, 0), ISNULL(uas.c5, 0),
	ISNULL(uas.s6, 0), ISNULL(uas.l6, 0), ISNULL(uas.d6, 0), ISNULL(uas.c6, 0),
	ISNULL(uas.s7, 0), ISNULL(uas.l7, 0), ISNULL(uas.d7, 0), ISNULL(uas.c7, 0),
	ISNULL(uas.s8, 0), ISNULL(uas.l8, 0), ISNULL(uas.d8, 0), ISNULL(uas.c8, 0),
	ISNULL(uas.s9, 0), ISNULL(uas.l9, 0), ISNULL(uas.d9, 0), ISNULL(uas.c9, 0),
	ISNULL(uas.s10, 0), ISNULL(uas.l10, 0), ISNULL(uas.d10, 0), ISNULL(uas.c10, 0),
	ISNULL(uas.s11, 0), ISNULL(uas.l11, 0), ISNULL(uas.d11, 0), ISNULL(uas.c11, 0),
	ISNULL(uas.s12, 0), ISNULL(uas.l12, 0), ISNULL(uas.d12, 0), ISNULL(uas.c12, 0),
	ISNULL(uas.s13, 0), ISNULL(uas.l13, 0), ISNULL(uas.d13, 0), ISNULL(uas.c13, 0),
	ISNULL(uas.s14, 0), ISNULL(uas.l14, 0), ISNULL(uas.d14, 0), ISNULL(uas.c14, 0),
	ISNULL(uas.s15, 0), ISNULL(uas.l15, 0), ISNULL(uas.d15, 0), ISNULL(uas.c15, 0),
	ISNULL(uas.s16, 0), ISNULL(uas.l16, 0), ISNULL(uas.d16, 0), ISNULL(uas.c16, 0),
	ISNULL(uas.s17, 0), ISNULL(uas.l17, 0), ISNULL(uas.d17, 0), ISNULL(uas.c17, 0),
	ISNULL(uas.s18, 0), ISNULL(uas.l18, 0), ISNULL(uas.d18, 0), ISNULL(uas.c18, 0),
	ISNULL(uas.s19, 0), ISNULL(uas.l19, 0), ISNULL(uas.d19, 0), ISNULL(uas.c19, 0),
	ISNULL(uas.s20, 0), ISNULL(uas.l20, 0), ISNULL(uas.d20, 0), ISNULL(uas.c20, 0),
	ISNULL(uas.s21, 0), ISNULL(uas.l21, 0), ISNULL(uas.d21, 0), ISNULL(uas.c21, 0),
	ISNULL(uas.s22, 0), ISNULL(uas.l22, 0), ISNULL(uas.d22, 0), ISNULL(uas.c22, 0),
	ISNULL(uas.s23, 0), ISNULL(uas.l23, 0), ISNULL(uas.d23, 0), ISNULL(uas.c23, 0),
	ISNULL(uas.s24, 0), ISNULL(uas.l24, 0), ISNULL(uas.d24, 0), ISNULL(uas.c24, 0),
	ISNULL(uas.s25, 0), ISNULL(uas.l25, 0), ISNULL(uas.d25, 0), ISNULL(uas.c25, 0),
	ISNULL(uas.s26, 0), ISNULL(uas.l26, 0), ISNULL(uas.d26, 0), ISNULL(uas.c26, 0),
	ISNULL(uas.s27, 0), ISNULL(uas.l27, 0), ISNULL(uas.d27, 0), ISNULL(uas.c27, 0),
	ISNULL(uas.s28, 0), ISNULL(uas.l28, 0), ISNULL(uas.d28, 0), ISNULL(uas.c28, 0),
	ISNULL(uas.s29, 0), ISNULL(uas.l29, 0), ISNULL(uas.d29, 0), ISNULL(uas.c29, 0),
	ISNULL(uas.s30, 0), ISNULL(uas.l30, 0), ISNULL(uas.d30, 0), ISNULL(uas.c30, 0),
	ISNULL(uas.s31, 0), ISNULL(uas.l31, 0), ISNULL(uas.d31, 0), ISNULL(uas.c31, 0),
	ISNULL(uas.s32, 0), ISNULL(uas.l32, 0), ISNULL(uas.d32, 0), ISNULL(uas.c32, 0),
	ISNULL(uas.s33, 0), ISNULL(uas.l33, 0), ISNULL(uas.d33, 0), ISNULL(uas.c33, 0),
	ISNULL(uas.s34, 0), ISNULL(uas.l34, 0), ISNULL(uas.d34, 0), ISNULL(uas.c34, 0),
	ud.quest_flag, ud.face_index, ud.hair_shape_index, ud.hair_color_index,
	ud.nickname, ud.power_flag, ud.pledge_dismiss_time, ud.pledge_ousted_time, ud.pledge_withdraw_time,
	ud.surrender_war_id, ud.use_time, ud.drop_exp,
	ISNULL(ub.status, 0), ISNULL(ub.ban_end , 0), ISNULL(ud.subjob_id , 0),
	ud.subjob0_class, ud.subjob1_class, ud.subjob2_class, ud.subjob3_class, ISNULL(ssq_dawn_round, 0),
	ISNULL(unc.color_rgb, 0xFFFFFF), isnull(unc.nickname_color_rgb, 0xECF9A2),
	ud.pledge_type , ud.grade_id, ISNULL(ud.academy_pledge_id, 0), ISNULL(us.service_flag, 0),
	ISNULL(ud.tutorial_flag, 0), ISNULL(ud.associated_inzone, 0), ISNULL(ud.bookmark_slot, 0)
from
	(select * from user_data (nolock) where char_id = @char_id and account_id > 0) as ud       
	left outer join
	(select * from user_ActiveSkill (nolock) where char_id = @char_id) as uas on ud.char_id = uas.char_id
	left outer join
	(select * from user_ban (nolock) where char_id = @char_id) as ub on ud.char_id = ub.char_id  
	left outer join
	(select * from user_name_color (nolock) where char_id = @char_id) as unc on ud.char_id = unc.char_id
	left outer join
	(select * from user_service (nolock) where char_id = @char_id) as us on ud.char_id = us.char_id
	left outer join
	(select * from user_slot (nolock) where char_id = @char_id) as usl on ud.char_id = usl.char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[minigame_agit_status]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[minigame_agit_status](
	[agit_id] [int] NOT NULL,
	[elapsed_time] [int] NOT NULL CONSTRAINT [DF__minigame___elaps__7EED82BB]  DEFAULT ((0)),
	[propose_time] [datetime] NOT NULL CONSTRAINT [DF__minigame___propo__7FE1A6F4]  DEFAULT (getdate()),
 CONSTRAINT [PK_minigame_agit_status] PRIMARY KEY CLUSTERED 
(
	[agit_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteItemAuctionBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_DeleteItemAuctionBid
desc:	delete item auction bid

history:	2007-04-16	created by btwinuni
*/
create procedure [dbo].[lin_DeleteItemAuctionBid]
	@bid_id int
as
set nocount on

delete from item_auction_bid where bid_id = @bid_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_surrender]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_surrender](
	[char_id] [int] NOT NULL,
	[surrender_war_id] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetBotReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetBotReport] 
(
	@char_id int,
	@reported int,
	@reported_date	int
)
AS

SET NOCOUNT ON


UPDATE bot_report SET reported = @reported, reported_date = @reported_date
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO bot_report (char_id, reported, reported_date, bot_admin) 
	VALUES (@char_id, @reported, @reported_date, 0)    	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitTeleport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitTeleport]
	@tel_lev	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET teleport_level = @tel_lev WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_STAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_STAT](
	[DAY] [smalldatetime] NOT NULL,
	[PVP] [bigint] NOT NULL,
	[PK] [bigint] NOT NULL,
	[DIE] [bigint] NOT NULL,
	[KILLNPC] [bigint] NOT NULL,
	[STAT_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MAX_ONLINE] [bigint] NOT NULL CONSTRAINT [DF_A_STAT_MAX_ONLINE]  DEFAULT ((0)),
 CONSTRAINT [PK_A_STAT] PRIMARY KEY CLUSTERED 
(
	[DAY] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EventItemFromWeb]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EventItemFromWeb](
	[account_id] [int] NULL,
	[char_id] [int] NULL,
	[char_name] [nvarchar](24) NULL,
	[item_type] [int] NULL,
	[from_table] [nvarchar](128) NULL,
	[result] [int] NULL,
	[apply_date] [datetime] NULL CONSTRAINT [DF__EventItem__apply__700B31DE]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_JoinAcademyMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_JoinAcademyMember
	join academy member
INPUT
	@user_id		int
	@pledge_id		int
	@join_level		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_JoinAcademyMember] (
	@user_id		int,
	@pledge_id		int,
	@join_level		int
)
AS

INSERT INTO academy_member(user_id, pledge_id, join_level, status, status_time)
VALUES (@user_id, @pledge_id, @join_level, 0, getdate())

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetUserDataEx]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetUserDataEx    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetUserDataEx
	
INPUT	
	@char_id	int,
	@dismiss_penalty_reserved	int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SetUserDataEx]
(
	@char_id	int,
	@dismiss_penalty_reserved	int
)
AS
SET NOCOUNT ON

INSERT INTO user_data_ex (char_id, dismiss_penalty_reserved) VALUES (@char_id, @dismiss_penalty_reserved)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_StopAllianceWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE
[dbo].[lin_StopAllianceWar] (@proposer_alliance_id INT, @proposee_alliance_id INT, @war_id INT,  @war_end_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

UPDATE Alliance_War
SET status = 1,	-- WAR_END_STOP
winner = 0,
end_time = @war_end_time
WHERE
id = @war_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = @war_id
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModChar
	
INPUT
	@sp		int,
	@exp		bigint,
	@align		int,
	@pk		int,
	@pkpardon	int,
	@duel		int,
	@char_id	int,
	@level		int
OUTPUT
return
made by
	carrot
date
	2002-06-10
	2006-01-25	btwinuni	exp: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_ModChar]
(
	@sp		int,
	@exp		bigint,
	@level		int,
	@align		int,
	@pk		int,
	@pkpardon	int,
	@duel		int,
	@char_id	int
)
AS
SET NOCOUNT ON

update user_data set sp=@sp, exp=@exp, lev = @level,  align=@align, pk=@pk, pkpardon=@pkpardon, duel=@duel where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pledge_skill]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pledge_skill](
	[pledge_id] [int] NOT NULL,
	[skill_id] [int] NOT NULL,
	[skill_lev] [tinyint] NOT NULL CONSTRAINT [DF__pledge_sk__skill__096B112E]  DEFAULT ((0)),
 CONSTRAINT [PK_pledge_skill] PRIMARY KEY CLUSTERED 
(
	[pledge_id] ASC,
	[skill_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pledge_skill]') AND name = N'idx_pledge_skill_lev')
CREATE NONCLUSTERED INDEX [idx_pledge_skill_lev] ON [dbo].[pledge_skill] 
(
	[skill_lev] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DeleteMail
	delete mail
INPUT
	@char_id		int,
	@mail_id		int,
	@mailbox_type			int

OUTPUT
return
made by
	kks
date
	2004-12-19
modified by kks (2005-08-29)
********************************************/
CREATE PROCEDURE [dbo].[lin_DeleteMail]
(
	@char_id		int,
	@mail_id		int,
	@mailbox_type			int
)
AS
SET NOCOUNT ON

UPDATE user_mail_receiver
SET deleted = 1
WHERE mail_id = @mail_id AND
	receiver_id = @char_id AND
	mailbox_type = @mailbox_type AND
	deleted = 0

IF @@ROWCOUNT = 0
	BEGIN
	UPDATE user_mail_sender
	SET deleted = 1
	WHERE mail_id = @mail_id AND
		sender_id = @char_id AND
		mailbox_type = @mailbox_type
	END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RequestPledgeMasterTransferCancel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RequestPledgeMasterTransferCancel
	
INPUT
	@pledge_id		int
OUTPUT
return
	@success_flag		int
made by
	kks
date
	2006-05-12
********************************************/
CREATE PROCEDURE [dbo].[lin_RequestPledgeMasterTransferCancel]
(
	@pledge_id		int
)
AS
SET NOCOUNT ON

delete from pledge_master_transfer where pledge_id = @pledge_id and status = 0
select @@rowcount

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UninstallAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UninstallAgitDeco]
	@agit_id int
as
set nocount on

UPDATE agit SET hp_stove = 0, hp_stove_expire = 0, mp_flame = 0, mp_flame_expire = 0, teleport_level = 0, teleport_expire = 0, hatcher = 0 WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dominion_renamed]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dominion_renamed](
	[char_id] [int] NOT NULL,
	[is_renamed] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_RENAME]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_RENAME](
	[INV_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CHAR_ID] [bigint] NOT NULL,
	[CHAR_NAME] [nvarchar](20) NOT NULL,
	[CHAR_NEW_NAME] [nvarchar](20) NOT NULL,
	[STATE] [bigint] NOT NULL,
	[DATE] [datetime] NULL CONSTRAINT [DF_A_RENAME_DATE]  DEFAULT (getdate()),
 CONSTRAINT [PK_RENAME_WM] PRIMARY KEY CLUSTERED 
(
	[INV_ID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBirthdayGiftCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetBirthdayGiftCount
desc:	캐릭터 생성일 기념 이벤트/5주년 이벤트 선물 받은 횟수

history:	2008-08-18	created by choanari
*/
create procedure [dbo].[lin_GetBirthdayGiftCount]
	@char_id int,
	@event_type int
as
set nocount on

select top 1 isnull(gift_index, 0) from user_birthday_history where char_id = @char_id and event_id = @event_type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[minigame_agit_member]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[minigame_agit_member](
	[agit_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[propose_time] [datetime] NOT NULL CONSTRAINT [DF__minigame___propo__7934A965]  DEFAULT (getdate()),
 CONSTRAINT [PK_minigame_agit_member] PRIMARY KEY CLUSTERED 
(
	[agit_id] ASC,
	[pledge_id] ASC,
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_friend]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_friend](
	[char_id] [int] NOT NULL,
	[friend_char_id] [int] NOT NULL,
	[friend_char_name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_user_friend] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[friend_char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeGenderForEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_ChangeGenderForEvent
desc:	change gender and reset face_index, hair_shape_index, hair_color_index to 0
exam:	exec lin_ChangeGenderForEvent ''''''server'''';''''login_id'''';''''password'''''', 1

history:	2006-07-11	created by btwinuni
*/
create procedure [dbo].[lin_ChangeGenderForEvent]
	@db_info	varchar(64),	-- ''''''server'''';''''login_id'''';''''password''''''
	@world_id	int
as

declare @sql varchar(4000)

set @sql = ''update dbo.user_data''
		+ '' set gender = gender ^ 1,''
		+ ''	face_index = 0,''
		+ ''	hair_shape_index = 0,''
		+ ''	hair_color_index = 0''
		+ '' where char_name in (''
		+ ''	select char_name ''
		+ ''	from openrowset(''''sqloledb'''', ''+@db_info+'',''
		+ ''		''''select char_name''
		+ ''		from L2EventDB.sysdev.ChangeGenderEventLogFinal (nolock)''
		+ ''		where world_id=''+cast(@world_id as nvarchar)+''''''))''
exec (@sql)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetCastleWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_SetCastleWar]
	@pledge_id	int,
	@castle_id	int,
	@type	int,
	@propose_time	int
as
set nocount on

INSERT INTO castle_war (pledge_id, castle_id, type, propose_time) VALUES (@pledge_id, @castle_id, @type, @propose_time)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetExpBySubjob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetExpBySubjob
	get experience of user_subjob by subjob_id
INPUT
	@char_id		int
	@subjob_id		int
OUTPUT
return
made by
	kernel0
date
	2005-04-20
********************************************/
CREATE PROCEDURE [dbo].[lin_GetExpBySubjob]
(
	@char_id		INT,
	@subjob_id		INT
)
AS
SET NOCOUNT ON

SELECT 
	exp
FROM 
	user_subjob
WHERE 
	char_id = @char_id 
	AND subjob_id = isnull(@subjob_id, 0)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSkillReuseDelay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE    PROCEDURE [dbo].[lin_GetSkillReuseDelay]
(
	@char_id	INT,
	@current_time	INT
)
AS
SET NOCOUNT ON

SELECT skill_id, subjob_id, to_end_time, skill_delay FROM user_skill_reuse_delay WHERE char_id = @char_id and @current_time <= to_end_time ORDER BY 1, 2

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetGroupPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetGroupPoint

INPUT
OUTPUT

return
made by
	young
date
	2004-07-15
********************************************/
CREATE PROCEDURE [dbo].[lin_GetGroupPoint]
(
	@group_id	int
)
AS
SET NOCOUNT ON

select sum( group_point) from event_point (nolock) where group_id = @group_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[nobless_achievements]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[nobless_achievements](
	[char_id] [int] NULL,
	[win_type] [int] NULL,
	[target] [int] NULL,
	[win_time] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddSubJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************************
#Name:	lin_AddSubjob
#Desc:	add subjob

#Argument:
	Input:	@char_id	INT
		@new_class	INT
		@hp		FLOAT
		@mp		FLOAT
		@sp		INT
		@exp		BIGINT
		@level		INT
		@subjob_id	INT
		@henna_1	INT
		@henna_2	INT
		@henna_3	INT
	Output:
#Return:	Success(1) / Failure(0)
#Result Set:

#Remark:
#Example:
#See:
#History:
	Create	btwinuni	2005-07-28
	Modify	btwinuni	2005-09-07
	Modify	btwinuni	2006-01-25	exp: int -> bigint
******************************************************************************/
CREATE PROCEDURE [dbo].[lin_AddSubJob]
(
	@char_id	INT,
	@new_class	INT,
	@hp		FLOAT,
	@mp		FLOAT,
	@sp		INT,
	@exp		BIGINT,
	@level		INT,
	@subjob_id	INT,
	@henna_1	INT,
	@henna_2	INT,
	@henna_3	INT
)
AS

SET NOCOUNT ON

DECLARE @ret INT
SELECT @ret = 1

BEGIN TRAN

-- subjob_id duplication check
IF EXISTS(SELECT subjob_id FROM user_subjob WHERE char_id = @char_id AND subjob_id = @subjob_id)
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

ELSE	-- insert
BEGIN
	INSERT INTO user_subjob
	(char_id, hp, mp, sp, exp, level, henna_1, henna_2, henna_3, subjob_id, create_date)
	VALUES
	(@char_id, @hp, @mp, @sp, @exp, @level, @henna_1, @henna_2, @henna_3, @subjob_id, getdate())

	DECLARE @sql VARCHAR(1000)
	SET @sql = ''UPDATE user_data ''
		+ '' SET subjob'' + cast(@subjob_id as varchar) + ''_class = '' + cast(@new_class as varchar)
		+ '' WHERE char_id = '' + cast(@char_id as varchar)
	EXEC (@sql)
END

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_pccafe_point]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_pccafe_point](
	[char_id] [int] NOT NULL,
	[point] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_pccafe_point]') AND name = N'IX_user_pccafe_point')
CREATE NONCLUSTERED INDEX [IX_user_pccafe_point] ON [dbo].[user_pccafe_point] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetSiegeTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetSiegeTime    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetSiegeTime
	
INPUT	
	@next_war_time	int,
	@castle_id	int,
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SetSiegeTime]
(
	@next_war_time	int,
	@castle_id	int
)
AS
SET NOCOUNT ON

UPDATE 
	castle 
SET 
	next_war_time = @next_war_time 
WHERE 
	id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetSubPledgeMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetSubPledgeMaster
	set subpledge master
INPUT
	@master_id		int
	@pledge_id		int
	@pledge_type		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_SetSubPledgeMaster] (
	@master_id		int,
	@pledge_id		int,
	@pledge_type		int
)
AS

UPDATE sub_pledge
SET master_id = @master_id
WHERE pledge_id = @pledge_id AND type = @pledge_type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pledge_announce]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pledge_announce](
	[pledge_id] [int] NOT NULL,
	[show_flag] [smallint] NOT NULL,
	[content] [nvarchar](3000) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[manor_info]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[manor_info](
	[manor_id] [int] NOT NULL,
	[residence_id] [int] NOT NULL,
	[adena_vault] [bigint] NOT NULL,
	[crop_buy_vault] [bigint] NOT NULL,
	[last_changed] [datetime] NOT NULL,
	[change_state] [tinyint] NOT NULL CONSTRAINT [DF__manor_inf__chang__39AE55D6]  DEFAULT ((0)),
 CONSTRAINT [PK_manor_info] PRIMARY KEY CLUSTERED 
(
	[manor_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetAcademyMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ResetAcademyMaster
	reset academy master
INPUT
	master_id		int,
	pledge_id	int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_ResetAcademyMaster] (
	@master_id		int,
	@pledge_id	int
)
AS

UPDATE academy_member
SET master_id = 0
WHERE master_id = @master_id AND pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_macro]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_macro](
	[macro_id] [int] IDENTITY(1,1) NOT NULL,
	[char_id] [int] NULL,
	[macro_name] [nvarchar](64) NULL,
	[macro_tooltip] [nvarchar](64) NULL,
	[macro_iconname] [nvarchar](64) NULL,
	[macro_icontype] [int] NULL,
 CONSTRAINT [IX_user_macro] UNIQUE CLUSTERED 
(
	[char_id] ASC,
	[macro_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetUserNickname]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetUserNickname    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE
[dbo].[lin_SetUserNickname] (@user_id INT, @nickname NVARCHAR(50))
AS

SET NOCOUNT ON

DECLARE @ret INT

UPDATE user_data
SET nickname = @nickname
WHERE char_id = @user_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = @user_id
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBuilderAccountByAccountName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadBuilderAccountByAccountName    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadBuilderAccountByAccountName
	
INPUT
	@account_name	NVARCHAR(50)
OUTPUT
return
made by
	carrot
date
	2002-06-09
change 	2003-07-03	carrot
	restrict only builer account
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadBuilderAccountByAccountName]
(
@account_name	NVARCHAR(50)
)
AS
SET NOCOUNT ON

SELECT top 1 account_id FROM builder_account (nolock) WHERE account_name= @account_name and account_id > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fortress]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[fortress](
	[id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[pledge_id] [int] NOT NULL CONSTRAINT [DF_fortress_pledge_id]  DEFAULT ((0)),
	[state] [int] NOT NULL CONSTRAINT [DF_fortress_state]  DEFAULT ((0)),
	[state_changed_time] [int] NOT NULL CONSTRAINT [DF_fortress_state_changed_time]  DEFAULT ((0)),
	[state_elapsed_time] [int] NOT NULL CONSTRAINT [DF_fortress_state_elapsed_time]  DEFAULT ((0)),
	[contract_status] [int] NOT NULL CONSTRAINT [DF_fortress_contract_status]  DEFAULT ((0)),
	[parent_castle_id] [int] NOT NULL CONSTRAINT [DF_fortress_parent_castle_id]  DEFAULT ((0)),
	[last_owner_changed_time] [int] NOT NULL CONSTRAINT [DF_fortress_last_owner_changed_time]  DEFAULT ((0)),
	[last_reward_given_time] [int] NOT NULL CONSTRAINT [DF_fortress_last_reward_given_time]  DEFAULT ((0)),
	[owner_reward_cycle_count] [int] NOT NULL CONSTRAINT [DF_fortress_owner_reward_cycle_count]  DEFAULT ((0)),
	[castle_treasure_level] [int] NOT NULL CONSTRAINT [DF_fortress_castle_treasure_level]  DEFAULT ((0)),
	[owner_siege_defend_count] [int] NOT NULL CONSTRAINT [DF_fortress_owner_siege_defend_count]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pledge_power]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pledge_power](
	[pledge_id] [int] NOT NULL,
	[grade_id] [int] NOT NULL,
	[power_bits] [int] NOT NULL,
 CONSTRAINT [PK_pledge_power] PRIMARY KEY CLUSTERED 
(
	[pledge_id] ASC,
	[grade_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_nr_memo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_nr_memo](
	[char_id] [int] NOT NULL,
	[quest_id] [int] NOT NULL,
	[state1] [int] NULL,
	[state2] [int] NULL,
	[journal] [int] NULL,
 CONSTRAINT [PK_user_nr_memo_1] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[quest_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agit_bid]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[agit_bid](
	[auction_id] [int] NULL,
	[attend_id] [int] IDENTITY(1,1) NOT NULL,
	[attend_price] [bigint] NULL,
	[attend_pledge_id] [int] NULL,
	[attend_date] [datetime] NULL CONSTRAINT [DF_agit_bid_attend_date]  DEFAULT (getdate()),
	[attend_time] [int] NULL,
 CONSTRAINT [IX_agit_bid] UNIQUE NONCLUSTERED 
(
	[auction_id] ASC,
	[attend_pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agit_bid]') AND name = N'IX_agit_auction')
CREATE NONCLUSTERED INDEX [IX_agit_auction] ON [dbo].[agit_bid] 
(
	[auction_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agit_bid]') AND name = N'IX_agit_price')
CREATE NONCLUSTERED INDEX [IX_agit_price] ON [dbo].[agit_bid] 
(
	[attend_price] ASC,
	[attend_date] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAllGroupPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetAllGroupPoint

INPUT
OUTPUT

return
made by
	kks
date
	2004-07-15
********************************************/
CREATE PROCEDURE [dbo].[lin_GetAllGroupPoint]
AS
SET NOCOUNT ON

select group_id, sum( group_point) from event_point (nolock) group by group_id
order by sum(group_point) desc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AirShip]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AirShip](
	[airship_id] [int] IDENTITY(1,1) NOT NULL,
	[airship_type] [int] NOT NULL CONSTRAINT [DF_AirShip_airship_type]  DEFAULT ((0)),
	[owner_id] [int] NOT NULL CONSTRAINT [DF_AirShip_owner_id]  DEFAULT ((0)),
	[airship_fuel] [int] NOT NULL CONSTRAINT [DF_AirShip_airship_fuel]  DEFAULT ((0)),
	[airship_typeid] [int] NOT NULL CONSTRAINT [DF_AirShip_airship_typeid]  DEFAULT ((0)),
	[deleted] [int] NOT NULL CONSTRAINT [DF_AirShip_deleted]  DEFAULT ((0)),
 CONSTRAINT [PK_AirShip] PRIMARY KEY CLUSTERED 
(
	[airship_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'AirShipTypeEnum' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'AirShip', @level2type=N'COLUMN', @level2name=N'airship_type'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'소유권자의 dbid' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'AirShip', @level2type=N'COLUMN', @level2name=N'owner_id'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'남은 연료량' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'AirShip', @level2type=N'COLUMN', @level2name=N'airship_fuel'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'airship script id' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'AirShip', @level2type=N'COLUMN', @level2name=N'airship_typeid'

GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAgitNextCost]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetAgitNextCost
	
INPUT
	

OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_SetAgitNextCost]
(
@agit_id		INT,
@next_cost		INT,
@cost_fail		int=0

)
AS
SET NOCOUNT ON

update agit set next_cost = @next_cost  , cost_fail = @cost_fail where id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateItemAuction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_CreateItemAuction
desc:	create item auction

history:	2007-04-16	created by btwinuni
*/
create procedure [dbo].[lin_CreateItemAuction]
	@auction_type int,
	@auction_npc int,
	@start_time int,
	@end_time int,
	@init_price bigint,
	@immediate_price bigint,
	@item_type int,
	@item_id int,
	@item_amount bigint,
	@item_owner int
as
set nocount on

declare @auction_id int

insert into item_auction(auction_type,extend_status,auction_npc,start_time,end_time,init_price,immediate_price,item_type,item_id,item_amount,item_owner)
values (@auction_type,0,@auction_npc,@start_time,@end_time,@init_price,@immediate_price,@item_type,@item_id,@item_amount,@item_owner)

if (@@error = 0)
begin
	set @auction_id = @@identity
end

select @auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LogForPremiumItemCreate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LogForPremiumItemCreate]
	@account_id	int,
	@char_id	int,
	@item_dbid	int,
	@item_amount_before	int,
	@item_amount_after	int,
	@reason		int,
	@item_type	int
AS
SET NOCOUNT ON

insert into user_premium_item_log (account_id, char_id, item_dbid, create_date, create_reason, item_amount_before, item_amount_after, item_type)
values (@account_id, @char_id, @item_dbid, getdate(), @reason, @item_amount_before, @item_amount_after, @item_type)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dominion]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dominion](
	[dominion_id] [int] NOT NULL,
	[dominion_status] [int] NOT NULL,
	[residence_status] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetWaitingTransferPledgeMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetWaitingTransferPledgeMaster
desc:	To get waiting to transfer pledge master
exam:	exec lin_GetWaitingTransferPledgeMaster
history:	2006-09-06	created by Phyllion
*/
CREATE procedure [dbo].[lin_GetWaitingTransferPledgeMaster]
as
SET NOCOUNT ON

select T.pledge_id 
from pledge_master_transfer T(nolock)
where T.status = 0

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdatePledgeInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UpdatePledgeInfo    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_UpdatePledgeInfo

INPUT
	@fieldName	nvarchar(50),
	@field_data	INT,
	@char_id	INT
OUTPUT
return
made by
	carrot
date
	2003-06-13
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdatePledgeInfo]
(
@fieldName	nvarchar(50),
@field_data	INT,
@char_id	INT
)
AS
SET NOCOUNT ON

IF @fieldName = N''pledge_dismiss_time'' begin update user_data set pledge_dismiss_time = @field_data where char_id =  @char_id end
ELSE IF @fieldName = N''pledge_ousted_time'' begin update user_data set pledge_ousted_time = @field_data where char_id =  @char_id end
ELSE IF @fieldName = N''pledge_withdraw_time'' begin update user_data set pledge_withdraw_time = @field_data where char_id =  @char_id end
ELSE IF @fieldName = N''surrender_war_id'' begin update user_data set surrender_war_id = @field_data where char_id =  @char_id end
ELSE 
BEGIN 
	RAISERROR (''lin_UpdatePledgeInfo : invalid field [%s]'', 16, 1, @fieldName)
	RETURN -1	
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModSubJobAbility]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModSubJobAbility
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@sp		int,
	@exp		bigint,
	@lev		int
OUTPUT
return
made by
	kks
date
	2005-01-18
	2005-04-20	kernel0
	2006-01-25	btwinuni	exp: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_ModSubJobAbility]
(
	@char_id	int,
	@subjob_id	int,
	@sp		int,
	@exp		bigint,
	@lev		int
)
AS
SET NOCOUNT ON

update user_subjob set sp = sp + @sp, exp = exp + @exp,  level = @lev where char_id = @char_id and subjob_id = @subjob_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSubPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadSubPledge
	load subpledge
INPUT
	@pledge_id		int
OUTPUT
return
date
	2006-04-21	kks
********************************************/
CREATE PROCEDURE
[dbo].[lin_LoadSubPledge] (
	@pledge_id		int
)
AS
SELECT master_id, type, name, member_count_upgrade FROM sub_pledge
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveBirthdayGift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveBirthdayGift
desc:	캐릭터 생성일 기념 이벤트/5주년 이벤트 선물 받은 기록

history:	2008-08-14	created by choanari
*/
create procedure [dbo].[lin_SaveBirthdayGift]
	@char_id int,
	@get_date nvarchar(20),
	@event_type int
as
set nocount on

if exists ( select char_id from user_birthday_history (nolock) where char_id = @char_id and event_id = @event_type)
begin 
	update user_birthday_history set get_date = @get_date, event_id = @event_type, gift_index = gift_index + 1 where char_id = @char_id and event_id = @event_type
end
else
begin
	insert into user_birthday_history(char_id, get_date, event_id, gift_index) values(@char_id, @get_date, @event_type, 1)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCharacterSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveCharacterSlot
desc:	save user_slot, separated from lin_SaveCharacter

history:	2007-03-30	created by btwinuni
*/
create procedure [dbo].[lin_SaveCharacterSlot]
(
	@char_id int,
	@ST_underwear int,
	@ST_right_ear int,
	@ST_left_ear int,
	@ST_neck int,
	@ST_right_finger int,
	@ST_left_finger int,
	@ST_head int,
	@ST_right_hand int,
	@ST_left_hand int,
	@ST_gloves int,
	@ST_chest int,
	@ST_legs int,
	@ST_feet int,
	@ST_back int,
	@ST_both_hand int,
	@ST_hair int,
	@ST_hair2 int,
	@ST_right_bracelet int,
	@ST_left_bracelet int,
	@ST_deco1 int,
	@ST_deco2 int,
	@ST_deco3 int,
	@ST_deco4 int,
	@ST_deco5 int,
	@ST_deco6 int,
	@ST_waist int
)
as

set nocount on

update user_slot
set 	ST_underwear= @ST_underwear,
	ST_right_ear= @ST_right_ear,
	ST_left_ear= @ST_left_ear,
	ST_neck= @ST_neck,
	ST_right_finger= @ST_right_finger,
	ST_left_finger= @ST_left_finger,
	ST_head= @ST_head,
	ST_right_hand= @ST_right_hand,
	ST_left_hand= @ST_left_hand,
	ST_gloves= @ST_gloves,
	ST_chest= @ST_chest,
	ST_legs= @ST_legs,
	ST_feet= @ST_feet,
	ST_back= @ST_back,
	ST_both_hand= @ST_both_hand,
	ST_hair = @ST_hair,
	ST_hair2 = @ST_hair2,
	ST_right_bracelet = @ST_right_bracelet,
	ST_left_bracelet = @ST_left_bracelet,
	ST_deco1 = @ST_deco1,
	ST_deco2 = @ST_deco2,
	ST_deco3 = @ST_deco3,
	ST_deco4 = @ST_deco4,
	ST_deco5 = @ST_deco5,
	ST_deco6 = @ST_deco6,
	ST_waist = @ST_waist
where char_id = @char_id

if @@rowcount = 0
begin
	insert into user_slot (char_id,ST_underwear,ST_right_ear,ST_left_ear,ST_neck,ST_right_finger,ST_left_finger,ST_head,
		ST_right_hand,ST_left_hand,ST_gloves,ST_chest,ST_legs,ST_feet,ST_back,ST_both_hand,ST_hair,ST_hair2,
		ST_right_bracelet,ST_left_bracelet,ST_deco1,ST_deco2,ST_deco3,ST_deco4,ST_deco5,ST_deco6,ST_waist)
	values (@char_id,@ST_underwear,@ST_right_ear,@ST_left_ear,@ST_neck,@ST_right_finger,@ST_left_finger,@ST_head,
		@ST_right_hand,@ST_left_hand,@ST_gloves,@ST_chest,@ST_legs,@ST_feet,@ST_back,@ST_both_hand,@ST_hair,@ST_hair2,
		@ST_right_bracelet,@ST_left_bracelet,@ST_deco1,@ST_deco2,@ST_deco3,@ST_deco4,@ST_deco5,@ST_deco6,@ST_waist)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitNextWarTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitNextWarTime]
	@next_war_time	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET next_war_time = @next_war_time WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPledgeRanking
	load pledge ranking
INPUT
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_LoadPledgeRanking] 
AS

SELECT pledge_id, root_name_value 
FROM pledge(nolock)
ORDER BY root_name_value DESC

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RPSetHero]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************************
#Name:	lin_RPSetHero
#Desc:	make daily report about character info set hero 

#Argument:
	Input:	@table_from	varchar(60)	log view: Lyyyy_mm_dd_Log_Data0_world
		@table_to	varchar(60)	report table: RP_AchieveMaxLevel
		@logdate	int		report date
	Output:	
#Return:
#Result Set:

#Remark:
#Example:	exec lin_RPSetHero ''L2005_10_12_log_data0_8'', ''RP_SetHero_8'', 20051012
#See:

#History:
	Create	neoliebe	2005-10-13
******************************************************************************/
CREATE    Procedure [dbo].[lin_RPSetHero]
	@table_from	varchar(60),
	@table_to	varchar(60),
	@logdate	int
AS
SET NOCOUNT ON

declare	@sql	varchar(4000)

-- report table is initiated
set @sql = ''if not exists (select * from dbo.sysobjects where id = object_id(N''''[dbo].['' + @table_to + '']'''') and objectproperty(id, N''''IsUserTable'''') = 1)''
	+ '' begin''
	+ '' create table [dbo].['' + @table_to + ''] (''
	+ ''log_date	int, ''
	+ ''log_time	varchar(4), ''
	+ ''char_name	nvarchar(48), ''
	+ ''account_name	nvarchar(32), ''
	+ ''class	int, ''
	+ ''level	int, ''
	+ ''olympiad_point	int, ''
	+ ''hero_cnt	int''
	+ '' )''
	+ '' create index ix_'' + @table_to + ''_1 on [dbo].['' + @table_to + ''] (log_date asc, log_time desc)'' 
	+ '' end''
exec (@sql)

set @sql = ''delete from [dbo].['' + @table_to + ''] where log_date = '' + cast(@logdate as varchar)
exec (@sql)

set @sql = ''insert into [dbo].['' + @table_to + ''] (log_date, log_time, char_name, account_name, class, level, olympiad_point, hero_cnt) ''
	+ ''select  '' + cast(@logdate as varchar) + '', substring(convert(varchar(5), act_time, 108), 0, 3) +  substring(convert(varchar(5), act_time, 108), 4, 6), ''
	+ '' str_actor, str_actor_account, etc_num3, etc_num4, etc_num5, etc_num6 ''
	+ ''from [lin2log].[dbo].['' +@table_from + ''] (nolock) where log_id = 862''
exec(@sql)

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetUnreadMailCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetUnreadMailCount
	get unread mail count
INPUT
	@char_id		int,

OUTPUT
return
made by
	kks
date
	2004-12-23
********************************************/
CREATE PROCEDURE [dbo].[lin_GetUnreadMailCount]
(
	@char_id		int
)
AS
SET NOCOUNT ON

SELECT COUNT(*)
FROM user_mail_receiver(NOLOCK)
WHERE receiver_id = @char_id
	AND mailbox_type = 0
	AND read_status = 0;

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item_receive]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_premium_item_receive](
	[warehouse_no] [bigint] NOT NULL,
	[real_recipient_char_id] [int] NOT NULL,
	[item_dbid] [int] NOT NULL,
	[item_amount] [bigint] NOT NULL,
	[receive_date] [datetime] NOT NULL,
	[product_id] [int] NULL DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item_receive]') AND name = N'IX_user_premium_item_receive_real_recipient_char_id')
CREATE NONCLUSTERED INDEX [IX_user_premium_item_receive_real_recipient_char_id] ON [dbo].[user_premium_item_receive] 
(
	[real_recipient_char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ReadBbsall]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ReadBbsall    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_ReadBbsall] 
(
	@nId	INT
)
AS

SET NOCOUNT ON

select 
	cnt, orderedTitle.title, orderedTitle.contents, orderedTitle.writer, cast( orderedTitle.cdate as smalldatetime)
from 
	(Select 
		count(bbs2.id) as cnt, bbs1.id, bbs1.title, bbs1.contents, bbs1.writer, bbs1.cdate
	from 
		Bbs_all as bbs1
		inner join
		Bbs_all as bbs2
		on bbs1.id <= bbs2.id
	group by 
		bbs1.id, bbs1.title, bbs1.contents, bbs1.writer, bbs1.cdate
	) as orderedTitle
where
	orderedTitle.id = @nId

IF @@rowcount = 1  
	UPDATE Bbs_all SET nRead = nRead + 1 WHERE id = @nId
Else
	RAISERROR (''Unavailable id.'', 16, 1)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAddedServiceListEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetAddedServiceListEvent] 
        @db_info        varchar(64), 
        @server_id      int 
as 
 
set nocount on 
 
declare 
@cursed_weapon        int,
@char_id        int,
@original_pk        int,
@sql varchar(4000) 


--메인-서브잡 교환(serviceType:5)-이벤트
set @sql = ''insert into AddedServiceListEvent (idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2, subjobId)'' 
        + '' select *'' 
        + '' from openrowset(''''sqloledb'''', ''+@db_info+'','' 
        + ''     ''''select idx, regiDate, 5, uid, uid as uid2, account, account as account2, serverid, serverid as serverid2, characterName, characterName as characterName2, 0, serviceFlag, null, null, toMainClassNum'' 
        + ''     from L2EventDB.dbo.L2ClassMoveEvent (nolock)'' 
        + ''     where serviceFlag = 0''''''  -- 서비스 신청 상태 
        + '')'' 
exec (@sql) 


 
set nocount off

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertCastleWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_InsertCastleWar]
	@castle_id	int,
	@pledge_id	int,
	@type	int
as
set nocount on

INSERT INTO castle_war (castle_id, pledge_id, type) VALUES (@castle_id, @pledge_id, @type)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_setCastleOwner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_setCastleOwner    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_setCastleOwner
	set castle Owner
INPUT
	nCastle_id, 
	nPledge_id

OUTPUT
return
made by
	carrot
date
	2002-06-12
change
********************************************/
CREATE PROCEDURE [dbo].[lin_setCastleOwner]
(
	@Castle_id	INT,
	@Pledge_id	INT
)
AS

SET NOCOUNT ON

DECLARE @Castle_idOld INT
DECLARE @nPledgeIdOld INT

SET @Castle_idOld = 0
SET @nPledgeIdOld = 0

SELECT @Castle_idOld = id, @nPledgeIdOld = pledge_id FROM castle WHERE id = @Castle_id 

IF @Castle_idOld = 0 
	INSERT INTO castle (id, name, pledge_id, type) VALUES (@Castle_id , ''test'', @Pledge_id,  1)
ELSE
	UPDATE castle  SET pledge_id = @Pledge_id WHERE id = @Castle_id  AND type = 1

IF @@ROWCOUNT > 0
	SELECT 1
ELSE
	SELECT 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBuilderAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetBuilderAccount    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetBuilderAccount
	
INPUT
	@account_name	nvarchar(50)
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_GetBuilderAccount]
(
	@account_name	nvarchar(50)
)
AS
SET NOCOUNT ON

select top 1 default_builder from builder_account  (nolock)  where account_name = @account_name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lotto_items]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[lotto_items](
	[round_number] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[number_flag] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[lotto_items]') AND name = N'IX_lotto_items')
CREATE CLUSTERED INDEX [IX_lotto_items] ON [dbo].[lotto_items] 
(
	[round_number] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ssq_join_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ssq_join_data](
	[round_number] [int] NOT NULL,
	[type] [tinyint] NOT NULL,
	[point] [bigint] NOT NULL,
	[main_event_point] [bigint] NULL,
	[collected_point] [bigint] NULL,
	[member_count] [int] NOT NULL,
	[seal1_selection_count] [int] NOT NULL,
	[seal2_selection_count] [int] NOT NULL,
	[seal3_selection_count] [int] NOT NULL,
	[seal4_selection_count] [int] NOT NULL,
	[seal5_selection_count] [int] NOT NULL,
	[seal6_selection_count] [int] NOT NULL,
	[seal7_selection_count] [int] NOT NULL,
	[last_changed_time] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDailyQuest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadDailyQuest
desc:	하루에 한번만 할수 있는 퀘스트 정보 로드

history:	2008-09-05	created by choanari
*/
create procedure [dbo].[lin_LoadDailyQuest]
	@char_id int
as
set nocount on

select isnull(quest_id, 0), isnull(complete_date, 0)
from user_daily_quest (nolock)
where char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetDefaultBuilder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetDefaultBuilder    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetDefaultBuilder
	Get default builder level of account
INPUT
	@account_name	nvarchar(50)
OUTPUT
return
made by
	young
date
	2002-11-26
********************************************/
CREATE PROCEDURE [dbo].[lin_GetDefaultBuilder]
(
@account_name	nvarchar(50)
)
AS
SET NOCOUNT ON

select default_builder from account_builder (nolock) where account_name = @account_name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAcademyMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadAcademyMember
	load academy member
INPUT
	@pledge_id		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_LoadAcademyMember] (
	@pledge_id		int
)
AS

SELECT user_id, join_level, master_id FROM academy_member
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_daily_quest]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_daily_quest](
	[char_id] [int] NOT NULL,
	[quest_id] [int] NOT NULL,
	[complete_date] [int] NOT NULL,
 CONSTRAINT [PK_user_daily_quest] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'퀘스트 id (하루 한번만 할수있는)' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_daily_quest', @level2type=N'COLUMN', @level2name=N'quest_id'

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_ban]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_ban](
	[char_id] [int] NOT NULL,
	[status] [int] NULL CONSTRAINT [DF_user_ban_status]  DEFAULT ((0)),
	[ban_date] [datetime] NULL CONSTRAINT [DF_user_ban_ban_date]  DEFAULT (getdate()),
	[ban_hour] [smallint] NULL CONSTRAINT [DF_user_ban_ban_hour]  DEFAULT ((0)),
	[ban_end] [int] NULL CONSTRAINT [DF_user_ban_ban_end]  DEFAULT ((0)),
 CONSTRAINT [PK_user_ban] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAgitOwner2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetAgitOwner2    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetAgitOwner2
	
INPUT	
	@pledge_id	int,
	@agit_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SetAgitOwner2]
(
	@pledge_id	int,
	@agit_id		int
)
AS
SET NOCOUNT ON

UPDATE agit SET pledge_id = @pledge_id WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[map](
	[map2] [int] NULL,
	[x2] [int] NULL,
	[y2] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModChar2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ModChar2    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_ModChar2
	
INPUT
	@sp		int,
	@exp		int,
	@align		int,
	@pk		int,
	@pkpardon	int,
	@duel		int,
	@char_id	int
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_ModChar2]
(
	@gender		int,
	@race		int,
	@class		int,
	@face_index		int,
	@hair_shape_index	int,
	@hair_color_index		int,
	@char_id	int
)
AS
SET NOCOUNT ON

update user_data set gender=@gender, race=@race, class=@class, face_index=@face_index, hair_shape_index=@hair_shape_index, hair_color_index=@hair_color_index where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharSvr2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_MoveCharSvr2
	move char
INPUT
	@world_id	int
OUTPUT

return
made by
	young
date
	2003-7-30
	2003-10-06
	2004-1-6
	2004-2-24
	2004-3-3
	2004-3-4
********************************************/
CREATE PROCEDURE [dbo].[lin_MoveCharSvr2]
(
	@old_world_id		int,
	@new_world_id		int,
	@conn_str		varchar(100)
)
AS

SET NOCOUNT ON

declare @sql varchar(4000)

--	& '' OPENROWSET ( ''SQLOLEDB'', ''l2world01'';''gamma'';''lineage2pwd'', '' 


-- pet_data
/*
set @sql = '' insert into pet_data ( pet_id, npc_class_id, expoint, nick_name, hp, mp, sp, meal  ) '' 
	+ '' select item_id, npc_class_id, expoint, null, hp, mp, sp, meal   '' 
	+ '' from '' 
	+ '' ( select * from user_item (nolock) where item_type in ( 2375 , 3500, 3501, 3502 ) and old_world_id = '' + CAST ( @old_world_id as varchar ) + '' ) as R1 ''
	+ '' left join ''
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select pet_id, npc_class_id, expoint, hp, mp, sp, meal  from lin2world.dbo.pet_data (nolock) '''' ) '' 
	+ '' ) as R2 '' 
	+ '' on R1.old_item_id = R2.pet_id ''
	+ '' where R2.npc_class_id is not null '' 
*/

set @sql =   '' insert into pet_data2 ( pet_id, npc_class_id, expoint, nick_name, hp, mp, sp, meal  ) '' 
	+ '' select  item_id, npc_class_id, expoint, ''''petname''''=null, hp, mp, sp, meal  '' 
	+ '' from '' 
	+ '' ( select * from user_item (nolock) where item_type in (  3500, 3501, 3502 ) and old_world_id = '' + CAST ( @old_world_id as varchar ) + '' ) as R1 ''
	+ '' left join ''
	+ '' ( '' 
	+ '' select * from  '' 
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '' 
	+ '' '''' select pet_id, npc_class_id, expoint, hp, mp, sp, meal  from lin2world.dbo.pet_data (nolock) '''' ) '' 
	+ '' ) as R2 '' 
	+ '' on R1.old_item_id = R2.pet_id ''
	+ '' where R2.npc_class_id is not null  order by item_id asc'' 


exec (@sql)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadLottoGame]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadLottoGame]
AS    
   
SET NOCOUNT ON    

select 	top 65535
	round_number,	
	state,
	left_time,
	chosen_number_flag,
	rule_number,

	total_count,
	winner1_count,
	winner2_count,
	winner3_count,
	winner4_count,
	carried_adena

from lotto_game	(nolock)
order by round_number

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CancelServiceList]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CancelServiceList](
	[idx] [int] NOT NULL,
	[postDate] [datetime] NOT NULL,
	[serviceType] [tinyint] NOT NULL,
	[fromUid] [int] NOT NULL,
	[toUid] [int] NULL,
	[fromAccount] [nvarchar](24) NULL,
	[toAccount] [nvarchar](24) NULL,
	[fromServer] [tinyint] NOT NULL,
	[toServer] [tinyint] NULL,
	[fromCharacter] [nvarchar](24) NOT NULL,
	[toCharacter] [nvarchar](24) NULL,
	[changeGender] [bit] NULL,
	[serviceFlag] [smallint] NOT NULL,
	[applyDate] [datetime] NULL,
	[reserve1] [varchar](200) NULL,
	[reserve2] [varchar](100) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelSubJobHenna]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DelSubJobHenna
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@henna	int

OUTPUT
return
made by
	kks
date
	2005-01-18
********************************************/
CREATE PROCEDURE [dbo].[lin_DelSubJobHenna]
(
	@char_id	int,
	@subjob_id	int,
	@henna	int
)
AS
SET NOCOUNT ON

declare @henna1 int
declare @henna2 int
declare @henna3 int

set @henna1 = 0
set @henna2 = 0
set @henna3 = 0

select @henna1 = isnull(henna_1, 0), @henna2 = isnull(henna_2, 0), @henna3 = isnull(henna_3, 0) from user_subjob where char_id = @char_id and subjob_id = @subjob_id

if (@henna = @henna1)
begin
	update user_subjob set henna_1 = 0 where char_id = @char_id and subjob_id = @subjob_id
end
else if (@henna = @henna2)
begin
	update user_subjob set henna_2 = 0 where char_id = @char_id and subjob_id = @subjob_id
end
else if (@henna = @henna3)
begin
	update user_subjob set henna_3 = 0 where char_id = @char_id and subjob_id = @subjob_id
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_SMS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_SMS](
	[INV_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CHAR_NAME] [nvarchar](20) NOT NULL,
	[CHAR_ID] [bigint] NOT NULL,
	[CODE] [nvarchar](10) NOT NULL,
	[COUNT] [bigint] NOT NULL,
	[COST] [bigint] NOT NULL,
	[SENDERID] [nvarchar](50) NOT NULL,
	[STATE] [bigint] NOT NULL,
	[DATE] [datetime] NULL CONSTRAINT [DF_A_SMS_DATE]  DEFAULT (getdate()),
 CONSTRAINT [PK_SMS_WM] PRIMARY KEY CLUSTERED 
(
	[INV_ID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_prohibit]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_prohibit](
	[char_name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_user_prohibit] PRIMARY KEY CLUSTERED 
(
	[char_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_acc_class]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_acc_class](
	[class] [tinyint] NOT NULL,
	[count] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[point]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[point](
	[map] [int] NULL,
	[align] [int] NULL,
	[loc] [int] NULL,
	[x] [int] NULL,
	[y] [int] NULL,
	[z] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fortress_siege]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[fortress_siege](
	[fortress_id] [int] NOT NULL CONSTRAINT [DF_fortress_siege_fortress_id]  DEFAULT ((0)),
	[siege_status] [int] NOT NULL CONSTRAINT [DF_fortress_siege_siege_status]  DEFAULT ((0)),
	[siege_start_time] [int] NOT NULL CONSTRAINT [DF_fortress_siege_siege_start_time]  DEFAULT ((0)),
	[siege_elapsed_time] [int] NOT NULL CONSTRAINT [DF_fortress_siege_siege_elapsed_time]  DEFAULT ((0)),
	[is_valid_info] [int] NOT NULL CONSTRAINT [DF_fortress_siege_is_valid_info]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LogForPremiumItemDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LogForPremiumItemDelete]
	@account_id	int,
	@char_id	int,
	@item_dbid	int,
	@item_amount_before	int,
	@item_amount_after	int,
	@reason		int,
	@item_type	int
AS
SET NOCOUNT ON

update user_premium_item_log
set delete_date = getdate(),
	delete_reason = @reason
where item_dbid = @item_dbid

if @@rowcount < 1
begin
	insert into user_premium_item_log (account_id, char_id, item_dbid, delete_date, delete_reason, item_amount_before, item_amount_after, item_type)
	values (@account_id, @char_id, @item_dbid, getdate(), @reason, @item_amount_before, @item_amount_after, @item_type)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetLastBirthdayDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetLastBirthdayDate    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetLastBirthdayDate
	Get Last Birthday Date
INPUT
	@char_id	int
	@event_type int // 0: 생성일 이벤트 1: 5주년 이벤트
OUTPUT
return
made by
	choanari
date
	2008-08-14
********************************************/
CREATE PROCEDURE [dbo].[lin_GetLastBirthdayDate]
(
	@char_id	int,
	@event_type int
)
AS
SET NOCOUNT ON

select ISNULL(YEAR(get_date),0), ISNULL(MONTH(get_date),0), ISNULL(DAY(get_date),0)
from user_birthday_history (nolock)
where char_id = @char_id and event_id = @event_type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadMinigameAgitStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_LoadMinigameAgitStatus]
(
	@agit_id	int
)
as
set nocount on
SELECT elapsed_time FROM minigame_agit_status WHERE agit_id = @Agit_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateUseTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UpdateUseTime    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_UpdateUseTime
	update character use time
INPUT
	char_id		int,
	usedtimesec	int
OUTPUT
return
made by
	young
date
	2003-03-26

		add usetime set
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdateUseTime]
(
	@char_id	INT,
	@usedTimeSec	INT
)
AS

SET NOCOUNT ON

UPDATE user_data SET use_time = use_time + @usedTimeSec WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAllMemberPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetAllMemberPledge    Script Date: 2003-09-20 오전 11:51:58 ******/
-- lin_GetAllMemberPledge
-- by bert
CREATE PROCEDURE
[dbo].[lin_GetAllMemberPledge] (@alliance_id INT)
AS

SET NOCOUNT ON

SELECT pledge_id FROM pledge WHERE alliance_id = @alliance_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetBotAdmin]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetBotAdmin] 
(
	@char_id int
)
AS

SET NOCOUNT ON


UPDATE bot_report SET bot_admin = 1
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO bot_report (char_id, reported, reported_date, bot_admin) 
	VALUES (@char_id, 0, 0, 1)  	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_PVP_PK]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_PVP_PK](
	[DATE] [smalldatetime] NOT NULL,
	[P_TYPE] [bigint] NOT NULL,
	[NICK1] [nvarchar](20) NOT NULL,
	[NICK2] [nvarchar](20) NOT NULL,
	[LEV1] [bigint] NOT NULL,
	[LEV2] [bigint] NOT NULL,
	[P_ID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_setAgitOwner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_setAgitOwner    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_setAgitOwner
	set Agit Owner
INPUT
	nAgit_id, 
	nPledge_id

OUTPUT
return
made by
	carrot
date
	2002-06-12
change
********************************************/
CREATE PROCEDURE [dbo].[lin_setAgitOwner]
(
	@Agit_id		INT,
	@Pledge_id	INT
)
AS

SET NOCOUNT ON

IF NOT exists(SELECT id FROM castle WHERE id = @Agit_id )
	INSERT INTO castle (id, name, pledge_id, type) VALUES (@Agit_id, ''test'', @Pledge_id,  2)
ELSE
	UPDATE castle  SET pledge_id = @Pledge_id WHERE id = @Agit_id AND type = 2 

IF @@ROWCOUNT > 0
	SELECT 1
ELSE
	SELECT 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPledgeInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetPledgeInfo
	
INPUT	
	@fieldName	nvarchar(50),
	@field_data	INT,
	@pledge_id	INT
OUTPUT

return
made by
	carrot
date
	2002-06-16
modified by 
	kks (2005-07-22)
	btwinuni (2007-05-16)
********************************************/
CREATE PROCEDURE [dbo].[lin_SetPledgeInfo]
(
@fieldName	nvarchar(50),
@field_data	INT,
@pledge_id	INT
)
AS
SET NOCOUNT ON

if exists (select * from syscolumns where id = object_id(N''pledge'') and name = @fieldName)
begin
	declare @sql nvarchar(1024)
	set @sql = ''update pledge''
		+ '' set '' + @fieldName + '' = '' + cast(@field_data as nvarchar)
		+ '' where pledge_id = '' + cast(@pledge_id as nvarchar)
	exec (@sql)
end
else
begin
	raiserror (''lin_SetPledgeInfo : invalid field [%s]'', 16, 1, @fieldName)
	return -1
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RenameSubpledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RenameSubpledge
	rename subpledge
INPUT
	@pledge_id		int
	@pledge_type		int
	@subpledge_name		nvarchar(50)
OUTPUT

return

date
	2006-06-08	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_RenameSubpledge] (
	@pledge_id		int,
	@pledge_type		int,
	@subpledge_name		nvarchar(50)
)
AS

SET NOCOUNT ON

UPDATE sub_pledge
SET name = @subpledge_name
WHERE pledge_id = @pledge_id AND type = @pledge_type

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetOneMacro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetOneMacro
	get one macro
INPUT
	@char_id		int,
	@macro_number	int
OUTPUT
return
made by
	young
date
	2004-6-11
********************************************/
CREATE PROCEDURE [dbo].[lin_GetOneMacro]
(
@char_id		int,
@macro_id	int
)
AS
SET NOCOUNT ON

select R1.macro_id,  char_id, macro_name, macro_tooltip, macro_iconname, macro_icontype, 
macro_order, macro_int1, macro_int2, macro_int3, macro_str from (
select * from user_macro  where char_id = @char_id and macro_id = @macro_id ) as R1
left join ( select * from user_macroinfo where macro_id = @macro_id  ) as R2
on R1.macro_id = R2.macro_id
 order by macro_order asc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_auction_bid]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_auction_bid](
	[bid_id] [int] IDENTITY(1,1) NOT NULL,
	[auction_id] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[bidding_price] [bigint] NOT NULL,
	[bidding_date] [datetime] NOT NULL CONSTRAINT [DF_item_auction_bid_bidding_date]  DEFAULT (getdate()),
	[withdraw] [tinyint] NOT NULL CONSTRAINT [DF_item_auction_bid_withdraw]  DEFAULT ((0)),
 CONSTRAINT [PK__item_auction_bid__0C091D65] PRIMARY KEY CLUSTERED 
(
	[bid_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[item_auction_bid]') AND name = N'IX_item_auction_bid_auction_id')
CREATE NONCLUSTERED INDEX [IX_item_auction_bid_auction_id] ON [dbo].[item_auction_bid] 
(
	[auction_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ViewSiegeList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ViewSiegeList    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_ViewSiegeList
	
INPUT	
	@castle_id	int,
	@type	int
OUTPUT
	pledge_id, 
	name 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_ViewSiegeList]
(
	@castle_id	int,
	@type	int
)
AS
SET NOCOUNT ON

SELECT 
	p.pledge_id, p.name 
FROM 
	pledge p (nolock) , 
	castle_war cw (nolock)  
WHERE 
	p.pledge_id = cw.pledge_id 
	AND cw.castle_id = @castle_id
	AND cw.type = @type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[time_attack_record]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[time_attack_record](
	[ssq_round] [int] NOT NULL,
	[room_no] [tinyint] NOT NULL,
	[record_type] [tinyint] NOT NULL,
	[ssq_part] [tinyint] NOT NULL,
	[point] [int] NOT NULL,
	[record_time] [int] NOT NULL,
	[elapsed_time] [int] NOT NULL,
	[member_count] [int] NOT NULL,
	[member_names] [nvarchar](256) NOT NULL,
	[member_dbid_list] [nvarchar](128) NULL,
	[member_reward_flags] [int] NULL,
	[fee] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[npc_boss]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[npc_boss](
	[npc_db_name] [nvarchar](50) NOT NULL,
	[alive] [int] NOT NULL,
	[hp] [int] NULL,
	[mp] [int] NULL,
	[pos_x] [int] NULL,
	[pos_y] [int] NULL,
	[pos_z] [int] NULL,
	[time_low] [int] NULL,
	[time_high] [int] NULL,
	[i0] [int] NOT NULL CONSTRAINT [DF_npc_boss_i0]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[npc_boss]') AND name = N'idx_npc_boss_unique_name')
CREATE UNIQUE NONCLUSTERED INDEX [idx_npc_boss_unique_name] ON [dbo].[npc_boss] 
(
	[npc_db_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pledge_contribution]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pledge_contribution](
	[residence_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[contribution] [int] NOT NULL CONSTRAINT [DF_pledge_contribution_contribution]  DEFAULT ((0)),
 CONSTRAINT [PK_pledge_contribution] PRIMARY KEY CLUSTERED 
(
	[residence_id] ASC,
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FlushSkillName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_FlushSkillName    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_FlushSkillName
	delete Skill name data
INPUT
OUTPUT
return
made by
	carrot
date
	2002-10-8
********************************************/
CREATE PROCEDURE [dbo].[lin_FlushSkillName]
AS
SET NOCOUNT ON

TRUNCATE TABLE skillData

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PetitionMsg]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PetitionMsg](
	[Char_Id] [int] NOT NULL,
	[msg] [nvarchar](1024) NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PetitionMsg]') AND name = N'idx_petmsg_charid')
CREATE NONCLUSTERED INDEX [idx_petmsg_charid] ON [dbo].[PetitionMsg] 
(
	[Char_Id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_item_ent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_item_ent](
	[item_type] [int] NOT NULL,
	[enchant] [int] NOT NULL,
	[count] [int] NOT NULL,
	[sum] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CheckPreviousAllianceWarHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CheckPreviousAllianceWarHistory
	
INPUT	
	@challenger_alliance_id		int
	@challengee_alliance_id		int

OUTPUT

made by
	bert
date
	2003-11-04
********************************************/

create PROCEDURE [dbo].[lin_CheckPreviousAllianceWarHistory]
(
	@challenger		int,
	@challengee		int
)
AS
SET NOCOUNT ON

SELECT 
	id, challenger, challengee, status, begin_time 
FROM 
	alliance_war (nolock)  
WHERE 
	(challenger = @challenger AND challengee = @challengee) 
	OR (challengee = @challengee AND challenger = @challenger) 
ORDER BY 
	begin_time DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAcademyMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetAcademyMaster
	set academy master
INPUT
	master_id		int,
	member_id		int,
	pledge_id	int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_SetAcademyMaster] (
	@master_id		int,
	@member_id		int,
	@pledge_id	int
)
AS

UPDATE academy_member
SET master_id = @master_id
WHERE user_id = @member_id AND pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ArchiveMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ArchiveMail
	archive mail
INPUT
	@char_id		int,
	@mail_id		int,
	@mailbox_type			int

OUTPUT
return
made by
	kks
date
	2004-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_ArchiveMail]
(
	@char_id		int,
	@mail_id		int,
	@mailbox_type			int
)
AS
SET NOCOUNT ON

IF @mailbox_type = 0
BEGIN
	UPDATE user_mail_receiver
	SET mailbox_type = 2
	WHERE mail_id = @mail_id AND
		receiver_id = @char_id
END

if @mailbox_type = 1
BEGIN
	UPDATE user_mail_sender
	SET mailbox_type = 2
	WHERE mail_id = @mail_id AND
		sender_id = @char_id 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetHeroById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetHeroById]
(
@char_id INT
)
AS

SELECT 
udnp.char_name AS char_name, 
udnp.main_class AS main_class, 
udnp.hero_type AS hero_type, 
udnp.pledge_id AS pledge_id,
ISNULL(udnp.pledge_name, N'''') AS pledge_name,
ISNULL(udnp.pledge_crest_id, 0) AS pledge_crest_id,
ISNULL(udnp.alliance_id, 0) AS alliance_id, 
ISNULL(a.name, N'''') AS alliance_name,
ISNULL(a.crest_id, 0) AS alliance_crest_id, 
udnp.win_count AS win_count,
ISNULL(udnp.words, N'''') AS words

FROM
	(SELECT
	udn.char_name AS char_name, 
	udn.main_class AS main_class, 
	udn.hero_type AS hero_type, 
	udn.pledge_id AS pledge_id,
	p.name AS pledge_name,
	p.crest_id AS pledge_crest_id,
	p.alliance_id AS alliance_id, 
	udn.win_count AS win_count,
	udn.words AS words
 
	FROM
		(SELECT
		ud.char_name AS char_name, 
		ud.subjob0_class AS main_class, 
		un.hero_type AS hero_type, 
		ud.pledge_id AS pledge_id,
		un.win_count AS win_count,
		un.words AS words
	
		FROM user_data AS ud
			INNER JOIN user_nobless AS un
			ON ud.char_id = @char_id AND ud.char_id = un.char_id
		) AS udn
			LEFT OUTER JOIN pledge AS p 
			ON udn.pledge_id = p.pledge_id
	) AS udnp
		LEFT OUTER JOIN alliance AS a 
		ON udnp.alliance_id = a.id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadPledgeMember    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadPledgeMember
	
INPUT
	pledge_id = @pledge_id
OUTPUT
return
made by
	carrot
date
	2002-06-10
change 2003-07-22 carrot
	check character is deleted.
	
	2006-03-03 kks
	subpledge
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPledgeMember]
(
	@pledge_id		int
)
AS
SET NOCOUNT ON

SELECT char_id, pledge_type FROM user_data (nolock) WHERE pledge_id = @pledge_id and account_id > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitFlame]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitFlame]
	@flame	int,
	@expire	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET mp_flame = @flame, mp_flame_expire = @expire WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuestData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[QuestData](
	[id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[data] [nvarchar](50) NOT NULL,
	[logdate] [smalldatetime] NOT NULL CONSTRAINT [DF_QuestData_logdate]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSubJobLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetSubJobLevel]
(  
 @char_id INT  
)  
AS  
 
SET NOCOUNT ON  

select s.subjob_id, case when u.subjob_id = s.subjob_id then u.lev
	else s.level end
from user_subjob s(nolock), user_data u(nolock)
where s.char_id = u.char_id and s.char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Academy_Member]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Academy_Member](
	[user_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[join_level] [int] NOT NULL,
	[master_id] [int] NOT NULL CONSTRAINT [DF__Academy_M__maste__69F265D5]  DEFAULT ((0)),
	[status] [int] NOT NULL CONSTRAINT [DF_Academy_Member_status]  DEFAULT ((0)),
	[status_time] [datetime] NOT NULL CONSTRAINT [DF_Academy_Member_status_time]  DEFAULT (getdate()),
 CONSTRAINT [PK_Academy_Member] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Academy_Member]') AND name = N'IX_Academy_Member')
CREATE NONCLUSTERED INDEX [IX_Academy_Member] ON [dbo].[Academy_Member] 
(
	[user_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Academy_Member]') AND name = N'IX_Academy_Member_1')
CREATE NONCLUSTERED INDEX [IX_Academy_Member_1] ON [dbo].[Academy_Member] 
(
	[master_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CancelAgitAuction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CancelAgitAuction
	cancel agit auction
INPUT
	@agit_id	int,


OUTPUT
return
made by
	young
date
	2003-12-11
********************************************/
CREATE PROCEDURE [dbo].[lin_CancelAgitAuction]
(
@agit_id		INT,
@last_cancel		INT
)
AS
SET NOCOUNT ON

declare @auction_id int
set @auction_id = 0

select @auction_id = isnull(auction_id , 0) from agit (nolock) where id = @agit_id

update agit set auction_id = 0 , last_cancel = @last_cancel where id = @agit_id

select @auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sub_pledge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[sub_pledge](
	[pledge_id] [int] NOT NULL,
	[master_id] [int] NOT NULL CONSTRAINT [DF__sub_pledg__maste__0C477DD9]  DEFAULT ((0)),
	[type] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[member_count_upgrade] [int] NOT NULL CONSTRAINT [DF_sub_pledge_member_count_upgrade]  DEFAULT ((0)),
 CONSTRAINT [PK_sub_pledge] PRIMARY KEY CLUSTERED 
(
	[pledge_id] ASC,
	[type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[minigame_agit_pledge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[minigame_agit_pledge](
	[agit_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[propose_time] [datetime] NOT NULL CONSTRAINT [DF__minigame___propo__7C111610]  DEFAULT (getdate()),
	[point] [int] NOT NULL,
 CONSTRAINT [PK_minigame_agit_pledge] PRIMARY KEY CLUSTERED 
(
	[agit_id] ASC,
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateCastle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UpdateCastle    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE
[dbo].[lin_UpdateCastle] (@id INT, @pledge_id INT, @next_war_time INT, @tax_rate SMALLINT)
AS
UPDATE castle
SET pledge_id = @pledge_id, next_war_time = @next_war_time, tax_rate = @tax_rate
WHERE id = @id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CheckReserved]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CheckReserved    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_CheckReserved
	
INPUT
	@char_name	NCHAR(12),
	@account_name	NCHAR(13),
	@account_id	INT
OUTPUT
	
return
made by
	carrot
date
	2003-07-09
change
********************************************/
CREATE PROCEDURE [dbo].[lin_CheckReserved]
(
@char_name	NVARCHAR(24),
@account_name	NVARCHAR(24),
@account_id	INT
)
AS

SET NOCOUNT ON

SET @char_name = RTRIM(@char_name)

-- check reserved name
declare @reserved_name nvarchar(50)
declare @reserved_account_id int
select top 1 @reserved_name = char_name, @reserved_account_id = account_id from user_name_reserved (nolock) where used = 0 and char_name = @char_name
if not @reserved_name is null
begin
	if not @reserved_account_id = @account_id
	begin
		RAISERROR (''Character name is reserved by other player: name = [%s]'', 16, 1, @char_name)
		RETURN -1
	end
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_event_time]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_event_time](
	[account_id] [int] NOT NULL,
	[event_time] [int] NOT NULL,
 CONSTRAINT [PK__user_event_time__3A792834] PRIMARY KEY CLUSTERED 
(
	[account_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_ActiveSkill]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_ActiveSkill](
	[char_id] [int] NOT NULL,
	[s1] [int] NULL,
	[l1] [smallint] NULL,
	[d1] [int] NULL,
	[s2] [int] NULL,
	[l2] [smallint] NULL,
	[d2] [int] NULL,
	[s3] [int] NULL,
	[l3] [smallint] NULL,
	[d3] [int] NULL,
	[s4] [int] NULL,
	[l4] [smallint] NULL,
	[d4] [int] NULL,
	[s5] [int] NULL,
	[l5] [smallint] NULL,
	[d5] [int] NULL,
	[s6] [int] NULL,
	[l6] [smallint] NULL,
	[d6] [int] NULL,
	[s7] [int] NULL,
	[l7] [smallint] NULL,
	[d7] [int] NULL,
	[s8] [int] NULL,
	[l8] [smallint] NULL,
	[d8] [int] NULL,
	[s9] [int] NULL,
	[l9] [smallint] NULL,
	[d9] [int] NULL,
	[s10] [int] NULL,
	[l10] [smallint] NULL,
	[d10] [int] NULL,
	[s11] [int] NULL,
	[l11] [smallint] NULL,
	[d11] [int] NULL,
	[s12] [int] NULL,
	[l12] [smallint] NULL,
	[d12] [int] NULL,
	[s13] [int] NULL,
	[l13] [smallint] NULL,
	[d13] [int] NULL,
	[s14] [int] NULL,
	[l14] [smallint] NULL,
	[d14] [int] NULL,
	[s15] [int] NULL,
	[l15] [smallint] NULL,
	[d15] [int] NULL,
	[s16] [int] NULL,
	[l16] [smallint] NULL,
	[d16] [int] NULL,
	[s17] [int] NULL,
	[l17] [smallint] NULL,
	[d17] [int] NULL,
	[s18] [int] NULL,
	[l18] [smallint] NULL,
	[d18] [int] NULL,
	[s19] [int] NULL,
	[l19] [smallint] NULL,
	[d19] [int] NULL,
	[s20] [int] NULL,
	[l20] [smallint] NULL,
	[d20] [int] NULL,
	[c1] [tinyint] NULL,
	[c2] [tinyint] NULL,
	[c3] [tinyint] NULL,
	[c4] [tinyint] NULL,
	[c5] [tinyint] NULL,
	[c6] [tinyint] NULL,
	[c7] [tinyint] NULL,
	[c8] [tinyint] NULL,
	[c9] [tinyint] NULL,
	[c10] [tinyint] NULL,
	[c11] [tinyint] NULL,
	[c12] [tinyint] NULL,
	[c13] [tinyint] NULL,
	[c14] [tinyint] NULL,
	[c15] [tinyint] NULL,
	[c16] [tinyint] NULL,
	[c17] [tinyint] NULL,
	[c18] [tinyint] NULL,
	[c19] [tinyint] NULL,
	[c20] [tinyint] NULL,
	[s21] [int] NULL,
	[s22] [int] NULL,
	[s23] [int] NULL,
	[s24] [int] NULL,
	[s25] [int] NULL,
	[s26] [int] NULL,
	[s27] [int] NULL,
	[s28] [int] NULL,
	[s29] [int] NULL,
	[s30] [int] NULL,
	[s31] [int] NULL,
	[s32] [int] NULL,
	[s33] [int] NULL,
	[s34] [int] NULL,
	[l21] [smallint] NULL,
	[l22] [smallint] NULL,
	[l23] [smallint] NULL,
	[l24] [smallint] NULL,
	[l25] [smallint] NULL,
	[l26] [smallint] NULL,
	[l27] [smallint] NULL,
	[l28] [smallint] NULL,
	[l29] [smallint] NULL,
	[l30] [smallint] NULL,
	[l31] [smallint] NULL,
	[l32] [smallint] NULL,
	[l33] [smallint] NULL,
	[l34] [smallint] NULL,
	[d21] [int] NULL,
	[d22] [int] NULL,
	[d23] [int] NULL,
	[d24] [int] NULL,
	[d25] [int] NULL,
	[d26] [int] NULL,
	[d27] [int] NULL,
	[d28] [int] NULL,
	[d29] [int] NULL,
	[d30] [int] NULL,
	[d31] [int] NULL,
	[d32] [int] NULL,
	[d33] [int] NULL,
	[d34] [int] NULL,
	[c21] [tinyint] NULL,
	[c22] [tinyint] NULL,
	[c23] [tinyint] NULL,
	[c24] [tinyint] NULL,
	[c25] [tinyint] NULL,
	[c26] [tinyint] NULL,
	[c27] [tinyint] NULL,
	[c28] [tinyint] NULL,
	[c29] [tinyint] NULL,
	[c30] [tinyint] NULL,
	[c31] [tinyint] NULL,
	[c32] [tinyint] NULL,
	[c33] [tinyint] NULL,
	[c34] [tinyint] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_ActiveSkill]') AND name = N'idx_user_ActiveSkill')
CREATE NONCLUSTERED INDEX [idx_user_ActiveSkill] ON [dbo].[user_ActiveSkill] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_ActiveSkill]') AND name = N'IX_user_ActiveSkill')
CREATE UNIQUE NONCLUSTERED INDEX [IX_user_ActiveSkill] ON [dbo].[user_ActiveSkill] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveItemExpiration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveItemExpiration  
 Save item Expiration  
INPUT  
   item_id, user_id, expiration_date
OUTPUT  

return  
made by  
 zzangse  
date  
 2006-03-08  
********************************************/  
CREATE  PROCEDURE [dbo].[lin_SaveItemExpiration]  
(
	@item_id 	int,
	@user_id	int,
	@expiration_date	int
)
AS  
SET NOCOUNT ON  
  
  
SELECT top 1 item_id FROM item_expiration WHERE item_id = @item_id
if(@@ROWCOUNT > 0)
	begin
		update item_expiration	set user_id = @user_id, expiration_date = @expiration_date
	end
else
	begin
		insert into item_expiration	values(@item_id, @user_id, @expiration_date)
	end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_home_pccafe_point]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_home_pccafe_point](
	[char_id] [int] NOT NULL CONSTRAINT [DF_user_home_pccafe_point_id]  DEFAULT ((0)),
	[point] [int] NULL CONSTRAINT [DF_user_home_pccafe_point_point]  DEFAULT ((0)),
	[saved_day] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_home_pccafe_point]') AND name = N'IX_user_home_pccafe_point')
CREATE NONCLUSTERED INDEX [IX_user_home_pccafe_point] ON [dbo].[user_home_pccafe_point] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetMinigameAgitStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_SetMinigameAgitStatus]
(
	@agit_id	int,
	@elapsed_time int
)
as
set nocount on
IF NOT exists (SELECT * FROM minigame_agit_status WHERE agit_id = @Agit_id )
	insert into minigame_agit_status(agit_id, elapsed_time) values (@agit_id, @elapsed_time)
ELSE
	update minigame_agit_status set elapsed_time=@elapsed_time, propose_time=getdate() where agit_id=@agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadOwnthing]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadOwnthing]  
(  
 @original_dominion_id int
)  
AS  
SET NOCOUNT ON  
  
SELECT	current_dominion_id, pos_x, pos_y, pos_z
FROM	ownthing(nolock)
WHERE	original_dominion_id = @original_dominion_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeTimeData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_ChangeTimeData      
 chagne time data table      
INPUT        
 @char_name NVARCHAR(30),        
 @nType INT,        
 @nChangeMin INT        
OUTPUT        
 changed acount id      
 result used sec      
return        
       
made by        
 carrot        
date        
 2004-04-29        
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_ChangeTimeData]      
(        
 @char_name NVARCHAR(30),        
 @nType INT,        
 @nChangeMin INT        
)        
AS        
        
SET NOCOUNT ON        
        
      
SET @nChangeMin = @nChangeMin * 60      -- change min to sec
IF (@nType < 1 OR @nType > 2 OR @nChangeMin <= 0) -- 1 : add, 2 : del
BEGIN        
    RAISERROR (''Not valid parameter : charnname[%s] type[%d], min[%d] '',16, 1,  @char_name,  @nType , @nChangeMin )        
    RETURN -1        
END        
        
DECLARE @account_id INT        
SET @account_id = 0    
SELECT @account_id = account_id FROM user_data (nolock) WHERE char_name = @char_name      
        
IF (@account_id <= 0)        
BEGIN        
    RAISERROR (''Not valid account id : charnname[%s] type[%d], min[%d] '',16, 1,  @char_name,  @nType , @nChangeMin )        
    RETURN -1        
END        
      
DECLARE @used_sec INT        
SET @used_sec = -1      
SELECT TOP 1 @used_sec = used_sec FROM time_data WHERE account_id = @account_id      
IF (@used_sec < 0 )      
BEGIN      
    RAISERROR (''Not exist time data : account_id[%d], charnname[%s] type[%d], min[%d] '',16, 1,  @account_id, @char_name,  @nType , @nChangeMin )        
    RETURN -1        
END      
      
IF (@nType = 1) -- add      
BEGIN      
 UPDATE time_data SET used_sec = @used_sec + @nChangeMin WHERE account_id = @account_id      
END      
ELSE IF (@nType = 2) -- del      
BEGIN      
 IF (@used_sec < @nChangeMin)      
 BEGIN      
  SET @nChangeMin = @used_sec
 END      
 UPDATE time_data SET used_sec = @used_sec - @nChangeMin WHERE account_id = @account_id      
END      
ELSE      
BEGIN      
    RAISERROR (''Not valid parameter : charnname[%s] type[%d], min[%d] '',16, 1,  @char_name,  @nType , @nChangeMin )        
    RETURN -1        
END      
      
SELECT TOP 1 account_id, used_sec FROM time_data WHERE account_id = @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBbsTGSList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetBbsTGSList    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_GetBbsTGSList] 
(
	@nPage	INT,
	@nLinesPerPage	INT
)
AS

SET NOCOUNT ON

declare @nTot int

If @nPage IS NULL or @nPage < 1 
BEGIN
	SET @nPage = 1
END

If @nLinesPerPage IS NULL or @nLinesPerPage < 1 
BEGIN
	SET @nLinesPerPage = 1
END

select @nTot = count(id) - 1 from bbs_tgs (nolock)

select 
	orderedTitle.id, orderedTitle.title, left(orderedTitle.writer, 8), left(orderedTitle.contents, 80), 
SUBSTRING(CONVERT(VARCHAR, orderedtitle.cdate, 20), 6, 11 ),  
(@nTot / @nLinesPerPage) + 1
from 
	(Select 
		count(bbs2.id) as cnt, bbs1.id, bbs1.title, bbs1.cdate, bbs1.writer, bbs1.contents
	from 
		Bbs_tgs as bbs1
		inner join
		Bbs_tgs as bbs2
		on bbs1.id <= bbs2.id
	group by 
		bbs1.id, bbs1.title, bbs1.cdate, bbs1.writer, bbs1.contents
	) as orderedTitle
where 
	orderedTitle.cnt > (@nPage - 1) * @nLinesPerPage and orderedTitle.cnt <= @nPage * @nLinesPerPage
ORDER BY 
	orderedTitle.cnt ASC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[npcname]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[npcname](
	[npc_id] [int] NULL,
	[npc_name] [nvarchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveSSQUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_SaveSSQUserInfo
  * @brief Save user''s ssq parameter  to ssq_user_data
  * 
  * @date 2004/11/18
  * @author sonai <sonai@ncsoft.net>
  * 
  * 레코드가 없는 경우에는 새로운 값을 넣는다.
  *
  * @param[in]  ssq_part	SSQ 소속(황혼 : 1,  새벽 : 2)
  * @param[in]  ssq_position  SSQ 직위
  * @param[in]  seal_selection_no  가입시 선택한 봉인 번호
  * @param[in]  ssq_point  SSQ 공헌도 점수
  */
CREATE PROCEDURE [dbo].[lin_SaveSSQUserInfo] 
(
@char_id INT,
@round_number INT,
@ssq_join_time INT,
@ssq_part INT,
@ssq_position INT,
@seal_selection_no INT,
@ssq_point BIGINT,
@twilight_a_item_num BIGINT,
@twilight_b_item_num BIGINT,
@twilight_c_item_num BIGINT,
@dawn_a_item_num BIGINT,
@dawn_b_item_num BIGINT,
@dawn_c_item_num BIGINT,
@ticket_buy_count BIGINT
)
AS
SET NOCOUNT ON
IF EXISTS(SELECT * FROM ssq_user_data WHERE char_id = @char_id)
    BEGIN
    UPDATE ssq_user_data SET  round_number = @round_number,
                                                     ssq_join_time = @ssq_join_time,
 			             ssq_part = @ssq_part, 
		                          ssq_position = @ssq_position, 
			             seal_selection_no = @seal_selection_no, 
		                          ssq_point = @ssq_point,                                         
			             twilight_a_item_num = @twilight_a_item_num,
			             twilight_b_item_num = @twilight_b_item_num,
			             twilight_c_item_num = @twilight_c_item_num,
			             dawn_a_item_num = @dawn_a_item_num,
			             dawn_b_item_num = @dawn_b_item_num,
			             dawn_c_item_num = @dawn_c_item_num,
			             ticket_buy_count = @ticket_buy_count	
			             WHERE char_id = @char_id
   END
ELSE
   BEGIN
   INSERT INTO ssq_user_data (char_id, round_number, ssq_join_time, ssq_part, ssq_position,
			            seal_selection_no, ssq_point,
                                                    twilight_a_item_num, twilight_b_item_num, twilight_c_item_num,
                                                    dawn_a_item_num, dawn_b_item_num, dawn_c_item_num,
                                                    ticket_buy_count) 
	VALUES (@char_id, @round_number, @ssq_join_time, @ssq_part, @ssq_position,
			            @seal_selection_no, @ssq_point,
                                                    @twilight_a_item_num, @twilight_b_item_num, @twilight_c_item_num,
                                                    @dawn_a_item_num, @dawn_b_item_num, @dawn_c_item_num,
                                                    @ticket_buy_count)
   END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_item_stack]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_item_stack](
	[char_id] [int] NOT NULL,
	[item_type] [int] NOT NULL,
	[amount] [bigint] NOT NULL,
	[warehouse] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[object_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[object_data](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[owner_id] [int] NOT NULL CONSTRAINT [DF_object_data_pledge_id]  DEFAULT ((0)),
	[residence_id] [int] NOT NULL CONSTRAINT [DF_object_data_castle_id]  DEFAULT ((0)),
	[max_hp] [int] NOT NULL CONSTRAINT [DF_object_data_max_hp]  DEFAULT ((0)),
	[hp] [int] NOT NULL CONSTRAINT [DF_object_data_hp]  DEFAULT ((0)),
	[x_pos] [int] NOT NULL CONSTRAINT [DF_object_data_x_pos]  DEFAULT ((0)),
	[y_pos] [int] NOT NULL CONSTRAINT [DF_object_data_y_pos]  DEFAULT ((0)),
	[z_pos] [int] NOT NULL CONSTRAINT [DF_object_data_z_pos]  DEFAULT ((0)),
	[type] [int] NOT NULL,
 CONSTRAINT [PK_object_data] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertAgitAdena]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_InsertAgitAdena
	create agit_adena
INPUT
	
OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_InsertAgitAdena]
(
@agit_id		INT,
@pledge_id		INT,
@auction_id		INT,
@reason		INT,
@adena		BIGINT
)
AS
SET NOCOUNT ON
insert into agit_adena ( agit_id, pledge_id, auction_id, reason, adena)
values ( @agit_id, @pledge_id, @auction_id, @reason, @adena)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpgradeSubPledgeMemberCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpgradeSubPledgeMemberCount
	set subpledge master
INPUT
	@pledge_id		int
	@pledge_type		int
OUTPUT
return
date
	2006-04-21	kks
********************************************/
CREATE PROCEDURE
[dbo].[lin_UpgradeSubPledgeMemberCount] (
	@pledge_id		int,
	@pledge_type		int
)
AS
UPDATE sub_pledge
SET member_count_upgrade = 1
WHERE pledge_id = @pledge_id AND type = @pledge_type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveBotReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveBotReport] 
(
	@char_id int,
	@reported_date int
)
AS

SET NOCOUNT ON


UPDATE bot_report SET reported = reported + 1, reported_date = @reported_date
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO bot_report (char_id, reported, reported_date, bot_admin) 
	VALUES (@char_id, 1, @reported_date, 0)  	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertUserHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_InsertUserHistory    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_InsertUserHistory
	make user history log
INPUT
	@char_name	nvarchar(50),
	@char_id	int,
	@log_action	tinyint,
	@account_name	nvarchar(50),
	@create_date		datetime
OUTPUT
return
made by
	young
date
	2003-1-14
********************************************/
CREATE PROCEDURE [dbo].[lin_InsertUserHistory]
(
	@char_name	nvarchar(50),
	@char_id	int,
	@log_action	tinyint,
	@account_name	nvarchar(50),
	@create_date		datetime
)
AS
SET NOCOUNT ON

declare @create_date2 datetime

if @create_date is NULL
begin
	set @create_date2 = getdate()
end
else
begin
	set @create_date2 = @create_date
end
insert into user_history( char_name, char_id, log_action, account_name, create_date) values
( @char_name, @char_id, @log_action, @account_name, @create_date2)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_recipe]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_recipe](
	[char_id] [int] NOT NULL,
	[recipe_id] [int] NOT NULL,
 CONSTRAINT [PK_user_recipe] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[recipe_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_item]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_item](
	[item_id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[char_id] [int] NOT NULL,
	[item_type] [int] NOT NULL,
	[amount] [bigint] NOT NULL,
	[enchant] [int] NOT NULL,
	[eroded] [int] NOT NULL,
	[bless] [tinyint] NOT NULL,
	[ident] [int] NOT NULL,
	[wished] [tinyint] NOT NULL CONSTRAINT [DF_user_item_wished]  DEFAULT ((0)),
	[warehouse] [int] NOT NULL,
	[variation_opt1] [int] NULL CONSTRAINT [DF_user_item_variation_opt1]  DEFAULT ((0)),
	[variation_opt2] [int] NULL CONSTRAINT [DF_user_item_variation_opt2]  DEFAULT ((0)),
	[intensive_item_type] [int] NULL CONSTRAINT [DF_user_item_intensive_item_type]  DEFAULT ((0)),
	[inventory_slot_index] [int] NULL CONSTRAINT [DF_user_item_inventory_slot_index]  DEFAULT ((-1)),
 CONSTRAINT [pk_user_item] PRIMARY KEY NONCLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_item]') AND name = N'idx_user_item_charid')
CREATE CLUSTERED INDEX [idx_user_item_charid] ON [dbo].[user_item] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_item]') AND name = N'idx_item_type')
CREATE NONCLUSTERED INDEX [idx_item_type] ON [dbo].[user_item] 
(
	[item_type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_item]') AND name = N'idx_useritem_ware')
CREATE NONCLUSTERED INDEX [idx_useritem_ware] ON [dbo].[user_item] 
(
	[warehouse] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMacro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMacro
	get macro
INPUT
	@char_id		int,
OUTPUT
return
made by
	young
date
	2004-6-11
********************************************/
CREATE PROCEDURE [dbo].[lin_GetMacro]
(
@char_id		int
)
AS
SET NOCOUNT ON

select R1.macro_id,  char_id, macro_name, macro_tooltip, macro_iconname, macro_icontype, 
macro_order, macro_int1, macro_int2, macro_int3, macro_str from (
select * from user_macro  where char_id = @char_id ) as R1
left join ( select * from user_macroinfo ) as R2
on R1.macro_id = R2.macro_id
order by R1.macro_id asc ,   macro_order asc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetDbRelatedCounts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetDbRelatedCounts]
AS  
SET NOCOUNT ON  
  
SELECT  
(SELECT COUNT(id) FROM alliance) AS alliance_count,  
(SELECT COUNT(*) FROM war_declare WHERE challenger IN (SELECT pledge_id FROM pledge) AND challengee IN (SELECT pledge_id FROM pledge)) AS pledge_war_count,  
(SELECT COUNT(pledge_id) FROM pledge WHERE status = 3) AS dismiss_reserved_count,
(SELECT COUNT(*) FROM user_nobless WHERE char_id IN (SELECT char_id FROM user_data)) AS nobless_count

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllianceWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadAllianceWar
	
INPUT
	@war_id		int
OUTPUT
return
made by
	bert
date
	2003-11-07
********************************************/
create PROCEDURE [dbo].[lin_LoadAllianceWar]
(
	@war_id		int
)
AS
SET NOCOUNT ON

SELECT challenger, challengee, begin_time, status FROM alliance_war (nolock)  WHERE id = @war_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_ui]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_ui](
	[char_id] [int] NOT NULL,
	[ui_setting_size] [smallint] NOT NULL CONSTRAINT [DF_user_ui_ui_setting_size]  DEFAULT ((0)),
	[ui_setting] [varbinary](8000) NOT NULL CONSTRAINT [DF_user_ui_ui_setting]  DEFAULT ((0)),
 CONSTRAINT [PK_user_ui_char_id] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateLottoGame]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UpdateLottoGame]
(
	@round_number int,
	@state int,
	@left_time int,
	@chosen_nuimber_flag int,
	@rule_number int,
	@total_count int,
	@winner1_count int,
	@winner2_count int,
	@winner3_count int,
	@winner4_count int,
	@carried_adena bigint
) 
AS       
SET NOCOUNT ON    
update lotto_game
set  	state = @state,
	left_time = @left_time,
	chosen_number_flag = @chosen_nuimber_flag ,
	rule_number = @rule_number ,
	total_count = @total_count ,
	winner1_count = @winner1_count ,
	winner2_count = @winner2_count ,
	winner3_count = @winner3_count ,
	winner4_count = @winner4_count ,
	carried_adena = @carried_adena 
where round_number = @round_number

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAccount    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadAccount
	
INPUT
	@account_id	int
OUTPUT
return
made by
	carrot
date
	2002-06-09
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadAccount]
(
@account_id	int
)
AS
SET NOCOUNT ON

if @account_id < 1
begin
	RAISERROR (''lin_LoadAccount : invalid account_id [%d]'', 16, 1, @account_id)
	RETURN -1	
end

SELECT top 10 char_id, account_name FROM user_data (nolock) WHERE account_id= @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharCopyChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_MoveCharCopyChar]
(
	@world_id	varchar(5)
)
AS


declare @sql varchar(1024)
declare @conn_str varchar(256)

set @conn_str = ''127.0.0.'' + @world_id + '''''';''''sa'''';''''st82cak9''


set @sql = '' insert into req_charmove ( old_char_name, old_char_id, account_name, account_id,  old_world_id, new_world_id, new_char_name ) select R1.char_name, char_id, account_name, account_id, '' + @world_id + '' , 100, R1.char_name + ''''-'' + @world_id + ''''''   from ( select * from ''
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '''' select char_id, char_name, account_id, account_name from lin2world.dbo.user_data (nolock)  '''' ) )  as R1 ''
	+ '' left join ( select * from req_char (nolock) where server_id = '' + @world_id + '' ) as R2 ''
	+ '' on R1.char_name = R2.char_name ''
	+ '' where server_id is not null ''
exec ( @sql )

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_macroinfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_macroinfo](
	[macro_id] [int] NOT NULL,
	[macro_order] [int] NULL,
	[macro_int1] [int] NULL,
	[macro_int2] [int] NULL,
	[macro_int3] [int] NULL,
	[macro_str] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_macroinfo]') AND name = N'IX_user_macroinfo')
CREATE CLUSTERED INDEX [IX_user_macroinfo] ON [dbo].[user_macroinfo] 
(
	[macro_id] ASC,
	[macro_order] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateSSQUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
 * @fn lin_CreateSSQUserInfo
 * @brief  SSQ관련 유저 레코드 생성.
 */
CREATE PROCEDURE [dbo].[lin_CreateSSQUserInfo]
(
@char_id INT,
@round_number INT,
@ssq_join_time INT,
@ssq_part INT,
@ssq_position INT,
@seal_selection_no INT,
@ssq_point BIGINT,
@twilight_a_item_num BIGINT,
@twilight_b_item_num BIGINT,
@twilight_c_item_num BIGINT,
@dawn_a_item_num BIGINT,
@dawn_b_item_num BIGINT,
@dawn_c_item_num BIGINT,
@ticket_buy_count INT
)
AS
SET NOCOUNT ON
INSERT INTO ssq_user_data  
	(char_id, round_number, ssq_join_time, ssq_part, ssq_position, seal_selection_no, ssq_point,
              twilight_a_item_num, twilight_b_item_num, twilight_c_item_num, dawn_a_item_num, dawn_b_item_num, dawn_c_item_num,
              ticket_buy_count) 
	values 
	(@char_id, @round_number, @ssq_join_time, @ssq_part, @ssq_position, @seal_selection_no, @ssq_point,
              @twilight_a_item_num, @twilight_b_item_num, @twilight_c_item_num, @dawn_a_item_num, @dawn_b_item_num, @dawn_c_item_num,
              @ticket_buy_count)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_sociality]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_sociality](
	[char_id] [int] NOT NULL,
	[sociality] [int] NOT NULL,
	[used_sulffrage] [int] NOT NULL,
	[last_changed] [datetime] NOT NULL,
 CONSTRAINT [PK_user_sociality] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSociality]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_LoadSociality
 load sociality
INPUT        
 @char_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_LoadSociality]
(        
 @char_id INT
)        
AS        
        
SET NOCOUNT ON        

IF EXISTS(SELECT  * FROM user_sociality WHERE char_id = @char_id)
BEGIN
	SELECT  sociality, used_sulffrage, convert(nvarchar(19), last_changed, 121) FROM user_sociality WHERE char_id = @char_id
END
ELSE
BEGIN
	SELECT  0, 0, ''0000-00-00 00:00:00''
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateAgitHatcher]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateAgitHatcher]
	@hatcher	int,
	@agit_id	int
as
set nocount on

UPDATE agit SET hatcher = @hatcher WHERE id = @agit_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ManageUserNameReserved]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ManageUserNameReserved
	manage user name reserved ( add, del )
INPUT
	@option	int,
	@char_name	nvarchar(50),
	@account_id	int,
	@used		int
OUTPUT

return
made by
	kks
date
	2004-12-13
********************************************/
CREATE PROCEDURE [dbo].[lin_ManageUserNameReserved]
(
	@option	int,
	@char_name	nvarchar(50),
	@account_id	int,
	@used		int
)
AS
SET NOCOUNT ON

declare @reservedcount int
set @reservedcount  = 0

if ( @option = 0 )
begin
	-- add user name reserved
	select @reservedcount  = count(*) from user_name_reserved (nolock) where char_name = @char_name
	if ( @reservedcount >= 1)
		return

	insert into user_name_reserved ( char_name, account_id, used )
	values ( @char_name, @account_id, @used )
end 

if ( @option = 1 )
begin
	-- del user_name_reserved
	delete from user_name_reserved where char_name = @char_name
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBossRecordRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadBossRecordRanking
	Load Boss Record Ranking
INPUT  
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-03-07
********************************************/  
CREATE    PROCEDURE [dbo].[lin_LoadBossRecordRanking]  
AS  
SET NOCOUNT ON  
  
select char_id, sum(point) from user_bossrecord
group by char_id
having sum(point) > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllItemExpiration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadAllItemExpiration  
 Load item Expiration  
INPUT  
   
OUTPUT  
 item_id, user_id, expiration_date  
return  
made by  
 zzangse  
date  
 2006-01-23  
********************************************/  
CREATE  PROCEDURE [dbo].[lin_LoadAllItemExpiration]  

AS  
SET NOCOUNT ON  
  
  
SELECT item_id, user_id, expiration_date FROM item_expiration

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetBotReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ResetBotReport] 
(
	@char_id int
)
AS

SET NOCOUNT ON

UPDATE bot_report SET reported = 0
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO bot_report (char_id, reported, reported_date, bot_admin) 
	VALUES (@char_id, 0, 0, 0)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSiegeAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadSiegeAgitPledge]
(
	@agit_id INT
)
AS
SET NOCOUNT ON
SELECT pledge_id, propose_time, status FROM siege_agit_pledge WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[castle_tax]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[castle_tax](
	[income_update] [datetime] NOT NULL,
	[tax_change] [datetime] NOT NULL,
	[manor_reset] [datetime] NOT NULL CONSTRAINT [DF__castle_ta__manor__26B08FFB]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_mail_receiver]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_mail_receiver](
	[mail_id] [int] NOT NULL,
	[mailbox_type] [tinyint] NOT NULL CONSTRAINT [DF_user_mail_receiver_mailbox_type_1]  DEFAULT ((0)),
	[receiver_id] [int] NOT NULL,
	[receiver_name] [nvarchar](50) NOT NULL,
	[read_date] [datetime] NULL,
	[read_status] [tinyint] NOT NULL CONSTRAINT [DF_user_mail_receiver_read_status]  DEFAULT ((0)),
	[deleted] [tinyint] NOT NULL CONSTRAINT [DF_user_mail_receiver_deleted]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_mail_receiver]') AND name = N'IX_user_mail_receiver_1')
CREATE NONCLUSTERED INDEX [IX_user_mail_receiver_1] ON [dbo].[user_mail_receiver] 
(
	[mail_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_mail_receiver]') AND name = N'IX_user_mail_receiver_2')
CREATE NONCLUSTERED INDEX [IX_user_mail_receiver_2] ON [dbo].[user_mail_receiver] 
(
	[receiver_id] ASC,
	[read_status] ASC,
	[deleted] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetMacro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetMacro
	ALTER  macro
INPUT
	@macro_id		int,
	@macro_name		nvarchar(64),
	@macro_tooltip		nvarchar(64)
	@macro_iconname	nvarchar(64)
	@macro_icontype		int

OUTPUT
return
made by
	young
date
	2004-6-16
********************************************/
CREATE PROCEDURE [dbo].[lin_SetMacro]
(
@macro_id		int,
@macro_name		nvarchar(64),
@macro_tooltip		nvarchar(64),
@macro_iconname	nvarchar(64),
@macro_icontype	int
)
AS
SET NOCOUNT ON

if ( exists ( select * from user_macro where macro_id = @macro_id ) )
begin
	update user_macro
	set macro_name = @macro_name, macro_tooltip = @macro_tooltip,
		macro_iconname = @macro_iconname, macro_icontype = @macro_icontype
	where macro_id = @macro_id


	delete from user_macroinfo where macro_id = @macro_id


end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[login_announce]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[login_announce](
	[announce_id] [int] NOT NULL,
	[announce_msg] [nvarchar](256) NULL,
	[interval_10] [int] NOT NULL CONSTRAINT [DF_login_announce_interval_10]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_henna]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_henna](
	[char_id] [int] NOT NULL,
	[henna_1] [int] NOT NULL CONSTRAINT [DF_user_henna_henna_1]  DEFAULT ((0)),
	[henna_2] [int] NOT NULL CONSTRAINT [DF_user_henna_henna_2]  DEFAULT ((0)),
	[henna_3] [int] NOT NULL CONSTRAINT [DF_user_henna_henna_3]  DEFAULT ((0)),
	[subjob_id] [int] NULL,
 CONSTRAINT [PK_user_henna] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[builder_account]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[builder_account](
	[account_name] [nvarchar](50) NOT NULL,
	[default_builder] [int] NOT NULL CONSTRAINT [DF_account_builder_default_builder]  DEFAULT ((0)),
	[account_id] [int] NOT NULL CONSTRAINT [DF_builder_account_account_id]  DEFAULT ((0)),
 CONSTRAINT [PK_account_builder] PRIMARY KEY CLUSTERED 
(
	[account_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveOwnthing]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveOwnthing]  
(  
 @original_dominion_id int,  
 @current_dominion_id int,  
 @pos_x int,
 @pos_y int,
 @pos_z int
)  
AS
SET NOCOUNT ON

UPDATE ownthing SET current_dominion_id = @current_dominion_id, pos_x = @pos_x, pos_y = @pos_y, pos_z = @pos_z
WHERE original_dominion_id = @original_dominion_id

IF @@rowcount = 0
BEGIN
	INSERT INTO ownthing (original_dominion_id, current_dominion_id, pos_x, pos_y, pos_z) 
	VALUES (@original_dominion_id, @current_dominion_id, @pos_x, @pos_y, @pos_z) 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSharedReuseDelaysOfItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadSharedReuseDelaysOfItems
	Load Shared Reuse Delays of Items
INPUT  
	@char_id	int
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-09-22
********************************************/  
CREATE      PROCEDURE [dbo].[lin_LoadSharedReuseDelaysOfItems]  
(
	@char_id	int
)
AS  
SET NOCOUNT ON  
  
select shared_delay_id, next_available_time  from shared_reuse_delays_of_items
where char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModSubJobAbilityAbsolutely]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModSubJobAbilityAbsolutely
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@sp		int,
	@exp		bigint,
	@lev		int
OUTPUT
return
made by
	kks
date
	2005-01-18
	2006-01-25	btwinuni	exp: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_ModSubJobAbilityAbsolutely]
(
	@char_id	int,
	@subjob_id	int,
	@sp		int,
	@exp		bigint,
	@lev		int
)
AS
SET NOCOUNT ON

update user_subjob set sp =  @sp, exp = @exp,  level =  @lev where char_id = @char_id and subjob_id = @subjob_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPledgeCrest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetPledgeCrest    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_SetPledgeCrest
-- by bert
-- return crest id
-- modified by kks (2005-08-18)

CREATE PROCEDURE [dbo].[lin_SetPledgeCrest]
(
	@bitmap_size	INT,
	@bitmap	VARBINARY(3072)
)
AS

SET NOCOUNT ON

INSERT INTO Pledge_Crest
(bitmap_size, bitmap) VALUES (@bitmap_size, @bitmap)

SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateLottoGame]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreateLottoGame]
(
	@round_number int,
	@state int,
	@left_time int,
	@chosen_nuimber_flag int,
	@rule_number int,
	@total_count int,
	@winner1_count int,
	@winner2_count int,
	@winner3_count int,
	@winner4_count int,
	@carried_adena bigint
) 
AS       
SET NOCOUNT ON    
insert into lotto_game
values
(
	@round_number ,
	@state,
	@left_time,
	@chosen_nuimber_flag ,
	@rule_number ,
	@total_count ,
	@winner1_count ,
	@winner2_count ,
	@winner3_count ,
	@winner4_count ,
	@carried_adena )

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[manor_fix]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[manor_fix](
	[char_id] [int] NOT NULL,
	[item_type] [int] NOT NULL,
	[amount] [int] NOT NULL,
	[warehouse] [int] NOT NULL,
	[error_amount] [int] NULL,
	[to_dec] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateCastle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CreateCastle    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_CreateCastle
	
INPUT	
	@id	int,
	@name	nvarchar(50)
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_CreateCastle]
(
	@id	int,
	@name	nvarchar(50)
)
AS
SET NOCOUNT ON

INSERT INTO castle (id, name) VALUES (@id, @name)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_skill_reuse_delay]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_skill_reuse_delay](
	[char_id] [int] NOT NULL,
	[skill_id] [int] NOT NULL,
	[to_end_time] [int] NOT NULL,
	[subjob_id] [int] NOT NULL,
	[skill_delay] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_skill_reuse_delay]') AND name = N'IX_user_skill_reuse_delay_1')
CREATE CLUSTERED INDEX [IX_user_skill_reuse_delay_1] ON [dbo].[user_skill_reuse_delay] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[time_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[time_data](
	[account_id] [int] NOT NULL,
	[last_logout] [datetime] NOT NULL,
	[used_sec] [int] NOT NULL,
 CONSTRAINT [PK_char_data2] PRIMARY KEY CLUSTERED 
(
	[account_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveManorSeed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_SaveManorSeed
 save manor seed crop data
INPUT
	
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-06-21
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_SaveManorSeed]
(
@manor_id INT,
@data_index INT,
@seed_id BIGINT,
@seed_price BIGINT,
@seed_sell_count BIGINT,
@seed_remain_count BIGINT,
@crop_id BIGINT,
@crop_buy_count BIGINT,
@crop_remain_count BIGINT,
@crop_price BIGINT,
@crop_type BIGINT,
@crop_deposit BIGINT
)
AS        
        
SET NOCOUNT ON        
IF EXISTS(SELECT * FROM manor_data WHERE manor_id = @manor_id AND data_index =@data_index)
BEGIN
	UPDATE	
		manor_data
	SET 
		seed_id = @seed_id, 
		seed_price = @seed_price, 
		seed_sell_count = @seed_sell_count, 
		seed_remain_count = @seed_remain_count, 
		crop_id = @crop_id, 
		crop_buy_count = @crop_buy_count, 
		crop_price = @crop_price, 
		crop_type = @crop_type, 
		crop_remain_count = @crop_remain_count, 
		crop_deposit = @crop_deposit
	WHERE
		manor_id = @manor_id AND data_index = @data_index
END
ELSE
BEGIN
	INSERT INTO 
	manor_data 
	(manor_id, data_index, seed_id, seed_price, seed_sell_count, seed_remain_count, crop_id, crop_buy_count, crop_price, crop_type, crop_remain_count, crop_deposit) 
	VALUES 
	(@manor_id, @data_index, @seed_id, @seed_price, @seed_sell_count, @seed_remain_count, @crop_id, @crop_buy_count, @crop_price, @crop_type, @crop_remain_count, @crop_deposit)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAgitList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************************
#Name:	lin_GetAgitList
#Desc:	get agit list

#Argument:
	Input:
	Output:
#Return:
#Result Set:

#Remark:
#Example:
#See:
#History:
	Create	btwinuni	2005-09-20
	Modify	btwinuni	2005-11-16	auction_time
******************************************************************************/
CREATE PROCEDURE [dbo].[lin_GetAgitList]
AS

SET NOCOUNT ON

select a.id, a.name, a.pledge_id, isnull(p.name,''''), isnull(p.ruler_id,0), isnull(ud.char_name,''''), 
	isnull((select max(auction_time) from agit_auction(nolock) where agit_id = a.id), 0), 
	a.next_war_time
from agit as a(nolock)
	left join pledge as p(nolock) on a.pledge_id = p.pledge_id
	left join user_data as ud(nolock) on p.ruler_id = ud.char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMailList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMailList
	get mail list
INPUT
	@char_id		int,
	@mailbox_type			int,
	@page			int,
	@rows_per_page	int,
	@search_target		int,
	@keyword		nvarchar(20)
OUTPUT
return
made by
	kks
date
	2004-12-10
********************************************/
CREATE PROCEDURE [dbo].[lin_GetMailList]
(
	@char_id		int,
	@mailbox_type			int,
	@page			int,
	@rows_per_page	int,
	@search_target		int,
	@keyword		nvarchar(20)
)
AS
SET NOCOUNT ON

DECLARE @sql NVARCHAR(4000)
DECLARE @top int
DECLARE @total_count int
SET @total_count = 0

IF @page < 1
	SET @page = 1

SET @top = @page * @rows_per_page

IF @top < 1 
	RETURN

-- set search condition
DECLARE @search_condition NVARCHAR(1000)
SET @search_condition = N''''

-- incomming mailbox
if (@mailbox_type = 0)
begin
	IF (@keyword != N'''') 
	BEGIN
		IF (@search_target = 0)
			SET @search_condition = ''and r.mail_id IN (SELECT mail_id FROM user_mail_sender(nolock) WHERE sender_name = N'''''' + @keyword + '''''') ''
		IF (@search_target = 1)
			SET @search_condition = ''and m.title LIKE N''''%'' + @keyword + ''%'''' ''
	END

	SET @sql = 
	''DECLARE @total_count int '' +
	''SET @total_count = 0 '' +
	''SELECT @total_count = COUNT(*) '' + 
	''FROM user_mail m(nolock), user_mail_receiver r(nolock) '' +
	''WHERE m.id = r.mail_id '' +
	''	and r.receiver_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''	and r.deleted = 0 '' +
	''	and r.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +

	''SELECT TOP '' + CAST(@top as NVARCHAR) +  
	''	m.id, s.sender_id, s.sender_name, m.title, datediff( ss, ''''1970/1/1 0:0:0'''' , s.send_date ) s_date, '' +
	''	r.read_status, @total_count '' +
	''FROM user_mail m(nolock), user_mail_sender s(nolock), user_mail_receiver r(nolock) '' +
	''WHERE m.id = r.mail_id '' +
	''	and s.mail_id = r.mail_id '' +
	''	and r.receiver_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''	and r.deleted = 0 '' +
	''	and r.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +
	''ORDER BY s_date DESC''

	EXEC(@sql)
end

-- sent mailbox
if (@mailbox_type = 1)
begin
	IF (@keyword != N'''') 
	BEGIN
		IF (@search_target = 0)
			SET @search_condition = ''and s.mail_id IN (SELECT mail_id FROM user_mail_receiver(nolock) WHERE receiver_name = N'''''' + @keyword + '''''') ''
		IF (@search_target = 1)
			SET @search_condition = ''and m.title LIKE N''''%'' + @keyword + ''%'''' ''
	END

	SET @sql = 
	''DECLARE @total_count int '' +
	''SET @total_count = 0 '' +
	''SELECT @total_count = COUNT(*) '' + 
	''FROM user_mail m(nolock), user_mail_sender s(nolock) '' +
	''WHERE m.id = s.mail_id '' +
	''	and s.sender_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''	and s.deleted = 0 '' +
	''	and s.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +

	''SELECT TOP '' + CAST(@top as NVARCHAR) +  
	''	m.id, s.sender_id, s.receiver_name_list, m.title, datediff( ss, ''''1970/1/1 0:0:0'''' , s.send_date ) s_date, '' +
	''	s.mail_type, @total_count '' +
	''FROM user_mail m(nolock), user_mail_sender s(nolock) '' +
	''WHERE m.id = s.mail_id '' +
	''	and s.sender_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''	and s.deleted = 0 '' +
	''	and s.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +
	''ORDER BY s_date DESC''

	EXEC(@sql)
end

-- archive mailbox
if (@mailbox_type = 2)
begin
	-- 
	DECLARE @search_condition2 NVARCHAR(128)
	SET @search_condition2 = N''''

	IF (@keyword != N'''') 
	BEGIN
		IF (@search_target = 0)
		BEGIN
			SET @search_condition = ''and r.mail_id IN (SELECT mail_id FROM user_mail_sender(nolock) WHERE sender_name = N'''''' + @keyword + '''''') ''
			SET @search_condition2 = ''and s.mail_id IN (SELECT mail_id FROM user_mail_receiver(nolock) WHERE receiver_name = N'''''' + @keyword + '''''') ''
		END

		IF (@search_target = 1)
		BEGIN
			SET @search_condition = ''and m.title LIKE N''''%'' + @keyword + ''%'''' ''
			SET @search_condition2 = ''and m.title LIKE N''''%'' + @keyword + ''%'''' ''
		END
	END

	SET @sql = 
	''DECLARE @total_count int '' +
	''SET @total_count = 0 '' +
	''SELECT @total_count = '' + 
	''	(SELECT COUNT(*) cnt1'' +
	''	FROM user_mail m(nolock), user_mail_receiver r(nolock) '' +
	''	WHERE m.id = r.mail_id '' +
	''		and r.receiver_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''		and r.deleted = 0 '' +
	''		and r.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +
	''	) + '' +
	''	(SELECT COUNT(*) cnt2'' +
	''	FROM user_mail m(nolock), user_mail_sender s(nolock) '' +
	''	WHERE m.id = s.mail_id '' +
	''		and s.sender_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''		and s.deleted = 0 '' +
	''		and s.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition2 +
	''	) '' +
	'' '' +
	''SELECT TOP '' + CAST(@top as NVARCHAR) + '' *, @total_count '' +
	''FROM ( '' +
	''	SELECT '' +
	''		m.id, s.sender_id, s.sender_name, m.title, datediff( ss, ''''1970/1/1 0:0:0'''' , s.send_date ) s_date, '' +
	''		r.read_status type_flag '' +
	''	FROM user_mail m(nolock), user_mail_sender s(nolock), user_mail_receiver r(nolock) '' +
	''	WHERE m.id = r.mail_id '' +
	''		and s.mail_id = r.mail_id '' +
	''		and r.receiver_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''		and r.deleted = 0 '' +
	''		and r.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +
	''	union all '' +
	''	SELECT '' +
	''		m.id, s.sender_id, s.receiver_name_list, m.title, datediff( ss, ''''1970/1/1 0:0:0'''' , s.send_date ) s_date, '' +
	''		s.mail_type type_flag '' +
	''	FROM user_mail m(nolock), user_mail_sender s(nolock) '' +
	''	WHERE m.id = s.mail_id '' +
	''		and s.sender_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''		and s.deleted = 0 '' +
	''		and s.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition2 +
	'') as R1 '' +
	''	ORDER BY s_date DESC''
		
	EXEC(@sql)

end

-- temp mailbox
if (@mailbox_type = 3)
begin
	IF (@keyword != N'''') 
	BEGIN
		IF (@search_target = 0)
			SET @search_condition = ''and s.receiver_name_list LIKE  N''''%'' + @keyword + ''%'''' ''
		IF (@search_target = 1)
			SET @search_condition = ''and m.title LIKE N''''%'' + @keyword + ''%'''' ''
	END

	SET @sql = 
	''DECLARE @total_count int '' +
	''SET @total_count = 0 '' +
	''SELECT @total_count = COUNT(*) '' + 
	''FROM user_mail m(nolock), user_mail_sender s(nolock) '' +
	''WHERE m.id = s.mail_id '' +
	''	and s.sender_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''	and s.deleted = 0 '' +
	''	and s.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +
	
	''SELECT TOP '' + CAST(@top as NVARCHAR) +  
	''	m.id, s.sender_id, s.receiver_name_list, m.title, datediff( ss, ''''1970/1/1 0:0:0'''' , s.send_date ) s_date, '' +
	''	s.mail_type, @total_count '' +
	''FROM user_mail m(nolock), user_mail_sender s(nolock) '' +
	''WHERE m.id = s.mail_id '' +
	''	and s.sender_id = '' + CAST(@char_id as NVARCHAR) + '' '' +
	''	and s.deleted = 0 '' +
	''	and s.mailbox_type = '' + CAST(@mailbox_type as NVARCHAR) + '' '' +
	@search_condition +
	''ORDER BY s_date DESC''

	EXEC(@sql)

end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GraduatePledgeMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- lin_GraduatePledgeMember
-- by kernel0
-- created by kernel0 (2006-05-03)
-- refered lin_GraduatePledgeMember

CREATE PROCEDURE
[dbo].[lin_GraduatePledgeMember] (@pledge_id INT, @member_id INT, @pledge_type INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

UPDATE user_data
SET pledge_id = 0,
	pledge_type = 0,
	grade_id = 0,
        academy_pledge_id = @pledge_id
WHERE char_id = @member_id
AND pledge_id = @pledge_id
AND pledge_type = @pledge_type

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	-- 추가되는 코드는 여기에
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_item_period]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_item_period](
	[item_id] [int] NOT NULL,
	[start_time] [int] NOT NULL CONSTRAINT [DF_user_item_period_start_time]  DEFAULT ((0)),
	[period] [int] NOT NULL CONSTRAINT [DF_user_item_period_period]  DEFAULT ((0)),
	[item_type] [int] NOT NULL CONSTRAINT [DF_user_item_period_item_type]  DEFAULT ((0)),
 CONSTRAINT [PK_user_item_period] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSubPledgeSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE
[dbo].[lin_LoadSubPledgeSkill] (
	@pledge_id		int
)
AS

SELECT pledge_type, skill_id, skill_lev FROM subpledge_skill
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[event_items]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[event_items](
	[char_id] [int] NULL,
	[class_id] [int] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[log_date] [datetime] NULL CONSTRAINT [DF_event_items_log_date]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAgitAdena]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetAgitAdena
	get agit_adena log
INPUT
	

OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_GetAgitAdena]
(
@agit_id		INT,
@auction_id		INT,
@reason		INT
)
AS
SET NOCOUNT ON

if @reason = 1 
begin
	select top 1 isnull( adena , 0 ) , isnull( pledge_id , 0) from agit_adena (nolock) where agit_id = @agit_id and auction_id = @auction_id and reason = @reason
end else begin
	select isnull( adena , 0 ) , isnull( pledge_id , 0) from agit_adena (nolock) where agit_id = @agit_id and auction_id = @auction_id and reason = @reason
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBossRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadBossRecord
	Load Boss Record
INPUT  
	@char_id	int
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-02-27
********************************************/  
CREATE    PROCEDURE [dbo].[lin_LoadBossRecord]  
(
	@char_id	int
)
AS  
SET NOCOUNT ON  
  
select npc_class_id, point, accumulated_point  from user_bossrecord
where char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBBSBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetBBSBoard    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetBBSBoard
	Get BBS board Info
INPUT
	@board_id	int,
	@board_pagesize int
OUTPUT

return
made by
	young
date
	2002-10-21
********************************************/
CREATE PROCEDURE [dbo].[lin_GetBBSBoard]
(
	@board_id	int,
	@board_pagesize int
)
AS

set nocount on

declare @ncount int
declare @table_name nvarchar(20)
declare @exec nvarchar(200)

select @table_name = board_name from bbs_board (nolock) where board_id = @board_id

set @exec = ''select '''''' + @table_name + '''''' , (count(id) / '' + str(@board_pagesize) + '')+1 from '' + @table_name + '' (nolock)''
exec (@exec)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_updateSociality]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_updateSociality
 set sociality
INPUT        
 @char_id
 @sociality
 @sulffrage
 @last_changed
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_updateSociality]
(        
 @char_id INT,
 @sociality INT
)        
AS        
        
SET NOCOUNT ON        

UPDATE user_sociality 
SET sociality = @sociality 
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_writeBbsTGS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_writeBbsTGS    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_writeBbsTGS]
(
	@title NVARCHAR(50), 
	@contents NVARCHAR(4000), 
	@writer NVARCHAR(50)
)
AS


insert into bbs_tgs (title, contents, writer) values (@title, @contents, @writer)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fortress_siege_registry]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[fortress_siege_registry](
	[fortress_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[md_items]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[md_items](
	[item_type] [bigint] NOT NULL,
	[shop_price] [bigint] NULL,
	[real_price] [bigint] NULL,
	[item_name] [nvarchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSSQUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
 * @procedure lin_LoadSSQUserInfo
 * @brief  Load user''s ssq info from ssq_user_data
 *
 * @date  2004/11/18
 * @author sonai <sonai@ncsoft.net>
 *
 * @param[in]  char_id user_data''s id
 */
CREATE PROCEDURE [dbo].[lin_LoadSSQUserInfo] 
(
@char_id INT
)
AS
SET NOCOUNT ON

SELECT round_number, ssq_join_time, ssq_part, ssq_position, seal_selection_no, 
              ssq_point,
              twilight_a_item_num,twilight_b_item_num,twilight_c_item_num,
              dawn_a_item_num,dawn_b_item_num, dawn_c_item_num,
              ticket_buy_count       
             FROM ssq_user_data WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pet_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pet_data](
	[pet_id] [int] NOT NULL,
	[npc_class_id] [int] NOT NULL,
	[expoint] [bigint] NULL,
	[nick_name] [nvarchar](50) NULL,
	[hp] [float] NOT NULL CONSTRAINT [DF_pet_data_hp]  DEFAULT ((1)),
	[mp] [float] NOT NULL CONSTRAINT [DF_pet_data_mp]  DEFAULT ((0)),
	[sp] [int] NOT NULL CONSTRAINT [DF_pet_data_sp]  DEFAULT ((0)),
	[meal] [int] NOT NULL CONSTRAINT [DF_pet_data_meal]  DEFAULT ((1)),
	[slot1] [int] NOT NULL CONSTRAINT [DF_pet_data_slot1]  DEFAULT ((0)),
	[slot2] [int] NOT NULL CONSTRAINT [DF_pet_data_slot2]  DEFAULT ((0)),
	[slot3] [int] NOT NULL CONSTRAINT [DF__pet_data__slot3__46A09EA5]  DEFAULT ((0)),
 CONSTRAINT [PK_pet_data] PRIMARY KEY CLUSTERED 
(
	[pet_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateLottoGameState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UpdateLottoGameState]
(
	@round_number int,
	@state int,
	@left_time int
) 
AS       
SET NOCOUNT ON    

update lotto_game
set  	state = @state,
	left_time = @left_time
where round_number = @round_number

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetPledgeKillDeathCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetPledgeKillDeathCount]
(
@castle_id INT
)
AS
SET NOCOUNT ON

SELECT pledge_id, siege_kill, siege_death FROM pledge 
WHERE pledge_id IN 
(SELECT pledge_id FROM castle_war WHERE castle_id = @castle_id AND (type = 1 OR type = 2))

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPledgePowerGrade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetPledgePowerGrade
	set pledge power grade
INPUT
	grade_id	int
	char_id		int,
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_SetPledgePowerGrade] (
	@grade_id	int,
	@char_id		int
)
AS

UPDATE user_data
SET grade_id = @grade_id
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_item_cnt]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_item_cnt](
	[id] [int] NOT NULL,
	[count] [int] NOT NULL,
	[sum] [float] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDBSavingMap]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadDBSavingMap]
(        
@map_key INT
)        
AS    
SET NOCOUNT ON        
SELECT map_value FROM dbsaving_map WHERE map_key = @map_key

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RestoreChar ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetCharAccountId
	update account_id character
INPUT
	@account_id	int,
	@char_id	int
OUTPUT

return
made by
	young
date
	2003-09-02
	update account_id from character
********************************************/
CREATE PROCEDURE [dbo].[lin_RestoreChar ]
(
	@account_id	int,
	@char_id	int,
	@account_name	nvarchar(50) = ''''
)
AS

SET NOCOUNT ON

declare @char_inx int
declare @old_char_name nvarchar(50)
declare @new_char_name nvarchar(50)

select @old_char_name = char_name from user_data (nolock) where char_id = @char_id
select @char_inx = CHARINDEX ( ''_'', @old_char_name )

if @char_inx > 0 
begin
	select @new_char_name = SUBSTRING( @old_char_name, 1, @char_inx - 1)
end
else
begin
	select @new_char_name = @old_char_name
end

if ( len ( @account_name ) > 0 ) 
begin
	update user_data set account_id = @account_id , char_name = @new_char_name, account_name = @account_name , temp_delete_date = null  where char_id = @char_id
end else begin
	update user_data set account_id = @account_id , char_name = @new_char_name , temp_delete_date = null  where char_id = @char_id
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateMacroInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateMacroInfo
	create macroinfo
INPUT
	@macro_id		int,
	@macro_order		int,
	@macro_int1		int,
	@macro_int2		int,
	@macro_int3		int,
	@macro_str		nvarchar(255)

OUTPUT
return
made by
	young
date
	2004-6-11
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateMacroInfo]
(
@macro_id		int,
@macro_order		int,
@macro_int1		int,
@macro_int2		int,
@macro_int3		int,
@macro_str		nvarchar(255)
)
AS
SET NOCOUNT ON

if ( exists ( select * from user_macro where macro_id = @macro_id ) )
begin
	if ( exists ( select * from user_macroinfo where macro_id = @macro_id and macro_order = @macro_order ) )
	begin
		update user_macroinfo set macro_int1 = @macro_int1, macro_int2 = @macro_int2, macro_int3 = @macro_int3 where macro_id = @macro_id and macro_order = @macro_order

	end else begin
		insert into user_macroinfo ( macro_id, macro_order, macro_int1, macro_int2, macro_int3, macro_str )
		values ( @macro_id, @macro_order, @macro_int1, @macro_int2, @macro_int3, @macro_str )
	end

end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeSubJobBySubJobId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ChangeSubJobBySubJobId
	get temp mail 
INPUT
	@char_id		int,
	@subjob_id		int
OUTPUT
return
made by
	kks
date
	2005-04-06
	2005-09-07	modified by btwinuni
	2006-01-02	modified by btwinuni
********************************************/
CREATE PROCEDURE [dbo].[lin_ChangeSubJobBySubJobId]
(
	@char_id		int,
	@subjob_id		int
)
AS
SET NOCOUNT ON

IF EXISTS(SELECT TOP 1 char_id FROM user_data(NOLOCK) WHERE char_id = @char_id AND subjob_id = @subjob_id)
BEGIN
	RETURN
END

declare @origin_subjob int

select @origin_subjob = subjob_id from user_data (nolock) where char_id = @char_id

-- update subjob char property
UPDATE 	user_subjob 
SET hp = R.hp,
	mp = R.mp,
	sp = R.sp,
	exp = R.exp,
	level = R.lev
FROM ( SELECT hp, mp, sp, exp, lev, subjob_id FROM user_data(nolock) WHERE  char_id = @char_id ) AS R
WHERE user_subjob.char_id = @char_id
	AND user_subjob.subjob_id = R.subjob_id


-- update subjob char henna
UPDATE user_subjob
SET henna_1 = R.henna_1,
	henna_2 = R.henna_2,
	henna_3 = R.henna_3
FROM ( SELECT henna_1, henna_2, henna_3 FROM user_henna(nolock) WHERE char_id = @char_id ) AS R
WHERE user_subjob.char_id = @char_id
	AND user_subjob.subjob_id = @origin_subjob


-- update user data property
UPDATE 	user_data
SET hp = R.hp,
	mp = R.mp,
	sp = R.sp,
	exp = R.exp,
	lev = R.level,
	subjob_id = @subjob_id
FROM ( SELECT hp, mp, sp, exp, level FROM user_subjob(nolock) WHERE char_id = @char_id AND subjob_id = @subjob_id ) AS R
WHERE user_data.char_id = @char_id

declare @sql varchar(1000)
set @sql = ''update user_data ''
	+ '' set class = subjob'' + cast(@subjob_id as varchar) + ''_class ''
	+ '' where char_id = '' + cast(@char_id as varchar)
exec (@sql)


-- update char henna
UPDATE user_henna
SET henna_1 = R.henna_1,
	henna_2 = R.henna_2,
	henna_3 = R.henna_3
FROM ( SELECT henna_1, henna_2, henna_3 FROM user_subjob(nolock) WHERE char_id = @char_id AND subjob_id = @subjob_id ) AS R
WHERE user_henna.char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateAgitAuction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateAgitAuction
	create agit auction
INPUT
	@agit_id	int,
	@auction_desc	nvarchar(200),
	@min_price	int

OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateAgitAuction]
(
@agit_id		INT,
@auction_desc		nvarchar(200),
@min_price		INT,
@auction_time		INT,
@auction_tax		INT
)
AS
SET NOCOUNT ON

declare @auction_id int

insert into agit_auction ( agit_id, auction_desc, min_price, auction_time , auction_tax)
values ( @agit_id, @auction_desc, @min_price, @auction_time  , @auction_tax )

select @auction_id = @@IDENTITY

update agit set auction_id = @auction_id where id = @agit_id

select @auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPreviousCastleOwnerID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetPreviousCastleOwnerID
	set castle owner
INPUT
	residence_id
	nPledge_id

OUTPUT
return
made by
	kernel0
date
	2006-07-10
********************************************/
CREATE PROCEDURE [dbo].[lin_SetPreviousCastleOwnerID]
(
	@residence_id	INT,
	@Pledge_id	INT
)
AS

SET NOCOUNT ON

UPDATE castle  SET prev_castle_owner_id = @Pledge_id WHERE id = @residence_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_premium_item_log](
	[account_id] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[item_dbid] [int] NOT NULL,
	[create_date] [datetime] NULL,
	[create_reason] [int] NULL,
	[delete_date] [datetime] NULL,
	[delete_reason] [int] NULL,
	[item_amount_before] [int] NOT NULL,
	[item_amount_after] [int] NOT NULL,
	[item_type] [int] NULL CONSTRAINT [DF_user_premium_item_log_item_type]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item_log]') AND name = N'IX_user_premium_item_log_account_id')
CREATE NONCLUSTERED INDEX [IX_user_premium_item_log_account_id] ON [dbo].[user_premium_item_log] 
(
	[account_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_premium_item_log]') AND name = N'IX_user_premium_item_log_char_id')
CREATE NONCLUSTERED INDEX [IX_user_premium_item_log_char_id] ON [dbo].[user_premium_item_log] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveManorSeed_N]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_SaveManorSeed_N
 save manor seed crop data next
INPUT
	
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_SaveManorSeed_N]
(
@manor_id INT,
@data_index INT,
@seed_id_n BIGINT,
@seed_price_n BIGINT,
@seed_sell_count_n BIGINT,
@crop_id_n BIGINT,
@crop_buy_count_n BIGINT,
@crop_price_n BIGINT,
@crop_type_n BIGINT
)
AS        
        
SET NOCOUNT ON        
IF EXISTS(SELECT * FROM manor_data_n WHERE manor_id = @manor_id AND data_index =@data_index)
BEGIN
	UPDATE	
		manor_data_n
	SET 
		seed_id_n = @seed_id_n, 
		seed_price_n = @seed_price_n, 
		seed_sell_count_n = @seed_sell_count_n, 
		crop_id_n = @crop_id_n, 
		crop_buy_count_n = @crop_buy_count_n, 
		crop_price_n = @crop_price_n, 
		crop_type_n = @crop_type_n
	WHERE
		manor_id = @manor_id AND data_index = @data_index
END
ELSE
BEGIN
	INSERT INTO 
	manor_data_n
	(manor_id, data_index, seed_id_n, seed_price_n, seed_sell_count_n, crop_id_n, crop_buy_count_n, crop_price_n, crop_type_n) 
	VALUES 
	(@manor_id, @data_index, @seed_id_n, @seed_price_n, @seed_sell_count_n, @crop_id_n, @crop_buy_count_n, @crop_price_n, @crop_type_n)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateBossRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_UpdateBossRecord  
	Update Boss Record
INPUT  
	@char_id	int,
	@npc_class_id	int, 
	@point		int,
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-02-23  
********************************************/  
CREATE   PROCEDURE [dbo].[lin_UpdateBossRecord]  
(
	@char_id	int,
	@npc_class_id	int, 
	@point		int
)
AS  
SET NOCOUNT ON  
  
select top 1 * from user_bossrecord
where char_id = @char_id and npc_class_id = @npc_class_id

IF(@@ROWCOUNT > 0)
	BEGIN
	
		BEGIN
			update user_bossrecord set point = point + @point, accumulated_point = accumulated_point+@point where char_id = @char_id and npc_class_id = @npc_class_id
		END
	END
ELSE
	BEGIN
	
		BEGIN
			insert into user_bossrecord values(@char_id, @npc_class_id, @point, @point)
		END
	END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monrace]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[monrace](
	[race_id] [int] IDENTITY(1,1) NOT NULL,
	[make_date] [datetime] NULL CONSTRAINT [DF_monrace_make_date]  DEFAULT (getdate()),
	[lane1] [smallint] NULL,
	[lane2] [smallint] NULL,
	[lane3] [smallint] NULL,
	[lane4] [smallint] NULL,
	[lane5] [smallint] NULL,
	[lane6] [smallint] NULL,
	[lane7] [smallint] NULL,
	[lane8] [smallint] NULL,
	[run1] [float] NULL,
	[run2] [float] NULL,
	[run3] [float] NULL,
	[run4] [float] NULL,
	[run5] [float] NULL,
	[run6] [float] NULL,
	[run7] [float] NULL,
	[run8] [float] NULL,
	[win1] [smallint] NULL CONSTRAINT [DF_monrace_win1]  DEFAULT ((0)),
	[win2] [smallint] NULL CONSTRAINT [DF_monrace_win2]  DEFAULT ((0)),
	[winrate1] [float] NULL CONSTRAINT [DF_monrace_winrate1]  DEFAULT ((0.0)),
	[winrate2] [float] NULL CONSTRAINT [DF_monrace_winrate2]  DEFAULT ((0.0)),
	[race_end] [smallint] NULL CONSTRAINT [DF_monrace_race_end]  DEFAULT ((0)),
	[tax_rate] [int] NULL CONSTRAINT [DF_monrace_tax_rate]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[monrace]') AND name = N'IX_monrace')
CREATE CLUSTERED INDEX [IX_monrace] ON [dbo].[monrace] 
(
	[race_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveSharedReuseDelayOfItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveSharedReuseDelayOfItem
	Save Shared Reuse Delay of Item
INPUT  
	@char_id		int
	@shared_delay_id	int
	@next_available_time	int
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-09-22
********************************************/  
CREATE      PROCEDURE [dbo].[lin_SaveSharedReuseDelayOfItem]  
(
	@char_id		int,
	@shared_delay_id 	int,
	@next_available_time	int
)
AS  
SET NOCOUNT ON  
  
delete shared_reuse_delays_of_items 
where char_id = @char_id and shared_delay_id = @shared_delay_id

insert into shared_reuse_delays_of_items values(@char_id, @shared_delay_id, @next_available_time)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateMarketPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpdateMarketPrice
	update item market price
INPUT
	@item_type INT,
	@price INT
OUTPUT
return
made by
	kks
date
	2005-04-01
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdateMarketPrice] 
(
@item_type INT,
@enchant INT,
@price BIGINT
)
AS
SET NOCOUNT ON
DECLARE @avg_price FLOAT
DECLARE @frequency INT
DECLARE @new_avg_price FLOAT
IF EXISTS(SELECT TOP 1 * FROM item_market_price(nolock) WHERE item_type = @item_type AND enchant = @enchant)
    BEGIN
	UPDATE item_market_price
	SET 
		avg_price = ((avg_price * frequency) + @price) / (frequency + 1),
		frequency = frequency + 1
	WHERE item_type = @item_type AND
		enchant = @enchant
   END
ELSE
   BEGIN
	INSERT INTO item_market_price 
		(item_type, enchant, avg_price, frequency)
	VALUES 
		(@item_type, @enchant, @price, 1)
   END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_StartPledgeWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_StartPledgeWar    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_StartPledgeWar
-- by bert

CREATE PROCEDURE
[dbo].[lin_StartPledgeWar] (@challenger_pledge_id INT, @challengee_pledge_id INT, @war_begin_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

DECLARE @challenger_name VARCHAR(50)
DECLARE @challengee_name VARCHAR(50)

SELECT @challenger_name = name FROM Pledge WHERE pledge_id = @challenger_pledge_id
SELECT @challengee_name = name FROM Pledge WHERE pledge_id = @challengee_pledge_id

INSERT INTO Pledge_War
(challenger, challengee, begin_time, challenger_name, challengee_name)
VALUES
(@challenger_pledge_id, @challengee_pledge_id, @war_begin_time, @challenger_name, @challengee_name)

SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetUserBan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetUserBan

INPUT
	@char_id	INT
	@ban_hour	smallint
OUTPUT
return
made by
	young
date
	2003-09-22
********************************************/
CREATE PROCEDURE [dbo].[lin_SetUserBan]
(
	@char_id	INT,
	@status		INT,
	@ban_hour	smallint,
	@ban_end	INT
)
AS
SET NOCOUNT ON

if @ban_hour = 0 
begin
	delete from user_ban where char_id = @char_id
end else begin

	if ( exists ( select * from user_ban (nolock) where char_id = @char_id ) )
	begin
		-- update
		update user_ban set status = @status, ban_date = getdate(), ban_hour = @ban_hour, ban_end = @ban_end where char_id = @char_id
	end else begin
		-- insert
		insert into user_ban ( char_id, status, ban_hour , ban_end ) values ( @char_id, @status, @ban_hour, @ban_end  )
	end
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_blocklist]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_blocklist](
	[char_id] [int] NOT NULL,
	[block_char_id] [int] NOT NULL,
	[block_char_name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_user_blocklist] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[block_char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_subjob]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_subjob](
	[char_id] [int] NULL,
	[hp] [float] NULL,
	[mp] [float] NULL,
	[sp] [int] NULL,
	[exp] [bigint] NULL,
	[level] [tinyint] NULL,
	[henna_1] [int] NULL,
	[henna_2] [int] NULL,
	[henna_3] [int] NULL,
	[subjob_id] [int] NULL,
	[create_date] [datetime] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_subjob]') AND name = N'IX_user_subjob_char_id')
CREATE NONCLUSTERED INDEX [IX_user_subjob_char_id] ON [dbo].[user_subjob] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DisableChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DisableChar    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DisableChar
	disable character
INPUT
	@char_name nvarchar(50)
OUTPUT

return
made by
	young
date
	2002-11-30
	disable character
********************************************/
CREATE PROCEDURE [dbo].[lin_DisableChar]
(
@char_name nvarchar(50)
)
AS

SET NOCOUNT ON

update user_data set account_id = -2 where char_name = @char_name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadFieldCycleInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadFieldCycleInfo]
(
@field_id INT
)
AS

IF @field_ID = -1
BEGIN
	SELECT field_id, point, step, step_changed_time, point_changed_time, accumulated_point
	FROM field_cycle(nolock)
END
ELSE BEGIN
	SELECT field_id, point, step, step_changed_time, point_changed_time, accumulated_point
	FROM field_cycle(nolock)
	WHERE field_id = @field_id
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteDBSavingMap]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteDBSavingMap]
(
	@map_key	INT
)
AS
SET NOCOUNT ON
DELETE FROM dbsaving_map WHERE map_key = @map_key

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ownthing]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ownthing](
	[original_dominion_id] [int] NOT NULL,
	[current_dominion_id] [int] NOT NULL,
	[pos_x] [int] NOT NULL,
	[pos_y] [int] NOT NULL,
	[pos_z] [int] NOT NULL
) ON [PRIMARY]
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'현재 영지 id' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ownthing', @level2type=N'COLUMN', @level2name=N'current_dominion_id'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'현재 x 좌표' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ownthing', @level2type=N'COLUMN', @level2name=N'pos_x'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'현재 y 좌표' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ownthing', @level2type=N'COLUMN', @level2name=N'pos_y'

GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteMacro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DeleteMacro
	delete  macro
INPUT

	@macro_id	int
OUTPUT
return
made by
	young
date
	2004-6-11
********************************************/
CREATE PROCEDURE [dbo].[lin_DeleteMacro]
(
@macro_id		int
)
AS
SET NOCOUNT ON

delete from user_macroinfo where macro_id = @macro_id
delete from user_macro where macro_id = @macro_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAllCastleSiege]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetAllCastleSiege    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetAllCastleSiege
	
INPUT	
	@pledge_id	int
OUTPUT
	id, 
	next_war_time, 
	type 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_GetAllCastleSiege]
(
	@pledge_id	int
)
AS
SET NOCOUNT ON

SELECT 
	c.id, 
	c.next_war_time, 
	cw.type 
FROM 
	castle c (nolock) , 
	castle_war cw (nolock)  
WHERE 
	c.id = cw.castle_id 
	AND c.next_war_time <> 0 
	AND cw.pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllAgit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAllAgit    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadAllAgit
	
INPUT
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_LoadAllAgit]
AS
SET NOCOUNT ON

SELECT id, pledge_id FROM castle  (nolock) WHERE type = 2 ORDER BY id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadItemExpiration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadItemExpiration  
 Load item Expiration  
INPUT  
 @user_id INT,  
   
OUTPUT  
 item_id, expiration_date  
return  
made by  
 zzangse  
date  
 2006-01-23  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadItemExpiration]  
(  
 @user_id INT  
)  
AS  
SET NOCOUNT ON  
  
  
SELECT item_id, expiration_date FROM item_expiration (nolock) WHERE user_id = @user_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InitializeBossRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_InitializeBossRecord
	Initialize Certain User''s Boss Record
INPUT  
	@user db id		int
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-04-11
********************************************/  
CREATE     PROCEDURE [dbo].[lin_InitializeBossRecord]  
(
	@user_db_id 		int
)
AS  
SET NOCOUNT ON  
  
	
update user_bossrecord
set point = 0
where char_id = @user_db_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[siege_agit_pledge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[siege_agit_pledge](
	[agit_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[propose_time] [int] NOT NULL,
	[status] [int] NULL CONSTRAINT [DF__siege_agi__statu__611D28B2]  DEFAULT ((0)),
 CONSTRAINT [sap_uniq] UNIQUE NONCLUSTERED 
(
	[agit_id] ASC,
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[shortcut_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[shortcut_data](
	[char_id] [int] NOT NULL,
	[slotnum] [int] NOT NULL,
	[shortcut_type] [int] NOT NULL,
	[shortcut_id] [int] NOT NULL,
	[shortcut_macro] [nvarchar](256) NOT NULL,
	[subjob_id] [int] NOT NULL CONSTRAINT [DF__shortcut___subjo__12899BBD]  DEFAULT ((0)),
 CONSTRAINT [PK_shortcut_data] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[slotnum] ASC,
	[subjob_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddedServiceList]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AddedServiceList](
	[idx] [int] NOT NULL,
	[postDate] [datetime] NOT NULL,
	[serviceType] [tinyint] NOT NULL,
	[fromUid] [int] NOT NULL,
	[toUid] [int] NULL,
	[fromAccount] [nvarchar](24) NULL,
	[toAccount] [nvarchar](24) NULL,
	[fromServer] [tinyint] NOT NULL,
	[toServer] [tinyint] NULL,
	[fromCharacter] [nvarchar](24) NOT NULL,
	[toCharacter] [nvarchar](24) NULL,
	[changeGender] [bit] NULL,
	[serviceFlag] [smallint] NOT NULL,
	[applyDate] [datetime] NULL CONSTRAINT [DF_AddedServiceList_applyDate]  DEFAULT (getdate()),
	[reserve1] [varchar](200) NULL,
	[reserve2] [varchar](100) NULL,
	[toMainClassNum] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadManorSeed_N]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_LoadManorSeed_N
 load manor seed next
INPUT        
 @manor_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_LoadManorSeed_N]
(        
 @manor_id INT
)        
AS        
        
SET NOCOUNT ON        

SELECT 
	data_index, seed_id_n, seed_price_n, seed_sell_count_n,
	crop_id_n, crop_buy_count_n, crop_price_n, crop_type_n
FROM 
	manor_data_n
WHERE 
	manor_id = @manor_id
ORDER BY 
	data_index

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDominionSiege]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadDominionSiege]  
AS  
SET NOCOUNT ON  
  
SELECT	siege_state, prev_siege_end_time, siege_elapsed_time, next_siege_start_time
FROM	dominion_siege(nolock)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pledge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Pledge](
	[pledge_id] [int] IDENTITY(1,1) NOT NULL,
	[ruler_id] [int] NOT NULL,
	[name] [nvarchar](24) NOT NULL,
	[alliance_id] [int] NOT NULL CONSTRAINT [DF_Pledge_alliance_id]  DEFAULT ((0)),
	[challenge_time] [int] NOT NULL CONSTRAINT [DF_Pledge_challenge_time]  DEFAULT ((0)),
	[root_name_value] [int] NOT NULL CONSTRAINT [DF_Pledge_name_value]  DEFAULT ((0)),
	[now_war_id] [int] NOT NULL CONSTRAINT [DF_Pledge_now_war_id]  DEFAULT ((0)),
	[oust_time] [int] NOT NULL CONSTRAINT [DF_Pledge_oust_time]  DEFAULT ((0)),
	[skill_level] [smallint] NOT NULL CONSTRAINT [DF_Pledge_skill_level]  DEFAULT ((0)),
	[castle_id] [int] NOT NULL CONSTRAINT [DF_Pledge_castle_id]  DEFAULT ((0)),
	[agit_id] [int] NOT NULL CONSTRAINT [DF_Pledge_agit_id]  DEFAULT ((0)),
	[rank] [int] NOT NULL CONSTRAINT [DF_Pledge_rank]  DEFAULT ((0)),
	[name_value] [int] NOT NULL CONSTRAINT [DF_Pledge_name_value_1]  DEFAULT ((0)),
	[status] [int] NOT NULL CONSTRAINT [DF_Pledge_status]  DEFAULT ((0)),
	[private_flag] [int] NOT NULL CONSTRAINT [DF_Pledge_private_flag]  DEFAULT ((0)),
	[crest_id] [int] NOT NULL CONSTRAINT [DF_Pledge_crest_id]  DEFAULT ((0)),
	[is_guilty] [int] NOT NULL CONSTRAINT [DF_Pledge_is_guilty]  DEFAULT ((0)),
	[dismiss_reserved_time] [int] NOT NULL CONSTRAINT [DF_Pledge_dismiss_reserved_time]  DEFAULT ((0)),
	[alliance_withdraw_time] [int] NOT NULL CONSTRAINT [DF__pledge__alliance__29820FAE]  DEFAULT ((0)),
	[alliance_dismiss_time] [int] NOT NULL CONSTRAINT [DF__pledge__alliance__2A7633E7]  DEFAULT ((0)),
	[alliance_ousted_time] [int] NOT NULL CONSTRAINT [DF__pledge__alliance__288DEB75]  DEFAULT ((0)),
	[siege_kill] [int] NOT NULL CONSTRAINT [DF__Pledge__siege_ki__3F672F2C]  DEFAULT ((0)),
	[siege_death] [int] NOT NULL CONSTRAINT [DF__Pledge__siege_de__405B5365]  DEFAULT ((0)),
	[emblem_id] [int] NOT NULL CONSTRAINT [DF__Pledge__emblem_i__414F779E]  DEFAULT ((0)),
	[fortress_id] [int] NOT NULL CONSTRAINT [DF_Pledge_fortress_id]  DEFAULT ((0)),
	[castle_siege_defence_count] [int] NULL CONSTRAINT [DF_Pledge_castle_siege_defence_count]  DEFAULT ((0)),
 CONSTRAINT [PK_Pledge] PRIMARY KEY CLUSTERED 
(
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Pledge] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteSiegeAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteSiegeAgitPledge]
(
@agit_id INT
)
AS
SET NOCOUNT ON
DELETE FROM siege_agit_pledge WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllWarData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAllWarData    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadAllWarData
	
INPUT	
	@status	int
OUTPUT
	id, 
	begin_time, 
	challenger, 
	challengee 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_LoadAllWarData]
(
	@status	int
)
AS
SET NOCOUNT ON

SELECT 
	id, begin_time, challenger, challengee 
FROM 
	pledge_war (nolock)  
WHERE 
	status = @status

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_skill]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_skill](
	[char_id] [int] NOT NULL,
	[skill_id] [int] NOT NULL,
	[skill_lev] [smallint] NULL CONSTRAINT [DF_user_skill_skill_lev]  DEFAULT ((0)),
	[to_end_time] [int] NOT NULL CONSTRAINT [DF_user_skill_last_use]  DEFAULT ((0)),
	[subjob_id] [int] NOT NULL CONSTRAINT [DF__user_skil__subjo__10A1534B]  DEFAULT ((0)),
	[is_lock] [tinyint] NOT NULL CONSTRAINT [DF__user_skil__is_lo__19A178F7]  DEFAULT ((0)),
	[skill_delay] [int] NOT NULL CONSTRAINT [DF__user_skil__skill__51FBAC0A]  DEFAULT ((0)),
 CONSTRAINT [PK_user_skill] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[skill_id] ASC,
	[subjob_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_skill]') AND name = N'idx_skill_lev')
CREATE NONCLUSTERED INDEX [idx_skill_lev] ON [dbo].[user_skill] 
(
	[skill_lev] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_skill]') AND name = N'idx_skill_toend')
CREATE NONCLUSTERED INDEX [idx_skill_toend] ON [dbo].[user_skill] 
(
	[to_end_time] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDBSavingMap]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveDBSavingMap]
(        
@map_key	INT,
@map_value	INT
)        
AS  
SET NOCOUNT ON        
IF EXISTS(SELECT * FROM dbsaving_map WHERE map_key = @map_key)
BEGIN
	UPDATE dbsaving_map SET map_value = @map_value 
	WHERE map_key = @map_key
END
ELSE
BEGIN
	INSERT INTO dbsaving_map (map_key, map_value)
	VALUES (@map_key, @map_value)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeCrest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadPledgeCrest    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadPledgeCrest
	
INPUT
	@crest_id	int
OUTPUT
	bitmap_size, 
	bitmap 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_LoadPledgeCrest]
(
	@crest_id	int
)
AS
SET NOCOUNT ON

SELECT 
	bitmap_size, bitmap 
FROM 
	pledge_crest  (nolock) 
WHERE 
	crest_id = @crest_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateMacro]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateMacro
	create macro
INPUT
	@char_id		int,
	@macro_name		nvarchar(64),
	@macro_tooltip		nvarchar(64)
	@macro_iconname	nvarchar(64)
	@macro_icontype		int

OUTPUT
return
made by
	young
date
	2004-6-11
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateMacro]
(
@char_id		int,
@macro_name		nvarchar(64),
@macro_tooltip		nvarchar(64),
@macro_iconname	nvarchar(64),
@macro_icontype	int
)
AS
SET NOCOUNT ON

insert into user_macro ( char_id, macro_name, macro_tooltip, macro_iconname, macro_icontype)
values
( @char_id, @macro_name, @macro_tooltip, @macro_iconname, @macro_icontype)

select @@IDENTITY

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadManorSeed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_LoadManorSeed
 load manor seed
INPUT        
 @manor_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_LoadManorSeed]
(        
 @manor_id INT
)        
AS        
        
SET NOCOUNT ON        

SELECT 
	data_index, seed_id, seed_price, seed_sell_count, seed_remain_count, 
	crop_id, crop_price, crop_buy_count, crop_remain_count, crop_type, crop_deposit
FROM 
	manor_data
WHERE 
	manor_id = @manor_id
ORDER BY data_index

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_mail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_mail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetime] NOT NULL CONSTRAINT [DF_user_mail_mail_type]  DEFAULT (getdate()),
	[title] [nvarchar](200) NOT NULL,
	[content] [nvarchar](3500) NOT NULL,
 CONSTRAINT [PK_user_mail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_mail]') AND name = N'IX_user_mail_1')
CREATE NONCLUSTERED INDEX [IX_user_mail_1] ON [dbo].[user_mail] 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bookmark]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[bookmark](
	[char_id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[world] [int] NULL,
	[x] [int] NULL,
	[y] [int] NULL,
	[z] [int] NULL,
	[bookmarkid] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bookmark]') AND name = N'ix_bookmark')
CREATE NONCLUSTERED INDEX [ix_bookmark] ON [dbo].[bookmark] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_birthday_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_birthday_history](
	[char_id] [int] NOT NULL,
	[get_date] [datetime] NULL,
	[gift_index] [int] NULL,
	[event_id] [int] NULL
) ON [PRIMARY]
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'마지막 생성일 기념 선물 받은 날짜' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_birthday_history', @level2type=N'COLUMN', @level2name=N'get_date'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'선물 받은 횟수' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_birthday_history', @level2type=N'COLUMN', @level2name=N'gift_index'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'이벤트 종류 0:생성일 기념 이벤트 1:5주년 이벤트' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_birthday_history', @level2type=N'COLUMN', @level2name=N'event_id'

GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModChar3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModChar3
	
INPUT
	@sp	int,
	@exp	bigint,
	@level	int,
	@align	int,
	@pk	int,
	@pkpardon	int,
	@duel	int,
	@char_id	int
OUTPUT
return
made by
	young
date
	2003-08-26
	2006-01-25	btwinuni	exp: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_ModChar3]
(
	@sp		int,
	@exp		bigint,
	@level		int,
	@align		int,
	@pk		int,
	@pkpardon	int,
	@duel		int,
	@char_id	int
)
AS
SET NOCOUNT ON

update user_data set 
	sp = sp + @sp,
	exp = exp + @exp,	
	align = align + @align,
	pk = pk + @pk,
	pkpardon = pkpardon + @pkpardon,
	duel = duel + @duel,
	lev = @level 
where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateControlTower]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UpdateControlTower]
(
@control_level INT,
@hp INT,
@status INT,
@name VARCHAR(256)
)
AS
UPDATE control_tower
SET
control_level = @control_level,
hp = @hp,
status = @status
WHERE name = @name
IF @@ROWCOUNT <> 1
BEGIN
RAISERROR (''Failed to Update Control Tower name = %s.'', 16, 1, @name)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetSociality]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_ResetSociality
 set sociality
INPUT        
 @char_id
 @sociality
 @sulffrage
 @last_changed
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_ResetSociality]
(        
 @char_id INT,
 @sociality INT,
 @sulffrage INT,
 @last_changed DATETIME
)        
AS        
        
SET NOCOUNT ON        

IF EXISTS(SELECT  * FROM user_sociality WHERE char_id = @char_id)
BEGIN
	UPDATE user_sociality 
	SET sociality = @sociality , used_sulffrage = @sulffrage , last_changed = @last_changed
	WHERE char_id = @char_id
END
ELSE
BEGIN
	INSERT INTO user_sociality (char_id, sociality , used_sulffrage , last_changed ) VALUES (@char_id, @sociality , @sulffrage , @last_changed)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteSubPledgeSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DeleteSubPledgeSkill
	delete subpledge skill 
INPUT
	@pledge_id			int
	@pledge_type	int
	@skill_id				int
OUTPUT

return

date
	2006-04-24	btwinuni
********************************************/
CREATE PROCEDURE
[dbo].[lin_DeleteSubPledgeSkill] (
	@pledge_id			int,
	@pledge_type			int,
	@skill_id				int
)
AS

SET NOCOUNT ON

DELETE FROM subpledge_skill
WHERE pledge_id = @pledge_id AND pledge_type = @pledge_type AND skill_id = @skill_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agit_adena]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[agit_adena](
	[agit_id] [int] NULL,
	[pledge_id] [int] NULL,
	[auction_id] [int] NULL,
	[reason] [int] NULL,
	[adena] [bigint] NULL,
	[log_id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agit_adena]') AND name = N'IX_agit_adena')
CREATE NONCLUSTERED INDEX [IX_agit_adena] ON [dbo].[agit_adena] 
(
	[pledge_id] ASC,
	[auction_id] ASC,
	[reason] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UnregisterSiegeAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UnregisterSiegeAgitPledge]
(
	@agit_id INT,
	@pledge_id INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT

DELETE FROM siege_agit_pledge
WHERE 
agit_id = @agit_id AND pledge_id = @pledge_id

IF @@ERROR = 0
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pledge_namevalue_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pledge_namevalue_log](
	[pledge_id] [int] NOT NULL,
	[log_id] [tinyint] NOT NULL,
	[log_time] [datetime] NOT NULL CONSTRAINT [DF__pledge_na__log_t__059A804A]  DEFAULT (getdate()),
	[log_from] [int] NOT NULL,
	[log_to] [int] NOT NULL,
	[delta] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pledge_namevalue_log]') AND name = N'pledge_namevalue_log_IX')
CREATE NONCLUSTERED INDEX [pledge_namevalue_log_IX] ON [dbo].[pledge_namevalue_log] 
(
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetPunish]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetPunish    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetPunish
	Get punish
INPUT
	@char_id	INT
OUTPUT
return
made by
	young
date
	2002-11-27
********************************************/
CREATE PROCEDURE [dbo].[lin_GetPunish]
(
	@char_id	INT
)

as

set nocount on

select punish_id, punish_on, remain_game, remain_real from user_punish (nolock) where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCastleStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SaveCastleStatus    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SaveCastleStatus
	
INPUT	
	@status		int,
	@castle_id	int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SaveCastleStatus]
(
	@status		int,
	@castle_id	int
)
AS
SET NOCOUNT ON

UPDATE castle SET status = @status WHERE id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDominionSiege]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveDominionSiege] 
(
	@siege_state int,
	@prev_siege_end_time int,
	@siege_elapsed_time int,
	@next_siege_start_time int
)
AS

SET NOCOUNT ON

UPDATE dominion_siege SET siege_state = @siege_state, prev_siege_end_time = @prev_siege_end_time, siege_elapsed_time = @siege_elapsed_time, next_siege_start_time = @next_siege_start_time

IF @@rowcount = 0
BEGIN
	INSERT INTO dominion_siege (siege_state, prev_siege_end_time, siege_elapsed_time, next_siege_start_time) 
	VALUES (@siege_state, @prev_siege_end_time, @siege_elapsed_time, @next_siege_start_time) 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[olympiad_match]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[olympiad_match](
	[season] [int] NULL,
	[class] [int] NULL,
	[match_time] [int] NULL,
	[char_id] [int] NULL,
	[rival_id] [int] NULL,
	[point] [int] NULL,
	[is_winner] [tinyint] NULL,
	[elapsed_time] [int] NOT NULL CONSTRAINT [DF_olympiad_match_elapsed_time]  DEFAULT ((0)),
	[game_rule] [int] NOT NULL CONSTRAINT [DF_olympiad_match_game_rule]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[duel_record]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[duel_record](
	[user_id] [int] NOT NULL,
	[individual_win] [int] NOT NULL,
	[individual_lose] [int] NOT NULL,
	[individual_draw] [int] NOT NULL,
	[party_win] [int] NOT NULL,
	[party_lose] [int] NOT NULL,
	[party_draw] [int] NOT NULL,
 CONSTRAINT [PK__duel_record__53E3F47C] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateDoorDataIfNotExist]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreateDoorDataIfNotExist]  
(  
 @name  NVARCHAR(50),  
 @default_hp INT  
)  
AS  
SET NOCOUNT ON  
INSERT INTO door (name, hp, max_hp) VALUES (@name, @default_hp, @default_hp)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[shared_reuse_delays_of_items]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[shared_reuse_delays_of_items](
	[char_id] [int] NOT NULL,
	[shared_delay_id] [int] NOT NULL,
	[next_available_time] [int] NOT NULL,
 CONSTRAINT [PK_shared_item_reuse_delay] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[shared_delay_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSSQMainEventRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMainEventRecord
	get ssq main event record
INPUT

OUTPUT

return
made by
	kks
date
	2005-02-23
********************************************/
CREATE PROCEDURE [dbo].[lin_GetSSQMainEventRecord]

AS

SET NOCOUNT ON

select ssq_round, room_no, record_type, point, record_time, elapsed_time, member_count, member_names, datediff(s, ''1970-01-01'', getutcdate())
from time_attack_record
where record_type > 0
and ssq_round = (select max(round_number) max_ssq_round from ssq_data)
order by record_type asc, room_no desc

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CommentSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CommentSearch    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_CommentSearch
	
INPUT	
	@char_id		int,
	@page			int
OUTPUT
return
made by
	young
date
	2003-09-02
********************************************/
CREATE PROCEDURE [dbo].[lin_CommentSearch]
(
	@char_id		int,
	@page			int
)
AS
SET NOCOUNT ON


select comment_id, char_name, char_id, comment, writer from user_comment (nolock) 
where char_id = @char_id and deleted = 0
order by comment_id desc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetCharacterDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetCharacterDelete    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_SetCharacterDelete
	Set character is deleted
INPUT
	@char_id	INT
OUTPUT
	year
	month
	day
return
made by
	carrot
date
	2003-01-7
********************************************/
CREATE  PROCEDURE [dbo].[lin_SetCharacterDelete]
(
	@char_id	INT
)
AS

SET NOCOUNT ON

DECLARE @deletedDate	SMALLDATETIME

SET @deletedDate = GetDate()

UPDATE user_data SET temp_delete_date = @deletedDate WHERE char_id = @char_id

IF @@ROWCOUNT > 0 
BEGIN
	SELECT	YEAR(@deletedDate), MONTH(@deletedDate), DAY(@deletedDate),
		DATEPART(HOUR, @deletedDate), DATEPART(mi, @deletedDate), DATEPART(s, @deletedDate)
END
ELSE
BEGIN
	SELECT 0,0,0,0,0,0
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMacroCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMacroCount
	get macro coubt
INPUT
	@char_id		int,
OUTPUT
return
made by
	young
date
	2004-6-14
********************************************/
CREATE PROCEDURE [dbo].[lin_GetMacroCount]
(
@char_id		int
)
AS
SET NOCOUNT ON

select count(*) from user_macro where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FlushItemName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_FlushItemName    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_FlushItemName
	Delete item name data
INPUT
OUTPUT
return
made by
	carrot
date
	2002-10-8
********************************************/
CREATE PROCEDURE [dbo].[lin_FlushItemName]
AS
SET NOCOUNT ON

TRUNCATE TABLE ItemData

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WithdrawPledgeMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_WithdrawPledgeMember    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_WithdrawPledgeMember
-- by bert
-- modified by kks (2006-03-07)

CREATE PROCEDURE
[dbo].[lin_WithdrawPledgeMember] (@pledge_id INT, @member_id INT, @pledge_type INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

UPDATE user_data
SET pledge_id = 0,
	pledge_type = 0,
	grade_id = 0
WHERE char_id = @member_id
AND pledge_id = @pledge_id
AND pledge_type = @pledge_type

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	-- 추가되는 코드는 여기에
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadMarketPriceList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadMarketPriceList
	load item market price list
INPUT

OUTPUT
return
made by
	kks
date
	2005-04-01
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadMarketPriceList] 
AS

SET NOCOUNT ON

SELECT item_type, enchant, avg_price FROM item_market_price (nolock)
WHERE frequency >= 10

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteSkillList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteSkillList]
(
@char_id INT,
@skill_list NVARCHAR(2048)
)
AS
SET NOCOUNT ON

declare @sql nvarchar(1024)
set @sql = N''delete from user_skill where char_id = ''+cast(@char_id as nvarchar)+'' and skill_id in (''+@skill_list+'')''
exec (@sql)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModifyPledgeName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ModifyPledgeName    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_ModifyPledgeName
	
INPUT
	@crest_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_ModifyPledgeName]
(
	@pledge_name		NVARCHAR(50),
	@pledge_id		int
)
AS
SET NOCOUNT ON

update pledge set name = @pledge_name where pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoControlTower]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_InsertIntoControlTower]
(
@name VARCHAR(256),
@residence_id INT,
@control_level INT,
@hp INT,
@status INT
)
AS
INSERT INTO control_tower
(name, residence_id, control_level, hp, status)
VALUES
(@name, @residence_id, @control_level, @hp, @status)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelPledgeCrest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DelPledgeCrest    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DelPledgeCrest
	
INPUT
	@crest_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_DelPledgeCrest]
(
	@crest_id		int
)
AS
SET NOCOUNT ON

delete from pledge_crest where crest_id = @crest_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fortress_facility]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[fortress_facility](
	[fortress_id] [int] NOT NULL CONSTRAINT [DF_fortress_facility_fortress_id]  DEFAULT ((0)),
	[facility_type] [int] NOT NULL CONSTRAINT [DF_fortress_facility_facility_type]  DEFAULT ((0)),
	[facility_level] [int] NOT NULL CONSTRAINT [DF_fortress_facility_facility_level]  DEFAULT ((0)),
 CONSTRAINT [PK_fortress_facility] PRIMARY KEY CLUSTERED 
(
	[fortress_id] ASC,
	[facility_type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFieldCycleInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveFieldCycleInfo]
(
@field_id INT,
@point INT,
@step INT,
@step_changed_time INT,
@point_changed_time INT,
@accumulated_point INT
)
AS
SET NOCOUNT ON


UPDATE field_cycle 
SET point = @point, step = @step, step_changed_time = @step_changed_time, point_changed_time = @point_changed_time, accumulated_point = @accumulated_point
WHERE field_id = @field_id

if @@rowcount = 0
BEGIN	
	INSERT INTO field_cycle	
	(field_id, point, step, step_changed_time, point_changed_time, accumulated_point)
	VALUES			
	(@field_id, @point, @step, @step_changed_time, @point_changed_time, @accumulated_point)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBbsallList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetBbsallList    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_GetBbsallList] 
(
	@nPage	INT,
	@nLinesPerPage	INT
)
AS

SET NOCOUNT ON

If @nPage IS NULL or @nPage < 1 
BEGIN
	SET @nPage = 1
END

If @nLinesPerPage IS NULL or @nLinesPerPage < 1 
BEGIN
	SET @nLinesPerPage = 1
END

select 
	orderedTitle.id, orderedTitle.title, cast(datepart(month, orderedtitle.cdate) as varchar) +''/'' +  cast(datepart(day, orderedtitle.cdate) as varchar) + '' '' + cast(datepart(hour, orderedtitle.cdate) as varchar) + '':'' + cast(datepart(minute, orderedtitle.cdate) as varchar)
from 
	(Select 
		count(bbs2.id) as cnt, bbs1.id, bbs1.title, bbs1.cdate
	from 
		Bbs_all as bbs1
		inner join
		Bbs_all as bbs2
		on bbs1.id <= bbs2.id
	group by 
		bbs1.id, bbs1.title, bbs1.cdate
	) as orderedTitle
where 
	orderedTitle.cnt > (@nPage - 1) * @nLinesPerPage and orderedTitle.cnt <= @nPage * @nLinesPerPage
ORDER BY 
	orderedTitle.cnt ASC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPledgeSkill
	load pledge skill
INPUT
	@pledge_id		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/
CREATE PROCEDURE
[dbo].[lin_LoadPledgeSkill] (
	@pledge_id		int
)
AS

SELECT skill_id, skill_lev FROM pledge_skill
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[castle_crop]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[castle_crop](
	[castle_id] [int] NOT NULL,
	[item_type] [int] NOT NULL,
	[dropRate] [int] NOT NULL,
	[price] [bigint] NOT NULL,
	[level] [int] NOT NULL,
 CONSTRAINT [PK_castle_crop] PRIMARY KEY CLUSTERED 
(
	[castle_id] ASC,
	[item_type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateJournal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'--	kuooo
CREATE PROCEDURE
[dbo].[lin_UpdateJournal] ( @id INT,  
@j1 int, @j2 int, @j3 int, @j4 int, @j5 int, @j6 int, @j7 int, @j8 int,
@j9 int, @j10 int, @j11 int, @j12 int, @j13 int, @j14 int, @j15 int, @j16 int)
AS
UPDATE Quest
set 
j1 = @j1,
j2 = @j2,
j3 = @j3,
j4 = @j4,
j5 = @j5,
j6 = @j6,
j7 = @j7,
j8 = @j8,
j9 = @j9,
j10 = @j10,
j11 = @j11,
j12 = @j12,
j13 = @j13,
j14 = @j14,
j15 = @j15,
j16 = @j16
where char_id = @id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[castle]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[castle](
	[id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[pledge_id] [int] NOT NULL CONSTRAINT [DF__castle__pledge_i__1352D76D]  DEFAULT ((0)),
	[next_war_time] [int] NOT NULL CONSTRAINT [DF__castle__next_war__1446FBA6]  DEFAULT ((0)),
	[tax_rate] [smallint] NOT NULL CONSTRAINT [DF__castle__tax_rate__153B1FDF]  DEFAULT ((0)),
	[type] [tinyint] NOT NULL CONSTRAINT [DF_castle_type]  DEFAULT ((1)),
	[status] [tinyint] NOT NULL CONSTRAINT [DF_castle_status]  DEFAULT ((0)),
	[crop_income] [bigint] NOT NULL CONSTRAINT [DF_castle_crop_income]  DEFAULT ((0)),
	[shop_income] [bigint] NOT NULL CONSTRAINT [DF_castle_shop_income]  DEFAULT ((0)),
	[siege_elapsed_time] [int] NOT NULL CONSTRAINT [DF__castle__siege_el__3FA65AF7]  DEFAULT ((0)),
	[tax_child_rate] [int] NOT NULL CONSTRAINT [DF_castle_tax_child_rate]  DEFAULT ((0)),
	[shop_income_temp] [bigint] NOT NULL CONSTRAINT [DF__castle__shop_inc]  DEFAULT ((0)),
	[tax_rate_to_change] [smallint] NOT NULL CONSTRAINT [DF__castle__tax_rate__30CE2BBB]  DEFAULT ((-1)),
	[tax_child_rate_to_change] [smallint] NOT NULL CONSTRAINT [DF__castle__tax_chil__31C24FF4]  DEFAULT ((-1)),
	[prev_castle_owner_id] [int] NULL,
 CONSTRAINT [PK_castle] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[manor_data_n]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[manor_data_n](
	[manor_id] [int] NOT NULL,
	[data_index] [int] NOT NULL,
	[seed_id_n] [int] NOT NULL,
	[seed_price_n] [bigint] NOT NULL,
	[seed_sell_count_n] [bigint] NOT NULL,
	[crop_id_n] [int] NOT NULL,
	[crop_buy_count_n] [bigint] NOT NULL,
	[crop_price_n] [bigint] NOT NULL,
	[crop_type_n] [int] NOT NULL,
 CONSTRAINT [PK_manor_data_n] PRIMARY KEY CLUSTERED 
(
	[manor_id] ASC,
	[data_index] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCastleSiegeElapsedTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SaveCastleSiegeElapsedTime    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SaveCastleSiegeElapsedTime
	
INPUT	
	@siege_elapsed_time	int,
	@castle_id	int
OUTPUT

return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SaveCastleSiegeElapsedTime]
(
	@siege_elapsed_time	int,
	@castle_id	int
)
AS
SET NOCOUNT ON

UPDATE castle SET siege_elapsed_time = @siege_elapsed_time WHERE id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharCopyPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_MoveCharCopyPledge]
(
	@world_id	varchar(5)
)
AS


declare @sql varchar(1024)
declare @conn_str varchar(256)

set @conn_str = ''127.0.0.'' + @world_id + '''''';''''sa'''';''''st82cak9''

set @sql = '' insert into req_charmove ( old_char_name, old_char_id, account_name, account_id,  old_world_id, new_world_id, new_char_name ) select R1.char_name, char_id, account_name, account_id, '' + @world_id + '' , 100, R1.char_name + ''''-'' + @world_id + ''''''   from ( select * from ''
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '''' select pledge_id, char_id, char_name, account_id, account_name from lin2world.dbo.user_data (nolock) where account_id > 0  '''' ) )  as R1 ''
	+ '' left join ( select * from req_pledge (nolock) where server_id = '' + @world_id + '' ) as R2 ''
	+ '' on R1.pledge_id = R2.pledge_id ''
	+ '' where server_id is not null ''

exec ( @sql )

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSSQSystemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**  
  * @procedure lin_LoadSSQSystemInfo  
  * @brief SSQ 정보 로드  
  *  
  * @date 2004/11/18  
  * @author sonai  <sonai@ncsoft.net>  
  */  
CREATE PROCEDURE [dbo].[lin_LoadSSQSystemInfo] AS  
  
  
  
 SELECT TOP 2 round_number,  status, winner,  
   event_start_time, event_end_time, seal_effect_time, seal_effect_end_time,  
   seal1, seal2, seal3, seal4, seal5, seal6, seal7, ISNULL(castle_snapshot_time, 0), ISNULL(can_drop_guard, 0)  
   FROM ssq_data order by round_number desc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AcquireSubPledgeSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE
[dbo].[lin_AcquireSubPledgeSkill] (
	@pledge_id		int,
	@pledge_type		int,
	@skill_id			int,
	@skill_lev		int
)
AS

SET NOCOUNT ON

IF (EXISTS (SELECT skill_lev FROM subpledge_skill WHERE pledge_id = @pledge_id AND pledge_type = @pledge_type AND skill_id = @skill_id))
BEGIN
	UPDATE subpledge_skill SET skill_lev = @skill_lev WHERE pledge_id = @pledge_id AND pledge_type = @pledge_type AND skill_id = @skill_id
	-- AND skill_lev < @skill_lev
END
ELSE
BEGIN
INSERT INTO subpledge_skill(pledge_id, pledge_type, skill_id, skill_lev)
VALUES (@pledge_id, @pledge_type, @skill_id, @skill_lev)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDoor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadDoor]  
(  
 @name NVARCHAR(50)  
)  
AS  
SET NOCOUNT ON  
SELECT hp, ISNULL(max_hp, hp) FROM door  (nolock) WHERE name = @name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_expiration]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_expiration](
	[item_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[expiration_date] [int] NOT NULL,
 CONSTRAINT [PK_item_expiration] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[item_expiration]') AND name = N'IX_item_expiration')
CREATE NONCLUSTERED INDEX [IX_item_expiration] ON [dbo].[item_expiration] 
(
	[user_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadLastColor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadLastColor
desc:	load user last color
exam:	exec lin_LoadLastColor
history:	2008-03-14	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_LoadLastColor] 
(
	@char_id int
)
AS

SET NOCOUNT ON

SELECT color_index, saved_time  FROM user_last_color (nolock)  WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_log](
	[char_id] [int] NULL,
	[log_id] [tinyint] NULL,
	[log_date] [datetime] NULL CONSTRAINT [DF_user_log_log_date]  DEFAULT (getdate()),
	[log_from] [int] NULL,
	[log_to] [int] NULL,
	[use_time] [int] NULL,
	[subjob_id] [int] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_log]') AND name = N'IX_user_log')
CREATE CLUSTERED INDEX [IX_user_log] ON [dbo].[user_log] 
(
	[char_id] ASC,
	[log_id] ASC,
	[log_to] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_BONUS_CHAR]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_BONUS_CHAR](
	[ref_id] [bigint] IDENTITY(1,1) NOT NULL,
	[char_id] [bigint] NOT NULL,
	[bonus_count] [bigint] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UninstallAllBattleCamp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UninstallAllBattleCamp    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_UninstallAllBattleCamp
-- by bert
-- return deleted battle camp ids

CREATE PROCEDURE [dbo].[lin_UninstallAllBattleCamp] (@castle_id INT, @type INT)
AS

SET NOCOUNT ON

SELECT id FROM object_data WHERE residence_id = @castle_id AND type = @type

DELETE FROM object_data WHERE residence_id = @castle_id AND type = @type

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CommentDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CommentDelete
	
INPUT	
	@delete		int,
	@comment_id		int
OUTPUT
return
made by
	young
date
	2003-09-02
********************************************/
CREATE PROCEDURE [dbo].[lin_CommentDelete]
(
	@delete		int,
	@comment_id		int
)
AS
SET NOCOUNT ON

if @delete = 1
	update user_comment set deleted = 1 where comment_id = @comment_id
else if @delete = 2
	update user_comment set deleted = 0 where comment_id = @comment_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetBuilderCharacter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetBuilderCharacter    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_SetBuilderCharacter
	Set Builder Character flag
INPUT
	@char_name	nvarchar,
	@nBuilderLev	int
OUTPUT
	char_id
return
made by
	carrot
date
	2002-06-28
********************************************/
CREATE PROCEDURE [dbo].[lin_SetBuilderCharacter]
(
	@char_name	NVARCHAR(24),
	@nBuilderLev	INT
)
AS

SET NOCOUNT ON

DECLARE @Char_id INT
SET @Char_id = 0

UPDATE user_data SET builder =  @nBuilderLev WHERE char_name = @char_name
IF @@ROWCOUNT > 0
BEGIN
	SELECT @Char_id = char_id FROM user_data WHERE char_name = @char_name
END

SELECT @Char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertItemData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_InsertItemData]
	@item_type	int,
	@can_move	bit,
	@is_stackable	bit,
	@is_period	bit
as
set nocount on
insert into [dbo].[ItemData] (item_type, can_move, is_stackable, is_period)
values (@item_type, @can_move, @is_stackable, @is_period)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetRelatedCastleSiege]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetRelatedCastleSiege    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetRelatedCastleSiege
	
INPUT	
	@castle_id	int,
	@pledge_id	int
OUTPUT
	id, 
	next_war_time, 
	type 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_GetRelatedCastleSiege]
(
	@castle_id	int,
	@pledge_id	int
)
AS
SET NOCOUNT ON

SELECT 
	c.id, 
	c.next_war_time, 
	cw.type 
FROM 
	castle c (nolock) , 
	castle_war cw (nolock)  
WHERE 
	c.id = cw.castle_id 
	AND c.next_war_time <> 0 
	AND c.id = @castle_id
	AND cw.pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDuelRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SaveDuelRecord
	
INPUT	
	@user_id		int,
	@individual_win 	int,
	@individual_lose	int,
	@individual_draw	int,
	@party_win		int,
	@party_lose		int,
	@party_draw		int
OUTPUT

return
made by
	sei
date
	2006-11-01
********************************************/

CREATE PROCEDURE [dbo].[lin_SaveDuelRecord]
(
	@user_id		int,
	@individual_win 	int,
	@individual_lose	int,
	@individual_draw	int,
	@party_win		int,
	@party_lose		int,
	@party_draw		int
)
AS
SET NOCOUNT ON

IF EXISTS(SELECT * FROM duel_record WHERE user_id = @user_id)
	BEGIN

	UPDATE duel_record 
	SET 	individual_win = @individual_win,  individual_lose = @individual_lose, individual_draw = @individual_draw,
		party_win = @party_win, party_lose = @party_lose,  party_draw = @party_draw
	WHERE user_id = @user_id

	END
ELSE
	BEGIN
	
	INSERT INTO 	duel_record	(user_id, individual_win, individual_lose, individual_draw,
					party_win, party_lose, party_draw)
	VALUES			(@user_id, @individual_win, @individual_lose, @individual_draw,
					@party_win, @party_lose, @party_draw)

	END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadUserPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadUserPoint
desc:	load user point
exam:	exec lin_LoadUserPoint
history:	2008-02-25	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_LoadUserPoint] 
(
	@char_id int,
	@point_type int
)
AS

SET NOCOUNT ON

DECLARE @point int

SELECT @point = point FROM user_point(nolock)  WHERE char_id = @char_id and point_type = @point_type

if @point is null and @point_type = 6
begin
	INSERT INTO user_point (char_id, point_type, point)
	VALUES(@char_id, @point_type, 20000)
	set @point = 20000
end

select isnull(@point, 0)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_acc_lev]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_acc_lev](
	[lev] [tinyint] NOT NULL,
	[count] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_pvppoint_restrain]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_pvppoint_restrain](
	[char_id] [int] NOT NULL,
	[give_count] [int] NULL,
	[give_time] [int] NULL,
 CONSTRAINT [PK_user_pvppoint_restrain_1] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_OustPledgeMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_OustPledgeMember    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_OustPledgeMember
-- by bert
-- return ousted member id
-- modified by kks (2006-03-07)
CREATE PROCEDURE [dbo].[lin_OustPledgeMember]
(
	@pledge_id	INT,
	@pledge_type 	INT,
	@char_name	NVARCHAR(50)
)
AS

DECLARE @ret INT
DECLARE @char_id INT

SELECT @char_id = char_id
FROM user_data
WHERE char_name = @char_name and pledge_type = @pledge_type

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
BEGIN
	SELECT @ret = 0
	GOTO EXIT_PROC
END

SET NOCOUNT ON

BEGIN TRAN

UPDATE user_data
SET pledge_id = 0, pledge_type = 0, grade_id = 0
WHERE char_id = @char_id AND pledge_id = @pledge_id AND pledge_type = @pledge_type

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = @char_id
	-- 추가되는 코드는 여기에 들어간다.
END
ELSE
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

EXIT_PROC:
SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_auction]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_auction](
	[auction_id] [int] IDENTITY(1,1) NOT NULL,
	[auction_type] [tinyint] NOT NULL CONSTRAINT [DF_item_acution_auction_type]  DEFAULT ((0)),
	[auction_status] [tinyint] NOT NULL CONSTRAINT [DF_item_auction_auction_status]  DEFAULT ((0)),
	[extend_status] [tinyint] NOT NULL CONSTRAINT [DF_item_auction_extend_status]  DEFAULT ((0)),
	[auction_npc] [int] NOT NULL CONSTRAINT [DF_item_auction_auction_npc]  DEFAULT ((0)),
	[start_time] [int] NOT NULL,
	[end_time] [int] NOT NULL,
	[init_price] [bigint] NOT NULL CONSTRAINT [DF_item_auction_init_price]  DEFAULT ((0)),
	[immediate_price] [bigint] NOT NULL CONSTRAINT [DF_item_auction_immediate_price]  DEFAULT ((0)),
	[item_type] [int] NOT NULL,
	[item_id] [int] NOT NULL CONSTRAINT [DF_item_auction_item_id]  DEFAULT ((0)),
	[item_amount] [bigint] NOT NULL CONSTRAINT [DF_item_auction_item_amount]  DEFAULT ((0)),
	[item_owner] [int] NOT NULL CONSTRAINT [DF_item_auction_item_owner]  DEFAULT ((0)),
 CONSTRAINT [PK__item_auction__018B8EF2] PRIMARY KEY CLUSTERED 
(
	[auction_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[item_auction]') AND name = N'IX_item_auction_item_owner')
CREATE NONCLUSTERED INDEX [IX_item_auction_item_owner] ON [dbo].[item_auction] 
(
	[item_owner] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[changed_name_by_merge]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[changed_name_by_merge](
	[id] [int] NOT NULL,
	[type] [int] NOT NULL,
	[name_origin] [nvarchar](50) NOT NULL,
	[name_temp] [nvarchar](50) NULL,
	[name_new] [nvarchar](50) NULL,
	[previous_server] [int] NOT NULL,
	[change_date] [datetime] NULL,
	[change_flag] [int] NOT NULL CONSTRAINT [DF_changed_name_by_merge_change_flag]  DEFAULT ((0)),
 CONSTRAINT [PK_changed_name_by_merge] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAgit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_LoadAgit    
     
INPUT     
 @agit_id  int    
OUTPUT    
 pledge_id,     
 hp_stove,     
 hp_stove_expire,     
 mp_flame,     
 mp_flame_expire,     
 hatcher,     
 status,     
 next_war_time     
return    
made by    
 carrot    
date    
 2002-06-16    
********************************************/    
CREATE PROCEDURE [dbo].[lin_LoadAgit]    
(    
 @agit_id  int    
)    
AS    
    
SET NOCOUNT ON    
    
select pledge_id, hp_stove, hp_stove_expire, mp_flame, mp_flame_expire, hatcher, status, next_war_time ,  
  isnull(R1.auction_id, 0) , isnull( auction_time, 0)   , isnull ( last_price , 0) , isnull(last_cancel, 0) , isnull (min_price, 0), isnull(teleport_level, 0),   
 isnull(teleport_expire, 0),  isnull ( auction_desc, '''') , isnull( next_cost, 0) , isnull ( cost_fail, 0 )  , isnull ( tax_rate, 0 ),   
 isnull (tax_rate_to_change, 0), isnull (tax_child_rate, 0), isnull (tax_child_rate_to_change, 0), isnull(shop_income, 0), isnull(shop_income_temp, 0)  
from (    
 select id, pledge_id, hp_stove, hp_stove_expire, mp_flame, mp_flame_expire, hatcher, status, next_war_time , auction_id, last_price, last_cancel,   
 teleport_level, teleport_expire, next_cost, cost_fail  , tax_rate, tax_rate_to_change, tax_child_rate, tax_child_rate_to_change, shop_income_temp, shop_income  
 from agit (nolock)     
 where id = @agit_id      
 ) as R1    
 left join    
 (     
 select agit_id, auction_id, auction_time , min_price, auction_desc    
 from agit_auction (nolock)     
 where agit_id = @agit_id     
 ) as R2    
 on R1.id = R2.agit_id and R1.auction_id = R2.auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agit_auction]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[agit_auction](
	[agit_id] [int] NULL,
	[auction_id] [int] IDENTITY(1,1) NOT NULL,
	[auction_desc] [nvarchar](200) NULL,
	[min_price] [bigint] NULL,
	[accepted_bid] [bigint] NULL,
	[auction_time] [int] NULL,
	[auction_tax] [int] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agit_auction]') AND name = N'IX_agit_auction_1')
CREATE NONCLUSTERED INDEX [IX_agit_auction_1] ON [dbo].[agit_auction] 
(
	[agit_id] ASC,
	[auction_time] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agit_auction]') AND name = N'IX_agit_auction_2')
CREATE NONCLUSTERED INDEX [IX_agit_auction_2] ON [dbo].[agit_auction] 
(
	[auction_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDismissReservedPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadDismissReservedPledge    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadDismissReservedPledge
	
INPUT	
	@status	int
OUTPUT
	pledge_id, 
	dismiss_reserved_time 
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_LoadDismissReservedPledge]
(
	@status	int
)
AS
SET NOCOUNT ON

SELECT pledge_id, dismiss_reserved_time FROM pledge  (nolock) WHERE status = @status

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteCastleWarByCastleId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteCastleWarByCastleId]
(
@castle_id INT
)
AS
SET NOCOUNT ON
DELETE FROM castle_war WHERE castle_id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveLastColor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveLastColor
desc:	save LastColor
exam:	exec lin_SaveLastColor
history:	2008-3-14	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_SaveLastColor] 
(
	@char_id int,
	@color_index int,
	@saved_time int
)
AS

SET NOCOUNT ON

/*
IF (@point < 0)
BEGIN            
    RAISERROR (''Not valid parameter : char id[%d] point[%d]'', @char_id,  @point)
    RETURN -1            
END            

*/

UPDATE user_last_color SET color_index = @color_index, saved_time = @saved_time
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO user_last_color (char_id, color_index, saved_time) 
	VALUES (@char_id, @color_index, @saved_time)    	
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SurrenderAllianceWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- lin_SurrenderAllianceWar
-- by bert

CREATE PROCEDURE
[dbo].[lin_SurrenderAllianceWar] (@proposer_alliance_id INT, @proposee_alliance_id INT, @war_id INT, @war_end_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

UPDATE alliance_war
SET status = 2,	-- WAR_END_SURRENDER
winner = @proposee_alliance_id,
winner_name = (SELECT name FROM alliance WHERE id = @proposee_alliance_id),
end_time = @war_end_time
WHERE
id = @war_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = @war_id
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_name_reserved]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_name_reserved](
	[char_name] [nvarchar](50) NOT NULL,
	[account_id] [int] NOT NULL CONSTRAINT [DF_user_name_reserved_account_id]  DEFAULT ((0)),
	[used] [tinyint] NOT NULL CONSTRAINT [DF_user_name_reserved_used]  DEFAULT ((0)),
 CONSTRAINT [PK_user_name_reserved] PRIMARY KEY CLUSTERED 
(
	[char_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_inzone]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_inzone](
	[char_id] [int] NOT NULL,
	[inzone_type_id] [int] NOT NULL,
	[last_use] [int] NOT NULL CONSTRAINT [DF_user_inzone_last_use]  DEFAULT ((0)),
	[group_restriction] [int] NOT NULL CONSTRAINT [DF__user_inzo__group__43C431FA]  DEFAULT ((0)),
	[entrance_count] [int] NOT NULL CONSTRAINT [DF__user_inzo__entra__44B85633]  DEFAULT ((0)),
	[max_entrance_count] [int] NOT NULL CONSTRAINT [DF_user_inzone_max_entrance_count]  DEFAULT ((1)),
 CONSTRAINT [PK_user_inzone] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[inzone_type_id] ASC,
	[group_restriction] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPunish]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetPunish    Script Date: 2003-09-20 ?ㅼ쟾 11:52:00 ******/
/********************************************
lin_SetPunish
	Set punish
INPUT
	@char_id	INT,
	@punish_id 	INT,
	@punish_on	INT,
	@remain	INT
OUTPUT
return
made by
	young
date
	2002-11-27
********************************************/
CREATE   PROCEDURE [dbo].[lin_SetPunish]
(
	@char_id	INT,
	@punish_id	INT,
	@punish_on	INT,
	@remain	INT

)
AS
SET NOCOUNT ON

declare @nCount int

select @nCount = count(*) from user_punish (nolock) where char_id = @char_id and punish_id = @punish_id

if ( @nCount > 0 and @remain = 0)
begin
	delete from user_punish where char_id = @char_id and punish_id = @punish_id
end

if ( @nCount > 0 and @remain > 0)
begin
	if @punish_on = 1
		update user_punish set  remain_game = @remain where char_id = @char_id and punish_id = @punish_id

	if @punish_on = 0
		update user_punish set  remain_real = @remain  where char_id = @char_id and punish_id = @punish_id
		
end

if ( @nCount = 0 and @remain > 0)
begin
	if @punish_on = 1
		insert into user_punish(char_id, punish_id, punish_on, remain_game) values (@char_id, @punish_id, 1, @remain)

	if @punish_on = 0
		insert into user_punish(char_id, punish_id, punish_on, remain_real) values (@char_id, @punish_id, 0, @remain)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateCastleNextWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_UpdateCastleNextWar]
	@next_war_time	int,
	@castle_id	int
as
set nocount on

UPDATE castle SET next_war_time = @next_war_time WHERE id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharPlg]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_MoveCharPlg]
(
	@world_id	varchar(5)
)
AS


declare @sql varchar(1024)
declare @conn_str varchar(256)

set @conn_str = ''127.0.0.'' + @world_id + '''''';''''sa'''';''''st82cak9''

set @sql = '' insert into pledge ( old_world_id, old_pledge_id,  old_ruler_id, ruler_id, name, alliance_id, challenge_time, root_name_value, now_war_id, oust_time, skill_level, castle_id, agit_id, rank, name_value, status, private_flag, crest_id, is_guilty, dismiss_reserved_time, alliance_ousted_time, alliance_withdraw_time, alliance_dismiss_time )  ''
	+ '' select '' + @world_id + ''  , R1.pledge_id, ruler_id, 0, name + ''''-'' + @world_id + '''''' , 0, 0, 0, 0 ,0 ,0 , 0, 0, 0, name_value, 0, 0, 0, 0, 0, 0, 0, 0  from ( select * from ''
	+ '' OPENROWSET ( ''''SQLOLEDB'''', '''''' + @conn_str + '''''', '''' select * from lin2world.dbo.pledge (nolock)  '''' ) )  as R1 ''
	+ '' left join ( select * from req_pledge (nolock) where server_id = '' + @world_id + '' ) as R2 ''
	+ '' on R1.pledge_id = R2.pledge_id ''
	+ '' where server_id is not null ''

exec ( @sql )

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteCastleIncome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeleteCastleIncome    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DeleteCastleIncome
	
INPUT	
	@castle_id	int,
	@item_type	int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_DeleteCastleIncome]
(
	@castle_id	int,
	@item_type	int
)
AS
SET NOCOUNT ON

delete castle_crop where castle_id = @castle_id and item_type = @item_type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_classid_normal]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_classid_normal](
	[id] [int] NOT NULL,
 CONSTRAINT [PK_item_classid_normal] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveUserPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveUserPoint
desc:	save user point
exam:	exec lin_SaveUserPoint
history:	2008-02-25	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_SaveUserPoint] 
(
	@char_id int,
	@point_type int,
	@point int
)
AS

SET NOCOUNT ON

/*
IF (@point < 0)
BEGIN            
    RAISERROR (''Not valid parameter : char id[%d] point[%d]'', @char_id,  @point)
    RETURN -1            
END            

*/

UPDATE user_point SET point = @point
WHERE char_id = @char_id AND point_type = @point_type

IF @@rowcount = 0
BEGIN
	INSERT INTO user_point (char_id, point_type, point) 
	VALUES (@char_id, @point_type, @point)    	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[block_use_store]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[block_use_store](
	[char_id] [int] NOT NULL,
	[block_data] [datetime] NULL CONSTRAINT [DF__block_use__block__6BDAAE47]  DEFAULT (getdate()),
	[block_second] [int] NULL,
	[status] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InitPledgeCrest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_InitPledgeCrest    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_InitPledgeCrest
	
INPUT	
	@pledge_id	int
OUTPUT

return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_InitPledgeCrest]
(
	@pledge_id	int
)
AS
SET NOCOUNT ON

UPDATE Pledge SET crest_id = 0 WHERE pledge_id = @pledge_id	-- update tuple from pledge table

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[castle_war]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[castle_war](
	[castle_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL,
	[type] [tinyint] NOT NULL,
	[propose_time] [int] NULL CONSTRAINT [DF__castle_wa__propo__1A35AA7D]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDoorStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveDoorStatus]  
(  
 @hp INT,  
 @max_hp INT,  
 @name NVARCHAR(50)  
)  
AS  
SET NOCOUNT ON  
UPDATE door SET hp = @hp, max_hp = @max_hp WHERE name = @name

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadCastleWarRelatedPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadCastleWarRelatedPledge    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadCastleWarRelatedPledge
	
INPUT	
	@castle_id	int
OUTPUT
return
made by
	bert
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadCastleWarRelatedPledge]
(
	@castle_id	int
)
AS
SET NOCOUNT ON

SELECT 
	pledge_id, type, propose_time 
FROM 
	castle_war (nolock)  
WHERE 
	castle_id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_history](
	[char_name] [nvarchar](50) NOT NULL,
	[char_id] [int] NOT NULL,
	[log_date] [datetime] NOT NULL CONSTRAINT [DF_user_history_log_date]  DEFAULT (getdate()),
	[log_action] [tinyint] NOT NULL,
	[account_name] [nvarchar](50) NULL,
	[create_date] [datetime] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_history]') AND name = N'IX_user_history')
CREATE NONCLUSTERED INDEX [IX_user_history] ON [dbo].[user_history] 
(
	[char_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCharacter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveCharacter
desc:	save user_data

history:	2007-03-30	modified by btwinuni
*/
create procedure [dbo].[lin_SaveCharacter]
(
	@subjob_id int,
	@pledge_id int,
	@class int,
	@world int,
	@xloc int,
	@yloc int,
	@zloc int,
	@IsInVehicle int,
	@HP float,
	@MP float,
	@max_HP float,
	@max_MP float,
	@SP int,
	@Exp BIGINT,
	@Lev int,
	@align int,
	@PK int,
	@duel int,
	@pkpardon int,
	@Face_Index int,
	@Hair_Shape_Index int,
	@Hair_Color_Index int,
	@ssq_dawn_round int,
	@char_id  int,
	@subjob0_class int,
	@subjob1_class int,
	@subjob2_class int,
	@subjob3_class int,
	@CP float,
	@max_CP float
)
as

set nocount on

update	user_data 
set	subjob_id = @subjob_id,
	class= @class,
	world= @world,
	xloc= @xloc,
	yloc= @yloc,
	zloc= @zloc,
	IsInVehicle= @IsInVehicle,
	HP= @HP,
	MP= @MP,
	max_HP= @max_HP,
	max_MP= @max_MP,
	SP= @SP,
	Exp= @Exp,
	Lev= @Lev,
	align= @align,
	PK= @PK,
	duel= @duel,
	pkpardon= @pkpardon,
	Face_Index= @Face_Index, 
	Hair_Shape_Index= @Hair_Shape_Index, 
	Hair_Color_Index= @Hair_Color_Index ,
	ssq_dawn_round = @ssq_dawn_round,
	subjob0_class = @subjob0_class, 
	subjob1_class = @subjob1_class, 
	subjob2_class = @subjob2_class, 
	subjob3_class = @subjob3_class, 
	cp = @CP,
	max_cp = @max_CP

where	char_id= @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InitItemData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_InitItemData]
as
set nocount on
if exists (select * from sys.objects where object_id = object_id(N''[dbo].[ItemData]'') and type in (N''U''))
drop table [dbo].[ItemData]
create table [dbo].[itemData]
(
	item_type	int not null,
	can_move	bit not null default(0),
	is_stackable	bit not null default(0),
	is_period	bit not null default(0)
)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDuelRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadDuelRecord
	
INPUT	
	@user_id	int
OUTPUT
	 individual_win, 
	individual_lose, 
	individual_draw, 
	party_win, 
	party_lose, 
	party_draw
return
made by
	sei
date
	2006-11-01
********************************************/

CREATE PROCEDURE [dbo].[lin_LoadDuelRecord]
(
	@user_id 	int
)
AS
SET NOCOUNT ON

SELECT individual_win, individual_lose, individual_draw, party_win, party_lose, party_draw 
FROM duel_record
WHERE user_id = @user_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_item_mincnt]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_item_mincnt](
	[item_type] [int] NOT NULL,
	[item_id] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SurrenderPersonally]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SurrenderPersonally](@char_id INT, @war_id INT)  
AS  
  
SET NOCOUNT ON  
  
INSERT INTO user_surrender  
(char_id, surrender_war_id)  
VALUES   
(@char_id, @war_id)  
  
SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_PAY]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_PAY](
	[INV_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CHAR_NAME] [nvarchar](20) NOT NULL,
	[CHAR_ID] [bigint] NOT NULL,
	[COUNT] [bigint] NOT NULL,
	[TYPE] [bigint] NOT NULL,
	[STATE] [bigint] NOT NULL,
	[DATE] [datetime] NULL CONSTRAINT [DF_A_PAY_DATE]  DEFAULT (getdate()),
 CONSTRAINT [PK_PAY_WM] PRIMARY KEY CLUSTERED 
(
	[INV_ID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_STAT_CHARS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_STAT_CHARS](
	[date] [datetime] NOT NULL CONSTRAINT [DF_A_STAT_CHARS_date]  DEFAULT (getdate()),
	[name] [nvarchar](20) NULL CONSTRAINT [DF_A_STAT_CHARS_name]  DEFAULT (N'no_char'),
	[char_id] [bigint] NULL CONSTRAINT [DF_A_STAT_CHARS_char_id]  DEFAULT ((0)),
	[lev] [bigint] NULL CONSTRAINT [DF_A_STAT_CHARS_lev]  DEFAULT ((0)),
	[sumall] [bigint] NULL CONSTRAINT [DF_A_STAT_CHARS_sumall]  DEFAULT ((0)),
	[sumadena] [bigint] NULL CONSTRAINT [DF_A_STAT_CHARS_sumadena]  DEFAULT ((0)),
	[countitems] [bigint] NULL CONSTRAINT [DF_A_STAT_CHARS_countitems]  DEFAULT ((0)),
	[sumcoins] [bigint] NULL CONSTRAINT [DF_A_STAT_CHARS_sumcoins]  DEFAULT ((0)),
	[type] [tinyint] NOT NULL CONSTRAINT [DF_A_STAT_CHARS_type]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CommentWrite]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CommentWrite    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_CommentWrite
	
INPUT	
	@char_name		nvarchar(50),
	@char_id		int,
	@comment		nvarchar(200),
	@writer			nvarchar(50)
OUTPUT
return
made by
	young
date
	2003-09-02
********************************************/
create PROCEDURE [dbo].[lin_CommentWrite]
(
	@char_name		nvarchar(50),
	@char_id		int,
	@comment		nvarchar(200),
	@writer			nvarchar(50)
)
AS
SET NOCOUNT ON

insert into user_comment ( char_name, char_id, comment, writer )
values ( @char_name, @char_id, @comment, @writer )

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetCastleOwner2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetCastleOwner2    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetCastleOwner2
	
INPUT	
	@pledge_id	int,
	@agit_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SetCastleOwner2]
(
	@pledge_id	int,
	@castle_id		int
)
AS
SET NOCOUNT ON

UPDATE castle SET pledge_id = @pledge_id WHERE id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeclareWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeclareWar]
(
@challenger INT,
@challengee INT,
@declare_time INT
)
AS
SET NOCOUNT ON

INSERT INTO war_declare (challenger, challengee, declare_time) VALUES (@challenger, @challengee, @declare_time)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadControlTowerByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadControlTowerByName]
(
@name VARCHAR(256)
)
AS
SELECT residence_id, control_level, hp, status
FROM control_tower
WHERE name = @name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_updateSulffrageUsed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_updateSulffrageUsed
 set sulffrage
INPUT        
 @char_id
 @sociality
 @sulffrage
 @last_changed
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_updateSulffrageUsed]
(        
 @char_id INT,
 @sulffrage INT
)        
AS        
        
SET NOCOUNT ON        

UPDATE user_sociality 
SET used_sulffrage = @sulffrage
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetBirthday]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_Setbirthday
desc:	캐릭터 생성일 변경

history:	2008-09-08	created by choanari
*/
create procedure [dbo].[lin_SetBirthday]
	@char_id int,
	@date NVARCHAR(20)
as
set nocount on

if exists ( select char_id from user_data (nolock) where char_id = @char_id)
begin 
	update user_data set create_date = @date where char_id = @char_id
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[olympiad]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[olympiad](
	[season] [int] IDENTITY(1,1) NOT NULL,
	[step] [int] NULL,
	[season_start_time] [int] NULL,
	[start_sec] [int] NULL,
	[bonus1_sec] [int] NULL,
	[bonus2_sec] [int] NULL,
	[bonus3_sec] [int] NULL,
	[bonus4_sec] [int] NULL,
	[nominate_sec] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agit]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[agit](
	[id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[pledge_id] [int] NULL CONSTRAINT [DF__agit__pledge_id__17236851]  DEFAULT ((0)),
	[auction_price] [bigint] NULL CONSTRAINT [DF__agit__auction_pr]  DEFAULT ((0)),
	[auction_date] [int] NULL CONSTRAINT [DF__agit__auction_da__190BB0C3]  DEFAULT ((0)),
	[hp_stove] [tinyint] NULL CONSTRAINT [DF__agit__hp_stove__1F6E958F]  DEFAULT ((0)),
	[mp_flame] [tinyint] NULL CONSTRAINT [DF__agit__mp_flame__2062B9C8]  DEFAULT ((0)),
	[hatcher] [tinyint] NULL CONSTRAINT [DF__agit__hatcher__2156DE01]  DEFAULT ((0)),
	[hp_stove_expire] [int] NULL CONSTRAINT [DF__agit__hp_stove_e__224B023A]  DEFAULT ((0)),
	[mp_flame_expire] [int] NULL CONSTRAINT [DF__agit__mp_flame_e__233F2673]  DEFAULT ((0)),
	[status] [tinyint] NULL CONSTRAINT [DF__agit__status__270FB757]  DEFAULT ((2)),
	[next_war_time] [int] NULL CONSTRAINT [DF__agit__next_war_t__2803DB90]  DEFAULT ((0)),
	[auction_id] [int] NULL,
	[last_price] [bigint] NULL,
	[last_cancel] [int] NULL,
	[teleport_level] [int] NULL CONSTRAINT [DF__agit__teleport_l__442BE449]  DEFAULT ((0)),
	[teleport_expire] [int] NULL CONSTRAINT [DF__agit__teleport_e__45200882]  DEFAULT ((0)),
	[next_cost] [int] NULL,
	[cost_fail] [int] NULL,
	[tax_rate] [int] NOT NULL CONSTRAINT [DF_agit_tax_rate]  DEFAULT ((0)),
	[shop_income] [bigint] NOT NULL CONSTRAINT [DF_agit_shop_income]  DEFAULT ((0)),
	[tax_rate_to_change] [smallint] NOT NULL CONSTRAINT [DF__agit__tax_rate_t__2C09769E]  DEFAULT ((-1)),
	[tax_child_rate] [smallint] NOT NULL CONSTRAINT [DF__agit__tax_child___2CFD9AD7]  DEFAULT ((0)),
	[tax_child_rate_to_change] [smallint] NOT NULL CONSTRAINT [DF__agit__tax_child___2DF1BF10]  DEFAULT ((-1)),
	[shop_income_temp] [bigint] NOT NULL CONSTRAINT [DF__agit__shop_incom]  DEFAULT ((0)),
	[team_battle_status] [int] NULL,
 CONSTRAINT [PK_agit] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetCharacterDeleteRestore]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetCharacterDeleteRestore    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_SetCharacterDeleteRestore
	Restore character which is set deleted
INPUT
	@char_id	INT
OUTPUT
return
made by
	carrot
date
	2003-01-7
********************************************/
CREATE PROCEDURE [dbo].[lin_SetCharacterDeleteRestore]
(
	@char_id	INT
)
AS

SET NOCOUNT ON

UPDATE user_data SET temp_delete_date = NULL WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_warehouse]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_warehouse](
	[item_id] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[item_type] [int] NOT NULL,
	[amount] [bigint] NOT NULL,
	[enchant] [int] NOT NULL,
	[eroded] [int] NOT NULL,
	[bless] [tinyint] NOT NULL,
	[ident] [tinyint] NOT NULL,
	[wished] [tinyint] NULL,
	[warehouse] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_warehouse]') AND name = N'idx_user_warehouse_charid')
CREATE NONCLUSTERED INDEX [idx_user_warehouse_charid] ON [dbo].[user_warehouse] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_warehouse]') AND name = N'idx_user_warehouse_itemid')
CREATE UNIQUE NONCLUSTERED INDEX [idx_user_warehouse_itemid] ON [dbo].[user_warehouse] 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_warehouse]') AND name = N'idx_user_warehouse_itemtype')
CREATE NONCLUSTERED INDEX [idx_user_warehouse_itemtype] ON [dbo].[user_warehouse] 
(
	[item_type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSSQWinner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadSSQWinner]
(
@roundNumber INT
)  
AS
 SELECT winner FROM ssq_data 
 WHERE round_number = @roundNumber

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[char_pet]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[char_pet](
	[char_id] [int] NOT NULL,
	[pet_id] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dominion_registry]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dominion_registry](
	[dominion_id] [int] NOT NULL,
	[registry_type] [int] NOT NULL,
	[registry_id] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModSubJobClass]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModSubJobClass
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@class		int
OUTPUT
return
made by
	kks
date
	2005-01-18
	2005-09-07	modified by btwinuni
********************************************/
CREATE PROCEDURE [dbo].[lin_ModSubJobClass]
(
	@char_id	int,
	@subjob_id	int,
	@class		int
)
AS
SET NOCOUNT ON

--update user_subjob set class=@class where char_id = @char_id and subjob_id = @subjob_id
declare @sql varchar(1000)
set @sql = ''update user_data ''
	+ '' set subjob'' + cast(@subjob_id as varchar) + ''_class = '' + cast(@class as varchar)
	+ '' where char_id = '' + cast(@char_id as varchar)
exec (@sql)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UninstallBattleCamp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UninstallBattleCamp    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_UninstalllBattleCamp
-- by bert
-- return deleted battle camp id

CREATE PROCEDURE [dbo].[lin_UninstallBattleCamp] (@pledge_id INT, @type INT)
AS

SET NOCOUNT ON

SELECT id FROM object_data WHERE owner_id = @pledge_id AND type = @type

DELETE FROM object_data WHERE owner_id = @pledge_id AND type = @type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ExpireMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**  
name: lin_ExpireMail
desc: delete mail 90 day ago
exam: exec lin_ExpireMail
  
history: 2006-05-22 created by btwinuni  
*/  
CREATE PROCEDURE [dbo].[lin_ExpireMail]  
as
SET NOCOUNT ON

create table #id_list
(
	id	int
)

insert into #id_list
select id
from user_mail
where (id in (select mail_id from user_mail_receiver (nolock) where mailbox_type <> 2)
	or id in (select mail_id from user_mail_sender (nolock) where mailbox_type <> 2))
	and datediff(d, created_date, getdate()) > 90

BEGIN TRAN

	delete from user_mail_receiver where mail_id in (select id from #id_list)
	delete from user_mail_sender where mail_id in (select id from #id_list)
	delete from user_mail where id in (select id from #id_list)

COMMIT TRAN

drop table #id_list

SET NOCOUNT ON

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AcquirePledgeSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_AcquirePledgeSkill
	acquire pledge skill 
INPUT
	@pledge_id		int
	@skill_id		int
	@skill_lev		int
OUTPUT

return

date
	2006-04-21	kks
	2006-04-25	btwinuni	except skill_lev condition
********************************************/
CREATE PROCEDURE
[dbo].[lin_AcquirePledgeSkill] (
	@pledge_id		int,
	@skill_id	int,
	@skill_lev		int
)
AS

SET NOCOUNT ON

IF (EXISTS (SELECT skill_lev FROM pledge_skill WHERE pledge_id = @pledge_id AND skill_id = @skill_id))
BEGIN
	UPDATE pledge_skill SET skill_lev = @skill_lev WHERE pledge_id = @pledge_id AND skill_id = @skill_id
	-- AND skill_lev < @skill_lev
END
ELSE
BEGIN
INSERT INTO pledge_skill(pledge_id, skill_id, skill_lev)
VALUES (@pledge_id, @skill_id, @skill_lev)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadItems  
 Load item data and check adena data  
INPUT  
 @char_id INT,  
 @warehouse  INT  
OUTPUT  
 item_id, item_type, amount, enchant, eroded, bless, ident, wished  
return  
made by  
 carrot  
date  
 2002-04-23  
//const WCHAR* qsLoadItems = L"SELECT item_id, item_type, amount, enchant, eroded, bless, ident, wished FROM user_item WHERE char_id = %d AND warehouse = %d AND (NOT item_type = 0) AND NOT ITEM_TYPE = 57";  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadItems]  
(  
 @char_id INT,  
 @warehouse INT  
)  
AS  
SET NOCOUNT ON  
  
DECLARE @nSum  INT  
DECLARE @nCount INT  
  
SET @nSum = 0  
SET @nCount = 0  
  
  
--SELECT @nCount = count(amount), @nSum = sum(amount) FROM user_item WHERE char_id = @char_id AND item_type = 57 AND warehouse = @warehouse  
--IF @nCount > 1  
--BEGIN  
-- DECLARE @nMaxItemId INT  
-- SELECT @nMaxItemId = Max(item_id) FROM user_item WHERE char_id = @char_id AND item_type = 57 AND warehouse = @warehouse  
-- IF @nMaxItemId > 0   
-- BEGIN  
--  UPDATE user_item Set amount = @nSum WHERE char_id = @char_id AND item_type = 57 AND warehouse = @warehouse And item_id = @nMaxItemId  
--  DELETE user_item WHERE char_id = @char_id AND item_type = 57 AND warehouse = @warehouse And NOT item_id = @nMaxItemId  
-- END  
--END  
  
SELECT
	ui.item_id, ui.item_type, ui.amount, ui.enchant, ui.eroded, ui.bless, ui.ident, ui.wished,
	isnull(ui.variation_opt1, 0),
	isnull(ui.variation_opt2, 0),
	isnull(ui.intensive_item_type, 0),
	isnull(ui.inventory_slot_index, -1),
	isnull(uia.attack_attribute_type, -2),
	isnull(uia.attack_attribute_value, 0),
	isnull(uia.defend_attribute_0, 0),
	isnull(uia.defend_attribute_1, 0),
	isnull(uia.defend_attribute_2, 0),
	isnull(uia.defend_attribute_3, 0),
	isnull(uia.defend_attribute_4, 0),
	isnull(uia.defend_attribute_5, 0)
FROM (select * from user_item(nolock) where char_id = @char_id and warehouse = @warehouse) ui
	left join user_item_attribute uia(nolock) on ui.item_id = uia.item_id
WHERE item_type > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadControlTowerByResidenceId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadControlTowerByResidenceId]
(
@residence_id INT
)
AS
SELECT name, control_level, hp, status
FROM control_tower
WHERE residence_id = @residence_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_mail_sender]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_mail_sender](
	[mail_id] [int] NOT NULL,
	[related_id] [int] NOT NULL,
	[mail_type] [tinyint] NOT NULL,
	[mailbox_type] [tinyint] NOT NULL CONSTRAINT [DF_user_mail_sender_mailbox_type]  DEFAULT ((1)),
	[sender_id] [int] NOT NULL,
	[sender_name] [nvarchar](50) NOT NULL,
	[send_date] [datetime] NOT NULL CONSTRAINT [DF_user_mail_sender_send_date]  DEFAULT (getdate()),
	[receiver_name_list] [nvarchar](250) NOT NULL,
	[deleted] [tinyint] NOT NULL CONSTRAINT [DF_user_mail_sender_deleted]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_mail_sender]') AND name = N'IX_user_mail_sender')
CREATE CLUSTERED INDEX [IX_user_mail_sender] ON [dbo].[user_mail_sender] 
(
	[sender_id] ASC,
	[mailbox_type] ASC,
	[deleted] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_mail_sender]') AND name = N'IX_user_mail_sender_1')
CREATE NONCLUSTERED INDEX [IX_user_mail_sender_1] ON [dbo].[user_mail_sender] 
(
	[mail_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBlockList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadBlockList
	when character log in, load he''s blocked list.
INPUT
	char_id
OUTPUT
return
made by
	carrot
date
	2003-12-01
change
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadBlockList]
(
	@char_id	INT
)
AS

SET NOCOUNT ON

SELECT block_char_id, block_char_name FROM user_blocklist WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_point]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_point](
	[char_id] [int] NOT NULL,
	[point_type] [int] NOT NULL,
	[point] [int] NULL,
 CONSTRAINT [PK_user_point_1] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[point_type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_data](
	[char_name] [nvarchar](50) NOT NULL,
	[char_id] [int] IDENTITY(1,1) NOT NULL,
	[account_name] [nvarchar](50) NOT NULL,
	[account_id] [int] NOT NULL,
	[pledge_id] [int] NOT NULL CONSTRAINT [DF_user_data_pledge_id]  DEFAULT ((0)),
	[builder] [tinyint] NOT NULL CONSTRAINT [DF_user_data_builder]  DEFAULT ((0)),
	[gender] [tinyint] NOT NULL,
	[race] [tinyint] NOT NULL,
	[class] [tinyint] NOT NULL,
	[world] [smallint] NOT NULL,
	[xloc] [int] NOT NULL,
	[yloc] [int] NOT NULL,
	[zloc] [int] NOT NULL,
	[IsInVehicle] [smallint] NOT NULL CONSTRAINT [DF_user_data_IsInVehicle]  DEFAULT ((0)),
	[HP] [float] NOT NULL,
	[MP] [float] NOT NULL,
	[SP] [int] NOT NULL CONSTRAINT [DF_user_data_SP]  DEFAULT ((0)),
	[Exp] [bigint] NULL,
	[Lev] [tinyint] NOT NULL,
	[align] [int] NOT NULL,
	[PK] [int] NOT NULL CONSTRAINT [DF_user_data_PK]  DEFAULT ((0)),
	[PKpardon] [int] NOT NULL CONSTRAINT [DF_user_data_PKpardon]  DEFAULT ((0)),
	[Duel] [int] NOT NULL CONSTRAINT [DF_user_data_Dual]  DEFAULT ((0)),
	[create_date] [datetime] NOT NULL CONSTRAINT [DF_user_data_create_date]  DEFAULT (getdate()),
	[login] [datetime] NULL,
	[logout] [datetime] NULL,
	[quest_flag] [binary](128) NULL CONSTRAINT [DF_user_data_quest_flag]  DEFAULT (0x00),
	[nickname] [nvarchar](50) NULL,
	[power_flag] [binary](32) NOT NULL CONSTRAINT [DF_user_data_power_flag]  DEFAULT (0x0000000000000000000000000000000000000000000000000000000000000000),
	[pledge_dismiss_time] [int] NOT NULL CONSTRAINT [DF_user_data_pledge_manage_time]  DEFAULT ((0)),
	[pledge_leave_time] [int] NOT NULL CONSTRAINT [DF_user_data_pledge_leave_time]  DEFAULT ((0)),
	[pledge_leave_status] [tinyint] NOT NULL CONSTRAINT [DF_user_data_pledge_leave_status]  DEFAULT ((0)),
	[max_hp] [int] NOT NULL CONSTRAINT [DF_user_data_max_hp]  DEFAULT ((0)),
	[max_mp] [int] NOT NULL CONSTRAINT [DF_user_data_max_mp]  DEFAULT ((0)),
	[quest_memo] [char](32) NULL,
	[face_index] [int] NOT NULL CONSTRAINT [DF_user_data_face_index]  DEFAULT ((0)),
	[hair_shape_index] [int] NOT NULL CONSTRAINT [DF_user_data_hair_shape_index]  DEFAULT ((0)),
	[hair_color_index] [int] NOT NULL CONSTRAINT [DF_user_data_hair_color_index]  DEFAULT ((0)),
	[use_time] [int] NOT NULL CONSTRAINT [DF_user_data_use_time]  DEFAULT ((0)),
	[temp_delete_date] [smalldatetime] NULL,
	[pledge_ousted_time] [int] NOT NULL CONSTRAINT [DF_user_data_pledge_ousted_time]  DEFAULT ((0)),
	[pledge_withdraw_time] [int] NOT NULL CONSTRAINT [DF_user_data_plwdge_withdraw_time]  DEFAULT ((0)),
	[surrender_war_id] [int] NOT NULL CONSTRAINT [DF_user_data_surrender_war_id]  DEFAULT ((0)),
	[drop_exp] [bigint] NULL CONSTRAINT [DF_user_data_drop_exp]  DEFAULT ((0)),
	[old_x] [int] NULL,
	[old_y] [int] NULL,
	[old_z] [int] NULL,
	[subjob_id] [int] NULL,
	[ssq_dawn_round] [int] NULL,
	[cp] [float] NOT NULL CONSTRAINT [DF__user_data__cp__137DBFF6]  DEFAULT ((0)),
	[max_cp] [float] NOT NULL CONSTRAINT [DF__user_data__max_c__1471E42F]  DEFAULT ((0)),
	[subjob0_class] [int] NOT NULL CONSTRAINT [DF__user_data__subjo__46142CBB]  DEFAULT ((-1)),
	[subjob1_class] [int] NOT NULL CONSTRAINT [DF__user_data__subjo__470850F4]  DEFAULT ((-1)),
	[subjob2_class] [int] NOT NULL CONSTRAINT [DF__user_data__subjo__47FC752D]  DEFAULT ((-1)),
	[subjob3_class] [int] NOT NULL CONSTRAINT [DF__user_data__subjo__48F09966]  DEFAULT ((-1)),
	[pledge_type] [int] NOT NULL CONSTRAINT [DF__user_data__pledg__13E89FA1]  DEFAULT ((0)),
	[grade_id] [int] NOT NULL CONSTRAINT [DF__user_data__grade__15D0E813]  DEFAULT ((0)),
	[academy_pledge_id] [int] NULL,
	[item_duration] [int] NOT NULL CONSTRAINT [DF_user_data_item_duration]  DEFAULT ((2100000000)),
	[tutorial_flag] [binary](128) NULL CONSTRAINT [DF__user_data__tutor__1592879F]  DEFAULT ((0)),
	[associated_inzone] [int] NULL CONSTRAINT [DF_user_data_associated_inzone]  DEFAULT ((0)),
	[bookmark_slot] [int] NOT NULL CONSTRAINT [DF_user_data_bookmark_slot]  DEFAULT ((0)),
 CONSTRAINT [PK_user_data] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_data]') AND name = N'idx_user_data_1')
CREATE NONCLUSTERED INDEX [idx_user_data_1] ON [dbo].[user_data] 
(
	[account_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_data]') AND name = N'idx_user_data_account_name')
CREATE NONCLUSTERED INDEX [idx_user_data_account_name] ON [dbo].[user_data] 
(
	[account_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_data]') AND name = N'idx_user_data_pledge')
CREATE NONCLUSTERED INDEX [idx_user_data_pledge] ON [dbo].[user_data] 
(
	[pledge_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_data]') AND name = N'idx_user_data1')
CREATE UNIQUE NONCLUSTERED INDEX [idx_user_data1] ON [dbo].[user_data] 
(
	[char_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadCastle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadCastle  
   
INPUT   
 @id int,  
 @type int  
OUTPUT  
 pledge_id,   
 next_war_time,   
 tax_rate,   
 status,   
 name,   
 crop_income,   
 shop_income,   
 siege_elapsed_time   
 shop_Income_Temp,   
 Tax_rate_to_change,  
 tax_child_rate_to_change  
return  
made by  
 carrot  
date  
 2002-06-16  
change 2004-02-29 carrot  
 add CastleIncomeTemp and TaxRateTochange, tax_child_rate_to_change  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadCastle]  
(  
 @id int,  
 @type int  
)  
AS  
SET NOCOUNT ON  
  
SELECT   
 pledge_id, next_war_time, tax_rate, tax_child_rate, status, name, crop_income, shop_income, siege_elapsed_time, shop_Income_Temp, Tax_rate_to_change,  
 tax_child_rate_to_change, prev_castle_owner_id
FROM   
 castle (nolock)   
WHERE   
 id = @id AND type = @type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_item_attribute]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_item_attribute](
	[item_id] [int] NOT NULL,
	[attack_attribute_type] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_attack_attribute_type]  DEFAULT ((-2)),
	[attack_attribute_value] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_attack_attribute_value]  DEFAULT ((0)),
	[defend_attribute_0] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_defend_attribute_0]  DEFAULT ((0)),
	[defend_attribute_1] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_defend_attribute_1]  DEFAULT ((0)),
	[defend_attribute_2] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_defend_attribute_2]  DEFAULT ((0)),
	[defend_attribute_3] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_defend_attribute_3]  DEFAULT ((0)),
	[defend_attribute_4] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_defend_attribute_4]  DEFAULT ((0)),
	[defend_attribute_5] [smallint] NOT NULL CONSTRAINT [DF_user_item_attribute_defend_attribute_5]  DEFAULT ((0)),
 CONSTRAINT [PK_user_item_attribute] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetQuest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SetQuest   
   
INPUT  
@q1	INT,	@s1	INT,	@s2_1		INT,		@j1	INT,
@q2	INT,	@s2	INT,	@s2_2		INT,		@j2	INT,
@q3	INT,	@s3	INT,	@s2_3		INT,		@j3	INT,
@q4	INT,	@s4	INT,	@s2_4		INT,		@j4	INT,
@q5	INT,	@s5	INT,	@s2_5		INT,		@j5	INT,
@q6	INT,	@s6	INT,	@s2_6		INT,		@j6	INT,
@q7	INT,	@s7	INT,	@s2_7		INT,		@j7	INT,
@q8	INT,	@s8	INT,	@s2_8		INT,		@j8	INT,
@q9	INT,	@s9	INT,	@s2_9		INT,		@j9	INT,
@q10	INT,	@s10	INT,	@s2_10	INT,		@j10	INT,
@q11	INT,	@s11	INT,	@s2_11	INT,		@j11	INT,
@q12	INT,	@s12	INT,	@s2_12	INT,		@j12	INT,
@q13	INT,	@s13	INT,	@s2_13	INT,		@j13	INT,
@q14	INT,	@s14	INT,	@s2_14	INT,		@j14	INT,
@q15	INT,	@s15	INT,	@s2_15	INT,		@j15	INT,
@q16	INT,	@s16	INT,	@s2_16	INT,		@j16	INT,
@q17	INT,	@s17	INT,	@s2_17	INT,		@j17	INT,
@q18	INT,	@s18	INT,	@s2_18	INT,		@j18	INT,
@q19	INT,	@s19	INT,	@s2_19	INT,		@j19	INT,
@q20	INT,	@s20	INT,	@s2_20	INT,		@j20	INT,
@q21	INT,	@s21	INT,	@s2_21	INT,		@j21	INT,
@q22	INT,	@s22	INT,	@s2_22	INT,		@j22	INT,
@q23	INT,	@s23	INT,	@s2_23	INT,		@j23	INT,
@q24	INT,	@s24	INT,	@s2_24	INT,		@j24	INT,
@q25	INT,	@s25	INT,	@s2_25	INT,		@j25	INT,
@q26	INT,	@s26	INT,	@s2_26	INT,		@j26	INT,
  
@char_id  INT  
OUTPUT  
return  
made by  
 carrot  
 
modified by ParkPD
modified by choanari 2008-08-19
 
date  
 2006-08-09
 
********************************************/  
CREATE PROCEDURE [dbo].[lin_SetQuest]  
(  
@q1		INT,	@s1		INT,		@s2_1			INT,		@j1			INT,
@q2		INT,	@s2		INT,		@s2_2			INT,		@j2			INT,
@q3		INT,	@s3		INT,		@s2_3			INT,		@j3			INT,
@q4		INT,	@s4		INT,		@s2_4			INT,		@j4			INT,
@q5		INT,	@s5		INT,		@s2_5			INT,		@j5			INT,
@q6		INT,	@s6		INT,		@s2_6			INT,		@j6			INT,
@q7		INT,	@s7		INT,		@s2_7			INT,		@j7			INT,
@q8		INT,	@s8		INT,		@s2_8			INT,		@j8			INT,
@q9		INT,	@s9		INT,		@s2_9			INT,		@j9			INT,
@q10		INT,	@s10		INT,		@s2_10		INT,		@j10			INT,
@q11		INT,	@s11		INT,		@s2_11		INT,		@j11			INT,
@q12		INT,	@s12		INT,		@s2_12		INT,		@j12			INT,
@q13		INT,	@s13		INT,		@s2_13		INT,		@j13			INT,
@q14		INT,	@s14		INT,		@s2_14		INT,		@j14			INT,
@q15		INT,	@s15		INT,		@s2_15		INT,		@j15			INT,
@q16		INT,	@s16		INT,		@s2_16		INT,		@j16			INT,
@q17		INT,	@s17		INT,		@s2_17		INT,		@j17			INT,
@q18		INT,	@s18		INT,		@s2_18		INT,		@j18			INT,
@q19		INT,	@s19		INT,		@s2_19		INT,		@j19			INT,
@q20		INT,	@s20		INT,		@s2_20		INT,		@j20			INT,
@q21		INT,	@s21		INT,		@s2_21		INT,		@j21			INT,
@q22		INT,	@s22		INT,		@s2_22		INT,		@j22			INT,
@q23		INT,	@s23		INT,		@s2_23		INT,		@j23			INT,
@q24		INT,	@s24		INT,		@s2_24		INT,		@j24			INT,
@q25		INT,	@s25		INT,		@s2_25		INT,		@j25			INT,
@q26		INT,	@s26		INT,		@s2_26		INT,		@j26			INT,
  
@char_id  INT  
  
)  
AS  
SET NOCOUNT ON  

if exists ( select char_id from quest (nolock) where char_id = @char_id)
begin  
	UPDATE quest   
	SET   
	q1  = @q1	,	s1  = @s1	,	s2_1	= @s2_1,	j1	= @j1	,
	q2  = @q2	,	s2  = @s2	,	s2_2	= @s2_2,	j2	= @j2	,
	q3  = @q3	,	s3  = @s3	,	s2_3	= @s2_3,	j3	= @j3	,
	q4  = @q4	,	s4  = @s4	,	s2_4	= @s2_4,	j4	= @j4	,
	q5  = @q5	,	s5  = @s5	,	s2_5	= @s2_5,	j5	= @j5	,
	q6  = @q6	,	s6  = @s6	,	s2_6	= @s2_6,	j6	= @j6	,
	q7  = @q7	,	s7  = @s7	,	s2_7	= @s2_7,	j7	= @j7	,
	q8  = @q8	,	s8  = @s8	,	s2_8	= @s2_8,	j8	= @j8	,
	q9  = @q9	,	s9  = @s9	,	s2_9	= @s2_9,	j9	= @j9	,
	q10 = @q10	,	s10 = @s10	,	s2_10	= @s2_10,	j10	= @j10	,
	q11 = @q11	,	s11 = @s11	,	s2_11	= @s2_11,	j11	= @j11	,
	q12 = @q12	,	s12 = @s12	,	s2_12	= @s2_12,	j12	= @j12	,
	q13 = @q13	,	s13 = @s13	,	s2_13	= @s2_13,	j13	= @j13	,
	q14 = @q14	,	s14 = @s14	,	s2_14	= @s2_14,	j14	= @j14	,
	q15 = @q15	,	s15 = @s15	,	s2_15	= @s2_15,	j15	= @j15	,
	q16 = @q16	,	s16 = @s16	,	s2_16	= @s2_16,	j16	= @j16	,
	q17 = @q17	,	s17 = @s17	,	s2_17	= @s2_17,	j17	= @j17	,
	q18 = @q18	,	s18 = @s18	,	s2_18	= @s2_18,	j18	= @j18	,
	q19 = @q19	,	s19 = @s19	,	s2_19	= @s2_19,	j19	= @j19	,
	q20 = @q20	,	s20 = @s20	,	s2_20	= @s2_20,	j20	= @j20	,
	q21 = @q21	,	s21 = @s21	,	s2_21	= @s2_21,	j21	= @j21	,
	q22 = @q22	,	s22 = @s22	,	s2_22	= @s2_22,	j22	= @j22	,
	q23 = @q23	,	s23 = @s23	,	s2_23	= @s2_23,	j23	= @j23	,
	q24 = @q24	,	s24 = @s24	,	s2_24	= @s2_24,	j24	= @j24	,
	q25 = @q25	,	s25 = @s25	,	s2_25	= @s2_25,	j25	= @j25	,
	q26 = @q26	,	s26 = @s26	,	s2_26	= @s2_26,	j26	= @j26
	WHERE char_id = @char_id
end
else
begin
	insert into quest (char_id,
	q1,	s1,	s2_1,	j1,
	q2,	s2,	s2_2,	j2,
	q3,	s3,	s2_3,	j3,
	q4,	s4,	s2_4,	j4,
	q5,	s5,	s2_5,	j5,
	q6,	s6,	s2_6,	j6,
	q7,	s7,	s2_7,	j7,
	q8,	s8,	s2_8,	j8,
	q9,	s9,	s2_9,	j9,
	q10,	s10,	s2_10,	j10,
	q11,	s11,	s2_11,	j11,
	q12,	s12,	s2_12,	j12,
	q13,	s13,	s2_13,	j13,
	q14,	s14,	s2_14,	j14,
	q15,	s15,	s2_15,	j15,
	q16,	s16,	s2_16,	j16,
	q17,	s17,	s2_17,	j17,
	q18,	s18,	s2_18,	j18,
	q19,	s19,	s2_19,	j19,
	q20,	s20,	s2_20,	j20,
	q21,	s21,	s2_21,	j21,
	q22,	s22,	s2_22,	j22,
	q23,	s23,	s2_23,	j23,
	q24,	s24,	s2_24,	j24,
	q25,	s25,	s2_25,	j25,
	q26,	s26,	s2_26,	j26)
	values (@char_id, 
	@q1	,	@s1	,	@s2_1,	@j1	,
	@q2	,	@s2	,	@s2_2,	@j2	,
	@q3	,	@s3	,	@s2_3,	@j3	,
	@q4	,	@s4	,	@s2_4,	@j4	,
	@q5	,	@s5	,	@s2_5,	@j5	,
	@q6	,	@s6	,	@s2_6,	@j6	,
	@q7	,	@s7	,	@s2_7,	@j7	,
	@q8	,	@s8	,	@s2_8,	@j8	,
	@q9	,	@s9	,	@s2_9,	@j9	,
	@q10	,	@s10	,	@s2_10,	@j10	,
	@q11	,	@s11	,	@s2_11,	@j11	,
	@q12	,	@s12	,	@s2_12,	@j12	,
	@q13	,	@s13	,	@s2_13, @j13	,
	@q14	,	@s14	,	@s2_14,	@j14	,
	@q15	,	@s15	,	@s2_15,	@j15	,
	@q16	,	@s16	,	@s2_16,	@j16	,
	@q17	,	@s17	,	@s2_17,	@j17	,
	@q18	,	@s18	,	@s2_18,	@j18	,
	@q19	,	@s19	,	@s2_19,	@j19	,
	@q20	,	@s20	,	@s2_20,	@j20	,
	@q21	,	@s21	,	@s2_21,	@j21	,
	@q22	,	@s22	,	@s2_22,	@j22	,
	@q23	,	@s23	,	@s2_23,	@j23	,
	@q24	,	@s24	,	@s2_24,	@j24	,
	@q25	,	@s25	,	@s2_25,	@j25	,
	@q26	,	@s26	,	@s2_26,	@j26)

end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetUserService]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_SetUserService]
	@char_id	int,
	@service_flag	int
as

if @service_flag = 0
	delete from user_service where char_id = @char_id
else
begin
	if exists (select * from user_service(nolock) where char_id = @char_id)
		update user_service set service_flag = @service_flag, reg_date = getdate() where char_id = @char_id
	else
		insert into user_service (char_id, service_flag) values (@char_id, @service_flag)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_journal]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_journal](
	[char_id] [int] NOT NULL,
	[type] [smallint] NOT NULL,
	[int_data_1] [int] NULL,
	[int_data_2] [int] NULL,
	[log_data] [smalldatetime] NOT NULL CONSTRAINT [DF_user_journal_log_data]  DEFAULT (getdate()),
	[play_time] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadQuest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadQuest  
   
INPUT  
 @char_id int  
OUTPUT  
return  
made by  
 carrot  
modified by ParkPD
date  
 2006-08-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadQuest]  
(  
@char_id int  
)  
AS  
SET NOCOUNT ON  
  
SELECT TOP 1  
	q1,	s1,	s2_1,	j1,	
	q2,	s2,	s2_2,	j2,	
	q3,	s3,	s2_3,	j3,	
	q4,	s4,	s2_4,	j4,	
	q5,	s5,	s2_5,	j5,	
	q6,	s6,	s2_6,	j6,	
	q7,	s7,	s2_7,	j7,	
	q8,	s8,	s2_8,	j8,	
	q9,	s9,	s2_9,	j9,	
	q10,	s10,	s2_10,	j10,
	q11,	s11,	s2_11,	j11,
	q12,	s12,	s2_12,	j12,
	q13,	s13,	s2_13,	j13,
	q14,	s14,	s2_14,	j14,
	q15,	s15,	s2_15,	j15,
	q16,	s16,	s2_16,	j16,
	q17,	s17,	s2_17,	j17,
	q18,	s18,	s2_18,	j18,
	q19,	s19,	s2_19,	j19,
	q20,	s20,	s2_20,	j20,
	q21,	s21,	s2_21,	j21,
	q22,	s22,	s2_22,	j22,
	q23,	s23,	s2_23,	j23,
	q24,	s24,	s2_24,	j24,
	q25,	s25,	s2_25,	j25,
	q26,	s26,	s2_26,	j26
FROM quest (nolock)   
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RegisterSiegeAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_RegisterSiegeAgitPledge]
(
	@agit_id INT,
	@pledge_id INT,
	@propose_time INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT

INSERT INTO siege_agit_pledge
(agit_id, pledge_id, propose_time)
VALUES
(@agit_id, @pledge_id, @propose_time)

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadMinigameAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_LoadMinigameAgitMember]
(
	@agit_id	int
)
as
set nocount on
select pledge_id, char_id from minigame_agit_member where agit_id=@agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveSSQSystemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**  
  * @procedure lin_SaveSSQSystemInfo  
  * @brief SSQ 시스템 정보 DB를 저장한다.  
  *  
  * @date 2004/11/26  
  * @author Seongeun Park  <sonai@ncsoft.net>  
  */  
CREATE PROCEDURE [dbo].[lin_SaveSSQSystemInfo]   
(  
@round_number INT,  
@status TINYINT,  
@winner TINYINT,  
@event_start_time INT,  
@event_end_time  INT,  
@seal_effect_time INT,  
@seal_effect_end_time INT,  
@seal1 TINYINT,  
@seal2 TINYINT,  
@seal3 TINYINT,  
@seal4 TINYINT,  
@seal5 TINYINT,  
@seal6 TINYINT,  
@seal7 TINYINT,  
@castle_snapshot_time INT,  
@can_drop_guard INT  
)  
AS  
  
SET NOCOUNT ON  
  
UPDATE ssq_data SET  status = @status,   
                                        winner = @winner,   
   event_start_time = @event_start_time,  
   event_end_time = @event_end_time,  
               seal_effect_time  =  @seal_effect_time,  
   seal_effect_end_time = @seal_effect_end_time,   
   seal1 = @seal1,  
   seal2 = @seal2,  
   seal3 = @seal3,  
   seal4 = @seal4,  
   seal5 = @seal5,  
   seal6 = @seal6,  
   seal7 = @seal7,  
   castle_snapshot_time = @castle_snapshot_time,  
               can_drop_guard = @can_drop_guard,  
   last_changed_time = GETDATE()  
                      WHERE round_number = @round_number

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoMinigameAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_InsertIntoMinigameAgitMember]
(
	@agit_id		int,
	@pledge_id	int,
	@char_id	int
)
as
set nocount on
insert into minigame_agit_member(agit_id, pledge_id, char_id) values (@agit_id, @pledge_id, @char_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetResidenceByIdType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetResidenceByIdType]
	@residence_id int,
	@type int
as
set nocount on

SELECT id, owner_id, residence_id, max_hp, hp, x_pos, y_pos, z_pos FROM object_data (nolock) WHERE residence_id = @residence_id AND type = @type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeletePledgeSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeletePledgeSkill]
	@pledge_id	int,
	@skill_id		int
AS

SET NOCOUNT ON

DELETE FROM pledge_skill
WHERE pledge_id = @pledge_id AND skill_id = @skill_id

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChallengeRejected]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ChallengeRejected    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_ChallengeRejected
	
INPUT	
	@challenger int, 
	@challenger_name nvarchar(50),
	@challengee int, 
	@challengee_name nvarchar(50),
	@begin_time int, 
	@status int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_ChallengeRejected]
(
	@challenger int, 
	@challenger_name nvarchar(50),
	@challengee int, 
	@challengee_name nvarchar(50),
	@begin_time int, 
	@status int
)
AS
SET NOCOUNT ON

INSERT INTO pledge_war (challenger, challenger_name,  challengee, challengee_name, begin_time, status) 
VALUES (@challenger, @challenger_name,  @challengee, @challengee_name, @begin_time, @status)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteSurrenderWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteSurrenderWar]( @war_id INT)  
AS  
  
SET NOCOUNT ON  
SELECT char_id FROM user_surrender WHERE surrender_war_id = @war_id  
DELETE FROM user_surrender WHERE surrender_war_id = @war_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WriteCastleTax]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************      
lin_WriteCastleTax      
       
INPUT      
OUTPUT      
return      
made by      
 carrot      
date      
 2002-06-10      
change carrot 2003-12-22    
 add tax_type, residence type to differentiate agit from castle    
change carrot 2004-02-29  
 add TaxRateToChange  
********************************************/      
CREATE PROCEDURE [dbo].[lin_WriteCastleTax]      
(      
 @nIsCastle int,    
 @tax_type int,      
 @tax_rate  int,      
 @to_change  int,      
 @residence_id  int      
)      
AS      
SET NOCOUNT ON      
    
IF(@nIsCastle = 1)    
BEGIN    
 IF (@tax_type = 2)    
  UPDATE castle SET tax_child_rate = @tax_rate, tax_child_rate_to_change = @to_change  WHERE id = @residence_id      
 ELSE IF (@tax_type = 1)    
  UPDATE castle SET tax_rate = @tax_rate, tax_rate_to_change = @to_change  WHERE id = @residence_id      
 ELSE    
  RAISERROR (''tax type is invalid. castle cannot save type[%d] id and castle id[%d].'', 16, 1, @tax_type, @residence_id )    
END    
ELSE IF(@nIsCastle = 0)    
BEGIN    
 IF (@tax_type = 2)    
BEGIN  
  UPDATE agit SET tax_child_rate = @tax_rate, tax_child_rate_to_change = @to_change  WHERE id = @residence_id      
END  
 ELSE IF (@tax_type = 1)    
  UPDATE agit SET tax_rate = @tax_rate, tax_rate_to_change = @to_change WHERE id = @residence_id      
 ELSE    
  RAISERROR (''tax type is invalid. agit cannot save type[%d] id and agit id[%d].'', 16, 1, @tax_type, @residence_id )    
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_last_color]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_last_color](
	[char_id] [int] NOT NULL,
	[color_index] [int] NOT NULL,
	[saved_time] [int] NULL,
 CONSTRAINT [PK_user_last_color_1] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FELoadStartTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_FELoadStartTime
	
OUTPUT
starttime

made by
	mgpark
date
	2006-01-16
********************************************/
CREATE PROCEDURE [dbo].[lin_FELoadStartTime]

AS
SET NOCOUNT ON

SELECT starttime FROM fishing_event_time

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteBlockList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_DeleteBlockList    
 delete character''s blocked list.    
INPUT    
 char_id,    
 target char_name    
OUTPUT    
return    
made by    
 carrot    
date    
 2003-12-01    
change    
********************************************/    
CREATE PROCEDURE [dbo].[lin_DeleteBlockList]    
(    
 @char_id INT,    
 @target_char_name NVARCHAR(50)    
)    
AS    
    
SET NOCOUNT ON    
    
DECLARE @target_char_id INT    
SET @target_char_id = 0    
  
SELECT @target_char_id = block_char_id FROM user_blocklist (nolock) WHERE char_id = @char_id and block_char_name = @target_char_name    
  
--SELECT @target_char_id = char_id FROM user_data WHERE char_name = @target_char_name    
    
IF @target_char_id > 0    
BEGIN    
 DELETE user_blocklist  WHERE char_id = @char_id AND block_char_id = @target_char_id    
 IF NOT @@ROWCOUNT = 1    
 BEGIN    
  RAISERROR (''Cannot find delete blocklist: char id = [%d], target name[%s]'', 16, 1, @char_id, @target_char_name)    
 END    
 ELSE    
 BEGIN    
  SELECT @target_char_id    
 END    
END    
ELSE    
BEGIN    
 RAISERROR (''Cannot find delete blocklist: char id = [%d], target naem[%s]'', 16, 1, @char_id, @target_char_name)    
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ssq_top_point_user]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ssq_top_point_user](
	[ssq_round] [int] NOT NULL,
	[record_id] [int] NOT NULL,
	[rank_time] [int] NOT NULL,
	[ssq_point] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[char_name] [nvarchar](50) NOT NULL,
	[ssq_part] [tinyint] NOT NULL,
	[ssq_position] [tinyint] NOT NULL,
	[seal_selection_no] [tinyint] NOT NULL,
	[last_changed_time] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetClass]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetClass]
(
@char_id AS INT,
@subjob_id AS INT,
@class AS INT
)
AS
SET NOCOUNT ON

IF @subjob_id = 0
	UPDATE user_data SET class = @class, subjob0_class = @class WHERE char_id = @char_id
ELSE IF @subjob_id = 1
	UPDATE user_data SET class = @class, subjob1_class = @class WHERE char_id = @char_id
ELSE IF @subjob_id = 2
	UPDATE user_data SET class = @class, subjob2_class = @class WHERE char_id = @char_id
ELSE IF @subjob_id = 3
	UPDATE user_data SET class = @class, subjob3_class = @class WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadFortressFacility]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadFortressFacility
   
INPUT   
 @fortress_id INT,
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-30  
********************************************/  

CREATE PROCEDURE [dbo].[lin_LoadFortressFacility]
(
	@fortress_id INT
)
AS
SET NOCOUNT ON
SELECT facility_type, facility_level FROM fortress_facility (nolock) WHERE fortress_id = @fortress_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteUserBookmarkSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_DeleteUserBookmarkSlot
desc:	delete user boolmark slot info.

history:	2008-03-25	created by tempted
*/

CREATE PROCEDURE [dbo].[lin_DeleteUserBookmarkSlot] 
(
	@char_id int,
	@slot_id int
)
AS

SET NOCOUNT ON

DELETE FROM user_bookmark
WHERE char_id = @char_id AND slot_id = @slot_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agit_deco]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[agit_deco](
	[agit_id] [int] NOT NULL,
	[type] [int] NOT NULL,
	[id] [int] NOT NULL,
	[name] [varchar](256) NULL,
	[level] [int] NULL,
	[expire] [int] NULL,
	[is_active] [int] NULL CONSTRAINT [DF_agit_deco_is_active]  DEFAULT ((1)),
 CONSTRAINT [PK_agit_deco] PRIMARY KEY CLUSTERED 
(
	[agit_id] ASC,
	[type] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SurrenderPledgeWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SurrenderPledgeWar    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_SurrenderPledgeWar
-- by bert

CREATE PROCEDURE
[dbo].[lin_SurrenderPledgeWar] (@proposer_pledge_id INT, @proposee_pledge_id INT, @war_id INT, @war_end_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

UPDATE Pledge_War
SET status = 2,	-- WAR_END_SURRENDER
winner = @proposee_pledge_id,
winner_name = (SELECT name FROM Pledge WHERE pledge_id = @proposee_pledge_id),
end_time = @war_end_time
WHERE
id = @war_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = @war_id
END
ELSE
BEGIN
	SELECT @ret = 0
END

IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dominion_siege]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dominion_siege](
	[siege_state] [int] NOT NULL,
	[prev_siege_end_time] [int] NOT NULL,
	[siege_elapsed_time] [int] NOT NULL,
	[next_siege_start_time] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_bossrecord_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_bossrecord_history](
	[round_number] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[point] [int] NOT NULL,
	[accumulated_point] [int] NOT NULL,
 CONSTRAINT [PK_user_bossrecord_history] PRIMARY KEY CLUSTERED 
(
	[round_number] ASC,
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bot_report]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[bot_report](
	[char_id] [int] NOT NULL,
	[reported] [int] NULL,
	[reported_date] [int] NULL,
	[bot_admin] [int] NULL,
 CONSTRAINT [PK_bot_report] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lotto_game]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[lotto_game](
	[round_number] [int] NOT NULL,
	[state] [int] NOT NULL,
	[left_time] [int] NOT NULL,
	[chosen_number_flag] [int] NOT NULL,
	[rule_number] [int] NOT NULL,
	[winner1_count] [int] NOT NULL,
	[winner2_count] [int] NOT NULL,
	[winner3_count] [int] NOT NULL,
	[winner4_count] [int] NOT NULL,
	[total_count] [int] NOT NULL,
	[carried_adena] [bigint] NOT NULL,
 CONSTRAINT [PK_lotto_game] PRIMARY KEY CLUSTERED 
(
	[round_number] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetResidenceByType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetResidenceByType]
	@type int
as
set nocount on

SELECT id, owner_id, residence_id, max_hp, hp, x_pos, y_pos, z_pos FROM object_data (nolock) WHERE type = @type

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_acc_race]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_acc_race](
	[race] [tinyint] NOT NULL,
	[count] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FESaveStartTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_FESaveStartTime
 INPUT            
 @nStartTime  INT            
OUTPUT            
return            
           
made by            
	mgpark
date            
 2006-01-16    

********************************************/            
CREATE PROCEDURE [dbo].[lin_FESaveStartTime]    
(            
 @nStartTime INT
)            
AS            
            
SET NOCOUNT ON            

IF (@nStartTime < 0)            
BEGIN            

   RETURN -1            
END            



IF EXISTS(SELECT * FROM  fishing_event_time)
BEGIN
	UPDATE  fishing_event_time SET starttime = @nStartTime
	
END
ELSE
BEGIN
	INSERT INTO fishing_event_time (starttime) 
	VALUES (@nStartTime)    	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateAgitIfNotExist]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_CreateAgitIfNotExist    Script Date: 2003-09-20 오전 11:51:58 ******/
CREATE PROCEDURE [dbo].[lin_CreateAgitIfNotExist]
(
	@agit_id	INT,
	@agit_name VARCHAR(50)
)
AS

SET NOCOUNT ON

INSERT INTO agit
(id, name)
VALUES (@agit_id, @agit_name)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetUI]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetUI
desc:	get ui information

history:	2007-05-28	created by neo
*/
CREATE   PROCEDURE [dbo].[lin_GetUI]
(
	@char_id		int
)
AS
SET NOCOUNT ON

SELECT ui_setting_size, ui_setting FROM user_ui (nolock) WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stat_item_ment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stat_item_ment](
	[item_type] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[char_name] [nvarchar](50) NOT NULL,
	[max_ent] [int] NOT NULL,
	[builder] [tinyint] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RegisterPeriodicItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_RegisterPeriodicItem]
	@item_id int,
	@start_time int,
	@period	int,
	@item_class_id int
as
set nocount on

INSERT INTO user_item_period (item_id, start_time, period, item_type) 
VALUES (@item_id, @start_time, @period, @item_class_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_deleted]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_deleted](
	[char_id] [int] NOT NULL,
	[delete_date] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertSkillName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_InsertSkillName    Script Date: 2003-09-20 오전 11:51:59 ******/

/********************************************
lin_InsertSkillName
	insert Skill name data
INPUT
	@id	INT,
	@lev 	INT,
	@name 	nvarchar(50)
	@skill_desc 	nvarchar(50),
	@magic_skill	INT,
	@activateType	nvarchar(5)
OUTPUT
return
made by
	carrot
date
	2002-10-8
********************************************/
CREATE PROCEDURE [dbo].[lin_InsertSkillName]
(
@id	INT,
@lev 	INT,
@name 	nvarchar(50),
@skill_desc 	nvarchar(50),
@magic_skill	INT,
@activateType	nvarchar(5)
)
AS
SET NOCOUNT ON


INSERT INTO skillData
	(id, lev, name, skill_desc, bIsMagic, activate_type) 
	values 
	(@id, @lev, @name, @skill_desc, @magic_skill, @activateType)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetFortressFacility]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SetFortressFacility
   
INPUT   
 @fortress_id INT,
 @facility_type INT,
 @facility_level INT

  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-30  
********************************************/  
CREATE PROCEDURE [dbo].[lin_SetFortressFacility]
(
	@fortress_id INT,
	@facility_type INT,
	@facility_level INT
)
AS
SET NOCOUNT ON

update fortress_facility
set facility_level = @facility_level
WHERE fortress_id = @fortress_id AND facility_type = @facility_type

if @@rowcount = 0
begin
	INSERT INTO fortress_facility
	(fortress_id, facility_type, facility_level)
	VALUES
	(@fortress_id, @facility_type, @facility_level)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_prohibit_word]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_prohibit_word](
	[words] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_user_prohibit_word] PRIMARY KEY CLUSTERED 
(
	[words] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_BONUS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_BONUS](
	[bonus_id] [bigint] IDENTITY(1,1) NOT NULL,
	[bonus_ip] [nvarchar](20) NOT NULL,
	[bonus_date] [datetime] NOT NULL CONSTRAINT [DF_A_BONUS_bonus_date]  DEFAULT (getdate()),
	[ref_id] [bigint] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveUserBookmarkSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveUserBookmarkSlot
desc:	save user boolmark slot info.

history:	2008-03-25	created by tempted
*/

CREATE PROCEDURE [dbo].[lin_SaveUserBookmarkSlot] 
(
	@char_id int,
	@slot_id int,
	@pos_x int,
	@pos_y int,
	@pos_z int,
	@icon_id int,
	@slot_title NVARCHAR(100),
	@icon_title NVARCHAR(100)
)
AS

SET NOCOUNT ON

UPDATE user_bookmark 
SET slot_id = @slot_id, pos_x = @pos_x, pos_y = @pos_y, pos_z = @pos_z, 
	icon_id = @icon_id,	slot_title = @slot_title, icon_title = @icon_title
WHERE char_id = @char_id and slot_id = @slot_id

IF @@rowcount = 0
BEGIN
	INSERT INTO user_bookmark (char_id, slot_id, pos_x, pos_y, pos_z, icon_id, slot_title, icon_title) 
	VALUES (@char_id, @slot_id, @pos_x, @pos_y, @pos_z, @icon_id, @slot_title, @icon_title)    	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GiveEventItemFromWeb]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GiveEventItemFromWeb]
	@db_info	nvarchar(128),	-- ''''''server'''';''''login_id'''';''''password''''''
	@world_id	int,
	@table_name	nvarchar(128),
	@item_type	int
as
set nocount on

declare @sql nvarchar(4000)
set @sql = ''declare''
	+ ''	@char_id	int,''
	+ ''	@account_id	int,''
	+ ''	@char_name	nvarchar(24)''
	+ ''''
	+ '' declare char_cursor cursor for''
	+ '' select uid, character from openrowset(''''sqloledb'''', ''+@db_info+'',''
	+ ''	''''select uid, character from L2EventDB.dbo.''+@table_name+'' where server = ''+cast(@world_id as nvarchar)+'''''')''
	+ '' open char_cursor''
	+ '' fetch next from char_cursor into @account_id, @char_name''
	+ ''''
	+ '' while @@fetch_status = 0''
	+ '' begin''
	+ ''	select @char_id = char_id from user_data(nolock) where account_id = @account_id and char_name = @char_name''
	+ ''	if @@rowcount > 0''
	+ ''	begin''
	+ ''		insert into user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)''
	+ ''		values (@char_id, ''+cast(@item_type as nvarchar)+'', 1, 0, 0, 0, 0, 1, 1)''
	+ ''	end''
	+ ''''
	+ ''	insert into EventItemFromWeb (account_id, char_id, char_name, item_type, from_table, result)''
	+ ''	values (@account_id, @char_id, @char_name, ''+cast(@item_type as nvarchar)+'', ''''''+@table_name+'''''', @@rowcount)''
	+ ''''
	+ ''	fetch next from char_cursor into @account_id, @char_name''	
	+ '' end''
	+ ''''
	+ '' close char_cursor''
	+ '' deallocate char_cursor''
exec (@sql)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadPledgeWar    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadPledgeWar
	
INPUT
	@war_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_LoadPledgeWar]
(
	@war_id		int
)
AS
SET NOCOUNT ON

SELECT challenger, challengee, begin_time, status FROM pledge_war (nolock)  WHERE id = @war_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApproveBattle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ApproveBattle    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_ApproveBattle
	
INPUT	
	@castle_id	int,
	@type	int
OUTPUT
	pledge_id, 
	name 
	type
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_ApproveBattle]
(
	@castle_id	int,
	@type	int
)
AS
SET NOCOUNT ON

SELECT 
	p.pledge_id, 
	p.name, 
	type 
FROM 
	pledge p (nolock), 
	castle_war cw (nolock) 
WHERE 
	p.pledge_id = cw.pledge_id 
	AND cw.castle_id = @castle_id
	AND cw.type <> @type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_writeBbsall]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_writeBbsall    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_writeBbsall]
(
	@title NVARCHAR(50), 
	@contents NVARCHAR(4000), 
	@writer NVARCHAR(50)
)
AS
insert into bbs_all (title, contents, writer) values (@title, @contents, @writer)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveObjectHp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SaveObjectHp    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SaveObjectHp
	
INPUT	
	@hp	int,
	@id	int
OUTPUT

return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_SaveObjectHp]
(
	@hp	int,
	@id	int
)
AS
SET NOCOUNT ON

UPDATE object_data SET hp = @hp WHERE id = @id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WithdrawAlliance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_WithdrawAlliance    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_WithdrawAlliance
-- by bert
-- return Result(0 if failed)

CREATE PROCEDURE
[dbo].[lin_WithdrawAlliance] (@alliance_id INT, @member_pledge_id INT, @alliance_withdraw_time INT)
AS

SET NOCOUNT ON

DECLARE @result INT

UPDATE pledge
SET alliance_id = 0, alliance_withdraw_time = @alliance_withdraw_time
WHERE pledge_id = @member_pledge_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @result = 1
END
ELSE
BEGIN
	SELECT @result = 0
END

SELECT @result

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveUI]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveUI
desc:	save ui information

history:	2007-05-28	created by neo
*/
CREATE  PROCEDURE [dbo].[lin_SaveUI]
(
	@char_id		int,
	@ui_setting_size                smallint,
	@ui_setting		varbinary(8000)
)
AS        
SET NOCOUNT ON

DECLARE @char_id_tmp int

UPDATE user_ui SET ui_setting_size = @ui_setting_size, ui_setting = @ui_setting WHERE char_id = @char_id

if @@rowcount = 0
begin
	INSERT INTO user_ui (char_id, ui_setting_size, ui_setting) VALUES(@char_id, @ui_setting_size, @ui_setting)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadNpcBoss]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadNpcBoss    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadNpcBoss
	
INPUT	
	@NPC_name	nvarchar(50)
OUTPUT
	alive, 
	hp, 
	mp, 
	pos_x, 
	pos_y, 
	pos_z, 
	time_low, 
	time_high 
	i0
return
made by
	carrot
date
	2002-06-16
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadNpcBoss]
(
	@NPC_name	nvarchar(50)
)
AS
SET NOCOUNT ON

select 
	alive,  hp,  mp, pos_x, pos_y, pos_z, time_low, time_high , i0
from 
	npc_boss  (nolock)  
where 
	npc_db_name = @NPC_name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[quest]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[quest](
	[char_id] [int] NOT NULL,
	[q1] [int] NOT NULL CONSTRAINT [DF_Quest_q1]  DEFAULT ((0)),
	[s1] [int] NULL CONSTRAINT [DF_Quest_s1]  DEFAULT ((0)),
	[q2] [int] NOT NULL CONSTRAINT [DF_Quest_q2]  DEFAULT ((0)),
	[s2] [int] NOT NULL CONSTRAINT [DF_Quest_s2]  DEFAULT ((0)),
	[q3] [int] NOT NULL CONSTRAINT [DF_Quest_q3]  DEFAULT ((0)),
	[s3] [int] NOT NULL CONSTRAINT [DF_Quest_s3]  DEFAULT ((0)),
	[q4] [int] NOT NULL CONSTRAINT [DF_Quest_q4]  DEFAULT ((0)),
	[s4] [int] NOT NULL CONSTRAINT [DF_Quest_s4]  DEFAULT ((0)),
	[q5] [int] NOT NULL CONSTRAINT [DF_Quest_q5]  DEFAULT ((0)),
	[s5] [int] NOT NULL CONSTRAINT [DF_Quest_s5]  DEFAULT ((0)),
	[q6] [int] NOT NULL CONSTRAINT [DF_Quest_q6]  DEFAULT ((0)),
	[s6] [int] NOT NULL CONSTRAINT [DF_Quest_s6]  DEFAULT ((0)),
	[q7] [int] NOT NULL CONSTRAINT [DF_Quest_q7]  DEFAULT ((0)),
	[s7] [int] NOT NULL CONSTRAINT [DF_Quest_s7]  DEFAULT ((0)),
	[q8] [int] NOT NULL CONSTRAINT [DF_Quest_q8]  DEFAULT ((0)),
	[s8] [int] NOT NULL CONSTRAINT [DF_Quest_s8]  DEFAULT ((0)),
	[q9] [int] NOT NULL CONSTRAINT [DF_Quest_q9]  DEFAULT ((0)),
	[s9] [int] NOT NULL CONSTRAINT [DF_Quest_s9]  DEFAULT ((0)),
	[q10] [int] NOT NULL CONSTRAINT [DF_Quest_q10]  DEFAULT ((0)),
	[s10] [int] NOT NULL CONSTRAINT [DF_Quest_s10]  DEFAULT ((0)),
	[q11] [int] NOT NULL CONSTRAINT [DF_Quest_q11]  DEFAULT ((0)),
	[s11] [int] NOT NULL CONSTRAINT [DF_Quest_s11]  DEFAULT ((0)),
	[q12] [int] NOT NULL CONSTRAINT [DF_Quest_q12]  DEFAULT ((0)),
	[s12] [int] NOT NULL CONSTRAINT [DF_Quest_s12]  DEFAULT ((0)),
	[q13] [int] NOT NULL CONSTRAINT [DF_Quest_q13]  DEFAULT ((0)),
	[s13] [int] NOT NULL CONSTRAINT [DF_Quest_s13]  DEFAULT ((0)),
	[q14] [int] NOT NULL CONSTRAINT [DF_Quest_q14]  DEFAULT ((0)),
	[s14] [int] NOT NULL CONSTRAINT [DF_Quest_s14]  DEFAULT ((0)),
	[q15] [int] NOT NULL CONSTRAINT [DF_Quest_q15]  DEFAULT ((0)),
	[s15] [int] NOT NULL CONSTRAINT [DF_Quest_s15]  DEFAULT ((0)),
	[q16] [int] NOT NULL CONSTRAINT [DF_Quest_q16]  DEFAULT ((0)),
	[s16] [int] NOT NULL CONSTRAINT [DF_Quest_s16]  DEFAULT ((0)),
	[j1] [int] NOT NULL CONSTRAINT [DF_Quest_j1]  DEFAULT ((0)),
	[j2] [int] NOT NULL CONSTRAINT [DF_Quest_j2]  DEFAULT ((0)),
	[j3] [int] NOT NULL CONSTRAINT [DF_Quest_j3]  DEFAULT ((0)),
	[j4] [int] NOT NULL CONSTRAINT [DF_Quest_j4]  DEFAULT ((0)),
	[j5] [int] NOT NULL CONSTRAINT [DF_Quest_j5]  DEFAULT ((0)),
	[j6] [int] NOT NULL CONSTRAINT [DF_Quest_j6]  DEFAULT ((0)),
	[j7] [int] NOT NULL CONSTRAINT [DF_Quest_j7]  DEFAULT ((0)),
	[j8] [int] NOT NULL CONSTRAINT [DF_Quest_j8]  DEFAULT ((0)),
	[j9] [int] NOT NULL CONSTRAINT [DF_Quest_j9]  DEFAULT ((0)),
	[j10] [int] NOT NULL CONSTRAINT [DF_Quest_j10]  DEFAULT ((0)),
	[j11] [int] NOT NULL CONSTRAINT [DF_Quest_j11]  DEFAULT ((0)),
	[j12] [int] NOT NULL CONSTRAINT [DF_Quest_j12]  DEFAULT ((0)),
	[j13] [int] NOT NULL CONSTRAINT [DF_Quest_j13]  DEFAULT ((0)),
	[j14] [int] NOT NULL CONSTRAINT [DF_Quest_j14]  DEFAULT ((0)),
	[j15] [int] NOT NULL CONSTRAINT [DF_Quest_j15]  DEFAULT ((0)),
	[j16] [int] NOT NULL CONSTRAINT [DF_Quest_j16]  DEFAULT ((0)),
	[s2_1] [int] NULL CONSTRAINT [DF_QUEST_S2_1]  DEFAULT ((0)),
	[s2_2] [int] NULL CONSTRAINT [DF_QUEST_S2_2]  DEFAULT ((0)),
	[s2_3] [int] NULL CONSTRAINT [DF_QUEST_S2_3]  DEFAULT ((0)),
	[s2_4] [int] NULL CONSTRAINT [DF_QUEST_S2_4]  DEFAULT ((0)),
	[s2_5] [int] NULL CONSTRAINT [DF_QUEST_S2_5]  DEFAULT ((0)),
	[s2_6] [int] NULL CONSTRAINT [DF_QUEST_S2_6]  DEFAULT ((0)),
	[s2_7] [int] NULL CONSTRAINT [DF_QUEST_S2_7]  DEFAULT ((0)),
	[s2_8] [int] NULL CONSTRAINT [DF_QUEST_S2_8]  DEFAULT ((0)),
	[s2_9] [int] NULL CONSTRAINT [DF_QUEST_S2_9]  DEFAULT ((0)),
	[s2_10] [int] NULL CONSTRAINT [DF_QUEST_S2_10]  DEFAULT ((0)),
	[s2_11] [int] NULL CONSTRAINT [DF_QUEST_S2_11]  DEFAULT ((0)),
	[s2_12] [int] NULL CONSTRAINT [DF_QUEST_S2_12]  DEFAULT ((0)),
	[s2_13] [int] NULL CONSTRAINT [DF_QUEST_S2_13]  DEFAULT ((0)),
	[s2_14] [int] NULL CONSTRAINT [DF_QUEST_S2_14]  DEFAULT ((0)),
	[s2_15] [int] NULL CONSTRAINT [DF_QUEST_S2_15]  DEFAULT ((0)),
	[s2_16] [int] NULL CONSTRAINT [DF_QUEST_S2_16]  DEFAULT ((0)),
	[q17] [int] NOT NULL CONSTRAINT [DF__Quest__q17__3B97699F]  DEFAULT ((0)),
	[q18] [int] NOT NULL CONSTRAINT [DF__Quest__q18__3C8B8DD8]  DEFAULT ((0)),
	[q19] [int] NOT NULL CONSTRAINT [DF__Quest__q19__3D7FB211]  DEFAULT ((0)),
	[q20] [int] NOT NULL CONSTRAINT [DF__Quest__q20__3E73D64A]  DEFAULT ((0)),
	[q21] [int] NOT NULL CONSTRAINT [DF__Quest__q21__3F67FA83]  DEFAULT ((0)),
	[q22] [int] NOT NULL CONSTRAINT [DF__Quest__q22__405C1EBC]  DEFAULT ((0)),
	[q23] [int] NOT NULL CONSTRAINT [DF__Quest__q23__415042F5]  DEFAULT ((0)),
	[q24] [int] NOT NULL CONSTRAINT [DF__Quest__q24__4244672E]  DEFAULT ((0)),
	[q25] [int] NOT NULL CONSTRAINT [DF__Quest__q25__43388B67]  DEFAULT ((0)),
	[q26] [int] NOT NULL CONSTRAINT [DF__Quest__q26__442CAFA0]  DEFAULT ((0)),
	[s17] [int] NOT NULL CONSTRAINT [DF__Quest__s17__4520D3D9]  DEFAULT ((0)),
	[s18] [int] NOT NULL CONSTRAINT [DF__Quest__s18__4614F812]  DEFAULT ((0)),
	[s19] [int] NOT NULL CONSTRAINT [DF__Quest__s19__47091C4B]  DEFAULT ((0)),
	[s20] [int] NOT NULL CONSTRAINT [DF__Quest__s20__47FD4084]  DEFAULT ((0)),
	[s21] [int] NOT NULL CONSTRAINT [DF__Quest__s21__48F164BD]  DEFAULT ((0)),
	[s22] [int] NOT NULL CONSTRAINT [DF__Quest__s22__49E588F6]  DEFAULT ((0)),
	[s23] [int] NOT NULL CONSTRAINT [DF__Quest__s23__4AD9AD2F]  DEFAULT ((0)),
	[s24] [int] NOT NULL CONSTRAINT [DF__Quest__s24__4BCDD168]  DEFAULT ((0)),
	[s25] [int] NOT NULL CONSTRAINT [DF__Quest__s25__4CC1F5A1]  DEFAULT ((0)),
	[s26] [int] NOT NULL CONSTRAINT [DF__Quest__s26__4DB619DA]  DEFAULT ((0)),
	[s2_17] [int] NOT NULL CONSTRAINT [DF__Quest__s2_17__4EAA3E13]  DEFAULT ((0)),
	[s2_18] [int] NOT NULL CONSTRAINT [DF__Quest__s2_18__4F9E624C]  DEFAULT ((0)),
	[s2_19] [int] NOT NULL CONSTRAINT [DF__Quest__s2_19__50928685]  DEFAULT ((0)),
	[s2_20] [int] NOT NULL CONSTRAINT [DF__Quest__s2_20__5186AABE]  DEFAULT ((0)),
	[s2_21] [int] NOT NULL CONSTRAINT [DF__Quest__s2_21__527ACEF7]  DEFAULT ((0)),
	[s2_22] [int] NOT NULL CONSTRAINT [DF__Quest__s2_22__536EF330]  DEFAULT ((0)),
	[s2_23] [int] NOT NULL CONSTRAINT [DF__Quest__s2_23__54631769]  DEFAULT ((0)),
	[s2_24] [int] NOT NULL CONSTRAINT [DF__Quest__s2_24__55573BA2]  DEFAULT ((0)),
	[s2_25] [int] NOT NULL CONSTRAINT [DF__Quest__s2_25__564B5FDB]  DEFAULT ((0)),
	[s2_26] [int] NOT NULL CONSTRAINT [DF__Quest__s2_26__573F8414]  DEFAULT ((0)),
	[j17] [int] NOT NULL CONSTRAINT [DF__Quest__j17__5833A84D]  DEFAULT ((0)),
	[j18] [int] NOT NULL CONSTRAINT [DF__Quest__j18__5927CC86]  DEFAULT ((0)),
	[j19] [int] NOT NULL CONSTRAINT [DF__Quest__j19__5A1BF0BF]  DEFAULT ((0)),
	[j20] [int] NOT NULL CONSTRAINT [DF__Quest__j20__5B1014F8]  DEFAULT ((0)),
	[j21] [int] NOT NULL CONSTRAINT [DF__Quest__j21__5C043931]  DEFAULT ((0)),
	[j22] [int] NOT NULL CONSTRAINT [DF__Quest__j22__5CF85D6A]  DEFAULT ((0)),
	[j23] [int] NOT NULL CONSTRAINT [DF__Quest__j23__5DEC81A3]  DEFAULT ((0)),
	[j24] [int] NOT NULL CONSTRAINT [DF__Quest__j24__5EE0A5DC]  DEFAULT ((0)),
	[j25] [int] NOT NULL CONSTRAINT [DF__Quest__j25__5FD4CA15]  DEFAULT ((0)),
	[j26] [int] NOT NULL CONSTRAINT [DF__Quest__j26__60C8EE4E]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[quest]') AND name = N'IX_Quest')
CREATE UNIQUE NONCLUSTERED INDEX [IX_Quest] ON [dbo].[quest] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModItemPeriod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModItemPeriod
	modify period of period item
INPUT
	@item_id int,
	@newPeriod	int
OUTPUT
return
made by
	choanari for L2Admin
date
	2008-07-03
********************************************/
CREATE PROCEDURE [dbo].[lin_ModItemPeriod]
(
	@item_id	int,
	@newPeriod	int
)
AS
SET NOCOUNT ON

UPDATE
	user_item_period
SET
	period = @newPeriod
WHERE item_id = @item_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MakeBBSBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_MakeBBSBoard    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_MakeBBSBoard
	Make BBS board
INPUT
	@board_name	nvarchar(20),
	@board_desc	nvarchar(50)
OUTPUT

return
made by
	young
date
	2002-10-16
********************************************/
CREATE PROCEDURE [dbo].[lin_MakeBBSBoard]
(
	@board_name	nvarchar(20),
	@board_desc	nvarchar(50)
)
AS

set nocount on

declare @ncount int
declare @table_name nvarchar(20)
declare @exec nvarchar(500)

set @table_name = ''bbs_'' + @board_name

select @ncount = count(*) from sysobjects (nolock) where name = @table_name
select @ncount
if @ncount = 0
begin

	set @exec = ''CREATE TABLE dbo.'' + @table_name + ''('' + char(13)
	set @exec = @exec + '' id int IDENTITY (1,1) NOT NULL, '' + char(13)
	set @exec = @exec + '' title nvarchar(100) NULL, '' + char(13)
	set @exec = @exec + '' contents nvarchar(3000) NULL, '' + char(13)
	set @exec = @exec + '' writer nvarchar(50) NULL, '' + char(13)
	set @exec = @exec + '' cdate datetime NOT NULL, '' + char(13)
	set @exec = @exec + '' nread int NOT NULL)  '' + char(13)
	exec (@exec)
	set @exec = ''ALTER TABLE dbo.'' + @table_name + '' WITH NOCHECK ADD'' + char(13)
	set @exec = @exec + ''CONSTRAINT PK_'' + @table_name + '' PRIMARY KEY CLUSTERED'' + char(13)
	set @exec = @exec + ''( '' + char(13)
	set @exec = @exec + ''id '' + char(13)
	set @exec = @exec + '')'' + char(13)
	exec (@exec)
	set @exec = ''ALTER TABLE dbo.'' + @table_name + '' WITH NOCHECK ADD'' + char(13)
	set @exec = @exec + ''CONSTRAINT DF_'' + @table_name + ''_cdate DEFAULT getdate() FOR cdate, '' + char(13)
	set @exec = @exec + ''CONSTRAINT DF_'' + @table_name + ''_nread DEFAULT 0 FOR nread '' + char(13)
	exec (@exec)

	insert into bbs_board(board_name, board_desc) values(@table_name, @board_desc)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_item_deleted]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_item_deleted](
	[item_id] [int] NOT NULL,
	[char_id] [int] NOT NULL,
	[item_type] [int] NOT NULL,
	[amount] [bigint] NOT NULL,
	[enchant] [int] NOT NULL,
	[eroded] [int] NOT NULL,
	[bless] [tinyint] NOT NULL,
	[ident] [int] NOT NULL,
	[wished] [int] NOT NULL,
	[warehouse] [int] NOT NULL,
	[variation_opt1] [int] NULL,
	[variation_opt2] [int] NOT NULL,
	[intensive_item_type] [int] NOT NULL,
	[inventory_slot_index] [int] NULL,
	[isRestored] [int] NOT NULL CONSTRAINT [DF_user_item_deleted_isRestored]  DEFAULT ((0)),
 CONSTRAINT [PK_user_item_deleted] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_item_deleted]') AND name = N'IX_user_item_deleted')
CREATE NONCLUSTERED INDEX [IX_user_item_deleted] ON [dbo].[user_item_deleted] 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'item_unique_id' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'item_id'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'소유 캐릭터 id' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'char_id'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'item_type' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'item_type'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'수량' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'amount'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'enchant' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'enchant'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'eroded' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'eroded'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'bless' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'bless'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ident' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'ident'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'wished' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'wished'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'warehouse' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'warehouse'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'제련1' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'variation_opt1'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'제련2' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'variation_opt2'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'광물' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'intensive_item_type'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'inventory_slot_index' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'user_item_deleted', @level2type=N'COLUMN', @level2name=N'inventory_slot_index'

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[war_declare]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[war_declare](
	[challenger] [int] NOT NULL,
	[challengee] [int] NOT NULL,
	[declare_time] [int] NOT NULL,
 CONSTRAINT [PK_war_declare] PRIMARY KEY CLUSTERED 
(
	[challenger] ASC,
	[challengee] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[subpledge_skill]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[subpledge_skill](
	[pledge_id] [int] NOT NULL,
	[pledge_type] [int] NOT NULL,
	[skill_id] [int] NOT NULL,
	[skill_lev] [tinyint] NOT NULL,
 CONSTRAINT [PK_subpledge_skill] PRIMARY KEY CLUSTERED 
(
	[pledge_id] ASC,
	[pledge_type] ASC,
	[skill_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[item_market_price]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[item_market_price](
	[item_type] [int] NOT NULL,
	[enchant] [int] NOT NULL,
	[avg_price] [float] NOT NULL,
	[frequency] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[A_TOP_BONUS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[A_TOP_BONUS](
	[BID] [bigint] IDENTITY(1,1) NOT NULL,
	[IP] [nvarchar](20) NOT NULL,
	[ACCOUNT] [nvarchar](20) NOT NULL,
	[TIME] [datetime] NOT NULL,
	[NICK] [nvarchar](20) NOT NULL,
	[TOCHAR] [nvarchar](20) NOT NULL,
	[AMOUNT] [bigint] NOT NULL CONSTRAINT [DF_A_TOP_BONUS_AMOUNT]  DEFAULT ((0)),
	[ITEM_TYPE] [bigint] NOT NULL CONSTRAINT [DF_A_TOP_BONUS_ITEM_TYPE]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[event_point]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[event_point](
	[point_id] [int] IDENTITY(1,1) NOT NULL,
	[group_id] [int] NULL,
	[group_point] [float] NULL CONSTRAINT [DF_event_point_group_point]  DEFAULT ((0.0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[event_point]') AND name = N'IX_event_point')
CREATE CLUSTERED INDEX [IX_event_point] ON [dbo].[event_point] 
(
	[group_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveHenna]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveHenna]
(        
@char_id INT,
@henna_1 INT,
@henna_2 INT,
@henna_3 INT
)        
AS  
SET NOCOUNT ON        

IF EXISTS(SELECT * FROM user_henna WHERE char_id = @char_id)
BEGIN
	UPDATE user_henna SET henna_1 = @henna_1, henna_2 = @henna_2, henna_3 = @henna_3 
	WHERE char_id = @char_id
END
ELSE
BEGIN
	INSERT INTO user_henna (char_id, henna_1, henna_2, henna_3)
	VALUES (@char_id, @henna_1, @henna_2, @henna_3)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_punish]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_punish](
	[char_id] [int] NOT NULL,
	[punish_id] [int] NOT NULL,
	[punish_on] [tinyint] NOT NULL CONSTRAINT [DF_user_punish_punish_on]  DEFAULT ((0)),
	[remain_game] [int] NULL,
	[remain_real] [int] NULL,
	[punish_seconds] [int] NULL,
	[punish_date] [datetime] NULL CONSTRAINT [DF_user_punish_punish_date]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_punish]') AND name = N'IX_user_punish')
CREATE NONCLUSTERED INDEX [IX_user_punish] ON [dbo].[user_punish] 
(
	[char_id] ASC,
	[punish_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CancelWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CancelWar]
(
@challenger INT,
@challengee INT
)
AS
SET NOCOUNT ON

DELETE FROM war_declare
WHERE challenger = @challenger AND challengee = @challengee

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cursed_weapon]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[cursed_weapon](
	[item_id] [int] NOT NULL,
	[create_date] [int] NOT NULL CONSTRAINT [DF__cursed_we__creat__6FAB3F2B]  DEFAULT ((0)),
	[last_kill_date] [int] NOT NULL CONSTRAINT [DF__cursed_we__last___709F6364]  DEFAULT ((0)),
	[expired_date] [int] NOT NULL,
	[kill_point] [float] NOT NULL CONSTRAINT [DF__cursed_we__kill___7193879D]  DEFAULT ((0)),
	[char_id] [int] NOT NULL,
	[item_class_id] [int] NOT NULL,
	[original_pk] [int] NOT NULL,
	[total_pk] [int] NULL CONSTRAINT [DF__cursed_we__total__7287ABD6]  DEFAULT ((0)),
 CONSTRAINT [PK_cursed_weapon] PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetFortressFacility]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_ResetFortressFacility
   
INPUT   
 @fortress_id INT,
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-30  
********************************************/  
CREATE PROCEDURE [dbo].[lin_ResetFortressFacility]
(
	@fortress_id INT
)
AS
SET NOCOUNT ON
DELETE FROM fortress_facility
WHERE fortress_id = @fortress_id
SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDominion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadDominion]  
(  
	@dominion_id int
)  
AS  
SET NOCOUNT ON  
  
SELECT	dominion_status, residence_status
FROM	dominion(nolock)
WHERE	dominion_id = @dominion_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[req_charmove]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[req_charmove](
	[old_char_name] [nvarchar](50) NOT NULL,
	[old_char_id] [int] NULL,
	[account_name] [nvarchar](50) NOT NULL,
	[account_id] [int] NULL,
	[old_world_id] [int] NULL,
	[req_date] [datetime] NULL,
	[req_id] [int] NOT NULL,
	[new_world_id] [int] NULL,
	[new_char_name] [nvarchar](50) NULL,
	[new_char_id] [int] NULL,
	[is_pc_bang] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_rim_point]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_rim_point](
	[char_id] [int] NOT NULL,
	[point] [int] NOT NULL,
	[log_time] [int] NOT NULL,
 CONSTRAINT [PK_user_rim_point] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBlockCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetBlockCount
	get block count
INPUT
	@char_id		int,
	@block_target_id		int
OUTPUT
return
made by
	kks
date
	2004-12-23
********************************************/
CREATE PROCEDURE [dbo].[lin_GetBlockCount]
(
	@char_id		int,
	@block_target_id	int
)
AS
SET NOCOUNT ON

SELECT COUNT(*)
FROM user_blocklist(NOLOCK)
WHERE char_id = @block_target_id
	AND block_char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPetItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadPetItems    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadPetItems
	Load item data from pet inventory
INPUT
	@pet_id 	INT
OUTPUT
	item_id, item_type, amount, enchant, eroded, bless, ident, wished
return
made by
	kuooo
date
	2003-08-25
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPetItems]
(
	@pet_id 	INT
)
AS

SELECT  
        ui.item_id, ui.item_type, ui.amount, ui.enchant, ui.eroded, ui.bless, ui.ident, ui.wished, 
        isnull(ui.variation_opt1, 0), 
        isnull(ui.variation_opt2, 0), 
        isnull(uia.attack_attribute_type, -2), 
        isnull(uia.attack_attribute_value, 0), 
        isnull(uia.defend_attribute_0, 0), 
        isnull(uia.defend_attribute_1, 0), 
        isnull(uia.defend_attribute_2, 0), 
        isnull(uia.defend_attribute_3, 0), 
        isnull(uia.defend_attribute_4, 0), 
        isnull(uia.defend_attribute_5, 0) 
FROM (select * from user_item (nolock) where char_id = @pet_id AND warehouse = 5) ui 
        left join (select * from user_item_attribute) uia on ui.item_id = uia.item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllCastle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAllCastle    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadAllCastle
	
INPUT
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_LoadAllCastle]
--(
--	@tax_rate		int,
--	@castle_id		int
--)
AS
SET NOCOUNT ON

SELECT castle_d.id, castle_d.pledge_id, castle_d.next_war_time, castle_d.tax_rate, (select char_name from user_data where char_id = p.ruler_id)
FROM 
	(select * from castle (nolock) where type= 1) as castle_d
	inner join
	(select * from pledge (nolock) where pledge_id in (select pledge_id from castle)) as p
	on 
	castle_d.pledge_id = p.pledge_id
ORDER BY castle_d.id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateAirShip]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreateAirShip]
	@airship_type int,
	@owner_id int,
	@fuel int,
	@airship_typeid int
AS
SET NOCOUNT ON

DECLARE @airship_id int
SET @airship_id = 0

INSERT INTO airship (airship_type, owner_id, airship_fuel, airship_typeid, deleted) 
VALUES (@airship_type, @owner_id, @fuel, @airship_typeid, 0)

IF (@@error = 0)
BEGIN
	SET @airship_id = @@identity
END

SELECT @airship_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadUserBookmark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadUserBookmark
desc:	load user bookmark slot info.

history:	2008-03-25	created by tempted
*/
create procedure [dbo].[lin_LoadUserBookmark]
	@char_id int
as

set nocount on

SELECT slot_id, pos_x, pos_y, pos_z, icon_id, slot_title, icon_title 
FROM user_bookmark
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdatePledgeNameValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpdatePledgeNameValue
	update pledge name value
INPUT
	@pledge_id INT,
	@delta 	INT	
OUTPUT
	
return
made by
	kks
date
	2006-03-08
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdatePledgeNameValue]
(
	@pledge_id INT,
	@delta 	INT	
)

AS

SET NOCOUNT ON

UPDATE
	pledge
SET
	root_name_value = root_name_value + @delta
WHERE
	pledge_id = @pledge_id

SELECT 
	root_name_value
FROM
	pledge
WHERE
	pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RegisterAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************************
#Name:	lin_RegisterAccount
#Desc:	add account to account_ch2 table

#Argument:
	Input:	@account_name	VARCHAR(50)
	Output:
#Return:
#Result Set:

#Remark:
#Example:
#See:
#History:
	Create	btwinuni	2005-09-12
******************************************************************************/
CREATE PROCEDURE [dbo].[lin_RegisterAccount]
(
	@account_name	nvarchar(50)
)
AS

SET NOCOUNT ON

-- if there is not account_ch2 table, end procedure
if not exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[account_ch2]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)
begin
	return
end

-- account duplication check
if not exists (select * from account_ch2 where account = @account_name)
begin
	insert into account_ch2 values (@account_name)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fishing_event_record]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[fishing_event_record](
	[char_id] [int] NULL,
	[length] [int] NULL,
	[isrewardtime] [int] NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCastleIncome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************      
lin_SaveCastleIncome      
       
INPUT       
 @crop_income int,      
 @shop_income int,      
 @castle_id int      
OUTPUT      
return      
made by      
 carrot      
date      
 2002-06-16      
change 2003-12-22 carrot    
 add about agit income    
change 2004-03-02 carrot    
 add taxincomeTemp   
 ********************************************/      
create PROCEDURE [dbo].[lin_SaveCastleIncome]      
(      
 @crop_income bigint,      
 @shop_income bigint,      
 @castle_id int  ,    
 @crop_income_temp bigint,      
 @is_castle int    
)      
AS      
SET NOCOUNT ON      
      
if (@is_castle = 1) -- castle    
 UPDATE castle SET crop_income = @crop_income, shop_income = @shop_income, shop_income_temp = @crop_income_temp WHERE id = @castle_id      
else -- agit    
 UPDATE agit SET shop_income = @shop_income, shop_income_temp = @crop_income_temp WHERE id = @castle_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[req_char]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[req_char](
	[server_id] [int] NULL,
	[char_name] [nvarchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mercenary]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[mercenary](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[residence_id] [int] NOT NULL,
	[npc_id] [int] NOT NULL,
	[x] [int] NOT NULL,
	[y] [int] NOT NULL,
	[z] [int] NOT NULL,
	[angle] [int] NOT NULL,
	[hp] [int] NOT NULL,
	[mp] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateCastleWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UpdateCastleWar    Script Date: 2003-09-20 오전 11:52:00 ******/
-- lin_UpdateCastleWar
-- by bert ( -_-)/

CREATE PROCEDURE
[dbo].[lin_UpdateCastleWar] (@castle_id INT, @pledge_id INT, @status INT)
AS
SET NOCOUNT ON

UPDATE castle_war
SET type = @status
WHERE castle_id = @castle_id AND pledge_id = @pledge_id

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InstallBattleCamp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_InstallBattleCamp    Script Date: 2003-09-20 오전 11:51:59 ******/
-- lin_InstallBattleCamp
-- by bert
-- return new battle camp id

CREATE PROCEDURE [dbo].[lin_InstallBattleCamp] (@pledge_id INT, @castle_id INT, @max_hp INT, @hp INT, @x INT, @y INT, @z INT, @type INT)
AS

SET NOCOUNT ON

INSERT INTO object_data
(owner_id, residence_id, max_hp, hp, x_pos, y_pos, z_pos, type)
VALUES 
(@pledge_id, @castle_id, @max_hp, @hp, @x, @y, @z, @type)

SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPVPPointRestrain]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadPVPPointRestrain
desc:	load user point
exam:	exec lin_LoadPVPPointRestrain
history:	2008-02-25	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_LoadPVPPointRestrain] 
(
	@char_id int
)
AS

SET NOCOUNT ON

SELECT give_count, give_time  FROM user_pvppoint_restrain (nolock)  WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllAllianceWarData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadAllAllianceWarData
	
INPUT	
	@status	int
OUTPUT
	id, 
	begin_time, 
	challenger, 
	challengee 
return
made by
	bert
date
	2003-11-07
********************************************/
create PROCEDURE [dbo].[lin_LoadAllAllianceWarData]
(
	@status	int
)
AS
SET NOCOUNT ON

SELECT 
	id, begin_time, challenger, challengee 
FROM 
	alliance_war (nolock)  
WHERE 
	status = @status

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetWarDeclare]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetWarDeclare]
AS
SELECT challenger, challengee, declare_time FROM war_declare WHERE challenger IN (SELECT pledge_id FROM pledge) AND challengee IN (SELECT pledge_id FROM pledge)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_bossrecord]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_bossrecord](
	[char_id] [int] NOT NULL,
	[npc_class_id] [int] NOT NULL,
	[point] [int] NOT NULL,
	[accumulated_point] [int] NOT NULL,
 CONSTRAINT [PK_user_bossrecord] PRIMARY KEY CLUSTERED 
(
	[char_id] ASC,
	[npc_class_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveNpcBoss]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SaveNpcBoss 
	
INPUT
OUTPUT
return
made by
date
********************************************/
CREATE PROCEDURE [dbo].[lin_SaveNpcBoss]
(
@npc_db_name	nvarchar(50),
@alive		INT,
@hp 		INT,
@mp 		INT,
@pos_x 		INT,
@pos_y 		INT,
@pos_z 		INT,
@time_low 	INT,
@time_high	INT
)
AS
SET NOCOUNT ON

update npc_boss 
set
	alive=@alive, hp=@hp, mp=@mp, pos_x=@pos_x, pos_y=@pos_y, pos_z=@pos_z, time_low=@time_low, time_high=@time_high
where npc_db_name = @npc_db_name

if @@rowcount = 0
begin
	insert into npc_boss values 
	(@npc_db_name, @alive, @hp,@mp, @pos_x, @pos_y,@pos_z, @time_low, @time_high, 0)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RemoveExpiredPeriodicItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_RemoveExpiredPeriodicItem]
	@item_id int
as
set nocount on

DELETE FROM user_item_period WHERE item_id = @item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SkillData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SkillData](
	[id] [int] NOT NULL,
	[lev] [smallint] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[logdate] [smalldatetime] NOT NULL CONSTRAINT [DF_SkillData_logdate]  DEFAULT (getdate()),
	[skill_desc] [nvarchar](255) NULL,
	[bIsMagic] [tinyint] NULL,
	[activate_type] [nvarchar](5) NULL,
 CONSTRAINT [PK_SkillData] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[lev] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SkillData]') AND name = N'IX_name')
CREATE NONCLUSTERED INDEX [IX_name] ON [dbo].[SkillData] 
(
	[name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monrace_ticket]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[monrace_ticket](
	[ticket_id] [int] IDENTITY(1,1) NOT NULL,
	[monraceid] [int] NULL,
	[bet_type] [smallint] NULL CONSTRAINT [DF_monrace_ticket_bet_type]  DEFAULT ((0)),
	[bet_1] [smallint] NULL CONSTRAINT [DF_monrace_ticket_bet_1]  DEFAULT ((0)),
	[bet_2] [smallint] NULL CONSTRAINT [DF_monrace_ticket_bet_2]  DEFAULT ((0)),
	[bet_3] [smallint] NULL,
	[bet_money] [bigint] NULL,
	[item_id] [int] NULL,
	[tax_money] [bigint] NULL CONSTRAINT [DF_monrace_ticket_tax_money]  DEFAULT ((0)),
	[deleted] [int] NULL CONSTRAINT [DF_monrace_ticket_deleted]  DEFAULT ((0)),
	[remotefee] [bigint] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[monrace_ticket]') AND name = N'IX_monrace_ticket_1')
CREATE CLUSTERED INDEX [IX_monrace_ticket_1] ON [dbo].[monrace_ticket] 
(
	[monraceid] ASC,
	[bet_type] ASC,
	[bet_1] ASC,
	[bet_2] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[monrace_ticket]') AND name = N'IX_monrace_ticket')
CREATE NONCLUSTERED INDEX [IX_monrace_ticket] ON [dbo].[monrace_ticket] 
(
	[item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadHenna]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadHenna]
(        
@char_id INT)        
AS    
SET NOCOUNT ON        

SELECT  henna_1, henna_2, henna_3 FROM user_henna WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reward_for_bossrecord]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[reward_for_bossrecord](
	[round_number] [int] NULL,
	[reward_date] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteBBSBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeleteBBSBoard    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_DeleteBBSBoard
	Delete BBS board
INPUT
	@board_name	nvarchar(20)
OUTPUT

return
made by
	young
date
	2002-10-16
********************************************/
CREATE PROCEDURE [dbo].[lin_DeleteBBSBoard]
(
	@board_name	nvarchar(20)
)
AS

set nocount on

declare @ncount int
declare @table_name nvarchar(20)
declare @exec nvarchar(500)

set @table_name = ''bbs_'' + @board_name

set @exec = ''drop table '' + @table_name
exec (@exec)

delete from bbs_board where board_name =  @table_name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreatePremiumItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreatePremiumItem]
(
@char_id	INT,
@item_type 	INT,
@amount 	INT,
@enchant 	INT,
@eroded 	INT,
@bless 		TINYINT,
@ident 		INT,
@wished 	TINYINT,
@warehouse	INT,
@variation_opt1 INT,
@variation_opt2 INT,
@intensive_item_type INT,
@warehouse_no	BIGINT
)
AS
SET NOCOUNT ON

BEGIN TRAN
DECLARE @new_item_id INT
DECLARE @item_remain INT
SET @new_item_id = 0

SELECT @item_remain = item_remain FROM user_premium_item (NOLOCK) WHERE warehouse_no = @warehouse_no

IF @item_remain < @amount
BEGIN
	RAISERROR(''Remained amount[%d] is below than request[%d]'', 16, 1, @item_remain, @amount)
	ROLLBACK TRAN
	SELECT 0
	RETURN
END

INSERT INTO user_item 
(char_id , item_type , amount , enchant , eroded , bless , ident , wished , warehouse, variation_opt1, variation_opt2, intensive_item_type) 
VALUES
(@char_id, @item_type , @amount , @enchant , @eroded , @bless , @ident , @wished , @warehouse, @variation_opt1, @variation_opt2, @intensive_item_type)

SET @new_item_id =  @@IDENTITY

UPDATE user_premium_item
SET item_remain = item_remain - @amount
WHERE warehouse_no = @warehouse_no

INSERT INTO user_premium_item_receive (warehouse_no, real_recipient_char_id, item_dbid, item_amount, receive_date)
VALUES (@warehouse_no, @char_id, @new_item_id, @amount, GETDATE())

IF @new_item_id > 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @new_item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[door]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[door](
	[name] [nvarchar](50) NOT NULL,
	[hp] [int] NOT NULL,
	[max_hp] [int] NULL,
 CONSTRAINT [PK_door] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateSSQTopPointUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_CreateSSQTopPointUser
  * @brief 타임 어택 정보 저장.
  *
  * @date 2004/12/09
  * @author Seongeun Park  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_CreateSSQTopPointUser] 
(
@ssq_round INT,
@record_id INT,

@ssq_point INT,
@rank_time INT,
@char_id  INT,
@char_name NVARCHAR(50),
@ssq_part TINYINT,
@ssq_position TINYINT,
@seal_selection_no TINYINT
)
AS

SET NOCOUNT ON

INSERT INTO ssq_top_point_user  
	         (ssq_round, record_id, ssq_point, rank_time, char_id, char_name, 
	          ssq_part, ssq_position, seal_selection_no, last_changed_time)
	VALUES (@ssq_round, @record_id, @ssq_point, @rank_time, @char_id, @char_name, @ssq_part, @ssq_position, @seal_selection_no, GETDATE())

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MigrationListForSeven]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MigrationListForSeven](
	[idx] [int] NOT NULL,
	[postDate] [datetime] NOT NULL,
	[serviceType] [tinyint] NOT NULL,
	[fromUid] [int] NOT NULL,
	[toUid] [int] NULL,
	[fromAccount] [nvarchar](24) NULL,
	[toAccount] [nvarchar](24) NULL,
	[fromServer] [tinyint] NOT NULL,
	[toServer] [tinyint] NULL,
	[fromCharacter] [nvarchar](24) NOT NULL,
	[toCharacter] [nvarchar](24) NULL,
	[changeGender] [bit] NULL,
	[serviceFlag] [smallint] NOT NULL,
	[applyDate] [datetime] NULL CONSTRAINT [DF_MigrationListForSeven_applyDate]  DEFAULT (getdate()),
	[reserve1] [varchar](200) NULL,
	[reserve2] [varchar](100) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSurrenderWarId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetSurrenderWarId

INPUT
	@char_id	INT
OUTPUT
return
made by
	bert
date
	2003-10-07
********************************************/
CREATE PROCEDURE [dbo].[lin_GetSurrenderWarId]
(
@char_id	INT
)
AS
SET NOCOUNT ON


SELECT char_id, surrender_war_id FROM user_surrender us, pledge_war pw WHERE us.char_id = @char_id AND us.surrender_war_id = pw.id AND pw.status = 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[residence_guard]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[residence_guard](
	[residence_id] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[npc_id] [int] NOT NULL,
	[guard_type] [int] NOT NULL,
	[can_move] [int] NOT NULL,
	[x] [int] NOT NULL,
	[y] [int] NOT NULL,
	[z] [int] NOT NULL,
	[angle] [int] NOT NULL,
 CONSTRAINT [pk_residence_guard] PRIMARY KEY CLUSTERED 
(
	[x] ASC,
	[y] ASC,
	[z] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelCursedWeapon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_DelCursedWeapon]
(
	@item_id		int
)
as
set nocount on
delete from cursed_weapon
	where item_id=@item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RemoveAirShip]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_RemoveAirShip]
	@airship_id int,
	@reason int
AS
SET NOCOUNT ON

UPDATE airship
SET deleted = @reason
WHERE airship_id = @airship_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllAuctionBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadAllAuctionBid
desc:	load all bid

history:	2007-04-12	created by btwinuni
*/
create procedure [dbo].[lin_LoadAllAuctionBid]
	@auction_id int
as
set nocount on

select char_id, bidding_price
from item_auction_bid (nolock)
where auction_id = @auction_id
	and withdraw = 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SavePVPPointRestrain]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SavePVPPointRestrain
desc:	save pvp point restrain
exam:	exec lin_SavePVPPointRestrain
history:	2008-02-25	created by Phyllion
*/

CREATE PROCEDURE [dbo].[lin_SavePVPPointRestrain] 
(
	@char_id int,
	@give_count int,
	@give_time int
)
AS

SET NOCOUNT ON

/*
IF (@point < 0)
BEGIN            
    RAISERROR (''Not valid parameter : char id[%d] point[%d]'', @char_id,  @point)
    RETURN -1            
END            

*/

UPDATE user_pvppoint_restrain SET give_count = @give_count, give_time = @give_time
WHERE char_id = @char_id

IF @@rowcount = 0
BEGIN
	INSERT INTO user_pvppoint_restrain (char_id, give_count, give_time) 
	VALUES (@char_id, @give_count, @give_time)    	
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbsaving_map]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dbsaving_map](
	[map_key] [int] NOT NULL,
	[map_value] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FinishPledgeWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_FinishPledgeWar    Script Date: 2003-09-20 오전 11:51:58 ******/
-- lin_FinishPledgeWar
-- by bert

CREATE PROCEDURE
[dbo].[lin_FinishPledgeWar] (@by_timeout INT, @winner_pledge_id INT, @loser_pledge_id INT, @war_id INT, @war_end_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

IF @by_timeout = 0
BEGIN	-- 적혈맹주가 죽은 경우, 즉 승패가 갈린 경우
	UPDATE Pledge_War
	SET status = 3,	-- WAR_END_NORMAL
	winner = @winner_pledge_id,
	winner_name = (SELECT name FROM Pledge WHERE pledge_id = @winner_pledge_id),
	end_time = @war_end_time
	WHERE
	id = @war_id
	AND
	status = 0
	
	-- now_war_id = 0 세팅	now_war_id는 오직 stored procedure에 의해서만 바뀐다.
	IF @@ERROR = 0 AND @@ROWCOUNT = 1
	BEGIN
		SELECT @ret = @war_id
	END
	ELSE
	BEGIN
		SELECT @ret = 0
	END	
END
ELSE
BEGIN	-- 24시간 타임아웃이 걸린 경우, 승패가 갈리지 않은 경우
	UPDATE Pledge_War
	SET status = 4,	-- WAR_END_TIMEOUT
	end_time = @war_end_time
	WHERE
	id = @war_id
	AND
	status = 0

	-- now_war_id = 0 세팅	now_war_id는 오직 stored procedure에 의해서만 바뀐다.
	IF @@ERROR = 0 AND @@ROWCOUNT = 1
	BEGIN
		SELECT @ret = @war_id
	END
	ELSE
	BEGIN
		SELECT @ret = 0
	END
END

IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_service]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_service](
	[char_id] [int] NOT NULL,
	[service_flag] [int] NOT NULL CONSTRAINT [DF__user_serv__servi__39AF212D]  DEFAULT ((0)),
	[reg_date] [datetime] NOT NULL CONSTRAINT [DF__user_serv__reg_d__3AA34566]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_JoinAlliance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_JoinAlliance    Script Date: 2003-09-20 오전 11:51:59 ******/
-- lin_JoinAlliance
-- by bert
-- return Result(0 if failed)

CREATE PROCEDURE
[dbo].[lin_JoinAlliance] (@alliance_id INT, @member_pledge_id INT)
AS

SET NOCOUNT ON

DECLARE @result INT

UPDATE pledge
SET alliance_id = @alliance_id
WHERE pledge_id = @member_pledge_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @result = 1
END
ELSE
BEGIN
	SELECT @result = 0
END

SELECT @result

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveUserPremiumItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SaveUserPremiumItem
desc:	save premium item from IBServer

history:	2008-04-07	created by btwinuni
*/
create procedure [dbo].[lin_SaveUserPremiumItem]
(
	@warehouse_no			bigint,
	@buyer_id				int,
	@buyer_char_id			int,
	@buyer_char_name		nvarchar(50),
	@recipient_id			int,
	@recipient_char_id		int,
	@recipient_char_name	nvarchar(50),
	@item_id				int,
	@item_amount			bigint
)
as

set nocount on

if not exists (select * from user_premium_item (nolock) where warehouse_no = @warehouse_no)
begin
	insert into user_premium_item (warehouse_no,buyer_id,buyer_char_id,buyer_char_name,recipient_id,recipient_char_id,recipient_char_name,item_id,item_amount,item_remain)
	values (@warehouse_no,@buyer_id,@buyer_char_id,@buyer_char_name,@recipient_id,@recipient_char_id,@recipient_char_name,@item_id,@item_amount,@item_amount)

	select @@error
end
else
begin
	select 0
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetPetitionMsg]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetPetitionMsg    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetPetitionMsg
	get Petition Msg and delete it
INPUT
	@char_id	int
OUTPUT
	msg(nvarchar 500)
return
made by
	carrot
date
	2003-02-27
********************************************/
CREATE PROCEDURE [dbo].[lin_GetPetitionMsg]
(
	@char_id	int
)
AS
SET NOCOUNT ON

select ISNULL(msg, '''') as msg from PetitionMsg where char_id = @char_id
delete PetitionMsg where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPeriodicItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_LoadPeriodicItems]
	@char_id int
as
set nocount on

SELECT uip.item_id, uip.start_time, uip.period,uip.item_type 
FROM user_item_period uip, user_item ui
WHERE uip.item_id = ui.item_id and ui.char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetTransferredPledgeMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetTransferredPledgeMaster
desc:	get transferred pledge master
exam:	exec lin_GetTransferredPledgeMaster

history:	2006-06-15	created by btwinuni
*/
CREATE procedure [dbo].[lin_GetTransferredPledgeMaster]
as

SET NOCOUNT ON

select distinct P.pledge_id, P.new_master_id, U.char_name
from (
	select T1.pledge_id, T2.new_master_id
	from (
		select pledge_id, max(status_time) as status_time
		from pledge_master_transfer(nolock)
		where status = 1
		group by pledge_id
	) T1, pledge_master_transfer T2(nolock)
	where T1.pledge_id = T2.pledge_id
		and T1.status_time = T2.status_time
		and T2.status = 1
) P, user_data U(nolock)
where P.new_master_id = U.char_id
	and P.pledge_id = U.pledge_id

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_TransferPledgeMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE
[dbo].[lin_TransferPledgeMaster]
AS

SET NOCOUNT ON


BEGIN TRAN
DECLARE @pledge_id INT, @new_master_id INT

DECLARE master_transfer_cursor CURSOR FOR
SELECT 
	T.pledge_id, T.new_master_id
FROM	
	pledge_master_transfer AS T, user_data AS U
WHERE
	U.account_id > 0 AND
	T.status = 0 AND		-- candidate
--	T.status_time BETWEEN getdate() and getdate() AND
	T.new_master_id = U.char_id AND
	T.pledge_id = U.pledge_id AND
	U.pledge_type = 0

OPEN master_transfer_cursor

FETCH NEXT FROM master_transfer_cursor
INTO @pledge_id, @new_master_id

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE 
		pledge
	SET
		ruler_id = @new_master_id
	WHERE
		pledge_id = @pledge_id

	IF (@@ROWCOUNT > 0)
	BEGIN
		UPDATE
			pledge_master_transfer
		SET
			status = 1,	-- success
			status_time = getdate()
		WHERE
			pledge_id = @pledge_id AND
			new_master_id = @new_master_id AND
			status = 0

		UPDATE 
			sub_pledge
		SET
			master_id = 0
		WHERE
			pledge_id = @pledge_id AND
			master_id = @new_master_id
	END
	ELSE
	BEGIN
		UPDATE
			pledge_master_transfer
		SET
			status = 2,	-- update failure
			status_time = getdate()
		WHERE
			pledge_id = @pledge_id AND
			new_master_id = @new_master_id AND
			status = 0
	END

	FETCH NEXT FROM master_transfer_cursor
	INTO @pledge_id, @new_master_id
END

CLOSE master_transfer_cursor
DEALLOCATE master_transfer_cursor

UPDATE
	pledge_master_transfer
SET
	status = -1,	-- invalid new master
	status_time = getdate()
WHERE
	status = 0
	
COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveBossRecordRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveBossRecordRound
	Save Boss Record History
INPUT  
	@round_number		int
	@start_time		int
	@end_time		int
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-02-28
********************************************/  
CREATE    PROCEDURE [dbo].[lin_SaveBossRecordRound]  
(
	@round_number		int,
	@start_time		int,
	@end_time		int
)
AS  
SET NOCOUNT ON  
  
select top 1 * from bossrecord_round
where round_number = @round_number

IF(@@ROWCOUNT >0)
	BEGIN
		update bossrecord_round set start_time = @start_time, end_time = @end_time where round_number = @round_number
	END
ELSE
	BEGIN
		insert into bossrecord_round values(@round_number, @start_time, @end_time)
	END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveToNextBossRecordRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_MoveToNextBossRecordRound
	Move To Next Boss Record Round
INPUT  
	@round_number		int
	@start_time		int
	@end_time		int
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-02-28
********************************************/  
CREATE    PROCEDURE [dbo].[lin_MoveToNextBossRecordRound]  
(
	@round_number		int, 
	@start_time		int,
	@end_time 		int
)
AS  
SET NOCOUNT ON  
  
select top 1 * from bossrecord_round
where round_number = @round_number

if(@@ROWCOUNT > 0)
BEGIN
	insert into user_bossrecord_history 
	select @round_number, char_id , sum(point) , sum(accumulated_point)
	from user_bossrecord
	group by char_id
	
	update user_bossrecord
	set point = 0
	
	insert into bossrecord_round values(@round_number + 1, @start_time, @end_time)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBossRecordRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadBossRecordRound
	Load Boss Record Round
INPUT  
OUTPUT  
 
return  
made by  
 zzangse  
date  
 2006-02-28
********************************************/  
CREATE    PROCEDURE [dbo].[lin_LoadBossRecordRound]  

AS  
SET NOCOUNT ON  
  
select top 1 round_number, start_time, end_time 
from bossrecord_round
order by round_number desc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RewardForBossrecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_RewardForBossrecord]
	@round_number	int = 0
as
set nocount on
-- round_number가 없다면 바로 전 주기를 찾도록 하자.
if @round_number = 0
begin
	select @round_number = max(round_number)
	from user_bossrecord_history (nolock)
	where round_number in (
		select round_number
		from bossrecord_round (nolock)
		where end_time < datediff(ss, ''1970-01-01 00:00:00'', getutcdate()))
end
-- 이미 보상을 지급했다면 return
if exists (select * from reward_for_bossrecord where round_number = @round_number)
begin
	RAISERROR(''invalid round_number: [%d]'', 16, 1, @round_number)
	return
end
-- 순위 테이블을 생성
truncate table tbl_rank
insert into tbl_rank
select char_id, (select count(*)+1 from user_bossrecord_history (nolock) where round_number = @round_number and point > T.point)
from user_bossrecord_history T(nolock)
where round_number = @round_number
-- 보상 지급 후보자 선출
begin tran
declare @char_id int
declare @rank int
declare @rank_count int
declare @reward int
declare @root_name_value int
declare @pledge_id int
declare candidate_cursor cursor for select char_id, rank from tbl_rank where rank <= 100
open candidate_cursor
fetch next from candidate_cursor into @char_id, @rank
while @@fetch_status = 0
begin
	select @rank_count = count(*) from tbl_rank where rank = @rank
	if @rank_count = 0	-- 사실 에러지만..
		continue
	if @rank between 1 and 10
	begin
		select @reward = sum(reward)/@rank_count from tbl_reward (nolock) where rank between @rank and @rank + (@rank_count-1)
		if @reward < 25
			set @reward = 25
	end
	else if @rank between 11 and 50
		set @reward = 25
	else
		set @reward = 15
	
	select @pledge_id = pledge_id from user_data (nolock) where char_id = @char_id
	if @pledge_id > 0
	begin
		select @root_name_value = root_name_value
		from pledge (nolock)
		where pledge_id = @pledge_id
		update pledge
		set root_name_value = root_name_value + @reward
		where pledge_id = @pledge_id and skill_level >= 5	-- 혈맹 레벨이 5이상인 경우만 지급
		if @@rowcount > 0
			insert into pledge_namevalue_log (pledge_id, log_id, log_from, log_to, delta)
			values (@pledge_id, 1, @root_name_value, @root_name_value + @reward, @reward)
	end
	fetch next from candidate_cursor into @char_id, @rank
end
close candidate_cursor
deallocate candidate_cursor
insert into reward_for_bossrecord (round_number, reward_date) values (@round_number, getdate())
commit tran

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteOlympiadTradePoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteOlympiadTradePoint]
(
@char_id INT,
@olympiad_trade_point INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
--SET trade_point = 0
SET trade_point = trade_point - @olympiad_trade_point
WHERE 
char_id = @char_id
--AND trade_point = @olympiad_trade_point

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharAddedService]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_MoveCharAddedService
desc:	move character to this server from another server(CommingFromServer)
exam:	exec lin_MoveCharAddedService ''''''server'''';''''login_id'''';''''password'''''', 1, ''from_name'', ''to_name''

history:	2006-11-20	created by btwinuni
              2007-01-23      modified as ''lin_MoveCharAddedService'' from ''lin_MoveCharacter''
              2007-07-23      modified as CT1 version by neo
			  2008-05-07	  modified as CT2 Part1 version by neo
			  2008-08-04	  modified as CT2 Part2 version by neo
			  2008-12-02	  modified as CT2 Final version by neo
*/

CREATE procedure [dbo].[lin_MoveCharAddedService]
	@db_info	varchar(64),	-- CommingFromServer
	@fromCharId	int,		-- character of CommingFromServer
	@fromCharName	nvarchar(24),	-- character of CommingFromServer
	@toCharName	nvarchar(24)	-- character of this server
as

set nocount on

declare
	@char_id	int,
	@item_id		int,
	@item_type	int,
	@amount	BIGINT,
	@enchant	int,
	@eroded	int,
	@bless		int,
	@ident		int,
	@wished	int,
	@warehouse	int,
	@variation_opt1	int,
	@variation_opt2	int,
	@intensive_item_type	int,
              @inventory_slot_index        int,
	@new_item_id	int,
              @level                  int,
              @adena_limit        int,
              @original_pk         int,
	@sql		varchar(4000)



-- user_data
set @sql = ''insert into user_data (''
	+ ''	char_name,account_name,account_id,pledge_id,builder,gender,race,class,world,''
	+ ''	xloc,yloc,zloc,IsInVehicle,HP,MP,SP,Exp,Lev,align,PK,PKpardon,Duel,''
	+ ''	create_date,login,logout,quest_flag,nickname,power_flag,''
	+ ''	pledge_dismiss_time,pledge_leave_time,pledge_leave_status,max_hp,max_mp,quest_memo,''
	+ ''	face_index,hair_shape_index,hair_color_index,use_time,temp_delete_date,''
	+ ''	pledge_ousted_time,pledge_withdraw_time,surrender_war_id,drop_exp,subjob_id,ssq_dawn_round,''
	+ ''	cp,max_cp,subjob0_class,subjob1_class,subjob2_class,subjob3_class,pledge_type,''
	+ ''	grade_id,academy_pledge_id,''
	+ ''	item_duration,''	--interlude
	+ ''	tutorial_flag,''	--CT1
	+ ''	bookmark_slot''	--CT2 Part2
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',account_name,account_id,pledge_id,builder,gender,race,class,world,''
	+ ''	xloc,yloc,zloc,IsInVehicle,HP,MP,SP,Exp,Lev,align,PK,PKpardon,Duel,''
	+ ''	create_date,login,logout,quest_flag,nickname,power_flag,''
	+ ''	pledge_dismiss_time,pledge_leave_time,pledge_leave_status,max_hp,max_mp,quest_memo,''
	+ ''	face_index,hair_shape_index,hair_color_index,use_time,temp_delete_date,''
	+ ''	pledge_ousted_time,pledge_withdraw_time,surrender_war_id,drop_exp,subjob_id, 0,''
	+ ''	cp,max_cp,subjob0_class,subjob1_class,subjob2_class,subjob3_class,pledge_type,''
	+ ''	grade_id,academy_pledge_id,''
	+ ''	item_duration,''	--interlude
	+ ''	tutorial_flag,''	--CT1
	+ ''	bookmark_slot''	--CT2 Part2
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_data(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



-- set @char_id as char_id of migrator
select @char_id = char_id from user_data(nolock) where char_name = @toCharName


--user_slot
set @sql = ''insert into user_slot (''
	+ ''	char_id,ST_underwear,ST_right_ear,ST_left_ear,ST_neck,ST_right_finger,ST_left_finger,ST_head,ST_right_hand,ST_left_hand,''
	+ ''	ST_gloves,ST_chest,ST_legs,ST_feet,ST_back,ST_both_hand,ST_hair,ST_hair2,''
    + '' ST_right_bracelet,ST_left_bracelet,ST_deco1,ST_deco2,ST_deco3,ST_deco4,ST_deco5,ST_deco6''
    + '' ,ST_waist'' --CT2 Final
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',0,0,0,0,0,0,0,0,0,''
	+ ''	0,0,0,0,0,0,0,0,''
	+ ''	0,0,0,0,0,0,0,0''
    + '' ,0'' --CT2 Final

exec (@sql)
if @@error <> 0	goto Err



-- user_item & user_item_duration
create table #migrator_user_item
(
	item_id		int,
	char_id		int,
	item_type	int,
	amount		BIGINT,
	enchant		int,
	eroded		int,
	bless		int,
	ident		int,
	wished		int,
	warehouse	int,
	variation_opt1	int,	--interlude
	variation_opt2	int,	--interlude
	intensive_item_type	int,	--interlude
	inventory_slot_index  int,	--CT1
	duration		int,	--interlude
    attack_attribute_type SMALLINT,	--CT1, CT2 Final
	attack_attribute_value SMALLINT,	--CT1, CT2 Final
	defend_attribute_0 SMALLINT,	--CT1, CT2 Final
	defend_attribute_1 SMALLINT,	--CT1, CT2 Final
	defend_attribute_2 SMALLINT,	--CT1, CT2 Final
	defend_attribute_3 SMALLINT,	--CT1, CT2 Final
	defend_attribute_4 SMALLINT,	--CT1, CT2 Final
	defend_attribute_5 SMALLINT,	--CT1, CT2 Final
	new_item_id	int
)


--1.착용아이템
set @sql = ''insert into #migrator_user_item (''
	+ ''	item_id,char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse,''
	+ ''	variation_opt1,variation_opt2,intensive_item_type,''	--interlude
	+ ''	inventory_slot_index,'' 	--CT1
	+ ''	duration,'' 	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' )''
	+ '' select''
	+ ''	item_id,''+cast(@char_id as varchar)+'',item_type,amount,enchant,eroded,bless,ident,wished,warehouse,''
	+ ''	isnull(variation_opt1,0),isnull(variation_opt2,0),isnull(intensive_item_type,0),''        	--interlude
              + ''	inventory_slot_index,''        	--CT1
              + ''	duration,''        	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select item.*, isnull(dur.duration,-1) duration, ''
	+ ''	isnull(atr.attack_attribute_type,-1) attack_attribute_type, isnull(atr.attack_attribute_value,-1) attack_attribute_value, ''
	+ ''	isnull(atr.defend_attribute_0,-1) defend_attribute_0, isnull(atr.defend_attribute_1,-1) defend_attribute_1, ''
	+ ''	isnull(atr.defend_attribute_2,-1) defend_attribute_2, isnull(atr.defend_attribute_3,-1) defend_attribute_3, ''
	+ ''	isnull(atr.defend_attribute_4,-1) defend_attribute_4, isnull(atr.defend_attribute_5,-1) defend_attribute_5 ''
    + ''          from  lin2world.dbo.user_item item(nolock) ''
    + ''				left outer join lin2world.dbo.user_item_duration dur(nolock) on item.item_id = dur.item_id ''
	+ ''				left outer join lin2world.dbo.user_item_attribute atr(nolock) on item.item_id = atr.item_id ''
	+ ''				left outer join lin2world.dbo.ItemData dat(nolock) on item.item_type = dat.item_type ''	--CT2 Part2 (기간제아이템이 아닌 경우에만 이동)
	+ ''	where item.item_id in ( ''
	+ ''	select ST_underwear from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_ear from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_ear from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_neck from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_finger from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_finger from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_head from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_hand from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_hand from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_gloves from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_chest from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_legs from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_feet from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_back from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_both_hand from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_hair from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_hair2 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_bracelet from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_bracelet from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco1 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco2 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco3 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco4 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco5 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco6 from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''	--CT2 Final
	+ ''	select ST_waist from lin2world.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '') ''	--CT2 Final
    + '' and item.char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ '' and isnull(dat.is_period, 0) = 0 '' --CT2 Part2 (기간제아이템이 아닌 경우에만 이동)
    +'''''')''
exec (@sql)
if @@error <> 0	goto Err


--2.이동가능아이템
set @sql = ''insert into #migrator_user_item ( ''
	+ ''	item_id,char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse, ''
	+ ''	variation_opt1,variation_opt2,intensive_item_type,'' --interlude
	+ ''           inventory_slot_index,''	--CT1
	+ ''           duration,''	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' ) ''
	+ '' select ''
	+ ''	item_id,''+cast(@char_id as varchar)+'',item_type,amount,enchant,eroded,bless,ident,wished,warehouse, ''
	+ ''	isnull(variation_opt1,0),isnull(variation_opt2,0),isnull(intensive_item_type,0),'' --interlude
	+ ''          inventory_slot_index,''	--CT1
	+ ''          duration, ''	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select item.*, isnull(dur.duration,-1) duration, ''
              + ''          isnull(atr.attack_attribute_type,-1) attack_attribute_type, isnull(atr.attack_attribute_value,-1) attack_attribute_value, ''
	+ ''	isnull(atr.defend_attribute_0,-1) defend_attribute_0, isnull(atr.defend_attribute_1,-1) defend_attribute_1, ''
	+ ''	isnull(atr.defend_attribute_2,-1) defend_attribute_2, isnull(atr.defend_attribute_3,-1) defend_attribute_3, ''
	+ ''	isnull(atr.defend_attribute_4,-1) defend_attribute_4, isnull(atr.defend_attribute_5,-1) defend_attribute_5 ''
	+ ''	from ''
              + ''          (select * from lin2world.dbo.user_item(nolock) where char_id = ''+cast(@fromCharId as varchar)+'' and warehouse = 0) item ''
	+ ''	inner join lin2world.dbo.ItemData dat(nolock) on item.item_type = dat.item_type and dat.can_move = 1 ''
	+ ''	and dat.is_period = 0 ''	--CT2 Part2 (기간제아이템이 아닌 경우에만 이동)
	+ ''	left outer join lin2world.dbo.user_item_duration dur(nolock) on item.item_id = dur.item_id''
	+ ''          left outer join lin2world.dbo.user_item_attribute atr(nolock) on item.item_id = atr.item_id'''') ''
	+ ''where item_id not in (select item_id from #migrator_user_item) ''
exec (@sql)
if @@error <> 0	goto Err



/*
--3.레벨별 아데나 제한 :  MAX(액티브레벨 and 서브잡레벨) 기준으로 아데나 제한이 적용될 경우
-- user_subjob
set @sql = ''insert into user_subjob (''
	+ ''	char_id,hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_subjob(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

--set @level as max level from user_subjob
select @level = max(level) from 
(
        select lev as level from user_data(nolock) where char_id = @char_id
        union
        select level as level from user_subjob(nolock) where char_id = @char_id
) level_data
*/

--3.레벨별 아데나 제한 modified at CT2 Final
select @level = lev from user_data(nolock) where char_name = @toCharName

if @level >= 40 and @level <= 51
        begin
                set @adena_limit =  150000000
        end
else if @level >= 52 and @level <= 60
        begin
                set @adena_limit =  300000000
        end
else if @level >= 61 and @level <= 70
        begin
                set @adena_limit =  600000000
        end
else if @level >= 71 and @level <= 75
        begin
                set @adena_limit =  900000000
        end
else if @level >= 76 and @level <= 77
        begin
                set @adena_limit = 1200000000
        end
else if @level >= 78 and @level <= 79
        begin
                set @adena_limit = 1500000000
        end
else if @level >= 80
        begin
                set @adena_limit = 2100000000
        end
else
        begin
                set @adena_limit = 0
        end

update #migrator_user_item
set amount = @adena_limit
where item_type = 57 and amount > @adena_limit
if @@error <> 0	goto Err



declare item_cursor cursor for
select item_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse, 
variation_opt1, variation_opt2, intensive_item_type, 	--interlude
inventory_slot_index        --CT1
from #migrator_user_item

open item_cursor
fetch next from item_cursor into @item_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
@variation_opt1, @variation_opt2, @intensive_item_type,	--interlude
@inventory_slot_index --CT1
while @@fetch_status = 0
begin
	insert into user_item (char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse,
	variation_opt1,variation_opt2,intensive_item_type,	--interlude
              inventory_slot_index)	--CT1
	values (@char_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
	@variation_opt1, @variation_opt2, @intensive_item_type,	--interlude
              @inventory_slot_index)	--CT1
              if @@error <> 0	goto Err

	set @new_item_id = scope_identity()
	update #migrator_user_item set new_item_id = @new_item_id where item_id = @item_id
	
	fetch next from item_cursor into @item_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
	@variation_opt1, @variation_opt2, @intensive_item_type,	--interlude
              @inventory_slot_index        --CT1
end

close item_cursor
deallocate item_cursor


--user_item_duration
insert into user_item_duration (item_id, duration)
(select new_item_id, duration from #migrator_user_item where duration > -1)	--interlude

if @@error <> 0	goto Err


--user_item_attribute
insert into user_item_attribute (item_id, attack_attribute_type, attack_attribute_value, 
defend_attribute_0, defend_attribute_1, defend_attribute_2, defend_attribute_3, defend_attribute_4, defend_attribute_5)
(select new_item_id, attack_attribute_type, attack_attribute_value, 
defend_attribute_0, defend_attribute_1, defend_attribute_2, defend_attribute_3, defend_attribute_4, defend_attribute_5 
from #migrator_user_item where attack_attribute_type <> -1)	--CT1


-- user_skill
set @sql = ''insert into user_skill (''
	+ ''	char_id,skill_id,skill_lev,to_end_time,subjob_id,is_lock,''
	+ ''	skill_delay''	-- interlude
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',skill_id,skill_lev,to_end_time,subjob_id,is_lock,''
	+ ''	skill_delay''	-- interlude
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_skill(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- quest
set @sql = ''insert into quest (''
	+ ''	char_id,q1,s1,q2,s2,q3,s3,q4,s4,q5,s5,q6,s6,q7,s7,q8,s8,q9,s9,q10,''
	+ ''	s10,q11,s11,q12,s12,q13,s13,q14,s14,q15,s15,q16,s16,''
	+ ''	j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12,j13,j14,j15,j16,''
	+ ''	s2_1,s2_2,s2_3,s2_4,s2_5,s2_6,s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16,''
	+ ''	q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,''
	+ ''	s2_17,s2_18,s2_19,s2_20,s2_21,s2_22,s2_23,s2_24,s2_25,s2_26,j17,j18,j19,j20,j21,j22,j23,j24,j25,j26''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',q1,s1,q2,s2,q3,s3,q4,s4,q5,s5,q6,s6,q7,s7,q8,s8,q9,s9,q10,''
	+ ''	s10,q11,s11,q12,s12,q13,s13,q14,s14,q15,s15,q16,s16,''
	+ ''	j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12,j13,j14,j15,j16,''
	+ ''	s2_1,s2_2,s2_3,s2_4,s2_5,s2_6,s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16,''
	+ ''	q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,''
	+ ''	s2_17,s2_18,s2_19,s2_20,s2_21,s2_22,s2_23,s2_24,s2_25,s2_26,j17,j18,j19,j20,j21,j22,j23,j24,j25,j26''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.quest(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

--CT2 Final 영지전 관련 퀘스트 19+2 제외 (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q1 = 0,  s1 = 0,  s2_1 = 0,  j1 = 0 where char_id = @char_id and  q1 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q2 = 0,  s2 = 0,  s2_2 = 0,  j2 = 0 where char_id = @char_id and  q2 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q3 = 0,  s3 = 0,  s2_3 = 0,  j3 = 0 where char_id = @char_id and  q3 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q4 = 0,  s4 = 0,  s2_4 = 0,  j4 = 0 where char_id = @char_id and  q4 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q5 = 0,  s5 = 0,  s2_5 = 0,  j5 = 0 where char_id = @char_id and  q5 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q6 = 0,  s6 = 0,  s2_6 = 0,  j6 = 0 where char_id = @char_id and  q6 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q7 = 0,  s7 = 0,  s2_7 = 0,  j7 = 0 where char_id = @char_id and  q7 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q8 = 0,  s8 = 0,  s2_8 = 0,  j8 = 0 where char_id = @char_id and  q8 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q9 = 0,  s9 = 0,  s2_9 = 0,  j9 = 0 where char_id = @char_id and  q9 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q10 = 0, s10 = 0, s2_10 = 0, j10 = 0 where char_id = @char_id and q10 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q11 = 0, s11 = 0, s2_11 = 0, j11 = 0 where char_id = @char_id and q11 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q12 = 0, s12 = 0, s2_12 = 0, j12 = 0 where char_id = @char_id and q12 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q13 = 0, s13 = 0, s2_13 = 0, j13 = 0 where char_id = @char_id and q13 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q14 = 0, s14 = 0, s2_14 = 0, j14 = 0 where char_id = @char_id and q14 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q15 = 0, s15 = 0, s2_15 = 0, j15 = 0 where char_id = @char_id and q15 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q16 = 0, s16 = 0, s2_16 = 0, j16 = 0 where char_id = @char_id and q16 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q17 = 0, s17 = 0, s2_17 = 0, j17 = 0 where char_id = @char_id and q17 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q18 = 0, s18 = 0, s2_18 = 0, j18 = 0 where char_id = @char_id and q18 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q19 = 0, s19 = 0, s2_19 = 0, j19 = 0 where char_id = @char_id and q19 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q20 = 0, s20 = 0, s2_20 = 0, j20 = 0 where char_id = @char_id and q20 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q21 = 0, s21 = 0, s2_21 = 0, j21 = 0 where char_id = @char_id and q21 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q22 = 0, s22 = 0, s2_22 = 0, j22 = 0 where char_id = @char_id and q22 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q23 = 0, s23 = 0, s2_23 = 0, j23 = 0 where char_id = @char_id and q23 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q24 = 0, s24 = 0, s2_24 = 0, j24 = 0 where char_id = @char_id and q24 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q25 = 0, s25 = 0, s2_25 = 0, j25 = 0 where char_id = @char_id and q25 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q26 = 0, s26 = 0, s2_26 = 0, j26 = 0 where char_id = @char_id and q26 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)


-- user_history
set @sql = ''insert into user_history (''
	+ ''	char_name,char_id,log_date,log_action,account_name,create_date''
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',''+cast(@char_id as varchar)+'',log_date,log_action,account_name,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_history(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_log
set @sql = ''insert into user_log (''
	+ ''	char_id,log_id,log_date,log_from,log_to,use_time,subjob_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',log_id,log_date,log_from,log_to,use_time,subjob_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_log(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_comment
set @sql = ''insert into user_comment (''
	+ ''	char_name,char_id,comment,comment_date,writer,deleted''
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',''+cast(@char_id as varchar)+'',comment,comment_date,writer,deleted''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_comment(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- pet_data
set @sql = ''insert into pet_data (''
	+ ''	pet_id,npc_class_id,expoint,nick_name,hp,mp,sp,meal,slot1,slot2,slot3'' --slot3 CT2 Part1
	+ '' )''
	+ '' select''
	+ ''	T2.new_item_id,npc_class_id,expoint,null,hp,mp,sp,meal,slot1,slot2,slot3'' --slot3 CT2 Part1
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.pet_data(nolock) where npc_class_id is not null'''') T1 ''
	+ ''	inner join (select * from #migrator_user_item(nolock)) T2 on T1.pet_id = T2.item_id''
exec (@sql)
if @@error <> 0	goto Err

-- initiate pet_name
update user_item
set eroded = 0
from pet_data
where user_item.item_id = pet_data.pet_id
	and char_id = @char_id


-- user_recipe
set @sql = ''insert into user_recipe (''
	+ ''	char_id,recipe_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',recipe_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_recipe(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_henna
set @sql = ''insert into user_henna (''
	+ ''	char_id,henna_1,henna_2,henna_3,subjob_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',henna_1,henna_2,henna_3,subjob_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_henna(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_sociality
set @sql = ''insert into user_sociality (''
	+ ''	char_id,sociality,used_sulffrage,last_changed''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',sociality,used_sulffrage,last_changed''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_sociality(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_subjob
set @sql = ''insert into user_subjob (''
	+ ''	char_id,hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_subjob(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_ban
set @sql = ''insert into user_ban (''
	+ ''	char_id,status,ban_date,ban_hour,ban_end''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',status,ban_date,ban_hour,ban_end''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_ban(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_punish
set @sql = ''insert into user_punish (''
	+ ''	char_id,punish_id,punish_on,remain_game,remain_real,punish_seconds,punish_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',punish_id,punish_on,remain_game,remain_real,punish_seconds,punish_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_punish(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_nobless
set @sql = ''insert into user_nobless (''
	+ ''	char_id,nobless_type,hero_type,win_count,previous_point,olympiad_point,match_count,words,olympiad_win_count,olympiad_lose_count,history_open,trade_point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',nobless_type,0,0,0,0,0,null,0,0,0,0''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_nobless(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



-- duel_record	--interlude
set @sql = ''insert into duel_record (''
	+ ''	user_id,individual_win,individual_lose,individual_draw,party_win,party_lose,party_draw''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',individual_win,individual_lose,individual_draw,party_win,party_lose,party_draw''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.duel_record(nolock) where user_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- shared_reuse_delays_of_items	--interlude
set @sql = ''insert into shared_reuse_delays_of_items (''
	+ ''	char_id,shared_delay_id,next_available_time''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',shared_delay_id,next_available_time''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.shared_reuse_delays_of_items(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_skill_reuse_delay	--interlude
set @sql = ''insert into user_skill_reuse_delay (''
	+ ''	char_id,skill_id,to_end_time,subjob_id,skill_delay''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',skill_id,to_end_time,subjob_id,skill_delay''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_skill_reuse_delay(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_activeskill	--CT1
set @sql = ''insert into user_activeskill (''
	+ ''	char_id,s1,l1,d1,s2,l2,d2,s3,l3,d3,s4,l4,d4,s5,l5,d5,s6,l6,d6,s7,l7,d7,s8,l8,d8,s9,l9,d9,s10,l10,d10,s11,l11,d11,s12,l12,d12,s13,l13,d13,s14,l14,d14,s15,l15,d15,s16,l16,d16,s17,l17,d17,s18,l18,d18,s19,l19,d19,s20,l20,d20,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,l21,l22,l23,l24,l25,l26,l27,l28,l29,l30,l31,l32,l33,l34,d21,d22,d23,d24,d25,d27,d28,d29,d30,d31,d32,d33,d34,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',s1,l1,d1,s2,l2,d2,s3,l3,d3,s4,l4,d4,s5,l5,d5,s6,l6,d6,s7,l7,d7,s8,l8,d8,s9,l9,d9,s10,l10,d10,s11,l11,d11,s12,l12,d12,s13,l13,d13,s14,l14,d14,s15,l15,d15,s16,l16,d16,s17,l17,d17,s18,l18,d18,s19,l19,d19,s20,l20,d20,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,l21,l22,l23,l24,l25,l26,l27,l28,l29,l30,l31,l32,l33,l34,d21,d22,d23,d24,d25,d27,d28,d29,d30,d31,d32,d33,d34,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_activeskill(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_ui	--CT1
set @sql = ''insert into user_ui (''
	+ ''	char_id,ui_setting_size,ui_setting''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',ui_setting_size,ui_setting''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_ui(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_point	--CT2 Part1
declare @VITIALITY_POINT_TYPE int
set @VITIALITY_POINT_TYPE = 6
declare @DEFAULT_VITIALITY_POINT int
set @DEFAULT_VITIALITY_POINT = 20000

set @sql = ''insert into user_point (''
	+ ''	char_id,point_type,point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',point_type,point''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_point(nolock) where char_id=''+cast(@fromCharId as varchar)
	+ ''   and point_type <> '' + cast(@VITIALITY_POINT_TYPE as varchar) + '''''')''
exec (@sql)
if @@error <> 0	goto Err

-- insert vitality point(20000)

insert into user_point (char_id,point_type,point) 
values(@char_id,@VITIALITY_POINT_TYPE,@DEFAULT_VITIALITY_POINT)


-- user_pvppoint_restrain	--CT2 Part1
set @sql = ''insert into user_pvppoint_restrain (''
	+ ''	char_id,give_count,give_time''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',give_count,give_time''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_pvppoint_restrain(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_nr_memo	--CT2 Part1
set @sql = ''insert into user_nr_memo (''
	+ ''	char_id,quest_id,state1,state2,journal''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',quest_id,state1,state2,journal''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_nr_memo(nolock) where char_id=''+cast(@fromCharId as varchar)
	+ '' and quest_id not in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)'' --CT2 Final 영지전 관련 퀘스트 19+2 제외
	+ '''''')''
exec (@sql)
if @@error <> 0	goto Err


--user_bookmark --CT2 Part2
set @sql = ''insert into user_bookmark (''
	+ ''	char_id,slot_id,pos_x,pos_y,pos_z,slot_title,icon_id,icon_title''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',slot_id,pos_x,pos_y,pos_z,slot_title,icon_id,icon_title''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_bookmark(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


--user_pccafe_point --CT2 Part2
set @sql = ''insert into user_pccafe_point (''
	+ ''	char_id,point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',point''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_pccafe_point(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


--user_name_color --CT2 Part2
set @sql = ''insert into user_name_color (''
	+ ''	char_id,color_rgb,nickname_color_rgb''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',color_rgb,nickname_color_rgb''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_name_color(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


--bot_report --CT2 Part2, CT2 Final
set @sql = ''insert into bot_report (''
	+ ''	char_id,reported,reported_date,bot_admin''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',reported,reported_date,bot_admin''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.bot_report(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



drop table #migrator_user_item
return @char_id

Err:
	if isnull(@char_id, 0) <> 0
	begin
		delete from user_data where char_id = @char_id
		delete from user_slot where char_id = @char_id	--CT1
		delete from user_skill where char_id = @char_id
		delete from quest where char_id = @char_id
		delete from user_history where char_id = @char_id
        		delete from user_log where char_id = @char_id
		delete from user_comment where char_id = @char_id
		delete from pet_data where pet_id in (select item_id from user_item where char_id = @char_id and item_type in (2375,3500,3501,3502,4422,4423,4424,4425,6648,6649,6650))
		delete from user_recipe where char_id = @char_id
		delete from user_henna where char_id = @char_id
		delete from user_sociality where char_id = @char_id
		delete from user_subjob where char_id = @char_id
		delete from user_ban where char_id = @char_id
		delete from user_punish where char_id = @char_id
		delete from user_nobless where char_id = @char_id
		delete from user_item_duration where item_id in (select item_id from user_item where char_id = @char_id)	--interlude
                            delete from user_item_attribute where item_id in (select item_id from user_item where char_id = @char_id)	--CT1
		delete from user_item where char_id = @char_id
		delete from duel_record where user_id = @char_id	--interlude
		delete from shared_reuse_delays_of_items where char_id = @char_id	--interlude
		delete from user_skill_reuse_delay where char_id = @char_id	--interlude
		delete from user_activeskill where char_id = @char_id	--interlude
		delete from user_ui where char_id = @char_id	--CT1
		delete from user_point where char_id = @char_id	--CT2 Part1
		delete from user_pvppoint_restrain where char_id = @char_id	--CT2 Part1
		delete from user_nr_memo where char_id = @char_id	--CT2 Part1
		delete from user_bookmark where char_id = @char_id	--CT2 Part2
		delete from user_pccafe_point where char_id = @char_id	--CT2 Part2
		delete from bot_report where char_id = @char_id	--CT2 Part2
	end

	print(@sql)

	drop table #migrator_user_item
	return 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveNoblessType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveNoblessType]
(
@char_id INT,
@nobless_type INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET nobless_type = @nobless_type
WHERE char_id = @char_id

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModOlympiadPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ModOlympiadPoint]
(
	@char_id	int,
	@previous_point	int,
	@olympiad_point	int,
	@mod_type	int
)
AS

declare
	@old_previous_point	int,
	@old_olympiad_point	int,
	@new_previous_point	int,
	@new_olympiad_point	int

select @old_previous_point = previous_point, @old_olympiad_point = olympiad_point
from user_nobless (nolock)
where char_id = @char_id

-- is not nobless
if @old_previous_point is null or @old_olympiad_point is null
return

if @mod_type = 1	-- relative
begin
	set @new_previous_point = @old_previous_point + @previous_point
	if @new_previous_point < 0
		set @new_previous_point = 0

	set @new_olympiad_point = @old_olympiad_point + @olympiad_point
	if @new_olympiad_point < 0
		set @new_olympiad_point = 0
end
else		-- absolute
begin
	set @new_previous_point = @previous_point
	if @new_previous_point < 0
		set @new_previous_point = 0

	set @new_olympiad_point = @olympiad_point
	if @new_olympiad_point < 0
		set @new_olympiad_point = 0
end

update user_nobless
set previous_point = @new_previous_point,
	olympiad_point = @new_olympiad_point
where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveOlympiadRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveOlympiadRecord]
(
@season INT,
@winner_id INT,
@winner_point INT,
@loser_id INT,
@loser_point INT,
@time INT,
@draw INT,
@elapsed_time INT,
@game_rule INT
)
AS
SET NOCOUNT ON

DECLARE @winner_class INT
DECLARE @loser_class INT

/* 
 is_winner
	0 : loser
	1 : winner
	2 : got penalty
	3 : draw	
*/

IF @draw = 1	 /* 비겼을 경우 추가 */
BEGIN
	IF @winner_id <> 0
	BEGIN
		UPDATE user_nobless
		SET olympiad_point = olympiad_point + @winner_point, match_count = match_count+1
		WHERE char_id = @winner_id
	
		SELECT @winner_class = subjob0_class FROM user_data(nolock) WHERE char_id = @winner_id
	
		INSERT olympiad_match
		(season, class, match_time, char_id, rival_id, point, is_winner, elapsed_time, game_rule)
		VALUES
		(@season, @winner_class, @time, @winner_id, @loser_id, @winner_point, 3, @elapsed_time, @game_rule)
	END
	
	IF @loser_id <> 0
	BEGIN
		UPDATE user_nobless
		SET olympiad_point = olympiad_point + @loser_point, match_count = match_count+1
		WHERE char_id = @loser_id
	
		SELECT @loser_class = subjob0_class FROM user_data(nolock) WHERE char_id = @loser_id
	
		INSERT olympiad_match
		(season, class, match_time, char_id, rival_id, point, is_winner, elapsed_time, game_rule)
		VALUES
		(@season, @loser_class, @time, @loser_id, @winner_id, @loser_point, 3, @elapsed_time, @game_rule)
	END
END ELSE 
IF @draw = 2	/* 올림피아드 점수만 바꾸는 경우 : 현재는 리스로 인한 페널티를 줄때만 적용한다. */
BEGIN
	/* loser_id : 페널티 대상, loser_point : 페널티 점수, winner_id: 경기 상대자, winner_point:경기 상대자의 변동점수. 항상 0으로 한다.  */
	/* 페널티 대상자에 대해서만 기록하며 전적횟수 승패횟수에는 영향을 주지 않는다 */
	IF @loser_id <> 0
	BEGIN
		UPDATE user_nobless
		SET olympiad_point = olympiad_point + @loser_point
		WHERE char_id = @loser_id
	
		SELECT @loser_class = subjob0_class FROM user_data(nolock) WHERE char_id = @loser_id
	
		INSERT olympiad_match
		(season, class, match_time, char_id, rival_id, point, is_winner, elapsed_time, game_rule)
		VALUES
		(@season, @loser_class, @time, @loser_id, @winner_id, @loser_point, 2, @elapsed_time, @game_rule)
	END
END ELSE 
BEGIN
	IF @winner_id <> 0
	BEGIN
		UPDATE user_nobless
		SET olympiad_point = olympiad_point + @winner_point, match_count = match_count+1, olympiad_win_count = olympiad_win_count+1
		WHERE char_id = @winner_id
	
		SELECT @winner_class = subjob0_class FROM user_data(nolock) WHERE char_id = @winner_id
	
		INSERT olympiad_match
		(season, class, match_time, char_id, rival_id, point, is_winner, elapsed_time, game_rule)
		VALUES
		(@season, @winner_class, @time, @winner_id, @loser_id, @winner_point, 1, @elapsed_time, @game_rule)
	END
	
	IF @loser_id <> 0
	BEGIN
		UPDATE user_nobless
		SET olympiad_point = olympiad_point + @loser_point, match_count = match_count+1, olympiad_lose_count = olympiad_lose_count+1
		WHERE char_id = @loser_id
	
		SELECT @loser_class = subjob0_class FROM user_data(nolock) WHERE char_id = @loser_id
	
		INSERT olympiad_match
		(season, class, match_time, char_id, rival_id, point, is_winner, elapsed_time, game_rule)
		VALUES
		(@season, @loser_class, @time, @loser_id, @winner_id, @loser_point, 0, @elapsed_time, @game_rule)
	END
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharAddedServiceEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_MoveCharAddedServiceEvent
desc:	move character to this server from another server(CommingFromServer)
exam:	exec lin_MoveCharAddedServiceEvent ''''''server'''';''''login_id'''';''''password'''''', 1, ''from_name'', ''to_name''

history:	2006-11-20	created by btwinuni
              2007-01-23      modified as ''lin_MoveCharAddedService'' from ''lin_MoveCharacter''
              2007-07-23      modified as CT1 version by neo
			  2008-05-07	  modified as CT2 Part1 version by neo
			  2008-08-04	  modified as CT2 Part2 version by neo
			  2008-12-02	  modified as CT2 Final version by neo
*/

create procedure [dbo].[lin_MoveCharAddedServiceEvent]
	@db_info	varchar(64),	-- CommingFromServer
	@fromCharId	int,		-- character of CommingFromServer
	@fromCharName	nvarchar(24),	-- character of CommingFromServer
	@toCharName	nvarchar(24)	-- character of this server
as

set nocount on

declare
	@char_id	int,
	@item_id		int,
	@item_type	int,
	@amount	BIGINT,
	@enchant	int,
	@eroded	int,
	@bless		int,
	@ident		int,
	@wished	int,
	@warehouse	int,
	@variation_opt1	int,
	@variation_opt2	int,
	@intensive_item_type	int,
              @inventory_slot_index        int,
	@new_item_id	int,
              @level                  int,
              @adena_limit        int,
              @original_pk         int,
	@sql		varchar(4000)

-- ###### 캐릭터명 중복체크 시작
-- changed_name_by_merge
if not exists (select * from sysobjects where id = object_id(N''changed_name_by_merge'') and objectproperty(id, N''IsUserTable'') = 1)
begin
	create table dbo.changed_name_by_merge
	(
		id		int not null,
		type		int not null,	-- 0: user, 1; pledge
		name_origin	nvarchar(50) not null,
		name_temp	nvarchar(50) null,
		name_new	nvarchar(50) null,
		previous_server	int not null,
		change_date	datetime null,
		change_flag	int not null constraint DF_changed_name_by_merge_change_flag default(0)
	)

	alter table dbo.changed_name_by_merge add constraint
		PK_changed_name_by_merge primary key clustered (id, type) on [primary]
end

declare @duplicated_char_id int
set @duplicated_char_id = 0
declare @serialNo int
set @serialNo = 0

select @duplicated_char_id = char_id from user_data where char_name = @toCharName

while (@duplicated_char_id > 0)
begin
	set @duplicated_char_id = 0 
	
	set @toCharName = cast(@serialNo as nvarchar) + @fromCharName
	select @duplicated_char_id = char_id from user_data where char_name = @toCharName
	
	set @serialNo = @serialNo + 1
end
-- ###### 캐릭터명 중복체크 끝


-- user_data
set @sql = ''insert into user_data (''
	+ ''	char_name,account_name,account_id,pledge_id,builder,gender,race,class,world,''
	+ ''	xloc,yloc,zloc,IsInVehicle,HP,MP,SP,Exp,Lev,align,PK,PKpardon,Duel,''
	+ ''	create_date,login,logout,quest_flag,nickname,power_flag,''
	+ ''	pledge_dismiss_time,pledge_leave_time,pledge_leave_status,max_hp,max_mp,quest_memo,''
	+ ''	face_index,hair_shape_index,hair_color_index,use_time,temp_delete_date,''
	+ ''	pledge_ousted_time,pledge_withdraw_time,surrender_war_id,drop_exp,subjob_id,ssq_dawn_round,''
	+ ''	cp,max_cp,subjob0_class,subjob1_class,subjob2_class,subjob3_class,pledge_type,''
	+ ''	grade_id,academy_pledge_id,''
	+ ''	item_duration,''	--interlude
	+ ''	tutorial_flag,''	--CT1
	+ ''	bookmark_slot''	--CT2 Part2
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',account_name,account_id,0,builder,gender,race,class,world,''
	+ ''	xloc,yloc,zloc,IsInVehicle,HP,MP,SP,Exp,Lev,align,PK,PKpardon,Duel,''
	+ ''	create_date,login,logout,quest_flag,nickname,0,''
	+ ''	0,0,0,max_hp,max_mp,quest_memo,''
	+ ''	face_index,hair_shape_index,hair_color_index,use_time,temp_delete_date,''
	+ ''	0,0,0,drop_exp,subjob_id, 0,''
	+ ''	cp,max_cp,subjob0_class,subjob1_class,subjob2_class,subjob3_class,0,''
	+ ''	grade_id,0,''
	+ ''	item_duration,''	--interlude
	+ ''	tutorial_flag,''	--CT1
	+ ''	bookmark_slot''	--CT2 Part2
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_data(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



-- set @char_id as char_id of migrator
select @char_id = char_id from user_data(nolock) where char_name = @toCharName


-- ###### 캐릭터명 중복
if @fromCharName <> @toCharName
begin
	insert into changed_name_by_merge (id, type, name_origin, name_temp, name_new, previous_server)	
		values (@char_id, 0, @fromCharName, @toCharName, @toCharName, 99)
end


--user_slot
set @sql = ''insert into user_slot (''
	+ ''	char_id,ST_underwear,ST_right_ear,ST_left_ear,ST_neck,ST_right_finger,ST_left_finger,ST_head,ST_right_hand,ST_left_hand,''
	+ ''	ST_gloves,ST_chest,ST_legs,ST_feet,ST_back,ST_both_hand,ST_hair,ST_hair2,''
    + '' ST_right_bracelet,ST_left_bracelet,ST_deco1,ST_deco2,ST_deco3,ST_deco4,ST_deco5,ST_deco6''
    + '' ,ST_waist'' --CT2 Final
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',0,0,0,0,0,0,0,0,0,''
	+ ''	0,0,0,0,0,0,0,0,''
	+ ''	0,0,0,0,0,0,0,0''
    + '' ,0'' --CT2 Final

exec (@sql)
if @@error <> 0	goto Err



-- user_item & user_item_duration
create table #migrator_user_item
(
	item_id		int,
	char_id		int,
	item_type	int,
	amount		BIGINT,
	enchant		int,
	eroded		int,
	bless		int,
	ident		int,
	wished		int,
	warehouse	int,
	variation_opt1	int,	--interlude
	variation_opt2	int,	--interlude
	intensive_item_type	int,	--interlude
	inventory_slot_index  int,	--CT1
	duration		int,	--interlude
    attack_attribute_type SMALLINT,	--CT1, CT2 Final
	attack_attribute_value SMALLINT,	--CT1, CT2 Final
	defend_attribute_0 SMALLINT,	--CT1, CT2 Final
	defend_attribute_1 SMALLINT,	--CT1, CT2 Final
	defend_attribute_2 SMALLINT,	--CT1, CT2 Final
	defend_attribute_3 SMALLINT,	--CT1, CT2 Final
	defend_attribute_4 SMALLINT,	--CT1, CT2 Final
	defend_attribute_5 SMALLINT,	--CT1, CT2 Final
	new_item_id	int
)


--1.착용아이템
set @sql = ''insert into #migrator_user_item (''
	+ ''	item_id,char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse,''
	+ ''	variation_opt1,variation_opt2,intensive_item_type,''	--interlude
	+ ''	inventory_slot_index,'' 	--CT1
	+ ''	duration,'' 	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' )''
	+ '' select''
	+ ''	item_id,''+cast(@char_id as varchar)+'',item_type,amount,enchant,eroded,bless,ident,wished,warehouse,''
	+ ''	isnull(variation_opt1,0),isnull(variation_opt2,0),isnull(intensive_item_type,0),''        	--interlude
              + ''	inventory_slot_index,''        	--CT1
              + ''	duration,''        	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select item.*, isnull(dur.duration,-1) duration, ''
	+ ''	isnull(atr.attack_attribute_type,-1) attack_attribute_type, isnull(atr.attack_attribute_value,-1) attack_attribute_value, ''
	+ ''	isnull(atr.defend_attribute_0,-1) defend_attribute_0, isnull(atr.defend_attribute_1,-1) defend_attribute_1, ''
	+ ''	isnull(atr.defend_attribute_2,-1) defend_attribute_2, isnull(atr.defend_attribute_3,-1) defend_attribute_3, ''
	+ ''	isnull(atr.defend_attribute_4,-1) defend_attribute_4, isnull(atr.defend_attribute_5,-1) defend_attribute_5 ''
    + ''          from  lin2world_99.dbo.user_item item(nolock) ''
    + ''				left outer join lin2world_99.dbo.user_item_duration dur(nolock) on item.item_id = dur.item_id ''
	+ ''				left outer join lin2world_99.dbo.user_item_attribute atr(nolock) on item.item_id = atr.item_id ''
	+ ''				left outer join lin2world_99.dbo.ItemData dat(nolock) on item.item_type = dat.item_type ''	--CT2 Part2 (기간제아이템이 아닌 경우에만 이동)
	+ ''	where item.item_id in ( ''
	+ ''	select ST_underwear from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_ear from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_ear from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_neck from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_finger from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_finger from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_head from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_hand from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_hand from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_gloves from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_chest from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_legs from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_feet from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_back from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_both_hand from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_hair from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_hair2 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_right_bracelet from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_left_bracelet from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco1 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco2 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco3 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco4 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco5 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''
	+ ''	select ST_deco6 from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ ''	union ''	--CT2 Final
	+ ''	select ST_waist from lin2world_99.dbo.user_slot where char_id = ''+cast(@fromCharId as varchar)+ '') ''	--CT2 Final
    + '' and item.char_id = ''+cast(@fromCharId as varchar)+ '' ''
	+ '' and isnull(dat.is_period, 0) = 0 '' --CT2 Part2 (기간제아이템이 아닌 경우에만 이동)
    +'''''')''
exec (@sql)
if @@error <> 0	goto Err


--2.이동가능아이템
set @sql = ''insert into #migrator_user_item ( ''
	+ ''	item_id,char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse, ''
	+ ''	variation_opt1,variation_opt2,intensive_item_type,'' --interlude
	+ ''           inventory_slot_index,''	--CT1
	+ ''           duration,''	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' ) ''
	+ '' select ''
	+ ''	item_id,''+cast(@char_id as varchar)+'',item_type,amount,enchant,eroded,bless,ident,wished,warehouse, ''
	+ ''	isnull(variation_opt1,0),isnull(variation_opt2,0),isnull(intensive_item_type,0),'' --interlude
	+ ''          inventory_slot_index,''	--CT1
	+ ''          duration, ''	--interlude
	+ ''	attack_attribute_type,attack_attribute_value,'' 	--CT1
	+ ''	defend_attribute_0,defend_attribute_1,defend_attribute_2,'' 	--CT1
	+ ''	defend_attribute_3,defend_attribute_4,defend_attribute_5'' 	--CT1
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select item.*, isnull(dur.duration,-1) duration, ''
              + ''          isnull(atr.attack_attribute_type,-1) attack_attribute_type, isnull(atr.attack_attribute_value,-1) attack_attribute_value, ''
	+ ''	isnull(atr.defend_attribute_0,-1) defend_attribute_0, isnull(atr.defend_attribute_1,-1) defend_attribute_1, ''
	+ ''	isnull(atr.defend_attribute_2,-1) defend_attribute_2, isnull(atr.defend_attribute_3,-1) defend_attribute_3, ''
	+ ''	isnull(atr.defend_attribute_4,-1) defend_attribute_4, isnull(atr.defend_attribute_5,-1) defend_attribute_5 ''
	+ ''	from ''
              + ''          (select * from lin2world_99.dbo.user_item(nolock) where char_id = ''+cast(@fromCharId as varchar)+'' and warehouse = 0) item ''
	+ ''	inner join lin2world_99.dbo.ItemData dat(nolock) on item.item_type = dat.item_type and dat.can_move = 1 ''
	+ ''	and dat.is_period = 0 ''	--CT2 Part2 (기간제아이템이 아닌 경우에만 이동)
	+ ''	left outer join lin2world_99.dbo.user_item_duration dur(nolock) on item.item_id = dur.item_id''
	+ ''          left outer join lin2world_99.dbo.user_item_attribute atr(nolock) on item.item_id = atr.item_id'''') ''
	+ ''where item_id not in (select item_id from #migrator_user_item) ''
exec (@sql)
if @@error <> 0	goto Err



/*
--3.레벨별 아데나 제한 :  MAX(액티브레벨 and 서브잡레벨) 기준으로 아데나 제한이 적용될 경우
-- user_subjob
set @sql = ''insert into user_subjob (''
	+ ''	char_id,hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_subjob(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

--set @level as max level from user_subjob
select @level = max(level) from 
(
        select lev as level from user_data(nolock) where char_id = @char_id
        union
        select level as level from user_subjob(nolock) where char_id = @char_id
) level_data
*/

--3.레벨별 아데나 제한 modified for Event
select @level = lev from user_data(nolock) where char_name = @toCharName

if @level >= 20 and @level <= 51
        begin
                set @adena_limit =  50000000
        end
else if @level >= 52 and @level <= 60
        begin
                set @adena_limit = 100000000
        end
else if @level >= 61 and @level <= 70
        begin
                set @adena_limit = 200000000
        end
else if @level >= 71 and @level <= 75
        begin
                set @adena_limit = 300000000
        end
else if @level >= 76 and @level <= 77
        begin
                set @adena_limit = 400000000
        end
else if @level >= 78 and @level <= 79
        begin
                set @adena_limit = 500000000
        end
else if @level >= 80
        begin
                set @adena_limit = 700000000
        end
else
        begin
                set @adena_limit = 50000000
        end

update #migrator_user_item
set amount = @adena_limit
where item_type = 57 and amount > @adena_limit
if @@error <> 0	goto Err



declare item_cursor cursor for
select item_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse, 
variation_opt1, variation_opt2, intensive_item_type, 	--interlude
inventory_slot_index        --CT1
from #migrator_user_item

open item_cursor
fetch next from item_cursor into @item_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
@variation_opt1, @variation_opt2, @intensive_item_type,	--interlude
@inventory_slot_index --CT1
while @@fetch_status = 0
begin
	insert into user_item (char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse,
	variation_opt1,variation_opt2,intensive_item_type,	--interlude
              inventory_slot_index)	--CT1
	values (@char_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
	@variation_opt1, @variation_opt2, @intensive_item_type,	--interlude
              @inventory_slot_index)	--CT1
              if @@error <> 0	goto Err

	set @new_item_id = scope_identity()
	update #migrator_user_item set new_item_id = @new_item_id where item_id = @item_id
	
	fetch next from item_cursor into @item_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
	@variation_opt1, @variation_opt2, @intensive_item_type,	--interlude
              @inventory_slot_index        --CT1
end

close item_cursor
deallocate item_cursor


--user_item_duration
insert into user_item_duration (item_id, duration)
(select new_item_id, duration from #migrator_user_item where duration > -1)	--interlude

if @@error <> 0	goto Err


--user_item_attribute
insert into user_item_attribute (item_id, attack_attribute_type, attack_attribute_value, 
defend_attribute_0, defend_attribute_1, defend_attribute_2, defend_attribute_3, defend_attribute_4, defend_attribute_5)
(select new_item_id, attack_attribute_type, attack_attribute_value, 
defend_attribute_0, defend_attribute_1, defend_attribute_2, defend_attribute_3, defend_attribute_4, defend_attribute_5 
from #migrator_user_item where attack_attribute_type <> -1)	--CT1


-- user_skill
set @sql = ''insert into user_skill (''
	+ ''	char_id,skill_id,skill_lev,to_end_time,subjob_id,is_lock,''
	+ ''	skill_delay''	-- interlude
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',skill_id,skill_lev,to_end_time,subjob_id,is_lock,''
	+ ''	skill_delay''	-- interlude
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_skill(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- quest
set @sql = ''insert into quest (''
	+ ''	char_id,q1,s1,q2,s2,q3,s3,q4,s4,q5,s5,q6,s6,q7,s7,q8,s8,q9,s9,q10,''
	+ ''	s10,q11,s11,q12,s12,q13,s13,q14,s14,q15,s15,q16,s16,''
	+ ''	j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12,j13,j14,j15,j16,''
	+ ''	s2_1,s2_2,s2_3,s2_4,s2_5,s2_6,s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16,''
	+ ''	q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,''
	+ ''	s2_17,s2_18,s2_19,s2_20,s2_21,s2_22,s2_23,s2_24,s2_25,s2_26,j17,j18,j19,j20,j21,j22,j23,j24,j25,j26''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',q1,s1,q2,s2,q3,s3,q4,s4,q5,s5,q6,s6,q7,s7,q8,s8,q9,s9,q10,''
	+ ''	s10,q11,s11,q12,s12,q13,s13,q14,s14,q15,s15,q16,s16,''
	+ ''	j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12,j13,j14,j15,j16,''
	+ ''	s2_1,s2_2,s2_3,s2_4,s2_5,s2_6,s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16,''
	+ ''	q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,''
	+ ''	s2_17,s2_18,s2_19,s2_20,s2_21,s2_22,s2_23,s2_24,s2_25,s2_26,j17,j18,j19,j20,j21,j22,j23,j24,j25,j26''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.quest(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

--CT2 Final 영지전 관련 퀘스트 19+2 제외 (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q1 = 0,  s1 = 0,  s2_1 = 0,  j1 = 0 where char_id = @char_id and  q1 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q2 = 0,  s2 = 0,  s2_2 = 0,  j2 = 0 where char_id = @char_id and  q2 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q3 = 0,  s3 = 0,  s2_3 = 0,  j3 = 0 where char_id = @char_id and  q3 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q4 = 0,  s4 = 0,  s2_4 = 0,  j4 = 0 where char_id = @char_id and  q4 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q5 = 0,  s5 = 0,  s2_5 = 0,  j5 = 0 where char_id = @char_id and  q5 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q6 = 0,  s6 = 0,  s2_6 = 0,  j6 = 0 where char_id = @char_id and  q6 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q7 = 0,  s7 = 0,  s2_7 = 0,  j7 = 0 where char_id = @char_id and  q7 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q8 = 0,  s8 = 0,  s2_8 = 0,  j8 = 0 where char_id = @char_id and  q8 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set  q9 = 0,  s9 = 0,  s2_9 = 0,  j9 = 0 where char_id = @char_id and  q9 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q10 = 0, s10 = 0, s2_10 = 0, j10 = 0 where char_id = @char_id and q10 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q11 = 0, s11 = 0, s2_11 = 0, j11 = 0 where char_id = @char_id and q11 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q12 = 0, s12 = 0, s2_12 = 0, j12 = 0 where char_id = @char_id and q12 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q13 = 0, s13 = 0, s2_13 = 0, j13 = 0 where char_id = @char_id and q13 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q14 = 0, s14 = 0, s2_14 = 0, j14 = 0 where char_id = @char_id and q14 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q15 = 0, s15 = 0, s2_15 = 0, j15 = 0 where char_id = @char_id and q15 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q16 = 0, s16 = 0, s2_16 = 0, j16 = 0 where char_id = @char_id and q16 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q17 = 0, s17 = 0, s2_17 = 0, j17 = 0 where char_id = @char_id and q17 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q18 = 0, s18 = 0, s2_18 = 0, j18 = 0 where char_id = @char_id and q18 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q19 = 0, s19 = 0, s2_19 = 0, j19 = 0 where char_id = @char_id and q19 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q20 = 0, s20 = 0, s2_20 = 0, j20 = 0 where char_id = @char_id and q20 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q21 = 0, s21 = 0, s2_21 = 0, j21 = 0 where char_id = @char_id and q21 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q22 = 0, s22 = 0, s2_22 = 0, j22 = 0 where char_id = @char_id and q22 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q23 = 0, s23 = 0, s2_23 = 0, j23 = 0 where char_id = @char_id and q23 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q24 = 0, s24 = 0, s2_24 = 0, j24 = 0 where char_id = @char_id and q24 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q25 = 0, s25 = 0, s2_25 = 0, j25 = 0 where char_id = @char_id and q25 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)
update quest set q26 = 0, s26 = 0, s2_26 = 0, j26 = 0 where char_id = @char_id and q26 in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)


-- user_history
set @sql = ''insert into user_history (''
	+ ''	char_name,char_id,log_date,log_action,account_name,create_date''
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',''+cast(@char_id as varchar)+'',log_date,log_action,account_name,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_history(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_log
set @sql = ''insert into user_log (''
	+ ''	char_id,log_id,log_date,log_from,log_to,use_time,subjob_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',log_id,log_date,log_from,log_to,use_time,subjob_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_log(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_comment
set @sql = ''insert into user_comment (''
	+ ''	char_name,char_id,comment,comment_date,writer,deleted''
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',''+cast(@char_id as varchar)+'',comment,comment_date,writer,deleted''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_comment(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- pet_data
set @sql = ''insert into pet_data (''
	+ ''	pet_id,npc_class_id,expoint,nick_name,hp,mp,sp,meal,slot1,slot2,slot3'' --slot3 CT2 Part1
	+ '' )''
	+ '' select''
	+ ''	T2.new_item_id,npc_class_id,expoint,null,hp,mp,sp,meal,slot1,slot2,slot3'' --slot3 CT2 Part1
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.pet_data(nolock) where npc_class_id is not null'''') T1 ''
	+ ''	inner join (select * from #migrator_user_item(nolock)) T2 on T1.pet_id = T2.item_id''
exec (@sql)
if @@error <> 0	goto Err

-- initiate pet_name
update user_item
set eroded = 0
from pet_data
where user_item.item_id = pet_data.pet_id
	and char_id = @char_id


-- user_recipe
set @sql = ''insert into user_recipe (''
	+ ''	char_id,recipe_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',recipe_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_recipe(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_henna
set @sql = ''insert into user_henna (''
	+ ''	char_id,henna_1,henna_2,henna_3,subjob_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',henna_1,henna_2,henna_3,subjob_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_henna(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_sociality
set @sql = ''insert into user_sociality (''
	+ ''	char_id,sociality,used_sulffrage,last_changed''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',sociality,used_sulffrage,last_changed''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_sociality(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_subjob
set @sql = ''insert into user_subjob (''
	+ ''	char_id,hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_subjob(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_ban
set @sql = ''insert into user_ban (''
	+ ''	char_id,status,ban_date,ban_hour,ban_end''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',status,ban_date,ban_hour,ban_end''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_ban(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_punish
set @sql = ''insert into user_punish (''
	+ ''	char_id,punish_id,punish_on,remain_game,remain_real,punish_seconds,punish_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',punish_id,punish_on,remain_game,remain_real,punish_seconds,punish_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_punish(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_nobless
set @sql = ''insert into user_nobless (''
	+ ''	char_id,nobless_type,hero_type,win_count,previous_point,olympiad_point,match_count,words,olympiad_win_count,olympiad_lose_count,history_open,trade_point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',nobless_type,0,0,0,0,0,null,0,0,0,0''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_nobless(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



-- duel_record	--interlude
set @sql = ''insert into duel_record (''
	+ ''	user_id,individual_win,individual_lose,individual_draw,party_win,party_lose,party_draw''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',individual_win,individual_lose,individual_draw,party_win,party_lose,party_draw''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.duel_record(nolock) where user_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- shared_reuse_delays_of_items	--interlude
set @sql = ''insert into shared_reuse_delays_of_items (''
	+ ''	char_id,shared_delay_id,next_available_time''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',shared_delay_id,next_available_time''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.shared_reuse_delays_of_items(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_skill_reuse_delay	--interlude
set @sql = ''insert into user_skill_reuse_delay (''
	+ ''	char_id,skill_id,to_end_time,subjob_id,skill_delay''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',skill_id,to_end_time,subjob_id,skill_delay''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_skill_reuse_delay(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_activeskill	--CT1
set @sql = ''insert into user_activeskill (''
	+ ''	char_id,s1,l1,d1,s2,l2,d2,s3,l3,d3,s4,l4,d4,s5,l5,d5,s6,l6,d6,s7,l7,d7,s8,l8,d8,s9,l9,d9,s10,l10,d10,s11,l11,d11,s12,l12,d12,s13,l13,d13,s14,l14,d14,s15,l15,d15,s16,l16,d16,s17,l17,d17,s18,l18,d18,s19,l19,d19,s20,l20,d20,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,l21,l22,l23,l24,l25,l26,l27,l28,l29,l30,l31,l32,l33,l34,d21,d22,d23,d24,d25,d27,d28,d29,d30,d31,d32,d33,d34,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',s1,l1,d1,s2,l2,d2,s3,l3,d3,s4,l4,d4,s5,l5,d5,s6,l6,d6,s7,l7,d7,s8,l8,d8,s9,l9,d9,s10,l10,d10,s11,l11,d11,s12,l12,d12,s13,l13,d13,s14,l14,d14,s15,l15,d15,s16,l16,d16,s17,l17,d17,s18,l18,d18,s19,l19,d19,s20,l20,d20,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,l21,l22,l23,l24,l25,l26,l27,l28,l29,l30,l31,l32,l33,l34,d21,d22,d23,d24,d25,d27,d28,d29,d30,d31,d32,d33,d34,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_activeskill(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_ui	--CT1
set @sql = ''insert into user_ui (''
	+ ''	char_id,ui_setting_size,ui_setting''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',ui_setting_size,ui_setting''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_ui(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_point	--CT2 Part1
declare @VITIALITY_POINT_TYPE int
set @VITIALITY_POINT_TYPE = 6
declare @DEFAULT_VITIALITY_POINT int
set @DEFAULT_VITIALITY_POINT = 20000

set @sql = ''insert into user_point (''
	+ ''	char_id,point_type,point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',point_type,point''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_point(nolock) where char_id=''+cast(@fromCharId as varchar)
	+ ''   and point_type <> '' + cast(@VITIALITY_POINT_TYPE as varchar) + '''''')''
exec (@sql)
if @@error <> 0	goto Err

-- insert vitality point(20000)

insert into user_point (char_id,point_type,point) 
values(@char_id,@VITIALITY_POINT_TYPE,@DEFAULT_VITIALITY_POINT)


-- user_pvppoint_restrain	--CT2 Part1
set @sql = ''insert into user_pvppoint_restrain (''
	+ ''	char_id,give_count,give_time''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',give_count,give_time''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_pvppoint_restrain(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_nr_memo	--CT2 Part1
set @sql = ''insert into user_nr_memo (''
	+ ''	char_id,quest_id,state1,state2,journal''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',quest_id,state1,state2,journal''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_nr_memo(nolock) where char_id=''+cast(@fromCharId as varchar)
	+ '' and quest_id not in (717,718,719,720,721,722,723,724,725,729,730,731,732,733,734,735,736,737,738,728,739)'' --CT2 Final 영지전 관련 퀘스트 19+2 제외
	+ '''''')''
exec (@sql)
if @@error <> 0	goto Err


--user_bookmark --CT2 Part2
set @sql = ''insert into user_bookmark (''
	+ ''	char_id,slot_id,pos_x,pos_y,pos_z,slot_title,icon_id,icon_title''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',slot_id,pos_x,pos_y,pos_z,slot_title,icon_id,icon_title''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_bookmark(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


--user_pccafe_point --CT2 Part2
set @sql = ''insert into user_pccafe_point (''
	+ ''	char_id,point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',point''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_pccafe_point(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


--user_name_color --CT2 Part2
set @sql = ''insert into user_name_color (''
	+ ''	char_id,color_rgb,nickname_color_rgb''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',color_rgb,nickname_color_rgb''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.user_name_color(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


--bot_report --CT2 Part2, CT2 Final
set @sql = ''insert into bot_report (''
	+ ''	char_id,reported,reported_date,bot_admin''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',reported,reported_date,bot_admin''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world_99.dbo.bot_report(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



--##### 추가작업
--##### 1.피씨방포인트(user_pccafe_point) 2만점 지급
declare @point int
set @point = 20000

update user_pccafe_point set point = point + @point where char_id = @char_id
if @@rowcount = 0
begin
	insert into user_pccafe_point (char_id, point)
		values (@char_id, @point)
end

--##### 2.그레시아증표(item_type = 14607) 1개 지급(캐릭터 인벤토리에)
insert into user_item (char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse)
	values (@char_id, 14607, 1, 0, 0, 0, 0, 0, 0)



drop table #migrator_user_item
return @char_id

Err:
	if isnull(@char_id, 0) <> 0
	begin
		delete from user_data where char_id = @char_id
		delete from user_slot where char_id = @char_id	--CT1
		delete from user_skill where char_id = @char_id
		delete from quest where char_id = @char_id
		delete from user_history where char_id = @char_id
        		delete from user_log where char_id = @char_id
		delete from user_comment where char_id = @char_id
		delete from pet_data where pet_id in (select item_id from user_item where char_id = @char_id and item_type in (2375,3500,3501,3502,4422,4423,4424,4425,6648,6649,6650))
		delete from user_recipe where char_id = @char_id
		delete from user_henna where char_id = @char_id
		delete from user_sociality where char_id = @char_id
		delete from user_subjob where char_id = @char_id
		delete from user_ban where char_id = @char_id
		delete from user_punish where char_id = @char_id
		delete from user_nobless where char_id = @char_id
		delete from user_item_duration where item_id in (select item_id from user_item where char_id = @char_id)	--interlude
                            delete from user_item_attribute where item_id in (select item_id from user_item where char_id = @char_id)	--CT1
		delete from user_item where char_id = @char_id
		delete from duel_record where user_id = @char_id	--interlude
		delete from shared_reuse_delays_of_items where char_id = @char_id	--interlude
		delete from user_skill_reuse_delay where char_id = @char_id	--interlude
		delete from user_activeskill where char_id = @char_id	--interlude
		delete from user_ui where char_id = @char_id	--CT1
		delete from user_point where char_id = @char_id	--CT2 Part1
		delete from user_pvppoint_restrain where char_id = @char_id	--CT2 Part1
		delete from user_nr_memo where char_id = @char_id	--CT2 Part1
		delete from user_bookmark where char_id = @char_id	--CT2 Part2
		delete from user_pccafe_point where char_id = @char_id	--CT2 Part2
		delete from bot_report where char_id = @char_id	--CT2 Part2
	end

	print(@sql)

	drop table #migrator_user_item
	return 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WriteHeroWords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_WriteHeroWords]
(
@char_id INT,
@hero_words VARCHAR(128)
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET words = @hero_words
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InitAllOlympiadPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_InitAllOlympiadPoint]
(
@season INT,
@step INT,
@init_point INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET olympiad_point = @init_point

UPDATE olympiad
SET step = @step
WHERE season = @season

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MoveCharacter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_MoveCharacter
desc:	migrate to this server from 7th server
exam:	exec lin_MoveCharacter ''''''server'''';''''login_id'''';''''password'''''', 1, ''from_name'', ''to_name''

history:	2006-11-20	created by btwinuni
*/
create procedure [dbo].[lin_MoveCharacter]
	@db_info	varchar(64),	-- to 7th server
	@fromCharId	int,		-- character of 7th server
	@fromCharName	nvarchar(24),	-- character of 7th server
	@toCharName	nvarchar(24)	-- character of this server
as

set nocount on

declare
	@char_id	int,
	@item_id		int,
	@item_type	int,
	@amount	int,
	@enchant	int,
	@eroded	int,
	@bless		int,
	@ident		int,
	@wished	int,
	@warehouse	int,
	@variation_opt1	int,
	@variation_opt2	int,
	@intensive_item_type	int,
	@new_item_id	int,
	@sql		varchar(4000)

-- user_data
set @sql = ''insert into user_data (''
	+ ''	char_name,account_name,account_id,pledge_id,builder,gender,race,class,world,''
	+ ''	xloc,yloc,zloc,IsInVehicle,HP,MP,SP,Exp,Lev,align,PK,PKpardon,Duel,''
	+ ''	ST_underware,ST_right_ear,ST_left_ear,ST_neck,ST_right_finger,ST_left_finger,ST_head,''
	+ ''	ST_right_hand,ST_left_hand,ST_gloves,ST_chest,ST_legs,ST_feet,ST_back,ST_both_hand,''
	+ ''	create_date,login,logout,quest_flag,nickname,power_flag,''
	+ ''	pledge_dismiss_time,pledge_leave_time,pledge_leave_status,max_hp,max_mp,quest_memo,''
	+ ''	face_index,hair_shape_index,hair_color_index,use_time,temp_delete_date,''
	+ ''	pledge_ousted_time,pledge_withdraw_time,surrender_war_id,drop_exp,subjob_id,ssq_dawn_round,''
	+ ''	cp,max_cp,ST_hair,subjob0_class,subjob1_class,subjob2_class,subjob3_class,pledge_type,''
	+ ''	ST_hair2,grade_id,academy_pledge_id,''
	+ ''	item_duration''	--interlude
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',account_name,account_id,pledge_id,builder,gender,race,class,world,''
	+ ''	xloc,yloc,zloc,IsInVehicle,HP,MP,SP,Exp,Lev,align,PK,PKpardon,Duel,''
	+ ''	0,0,0,0,0,0,0,''		-- reset equipped item
	+ ''	0,0,0,0,0,0,0,0,''		-- reset equipped item
	+ ''	create_date,login,logout,quest_flag,nickname,power_flag,''
	+ ''	pledge_dismiss_time,pledge_leave_time,pledge_leave_status,max_hp,max_mp,quest_memo,''
	+ ''	face_index,hair_shape_index,hair_color_index,use_time,temp_delete_date,''
	+ ''	pledge_ousted_time,pledge_withdraw_time,surrender_war_id,drop_exp,subjob_id,ssq_dawn_round,''
	+ ''	cp,max_cp,0,subjob0_class,subjob1_class,subjob2_class,subjob3_class,pledge_type,''
	+ ''	0,grade_id,academy_pledge_id,''
	+ ''	item_duration''	--interlude
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_data(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- set @char_id to char_id of migrator
select @char_id = char_id from user_data(nolock) where char_name = @toCharName

-- user_item & user_item_duration
create table #migrator_user_item
(
	item_id		int,
	char_id		int,
	item_type	int,
	amount		int,
	enchant		int,
	eroded		int,
	bless		int,
	ident		int,
	wished		int,
	warehouse	int,
	variation_opt1	int,	--interlude
	variation_opt2	int,	--interlude
	intensive_item_type	int,	--interlude
	duration		int,	--interlude
	new_item_id	int
)


set @sql = ''insert into #migrator_user_item (''
	+ ''	item_id,char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse,''
	+ ''	variation_opt1,variation_opt2,intensive_item_type,duration''	--interlude
	+ '' )''
	+ '' select''
	+ ''	item_id,''+cast(@char_id as varchar)+'',item_type,amount,enchant,eroded,bless,ident,wished,warehouse,''
	+ ''	variation_opt1,variation_opt2,intensive_item_type,duration''	--interlude
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select item.*, isnull(dur.duration,-1) duration from lin2world.dbo.user_item item(nolock) left outer join lin2world.dbo.user_item_duration dur(nolock) on item.item_id = dur.item_id where item.char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)

if @@error <> 0	goto Err


declare item_cursor cursor for
select item_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse, 
variation_opt1, variation_opt2, intensive_item_type 	--interlude
from #migrator_user_item

open item_cursor
fetch next from item_cursor into @item_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
@variation_opt1, @variation_opt2, @intensive_item_type	--interlude

while @@fetch_status = 0
begin
	insert into user_item (char_id,item_type,amount,enchant,eroded,bless,ident,wished,warehouse,
	variation_opt1,variation_opt2,intensive_item_type)	--interlude
	values (@char_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
	@variation_opt1, @variation_opt2, @intensive_item_type)	--interlude

	set @new_item_id = @@identity
	update #migrator_user_item set new_item_id = @new_item_id where item_id = @item_id
	
	fetch next from item_cursor into @item_id, @item_type, @amount, @enchant, @eroded, @bless, @ident, @wished, @warehouse, 
	@variation_opt1, @variation_opt2, @intensive_item_type	--interlude
end

close item_cursor
deallocate item_cursor

--user_item_duration
insert into user_item_duration (item_id, duration)
(select new_item_id, duration from #migrator_user_item where duration > -1)	--interlude

if @@error <> 0	goto Err


-- user_skill
set @sql = ''insert into user_skill (''
	+ ''	char_id,skill_id,skill_lev,to_end_time,subjob_id,is_lock,''
	+ ''	skill_delay''	-- interlude
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',skill_id,skill_lev,to_end_time,subjob_id,is_lock,''
	+ ''	skill_delay''	-- interlude
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_skill(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- quest
set @sql = ''insert into quest (''
	+ ''	char_id,q1,s1,q2,s2,q3,s3,q4,s4,q5,s5,q6,s6,q7,s7,q8,s8,q9,s9,q10,''
	+ ''	s10,q11,s11,q12,s12,q13,s13,q14,s14,q15,s15,q16,s16,''
	+ ''	j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12,j13,j14,j15,j16,''
	+ ''	s2_1,s2_2,s2_3,s2_4,s2_5,s2_6,s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16,''
	+ ''	q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,''
	+ ''	s2_17,s2_18,s2_19,s2_20,s2_21,s2_22,s2_23,s2_24,s2_25,s2_26,j17,j18,j19,j20,j21,j22,j23,j24,j25,j26''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',q1,s1,q2,s2,q3,s3,q4,s4,q5,s5,q6,s6,q7,s7,q8,s8,q9,s9,q10,''
	+ ''	s10,q11,s11,q12,s12,q13,s13,q14,s14,q15,s15,q16,s16,''
	+ ''	j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12,j13,j14,j15,j16,''
	+ ''	s2_1,s2_2,s2_3,s2_4,s2_5,s2_6,s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16,''
	+ ''	q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,''
	+ ''	s2_17,s2_18,s2_19,s2_20,s2_21,s2_22,s2_23,s2_24,s2_25,s2_26,j17,j18,j19,j20,j21,j22,j23,j24,j25,j26''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.quest(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_history
set @sql = ''insert into user_history (''
	+ ''	char_name,char_id,log_date,log_action,account_name,create_date''
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',''+cast(@char_id as varchar)+'',log_date,log_action,account_name,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_history(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_log
set @sql = ''insert into user_log (''
	+ ''	char_id,log_id,log_date,log_from,log_to,use_time,subjob_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',log_id,log_date,log_from,log_to,use_time,subjob_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_log(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_comment
set @sql = ''insert into user_comment (''
	+ ''	char_name,char_id,comment,comment_date,writer,deleted''
	+ '' )''
	+ '' select''
	+ ''	''''''+@toCharName+'''''',''+cast(@char_id as varchar)+'',comment,comment_date,writer,deleted''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_comment(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- pet_data
set @sql = ''insert into pet_data (''
	+ ''	pet_id,npc_class_id,expoint,nick_name,hp,mp,sp,meal,slot1,slot2''
	+ '' )''
	+ '' select''
	+ ''	T2.new_item_id,npc_class_id,expoint,null,hp,mp,sp,meal,slot1,slot2''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.pet_data(nolock)'''') T1, ''
	+ ''	(select * from #migrator_user_item(nolock) where item_type in (2375,3500,3501,3502,4422,4423,4424,4425,6648,6649,6650)) T2''
	+ '' where item_id = pet_id and npc_class_id is not null''
exec (@sql)
if @@error <> 0	goto Err

-- initiate pet_name
update user_item set eroded = 0 where char_id = @char_id and item_type in (2375,3500,3501,3502,4422,4423,4424,4425,6648,6649,6650)

-- user_recipe
set @sql = ''insert into user_recipe (''
	+ ''	char_id,recipe_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',recipe_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_recipe(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_henna
set @sql = ''insert into user_henna (''
	+ ''	char_id,henna_1,henna_2,henna_3,subjob_id''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',henna_1,henna_2,henna_3,subjob_id''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_henna(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_sociality
set @sql = ''insert into user_sociality (''
	+ ''	char_id,sociality,used_sulffrage,last_changed''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',sociality,used_sulffrage,last_changed''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_sociality(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_subjob
set @sql = ''insert into user_subjob (''
	+ ''	char_id,hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',hp,mp,sp,exp,level,henna_1,henna_2,henna_3,subjob_id,create_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_subjob(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_ban
set @sql = ''insert into user_ban (''
	+ ''	char_id,status,ban_date,ban_hour,ban_end''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',status,ban_date,ban_hour,ban_end''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_ban(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_punish
set @sql = ''insert into user_punish (''
	+ ''	char_id,punish_id,punish_on,remain_game,remain_real,punish_seconds,punish_date''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',punish_id,punish_on,remain_game,remain_real,punish_seconds,punish_date''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_punish(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- user_nobless
set @sql = ''insert into user_nobless (''
	+ ''	char_id,nobless_type,hero_type,win_count,previous_point,olympiad_point,match_count,words,olympiad_win_count,olympiad_lose_count,history_open,trade_point''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',nobless_type,0,0,0,0,0,null,0,0,0,0''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_nobless(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



-- duel_record	--interlude
set @sql = ''insert into duel_record (''
	+ ''	user_id,individual_win,individual_lose,individual_draw,party_win,party_lose,party_draw''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',individual_win,individual_lose,individual_draw,party_win,party_lose,party_draw''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.duel_record(nolock) where user_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err

-- shared_reuse_delays_of_items	--interlude
set @sql = ''insert into shared_reuse_delays_of_items (''
	+ ''	char_id,shared_delay_id,next_available_time''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',shared_delay_id,next_available_time''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.shared_reuse_delays_of_items(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err


-- user_skill_reuse_delay	--interlude
set @sql = ''insert into user_skill_reuse_delay (''
	+ ''	char_id,skill_id,to_end_time,subjob_id,skill_delay''
	+ '' )''
	+ '' select''
	+ ''	''+cast(@char_id as varchar)+'',skill_id,to_end_time,subjob_id,skill_delay''
	+ '' from openrowset(''''SQLOLEDB'''', ''+@db_info+'',''
	+ ''	''''select * from lin2world.dbo.user_skill_reuse_delay(nolock) where char_id=''+cast(@fromCharId as varchar)+'''''')''
exec (@sql)
if @@error <> 0	goto Err



drop table #migrator_user_item
return @char_id

Err:
	if isnull(@char_id, 0) <> 0
	begin
		delete from user_data where char_id = @char_id
		delete from user_skill where char_id = @char_id
		delete from quest where char_id = @char_id
		delete from user_history where char_id = @char_id
		delete from user_log where char_id = @char_id
		delete from user_comment where char_id = @char_id
		delete from pet_data where pet_id in (select item_id from user_item where char_id = @char_id and item_type in (2375,3500,3501,3502,4422,4423,4424,4425,6648,6649,6650))
		delete from user_recipe where char_id = @char_id
		delete from user_henna where char_id = @char_id
		delete from user_sociality where char_id = @char_id
		delete from user_subjob where char_id = @char_id
		delete from user_ban where char_id = @char_id
		delete from user_punish where char_id = @char_id
		delete from user_nobless where char_id = @char_id
		delete from user_item_duration where item_id in (select item_id from user_item where char_id = @char_id)	--interlude
		delete from user_item where char_id = @char_id
		delete from duel_record where user_id = @char_id	--interlude
		delete from shared_reuse_delays_of_items where char_id = @char_id	--interlude
		delete from user_skill_reuse_delay where char_id = @char_id	--interlude

	end

	drop table #migrator_user_item
	return 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAllNobless]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetAllNobless]
AS
SELECT char_id, nobless_type, hero_type, win_count, previous_point, olympiad_point, match_count, olympiad_win_count, olympiad_lose_count, trade_point FROM user_nobless

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MainSubJobExchange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_MainSubJobExchange 
desc:   exchange mainjob and subjob 
exam:   exec lin_MainSubJobExchange ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2009-01-06      created by neo 
*/ 


CREATE procedure [dbo].[lin_MainSubJobExchange] 
        @char_id		int,            -- character id 
		@subjob_id      int				-- subjob id 
as 
 
set nocount on 
 
declare 
		@sql					nvarchar(4000),
		@class					int,
        @gender					int, 
        @cursed_weapon			int,
        @db_info				nvarchar(64),
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				bigint,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int,
		@counter_race			int,
		@subjob0_class			int,
		@subjob1_class			int,
		@subjob2_class			int,
		@subjob3_class			int

		
	--#조건체크 시작
		-- main class is warsmith(57,118) or overload(51,115)(-5006)
		set @class = -1
		select @class = subjob0_class from user_data (nolock) where char_id = @char_id
		if @class in (-1, 57, 118, 51, 115)
		begin
			set @err = -5006
			goto END_TRAN
		end
		-- sub class is hidden class(135,136)(-5008)
		set @class = -1
		if @subjob_id = 1
		begin
			select @class = subjob1_class from user_data (nolock) where char_id = @char_id
		end
		else if @subjob_id = 2
		begin
			select @class = subjob2_class from user_data (nolock) where char_id = @char_id
		end
		else if @subjob_id = 3
		begin
			select @class = subjob3_class from user_data (nolock) where char_id = @char_id
		end
		if @class in (-1, 135, 136)
		begin
            set @err = -5008
			goto END_TRAN
		end
		-- if race of subjob is darkelf then no elf allowed in other subjob, if elf then no darkelf(-5009)
		set @counter_race = -1
		select @race = race from class_by_race (nolock) where class = @class
		if @race in (1, 2)
		begin
			if @race = 1
				begin
					set @counter_race = 2
				end
			else
				begin
					set @counter_race = 1
				end
			
			if @counter_race in (select race from class_by_race (nolock) where class in 
					(
						select subjob1_class from user_data (nolock) where char_id = @char_id
							union all
						select subjob2_class from user_data (nolock) where char_id = @char_id
							union all
						select subjob3_class from user_data (nolock) where char_id = @char_id
					)
				)
			begin
				set @err = -5009
				goto END_TRAN
			end
		end					
	--#조건체크 끝

		-- shortcut_data / user_skill / user_skill_reuse_delay / user_subjob / user_data / user_henna / user_log
		begin tran
			set @err = 0

			-- 안전빵: 현재 상태 저장
			select @bak_hp = hp, @bak_mp = mp, @bak_sp = sp, @bak_exp = exp, @bak_lev = lev, @bak_subjob_id = subjob_id, @quest = quest_flag from user_data (nolock) where char_id = @char_id
			select @henna1 = henna_1, @henna2 = henna_2, @henna3 = henna_3 from user_henna (nolock) where char_id = @char_id
			update user_subjob
			set hp = @bak_hp,
				mp = @bak_mp,
				sp = @bak_sp,
				exp = @bak_exp,
				level = @bak_lev,
				henna_1 = @henna1,
				henna_2 = @henna2,
				henna_3 = @henna3
			where char_id = @char_id and subjob_id = @bak_subjob_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- delete subjob skill from main class
			delete from user_skill where char_id = @char_id and subjob_id = 0 and (skill_id between 631 and 634 or skill_id between 637 and 648 or skill_id between 650 and 662 or skill_id between 799 and 804 or skill_id between 1489 and 1491)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- delete item for subjob skill book
			delete from user_item where char_id = @char_id and warehouse in (0,1) and (item_type between 10280 and 10294 or item_type = 10612)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- initiate quest flag for subjob skill (이거 테스트 백만번 해야함!!!)
			-- # of quest for subjob skill :255~266
			set @i = 255

			while @i <= 266
			begin
				set @quest = dbo.SetBitFlag (@quest, @i, 0)
				set @i = @i + 1
			end

			update user_data
			set quest_flag = @quest
			where char_id = @char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- initiate brother_chained_to_you quest (422)
			set @i = 1
			while @i <= 26
			begin
				set @sql = ''update quest''
						 + '' set q''+cast(@i as nvarchar)+''=0, s''+cast(@i as nvarchar)+''=0, s2_''+cast(@i as nvarchar)+''=0, j''+cast(@i as nvarchar)+''=0''
						 + '' where char_id=''+cast(@char_id as nvarchar)
						 + ''	and q''+cast(@i as nvarchar)+''=422''
				exec (@sql)

				if @@rowcount > 0
				begin
					delete from user_item where char_id = @char_id and warehouse in (0,1) and item_type in (4326,4327,4328,4329,4330,4331,4425,4426)
					break
				end

				set @i = @i + 1
			end

			-- ### exchange data
			-- shortcut_data
			update shortcut_data
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN
			
			-- user_skill
			update user_skill
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_skill_reuse_delay
			update user_skill_reuse_delay
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_subjob
			update user_subjob
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_data
			select @subjob0_class = subjob0_class, @subjob1_class = subjob1_class, @subjob2_class = subjob2_class, @subjob3_class = subjob3_class 
			from user_data (nolock) where char_id = @char_id
			if @subjob0_class = -1
			begin
				set @err = 1
				goto END_TRAN
			end

			if @subjob_id = 1
			begin
				update user_data set subjob0_class = @subjob1_class where char_id = @char_id
				update user_data set subjob1_class = @subjob0_class where char_id = @char_id
			end
			else if @subjob_id = 2
			begin
				update user_data set subjob0_class = @subjob2_class where char_id = @char_id
				update user_data set subjob2_class = @subjob0_class where char_id = @char_id
			end
			else if @subjob_id = 3
			begin
				update user_data set subjob0_class = @subjob3_class where char_id = @char_id
				update user_data set subjob3_class = @subjob0_class where char_id = @char_id
			end
			set @err = @@error
			if @err <> 0	goto END_TRAN

			select @bak_hp = hp, @bak_mp = mp, @bak_sp = sp, @bak_exp = exp, @bak_lev = level, @henna1 = henna_1, @henna2 = henna_2, @henna3 = henna_3 from user_subjob (nolock) where char_id = @char_id and subjob_id = @bak_subjob_id
			select @race = race, @gender = sex from class_by_race (nolock) where class = (select subjob0_class from user_data (nolock) where char_id = @char_id)


			update user_data
			set race = @race,
				class = case subjob_id when 0 then subjob0_class when 1 then subjob1_class when 2 then subjob2_class when 3 then subjob3_class end,
				gender = case when @gender = -1 then gender & 1 else @gender end,
				face_index = 0,
				hair_shape_index = 0,
				hair_color_index = 0,
				hp = @bak_hp,
				mp = @bak_mp,
				sp = @bak_sp,
				exp = @bak_exp,
				lev = @bak_lev
			where char_id = @char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_henna
			update user_henna
			set henna_1 = @henna1,
				henna_2 = @henna2,
				henna_3 = @henna3
			where char_id = @char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- olympiad point 초기화
			update user_nobless
			set olympiad_point = 0,
				previous_point = 0
			where char_id = @char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_log
			update user_log
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN
			

END_TRAN:
			if @err = 0
			begin
				commit tran
			end
			else
			begin
				rollback tran
			end
		
return @err

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveHeroType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveHeroType]
(
@char_id INT,
@hero_type INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET hero_type = @hero_type
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetHistoryOpen]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetHistoryOpen]
(
@char_id AS INT,
@history_open AS TINYINT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET history_open = @history_open
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAllHeroes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetAllHeroes]
AS
SELECT ud.subjob0_class, un.char_id  FROM user_nobless un, user_data ud 
WHERE un.hero_type <> 0 AND un.char_id = ud.char_id AND ud.account_id > -1
ORDER BY win_count DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_NominateHeroes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE   PROCEDURE [dbo].[lin_NominateHeroes]
(
@now_season INT,
@new_step INT,
@new_season_start_time INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET hero_type = 0

CREATE TABLE #olympiad_participant
	(char_id INT, main_class INT, match_count INT, olympiad_point INT, olympiad_win_count INT, 
	win_ratio FLOAT, olympiad_lose_count INT)

CREATE TABLE #hero_candidate
	(char_id INT, main_class INT, match_count INT, olympiad_point INT, olympiad_win_count INT, 
	win_ratio FLOAT, olympiad_lose_count INT, team_win_count INT, ranking INT)

-- 일단 한번이라도 참가한 9회이상 참가한 사람은 전부 골라내서
-- 나중에 영웅선발 할때는 여기에 1승이상, 1점이상인 애들을 대상으로 하고
-- 점수 줄 때는 그냥 9회이상 참가했으면 전부 준다.

-- 남여 soul_hound를 제외하고 전부
INSERT INTO #olympiad_participant 
	SELECT un.char_id, ud.subjob0_class, un.match_count, un.olympiad_point , un.olympiad_win_count, 
		CAST(un.olympiad_win_count AS FLOAT) / CAST(un.match_count AS FLOAT), un.olympiad_lose_count
	FROM user_nobless un, user_data ud
	WHERE un.char_id = ud.char_id AND un.match_count >= 9
	and ((ud.subjob0_class >= 88 and ud.subjob0_class <= 118) or ud.subjob0_class = 131 or ud.subjob0_class = 134)
	and ud.account_id > -1
-- 남여 soul_hound는 일단 남 soul_hound로 몰아버리자.
INSERT INTO #olympiad_participant 
	SELECT un.char_id, 132, un.match_count, un.olympiad_point , un.olympiad_win_count, 
		CAST(un.olympiad_win_count AS FLOAT) / CAST(un.match_count AS FLOAT), un.olympiad_lose_count
	FROM user_nobless un, user_data ud 
	WHERE un.char_id = ud.char_id AND un.match_count >= 9
	and (ud.subjob0_class = 132 or ud.subjob0_class = 133)
	and ud.account_id > -1

-- 일단 순서를 매겨주자 : 다음 시즌 trade_point 지급용
INSERT INTO #hero_candidate
	SELECT op.char_id, op.main_class, op.match_count, op.olympiad_point, op.olympiad_win_count, op.win_ratio, 
		op.olympiad_lose_count, 0, 
		ROW_NUMBER() OVER 
			(ORDER BY op.olympiad_point DESC, op.olympiad_win_count DESC, op.win_ratio DESC, op.match_count DESC, 
			ud.exp DESC, op.char_id)
	FROM #olympiad_participant op, user_data ud
	WHERE op.char_id = ud.char_id
	ORDER BY op.olympiad_point DESC, op.olympiad_win_count DESC, op.win_ratio DESC, op.match_count DESC, 
		ud.exp DESC, op.char_id

-- 팀전 승리 횟수를 업데이트 - 영웅 선발용
CREATE TABLE #team_win_table
	(char_id INT, win_count INT)

INSERT INTO #team_win_table
	SELECT om.char_id, count(om.char_id) 
	FROM olympiad_match om
	WHERE om.game_rule = 0
	GROUP BY om.char_id, om.game_rule

UPDATE hc
	SET team_win_count = win_count
	FROM #hero_candidate hc JOIN #team_win_table tw ON (hc.char_id = tw.char_id)

-- 영웅될 놈 선별하기 시작
CREATE TABLE #highest_score (main_class INT, olympiad_point INT, match_count INT, olympiad_win_count INT, win_ratio FLOAT)

DECLARE @hero_candidate_class INT
DECLARE hero_candidate_cursor CURSOR FOR
SELECT DISTINCT main_class FROM #hero_candidate

OPEN hero_candidate_cursor

FETCH NEXT FROM hero_candidate_cursor INTO @hero_candidate_class

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @olympiad_point_max INT
	DECLARE @olympiad_win_max INT
	DECLARE @win_ratio_max FLOAT
	DECLARE @team_win_max INT
	DECLARE @count1 INT
	DECLARE @count2 INT
	DECLARE @count3 INT
	DECLARE @count4 INT

	SELECT @olympiad_point_max = max(olympiad_point) FROM #hero_candidate 
	WHERE main_class = @hero_candidate_class

	SELECT @olympiad_win_max = max(olympiad_win_count) FROM #hero_candidate 
	WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max

	SELECT @win_ratio_max = max(win_ratio) FROM #hero_candidate 
	WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
		AND olympiad_win_count = @olympiad_win_max

	SELECT @team_win_max = max(team_win_count) FROM #hero_candidate 
	WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
		AND olympiad_win_count = @olympiad_win_max AND win_ratio = @win_ratio_max

	-- for test
	--SELECT @olympiad_point_max AS C1, @olympiad_win_max AS C2, @win_ratio_max AS C3

	-- 최고 포인트인 사람이 1명일때만 영웅 등극 가능
	-- CH5에서 변경!! 		1. 최다포인트	2. 다승	3. 최고승률	4. 팀전승수
	SELECT @count1 = count(*) FROM #hero_candidate 
		WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max
	SELECT @count2 = count(*) FROM #hero_candidate 
		WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
		AND olympiad_win_count = @olympiad_win_max
	SELECT @count3 = count(*) FROM #hero_candidate 
		WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
		AND olympiad_win_count = @olympiad_win_max AND win_ratio = @win_ratio_max
	SELECT @count4 = count(*) FROM #hero_candidate 
		WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
		AND olympiad_win_count = @olympiad_win_max AND win_ratio = @win_ratio_max AND team_win_count = @team_win_max

	IF @count1 =1
	  BEGIN
		INSERT INTO #highest_score
			SELECT main_class, olympiad_point, match_count, olympiad_win_count, win_ratio
			FROM #hero_candidate 
			WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max
	  END
	ELSE
	IF @count2 = 1
	 BEGIN
		INSERT INTO #highest_score
			SELECT main_class, olympiad_point, match_count, olympiad_win_count, win_ratio
			FROM #hero_candidate 
			WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
			AND olympiad_win_count = @olympiad_win_max
	 END
	ELSE
	IF @count3 = 1
	 BEGIN
		INSERT INTO #highest_score
			SELECT main_class, olympiad_point, match_count, olympiad_win_count, win_ratio
			FROM #hero_candidate 
			WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
			AND olympiad_win_count = @olympiad_win_max AND win_ratio = @win_ratio_max
	 END
	ELSE
	IF @count4 = 1
	 BEGIN
		INSERT INTO #highest_score
			SELECT main_class, olympiad_point, match_count, olympiad_win_count, win_ratio
			FROM #hero_candidate 
			WHERE main_class = @hero_candidate_class AND olympiad_point = @olympiad_point_max 
			AND olympiad_win_count = @olympiad_win_max AND win_ratio = @win_ratio_max 
			AND team_win_count = @team_win_max
	 END

	FETCH NEXT FROM hero_candidate_cursor INTO @hero_candidate_class
END

CLOSE hero_candidate_cursor
DEALLOCATE hero_candidate_cursor

CREATE TABLE #highest_score_nobless (char_id INT, main_class INT)
INSERT INTO #highest_score_nobless
	SELECT c.char_id, c.main_class FROM #hero_candidate c, #highest_score s
		WHERE c.main_class = s.main_class AND c.olympiad_point = s.olympiad_point AND c.match_count = s.match_count AND c.olympiad_win_count = s.olympiad_win_count AND c.win_ratio = s.win_ratio

CREATE TABLE #hero (char_id INT, main_class INT)
INSERT INTO #hero
	SELECT char_id, main_class  FROM #highest_score_nobless WHERE main_class IN (SELECT main_class FROM #highest_score_nobless GROUP BY main_class HAVING COUNT(main_class) = 1)

UPDATE user_nobless
SET hero_type = 1, win_count = win_count+1
WHERE char_id IN (SELECT char_id FROM #hero)

UPDATE user_nobless
SET previous_point = olympiad_point, trade_point = 0
--SET previous_point = olympiad_point, trade_point = olympiad_point

-- trade point 산정
DECLARE @total_participants INT
DECLARE @rank1 INT	-- 상위 1%
DECLARE @rank2 INT	-- 상위 10%
DECLARE @rank3 INT	-- 상위 25%
DECLARE @rank4 INT	-- 상위 50%

DECLARE @point_rank1 INT
DECLARE @point_rank2 INT
DECLARE @point_rank3 INT
DECLARE @point_rank4 INT
DECLARE @point_rank5 INT

SET @point_rank1 = 120
SET @point_rank2 = 80
SET @point_rank3 = 55
SET @point_rank4 = 35
SET @point_rank5 = 20

SELECT @total_participants = MAX(ranking) FROM #hero_candidate 
SET @rank1 = @total_participants / 100
IF @rank1 < 1 BEGIN SET @rank1 = 1 END
SET @rank2 = @total_participants / 10
IF @rank2 < 1 BEGIN SET @rank2 = 1 END
SET @rank3 = @total_participants / 4
IF @rank3 < 1 BEGIN SET @rank3 = 1 END
SET @rank4 = @total_participants / 2
IF @rank4 < 1 BEGIN SET @rank4 = 1 END

UPDATE un
	SET trade_point = 
	(
	CASE
		WHEN hc.ranking <= @rank1 THEN @point_rank1
		WHEN hc.ranking <= @rank2 THEN @point_rank2
		WHEN hc.ranking <= @rank3 THEN @point_rank3
		WHEN hc.ranking <= @rank4 THEN @point_rank4
		ELSE @point_rank5
	END
	)
	FROM user_nobless un JOIN #hero_candidate hc ON (un.char_id = hc.char_id)

UPDATE user_nobless
SET olympiad_point = 0, match_count = 0, olympiad_win_count = 0, olympiad_lose_count = 0

INSERT INTO olympiad_result
	SELECT @now_season, main_class, char_id, olympiad_point, match_count, olympiad_win_count, olympiad_lose_count,
		team_win_count, ranking
	FROM #hero_candidate

INSERT INTO olympiad
	(step, season_start_time) VALUES (@new_step, @new_season_start_time)

SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddAllOlympiadBonusPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_AddAllOlympiadBonusPoint]
(
@season INT,
@step INT,
@bonus_point INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET olympiad_point = olympiad_point + @bonus_point

UPDATE olympiad
SET step = @step
WHERE season = @season

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetOlympiadPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ResetOlympiadPoint]
(
@give_point INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET previous_point = olympiad_point

UPDATE user_nobless
SET olympiad_point = @give_point

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetNoblessById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetNoblessById]
(
@char_id AS INT
)
AS
SELECT nobless_type, hero_type, win_count, previous_point, olympiad_point, match_count, olympiad_win_count, olympiad_lose_count, history_open, trade_point FROM user_nobless WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddOlympiadPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_AddOlympiadPoint]
(
@char_id INT,
@diff INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET olympiad_point = olympiad_point + @diff
WHERE char_id = @char_id

DECLARE @olympiad_point INT
SELECT @olympiad_point = olympiad_point FROM user_nobless WHERE char_id = @char_id
IF @olympiad_point < 0
BEGIN
	UPDATE user_nobless
	SET olympiad_point = 0
	WHERE char_id = @char_id
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ReloadOlympiadPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ReloadOlympiadPoint]
(
@char_id INT
)
AS
SELECT olympiad_point FROM user_nobless WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetHeroByClassId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetHeroByClassId]
	@class_id	int
AS
SELECT un.char_id  
FROM user_nobless un, user_data ud 
WHERE un.char_id = ud.char_id 
	AND un.hero_type <> 0 
	AND ud.subjob0_class = @class_id
ORDER BY win_count DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_NewNobless]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_NewNobless]
(
@char_id INT,
@nobless_type INT,
@olympiad_point INT
)
AS
SET NOCOUNT ON

INSERT user_nobless
(char_id,  nobless_type, olympiad_point)
VALUES
(@char_id, @nobless_type, @olympiad_point)

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeletePreviousOlympiadPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeletePreviousOlympiadPoint]
(
@char_id INT,
@previous_olympiad_point INT
)
AS
SET NOCOUNT ON

UPDATE user_nobless
SET previous_point = 0
WHERE 
char_id = @char_id
AND previous_point = @previous_olympiad_point

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeCharacterName2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_ChangeCharacterName2
desc:	for merged server

history:	2004-12-21	created by kks
	2007-05-07	modified by btwinnuni
*/
CREATE PROCEDURE [dbo].[lin_ChangeCharacterName2]
(
	@char_id		INT,
	@old_char_name	NVARCHAR(24),
	@new_char_name	NVARCHAR(24)
)
AS

SET NOCOUNT ON

DECLARE @nTmpCount INT
DECLARE @account_name NVARCHAR(50)
DECLARE @create_date datetime

DECLARE @ret_char_id INT
SET @ret_char_id = 0

begin tran

if @new_char_name like N'' ''
begin
	raiserror(''pledge name has space : name = [%s]'', 16, 1, @new_char_name)
	goto exit_tran
end

DECLARE @builder INT
select @builder = builder from user_data (nolock) where char_id = @char_id

if @builder = 0
begin
	-- check user_prohibit   
	if exists (select char_name from user_prohibit (nolock) where char_name = @new_char_name)
	begin
		raiserror(''pledge name is prohibited: name = [%s]'', 16, 1, @new_char_name)
		goto exit_tran
	end
	  
	declare @user_prohibit_word nvarchar(20)
	select top 1 @user_prohibit_word = words from user_prohibit_word (nolock) where patindex(''%'' + words + ''%'', @new_char_name) > 0
	if @user_prohibit_word is not null
	begin
		raiserror(''pledge name has prohibited word: name = [%s], word[%s]'', 16, 1, @new_char_name, @user_prohibit_word)
		goto exit_tran
	end
end

IF not exists(SELECT char_name FROM user_data WHERE char_name = @new_char_name and char_id != @char_id)
BEGIN
	UPDATE user_data set char_name = @new_char_name where char_name = @old_char_name
	
	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @char_id = char_id , @account_name = account_name, @create_date = create_date  FROM user_data WHERE char_name = @new_char_name
		--  나를 친구로 하고 있는 목록도 갱신
		UPDATE user_friend set friend_char_name = @new_char_name where friend_char_id = @char_id and friend_char_name = @old_char_name
		UPDATE user_comment set char_name = @new_char_name where char_id = @char_id
		UPDATE EventItemFromWeb set char_name = @new_char_name where char_id = @char_id
		UPDATE changed_name_by_merge set name_new = @new_char_name, change_date = getdate(), change_flag = 1 where id = @char_id and type = 0
	
		-- make user_history
		exec lin_InsertUserHistory @new_char_name, @char_id, 3, @account_name, @create_date

		set @ret_char_id = @char_id
	END
END

exit_tran:
if @ret_char_id > 0
begin
	commit tran
	select @ret_char_id
end
else
begin
	rollback tran
	select 0
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DismissAlliance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DismissAlliance    Script Date: 2003-09-20 오전 11:51:58 ******/
-- lin_DismissAlliance
-- by bert
-- return Result(0 if failed)

CREATE PROCEDURE
[dbo].[lin_DismissAlliance] (@alliance_id INT, @master_pledge_id INT, @dismiss_time INT)
AS

SET NOCOUNT ON

DECLARE @result INT

BEGIN TRAN

DELETE FROM alliance
WHERE id = @alliance_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @result = 1
END
ELSE
BEGIN
	SELECT @result = 0
	GOTO EXIT_TRAN
END

UPDATE pledge
SET alliance_dismiss_time = @dismiss_time
WHERE pledge_id = @master_pledge_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @result = 1
END
ELSE
BEGIN
	SELECT @result = 0
END

EXIT_TRAN:

IF @result <> 0
BEGIN
	COMMIT TRAN
	UPDATE pledge SET alliance_id = 0 WHERE alliance_id = @alliance_id
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @result

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllAllianceId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAllAllianceId    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_LoadAllAllianceId
-- by bert
CREATE PROCEDURE
[dbo].[lin_LoadAllAllianceId]
AS

SET NOCOUNT ON

SELECT id FROM alliance

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_OustMemberPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_OustMemberPledge    Script Date: 2003-09-20 오전 11:51:59 ******/
-- lin_OustMemberPledge
-- by bert
-- return Result(0 if failed)

CREATE PROCEDURE
[dbo].[lin_OustMemberPledge] (@alliance_id INT, @member_pledge_id INT, @oust_time INT)
AS

SET NOCOUNT ON

DECLARE @result INT

BEGIN TRAN

UPDATE alliance
SET oust_time = @oust_time
WHERE id = @alliance_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @result = 1
END
ELSE
BEGIN
	SELECT @result = 0
	GOTO EXIT_TRAN
END

UPDATE pledge
SET alliance_id = 0, alliance_ousted_time = @oust_time
WHERE pledge_id = @member_pledge_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @result = 1
END
ELSE
BEGIN
	SELECT @result = 0
END

EXIT_TRAN:
IF @result <> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @result

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAlliance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAlliance    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_LoadAlliance
-- by bert
CREATE PROCEDURE
[dbo].[lin_LoadAlliance] (@alliance_id INT)
AS

SET NOCOUNT ON

SELECT id, name, master_pledge_id, oust_time, crest_id FROM alliance WHERE id = @alliance_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAllianceInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetAllianceInfo    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_SetAllianceInfo
	
INPUT	
	@fieldName	nvarchar(50),
	@field_data	INT,
	@pledge_id	INT
OUTPUT

return
made by
	bert ^^
********************************************/

CREATE PROCEDURE [dbo].[lin_SetAllianceInfo]
(
@fieldName	nvarchar(50),
@field_data	INT,
@alliance_id	INT
)
AS
SET NOCOUNT ON

IF @fieldName = N''oust_time'' begin update alliance set oust_time = @field_data where id =  @alliance_id end
ELSE IF @fieldName = N''crest_id'' begin update alliance set crest_id = @field_data where id =  @alliance_id end
ELSE 
BEGIN 
	RAISERROR (''lin_SetAllianceInfo : invalid field [%s]'', 16, 1, @fieldName)
	RETURN -1	
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_StartAllianceWar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- lin_StartAllianceWar
-- by bert

CREATE PROCEDURE
[dbo].[lin_StartAllianceWar] (@challenger_alliance_id INT, @challengee_alliance_id INT, @war_begin_time INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

DECLARE @challenger_name VARCHAR(50)
DECLARE @challengee_name VARCHAR(50)

SELECT @challenger_name = name FROM alliance WHERE id = @challenger_alliance_id
SELECT @challengee_name = name FROM alliance WHERE id = @challengee_alliance_id

INSERT INTO Alliance_War
(challenger, challengee, begin_time, challenger_name, challengee_name)
VALUES
(@challenger_alliance_id, @challengee_alliance_id, @war_begin_time, @challenger_name, @challengee_name)

SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModifyAllianceName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ModifyAllianceName]
(  
@alliance_name  NVARCHAR(50),  
@alliance_id  int  
)  
AS  
SET NOCOUNT ON 

UPDATE alliance SET name = @alliance_name WHERE id = @alliance_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateAlliance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE
[dbo].[lin_CreateAlliance] (@name NVARCHAR(50), @master_pledge_id INT)
AS

SET NOCOUNT ON

DECLARE @alliance_id INT

BEGIN TRAN

IF @name LIKE N'' ''   
BEGIN  
 RAISERROR (''alliance name has space : name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END  
  
-- check user_prohibit   
IF EXISTS(SELECT char_name FROM user_prohibit (nolock) WHERE char_name = @name)  
BEGIN
 RAISERROR (''alliance name is prohibited: name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END
  
DECLARE @user_prohibit_word NVARCHAR(20)  
SELECT TOP 1 @user_prohibit_word = words FROM user_prohibit_word (nolock) WHERE PATINDEX(''%'' + words + ''%'', @name) > 0   
IF @user_prohibit_word IS NOT NULL
BEGIN
 RAISERROR (''alliance name has prohibited word: name = [%s], word[%s]'', 16, 1, @name, @user_prohibit_word)  
 GOTO EXIT_TRAN
END

INSERT INTO alliance (name, master_pledge_id) VALUES (@name, @master_pledge_id)

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @alliance_id = @@IDENTITY
	UPDATE pledge
	SET alliance_id = @alliance_id
	WHERE pledge_id = @master_pledge_id
END
ELSE
BEGIN
	SELECT @alliance_id = 0
	GOTO EXIT_TRAN
END

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
BEGIN
	SELECT @alliance_id = 0
END

EXIT_TRAN:
IF @alliance_id <> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @alliance_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeletePremiumItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeletePremiumItem]
(
@warehouse_no	BIGINT
)
AS
SET NOCOUNT ON

DELETE FROM user_premium_item WHERE warehouse_no = @warehouse_no

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadUserPremiumItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadUserPremiumItem]
	@nAccountId int
AS
SET NOCOUNT ON
select warehouse_no, item_id, item_amount, buyer_id, buyer_char_name
from user_premium_item (readuncommitted) 
where recipient_id = @nAccountId
	and item_remain > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPremiumItemsForBatch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadPremiumItemsForBatch]
AS
SET NOCOUNT ON

SELECT warehouse_no
FROM user_premium_item (NOLOCK)
WHERE ibserver_delete_date is NULL
	AND warehouse_no > 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetDeletedInIBServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetDeletedInIBServer]
(
@warehouse_no	BIGINT
)
AS
SET NOCOUNT ON

UPDATE user_premium_item
SET ibserver_delete_date = GETDATE()
WHERE warehouse_no = @warehouse_no

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateMonRaceMon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateMonRaceMon
	create monster race
INPUT
	@runner_id	int
	@initial_win	int
OUTPUT
return
made by
	young
date
	2004-5-19
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateMonRaceMon]
(
@runner_id		INT,
@initial_win		INT,
@run_count		INT,
@win_count		INT
)
AS
SET NOCOUNT ON

if not exists ( select * from monrace_mon (nolock) where runner_id = @runner_id ) 
begin
	insert into monrace_mon( runner_id, initial_win , run_count, win_count ) values ( @runner_id, @initial_win , @run_count, @win_count)
end 

select initial_win, run_count, win_count  from monrace_mon ( nolock) where runner_id = @runner_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateMonRaceMon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpdateMonRaceMon
	update monster race
INPUT
	@runner_id	int
	@win_rate	int
OUTPUT
return
made by
	young
date
	2004-5-19
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdateMonRaceMon]
(
@runner_id		INT,
@win_rate		INT,
@run_count		INT,
@win_count		INT
)
AS
SET NOCOUNT ON

if exists ( select * from monrace_mon (nolock) where runner_id = @runner_id ) 
begin
	update monrace_mon set initial_win = @win_rate , run_count = @run_count, win_count = @win_count where runner_id = @runner_id
end else begin
	insert into monrace_mon( runner_id, initial_win , run_count, win_count ) values ( @runner_id, @win_rate , @run_count, @win_count )
end 

select initial_win , run_count, win_count  from monrace_mon ( nolock) where runner_id = @runner_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadNewbieData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadNewbieData
	load newbie data
INPUT

OUTPUT
return
made by
	kks
date
	2004-11-25
change
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadNewbieData]

AS

SET NOCOUNT ON

SELECT account_id, char_id, newbie_stat
FROM user_newbie (nolock)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetNewbieStat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetNewbieStat
	set newbie staus
INPUT
	@account_id	INT,
	@newbie_stat 	INT
OUTPUT
return
made by
	kks
date
	2004-11-25
********************************************/
CREATE PROCEDURE [dbo].[lin_SetNewbieStat]
(
	@account_id	INT,
	@newbie_stat 	INT
)
AS
SET NOCOUNT ON

UPDATE user_newbie 
SET newbie_stat = @newbie_stat
WHERE account_id = @account_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateNewbieData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateNewbieData
	create  newbie data
INPUT
	@account_id	INT,

OUTPUT
return
made by
	kks
date
	2004-11-25

********************************************/
CREATE PROCEDURE [dbo].[lin_CreateNewbieData]
(
	@account_id	INT
)
AS
SET NOCOUNT ON

INSERT INTO user_newbie(account_id, char_id, newbie_stat)
VALUES (@account_id, 0, 0)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateNewbieCharData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpdateNewbieCharData
	update newbie char
INPUT
	@account_id	INT,
	@char_id 	INT
OUTPUT
return
made by
	kks
date
	2004-11-25
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdateNewbieCharData]
(
	@account_id	INT,
	@char_id 	INT
)
AS
SET NOCOUNT ON

UPDATE user_newbie 
SET char_id = @char_id
WHERE account_id = @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeletePledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeletePledge    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_DeletePledge
-- by bert
-- return none

CREATE PROCEDURE
[dbo].[lin_DeletePledge] (@pledge_id INT)
AS

SET NOCOUNT ON

DELETE
FROM Academy_Member
WHERE pledge_id = @pledge_id

DELETE
FROM Academy
WHERE pledge_id = @pledge_id

DELETE
FROM Sub_Pledge
WHERE pledge_id = @pledge_id

DELETE
FROM Pledge_Skill
WHERE pledge_id = @pledge_id


DELETE
FROM Pledge
WHERE pledge_id = @pledge_id


UPDATE user_data
SET pledge_id = 0, pledge_type = 0, grade_id = 0
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAcademyName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetAcademyName
	Get Academy Name
INPUT
	@pledge_id		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_GetAcademyName] (
	@pledge_id		int
)
AS

SELECT name FROM academy
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RenameAcademy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RenameAcademy
	rename academy
INPUT
	@pledge_id		int
	@academy_name		nvarchar(50)
OUTPUT

return

date
	2006-06-08	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_RenameAcademy] (
	@pledge_id		int,
	@academy_name		nvarchar(50)
)
AS

SET NOCOUNT ON

UPDATE academy
SET name = @academy_name
WHERE pledge_id = @pledge_id

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadTeamBattleAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadTeamBattleAgitMember]
(
	@agit_id INT
)
AS
SET NOCOUNT ON
SELECT char_id, pledge_id, propose_time FROM team_battle_agit_member WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoTeamBattleAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_InsertIntoTeamBattleAgitMember]
(
@agit_id INT,
@char_id INT,
@pledge_id INT,
@propose_time INT
)
AS
SET NOCOUNT ON
INSERT INTO team_battle_agit_member
(agit_id, char_id, pledge_id, propose_time)
VALUES
(@agit_id, @char_id, @pledge_id, @propose_time)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UnregisterTeamBattleAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UnregisterTeamBattleAgitMember]
(
	@agit_id INT,
	@char_id INT,
	@pledge_id INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT

DELETE FROM team_battle_agit_member
WHERE 
agit_id = @agit_id AND char_id = @char_id AND pledge_id = @pledge_id

IF @@ERROR = 0
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteTeamBattleAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteTeamBattleAgitMember]
(
@agit_id INT
)
AS
SET NOCOUNT ON
DELETE FROM team_battle_agit_member WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_NewTeamBattleAgitMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_NewTeamBattleAgitMember]
(
	@agit_id INT,
	@char_id INT,
	@pledge_id INT,
	@propose_time INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT

INSERT INTO team_battle_agit_member
(agit_id, char_id, pledge_id, propose_time)
VALUES
(@agit_id, @char_id, @pledge_id, @propose_time)

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_NewTeamBattleAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_NewTeamBattleAgitPledge]
(
	@agit_id INT,
	@pledge_id INT,
	@char_id INT,
	@propose_time INT,
	@color INT,
	@npc_type INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

INSERT INTO team_battle_agit_pledge
(agit_id, pledge_id, propose_time, color, npc_type)
VALUES
(@agit_id, @pledge_id, @propose_time, @color, @npc_type)

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

INSERT INTO team_battle_agit_member
(agit_id, char_id, pledge_id, propose_time)
VALUES
(@agit_id, @char_id, @pledge_id, @propose_time)

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

EXIT_TRAN:

IF @ret <> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetTeamBattleWinner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetTeamBattleWinner]
(
@agit_id INT,
@winner_pledge_id INT,
@master_pledge_id INT,
@is_final INT
)
AS
SET NOCOUNT ON
IF @is_final <> 0	-- battle royal
BEGIN
	DELETE FROM team_battle_agit_pledge WHERE agit_id = @agit_id AND pledge_id <> @winner_pledge_id AND pledge_id <> @master_pledge_id
	DELETE FROM team_battle_agit_member WHERE agit_id = @agit_id AND pledge_id <> @winner_pledge_id AND pledge_id <> @master_pledge_id
END
ELSE	-- final winner
BEGIN
	DELETE FROM team_battle_agit_pledge WHERE agit_id = @agit_id AND pledge_id <> @winner_pledge_id
	DELETE FROM team_battle_agit_member WHERE agit_id = @agit_id
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UnregisterTeamBattleAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UnregisterTeamBattleAgitPledge]
(
	@agit_id INT,
	@pledge_id INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

DELETE FROM team_battle_agit_pledge
WHERE 
agit_id = @agit_id AND pledge_id = @pledge_id

IF @@ERROR <> 0
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

DELETE FROM  team_battle_agit_member
WHERE agit_id = @agit_id AND pledge_id = @pledge_id

IF @@ERROR = 0
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

EXIT_TRAN:

IF @ret <> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateItemDuration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_UpdateItemDuration
	Update Item Duration
INPUT  
	@item_id	int,
	@duration	int
OUTPUT  
 
return  
made by  
 kks
date  
 2006-10-31  
********************************************/  
CREATE   PROCEDURE [dbo].[lin_UpdateItemDuration]  
(
	@item_id	int,
	@duration	int
)
AS  
SET NOCOUNT ON  

UPDATE
	user_item_duration
SET
	duration = @duration
WHERE item_id = @item_id

IF(@@ROWCOUNT = 0)
BEGIN
	INSERT INTO user_item_duration (item_id, duration) VALUES (@item_id, @duration)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetItemDuration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetItemDuration]
	@item_id int
as
set nocount on

SELECT duration FROM user_item_duration (nolock) WHERE item_id = @item_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RestoreChar2 ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_RestoreChar2
	restore deleted char
INPUT
	@account_id	int,
	@char_id	int
OUTPUT
return
made by
	young
date
	2004-03-11
	update account_id from character
	2007-11-05 modified by choanari	
********************************************/
CREATE PROCEDURE [dbo].[lin_RestoreChar2 ]
(
	@account_id	int,
	@char_id	int,
	@new_char_name	nvarchar(50),
	@account_name	nvarchar(50) = ''''
)
AS
SET NOCOUNT ON
if ( len ( @account_name ) > 0 ) 
begin
	update user_data set account_id = @account_id , char_name = @new_char_name, account_name = @account_name , temp_delete_date = null  where char_id = @char_id
end else begin
	update user_data set account_id = @account_id , char_name = @new_char_name , temp_delete_date = null  where char_id = @char_id
end

if not exists (select top 1 * from user_item where char_id = @char_id)
begin
	select ui.item_id, ui.item_type, ui.amount, ui.enchant, ui.eroded, ui.bless, ui.ident, ui.wished, ui.warehouse, 
		ui.variation_opt1, ui.variation_opt2, ui.intensive_item_type, isnull(uia.attack_attribute_type, -2) attack_attribute_type,
		isnull(uia.attack_attribute_value, 0) attack_attribute_value, isnull(uia.defend_attribute_0, 0) defend_attribute_0, 
		isnull(uia.defend_attribute_1, 0) defend_attribute_1, isnull(uia.defend_attribute_2, 0) defend_attribute_2,
		isnull(uia.defend_attribute_3, 0) defend_attribute_3, isnull(uia.defend_attribute_4, 0) defend_attribute_4, 
		isnull(uia.defend_attribute_5, 0) defend_attribute_5, isnull(uid.duration, -1) duration
	from user_item_deleted ui left join user_item_attribute uia on ui.item_id = uia.item_id
		left join user_item_duration uid on  ui.item_id = uid.item_id
	where ui.char_id = @char_id and ui.isRestored = 0

	update user_item_deleted set isRestored = 1 where char_id = @char_id
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_DeleteItem  
   
INPUT  
 @item_id  INT  
OUTPUT  
return  
made by  
 carrot  
date  
 2002-06-10  
modified by kks
modified date 2006-10-30
********************************************/  
CREATE PROCEDURE [dbo].[lin_DeleteItem]  
(  
 @item_id  INT  
)  
AS  
SET NOCOUNT ON  
  
SET NOCOUNT ON   
DELETE FROM USER_ITEM_DURATION WHERE item_id = @item_id
DELETE FROM user_item_attribute WHERE item_id = @item_id
DELETE FROM user_item_period WHERE item_id = @item_id
DELETE FROM USER_ITEM WHERE item_id=@item_id 
--UPDATE user_item  set char_id=0, item_type=0 WHERE item_id=@item_id  
SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteTeamBattleAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteTeamBattleAgitPledge]
(
@agit_id INT
)
AS
SET NOCOUNT ON
DELETE FROM team_battle_agit_pledge WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadTeamBattleAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadTeamBattleAgitPledge]
(
	@agit_id INT
)
AS
SET NOCOUNT ON
SELECT pledge_id, propose_time, color, npc_type FROM team_battle_agit_pledge WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoTeamBattleAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_InsertIntoTeamBattleAgitPledge]
(
@agit_id INT,
@pledge_id INT,
@propose_time INT,
@color INT,
@npc_type INT
)
AS
SET NOCOUNT ON
INSERT INTO team_battle_agit_pledge
(agit_id, pledge_id, propose_time, color, npc_type)
VALUES
(@agit_id, @pledge_id, @propose_time, @color, @npc_type)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetTeamBattleNpcType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetTeamBattleNpcType]
(
	@agit_id INT,
	@pledge_id INT,
	@npc_type INT
)
AS
SET NOCOUNT ON
UPDATE team_battle_agit_pledge
SET npc_type = @npc_type 
WHERE agit_id = @agit_id AND pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetColor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_SetColor]
(
	@char_id	int,
	@color		int,
	@type		int
)
AS

SET NOCOUNT ON

if @type = 0
begin
	if exists (select * from user_name_color(nolock) where char_id = @char_id)
		update user_name_color set color_rgb = @color where char_id = @char_id
	else
		insert into user_name_color (char_id, color_rgb)
		values (@char_id, @color)
end
else if @type = 1
begin
	if exists (select * from user_name_color(nolock) where char_id = @char_id)
		update user_name_color set nickname_color_rgb = @color where char_id = @char_id
	else
		insert into user_name_color (char_id, nickname_color_rgb)
		values (@char_id, @color)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/**
name:	lin_CreateChar
desc:	create user_data, quest, user_slot

history:	2007-03-30	modified by btwinuni
*/
CREATE procedure [dbo].[lin_CreateChar]
(  
	@char_name	nvarchar(24),
	@account_name	nvarchar(24),
	@account_id	int,
	@pledge_id	int,
	@builder		tinyint,
	@gender	tinyint,
	@race		tinyint,
	@class		tinyint,
	@world		smallint,
	@xloc		int,
	@yloc		int,
	@zloc		int,
	@HP		float,
	@MP		float,
	@SP		int,
	@Exp		bigint,
	@Lev		tinyint,
	@align		smallint,
	@PK		int,
	@Duel		int,
	@PKPardon	int,
	@FaceIndex	int = 0,
	@HairShapeIndex	int = 0,
	@HairColorIndex	int = 0
)  
as

--set @Exp=25259243744
--set @SP=50000000
--set @Lev=85

set nocount on

declare @char_id int

set @char_id = 0
set @char_name = rtrim(@char_name)


if(@FaceIndex>7)set @FaceIndex=0
if(@HairShapeIndex>4)set @HairShapeIndex=0
if(@HairColorIndex>3)set @HairColorIndex=0

if @char_name like N''%[^a-zA-Z0-9]%''
begin
	raiserror (''Character name has space : name = [%s]'', 16, 1, @char_name)  
	return -1
end

if @char_name like N''% %''
begin
	raiserror (''Character name has space : name = [%s]'', 16, 1, @char_name)  
	return -1
end

if @char_name like N''% %''
begin
	raiserror (''Character name has space : name = [%s]'', 16, 1, @char_name)  
	return -1
end

-- check user_data
if exists(select char_name from user_data (nolock) where char_name = @char_name)
begin
	raiserror (''Character name is used: name = [%s]'', 16, 1, @char_name)
	return -1
end

-- check user_prohibit
if exists(select char_name from user_prohibit (nolock) where char_name = @char_name)
begin
	raiserror (''Character name is prohibited: name = [%s]'', 16, 1, @char_name)
	return -1
end

declare @user_prohibit_word nvarchar(20)
select top 1 @user_prohibit_word = words from user_prohibit_word (nolock) where @char_name like ''%'' + words + ''%''
if @user_prohibit_word is not null
begin
	raiserror (''Character name has prohibited word: name = [%s], word[%s]'', 16, 1, @char_name, @user_prohibit_word)
	return -1
end

-- check reserved name
declare @reserved_name nvarchar(50)
declare @reserved_account_id int
select top 1 @reserved_name = char_name, @reserved_account_id = account_id from user_name_reserved (nolock) where used = 0 and char_name = @char_name
if not @reserved_name is null
begin
	if not @reserved_account_id = @account_id
	begin
		raiserror (''Character name is reserved by other player: name = [%s]'', 16, 1, @char_name)
		return -1
	end
end

-- insert user_data
insert into user_data (
	char_name, account_name, account_id, pledge_id, builder, gender, race, class, subjob0_class,
	world, xloc, yloc, zloc, HP, MP, max_hp, max_mp, SP, Exp, Lev, align, PK, PKpardon, duel,
	create_date, face_index, hair_shape_index, hair_color_index
)
values (
	@char_name, @account_name, @account_id, @pledge_id, @builder, @gender, @race, @class, @class,
	@world, @xloc, @yloc, @zloc, @HP, @MP, @HP, @MP, @SP, @Exp, @Lev, @align, @PK, @Duel, @PKPardon, 
	GETDATE(), @FaceIndex, @HairShapeIndex, @HairColorIndex
)
  
if (@@error = 0)
begin
	set @char_id = @@identity
	insert into quest (char_id) values (@char_id)
	insert into user_slot (char_id) values (@char_id)
end

select @char_id

if @char_id > 0
begin
	-- make user_history  
	exec lin_InsertUserHistory @char_name, @char_id, 1, @account_name, NULL
	if not @reserved_name is null
		update user_name_reserved set used = 1 where char_name = @reserved_name
end





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetNoblessTop10]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetNoblessTop10]
(
@class INT,
@season INT
)
AS  
SET NOCOUNT ON  

SELECT TOP 10 WITH TIES u.char_id, u.char_name, o.point, o.match_count, o.olympiad_win_count 
FROM user_data u, olympiad_result o 
WHERE o.class = @class AND u.char_id = o.char_id AND o.season = @season AND u.account_id > -1
ORDER BY point DESC, olympiad_win_count DESC, match_count ASC, u.char_name ASC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_WriteNoblessAchievement]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_WriteNoblessAchievement]
(
@char_id INT,
@win_type INT,
@target INT,
@win_time INT
)
AS
SET NOCOUNT ON

INSERT INTO nobless_achievements
(char_id, win_type, target, win_time)
VALUES
(@char_id, @win_type, @target, @win_time)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetNoblessAchievements]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetNoblessAchievements]
(
@char_id INT
)
AS
SELECT win_type, target, win_time FROM nobless_achievements WHERE char_id = @char_id ORDER BY win_time DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetUserDataByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetUserDataByCharName    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetUserDataByCharName

INPUT
	@char_name	NVARCHAR(50)
OUTPUT
	ud.char_name, ud.account_name, ud.account_id, ud.pledge_id, ud.builder, ud.gender, ud.race, ud.class, ud.world, ud.xloc, ud.yloc, ud.zloc, 
	ud.HP, ud.MP, ud.SP, ud.Exp, ud.Lev, ud.align, ud.PK, ud.Str, ud.Dex, ud.Con, ud.Int, ud.Wit, ud.Men, 
	ud.ST_underware, ud.ST_right_ear, ud.ST_left_ear, ud.ST_neck, ud.ST_right_finger, ud.ST_left_finger, ud.ST_head, ud.ST_right_hand, 
	ud.ST_left_hand, ud.ST_gloves, ud.ST_chest, ud.ST_legs, ud.ST_feet, ud.ST_back, ud.ST_both_hand,
	uas.s1, uas.l1, uas.d1, uas.s2, uas.l2, uas.d2, uas.s3, uas.l3, uas.d3, uas.s4, uas.l4, uas.d4, uas.s5, uas.l5, uas.d5, uas.s6, uas.l6, uas.d6, uas.s7, uas.l7, uas.d7, uas.s8, uas.l8, uas.d8, uas.s9, uas.l9, uas.d9, uas.s10, uas.l10, uas.d10, 
	uas.s11, uas.l11, uas.d11, uas.s12, uas.l12, uas.d12, uas.s13, uas.l13, uas.d13, uas.s14, uas.l14, uas.d14, uas.s15, uas.l15, uas.d15, uas.s16, uas.l16, uas.d16, uas.s17, uas.l17, uas.d17, uas.s18, uas.l18, uas.d18, uas.s19, uas.l19, uas.d19, uas.s20, uas.l20, uas.d20
return
made by
	carrot
date
	2002-06-09
********************************************/
CREATE PROCEDURE [dbo].[lin_GetUserDataByCharName]
(
@char_name	nvarchar(50)
)
AS
SET NOCOUNT ON

declare @char_id	INT

set @char_id = 0

select top 1 @char_id = char_id from user_data where char_name = @char_name

exec lin_GetUserDataByCharId @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetMinigameAgit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_ResetMinigameAgit]
(
	@agit_id		int
)
as
set nocount on
delete from minigame_agit_status where agit_id=@agit_id
delete from minigame_agit_pledge where agit_id=@agit_id
delete from minigame_agit_member where agit_id=@agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteAllDominionRenamed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteAllDominionRenamed]  
AS
SET NOCOUNT ON

DELETE dominion_renamed

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDominionRenamed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadDominionRenamed]
(
	@char_id int
)
AS
SET NOCOUNT ON
SELECT is_renamed FROM dominion_renamed WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDominionRenamed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveDominionRenamed]
(        
@char_id INT,
@is_renamed INT
)        
AS  
SET NOCOUNT ON        
IF EXISTS(SELECT * FROM dominion_renamed WHERE char_id = @char_id)
BEGIN
	UPDATE dominion_renamed SET is_renamed = @is_renamed 
	WHERE char_id = @char_id
END
ELSE
BEGIN
	INSERT INTO dominion_renamed (char_id, is_renamed)
	VALUES (@char_id, @is_renamed)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteDominionRenamed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteDominionRenamed]  
AS
SET NOCOUNT ON

DELETE dominion_renamed

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteFriends]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeleteFriends    Script Date: 2003-09-20 오전 11:51:58 ******/
-- lin_DeleteFriends
-- by bert
-- return deleted friend id set

CREATE PROCEDURE [dbo].[lin_DeleteFriends] (@char_id INT)
AS

SET NOCOUNT ON

SELECT friend_char_id FROM user_friend WHERE char_id = @char_id

DELETE FROM user_friend
WHERE char_id = @char_id OR friend_char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_EstablishFriendship]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_EstablishFriendship    Script Date: 2003-09-20 오전 11:51:58 ******/
-- lin_EstablishFriendship
-- by bert

CREATE PROCEDURE [dbo].[lin_EstablishFriendship] (@char_id INT, @char_name VARCHAR(50), @friend_char_id INT, @friend_char_name VARCHAR(50))
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

INSERT INTO user_friend
(char_id, friend_char_id, friend_char_name)
VALUES
(@char_id, @friend_char_id, @friend_char_name)

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

INSERT INTO user_friend
(char_id, friend_char_id, friend_char_name)
VALUES
(@friend_char_id, @char_id, @char_name)

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

EXIT_TRAN:

IF @ret <> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_BreakFriendship]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_BreakFriendship    Script Date: 2003-09-20 오전 11:51:58 ******/
-- lin_BreakFriendship
-- by bert

CREATE PROCEDURE [dbo].[lin_BreakFriendship] (@char_id INT, @friend_char_id INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

DELETE FROM user_friend
WHERE
(char_id = @char_id AND friend_char_id = @friend_char_id)
OR
(char_id = @friend_char_id AND friend_char_id = @char_id)

IF @@ERROR = 0 AND @@ROWCOUNT = 2
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CleanUpGhostData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_CleanUpGhostData  
     
INPUT    
OUTPUT    
    
return    
made by    
 bert   
date    
 2004-04-27    
 2005-11-21	by btwinuni	delete pledge_war, alliance_war
 2005-12-20	by btwinuni	add clean up war_declare
 2006-04-20	by btwinuni	except nobless nickname clean-up
********************************************/    
CREATE PROCEDURE [dbo].[lin_CleanUpGhostData]  
AS  
SET NOCOUNT ON  
  
-- 유령 정리  
UPDATE user_data  
SET pledge_id = 0, nickname = ''''  
WHERE account_id in (-1, -3, -4)
	and pledge_id > 0
  
-- 유령 친구 정리  
DELETE FROM user_friend  
WHERE  
char_id IN (SELECT char_id FROM user_data WHERE account_id in (-1, -3, -4))
OR  
friend_char_id IN (SELECT char_id FROM user_data WHERE account_id in (-1, -3, -4))

-- 유령 차단목록 정리  
DELETE FROM user_blocklist
WHERE  
char_id IN (SELECT char_id FROM user_data WHERE account_id in (-1, -3, -4))
OR  
block_char_id IN (SELECT char_id FROM user_data WHERE account_id in (-1, -3, -4))
  
-- 유령 혈맹 정리 (혈맹주가 없는 혈)  
DELETE FROM pledge WHERE ruler_id IN (SELECT char_id FROM user_data WHERE account_id in (-1, -3, -4))
  
-- 유령혈맹 해산처리  
UPDATE user_data  
SET pledge_id = 0  
WHERE pledge_id > 0 AND pledge_id NOT IN (SELECT pledge_id FROM pledge)  
  
--UPDATE user_data  
--SET nickname = ''''  
--WHERE pledge_id = 0
--	and char_id not in (select char_id from user_nobless where nobless_type = 1)
--	and nickname <> ''''
  
-- 유령 아지트 소유혈 정리  
UPDATE agit  
SET pledge_id = 0  
WHERE pledge_id > 0 AND pledge_id NOT IN (SELECT pledge_id FROM pledge)  
  
-- 유령 성 소유혈 정리  
UPDATE castle  
SET pledge_id = 0  
WHERE pledge_id > 0 AND pledge_id NOT IN (SELECT pledge_id FROM pledge)  
  
-- 2005-12-20	by btwinuni
-- 각종 유령 전쟁 정리  
DELETE FROM war_declare
WHERE  
(challengee > 0 AND challengee NOT IN (SELECT pledge_id FROM pledge))  
OR  
(challenger > 0 AND challenger NOT IN (SELECT pledge_id FROM pledge))  
  
DELETE FROM siege_agit_pledge  
WHERE  
pledge_id > 0 AND pledge_id NOT IN (SELECT pledge_id FROM pledge)  
  
DELETE FROM team_battle_agit_pledge  
WHERE  
pledge_id > 0 AND pledge_id NOT IN (SELECT pledge_id FROM pledge)  
  
-- 유령 동맹 처리(동맹주가 없는 동맹)  
DELETE FROM alliance WHERE master_pledge_id NOT IN (SELECT pledge_id FROM pledge)  
  
-- 유령 동맹해산 처리  
UPDATE pledge  
SET alliance_id = 0  
WHERE alliance_id > 0 AND alliance_id NOT IN (SELECT id FROM alliance)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadFriends]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadFriends] (@char_id INT)  
AS  
  
SET NOCOUNT ON  
  
SELECT friend_char_id, ud.char_name AS friend_char_name   
FROM user_friend AS uf, user_data AS ud  
WHERE uf.char_id = @char_id AND uf.friend_char_id = ud.char_id AND ud.account_id <> -1

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPledgeAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetPledgeAnnounce
	set pledge announce 
INPUT
	@pledge_id		int,
	@show_flag		smallint,
	@content		nvarchar(3000)
OUTPUT
return
made by
	kks
date
	2005-07-22
********************************************/
CREATE PROCEDURE [dbo].[lin_SetPledgeAnnounce]
(  
	@pledge_id		int,
	@show_flag		smallint,
	@content		nvarchar(3000)
)  
AS  
SET NOCOUNT ON  
  

UPDATE pledge_announce SET show_flag = @show_flag , content = @content
WHERE pledge_id = @pledge_id

IF (@@ROWCOUNT = 0)  
 BEGIN  
  INSERT INTO pledge_announce (pledge_id, show_flag, content)
	VALUES (@pledge_id, @show_flag, @content)
 END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPledgeAnnounce
	load pledge announce 
INPUT
	@pledge_id		int
OUTPUT
return
made by
	kks
date
	2005-07-22
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPledgeAnnounce]
(  
	@pledge_id		int
)  
AS  
SET NOCOUNT ON  
  

select show_flag, content 
from pledge_announce (nolock)
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SwitchPledgeAnnounceShowFlag]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SwitchPledgeAnnounceShowFlag
	set pledge announce show flag
INPUT
	@pledge_id		int,
	@show_flag		smallint
OUTPUT
return
made by
	kks
date
	2005-07-22
********************************************/
CREATE PROCEDURE [dbo].[lin_SwitchPledgeAnnounceShowFlag]
(  
	@pledge_id		int,
	@show_flag		smallint
)  
AS  
SET NOCOUNT ON  
  

UPDATE pledge_announce SET show_flag = @show_flag
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadManorInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_LoadManorInfo
 load manor seed next
INPUT        
 @manor_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE  PROCEDURE [dbo].[lin_LoadManorInfo]
(        
 @manor_id INT
)        
AS        
        
SET NOCOUNT ON        

IF EXISTS(SELECT * FROM manor_info WHERE manor_id = @manor_id)
BEGIN
	SELECT 
		residence_id, adena_vault, crop_buy_vault, change_state, convert(nvarchar(19), last_changed, 121)
	FROM 
		manor_info
	WHERE 
		manor_id = @manor_id
END
ELSE
BEGIN
	SELECT 0, 0, 0, 0, ''0000-00-00 00:00:00''

END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveManorInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_SaveManorInfo
INPUT        
 @manor_id
 
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE  PROCEDURE [dbo].[lin_SaveManorInfo]
(        
 @manor_id INT,
 @residence_id INT,
 @AdenaSeedSell BIGINT,
 @AdenaCropBuy BIGINT,
 @change_state TINYINT,
 @last_changed DATETIME
)        
AS        
        
SET NOCOUNT ON        
IF EXISTS(SELECT * FROM manor_info WHERE manor_id = @manor_id)
BEGIN
	UPDATE
		manor_info
	SET
		residence_id = @residence_id,
		adena_vault = @AdenaSeedSell,
		crop_buy_vault = @AdenaCropBuy,
		change_state = @change_state,
		last_changed = @last_changed
	WHERE
		manor_id = @manor_id
END
ELSE
BEGIN
	INSERT INTO manor_info (manor_id, residence_id, adena_vault, crop_buy_vault, change_state, last_changed) 
	VALUES (@manor_id, @residence_id,@AdenaSeedSell,@AdenaCropBuy, @change_state, @last_changed)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadFortress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadCastle  
   
INPUT   
 @id int,  
  
OUTPUT  
 state,   
 state_changed_time,   
 state_elapsed_time,
 pledge_id   
 contract_status,   
 parent_castle_id,   
 last_owner_changed_time,   
 last_reward_given_time,   
 owner_reward_cycle_count,   
 castle_treasure_level,   
 owner_siege_defend_count,  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadFortress]  
(  
 @id int
)  
AS  
SET NOCOUNT ON  
  
SELECT   
 state, state_changed_time, state_elapsed_time, pledge_id, contract_status,
parent_castle_id, last_owner_changed_time, last_reward_given_time, 
owner_reward_cycle_count, castle_treasure_level, owner_siege_defend_count
FROM   
 fortress (nolock)
WHERE   
 id = @id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressContractInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressContractInfo
   
INPUT   
 @id int,  
 @contract_status int,
 @parent_castle_id int,
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressContractInfo]  
(  
 @id int,
 @contract_status int,
 @parent_castle_id int
)  
AS  
UPDATE fortress
SET contract_status = @contract_status, parent_castle_id = @parent_castle_id
WHERE id = @id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressRewardInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressRewardInfo
   
INPUT   
 @id int,  
 @last_reward_given_time int,
 @owner_reward_cycle_count int,
 @castle_treasure_level int
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressRewardInfo]  
(  
 @id int,  
 @last_reward_given_time int,
 @owner_reward_cycle_count int,
 @castle_treasure_level int
)  
AS  
UPDATE fortress
SET last_reward_given_time = @last_reward_given_time, 
owner_reward_cycle_count = @owner_reward_cycle_count, 
castle_treasure_level = @castle_treasure_level
WHERE id = @id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressState
   
INPUT   
 @id int,  
 @state int,
 @state_changed_time int,
 @state_elapsed_time int
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressState]  
(  
 @id int,
 @state int,
 @state_changed_time int,
 @state_elapsed_time int
)  
AS  
UPDATE fortress
SET state = @state, state_changed_time = @state_changed_time, state_elapsed_time = @state_elapsed_time  
WHERE id = @id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateFortressOwner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_UpdateFortressOwner
   
INPUT   
 @id int,  
 @pledge_id int,
 @last_owner_changed_time int,
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_UpdateFortressOwner]  
(  
 @id int,
 @pledge_id int,
 @last_owner_changed_time int
)  
AS  
UPDATE fortress
SET pledge_id = @pledge_id, last_owner_changed_time = @last_owner_changed_time
WHERE id = @id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateFortress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateFortress
	
INPUT	
	@id	int,
	@name	nvarchar(50)
OUTPUT
return
made by
	sei
date
	2007-04-09
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateFortress]
(
	@id	int,
	@name	nvarchar(50)
)
AS
SET NOCOUNT ON

INSERT INTO fortress (id, name) VALUES (@id, @name)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetPowerGrade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetPowerGrade
	set pledge power
INPUT
	@pledge_id		int,
	@grade_id		int,
	@power		int
OUTPUT
return
made by
	kks
date
	2006-03-28
********************************************/
CREATE PROCEDURE [dbo].[lin_SetPowerGrade]
(  
	@pledge_id		int,
	@grade_id		int,
	@power		int
)  
AS  
SET NOCOUNT ON  
  

UPDATE pledge_power SET power_bits = @power
WHERE pledge_id = @pledge_id and grade_id = @grade_id

IF (@@ROWCOUNT = 0)  
 BEGIN  
  INSERT INTO pledge_power (pledge_id, grade_id, power_bits)
	VALUES (@pledge_id, @grade_id, @power)
 END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetPledgePower]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetPledgePower
	Get Pledge Power
INPUT
	@pledge_id		int
OUTPUT

return

date
	2006-04-21	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_GetPledgePower] (
	@pledge_id		int
)
AS

SELECT grade_id, power_bits FROM pledge_power
WHERE pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAgitAuction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetAgitAuction
	create agit bid
INPUT
	@auction_id	int
OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_SetAgitAuction]
(
@agit_id		INT,
@auction_id		INT,
@next_cost		INT
)
AS
SET NOCOUNT ON
declare @max_price  BIGINT
declare @attend_id int
declare @pledge_id int
declare @tax int
set @attend_id = 0
set @max_price = 0
set @pledge_id = 0
set @tax = 0
select top 1 @max_price = attend_price, @attend_id = attend_id, @pledge_id = attend_pledge_id from agit_bid (nolock) 
	where auction_id = @auction_id 
	order by attend_price desc, attend_id asc
if ( @max_price > 0 )
begin
	-- 낙찰
	update agit_auction set accepted_bid = @attend_id where auction_id = @auction_id
	update agit set auction_id = null , last_price = @max_price, next_cost = @next_cost  , cost_fail = NULL  where id = @agit_id
	update pledge set agit_id = @agit_id where pledge_id = @pledge_id
	select @tax = isnull( auction_tax , 0) from agit_auction (nolock) where auction_id = @auction_id
end  else begin
	-- 유찰
	update agit_auction set accepted_bid = 0 where auction_id = @auction_id
	update agit set auction_id = null , next_cost = 0  , cost_fail = NULL where id = @agit_id
end
select @attend_id, @max_price, @pledge_id, @tax

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateAgitBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateAgitBid
	create agit bid
INPUT
	@auction_id	int,
	@price		int,
	@pledge_id	int
OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateAgitBid]
(
@agit_id		INT,
@auction_id		INT,
@price			BIGINT,
@pledge_id		INT,
@attend_time		INT
)
AS
SET NOCOUNT ON
declare @last_bid bigint
declare @bid_id int
declare @diff_adena bigint
set @last_bid = 0
set @bid_id = 0
set @diff_adena = 0
select @last_bid  = attend_price , @bid_id = attend_id from agit_bid (nolock) where auction_id = @auction_id and attend_pledge_id = @pledge_id
if ( @@ROWCOUNT > 0 ) 
begin
	update agit_bid set attend_price = @price  , attend_time = @attend_time where auction_id = @auction_id and attend_pledge_id = @pledge_id
	set @diff_adena = @last_bid - @price 
end else begin
	insert into agit_bid ( auction_id, attend_price, attend_pledge_id , attend_time )
	values (  @auction_id, @price, @pledge_id , @attend_time )
	set @bid_id = @@IDENTITY
	set @diff_adena = @price
end
select @auction_id, @bid_id, @diff_adena

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteAgitBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DeleteAgitBid
	delete agit bid
INPUT
	@agit_id	int
	@pledge_id	int
OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_DeleteAgitBid]
(
@agit_id		INT,
@pledge_id		INT
)
AS
SET NOCOUNT ON
declare @auction_id	int
declare @price bigint
set @auction_id = 0
set @price = 0
select @auction_id = isnull( auction_id , 0) from agit (nolock) where id = @agit_id
if @auction_id > 0
begin
	select @price = attend_price from agit_bid where  auction_id = @auction_id and attend_pledge_id = @pledge_id
	delete from agit_bid where auction_id = @auction_id and attend_pledge_id = @pledge_id
end 
select @agit_id, @pledge_id, @auction_id, @price

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAgitBidOne]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetAgitBidOne
	get  agit bid
INPUT
	@auction_id	int,
	@pledge_id	int

OUTPUT
return
made by
	young
date
	2003-12-23
********************************************/
CREATE PROCEDURE [dbo].[lin_GetAgitBidOne]
(
@auction_id		INT,
@pledge_id		INT
)
AS
SET NOCOUNT ON

declare @last_bid int
declare @bid_id int

set @last_bid = 0
set @bid_id = 0

select @last_bid  = Isnull( attend_price, 0) , @bid_id = isnull( attend_id , 0) from agit_bid (nolock) where auction_id = @auction_id and attend_pledge_id = @pledge_id

select @auction_id, @bid_id, @last_bid

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAgitBid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetAgitBid
	
INPUT
	@auction_id	int
OUTPUT
return
made by
	young
date
	2003-12-1
********************************************/
CREATE PROCEDURE [dbo].[lin_GetAgitBid]
(
	@auction_id	int
)
AS
SET NOCOUNT ON


select attend_id, attend_price, attend_pledge_id, attend_time  from agit_bid (nolock) where auction_id = @auction_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreatePremiumItemReceive]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreatePremiumItemReceive]
(
@new_item_id	INT,
@char_id	INT,
@amount 	INT,
@warehouse_no	BIGINT,
@product_id	INT
)
AS
SET NOCOUNT ON

INSERT INTO user_premium_item_receive (warehouse_no, real_recipient_char_id, item_dbid, item_amount, product_id, receive_date)
VALUES (@warehouse_no, @char_id, @new_item_id, @amount, @product_id, GETDATE())

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPremiumItemReceive]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/********************************************
lin_LoadPremiumItemReceive
	
INPUT
	@warehouse_no	bigint
OUTPUT
	@item_dbid		int
return
made by
	thefact
date
	2008-12-11
check if cashshop item is already given to user when game server start
added by branch team for cashshop 
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPremiumItemReceive]
(
@warehouse_no	BIGINT
)
AS
SET NOCOUNT ON

SELECT item_dbid FROM user_premium_item_receive
WHERE warehouse_no = @warehouse_no and product_id > 0

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadLottoItems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadLottoItems]
(
	@round int
)
AS    
   
SET NOCOUNT ON    

select 	item_id,
	number_flag
from lotto_items
where round_number = @round

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateLottoItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreateLottoItem]
(
	@round_number int,
	@item_id int,
	@number_flag int	
) 
AS       
SET NOCOUNT ON    

insert into lotto_items
values
(
	@round_number ,
	@item_id,
	@number_flag
)

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddLottoItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_AddLottoItem]  
(  
 @round int ,
 @item_id int ,
 @number_flag int
)  
AS  
  
SET NOCOUNT ON  

insert lotto_items
values (@round, @item_id, @number_flag)

declare @tot_count int

select @tot_count = count(*) from lotto_items (nolock) where round_number = @round
update lotto_game set total_count = @tot_count where round_number = @round
select @tot_count

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadSSQJoinInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_LoadSSQJoinInfo
  * @brief SSQ 황혼/새벽 전체 가입 정보
  *
  * @date 2004/11/18
  * @author sonai  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_LoadSSQJoinInfo]
(
@round_number INT
)
 AS 

SELECT point, collected_point, main_event_point, type, member_count, 
	 seal1_selection_count, 
	 seal2_selection_count, 
	 seal3_selection_count, 
	 seal4_selection_count, 
	 seal5_selection_count, 
	 seal6_selection_count, 
	 seal7_selection_count
	 
	FROM ssq_join_data WHERE round_number = @round_number

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveSSQJoinInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_SaveSSQJoinInfo
  * @brief SSQ 시스템 정보 DB를 저장한다.
  *
  * @date 2004/11/26
  * @author Seongeun Park  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_SaveSSQJoinInfo] 
(
@round_number INT,
@type TINYINT,
@point BIGINT,
@collected_point BIGINT,
@main_event_point BIGINT,
@member_count INT,
@seal1 INT,
@seal2 INT,
@seal3 INT,
@seal4 INT,
@seal5 INT,
@seal6 INT,
@seal7 INT
)
AS
SET NOCOUNT ON
UPDATE ssq_join_data SET point = @point, collected_point = @collected_point, main_event_point = @main_event_point,
			       member_count = @member_count,
			       seal1_selection_count = @seal1,
			       seal2_selection_count = @seal2,
			       seal3_selection_count = @seal3,
			       seal4_selection_count = @seal4,
			       seal5_selection_count = @seal5,
			       seal6_selection_count = @seal6,
			       seal7_selection_count = @seal7,
			       last_changed_time = GETDATE()		                          
  	                   WHERE round_number = @round_number AND type =@type

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSSQStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetSSQStatus
	get ssq status
INPUT

OUTPUT

return
made by
	kks
date
	2005-02-23
changed by
	carrot
date
	2005-03-08
changed by 
	kks
date	
	2005-03-15
changed by 
	kks
date	2005-03-21
changed by 
	kks
date	2005-03-23
********************************************/
CREATE PROCEDURE [dbo].[lin_GetSSQStatus]

AS

SET NOCOUNT ON

declare @dawn_collected_point int
declare @dawn_main_event_point int
declare @twilight_collected_point int
declare @twilight_main_event_point int
declare @current_round_number int

select  @current_round_number = max(round_number) from ssq_data

select @dawn_collected_point = case when dawn_point + twilight_point = 0 then 0 else  ((convert(float, dawn_point) / (dawn_point + twilight_point)) * 500) end, 
@twilight_collected_point = case when dawn_point + twilight_point = 0 then 0 else ((convert(float, twilight_point) / (dawn_point + twilight_point)) * 500) end
from
(
select sum(dawn) dawn_point, sum(twilight) twilight_point
from
(select 
case when type = 1 then sum(collected_point) else 0 end twilight, 
case when type = 2 then sum(collected_point) else 0 end dawn
from ssq_join_data
where round_number = @current_round_number
group by type
) as a
) as b

select @dawn_main_event_point = sum(dawn), @twilight_main_event_point = sum(twilight)
from 
(
select 
case when ssq_part = 1 then sum(point) else 0 end twilight,
case when ssq_part = 2 then sum(point) else 0 end dawn
from
(
select 
case 
when sum_point > 0 then 1	-- if sum(point) is positive, twilight wins!!!
when sum_point < 0 then 2	-- if sum(point) is negative, dawn wins!!!
else 0 end ssq_part,		-- even, none wins
case when room_no = 1 then 60 
when room_no = 2 then 70
when room_no = 3 then 100
when room_no = 4 then 120
when room_no = 5 then 150
else 0 end point
from
(
select room_no, sum(point) sum_point -- twilight point + dawn point
from
(
select room_no,
case
when ssq_part = 1 then point 	-- twilight point
when ssq_part = 2 then -point	-- dawn point
else 0 end point
from time_attack_record
where record_type > 0
and ssq_round = @current_round_number
) as x
group by room_no
) as y
) as a
group by ssq_part
) as b

select top 1 round_number, @twilight_main_event_point + @twilight_collected_point twilight_point, @dawn_main_event_point + @dawn_collected_point dawn_point,  
seal1, seal2, seal3, seal4, seal5, seal6, seal7, datediff(s, ''1970-01-01'', getutcdate()), status
from ssq_data
where round_number = @current_round_number

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateSSQRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**  
  * @procedure lin_CreateSSQRound  
  * @brief SSQ 정보 로드  
  *  
  * @date 2004/11/18  
  * @author sonai  <sonai@ncsoft.net>  
  */  
CREATE PROCEDURE [dbo].[lin_CreateSSQRound]   
(  
@round_number INT,  
@status INT,  
@winner INT,  
@event_start_time INT,  
@event_end_time INT,  
@seal_effect_time INT,  
@seal_effect_end_time INT,  
@seal1 INT,  
@seal2 INT,  
@seal3 INT,  
@seal4 INT,  
@seal5 INT,  
@seal6 INT,  
@seal7 INT,  
@castle_snapshot_time INT,  
@can_drop_guard INT  
)  
AS  
  
SET NOCOUNT ON  
/*DECLARE @ret AS INT*/  
  
/* 황혼 세력 정보 생성 */  
INSERT ssq_join_data(round_number, point,  collected_point, main_event_point, type, member_count,   
                         seal1_selection_count, seal2_selection_count, seal3_selection_count,  
             seal4_selection_count, seal5_selection_count, seal6_selection_count, seal7_selection_count,  
             last_changed_time)  
  VALUES(@round_number, 0, 0, 0, 1, 0,   0, 0, 0, 0, 0, 0, 0, GETDATE())  
  
/*SELECT @ret = @@ROWCOUNT*/  
  
/* 새벽 세력 정보 생성 */  
INSERT ssq_join_data(round_number, point, collected_point, main_event_point, type, member_count,   
             seal1_selection_count, seal2_selection_count, seal3_selection_count,  
             seal4_selection_count, seal5_selection_count, seal6_selection_count, seal7_selection_count,  
             last_changed_time)  
  VALUES(@round_number,  0, 0, 0, 2, 0,   0, 0, 0, 0, 0, 0, 0, GETDATE())  
  
/*SELECT @ret = @ret + @@ROWCOUNT */  
  
INSERT ssq_data(round_number, status, winner, event_start_time, event_end_time, seal_effect_time, seal_effect_end_time,  
       seal1, seal2, seal3, seal4, seal5, seal6, seal7,  
       last_changed_time, castle_snapshot_time, can_drop_guard)  
   VALUES(@round_number, @status, @winner,  @event_start_time,  @event_end_time,  @seal_effect_time, @seal_effect_end_time,  
      @seal1, @seal2, @seal3, @seal4, @seal5, @seal6, @seal7,  
       GETDATE(), @castle_snapshot_time, @can_drop_guard)  
  
/*  
SELECT @ret = @ret + @@ROWCOUNT  
  
SELECT @ret  
*/

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CheckPetName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CheckPetName]
(
@pet_name NVARCHAR(24)
)
AS

SET NOCOUNT ON

declare @result  int
set @result = 1

SET @pet_name = RTRIM(@pet_name)
IF @pet_name  LIKE N'' '' 
BEGIN
	RAISERROR (''pet name has space : name = [%s]'', 16, 1, @pet_name)
	set @result = -1
END

-- check user_prohibit 
if exists(select char_name from user_prohibit (nolock) where char_name = @pet_name)
begin
	RAISERROR (''Pet  name is prohibited: name = [%s]'', 16, 1, @pet_name)
	set @result = -2
end

-- prohibit word
declare @user_prohibit_word nvarchar(20)
select top 1 @user_prohibit_word = words from user_prohibit_word (nolock) where PATINDEX(''%'' + words + ''%'', @pet_name) > 0 
if @user_prohibit_word is not null
begin
	RAISERROR (''pet  name has prohibited word: name = [%s], word[%s]'', 16, 1, @pet_name, @user_prohibit_word)
	set @result = -3
end

-- check reserved name
--declare @reserved_name nvarchar(50)
--select top 1 @reserved_name = char_name from user_name_reserved (nolock) where used = 0 and char_name = @pet_name
--if not @reserved_name is null
--begin
--	RAISERROR (''pet name is reserved by other player: name = [%s]'', 16, 1, @pet_name)
--	set @result = -4
--end

-- check duplicated pet name
declare @dup_pet_name nvarchar(50)
select top 1 @dup_pet_name = nick_name from pet_data (nolock) where nick_name = @pet_name
if not @dup_pet_name is null
begin
	RAISERROR (''duplicated pet name[%s]'', 16, 1, @pet_name)
	set @result = -4
end

select @result

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreatePledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_CreatePledge
desc:	create pledge

history:	2007-05-14	modified by btwinuni
*/
CREATE PROCEDURE
[dbo].[lin_CreatePledge] (@name NVARCHAR(50), @ruler_id INT)
AS

SET NOCOUNT ON

DECLARE @pledge_id INT


BEGIN TRAN

IF @name LIKE N'' ''   
BEGIN  
 RAISERROR (''pledge name has space : name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END  
  
-- check user_prohibit   
IF EXISTS(SELECT char_name FROM user_prohibit (nolock) WHERE char_name = @name)  
BEGIN
 RAISERROR (''pledge name is prohibited: name = [%s]'', 16, 1, @name)  
 GOTO EXIT_TRAN
END
  
DECLARE @user_prohibit_word NVARCHAR(20)  
SELECT TOP 1 @user_prohibit_word = words FROM user_prohibit_word (nolock) WHERE PATINDEX(''%'' + words + ''%'', @name) > 0   
IF @user_prohibit_word IS NOT NULL
BEGIN
 RAISERROR (''pledge name has prohibited word: name = [%s], word[%s]'', 16, 1, @name, @user_prohibit_word)  
 GOTO EXIT_TRAN
END

if exists (select * from changed_name_by_merge (nolock) where type = 1 and name_new = @name)
begin
 raiserror (''pledge name is duplicated: name = [%s]'', 16, 1, @name)
 goto EXIT_TRAN
end

INSERT INTO Pledge (name, ruler_id) VALUES (@name, @ruler_id)

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	SELECT @pledge_id = @@IDENTITY
	UPDATE user_data
	SET pledge_id = @pledge_id
	WHERE char_id = @ruler_id
END
ELSE
BEGIN
	SELECT @pledge_id = 0
	GOTO EXIT_TRAN
END

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
BEGIN
	SELECT @pledge_id = 0
END

EXIT_TRAN:
IF @pledge_id <> 0
BEGIN
	COMMIT TRAN
	SELECT @pledge_id AS pledge_id, (SELECT char_name FROM user_data WHERE char_id = @ruler_id) AS pledge_ruler_name
END
ELSE
BEGIN
	ROLLBACK TRAN
	SELECT 0 AS pledge_id, N'''' AS pledge_ruler_name
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetNewNameForMerged]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_SetNewNameForMerged
desc:	set new name

history:	2007-05-14	created by btwinuni
*/
create procedure [dbo].[lin_SetNewNameForMerged]
	@type int,
	@dbid int,
	@name nvarchar(50)
as

set nocount on

declare @ret int
set @ret = 0

begin tran

if @type = 1
begin
	if @name like N'' ''
	begin
		raiserror(''pledge name has space : name = [%s]'', 16, 1, @name)
		goto exit_tran
	end
	
	-- check user_prohibit   
	if exists (select char_name from user_prohibit (nolock) where char_name = @name)  
	begin
		raiserror(''pledge name is prohibited: name = [%s]'', 16, 1, @name)
		goto exit_tran
	end
	  
	declare @user_prohibit_word nvarchar(20)
	select top 1 @user_prohibit_word = words from user_prohibit_word (nolock) where patindex(''%'' + words + ''%'', @name) > 0
	if @user_prohibit_word is not null
	begin
		raiserror(''pledge name has prohibited word: name = [%s], word[%s]'', 16, 1, @name, @user_prohibit_word)
		goto exit_tran
	end
	
	if exists (select * from changed_name_by_merge (nolock) where type = 1 and name_new = @name)
	begin
		raiserror (''pledge name is duplicated: name = [%s]'', 16, 1, @name)
		goto exit_tran
	end
	
	if exists (select * from pledge (nolock) where name = @name)
	begin
		raiserror (''pledge name is duplicated: name = [%s]'', 16, 1, @name)
		goto exit_tran
	end

	update changed_name_by_merge
	set name_temp = name_new,
		name_new = @name,
		change_flag = 2,		-- for pre-maintenance
		change_date = getdate()
	where id = @dbid
		and type = @type
		and change_flag = 0

	select @ret = @@rowcount
end

exit_tran:
if @ret > 0
begin
	commit tran
	select 1
end
else
begin
	rollback tran
	select 0
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CopyChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CopyChar
	copy character sp
INPUT
	@char_id		int
	@new_char_name	nvarchar(24)
	@account_id		int
	@account_name	nvarchar(24)
	@builder		int
OUTPUT

return
made by
	young
date
	2003-11-17
	2005-09-07	modified by btwinuni
	2005-10-28	modified by btwinuni	for CH4
	2006-01-25	modified	by btwinuni	exp: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_CopyChar]
(
@char_id		int,
@new_char_name	nvarchar(24),
@account_id		int,
@account_name	nvarchar(24),
@builder		int
)
AS

SET NOCOUNT ON


declare @new_char_id	int

set @new_char_id = 0

SET @new_char_name = RTRIM(@new_char_name)


IF @new_char_name LIKE N'' '' 
BEGIN
	RAISERROR (''Character name has space : name = [%s]'', 16, 1, @new_char_name)
	RETURN -1
END

-- check user_prohibit 
if exists(select char_name from user_prohibit (nolock) where char_name = @new_char_name)
begin
	RAISERROR (''Character name is prohibited: name = [%s]'', 16, 1, @new_char_name)
	RETURN -1	
end

declare @user_prohibit_word nvarchar(20)
select top 1 @user_prohibit_word = words from user_prohibit_word (nolock) where PATINDEX(''%'' + words + ''%'', @new_char_name) > 0   
if @user_prohibit_word is not null
begin
	RAISERROR (''Character name has prohibited word: name = [%s], word[%s]'', 16, 1, @new_char_name, @user_prohibit_word)
	RETURN -1	
end

-- check reserved name
declare @reserved_name nvarchar(50)
declare @reserved_account_id int
select top 1 @reserved_name = char_name, @reserved_account_id = account_id from user_name_reserved (nolock) where used = 0 and char_name = @new_char_name
if not @reserved_name is null
begin
	if not @reserved_account_id = @account_id
	begin
		RAISERROR (''Character name is reserved by other player: name = [%s]'', 16, 1, @new_char_name)
		RETURN -1
	end
end

declare	@gender	int
declare	@race	int
declare	@class	int
declare	@world	int
declare	@xloc	int
declare	@yloc	int
declare	@zloc	int
declare	@HP	float
declare	@MP	float
declare	@SP	int
declare	@Exp	bigint
declare	@Lev	int
declare	@align	int
declare	@PK	int
declare	@PKpardon	int
declare	@Duel		int
declare	@quest_flag	binary
declare	@max_hp	int
declare	@max_mp	int
declare	@quest_memo	char(32)
declare	@face_index	int
declare	@hair_shape_index	int
declare	@hair_color_index	int
declare	@drop_exp	bigint
declare	@subjob_id	int
declare	@cp		float
declare	@max_cp	float
declare	@subjob0_class	int
declare	@subjob1_class	int
declare	@subjob2_class	int
declare	@subjob3_class	int

-- insert user_data
select  	@builder = builder,
	@gender = gender,
	@race = race, 
	@class = class,
	@world = world,
	@xloc = xloc,
	@yloc = yloc,
	@zloc = zloc,
	@HP = HP,
	@MP = MP,
	@SP = SP,
	@Exp = Exp,
	@Lev = Lev,
	@align = align,
	@PK = PK,
	@PKpardon = PKpardon,
	@Duel = Duel,
	@quest_flag = quest_flag,
	@max_hp = max_hp,
	@max_mp = max_mp,
	@quest_memo = quest_memo,
	@face_index = face_index,
	@hair_shape_index = hair_shape_index,
	@hair_color_index = hair_color_index,
	@drop_exp = drop_exp,
	@subjob_id = subjob_id,
	@cp = cp,
	@max_cp = max_cp,
	@subjob0_class = subjob0_class,
	@subjob1_class = subjob1_class,
	@subjob2_class = subjob2_class,
	@subjob3_class = subjob3_class
	from user_data (nolock) 
	where char_id = @char_id

if ( @@ROWCOUNT > 0 ) 
begin
	INSERT INTO user_data 
	( char_name, account_name, account_id, pledge_id, create_date,
	builder, gender, race, class, world, xloc, yloc, zloc, HP, MP, SP, Exp, Lev, align, PK, PKpardon, Duel,
	quest_flag, max_hp, max_mp, quest_memo, face_index, hair_shape_index, hair_color_index, drop_exp, subjob_id, cp, max_cp,
	subjob0_class, subjob1_class, subjob2_class, subjob3_class)
	VALUES
	(@new_char_name, @account_name, @account_id, 0, GETDATE(),
	@builder, @gender, @race, @class, @world, @xloc, @yloc, @zloc, @HP, @MP, @SP, @Exp, @Lev, @align, @PK, @PKpardon, @Duel,
	@quest_flag, @max_hp, @max_mp, @quest_memo, @face_index, @hair_shape_index, @hair_color_index, @drop_exp, @subjob_id, @cp, @max_cp,
	@subjob0_class, @subjob1_class, @subjob2_class, @subjob3_class)

	IF (@@error = 0)
	BEGIN
		SET @new_char_id = @@IDENTITY

		insert into user_item ( char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
		select @new_char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse
		from user_item (nolock) where char_id = @char_id and item_type not in (
			2375, 3500, 3501, 3502, 4422, 4423, 4424, 4425,	-- pet
			4442, 4443, 4444 )				-- lotto, monster race

		insert into user_skill ( char_id,  skill_id, skill_lev, to_end_time, subjob_id )
		select @new_char_id, skill_id, skill_lev, to_end_time, subjob_id
		from user_skill (nolock) where char_id = @char_id

		insert into quest 
		(	char_id, 
			q1,			s1,		s2_1,			j1,	
			q2,			s2,		s2_2,			j2,	
			q3,			s3,		s2_3,			j3,	
			q4,			s4,		s2_4,			j4,	
			q5,			s5,		s2_5,			j5,	
			q6,			s6,		s2_6,			j6,	
			q7,			s7,		s2_7,			j7,	
			q8,			s8,		s2_8,			j8,	
			q9,			s9,		s2_9,			j9,	
			q10,		s10,	s2_10,			j10,
			q11,		s11,	s2_11,			j11,
			q12,		s12,	s2_12,			j12,
			q13,		s13,	s2_13,			j13,
			q14,		s14,	s2_14,			j14,
			q15,		s15,	s2_15,			j15,
			q16,		s16,	s2_16,			j16,
			q17,		s17,	s2_17,			j17,
			q18,		s18,	s2_18,			j18,
			q19,		s19,	s2_19,			j19,
			q20,		s20,	s2_20,			j20,
			q21,		s21,	s2_21,			j21,
			q22,		s22,	s2_22,			j22,
			q23,		s23,	s2_23,			j23,
			q24,		s24,	s2_24,			j24,
			q25,		s25,	s2_25,			j25,
			q26,		s26,	s2_26,			j26
		)
		select 
			@new_char_id, 
			q1,			s1,		s2_1,			j1,	
			q2,			s2,		s2_2,			j2,	
			q3,			s3,		s2_3,			j3,	
			q4,			s4,		s2_4,			j4,	
			q5,			s5,		s2_5,			j5,	
			q6,			s6,		s2_6,			j6,	
			q7,			s7,		s2_7,			j7,	
			q8,			s8,		s2_8,			j8,	
			q9,			s9,		s2_9,			j9,	
			q10,		s10,	s2_10,			j10,
			q11,		s11,	s2_11,			j11,
			q12,		s12,	s2_12,			j12,
			q13,		s13,	s2_13,			j13,
			q14,		s14,	s2_14,			j14,
			q15,		s15,	s2_15,			j15,
			q16,		s16,	s2_16,			j16,
			q17,		s17,	s2_17,			j17,
			q18,		s18,	s2_18,			j18,
			q19,		s19,	s2_19,			j19,
			q20,		s20,	s2_20,			j20,
			q21,		s21,	s2_21,			j21,
			q22,		s22,	s2_22,			j22,
			q23,		s23,	s2_23,			j23,
			q24,		s24,	s2_24,			j24,
			q25,		s25,	s2_25,			j25,
			q26,		s26,	s2_26,			j26
		from quest (nolock) where char_id = @char_id

		insert into user_subjob ( char_id, hp, mp, sp, exp, level, henna_1, henna_2, henna_3, subjob_id, create_date )
		select @new_char_id, hp, mp, sp, exp, level, 0, 0, 0, subjob_id, GETDATE()
		from user_subjob (nolock) where char_id = @char_id

	END
end

SELECT @new_char_id

if @new_char_id > 0
begin
	-- make user_history
	exec lin_InsertUserHistory @new_char_name, @new_char_id, 1, @account_name, NULL
	if not @reserved_name is null
		update user_name_reserved set used = 1 where char_name = @reserved_name
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressSiegeState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressSiegeState
   
INPUT   
 @fortress_id int,  
 @siege_status int,
 @siege_start_time int,
 @siege_elapsed_time int
 @is_valid_info int
  
OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressSiegeState]  
(  
 @fortress_id int,
 @siege_status int,
 @siege_start_time int,
 @siege_elapsed_time int,
 @is_valid_info int
)  
AS  
SET NOCOUNT ON

UPDATE fortress_siege
SET siege_status = @siege_status, siege_start_time = @siege_start_time, siege_elapsed_time = @siege_elapsed_time, is_valid_info = @is_valid_info
WHERE fortress_id = @fortress_id

IF @@rowcount = 0
BEGIN
	INSERT INTO fortress_siege(fortress_id, siege_status, siege_start_time, siege_elapsed_time, is_valid_info)
	VALUES (@fortress_id, @siege_status, @siege_start_time, @siege_elapsed_time, @is_valid_info)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadFortressSiege]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadFortressSiege
   
INPUT   
 @fortress_id int,  
  
OUTPUT  
 siege_status,   
 siege_start_time,   
 siege_elapsed_time,
 is_valid_info   

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadFortressSiege]  
(  
 @fortress_id int
)  
AS  
SET NOCOUNT ON  
  
SELECT   
 siege_status, siege_start_time, siege_elapsed_time, is_valid_info
FROM   
 fortress_siege (nolock)
WHERE   
 fortress_id = @fortress_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadTimeAttackRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_LoadTimeAttackRecord
  * @brief TimeAttackRecord 로드
  *
  * @date 2004/12/04
  * @author sonai  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_LoadTimeAttackRecord] 
(
@ssq_round INT
)
AS

SELECT room_no, record_type, ssq_round, ssq_part, point, record_time, elapsed_time, member_count, member_names, 
	 ISNULL(member_dbid_list, ''''), ISNULL(member_reward_flags, 0), ISNULL(fee, 0)
	 FROM time_attack_record  WHERE ssq_round = @ssq_round

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveTimeAttackRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
  * @procedure lin_SaveTimeAttackRecord
  * @brief 타임 어택 정보 저장.
  *
  * @date 2004/12/04
  * @author Seongeun Park  <sonai@ncsoft.net>
  */
CREATE PROCEDURE [dbo].[lin_SaveTimeAttackRecord] 
(
@room_no TINYINT,
@record_type TINYINT,
@ssq_round INT,

@ssq_part TINYINT,
@point INT,
@record_time INT,
@elapsed_time INT,
@member_count  INT,
@member_names NVARCHAR(256),
@member_dbid_list NVARCHAR(128),
@member_reward_flags INT,
@fee INT
)
AS

SET NOCOUNT ON

UPDATE time_attack_record SET  ssq_part = @ssq_part,
				  point = @point,
				  record_time = @record_time,
				  elapsed_time = @elapsed_time,
			      	  member_count = @member_count,
				  member_names = @member_names,
				  member_dbid_list = @member_dbid_list,
				  member_reward_flags = @member_reward_flags,
				  fee = @fee			       	                          
  	                   WHERE room_no = @room_no AND record_type = @record_type AND ssq_round = @ssq_round

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateTimeAttackRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
 * @fn lin_CreateTimeAttackRecord
 * @brief 타임 어택 기록에 대한 레코드를 하나 생성
 */
CREATE PROCEDURE [dbo].[lin_CreateTimeAttackRecord]
(
@room_no TINYINT,
@record_type TINYINT,
@ssq_round INT,
@ssq_part TINYINT,
@point       INT,
@record_time INT,
@elapsed_time INT,
@member_count INT,
@member_names NVARCHAR(256),
@member_dbid_list NVARCHAR(128),
@member_reward_flags INT,
@fee INT

)
AS
SET NOCOUNT ON

INSERT INTO time_attack_record  
	(room_no, record_type, ssq_round, ssq_part, point, record_time, elapsed_time, member_count, member_names,
              member_dbid_list, member_reward_flags, fee) 
	values 
	(@room_no, @record_type, @ssq_round, @ssq_part, @point, @record_time, @elapsed_time, @member_count, @member_names,
              @member_dbid_list, @member_reward_flags, @fee)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MakeSnapTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_MakeSnapTable
desc:	make tmp table for world snap shot of user_data, user_item, pledge, user_nobless, user_subjob, ssq
exam:	exec lin_MakeSnapTable
history:	2004-06-15	created by flagoftiger
	2005-05-16	modified by btwinuni	add: pledge
	2005-09-29	modified by btwinuni	add: user_nobless
	2006-01-09	modified by neoliebe	add: user_subjob
	2006-02-20	modified by btwinuni	add: rel. ssq
	2006-02-20	modified by neoliebe	mod: remove where-condition from user_item query
*/
CREATE PROCEDURE [dbo].[lin_MakeSnapTable]
AS
SET NOCOUNT ON
-- user_data
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_user_data'') and type in (N''U''))	drop table dbo.tmp_user_data
select * into dbo.tmp_user_data from dbo.user_data (nolock) where account_id > 0 and builder = 0
-- user_item
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_user_item'') and type in (N''U''))	drop table dbo.tmp_user_item
select * into dbo.tmp_user_item from dbo.user_item (nolock) --where char_id in (select char_id from user_data (nolock) where account_id > 0 and builder = 0)
-- user_subjob
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_user_subjob'') and type in (N''U''))	drop table dbo.tmp_user_subjob
select * into dbo.tmp_user_subjob from dbo.user_subjob (nolock) where char_id in (select char_id from user_data (nolock) where account_id > 0 and builder = 0)
-- pledge
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_pledge'') and type in (N''U''))	drop table dbo.tmp_pledge
select * into dbo.tmp_pledge from dbo.pledge (nolock)
-- user_nobless
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_user_nobless'') and type in (N''U''))	drop table dbo.tmp_user_nobless
select * into dbo.tmp_user_nobless from dbo.user_nobless (nolock) where char_id in (select char_id from user_data (nolock) where account_id > 0 and builder = 0)
-- for SSQ
declare @round int
select @round = max(round_number) from ssq_data (nolock)
-- ssq_data
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_ssq_data'') and type in (N''U''))	drop table dbo.tmp_ssq_data
select * into dbo.tmp_ssq_data from dbo.ssq_data (nolock) where round_number = @round
-- ssq_join_data
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_ssq_join_data'') and type in (N''U''))	drop table dbo.tmp_ssq_join_data
select * into dbo.tmp_ssq_join_data from dbo.ssq_join_data (nolock) where round_number = @round
-- time_attack_record
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_time_attack_record'') and type in (N''U''))	drop table dbo.tmp_time_attack_record
select * into dbo.tmp_time_attack_record from dbo.time_attack_record (nolock) where ssq_round = @round
-- ssq_user_data
if exists (select * from sys.objects where object_id = object_id(N''dbo.tmp_ssq_user_data'') and type in (N''U''))	drop table dbo.tmp_ssq_user_data
select * into dbo.tmp_ssq_user_data from dbo.ssq_user_data (nolock) where round_number = @round

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SavePledgeContribution]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SavePledgeContribution]
(
@agit_id INT,
@pledge_id INT,
@contribution INT
)
AS
SET NOCOUNT ON

UPDATE pledge_contribution SET contribution = contribution + @contribution WHERE pledge_id = @pledge_id AND residence_id = @agit_id
IF @@ROWCOUNT = 0
INSERT INTO pledge_contribution (contribution, pledge_id, residence_id) VALUES (@contribution, @pledge_id , @agit_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertPledgeContribution]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_InsertPledgeContribution]
	@contribution	int,
	@pledge_id	int,
	@residence_id	int
as
set nocount on

INSERT INTO pledge_contribution (contribution, pledge_id, residence_id) VALUES (@contribution, @pledge_id, @residence_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetContributionWinnerPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetContributionWinnerPledge]
(
	@agit_id		int,
	@register_only	int
)
AS
SET NOCOUNT ON

IF @register_only = 0	-- not siege agit
BEGIN
SELECT 
	p.pledge_id 
FROM 
	pledge p (nolock) , 
	pledge_contribution pc (nolock)  
WHERE 
	p.pledge_id = pc.pledge_id 
	AND (p.agit_id = @agit_id OR p.agit_id = 0) 
	AND p.skill_level >= 4 
	AND pc.residence_id = @agit_id
ORDER BY 
	pc.contribution DESC
END
ELSE			-- siege agit
BEGIN
SELECT 
	p.pledge_id 
FROM 
	pledge p (nolock) , 
	pledge_contribution pc (nolock)  
WHERE 
	p.pledge_id = pc.pledge_id 
	AND (p.agit_id = @agit_id OR p.agit_id = 0) 
	AND p.skill_level >= 4 
	AND pc.residence_id = @agit_id
	AND p.pledge_id IN (SELECT pledge_id FROM siege_agit_pledge WHERE agit_id = @agit_id)
ORDER BY 
	pc.contribution DESC
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeletePledgeContribution]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeletePledgeContribution    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DeletePledgeContribution
	
INPUT	
	@residence_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_DeletePledgeContribution]
(
	@residence_id		int
)
AS
SET NOCOUNT ON

DELETE FROM pledge_contribution WHERE residence_id = @residence_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetContributionRelatedPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetContributionRelatedPledge    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetContributionRelatedPledge
	
INPUT	
	@residence_id		int
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_GetContributionRelatedPledge]
(
	@residence_id		int
)
AS
SET NOCOUNT ON

SELECT pledge_id FROM pledge_contribution (nolock)  WHERE residence_id = @residence_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AcademyGraduateList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_AcademyGraduater
	academy graduated  list
INPUT
	@pledge_id		int
OUTPUT

return

date
	2006-07-12	kks
********************************************/

CREATE PROCEDURE
[dbo].[lin_AcademyGraduateList] (
	@pledge_id		int
)
AS

select char_name 
from user_data U(nolock), academy_member A(nolock)
where U.char_id = A.user_id
and A.pledge_id = @pledge_id
and A.status = 1
and A.status_time between dateadd(day, -7, getdate()) and getdate()

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadMinigameAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_LoadMinigameAgitPledge]
(
	@agit_id	int
)
as
set nocount on
select pledge_id, point from minigame_agit_pledge where agit_id=@agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteFromMinigameAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  procedure [dbo].[lin_DeleteFromMinigameAgitPledge]
(
	@agit_id		int,
	@pledge_id	int
)
as
set nocount on
delete from minigame_agit_pledge where agit_id=@agit_id and pledge_id=@pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoMinigameAgitPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  procedure [dbo].[lin_InsertIntoMinigameAgitPledge]
(
	@agit_id		int,
	@pledge_id	int,
	@point		int
)
as
set nocount on
IF not exists(select * from minigame_agit_pledge where agit_id=@agit_id and pledge_id=@pledge_id)
  BEGIN
	insert into minigame_agit_pledge(agit_id, pledge_id, point) values (@agit_id, @pledge_id, @point)
	SELECT 0
  END
ELSE
  BEGIN
	SELECT -1
  END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadEventTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadEventTime]
	@account_id	int
as

select event_time from user_event_time where account_id = @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveEventTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveEventTime]
	@account_id	int,
	@event_time	int
as
set nocount on

update user_event_time set event_time = @event_time where account_id = @account_id
if @@rowcount = 0
begin
	insert into user_event_time (account_id, event_time) values (@account_id, @event_time)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateActiveSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UpdateActiveSkill]
(    
 @char_id INT,    
 @s1 INT, @l1 SMALLINT, @d1 INT, @c1 SMALLINT,     
 @s2 INT, @l2 SMALLINT, @d2 INT, @c2 SMALLINT,     
 @s3 INT, @l3 SMALLINT, @d3 INT, @c3 SMALLINT,     
 @s4 INT, @l4 SMALLINT, @d4 INT, @c4 SMALLINT,     
 @s5 INT, @l5 SMALLINT, @d5 INT, @c5 SMALLINT,     
 @s6 INT, @l6 SMALLINT, @d6 INT, @c6 SMALLINT,     
 @s7 INT, @l7 SMALLINT, @d7 INT, @c7 SMALLINT,     
 @s8 INT, @l8 SMALLINT, @d8 INT, @c8 SMALLINT,     
 @s9 INT, @l9 SMALLINT, @d9 INT, @c9 SMALLINT,     
 @s10 INT, @l10 SMALLINT, @d10 INT, @c10 SMALLINT,     
 @s11 INT, @l11 SMALLINT, @d11 INT, @c11 SMALLINT,     
 @s12 INT, @l12 SMALLINT, @d12 INT, @c12 SMALLINT,     
 @s13 INT, @l13 SMALLINT, @d13 INT, @c13 SMALLINT,     
 @s14 INT, @l14 SMALLINT, @d14 INT, @c14 SMALLINT,     
 @s15 INT, @l15 SMALLINT, @d15 INT, @c15 SMALLINT,     
 @s16 INT, @l16 SMALLINT, @d16 INT, @c16 SMALLINT,     
 @s17 INT, @l17 SMALLINT, @d17 INT, @c17 SMALLINT,     
 @s18 INT, @l18 SMALLINT, @d18 INT, @c18 SMALLINT,     
 @s19 INT, @l19 SMALLINT, @d19 INT, @c19 SMALLINT,     
 @s20 INT, @l20 SMALLINT, @d20 INT, @c20 SMALLINT,
 @s21 INT, @l21 SMALLINT, @d21 INT, @c21 SMALLINT,     
 @s22 INT, @l22 SMALLINT, @d22 INT, @c22 SMALLINT,     
 @s23 INT, @l23 SMALLINT, @d23 INT, @c23 SMALLINT,     
 @s24 INT, @l24 SMALLINT, @d24 INT, @c24 SMALLINT,     
 @s25 INT, @l25 SMALLINT, @d25 INT, @c25 SMALLINT,     
 @s26 INT, @l26 SMALLINT, @d26 INT, @c26 SMALLINT,     
 @s27 INT, @l27 SMALLINT, @d27 INT, @c27 SMALLINT,     
 @s28 INT, @l28 SMALLINT, @d28 INT, @c28 SMALLINT,     
 @s29 INT, @l29 SMALLINT, @d29 INT, @c29 SMALLINT,     
 @s30 INT, @l30 SMALLINT, @d30 INT, @c30 SMALLINT,     
 @s31 INT, @l31 SMALLINT, @d31 INT, @c31 SMALLINT,     
 @s32 INT, @l32 SMALLINT, @d32 INT, @c32 SMALLINT,     
 @s33 INT, @l33 SMALLINT, @d33 INT, @c33 SMALLINT,     
 @s34 INT, @l34 SMALLINT, @d34 INT, @c34 SMALLINT
)    
AS    
SET NOCOUNT ON    
  
IF EXISTS(SELECT * FROM user_activeskill WHERE char_id = @char_id)  
BEGIN  
 UPDATE user_activeskill     
 SET     
 s1 = @s1, l1 = @l1, d1 = @d1, c1 = @c1,     
 s2 = @s2, l2 = @l2, d2 = @d2, c2 = @c2,     
 s3 = @s3, l3 = @l3, d3 = @d3, c3 = @c3,     
 s4 = @s4, l4 = @l4, d4 = @d4, c4 = @c4,     
 s5 = @s5, l5 = @l5, d5 = @d5, c5 = @c5,     
 s6 = @s6, l6 = @l6, d6 = @d6, c6 = @c6,     
 s7 = @s7, l7 = @l7, d7 = @d7, c7 = @c7,     
 s8 = @s8, l8 = @l8, d8 = @d8, c8 = @c8,     
 s9 = @s9, l9 = @l9, d9 = @d9, c9 = @c9,     
 s10 = @s10, l10 = @l10, d10 = @d10, c10 = @c10,     
 s11 = @s11, l11 = @l11, d11 = @d11, c11 = @c11,     
 s12 = @s12, l12 = @l12, d12 = @d12, c12 = @c12,     
 s13 = @s13, l13 = @l13, d13 = @d13, c13 = @c13,     
 s14 = @s14, l14 = @l14, d14 = @d14, c14 = @c14,     
 s15 = @s15, l15 = @l15, d15 = @d15, c15 = @c15,     
 s16 = @s16, l16 = @l16, d16 = @d16, c16 = @c16,     
 s17 = @s17, l17 = @l17, d17 = @d17, c17 = @c17,     
 s18 = @s18, l18 = @l18, d18 = @d18, c18 = @c18,     
 s19 = @s19, l19 = @l19, d19 = @d19, c19 = @c19,     
 s20 = @s20, l20 = @l20, d20 = @d20, c20 = @c20 ,
 s21 = @s21, l21 = @l21, d21 = @d21, c21 = @c21,     
 s22 = @s22, l22 = @l22, d22 = @d22, c22 = @c22,     
 s23 = @s23, l23 = @l23, d23 = @d23, c23 = @c23,     
 s24 = @s24, l24 = @l24, d24 = @d24, c24 = @c24,     
 s25 = @s25, l25 = @l25, d25 = @d25, c25 = @c25,     
 s26 = @s26, l26 = @l26, d26 = @d26, c26 = @c26,     
 s27 = @s27, l27 = @l27, d27 = @d27, c27 = @c27,     
 s28 = @s28, l28 = @l28, d28 = @d28, c28 = @c28,     
 s29 = @s29, l29 = @l29, d29 = @d29, c29 = @c29,     
 s30 = @s30, l30 = @l30, d30 = @d30, c30 = @c30,     
 s31 = @s31, l31 = @l31, d31 = @d31, c31 = @c31,     
 s32 = @s32, l32 = @l32, d32 = @d32, c32 = @c32,     
 s33 = @s33, l33 = @l33, d33 = @d33, c33 = @c33,     
 s34 = @s34, l34 = @l34, d34 = @d34, c34 = @c34
 WHERE char_id = @char_id    END  
ELSE   
BEGIN  
 INSERT INTO user_activeskill    
 (char_id,     
 s1, l1, d1, c1,     
 s2, l2, d2, c2,     
 s3, l3, d3, c3,     
 s4, l4, d4, c4,     
 s5, l5, d5, c5,     
 s6, l6, d6, c6,     
 s7, l7, d7, c7,     
 s8, l8, d8, c8,     
 s9, l9, d9, c9,     
 s10, l10, d10, c10,     
 s11, l11, d11, c11,     
 s12, l12, d12, c12,     
 s13, l13, d13, c13,     
 s14, l14, d14, c14,     
 s15, l15, d15, c15,     
 s16, l16, d16, c16,     
 s17, l17, d17, c17,     
 s18, l18, d18, c18,     
 s19, l19, d19, c19,     
 s20, l20, d20, c20,
 s21, l21, d21, c21,     
 s22, l22, d22, c22,     
 s23, l23, d23, c23,     
 s24, l24, d24, c24,     
 s25, l25, d25, c25,     
 s26, l26, d26, c26,     
 s27, l27, d27, c27,     
 s28, l28, d28, c28,     
 s29, l29, d29, c29,     
 s30, l30, d30, c30,     
 s31, l31, d31, c31,     
 s32, l32, d32, c32,     
 s33, l33, d33, c33,     
 s34, l34, d34, c34
)     
 VALUES     
 (@char_id,    
 @s1, @l1, @d1, @c1,     
 @s2, @l2, @d2, @c2,     
 @s3, @l3, @d3, @c3,     
 @s4, @l4, @d4, @c4,     
 @s5, @l5, @d5, @c5,     
 @s6, @l6, @d6, @c6,     
 @s7, @l7, @d7, @c7,     
 @s8, @l8, @d8, @c8,     
 @s9, @l9, @d9, @c9,     
 @s10, @l10, @d10, @c10,     
 @s11, @l11, @d11, @c11,     
 @s12, @l12, @d12, @c12,     
 @s13, @l13, @d13, @c13,     
 @s14, @l14, @d14, @c14,     
 @s15, @l15, @d15, @c15,     
 @s16, @l16, @d16, @c16,     
 @s17, @l17, @d17, @c17,     
 @s18, @l18, @d18, @c18,     
 @s19, @l19, @d19, @c19,     
 @s20, @l20, @d20, @c20,
 @s21, @l21, @d21, @c21,     
 @s22, @l22, @d22, @c22,     
 @s23, @l23, @d23, @c23,     
 @s24, @l24, @d24, @c24,     
 @s25, @l25, @d25, @c25,     
 @s26, @l26, @d26, @c26,     
 @s27, @l27, @d27, @c27,     
 @s28, @l28, @d28, @c28,     
 @s29, @l29, @d29, @c29,     
 @s30, @l30, @d30, @c30,     
 @s31, @l31, @d31, @c31,     
 @s32, @l32, @d32, @c32,     
 @s33, @l33, @d33, @c33,     
 @s34, @l34, @d34, @c34
)    
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateSubJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_CreateSubJob
desc:	create subjob

history:	2006-01-10	modified by btwinuni: if the char_id and subjob_id are existed user_subjob table, don''t insert
			2007-08-21	modified by btwinuni: update class
*/
CREATE PROCEDURE [dbo].[lin_CreateSubJob]
(
	@char_id	INT,
	@new_subjob_id TINYINT,
	@new_class	TINYINT,
	@new_lev	INT,
	@new_exp	BIGINT,
	@old_subjob_id	TINYINT,
	@hp		FLOAT,
	@mp		FLOAT,
	@sp		INT,
	@exp		BIGINT,
	@level		TINYINT,
	@henna_1	INT,
	@henna_2	INT,
	@henna_3	INT
)
AS
SET NOCOUNT ON
DECLARE @ret INT
SELECT @ret = 0

-- transaction on
BEGIN TRAN

IF @new_subjob_id = 1
BEGIN
	UPDATE user_data
	SET class = @new_class
		, subjob_id = @new_subjob_id
		, subjob1_class = @new_class
		, SP = 0
		, Exp = @new_exp
		, Lev = @new_lev
	WHERE char_id = @char_id
END
ELSE IF @new_subjob_id = 2
BEGIN
	UPDATE user_data
	SET class = @new_class
		, subjob_id = @new_subjob_id
		, subjob2_class = @new_class
		, SP = 0
		, Exp = @new_exp
		, Lev = @new_lev
	WHERE char_id = @char_id
END
ELSE IF @new_subjob_id = 3
BEGIN
	UPDATE user_data
	SET class = @new_class
		, subjob_id = @new_subjob_id
		, subjob3_class = @new_class
		, SP = 0
		, Exp = @new_exp
		, Lev = @new_lev
	WHERE char_id = @char_id
END
IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
BEGIN
	GOTO EXIT_TRAN
END

-- save old class
IF @old_subjob_id = 0 AND (NOT EXISTS(SELECT char_id FROM user_subjob WHERE char_id = @char_id AND subjob_id = 0))
BEGIN
	DECLARE @original_date DATETIME
	SELECT @original_date = create_date FROM user_data(NOLOCK) WHERE char_id = @char_id
	INSERT INTO user_subjob
	(char_id, subjob_id, hp, mp, sp, exp, level, henna_1, henna_2, henna_3, create_date)
	VALUES
	(@char_id, 0, @hp, @mp, @sp, @exp, @level, @henna_1, @henna_2, @henna_3, @original_date)
END
UPDATE user_subjob
SET hp = @hp, mp = @mp, sp = @sp, exp = @exp, level = @level, 
	henna_1 = @henna_1, henna_2 = @henna_2, henna_3 = @henna_3
WHERE char_id = @char_id AND subjob_id = @old_subjob_id
IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
BEGIN
	GOTO EXIT_TRAN
END
-- create new class
if not exists (select * from user_subjob (nolock) where char_id = @char_id and subjob_id = @new_subjob_id)
INSERT INTO user_subjob (char_id, hp, mp, sp, exp, level, henna_1, henna_2, henna_3, subjob_id, create_date)
VALUES (@char_id, 1, 1, 0, @new_exp, @new_lev, 0, 0, 0, @new_subjob_id, GETDATE())
IF @@ERROR <> 0 AND @@ROWCOUNT <> 1
BEGIN
	GOTO EXIT_TRAN
END


-- init data: user_activeskill, user_henna
UPDATE user_activeskill
SET	s1 = 0, l1 = 0, d1 = 0, c1 = 0,
	s2 = 0, l2 = 0, d2 = 0, c2 = 0,
	s3 = 0, l3 = 0, d3 = 0, c3 = 0,
	s4 = 0, l4 = 0, d4 = 0, c4 = 0,
	s5 = 0, l5 = 0, d5 = 0, c5 = 0,
	s6 = 0, l6 = 0, d6 = 0, c6 = 0,
	s7 = 0, l7 = 0, d7 = 0, c7 = 0,
	s8 = 0, l8 = 0, d8 = 0, c8 = 0,
	s9 = 0, l9 = 0, d9 = 0, c9 = 0,
	s10 = 0, l10 = 0, d10 = 0, c10 = 0,
	s11 = 0, l11 = 0, d11 = 0, c11 = 0,
	s12 = 0, l12 = 0, d12 = 0, c12 = 0,
	s13 = 0, l13 = 0, d13 = 0, c13 = 0,
	s14 = 0, l14 = 0, d14 = 0, c14 = 0,
	s15 = 0, l15 = 0, d15 = 0, c15 = 0,
	s16 = 0, l16 = 0, d16 = 0, c16 = 0,
	s17 = 0, l17 = 0, d17 = 0, c17 = 0,
	s18 = 0, l18 = 0, d18 = 0, c18 = 0,
	s19 = 0, l19 = 0, d19 = 0, c19 = 0,
	s20 = 0, l20 = 0, d20 = 0, c20 = 0,
	s21 = 0, l21 = 0, d21 = 0, c21 = 0,
	s22 = 0, l22 = 0, d22 = 0, c22 = 0,
	s23 = 0, l23 = 0, d23 = 0, c23 = 0,
	s24 = 0, l24 = 0, d24 = 0, c24 = 0,
	s25 = 0, l25 = 0, d25 = 0, c25 = 0,
	s26 = 0, l26 = 0, d26 = 0, c26 = 0,
	s27 = 0, l27 = 0, d27 = 0, c27 = 0,
	s28 = 0, l28 = 0, d28 = 0, c28 = 0,
	s29 = 0, l29 = 0, d29 = 0, c29 = 0,
	s30 = 0, l30 = 0, d30 = 0, c30 = 0,
	s31 = 0, l31 = 0, d31 = 0, c31 = 0,
	s32 = 0, l32 = 0, d32 = 0, c32 = 0,
	s33 = 0, l33 = 0, d33 = 0, c33 = 0,
	s34 = 0, l34 = 0, d34 = 0, c34 = 0
WHERE char_id = @char_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN
END

UPDATE user_henna
SET henna_1 = 0, henna_2 = 0, henna_3 = 0
WHERE char_id = @char_id
IF @@ERROR = 0
BEGIN
	set @ret = @new_subjob_id
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateActiveSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_CreateActiveSkill]
(
	@char_id INT,
	@s1 INT, @l1 SMALLINT, @d1 INT, @c1 SMALLINT, 
	@s2 INT, @l2 SMALLINT, @d2 INT, @c2 SMALLINT, 
	@s3 INT, @l3 SMALLINT, @d3 INT, @c3 SMALLINT, 
	@s4 INT, @l4 SMALLINT, @d4 INT, @c4 SMALLINT, 
	@s5 INT, @l5 SMALLINT, @d5 INT, @c5 SMALLINT, 
	@s6 INT, @l6 SMALLINT, @d6 INT, @c6 SMALLINT, 
	@s7 INT, @l7 SMALLINT, @d7 INT, @c7 SMALLINT, 
	@s8 INT, @l8 SMALLINT, @d8 INT, @c8 SMALLINT, 
	@s9 INT, @l9 SMALLINT, @d9 INT, @c9 SMALLINT, 
	@s10 INT, @l10 SMALLINT, @d10 INT, @c10 SMALLINT, 
	@s11 INT, @l11 SMALLINT, @d11 INT, @c11 SMALLINT, 
	@s12 INT, @l12 SMALLINT, @d12 INT, @c12 SMALLINT, 
	@s13 INT, @l13 SMALLINT, @d13 INT, @c13 SMALLINT, 
	@s14 INT, @l14 SMALLINT, @d14 INT, @c14 SMALLINT, 
	@s15 INT, @l15 SMALLINT, @d15 INT, @c15 SMALLINT, 
	@s16 INT, @l16 SMALLINT, @d16 INT, @c16 SMALLINT, 
	@s17 INT, @l17 SMALLINT, @d17 INT, @c17 SMALLINT, 
	@s18 INT, @l18 SMALLINT, @d18 INT, @c18 SMALLINT, 
	@s19 INT, @l19 SMALLINT, @d19 INT, @c19 SMALLINT, 
	@s20 INT, @l20 SMALLINT, @d20 INT, @c20 SMALLINT,
	@s21 INT, @l21 SMALLINT, @d21 INT, @c21 SMALLINT, 
	@s22 INT, @l22 SMALLINT, @d22 INT, @c22 SMALLINT, 
	@s23 INT, @l23 SMALLINT, @d23 INT, @c23 SMALLINT, 
	@s24 INT, @l24 SMALLINT, @d24 INT, @c24 SMALLINT, 
	@s25 INT, @l25 SMALLINT, @d25 INT, @c25 SMALLINT, 
	@s26 INT, @l26 SMALLINT, @d26 INT, @c26 SMALLINT, 
	@s27 INT, @l27 SMALLINT, @d27 INT, @c27 SMALLINT, 
	@s28 INT, @l28 SMALLINT, @d28 INT, @c28 SMALLINT, 
	@s29 INT, @l29 SMALLINT, @d29 INT, @c29 SMALLINT, 
	@s30 INT, @l30 SMALLINT, @d30 INT, @c30 SMALLINT, 
	@s31 INT, @l31 SMALLINT, @d31 INT, @c31 SMALLINT, 
	@s32 INT, @l32 SMALLINT, @d32 INT, @c32 SMALLINT, 
	@s33 INT, @l33 SMALLINT, @d33 INT, @c33 SMALLINT, 
	@s34 INT, @l34 SMALLINT, @d34 INT, @c34 SMALLINT
)
AS
SET NOCOUNT ON
INSERT INTO user_activeskill
(char_id, 
s1, l1, d1, c1, 
s2, l2, d2, c2, 
s3, l3, d3, c3, 
s4, l4, d4, c4, 
s5, l5, d5, c5, 
s6, l6, d6, c6, 
s7, l7, d7, c7, 
s8, l8, d8, c8, 
s9, l9, d9, c9, 
s10, l10, d10, c10, 
s11, l11, d11, c11, 
s12, l12, d12, c12, 
s13, l13, d13, c13, 
s14, l14, d14, c14, 
s15, l15, d15, c15, 
s16, l16, d16, c16, 
s17, l17, d17, c17, 
s18, l18, d18, c18, 
s19, l19, d19, c19, 
s20, l20, d20, c20,
s21, l21, d21, c21, 
s22, l22, d22, c22, 
s23, l23, d23, c23, 
s24, l24, d24, c24, 
s25, l25, d25, c25, 
s26, l26, d26, c26, 
s27, l27, d27, c27, 
s28, l28, d28, c28, 
s29, l29, d29, c29, 
s30, l30, d30, c30, 
s31, l31, d31, c31, 
s32, l32, d32, c32, 
s33, l33, d33, c33, 
s34, l34, d34, c34
) 
VALUES 
(@char_id,
@s1, @l1, @d1, @c1, 
@s2, @l2, @d2, @c2, 
@s3, @l3, @d3, @c3, 
@s4, @l4, @d4, @c4, 
@s5, @l5, @d5, @c5, 
@s6, @l6, @d6, @c6, 
@s7, @l7, @d7, @c7, 
@s8, @l8, @d8, @c8, 
@s9, @l9, @d9, @c9, 
@s10, @l10, @d10, @c10, 
@s11, @l11, @d11, @c11, 
@s12, @l12, @d12, @c12, 
@s13, @l13, @d13, @c13, 
@s14, @l14, @d14, @c14, 
@s15, @l15, @d15, @c15, 
@s16, @l16, @d16, @c16, 
@s17, @l17, @d17, @c17, 
@s18, @l18, @d18, @c18, 
@s19, @l19, @d19, @c19, 
@s20, @l20, @d20, @c20,
@s21, @l21, @d21, @c21, 
@s22, @l22, @d22, @c22, 
@s23, @l23, @d23, @c23, 
@s24, @l24, @d24, @c24, 
@s25, @l25, @d25, @c25, 
@s26, @l26, @d26, @c26, 
@s27, @l27, @d27, @c27, 
@s28, @l28, @d28, @c28, 
@s29, @l29, @d29, @c29, 
@s30, @l30, @d30, @c30, 
@s31, @l31, @d31, @c31, 
@s32, @l32, @d32, @c32, 
@s33, @l33, @d33, @c33, 
@s34, @l34, @d34, @c34
)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RenewSubjob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE   PROCEDURE [dbo].[lin_RenewSubjob]
(
	@char_id		INT,
	@subjob_id		TINYINT,
	@new_class		TINYINT,
	@new_lev		INT,
	@new_exp		BIGINT,
	@old_subjob_id 		TINYINT,
	@hp				FLOAT,
	@mp				FLOAT,
	@sp				INT,
	@exp			BIGINT,
	@level			TINYINT,
	@henna_1		INT,
	@henna_2		INT,
	@henna_3		INT
)
AS
SET NOCOUNT ON
DECLARE @ret INT
SET @ret = 0

-- transaction on
BEGIN TRAN

-- save current status
IF (@subjob_id != @old_subjob_id)	-- save now info
BEGIN
	UPDATE user_subjob
	SET hp = @hp, mp = @mp, sp = @sp, exp = @exp, level = @level, 
		henna_1 = @henna_1, henna_2 = @henna_2, henna_3 = @henna_3
	WHERE char_id = @char_id AND subjob_id = @old_subjob_id
	IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
	BEGIN
		GOTO EXIT_TRAN
	END		
END

-- clear old subjob info
DELETE FROM shortcut_data WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END

DELETE FROM user_skill WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END

DELETE FROM user_skill_reuse_delay WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END

-- update user_data
IF @subjob_id = 1
BEGIN
	UPDATE user_data
	SET class = @new_class
		, subjob_id = @subjob_id
		, subjob1_class = @new_class
		, SP = 0
		, Exp = @new_exp
		, Lev = @new_lev
	WHERE char_id = @char_id
END
ELSE IF @subjob_id = 2
BEGIN
	UPDATE user_data
	SET class = @new_class
		, subjob_id = @subjob_id
		, subjob2_class = @new_class
		, SP = 0
		, Exp = @new_exp
		, Lev = @new_lev
	WHERE char_id = @char_id
END
ELSE IF @subjob_id = 3
BEGIN
	UPDATE user_data
	SET class = @new_class
		, subjob_id = @subjob_id
		, subjob3_class = @new_class
		, SP = 0
		, Exp = @new_exp
		, Lev = @new_lev
	WHERE char_id = @char_id
END
ELSE
BEGIN
	RAISERROR(''Invalid Subjob ID [%d]. user [%d]'', 16, 1, @subjob_id, @char_id)
	GOTO EXIT_TRAN
END

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
BEGIN
	GOTO EXIT_TRAN
END

-- update new class
UPDATE user_subjob
SET hp = 1, mp = 1, sp = 0, exp = @new_exp, level = @new_lev, henna_1 = 0, henna_2 = 0, henna_3 = 0, create_date = GETDATE()
WHERE char_id = @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0 AND @@ROWCOUNT <> 1
BEGIN
	GOTO EXIT_TRAN
END

-- init data: user_activeskill, user_henna
UPDATE user_activeskill
SET	s1 = 0, l1 = 0, d1 = 0, c1 = 0,
	s2 = 0, l2 = 0, d2 = 0, c2 = 0,
	s3 = 0, l3 = 0, d3 = 0, c3 = 0,
	s4 = 0, l4 = 0, d4 = 0, c4 = 0,
	s5 = 0, l5 = 0, d5 = 0, c5 = 0,
	s6 = 0, l6 = 0, d6 = 0, c6 = 0,
	s7 = 0, l7 = 0, d7 = 0, c7 = 0,
	s8 = 0, l8 = 0, d8 = 0, c8 = 0,
	s9 = 0, l9 = 0, d9 = 0, c9 = 0,
	s10 = 0, l10 = 0, d10 = 0, c10 = 0,
	s11 = 0, l11 = 0, d11 = 0, c11 = 0,
	s12 = 0, l12 = 0, d12 = 0, c12 = 0,
	s13 = 0, l13 = 0, d13 = 0, c13 = 0,
	s14 = 0, l14 = 0, d14 = 0, c14 = 0,
	s15 = 0, l15 = 0, d15 = 0, c15 = 0,
	s16 = 0, l16 = 0, d16 = 0, c16 = 0,
	s17 = 0, l17 = 0, d17 = 0, c17 = 0,
	s18 = 0, l18 = 0, d18 = 0, c18 = 0,
	s19 = 0, l19 = 0, d19 = 0, c19 = 0,
	s20 = 0, l20 = 0, d20 = 0, c20 = 0,
	s21 = 0, l21 = 0, d21 = 0, c21 = 0,
	s22 = 0, l22 = 0, d22 = 0, c22 = 0,
	s23 = 0, l23 = 0, d23 = 0, c23 = 0,
	s24 = 0, l24 = 0, d24 = 0, c24 = 0,
	s25 = 0, l25 = 0, d25 = 0, c25 = 0,
	s26 = 0, l26 = 0, d26 = 0, c26 = 0,
	s27 = 0, l27 = 0, d27 = 0, c27 = 0,
	s28 = 0, l28 = 0, d28 = 0, c28 = 0,
	s29 = 0, l29 = 0, d29 = 0, c29 = 0,
	s30 = 0, l30 = 0, d30 = 0, c30 = 0,
	s31 = 0, l31 = 0, d31 = 0, c31 = 0,
	s32 = 0, l32 = 0, d32 = 0, c32 = 0,
	s33 = 0, l33 = 0, d33 = 0, c33 = 0,
	s34 = 0, l34 = 0, d34 = 0, c34 = 0
WHERE char_id = @char_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN
END

UPDATE user_henna
SET henna_1 = 0, henna_2 = 0, henna_3 = 0
WHERE char_id = @char_id
IF @@ERROR = 0
BEGIN
	set @ret = @subjob_id
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeSubJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_ChangeSubJob
desc:	change subjob

history:
*/
CREATE PROCEDURE [dbo].[lin_ChangeSubJob]
(
	@char_id	INT,
	@subjob_id	TINYINT,
	@old_subjob_id	TINYINT,
	@hp		FLOAT,
	@mp		FLOAT,
	@sp		INT,
	@exp		BIGINT,
	@level		TINYINT,
	@henna_1	INT,
	@henna_2	INT,
	@henna_3	INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT
SET @ret = 0

BEGIN TRAN

-- update user_subjob
UPDATE user_subjob
SET hp = @hp, mp = @mp, sp = @sp, exp = @exp, level = @level, 
	henna_1 = @henna_1, henna_2 = @henna_2, henna_3 = @henna_3
WHERE char_id = @char_id AND subjob_id = @old_subjob_id
IF @@ERROR <> 0 AND @@ROWCOUNT <> 1	-- update, insert check
BEGIN
	GOTO EXIT_TRAN
END

-- update user_data
declare @sub_hp float
declare @sub_mp float
declare @sub_sp int
declare @sub_exp bigint
declare @sub_lev int
declare @sub_hen1 int
declare @sub_hen2 int
declare @sub_hen3 int

SELECT @sub_hp = hp, @sub_mp = mp, @sub_sp = sp, @sub_exp = exp, @sub_lev = level,
	@sub_hen1 = henna_1, @sub_hen2 = henna_2, @sub_hen3 = henna_3
FROM user_subjob (nolock)
WHERE char_id = @char_id
	AND subjob_id = @subjob_id

IF @subjob_id = 0
BEGIN
	UPDATE user_data
	SET class = subjob0_class
		, subjob_id = @subjob_id
		, HP = @sub_hp
		, MP = @sub_mp
		, SP = @sub_sp
		, Exp = @sub_exp
		, Lev = @sub_lev
	WHERE char_id = @char_id
END
ELSE IF @subjob_id = 1
BEGIN
	UPDATE user_data
	SET class = subjob1_class
		, subjob_id = @subjob_id
		, HP = @sub_hp
		, MP = @sub_mp
		, SP = @sub_sp
		, Exp = @sub_exp
		, Lev = @sub_lev
	WHERE char_id = @char_id
END
ELSE IF @subjob_id = 2
BEGIN
	UPDATE user_data
	SET class = subjob2_class
		, subjob_id = @subjob_id
		, HP = @sub_hp
		, MP = @sub_mp
		, SP = @sub_sp
		, Exp = @sub_exp
		, Lev = @sub_lev
	WHERE char_id = @char_id
END
ELSE IF @subjob_id = 3
BEGIN
	UPDATE user_data
	SET class = subjob3_class
		, subjob_id = @subjob_id
		, HP = @sub_hp
		, MP = @sub_mp
		, SP = @sub_sp
		, Exp = @sub_exp
		, Lev = @sub_lev
	WHERE char_id = @char_id
END
ELSE
BEGIN
	RAISERROR(''Invalid Subjob ID [%d]. user [%d]'', 16, 1, @subjob_id, @char_id)
	GOTO EXIT_TRAN
END
IF @@ERROR <> 0 AND @@ROWCOUNT <> 1
BEGIN
	GOTO EXIT_TRAN
END

-- init data: user_activeskill, user_henna
UPDATE user_activeskill
SET	s1 = 0, l1 = 0, d1 = 0, c1 = 0,
	s2 = 0, l2 = 0, d2 = 0, c2 = 0,
	s3 = 0, l3 = 0, d3 = 0, c3 = 0,
	s4 = 0, l4 = 0, d4 = 0, c4 = 0,
	s5 = 0, l5 = 0, d5 = 0, c5 = 0,
	s6 = 0, l6 = 0, d6 = 0, c6 = 0,
	s7 = 0, l7 = 0, d7 = 0, c7 = 0,
	s8 = 0, l8 = 0, d8 = 0, c8 = 0,
	s9 = 0, l9 = 0, d9 = 0, c9 = 0,
	s10 = 0, l10 = 0, d10 = 0, c10 = 0,
	s11 = 0, l11 = 0, d11 = 0, c11 = 0,
	s12 = 0, l12 = 0, d12 = 0, c12 = 0,
	s13 = 0, l13 = 0, d13 = 0, c13 = 0,
	s14 = 0, l14 = 0, d14 = 0, c14 = 0,
	s15 = 0, l15 = 0, d15 = 0, c15 = 0,
	s16 = 0, l16 = 0, d16 = 0, c16 = 0,
	s17 = 0, l17 = 0, d17 = 0, c17 = 0,
	s18 = 0, l18 = 0, d18 = 0, c18 = 0,
	s19 = 0, l19 = 0, d19 = 0, c19 = 0,
	s20 = 0, l20 = 0, d20 = 0, c20 = 0,
	s21 = 0, l21 = 0, d21 = 0, c21 = 0,
	s22 = 0, l22 = 0, d22 = 0, c22 = 0,
	s23 = 0, l23 = 0, d23 = 0, c23 = 0,
	s24 = 0, l24 = 0, d24 = 0, c24 = 0,
	s25 = 0, l25 = 0, d25 = 0, c25 = 0,
	s26 = 0, l26 = 0, d26 = 0, c26 = 0,
	s27 = 0, l27 = 0, d27 = 0, c27 = 0,
	s28 = 0, l28 = 0, d28 = 0, c28 = 0,
	s29 = 0, l29 = 0, d29 = 0, c29 = 0,
	s30 = 0, l30 = 0, d30 = 0, c30 = 0,
	s31 = 0, l31 = 0, d31 = 0, c31 = 0,
	s32 = 0, l32 = 0, d32 = 0, c32 = 0,
	s33 = 0, l33 = 0, d33 = 0, c33 = 0,
	s34 = 0, l34 = 0, d34 = 0, c34 = 0
WHERE char_id = @char_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN
END

UPDATE user_henna
SET henna_1 = @sub_hen1, henna_2 = @sub_hen2, henna_3 = @sub_hen3
WHERE char_id = @char_id
IF @@ERROR = 0
BEGIN
	set @ret = 1
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END

select @sub_hp, @sub_mp, @sub_sp, @sub_exp, @sub_lev, @sub_hen1, @sub_hen2, @sub_hen3

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MakeItemAsStackable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_MakeItemAsStackable]
(
	@min_item_type as int,
	@max_item_type as int
)
as
set nocount on

-- do summation to user_item_stack table
insert into user_item_stack(char_id, item_type, amount, warehouse)
select char_id, item_type, sum(amount), warehouse
from user_item(nolock)
where char_id <> 0 and item_type between @min_item_type and @max_item_type
group by char_id, item_type, warehouse
having sum(amount) >1

-- delete original user_item data
delete from user_item
where item_id in
(
select user_item.item_id
from user_item, (select char_id, item_type, warehouse from user_item_stack(nolock)) as T1
where T1.char_id = user_item.char_id and T1.item_type = user_item.item_type and T1.warehouse = user_item.warehouse
)

-- insert into user_item
insert into user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
select char_id, item_type, amount, 0, 0, 0, 0, 0, warehouse from user_item_stack(nolock)

-- delete summation data
delete user_item_stack

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveRecipeInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_SaveRecipeInfo
 delete recipe info
INPUT        
 @char_id
 @recipe_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_SaveRecipeInfo]
(        
 @char_id INT,
 @recipe_id INT
)        
AS        
        
SET NOCOUNT ON        

INSERT user_recipe VALUES (@char_id, @recipe_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelRecipeInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_DelRecipeInfo
 delete recipe info
INPUT        
 @char_id
 @recipe_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_DelRecipeInfo]
(        
 @char_id INT,
 @recipe_id INT
)        
AS        
        
SET NOCOUNT ON        

DELETE user_recipe WHERE char_id = @char_id and recipe_id = @recipe_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadRecipeInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************        
lin_LoadRecipeInfo
 load all recipe
INPUT        
 @char_id
OUTPUT        
return        
       
made by        
 carrot        
date        
 2004-07-4
change        
********************************************/        
CREATE PROCEDURE [dbo].[lin_LoadRecipeInfo]
(        
 @char_id INT
)        
AS        
        
SET NOCOUNT ON        

SELECT recipe_id FROM user_recipe WHERE char_id = @char_id ORDER BY recipe_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_TrasferWarehouseNewPartial]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_TrasferWarehouseNewPartial    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_TrasferWarehouseNewPartial
	move inventory to warehouse || move warehouse to inventory total partial item 
INPUT
	@char_id		INT,
	@item_id			INT,
	@ToWarehouseID	INT,
	@bIsToInven		TINYINT
	@nCount			INT
OUTPUT
	bIsSuccess		1/0
return
made by
	carrot
date
	2002-10-17
********************************************/
CREATE PROCEDURE [dbo].[lin_TrasferWarehouseNewPartial]
(
	@char_id		INT,
	@item_id			INT,
	@ToWarehouseID	INT,
	@bIsToInven		TINYINT,
	@nCount			INT
)
AS
SET NOCOUNT ON

IF (@bIsToInven > 0) 
BEGIN
	IF (SELECT amount FROm user_warehouse WHERE item_id = @item_id) > @nCount
	BEGIN
		INSERT INTO user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
			SELECT char_id, item_type, @nCount, enchant, eroded, bless, ident, wished, warehouse FROM user_warehouse WHERE item_id = @item_id
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT 0
		END
		ELSE 
		BEGIN
			SELECT item_id FROM user_item WHERE item_id = @@IDENTITY
			UPDATE user_warehouse SET amount = amount - @nCount WHERE item_id = @item_id
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END
END
ELSE
BEGIN
	IF (SELECT amount FROm user_item WHERE item_id = @item_id) > @nCount
	BEGIN
		INSERT INTO user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
			SELECT char_id, item_type, @nCount, enchant, eroded, bless, ident, wished, warehouse FROM user_item WHERE item_id = @item_id
		INSERT INTO user_warehouse (item_id, char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
			SELECT item_id, char_id, item_type, @nCount, enchant, eroded, bless, ident, wished, warehouse FROM user_item WHERE item_id = @@IDENTITY
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT 0
		END
		ELSE 
		BEGIN
			SELECT item_id FROM user_warehouse WHERE item_id = @@IDENTITY
			DELETE user_item WHERE item_id = @@IDENTITY
			UPDATE user_item SET amount = amount - @nCount WHERE item_id = @item_id
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SeizeItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SeizeItem    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SeizeItem
	
INPUT
	@option	INT,
	@warehouse	INT,
	@item_id	INT
OUTPUT
return
made by
	young
date
	2003-06-25
	2004-5-21 modified by young
********************************************/
CREATE PROCEDURE [dbo].[lin_SeizeItem]
(
@option	INT,
@warehouse	INT,
@item_id	INT
)
AS
SET NOCOUNT ON


if @option = 1
	update user_item set warehouse = 1001 where item_id = @item_id
else if @option = 2
	update user_item set warehouse = @warehouse where item_id = @item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AdenaChange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_AdenaChange    Script Date: 2003-09-20 오전 11:51:56 ******/
/********************************************
lin_AdenaChange
	change adena and return result amount
INPUT
	@char_id	INT,
	@price	 	BIGINT
OUTPUT
	adena id		INT,
	amount		BIGINT
return
made by
	carrot
date
	2002-04-22
********************************************/
CREATE PROCEDURE [dbo].[lin_AdenaChange]
(
	@char_id	INT,
	@price	 	BIGINT
)
AS
SET NOCOUNT ON
DECLARE @nAmount	BIGINT
SET @nAmount = NULL
SELECT @nAmount = amount FROM user_item WHERE char_id = @char_id AND item_type = 57
IF @nAmount IS NULL
	BEGIN
		SELECT -1, -1
	END
ELSE IF @nAmount + @price < 0
	BEGIN
		SELECT -1, -1
	END
ELSE
	BEGIN
		UPDATE user_item SET amount = amount + @price WHERE char_id = @char_id AND item_type = 57 AND warehouse = 0
		SELECT item_id, amount FROM user_item WHERE char_id = @char_id AND item_type = 57 AND warehouse = 0
	END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_DeleteChar
desc:	delete character

history:	2002-02-16	created by carrot
	2007-05-25	modified by btwinuni : make history except deleted
	2007-11-07	modified by choanari : get item list by character deleted
*/
CREATE PROCEDURE [dbo].[lin_DeleteChar]
(
@char_id	INT
)
AS

SET NOCOUNT ON

DECLARE @backup_char_name NVARCHAR(50)
DECLARE @original_account_id INT
DECLARE @original_char_name NVARCHAR(50)
DECLARE @original_account_name NVARCHAR(50)
DECLARE @create_date datetime

set @original_account_id = 0
SELECT
	@original_account_id = account_id
	,@original_char_name = char_name
	,@original_account_name = account_name
	,@create_date = create_date
FROM user_data
WHERE char_id = @char_id

SELECT @backup_char_name = @original_char_name + ''_'' + LTRIM(STR(@original_account_id)) + ''_'' + LTRIM(STR(@char_id))

UPDATE user_data
SET account_id = -1
, char_name = @backup_char_name
, pledge_id = 0
WHERE char_id = @char_id

INSERT INTO user_deleted
(char_id, delete_date) VALUES (@char_id, GETDATE())

--DECLARE @tempItemIDtable TABLE (item_id INT)
--INSERT INTO @tempItemIDtable
--SELECT item_id FROM user_item  WHERE char_id = @char_id
--UPDATE user_item  SET char_id = 0, item_type = 0, amount = 0, enchant = 0, eroded = 0, bless = 0, ident = 0, wished = 0, warehouse = 0  WHERE char_id = @char_id
--SELECT item_id FROM @tempItemIDtable

select item_id from user_item (nolock) where char_id = @char_id and warehouse in (0, 1, 1001)

if @original_account_id <> -1
begin
	-- make user_history
	exec lin_InsertUserHistory @original_char_name, @char_id, 2, @original_account_name, @create_date
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DepositBank]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DepositBank    Script Date: 2003-09-20 오전 11:51:57 ******/
CREATE PROCEDURE [dbo].[lin_DepositBank]
(
	@oldItemId int,
	@nAmount int,
	@warehouse int
)
AS

SET NOCOUNT ON

declare @newItemId int

IF @nAmount > 0 
BEGIN
	insert into user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
	select char_id, item_type, @nAmount, enchant, eroded, bless, ident, wished, @warehouse from user_item where item_id = @oldItemId
	set @newItemId = @@identity
	update user_item set amount = amount - @nAmount where item_id = @oldItemId
	select @newItemId
END
ELSE IF @nAmount = 0
BEGIN
	SELECT 0
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GiveEventItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/******************************************************************************
#Name:	lin_GiveEventItem
#Desc:	give users event item
#Argument:
	Input:	@db_server	nvarchar(30)
		@user_id	nvarchar(30)
		@user_pass	nvarchar(30)
		@world_id	int
	Output:
#Return:
#Result Set:
#Remark:
#Example:	exec lin_GiveEventItem ''L2AdminWeb'', ''gamma'', ''password'', 1
#See:
#History:
	Create	btwinuni	2005-12-01
******************************************************************************/
CREATE PROCEDURE [dbo].[lin_GiveEventItem]
(
	@db_server	nvarchar(30),
	@user_id	nvarchar(30),
	@user_pass	nvarchar(30),
	@world_id	int
)
AS
SET NOCOUNT ON
declare
	@regDate	varchar(20),
	@char_id	int,
	@eventId		varchar(30),
	@oldEventId	varchar(30),
	@itemId		int,
	@itemType	int,
	@amount	bigint,
	@i			int,
	@sql		varchar(4000)
set @regDate = left(convert(nvarchar, getdate(), 120), 11) + ''00:00:00''
-- 1. 아이템 지급을 위한 임시 테이블을 생성
if exists (select * from sys.objects where object_id = object_id(N''tmp_eventApplier'') and type in (N''U''))
drop table tmp_eventApplier
if exists (select * from sys.objects where object_id = object_id(N''tmp_eventItem'') and type in (N''U''))
drop table tmp_eventItem
create table tmp_eventApplier
(
	eventId		varchar(30) not null,
	accountId	int not null,
	charId		int not null,
	submitFlag	int not null default(0),
	submitDate	datetime null
)
create table tmp_eventItem
(
	eventId	varchar(30) not null,
	itemId	int not null,
	itemType	tinyint not null,
	amount		bigint not null
)
set @sql = ''INSERT INTO tmp_eventApplier (eventId, accountId, charId, submitFlag)''
	+ '' SELECT eventId, accountId, charId, submitFlag''
	+ '' FROM OPENROWSET(''''SQLOLEDB'''', '''''' + @db_server + '''''';'''''' + @user_id + '''''';'''''' + @user_pass + '''''',''
	+ ''	''''SELECT eventId, accountId, charId, 1 as submitFlag FROM Lin2Admin.dbo.EventApplier (nolock)''
	+ ''	WHERE serverId = '' + cast(@world_id as varchar)
	+ ''		AND registerDate < '''''''''' + @regDate + ''''''''''''
	+ ''		AND submitFlag = 0'''')''
exec (@sql)
set @sql = ''INSERT INTO tmp_eventItem (eventId, itemId, itemType, amount)''
	+ '' SELECT eventId, itemId, itemType, amount''
	+ '' FROM OPENROWSET(''''SQLOLEDB'''', '''''' + @db_server + '''''';'''''' + @user_id + '''''';'''''' + @user_pass + '''''',''
	+ ''	''''SELECT eventId, itemId, itemType, amount FROM Lin2Admin.dbo.EventItem (nolock)''
	+ ''	WHERE eventId in (''
	+ ''		SELECT distinct eventId FROM Lin2Admin.dbo.EventApplier (nolock)''
	+ ''		WHERE serverId = '' + cast(@world_id as varchar)
	+ ''			AND registerDate < '''''''''' + @regDate + ''''''''''''
	+ ''			AND submitFlag = 0)'''')''
exec (@sql)
-- 2. 아이템 지급
BEGIN TRAN
	-- 부재캐릭 처리
	update tmp_eventApplier
	set submitFlag = 11,
		submitDate = getdate()
	where charId not in (select char_id from user_data (nolock) where account_id > 0)
	if @@error > 0
		goto EXIT_TRAN
	declare item_cursor cursor for select eventId, itemId, itemType, amount from tmp_eventItem (nolock)
	open item_cursor
	fetch next from item_cursor into @eventId, @itemId, @itemType, @amount
	while @@fetch_status = 0
	begin
		if @itemType = 1		-- 수량성
		begin
			declare char_cursor cursor for select charId from tmp_eventApplier (nolock) where eventId = @eventId and submitFlag = 1
			open char_cursor
			fetch next from char_cursor into @char_id
			while @@fetch_status = 0
			begin
				if exists (select * from user_item (nolock) where char_id = @char_id and item_type = @itemId and warehouse = 1)
					update user_item set amount = amount + @amount where char_id = @char_id and item_type = @itemId and warehouse = 1
				else
					insert into user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
					values (@char_id, @itemId, @amount, 0, 0, 0, 0, 1, 1)
				if @@error > 0
				begin
					close char_cursor
					deallocate char_cursor
					close item_cursor
					deallocate item_cursor
					goto EXIT_TRAN
				end
				fetch next from char_cursor into @char_id
			end
			close char_cursor
			deallocate char_cursor
		end
		else if @itemType = 2	-- 비수량성
		begin
			set @i = 1
			while @i <= @amount
			begin
				insert into user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
				select charId, @itemId, 1, 0, 0, 0, 0, 1, 1
				from tmp_eventApplier (nolock)
				where eventId = @eventId and submitFlag = 1
				if @@error > 0
				begin
					close item_cursor
					deallocate item_cursor
					goto EXIT_TRAN
				end
				set @i = @i + 1
			end
		end
		set @oldEventId = @eventId
		fetch next from item_cursor into @eventId, @itemId, @itemType, @amount
		-- 지급 완료된 상태로 변경
		if (@oldEventId is not null and @oldEventId <> @eventId) or @@fetch_status <> 0
			update tmp_eventApplier
			set submitFlag = 2, submitDate = getdate()
			where eventId = @oldEventId and submitFlag = 1
	end
EXIT_TRAN:
if @@error = 0
begin
	COMMIT TRAN
end
else
begin
	ROLLBACK TRAN
	update tmp_eventApplier
	set submitFlag = 12, submitDate = getdate()
	where eventId = @eventId
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Lin_EnchantItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.Lin_EnchantItem    Script Date: 2003-09-20 오전 11:51:56 ******/
/********************************************
Lin_EnchantItem
	enchant item
INPUT
	@char_id	INT,
	@item_id 	INT,
	@target_item_id 	INT,
	@nEnchantNum 	INT
	@bZeorDelete 	INT = 0
OUTPUT
	@nResultAmount	INT
return
made by
	carrot
date
	2002-10-14
********************************************/
CREATE PROCEDURE [dbo].[Lin_EnchantItem]
(
	@char_id	INT,
	@item_id 	INT,
	@target_item_id 	INT,
	@nEnchantNum 	INT,
	@bZeorDelete 	INT = 0
)
AS
SET NOCOUNT ON

DECLARE @nResultAmount 	INT
SET @nResultAmount = -1

UPDATE user_item SET amount = amount -1 WHERE char_id = @char_id AND item_id = @item_id
UPDATE user_item SET enchant = enchant + @nEnchantNum WHERE char_id = @char_id AND item_id = @target_item_id

IF NOT @@ROWCOUNT = 1 
	SELECT -1
ELSE
BEGIN
	
	SELECT @nResultAmount = ISNULL(amount, -1) FROM user_item WHERE char_id = @char_id AND item_id = @item_id
	IF ( @nResultAmount = 0 AND @bZeorDelete = 1) 
	BEGIN
		DELETE user_item WHERE char_id = @char_id AND item_id = @item_id
--		UPDATE user_item SET char_id = 0, item_type = 0 WHERE char_id = @char_id AND item_id = @item_id
	END

	SELECT @nResultAmount
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_TrasferWarehouseNewAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_TrasferWarehouseNewAll    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_TrasferWarehouseNewPartial
	movet inventory to warehouse || move warehouse to inventory total item
INPUT
	@char_id		INT,
	@item_id			INT,
	@ToWarehouseID	INT,
	@bIsToInven		TINYINT
OUTPUT
	
return
made by
	carrot
date
	2002-10-17
********************************************/
CREATE PROCEDURE [dbo].[lin_TrasferWarehouseNewAll]
(
	@char_id		INT,
	@item_id			INT,
	@ToWarehouseID	INT,
	@bIsToInven		TINYINT
)
AS
SET NOCOUNT ON

IF (@bIsToInven > 0) 
BEGIN
	SET IDENTITY_INSERT user_item ON

	IF (SELECT COUNT(*) FROm user_warehouse WHERE item_id = @item_id) = 1
	BEGIN
		INSERT INTO user_item (item_id, char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
			SELECT item_id, char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse FROM user_warehouse WHERE item_id = @item_id
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT 0
		END
		ELSE 
		BEGIN
			DELETE user_warehouse WHERE item_id = @item_id
			SELECT 1
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END

	SET IDENTITY_INSERT user_item OFF
END
ELSE
BEGIN
	IF (SELECT COUNT(*) FROm user_item WHERE item_id = @item_id) = 1
	BEGIN
		INSERT INTO user_warehouse (item_id, char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
			SELECT item_id, char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse FROM user_item WHERE item_id = @item_id
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT 0
		END
		ELSE 
		BEGIN
			DELETE user_item WHERE item_id = @item_id
			SELECT 1
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LIN_MakeNewBlankItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.LIN_MakeNewBlankItem    Script Date: 2003-09-20 오전 11:51:56 ******/
CREATE PROCEDURE [dbo].[LIN_MakeNewBlankItem]
AS

SET NOCOUNT ON

declare @newItemId int

insert into user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse)
values(0,0,0,0,0,0,0,0,0)

SET @newItemId = @@IDENTITY
select @newItemId

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateItemSlotIndex]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/**
name:	lin_UpdateItemSlotIndex
desc:	update inventory_slot_index on user_item table

history:	2009-01-16	created by btwinuni
*/
create procedure [dbo].[lin_UpdateItemSlotIndex]
(
	@item_id int,
	@slot_index int
)
as
set nocount on

update user_item set inventory_slot_index = @slot_index where item_id = @item_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SeizeItem2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SeizeItem2
	
INPUT
	@option	INT,
	@warehouse	INT,
	@item_id	INT
OUTPUT
return
made by
	young
date
	2004-6-22 
********************************************/
CREATE PROCEDURE [dbo].[lin_SeizeItem2]
(
@option	INT,
@warehouse	INT,
@item_id	INT
)
AS
SET NOCOUNT ON

update user_item set warehouse = @warehouse where item_id = @item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AmountChange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_AmountChange    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_AmountChange
	change item''s amount and return result amount
INPUT
	@char_id	INT,
	@item_id 	INT,
	@change 	INT,
	@bZeorDelete 	INT = 0
OUTPUT
	amount		INT
return
made by
	carrot
date
	2002-04-22
change
	2002-10-15
		아이템 갯수가 0이 되었을 때 지울지 말지 변수 받도록 수정
change
	2003-05-12
		줄일 아이템 갯수를 받도록 수정
********************************************/
CREATE PROCEDURE [dbo].[lin_AmountChange]
(
	@char_id	INT,
	@item_id 	INT,
	@change 	BIGINT,
	@bZeorDelete 	INT = 0
)
AS
SET NOCOUNT ON
DECLARE @nResultAmount 	BIGINT
SET @nResultAmount = -1
IF(select top 1 amount from user_item where char_id = @char_id AND item_id = @item_id ) + @change >= 0
begin
	UPDATE user_item SET amount = amount + @change WHERE char_id = @char_id AND item_id = @item_id
	
	IF NOT @@ROWCOUNT = 1 
		SELECT -1
	ELSE
		SELECT @nResultAmount = ISNULL(amount, -1) FROM user_item WHERE char_id = @char_id AND item_id = @item_id
		IF ( @nResultAmount = 0 AND @bZeorDelete = 1) 
		BEGIN
			DELETE user_item WHERE char_id = @char_id AND item_id = @item_id
	--		UPDATE user_item SET char_id = 0, item_type = 0 WHERE char_id = @char_id AND item_id = @item_id
		END
	
		SELECT @nResultAmount
end
else
select -1

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetItemType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetItemType
	Get item type
INPUT
	@item_id		 INT
OUTPUT

return
made by
	young
date
	2004-01-09
********************************************/
CREATE PROCEDURE [dbo].[lin_GetItemType]
(
	@item_id		INT
)
AS

SET NOCOUNT ON

select item_id, char_id, item_type, amount, warehouse from user_item (nolock) where item_id = @item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMigrationList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_GetMigrationList
desc:	copy migration list for 7th server from L2EventDB to world DB
exam:	exec lin_GetMigrationList ''''''server'''';''''login_id'''';''''password'''''', 1

history:	2006-11-20	created by btwinuni
*/
create procedure [dbo].[lin_GetMigrationList]
	@db_info	varchar(64),	-- to L2EventDB
	@server_id	int		-- this server
as

set nocount on

declare
	@item_id		int,
	@char_id	int,
	@original_pk	int,
	@sql		varchar(4000)

truncate table MigrationListForSeven

set @sql = ''insert into MigrationListForSeven (idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2)''
	+ '' select *''
	+ '' from openrowset(''''sqloledb'''', ''+@db_info+'',''
	+ ''	''''select idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2''
	+ ''	from L2EventDB.dbo.L2AddedServiceEvent (nolock)''
	+ ''	where serviceType = 4''		-- 서버이전
	+ ''		and serviceFlag = 0''	-- 서비스 신청 상태
	+ ''		and status = 2'''')''		-- 결제 완료 상태
exec (@sql)

select @item_id = item_id, @char_id = char_id, @original_pk = original_pk from cursed_weapon

-- cursed weapon user
if exists (select * from MigrationListForSeven where fromCharacter = (select char_name from user_data where char_id = @char_id) and fromServer = @server_id)
begin
	update user_data set align = @original_pk where char_id = @char_id
	delete from user_item where item_id = @item_id
	delete from cursed_weapon
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/****** Object:  Stored Procedure dbo.lin_CreateItem    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_CreateItem
	create item sp
INPUT
	@char_id	INT,
	@item_type 	INT,
	@amount 	INT,
	@enchant 	INT,
	@eroded 	INT,
	@bless 		TINYINT,
	@ident 		TINYINT,
	@ready 		TINYINT,
	@wished 	TINYINT,
	@warehouse	INT,
 	@variation_opt1 INT,
	@variation_opt2 INT,
	@intensive_item_type INT
OUTPUT
	Item_ID, @@IDENTITY
return
made by
	carrot
date
	2002-01-31
modified by 
	kernel0
modified date 
	2006-10-16	
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateItem]
(
@char_id	INT,
@item_type 	INT,
@amount 	BIGINT,
@enchant 	INT,
@eroded 	INT,
@bless 		TINYINT,
@ident 		INT,
@wished 	TINYINT,
@warehouse	INT,
@variation_opt1 INT,
@variation_opt2 INT,
@intensive_item_type INT
)
AS
SET NOCOUNT ON

--FOR TEST
/*
IF (select is_stackable from itemdata where item_type = @item_type) > 0
begin
	set @amount = @amount + 2150000000
end
*/

insert into user_item 
	(char_id , item_type , amount , enchant , eroded , bless , ident , wished , warehouse, variation_opt1, variation_opt2, intensive_item_type) 
	values 
	(@char_id, @item_type , @amount , @enchant , @eroded , @bless , @ident , @wished , @warehouse, @variation_opt1, @variation_opt2, @intensive_item_type)
SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAddedServiceList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetAddedServiceList] 
        @db_info        varchar(64), 
        @server_id      int 
as 
 
set nocount on 
 
declare 
@cursed_weapon        int,
@char_id        int,
@original_pk        int,
@sql varchar(4000) 


-- delete old list
truncate table AddedServiceList


-- get new list
set @sql = ''insert into AddedServiceList (idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2, toMainClassNum)'' 
        + '' select *'' 
        + '' from openrowset(''''sqloledb'''', ''+@db_info+'','' 
        + ''     ''''select idx, postDate, serviceType, fromUid, toUid, fromAccount, toAccount, fromServer, toServer, fromCharacter, toCharacter, changeGender, serviceFlag, reserve1, reserve2, toMainClassNum'' 
        + ''     from L2EventDB.dbo.L2AddedService (nolock)'' 
        + ''     where serviceFlag = 0''  -- 서비스 신청 상태 
        + ''             and status = 2'''''' -- 결제 완료 상태 
        + '')'' 
exec (@sql) 


-- cursed weapon user
declare cursed_cursor cursor for 
select item_id, char_id, original_pk from cursed_weapon
 
open cursed_cursor 
fetch next from cursed_cursor into @cursed_weapon, @char_id, @original_pk

while @@fetch_status = 0 
begin
        if exists (select * from AddedServiceList where fromCharacter = (select char_name from user_data where char_id = @char_id) and fromServer = @server_id and serviceType = 4 and serviceFlag = 0)
        begin
        	update user_data set pk = @original_pk where char_id = @char_id
        	delete from user_item where item_id = @cursed_weapon
        	delete from cursed_weapon where item_id = @cursed_weapon
        end
        fetch next from cursed_cursor into @cursed_weapon, @char_id, @original_pk
end 

close cursed_cursor 
deallocate cursed_cursor 

 
set nocount off

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModItemOwner]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModItemOwner
	
INPUT
	@item_id	INT,
	@new_char_id	INT,
	@new_warehouse	INT
OUTPUT
return
made by
	young
date
	2003-11-07
********************************************/
CREATE PROCEDURE [dbo].[lin_ModItemOwner]
(
@item_id	INT,
@new_char_id 	INT,
@new_warehouse	INT

)
AS
SET NOCOUNT ON

UPDATE user_item  set char_id=@new_char_id,  warehouse=@new_warehouse WHERE item_id=@item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteExpiredItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_DeleteExpiredItem  
   
INPUT  
 @item_id  INT  
OUTPUT
 @deleted row count of user_data
 @deleted row count of item_expiration  
return  
made by  
 zzangse  
date  
 2006-01-25  
********************************************/  
CREATE  PROCEDURE [dbo].[lin_DeleteExpiredItem]  
(  
 @item_id  INT  
)  
AS  
 
SET NOCOUNT ON   

DECLARE @deleted_row_count_of_user_data as int
DECLARE @deleted_row_count_of_item_expiration as int  
SET @deleted_row_count_of_user_data = 0
SET @deleted_row_count_of_item_expiration =0

DELETE  FROM USER_ITEM WHERE item_id=@item_id  
SET @deleted_row_count_of_user_data = @@ROWCOUNT 
DELETE FROM  item_expiration WHERE item_id = @item_id
SET @deleted_row_count_of_item_expiration = @@ROWCOUNT

select @deleted_row_count_of_user_data, @deleted_row_count_of_item_expiration

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetItem    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_GetItem
	Get item from ground 
INPUT
	@char_id	INT,
	@item_id		 INT
OUTPUT
	item_id, amount
return
made by
	carrot
date
	2002-04-30
********************************************/
CREATE PROCEDURE [dbo].[lin_GetItem]
(
	@char_id	INT,
	@item_id		INT
)
AS
SET NOCOUNT ON
DECLARE @nCount	INT
DECLARE @nAmountIn	BIGINT
DECLARE @nAmountOld	BIGINT
DECLARE @nItemType	INT
SET @nCount = -1
SET @nAmountIn = -1
SET @nItemType = -1
SELECT @nAmountIn = amount, @nItemType = item_type FROM user_item WHERE item_id = @item_id
IF @nItemType = -1 
BEGIN
	RETURN
END
IF (@nItemType = 57)
	BEGIN
		SELECT @nCount = count(*) FROM user_item WHERE char_id = @char_id AND item_type = 57 AND warehouse = 0
		IF @nCount = 0
			UPDATE user_item SET char_id = @char_id  WHERE item_id = @item_id
		ELSE
		BEGIN
			DELETE user_item WHERE item_id = @item_id
			UPDATE user_item SET amount = amount + @nAmountIn  WHERE char_id = @char_id AND item_type = 57 AND warehouse = 0
		END
		SELECT item_id, amount FROM user_item WHERE char_id = @char_id AND item_type = 57
	END
ELSE
	BEGIN
		UPDATE user_item SET char_id = @char_id  WHERE item_id = @item_id
		SELECT item_id, amount FROM user_item WHERE item_id = @item_id
	END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_BetaAddItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_BetaAddItem    Script Date: 2003-09-20 오전 11:51:56 ******/
CREATE PROCEDURE [dbo].[lin_BetaAddItem]  
(
	@char_id int,
	@Item_type int,
	@amount bigint
)
AS
SET NOCOUNT ON
DECLARE @tempRowCount INT
DECLARE @bIsStackable TINYINT
SELECT @bIsStackable = IsStackable FROM ITEMNAME WHERE id = @Item_type
If @bIsStackable Is NULL 
Begin
	RAISERROR (''Not exist Item Type'', 16, 1)
End
Else
Begin
	If @bIsStackable = 1
	Begin
		Update user_item set amount = amount + @amount  where item_type = @Item_type and char_id = @char_id
		Set @tempRowCount = @@ROWCOUNT
		If @tempRowCount = 0
			INSERT INTO user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse) VALUES (@char_id, @Item_type, @amount, 0,0,0,0,0,0)
	End
	Else If @amount = 1
	Begin
		INSERT INTO user_item (char_id, item_type, amount, enchant, eroded, bless, ident, wished, warehouse) VALUES (@char_id, @Item_type, @amount, 0,0,0,0,0,0)
		Set @tempRowCount = @@ROWCOUNT
	End
	Else
	Begin
		RAISERROR (''Amount is invalid'', 16, 1)
	End
End
If @tempRowCount Is NOT NULL
	Select @tempRowCount

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateUserItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UpdateUserItem    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_UpdateUserItem
	
INPUT
	@char_id	INT,
	@item_type	INT,
	@amount	INT,
	@enchant	INT,
	@eroded	INT,
	@bless		INT,
	@ident		INT,
	@wished	INT,
	@warehouse	INT,
	@item_id		INT,
	@intensive_item_type 	INT,
	@inventory_slot_index	INT
OUTPUT
return
made by
	carrot
date
	2002-06-09
modified by 
	kernel0
modified date 
	2006-10-16	
********************************************/
CREATE  PROCEDURE [dbo].[lin_UpdateUserItem]
(
@char_id	INT,
@item_type	INT,
@amount	BIGINT,
@enchant	INT,
@eroded	INT,
@bless		INT,
@ident		INT,
@wished	INT,
@warehouse	INT,
@item_id		INT,
@variation_opt1 INT,
@variation_opt2 INT,
@intensive_item_type INT,
@inventory_slot_index	INT
)
AS
SET NOCOUNT ON

IF @bless < 0 OR @bless > 255
	SET @bless = 0

UPDATE 
	user_item  
set 
	char_id = @char_id, item_type=@item_type, amount=@amount, enchant=@enchant, eroded=@eroded, bless=@bless, ident=@ident, wished=@wished, warehouse=@warehouse,
	variation_opt1 = @variation_opt1, 
	variation_opt2 = @variation_opt2,
	intensive_item_type = @intensive_item_type,
	inventory_slot_index = @inventory_slot_index
WHERE item_id=@item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateWarehouseItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_UpdateWarehouseItem    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_UpdateWarehouseItem 
	
INPUT
	@warehouse	INT,
	@amount	INT,
	@item_id		INT
OUTPUT
return
made by
	carrot
date
	2002-06-10
********************************************/
create PROCEDURE [dbo].[lin_UpdateWarehouseItem]
(
	@warehouse	INT,
	@amount	BIGINT,
	@item_id		INT
)
AS
SET NOCOUNT ON
UPDATE user_item SET warehouse=@warehouse,amount=@amount WHERE item_id=@item_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPetList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPetList
	
INPUT
	char_id = @char_id
OUTPUT
return
made by
	choanari
date
	2007-12-04
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPetList]
(
	@char_id		int
)
AS
SET NOCOUNT ON

SELECT pet_data.pet_id, user_item.item_type, user_item.enchant, user_item.eroded
FROM user_item (nolock) inner join pet_data (nolock)
	on user_item.item_id = pet_data.pet_id
WHERE user_item.char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetPledgeAdena ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetPledgeAdena
	Get pledge adena
INPUT
	@pledge_id	INT
OUTPUT
return
made by
	young
date
	2003-12-11
********************************************/
CREATE PROCEDURE [dbo].[lin_GetPledgeAdena ]
(
	@pledge_id	INT
)

as

set nocount on

select isnull( sum(amount) , 0) from user_item (nolock) where warehouse = 2 and char_id = @pledge_id and item_type = 57

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddPunishmentHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_AddPunishmentHistory
	Add Punishment Histroy to user_history
INPUT
	@char_name	NVARCHAR(24),
	@char_id	INT,
	@log_type	TINYINT,
	@account_name	NVARCHAR(24)
OUTPUT
	
return
made by
	zzangse
date
	2005-08-31			created by zzangse
********************************************/
CREATE  PROCEDURE [dbo].[lin_AddPunishmentHistory] 
(
	@char_name	NVARCHAR(24),
	@char_id	INT,
	@log_type	TINYINT,
	@account_name	NVARCHAR(24)
)
AS

SET NOCOUNT ON  
SET @char_name = RTRIM(@char_name)  
DECLARE @create_date datetime

SELECT
	@create_date = create_date
FROM user_data
WHERE char_id = @char_id

if @char_id>0
begin  
 -- make user_history  
 exec lin_InsertUserHistory @char_name, @char_id, @log_type, @account_name, @create_date 
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeCharacterName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ChangeCharacterName    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_ChangeCharacterName
	change character name
INPUT
	@old_char_name	nvarchar,
	@new_char_name	nvarchar
OUTPUT
	char_id
return
made by
	young
date
	2002-010-08
********************************************/
CREATE PROCEDURE [dbo].[lin_ChangeCharacterName]
(
	@old_char_name	NVARCHAR(24),
	@new_char_name	NVARCHAR(24)
)
AS

SET NOCOUNT ON

DECLARE @Char_id INT
DECLARE @nTmpCount INT
DECLARE @account_name NVARCHAR(50)
DECLARE @create_date datetime

SET @Char_id = 0

IF not exists(SELECT char_name FROM user_data WHERE char_name = @new_char_name)
BEGIN
	UPDATE user_data set char_name = @new_char_name where char_name = @old_char_name
	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @char_id = char_id , @account_name = account_name, @create_date = create_date  FROM user_data WHERE char_name = @new_char_name
	END
END

SELECT @Char_id

if @char_id > 0
begin
	-- make user_history
	exec lin_InsertUserHistory @new_char_name, @char_id, 3, @account_name, @create_date
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetLastTaxUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_SetLastTaxUpdate  
     
INPUT     
@income  datetime,
@tax datetime
OUTPUT    
made by    
 carrot    
date    
 2004-02-29  
********************************************/    
CREATE PROCEDURE [dbo].[lin_SetLastTaxUpdate]  
(  
@income  datetime,
@tax datetime,
@manor datetime
)  
AS    
    
SET NOCOUNT ON    

IF EXISTS(SELECT * FROM castle_tax)  
BEGIN  
 UPDATE castle_tax SET   income_update =  @income, tax_change =   @tax, manor_reset =   @manor 
END  
ELSE  
BEGIN  
 INSERT INTO castle_tax VALUES  
 (  @income, @tax, @manor)  
  
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadLastTaxUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_LoadLastTaxUpdate  
     
INPUT     
OUTPUT    
made by    
 carrot    
date    
 2004-02-29  
********************************************/    
create PROCEDURE [dbo].[lin_LoadLastTaxUpdate]  
AS    
    
SET NOCOUNT ON    
  
SELECT TOP 1  
 YEAR(income_update), MONTH(income_update), DAY(income_update),   
 DATEPART ( hh , income_update ), DATEPART ( mi , income_update ), DATEPART ( ss , income_update ),  
 YEAR(tax_change), MONTH(tax_change), DAY(tax_change),   
 DATEPART ( hh , tax_change ), DATEPART ( mi , tax_change), DATEPART ( ss , tax_change),  
 YEAR(manor_reset), MONTH(manor_reset), DAY(manor_reset),   
 DATEPART ( hh , manor_reset ), DATEPART ( mi , manor_reset), DATEPART ( ss , manor_reset)  
FROM   
 castle_tax

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SendMailToReceiver]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SendMailToReceiver
	send mail  to receiver
INPUT
	@mail_id		int,
	@receiverName		nvarchar(50)
OUTPUT
return
made by
	kks
date
	2004-12-19
modified by
	kks
date
	2005-04-06
********************************************/
CREATE PROCEDURE [dbo].[lin_SendMailToReceiver]
(
	@mail_id		int,
	@receiver_name		nvarchar(50)
)
AS
SET NOCOUNT ON

if (@receiver_name = NULL)
BEGIN
	RETURN
END

DECLARE @receiver_id int
SET @receiver_id = 0

SELECT @receiver_id  = char_id FROM user_data(nolock) WHERE char_name = @receiver_name

IF (@receiver_id > 0) 
BEGIN
	INSERT INTO user_mail_receiver
	(mail_id, receiver_id, receiver_name)
	VALUES 
	(@mail_id, @receiver_id, @receiver_name)
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelLoginAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DelLoginAnnounce    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DelLoginAnnounce
	delete login announce
INPUT
	@announce_id int

OUTPUT
	
return
made by
	young
date
	2002-11-30
********************************************/
CREATE PROCEDURE [dbo].[lin_DelLoginAnnounce]
(
	@announce_id int 
)

AS

SET NOCOUNT ON

delete from login_announce where announce_id = @announce_id and interval_10 = 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelIntervalAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DelIntervalAnnounce
	delete interval announce
INPUT
	
OUTPUT
	interval
	announce id
return
made by
	carrot
date
	2003-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_DelIntervalAnnounce]
(
	@nInterval 	INT,
	@nAnnounceId	INT
)
AS
SET NOCOUNT ON

if EXISTS(select top 1 * from login_announce where interval_10 = @nInterval and announce_id = @nAnnounceId)
  BEGIN
    DELETE login_announce WHERE interval_10 = @nInterval and announce_id = @nAnnounceId
  END
ELSE
  BEGIN
    RAISERROR (''Cannot find announce[%d] id and interval number[%d].'', 16, 1, @nAnnounceId, @nInterval)
  END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetLoginAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetLoginAnnounce    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_GetLoginAnnounce
	get login announce
INPUT
	
OUTPUT
	
return
made by
	young
date
	2002-11-30
change 	2003-12-18	carrot
	add interval_10 check
********************************************/
CREATE PROCEDURE [dbo].[lin_GetLoginAnnounce]

AS
SET NOCOUNT ON

select announce_id, announce_msg from login_announce (nolock) where interval_10 = 0 order by announce_id asc

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetLoginAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetLoginAnnounce    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetLoginAnnounce
	set login announce
INPUT
	@announce_id int,
	@announce_msg nvarchar(64)	
OUTPUT
	
return
made by
	young
date
	2002-11-30
********************************************/
CREATE PROCEDURE [dbo].[lin_SetLoginAnnounce]
(
	@announce_id int , 
	@announce_msg nvarchar(64)
)

AS

SET NOCOUNT ON


if exists(select announce_id from login_announce (nolock) where announce_id = @announce_id  and interval_10 = 0 )
begin

	update login_announce set announce_msg = @announce_msg where announce_id = @announce_id and interval_10 = 0

end else begin

	insert into login_announce(announce_id, announce_msg , interval_10 ) values(@announce_id, @announce_msg, 0 ) 

end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetIntervalAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetIntervalAnnounce
	set interval announce
INPUT
	
OUTPUT
	interval
	announce id
	msg
return
made by
	carrot
date
	2003-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_SetIntervalAnnounce]
(
	@nInterval 	INT,
	@nAnnounceId	INT,
	@wsMsg	NVARCHAR(100)
)
AS
SET NOCOUNT ON

if EXISTS(select top 1 * from login_announce where interval_10 = @nInterval and announce_id = @nAnnounceId)
  BEGIN
    UPDATE login_announce SET announce_msg = @wsMsg WHERE interval_10 = @nInterval and announce_id = @nAnnounceId
  END
ELSE
  BEGIN
    INSERT INTO login_announce (interval_10, announce_id, announce_msg) VALUES (@nInterval, @nAnnounceId, @wsMsg)
  END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetIntervalAnnounce]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetIntervalAnnounce
	get interval announce
INPUT
	
OUTPUT
	interval
	announce id
	msg
return
made by
	carrot
date
	2003-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_GetIntervalAnnounce]
AS
SET NOCOUNT ON

select interval_10, announce_id, announce_msg from login_announce (nolock) where interval_10 > 0 order by interval_10, announce_id asc

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteSubJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteSubJob]
(
	@char_id	INT,
	@subjob_id	INT
)
AS
SET NOCOUNT ON

DECLARE @ret INT
SELECT @ret = 0
BEGIN TRAN
DELETE FROM shortcut_data WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END
DELETE FROM user_henna WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END
DELETE FROM user_skill WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END
DELETE FROM user_skill_reuse_delay WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END
DELETE FROM user_log WHERE char_id =  @char_id AND subjob_id = @subjob_id
IF @@ERROR <> 0
BEGIN
	GOTO EXIT_TRAN	
END

IF @subjob_id = 1
	UPDATE user_data SET subjob1_class = -1 WHERE char_id = @char_id
ELSE IF @subjob_id = 2
	UPDATE user_data SET subjob2_class = -1 WHERE char_id = @char_id
ELSE IF @subjob_id = 3
	UPDATE user_data SET subjob3_class = -1 WHERE char_id = @char_id
IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

DECLARE @now_subjob_id INT
SELECT @now_subjob_id = subjob_id FROM user_data where char_id =  @char_id
DECLARE @hp int, @mp int, @sp int, @exp bigint, @level tinyint
IF @now_subjob_id = @subjob_id
BEGIN
	SELECT @hp = hp, @mp = mp, @sp = sp, @exp = exp, @level = level 
	FROM user_subjob
	WHERE char_id = @char_id and subjob_id = 0

	UPDATE user_data SET class = subjob0_class, subjob_id = 0, hp = @hp, mp = @mp, sp = @sp, exp = @exp, lev = @level
	WHERE char_id = @char_id 
	IF @@ERROR <> 0 OR @@ROWCOUNT <> 1	-- update, insert check
	BEGIN
		SELECT @ret = 0
		GOTO EXIT_TRAN
	END
END

DELETE FROM user_subjob
WHERE char_id = @char_id AND subjob_id = @subjob_id
IF @@ERROR = 0 AND @@ROWCOUNT = 1	-- update, insert check
BEGIN
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
END
EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetBuilderAccount ]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SetBuilderAccount     Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SetBuilderAccount
	set builder account
INPUT
	@account_name	nvarchar(50),
	@default_level		int

OUTPUT
return
made by
	young
date
	2002-11-28
change
********************************************/
CREATE PROCEDURE [dbo].[lin_SetBuilderAccount ]
(
	@account_name	nvarchar(50),
	@default_level		int
)
AS

SET NOCOUNT ON

if ( @default_level = 0)
begin
	delete from builder_account where account_name = @account_name
end else begin
	if exists(select * from builder_account where account_name = @account_name)
	begin
		update builder_account set default_builder = @default_level where account_name = @account_name
	end else begin
		declare @account_id int
		set @account_id = 0
		select top 1 @account_id = account_id from user_data where account_name = @account_name and account_id > 0
		insert into builder_account(account_name, default_builder, account_id) values(@account_name, @default_level, @account_id)
	end
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveTimeData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_SaveTimeData    
 Save time data table          
INPUT            
 @char_name NVARCHAR(30),            
 @nUsedSec INT            
OUTPUT            
return            
           
made by            
 carrot            
date            
 2004-05-10    
change            
********************************************/            
CREATE PROCEDURE [dbo].[lin_SaveTimeData]    
(            
 @account_id INT,
 @nUsedSec INT,
 @dtLastSaveDate NVARCHAR(20)
)            
AS            
            
SET NOCOUNT ON            

IF (@nUsedSec < 0)            
BEGIN            
    RAISERROR (''Not valid parameter : account id[%d] sec[%d], dt[%s] '',16, 1,  @account_id,  @nUsedSec, @dtLastSaveDate)
    RETURN -1            
END            

UPDATE  time_data SET last_logout = @dtLastSaveDate, used_sec = @nUsedSec WHERE account_id = @account_id 

IF (@@ROWCOUNT = 0)
BEGIN
	INSERT INTO time_data (account_id, last_logout, used_sec) VALUES (@account_id, @dtLastSaveDate, @nUsedSec)    
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDayUsedTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_LoadDayUsedTime    
 load account''s today used time    
INPUT    
 account_id    
OUTPUT    
return    
 used sec INT    
made by    
 carrot    
date    
 2004-03-29    
********************************************/    
CREATE PROCEDURE [dbo].[lin_LoadDayUsedTime]    
(    
 @account_id INT    
)    
AS    
    
SET NOCOUNT ON    

SELECT TOP 1 used_sec, convert(varchar(19), last_logout, 121) FROM time_data (nolock) WHERE account_id = @account_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressSiegeRegisterPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressSiegeRegisterPledge
   
INPUT   
 @fortress_id int,  
 @pledge_id int

OUTPUT  

return  

made by  
 sei

date  
 2007-04-10 
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressSiegeRegisterPledge]  
(  
 @fortress_id int,  
 @pledge_id int
)  
AS
SET NOCOUNT ON

IF NOT EXISTS (SELECT * 
		FROM fortress_siege_registry (nolock)
		WHERE fortress_id = @fortress_id AND pledge_id = @pledge_id)
BEGIN
	INSERT INTO fortress_siege_registry(fortress_id, pledge_id)
	VALUES (@fortress_id, @pledge_id)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetFortressSiegeRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_ResetFortressSiegeRegistry
   
INPUT   
 @fortress_id int,  

OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_ResetFortressSiegeRegistry]  
(  
 @fortress_id int
)  
AS
SET NOCOUNT ON

DELETE FROM fortress_siege_registry
WHERE fortress_id = @fortress_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadFortressSiegeRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_LoadFortressSiegeRegistry
   
INPUT   
 @fortress_id int,  
  
OUTPUT  
 pledge_id

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_LoadFortressSiegeRegistry]  
(  
 @fortress_id int
)  
AS  
SET NOCOUNT ON  
  
SELECT   
 pledge_id
FROM   
 fortress_siege_registry (nolock)
WHERE   
 fortress_id = @fortress_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressSiegeUnregisterPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressSiegeUnregisterPledge
   
INPUT   
 @fortress_id int,  
 @pledge_id int

OUTPUT  

return  

made by  
 sei

date  
 2007-04-10 
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressSiegeUnregisterPledge]  
(  
 @fortress_id int,  
 @pledge_id int
)  
AS
SET NOCOUNT ON

DELETE FROM fortress_siege_registry
WHERE fortress_id = @fortress_id AND pledge_id = @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveFortressSiegeRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_SaveFortressSiegeRegistry
   
INPUT   
 @fortress_id int,  
 @pledge_id int

OUTPUT  

return  

made by  
 sei

date  
 2007-04-09  
********************************************/  
CREATE PROCEDURE [dbo].[lin_SaveFortressSiegeRegistry]  
(  
 @fortress_id int,  
 @pledge_id int
)  
AS
SET NOCOUNT ON

IF NOT EXISTS (SELECT * 
		FROM fortress_siege_registry (nolock)
		WHERE fortress_id = @fortress_id AND pledge_id = @pledge_id)
BEGIN
	INSERT INTO fortress_siege_registry(fortress_id, pledge_id)
	VALUES (@fortress_id, @pledge_id)
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreatePet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreatePet
	create item sp
INPUT
	@pet_id	INT,  // same as pet_collar_dbid
	@npc_class_id	INT
OUTPUT
return
made by
	kuooo
date
	2002-08-19
	2006-01-25	btwinuni	expoint: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_CreatePet]
(
@pet_dbid		INT,
@npc_class_id		INT,
@exp_in		BIGINT,
@hp			float,
@mp			float,
@meal			int
)
AS
SET NOCOUNT ON

insert into pet_data
	(pet_id, npc_class_id,  expoint, hp, mp, meal)
	values (@pet_dbid, @npc_class_id, @exp_in, @hp, @mp, @meal)

/*SELECT @@IDENTITY*/

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeletePet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeletePet    Script Date: 2003-09-20 오전 11:51:57 ******/
/********************************************
lin_DeleteItem
	
INPUT
	@pet_id	INT
OUTPUT
return
made by
	kuooo
date
	2003-08-19
********************************************/
CREATE PROCEDURE [dbo].[lin_DeletePet]
(
	@pet_id	INT
)
AS
SET NOCOUNT ON
DELETE FROM pet_data WHERE pet_id = @pet_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SavePet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SavePet
INPUT
OUTPUT
return
made by
	kuooo
date
	2003-08-19
	2006-01-25	btwinuni	expoint: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_SavePet]
(
	@pet_id 	INT,
	@expoint	BIGINT,
	@hp		float,
	@mp		float,
	@sp		INT,
	@meal		INT,
	@nick_name	NVARCHAR(50),
	@slot1		int,
	@slot2		int,
	@slot3		int
)
AS
SET NOCOUNT ON
UPDATE 
	pet_data
set 
	expoint = @expoint,
	hp = @hp,
	mp = @mp,
	sp = @sp,
	meal = @meal,
	nick_name = @nick_name,
	slot1 = @slot1,
	slot2 = @slot2,
	slot3 = @slot3
WHERE 
	pet_id = @pet_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPet
	
INPUT	
	@pet_id int
OUTPUT
return
made by
	kuooo
date
	2003-08-22
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPet]
(
	@pet_id int
)
AS
SET NOCOUNT ON
SELECT npc_class_id  , expoint , hp, mp, sp, meal, nick_name , slot1, slot2, slot3 FROM pet_data (nolock) WHERE pet_id = @pet_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateMonRace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpdateMonRace
	update monster race
INPUT
	@race_id	int
	@winrate1	float,
	@winrate2	float
OUTPUT
return
made by
	young
date
	2004-5-18
********************************************/
CREATE PROCEDURE [dbo].[lin_UpdateMonRace]
(
@race_id		INT,
@winrate1		FLOAT,
@winrate2		FLOAT
)
AS
SET NOCOUNT ON

update monrace set winrate1 = @winrate1, winrate2 = @winrate2 where race_id = @race_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateMonRaceInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_UpdateMonRaceInfo
	update monster race info
INPUT
	@race_id	int
	@run1	float,
	@run2	float,
	@run3	float,
	@run4	float,
	@run5	float,
	@run6	float,
	@run7	float,
	@run8	float,
	@win1	int,
	@win2	int,

OUTPUT
return
made by
	young
date
	2004-5-18
********************************************/
CREATE  PROCEDURE [dbo].[lin_UpdateMonRaceInfo]
(
@race_id		INT,
@run1			FLOAT,
@run2			FLOAT,
@run3			FLOAT,
@run4			FLOAT,
@run5			FLOAT,
@run6			FLOAT,
@run7			FLOAT,
@run8			FLOAT,
@win1			int,
@win2			int

)
AS
SET NOCOUNT ON

update monrace set run1 = @run1, run2 = @run2, run3 = @run3, run4 = @run4, run5 = @run5, run6 = @run6, run7 = @run7, run8 = @run8, win1 = @win1, win2 = @win2 , race_end = 1 where race_id = @race_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMonRaceResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_GetMonRaceResult  
   
INPUT  
 @nPage  int,
 @nLinePerPage int
OUTPUT  
return  
made by  
 young  
date  
 2003-06-15  
change	
 2004-12-24 carrot
 change top 2000 to get by page number
 2005-02-22 kks
 fix column mismatch & page default
********************************************/  
CREATE    PROCEDURE [dbo].[lin_GetMonRaceResult]  
(  
 @nPage  int,
 @nLinePerPage int
)  
AS  
SET NOCOUNT ON  
  
--select top 2000 race_id, lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8, win1, win2, winrate1, winrate2, race_end from  
--monrace (nolock)  
--order by race_id desc  
 
IF (@nPage <= 0)
	SET @nPage = 1

DECLARE @nMaxRaceId int  
SET @nMaxRaceId = 0
  
select top 1 @nMaxRaceId = race_id from monrace order by race_id desc  

select race_id, lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8, win1, win2, winrate1, winrate2, race_end 
from monrace where race_id <= (@nMaxRaceId - (@nPage - 1) * @nLinePerPage) and race_id > (@nMaxRaceId - @nPage * @nLinePerPage)
order by race_id desc

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateMonRace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateMonRace
	create monster race
INPUT
	@mon1		smallint,
	@mon2		smallint,
	@mon3		smallint,
	@mon4		smallint,
	@mon5		smallint,
	@mon6		smallint,
	@mon7		smallint,
	@mon8		smallint

OUTPUT
return
made by
	young
date
	2004-5-18
********************************************/
CREATE PROCEDURE [dbo].[lin_CreateMonRace]
(
@mon1			SMALLINT,
@mon2			SMALLINT,
@mon3			SMALLINT,
@mon4			SMALLINT,
@mon5			SMALLINT,
@mon6			SMALLINT,
@mon7			SMALLINT,
@mon8			SMALLINT,
@tax_rate		int
)
AS
SET NOCOUNT ON

declare @race_id int

insert into monrace ( lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8 , tax_rate)
values ( @mon1, @mon2, @mon3, @mon4, @mon5,@mon6, @mon7,  @mon8 , @tax_rate )

select @race_id  = @@IDENTITY

select @race_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMonRaceTicket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMonRaceTicket
	
INPUT
	@item_id		int
OUTPUT
return
made by
	young
date
	2003-06-10
********************************************/
CREATE  PROCEDURE [dbo].[lin_GetMonRaceTicket]
(
	@item_id		int
)
AS
SET NOCOUNT ON

declare @ticket_id	int
declare @monraceid	int
declare @bet_type	int
declare @bet_1		int
declare @bet_2		int
declare @bet_3		int
declare @bet_money	int
declare @winrate1	float
declare @winrate2	float
declare @win1		int
declare @win2		int
declare @race_end	int
declare @tax_money	int
declare @remotefee	int

select @ticket_id = ticket_id, @monraceid = monraceid, @bet_type=bet_type, @bet_1 = bet_1, @bet_2 = bet_2 , @bet_3 = bet_3, @bet_money = bet_money  , @tax_money = tax_money , @remotefee = remotefee from monrace_ticket where item_id = @item_id and deleted = 0
select @winrate1=winrate1, @winrate2=winrate2, @win1 = win1, @win2=win2 , @race_end = race_end  from monrace where race_id = @monraceid

select @ticket_id, @monraceid, @bet_type, @bet_1, @bet_2, @bet_3, @bet_money, @winrate1, @winrate2, @win1, @win2, @race_end, @tax_money, @remotefee

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetShortCut]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  PROCEDURE  [dbo].[lin_GetShortCut]
(  
@char_id  INT,
@subjob_id INT
)  
AS  
SET NOCOUNT ON  
  
SELECT slotnum, shortcut_type, shortcut_id, shortcut_macro
FROM shortcut_data (nolock)
WHERE char_id = @char_id AND subjob_id = @subjob_id
ORDER BY slotnum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetShortCut]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetShortCut]
(  
 @char_id INT, 
 @subjob_id INT,
 @slotnum  INT,  
 @type   INT,  
 @id   INT,  
 @macro   NVARCHAR(256)  
)  
AS  
SET NOCOUNT ON  
  
IF (@char_id = 0)
BEGIN
SET @char_id = @subjob_id
SET @subjob_id = 0
END

IF (@type = 0)  
BEGIN  
 DELETE shortcut_data WHERE  char_id = @char_id AND subjob_id = @subjob_id AND slotnum = @slotnum  
END  
ELSE   
BEGIN  
 UPDATE shortcut_data SET shortcut_type=@type , shortcut_id= @id, shortcut_macro = @macro WHERE char_id = @char_id AND subjob_id = @subjob_id AND slotnum = @slotnum  
 IF (@@ROWCOUNT = 0)  
 BEGIN  
  INSERT INTO shortcut_data (char_id, slotnum, shortcut_type, shortcut_id, shortcut_macro, subjob_id) VALUES (@char_id, @slotnum, @type, @id, @macro, @subjob_id)  
 END  
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAllPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_LoadAllPledge    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_LoadAllPledge
	
INPUT
OUTPUT
return
made by
	carrot
date
	2002-06-16
********************************************/
create PROCEDURE [dbo].[lin_LoadAllPledge]
--(
--	@account_name	nvarchar(50)
--)
AS
SET NOCOUNT ON

SELECT 
	p.pledge_id, p.name, p.ruler_id, ud.char_name, 
	p.alliance_id, p.challenge_time, p.now_war_id, p.name_value, p.oust_time, p.skill_level, 
	p.private_flag, p.status, p.rank, p.castle_id, p.agit_id, p.root_name_value, 
	p.crest_id, p.is_guilty, p.dismiss_reserved_time 
FROM 
	pledge p (nolock),
	(select * from user_data (nolock) where pledge_id > 0 ) ud 
WHERE
	p.ruler_id = ud.char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteCharClearPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DeleteCharClearPledge    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DeleteCharClearPledge
	Delete character sp
INPUT
	@char_id	INT
OUTPUT
	item_id
return
made by
	bert, young
date
	2003-09-17
********************************************/
CREATE PROCEDURE [dbo].[lin_DeleteCharClearPledge]
(
	@char_id INT
)
AS

SET NOCOUNT ON

DECLARE @pledge_id INT

SELECT @pledge_id = pledge_id FROM user_data WHERE char_id = @char_id 

IF @pledge_id <> 0
BEGIN
	DECLARE @ruler_id INT
	DECLARE @now_war_id INT

	SELECT @ruler_id = ruler_id, @now_war_id = now_war_id FROM pledge WHERE pledge_id = @pledge_id
	IF @ruler_id = @char_id  -- 혈맹주인 경우 혈맹 정리
	BEGIN
		IF @now_war_id <> 0 -- 혈전 중인 혈맹인 경우 혈전 정리
		BEGIN
			DECLARE @challenger INT
			DECLARE @challengee INT

			SELECT @challenger = challenger, @challengee = challengee FROM pledge_war WHERE id = @now_war_id
			UPDATE pledge SET now_war_id = 0 WHERE pledge_id IN (@challenger, @challengee)
			DELETE FROM pledge_war WHERE id = @now_war_id
		END
		
		UPDATE user_data SET pledge_id = 0 WHERE pledge_id = @pledge_id
	END
	UPDATE user_data SET pledge_id = 0 WHERE char_id = @char_id 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_LoadPledgeById
	
INPUT
	@CharName		NVARCHAR(50)
OUTPUT
return
made by
	carrot
date
	2002-06-10
modified by kks (2005-07-22)
********************************************/
CREATE PROCEDURE [dbo].[lin_LoadPledgeById]
(
	@PledgeId		int
)
AS
SET NOCOUNT ON

SELECT 
	p.pledge_id, p.name, p.ruler_id, ud.char_name, 
	p.alliance_id, p.challenge_time, p.now_war_id, p.name_value, p.oust_time, p.skill_level, 
	p.private_flag, p.status, p.rank, p.castle_id, p.agit_id, p.fortress_id, p.root_name_value, 
	p.crest_id, p.is_guilty, p.dismiss_reserved_time, p.alliance_ousted_time, p.alliance_withdraw_time, p.alliance_dismiss_time,
	p.emblem_id, p.castle_siege_defence_count
FROM 
	(select * from pledge (nolock)where pledge_id = @PledgeId) as  p  
	JOIN 
	(select * from user_data (nolock)where pledge_id = @PledgeId) as  ud
	ON p.ruler_id = ud.char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetSubJobAcquireSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SetSubJobAcquireSkill
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@skill_id	int,
	@skill_level	int

OUTPUT
return
made by
	kks
date
	2005-01-19
********************************************/
CREATE PROCEDURE [dbo].[lin_SetSubJobAcquireSkill]
(
	@char_id	int,
	@subjob_id	int,
	@skill_id	int,
	@skill_level	int
)
AS
SET NOCOUNT ON

DECLARE @cnt INT
SET @cnt = 0

IF exists(select * from user_skill(nolock) where char_id = @char_id and subjob_id = @subjob_id and skill_id = @skill_id)    
BEGIN    
	update user_skill set skill_lev = @skill_level where char_id = @char_id and subjob_id = @subjob_id and skill_id = @skill_id
END    
ELSE
BEGIN    
	insert into user_skill (char_id, skill_id, skill_lev, to_end_time, subjob_id) values (@char_id, @skill_id, @skill_level, 0, @subjob_id)
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteSubJobSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DeleteSubJobSkill
	
INPUT
	@char_id	int,
	@subjob_id	int,
	@skill_id	int

OUTPUT
return
made by
	kks
date
	2005-01-19
********************************************/
CREATE PROCEDURE [dbo].[lin_DeleteSubJobSkill]
(
	@char_id	int,
	@subjob_id	int,
	@skill_id	int
)
AS
SET NOCOUNT ON

delete user_skill where char_id = @char_id and subjob_id = @subjob_id and skill_id = @skill_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetSkillLock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetSkillLock]
(
	@char_id	INT,
	@subjob_id	INT,
	@skill_id		INT,
	@nSkillLock	INT
)
AS
SET NOCOUNT ON

UPDATE user_skill SET is_lock = @nSkillLock WHERE char_id = @char_id AND skill_id = @skill_id AND ISNULL(subjob_id, 0) = @subjob_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelAquireSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DelAquireSkill]
(
	@char_id	INT,
	@subjob_id	INT,
	@skill_id		INT
)
AS
SET NOCOUNT ON

DELETE FROM user_skill WHERE char_id = @char_id AND skill_id = @skill_id AND ISNULL(subjob_id, 0) = @subjob_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetAquireSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetAquireSkill]
(
	@char_id	INT,
	@subjob_id	INT
)
AS
SET NOCOUNT ON

SELECT skill_id, skill_lev, is_lock FROM user_skill WHERE char_id = @char_id AND ISNULL(subjob_id, 0) = @subjob_id ORDER BY 1, 2

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAquireSkill]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetAquireSkill]
(
	@char_id	INT,
	@subjob_id	INT,
	@skill_id		INT,
	@skill_level	SMALLINT
)
AS
SET NOCOUNT ON
IF EXISTS(SELECT skill_lev FROM user_skill WHERE char_id = @char_id AND skill_id = @skill_id AND ISNULL(subjob_id, 0) = @subjob_id)
	UPDATE user_skill SET skill_lev = @skill_level WHERE char_id = @char_id AND skill_id = @skill_id AND ISNULL(subjob_id, 0) = @subjob_id
ELSE
	INSERT INTO user_skill (char_id, subjob_id, skill_id, skill_lev) VALUES (@char_id, @subjob_id, @skill_id, @skill_level)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ManBookMark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ManBookMark
	manage bookmark ( add, get-list, get , del )
INPUT
	@char_id	int,
	@bookmark_name	nvarchar(50)
OUTPUT

return
made by
	young
date
	2002-11-13
********************************************/
CREATE PROCEDURE [dbo].[lin_ManBookMark]
(
	@option	int,
	@char_id	int,
	@bookmark_id	int=0,
	@bookmark_name	nvarchar(50)='''',
	@x_loc		int= 0,
	@y_loc		int=0,
	@z_loc		int=0
)
AS
SET NOCOUNT ON

declare @bookmarkcount int
set @bookmarkcount  = 0

if ( @option = 1 )
begin
	-- add bookmark
	select @bookmarkcount  = count(*) from bookmark (nolock) where char_id = @char_id
	if ( @bookmarkcount >= 200 )
		return

	insert into bookmark ( char_id, name, world, x, y, z )
	values ( @char_id, @bookmark_name, 0, @x_loc, @y_loc, @z_loc )
end 

if ( @option = 2 )
begin
	-- get bookmark list
	select bookmarkid, name, x, y, z from bookmark (nolock) where char_id = @char_id order by name asc
end

if ( @option = 3 )
begin
	-- get on ebookmark
	select name, x, y, z from bookmark (nolock) where bookmarkid = @bookmark_id
end

if ( @option = 4 )
begin
	-- del one bookmark
	delete from bookmark where bookmarkid = @bookmark_id
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetBookMark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetBookMark    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_GetBookMark
	get  bookmark item
INPUT
	@char_id	int,
	@bookmark_name	nvarchar(50)
OUTPUT

return
made by
	young
date
	2002-11-13
********************************************/
CREATE PROCEDURE [dbo].[lin_GetBookMark]
(
	@char_id	int,
	@bookmark_name	nvarchar(50)
)
AS
SET NOCOUNT ON

select world, x, y, z from bookmark (nolock) where char_id = @char_id and name = @bookmark_name

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetListBookMark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetListBookMark    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetListBookMark
	get ths list of  bookmark item
INPUT
	@char_id	int
OUTPUT

return
made by
	young
date
	2002-11-13
********************************************/
CREATE PROCEDURE [dbo].[lin_GetListBookMark]
(
	@char_id	int
)
AS
SET NOCOUNT ON

select name from bookmark (nolock) where char_id = @char_id order by name

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelBookMark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_DelBookMark    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_DelBookMark
	add bookmark item
INPUT
	@char_id	int,
	@bookmark_name	nvarchar(50)
OUTPUT

return
made by
	young
date
	2002-11-13
********************************************/
CREATE PROCEDURE [dbo].[lin_DelBookMark]
(
	@char_id	int,
	@bookmark_name	nvarchar(50)
)
AS
SET NOCOUNT ON

delete from bookmark where char_id = @char_id and name = @bookmark_name

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddBookMark]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_AddBookMark    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_AddBookMark
	add bookmark item
INPUT
	@char_id	int,
	@bookmark_name	nvarchar(50),
	@world		int,
	@x		int,
	@y		int,
	@z		int
OUTPUT

return
made by
	young
date
	2002-11-13
********************************************/
CREATE PROCEDURE [dbo].[lin_AddBookMark]
(
	@char_id	int,
	@bookmark_name	nvarchar(50),
	@world		int,
	@x		int,
	@y		int,
	@z		int
)
AS
SET NOCOUNT ON

if exists(select name from bookmark where char_id = @char_id and name = @bookmark_name)
begin
	update bookmark set world=@world, x=@x, y=@y, z=@z where char_id = @char_id and name = @bookmark_name
end 
else 
begin
	insert into bookmark(char_id, name, world, x, y, z) 
	values( @char_id, @bookmark_name, @world, @x,@y,@z)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddPledgeNameValueLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_AddPledgeNameValueLog
desc:	add log for changing root name value
exam:	exec lin_AddPledgeNameValueLog @pledge_id, @log_id, @from, @to, @delta

history:	2006-03-31	created by btwinuni
*/
CREATE Procedure [dbo].[lin_AddPledgeNameValueLog]
	@pledge_id	int,
	@log_id		tinyint,
	@log_from	int,
	@log_to		int,
	@delta		int
AS
SET NOCOUNT ON

insert into pledge_namevalue_log (pledge_id, log_id, log_from, log_to, delta)
values (@pledge_id, @log_id, @log_from, @log_to, @delta)

SET NOCOUNT OFF

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetOlympiadMatchResult]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_GetOlympiadMatchResult]
(
@char_id INT,
@season  INT
)
AS
SELECT om.match_time, ud.char_name, om.is_winner, om.elapsed_time, ud.subjob0_class, om.game_rule
FROM olympiad_match om(nolock), user_data ud(nolock)
WHERE om.rival_id = ud.char_id 
AND om.char_id = @char_id AND om.season = @season AND om.is_winner <> 2
ORDER BY om.game_rule, om.match_time
-- is_winner가 2인 경우는 페널티 먹은 경우로써 경기횟수에 포함되지 않는다.

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertUserLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_InsertUserLog    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_InsertUserLog
	add user log data
INPUT
	char_id
	log_id
OUTPUT
return
made by
	young
date
	2003-1-15
change
********************************************/
CREATE PROCEDURE [dbo].[lin_InsertUserLog]
(
	@char_id	INT,
	@log_id	TINYINT
)
AS

SET NOCOUNT ON

insert into user_log( char_id, log_id)
values (@char_id, @log_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetUserLogTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_GetUserLogTime    Script Date: 2003-09-20 오전 11:51:59 ******/
/********************************************
lin_GetUserLogTime
	get user log time
INPUT
	char_id, 
	log_id,
	log_to

OUTPUT
	time diff
return
made by
	young
date
	2003-01-22
change
********************************************/
CREATE PROCEDURE [dbo].[lin_GetUserLogTime]
(
	@char_id	INT,
	@log_id		INT,
	@log_to	INT
)
AS

SET NOCOUNT ON

DECLARE @use_time int

select 
	top 1 @use_time = use_time
from 
	user_log (nolock)
where 
	char_id = @char_id 
	and log_id = @log_id 
	and log_to = @log_to
order by 
	log_date desc

if @use_time = NULL
begin
	select @use_time = use_time
	from user_data (nolock)
	where char_id = @char_id
end

select @use_time

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddUserLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_AddUserLog
	
INPUT	
	@char_id	int,
	@log_id		int,
	@log_from	int,
	@log_to		int,
	@use_time	int,
	@subjob_id	int
OUTPUT
return
made by
	carrot
date
	2002-06-16
modified by 
	kks
date
	2005-01-17	
modified by
	btwinuni
date
	2005-10-24
********************************************/
CREATE PROCEDURE [dbo].[lin_AddUserLog]
(
	@char_id	int,
	@log_id		int,
	@log_from	int,
	@log_to		int,
	@use_time	int,
	@subjob_id	int = -1
)
AS
SET NOCOUNT ON


if @subjob_id < 0
begin
	SELECT @subjob_id = subjob_id FROM user_data(NOLOCK) WHERE char_id = @char_id
end

insert into user_log(char_id, log_id, log_from, log_to, use_time, subjob_id) values(@char_id, @log_id, @log_from, @log_to, @use_time, @subjob_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeNameByMergeBatch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_ChangeNameByMergeBatch
desc:	batch for changing pledge name

history:	2007-06-04	created by btwinnuni
*/
create procedure [dbo].[lin_ChangeNameByMergeBatch]
as

set nocount on

begin tran

if exists (select * from sysobjects where id = object_id(N''changed_name_by_merge'') and objectproperty(id, N''IsUserTable'') = 1)
begin
	update pledge
	set pledge.name = changed_name_by_merge.name_new
	from changed_name_by_merge
	where pledge.pledge_id = changed_name_by_merge.id
		and changed_name_by_merge.type = 1
		and changed_name_by_merge.change_flag = 2

	if (@@rowcount > 0 and @@error = 0)
	begin
		update changed_name_by_merge
		set change_date = getdate(),
			change_flag = 1
		where type = 1
			and change_flag = 2
	end
end

commit tran

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadMergedInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadMergedInfo
desc:	for merged server

history:	2007-05-07	created by btwinuni
*/
create procedure [dbo].[lin_LoadMergedInfo]
	@id int,
	@type int
as

set nocount on
select previous_server, name_origin from changed_name_by_merge (nolock) where id = @id and type = @type and change_flag = 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadInZoneRestriction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadInZoneRestriction
desc:	get last time used inzone

history:	2007-05-22	created by btwinuni
*/
create procedure [dbo].[lin_LoadInZoneRestriction]
	@char_id int
as

set nocount on

select inzone_type_id, group_restriction, last_use, entrance_count, max_entrance_count from user_inzone (nolock) 
where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetInZoneRestriction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_ResetInZoneRestriction
desc:	reset all last time used inzone

history:	2007-06-25	created by btwinuni
*/
create procedure [dbo].[lin_ResetInZoneRestriction]
	@char_id int
as

set nocount on

delete from user_inzone where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_MarkInZoneRestriction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_MarkInZoneRestriction
desc:	set last time used inzone

history:	2007-05-22	created by btwinuni
*/
create procedure [dbo].[lin_MarkInZoneRestriction]
	@char_id int,
	@inzone_type_id int,
	@group_restriction int,
	@last_use int,
	@entrance_count int,
	@max_entrance_count int
as

set nocount on

update user_inzone
set last_use = @last_use,
	entrance_count = @entrance_count,
	max_entrance_count = @max_entrance_count
where char_id = @char_id
	and inzone_type_id = @inzone_type_id
	and group_restriction = @group_restriction

if @@rowcount = 0
begin
	insert into user_inzone (char_id, inzone_type_id, group_restriction, last_use, entrance_count, max_entrance_count)
	values (@char_id, @inzone_type_id, @group_restriction, @last_use, @entrance_count, @max_entrance_count)
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_StartOlympiadSeason]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_StartOlympiadSeason]
(
@season INT,
@step INT,
@season_start_time INT
)
AS
SET NOCOUNT ON

UPDATE olympiad
SET step = @step, season_start_time = @season_start_time
WHERE season = @season

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadOlympiad]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadOlympiad]
AS
SET NOCOUNT ON

DECLARE @cnt INT
SELECT @cnt = COUNT(*) FROM olympiad

IF @cnt = 0
BEGIN
	INSERT INTO olympiad (step) VALUES (0)
END
SELECT TOP 1 season, step, 
ISNULL(season_start_time, 0),
ISNULL(start_sec, 0), 
ISNULL(bonus1_sec, 0), 
ISNULL(bonus2_sec, 0), 
ISNULL(bonus3_sec, 0), 
ISNULL(bonus4_sec, 0), 
ISNULL(nominate_sec, 0) 
FROM olympiad ORDER BY season DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveOlympiadTerm]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveOlympiadTerm]
(
@season INT,
@start_sec INT,
@bonus1_sec INT,
@bonus2_sec INT,
@bonus3_sec INT,
@bonus4_sec INT,
@nominate_sec INT
)
AS
SET NOCOUNT ON

UPDATE olympiad
SET start_sec = @start_sec, 
bonus1_sec = @bonus1_sec, bonus2_sec = @bonus2_sec, bonus3_sec = @bonus3_sec, bonus4_sec = @bonus4_sec, 
nominate_sec = @nominate_sec
WHERE season = @season

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveSeasonStartTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveSeasonStartTime]
(
@season AS INT,
@season_start_time AS INT
)
AS
SET NOCOUNT ON
UPDATE olympiad
SET season_start_time = @season_start_time
WHERE season = @season

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetDominionRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ResetDominionRegistry]  
(  
 @dominion_id int
)  
AS
SET NOCOUNT ON

DELETE FROM dominion_registry
WHERE dominion_id = @dominion_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadDominionRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadDominionRegistry]  
(  
 @dominion_id int
)  
AS  
SET NOCOUNT ON  
  
SELECT	registry_type, registry_id
FROM	dominion_registry(nolock)
WHERE	dominion_id = @dominion_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteDominionRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteDominionRegistry]  
(  
 @dominion_id int,
 @registry_type int,
 @registry_id	int
)  
AS
SET NOCOUNT ON

DELETE FROM dominion_registry
WHERE dominion_id = @dominion_id and registry_type = @registry_type and registry_id = @registry_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDominionRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SaveDominionRegistry]  
(  
 @dominion_id int,  
 @registry_type int,
 @registry_id	int
)  
AS
SET NOCOUNT ON

INSERT INTO dominion_registry (dominion_id, registry_type, registry_id) 
VALUES (@dominion_id, @registry_type, @registry_id)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CharLogout]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_CharLogout    
 log character Logout    
INPUT    
 char_id    
OUTPUT    
return    
 week play time by sec    
made by    
 carrot    
date    
 2002-06-11    
change    
 2002.-12-20    
  add usetime set    
 2004-03-29    
  add function to write today''s used sec    
********************************************/    
CREATE PROCEDURE [dbo].[lin_CharLogout]    
(    
 @char_id INT,    
 @usedTimeSec INT
)    
AS    
    
SET NOCOUNT ON    
    
DECLARE @logoutDate DATETIME    
SET @logoutDate = GETDATE()    
    
UPDATE user_data SET Logout = @logoutDate, use_time = use_time + @usedTimeSec WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddBlockList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_AddBlockList  
 add character''s blocked list.  
INPUT  
 char_id,  
 target char_name  
OUTPUT  
return  
made by  
 carrot  
date  
 2003-12-01  
change  
********************************************/  
CREATE PROCEDURE [dbo].[lin_AddBlockList]  
(  
 @char_id INT,  
 @target_char_name NVARCHAR(50)  
)  
AS  
  
SET NOCOUNT ON  
  
DECLARE @target_char_id INT  
DECLARE @target_builder_lev INT  
SET @target_char_id = 0  
SET @target_builder_lev  = 0

SELECT @target_char_id = char_id, @target_builder_lev = builder FROM user_data WHERE char_name = @target_char_name  

IF (@target_builder_lev  > 0 AND @target_builder_lev  <= 5)
BEGIN
  RAISERROR (''Try block builder : char id = [%d], target naem[%s]'', 16, 1, @char_id, @target_char_name)  
  RETURN -1;
END
  
IF @target_char_id > 0  
BEGIN  
 INSERT INTO user_blocklist VALUES (@char_id, @target_char_id, @target_char_name)  
 IF NOT @@ROWCOUNT = 1  
 BEGIN  
  RAISERROR (''Cannot find add blocklist: char id = [%d], target naem[%s]'', 16, 1, @char_id, @target_char_name)  
 END  
 ELSE  
 BEGIN  
  SELECT @target_char_id  
 END  
END  
ELSE  
BEGIN  
 RAISERROR (''Cannot find add blocklist: char id = [%d], target naem[%s]'', 16, 1, @char_id, @target_char_name)  
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_AddUserBookmarkSlot]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_AddUserBookmarkSlot
desc:	increase user boolmark slot

history:	2008-03-25	created by tempted
*/

CREATE PROCEDURE [dbo].[lin_AddUserBookmarkSlot] 
(
	@char_id int,
	@slot_num int
)
AS

SET NOCOUNT ON

UPDATE user_data 
SET bookmark_slot = bookmark_slot + @slot_num
WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_EnableChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_EnableChar    Script Date: 2003-09-20 오전 11:51:58 ******/
/********************************************
lin_EnableChar
	Enable character
INPUT
	@char_name nvarchar(50),
	@account_id int
OUTPUT

return
made by
	young
date
	2002-12-6
	enable character
********************************************/
CREATE PROCEDURE [dbo].[lin_EnableChar]
(
@char_name nvarchar(50),
@account_id int
)
AS

SET NOCOUNT ON

declare @old_account_id int

select @old_account_id = account_id from user_data (nolock) where char_name = @char_name

if @old_account_id < 0
begin
	update user_data set account_id = @account_id where char_name = @char_name
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetUserSSQDawnRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**  
  * @procedure lin_SetUserSSQDawnRound  
  * @brief SSQ 관련 정보 세팅  
  *  
  * @date 2004/12/17  
  * @author Seongeun Park  <sonai@ncsoft.net>  
  */  
CREATE PROCEDURE [dbo].[lin_SetUserSSQDawnRound]  
(  
 @char_id  INT,  
 @ssq_dawn_round INT  
)  
AS  
SET NOCOUNT ON  
  
UPDATE user_data SET ssq_dawn_round = @ssq_dawn_round WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SaveMaill
	save mail 
INPUT
	@char_id		int,
	@mail_type		int,
	@related_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
OUTPUT
return
made by
	kks
date
	2004-12-15
********************************************/
CREATE PROCEDURE [dbo].[lin_SaveMail]
(
	@char_id		int,
	@mail_type		int,
	@related_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
)
AS
SET NOCOUNT ON

DECLARE @mail_id int
SET @mail_id = 0

INSERT INTO user_mail
(title, content) VALUES (@title, @content)

SET @mail_id = @@IDENTITY

DECLARE @sender_name nvarchar(50)

SELECT @sender_name = char_name FROM user_data(nolock) WHERE char_id = @char_id

INSERT INTO user_mail_sender
(mail_id, related_id, mail_type, mailbox_type, sender_id, sender_name, receiver_name_list)
VALUES
(@mail_id, @related_id, @mail_type, 3, @char_id, @sender_name, @receiver_name_list)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveCharacterPledge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_SaveCharacterPledge    Script Date: 2003-09-20 오전 11:52:00 ******/
/********************************************
lin_SaveCharacterPledge

INPUT
OUTPUT
return
made by
	carrot
date
	2003-06-30
change
	kks (2006-03-07)
********************************************/
CREATE PROCEDURE [dbo].[lin_SaveCharacterPledge]
(
	@pledge_id INT,
	@char_id  INT,
	@pledge_type INT
)
AS

SET NOCOUNT ON

UPDATE 
	user_data 
set 
	pledge_id= @pledge_id,
	pledge_type = @pledge_type
WHERE 
	char_id= @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetRimPointRank]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:	lin_GetRimPointRank
desc:	
exam:	exec lin_GetRimPointRank @bidingTime
 
history:	2008-06-13	choanari
*/ 
CREATE procedure [dbo].[lin_GetRimPointRank]
	@bindingTime int
as 

set nocount on 

select top 25 ur.char_id, ud.char_name, ud.class, ud.lev, max(ur.point) 
from user_rim_point ur (nolock) left join user_data ud (nolock) on ur.char_id = ud.char_id
where ur.log_time >= @bindingTime
group by ur.char_id, ud.char_name, ud.class, ud.lev
order by max(ur.point)desc, ud.lev

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_JoinPledgeMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_JoinPledgeMember    Script Date: 2003-09-20 오전 11:51:57 ******/
-- lin_JoinPledgeMember
-- by kks

CREATE PROCEDURE
[dbo].[lin_JoinPledgeMember] (@pledge_id INT, @pledge_type INT, @member_id INT)
AS

SET NOCOUNT ON

DECLARE @ret INT

BEGIN TRAN

UPDATE user_data
SET pledge_id = @pledge_id, pledge_type = @pledge_type, grade_id = 0
WHERE char_id = @member_id

IF @@ERROR = 0 AND @@ROWCOUNT = 1
BEGIN
	-- 추가되는 코드는 여기에
	SELECT @ret = 1
END
ELSE
BEGIN
	SELECT @ret = 0
	GOTO EXIT_TRAN
END

EXIT_TRAN:
IF @ret<> 0
BEGIN
	COMMIT TRAN
END
ELSE
BEGIN
	ROLLBACK TRAN
END
SELECT @ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SaveDropExp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SaveDropExp
	
INPUT	
	@drop_exe	bigint,
	@char_id	int
OUTPUT
return
made by
	carrot
date
	2002-06-16
	2006-01-25	btwinuni	drop_exp: int -> bigint
********************************************/
CREATE PROCEDURE [dbo].[lin_SaveDropExp]
(
	@drop_exe	bigint,
	@char_id	int
)
AS
SET NOCOUNT ON

update user_data set drop_exp = @drop_exe where char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetSimpleUserData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetSimpleUserData]
	@char_id int
as
set nocount on

SELECT char_name, nickname, lev, class, gender, race, grade_id FROM user_data (nolock) WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetUserItemDuration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_GetUserItemDuration]
	@char_id int
as
set nocount on

SELECT item_duration FROM user_data (nolock) WHERE char_id = @char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ChangeCharacterLocation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****** Object:  Stored Procedure dbo.lin_ChangeCharacterLocation    Script Date: 2003-09-20 오전 11:51:56 ******/
/********************************************
lin_ChangeCharacterLocation
	Set Character location
INPUT
	@char_name	nvarchar,
	@nWorld		SMALLINT,
	@nX		INT,
	@nY		INT,
	@nZ		INT
OUTPUT
	char_id
return
made by
	carrot
date
	2002-07-02
********************************************/
CREATE PROCEDURE [dbo].[lin_ChangeCharacterLocation]
(
	@char_name	NVARCHAR(24),
	@nWorld		INT,
	@nX		INT,
	@nY		INT,
	@nZ		INT
)
AS

SET NOCOUNT ON

DECLARE @Char_id INT
SET @Char_id = 0

UPDATE user_data SET world = @nWorld, xLoc = @nX , yLoc = @nY , zLoc = @nZ WHERE char_name = @char_name
IF @@ROWCOUNT > 0
BEGIN
	SELECT @Char_id = char_id FROM user_data WHERE char_name = @char_name
END

SELECT @Char_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetDBIDByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************    
lin_GetDBIDByCharName  
 Get user id  
INPUT    
 @charname nvarchar(50),    
OUTPUT    
    
return    
made by    
 carrot    
date    
 2004-02-22  
********************************************/    
CREATE PROCEDURE [dbo].[lin_GetDBIDByCharName]  
(    
 @char_name nvarchar(50)  
)    
AS    
SET NOCOUNT ON    
  
SELECT TOP 1 char_id FROM user_data WHERE char_name = @char_name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadBotReportTopTen]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadBotReportTopTen
desc:	Load Bot Report Top Ten
exam:	exec lin_LoadBotReportTopTen
history:	2008-06-18	created by Phyllion
*/
CREATE procedure [dbo].[lin_LoadBotReportTopTen]
as
SET NOCOUNT ON

SELECT TOP 40 b.char_id, b.reported 
FROM bot_report b inner join user_data ud on b.char_id = ud.char_id and ud.account_id > 0
ORDER BY reported DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_SetAgitDeco]
(
	@agit_id INT,
	@type INT,
	@id INT,
	@name VARCHAR(256),
	@level INT,
	@expire INT,
	@is_active INT
)
AS
SET NOCOUNT ON

DELETE FROM agit_deco
WHERE agit_id = @agit_id AND type = @type

INSERT INTO agit_deco
(agit_id, type, id, name, level, expire, is_active)
VALUES
(@agit_id, @type, @id, @name, @level, @expire, @is_active)

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadAgitDeco]
(
	@agit_id INT
)
AS
SET NOCOUNT ON

SELECT type, id, level, expire, is_active FROM agit_deco WHERE agit_id = @agit_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ResetAgitDeco]
(
	@agit_id INT,
	@type INT
)
AS
SET NOCOUNT ON

DELETE FROM agit_deco
WHERE agit_id = @agit_id AND type = @type

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_RenewAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_RenewAgitDeco]
(
	@agit_id INT,
	@type INT,
	@expire INT,
	@is_active INT
)
AS
SET NOCOUNT ON

UPDATE agit_deco
SET expire = @expire, is_active = @is_active
WHERE agit_id = @agit_id AND type = @type

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ActivateAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [dbo].[lin_ActivateAgitDeco]
	@is_active	int,
	@agit_id	int,
	@type	int
as
set nocount on

UPDATE agit_deco SET is_active = @is_active WHERE agit_id = @agit_id AND type = @type

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ResetAllAgitDeco]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_ResetAllAgitDeco]
(
	@agit_id INT
)
AS
SET NOCOUNT ON

DELETE FROM agit_deco
WHERE agit_id = @agit_id

SELECT @@ROWCOUNT

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CopyItemByDeletedChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:	lin_CopyByDeletedChar
desc:	back up items by deleted character
inout:
	@char_id	INT,
	@item_type	INT,
	@amount	BIGINT,
	@enchant	INT,
	@eroded	INT,
	@bless		INT,
	@ident		INT,
	@wished	INT,
	@warehouse	INT,
	@item_id		INT,
	@variation_opt1 INT,
	@variation_opt2 INT,
	@intensive_item_type INT,
	@inventory_slot_index	INT
output:
	Item_ID, @@IDENTITY
 
history:	2007-10-09 made by choanari
*/ 
CREATE procedure [dbo].[lin_CopyItemByDeletedChar]
(
@char_id	INT,
@item_type	INT,
@amount	BIGINT,
@enchant	INT,
@eroded	INT,
@bless		INT,
@ident		INT,
@wished	INT,
@warehouse	INT,
@item_id		INT,
@variation_opt1 INT,
@variation_opt2 INT,
@intensive_item_type INT,
@inventory_slot_index	INT
)
as  
set nocount on 

IF @bless < 0 OR @bless > 255
	SET @bless = 0

insert into user_item_deleted
	(item_id, char_id , item_type , amount , enchant , eroded , bless , ident , wished , warehouse, variation_opt1, variation_opt2, intensive_item_type, inventory_slot_index) 
	values 
	(@item_id, @char_id, @item_type , @amount , @enchant , @eroded , @bless , @ident , @wished , @warehouse, @variation_opt1, @variation_opt2, @intensive_item_type, @inventory_slot_index)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SetRimPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:	lin_SetRimPoint
desc:	
exam:	exec lin_SetRimPoint @char_id, @point, @get_time, @reset_time
 
history:	2008-06-12	choanari
*/ 
CREATE procedure [dbo].[lin_SetRimPoint]
	@char_id int,
	@point int,
	@get_time int,
	@reset_time int
as 
declare
	@last_time int,
	@last_point int

set nocount on 

if ( exists ( select * from user_rim_point (nolock) where char_id = @char_id ) )
begin
	set @last_time = (select top 1 log_time from user_rim_point (nolock) where char_id = @char_id)
	if (@last_time + @reset_time < @get_time)
	begin
		-- update
		update user_rim_point set point = @point, log_time = @get_time where char_id = @char_id
	end else begin
		set @last_point = (select top 1 point from user_rim_point (nolock) where char_id = @char_id)
		if(@last_point >= @point)
		begin
			update user_rim_point set point = @last_point, log_time = @get_time where char_id = @char_id
		end else begin
			update user_rim_point set point = @point, log_time = @get_time where char_id = @char_id
		end
	end
end else begin
	-- insert
	insert into user_rim_point ( char_id, point, log_time ) values ( @char_id, @point, @get_time )
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FEInsertRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_FEInsertRanking
 INPUT            
 @char_id  INT            
 @fish_length  INT            
OUTPUT            
return            
           
made by            
	mgpark
date            
 2006-01-16    
********************************************/            
CREATE PROCEDURE [dbo].[lin_FEInsertRanking]    
(            
 @char_id  INT,    
 @fish_length  INT,      
 @prize_count  INT
)            
AS            
            
SET NOCOUNT ON            
INSERT INTO fishing_event_record (char_id, length, isrewardtime) 
VALUES (@char_id, @fish_length, 0)    	
if ( (select count(*) from fishing_event_record where  isrewardtime = 0 )  > @prize_count )
begin
	Delete fishing_event_record  
	WHERE (id = (Select top 1 id FROM fishing_event_record where isrewardtime = 0 order by length, id desc))
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FELoadList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_FELoadList
 INPUT            
 @isrewardtime  INT            
OUTPUT            
return            
	char_id, length
           
made by            
	mgpark
date            
 2006-01-16    

********************************************/            
CREATE PROCEDURE [dbo].[lin_FELoadList]    
(            
 @isrewardtime  INT
)            
AS            
            
SET NOCOUNT ON            

if @isrewardtime = 0
begin

	SELECT char_id,  length, isrewardtime FROM fishing_event_record
	WHERE isrewardtime = 0
	ORDER BY length DESC, id
end
else
begin
	SELECT char_id,  length, isrewardtime FROM fishing_event_record
	WHERE isrewardtime = 1  or  isrewardtime = 2
	ORDER BY length DESC, id
end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FEFinish]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_FEFinish 
 INPUT            
 OUTPUT            
made by            
	mgpark
date            
 2006-01-16    

********************************************/            
CREATE PROCEDURE [dbo].[lin_FEFinish]    
AS            
            
SET NOCOUNT ON            

	Delete fishing_event_record WHERE isrewardtime = 1 OR isrewardtime = 2


	Update fishing_event_record SET isrewardtime = 1
	WHERE  isrewardtime = 0

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_FEDeletePrize]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************            
lin_FEDeletePrize
 INPUT
	@char_id INT
 OUTPUT            
made by            
	mgpark
date            
 2006-01-16    

********************************************/            
CREATE PROCEDURE [dbo].[lin_FEDeletePrize]    
(
	@char_id INT
)

AS            
            
SET NOCOUNT ON            

Update fishing_event_record SET isrewardtime = 2
/* WHERE char_id = @char_id  AND isrewardtime = 1*/
 WHERE (id = (Select top 1 id FROM fishing_event_record where char_id = @char_id  AND isrewardtime = 1 order by length desc, id ))

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoMercenary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_InsertIntoMercenary]  
(  
@residence_id INT,  
@npc_id INT,  
@x INT,  
@y INT,  
@z INT,  
@angle INT,  
@hp INT,  
@mp INT  
)  
AS  
SET NOCOUNT ON  
  
if exists(select * from mercenary where x= @x and y = @y and  z = @z)  
begin  
 delete mercenary where x= @x and y = @y and  z = @z  
end  
  
INSERT INTO mercenary  
(residence_id, npc_id, x, y, z, angle, hp, mp)  
VALUES  
(@residence_id, @npc_id, @x, @y, @z, @angle, @hp, @mp)  
SELECT @@IDENTITY

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_UpdateMercenary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_UpdateMercenary]
(
@id INT,
@x INT,
@y INT,
@z INT,
@angle INT,
@hp INT,
@mp INT
)
AS
UPDATE mercenary
SET
x = @x,
y = @y,
z = @z, 
angle = @angle,
hp = @hp,
mp = @mp
WHERE id = @id
IF @@ROWCOUNT <> 1
BEGIN
RAISERROR (''Failed to Update Mercenary id = %d.'', 16, 1, @id)
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteMercenary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteMercenary]
(
@residence_id INT
)
AS
IF EXISTS(SELECT * FROM mercenary WHERE residence_id = @residence_id)
	DELETE FROM mercenary WHERE residence_id = @residence_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadMercenary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadMercenary]
(
@residence_id INT
)
AS
SELECT id, npc_id, x, y, z, angle, hp, mp
FROM mercenary
WHERE residence_id = @residence_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMonRaceBet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMonRaceBet
	
INPUT
	@bet_type		int
	@race_id		int
OUTPUT
return
made by
	young
date
	2003-05-31
********************************************/
CREATE PROCEDURE [dbo].[lin_GetMonRaceBet]
(
	@bet_type		int,
	@race_id		int
)
AS
SET NOCOUNT ON

if ( @bet_type = 1 )
begin

	select bet_1, sum( bet_money) from monrace_ticket (nolock) 
	where monraceid = @race_id
	and bet_type = 1 and deleted = 0
	group by bet_1

end else begin

	select bet_1, bet_2 , sum( bet_money ) from monrace_ticket (nolock) 
	where monraceid = @race_id
	and bet_type = 2 and deleted = 0
	group by bet_1, bet_2

end

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_GetMonRaceTaxSum]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_GetMonRaceTaxSum
	
INPUT
	@race_id		int
OUTPUT
return
made by
	young
date
	2004-08-05
********************************************/
CREATE  PROCEDURE [dbo].[lin_GetMonRaceTaxSum]
(
	@race_id		int
)
AS
SET NOCOUNT ON

select isnull( sum ( tax_money) , 0) from monrace_ticket (nolock) where monraceid = @race_id and deleted = 0

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DelMonRaceTicket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_DelMonRaceTicket
	
INPUT
	@item_id		int
OUTPUT
return
made by
	young
date
	2003-06-10
********************************************/
CREATE  PROCEDURE [dbo].[lin_DelMonRaceTicket]
(
	@item_id		int
)
AS
SET NOCOUNT ON

update monrace_ticket set deleted = 1 where item_id = @item_id

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CreateMonRaceTicket]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_CreateMonRaceTicket
	ALTER  monster race ticket
INPUT
	@monraceid	int,
	@bet_type	smallint,
	@bet_1		smallint,
	@bet_2		smallint,
	@bet_3		smallint,
	@bet_money	int,
	@tax_money	int,
	@item_id	int,
	@remotefee	int=0

OUTPUT
return
made by
	young
date
	2004-5-18
********************************************/

CREATE PROCEDURE [dbo].[lin_CreateMonRaceTicket]
(
	@monraceid	int,
	@bet_type	smallint,
	@bet_1		smallint,
	@bet_2		smallint,
	@bet_3		smallint,
	@bet_money	int,
	@tax_money	int,
	@item_id	int,
	@remotefee	int=0
)
AS
SET NOCOUNT ON

declare @ticket_id int

insert into monrace_ticket ( monraceid, bet_type, bet_1, bet_2, bet_3, bet_money,  tax_money, item_id , remotefee )
values ( @monraceid, @bet_type, @bet_1, @bet_2, @bet_3,  @bet_money,  @tax_money, @item_id , @remotefee )

select @ticket_id  = @@IDENTITY

select @ticket_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteResidenceGuard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteResidenceGuard]
(
@x INT,
@y INT,
@z INT
)
AS
DELETE FROM residence_guard
WHERE x = @x AND y = @y AND z = @z

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadResidenceGuard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_LoadResidenceGuard]
(
@residence_id INT
)
AS
SELECT item_id, npc_id, guard_type, can_move, x, y, z, angle
FROM residence_guard
WHERE residence_id = @residence_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_InsertIntoResidenceGuard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_InsertIntoResidenceGuard]
(
@residence_id INT,
@item_id INT,
@npc_id INT,
@guard_type INT,
@can_move INT,
@x INT,
@y INT,
@z INT,
@angle INT
)
AS
INSERT INTO residence_guard
(residence_id, item_id, npc_id, guard_type, can_move, x, y, z, angle)
VALUES
(@residence_id, @item_id, @npc_id, @guard_type, @can_move, @x, @y, @z, @angle)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteAllResidenceGuard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[lin_DeleteAllResidenceGuard]  
(  
@res INT  
)  
AS  
IF EXISTS(SELECT * FROM residence_guard WHERE residence_id = @res)
	DELETE FROM residence_guard WHERE residence_id = @res

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_LoadPledgeByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_LoadPledgeByName
desc:	get pledge

history:	2007-05-10	modified by btwinuni
*/
CREATE PROCEDURE [dbo].[lin_LoadPledgeByName]
(
 @PledgeName  NVARCHAR(50)  
) 
AS
SET NOCOUNT ON

declare @pledge_id INT

set @pledge_id = 0

select top 1 @pledge_id = pledge_id from pledge (nolock) where name = @PledgeName

exec lin_LoadPledgeById @pledge_id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService3ChangeName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService3ChangeName 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService3ChangeName ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated from ''lin_ApplyAddedService'' by neo
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService3ChangeName] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 
declare 
        @sql				nvarchar(4000),
        @from_server		int,
        @to_server			int,
        @from_char_id		int, 
        @to_char_id			int, 
        @to_account_name	nvarchar(24), 
        @idx				int, 
        @from_account_id	int, 
        @to_account_id		int, 
        @char_count			int, 
        @from_char_name		nvarchar(24), 
        @to_char_name		nvarchar(24), 
        @class				int,
        @gender				int, 
        @old_gender			int, 
        @old_face_index		int, 
        @old_hair_shape_index	int, 
        @old_hair_color_index	int, 
        @ban_status				int, 
        @ban_date				datetime, 
        @ban_hour				int, 
        @pledge_id				int, 
        @level					int, 
        @original_pk			int,
        @cursed_weapon			int,
        @char_id				int,
        @db_info				nvarchar(64),
        @subjob_id				int,
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				int,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int
		


 
 
-- ServiceType == 3     // 이름변경 
declare name_cursor cursor for 
select idx, fromUid, fromCharacter, toCharacter from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 3 and fromServer = @server_id 
 
open name_cursor 
fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
 
while @@fetch_status = 0 
begin 
        set @pledge_id = 0 
        -- source character is not existed(-3001) 
        select @from_char_id = char_id, @pledge_id = @pledge_id + pledge_id from user_data (nolock) where account_id = @from_account_id and char_name = @from_char_name 
        if @@rowcount = 0 
        begin 
                update AddedServiceList set serviceFlag = -3001, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -3001, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
                continue 
        end 
        -- destination character is not existed(-3002) 
        select @to_char_id = char_id, @level = lev, @pledge_id = @pledge_id + pledge_id from user_data (nolock) where account_id = @from_account_id and char_name = @to_char_name 
        if @@rowcount = 0 
        begin 
                update AddedServiceList set serviceFlag = -3002, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -3002, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
                continue 
        end 
        -- character is banned(-3003) 
        set @ban_status = null 
        select @ban_status = status, @ban_date = ban_date, @ban_hour = ban_hour from user_ban where char_id = @from_char_id 
        if isnull(@ban_status, 0) = 2 or (isnull(@ban_status, 0) = 1 and dateadd(hh, @ban_hour, @ban_date) > getdate()) 
        begin 
                update AddedServiceList set serviceFlag = -3003, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -3003, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
                continue 
        end 
        -- character is a member of pledge(-3004) 
        if @pledge_id > 0 
        begin 
                update AddedServiceList set serviceFlag = -3004, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -3004, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
                continue 
        end 
        -- character is hero(-3005) 
        select * from user_nobless where char_id = @from_char_id and hero_type > 0 
        if @@rowcount > 0 
        begin 
                update AddedServiceList set serviceFlag = -3005, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -3005, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
                continue 
        end 
        -- target character is invalid(-3006) 
        if @level is null or @level > 1 
        begin 
                update AddedServiceList set serviceFlag = -3006, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -3006, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
                continue 
        end 
 
        update user_data set account_id = -4, char_name = cast(@server_id as varchar)+''_''+@from_char_name where account_id = @from_account_id and char_id = @to_char_id 
        update user_data set char_name = @to_char_name where char_id = @from_char_id 
        update user_data set char_name = @from_char_name where char_id = @to_char_id    -- prohibit to use source character''s name 
        -- success to serve (1) 
        if @@rowcount > 0 
        begin 
                update AddedServiceList set serviceFlag = 1, applyDate = getdate() where idx = @idx 
                exec lin_AddPunishmentHistory @from_char_name, @from_char_id, 103, @to_account_name 
                update user_friend set friend_char_name = @to_char_name where friend_char_name = @from_char_name 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_comm+'','' 
                        + ''     ''''select * from lin2comm.dbo.user_memo'' 
                        + ''     where world_id=''+cast(@server_id as varchar) 
                        + ''             and account_id=''+cast(@from_account_id as varchar) 
                        + ''             and char_id=''+cast(@from_char_id as varchar)+'''''')'' 
                        + '' set char_name=''''''+@to_char_name+'''''''' 
                exec(@sql) 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = 1, applyDate = getdate()'' 
                exec(@sql) 
        end 
        -- fail to serve (-1) 
        else 
        begin 
                update AddedServiceList set serviceFlag = -1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
        end 
 
        fetch next from name_cursor into @idx, @from_account_id, @from_char_name, @to_char_name 
end 
 
close name_cursor 
deallocate name_cursor

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService5MainSubJobExchange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService5MainSubJobExchange 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService5MainSubJobExchange ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated from ''lin_ApplyAddedService'' by neo
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService5MainSubJobExchange] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 
declare 
        @sql				nvarchar(4000),
        @from_server		int,
        @to_server			int,
        @from_char_id		int, 
        @to_char_id			int, 
        @to_account_name	nvarchar(24), 
        @idx				int, 
        @from_account_id	int, 
        @to_account_id		int, 
        @char_count			int, 
        @from_char_name		nvarchar(24), 
        @to_char_name		nvarchar(24), 
        @class				int,
        @gender				int, 
        @old_gender			int, 
        @old_face_index		int, 
        @old_hair_shape_index	int, 
        @old_hair_color_index	int, 
        @ban_status				int, 
        @ban_date				datetime, 
        @ban_hour				int, 
        @pledge_id				int, 
        @level					int, 
        @original_pk			int,
        @cursed_weapon			int,
        @char_id				int,
        @db_info				nvarchar(64),
        @subjob_id				int,
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				bigint,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int,
		@counter_race			int,
		@subjob0_class			int,
		@subjob1_class			int,
		@subjob2_class			int,
		@subjob3_class			int



-- ServiceType == 5     // 메인, 서브 직업 변경
declare change_sub_cursor cursor for 
select idx, fromUid, fromCharacter, toMainClassNum from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 5 and fromServer = @server_id and toMainClassNum in (1,2,3)
--이벤트 select idx, fromUid, fromCharacter, subjobId from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 5 and fromServer = @server_id and subjobId in (1,2,3)

open change_sub_cursor 
fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id

while @@fetch_status = 0 
begin 
		-- ### 조건체크 시작
        -- character is not existed(-5001) 
        select @from_char_id = char_id, @to_account_name = account_name, @class = class, @bak_subjob_id = subjob_id
        from user_data (nolock) where account_id = @from_account_id and char_name = @from_char_name  
        if @@rowcount = 0 
        begin 
                update AddedServiceList set serviceFlag = -5001, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -5001, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
                continue 
        end 
        -- character is banned(-5002) 
        set @ban_status = null 
        select @ban_status = status, @ban_date = ban_date, @ban_hour = ban_hour from user_ban where char_id = @from_char_id 
        if isnull(@ban_status, 0) = 2 or (isnull(@ban_status, 0) = 1 and dateadd(hh, @ban_hour, @ban_date) > getdate()) 
        begin 
                update AddedServiceList set serviceFlag = -5002, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -5002, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
                continue 
        end 
        -- character is hero(-5003) 
        if exists (select top 1 * from user_nobless (nolock) where char_id = @from_char_id and hero_type > 0)
        begin 
            update AddedServiceList set serviceFlag = -5003, applyDate = getdate() where idx = @idx 
            set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                    + '' set serviceFlag = -5003, applyDate = getdate()'' 
            exec(@sql) 
            fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
            continue 
        end 
		-- main level is below 75 or upper 80(-5004)
		set @level = 0

		if (@bak_subjob_id = 0)
			begin
				select @level = lev from user_data (nolock) where char_id = @from_char_id
			end
		else
			begin
				select @level = level from user_subjob (nolock) where char_id = @from_char_id and subjob_id = 0
			end
		
		if @level < 75 or 80 < @level
		begin
                update AddedServiceList set serviceFlag = -5004, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -5004, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
                continue 
		end
		-- sub level is below 75(-5005)
		set @level = 0

		if (@bak_subjob_id = @subjob_id)
			begin
				select @level = lev from user_data (nolock) where char_id = @from_char_id
			end
		else
			begin
				select @level = level from user_subjob (nolock) where char_id = @from_char_id and subjob_id = @subjob_id
			end

		if @level < 75
		begin
                update AddedServiceList set serviceFlag = -5005, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -5005, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
                continue 
		end
		-- main class is warsmith(57,118) or overload(51,115)(-5006)
		set @class = -1
		select @class = subjob0_class from user_data (nolock) where char_id = @from_char_id
		if @class in (-1, 57, 118, 51, 115)
		begin
                update AddedServiceList set serviceFlag = -5006, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -5006, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
                continue 
		end
		-- main class has more than 80 items(-5007)
		if (select count(*) from user_item (nolock) where char_id = @from_char_id and warehouse = 0) > 80
		begin
            update AddedServiceList set serviceFlag = -5007, applyDate = getdate() where idx = @idx 
            set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                    + '' set serviceFlag = -5007, applyDate = getdate()'' 
            exec(@sql) 
            fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
            continue 
		end
		-- sub class is hidden class(135,136)(-5008)
		set @class = -1
		if @subjob_id = 1
		begin
			select @class = subjob1_class from user_data (nolock) where char_id = @from_char_id
		end
		else if @subjob_id = 2
		begin
			select @class = subjob2_class from user_data (nolock) where char_id = @from_char_id
		end
		else if @subjob_id = 3
		begin
			select @class = subjob3_class from user_data (nolock) where char_id = @from_char_id
		end
		if @class in (-1, 135, 136)
		begin
                update AddedServiceList set serviceFlag = -5008, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -5008, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
                continue 
		end
		-- if race of subjob is darkelf then no elf allowed in other subjob, if elf then no darkelf(-5009)
		set @counter_race = -1
		select @race = race from class_by_race (nolock) where class = @class
		if @race in (1, 2)
		begin
			if @race = 1
				begin
					set @counter_race = 2
				end
			else
				begin
					set @counter_race = 1
				end
			
			if @counter_race in (select race from class_by_race (nolock) where class in 
					(
						select subjob1_class from user_data (nolock) where char_id = @from_char_id
							union all
						select subjob2_class from user_data (nolock) where char_id = @from_char_id
							union all
						select subjob3_class from user_data (nolock) where char_id = @from_char_id
					)
				)
			begin
				update AddedServiceList set serviceFlag = -5009, applyDate = getdate() where idx = @idx 
				set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
						+ '' set serviceFlag = -5009, applyDate = getdate()'' 
				exec(@sql) 
				fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
				continue 	
			end
		end					
			
		-- ### 조건체크 끝

		-- 체크 통과
		-- shortcut_data / user_skill / user_skill_reuse_delay / user_subjob / user_data / user_henna / user_log
		begin tran
			set @err = 0

			-- 안전빵: 현재 상태 저장
			select @bak_hp = hp, @bak_mp = mp, @bak_sp = sp, @bak_exp = exp, @bak_lev = lev, @bak_subjob_id = subjob_id, @quest = quest_flag from user_data (nolock) where char_id = @from_char_id
			select @henna1 = henna_1, @henna2 = henna_2, @henna3 = henna_3 from user_henna (nolock) where char_id = @from_char_id
			update user_subjob
			set hp = @bak_hp,
				mp = @bak_mp,
				sp = @bak_sp,
				exp = @bak_exp,
				level = @bak_lev,
				henna_1 = @henna1,
				henna_2 = @henna2,
				henna_3 = @henna3
			where char_id = @from_char_id and subjob_id = @bak_subjob_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- delete subjob skill from main class
			delete from user_skill where char_id = @from_char_id and subjob_id = 0 and (skill_id between 631 and 634 or skill_id between 637 and 648 or skill_id between 650 and 662 or skill_id between 799 and 804 or skill_id between 1489 and 1491)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- delete item for subjob skill book
			delete from user_item where char_id = @from_char_id and warehouse in (0,1) and (item_type between 10280 and 10294 or item_type = 10612)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- initiate quest flag for subjob skill (이거 테스트 백만번 해야함!!!)
			-- # of quest for subjob skill :255~266
			set @i = 255

			while @i <= 266
			begin
				set @quest = dbo.SetBitFlag (@quest, @i, 0)
				set @i = @i + 1
			end

			update user_data
			set quest_flag = @quest
			where char_id = @from_char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- initiate brother_chained_to_you quest (422)
			set @i = 1
			while @i <= 26
			begin
				set @sql = ''update quest''
						 + '' set q''+cast(@i as nvarchar)+''=0, s''+cast(@i as nvarchar)+''=0, s2_''+cast(@i as nvarchar)+''=0, j''+cast(@i as nvarchar)+''=0''
						 + '' where char_id=''+cast(@from_char_id as nvarchar)
						 + ''	and q''+cast(@i as nvarchar)+''=422''
				exec (@sql)

				if @@rowcount > 0
				begin
					delete from user_item where char_id = @from_char_id and warehouse in (0,1) and item_type in (4326,4327,4328,4329,4330,4331,4425,4426)
					break
				end

				set @i = @i + 1
			end

			-- ### exchange data
			-- shortcut_data
			update shortcut_data
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @from_char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN
			
			-- user_skill
			update user_skill
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @from_char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_skill_reuse_delay
			update user_skill_reuse_delay
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @from_char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_subjob
			update user_subjob
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @from_char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_data
			select @subjob0_class = subjob0_class, @subjob1_class = subjob1_class, @subjob2_class = subjob2_class, @subjob3_class = subjob3_class 
			from user_data (nolock) where char_id = @from_char_id
			if @subjob0_class = -1
			begin
				set @err = 1
				goto END_TRAN
			end

			if @subjob_id = 1
			begin
				update user_data set subjob0_class = @subjob1_class where char_id = @from_char_id
				update user_data set subjob1_class = @subjob0_class where char_id = @from_char_id
			end
			else if @subjob_id = 2
			begin
				update user_data set subjob0_class = @subjob2_class where char_id = @from_char_id
				update user_data set subjob2_class = @subjob0_class where char_id = @from_char_id
			end
			else if @subjob_id = 3
			begin
				update user_data set subjob0_class = @subjob3_class where char_id = @from_char_id
				update user_data set subjob3_class = @subjob0_class where char_id = @from_char_id
			end
			set @err = @@error
			if @err <> 0	goto END_TRAN

			select @bak_hp = hp, @bak_mp = mp, @bak_sp = sp, @bak_exp = exp, @bak_lev = level, @henna1 = henna_1, @henna2 = henna_2, @henna3 = henna_3 from user_subjob (nolock) where char_id = @from_char_id and subjob_id = @bak_subjob_id
			select @race = race, @gender = sex from class_by_race (nolock) where class = (select subjob0_class from user_data (nolock) where char_id = @from_char_id)


			update user_data
			set race = @race,
				class = case subjob_id when 0 then subjob0_class when 1 then subjob1_class when 2 then subjob2_class when 3 then subjob3_class end,
				gender = case when @gender = -1 then gender & 1 else @gender end,
				face_index = 0,
				hair_shape_index = 0,
				hair_color_index = 0,
				hp = @bak_hp,
				mp = @bak_mp,
				sp = @bak_sp,
				exp = @bak_exp,
				lev = @bak_lev
			where char_id = @from_char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_henna
			update user_henna
			set henna_1 = @henna1,
				henna_2 = @henna2,
				henna_3 = @henna3
			where char_id = @from_char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- olympiad point 초기화
			update user_nobless
			set olympiad_point = 0,
				previous_point = 0
			where char_id = @from_char_id
			set @err = @@error
			if @err <> 0	goto END_TRAN

			-- user_log
			update user_log
			set subjob_id = case subjob_id when 0 then @subjob_id when @subjob_id then 0 end
			where char_id = @from_char_id and subjob_id in (0, @subjob_id)
			set @err = @@error
			if @err <> 0	goto END_TRAN
			

END_TRAN:
			if @err = 0
			begin
				commit tran

                update AddedServiceList set serviceFlag = 1, applyDate = getdate() where idx = @idx 
                exec lin_AddPunishmentHistory @from_char_name, @from_char_id, 105, @to_account_name 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = 1, applyDate = getdate()'' 
                exec(@sql) 
			end
			else
			begin
				rollback tran

                update AddedServiceList set serviceFlag = -1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
			end
		-- transaction 끝

        fetch next from change_sub_cursor into @idx, @from_account_id, @from_char_name, @subjob_id
end 
 
close change_sub_cursor 
deallocate change_sub_cursor

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService2ChangeSex]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService2ChangeSex 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService2ChangeSex ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated from ''lin_ApplyAddedService'' by neo
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService2ChangeSex] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 
declare 
        @sql				nvarchar(4000),
        @from_server		int,
        @to_server			int,
        @from_char_id		int, 
        @to_char_id			int, 
        @to_account_name	nvarchar(24), 
        @idx				int, 
        @from_account_id	int, 
        @to_account_id		int, 
        @char_count			int, 
        @from_char_name		nvarchar(24), 
        @to_char_name		nvarchar(24), 
        @class				int,
        @gender				int, 
        @old_gender			int, 
        @old_face_index		int, 
        @old_hair_shape_index	int, 
        @old_hair_color_index	int, 
        @ban_status				int, 
        @ban_date				datetime, 
        @ban_hour				int, 
        @pledge_id				int, 
        @level					int, 
        @original_pk			int,
        @cursed_weapon			int,
        @char_id				int,
        @db_info				nvarchar(64),
        @subjob_id				int,
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				int,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int
		

-- ServiceType == 2     // 성별전환 
declare sex_cursor cursor for 
select idx, fromUid, fromCharacter, changeGender from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 2 and fromServer = @server_id 
 
open sex_cursor 
fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
 
while @@fetch_status = 0 
begin 
        -- character is not existed(-2001) 
        select @from_char_id = char_id, @to_account_name = account_name, @old_gender = gender, @old_face_index = face_index, @old_hair_shape_index = hair_shape_index, @old_hair_color_index = hair_color_index, @class = class 
        from user_data (nolock) where account_id = @from_account_id and char_name = @from_char_name  
        if @@rowcount = 0 
        begin 
                update AddedServiceList set serviceFlag = -2001, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -2001, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
                continue 
        end 
        -- character is banned(-2002) 
        set @ban_status = null 
        select @ban_status = status, @ban_date = ban_date, @ban_hour = ban_hour from user_ban where char_id = @from_char_id 
        if isnull(@ban_status, 0) = 2 or (isnull(@ban_status, 0) = 1 and dateadd(hh, @ban_hour, @ban_date) > getdate()) 
        begin 
                update AddedServiceList set serviceFlag = -2002, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -2002, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
                continue 
        end 
        -- parameter is out of bound (-2003) 
        if @gender is null or @gender < 0 or @gender > 1 
        begin 
                update AddedServiceList set serviceFlag = -2003, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -2003, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
                continue 
        end 
        -- parameter is not valid (-2004) 
        if @old_gender ^ 1 <> @gender 
        begin 
                update AddedServiceList set serviceFlag = -2004, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -2004, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
                continue 
        end 
        -- kamael is not allowed to change gender (-2005) 
        if @class >= 123 and @class <= 136
        begin 
                update AddedServiceList set serviceFlag = -2005, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -2005, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
                continue 
        end 

 
        update user_data set gender = @gender, face_index = 0, hair_shape_index = 0, hair_color_index = 0 where account_id = @from_account_id and char_id = @from_char_id 
        -- success to serve (1) 
        if @@rowcount > 0 
        begin 
                update AddedServiceList set serviceFlag = 1, applyDate = getdate(), 
                        reserve2 = cast(@old_face_index as varchar) + cast(@old_hair_shape_index as varchar) + cast(@old_hair_color_index as varchar) 
                where idx = @idx 
                exec lin_AddPunishmentHistory @from_char_name, @from_char_id, 102, @to_account_name 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = 1, applyDate = getdate()'' 
                exec(@sql) 
        end 
        -- fail to serve (-1) 
        else 
        begin 
                update AddedServiceList set serviceFlag = -1, applyDate = getdate(), 
                        reserve2 = cast(@old_face_index as varchar) + cast(@old_hair_shape_index as varchar) + cast(@old_hair_color_index as varchar) 
                where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
        end 
 
        fetch next from sex_cursor into @idx, @from_account_id, @from_char_name, @gender 
end 
 
close sex_cursor 
deallocate sex_cursor

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService1ChangeAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService1ChangeAccount 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService1ChangeAccount ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated from ''lin_ApplyAddedService'' by neo
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService1ChangeAccount] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 
declare 
        @sql				nvarchar(4000),
        @from_server		int,
        @to_server			int,
        @from_char_id		int, 
        @to_char_id			int, 
        @to_account_name	nvarchar(24), 
        @idx				int, 
        @from_account_id	int, 
        @to_account_id		int, 
        @char_count			int, 
        @from_char_name		nvarchar(24), 
        @to_char_name		nvarchar(24), 
        @class				int,
        @gender				int, 
        @old_gender			int, 
        @old_face_index		int, 
        @old_hair_shape_index	int, 
        @old_hair_color_index	int, 
        @ban_status				int, 
        @ban_date				datetime, 
        @ban_hour				int, 
        @pledge_id				int, 
        @level					int, 
        @original_pk			int,
        @cursed_weapon			int,
        @char_id				int,
        @db_info				nvarchar(64),
        @subjob_id				int,
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				int,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int
		

 
 
-- ServiceType == 1     // 계정이전 
declare account_cursor cursor for 
select idx, fromUid, toUid, toAccount, fromCharacter from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 1 and fromServer = @server_id 
 
open account_cursor 
fetch next from account_cursor into @idx, @from_account_id, @to_account_id, @to_account_name, @from_char_name 
 
while @@fetch_status = 0 
begin 
        -- character is not existed(-1001) 
        select @from_char_id = char_id from user_data (nolock) where account_id = @from_account_id and char_name = @from_char_name 
        if @@rowcount = 0 
        begin 
                update AddedServiceList set serviceFlag = -1001, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1001, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from account_cursor into @idx, @from_account_id, @to_account_id, @to_account_name, @from_char_name 
                continue 
        end 
        -- character is banned(-1002) 
        set @ban_status = null 
        select @ban_status = status, @ban_date = ban_date, @ban_hour = ban_hour from user_ban where char_id = @from_char_id 
        if isnull(@ban_status, 0) = 2 or (isnull(@ban_status, 0) = 1 and dateadd(hh, @ban_hour, @ban_date) > getdate()) 
        begin 
                update AddedServiceList set serviceFlag = -1002, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1002, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from account_cursor into @idx, @from_account_id, @to_account_id, @to_account_name, @from_char_name 
                continue 
        end 
        -- target account has 7 characters(-1003) 
        set @char_count = 0 
        select @char_count = count(*) from user_data (nolock)  
        where account_id = @to_account_id  
                and ((temp_delete_date is null) or (temp_delete_date is not null and datediff(mi, temp_delete_date, getdate()) < (7*24*60))) 
        if @char_count >= 7 
        begin 
                update AddedServiceList set serviceFlag = -1003, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1003, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from account_cursor into @idx, @from_account_id, @to_account_id, @to_account_name, @from_char_name 
                continue 
        end 
 
        update user_data set account_id = @to_account_id, account_name = @to_account_name where account_id = @from_account_id and char_id = @from_char_id 
        --update user_data set account_id = @to_account_id, account_name = @to_account_name, old_account_id = @from_account_id where account_id = @from_account_id and char_id = @from_char_id 
        -- success to serve (1) 

        if @@rowcount > 0 
        begin 
				--기간제 아이템 삭제 --CT2 Part2
				delete user_item where item_id in
				(	
					select item_id 
					from user_item(nolock) inner join ItemData(nolock) on user_item.item_type = ItemData.item_type
					where char_id = @from_char_id and warehouse in (0,1) and ItemData.is_period = 1 
				)

                update AddedServiceList set serviceFlag = 1, applyDate = getdate() where idx = @idx 
                exec lin_AddPunishmentHistory @from_char_name, @from_char_id, 101, @to_account_name 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_comm+'','' 
                        + ''     ''''select * from lin2comm.dbo.user_memo'' 
                        + ''     where world_id=''+cast(@server_id as varchar) 
                        + ''             and account_id=''+cast(@from_account_id as varchar) 
                        + ''             and char_id=''+cast(@from_char_id as varchar)+'''''')'' 
                        + '' set account_id=''+cast(@to_account_id as varchar)+'', account_name=''''''+@to_account_name+'''''''' 
                exec(@sql) 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = 1, applyDate = getdate()'' 
                exec(@sql) 
        end 
        -- fail to serve (-1) 
        else 
        begin 
                update AddedServiceList set serviceFlag = -1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
        end 
 
        fetch next from account_cursor into @idx, @from_account_id, @to_account_id, @to_account_name, @from_char_name 
end 
 
close account_cursor 
deallocate account_cursor

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_CancelAddedService]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/**
name:	lin_CancelAddedService
desc:	apply added service to each character
exam:	exec lin_CancelAddedService

history:	2006-08-29	created by btwinuni
*/
create procedure [dbo].[lin_CancelAddedService]
as

set nocount on

declare
	@char_id	int,
	@account_name	nvarchar(24),
	@idx		int,
	@from_account	int,
	@to_account	int,
	@char_count	int,
	@char_name	nvarchar(24),
	@gender	int,
	@old_gender	int

-- ServiceType == 1	// 계정이전
declare account_cursor cursor for
select idx, fromUid, toUid, fromAccount, fromCharacter from AddedServiceList (nolock) where idx in (select idx from CancelServiceList) and serviceFlag = 1 and serviceType = 1

open account_cursor
fetch next from account_cursor into @idx, @from_account, @to_account, @account_name, @char_name

while @@fetch_status = 0
begin
	update user_data set account_id = @from_account, account_name = @account_name where account_id = @to_account and char_name = @char_name
	-- success to serve (1)
	if @@rowcount > 0
	begin
		update CancelServiceList set serviceFlag = 1, applyDate = getdate() where idx = @idx
		exec lin_AddPunishmentHistory @char_name, @char_id, 111, @account_name		-- 111는 계정이전 부가서비스 취소
	end
	-- fail to serve (-1)
	else
		update CancelServiceList set serviceFlag = -1, applyDate = getdate() where idx = @idx

	fetch next from account_cursor into @idx, @from_account, @to_account, @account_name, @char_name
end

close account_cursor
deallocate account_cursor


-- ServiceType == 2	// 성별전환
declare sex_cursor cursor for
select idx, fromCharacter, changeGender from AddedServiceList (nolock) where idx in (select idx from CancelServiceList) and serviceFlag = 1 and serviceType = 2

open sex_cursor
fetch next from sex_cursor into @idx, @char_name, @gender

while @@fetch_status = 0
begin
	set @gender = @gender ^ 1
	update user_data set gender = @gender where char_name = @char_name

	-- success to serve (1)
	if @@rowcount > 0
	begin
		update CancelServiceList set serviceFlag = 1, applyDate = getdate() where Idx = @idx
		exec lin_AddPunishmentHistory @char_name, @char_id, 112, @account_name
	end
	-- fail to serve (-1)
	else
		update CancelServiceList set serviceFlag = -1, applyDate = getdate() where Idx = @idx

	fetch next from sex_cursor into @idx, @char_name, @gender
end

close sex_cursor
deallocate sex_cursor

set nocount off

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_DeleteNotOwnedItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************  
lin_DeleteNotOwnedItem  
   
INPUT  
OUTPUT  
  
return  
made by  
 carrot  
date  
 2003-10-12  
********************************************/  
CREATE PROCEDURE [dbo].[lin_DeleteNotOwnedItem]  
AS  
SET NOCOUNT ON  
  
DELETE user_item WHERE char_id =  0 OR item_type = 0  
  
DECLARE @ToDeleteCharacter CURSOR  
DECLARE @char_id INT  
SET @ToDeleteCharacter = CURSOR FAST_FORWARD FOR  
 SELECT char_id  
 FROM user_data  
 WHERE account_id > 0 AND temp_delete_date IS NOT NULL AND DATEDIFF ( mi , temp_delete_date , GETDATE())  >= (7 * 24 * 60)
OPEN @ToDeleteCharacter  
FETCH FROM @ToDeleteCharacter INTO @char_id  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
 EXEC lin_deleteChar @char_id  
 FETCH NEXT FROM @ToDeleteCharacter INTO @char_id  
END  
  
CLOSE @ToDeleteCharacter   
DEALLOCATE @ToDeleteCharacter  

exec dbo.lin_CleanUpGhostData

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService6ChangeServerEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService6ChangeServerEvent 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService6ChangeServerEvent ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated from ''lin_ApplyAddedService'' by neo
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService6ChangeServerEvent] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 
declare 
        @sql				nvarchar(4000),
        @from_server		int,
        @to_server			int,
        @from_char_id		int, 
        @to_char_id			int, 
        @to_account_name	nvarchar(24), 
        @idx				int, 
        @from_account_id	int, 
        @to_account_id		int, 
        @char_count			int, 
        @from_char_name		nvarchar(24), 
        @to_char_name		nvarchar(24), 
        @class				int,
        @gender				int, 
        @old_gender			int, 
        @old_face_index		int, 
        @old_hair_shape_index	int, 
        @old_hair_color_index	int, 
        @ban_status				int, 
        @ban_date				datetime, 
        @ban_hour				int, 
        @pledge_id				int, 
        @level					int, 
        @original_pk			int,
        @cursed_weapon			int,
        @char_id				int,
        @db_info				nvarchar(64),
        @subjob_id				int,
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				int,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int
		




-- ServiceType == 6     // 서버 이전 서비스: 타 서버, 동일 계정으로 캐릭터 이동 

-- //각 월드 DB접속정보 테이블 확인 -> from 서버가 무조건 99번
if not exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[tmp_db_connections]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) 
begin
        RAISERROR(''No Connection Info!! Table [dbo].[tmp_db_connections] does not exist'',1,1)
        return
end

declare server_cursor cursor for 
select idx, fromUid, fromAccount, fromServer, fromCharacter, toCharacter, toServer from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 6 and toServer = @server_id 
 
open server_cursor 
fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server

while @@fetch_status = 0 
begin
        -- not allowed server (-6001)
        if (@to_server = 7)
        begin 
                update AddedServiceList set serviceFlag = -6001, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -6001, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 

        
        -- invalid source character
        create table #tmp_validator (
                char_id		int,
                class		int,
                level		int,
                pledge_id	int,
                hero_type	int,
                ban_status        int,
                ban_date        datetime,
                ban_hour        int
        )

		-- 체험서버(99)
		set @from_server = 99
        --@from_server별 db connection info를 가져온다
        select @db_info = db_info from [dbo].[tmp_db_connections] where server_id = @from_server
        if @@error <> 0 or @db_info is NULL
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -6101, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -6101, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue         
        end        
		
        set @sql = ''insert into #tmp_validator(char_id, class, level, pledge_id, hero_type, ban_status, ban_date, ban_hour)''
                + '' select * from openrowset(''''sqloledb'''', ''+@db_info+'', ''
                + '' 	''''select T1.char_id, T1.class, T1.lev, T1.pledge_id, isnull(T2.hero_type, 0), isnull(T3.status, 0), isnull(T3.ban_date, 0), isnull(T3.ban_hour, 0) ''
                + ''	from lin2world_99.dbo.user_data T1(nolock) left join lin2world_99.dbo.user_nobless T2(nolock) on T1.char_id = T2.char_id''
                + ''	        left join lin2world_99.dbo.user_ban T3(nolock) on T1.char_id = T3.char_id''
                + '' 	where account_id = ''+cast(@to_account_id as varchar)
                + ''		and char_name = ''''''''''+@from_char_name+'''''''''''''')''
        exec (@sql)
        if @@error <> 0
        begin
                update AddedServiceList set serviceFlag = -6102, applyDate = getdate() where idx = @idx                 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end

        -- source character is not existed (-6002)
        if (select count(*) from #tmp_validator) = 0
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -6002, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -6002, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end

        -- character in fromserver is banned(-6003) 
        set @ban_status = null 
        select @ban_status = ban_status, @ban_date = ban_date, @ban_hour = ban_hour from #tmp_validator
        if isnull(@ban_status, 0) = 2 or (isnull(@ban_status, 0) = 1 and dateadd(hh, @ban_hour, @ban_date) > getdate()) 
        begin 
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -6003, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4003, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 


        -- level (-6004)
        if exists (select * from #tmp_validator where level < 20)
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -6004, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -6004, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue         
        end


        select @from_char_id = char_id from #tmp_validator

        drop table #tmp_validator



        -- do migrate !!!!
        --exec @to_char_id = lin_MoveCharAddedServiceEvent @db_info, @from_char_id, @from_char_name, @to_char_name
		exec @to_char_id = lin_MoveCharAddedServiceEvent @db_info, @from_char_id, @from_char_name, @from_char_name
        if @to_char_id > 0	-- success
        begin
                update AddedServiceList set serviceFlag = 1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_info+'', ''''select * from lin2world_99.dbo.user_data where char_id=''+cast(@from_char_id as varchar)+'''''')''
                        + '' set account_id = -3''
                exec (@sql)

                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')''
                        + '' set serviceFlag = 1, applyDate = getdate()''
                exec (@sql)
                exec lin_AddPunishmentHistory @to_char_name, @to_char_id, 104, @to_account_id

                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_comm+'','' 
                        + ''     ''''select * from lin2comm.dbo.user_memo'' 
                        + ''        where world_id=''+cast(@from_server as varchar) 
                        + ''                and account_id=''+cast(@from_account_id as varchar) 
                        + ''                and char_id=''+cast(@from_char_id as varchar)+'''''')'' 
                        + ''                set world_id=''+cast(@server_id as varchar)+'', account_name=''''''+@to_account_name+'''''''' 
                exec(@sql) 
        end
        else
        begin
                update AddedServiceList set serviceFlag = -1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
        end
 
        fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
end 

if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[tmp_db_connections]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) 
begin
        drop table[dbo]. tmp_db_connections
end

close server_cursor 
deallocate server_cursor

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService4ChangeServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService4ChangeServer 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService4ChangeServer ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated from ''lin_ApplyAddedService'' by neo
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService4ChangeServer] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 
declare 
        @sql				nvarchar(4000),
        @from_server		int,
        @to_server			int,
        @from_char_id		int, 
        @to_char_id			int, 
        @to_account_name	nvarchar(24), 
        @idx				int, 
        @from_account_id	int, 
        @to_account_id		int, 
        @char_count			int, 
        @from_char_name		nvarchar(24), 
        @to_char_name		nvarchar(24), 
        @class				int,
        @gender				int, 
        @old_gender			int, 
        @old_face_index		int, 
        @old_hair_shape_index	int, 
        @old_hair_color_index	int, 
        @ban_status				int, 
        @ban_date				datetime, 
        @ban_hour				int, 
        @pledge_id				int, 
        @level					int, 
        @original_pk			int,
        @cursed_weapon			int,
        @char_id				int,
        @db_info				nvarchar(64),
        @subjob_id				int,
        @err					int,
        @race					int,
        @bak_hp					int,
        @bak_mp					int,
        @bak_sp					int,
        @bak_exp				int,
        @bak_lev				int,
        @bak_subjob_id			int,
        @henna1					int,
        @henna2					int,
        @henna3					int,
        @quest					binary(128),
        @i						int
		




-- ServiceType == 4     // 서버 이전 서비스: 타 서버, 동일 계정으로 캐릭터 이동 

-- //각 월드 DB접속정보 테이블 확인
if not exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[tmp_db_connections]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) 
begin
        RAISERROR(''No Connection Info!! Table [dbo].[tmp_db_connections] does not exist'',1,1)
        return
end

declare server_cursor cursor for 
select idx, fromUid, fromAccount, fromServer, fromCharacter, toCharacter, toServer from AddedServiceList (nolock) where serviceFlag = 0 and serviceType = 4 and toServer = @server_id 
 
open server_cursor 
fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server

while @@fetch_status = 0 
begin
        -- not allowed server (-4012)
        if (@to_server = 7 or @to_server = 35)        --//temp code
        begin 
                update AddedServiceList set serviceFlag = -4012, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4012, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 

        -- target character is not existed (-4001)
        select @to_char_id = char_id, @level = lev from user_data (nolock) where account_id = @to_account_id and char_name = @to_char_name
        if @@rowcount = 0
        begin 
                update AddedServiceList set serviceFlag = -4001, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4001, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 

        -- invalid target character (-4005)
        if @level <> 1
        begin 
                update AddedServiceList set serviceFlag = -4005, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4005, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 

        -- invalid source character
        create table #tmp_validator (
                char_id		int,
                class		int,
                level		int,
                pledge_id	int,
                hero_type	int,
                ban_status        int,
                ban_date        datetime,
                ban_hour        int
        )

        --@from_server별 db connection info를 가져온다
        select @db_info = db_info from [dbo].[tmp_db_connections] where server_id = @from_server
        if @@error <> 0 or @db_info is NULL
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4010, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue         
        end        

        set @sql = ''insert into #tmp_validator(char_id, class, level, pledge_id, hero_type, ban_status, ban_date, ban_hour)''
                + '' select * from openrowset(''''sqloledb'''', ''+@db_info+'', ''
                + '' 	''''select T1.char_id, T1.class, T1.lev, T1.pledge_id, isnull(T2.hero_type, 0), isnull(T3.status, 0), isnull(T3.ban_date, 0), isnull(T3.ban_hour, 0) ''
                + ''	from lin2world.dbo.user_data T1(nolock) left join lin2world.dbo.user_nobless T2(nolock) on T1.char_id = T2.char_id''
                + ''	        left join lin2world.dbo.user_ban T3(nolock) on T1.char_id = T3.char_id''
                + '' 	where account_id = ''+cast(@to_account_id as varchar)
                + ''		and char_name = ''''''''''+@from_char_name+'''''''''''''')''
        exec (@sql)
        if @@error <> 0
        begin
                update AddedServiceList set serviceFlag = -4011, applyDate = getdate() where idx = @idx                 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end

        -- source character is not existed (-4002)
        if (select count(*) from #tmp_validator) = 0
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4002, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4002, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end

        -- character in fromserver is banned(-4003) 
        set @ban_status = null 
        select @ban_status = ban_status, @ban_date = ban_date, @ban_hour = ban_hour from #tmp_validator
        if isnull(@ban_status, 0) = 2 or (isnull(@ban_status, 0) = 1 and dateadd(hh, @ban_hour, @ban_date) > getdate()) 
        begin 
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4003, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4003, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 


        -- class (-4006)
        if exists (select * from #tmp_validator where class in (0, 10, 18, 25, 31, 38, 44, 49, 53, 1, 4, 7, 11, 15, 19, 22, 26, 29, 32, 35, 39, 42, 45, 47, 50, 54, 56, 123, 124, 125, 126))	-- 2차전직 전 class
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4006, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4006, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue 
        end 


        -- level (-4007)
        if exists (select * from #tmp_validator where level < 40)
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4007, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4007, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue         
        end


        -- pledge (-4008)
        if exists (select * from #tmp_validator where pledge_id > 0)
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4008, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4008, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue         
        end


        -- hero (-4009)
        if exists (select * from #tmp_validator where hero_type > 0)
        begin
                drop table #tmp_validator
                update AddedServiceList set serviceFlag = -4009, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                        + '' set serviceFlag = -4009, applyDate = getdate()'' 
                exec(@sql) 
                fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
                continue         
        end



        select @from_char_id = char_id from #tmp_validator

        drop table #tmp_validator



        -- do migrate !!!!
        exec lin_DeleteChar @to_char_id	-- 이주를 위해 만든 1랩 캐릭터 우선 삭제
        exec @to_char_id = lin_MoveCharAddedService @db_info, @from_char_id, @from_char_name, @to_char_name
        if @to_char_id > 0	-- success
        begin
                update AddedServiceList set serviceFlag = 1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_info+'', ''''select * from lin2world.dbo.user_data where char_id=''+cast(@from_char_id as varchar)+'''''')''
                        + '' set account_id = -3''
                exec (@sql)

                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')''
                        + '' set serviceFlag = 1, applyDate = getdate()''
                exec (@sql)
                exec lin_AddPunishmentHistory @to_char_name, @to_char_id, 104, @to_account_id

                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_comm+'','' 
                        + ''     ''''select * from lin2comm.dbo.user_memo'' 
                        + ''        where world_id=''+cast(@from_server as varchar) 
                        + ''                and account_id=''+cast(@from_account_id as varchar) 
                        + ''                and char_id=''+cast(@from_char_id as varchar)+'''''')'' 
                        + ''                set world_id=''+cast(@server_id as varchar)+'', account_name=''''''+@to_account_name+'''''''' 
                exec(@sql) 
        end
        else
        begin
                update AddedServiceList set serviceFlag = -1, applyDate = getdate() where idx = @idx 
                set @sql = ''update openrowset(''''sqloledb'''', ''+@db_event+'', ''''select * from L2EventDB.dbo.L2AddedService where idx=''+cast(@idx as varchar)+'''''')'' 
                + '' set serviceFlag = -1, applyDate = getdate()'' 
                exec(@sql) 
        end
 
        fetch next from server_cursor into @idx, @to_account_id,  @to_account_name, @from_server, @from_char_name, @to_char_name, @to_server
end 

/* 체험서버 캐릭터 이전에서 사용함
if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[tmp_db_connections]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) 
begin
        drop table[dbo]. tmp_db_connections
end
*/

close server_cursor 
deallocate server_cursor

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_SendMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_SendMail
	send mail 
INPUT
	@char_id		int,
	@mail_type		int,
	@related_id		int,
	@receiverName		nvarchar(50),
	@title			nvarchar(200),
	@content		nvarchar(4000)
OUTPUT
return
made by
	kks
date
	2004-12-15
modified by
	kks
date
	2005-04-26
********************************************/
CREATE PROCEDURE [dbo].[lin_SendMail]
(
	@char_id		int,
	@mail_type		int,
	@related_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
)
AS
SET NOCOUNT ON

DECLARE @mail_id int
SET @mail_id = 0

INSERT INTO user_mail
(title, content) VALUES (@title, @content)

SET @mail_id = @@IDENTITY

DECLARE @sender_name nvarchar(50)
DECLARE @char_name NVARCHAR(50)

SELECT @sender_name = char_name FROM user_data(nolock) WHERE char_id = @char_id

INSERT INTO user_mail_sender
(mail_id, related_id, mail_type, sender_id, sender_name, receiver_name_list)
VALUES
(@mail_id, @related_id, @mail_type, @char_id, @sender_name, @receiver_name_list)

if @mail_type = 1
BEGIN
	DECLARE name_cursor CURSOR FOR
	(SELECT char_name FROM user_data(nolock) WHERE pledge_id = (SELECT pledge_id FROM pledge(nolock) WHERE name = @receiver_name_list))
	OPEN name_cursor
	FETCH NEXT FROM name_cursor into @char_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC lin_SendMailToReceiver @mail_id, @char_name
		FETCH NEXT FROM name_cursor into @char_name
	END

	CLOSE name_cursor
	DEALLOCATE name_cursor
END
ELSE
BEGIN
--	DECLARE @receiver_name_list_replaced nvarchar(300)
--	SELECT @receiver_name_list_replaced = REPLACE(@receiver_name_list,'';'', '' ; '')
	
--	DECLARE @receiver_name1 nvarchar (50), @receiver_name2 nvarchar (50), @receiver_name3 nvarchar (50), @receiver_name4 nvarchar (50), @receiver_name5 nvarchar (50)
--	EXEC master..xp_sscanf @receiver_name_list_replaced, ''%s ; %s ; %s ; %s ; %s '',
--	   @receiver_name1 OUTPUT, @receiver_name2 OUTPUT, @receiver_name3 OUTPUT, @receiver_name4 OUTPUT, @receiver_name5 OUTPUT
	
--	EXEC lin_SendMailToReceiver @mail_id, @receiver_name1
--	EXEC lin_SendMailToReceiver @mail_id, @receiver_name2
--	EXEC lin_SendMailToReceiver @mail_id, @receiver_name3
--	EXEC lin_SendMailToReceiver @mail_id, @receiver_name4
--	EXEC lin_SendMailToReceiver @mail_id, @receiver_name5
	
	DECLARE @pos int

	set @pos = charindex('';'', @receiver_name_list)
	while (@pos > 0)
	begin
		SET @char_name = substring(@receiver_name_list, 0, @pos)
		EXEC lin_SendMailToReceiver @mail_id, @char_name

		set @receiver_name_list = substring(@receiver_name_list, @pos+1, len(@receiver_name_list)-@pos+1)
		set @pos = charindex('';'', @receiver_name_list)
	end
END

' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ModifySendTempMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/********************************************
lin_ModifySendTempMail
	modify and send temp mail 
INPUT
	@char_id		int,
	@mail_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
OUTPUT
return
made by
	kks
date
	2004-12-19
********************************************/
CREATE PROCEDURE [dbo].[lin_ModifySendTempMail]
(
	@char_id		int,
	@mail_id		int,
	@receiver_name_list		nvarchar(250),
	@title			nvarchar(200),
	@content		nvarchar(4000)
)
AS
SET NOCOUNT ON

UPDATE user_mail
SET title = @title,
	content = @content,
	created_date = GETDATE()
WHERE id = @mail_id

UPDATE user_mail_sender
SET receiver_name_list = @receiver_name_list,
	send_date = GETDATE(),
	mailbox_type = 1
WHERE 
	mail_id = @mail_id AND 
	sender_id = @char_id

DECLARE @mail_type INT
SELECT @mail_type = mail_type FROM user_mail_sender(nolock) WHERE mail_id = @mail_id

if @mail_type = 1
BEGIN
	DECLARE @char_name NVARCHAR(50)
	DECLARE name_cursor CURSOR FOR
	(SELECT char_name FROM user_data(nolock) WHERE pledge_id = (SELECT pledge_id FROM pledge(nolock) WHERE name = @receiver_name_list))
	OPEN name_cursor
	FETCH NEXT FROM name_cursor into @char_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC lin_SendMailToReceiver @mail_id, @char_name
	END

	CLOSE name_cursor
	DEALLOCATE name_cursor
END
ELSE
BEGIN
	DECLARE @receiver_name_list_replaced nvarchar(300)
	SELECT @receiver_name_list_replaced = REPLACE(@receiver_name_list,'';'', '' ; '')
	
	DECLARE @receiver_name1 nvarchar (50), @receiver_name2 nvarchar (50), @receiver_name3 nvarchar (50), @receiver_name4 nvarchar (50), @receiver_name5 nvarchar (50)
	EXEC master..xp_sscanf @receiver_name_list_replaced, ''%s ; %s ; %s ; %s ; %s'',
	   @receiver_name1 OUTPUT, @receiver_name2 OUTPUT, @receiver_name3 OUTPUT, @receiver_name4 OUTPUT, @receiver_name5 OUTPUT
	
	EXEC lin_SendMailToReceiver @mail_id, @receiver_name1
	EXEC lin_SendMailToReceiver @mail_id, @receiver_name2
	EXEC lin_SendMailToReceiver @mail_id, @receiver_name3
	EXEC lin_SendMailToReceiver @mail_id, @receiver_name4
	EXEC lin_SendMailToReceiver @mail_id, @receiver_name5
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lin_ApplyAddedService]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/** 
name:   lin_ApplyAddedService 
desc:   apply added service to each character 
exam:   exec lin_ApplyAddedService ''''''server'''';''''login_id'''';''''password'''''', ''''''server'''';''''login_id'''';''''password'''''', 1 
 
history:        2006-08-29      created by btwinuni 
        2006-12-13      add 3rd service type and modify how to notify to L2EventDB 
        2007-01-23      add 4rd service type by neo
        2007-07-23      modified as CT1 version by neo
        2008-01-10      seperated into 5 sp by service type by neo		
*/ 
CREATE procedure [dbo].[lin_ApplyAddedService] 
        @db_event       nvarchar(64),   -- to L2EventDB 
        @db_comm        nvarchar(64),   -- to lin2comm 
        @server_id      int             -- this server 
as 
 
set nocount on 
 

-- 1. ServiceType == 5     // 메인, 서브 직업 변경
exec lin_ApplyAddedService5MainSubJobExchange @db_event, @db_comm, @server_id

-- 2. ServiceType == 2     // 성별전환 
exec lin_ApplyAddedService2ChangeSex @db_event, @db_comm, @server_id

-- 3. ServiceType == 1     // 계정이전 
exec lin_ApplyAddedService1ChangeAccount @db_event, @db_comm, @server_id

-- 4. ServiceType == 3     // 이름변경
exec lin_ApplyAddedService3ChangeName @db_event, @db_comm, @server_id

-- 5. ServiceType == 4     // 서버 이전 서비스: 타 서버, 동일 계정으로 캐릭터 이동 
exec lin_ApplyAddedService4ChangeServer @db_event, @db_comm, @server_id

-- 6. ServiceType == 6     // 서버 이전 서비스: 타 서버, 동일 계정으로 캐릭터 이동(체험서버)
exec lin_ApplyAddedService6ChangeServerEvent @db_event, @db_comm, @server_id

' 
END
