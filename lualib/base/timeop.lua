
local skynet = require "skynet"

local floor = math.floor
local max = math.max
local min = math.min

function get_time(bRound)
    bRound = bRound or true                                 --默认取整
    local fTime = skynet.time()
    if bRound then
        return floor(fTime)
    end
    return fTime
end

function get_current()
    return skynet.now()
end

function get_second()
    return math.floor(get_current()/100)
end

function get_ssecond()
    return get_current()/100
end

function get_msecond()
    return get_current()*10
end

function get_dayno()
    local iTime = get_time()
    local iDayNo = floor(iTime // (3600*24))
    return iDayNo
end

--5点算天
function get_morningdayno()
    local iTime = get_time()
    local iDayMorningNo = floor((iTime-5*3600) // 3600*24)
    return iDayMorningNo
end

function get_weekno()
    local iTime = get_time()
    local iWeekNo = floor(iTime//(7*3600*24))
    return iWeekNo
end

--5点算星期
function get_morningweekno()
    local iTime = get_time()
    local iWeekNo = floor((iTime-5*3600)//(7*3600*24))
    return iWeekNo
end

function get_hourno()
    local iTime = get_time()
    local iHourNo = floor(iTime//3600)
    return iHourNo
end

function chinadate()
    local iTime = get_time()
    local mDate = os.date("*t",iTime)
    local iWeekDay = mDate.wday
    if mDate.wday == 0 then
        iWeekDay = 7
    end
    return iWeekDay,mDate.hour
end