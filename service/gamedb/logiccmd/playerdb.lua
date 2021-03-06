--import module
local global = require "global"
local skynet = require "skynet"
local mongoop = require "base.mongoop"
local interactive = require "base.interactive"

local sPlayerTableName = "player"

function GetPlayer(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName, {pid = mData.pid}, {pid = true, account = true, base_info = true, deleted = true})
    interactive.Response(mRecord.source, mRecord.session, {
        data = m,
        pid = mData.pid,
    })
end

function CreatePlayer(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Insert(sPlayerTableName, mData.data)
end

function RemovePlayer(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName, {pid = mData.pid}, {["$set"] = {deleted = true}})
end

function GetPlayerListByAccount(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:Find(sPlayerTableName, {account = mData.account}, {pid = true, account = true, base_info = true, deleted = true})
    local mRet = {}
    while m:hasNext() do
        table.insert(mRet, m:next())
    end
    interactive.Response(mRecord.source, mRecord.session, {
        data = mRet,
        account = mData.account,
    })
end

function LoadPlayerBase(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName, {pid = mData.pid}, {base_info = true})
    interactive.Response(mRecord.source, mRecord.session, {
        data = m.base_info,
        pid = mData.pid,
    })
end

function SavePlayerBase(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName, {pid = mData.pid}, {["$set"]={base_info = mData.data}})
end

function LoadPlayerActive(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName, {pid = mData.pid}, {active_info = true})
    interactive.Response(mRecord.source, mRecord.session, {
        data = m.active_info,
        pid = mData.pid,
    })
end

function SavePlayerActive(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName, {pid = mData.pid}, {["$set"]={active_info = mData.data}})
end

function LoadPlayerItem(mRecord,mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName,{pid = mData.pid},{item_info = true})
    interactive.Response(mRecord.source,mRecord.session,{
        data = m.item_info,
        pid = mData.pid,
     })
end

function SavePlayerItem(mRecord,mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName,{pid=mData.pid},{["$set"]={item_info=mData.data}})
end

function LoadPlayerTimeInfo(mRecord,mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName,{pid = mData.pid},{time_info = true})
    interactive.Response(mRecord.source,mRecord.session,{
        data = m.time_info,
        pid = mData.pid,
     })
end

function SavePlayerTimeInfo(mRecord,mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName,{pid=mData.pid},{["$set"]={time_info=mData.data}})
end

function LoadPlayerTask(mRecord,mData)
   local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName,{pid = mData.pid},{task_info = true})
    interactive.Response(mRecord.source,mRecord.session,{
        data = m.task_info,
        pid = mData.pid,
     })
end

function SavePlayerTaskInfo(mRecord,mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName,{pid=mData.pid},{["$set"]={task_info=mData.data}})
end

function LoadPlayerWareHouse(mRecord,mData)
   local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sPlayerTableName,{pid = mData.pid},{wh_info = true})
    interactive.Response(mRecord.source,mRecord.session,{
        data = m.wh_info,
        pid = mData.pid,
     })
end

function SavePlayerWareHouse(mRecord,mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sPlayerTableName,{pid=mData.pid},{["$set"]={wh_info=mData.data}})
end
