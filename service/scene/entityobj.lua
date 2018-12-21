--import module

local global = require "global"
local skynet = require "skynet"
local laoi = require "laoi"
local interactive = require "base.interactive"
local net = require "base.net"

local gamedefines = import(lualib_path("public.gamedefines"))


CEntity = {}
CEntity.__index = CEntity

function CEntity:New(iEid)
    local o = setmetatable({}, self)
    o.m_iType = gamedefines.SCENE_ENTITY_TYPE.ENTITY_TYPE
    o.m_iEid = iEid
    o.m_iScene = nil
    o.m_sAoiMode = nil
    o.m_mPos = nil
    o.m_fSpeed = 0
    o.m_mWatcher = {}
    o.m_mMarker = {}
    return o
end

function CEntity:Release()
end

function CEntity:Type()
    return self.m_iType
end

function CEntity:Init(mInit)
    self.m_sAoiMode = mInit.aoi_mode or "wm"
    self.m_iScene = mInit.scene_id

    local mPos = mInit.pos
    local m = {}
    m.x = mPos.x or 0
    m.y = mPos.y or 0
    m.z = mPos.z or 0
    m.face_x = mPos.face_x or 0
    m.face_y = mPos.face_y or 0
    m.face_z = mPos.face_z or 0
    self.m_mPos = mPos

    self.m_fSpeed = mInit.speed

    self:CheckAoi()
end

function CEntity:GetEid()
    return self.m_iEid
end

function CEntity:GetSceneId()
    return self.m_iScene
end

function CEntity:GetAoiMode()
    return self.m_sAoiMode
end

function CEntity:UpdateEntityToAoi(sMode)
    local oScene = self:GetScene()
    oScene:UpdateEntityToAoi(self:GetEid(), sMode)
end

function CEntity:SetSpeed(fSpeed)
    self.m_fSpeed = fSpeed
end

function CEntity:SetPos(mPos)
    local m = self.m_mPos
    m.x = mPos.x or 0
    m.y = mPos.y or 0
    m.z = mPos.z or 0
    m.face_x = mPos.face_x or 0
    m.face_y = mPos.face_y or 0
    m.face_z = mPos.face_z or 0
    self:UpdateEntityToAoi()
end

function CEntity:IsOutOfAoi(o)
    local mPos1 = self:GetPos()
    local mPos2 = o:GetPos()
    return ((mPos1.x - mPos2.x) ^ 2 + (mPos1.y - mPos2.y) ^ 2) > gamedefines.SCENE_AOI_DIS ^ 2
end

--lxldebug
function CEntity:CheckAoi()
    local iEid = self:GetEid()
    local iScene = self:GetSceneId()
    local f
    f = function ()
        local oSceneMgr = global.oSceneMgr
        local oScene = oSceneMgr:GetScene(iScene)
        if oScene then
            local oEntity = oScene:GetEntity(iEid)
            if oEntity then
                local mMarker = oEntity:GetMarkerMap()
                for k, _ in pairs(mMarker) do
                    local oMarker = oEntity:GetEntity(k)
                    if oMarker and self:IsOutOfAoi(oMarker) then
                        oEntity:LeaveAoi(oMarker)
                    end
                end
            end
        end
        skynet.timeout(3 * 100, f)
    end
    f()
end

function CEntity:GetScene()
    local oSceneMgr = global.oSceneMgr
    return oSceneMgr:GetScene(self:GetSceneId())
end

function CEntity:GetEntity(iEid)
    local oScene = self:GetScene()
    return oScene:GetEntity(iEid)
end

function CEntity:GetPos()
    return self.m_mPos
end

function CEntity:GetSpeed()
    return self.m_fSpeed
end

function CEntity:GetWatcherMap()
    return self.m_mWatcher
end

function CEntity:GetMarkerMap()
    return self.m_mMarker
end

function CEntity:AddWatcher(oWatcher)
    self.m_mWatcher[oWatcher:GetEid()] = true
end

function CEntity:DelWatcher(oWatcher)
    self.m_mWatcher[oWatcher:GetEid()] = nil
end

function CEntity:EnterAoi(oMarker)
    if not self.m_mMarker[oMarker:GetEid()] then
        self.m_mMarker[oMarker:GetEid()] = true
        oMarker:AddWatcher(self)
        self:OnEnterAoi(oMarker)
    end
end

function CEntity:LeaveAoi(oMarker)
    if self.m_mMarker[oMarker:GetEid()] then
        self.m_mMarker[oMarker:GetEid()] = nil
        oMarker:DelWatcher(self)
        self:OnLeaveAoi(oMarker)
    end
end

function CEntity:OnEnterAoi(oMarker)
end

function CEntity:OnLeaveAoi(oMarker)
end

function CEntity:Send(sMessage, mData)
end

function CEntity:SendRaw(sData)
end

function CEntity:SendAoi(sMessage, mData, bInclude, mExclude)
    local sData = net.PackData(sMessage, mData)
    mExclude = mExclude or {}

    if bInclude then
        if not mExclude[self:GetEid()] then
            self:SendRaw(sData)
        end
    end

    for k, _ in pairs(self.m_mWatcher) do
        if not mExclude[self:GetEid()] then
            local o = self:GetEntity(k)
            if o then
                o:SendRaw(sData)
            end
        end
    end
end
