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