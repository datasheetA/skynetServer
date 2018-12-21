local global = require "global"
local skynet = require "skynet"
local laoi = require "laoi"
local interactive = require "base.interactive"
local net = require "base.net"
local geometry = require "base.geometry"

local gamedefines = import(lualib_path("public.gamedefines"))
local CEntity = import(service_path("entityobj")).CEntity

function NewNpcEntity(...)
    return CNpcEntity:New(...)
end

CNpcEntity = {}
CNpcEntity.__index = CNpcEntity
inherit(CNpcEntity, CEntity)

function CNpcEntity:New(iEid, iPid, mMail)
    local o = super(CNpcEntity).New(self, iEid)
    o.m_iType = gamedefines.SCENE_ENTITY_TYPE.NPC_TYPE
    return o
end

function CNpcEntity:Init(mInit)
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

    local mData = mInit.data
    self.m_mData = mData
end

function CNpcEntity:GetAoiInfo()
    local mData = self.m_mData or {}
    local mPos = self:GetPos()
    local mDesc = {
            scale = mData.scale,
            color = mData.color,
            mutateTexture = mData.mutateTexture,
            weapon = mData.weapon,
            adorn = mData.adorn
    }
    local mBlock = {
        mask = 255,
    }
    local m = {
        block = mBlock,
        pos_info = {
            v = geometry.Cover(self:GetSpeed()),
            x = geometry.Cover(mPos.x),
            y = geometry.Cover(mPos.y),
            z = geometry.Cover(mPos.z),
            face_x = geometry.Cover(mPos.face_x),
            face_y = geometry.Cover(mPos.face_y),
            face_z = geometry.Cover(mPos.face_z),
        },
        npctype = mData.npctype,
        npcid = mData.npcid,
        name = mData.name,
        title = mData.title,
        model = mData.model,
        desc = mDesc,
    }
    return m
end

function CNpcEntity:SyncInfo(mArgs)
end