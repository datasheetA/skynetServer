--import module
local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))

CPlayerBaseCtrl = {}
CPlayerBaseCtrl.__index = CPlayerBaseCtrl
inherit(CPlayerBaseCtrl, datactrl.CDataCtrl)

function CPlayerBaseCtrl:New(pid)
    local o = super(CPlayerBaseCtrl).New(self, {pid = pid})
    return o
end

function CPlayerBaseCtrl:Load(mData)
    local mData = mData or {}
    self:SetData("grade", mData.grade or 0)
    self:SetData("name", mData.name or string.format("DEBUG%d", self:GetInfo("pid")))
end

function CPlayerBaseCtrl:Save()
    local mData = {}
    mData.grade = self:GetData("grade", 0)
    mData.name = self:GetData("name")
    return mData
end
