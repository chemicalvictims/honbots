--DSBot v0.000001
local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic 		= true
object.bRunBehaviors	= true
object.bUpdates 		= true
object.bUseShop 		= true

object.bRunCommands 	= true
object.bMoveCommands 	= true
object.bAttackCommands 	= true
object.bAbilityCommands = true
object.bOtherCommands 	= true

object.bReportBehavior = false
object.bDebugUtility = false
object.bDebugExecute = false


object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core 		= {}
object.eventsLib 	= {}
object.metadata 	= {}
object.behaviorLib 	= {}
object.skills 		= {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

local sqrtTwo = math.sqrt(2)

local skillBuild = nil

BotEcho('loading nymphora_main...')

object.heroName = 'Hero_Fairy'

object.nNymphManaGive = 
{
	75, 150, 225, 300
}

object.vecNymphTeleportPositions =
{
	Vector3.Create(15308, 3924, 128), -- Legion Secret Shop
	Vector3.Create(1107, 12410, 128), -- Hellbourne Secret Shop
	Vector3.Create(13223, 3669, 128), -- Near Legion Lane 'Ganking' pos
	Vector3.Create(3056, 12030, 128), -- Near Hellbourne Lane 'Ganking' pos
	Vector3.Create(9868, 3249, 128), -- Legion Jungles
	Vector3.Create(6914, 12709, 128) -- Helbourne Jungles
	
	
}

object.vecNymphTeleportPositionsHellbourne =
{
	Vector3.Create(13963, 13436, 110), -- Helbourne Well
	Vector3.Create(11620, 7974, 128), -- Helbourne Observatory
	Vector3.Create(9425, 8201, 0), -- Helbourne First Mid Tower
	Vector3.Create(14219, 6538, 128), -- Helbourne First Bot Tower
	Vector3.Create(8656, 13997, 128), -- Helbourne Second Top Tower
	Vector3.Create(3766, 14184, 128) -- Helbourne First Top Tower
}

object.vecNymphTeleportPositionsLegion =
{
	Vector3.Create(1726, 1112, 101), -- Legion Well
	Vector3.Create(3609, 9089, 128), -- Legion Observatory
	Vector3.Create(2025, 9316, 128), -- Legion First Top Tower
	Vector3.Create(12773, 1375, 128), -- Legion First Bot Tower
	Vector3.Create(7198, 1455, 128), -- Legion Second Bot Tower
	Vector3.Create(6483, 6242, 0) -- Legion First Mid Tower
}

--------------------------------
-- Skills
--------------------------------
function object:SkillBuild()
 --core.VerboseLog("SkillBuild()")

	local unitSelf = object.core.unitSelf
	local level = unitSelf:GetLevel()
	
	if  skills.health == nil
	then
		skills.health  = unitSelf:GetAbility(0)
		skills.mana   = unitSelf:GetAbility(1)
		skills.stun   = unitSelf:GetAbility(2)
		skills.tele   = unitSelf:GetAbility(3)
		skills.attrib  = unitSelf:GetAbility(4)

		skillBuild = 
		{
			skills.stun, skills.mana, skills.stun,
			skills.mana, skills.stun, skills.tele,
			skills.stun, skills.mana, skills.mana,
			skills.health, skills.tele, skills.health,
			skills.health, skills.health, skills.attrib,
			skills.tele, skills.attrib, skills.attrib,
			skills.attrib, skills.attrib, skills.attrib, 
			skills.attrib, skills.attrib, skills.attrib, 
			skills.attrib
		}
	end

	if unitSelf:GetAbilityPointsAvailable() <= 0 then
		return
	end

	skillBuild[level]:LevelUp()
end

object.nHealUpBonus = 12
object.nManaUpBonus = 8
object.nStunUpBonus = 18
object.nSheepstickUp = 16

object.nStunUseBonus = 18
object.nHealUseBonus = 10
object.nSheepstickUse = 16

object.nStimulusHeal = 3
object.nStimulusMana = 0.7
object.nStimulusStun = 1.5
object.nManaCostWeight = 0.01

object.nTeleportRange = 8000

object.nHealThreshold = 25
object.nStunThreshold = 25
object.nSheepstickThreshold = 30


function getAbilityStimulusStun(targetUnit ,distanceSq)
	local stimulusManaCost = getAbilityStimulusByManaCost(skills.stun)
	local stimulus = 1
	local unitSelf = object.core.unitSelf
	
