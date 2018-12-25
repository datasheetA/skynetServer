
function list_generate(t, func, bIsMap)
    local r = {}
    if not bIsMap then
        for _, v in ipairs(t) do
            if func then
                v = func(v)
            end
            table.insert(r, v)
        end
    else
        for _, v in pairs(t) do
            if func then
                v = func(v)
            end
            table.insert(r, v)
        end
    end
    return r
end

function table_count(t)
    local iLen = 0
    for k, v in pairs(t) do
        iLen = iLen + 1
    end
    return iLen
end

function table_key_list(t)
    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end
    return l
end

function table_value_list(t)
    local l = {}
    for k, v in pairs(t) do
        table.insert(l, v)
    end
    return l
end

function table_copy(t)
    local m = {}
    for k, v in pairs(t) do
        m[k] = v
    end
    return m
end

function table_deep_copy(t)
    local r = {}
    local f
    f = function (ot)
        if r[ot] then
            return r[ot]
        end
        local m = {}
        r[ot] = m
        for k, v in pairs(ot) do
            local ok, ov = k, v
            if type(k) == "table" then
                ok = f(k)
            end
            if type(v) == "table" then
                ov = f(v)
            end
            m[ok] = ov
        end
        return m
    end

    return f(t)
end
