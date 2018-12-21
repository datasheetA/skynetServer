--import module
local global = require "global"
local skynet = require "skynet"

function ConfirmRemote(mRecord, mData)
    local iScene = mData.scene_id
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:ConfirmRemote(iScene)
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

function SyncPlayerPos(mRecord, mData)
    local iScene = mData.scene_id
    local iPid = mData.pid
    local mPosInfo = mData.pos_info
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        local oPlayerEntity = oScene:GetPlayerEntity(iPid)
        if oPlayerEntity then
            oPlayerEntity:SyncPos(mPosInfo)
        end
    end
end
