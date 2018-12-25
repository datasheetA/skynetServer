local global = require "global"
local skynet = require "skynet"
local extend = require "base/extend"
local tableop = require "base.tableop"

local timeop = import(lualib_path("base.timeop"))
local stringop = import(lualib_path("base.stringop"))
local loaditem = import(service_path("item.loaditem"))

local max = math.max
local min = math.min

function C2GSClickTask(oPlayer,mData)
    local taskid = mData["taskid"]
    local oTask = oPlayer.m_oTaskCtrl:GetTask(taskid)
    if not oTask then
        return
    end
    oTask:Click(oPlayer)
end

function C2GSTaskEvent(oPlayer,mData)
    local taskid = mData["taskid"]
    local npcid = mData["npcid"]
    local oTask = oPlayer.m_oTaskCtrl:GetTask(taskid)
    if not oTask then
        return
    end
    oTask:DoNpcEvent(oPlayer.m_iPid,npcid)
end

function C2GSCommitTask(oPlayer,mData)
    local taskid = mData["taskid"]
    local oTask = oPlayer.m_oTaskCtrl:GetTask(taskid)
    if not oTask then
        return
    end
    oTask:MissionDone()
end
