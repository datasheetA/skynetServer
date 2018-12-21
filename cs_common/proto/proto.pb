
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
X
base/role.protobase"

SimpleRole
pid ("$
Role
account (	
pid (
á
base/war.protobase"-
PlayerWarriorStatus

hp (

mp ("T
PlayerWarrior
wid (
pos ()
status (2.base.PlayerWarriorStatus"D
WarCamp
camp_id ((
player_list (2.base.PlayerWarrior
h
client/login.proto"#
C2GSLoginAccount
account (	"-
C2GSLoginRole
account (	
pid (
?
client/other.proto"
C2GSHeartBeat"
	C2GSGMCmd
cmd (	
u
client/scene.protobase/scene.proto"M
C2GSSyncPos
scene_id (
eid (
pos_info (2.base.PosInfo
¾
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

action_wid (
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
3
server/other.proto"
GS2CHeartBeat
time (
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
Ï	
server/war.protobase/war.proto"@
GS2CWarStart
war_id ( 
	camp_list (2.base.WarCamp"

GS2CWarEnd
war_id ("3
GS2CWarBoutStart
war_id (
bout_id ("1
GS2CWarBoutEnd
war_id (
bout_id ("W
GS2CWarAddWarrior
war_id (
type ($
warrior (2.base.PlayerWarrior"K
GS2CWarSkillStart
war_id (
action_wlist (
skill_id ("I
GS2CWarSkillEnd
war_id (
action_wlist (
skill_id ("R
GS2CWarNormalAttackStart
war_id (

action_wid (

select_wid ("<
GS2CWarNormalAttackEnd
war_id (

action_wid ("a
GS2CWarMagicStart
war_id (
action_wlist (
select_wlist (
magic_id ("I
GS2CWarMagicEnd
war_id (
action_wlist (
magic_id ("M
GS2CWarProtectStart
war_id (

action_wid (

select_wid ("7
GS2CWarProtectEnd
war_id (

action_wid ("8
GS2CWarEscapeStart
war_id (

action_wid ("6
GS2CWarEscapeEnd
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
status (2.base.PlayerWarriorStatus