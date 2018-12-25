local global = require "global"
local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"
local servicetimer = require "base.servicetimer"
local texthandle = require "base.texthandle"
local res = require "base.res"

require "skynet.manager"

local netcmd = import(service_path("netcmd.init"))
local logiccmd = import(service_path("logiccmd.init"))
local worldobj = import(service_path("worldobj"))
local sceneobj = import(service_path("sceneobj"))
local warobj = import(service_path("warobj"))
local gmobj = import(service_path("gmobj"))
local publicobj = import(service_path("publicobj"))
local npcobj = import(service_path("npcobj"))
local cbobj = import(service_path("cbobj"))
local notify = import(service_path("notify"))
local uiobj = import(service_path("uiobj"))

skynet.start(function()
    net.Init(netcmd)
    interactive.Init(logiccmd)
    texthandle.Init()

    global.oGlobalTimer = servicetimer.NewTimer()
    global.oGMMgr = gmobj.NewGMMgr()
    global.oNotifyMgr = notify.NewNotifyMgr()

    interactive.Request(".gamedb", "worlddb", "LoadWorld", {server_id = MY_SERVER_ID}, function (mRecord, mData)
            global.oWorldMgr = worldobj.NewWorldMgr()
            global.oWorldMgr:Load(mData.data)
            global.oWorldMgr:Schedule()

            local iCount
            iCount = skynet.getenv("SCENE_SERVICE_COUNT")
            local lSceneRemote = {}
            for i = 1, iCount do
                local iAddr = skynet.newservice("scene")
                table.insert(lSceneRemote, iAddr)
            end
            global.oSceneMgr = sceneobj.NewSceneMgr(lSceneRemote)

            iCount = skynet.getenv("WAR_SERVICE_COUNT")
            local lWarRemote = {}
            for i = 1, iCount do
                local iAddr = skynet.newservice("war")
                table.insert(lWarRemote, iAddr)
            end
            global.oWarMgr = warobj.NewWarMgr(lWarRemote)

            --lxldebug add some temp scene
            local mScene = res["daobiao"]["scene"]
            for k, v in pairs(mScene) do
                local iCnt = v.line_count
                for i = 1, iCnt do
                    global.oSceneMgr:CreateScene({
                        map_id = v.map_id,
                        res_data = v,
                        is_durable = true,
                    })
                end
            end

            global.oPubMgr = publicobj.NewPubMgr()
            global.oNpcMgr = npcobj.NewNpcMgr()
            local oNpcMgr = global.oNpcMgr
            oNpcMgr:LoadInit()
            global.oCbMgr = cbobj.NewCBMgr()
            global.oUIMgr = uiobj.NewUIMgr()

            skynet.dispatch_finish_hook(function ()
                local oWorldMgr = global.oWorldMgr
                oWorldMgr:WorldDispatchFinishHook()
            end)

    end)


    skynet.register ".world"

    print("world service booted")
end)
