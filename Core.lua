local MAJOR, MINOR = "LibItemUpgradeInfo-1.0", 26
local type,tonumber,select,strsplit,GetItemInfoFromHyperlink=type,tonumber,select,strsplit,GetItemInfoFromHyperlink
local library,previous = _G.LibStub:NewLibrary(MAJOR, MINOR)
local lib=library --#lib Needed to keep Eclipse LDT happy
if not lib then return end
local pp=print
--@debug@
LoadAddOn("Blizzard_DebugTools")
LoadAddOn("LibDebug")
if LibDebug then LibDebug() end
--@end-debug@
--[===[@non-debug@
local print=function() end
--@end-non-debug@]===]
--[[
Caching system
1	itemName	String	The name of the item.
2	itemLink	String	The item link of the item.
3	itemRarity	Number	The quality of the item. The value is 0 to 7, which represents Poor to Heirloom. This appears to include gains from upgrades/bonuses.
4	itemLevel	Number	The item level of this item, not including item levels gained from upgrades. There is currently no API to get the item level including upgrades/bonuses.
5	itemMinLevel	Number	The minimum level required to use the item, 0 meaning no level requirement.
6	itemType	String	The type of the item: Armor, Weapon, Quest, Key, etc. (localized)
7	itemSubType	String	The sub-type of the item: Enchanting, Cloth, Sword, etc. See itemType. (localized)
8	itemStackCount	Number	How many of the item per stack: 20 for Runecloth, 1 for weapon, 100 for Alterac Ram Hide, etc.
9	itemEquipLoc	String	The type of inventory equipment location in which the item may be equipped, or "" if it can't be equippable. The string returned is also the name of a global string variable e.g. if "INVTYPE_WEAPONMAINHAND" is returned, _G["INVTYPE_WEAPONMAINHAND"] will be the localized, displayable name of the location.
10	iconFileDataID	Number	The FileDataID for the icon texture for the item.
11	itemSellPrice	Number	The price, in copper, a vendor is willing to pay for this item, 0 for items that cannot be sold.
12	itemClassID	Number	This is the numerical value that determines the string to display for 'itemType'.
13	itemSubClassID	Number	This is the numerical value that determines the string to display for 'itemSubType'
14 ? number
15 ? number
16 ? ?
17 ? boolean
--]]
-- ItemLink Constants
local i_Name=1
local i_Link=2
local i_Rarity=3
local i_Quality=3
local i_Level=4
local i_MinLevel =5
local i_ClassName=6
local i_SubClassName=7
local i_StackCount=8
local i_EquipLoc=9
local i_TextureId=10
local i_SellPrice=11
local i_ClassID=12
local i_SubCkass_ID=13
local i_unk1=14
local i_unk2=15
local i_unk3=16
local i_unk4=17


do
local oGetItemInfo=GetItemInfo
lib.itemcache=lib.itemcache or
	setmetatable({miss=0,tot=0},{
		__index=function(table,key)
			if (not key) then return "" end
			if (key=="miss") then return 0 end
			if (key=="tot") then return 0 end
			local cached={oGetItemInfo(key)}
			if #cached==0 then return nil end
			local itemLink=cached[2]
			if not itemLink then return nil end
			local itemID=lib:GetItemID(itemLink)
			local name=cached[1]
			cached.englishClass=GetItemClassInfo(cached[12])
			cached.englishSubClass=GetItemSubClassInfo(cached[12],cached[13])
			rawset(table,itemLink,cached)
			rawset(table,itemID,cached)
			rawset(table,name,cached)
			table.miss=table.miss+1
			return cached
		end

	})
end
local cache,select,unpack=lib.itemcache,select,unpack
local	function CachedGetItemInfo(key,index)
	if not key then return nil end
	index=index or 1
	cache.tot=cache.tot+1
	local cached=cache[key]
	if cached and type(cached)=='table' then
		return select(index,unpack(cached))
	else
		rawset(cache,key,nil) -- voiding broken cache entry
	end
end

