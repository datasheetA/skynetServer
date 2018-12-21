--import module
local global = require "global"
local extend = require "base.extend"

local handlenpc = import(service_path("npc/handlenpc"))

function C2GSClickNpc(oPlayer,mData)
    local npcid = mData["npcid"]
    local oNpcMgr = global.oNpcMgr
    local oNpc = oNpcMgr:GetObject(npcid)
    assert(oNpc,string.format("C2GSClickNpc err %d",npcid))
    oNpc:do_look(oPlayer)
end

function C2GSNpcRespond(oPlayer,mData)
    local npcid = mData["npcid"]
    local iAnswer = mData["answer"]
    local oNpcMgr = global.oNpcMgr
    local oNpc = oNpcMgr:GetObject(npcid)
    assert(oNpc,string.format("C2GSNpcRespond err %d",npcid))
    handlenpc.Respond(oPlayer.m_iPid,npcid,iAnswer)
end

function GS2CNpcObjSay(pid,oNpc,sText)
    handlenpc.ClearRespond(pid)
    local mNet = {}
    mNet["npcid"] = oNpc.m_ID
    mNet["model"] = oNpc.m_Model
    mNet["name"] = oNpc:Name()
    mNet["text"] = sText
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(iOwner)
    if oPlayer then
        oPlayer:Send("GS2CNpcSay",mNet)
    end
end

function GS2CNpcSay(pid,npcid,iModel,sName,sText)
    handlenpc.ClearRespond(pid)
    local mNet = {}
    mNet["npcid"] = npcid
    mNet["model"] = iModel
    mNet["name"] = sName
    mNet["text"] = sText
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(iOwner)
    if oPlayer then
        oPlayer:Send("GS2CNpcSay",mNet)
    end
end