--import module
local global = require "global"
local skynet = require "skynet"
local geometry = require "base.geometry"
local protobuf = require "base.protobuf"
local interactive = require "base.interactive"

ForwardNetcmds = {}

function ForwardNetcmds.C2GSSyncPos(oPlayer, mData)
    local iScene = mData.scene_id
    local iEid = mData.eid
    local mPosInfo = mData.pos_info

    if oPlayer:GetEid() ~= iEid then
        return
    end

    local mPos = {
        v = geometry.Recover(mPosInfo.v),
        x = geometry.Recover(mPosInfo.x),
        y = geometry.Recover(mPosInfo.y),
        z = geometry.Recover(mPosInfo.z),
        face_x = geometry.Recover(mPosInfo.face_x),
        face_y = geometry.Recover(mPosInfo.face_y),
        face_z = geometry.Recover(mPosInfo.face_z),
    }
    oPlayer:SyncPos(mPos)
end

function ConfirmRemote(mRecord, mData)
    local iScene = mData.scene_id
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:ConfirmRemote(iScene)
end

function RemoveRemote(mRecord, mData)
    local iScene = mData.scene_id
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:RemoveScene(iScene)
end

function EnterPlayer(mRecord, mData)
    local iScene = mData.scene_id
    local mPos = mData.pos
    local iPid = mData.pid
    local iEid = mData.eid
    local mMail = mData.mail
    local mInfo = mData.data
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    assert(oScene, string.format("EnterPlayer error scene: %d %d %d", iScene, iPid, iEid))
    oScene:EnterPlayer(iPid, iEid, mMail, mPos, mInfo)
end

function SyncPlayerInfo(mRecord,mData)
    local iScene = mData.scene_id
    local mArgs = mData.args
    local iEid = mData.eid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    assert(oScene,string.format("SyncPlayerInfo err scene,%d",iScene))
    local oPlayerEntity = oScene:GetEntity(iEid)
    assert(oPlayerEntity,string.format("SyncPlayerInfo err %d",iEid))
    if oPlayerEntity:IsPlayer() then
        oPlayerEntity:SyncInfo(mArgs)
    end
end

function LeavePlayer(mRecord, mData)
    local iScene = mData.scene_id
    local iPid = mData.pid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        oScene:LeavePlayer(iPid)
    end
end

function ReEnterPlayer(mRecord, mData)
    local iScene = mData.scene_id
    local iPid = mData.pid
    local mMail = mData.mail
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    assert(oScene, string.format("ReEnterPlayer error scene: %d %d", iScene, iPid))
    oScene:ReEnterPlayer(iPid, mMail)
end

function NotifyDisconnected(mRecord, mData)
    local iScene = mData.scene_id
    local iPid = mData.pid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if oPlayerEntity then
            oPlayerEntity:Disconnected()
        end
    end
end

function NotifyEnterWar(mRecord, mData)
    local iScene = mData.scene_id
    local iPid = mData.pid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if oPlayerEntity then
            oPlayerEntity:EnterWar()
        end
    end
end

function NotifyLeaveWar(mRecord, mData)
    local iScene = mData.scene_id
    local iPid = mData.pid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if oPlayerEntity then
            oPlayerEntity:LeaveWar()
        end
    end
end

function Forward(mRecord, mData)
    local iPid = mData.pid
    local iRouteScene = mData.scene_id
    local sCmd = mData.cmd
    local m = protobuf.default(sCmd, mData.data)

    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iRouteScene)
    if oScene then
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if oPlayerEntity then
            local func = ForwardNetcmds[sCmd]
            if func then
                func(oPlayerEntity, m)
            end
        end
    end
end

function Query(mRecord, mData)
    local oSceneMgr = global.oSceneMgr
    local sType = mData.type
    local iScene = mData.scene_id
    local m = mData.data

    local oScene = oSceneMgr:GetScene(iScene)
    if not oScene then
        interactive.Response(mRecord.source, mRecord.session, {})
        return
    end

    if sType == "player_pos" then
        local iPid = m.pid
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if oPlayerEntity then
            interactive.Response(mRecord.source, mRecord.session, {
                data = {
                    scene_id = iScene,
                    pid = iPid,
                    pos_info = oPlayerEntity:GetPos(),
                }
            })
            return
        end
    end
end

function EnterNpc(mRecord,mData)
   local iScene = mData.scene_id
   local mPos = mData.pos
   local mInfo = mData.data
   local iEid = mData.eid
   local oSceneMgr = global.oSceneMgr
   local oScene = oSceneMgr:GetScene(iScene)
   assert(oScene,string.format("EnterNpc error scene:%d %d %d",iScene,iEid,mInfo.npctype))
   oScene:EnterNpc(iEid,mPos,mInfo)
end

function SyncNpcInfo(mRecord,mData)
    local iScene = mData.scene_id
    local mArgs = mData.args
    local iEid = mData.eid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    assert(oScene,string.format("SyncNpcInfo err scene,%d",iScene))
    local oNpcEntity = oScene:GetEntity(iEid)
    assert(oNpcEntity,string.format("SyncNpcInfo err %d",iEid))
    if oNpcEntity:IsNpc() then
        oNpcEntity:SyncInfo(mArgs)
    end
end

function RemoveSceneNpc(mRecord,mData)
    local iScene = mData.scene_id
    local iEid = mData.eid
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    assert(oScene,string.format("RemoveSceneNpc error scene%d %d %d",iScene,iEid))
    oScene:RemoveSceneNpc(iEid)
end