	stimulus = stimulus / (targetUnit:GetHealth() / targetUnit:GetMaxHealth())
	
	return stimulus * stimulusManaCost
end

function getAbilityStimulusHeal(targetUnit)
	local stimulusManaCost = getAbilityStimulusByManaCost(skills.stun)
	local stimulus = 1
	local unitSelf = object.core.unitSelf
	
	stimulus = stimulus / (targetUnit:GetHealth() / targetUnit:GetMaxHealth())
	
	return stimulus * stimulusManaCost
end

function getAbilityStimulusMana(targetUnit)
	local stimulus = 0
	local manaLevel
	local abilMana = object.core.unitSelf:GetAbility(1)
	
	manaLevel = abilMana:GetLevel()
	
	if(manaLevel ~= nil and manaLevel > 0)
	then
		local manaGiven = object.nNymphManaGive[manaLevel]
		
		return ((targetUnit:GetMaxMana() - targetUnit:GetMana()) / manaGiven)
	end
	return 0
end

function getAbilityStimulusByManaCost(ability)
	local unitSelf = object.core.unitSelf
	
	local manaRatio = (unitSelf:GetMana() / unitSelf:GetMaxMana())
	
	local manaCostRatio = (ability:GetManaCost() / unitSelf:GetMaxMana())
	
	return manaRatio / manaCostRatio
end

---------------------------------------------------
--                   Overrides                   --
---------------------------------------------------

--local thoughtOnce = false

function object:onthinkOverride(tGameVariables)
	--if(thoughtOnce)
	--then
	--	local unitSelf = self.core.unitSelf
	--	local pos = unitSelf:GetPosition()
	--
	--	BotEcho(pos.x .. "," .. pos.y .. "," .. pos.z)
	--	return
	--end
	self:onthinkOld(tGameVariables)
	--thoughtOnce = true
	--core.unitSelf:TeamShare()
	
	local unitSelf = self.core.unitSelf
	local pos = unitSelf:GetPosition()
	
	--BotEcho(pos.x .. "," .. pos.y .. "," .. pos.z)
	
	if(not unitSelf:IsAlive() or unitSelf:IsChanneling())then return end
	
	if(skills.mana:CanActivate() or skills.health:CanActivate())
	then
		local mana = skills.mana
		local health = skills.health
		
		local myTeam = unitSelf:GetTeam()
		
		local minManaRatio = 1
		local heroWithMinManaRatio = nil
		
		local minHealthRatio = 1
		local heroWithMinHealthRatio = nil
		
		local peopleAround = HoN.GetUnitsInRadius(unitSelf:GetPosition(), 800, core.UNIT_MASK_ALIVE + core.UNIT_MASK_HERO)
		for _, hero in pairs(peopleAround) do
			if(hero:GetTeam() == myTeam)
			then
				local manaRatio = hero:GetMana() / hero:GetMaxMana()
				local healthRatio = hero:GetHealth() / hero:GetMaxHealth()
				
				if(manaRatio < minManaRatio)
				then
					minManaRatio = manaRatio
					heroWithMinManaRatio = hero
				end
				if(healthRatio < minHealthRatio)
				then
					minHealthRatio = healthRatio
					heroWithMinHealthRatio = hero
				end
			end
		end
		
		if(not (heroWithMinManaRatio == nil) and mana:CanActivate() and getAbilityStimulusMana(heroWithMinManaRatio) >= object.nStimulusMana)
		then
			core.OrderAbilityEntity(object, mana, heroWithMinManaRatio)
		elseif(not(heroWithMinHealthRatio == nul) and minHealthRatio <= 0.7 and health:CanActivate() and getAbilityStimulusHeal(heroWithMinHealthRatio) >= object.nStimulusHeal)
		then
			core.OrderAbilityPosition(object, health, heroWithMinHealthRatio:GetPosition())
		end
	end
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride

----------------------------------
--	Glacius specific harass bonuses
--
--  Abilities off cd increase harass util
--  Ability use increases harass util for a time
----------------------------------

local function AbilitiesUpUtilityFn()
	local nUtility = 0
	
	if skills.health:CanActivate() then
		nUtility = nUtility + object.nHealUpBonus
	end
	
	if skills.mana:CanActivate() then
		nUtility = nUtility + object.nManaUpBonus
	end
		
	if skills.stun:CanActivate() then
		nUtility = nUtility + object.nStunUpBonus
	end
	
	if object.itemSheepstick and object.itemSheepstick:CanActivate() then
		nUtility = nUtility + object.nSheepstickUp
	end
	
