local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))
local tasknet = import(service_path("netcmd/task"))
local loadtask = import(service_path("task/loadtask"))

local max = math.max
local min = math.min

CTaskCtrl = {}
CTaskCtrl.__index = CTaskCtrl
inherit(CTaskCtrl, datactrl.CDataCtrl)

function CTaskCtrl:New(pid)
    local o = super(CTaskCtrl).New(self, {pid = pid})
    o.m_Owner = pid
    o.m_List = {}
    return o
end

function CTaskCtrl:Save()
    local mData = {}
    mData["Data"] = self.m_mData
    local mTaskData = {}
    for taskid,oTask in pairs(self.m_List) do
        mTaskData[taskid] = oTask:Save()
    end
    mData["TaskData"] = mTaskData
    return mData
end

function CTaskCtrl:Load(mData)
    if not mData then
        return
    end
    self.m_mData = mData["Data"]
    local mTaskData = mData["TaskData"]
    for taskid,mArgs in pairs(mTaskData) do
        local oTask = loadtask.LoadTask(taskid,mArgs)
        if not oTask:IsTimeOut() then
            oTask:SetOwner(self.m_Owner)
            self.m_List[taskid] = oTask
        else
            --
        end
    end

    self:Dirty()
end

function CTaskCtrl:ValidAddTask(oTask)
    for _,taskobj in pairs(self.m_List) do
        if taskobj.m_ID == oTask.m_ID then
            return false
        end
        if taskobj:Type() == oTask:Type() then
            return false
        end
    end
    return true
end

function CTaskCtrl:AddTask(taskid,npcobj)
    local oTask = loadtask.CreateTask(taskid)
    if not self:ValidAddTask(oTask) then
        return
    end
     local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if not oTask:PreCondition(oPlayer) then
        return
    end
    self:Dirty()
    oTask:Config(self.m_Owner,npcobj)
    oTask:Setup()
    self.m_List[oTask.m_ID] = oTask
    oTask:SetOwner(self.m_Owner)
    self:GS2CAddTask(oTask)
end

function CTaskCtrl:RemoveTask(oTask)
    self:Dirty()
    self.m_List[oTask.m_ID] = nil
    self:GS2CRemoveTask(oTask)
end

function CTaskCtrl:GetTask(taskid)
   return self.m_List[taskid]
end

function CTaskCtrl:HasTask(taskid)
   local oTask = self.m_List[taskid]
    if oTask then
        return oTask
    end
    return false
end

function CTaskCtrl:HasTaskType(iTaskType)
    for _,oTask in pairs(self.m_List) do
        if oTask:Type() == iTaskType then
            return oTask
        end
    end
    return false
end

function CTaskCtrl:IsDirty()
    local bDirty = super(CTaskCtrl).IsDirty(self)
   if bDirty then
        return true
    end
    for taskid,oTask in pairs(self.m_List) do
        if oTask:IsDirty() then
            return true
        end
    end
    return false
end

function CTaskCtrl:UnDirty()
    super(CTaskCtrl).UnDirty(self)
    for taskid,oTask in pairs(self.m_List) do
        if oTask:IsDirty() then
            oTask:UnDirty()
        end
    end
end

function CTaskCtrl:GS2CAddTask(oTask)
    local mNet = {}
    local mData = oTask:PackTaskInfo()
    mNet["taskdata"] = mData
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
         oPlayer:Send("GS2CAddTask",mNet)
    end
end

function CTaskCtrl:GS2CRemoveTask(oTask)
    local mNet = {}
    mNet["taskid"] = oTask.m_ID
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CDelTask",mNet)
    end
end

function CTaskCtrl:OnLogin()
     local mNet = {}
    local mData = {}
    for _,oTask in pairs(self.m_List) do
        table.insert(mData,PackTaskInfo(oTask))
    end
    mNet["taskdata"] = mData
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
         oPlayer:Send("GS2CLoginTask",mNet)
    end
end