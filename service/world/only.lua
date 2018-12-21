local global = require "global"

function OnlineExecute(pid,sFunc,mArgs)
    local oWorldMgr = global.oWorldMgr
    oWorldMgr:LoadRW(pid,function (oRW)
    	oRW:AddFunc(sFunc,mArgs)
    end)
end