	return nUtility
end

--ability use gives bonus to harass util for a while
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)
	
	local nAddBonus = 0
	
	if EventData.Type == "Ability" then
		--BotEcho("ABILILTY EVENT!  InflictorName: "..EventData.InflictorName)		
		if EventData.InflictorName == "Ability_Fairy3" then
			nAddBonus = nAddBonus + object.nStunUseBonus
		elseif EventData.InflictorName == "Ability_Fairy1" then
			nAddBonus = nAddBonus + object.nHealUseBonus
		end
	elseif EventData.Type == "Item" then
		if core.itemSheepstick ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSheepstick:GetName() then
			nAddBonus = nAddBonus + self.nSheepstickUse
		end
	end
	
	if(core.GetCurrentBehaviorName(object) == "RetreatFromThreat")
	then
		--BotEcho("IM RUNNING AWAY")
	end
	
	if nAddBonus > 0 then
		--decay before we add
		core.DecayBonus(self)
	
		core.nHarassBonus = core.nHarassBonus + nAddBonus
	end
end
object.oncombateventOld = object.oncombatevent
object.oncombatevent 	= object.oncombateventOverride

function behaviorLib.MoveExecuteOverride(botBrain, vecDesiredPosition)
	local bActionTaken = false
	if(skills.tele:CanActivate())
	then
		local unitSelf = object.core.unitSelf
		local goal = vecDesiredPosition
		local selfPos = unitSelf:GetPosition()
		local distSq = Vector3.Distance2DSq(goal, selfPos)
		
		local teamTable
		
		if(unitSelf:GetTeam() == HoN.GetLegionTeam())
		then
			teamTable = object.vecNymphTeleportPositionsLegion
		else
			teamTable = object.vecNymphTeleportPositionsHellbourne
		end
		
		if(distSq >= object.nTeleportRange * object.nTeleportRange)
		then
			local nClosestDestDistSq = 100000 * 100000
			local vecClosestDest = nil
			for i, vecPotentialDest in ipairs(object.vecNymphTeleportPositions)
			do
				local potDestDistSq = Vector3.Distance2DSq(vecPotentialDest, goal)
				if(potDestDistSq < nClosestDestDistSq)
				then
					nClosestDestDistSq = potDestDistSq
					vecClosestDest = vecPotentialDest
				end
			end
			
			for i, vecPotentialDest in ipairs(teamTable)
			do
				local potDestDistSq = Vector3.Distance2DSq(vecPotentialDest, goal)
				if(potDestDistSq < nClosestDestDistSq)
				then
					nClosestDestDistSq = potDestDistSq
					vecClosestDest = vecPotentialDest
				end
			end
			if(vecClosestDest ~= nil)
			then
				object:OrderAbilityPosition(skills.tele, vecClosestDest)
				object:TeamChat("Teleporting Away!")
				bActionTaken = true
			end
		end
	end
	
	if not bActionTaken
	then
		behaviorLib.MoveExecuteOld(botBrain, vecDesiredPosition)
	end
end
behaviorLib.MoveExecuteOld = behaviorLib.MoveExecute
behaviorLib.MoveExecute = behaviorLib.MoveExecuteOverride

--Utility calc override
local function CustomHarassUtilityOverride(hero)
	local nUtility = AbilitiesUpUtilityFn()
	
	return nUtility
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityOverride 


----------------------------------
--	Glacius harass actions
----------------------------------
local rangeForStun = 500
local rangeForHeal = 600

