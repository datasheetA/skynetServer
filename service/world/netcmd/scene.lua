--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local geometry = require "base.geometry"

function C2GSSyncPos(oPlayer, mData)
    local iScene = mData.scene_id
    local iEid = mData.eid
    local mPosInfo = mData.pos_info

    local mPos = {
        v = geometry.recover(mPosInfo.v),
        x = geometry.recover(mPosInfo.x),
        y = geometry.recover(mPosInfo.y),
        z = geometry.recover(mPosInfo.z),
        face_x = geometry.recover(mPosInfo.face_x),
        face_y = geometry.recover(mPosInfo.face_y),
        face_z = geometry.recover(mPosInfo.face_z),
    }

    local oScene = oPlayer:GetNowScene()
    if oScene:GetSceneId() == iScene then
        oScene:SyncPos(iEid, oPlayer:GetPid(), mPos)
    end
end
