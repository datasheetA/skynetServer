
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

function CPlayerEntity:GetPid()
    return self.m_iPid
end

function CPlayerEntity:Send(sMessage, mData)
    if self.m_mMail then
        net.Send(self.m_mMail, sMessage, mData)
    end
end

function CPlayerEntity:Disconnected()
    self.m_mMail = nil
end

function CPlayerEntity:SendRaw(sData)
    if self.m_mMail then
        net.SendRaw(self.m_mMail, sData)
    end
end

function CPlayerEntity:ReEnter(mMail)
    self.m_mMail = mMail

    local mPos = self:GetPos()
    self:Send("GS2CEnterScene", {
        scene_id = self:GetSceneId(),
        eid = self:GetEid(),
        pos_info = {
            v = geometry.Cover(self:GetSpeed()),
            x = geometry.Cover(mPos.x),
            y = geometry.Cover(mPos.y),
            z = geometry.Cover(mPos.z),
            face_x = geometry.Cover(mPos.face_x),
            face_y = geometry.Cover(mPos.face_y),
            face_z = geometry.Cover(mPos.face_z),
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
            v = geometry.Cover(self:GetSpeed()),
            x = geometry.Cover(mPos.x),
            y = geometry.Cover(mPos.y),
            z = geometry.Cover(mPos.z),
            face_x = geometry.Cover(mPos.face_x),
            face_y = geometry.Cover(mPos.face_y),
            face_z = geometry.Cover(mPos.face_z),
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
            v = geometry.Cover(mPosInfo.v),
            x = geometry.Cover(mPosInfo.x),
            y = geometry.Cover(mPosInfo.y),
            z = geometry.Cover(mPosInfo.z),
            face_x = geometry.Cover(mPosInfo.face_x),
            face_y = geometry.Cover(mPosInfo.face_y),
            face_z = geometry.Cover(mPosInfo.face_z),
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
