
local M = {}

function M.cover(f)
    return math.floor(f*1000)
end

function M.recover(i)
    return i/1000
end

return M
