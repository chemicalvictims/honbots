
-- EngiBot v 1.01
-- Built by V1P3R`
-- This Bot has been designed to be an aggressive early game harasser, and transition
-- into a powerful team presence bot. 
--
--
-- How the skills work
-- EngiBot is fairly accurate with his Keg stuns and enjoys pressuring heroes from 
-- a very early stage. This allows the laning bot or player to follow up with another
-- stun or ability in order to finish the enemy.
-- Along with Keg stuns, EngiBot will place the turret positioned "at the feet" or 
-- "directly below" the enemy unit. Immediately after, EngiBot will follow up with
-- a Keg Stun.
-- If possible, EngiBot will then move into position, and use his Energy Field in order
-- to maximize damage.
-- Spider Mines are now implemented. When in range, EngiBot will drop a spider mine.
-- Additionally, after landing a Keg stun, EngiBot will attempt to move into range and 
-- drop a spider mine resulting in a more efficient combination

-- EngiBot is still a work in progress and I am always looking to implement new 
-- features and ideas. Please report any ideas or comments,
-- as well as issues to me via PM or email at nlagueruela@yahoo.com.

-- Upcoming impelementations
-- Spider Mine tweak (Specifically dropping mines while retreating to base 
-- and if being pursued 
-- Portal Key initiation
-- Smarter vector targetting for turret (based on hero position)

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

BotEcho('loading engineer_main...')

object.heroName = 'Hero_Engineer'

object.tSkills = {
	0, 1, 0, 1, 0, -- Keg lvl 3 Turret lvl 2
	3, 0, 1, 1, 4, -- Ultimate lvl 1 Keg lvl 4 Turret lvl 4 Attributes lvl 1
	3, 2, 2, 2, 2, -- Ultimate lvl 2 Spider Mines lvl 4
	3, 4, 4, 4, 4, -- Ultimate lvl 3 Attributes lvl 5
	4, 4, 4, 4, 4, -- Attributes lvl 10
}

--------------------------------
-- Skills
--------------------------------
function object:SkillBuild()
local unitSelf = self.core.unitSelf

	if skills.abilKeg == nil then
		skills.abilKeg		= unitSelf:GetAbility(0)
		skills.abilTurret	= unitSelf:GetAbility(1)
		skills.abilSpiderMine	= unitSelf:GetAbility(2)
		skills.abilEnergyField	= unitSelf:GetAbility(3)
		skills.abilAttributeBoost	= unitSelf:GetAbility(4)
	end

	if unitSelf:GetAbilityPointsAvailable() <= 0 then
		return
	end
	
	local nLev = unitSelf:GetLevel()
    local nLevPts = unitSelf:GetAbilityPointsAvailable()
    for i = nLev, nLev+nLevPts do
        unitSelf:GetAbility( object.tSkills[i] ):LevelUp()
    end
end

----------------------------------
--	EngiBot's specific harass bonuses
--
--  Abilities off cd increase harass util
--  Ability use increases harass util for a time
----------------------------------
-- These are bonus agression points if a skill or item is available for use
object.nKegUpBonus = 15
object.nTurretUpBonus = 18
object.nEnergyFieldUpBonus = 60
object.nSpiderMineUpBonus = 10
object.nSheepstickUp = 12
object.nPortalKeyUp = 40

-- These are bonus agression points that are applied to the bot upon successfully using a skill or item
object.nKegUseBonus = 22
object.nTurretUseBonus = 20
object.nEnergyFieldUseBonus = 60
object.nSpiderMineUseBonus = 50
object.nSheepstickUse = 16
object.nPortalKeyUse = 50

-- These are thresholds of aggression the bot must reach to use these abilities
object.nKegThreshold = 22
object.nTurretThreshold = 25
object.nEnergyFieldThreshold = 30
object.nSpiderMineThreshold = 30
object.nSheepstickThreshold = 30
object.nPortalKeyThreshold = 20

local function AbilitiesUpUtilityFn()
	local nUtility = 0
	local val = 0
	
	if skills.abilKeg:CanActivate() then
		nUtility = nUtility + object.nKegUpBonus
	end
	
	if skills.abilTurret:CanActivate() then
		nUtility = nUtility + object.nTurretUpBonus
	end
	
	if skills.abilSpiderMine:CanActivate() then
		nUtility = nUtility + object.nSpiderMineUpBonus
	end
		
	if skills.abilEnergyField:CanActivate() then
		nUtility = nUtility + object.nEnergyFieldUpBonus
	end
	
	if object.itemPortalKey and object.itemPortalKey:CanActivate() then
		nUtility = nUtility + object.nPortalKeyUp
	end
	
	if object.itemSheepstick and object.itemSheepstick:CanActivate() then
		nUtility = nUtility + object.nSheepstickUp
	end
	
	return nUtility
end

object.UseTurret = false
--ability use gives bonus to harass util for a while
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)
	
	local nAddBonus = 0
	
	if EventData.Type == "Ability" then
		--BotEcho("ABILILTY EVENT!  InflictorName: "..EventData.InflictorName)		
		if EventData.InflictorName == "Ability_Engineer1" then
			nAddBonus = nAddBonus + object.nKegUseBonus
		elseif EventData.InflictorName == "Ability_Engineer2" then
			nAddBonus = nAddBonus + object.nTurretUseBonus
		elseif EventData.InflictorName == "Ability_Engineer3" then
			nAddBonus = nAddBonus + object.nSpiderMineUseBonus
		elseif EventData.InflictorName == "Ability_Engineer4" then
			nAddBonus = nAddBonus + object.nEnergyFieldUseBonus
		end
	elseif EventData.Type == "Item" then
		if core.itemSheepstick ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSheepstick:GetName() then
			nAddBonus = nAddBonus + self.nSheepstickUse
		end
	end
	
	if nAddBonus > 0 then
		--decay before we add
		core.DecayBonus(self)
	
		core.nHarassBonus = core.nHarassBonus + nAddBonus
	end
end
object.oncombateventOld = object.oncombatevent
object.oncombatevent 	= object.oncombateventOverride

--Utility calc override
local function CustomHarassUtilityOverride(hero)
	local nUtility = AbilitiesUpUtilityFn()
	
	return nUtility
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityOverride  


----------------------------------
--	Enginner's harass actions
----------------------------------
function object.GetKegRadius()
	return 200
end

function object.GetSpiderMineRadius()
	return 550
end

function object.GetEnergyFieldRadius()
	return 575
end

function object.GetTurretRadius()
	return 400
end

--local timeStunned=0

local function HarassHeroExecuteOverride(botBrain)
	local bDebugEchos = false
	
	local unitTarget = behaviorLib.heroTarget
	if unitTarget == nil then
		return false --can not execute, move on to the next behavior
	end
	
	local unitSelf = core.unitSelf
	local vecMyPosition = unitSelf:GetPosition()
	local nMyExtraRange = core.GetExtraRange(unitSelf)
	
	local targetPosition = unitTarget:GetPosition()
	
	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(unitTarget)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
	
	local nLastHarassUtil = behaviorLib.lastHarassUtil
	local bCanSee = core.CanSeeUnit(botBrain, unitTarget)	
	
	if bDebugEchos then BotEcho("Engineer HarassHero at "..nLastHarassUtil) end
	local bActionTaken = false
	
	--since we are using an old pointer, ensure we can still see the target for entity targeting
	if core.CanSeeUnit(botBrain, unitTarget) then
		local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
		core.FindItems()
		local itemPortalKey = core.itemPortalKey

		--Sheepstick usage
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
		--]]
	--end
		--Turret using Vector targetting. Working
		if not bActionTaken and nLastHarassUtil > botBrain.nTurretThreshold and bCanSee then
			if bDebugEchos then BotEcho("  No action yet, checking Turret") end
			local abilTurret = skills.abilTurret
			--Check if turret is available, and which team EngiBot is on.
			if abilTurret:CanActivate() and core.myTeam == HoN.GetHellbourneTeam() then
				botBrain:OrderAbilityVector(skills.abilTurret, Vector3.Create(targetPosition.x+100, targetPosition.y+100), targetPosition)
				bActionTaken = true
			elseif abilTurret:CanActivate() then
				botBrain:OrderAbilityVector(skills.abilTurret, Vector3.Create(targetPosition.x-100, targetPosition.y-100), targetPosition)
				bActionTaken = true
			end
			object.UseTurret = false
		end
		--]]
		--[[ Another turret variation. Not working
		if not bActionTaken and nLastHarassUtil > botBrain.nTurretThreshold then
			if bDebugEchos then BotEcho("  No action yet, checking Turret") end
			local abilTurret = skills.abilTurret
			if abilTurret:CanActivate() then
				local abilTurret = skills.abilTurret
				local nRadius = botBrain.GetTurretRadius()
				local nRange = skills.abilTurret and skills.abilTurret:GetRange() or nil
				local vecTarget = core.AoETargeting(unitSelf, nRange, nRadius, true, unitTarget, core.enemyTeam, nil)
				
				if vecTarget then
					bActionTaken = core.OrderAbilityPosition(botBrain, abilTurret, vecTarget)
				end
			end
		end
		--]]
	end
	
	-- Keg code similar to Glacius tundra blast
	if not bActionTaken and nLastHarassUtil > botBrain.nKegThreshold then
		if bDebugEchos then BotEcho("  No action yet, checking Keg") end
		local abilKeg = skills.abilKeg
		if abilKeg:CanActivate() then
			local abilKeg = skills.abilKeg
			local nRadius = botBrain.GetKegRadius()
			local nRange = skills.abilKeg and skills.abilKeg:GetRange() or nil
			local vecTarget = core.AoETargeting(unitSelf, nRange, nRadius, true, unitTarget, core.enemyTeam, nil)
				
			if vecTarget then
				bActionTaken = core.OrderAbilityPosition(botBrain, abilKeg, vecTarget)
			end
		end
	end
	--[[
	-- Keg using FA's crippling volley code. Used for prediction of landing keg.
	if not bActionTaken and nLastHarassUtility > botBrain.nKegThreshold then
		if bDebugEchos then BotEcho("  No action yet, checking keg") end
		local abilKeg = skills.abilKeg
		if abilKeg:CanActivate() then
			local nRange = abilKeg:GetRange()
			if nTargetDistanceSq < (nRange * nRange) then
				local vecTarget = vecTargetPosition
				
				--prediction
				if unitTarget.bIsMemoryUnit then
					--core.teamBotBrain:UpdateMemoryUnit(unitTarget)
					if unitTarget.storedPosition and unitTarget.lastStoredPosition then
						local vecLastDirection = Vector3.Normalize(unitTarget.storedPosition - unitTarget.lastStoredPosition)
						vecTarget = vecTarget + vecLastDirection * object.GetKegRadius()
						--core.DrawDebugArrow(vecTargetPosition, vecTarget, 'orange')
						--core.DrawXPosition(vecTarget, 'red', 400)
					end
				end
				
				bActionTaken = core.OrderAbilityPosition(botBrain, abilKeg, vecTarget)
			end
		end 
	end
	--]]
	--[[ Portal Key implementation used in karius101' pebbsbot. Not working atm
	if not bActionTaken then-- and not bTargetVuln then
		if itemPortalKey then
			local nPortalKeyRange = itemPortalKey:GetRange()
            if itemPortalKey:CanActivate() then--and unitSelf:GetMana()>315 and nLastHarassUtility > botBrain.nPortalkeyThreshold then
					--BotEcho(" " .. nTargetDistanceSq .. " " .. (nRange*nRange));
				if nTargetDistanceSq <= (nPortalKeyRange*nPortalKeyRange) and nTargetDistanceSq>(750*750) then
					bActionTaken = core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecTargetPosition) --teleport on that mofo
						
					bActionTaken = core.OrderAbilityPosition(botBrain, abilEnergyField,(vecTargetPosition+relativeMov), false, true)
					timeStunned=HoN.GetGameTime()
					
					bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget, false, true)
						
				elseif nTargetDistanceSq>(nPortalKeyRange*nPortalKeyRange) then
					bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
				end
			end
		end
	end
	--]]
	-- Energy Field similar to Glacius ultimate code
		if not bActionTaken and nLastHarassUtil > botBrain.nEnergyFieldThreshold then
			if bDebugEchos then BotEcho("  No action yet, checking Energy Field.") end
			local abilEnergyField = skills.abilEnergyField
			if abilEnergyField:CanActivate() then
			--get the target well within the radius for maximum effect
				local nRadius = botBrain.GetEnergyFieldRadius()
				local nHalfRadiusSq = nRadius * nRadius * 0.25
				if nTargetDistanceSq <= nHalfRadiusSq then
					bActionTaken = core.OrderAbility(botBrain, abilEnergyField)
				elseif not unitSelf:IsAttackReady() then
				--move in when we aren't attacking
					core.OrderMoveToUnit(botBrain, unitSelf, unitTarget)
					bActionTaken = true
				end
			end
		end
		
		if not bActionTaken and nLastHarassUtil > botBrain.nSpiderMineThreshold then
			if bDebugEchos then BotEcho("  No action yet, checking Energy Field.") end
			local abilSpiderMine = skills.abilSpiderMine
			if abilSpiderMine:CanActivate() then
			--get the target well within the radius for maximum effect
				local nRadius = botBrain.GetSpiderMineRadius()
				local nHalfRadiusSq = nRadius * nRadius * 0.25
				if nTargetDistanceSq <= nHalfRadiusSq then
					bActionTaken = core.OrderAbility(botBrain, abilSpiderMine)
				elseif not unitSelf:IsAttackReady() then
				--move in when we aren't attacking
					core.OrderMoveToUnit(botBrain, unitSelf, unitTarget)
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

	if core.itemPortalKey ~= nil and not core.itemPortalKey:IsValid() then
		core.itemPortalKey = nil
	end
	if core.itemSheepstick ~= nil and not core.itemSheepstick:IsValid() then
		core.itemSheepstick = nil
	end
	if core.itemRoS ~= nil and not core.itemRoS:IsValid() then
		core.itemRoS = nil
	end

	if bUpdated then
		--only update if we need to
		if core.itemSheepstick and core.itemRoS and core.itemPortalKey then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
					core.itemSheepstick = core.WrapInTable(curItem)
				elseif core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
					core.itemPortalKey = core.WrapInTable(curItem)
					core.itemPortalKey.nRadius = 1200
				elseif core.itemRoS == nil and curItem:GetName() == "Item_Replenish" then
					core.itemRoS = core.WrapInTable(curItem)
					core.itemRoS.nReplenishValue = 135
					core.itemRoS.nRadius = 500
				end
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride
-----------------------------------------------
--  DJulio's Ring of Sorcery Implementation
--  
--	Execute: Use Ring of Sorcery (edited Astrolabe code)
----------------------------------

behaviorLib.nReplenishUtilityMul = 1.3
behaviorLib.nReplenishManaUtilityMul = 1.0
behaviorLib.nReplenishTimeToLiveUtilityMul = 0.5

function behaviorLib.ReplenishManaUtilityFn(unitHero)
	local nUtility = 0
	
	local nYIntercept = 100
	local nXIntercept = 100
	local nOrder = 2

	nUtility = core.ExpDecay(unitHero:GetManaPercent() * 100, nYIntercept, nXIntercept, nOrder)
	
	return nUtility
end

function behaviorLib.TimeToLiveUtilityFn(unitHero)
	--Increases as your time to live based on your damage velocity decreases
	local nUtility = 0
	
	local nManaVelocity = unitHero:GetManaRegen()	-- Get mana regen
	local nMana = unitHero:GetMana()				-- Get mana
	local nTimeToLive = 9999
	if nManaVelocity < 0 then
		nTimeToLive = nMana / (-1 * nManaVelocity)
		
		local nYIntercept = 100
		local nXIntercept = 20
		local nOrder = 2
		nUtility = core.ExpDecay(nTimeToLive, nYIntercept, nXIntercept, nOrder)
	end
	
	nUtility = Clamp(nUtility, 0, 100)
	
	--BotEcho(format("%d timeToLive: %g  healthVelocity: %g", HoN.GetGameTime(), nTimeToLive, nManaVelocity))
	
	return nUtility, nTimeToLive
end

behaviorLib.nReplenishCostBonus = 10
behaviorLib.nReplenishCostBonusCooldownThresholdMul = 4.0
function behaviorLib.AbilityCostBonusFn(unitSelf, ability)
	local bDebugEchos = false
	
	local nCost =		ability:GetManaCost()		-- Get item mana cost
	local nCooldownMS =	ability:GetCooldownTime()	-- Get item cooldown
	local nRegen =		unitSelf:GetManaRegen()		-- Get bot's mana regeneration
	
	local nTimeToRegenMS = nCost / nRegen * 1000
	
	if bDebugEchos then BotEcho(format("AbilityCostBonusFn - nCost: %d  nCooldown: %d  nRegen: %g  nTimeToRegen: %d", nCost, nCooldownMS, nRegen, nTimeToRegenMS)) end
	if nTimeToRegenMS < nCooldownMS * behaviorLib.nReplenishCostBonusCooldownThresholdMul then
		return behaviorLib.nReplenishCostBonus
	end
	
	return 0
end

behaviorLib.unitReplenishTarget = nil
behaviorLib.nReplenishTimeToLive = nil
function behaviorLib.ReplenishUtility(botBrain)
	local bDebugEchos = false
	
	if bDebugEchos then BotEcho("ReplenishUtility") end
	
	local nUtility = 0

	local unitSelf = core.unitSelf
	behaviorLib.unitReplenishTarget = nil
	
	core.FindItems()
	local itemRoS = core.itemRoS
	
	local nHighestUtility = 0
	local unitTarget = nil
	local nTargetTimeToLive = nil
	local sAbilName = ""
	if itemRoS and itemRoS:CanActivate() then
		local tTargets = core.CopyTable(core.localUnits["AllyHeroes"]) 	-- Get allies close to the bot
		tTargets[unitSelf:GetUniqueID()] = unitSelf 					-- Identify bot as a target too
		for key, hero in pairs(tTargets) do
			--Don't mana ourself if we are going to head back to the well anyway, 
			--	as it could cause us to retrace half a walkback
			if hero:GetUniqueID() ~= unitSelf:GetUniqueID() or core.GetCurrentBehaviorName(botBrain) ~= "HealAtWell" then
				local nCurrentUtility = 0
				
				local nManaUtility = behaviorLib.ReplenishManaUtilityFn(hero) * behaviorLib.nReplenishManaUtilityMul
				local nTimeToLiveUtility = nil
				local nCurrentTimeToLive = nil
				nTimeToLiveUtility, nCurrentTimeToLive = behaviorLib.TimeToLiveUtilityFn(hero)
				nTimeToLiveUtility = nTimeToLiveUtility * behaviorLib.nReplenishTimeToLiveUtilityMul
				nCurrentUtility = nManaUtility + nTimeToLiveUtility
				
				if nCurrentUtility > nHighestUtility then
					nHighestUtility = nCurrentUtility
					nTargetTimeToLive = nCurrentTimeToLive
					unitTarget = hero
					if bDebugEchos then BotEcho(format("%s Replenish util: %d  health: %d  ttl:%d", hero:GetTypeName(), nCurrentUtility, nReplenishUtility, nTimeToLiveUtility)) end
				end
			end
		end

		if unitTarget then
			nUtility = nHighestUtility				
			sAbilName = "Replenish"
		
			behaviorLib.unitReplenishTarget = unitTarget
			behaviorLib.nReplenishTimeToLive = nTargetTimeToLive
		end		
	end
	
	if bDebugEchos then BotEcho(format("    abil: %s util: %d", sAbilName, nUtility)) end
	
	nUtility = nUtility * behaviorLib.nReplenishUtilityMul
	
	if botBrain.bDebugUtility == true and nUtility ~= 0 then
		BotEcho(format("  HelpUtility: %g", nUtility))
	end
	
	return nUtility
end

-- Executing the behavior to use the Ring of Sorcery
function behaviorLib.ReplenishExecute(botBrain)
	core.FindItems()
	local itemRoS = core.itemRoS
	
	local unitReplenishTarget = behaviorLib.unitReplenishTarget
	local nReplenishTimeToLive = behaviorLib.nReplenishTimeToLive
	
	if unitReplenishTarget and itemRoS and itemRoS:CanActivate() then 
		local unitSelf = core.unitSelf													-- Get bot's position
		local vecTargetPosition = unitReplenishTarget:GetPosition()						-- Get target's position
		local nDistance = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPosition)	-- Get distance between bot and target
		if nDistance < itemRoS.nRadius then
			core.OrderItemClamp(botBrain, unitSelf, itemRoS) -- Use Ring of Sorcery, if in range
		else
			core.OrderMoveToUnitClamp(botBrain, unitSelf, unitReplenishTarget) -- Move closer to target
		end
	else
		return false
	end
	
	return true
end

behaviorLib.ReplenishBehavior = {}
behaviorLib.ReplenishBehavior["Utility"] = behaviorLib.ReplenishUtility
behaviorLib.ReplenishBehavior["Execute"] = behaviorLib.ReplenishExecute
behaviorLib.ReplenishBehavior["Name"] = "Replenish"
tinsert(behaviorLib.tBehaviors, behaviorLib.ReplenishBehavior)

----------------------------------
--	Engineer items
----------------------------------
--[[ list code:
	"# Item" is "get # of these"
	"Item #" is "get this level of the item" --]]
behaviorLib.StartingItems = 
	{"Item_PretendersCrown", "Item_MinorTotem", "Item_MinorTotem", "Item_MinorTotem", "Item_RunesOfTheBlight", "Item_RunesOfTheBlight", "Item_MinorTotem"}
behaviorLib.LaneItems = 
	{"Item_ManaRegen3", "Item_Marchers", "Item_Striders", "Item_MysticVestments", "Item_Replenish", "Item_Manatube"} --ManaRegen3 is Ring of the Teacher, Item_Strength5 is Fortified Bracer
behaviorLib.MidItems = 
	{"Item_Morph", "Item_MagicArmor2"} 
behaviorLib.LateItems = 
	{"Item_BehemothsHeart"} 



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

BotEcho('finished loading engineer_main')
