--import module
local global = require "global"
local skynet = require "skynet"
local protobuf = require "base.protobuf"

ForwardNetcmds = {}

function ForwardNetcmds.C2GSWarSkill(oPlayer, mData)
        local l1 = mData.action_wlist
        local l2 = mData.select_wlist
        local iSkill = mData.skill_id

        local iWid = l1[1]

        local oWar = oPlayer:GetWar()
        local oAction = oWar:GetWarrior(iWid)
        if oAction then
            oWar:AddBoutCmd(iWid, {
                cmd = "skill",
                data = {
                    action_wlist = l1,
                    select_wlist = l2,
                    skill_id = iSkill,
                }
            })
        end
end

function ForwardNetcmds.C2GSWarNormalAttack(oPlayer, mData)
        local iActionWid = mData.action_wid
        local iSelectWid = mData.select_wid

        local oWar = oPlayer:GetWar()
        local oAction = oWar:GetWarrior(iActionWid)
        if oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "normal_attack",
                data = {
                    action_wid = iActionWid,
                    select_wid = iSelectWid,
                }
            })
        end
end

function ForwardNetcmds.C2GSWarEscape(oPlayer, mData)
        local iActionWid = mData.action_wid

        local oWar = oPlayer:GetWar()
        local oAction = oWar:GetWarrior(iActionWid)
        if oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "escape",
                data = {
                    action_wid = iActionWid,
                }
            })
        end
end

function ForwardNetcmds.C2GSWarDefense(oPlayer, mData)
        local iActionWid = mData.action_wid

        local oWar = oPlayer:GetWar()
        local oAction = oWar:GetWarrior(iActionWid)
        if oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "defense",
                data = {
                    action_wid = iActionWid,
                }
            })
        end
end

function ForwardNetcmds.C2GSWarProtect(oPlayer, mData)
        local iActionWid = mData.action_wid
        local iSelectWid = mData.select_wid

        local oWar = oPlayer:GetWar()
        local oAction = oWar:GetWarrior(iActionWid)
        if oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "protect",
                data = {
                    action_wid = iActionWid,
                    select_wid = iSelectWid,
                }
            })
        end
end



function ConfirmRemote(mRecord, mData)
    local iWarId = mData.war_id
    local oWarMgr = global.oWarMgr
    oWarMgr:ConfirmRemote(iWarId)
end

function RemoveRemote(mRecord, mData)
    local iWarId = mData.war_id
    local oWarMgr = global.oWarMgr
    oWarMgr:RemoveWar(iWarId)
end

function EnterPlayer(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local iWid = mData.wid
    local iCamp = mData.camp_id
    local mMail = mData.mail
    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    assert(oWar, string.format("EnterPlayer error war: %d %d %d", iWarId, iPid, iWid))
    oWar:EnterPlayer(iPid, iWid, iCamp, mMail)
end

function LeavePlayer(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        oWar:LeavePlayer(iPid)
    end
end

function ReEnterPlayer(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local mMail = mData.mail
    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    assert(oWar, string.format("ReEnterPlayer error war: %d %d", iWarId, iPid))
    oWar:ReEnterPlayer(iPid, mMail)
end

function NotifyDisconnected(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local oPlayerWarrior = oWar:GetPlayerWarrior(iPid)
        if oPlayerWarrior then
            oPlayerWarrior:Disconnected()
        end
    end
end

function WarStart(mRecord, mData)
    local iWarId = mData.war_id
    local mInfo = mData.info
    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        oWar:WarStart(mInfo)
    end
end

function WarPrepare(mRecord, mData)
    local iWarId = mData.war_id
    local mInfo = mData.info
    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        oWar:WarPrepare(mInfo)
    end
end

function TestCmd(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local sCmd = mData.cmd
    local m = mData.data

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        if sCmd == "wartimeover" then
            oWar:BoutProcess()
        end
    end
end

function Forward(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local sCmd = mData.cmd
    local m = protobuf.default(sCmd, mData.data)

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local oPlayer = oWar:GetPlayerWarrior(iPid)
        if oPlayer then
            local func = ForwardNetcmds[sCmd]
            if func then
                func(oPlayer, m)
            end
        end
    end
end