local upgradeTable = {
	[  1] = { upgrade = 1, max = 1, ilevel = 8 },
	[373] = { upgrade = 1, max = 3, ilevel = 4 },
	[374] = { upgrade = 2, max = 3, ilevel = 8 },
	[375] = { upgrade = 1, max = 3, ilevel = 4 },
	[376] = { upgrade = 2, max = 3, ilevel = 4 },
	[377] = { upgrade = 3, max = 3, ilevel = 4 },
	[378] = {                       ilevel = 7 },
	[379] = { upgrade = 1, max = 2, ilevel = 4 },
	[380] = { upgrade = 2, max = 2, ilevel = 4 },
	[445] = { upgrade = 0, max = 2, ilevel = 0 },
	[446] = { upgrade = 1, max = 2, ilevel = 4 },
	[447] = { upgrade = 2, max = 2, ilevel = 8 },
	[451] = { upgrade = 0, max = 1, ilevel = 0 },
	[452] = { upgrade = 1, max = 1, ilevel = 8 },
	[453] = { upgrade = 0, max = 2, ilevel = 0 },
	[454] = { upgrade = 1, max = 2, ilevel = 4 },
	[455] = { upgrade = 2, max = 2, ilevel = 8 },
	[456] = { upgrade = 0, max = 1, ilevel = 0 },
	[457] = { upgrade = 1, max = 1, ilevel = 8 },
	[458] = { upgrade = 0, max = 4, ilevel = 0 },
	[459] = { upgrade = 1, max = 4, ilevel = 4 },
	[460] = { upgrade = 2, max = 4, ilevel = 8 },
	[461] = { upgrade = 3, max = 4, ilevel = 12 },
	[462] = { upgrade = 4, max = 4, ilevel = 16 },
	[465] = { upgrade = 0, max = 2, ilevel = 0 },
	[466] = { upgrade = 1, max = 2, ilevel = 4 },
	[467] = { upgrade = 2, max = 2, ilevel = 8 },
	[468] = { upgrade = 0, max = 4, ilevel = 0 },
	[469] = { upgrade = 1, max = 4, ilevel = 4 },
	[470] = { upgrade = 2, max = 4, ilevel = 8 },
	[471] = { upgrade = 3, max = 4, ilevel = 12 },
	[472] = { upgrade = 4, max = 4, ilevel = 16 },
	[491] = { upgrade = 0, max = 4, ilevel = 0 },
	[492] = { upgrade = 1, max = 4, ilevel = 4 },
	[493] = { upgrade = 2, max = 4, ilevel = 8 },
	[494] = { upgrade = 0, max = 6, ilevel = 0 },
	[495] = { upgrade = 1, max = 6, ilevel = 4 },
	[496] = { upgrade = 2, max = 6, ilevel = 8 },
	[497] = { upgrade = 3, max = 6, ilevel = 12 },
	[498] = { upgrade = 4, max = 6, ilevel = 16 },
	[503] = { upgrade = 3, max = 3, ilevel = 1 },
	[504] = { upgrade = 3, max = 4, ilevel = 12 },
	[505] = { upgrade = 4, max = 4, ilevel = 16 },
	[506] = { upgrade = 5, max = 6, ilevel = 20 },
	[507] = { upgrade = 6, max = 6, ilevel = 24 },
	[529] = { upgrade = 0, max = 2, ilevel = 0 },
	[530] = { upgrade = 1, max = 2, ilevel = 5 },
	[531] = { upgrade = 2, max = 2, ilevel = 10 },
	[535] = { upgrade = 1, max = 3, ilevel = 15 },
	[536] = { upgrade = 2, max = 3, ilevel = 30 },
	[537] = { upgrade = 3, max = 3, ilevel = 45 },
	[538] = { upgrade = 0, max = 3, ilevel = 0 },

}
do
	local stub = { ilevel = 0 }
	setmetatable(upgradeTable, { __index = function(t, key)
		return stub
	end})
end
-- Tooltip Scanning stuff
local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
local soulboundPattern = _G.ITEM_SOULBOUND
local boePattern=_G.ITEM_BIND_ON_EQUIP
local bopPattern=_G.ITEM_BIND_ON_PICKUP
local boaPattern1=_G.ITEM_BIND_TO_BNETACCOUNT
local boaPattern2=_G.ITEM_BNETACCOUNTBOUND

