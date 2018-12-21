--import module

local global = require "global"
local skynet = require "skynet"
local laoi = require "laoi"
local geometry = require "base.geometry"

local gamedefines = import(lualib_path("public.gamedefines"))
local playerobj = import(service_path("playerobj"))

function NewScene(...)
    local o = CScene:New(...)
    return o
end

CScene = {}
CScene.__index = CScene
inherit(CScene, logic_base_cls())

function CScene:New(id)
    local o = super(CScene).New(self)
    o.m_iScene = id
    o.m_oAoi = laoi.laoi_create(gamedefines.SCENE_AOI_DIS)

    o.m_mEntitys = {}
    o.m_mPlayers = {}
    return o
end

function CScene:Release()
    for _, v in pairs(self.m_mEntitys) do
        v:Release()
    end
    self.m_mEntitys = {}
    super(CScene).Release(self)
end

function CScene:Init(mInit)
    local f1
    f1 = function ()
        self:DelTimeCb("_CheckAoiSchedule")
        self:AddTimeCb("_CheckAoiSchedule", 1*100, f1)
        self:_CheckAoiSchedule()
    end
    f1()
end

function CScene:GetSceneId()
    return self.m_iScene
end

function CScene:GetEntity(id)
    return self.m_mEntitys[id]
end

function CScene:GetPlayerEntity(id)
    local id = self.m_mPlayers[id]
    if id then
        return self.m_mEntitys[id]
    end
end

--lxldebug
function CScene:_CheckAoiSchedule()
    assert(not self:IsRelease(), "_CheckAoiSchedule fail")
    local l = self.m_oAoi:laoi_message()
    for _, v in ipairs(l) do
        local iWatcher, iMarker = v[1], v[2]
        local oWatcher = self:GetEntity(iWatcher)
        local oMarker = self:GetEntity(iMarker)
        if oWatcher and oMarker then
            oWatcher:EnterAoi(oMarker)
        end
    end
end

function CScene:UpdateEntityToAoi(iEid, sMode)
    local oEntity = self:GetEntity(iEid)
    if oEntity then
        local mPos = oEntity:GetPos()
        local sAoiMode = sMode or oEntity:GetAoiMode()
        self.m_oAoi:laoi_update(iEid, sAoiMode, mPos.x, mPos.y, mPos.z)
    end
end

function CScene:Enter(obj)
    sMode = sMode or "wm"
    self.m_mEntitys[obj:GetEid()] = obj
    self:UpdateEntityToAoi(obj:GetEid())
    return obj
end

function CScene:Leave(obj)
    local mWatcher = obj:GetWatcherMap()
    for k, _ in pairs(mWatcher) do
        local oWatcher = self:GetEntity(k)
        if oWatcher then
            oWatcher:LeaveAoi(obj)
        end
    end
    self.m_mEntitys[obj:GetEid()] = nil
    obj:Release()
    self:UpdateEntityToAoi(iEid, "d")
end

function CScene:EnterPlayer(iPid, iEid, mMail, mPos)
    assert(not self.m_mPlayers[iPid], string.format("EnterPlayer error %d %d", iPid, iEid))
    local obj = playerobj.NewPlayerEntity(iEid, iPid, mMail)
    self.m_mPlayers[iPid] = iEid
    obj:Init({
        aoi_mode = "wm",
        scene_id = self:GetSceneId(),
        pos = mPos,
        speed = 0,
    })

    obj:Send("GS2CEnterScene", {
        scene_id = self:GetSceneId(),
        eid = obj:GetEid(),
        pos_info = {
            v = geometry.Cover(obj:GetSpeed()),
            x = geometry.Cover(mPos.x),
            y = geometry.Cover(mPos.y),
            z = geometry.Cover(mPos.z),
            face_x = geometry.Cover(mPos.face_x),
            face_y = geometry.Cover(mPos.face_y),
            face_z = geometry.Cover(mPos.face_z),
        }
    })

    return self:Enter(obj)
end

function CScene:LeavePlayer(iPid)
    local eid = self.m_mPlayers[iPid]
    local obj = self:GetEntity(eid)
    if obj then
        self:Leave(obj)
        self.m_mPlayers[iPid] = nil
    end
end

function CScene:ReEnterPlayer(iPid, mMail)
    local oEntity = self:GetPlayerEntity(iPid)
    assert(oEntity, string.format("ReEnterPlayer error %d", iPid))
    oEntity:ReEnter(mMail)
end
