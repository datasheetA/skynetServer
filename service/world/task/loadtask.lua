local global = require "global"

local mTaskDir = {
    ["test"] = {1,200}
}

local mTaskList = {}

function GetDir(taskid)
    for sDir,mPos in pairs(mTaskDir) do
        local iStart,iEnd = table.unpack(mPos)
        if iStart <= taskid and taskid <= iEnd then
            return sDir
        end
    end
end

function CreateTask(taskid)
    local sDir = GetDir(taskid)
    local sPath = string.format("task/%s/%sbase",sDir,sDir)
    local oModule = import(service_path(sPath))
    assert(oModule,string.format("Create Task err:%d %s",taskid,sPath))
    local oTask = oModule.NewTask(taskid)
    return oTask
end

function GetTask(taskid)
    local oTask = mTaskList[taskid]
    if not oTask then
        oTask = CreateTask(taskid)
        mTaskList[taskid] = oTask
    end
    return oTask
end

function LoadTask(taskid,mArgs)
   local sDir = GetDir(taskid)
    local sPath = string.format("task/%s/%sbase",sDir,sDir)
    local oModule = import(service_path(sPath))
    assert(oModule,string.format("Create Task err:%d %s",taskid,sPath))
    local oTask = oModule.NewTask(taskid)
    oTask:Load(mArgs)
    oTask:Setup()
    return oTask
end