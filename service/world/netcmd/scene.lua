--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function C2GSSyncPos(oPlayer, mData)
    local oScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oScene:GetSceneId() == mData.scene_id then
        oScene:Forward("C2GSSyncPos", oPlayer:GetPid(), mData)
    end
end

function C2GSTransfer(oPlayer, mData)
    local oSceneMgr = global.oSceneMgr
    local oScene = oPlayer.m_oActiveCtrl:GetNowScene()
    if oScene:GetSceneId() == mData.scene_id then
        oSceneMgr:TransferScene(oPlayer, mData.transfer_id)
    end
end
