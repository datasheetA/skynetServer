--import module
local global = require "global"
local skynet = require "skynet"
local mongoop = require "base.mongoop"
local interactive = require "base.interactive"

local sWorldTableName = "world"

function LoadWorld(mRecord, mData)
    local oGameDb = global.oGameDb
    local m = oGameDb:FindOne(sWorldTableName, {server_id = mData.server_id}, {data = true})
    m = m or {}
    interactive.Response(mRecord.source, mRecord.session, {
        data = m.data,
        server_id = mData.server_id,
    })
end

function SaveWorld(mRecord, mData)
    local oGameDb = global.oGameDb
    oGameDb:Update(sWorldTableName, {server_id = mData.server_id}, {["$set"]={data = mData.data}},true)
end
