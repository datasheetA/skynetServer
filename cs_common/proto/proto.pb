
ÿ
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
mask (
Ž
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
X
base/role.protobase"

SimpleRole
pid ("$
Role
account (	
pid (
h
client/login.proto"#
C2GSLoginAccount
account (	"-
C2GSLoginRole
account (	
pid (
u
client/scene.protobase/scene.proto"M
C2GSSyncPos
scene_id (
eid (
pos_info (2.base.PosInfo
ô
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
?
client/other.proto"
C2GSHeartBeat"
	C2GSGMCmd
cmd (	
¬
client/item.proto"-
C2GSItemUse
itemid (
target ("
C2GSItemInfo
itemid (",
C2GSItemMove
itemid (
iPos ("
C2GSItemArrage"&
C2GSAddItemExtendSize
iSize ("0
C2GSDeComposeItem

id (
iAmount (".
C2GSComposeItem

id (
iAmount (
å
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
å
server/scene.protobase/scene.proto"1
GS2CShowScene
scene_id (
map_id ("P
GS2CEnterScene
scene_id (
eid (
pos_info (2.base.PosInfo"`
GS2CEnterAoi
scene_id (
eid (
type (#

aoi_player (2.base.PlayerAoi"-
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

server/war.protobase/war.proto"
GS2CShowWar
war_id ("0
GS2CWarResult
war_id (
bout_id ("3
GS2CWarBoutStart
war_id (
bout_id (" 
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

select_wid ("\
GS2CWarMagic
war_id (
action_wlist (
select_wlist (
magic_id ("H
GS2CWarProtect
war_id (

action_wid (

select_wid ("3
GS2CWarEscape
war_id (

action_wid ("J
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
3
server/other.proto"
GS2CHeartBeat
time (
ó
server/item.proto")
	applyinfo
sKey (	
iValue ("±
iteminfo

id (
sid (
sName (	
iPos (

iItemLevel (
iAmount (
iTime (
iKey (

apply_info	 (2
.applyinfo
sDesc
 (	">
GS2CLoginItem
itemdata (2	.iteminfo
iExtSize ("*
GS2CItemAdd
itemdata (2	.iteminfo"

GS2DelItem

id ("+
GS2CMoveItem

id (
destpos (",
GS2CItemAmount

id (
amount ("
GS2CItemQuickUse

id (
ü
server/player.proto"q
GS2CPropLogin
iGrade (
sName (	
iShape (
	iGoldCoin (
iGold (
iSilver ("r
GS2CPropChange
iGrade (
sName (	
iShape (
	iGoldCoin (
iGold (
iSilver (