local scanningTooltip
local tipCache = lib.tipCache or setmetatable({},{__index=function(table,key) return {} end})
local emptytable={}
local function ScanTip(itemLink,itemLevel,show)
	if type(itemLink)=="number" then
		itemLink=CachedGetItemInfo(itemLink,2)
		if not itemLink then return emptytable end
	end
	if type(tipCache[itemLink].ilevel)=="nil" then
		if not scanningTooltip then
			scanningTooltip = _G.CreateFrame("GameTooltip", "LibItemUpgradeInfoTooltip", nil, "GameTooltipTemplate")
		end
		scanningTooltip:ClearLines()
		local rc,message=pcall(scanningTooltip.SetHyperlink,scanningTooltip,itemLink)
		if (not rc) then
			return emptytable
		end
		local quality,_,_,class,subclass,_,_,_,_,classIndex,subclassIndex=CachedGetItemInfo(itemLink,3)
		-- line 1 is the item name
		-- line 2 may be the item level, or it may be a modifier like "Heroic"
		-- check up to line 6 just in case
		local ilevel,soulbound,bop,boe,boa,heirloom
		for i = 2, 6 do
			local label, text = _G["LibItemUpgradeInfoTooltipTextLeft"..i], nil
			if label then text=label:GetText() end
			if text then
				if ilevel==nil then ilevel = tonumber(text:match(itemLevelPattern)) end
				if soulbound==nil then soulbound = text:find(soulboundPattern) end
				if bop==nil then bop = text:find(bopPattern) end
				if boe==nil then boe = text:find(boePattern) end
				if boa==nil then boa = text:find(boaPattern1) end
				if boa==nil then boa = text:find(boaPattern2) end
			end
		end
		tipCache[itemLink]={
			ilevel=ilevel or itemLevel,
			soulbound=soulbound,
			bop=bop,
			boe=boe
		}
	end
	return tipCache[itemLink]
end


-- GetUpgradeID(itemString)
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Number - The upgrade ID (possibly 0), or nil if the input is invalid or
--            does not contain upgrade info
function lib:GetUpgradeID(itemString)
	if type(itemString)~="string" then return end
	local itemString = itemString:match("item[%-?%d:]+") or ""-- Standardize itemlink to itemstring
	local instaid, _, numBonuses, affixes = select(12, strsplit(":", itemString, 15))
	instaid=tonumber(instaid) or 7
	numBonuses=tonumber(numBonuses) or 0
	if instaid >0 and (instaid-4)%8==0 then
		return tonumber((select(numBonuses + 1, strsplit(":", affixes))))
	end
end

-- GetCurrentUpgrade(id)
--
-- Returns the current upgrade level of the item, e.g. 1 for a 1/2 item.
--
-- Arguments:
--   id - Number - The upgrade ID of the item (obtained via GetUpgradeID())
--
-- Returns:
--   Number - The current upgrade level of the item. Returns nil if the item
--            cannot be upgraded
function lib:GetCurrentUpgrade(id)
	return upgradeTable[id].upgrade
end

-- GetMaximumUpgrade(id)
--
-- Returns the maximum upgrade level of the item, e.g. 2 for a 1/2 item.
--
-- Arguments:
--   id - Number - The upgrade ID of the item (obtained via GetUpgradeID())
--
-- Returns:
--   Number - The maximum upgrade level of the item. Returns nil if the item
--            cannot be upgraded
function lib:GetMaximumUpgrade(id)
	return upgradeTable[id].max
end

-- GetItemLevelUpgrade(id)
--
-- Returns the item level increase that this upgrade is worth, e.g. 4 for a
-- 1/2 item or 8 for a 2/2 item.
--
-- Arguments:
--   id - Number - The upgrade ID of the item (obtained via GetUpgradeID())
--
-- Returns:
--   Number - The item level increase of the item. Returns 0 if the item
--            cannot be or has not been upgraded
function lib:GetItemLevelUpgrade(id)
	return upgradeTable[id].ilevel
end

-- GetItemUpgradeInfo(itemString)
--
-- Returns the current upgrade level, maximum upgrade level, and item level
-- increase for an item.
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns if the item can be upgraded:
--   Number - The current upgrade level of the item
--   Number - The maximum upgrade level of the item
--   Number - The item level increase of the item
-- or if the item cannot be upgraded:
--   nil
--   nil
--   0
-- or if the item is invalid or does not contain upgrade info:
--   nil
function lib:GetItemUpgradeInfo(itemString)
	local id = self:GetUpgradeID(itemString)
	if id then
		local cur = self:GetCurrentUpgrade(id)
		local max = self:GetMaximumUpgrade(id)
		local delta = self:GetItemLevelUpgrade(id)
		return cur, max, delta
	end
	return nil
end

