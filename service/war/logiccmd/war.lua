--import module
local global = require "global"
local skynet = require "skynet"

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

function WarSkill(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local m = mData.data

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local l1 = m.action_wlist
        local l2 = m.select_wlist
        local iSkill = m.skill_id

        local iWid = l1[1]

        local oPlayer = oWar:GetPlayerWarrior(iPid)
        local oAction = oWar:GetWarrior(iWid)
        if oPlayer and oAction then
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
end

function WarNormalAttack(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local m = mData.data

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local iActionWid = m.action_wid
        local iSelectWid = m.select_wid

        local oPlayer = oWar:GetPlayerWarrior(iPid)
        local oAction = oWar:GetWarrior(iActionWid)
        if oPlayer and oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "normal_attack",
                data = {
                    action_wid = iActionWid,
                    select_wid = iSelectWid,
                }
            })
        end
    end
end

function WarEscape(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local m = mData.data

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local iActionWid = m.action_wid

        local oPlayer = oWar:GetPlayerWarrior(iPid)
        local oAction = oWar:GetWarrior(iActionWid)
        if oPlayer and oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "escape",
                data = {
                    action_wid = iActionWid,
                }
            })
        end
    end
end

function WarDefense(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local m = mData.data

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local iActionWid = m.action_wid

        local oPlayer = oWar:GetPlayerWarrior(iPid)
        local oAction = oWar:GetWarrior(iActionWid)
        if oPlayer and oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "defense",
                data = {
                    action_wid = iActionWid,
                }
            })
        end
    end
end

function WarProtect(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local m = mData.data

    local oWarMgr = global.oWarMgr
    local oWar = oWarMgr:GetWar(iWarId)
    if oWar then
        local iActionWid = m.action_wid
        local iSelectWid = m.select_wid

        local oPlayer = oWar:GetPlayerWarrior(iPid)
        local oAction = oWar:GetWarrior(iActionWid)
        if oPlayer and oAction then
            oWar:AddBoutCmd(iActionWid, {
                cmd = "protect",
                data = {
                    action_wid = iActionWid,
                    select_wid = iSelectWid,
                }
            })
        end
    end
end
