--import module
local global  = require "global"
local extend = require "base.extend"

local datactrl = import(lualib_path("public.datactrl"))
local timeop = import(lualib_path("base.timeop"))
local stringop = import(lualib_path("base.stringop"))
local tableop = import(lualib_path("base.tableop"))

local loaditem = import(service_path("item/loaditem"))
local clientnpc = import(service_path("task/clientnpc"))
local loadtask = import(service_path("task/loadtask"))
local tasknet = import(service_path("netcmd/task"))
local gamedefines = import(lualib_path("public.gamedefines"))

local min = math.min
local max = math.max
local floor = math.floor

local gsub = string.gsub

CTask = {}
CTask.__index = CTask
inherit(CTask, datactrl.CDataCtrl)

function CTask:New(taskid)
    local o = super(CTask).New(self)
    o.m_ID = taskid
    o:Init()
    return o
end

function CTask:Init()
    self.m_Owner = 0
    self.m_mEvent = {}
    self.m_mNeedItem = {}
    self.m_mNeedSummon = {}
    self.m_mClientNpc = {}
    self.m_mTaskItem = {}
end

function CTask:GetTaskData()
    local res = require "base.res"
    local mData = res["daobiao"]["task"]
     mData = mData[self.m_ID]
    assert(mData,string.format("CTask GetTaskData err%d",self.m_ID))
    return mData
end

function CTask:GetNpcGroupData(iGroup)
    local res = require "base.res"
    local mData = res["daobiao"]["npcgroup"] or {}
    mData = mData[iGroup]
    assert(mData,string.format("CTask GetNpcGroupData err%d",iGroup))
    return mData["npc"]
end

function CTask:GetTempNpcData(iTempNpc)
    local res = require "base.res"
    local mData = res["daobiao"]["temp_npc"]
    local mTempData = mData[iTempNpc]
    assert(mTempData,string.format("CTask GetTempNpcData err:%d",iTempNpc))
    return mTempData
end

function CTask:GetEventData(iEvent)
    local res = require "base.res"
    local mData = res["daobiao"]["taskevent"]
    mData = mData[iEvent]
    assert(mData,string.format("CTask GetEventData err:%d",iEvent))
    return mData
end

function CTask:GetDialogData(iDialog)
    local res = require "base.res"
    local mData = res["daobiao"]["taskdialog"]
    mData = mData[iDialog]
    assert(mData,string.format("CTask:GetDialogData err:%d",iDialog))
    return mData["Dialog"]
end

function CTask:GetItemGroup(iGroup)
    local res = require "base.res"
    local mData = res["daobiao"]["itemgroup"]
    mData = mData[iGroup]
    assert(mData,string.format("CTask:GetItemGroup err:%d",iGroup))
    return mData["itemgroup"]
end

function CTask:GetTaskItemData(itemid)
    local res = require "base.res"
    local mData = res["daobiao"]["taskitem"]
    mData = mData[itemid]
    assert(mData,string.format("CTask:GetTaskItem err:%d",itemid))
    return mData
end

function CTask:GetSceneGroup(iGroup)
    local res = require "base.res"
    local mData = res["daobiao"]["scenegroup"][iGroup]
    mData = mData["maplist"]
    assert(mData,string.format("CTask:scenegroup err:%d",iGroup))
    return mData
end

function CTask:GetTextData(iText)
    local res = require "base.res"
    local mData = res["daobiao"]["tasktext"][iText]
    mData = mData["content"]
    assert(mData,string.format("CTask:GetTextData err:%d",iText))
end

--任务类型:寻人，寻物等
function CTask:TaskType()
    local mData = self:GetTaskData()
    return mData["tasktype"]
end

--玩法分类
function CTask:Type()
    local mData = self:GetTaskData()
    return mData["type"]
end

--寻路类型
function CTask:AutoType()
    local mData = self:GetTaskData()
    return mData["autotype"]
end

function CTask:Name()
    local mData = self:GetTaskData()
    return self:TransString(self.m_Owner,nil,mData["name"])
end

--目标描述
function CTask:TargetDesc()
    local mData = self:GetTaskData()
    return self:TransString(self.m_Owner,nil,mData["goalDesc"])
end

