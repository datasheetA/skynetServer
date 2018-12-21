--import module
local global = require "global"
local skynet = require "skynet"
local geometry = require "base.geometry"

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
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    assert(oScene, string.format("EnterPlayer error scene: %d %d %d", iScene, iPid, iEid))
    oScene:EnterPlayer(iPid, iEid, mMail, mPos)
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

function SyncPos(mRecord, mData)
    local iPid = mData.pid
    local iRouteScene = mData.scene_id
    local m = mData.data

    local iScene = m.scene_id
    local iEid = m.eid
    local mPosInfo = m.pos_info

    if iRouteScene ~= iScene then
        return
    end
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if not oPlayerEntity or oPlayerEntity:GetEid() ~= iEid then
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
        oPlayerEntity:SyncPos(mPos)
    end
end
