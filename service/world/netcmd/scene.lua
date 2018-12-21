--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function C2GSSyncPos(oPlayer, mData)
    local oScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oScene:GetSceneId() == mData.scene_id then
        oScene:Forward("SyncPos", oPlayer:GetPid(), mData)
    end
end