--任务描述
function CTask:DetailDesc()
    local mData = self:GetTaskData()
    return self:TransString(self.m_Owner,nil,mData["description"])
end

function CTask:NewMessage(pid,npcobj)
    local mData = self:GetTaskData()
    return self:TransString(self.m_Owner,nil,mData["acceptDialogConfig"])
end

--提交npc
function CTask:SubmitNpc()
    local mData = self:GetTaskData()
    return mData["submitNpcId"]
end

--设置行动目标
function CTask:SetTarget(iTarget)
    self:SetData("Target",iTarget)
    self:Refresh({target=iTarget})
end

--行动目标
function CTask:Target()
    local iTarget = self:GetData("Target")
    if iTarget then
        return iTarget
    end
    for _,oClientNpc in ipairs(self.m_mClientNpc) do
        return oClientNpc.m_ID
    end
    for npctype,iEvent in pairs(self.m_mEvent) do
        local oNpcMgr = global.oNpcMgr
        local oNpc = oNpcMgr:GetGlobalNpc(npctype)
        return oNpc.m_ID
    end
end

function CTask:Config(pid,npcobj)
    local mData = self:GetTaskData()
    local sConfig = mData["config"]
    self:DoScript(pid,npcobj,sConfig)
    sConfig = mData["submitConditionStr"]
    self:DoScript(pid,npcobj,sConfig)
    self:SubConfig(pid)
end

function CTask:SubConfig()
    --
end

function CTask:SetOwner(iOwner)
    self.m_Owner = iOwner
end

function CTask:SetTimer(iMin)
    local iSec = iMin * 60
    local iEndTime = timeop.get_time() + iSec * 60
    self:SetData("Time",iEndTime)
end

function CTask:Timer()
    local iEndTime = self:GetData("Time")
    local iNowTime = timeop.get_time()
    if iEndTime and iEndTime > iNowTime then
        return iEndTime - iNowTime
    end
    return 0
end

function CTask:Setup()
    local iTime = self:Timer()
    if iTime > 0 then
        self:DelTimeCb("timeout")
       self:AddTimeCb("timeout",iTime * 60, function()  self:TimeOut()  end)
    end
end

function CTask:TimeOut()
    self:Remove()
end

function CTask:IsTimeOut()
    local iEndTime = self:GetData("Time")
    if iEndTime and iEndTime <= timeop.get_time() then
        return true
    end
    return false
end

function CTask:Save()
    local mData = {}
    mData["needitem"] = self.m_mNeedItem
    mData["needsum"] = self.m_mNeedSummon
    local mClientNpc = {}
    for _,oClientNpc in ipairs(self.m_mClientNpc) do
        table.insert(mClientNpc,oClientNpc:Save())
    end
    mData["clientnpc"] = mClientNpc
    mData["event"] = self.m_mEvent
    mData["taskitem"] = self.m_mTaskItem
    mData["data"] = self.m_mData
    return mData
end

function CTask:Load(mData)
    if not mData then
        return
    end
    self.m_mNeedItem = mData["needitem"] or {}
    self.m_mNeedSummon = mData["needsum"] or {}
    local mClient = mData["clientnpc"] or {}
    for _,data in ipairs(mClient) do
        local oClientNpc = clientnpc.NewClientNpc(data)
        table.insert(self.m_mClientNpc,oClientNpc)
    end
    self.m_mData = mData["data"] or {}
    self.m_mEvent = mData["event"] or {}
    self.m_mTaskItem = mData["taskitem"] or {}

    self:Dirty()
end

function CTask:Remove()
    self:Release()
    local iOwner = self.m_Owner
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(iOwner)
    if oPlayer then
        oPlayer.m_oTaskCtrl:RemoveTask(self)
    end
end

function CTask:Release()
    self:DelTimeCb("timeout")
    self.m_mNeedItem = {}
    self.m_mNeedSummon = {}
    for _,oClientNpc in pairs(self.m_mClientNpc) do
        oClientNpc:Release()
    end
    self.m_mClientNpc = {}
end

function CTask:Abandon()
    self:Remove()
end

function CTask:MissionDone(pid,npcobj)
    self:Remove()
    self:OnMissionDone()
    local mData = self:GetTaskData()
    local s = mData["missiondone"]
    self:DoScript(pid,npcobj,s)
    s = mData["submitRewardStr"]
    self:DoScript(pid,npcobj,s)
    self:AfterMissionDone()
