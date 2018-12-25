--import module
local global = require "global"
local extend = require "base.extend"

local handlenpc = import(service_path("npc/handlenpc"))

function C2GSExchangeMoney(oPlayer,mData)
    local iType = mData["type"]
    local iGoldCoin = mData["goldcoin"]
    if not oPlayer:ValidGoldCoin(iGoldCoin) then
        return
    end
    local oWorldMgr = global.oWorldMgr
    if iType == 1 then
        oPlayer:ResumeGoldCoin(iGoldCoin,"兑换金币")
        local iGold = iGoldCoin * 50
        oPlayer:RewardGold(iGold,"金币兑换")
    elseif iType == 2 then
        oPlayer:ResumeGoldCoin(iGoldCoin,"兑换银币")
        local iServerGrade = oWorldMgr:GetServerGrade()
        local iSilver = (iServerGrade*25+4000) * iGoldCoin
        oPlayer:RewardSilver(iSilver,"金币兑换")
    end
end