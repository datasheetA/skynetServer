local global = require "global"
local skynet = require "skynet"

local itembase = import(service_path("item/itembase"))

CItem = {}
CItem.__index = CItem
inherit(CItem,itembase.CItem)
CItem.m_ItemType = "virtual"

function CItem:RealObj()
    -- body
end

function CItem:Reward()
    -- body
end