--import module
local skynet = require "skynet"
local global = require "global"

local datactrl = import(lualib_path("public.datactrl"))

CPlayerActiveCtrl = {}
CPlayerActiveCtrl.__index = CPlayerActiveCtrl
inherit(CPlayerActiveCtrl, datactrl.CDataCtrl)

function CPlayerActiveCtrl:New(pid)
    local o = super(CPlayerActiveCtrl).New(self, {pid = pid})
    o.m_mNowSceneInfo = nil
    o.m_mNowWarInfo = nil
    return o
end

function CPlayerActiveCtrl:Load(mData)
    local mData = mData or {}

    local mSceneInfo = mData.scene_info
    if not mSceneInfo then
        mSceneInfo = {
            map_id = 1001,
            pos = {
                x = 100,
                y = 100,
                z = 0,
                face_x = 0,
                face_y = 0,
                face_z = 0,
            },
        }
    end
    self:SetData("scene_info", mSceneInfo)
end

function CPlayerActiveCtrl:Save()
    local mData = {}
    mData.scene_info = self:GetData("scene_info")
    return mData
end

function CPlayerActiveCtrl:SetDurableSceneInfo(iMapId, mPos)
    local m = {
        map_id = iMapId,
        pos = mPos,
    }
    self:SetData("scene_info", m)
end

function CPlayerActiveCtrl:GetDurableSceneInfo()
    return self:GetData("scene_info")
end

function CPlayerActiveCtrl:GetNowWar()
    local m = self.m_mNowWarInfo
    if not m then
        return
    end
    local oWarMgr = global.oWarMgr
    return oWarMgr:GetWar(m.now_war)
end

function CPlayerActiveCtrl:GetNowScene()
    local m = self.m_mNowSceneInfo
    if not m then
        return
    end
    local oSceneMgr = global.oSceneMgr
    return oSceneMgr:GetScene(m.now_scene)
end

function CPlayerActiveCtrl:GetNowPos()
    local m = self.m_mNowSceneInfo
    if not m then
        return m
    end
    return m.now_pos
end

function CPlayerActiveCtrl:SetNowSceneInfo(mInfo)
    local m = self.m_mNowSceneInfo
    if not m then
        self.m_mNowSceneInfo = {}
        m = self.m_mNowSceneInfo
    end
    if mInfo.now_scene then
        m.now_scene = mInfo.now_scene
    end
    if mInfo.now_pos then
        m.now_pos = mInfo.now_pos
    end
end

function CPlayerActiveCtrl:SetNowWarInfo(mInfo)
    local m = self.m_mNowWarInfo
    if not m then
        self.m_mNowWarInfo = {}
        m = self.m_mNowWarInfo
    end
    if mInfo.now_war then
        m.now_war = mInfo.now_war
    end
end