local function HarassHeroExecuteOverride(botBrain)
	local bDebugEchos = false
	
	local unitTarget = behaviorLib.heroTarget
	if unitTarget == nil then
		return false --can not execute, move on to the next behavior
	end
	
	local unitSelf = core.unitSelf
	local vecMyPosition = unitSelf:GetPosition()
	local nMyExtraRange = core.GetExtraRange(unitSelf)
	
	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(unitTarget)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
	
	local nLastHarassUtil = behaviorLib.lastHarassUtil
	local bCanSee = core.CanSeeUnit(botBrain, unitTarget)	
	
	if bDebugEchos then BotEcho("Glacius HarassHero at "..nLastHarassUtil) end
	local bActionTaken = false
	
	if unitSelf:IsChanneling() then
		--continue to do so
		--TODO: early break logic
		return
	end
	
	if core.CanSeeUnit(botBrain, unitTarget) then
		local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized()

		--Sheepstick
		if not bActionTaken and not bTargetVuln then 
			core.FindItems()
			local itemSheepstick = core.itemSheepstick
			if itemSheepstick then
				local nRange = itemSheepstick:GetRange()
				if itemSheepstick:CanActivate() and nLastHarassUtil > object.nSheepstickThreshold then
					if nTargetDistanceSq < (nRange * nRange) then
						bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemSheepstick, unitTarget)
					end
				end
			end
		end
	end
	
	if not bActionTaken and nLastHarassUtil > botBrain.nStunThreshold then
		local stun = skills.stun
		
		if(stun:CanActivate())
		then
			if(nTargetDistanceSq <= rangeForStun * rangeForStun and getAbilityStimulusStun(unitTarget) >= object.nStimulusStun)
			then
				core.OrderAbilityPosition(botBrain, stun, vecTargetPosition)
				bActionTaken = true
			end
		end
	end
	
	if not bActionTaken and bTargetRooted and nLastHarassUtil > botBrain.nHealThreshold
	then
		local heal = skills.health
		if(heal:CanActivate())
		then
			if(nTargetDistanceSq <= rangeForHeal * rangeForHeal and getAbilityStimulusHeal(unitTarget) >= botBrain.nStimulusHeal)
			then
				core.OrderAbilityPosition(botBrain, heal, vecTargetPosition)
				bActionTaken = true
			end
		end
	end
	
	if not bActionTaken then
		if bDebugEchos then BotEcho("  No action yet, proceeding with normal harass execute.") end
		return object.harassExecuteOld(botBrain)
	end
end
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


----------------------------------
--  FindItems Override
----------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemAstrolabe ~= nil and not core.itemAstrolabe:IsValid() then
		core.itemAstrolabe = nil
	end
	if core.itemSheepstick ~= nil and not core.itemSheepstick:IsValid() then
		core.itemSheepstick = nil
	end

	if bUpdated then
		--only update if we need to
		if core.itemSheepstick and core.itemAstrolabe then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemAstrolabe == nil and curItem:GetName() == "Item_Astrolabe" then
					core.itemAstrolabe = core.WrapInTable(curItem)
					core.itemAstrolabe.nHealValue = 200
					core.itemAstrolabe.nRadius = 600
					--Echo("Saving astrolabe")
				elseif core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
					core.itemSheepstick = core.WrapInTable(curItem)
				end
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride


--TODO: extract this out to behaviorLib
----------------------------------
--	Glacius's Help behavior
--	
--	Utility: 
--	Execute: Use Astrolabe
----------------------------------
behaviorLib.nHealUtilityMul = 0.8
behaviorLib.nHealHealthUtilityMul = 1.0
behaviorLib.nHealTimeToLiveUtilityMul = 0.5

function behaviorLib.HealHealthUtilityFn(unitHero)
	local nUtility = 0
	
	local nYIntercept = 100
	local nXIntercept = 100
	local nOrder = 2

	nUtility = core.ExpDecay(unitHero:GetHealthPercent() * 100, nYIntercept, nXIntercept, nOrder)
	
	return nUtility
end

function behaviorLib.TimeToLiveUtilityFn(unitHero)
	--Increases as your time to live based on your damage velocity decreases
	local nUtility = 0
	
	local nHealthVelocity = unitHero:GetHealthVelocity()
	local nHealth = unitHero:GetHealth()
	local nTimeToLive = 9999
	if nHealthVelocity < 0 then
		nTimeToLive = nHealth / (-1 * nHealthVelocity)
		
		local nYIntercept = 100
		local nXIntercept = 20
		local nOrder = 2
		nUtility = core.ExpDecay(nTimeToLive, nYIntercept, nXIntercept, nOrder)
	end
	
	nUtility = Clamp(nUtility, 0, 100)
	
	--BotEcho(format("%d timeToLive: %g  healthVelocity: %g", HoN.GetGameTime(), nTimeToLive, nHealthVelocity))
	
	return nUtility, nTimeToLive
end

