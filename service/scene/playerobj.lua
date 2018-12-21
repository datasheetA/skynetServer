
local global = require "global"
local skynet = require "skynet"
local laoi = require "laoi"
local interactive = require "base.interactive"
local net = require "base.net"
local geometry = require "base.geometry"

local gamedefines = import(lualib_path("public.gamedefines"))
local CEntity = import(service_path("entityobj")).CEntity

function NewPlayerEntity(...)
    return CPlayerEntity:New(...)
end

CPlayerEntity = {}
CPlayerEntity.__index = CPlayerEntity
inherit(CPlayerEntity, CEntity)

function CPlayerEntity:New(iEid, iPid, mMail)
    local o = super(CPlayerEntity).New(self, iEid)
    o.m_iType = gamedefines.SCENE_ENTITY_TYPE.PLAYER_TYPE
    o.m_iPid = iPid
    o.m_mMail = mMail
    return o
end

function CPlayerEntity:Release()
end

function CPlayerEntity:GetPid()
    return self.m_iPid
end

function CPlayerEntity:Send(sMessage, mData)
    net.Send(self.m_mMail, sMessage, mData)
end

function CPlayerEntity:SendRaw(sData)
    net.SendRaw(self.m_mMail, sData)
end

function CPlayerEntity:ReEnter(mMail)
    self.m_mMail = mMail

    local mPos = self:GetPos()
    self:Send("GS2CEnterScene", {
        scene_id = self:GetSceneId(),
        eid = self:GetEid(),
        pos_info = {
            v = geometry.cover(self:GetSpeed()),
            x = geometry.cover(mPos.x),
            y = geometry.cover(mPos.y),
            z = geometry.cover(mPos.z),
            face_x = geometry.cover(mPos.face_x),
            face_y = geometry.cover(mPos.face_y),
            face_z = geometry.cover(mPos.face_z),
        }
    })

    local mMarker = self:GetMarkerMap()
    for k, _ in pairs(mMarker) do
        local oMarker = self:GetEntity(k)
        if oMarker then
            self:Send("GS2CEnterAoi", {
                scene_id = oMarker:GetSceneId(),
                eid = oMarker:GetEid(),
                type = oMarker:Type(),
                aoi_player = oMarker:GetAoiInfo(),
            })
        end
    end
end

function CPlayerEntity:GetAoiInfo()
    local mPos = self:GetPos()
    local m = {
        pid = self:GetPid(),
        pos_info = {
            v = geometry.cover(self:GetSpeed()),
            x = geometry.cover(mPos.x),
            y = geometry.cover(mPos.y),
            z = geometry.cover(mPos.z),
            face_x = geometry.cover(mPos.face_x),
            face_y = geometry.cover(mPos.face_y),
            face_z = geometry.cover(mPos.face_z),
        }
    }
    return m
end

function CPlayerEntity:OnEnterAoi(oMarker)
    self:Send("GS2CEnterAoi", {
        scene_id = oMarker:GetSceneId(),
        eid = oMarker:GetEid(),
        type = oMarker:Type(),
        aoi_player = oMarker:GetAoiInfo(),
    })
end

function CPlayerEntity:OnLeaveAoi(oMarker)
    self:Send("GS2CLeaveAoi", {
        scene_id = oMarker:GetSceneId(),
        eid = oMarker:GetEid(),
    })
end

--lxldebug
function CPlayerEntity:SyncPos(mPosInfo)
    self:SendAoi("GS2CSyncPos", {
        scene_id = self:GetSceneId(),
        eid = self:GetEid(),
        pos_info = {
            v = geometry.cover(mPosInfo.v),
            x = geometry.cover(mPosInfo.x),
            y = geometry.cover(mPosInfo.y),
            z = geometry.cover(mPosInfo.z),
            face_x = geometry.cover(mPosInfo.face_x),
            face_y = geometry.cover(mPosInfo.face_y),
            face_z = geometry.cover(mPosInfo.face_z),
        }
    })

    self:SetPos({
        x = mPosInfo.x,
        y = mPosInfo.y,
        z = mPosInfo.z,
        face_x = mPosInfo.face_x,
        face_y = mPosInfo.face_y,
        face_z = mPosInfo.face_z,
    })
    self:SetSpeed(mPosInfo.v)
end
