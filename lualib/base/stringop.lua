
function split_string(s, rep, f)
    local pattern = string.format("([^%s]+)", rep)
    local lst = {}
    string.gsub(s, pattern, function (c)
        if f then
            c = f(c)
        end
        lst[#lst + 1] = c
    end)
    return lst
end