behaviorLib.nHealCostBonus = 10
behaviorLib.nHealCostBonusCooldownThresholdMul = 4.0
function behaviorLib.AbilityCostBonusFn(unitSelf, ability)
	local bDebugEchos = false
	
	local nCost =		ability:GetManaCost()
	local nCooldownMS =	ability:GetCooldownTime()
	local nRegen =		unitSelf:GetManaRegen()
	
	local nTimeToRegenMS = nCost / nRegen * 1000
	
	if bDebugEchos then BotEcho(format("AbilityCostBonusFn - nCost: %d  nCooldown: %d  nRegen: %g  nTimeToRegen: %d", nCost, nCooldownMS, nRegen, nTimeToRegenMS)) end
	if nTimeToRegenMS < nCooldownMS * behaviorLib.nHealCostBonusCooldownThresholdMul then
		return behaviorLib.nHealCostBonus
	end
	
	return 0
end

behaviorLib.unitHealTarget = nil
behaviorLib.nHealTimeToLive = nil
function behaviorLib.HealUtility(botBrain)
	local bDebugEchos = false
	
	--[[
	if object.myName == "Bot1" then
		bDebugEchos = true
	end
	--]]
	if bDebugEchos then BotEcho("HealUtility") end
	
	local nUtility = 0

	local unitSelf = core.unitSelf
	behaviorLib.unitHealTarget = nil
	
	core.FindItems()
	local itemAstrolabe = core.itemAstrolabe
	
	local nHighestUtility = 0
	local unitTarget = nil
	local nTargetTimeToLive = nil
	local sAbilName = ""
	if itemAstrolabe and itemAstrolabe:CanActivate() then
		local tTargets = core.CopyTable(core.localUnits["AllyHeroes"])
		tTargets[unitSelf:GetUniqueID()] = unitSelf --I am also a target
		for key, hero in pairs(tTargets) do
			--Don't heal ourself if we are going to head back to the well anyway, 
			--	as it could cause us to retrace half a walkback
			if hero:GetUniqueID() ~= unitSelf:GetUniqueID() or core.GetCurrentBehaviorName(botBrain) ~= "HealAtWell" then
				local nCurrentUtility = 0
				
				local nHealthUtility = behaviorLib.HealHealthUtilityFn(hero) * behaviorLib.nHealHealthUtilityMul
				local nTimeToLiveUtility = nil
				local nCurrentTimeToLive = nil
				nTimeToLiveUtility, nCurrentTimeToLive = behaviorLib.TimeToLiveUtilityFn(hero)
				nTimeToLiveUtility = nTimeToLiveUtility * behaviorLib.nHealTimeToLiveUtilityMul
				nCurrentUtility = nHealthUtility + nTimeToLiveUtility
				
				if nCurrentUtility > nHighestUtility then
					nHighestUtility = nCurrentUtility
					nTargetTimeToLive = nCurrentTimeToLive
					unitTarget = hero
					if bDebugEchos then BotEcho(format("%s Heal util: %d  health: %d  ttl:%d", hero:GetTypeName(), nCurrentUtility, nHealthUtility, nTimeToLiveUtility)) end
				end
			end
		end

		if unitTarget then
			nUtility = nHighestUtility				
			sAbilName = "Astrolabe"
		
			behaviorLib.unitHealTarget = unitTarget
			behaviorLib.nHealTimeToLive = nTargetTimeToLive
		end		
	end
	
	if bDebugEchos then BotEcho(format("    abil: %s util: %d", sAbilName, nUtility)) end
	
	nUtility = nUtility * behaviorLib.nHealUtilityMul
	
	if botBrain.bDebugUtility == true and nUtility ~= 0 then
		BotEcho(format("  HelpUtility: %g", nUtility))
	end
	
	return nUtility
end

function behaviorLib.HealExecute(botBrain)
	core.FindItems()
	local itemAstrolabe = core.itemAstrolabe
	
	local unitHealTarget = behaviorLib.unitHealTarget
	local nHealTimeToLive = behaviorLib.nHealTimeToLive
	
	if unitHealTarget and itemAstrolabe and itemAstrolabe:CanActivate() then 
		local unitSelf = core.unitSelf
		local vecTargetPosition = unitHealTarget:GetPosition()
		local nDistance = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPosition)
		if nDistance < itemAstrolabe.nRadius then
			core.OrderItemClamp(botBrain, unitSelf, itemAstrolabe)
		else
			core.OrderMoveToUnitClamp(botBrain, unitSelf, unitHealTarget)
		end
	else
		return false
	end
	
	return true
end

behaviorLib.HealBehavior = {}
behaviorLib.HealBehavior["Utility"] = behaviorLib.HealUtility
behaviorLib.HealBehavior["Execute"] = behaviorLib.HealExecute
behaviorLib.HealBehavior["Name"] = "Heal"
tinsert(behaviorLib.tBehaviors, behaviorLib.HealBehavior)