end

function CTask:OnMissionDone()
end

function CTask:AfterMissionDone()
end

function CTask:IsDone()
    return self:GetData("Done",0)
end

function CTask:SetDone()
    return self:SetData("Done",1)
end

function CTask:CreateClientNpc(iTempNpc)
    local res = require "base.res"
    local mData = self:GetTempNpcData(iTempNpc)
    local iNameType = mData["nameType"]
    local sName
    if iNameType == 2 then
        sName = self:GetNpcName(iTempNpc)
    else
        sName = mData["name"]
    end
    local mModel = {
        shape = mData["modelId"],
        scale = mData["scale"],
        adorn = mData["ornamentId"],
        weapon = mData["wpmodel"],
        color = mData["mutateColor"],
        mutate_texture = mData["mutateTexture"],
    }
    local mPosInfo = {
        x = mData["x"],
        y = mData["y"],
        z = mData["z"],
        face_x = mData["face_x"] or 0,
        face_y = mData["face_y"] or  0,
        face_z = mData["face_z"] or 0,
    }
    local mArgs = {
        npctype = mData["type"],
        name = sName,
        title = mData["title"],
        map_id = mData["sceneId"],
        model_info = mModel,
        pos_info = mPosInfo,
        event = mData["event"] or 0,
        reuse = mData["reuse"] or 0,
    }
    local oClientNpc = clientnpc.NewClientNpc(mArgs)
    table.insert(self.m_mClientNpc,oClientNpc)
    return oClientNpc
end

function CTask:RemoveClientNpc(npcobj)
    if not npcobj then
        return
    end
    local bFlag
    local npcid = npcobj.m_ID
    for _,oClientNpc in ipairs(self.m_mClientNpc) do
        if oClientNpc.m_ID == npcid then
            bFlag = true
        end
    end
    if not bFlag then
        return
    end
    extend.Array.remove(self.m_mClientNpc,npcobj)
    local mNet = {}
    mNet["taskid"] = self.m_ID
    mNet["npcid"] = npcid
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if not oPlayer then
        return
    end
    oPlayer:Send("GS2CRemoveNpc",mNet)
end

function CTask:GetClientObj(npcid)
    for _,oClientNpc in pairs(self.m_mClientNpc) do
        if oClientNpc.m_ID == npcid then
            return oClientNpc
        end
    end
end

function CTask:GetNpcName(iTempNpc)
    return ""
end

--前置条件
function CTask:PreCondition(oPlayer)
    local mData = self:GetTaskData()
    local mCondition = mData["acceptConditionStr"]
    if not mCondition then
        return
    end
    for _,mArgs in pairs(mCondition) do
        local sKey,iValue = string.match(mArgs,"(.+):(.+)")
        if sKey == "grade" then
            iValue = tonumber(iValue)
            if oPlayer.m_oBaseCtrl:GetData("grade") < iValue then
                return false
            end
            return true
        else
            --
        end
    end
    return true
end

