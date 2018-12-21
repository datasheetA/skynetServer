--import module

local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"
local extype = require "base.extype"

local status = import(lualib_path("base.status"))
local gamedefines = import(lualib_path("public.gamedefines"))

function NewGateMgr(...)
    local o = CGateMgr:New(...)
    return o
end

function NewGate(...)
    local o = CGate:New(...)
    return o
end

function NewConnection(...)
    local o = CConnection:New(...)
    return o
end

CConnection = {}
CConnection.__index = CConnection
inherit(CConnection, logic_base_cls())

function CConnection:New(source, handle, ip, port)
    local o = super(CConnection).New(self)
    o.m_iGateAddr = source
    o.m_iHandle = handle
    o.m_sIP = ip
    o.m_iPort = port
    o.m_sAccount = nil

    self.m_oStatus = status.NewStatus()
    self.m_oStatus:Set(gamedefines.LOGIN_CONNECTION_STATUS.no_account)

    return o
end

function CConnection:Release()
    self.m_oStatus:Release()
    super(CConnection).Release(self)
end

function CConnection:Send(sMessage, mData)
    net.Send({gate = self.m_iGateAddr, fd = self.m_iHandle}, sMessage, mData)
end

function CConnection:SetAccount(sAccount)
    self.m_sAccount = sAccount
end

function CConnection:GetAccount()
    return self.m_sAccount
end

function CConnection:LoginAccount(mData)
    local iStatus = self.m_oStatus:Get()
    assert(iStatus, "connection status is nil")
    local oGateMgr = global.oGateMgr

    if iStatus ~= gamedefines.LOGIN_CONNECTION_STATUS.no_account then
        oGateMgr:KickConnection(self.m_iHandle)
        return
    end

    self.m_oStatus:Set(gamedefines.LOGIN_CONNECTION_STATUS.in_login_account)

    local sAccount = mData.account

    interactive.Request(".gamedb", "playerdb", "GetPlayerListByAccount", {account = sAccount}, function (mRecord, mData)
        if not self:IsRelease() then
            self:_LoginAccount1(mRecord, mData)
        end
    end)
end

function CConnection:_LoginAccount1(mRecord, mData)
    self.m_oStatus:Set(gamedefines.LOGIN_CONNECTION_STATUS.login_account)
    self:SetAccount(mData.account)
    local lRet = {}
    local lData = mData.data
    for _, v in ipairs(lData) do
        if not v.deleted then
            table.insert(lRet, {pid = v.pid})
        end
    end
    self:Send("GS2CLoginAccount", {account = mData.account, role_list = lRet})
end

function CConnection:LoginRole(mData)
    local iStatus = self.m_oStatus:Get()
    assert(iStatus, "connection status is nil")
    local oGateMgr = global.oGateMgr

    if iStatus ~= gamedefines.LOGIN_CONNECTION_STATUS.login_account then
        oGateMgr:KickConnection(self.m_iHandle)
        return
    end

    self.m_oStatus:Set(gamedefines.LOGIN_CONNECTION_STATUS.in_login_role)

    local sAccount = mData.account
    local pid = mData.pid

    interactive.Request(".gamedb", "playerdb", "GetPlayer", {pid = pid}, function (mRecord, mData)
        if not self:IsRelease() then
            self:_LoginRole1(mRecord, mData)
        end
    end)
end

function CConnection:_LoginRole1(mRecord, mData)
    local m = mData.data
    --lxldebug
    if not m then
        interactive.Send(".gamedb", "playerdb", "CreatePlayer", {
            data = {
                pid = mData.pid,
                account = self:GetAccount(),
                deleted = false,
                base_info = {grade = 0, name = string.format("DEBUG%d", mData.pid)},
                active_info = {map_id = 1001, pos = {x = 100, y = 100, z  = 0, face_x = 0, face_y = 0, face_z = 0}},
            }
        })
    end
    interactive.Send(".world", "login", "LoginPlayer", {
        conn = {
            handle = self.m_iHandle,
            gate = self.m_iGateAddr,
            ip = self.m_sIP,
            port = self.m_iPort,
        },
        role = {
            account = self:GetAccount(),
            pid = mData.pid,
        }
        })
end

function CConnection:LoginResult(mData)
    local iErrcode = mData.errcode
    local pid = mData.pid
    if iErrcode == gamedefines.ERRCODE.ok then
        self.m_oStatus:Set(gamedefines.LOGIN_CONNECTION_STATUS.login_role)
    else
        self.m_oStatus:Set(gamedefines.LOGIN_CONNECTION_STATUS.login_account)
        self:Send("GS2CLoginError", {pid = pid, errcode = iErrcode})
    end
end


CGate = {}
CGate.__index = CGate
inherit(CGate, logic_base_cls())

function CGate:New(iPort)
    local o = super(CGate).New(self)
    local iAddr = skynet.launch("zinc_gate", "S", skynet.address(MY_ADDR), iPort, extype.ZINC_CLIENT, 10000)
    o.m_iAddr = iAddr
    o.m_iPort = iPort
    o.m_mConnections = {}
    return o
end

function CGate:Release()
    for _, v in pairs(self.m_mConnections) do
        v:Release()
    end
    self.m_mConnections = {}
    super(CGate).Release(self)
end

function CGate:GetConnection(fd)
    return self.m_mConnections[fd]
end

function CGate:AddConnection(oConn)
    self.m_mConnections[oConn.m_iHandle] = oConn
    local oGateMgr = global.oGateMgr
    oGateMgr:SetConnection(oConn.m_iHandle, oConn)

    skynet.send(self.m_iAddr, "text", "forward", oConn.m_iHandle, skynet.address(MY_ADDR), skynet.address(self.m_iAddr))
    skynet.send(self.m_iAddr, "text", "start", oConn.m_iHandle)
    oConn:Send("GS2CHello", {time = math.floor(get_time())})
end

function CGate:DelConnection(iHandle)
    local oConn = self.m_mConnections[iHandle]
    if oConn then
        self.m_mConnections[iHandle] = nil
        oConn:Release()
        local oGateMgr = global.oGateMgr
        oGateMgr:SetConnection(iHandle, nil)
    end
end

CGateMgr = {}
CGateMgr.__index = CGateMgr
inherit(CGateMgr, logic_base_cls())

function CGateMgr:New()
    local o = super(CGateMgr).New(self)
    o.m_mGates = {}
    o.m_mNoteConnections = {}
    return o
end

function CGateMgr:Release()
    for _, v in pairs(self.m_mGates) do
        v:Release()
    end
    self.m_mGates = {}
    super(CGateMgr).Release(self)
end

function CGateMgr:AddGate(oGate)
    self.m_mGates[oGate.m_iAddr] = oGate
end

function CGateMgr:GetGate(iAddr)
    return self.m_mGates[iAddr]
end

function CGateMgr:GetConnection(iHandle)
    return self.m_mNoteConnections[iHandle]
end

function CGateMgr:SetConnection(iHandle, oConn)
    self.m_mNoteConnections[iHandle] = oConn
end

function CGateMgr:KickConnection(iHandle)
    local oConnection = self:GetConnection(iHandle)
    if oConnection then
        local oGate = self:GetGate(oConnection.m_iGateAddr)
        if oGate and oGate:GetConnection(iHandle) then
            oGate:DelConnection(iHandle)
        end
        skynet.send(oConnection.m_iGateAddr, "text", "kick", oConnection.m_iHandle)
    end
end
