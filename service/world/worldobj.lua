--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local gamedefines = import(lualib_path("public.gamedefines"))
local playerobj = import(service_path("playerobj"))
local connectionobj = import(service_path("connectionobj"))

function NewWorldMgr(...)
    local o = CWorldMgr:New(...)
    return o
end

CWorldMgr = {}
CWorldMgr.__index = CWorldMgr
inherit(CWorldMgr, logic_base_cls())

function CWorldMgr:New()
    local o = super(CWorldMgr).New(self)
    o.m_mOnlinePlayers = {}
    o.m_mLoginPlayers = {}
    o.m_mLogoutPlayers = {}

    o.m_mConnections = {}
    return o
end

function CWorldMgr:Release()
    for _, v in ipairs({self.m_mOnlinePlayers, self.m_mLoginPlayers, self.m_mLogoutPlayers}) do
        for _, v2 in pairs(v) do
            v:Release()
        end
    end
    for _, v in pairs(self.m_mConnections) do
        v:Release()
    end
    self.m_mOnlinePlayers = {}
    self.m_mLoginPlayers = {}
    self.m_mLogoutPlayers = {}
    self.m_mConnections = {}
    super(CWorldMgr).Release(self)
end

function CWorldMgr:GetConnection(iHandle)
    return self.m_mConnections[iHandle]
end

function CWorldMgr:DelConnection(iHandle)
    local oConnection = self.m_mConnections[iHandle]
    if oConnection then
        self.m_mConnections[iHandle] = nil
        oConnection:Disconnected()
        oConnection:Release()
    end
end

function CWorldMgr:FindPlayerAnywayByPid(pid)
    local obj
    for _, m in ipairs({self.m_mLoginPlayers, self.m_mOnlinePlayers, self.m_mLogoutPlayers}) do
        obj = m[pid]
        if obj then
            break
        end
    end
    return obj
end

function CWorldMgr:FindPlayerAnywayByFd(iHandle)
    local oConnection = self:GetConnection(iHandle)
    if oConnection then
        local iPid = oConnection:GetOwnerPid()
        return self:FindPlayerAnywayByPid(iPid)
    end
end

function CWorldMgr:GetOnlinePlayerByFd(iHandle)
    local oConnection = self:GetConnection(iHandle)
    if oConnection then
        local iPid = oConnection:GetOwnerPid()
        return self.m_mOnlinePlayers[iPid]
    end
end

function CWorldMgr:GetOnlinePlayerByPid(iPid)
    return self.m_mOnlinePlayers[iPid]
end

function CWorldMgr:KickConnection(iHandle)
    local oConnection = self:GetConnection(iHandle)
    if oConnection then
        self:DelConnection(iHandle)
        skynet.send(oConnection.m_iGateAddr, "text", "kick", oConnection.m_iHandle)
    end
end

function CWorldMgr:Logout(iPid)
    local oPlayer = self.m_mLoginPlayers[iPid]
    if oPlayer then
        self.m_mLoginPlayers[iPid] = nil
        return
    end
    oPlayer = self.m_mOnlinePlayers[iPid]
    if oPlayer then
        self.m_mOnlinePlayers[iPid] = nil
        self.m_mLogoutPlayers[iPid] = oPlayer
        if oPlayer then
            oPlayer:OnLogout()
        end        
        self.m_mLogoutPlayers[iPid] = nil
        oPlayer:Release()
    end
end

function CWorldMgr:Login(mRecord, mConn, mRole)
    local pid = mRole.pid
    if self.m_mLoginPlayers[pid] then
        interactive.Send(mRecord.source, "login", "LoginResult", {pid = pid, handle = mConn.handle, errcode = gamedefines.ERRCODE.in_login})
        return
    end
    if self.m_mLogoutPlayers[pid] then
        interactive.Send(mRecord.source, "login", "LoginResult", {pid = pid, handle = mConn.handle, errcode = gamedefines.ERRCODE.in_logout})
        return
    end

    local oPlayer = self.m_mOnlinePlayers[pid]
    if oPlayer then
        local oOldConn = oPlayer:GetConn()
        if oOldConn and oOldConn.m_iHandle ~= mConn.handle then
            self:KickConnection(oOldConn.m_iHandle)
        end

        local oConnection = connectionobj.NewConnection(mConn, pid)
        oConnection:Forward()
        self.m_mConnections[mConn.handle] = oConnection

        oPlayer:OnLogin(true)
        interactive.Send(mRecord.source, "login", "LoginResult", {pid = pid, handle = mConn.handle, errcode = gamedefines.ERRCODE.ok})
        return
    else
        local oPlayer = playerobj.NewPlayer(mConn, mRole)
        self.m_mLoginPlayers[oPlayer:GetPid()] = oPlayer

        local oConnection = connectionobj.NewConnection(mConn, pid)
        oConnection:Forward()
        self.m_mConnections[mConn.handle] = oConnection

        interactive.Request(".gamedb", "playerdb", "GetPlayer", {pid = pid}, function (mRecord, mData)
            if not self:IsRelease() then
                self:_LoginRole1(mRecord, mData)
            end
        end)
        return
    end
end

function CWorldMgr:_LoginRole1(mRecord, mData)
    local pid = mData.pid
    local m = mData.data
    local oPlayer = self.m_mLoginPlayers[pid]
    if not oPlayer then
        return
    end

    if not m then
        self.m_mLoginPlayers[pid] = nil
        local oConn = oPlayer:GetConn()
        if oConn then
            interactive.Send(".login", "login", "LoginResult", {pid = pid, handle = oConn.m_iHandle, errcode = gamedefines.ERRCODE.not_exist_player})
        end
        return
    end

    interactive.Request(".gamedb", "playerdb", "LoadPlayerBase", {pid = pid}, function (mRecord, mData)
        if not self:IsRelease() then
            self:_LoginRole2(mRecord, mData)
        end
    end)
end

function CWorldMgr:_LoginRole2(mRecord, mData)
    local pid = mData.pid
    local m = mData.data
    local oPlayer = self.m_mLoginPlayers[pid]
    if not oPlayer then
        return
    end

    oPlayer.m_oBaseCtrl:Load(m)

    interactive.Request(".gamedb", "playerdb", "LoadPlayerActive", {pid = pid}, function (mRecord, mData)
        if not self:IsRelease() then
            self:_LoginRole3(mRecord, mData)
        end
    end)
end

function CWorldMgr:_LoginRole3(mRecord, mData)
    local pid = mData.pid
    local m = mData.data
    local oPlayer = self.m_mLoginPlayers[pid]
    if not oPlayer then
        return
    end

    oPlayer.m_oActiveCtrl:Load(m)

    self.m_mLoginPlayers[pid] = nil
    self.m_mOnlinePlayers[pid] = oPlayer

    oPlayer:OnLogin(false)
    local oConn = oPlayer:GetConn()
    if oConn then
        interactive.Send(".login", "login", "LoginResult", {pid = pid, handle = oConn.m_iHandle, errcode = gamedefines.ERRCODE.ok})
    end
end
