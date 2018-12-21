--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function NewPlayer(...)
    local o = CPlayer:New(...)
    return o
end

CPlayer = {}
CPlayer.__index = CPlayer

function CPlayer:New(mConn, mRole)
    local o = setmetatable({}, self)

    o.m_iNetHandle = mConn.handle
    o.m_iPid = mRole.pid
    o.m_sAccount = mRole.account

    o.m_mSceneInfo = {}

    o.m_iDisconnectedTime = nil

    return o
end

function CPlayer:Release()
end

function CPlayer:GetAccount()
    return self.m_sAccount
end

function CPlayer:GetPid()
    return self.m_iPid
end

function CPlayer:GetNowScene()
    local m = self.m_mSceneInfo
    local oSceneMgr = global.oSceneMgr
    return oSceneMgr:GetScene(m.now_scene)
end

function CPlayer:GetNowPos()
    local m = self.m_mSceneInfo
    return m.now_pos
end

function CPlayer:SetSceneInfo(mInfo)
    local m = self.m_mSceneInfo
    if mInfo.now_scene then
        m.now_scene = mInfo.now_scene
    end
    if mInfo.now_pos then
        m.now_pos = mInfo.now_pos
    end
end

function CPlayer:GetConn()
    local oWorldMgr = global.oWorldMgr
    return oWorldMgr:GetConnection(self.m_iNetHandle)
end

function CPlayer:SetNetHandle(iNetHandle)
    self.m_iNetHandle = iNetHandle
    if iNetHandle then
        self.m_iDisconnectedTime = nil
    else
        self.m_iDisconnectedTime = get_msecond()
    end
end

function CPlayer:Send(sMessage, mData)
    local oConn = self:GetConn()
    if oConn then
        oConn:Send(sMessage, mData)
    end
end

function CPlayer:MailAddr()
    local oConn = self:GetConn()
    if oConn then
        return oConn:MailAddr()
    end
end

function CPlayer:OnLogin(bReEnter)
    self:Send("GS2CLoginRole", {role = {account = self:GetAccount(), pid = self:GetPid()}})
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:OnLogin(self, bReEnter)
end
