
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
