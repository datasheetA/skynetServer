local global = require "global"
local skynet = require "skynet"
local extend = require "base/extend"

function GS2CPropLogin(oPlayer,mNet)
     local mNet = {}
    mNet["iGrade"] = oPlayer.m_oBaseCtrl:GetData("grade",0)
    mNet["sName"] = oPlayer.m_oBaseCtrl:GetData("name","")
    mNet["iShape"] = 0
    mNet["iGoldCoin"] = oPlayer.m_GoldCoin or 0
    mNet["iGold"] = oPlayer.m_oBaseCtrl:GetData("gold",0)
    mNet["iSilver"] = oPlayer.m_oBaseCtrl:GetData("silver",0)
    oPlayer:Send("GS2CPropLogin",mNet)
end

function GS2CPropChange(pid,key,value)
    local mNet = {}
    mNet[key] = value
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
      oPlayer:Send("GS2CPropChange",mNet)
    end
end