function CTask:SetNeedItem(itemid,iAmount)
    self:Dirty()
    --取道具组
    if itemid < 1000 then
        local mItemGroup = self:GetItemGroup(itemid)
        local mItem = mItemGroup[math.random(#mItemGroup)]
        local sid = mItem["sid"]
        local iMin = mItem["min"]
        local iMax = mItem["max"]
        if iMax == iMin  then
             self.m_mNeedItem[sid] = iMax
        else
            local iNeedAmount = iMin + math.random(iMax-iMin)
            self.m_mNeedItem[sid] = iNeedAmount
        end
    else
        self.m_mNeedItem[itemid] = iAmount
    end
end

function CTask:SetNeedSummon(mArgs)
    self:Dirty()
    for sumid,iAmount in pairs(mArgs) do
        self.m_mNeedSummon[sumid] = iAmount
    end
end

function CTask:NeedItem()
    return self.m_mNeedItem
end

function CTask:NeedSummon()
    return self.m_mNeedSummon
end

function CTask:SetNeedTaskItem(mArgs)
    local map_id,x,z,radius,itemid = table.unpack(mArgs)
    self:Dirty()
    local mData = {
        itemid = itemid,
        map_id = map_id,
        pos_x = x,
        pos_z = z,
        radius = radius,
    }
    table.insert(self.m_mTaskItem,mData)
end

--随机场景使用任务道具
function CTask:SetRanScTaskItem(mArgs)
    local map_id,radius,itemid = table.unpack(mArgs)
    map_id = tonumber(map_id)
    local maplist = self:GetSceneGroup(map_id)
    local map_id = maplist[math.random(#maplist)]
    --先写死
    local x = 100
    local z = 100
    local mData = {
        itemid = itemid,
        map_id = map_id,
        pos_x = x,
        pos_z = z,
        radius = radius,
    }
    table.insert(self.m_mTaskItem,mData)
end

function CTask:SetAttr(mArgs)
    for _,sArgs in pairs(mArgs) do
        local key,value = string.match(sArgs,"(.+)=(.+)")
        if tonumber(value) then
            value = tonumber(value)
        end
        self:SetData(key,value)
    end
end

function CTask:DoScript(pid,npcobj,s)
    if type(s) ~= "table" then
        return
    end
    for _,ss in pairs(s) do
        self:DoScript2(pid,npcobj,ss)
    end
end

function CTask:DoScript2(pid,npcobj,s)
    if string.sub(s,1,5) == "DONE" then
        self:MissionDone()
    elseif string.sub(s,1,5) == "TIMER" then
        local iTime = string.sub(s,6,-1)
        iTime =tonumber(iTime)
        self:SetTimer(iTime)
    elseif string.sub(s,1,2) == "TI" then
        local sArgs = string.sub(s,3,-1)
        local mArgs = stringop.split_string(sArgs,":")
        self:SetNeedTaskItem(mArgs)
    elseif string.sub(s,1,3) == "GTI" then
        local sArgs = string.sub(s,4,-1)
        local mArgs = stringop.split_string(sArgs,":")
        self:SetRanScTaskItem(mArgs)
   elseif string.sub(s,1,3) == "SET" then
        local sArgs = string.sub(s,5,-2)
        local mArgs = stringop.split_string(sArgs,"|")
        self:SetAttr(mArgs)
    elseif string.sub(s,1,4) == "ITEM" then
        local sArgs = string.sub(s,6,-2)
        local mArgs = stringop.split_string(sArgs,"|")
        self:RewardItem(pid,mArgs)
    elseif string.sub(s,1,2) == "NT" then
        local iTaskid = string.sub(s,3,-1)
        iTaskid = tonumber(iTaskid)
        self:NextTask(iTaskid)
    elseif string.sub(s,1,2) == "NC" then
        local npctype = string.sub(s,3,-1)
        npctype = tonumber(npctype)
        self:CreateClientNpc(npctype)
    elseif string.sub(s,1,1) == "E" then
        local sArgs = string.sub(s,2,-1)
        local npctype,iEvent = string.match(sArgs,"(.+):(.+)")
        npctype = tonumber(npctype)
        iEvent = tonumber(iEvent)
        self:SetEvent(npctype,iEvent)
    elseif string.sub(s,1,1) == "I" then
        local sArgs = string.sub(s,2,-1)
        local itemid,iAmount = string.match(sArgs,"(.+):(.+)")
        itemid = tonumber(itemid)
        iAmount = tonumber(iAmount)
        self:SetNeedItem(itemid,iAmount)
    elseif string.sub(s,1,8) == "TAKEITEM" then
        self:TakeNeedItem(pid,npcobj)
    elseif string.sub(s,1,7) == "POPITEM" then
        self:PopTakeItemUI(pid,npcobj)
    elseif string.sub(s,1,6) == "TARGET" then
        local iTarget = string.sub(s,7,-1)
        iTarget = tonumber(iTarget)
        self:SetTarget(iTarget)
    elseif string.sub(s,1,2) == "D" then
        local iText = string.sub(s,2,-1)
        iText = tonumber(iText)
        if not iText then
            return
        end
        local sText = self:GetTextData(iText)
        if sText then
            self:SayText(pid,npcobj,sText)
        end
    elseif string.sub(s,1,2) == "DI" then
        local iDialog = string.sub(s,3,-1)
        iDialog = tonumber(iDialog)
        self:Dialog(iDialog)
    elseif string.sub(s,1,3) == "RN" then
        self:RemoveClientNpc(npcobj)
    end
    self:OtherScript(pid,npcobj,s)
end

function CTask:OtherScript(pid,npcobj,s)
    -- body
end

function CTask:GiveSummon(pid,sumid,attrid)
    -- body
end

function CTask:GivePartner(pid,parid)
    -- body
end

function CTask:RewardInfo()
    local mData = self:GetTaskData()
    return mData["submitRewardStr"]
end

function CTask:RewardItem(pid,mData)
    local sidlist = {}
    for _,sArgs in pairs(mData) do
        local sid,iAmount = string.match(sArgs,"(.+):(.+)")
        sid = tonumber(sid)
        iAmount = tonumber(iAmount)
        sidlist[sid] = iAmount
    end
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    assert(oPlayer,string.format("task rewarditem %d %d",self.m_ID,self.m_Owner))
    if oPlayer:ValidGive(sidlist) then
        oPlayer:GiveItem(sidlist)
    else
        --邮件
    end
end

function CTask:NextTask(taskid)
    local iOwner = self.m_Owner
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(iOwner)
    if not oPlayer then
        return
    end
    oPlayer:AddTask(taskid)
end

function CTask:ValidTakeItem(pid,npcobj)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if not oPlayer then
        return false
    end
    for sid,iAmount in pairs(self.m_mNeedItem) do
        if oPlayer:GetItemAmount(sid) < iAmount then
            return false
        end
    end
    return true
end

--自动提交，以后需要根据规则修改
function CTask:TakeNeedItem(pid,npcobj)
    if not self:ValidTakeItem(pid,npcobj) then
        return
    end
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if not oPlayer then
        return
    end
    for sid,iAmount in pairs(self.m_mNeedItem) do
        if not oPlayer:RemoveItemAmount(sid,iAmount) then
            return
        end
    end
    self:MissionDone()
end

function CTask:PopTakeItemUI(pid,npcobj)
    if not self:ValidTakeItem(pid,npcobj) then
        return
    end
    local mData = {}
    mData["taskid"]  = self.m_ID
    local func = function (oPlayer,mData)
        local mItemList = mData["itemlist"]
        local mAmount = {}
        for id,amount in pairs(mItemList) do
            local itemobj = oPlayer.m_oItemCtrl:HasItem(id)
            if not itemobj  or itemobj:GetAmount() < amount then
                return
            end
            local iShape = itemobj:Shape()
            if not mAmount[iShape] then
                mAmount[iShape] = 0
            end
            mAmount[iShape] = mAmount[iShape] + amount
        end
        for sid,iAmount in pairs(self.m_mNeedItem) do
            local iCommitAmount = mAmount[sid] or 0
            if iCommitAmount ~= iAmount then
                return
            end
        end
        local sReason = string.format("提交%s任务",self:Name())
        for id,amount in pairs(mItemList) do
            local itemobj = oPlayer.m_oItemCtrl:HasItem(id)
            if not itemobj or itemobj:GetAmount() < amount then
                return
            end
            itemobj:AddAmount(-amount,sReason)
        end
        self:MissionDone()
    end
    local oCbMgr = global.oCbMgr
    oCbMgr:SetCallBack(pid,"GS2CPopTaskItem",mData,nil,func)
end

function CTask:ValidTakeSummon()
    -- body
end

function CTask:TakeNeedSummon()
    -- body
end

--点击任务
function CTask:Click(pid)
    local iType = self:TaskType()
    local npcid
    local sc
    if extend.Table.find({gamedefines.TASK_TYPE.TASK_FIND_NPC,gamedefines.TASK_TYPE.TASK_NPC_FIGHT},iType) then
        npcid = self:Target()
    --暂时测试，以后更改
    elseif extend.Table.find({gamedefines.TASK_TYPE.TASK_FIND_ITEM,gamedefines.TASK_TYPE.TASK_FIND_SUMMON},iType) then
        npcid = 5201
    elseif extend.Table.find({gamedefines.TASK_TYPE.TASK_ANLEI},iType) then
        --
    end
    if npcid then
        local oNpc = self:GetNpcObj(npcid)
        if not oNpc then
            return
        end
        local iMap = oNpc:MapId()
        local iX = oNpc.m_mPosInfo["x"]
        local iZ = oNpc.m_mPosInfo["z"]
        local oSceneMgr = global.oSceneMgr
        oSceneMgr:SceneAutoFindPath(pid,iMap,iX,iZ,npcid,self:AutoType())
    end
end

function CTask:GetNpcObj(npcid)
    for _,oClientNpc in pairs(self.m_mClientNpc) do
        if oClientNpc.m_ID == npcid then
            return oClientNpc
        end
    end
    local oNpcMgr = global.oNpcMgr
    local oNpc = oNpcMgr:GetObject(npcid)
    return oNpc
end

function CTask:SetEvent(npctype,iEvent)
    self:Dirty()
    for _,oClientNpc in pairs(self.m_mClientNpc) do
        if oClientNpc:Type() == npctype then
            oClientNpc:SetEvent(iEvent)
            return
        end
    end
    --npc组
    if npctype < 1000 then
        local npclist = self:GetNpcGroupData(npctype)
        npctype = npclist[math.random(#npclist)]
        local oNpcMgr = global.oNpcMgr
        local oNpc = oNpcMgr:GetGlobalNpc(npctype)
        if not oNpc then
            oNpc = self:CreateClientNpc(npctype)
            oNpc:SetEvent(iEvent)
            return
        end
    end
    self.m_mEvent[npctype] = iEvent
end

function CTask:GetEvent(npcid)
     local oNpc = self:GetClientObj(npcid)
    local iEvent
    if oNpc then
        iEvent = oNpc.m_iEvent
    else
        oNpcMgr = global.oNpcMgr
        oNpc = oNpcMgr:GetObject(npcid)
        if not oNpc then
            return
        end
        local npctype = oNpc:Type()
        iEvent = self.m_mEvent[npctype]
    end
    return iEvent
end

function CTask:DoNpcEvent(pid,npcid)
    local oNpc = self:GetClientObj(npcid)
    local iEvent = self:GetEvent(npcid)
    if not iEvent then
        return
    end
    local mEvent = self:GetEventData(iEvent)
    if not mEvent then
        return
    end
    self:DoScript(pid,oNpc,mEvent["look"])
end

function CTask:Dialog(iDialog)
    local mData = self:GetDialogData(iDialog)
    if not mData then
        return
    end
    local mNet = {}
    mNet["dialog"] = mData
    if not npcobj then
        self:GS2CDialog(pid,mNet)
        return
    end
    local npcid = npcobj.m_ID
    local iEvent = self:GetEvent(npcid)
    if not iEvent then
        self:GS2CDialog(pid,mNet)
        return
    end
    local taskid = self.m_ID
    local func = function (oPlayer,mData)
        local oTask = oPlayer.m_oTaskCtrl:GetTask(taskid)
        if not oTask then
            return
        end
        local oNpc = self:GetNpcObj(npcid)
        if not oNpc then
            return
        end
        local mEvent = self:GetEventData(iEvent)
        oTask:DoScript(pid,oNpc,mEvent["answer"])
    end
    local mNet = {}
    mNet["dialog"] = mData
    local oCbMgr = global.oCbMgr
    oCbMgr:SetCallBack(pid,"GS2CDialog",mNet,nil,func)
end

function CTask:SayText(pid,npcobj,sText)
    if not npcobj then
        local mNet = {}
        mNet["text"] = sText
        local oWorldMgr = global.oWorldMgr
        local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
        if oPlayer then
            oPlayer:Send("GS2CNpcSay",mNet)
        end
        return
    end

    local npcid = npcobj.m_ID
    local iEvent = self:GetEvent(npcid)
    if not iEvent then
        npcobj:Say(sText)
        return
    end
    local mEvent = oTask:GetEventData(iEvent)
    local mAnswer = mEvent["answer"] or {}
    if tableop.table_count(mAnswer) == 0 then
        npcobj:Say(sText)
        return
    end
    self:SayRespondText(pid,npcobj,sText)
end

function CTask:SayRespondText(pid,npcobj,sText)
    if not npcobj then
        return
    end
    local taskid = self.m_ID
    local npcid = npcobj.m_ID
    local resfunc = function (oPlayer,mData)
        local oTask = oPlayer.m_oTaskCtrl:GetTask(taskid)
        if not oTask then
            return false
        end
        local oNpc = oTask:GetNpcObj(npcid)
        if not oNpc then
            return false
        end
        return true
    end
    local func = function (oPlayer,mData)
        local oTask = oPlayer.m_oTaskCtrl:GetTask(taskid)
        local oNpc = self:GetNpcObj(npcid)
        local iEvent = self:GetEvent(npcid)
        if not iEvent then
            return
        end
        local mEvent = oTask:GetEventData(iEvent)
        if not mEvent then
            return
        end
        local iAnswer = mData["answer"]
        local mAnswer = mEvent["answer"]
        local s = mAnswer[iAnswer] or ""
        self:DoScript(pid,oNpc,s)
    end
    npcobj:SayRespond(pid,sText,resfunc,func)
end

function CTask:TransString(pid,npcobj,s)
    if not s then
        return
    end
    if string.find(s,"{submitscene}") then
        local iTarget = self:Target()
        local oNpc = self:GetNpcObj(iTarget)
        assert(oNpc,string.format("TransString submitscene err:%d",pid,iTarget))
        local iMap = oNpc.m_iMapid
        local oSceneMgr = global.oSceneMgr
        local sSceneName = oSceneMgr:GetSceneName(iMap)
        s=gsub(s,"{submitscene}",sSceneName)
    end
    if string.find(s,"{submitnpc}") then
        local iTarget = self:Target()
        local oNpc = self:GetNpcObj(iTarget)
        assert(oNpc,string.format("TransString submitnpc err:%d %d",pid,iTarget))
        s = gsub(s,"{submitnpc}",oNpc:Name())
    end
    if string.find(s,"{item}") then
        for itemid,iAmount in pairs(self.m_mNeedItem) do
            local itemobj = loaditem.GetItem(itemid)
            s = gsub(s,"{item}",itemobj:Name())
            break
        end
    end
    if string.find(s,"{count}") then
        for itemid,iAmount in pairs(self.m_mNeedItem) do
            s = gsub(s,"{count}",iAmount)
            break
        end
    end
    return s
end

function CTask:Refresh(mNet)
    local iMask = 0
    local mArgs = {
            ["target"] = 1,
    }
    for key,iBit in pairs(mArgs) do
        if mNet[key] then
            iMask = iMask | (2^(iBit-1))
        end
    end
    mNet["mask"] = iMask
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(self.m_Owner)
    if oPlayer then
        oPlayer:Send("GS2CRefreshTask",mNet)
    end
end

function CTask:GS2CDialog(pid,mNet)
    local oWorldMgr = global.oWorldMgr
    local oPlayer = oWorldMgr:GetOnlinePlayerByPid(pid)
    if oPlayer then
        oPlayer:Send("GS2CDialog",mNet)
    end
end

function CTask:PackTaskInfo()
    local mNet = {}
    mNet["taskid"] = self.m_ID
    mNet["tasktype"] = self:TaskType()
    mNet["targetdesc"] = self:TargetDesc()
    mNet["detaildesc"] = self:DetailDesc()
    mNet["submitnpc"] = self:SubmitNpc()
    mNet["target"] = self:Target()
    local mData = {}
    local mNeedItem = self:NeedItem()
    for itemid,amount in pairs(mNeedItem) do
        table.insert(mData,{itemid=itemid,amount=amount})
    end
    mNet["needitem"] = mData
    mData = {}
    local mNeedSum = self:NeedSummon()
    for sumid,amount in pairs(mNeedSum) do
        table.insert(mData,{sumid=sumid,amount=amount})
    end
    mNet["needsum"] = mData
    mNet["rewardinfo"] = self:RewardInfo()
    mNet["time"] = self:Timer()
    mNet["isdone"] = self:IsDone()
    local mClientData = {}
    for _,oClientNpc in pairs(self.m_mClientNpc) do
        table.insert(mClientData,oClientNpc:PackInfo())
    end
    mNet["clientnpc"] = mClientData
    mNet["taskitem"] = self.m_mTaskItem

    return mNet
end