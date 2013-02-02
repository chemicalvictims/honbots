--[[

A simple library with Ring of Sorcery (mana replenish item) logic

]]

--[[ bunch of standard imports ]]
local _G = getfenv(0)
local object = _G.object

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


--[[ FindItems override that adds core.itemRingOfSorcery variable ]]
local function FindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemRingOfSorcery ~= nil and not core.itemRingOfSorcery:IsValid() then
		core.itemRingOfSorcery = nil
	end

	if bUpdated then
		--only update if we need to
		if core.itemRingOfSorcery then return end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemRingOfSorcery == nil and curItem:GetName() == "Item_Replenish" then
					core.itemRingOfSorcery = curItem
				end
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = FindItemsOverride


--[[ Replenish mana utility function. Checks if it's really needed ]]
function behaviorLib.ReplenishManaUtility(botBrain)
	local nManaReplenished = 135 --TODO: can we get it from item def?

	local nUtil = 0
	local unitSelf = core.unitSelf

	core.FindItems()
	local itemRingOfSorcery = core.itemRingOfSorcery

	if itemRingOfSorcery and itemRingOfSorcery:CanActivate() then
		local manaToSelf = nManaReplenished - itemRingOfSorcery:GetManaCost()
		local missingMana = unitSelf:GetMaxMana() - unitSelf:GetMana()
		if missingMana >= manaToSelf then
			nUtil = 1000 --highest utility, bcoz it has no cast time or any bad side effects
		end
	end

	return nUtil
end

--[[ Replenish mana execute function ]]
function behaviorLib.ReplenishManaExecute(botBrain)
	core.FindItems()
	local itemRingOfSorcery = core.itemRingOfSorcery

	if itemRingOfSorcery and itemRingOfSorcery:CanActivate() then
		core.OrderItemClamp(botBrain, core.unitSelf, itemRingOfSorcery)
		return true
	end

	return false
end

behaviorLib.ReplenishManaBehavior = {}
behaviorLib.ReplenishManaBehavior["Utility"] = behaviorLib.ReplenishManaUtility
behaviorLib.ReplenishManaBehavior["Execute"] = behaviorLib.ReplenishManaExecute
behaviorLib.ReplenishManaBehavior["Name"] = "ReplenishMana"
tinsert(behaviorLib.tBehaviors, behaviorLib.ReplenishManaBehavior)
