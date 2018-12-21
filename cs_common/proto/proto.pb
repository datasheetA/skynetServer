
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