-- GetHeirloomTrueLevel(itemString)
--
-- Returns the true item level for an heirloom (actually, returns the true level for any adapting item)
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Number, Boolean - The true item level of the item. If the item is not
--                     an heirloom, or an error occurs when trying to scan the
--                     item tooltip, the second return value is false. Otherwise
--                     the second return value is true. If the input is invalid,
--                     (nil, false) is returned.
-- Convert the ITEM_LEVEL constant into a pattern for our use
function lib:GetHeirloomTrueLevel(itemString)
	if type(itemString) ~= "string" then return nil,false end
	local _, itemLink, rarity, itemLevel = CachedGetItemInfo(itemString)
	if (not itemLink) then
		return nil,false
	end
	local rc=ScanTip(itemLink,itemLevel)
	if rc.ilevel then
		return rc.ilevel,true
	end
	return itemLevel, false
end

-- GetUpgradedItemLevel(itemString)
--
-- Returns the true item level of the item, including upgrades and heirlooms.
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Number - The true item level of the item, or nil if the input is invalid
function lib:GetUpgradedItemLevel(itemString)
	-- check for heirlooms first
	local ilvl, isTrue = self:GetHeirloomTrueLevel(itemString)
	if isTrue then
		return ilvl
	end
	-- not an heirloom? fall back to the regular item logic
	local id = self:GetUpgradeID(itemString)
	if ilvl and id then
		ilvl = ilvl + self:GetItemLevelUpgrade(id)
	end
	return ilvl
end

-- IsBop(itemString)
--
-- Check an item for  Bind On Pickup.
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Boolean - True if Bind On Pickup

function lib:IsBop(itemString)
	local rc=ScanTip(itemString)
	return rc.bop
end
-- IsBoe(itemString)
--
-- Check an item for  Bind On Equip.
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Boolean - True if Bind On Equip

function lib:IsBoe(itemString)
	local rc=ScanTip(itemString)
	return rc.boe
end
-- IsBoa(itemString)
--
-- Check an item for  Bind On Aaccount
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Boolean - True if Bind On Equip

function lib:IsBoa(itemString)
	local rc=ScanTip(itemString)
	return rc.boa
end

-- IsArtifact(itemString)
--
-- Check an item for  Heirloom
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Boolean - True if Artifact

function lib:IsArtifact(itemString)
	return CachedGetItemInfo(itemString,i_Quality)==LE_ITEM_QUALITY_ARTIFACT
end

-- GetClassInfoIsHeirloom(itemString)
--
-- Retrieve class and subclass
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   class,subclass


function lib:GetClassInfo(itemString)
	local rc=ScantTip(itemString)
	return rc.class,rc.subclass
end


-- IsHeirloom(itemString)
--
-- Check an item for  Heirloom
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Boolean - True if Heirloom

function lib:IsHeirloom(itemString)
	return CachedGetItemInfo(itemString,i_Quality) ==LE_ITEM_QUALITY_HEIRLOOM
end
---
-- Parses an itemlink and returns itemId without calling API again
-- @param #lib self
-- @param #string itemlink
-- @return #number itemId or 0
function lib:GetItemID(itemlink)
	if (type(itemlink)=="string") then
			local itemid,context=GetItemInfoFromHyperlink(itemlink)
			return tonumber(itemid) or 0
			--return tonumber(itemlink:match("Hitem:(%d+):")) or 0
	else
			return 0
	end
end

