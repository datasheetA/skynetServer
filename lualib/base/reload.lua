
local Ms = {}

function import(sModule)
    if not Ms[sModule] then
        local sPath = string.gsub(sModule, "%.", "/") .. ".lua"
        local m = setmetatable({}, {__index = _G})
        local f, s = loadfile(sPath, "bt", m)
        if not f then
            print("import error", s)
            return
        end
        f()
        Ms[sModule] = m
    end
    return Ms[sModule]
end

function reload(sModule)
    local om = Ms[sModule]
    if not om then
        return
    end
    local nm = setmetatable({}, {__index = _G})
    local sPath = string.gsub(sModule, "%.", "/") .. ".lua"
    local f, s = loadfile(sPath, "bt", nm)
    if not f then
        print("reload error", s)
        return
    end
    f()

    local visited = {}
    local recu = function (new, old)
        if visited[old] then
            return
        end
        visited[old] = true
        for k, v in pairs(new) do
            local o = old[k]
            if type(v) ~= type(o) then
                old[k] = v
            else
                if type(v) == "table" then
                    recu(v, o)
                else
                    old[k] = v
                end
            end
        end
    end

    recu(nm, om)
end
