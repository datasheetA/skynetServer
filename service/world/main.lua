local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"

require "skynet.manager"
require "base.skynet_text"

local netcmd = import(service_path("netcmd.init"))
local luacmd = import(service_path("luacmd.init"))
local worldobj = import(service_path("worldobj"))
local sceneobj = import(service_path("sceneobj"))

skynet.start(function()
    net.Init(netcmd)
    interactive.Init(luacmd)

    skynet.dispatch("text", function (session, address, message)
    end)

    global.oWorldMgr = worldobj.NewWorldMgr()

    local iCount = skynet.getenv("SCENE_SERVICE_COUNT")
    local lSceneRemote = {}
    for i = 1, iCount do
        local iAddr = skynet.newservice("scene")
        table.insert(lSceneRemote, iAddr)
    end
    global.oSceneMgr = sceneobj.NewSceneMgr(lSceneRemote)

    --lxldebug add some temp scene
    local mTestScenes = {
        {map_id = 1001, cnt = 3},
        {map_id = 1002, cnt = 3},
    }

    local oSceneMgr = global.oSceneMgr
    for _, v in ipairs(mTestScenes) do
        local iMapId = v.map_id
        for i = 1, v.cnt do
            oSceneMgr:CreateScene({
                map_id = iMapId,
                is_durable = true,
            })
        end
    end

    skynet.register ".world"

    print("world service booted")
end)
