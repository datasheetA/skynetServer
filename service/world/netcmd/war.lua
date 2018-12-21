--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function C2GSWarSkill(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("WarSkill", oPlayer:GetPid(), mData)
    end
end

function C2GSWarNormalAttack(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("WarNormalAttack", oPlayer:GetPid(), mData)
    end
end

function C2GSWarProtect(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("WarProtect", oPlayer:GetPid(), mData)
    end
end

function C2GSWarEscape(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("WarEscape", oPlayer:GetPid(), mData)
    end
end

function C2GSWarDefense(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("WarDefense", oPlayer:GetPid(), mData)
    end
end
