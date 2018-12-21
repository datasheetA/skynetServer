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
        v = geometry.Recover(mPosInfo.v),
        x = geometry.Recover(mPosInfo.x),
        y = geometry.Recover(mPosInfo.y),
        z = geometry.Recover(mPosInfo.z),
        face_x = geometry.Recover(mPosInfo.face_x),
        face_y = geometry.Recover(mPosInfo.face_y),
        face_z = geometry.Recover(mPosInfo.face_z),
    }

    local oScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oScene:GetSceneId() == iScene then
        oScene:SyncPos(iEid, oPlayer:GetPid(), mPos)
    end
end
