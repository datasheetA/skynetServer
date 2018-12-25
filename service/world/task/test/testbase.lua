--import module

local global = require "global"
local taskobj = import(service_path("task/taskobj"))

local CTask = {}
CTask.__index = CTask
inherit(CTask,taskobj.CTask)

function CTask:New(taskid)
    local o = super(CTask).New(self,taskid)
    return o
end

function NewTask(taskid)
    local o = CTask:New(taskid)
    return o
end