---
--
-- Returns a caching version of GetItemInfo. Can be used to override the original one.
-- Adds a second parameter to directly retrieving a specific value
-- (Note: internally uses select so it's actually like calling select(n,GetItemInfo(itemID))
--
-- Arguments:
--   self #lib self
--
-- Returns:
--   #function The new function
function lib:GetCachingGetItemInfo()
	return CachedGetItemInfo
end
function lib:GetCacheStats()
	local c=lib.itemcache
	local h=c.tot-c.miss
	local perc=( h>0) and h/c.tot*100 or 0
	return c.miss,h,perc
end

--[===========[ ]===========]
--[===[ Debug utilities ]===]
--[===========[ ]===========]

local function compareTables(t1, t2)
	local seen = {}
	for k, v1 in pairs(t1) do
		seen[k] = true
		local v2 = rawget(t2, k)
		if not v2 then return false end
		if type(v1) ~= type(v2) then return false end
		if type(v1) == "table" then
			if not compareTables(v1, v2) then return false end
		elseif v1 ~= v2 then return false end
	end
	for k in pairs(t2) do
		if not seen[k] then return false end
	end
	return true
end

-- prints the table rows in red and green
-- omits the lead { and the trailing }
local function printDiffTable(t1, t2)
	local keys, seen = {}, {}
	for k in pairs(t1) do
		keys[#keys+1] = k
		seen[k] = true
	end
	for k in pairs(t2) do
		if not seen[k] then
			keys[#keys+1] = k
		end
	end
	table.sort(keys)
	local function formatTable(t)
		local comps = {}
		for k, v in pairs(t) do
			comps[#comps+1] = ("%s = %d"):format(k, v)
		end
		return "{ " .. table.concat(comps, ", ") .. " }"
	end
	for _, k in ipairs(keys) do
		local v1, v2 = rawget(t1, k), rawget(t2, k)
		local equal
		if type(v1) == "table" and type(v2) == "table" then equal = compareTables(v1, v2)
		else equal = v1 == v2 end
		if not equal then
			if v1 then
				pp(("|cffff0000    [%d] = %s,|r"):format(k, formatTable(v1)))
			end
			if v2 then
				pp(("|cff00ff00    [%d] = %s,|r"):format(k, formatTable(v2)))
			end
		end
	end
end

-- Scans the first 10000 upgrade IDs
-- Run this with /run LibStub:GetLibrary("LibItemUpgradeInfo-1.0"):_CheckUpgradeTable()
-- If you don't have Aspirant's Staff of Harmony cached it may error out, just try again.
do
	local debugFrame
	local worker
	local newTable
	local debugTooltip
	function lib:_CheckUpgradeTable(itemLink)
		if worker then
			pp("|cffff0000LibItemUpgradeInfo-1.0: upgrade check already in progress")
			return
		end
		if not debugFrame then
			debugFrame = _G.CreateFrame("frame")
			debugFrame:Hide()
			debugFrame:SetScript("OnUpdate", function()
				local ok, result, count, max = pcall(worker)
				if not ok or result then
					debugFrame:Hide()
					worker = nil
				end
				if not ok then
					pp("|cffff0000LibItemUpgradeInfo-1.0 error: " .. result .. "|r")
				elseif result then
					pp("LibItemUpgradeInfo-1.0: scan complete")
					if compareTables(upgradeTable, newTable) then
						pp("LibItemUpgradeInfo-1.0: |cff00ff00No changes|r")
					else
						pp("LibItemUpgradeInfo-1.0: |cffff0000New table:|r {")
						printDiffTable(upgradeTable, newTable)
						pp("}")
					end
				else
					pp("LibItemUpgradeInfo-1.0: scanning " .. count .. "/" .. max)
				end
			end)
		end
		if not debugTooltip then
			debugTooltip = _G.CreateFrame("GameTooltip", "LibItemUpgradeInfoDebugTooltip", nil, "GameTooltipTemplate")
			debugTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
		end
		newTable = {}
		--local itemLink = "|cff0070dd|Hitem:89551:0:0:0:0:0:0:0:90:253:0:0:1:0|h[Aspirant's Staff of Harmony]|h|r"
		local itemLink = itemLink or "|cff0070dd|Hitem:89551:0:0:0:0:0:0:0:100:253:4:0:0:0|h[Aspirant's Staff of Harmony]|h|r"
-- Livello è il 9,upgradeid il 14. Al decimo posto, un valore che deve essere 4 o 4+n *8) per far scattare l'uso dell'upgradeid
		local itemLevel = select(4, _G.GetItemInfo(itemLink))
		assert(itemLevel, "Can't find item level for itemLink")
		local count, max, batchsize = 0, 10000, 200
		worker = function()
			for i = count, math.min(max, count+batchsize) do
				local link = itemLink:gsub("%d+|h", i.."|h")
				debugTooltip:ClearLines()
				debugTooltip:SetHyperlink(link)
				local upgrade, max
				local curLevel, maxLevel = _G.LibItemUpgradeInfoDebugTooltipTextLeft3:GetText():match("^Upgrade Level: (%d+)/(%d+)")
				local ilvl = tonumber(_G.LibItemUpgradeInfoDebugTooltipTextLeft2:GetText():match("Item Level (%d+)"))
				if not ilvl then
					ilvl = tonumber(_G.LibItemUpgradeInfoDebugTooltipTextLeft3:GetText():match("Item Level (%d+)"))
				end
				assert(ilvl ~= nil, "Can't find ItemLevel in tooltip: " .. _G.LibItemUpgradeInfoDebugTooltipTextLeft2:GetText())
				if curLevel or maxLevel or ilvl ~= itemLevel then
					newTable[i] = { upgrade = tonumber(curLevel), max = tonumber(maxLevel), ilevel = ilvl - itemLevel }
				end
			end
			count = count + batchsize
			return (count > max), count, max
		end
		debugFrame:Show()
	end
end

-- vim: set noet sw=4 ts=4:
