--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local gamedefines = import(lualib_path("public.gamedefines"))
local sceneobj = import(service_path("sceneobj"))

function NewSceneMgr(...)
    local o = CSceneMgr:New(...)
    return o
end

CSceneMgr = {}
CSceneMgr.__index = CSceneMgr

function CSceneMgr:New()
    local o = setmetatable({}, self)
    o.m_mScenes = {}
    return o
end

function CSceneMgr:Release()
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
