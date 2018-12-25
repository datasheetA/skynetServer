--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local extend = require "base/extend"

local loaditem = import(service_path("item/loaditem"))
local itemnet = import(service_path("netcmd/item"))
local timeop = import(lualib_path("base/timeop"))


function NewGMMgr(...)
    local o = CGMMgr:New(...)
    return o
end

Commands = {}
Helpers = {}

Helpers.setgrade = {
    "设置等级",
    "setgrade 等级",
    "示例: setgrade 20",
}
function Commands.setgrade(oMaster, i)
    oMaster.m_oBaseCtrl:SetData("grade", i)
end

Helpers.testwar = {
    "测试多人PVP",
    "testwar {玩家ID1,玩家ID2,...}",
    "testwar {999, 234,}",
}
function Commands.testwar(oMaster, lTargets)
    local oWarMgr = global.oWarMgr
    local oWorldMgr = global.oWorldMgr
    local oWar = oWarMgr:CreateWar({})

    if #lTargets <= 0 then
        return
    end

    local lRes = {}
    for _, v in ipairs(lTargets) do
        local o = oWorldMgr:GetOnlinePlayerByPid(v)
        if o then
            table.insert(lRes, o)
        end
    end
    local iMiddle = math.floor(#lRes/2 + 1)

    oWarMgr:EnterWar(oMaster, oWar:GetWarId(), {camp_id = 1}, true)
    for i = 1, iMiddle do
        local o = lRes[i]
        oWarMgr:EnterWar(o, oWar:GetWarId(), {camp_id = 2}, true)
    end
    for i = iMiddle + 1, #lRes do
        local o = lRes[i]
        oWarMgr:EnterWar(o, oWar:GetWarId(), {camp_id = 1}, true)
    end

    oWarMgr:StartWar(oWar:GetWarId())
end

Helpers.wartimeover = {
    "结束战斗本轮操作阶段",
    "wartimeover",
    "wartimeover",
}
function Commands.wartimeover(oMaster)
    local oWar = oMaster.m_oActiveCtrl:GetNowWar()
    if oWar then
        oWar:TestCmd("wartimeover", oMaster:GetPid(), {})
    end
end

Helpers.clone = {
    "克隆道具",
    "clone 物品类型 物品数量",
    "clone 1001 200",
}
function Commands.clone(oMaster,sid,iAmount)
    local itemobj = loaditem.GetItem(sid)
    if not itemobj then
        return
    end
   
    while(iAmount>0) do
        local itemobj = loaditem.Create(sid)
        local iMaxAmount = itemobj:GetMaxAmount()
        local iAddAmount = math.min(iAmount,iMaxAmount)
        iAmount = iAmount - iAddAmount
        itemobj:SetAmount(iAddAmount)
        oMaster:RewardItem(itemobj,"clone")
    end
end

Helpers.rewardgold = {
    "奖励金币",
    "rewardgold 金币数量",
    "rewardgold 200",
}
function Commands.rewardgold(oMaster,iVal)
    oMaster:RewardGold(iVal,"gm")
end

Helpers.rewardsilver = {
    "奖励银币",
    "rewardsilver 银币数量",
    "rewardsilver 200",
}
function Commands.rewardsilver(oMaster,iVal)
    oMaster:RewardSilver(iVal,"gm")
end

Helpers.rewardexp = {
    "奖励经验",
    "rewardexp 经验数量",
    "rewardexp 200",
}
function Commands.rewardexp(oMaster,iVal)
    oMaster:RewardExp(iVal,"gm")
end

Helpers.clearall = {
    "清空背包",
    "clearall",
    "clearall",
}
function Commands.clearall(oMaster)
    for _,itemobj in pairs(oMaster.m_oItemCtrl.m_Item) do
        oMaster.m_oItemCtrl:RemoveItem(itemobj)
    end
end

Helpers.map = {
    "跳到固定地图",
    "map {id=固定场景编号,x=X坐标,y=Y坐标,}",
    "map {id=1001,x=100,y=100,}",
}
function Commands.map(oMaster, m)
    local res = require "base.res"
    local iMapId = m.id
    local oNowScene = oMaster.m_oActiveCtrl:GetNowScene()
    if oNowScene:MapId() == iMapId then
        return
    end
    local oSceneMgr = global.oSceneMgr
    local oScene = oSceneMgr:SelectDurableScene(iMapId)
    local mNowPos = oMaster.m_oActiveCtrl:GetNowPos()
    oSceneMgr:EnterScene(oMaster, oScene:GetSceneId(), {pos = {x = m.x or mNowPos.x, y = m.y or mNowPos.y, z = mNowPos.z, face_x = mNowPos.face_x, face_y = mNowPos.face_y, face_z = mNowPos.face_z}}, true)
end

Helpers.help = {
    "GM指令帮助",
    "help 指令名",
    "help 'clearall'",
}
function Commands.help(oMaster, sCmd)
    if sCmd then
        local o = Helpers[sCmd]
        if o then
            local sMsg = string.format("%s:\n指令说明:%s\n参数说明:%s\n示例:%s\n", sCmd, o[1], o[2], o[3])
            oMaster:Send("GS2CGMMessage", {
                msg = sMsg,
            })
        else
            oMaster:Send("GS2CGMMessage", {
                msg = "没查到这个指令"
            })
        end
    else
        local sMsg = "所有指令简介:\n"
        for k, v in pairs(Helpers) do
            sMsg = sMsg .. string.format("%s: %s\n", k, v[1])
        end
        oMaster:Send("GS2CGMMessage", {
            msg = sMsg,
        })
    end
end


CGMMgr = {}
CGMMgr.__index = CGMMgr
inherit(CGMMgr, logic_base_cls())

function CGMMgr:New()
    local o = super(CGMMgr).New(self)
    return o
end

function CGMMgr:ReceiveCmd(oMaster, sCmd)
    local mMatch = {}
    mMatch["{"] = "}"

    local iState = 1
    local iBegin = 1
    local iEnd = 0

    local sMatch = nil
    local iMatch = 0

    local lArgs = {}
    for i = 1, #sCmd do
        local c = index_string(sCmd, i)

        if iState == 1 then
            if c == " " then
                iEnd = i-1
                iState = 3
                if iEnd>=iBegin then
                    table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
                end
            elseif mMatch[c] then
                assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
            end
        elseif iState == 2 then
            if iMatch <= 0 then
                if c == " " then
                    iEnd = i-1
                    iState = 3
                    if iEnd>=iBegin then
                        table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
                    end
                else
                    assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
                end
            else
                if c == mMatch[sMatch] then
                    iMatch = iMatch - 1
                elseif mMatch[c] then
                    assert(false, string.format("ReceiveCmd fail %d %s %s", iState, c, mMatch[c]))
                end
            end
        else
            if mMatch[c] then
                iState = 2
                iBegin = i
                sMatch = c
                iMatch = 1
            elseif c ~= " " then
                iBegin = i
                iState = 1
            end
        end
    end

    if iState == 1 then
        iEnd = #sCmd
        if iEnd>=iBegin then
            table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
        end
    elseif iState == 2 then
        if iMatch <= 0 then
            iEnd = #sCmd
            if iEnd>=iBegin then
                table.insert(lArgs, string.sub(sCmd, iBegin, iEnd))
            end
        end
    end

    local sCommand = lArgs[1]
    local lCommandArgs = {}
    for k = 2, #lArgs do
        local v = lArgs[k]
        local r = assert(load(string.format("return %s", v), "", "bt")(), string.format("ReceiveCmd fail index:%d value:%s", k, v))
        table.insert(lCommandArgs, r)
    end

    local func = Commands[sCommand]
    if func then
        func(oMaster, table.unpack(lCommandArgs))
    else
        assert(false, string.format("ReceiveCmd fail cmd:%s", sCommand))
    end

end
