-- ============================================================================
-- Base Item Lists
-- ============================================================================

local MAGE_WATER = {
	"Conjured Crystal Water",
	"Conjured Sparkling Water",
	"Conjured Mineral Water",
	"Conjured Spring Water",
	"Conjured Purified Water",
	"Conjured Fresh Water",
	"Conjured Water",
}

local MAGE_FOOD = {
	"Conjured Cinnamon Roll",
	"Conjured Sweet Roll",
	"Conjured Sourdough",
	"Conjured Pumpernickel",
	"Conjured Rye",
	"Conjured Bread",
	"Conjured Muffin",
}

local AV_ITEMS = {
	"Alterac Manna Biscuit",
	"Enriched Manna Biscuit",
	"Bottled Alterac Spring Water",
}

local WSG_ITEMS = {
	"Warsong Gulch Enriched Ration",
	"Warsong Gulch Field Ration",
	"Warsong Gulch Iron Ration",
}

local AB_ITEMS = {
	"Arathi Basin Enriched Ration",
	"Arathi Basin Field Ration",
	"Arathi Basin Iron Ration",
}

local NORMAL_WATER = {
	"Morning Glory Dew",
	"Blessed Sunfruit Juice",
	"Moonberry Juice",
	"Sweet Nectar",
	"Melon Juice",
	"Ice Cold Milk",
	"Refreshing Spring Water",
}

local NORMAL_FOOD = {
	"Alterac Swiss",
	"Spinefin Halibut",
	"Roasted Quail",
	"Cured Ham Steak",
	"Dried King Bolete",
	"Deep Fried Plantains",
	"Mutton Chop",
	"Wild Hog Shank",
	"Tough Hunk of Bread",
}

-- ============================================================================
-- Zone Priority Builder
-- ============================================================================

local function BuildPriorityList(isWater)
	local list = {}
	local zone = GetRealZoneText() or ""

	-- Mage consumables always first
	local mageList = isWater and MAGE_WATER or MAGE_FOOD
	for _, item in ipairs(mageList) do
		table.insert(list, item)
	end

	-- Add matching BG consumables
	if zone == "Alterac Valley" then
		for _, item in ipairs(AV_ITEMS) do
			table.insert(list, item)
		end
	elseif zone == "Warsong Gulch" then
		for _, item in ipairs(WSG_ITEMS) do
			table.insert(list, item)
		end
	elseif zone == "Arathi Basin" then
		for _, item in ipairs(AB_ITEMS) do
			table.insert(list, item)
		end
	end

	-- Fallback to standard consumables
	local normalList = isWater and NORMAL_WATER or NORMAL_FOOD
	for _, item in ipairs(normalList) do
		table.insert(list, item)
	end

	return list
end

-- ============================================================================
-- Helpers
-- ============================================================================

local lastComboUse = 0

local function IsComboItem(name)
	if not name then return false end
	local low = string.lower(name)
	return string.find(low, "ration", 1, true) or string.find(low, "biscuit", 1, true)
end

local function HasBuffTexture(texturePart)
	local i = 0
	while GetPlayerBuff(i) >= 0 do
		local index = GetPlayerBuff(i)
		local tex = GetPlayerBuffTexture(index)
		if tex and string.find(tex, texturePart, 1, true) then
			return true
		end
		i = i + 1
	end
	return false
end

local function IsAlreadyDrinking()
	return HasBuffTexture("INV_Drink")
end

local function IsAlreadyEating()
	return HasBuffTexture("INV_Misc_Fork&Knife")
end

local function FindBestItem(itemList)
	for _, itemName in ipairs(itemList) do
		local searchPattern = string.lower(itemName)
		for bag = 0, 4 do
			local numSlots = GetContainerNumSlots(bag)
			if numSlots and numSlots > 0 then
				for slot = 1, numSlots do
					local link = GetContainerItemLink(bag, slot)
					if link then
						local _, _, nameInLink = string.find(link, "%[(.-)%]")
						if nameInLink and string.lower(nameInLink) == searchPattern then
							local _, itemCount = GetContainerItemInfo(bag, slot)
							return bag, slot, itemCount, nameInLink
						end
					end
				end
			end
		end
	end
	return nil, nil, 0, nil
end

-- ============================================================================
-- SuperMacro Display Sync
-- ============================================================================

local function UpdateMacroDisplay()
	local macroIndex = GetMacroIndexByName("autorest")
	if macroIndex and macroIndex > 0 then
		local waterList = BuildPriorityList(true)
		local _, _, _, waterName = FindBestItem(waterList)
		if waterName then
			-- Keep SuperMacro icon and count synced
			EditMacro(macroIndex, "autorest", 1, "/autorest\n/run if false then UseItemByName(\"" .. waterName .. "\") end", 1)
		end
	end
end

-- ============================================================================
-- Core Actions
-- ============================================================================

function ADE_Drink()
	if UnitAffectingCombat("player") then return end
	if UnitPowerType("player") ~= 0 then return end
	if UnitMana("player") >= UnitManaMax("player") then return end
	if IsAlreadyDrinking() then return end

	local waterList = BuildPriorityList(true)
	local bag, slot, _, foundName = FindBestItem(waterList)

	if bag and slot then
		-- Avoid double-triggering combo items while eating
		if IsComboItem(foundName) then
			if IsAlreadyEating() or (GetTime() - lastComboUse) < 0.5 then return end
		end

		local _, duration = GetContainerItemCooldown(bag, slot)
		if duration == 0 then
			UseContainerItem(bag, slot)
			if IsComboItem(foundName) then
				lastComboUse = GetTime()
			end
		end
	end
end

function ADE_Eat()
	if UnitAffectingCombat("player") then return end
	if UnitHealth("player") >= UnitHealthMax("player") then return end
	if IsAlreadyEating() then return end

	local foodList = BuildPriorityList(false)
	local bag, slot, _, foundName = FindBestItem(foodList)

	if bag and slot then
		-- Avoid double-triggering combo items while drinking
		if IsComboItem(foundName) then
			if IsAlreadyDrinking() or (GetTime() - lastComboUse) < 0.5 then return end
		end

		local _, duration = GetContainerItemCooldown(bag, slot)
		if duration == 0 then
			UseContainerItem(bag, slot)
			if IsComboItem(foundName) then
				lastComboUse = GetTime()
			end
		end
	end
end

function ADE_DrinkAndEat()
	ADE_Drink()
	ADE_Eat()
end

-- ============================================================================
-- Events & Slash Commands
-- ============================================================================

local f = CreateFrame("Frame")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:SetScript("OnEvent", function()
	UpdateMacroDisplay()
end)

SLASH_ADEDRINK1 = "/autodrink"
SlashCmdList["ADEDRINK"] = ADE_Drink

SLASH_ADEEAT1 = "/autoeat"
SlashCmdList["ADEEAT"] = ADE_Eat

SLASH_ADEREST1 = "/autorest"
SlashCmdList["ADEREST"] = ADE_DrinkAndEat