
local skynet = require "skynet"
local netpack = require "netpack"
local protobuf = require "base.protobuf"
local netfind = require "base.netfind"
local extype = require "base.extype"

local M = {}

function M.Init(netcmd)
    protobuf.register_file(skynet.getenv("proto_file"))
    netfind.Init(skynet.getenv("proto_define"))

    skynet.register_protocol {
        name = "zinc",
        id = extype.ZINC,
        pack = function ( ... )
            return ...
        end,
    }

    if netcmd then
        skynet.register_protocol {
            name = "zinc_client",
            id = extype.ZINC_CLIENT,
            unpack = function (...) return ... end,
            dispatch = function (session, source, msg, sz)
                local sData = netpack.tostring2(msg, sz)
                assert(#sData >= 6, "zinc_client unpack error")
                local fd = sData:byte(1)*(2^24) + sData:byte(2)*(2^16) + sData:byte(3)*(2^8) + sData:byte(4)
                local iType = sData:byte(5)*(2^8) + sData:byte(6)
                local m = netfind.FindC2GSByType(iType)
                assert(m, "zinc_client unpack error")
                local mData, sMsg = protobuf.decode(m[2], string.sub(sData, 7))
                assert(mData, sMsg)
                netcmd.Invoke(m[1], m[2], fd, mData)
            end,
        }
    end
end

function M.PackData(sMessage, mData)
    local iType = netfind.FindGS2CByName(sMessage)
    assert(iType, "PackData error")
    local sEncode = protobuf.encode(sMessage, mData)
    local iPow = 8
    local lst = {}
    for i = 1, 2 do
        table.insert(lst,  string.char((iType//(2^iPow))%256))
        iPow = iPow - 8
    end
    table.insert(lst, sEncode)
    sEncode = table.concat(lst, "")
    sEncode = string.pack(">s2", sEncode)
    return sEncode
end

function M.Send(mMailBox, sMessage, mData)
    local sData = M.PackData(sMessage, mData)
    M.SendRaw(mMailBox, sData)
end

function M.SendRaw(mMailBox, sData)
    local iGateAddr = mMailBox.gate
    local fd = mMailBox.fd

    local iPow = 0
    local lst = {sData,}
    for i = 1, 4 do
        table.insert(lst, string.char((fd//(2^iPow))%256))
        iPow = iPow + 8
    end
    sData = table.concat(lst, "")

    skynet.send(iGateAddr, "zinc" , sData)
end

return M
