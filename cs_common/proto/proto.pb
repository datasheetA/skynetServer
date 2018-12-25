
–
base/common.protobase"e
PosInfo	
v (	
x (	
y (	
z (
face_x (
face_y (
face_z ("o
	ModelInfo
shape (
scale (
color (
mutate_texture (
weapon (
adorn ("

SimpleRole
pid ("ê
Role
mask (
grade (
name (	

title_list (	
goldcoin (
gold (
silver (
exp (
	chubeiexp	 (
max_hp
 (
max_mp (

hp (

mp (
enegy (
physique (
strength (
magic (
	endurance (
agility (

phy_attack (
phy_defense (

mag_attack (
mag_defense (

cure_power (
speed (

seal_ratio (
res_seal_ratio (
phy_critical_ratio (
res_phy_critical_ratio (
mag_critical_ratio (
res_mag_critical_ratio (#

model_info  (2.base.ModelInfo
school! (
point" ("^
	PlayerAoi#
block (2.base.PlayerAoiBlock
pos_info (2.base.PosInfo
pid ("Q
PlayerAoiBlock
mask (
name (	#

model_info (2.base.ModelInfo"k
NpcAoi 
block (2.base.NpcAoiBlock
pos_info (2.base.PosInfo
npctype (
npcid ("N
NpcAoiBlock
mask (
name (	#

model_info (2.base.ModelInfo"Ä
PlayerWarriorStatus
mask (

hp (

mp (
max_hp (
max_mp (#

model_info (2.base.ModelInfo"a
PlayerWarrior
wid (
pid (
pos ()
status (2.base.PlayerWarriorStatus"'
	ApplyInfo
key (	
value ("Ø
ItemInfo

id (
sid (
name (	
pos (
	itemlevel (
amount (
time (
key (#

apply_info	 (2.base.ApplyInfo
desc
 (	
h
client/login.proto"#
C2GSLoginAccount
account (	"-
C2GSLoginRole
account (	
pid (
∫
client/scene.protobase/common.proto"M
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
º
client/other.proto"
C2GSHeartBeat"
	C2GSGMCmd
cmd (	"(

CommitItem

id (
amount ("Q
C2GSCallback

sessionidx (
answer (
itemlist (2.CommitItem
ë
client/warehouse.proto""
C2GSSwitchWareHouse
wid ("
C2GSBuyWareHouse"0
C2GSRenameWareHouse
wid (
name (	"5
C2GSWareHouseWithStore
wid (
itemid ("1
C2GSWareHouseWithDraw
wid (
pos ("#
C2GSWareHouseArrange
wid (
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
Ü
client/task.proto"
C2GSClickTask
taskid (".
C2GSTaskEvent
taskid (
npcid (" 
C2GSCommitTask
taskid (

client/player.proto

client/openui.proto
Ö
server/login.protobase/common.proto"
	GS2CHello
time (".
GS2CLoginError
pid (
errcode ("H
GS2CLoginAccount
account (	#
	role_list (2.base.SimpleRole"G
GS2CLoginRole
account (	
pid (
role (2
.base.Role
π
server/scene.protobase/common.proto"E
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
eid ("î
GS2CSyncAoi
scene_id (
eid (
type (.
aoi_player_block (2.base.PlayerAoiBlock(
aoi_npc_block (2.base.NpcAoiBlock"M
GS2CSyncPos
scene_id (
eid (
pos_info (2.base.PosInfo"a
GS2CAutoFindPath
npcid (
map_id (
pos_x (
pos_z (
autotype (
_
server/npc.proto"K

GS2CNpcSay

sessionidx (
shape (
name (	
text (	
¡
server/war.protobase/common.proto"
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
damage ("s
GS2CWarWarriorStatus
war_id (
wid (
type (0
player_status (2.base.PlayerWarriorStatus"3
GS2CWarGoback
war_id (

action_wid (
Q
server/other.proto"
GS2CHeartBeat
time ("
GS2CGMMessage
msg (	
0
server/notify.proto"

GS2CNotify
cmd (	
•
server/warehouse.protobase/common.proto"4
GS2CWareHouseLogin
size (
namelist (	"S
GS2CRefreshWareHouse
wid (
name (	 
itemdata (2.base.ItemInfo".
GS2CWareHouseName
wid (
name (	"E
GS2CAddWareHouseItem
wid ( 
itemdata (2.base.ItemInfo"3
GS2CDelWareHouseItem
wid (
itemid ("A
GS2CMoveWareHouseItem
wid (

id (
destpos (
ÿ
server/item.protobase/common.proto"B
GS2CLoginItem 
itemdata (2.base.ItemInfo
extsize ("/
GS2CAddItem 
itemdata (2.base.ItemInfo"
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
ô
server/task.protobase/common.proto"*
NeedItem
itemid (
amount ("(
NeedSum
sumid (
amount ("X
TaskItem
itemid (
map_id (
pos_x (
pos_z (
radius ("û
	ClientNpc
npctype (
npcid (
name (	
title (	
map_id (
pos_info (2.base.PosInfo#

model_info (2.base.ModelInfo"´
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

rewardinfo (
taskitem (2	.TaskItem",
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
dialog (2.DialogInfo"?
GS2CRefreshTask
mask (
taskid (
target (".
GS2CRemoveNpc
taskid (
npcid (
è
server/player.protobase/common.proto"*
GS2CPropChange
role (2
.base.Role"9
GS2CServerGradeInfo
server_grade (
days (
ó
server/openui.proto"I

GS2CLoadUI

sessionidx (
type (
tip (
time ("5
GS2CPopTaskItem

sessionidx (
taskid (