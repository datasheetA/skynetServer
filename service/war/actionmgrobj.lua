--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

local gamedefines = import(lualib_path("public.gamedefines"))

function NewActionMgr(...)
    local o = CActionMgr:New(...)
    return o
end

CActionMgr = {}
CActionMgr.__index = CActionMgr
inherit(CActionMgr, logic_base_cls())

function CActionMgr:New()
    local o = super(CActionMgr).New(self)
    return o
end

function CActionMgr:WarSkill(oAction, lVictim, iSkill)
    local oWar = oAction:GetWar()

    oAction:SendAll("GS2CWarMagic", {
        war_id = oAction:GetWarId(),
        action_wlist = {oAction:GetWid(),},
        select_wlist = list_generate(lVictim, function (v)
            return v:GetWid()
        end),
        magic_id = iSkill,
    })
    oWar:AddAnimationTime(4 * 1000)

    self:DoSkill(oAction, lVictim, iSkill)

    oAction:SendAll("GS2CWarGoback", {
        war_id = oAction:GetWarId(),
        action_wid = oAction:GetWid(),
    })
end

function CActionMgr:WarEscape(oAction)
    local oWar = oAction:GetWar()

    oAction:SendAll("GS2CWarEscape", {
        war_id = oAction:GetWarId(),
        action_wid = oAction:GetWid(),
    })
    oWar:AddAnimationTime(1 * 1000)

    if oAction:Type() == gamedefines.WAR_WARRIOR_TYPE.PLAYER_TYPE then
        oWar:LeavePlayer(oAction:GetPid())
    end
end

function CActionMgr:WarNormalAttack(oAction, oVictim)
    local oWar = oAction:GetWar()
    oAction:SendAll("GS2CWarNormalAttack", {
        war_id = oAction:GetWarId(),
        action_wid = oAction:GetWid(),
        select_wid = oVictim:GetWid(),
    })
    oWar:AddAnimationTime(4 * 1000)

    local oNewVictim = oVictim:GetGuard()
    if oNewVictim then
        self:SendAll("GS2CWarProtect", {
            war_id = oNewVictim:GetWarId(),
            action_wid = oNewVictim:GetWid(),
            select_wid = oVictim:GetWid(),
        })
        self:DoNormalAttack(oAction, oNewVictim)
        self:SendAll("GS2CWarGoback", {
            war_id = oNewVictim:GetWarId(),
            action_wid = oNewVictim:GetWid(),
        })
    else
        self:DoNormalAttack(oAction, oVictim)
    end

    oAction:SendAll("GS2CWarGoback", {
        war_id = oAction:GetWarId(),
        action_wid = oAction:GetWid(),
    })
end

function CActionMgr:DoSkill(oAction, lVictim, iSkill)
    for _, oVictim in ipairs(lVictim) do
        local iDamage = math.random(-10, 10)
        local iFlag = 0
        if iDamage == 0 then
            iFlag = gamedefines.WAR_RECV_DAMAGE_FLAG.MISS
            oAction:SendAll("GS2CWarDamage", {
                war_id = oVictim:GetWarId(),
                wid = oVictim:GetWid(),
                type = iFlag,
                damage = 0,
            })
            return
        end

        if oVictim:IsDefense() then
            if iDamage < 0 then
                iDamage = math.min(-1, iDamage + 5)
                iFlag = gamedefines.WAR_RECV_DAMAGE_FLAG.DEFENSE
            end
        end
        if iDamage > 0 then
            oVictim:AddHp(iDamage)
        elseif iDamage < 0 then
            oVictim:SubHp(math.floor(iDamage))
        end
        oAction:SendAll("GS2CWarDamage", {
            war_id = oVictim:GetWarId(),
            wid = oVictim:GetWid(),
            type = iFlag,
            damage = iDamage,
        })
    end
end

function CActionMgr:DoNormalAttack(oAction, oVictim)
    local iDamage = math.random(-10, 10)
    local iFlag = 0
    if iDamage == 0 then
        iFlag = gamedefines.WAR_RECV_DAMAGE_FLAG.MISS
        oAction:SendAll("GS2CWarDamage", {
            war_id = oVictim:GetWarId(),
            wid = oVictim:GetWid(),
            type = iFlag,
            damage = 0,
        })
        return
    end

    if oVictim:IsDefense() then
        if iDamage < 0 then
            iDamage = math.min(-1, iDamage + 5)
            iFlag = gamedefines.WAR_RECV_DAMAGE_FLAG.DEFENSE
        end
    end
    if iDamage > 0 then
        oVictim:AddHp(iDamage)
    elseif iDamage < 0 then
        oVictim:SubHp(math.floor(iDamage))
    end
    oAction:SendAll("GS2CWarDamage", {
        war_id = oVictim:GetWarId(),
        wid = oVictim:GetWid(),
        type = iFlag,
        damage = iDamage,
    })
end
