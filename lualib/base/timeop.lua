
local skynet = require "skynet"

local floor = math.floor
local max = math.max
local min = math.min

function get_time(bFloat)
    local fTime = skynet.time()
    if not bFloat then
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

function get_daytime(tab)
    local iFactor = tab.factor  or 1                                        --正负因子
    local iDay = tab.day or 1                                                  --距离天数
    local iAnchor = tab.anchor or 0                                     --锚点
    iDay = iDay * iFactor                                                             
    local iCurTime = get_time()
    local iTime = iCurTime + iDay * 3600 * 24
    local date = os.date("*t",iTime)
    iTime = os.time({year=date.year,month=date.month,day=date.day,hour=iAnchor,min=0,sec=0})
    local retbl = {}
    retbl.time = iTime
    retbl.date = os.date("*t",iTime)
    return retbl
end

function get_hourtime(tab)
    local iFactor = tab.factor or 1                                                --正负因子
    local iHour = tab.hour or 1                                                     --距离小时
    iHour = iHour * iFactor
    local iCurTime = get_time()
    local iTime = iCurTime + iHour * 3600
    local date = os.date("*t",iTime)
    iTime = os.time({year=date.year,month=date.month,day=date.day,hour=date.hour,min=0,sec=0})
    local retbl = {}
    retbl.time = iTime
    retbl.date = os.date("*t",iTime)
    return retbl
end