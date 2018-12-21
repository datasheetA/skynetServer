--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function C2GSWarSkill(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("C2GSWarSkill", oPlayer:GetPid(), mData)
    end
end

function C2GSWarNormalAttack(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("C2GSWarNormalAttack", oPlayer:GetPid(), mData)
    end
end

function C2GSWarProtect(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("C2GSWarProtect", oPlayer:GetPid(), mData)
    end
end

function C2GSWarEscape(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("C2GSWarEscape", oPlayer:GetPid(), mData)
    end
end

function C2GSWarDefense(oPlayer, mData)
    local oNowWar = oPlayer.m_oActiveCtrl:GetNowWar()
    if oNowWar and oNowWar:GetWarId() == mData.war_id then
        oNowWar:Forward("C2GSWarDefense", oPlayer:GetPid(), mData)
    end
end
