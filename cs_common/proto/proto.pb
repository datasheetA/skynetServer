
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
=
base/role.protobase"$
Role
account (	
pid (
v
client/login.proto"#
C2GSLoginAccount
account (	"-
C2GSLoginRole
account (	
pid ("

C2GSTestDo
u
client/scene.protobase/scene.proto"M
C2GSSyncPos
scene_id (
eid (
pos_info (2.base.PosInfo
À
server/login.protobase/role.proto"
	GS2CHello".
GS2CLoginError
pid (
errcode ("#
GS2CLoginAccount
account (	")
GS2CLoginRole
role (2
.base.Role"

GS2CTestDo
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