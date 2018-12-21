
¨
base/scene.protobase"e
PosInfo	
v (	
x (	
y (	
z (
face_x (
face_y (
face_z ("^
	PlayerAoi#
block (2.base.PlayerAoiBlock
pos_info (2.base.PosInfo
pid ("
PlayerAoiBlock
mask ("Z
Desc
scale (
color (
mutateTexture (
weapon (
adorn ("±
NpcAoi 
block (2.base.NpcAoiBlock
pos_info (2.base.PosInfo
npctype (
npcid (
name (	
title (	
model (
desc (2
.base.Desc"
NpcAoiBlock
mask (
é
base/war.protobase"M
PlayerWarriorStatus

hp (

mp (
max_hp (
max_mp ("a
PlayerWarrior
wid (
pid (
pos ()
status (2.base.PlayerWarriorStatus"D
WarCamp
camp_id ((
player_list (2.base.PlayerWarrior
¬
base/role.protobase"

SimpleRole
pid ("ç
Role
account (	
pid (
grade (
name (	
shape (
goldcoin (
gold (
silver (
exp	 (
h
client/login.proto"#
C2GSLoginAccount
account (	"-
C2GSLoginRole
account (	
pid (
π
client/scene.protobase/scene.proto"M
C2GSSyncPos
scene_id (
eid (
pos_info (2.base.PosInfo"B
C2GSTransfer
scene_id (
eid (
transfer_id (
b
client/npc.proto"
C2GSClickNpc
npcid ("/
C2GSNpcRespond
npcid (
answer (
Ù
client/war.proto"\
C2GSWarSkill
war_id (
action_wlist (
select_wlist (
skill_id ("M
C2GSWarNormalAttack
war_id (

action_wid (

select_wid ("H
C2GSWarProtect
war_id (

action_wid (

select_wid ("3
C2GSWarEscape
war_id (

action_wid ("4
C2GSWarDefense
war_id (

action_wid (
c
client/other.proto"
C2GSHeartBeat"
	C2GSGMCmd
cmd (	""
C2GSCallback

sessionidx (
®
client/item.proto"-
C2GSItemUse
itemid (
target ("
C2GSItemInfo
itemid ("+
C2GSItemMove
itemid (
pos ("
C2GSItemArrage"%
C2GSAddItemExtendSize
size ("/
C2GSDeComposeItem

id (
amount ("-
C2GSComposeItem

id (
amount (
d
client/task.proto"
C2GSClickTask
taskid (".
C2GSTaskEvent
taskid (
npcid (

client/player.proto
Â
server/login.protobase/role.proto"
	GS2CHello
time (".
GS2CLoginError
pid (
errcode ("H
GS2CLoginAccount
account (	#
	role_list (2.base.SimpleRole")
GS2CLoginRole
role (2
.base.Role
ò
server/scene.protobase/scene.proto"E
GS2CShowScene
scene_id (
map_id (

scene_name (	"P
GS2CEnterScene
scene_id (
eid (
pos_info (2.base.PosInfo"
GS2CEnterAoi
scene_id (
eid (
type (#

aoi_player (2.base.PlayerAoi
aoi_npc (2.base.NpcAoi"-
GS2CLeaveAoi
scene_id (
eid ("X
GS2CSyncAoi
scene_id (
eid (*
block_player (2.base.PlayerAoiBlock"M
GS2CSyncPos
scene_id (
eid (
pos_info (2.base.PosInfo
Z
server/npc.proto"F

GS2CNpcSay
npcid (
model (
name (	
text (	
∑
server/war.protobase/war.proto"
GS2CShowWar
war_id ("0
GS2CWarResult
war_id (
bout_id ("F
GS2CWarBoutStart
war_id (
bout_id (
	left_time (" 
GS2CWarBoutEnd
war_id ("h
GS2CWarAddWarrior
war_id (
camp_id (
type ($
warrior (2.base.PlayerWarrior"0
GS2CWarDelWarrior
war_id (
wid ("M
GS2CWarNormalAttack
war_id (

action_wid (

select_wid ("n
GS2CWarSkill
war_id (
action_wlist (
select_wlist (
skill_id (
magic_id ("H
GS2CWarProtect
war_id (

action_wid (

select_wid ("D
GS2CWarEscape
war_id (

action_wid (
success ("J
GS2CWarDamage
war_id (
wid (
type (
damage ("l
GS2CWarWarriorStatus
war_id (
wid (
type ()
status (2.base.PlayerWarriorStatus"3
GS2CWarGoback
war_id (

action_wid (
Q
server/other.proto"
GS2CHeartBeat
time ("
GS2CGMMessage
msg (	
ë
server/item.proto"'
	applyinfo
key (	
value ("™
iteminfo

id (
sid (
name (	
pos (
	itemlevel (
amount (
time (
key (

apply_info	 (2
.applyinfo
desc
 (	"=
GS2CLoginItem
itemdata (2	.iteminfo
extsize ("*
GS2CAddItem
itemdata (2	.iteminfo"
GS2CDelItem

id ("+
GS2CMoveItem

id (
destpos (",
GS2CItemAmount

id (
amount ("
GS2CItemQuickUse

id ("%
GS2CItemExtendSize
extsize (
¥
server/task.protobase/scene.proto"*
NeedItem
itemid (
amount ("(
NeedSum
sumid (
amount ("¢
	ClientNpc
npctype (
npcid (
name (	
title (	
model (
map_id (
pos_info (2.base.PosInfo
desc (2
.base.Desc"é
TaskInfo
taskid (
tasktype (
name (	

targetdesc (	

detaildesc (	
	submitnpc (
target (
needitem (2	.NeedItem
needsum	 (2.NeedSum
	clientnpc
 (2
.ClientNpc
isdone (
time (

rewardinfo (",
GS2CLoginTask
taskdata (2	.TaskInfo"*
GS2CAddTask
taskdata (2	.TaskInfo"
GS2CDelTask
taskid ("I

DialogInfo
type (
preId (
content (	
voice ("=

GS2CDialog

sessionidx (
dialog (2.DialogInfo
ë
server/player.proto"z
GS2CPropChange
mask (
grade (
name (	
shape (
goldcoin (
gold (
silver (