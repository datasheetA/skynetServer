--import module

local global = require "global"
local npcobj = import(service_path("npc/npcobj"))
local handlenpc = import(service_path("npc/handlenpc"))

local CNpc = {}
CNpc.__index = CNpc
inherit(CNpc,npcobj.CNpc)

function CNpc:New(npcid)
    local o = super(CNpc).New(self,npcid)
    return o
end

function CNpc:do_look(oPlayer)
    local func = function (pid,mData)
    	local iAnswer = mData["answer"]
    	local sText = string.format("这是测试%d",iAnswer)
   	self:Say(oPlayer.m_iPid,sText)
    end
    local sText = "你好，这是测试#Q测试1#Q测试2#Q测试3"
    self:SayRespond(oPlayer.m_iPid,sText,nil,func)
end

function NewNpc(npctype,npcid)
    local o = CNpc:New(npctype,npcid)
    return o
end