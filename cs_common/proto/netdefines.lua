
local M = {}

local C2GS = {}
local GS2C = {}
M.C2GS = C2GS
M.GS2C = GS2C

local C2GS_BY_NAME = {}
local GS2C_BY_NAME = {}
M.C2GS_BY_NAME = C2GS_BY_NAME
M.GS2C_BY_NAME = GS2C_BY_NAME

--C2GS BEGIN

local C2GS_DEFINES = {}

C2GS_DEFINES.login = {
    C2GSLoginAccount = 1001,
    C2GSLoginRole = 1002,
}

C2GS_DEFINES.scene = {
    C2GSSyncPos = 2001,
    C2GSTransfer = 2002,
}

C2GS_DEFINES.other = {
    C2GSHeartBeat = 3001,
    C2GSGMCmd = 3002,
    C2GSCallback = 3003,
}

C2GS_DEFINES.war = {
    C2GSWarSkill = 4001,
    C2GSWarNormalAttack = 4002,
    C2GSWarProtect = 4003,
    C2GSWarEscape = 4004,
    C2GSWarDefense = 4005,
}

C2GS_DEFINES.item = {
    C2GSItemUse = 5001,
    C2GSItemInfo = 5002,
    C2GSItemMove = 5003,
    C2GSItemArrage = 5004,
    C2GSAddItemExtendSize  = 5005,
}

C2GS_DEFINES.player = {
    
}

C2GS_DEFINES.task = {
    C2GSClickTask = 7001,
    C2GSTaskEvent = 7002,
    C2GSUseTaskItem = 7003,
}

C2GS_DEFINES.npc = {
    C2GSClickNpc = 8001,
    C2GSNpcRespond = 8002,
}

C2GS_DEFINES.openui = {
    
}

--C2GS END

--GS2C BEGIN

local GS2C_DEFINES = {}

GS2C_DEFINES.login = {
    GS2CHello = 1001,
    GS2CLoginError = 1002,
    GS2CLoginAccount = 1003,
    GS2CLoginRole = 1004,
}

GS2C_DEFINES.scene = {
    GS2CShowScene = 2001,
    GS2CEnterScene = 2002,
    GS2CEnterAoi = 2003,
    GS2CLeaveAoi = 2004,
    GS2CSyncAoi = 2005,
    GS2CSyncPos = 2006,
}

GS2C_DEFINES.other = {
    GS2CHeartBeat = 3001,
    GS2CGMMessage = 3002,
}

GS2C_DEFINES.war = {
    GS2CShowWar = 4001,
    GS2CWarResult = 4002,
    GS2CWarBoutStart = 4003,
    GS2CWarBoutEnd = 4004,
    GS2CWarAddWarrior = 4005,
    GS2CWarDelWarrior = 4006,
    GS2CWarNormalAttack = 4007,
    GS2CWarSkill = 4008,
    GS2CWarProtect = 4009,
    GS2CWarEscape = 4010,
    GS2CWarDamage = 4011,
    GS2CWarWarriorStatus = 4012,
    GS2CWarGoback = 4013,
}

GS2C_DEFINES.item = {
    GS2CLoginItem = 5001,
    GS2CAddItem = 5002,
    GS2CDelItem  = 5003,
    GS2CMoveItem = 5004,
    GS2CItemAmount = 5005,
    GS2CItemQuickUse = 5006,
    GS2CItemExtendSize = 5007,
}

GS2C_DEFINES.player = {
    GS2CPropChange = 6001,
    GS2CServerGradeInfo = 6002,
}

GS2C_DEFINES.task = {
    GS2CLoginTask   = 7001,
    GS2CAddTask      = 7002,
    GS2CDelTask      = 7003,
    GS2CDialog         = 7004,
    GS2CRefreshTask = 7005,
}

GS2C_DEFINES.npc = {
    GS2CNpcSay = 8001,
}

GS2C_DEFINES.openui = {
    GS2CLoadUI = 9001,
}

GS2C_DEFINES.notify = {
    GS2CNotify = 10001,
}

--GS2C END

for k, v in pairs(C2GS_DEFINES) do
    for k2, v2 in pairs(v) do
        assert(not C2GS[v2], string.format("netdefines C2GS error %s %s %s", k, k2, v2))
        assert(not C2GS_BY_NAME[k2], string.format("netdefines C2GS_BY_NAME error %s %s %s", k, k2, v2))
        C2GS[v2] = {k, k2}
        C2GS_BY_NAME[k2] = v2
    end
end

for k, v in pairs(GS2C_DEFINES) do
    for k2, v2 in pairs(v) do
        assert(not GS2C[v2], string.format("netdefines GS2C error %s %s %s", k, k2, v2))
        assert(not GS2C_BY_NAME[k2], string.format("netdefines GS2C_BY_NAME error %s %s %s", k, k2, v2))
        GS2C[v2] = {k, k2}
        GS2C_BY_NAME[k2] = v2
    end
end

return M
