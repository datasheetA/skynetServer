--import module
local skynet = require "skynet"

local basectrl = import(service_path("playerctrl.basectrl"))
local activectrl = import(service_path("playerctrl.activectrl"))
local itemctrl = import(service_path("playerctrl.itemctrl"))
local timectrl = import(service_path("playerctrl.timectrl"))
local taskctrl = import(service_path("playerctrl.taskctrl"))

function NewBaseCtrl(...)
    return basectrl.CPlayerBaseCtrl:New(...)
end

function NewActiveCtrl(...)
    return activectrl.CPlayerActiveCtrl:New(...)
end

function NewItemCtrl( ... )
    return itemctrl.CItemCtrl:New(...)
end

function NewTimeCtrl( ... )
    return timectrl.CTimeCtrl:New(...)
end

function NewTodayCtrl(...)
    return timectrl.CToday:New(...)
end

function NewTodayMorningCtrl(...)
    return timectrl.CTodayMorning:New(...)
end

function NewWeekCtrl(...)
    return timectrl.CThisWeek:New(...)
end

function NewWeekMorningCtrl( ... )
    return timectrl.CThisWeekMorning:New(...)
end

function NewThisTempCtrl( ... )
    return timectrl.CThisTemp:New(...)
end

function NewSeveralDayCtrl( ... )
    return timectrl.CSeveralDay:New(...)
end

function NewTaskCtrl( ... )
    return taskctrl.CTaskCtrl:New(...)
end