function behaviorLib.RetreatFromThreatExecuteOverride(botBrain)
	local unitSelf = object.core.unitSelf
	local vecPos = unitSelf:GetPosition()
	local myTeam = unitSelf:GetTeam()
	
	if(behaviorLib.lastRetreatUtil > behaviorLib.retreatStunUtilThreshold and skills.stun:CanActivate())
	then
		local stun = skills.stun
		local closestThreatVec = nil
		local unitsHeroes = HoN.GetUnitsInRadius(vecPos, 800, core.UNIT_MASK_ALIVE + core.UNIT_MASK_HERO)
		
		for _, unitHero in pairs(unitsHeroes) do
			local vecHeroPos = unitHero:GetPosition()
			if(behaviorLib.GetThreat(unitHero) > behaviorLib.retreatStunThreatThreshold and HoN.CanSeePosition(vecHeroPos) and unitHero:GetTeam() ~= unitSelf:GetTeam())
			then
				closestThreatVec = unitHero:GetPosition()
			end
		end
		
		if(not(closestThreatVec == nil))
		then
			core.OrderAbilityPosition(botBrain, stun, closestThreatVec)
		end
	end
	return object.RetreatFromThreatExecuteOld(botBrain)
end

behaviorLib.retreatStunThreatThreshold = 3000
behaviorLib.retreatStunUtilThreshold = 20
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatBehavior["Execute"]
behaviorLib.RetreatFromThreatBehavior["Execute"] = behaviorLib.RetreatFromThreatExecuteOverride

local function healingPushStrength()
	return skills.health:GetLevel() * 20 -- 20 at level 4 heal
end

local function PushingStrengthUtilityOverride(myHero)
	local nUtility = object.funcPushUtilityOld(myHero)
	
	nUtility = nUtility + healingPushStrength()
	nUtility = Clamp(nUtility, 0, 100)
	
	return nUtility
end
object.funcPushUtilityOld = behaviorLib.PushingStrengthUtility
behaviorLib.PushingStrengthUtility = PushingStrengthUtilityOverride

function behaviorLib.PushExecuteOverride(botBrain)
	local bActionTaken = false
	
	if(skills.health:CanActivate())
	then
		local abilHeal = skills.health
		local vecMyPos, unitSelf, myTeam
		local unitsNear
		
		unitSelf = object.core.unitSelf
		vecMyPos = unitSelf:GetPosition()
		myTeam = unitSelf:GetTeam()
		
		unitsNear = HoN.GetUnitsInRadius(vecMyPos, 600, core.UNIT_MASK_ALIVE + core.UNIT_MASK_UNIT)
		
		for _, unitNear in pairs(unitsNear)
		do
			if(myTeam ~= unitNear:GetTeam() and not (unitNear:IsHero()))
			then
				object:OrderAbilityPosition(abilHeal, unitNear:GetPosition())
				bActionTaken = true
				break
			end
		end
	end
	
	if not bActionTaken
	then
		behaviorLib.PushExecuteOld(botBrain)
	end
end

behaviorLib.PushExecuteOld = behaviorLib.PushBehavior["Execute"]
behaviorLib.PushBehavior["Execute"] = behaviorLib.PushExecuteOverride

--object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
--behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

----------------------------------
--	Glacius items
----------------------------------
--[[ list code:
	"# Item" is "get # of these"
	"Item #" is "get this level of the item" --]]
behaviorLib.StartingItems = 
	{"Item_GuardianRing", "Item_MinorTotem", "2 Item_MinorTotem", "Item_HealthPotion", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = 
	{"Item_ManaRegen3", "Item_Marchers", "Item_Striders", "Item_Strength5"} --ManaRegen3 is Ring of the Teacher, Item_Strength5 is Fortified Bracer
behaviorLib.MidItems = 
	{"Item_Astrolabe", "Item_GraveLocket", "Item_SacrificialStone", "Item_Intelligence7"} --Intelligence7 is Staff of the Master
behaviorLib.LateItems = 
	{"Item_Morph", "Item_BehemothsHeart", 'Item_Damage9'} --Morph is Sheepstick. Item_Damage9 is Doombringer



--[[ colors:
	red
	aqua == cyan
	gray
	navy
	teal
	blue
	lime
	black
	brown
	green
	olive
	white
	silver
	purple
	maroon
	yellow
	orange
	fuchsia == magenta
	invisible
--]]

BotEcho('finished loading nymphora_main')
