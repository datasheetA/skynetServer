--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local sceneobj = import(service_path("sceneobj"))

function NewSceneMgr(...)
    local o = CSceneMgr:New(...)
    return o
end

CSceneMgr = {}
CSceneMgr.__index = CSceneMgr
inherit(CSceneMgr, logic_base_cls())

function CSceneMgr:New()
    local o = super(CSceneMgr).New(self)
    o.m_mScenes = {}
    o.m_mEntityAoiChange = {}
    return o
end

function CSceneMgr:Release()
    for _, v in pairs(self.m_mScenes) do
        v:Release()
    end
    self.m_mScenes = {}
    super(CSceneMgr).Release(self)
end

function CSceneMgr:ConfirmRemote(iScene)
    assert(not self.m_mScenes[iScene], string.format("ConfirmRemote error %d", iScene))
    local oScene = sceneobj.NewScene(iScene)
    oScene:Init()
    self.m_mScenes[iScene] = oScene
end

function CSceneMgr:GetScene(iScene)
    return self.m_mScenes[iScene]
end

function CSceneMgr:RemoveScene(iScene)
    local oScene = self.m_mScenes[iScene]
    if oScene then
        self.m_mScenes[iScene] = nil
        oScene:Release()
    end
end

function CSceneMgr:SetEntityAoiChange(iScene, iEid, l)
    local m1 = self.m_mEntityAoiChange[iScene]
    if not m1 then
        m1 = {}
        self.m_mEntityAoiChange[iScene] = m1
    end
    local m2 = m1[iEid]
    if not m2 then
        m2 = {}
        m1[iEid] = m2
    end

    for _, v in ipairs(l) do
        m2[v] = true
    end
end

function CSceneMgr:SceneDispatchFinishHook()
    local m1 = self.m_mEntityAoiChange
    for k, v in pairs(m1) do
        local oScene = self:GetScene(k)
        if oScene then
            for k2, v2 in pairs(v) do
                local o = oScene:GetEntity(k2)
                if o and next(v2) then
                    o:ClientBlockChange(v2)
                end
            end
        end
    end
    self.m_mEntityAoiChange = {}
end
