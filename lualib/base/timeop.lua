
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

function GetDayNo()
    local iTime = get_time()
    local iDayNo = floor(iTime // (3600*24))
    return iDayNo
end

--5点算天
function GetDayMorningNo()
    local iTime = get_time()
    local iDayMorningNo = floor((iTime-5*3600) // 3600*24)
    return iDayMorningNo
end

function GetWeekNo()
    local iTime = get_time()
    local iWeekNo = floor(iTime//(7*3600*24))
    return iWeekNo
end

--5点算星期
function GetWeekMorningNo()
    local iTime = get_time()
    local iWeekNo = floor((iTime-5*3600)//(7*3600*24))
    return iWeekNo
end

function GetHourNo()
    local iTime = get_time()
    local iHourNo = floor(iTime//3600)
    return iHourNo
end
