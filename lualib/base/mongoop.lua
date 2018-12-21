
local skynet = require "skynet"
local mongo = require "mongo"
local bson = require "bson"

local M = {}

local CMongoObj = {}
CMongoObj.__index = CMongoObj
M.CMongoObj = CMongoObj

function CMongoObj:New()
    local o = setmetatable({}, self)
    o.m_oDb = nil
    return o
end

function CMongoObj:Release()
end

function CMongoObj:Init(mInit)
    local mCfg = mInit.db_cfg
    local sDbName = mCfg.db
    local o = mongo.client(mCfg)
    o:getDB(sDbName)
    self.m_oDb = o[sDbName]
end

function CMongoObj:CreateIndex(sTableName, ...)
    local t = self.m_oDb[sTableName]
    t:ensureIndex(...)
    return
end

function CMongoObj:Insert(sTableName, ...)
    local t = self.m_oDb[sTableName]
    t:insert(...)
    local r = self.m_oDb:runCommand("getLastError")
    local ok = r and r.ok == 1 and r.err == bson.null
    if not ok then
        print(string.format("lxldebug Insert %s error:%s", sTableName, r.err))
    end
    return ok, r.err
end

function CMongoObj:BatchInsert(sTableName, ...)
    local t = self.m_oDb[sTableName]
    t:batch_insert(...)
    local r = self.m_oDb:runCommand("getLastError")
    local ok = r and r.ok == 1 and r.err == bson.null
    if not ok then
        print(string.format("lxldebug BatchInsert %s error:%s", sTableName, r.err))
    end
    return ok, r.err
end

function CMongoObj:Delete(sTableName, ...)
    local t = self.m_oDb[sTableName]
    t:delete(...)
    local r = self.m_oDb:runCommand("getLastError")
    local ok = r and r.ok == 1 and r.err == bson.null
    if not ok then
        print(string.format("lxldebug Delete %s error:%s", sTableName, r.err))
    end
    return ok, r.err
end

function CMongoObj:Update(sTableName, ...)
    local t = self.m_oDb[sTableName]
    t:update(...)
    local r = self.m_oDb:runCommand("getLastError")
    if not r or r.err ~= bson.null then
        print(string.format("lxldebug Update %s error:%s", sTableName, r.err))
        return false, r.err
    end
    local ok = r.n > 0
    if not ok then
        print(string.format("lxldebug Update %s failed", sTableName))
    end
    return ok, r.err
end

function CMongoObj:Find(sTableName, ...)
    local t = self.m_oDb[sTableName]
    local r = t:find(...)
    return r
end

function CMongoObj:FindOne(sTableName, ...)
    local t = self.m_oDb[sTableName]
    local r = t:findOne(...)
    if r then
        r._id = nil
    end
    return r
end


function M.NewMongoObj(...)
    return CMongoObj:New(...)
end

return M
