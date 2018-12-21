--import module
local global = require "global"
local skynet = require "skynet"
local mongoop = require "base.mongoop"
local interactive = require "base.interactive"

local sOfflineTableName = "offline"

function LoadOfflineRO(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sOfflineTableName, {pid = mData.pid}, {ro_info = true})
    m = m or {}
    interactive.Response(mRecord.source, mRecord.session, {
        data = m.ro_info,
        pid = mData.pid,
    })
end

function SaveOfflineRO(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sOfflineTableName, {pid = mData.pid}, {["$set"]={ro_info = mData.data}},true)
end

function LoadOfflineRW(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sOfflineTableName, {pid = mData.pid}, {rw_info = true})
    m = m or {}
    interactive.Response(mRecord.source, mRecord.session, {
        data = m.rw_info,
        pid = mData.pid,
    })
end

function SaveOfflineRW(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sOfflineTableName, {pid = mData.pid}, {["$set"]={rw_info = mData.data}},true)
end