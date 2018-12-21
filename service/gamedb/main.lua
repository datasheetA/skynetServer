local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local mongoop = require "base.mongoop"

require "skynet.manager"

local logiccmd = import(service_path("logiccmd.init"))

skynet.start(function()
    interactive.Init(logiccmd)

    local m = read_file(skynet.getenv("db_file"))
    global.oGameDb = mongoop.NewMongoObj()
    global.oGameDb:Init({
        db_cfg = m.game,
    })
    local oGameDb = global.oGameDb

    local sPlayerTableName = "player"
    oGameDb:CreateIndex(sPlayerTableName, {pid = 1}, {unique = true, name = "player_pid_index"})
    oGameDb:CreateIndex(sPlayerTableName, {account = 1}, {name = "player_account_index"})
    
    local sOfflineTableName = "offline"
    oGameDb:CreateIndex(sOfflineTableName,{pid = 1},{unique=true,name="offline_pid_index"})

    skynet.register ".gamedb"
    print("gamedb service booted")
end)
