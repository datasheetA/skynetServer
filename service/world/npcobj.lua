--import module

local global = require "global"
local loadnpc = import(service_path("npc/loadnpc"))

function NewNpcMgr()
    local oMgr = CNpcMgr:New()
    return oMgr
end


CNpcMgr = {}
CNpcMgr.__index = CNpcMgr
inherit(CNpcMgr,logic_base_cls())

function CNpcMgr:New()
    local o = super(CNpcMgr).New(self)
    o.m_mObject = {}
    o.m_mGlobalList = {}
    o.m_mTempList = {}
    o.m_iDispatchId = 0
    return o
end

function CNpcMgr:DispatchId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CNpcMgr:NewGlobalNpc(npctype)
    local oNpc = loadnpc.NewNpc(npctype,npcid)
    self.m_mObject[oNpc.m_ID] = oNpc
    self.m_mGlobalList[npctype] = oNpc
    return oNpc
end

function CNpcMgr:GetObject(npcid)
    return self.m_mObject[npcid]
end

function CNpcMgr:GetGlobalNpc(npctype)
    return self.m_mGlobalList[npctype]
end

function CNpcMgr:GetTempGlobalNpc(npctype)
    local oNpc = self.m_mTempList[npctype]
    if not oNpc then
        oNpc = loadnpc.NewNpc(npctype)
    end
    self.m_mTempList[npctype] = oNpc
    return oNpc
end

function CNpcMgr:RemoveSceneNpc(npcid)
    local oNpc = self.m_mObject[npcid]
    local iScene = oNpc.m_Scene
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:GetScene(iScene)
    if oScene then
        oScene:RemoveSceneNpc(npcid)
        self.m_mObject[npcid] = npcid
    end
end

--初始化
function CNpcMgr:LoadInit()
    local extend = require "base.extend"
    local res = require "base.res"
    local mGlobalData = res["daobiao"]["global_npc"] or {}
    for npctype,mData in pairs(mGlobalData) do
        local oTempNpc = self:GetTempGlobalNpc(npctype)
        local iMapid = oTempNpc.m_iMapid
        local oSceneMgr = global.oSceneMgr
        local mScene = oSceneMgr:GetSceneListByMap(iMapid)
        for _,oScene in pairs(mScene) do
            local oNpc = self:NewGlobalNpc(npctype)
            oNpc:SetScene(oScene.m_ID)
             oScene:EnterNpc(oNpc)
        end
    end
end