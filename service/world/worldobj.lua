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

function CWorldMgr:GetConnection(iHandle)
    return self.m_mConnections[iHandle]
end

function CWorldMgr:DelConnection(iHandle)
    local oConnection = self.m_mConnections[iHandle]
    if oConnection then
        self.m_mConnections[iHandle] = nil
        oConnection:Disconnected()
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
        --lxldebug todo load db
        local oPlayer = playerobj.NewPlayer(mConn, mRole)
        self.m_mLoginPlayers[oPlayer:GetPid()] = oPlayer

        local oConnection = connectionobj.NewConnection(mConn, pid)
        oConnection:Forward()
        self.m_mConnections[mConn.handle] = oConnection

        self.m_mLoginPlayers[oPlayer:GetPid()] = nil
        self.m_mOnlinePlayers[oPlayer:GetPid()] = oPlayer

        oPlayer:OnLogin(false)
        interactive.Send(mRecord.source, "login", "LoginResult", {pid = pid, handle = mConn.handle, errcode = gamedefines.ERRCODE.ok})
    end
end
