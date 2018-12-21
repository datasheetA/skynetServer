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


BlockHelperFunc = {}
BlockHelperDef = {}

BlockHelperDef.name = 2
function BlockHelperFunc.name(oEntity)
    return oEntity:GetName()
end

BlockHelperDef.model_info = 3
function BlockHelperFunc.model_info(oEntity)
    return oEntity:GetModelInfo()
end


CNpcEntity = {}
CNpcEntity.__index = CNpcEntity
inherit(CNpcEntity, CEntity)

function CNpcEntity:New(iEid, iPid, mMail)
    local o = super(CNpcEntity).New(self, iEid)
    o.m_iType = gamedefines.SCENE_ENTITY_TYPE.NPC_TYPE
    return o
end

function CNpcEntity:GetAoiInfo()
    local mPos = self:GetPos()
    local m = {
        npctype = self:GetData("npctype"),
        npcid = self:GetData("npcid"),
        pos_info = {
            v = geometry.Cover(self:GetSpeed()),
            x = geometry.Cover(mPos.x),
            y = geometry.Cover(mPos.y),
            z = geometry.Cover(mPos.z),
            face_x = geometry.Cover(mPos.face_x),
            face_y = geometry.Cover(mPos.face_y),
            face_z = geometry.Cover(mPos.face_z),
        },
        block = self:BlockInfo(),
    }
    return m
end

function CNpcEntity:BlockInfo(m)
    local mRet = {}
    if not m then
        m = BlockHelperDef
    end
    local iMask = 0
    for k, _ in pairs(m) do
        local i = assert(BlockHelperDef[k], string.format("BlockInfo fail i get %s", k))
        local f = assert(BlockHelperFunc[k], string.format("BlockInfo fail f get %s", k))
        mRet[k] = f(self)
        iMask = iMask | (2^(i-1))
    end
    mRet.mask = iMask
    return mRet
end

function CNpcEntity:BlockChange(...)
    local l = table.pack(...)
    local m = {}
    for _, v in ipairs(l) do
        m[v] = true
    end
    local mBlock = self:BlockInfo(m)
    self:SendAoi("GS2CSyncAoi", {
        scene_id = self:GetSceneId(),
        eid = self:GetEid(),
        type = self:Type(),
        aoi_npc_block = mBlock,
    })
end

function CNpcEntity:SyncInfo(mArgs)
    if mArgs.name then
        self:SetData("name", mArgs.name)
        self:BlockChange("name")
    end
    if mArgs.model_info then
        self:SetData("model_info", mArgs.model_info)
        self:BlockChange("model_info")
    end
end
