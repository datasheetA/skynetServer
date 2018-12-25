--import module
local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))
local playernet = import(service_path("netcmd/player"))

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
    self:SetData("point", mData.point or 0)
    self:SetData("name", mData.name or string.format("DEBUG%d", self:GetInfo("pid")))
    self:SetData("phy_critical_ratio", mData.phy_critical_ratio or 5)
    self:SetData("res_phy_critical_ratio", mData.res_phy_critical_ratio or 0)
    self:SetData("mag_critical_ratio", mData.mag_critical_ratio or 0)
    self:SetData("res_mag_critical_ratio", mData.res_mag_critical_ratio or 0)
    self:SetData("seal_ratio", mData.seal_ratio or 0)
    self:SetData("res_seal_ratio", mData.res_seal_ratio or 0)
    self:SetData("hit_ratio", mData.hit_ratio or 100)
    self:SetData("hit_res_ratio", mData.hit_res_ratio or 5)
    self:SetData("physique", mData.physique or 10)
    self:SetData("strength", mData.strength or 10)
    self:SetData("magic", mData.magic or 10)
    self:SetData("endurance", mData.endurance or 10)
    self:SetData("agility", mData.agility or 10)
    self:SetData("model_info", mData.model_info)
    self:SetData("school", mData.school)
end

function CPlayerBaseCtrl:Save()
    local mData = {}

    mData.grade = self:GetData("grade")
    mData.point = self:GetData("point")
    mData.name = self:GetData("name")
    mData.phy_critical_ratio = self:GetData("phy_critical_ratio")
    mData.res_phy_critical_ratio = self:GetData("res_phy_critical_ratio")
    mData.mag_critical_ratio = self:GetData("mag_critical_ratio")
    mData.res_mag_critical_ratio = self:GetData("res_mag_critical_ratio")
    mData.seal_ratio = self:GetData("seal_ratio")
    mData.res_seal_ratio = self:GetData("res_seal_ratio")
    mData.hit_ratio = self:GetData("hit_ratio")
    mData.hit_res_ratio = self:GetData("hit_res_ratio")
    mData.physique = self:GetData("physique")
    mData.strength = self:GetData("strength")
    mData.magic = self:GetData("magic")
    mData.endurance = self:GetData("endurance")
    mData.agility = self:GetData("agility")
    mData.model_info = self:GetData("model_info")
    mData.school = self:GetData("school")
    return mData
end
