--!strict
--[[
--------------------------------------------------------------------------------
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
⚠️  WARNING - PLEASE READ! ⚠️
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

If you are submitting to EToH: 
PLEASE, **DO NOT** make any script edits to this script. 
This is a core script and any edits you make to this script will NOT work 
elsewhere.

If you have any suggestions, please let us know.
Thank you
--------------------------------------------------------------------------------
]]

type ScrollableListDef<T> = {
	__index: ScrollableListDef<T>,

	Scroll: (self: ScrollableList<T>, units: number) -> T,
	Current: (self: ScrollableList<T>) -> T,
}

export type ScrollableList<T> = typeof(setmetatable(
	{} :: {
		items: { T },
		current: number,
	},
	{} :: ScrollableListDef<T>
))

local ScrollableList = {} :: ScrollableListDef<any>
ScrollableList.__index = ScrollableList

local function new<T>(items: { T }, default: number?): ScrollableList<T>
	return setmetatable({
		items = items,
		current = default or 1,
	}, ScrollableList)
end

function ScrollableList:Scroll(units: number)
	local items = self.items
	local index = (self.current + units) % #items
	index = if index <= 0 then #items else index

	self.current = index
	return items[self.current]
end

function ScrollableList:Current()
	return self.items[self.current]
end

return new
