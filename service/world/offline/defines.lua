local global = require "global"

--小于10000调用玩家方法
local Func2No = {
    ["RewardSilver"] = 1001
}

function GetFuncNo(sFunc)
    return Func2No[sFunc]
end

function GetFuncByNo(iFuncNo)
    for sFunc,iNo in pairs(Func2No) do
        if iFuncNo == iNo then
            return sFunc
        end
    end
end