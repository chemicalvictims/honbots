-------------------------------------------------------------------
-------------------------------------------------------------------
-- 	 ____	 _		 _____   _____   _____     ____    ________  --
--	|    \	| |		/	  \ /     \ |	  \   /	   \  |  _  _  | --
--  | Ѻ _|	| |___  |  Ѻ  | |  Ѻ  | |  ѻ__/	 |   _  | |__    __| --
--	|   \	|  _  \ |  _  | |  ___/ 3      \ |  (Ѻ) |    |  |    --
--  | |\ \	| |	| | | | | | | | 	|  Ѻ   | |	 ¯ 	|    |  |	 --
--  |_| \_\ |_| |_| |_| |_| |_,     |______,  \____,     |__|	 --
--																 --
-------------------------------------------------------------------
------------------------------------------------------------------- 
-- Rhapbot v0.3
-- Based on Skelbot and Scorcher
-- I need help with this
--

--####################################################################
--####################################################################
--#                                                                 ##
--#                       Bot Initiation                            ##
--#                                                                 ##
--####################################################################
--####################################################################


local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic         = true
object.bRunBehaviors    = true
object.bUpdates         = true
object.bUseShop         = true

object.bRunCommands     = true 
object.bMoveCommands     = true
object.bAttackCommands     = true
object.bAbilityCommands = true
object.bOtherCommands     = true

object.bReportBehavior = false
object.bDebugUtility = false

object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core         = {}
object.eventsLib     = {}
object.metadata     = {}
object.behaviorLib     = {}
object.skills         = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventslib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorlib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho(object:GetName()..' loading rhapsody_main...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, hero_yogi ==wildsoul
object.heroName = 'Hero_Rhapsody'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_MinorTotem", "Item_MinorTotem", "Item_ManaPotion", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_Striders", "Item_Astrolabe"}
behaviorLib.MidItems  = {"Item_HarkonsBlade", "Item_Immunity"}
behaviorLib.LateItems  = {"Item_ElderParasite", "Item_BehemothsHeart", "Item_Damage9"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 1, 0, 1, 0, 
	3, 0, 1, 1, 2, 
	2, 2, 2, 3, 4, 
	3, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 
}

-- These are bonus agression points if a skill/item is available for use
object.nabilQUp = 39
object.nabilWUp = 49
object.nabilEUp = 1


-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nabilQUse = 15
object.nabilWUse = 15



--These are thresholds of aggression the bot must reach to use these abilities
object.nabilQThreshold = 20
object.nabilWThreshold = 40





--####################################################################
--####################################################################
--#                                                                 ##
--#   bot function overrides                                        ##
--#                                                                 ##
--####################################################################
--####################################################################

------------------------------
--     skills               --
------------------------------
-- @param: none
-- @return: none
function object:SkillBuild()
    core.VerboseLog("skillbuild()")

-- takes care at load/reload, <name_#> to be replaced by some convinient name.
    local unitSelf = self.core.unitSelf
    if  skills.abilQ == nil then
        skills.abilQ = unitSelf:GetAbility(0)
        skills.abilW = unitSelf:GetAbility(1)
        skills.abilE = unitSelf:GetAbility(2)
        skills.abilR = unitSelf:GetAbility(3)
        skills.abilAttributeBoost = unitSelf:GetAbility(4)
    end
    if unitSelf:GetAbilityPointsAvailable() <= 0 then
        return
    end
    
   
    local nlev = unitSelf:GetLevel()
    local nlevpts = unitSelf:GetAbilityPointsAvailable()
    for i = nlev, nlev+nlevpts do
        unitSelf:GetAbility( object.tSkills[i] ):LevelUp()
    end
end

------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

    -- custom code here
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride




----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
function object:oncombateventOverride(EventData)

self:oncombateventOld(EventData)
 
    local nAddBonus = 0
 
    if EventData.Type == "Ability" then
        if EventData.InflictorName == "Ability_Rhapsody1" then
            nAddBonus = nAddBonus + object.nabilQUse
        elseif EventData.InflictorName == "Ability_Rhapsody2" then
            nAddBonus = nAddBonus + object.nabilWUse
        end
    end
 
   if nAddBonus > 0 then
        core.DecayBonus(self)
        core.nHarassBonus = core.nHarassBonus + nAddBonus
    end
--BotEcho(nAddBonus..' naddbonus')
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent     = object.oncombateventOverride

--[[function HealAtWellExecuteOverride(botBrain)
	
	--to do: attempt to use staccato during 'b phase'
	--only if an enemy hero is in range, no getting close to him
	
	
	
end	
behaviorLib.HealAtWellExecute = HealAtWellExecuteOverride--]]
------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function CustomHarassUtilityFnOverride(hero)
   local nUtil = 0
     
    if skills.abilQ:CanActivate() then
        nUnil = nUtil + object.nabilQUp
    end
 
    if skills.abilW:CanActivate() then
        nUtil = nUtil + object.nabilWUp
    end
 --BotEcho(nUtil..' nutil')
    return nUtil
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtilityFn = CustomHarassUtilityFnOverride   

--------------------------------------------------------------
--                    Harass Behavior                       --
-- All code how to use abilities against enemies goes here  --
--------------------------------------------------------------
-- @param botBrain: CBotBrain
-- @return: none
--

local function HarassHeroExecuteOverride(botBrain)
    
    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
    end
       
    local unitSelf = core.unitSelf
    local vecMyPosition = unitSelf:GetPosition() 
    local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
    local nMyExtraRange = core.GetExtraRange(unitSelf)
    
    local vecTargetPosition = unitTarget:GetPosition()
    local nTargetExtraRange = core.GetExtraRange(unitTarget)
    local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
    
    local nLastHarassUtility = behaviorLib.lastHarassUtil
    local bCanSee = core.CanSeeUnit(botBrain, unitTarget)    
    local bActionTaken = false
    local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized()
	local bDanceSuccess = false
    
    --- Insert abilities code here, set bActionTaken to true 
	local abilStun = skills.abilQ
	local abilDance = skills.abilW
	
	BotEcho (nLastHarassUtility..' lastharassutil')
	----------------------------------------------------- Staccato / Stun
	if core.CanSeeUnit(botBrain, unitTarget) then
		if not bActionTaken then --and bTargetVuln then
            if abilStun:CanActivate() and nLastHarassUtility > botBrain.nabilQThreshold and not unitSelf:HasState("State_Rhapsody_Ability1_Self") then
                local nRange = abilStun:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then
                    bActionTaken = core.OrderAbilityEntity(botBrain, abilStun, unitTarget)
                else
                    bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					
                end
            end
        end 
    end 
	----------------------------------------------------- Dance dance 
	if not bActionTaken then
		if abilDance:CanActivate() then
			if nLastHarassUtility > botBrain.nabilWThreshold or bTargetVuln then
                local nRange = abilDance:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then
                    bActionTaken = core.OrderAbilityPosition(botBrain, abilDance, vecTargetPosition)
					bDanceSuccess = true
				end
			end
		end
	end
	
    if not bActionTaken then
		if unitSelf:HasState("State_Rhapsody_Ability1_Self") then 				
								repeat
								core.OrderAbility(botBrain, abilStun)
								BotEcho('did it master')
								TIME_Sleep(1000)
								until not unitSelf:HasState("State_Rhapsody_Ability1_Self") 
		end  	  
	end
 
	
	if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end 
	
	if unitSelf:IsChanneling() then
    --dooo it
    return
    end
end


-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


-- find items override ------------------------------
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

----------------------------------
--	Rhapsody Help behavior
--	
--	Utility: 
--	Execute: Use Astrolabe / Protective Melody
----------------------------------
behaviorLib.nHealUtilityMul = 0.8
behaviorLib.nHealHealthUtilityMul = 1.0
behaviorLib.nHealTimeToLiveUtilityMul = 0.5

function object.GetProtectiveMelodyRadius()
	return 600
end

function behaviorLib.HealHealthUtilityFn(unitHerox)
	local nUtility = 0
	
	local nYIntercept = 100
	local nXIntercept = 100
	local nOrder = 2

	nUtility = core.ExpDecay(unitHerox:GetHealthPercent() * 100, nYIntercept, nXIntercept, nOrder)
	
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
	local nUltimateTTL = object.GetUltimateTimeToLiveThreshold () 
	local nHighestUtility = 0
	local unitTarget = nil
	local nTargetTimeToLive = nil
	local sAbilName = ""
	local abilMelody = skills.abilR
	
	if (itemAstrolabe and itemAstrolabe:CanActivate()) or abilMelody:CanActivate() then
		local tTargets = core.CopyTable(core.localUnits["AllyHeroes"])
		tTargets[unitSelf:GetUniqueID()] = unitSelf --I am also a target
		for key, hero in pairs(tTargets) do
			--Don't heal yourself if we are going to head back to the well anyway, 
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
			if abilMelody:CanActivate() and nTargetTimeToLive <= nUltimateTTL then
				local nCostBonus = behaviorLib.AbilityCostBonusFn(core.unitSelf, abilMelody)
				nUtility = nHighestUtility + nCostBonus
				sAbilName = "Protective Melody"
			end
			
			if nUtility == 0 and (itemAstrolabe and itemAstrolabe:CanActivate()) then
				nUtility = nHighestUtility				
				sAbilName = "Astrolabe"
			end
			
			if nUtility ~= 0 then
				behaviorLib.unitHealTarget = unitTarget
				behaviorLib.nHealTimeToLive = nTargetTimeToLive
			end
	
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
	local abilMelody = skills.abilR
	local itemAstrolabe = core.itemAstrolabe
	local nUltimateTTL = object.GetUltimateTimeToLiveThreshold () 
	local unitHealTarget = behaviorLib.unitHealTarget
	local nHealTimeToLive = behaviorLib.nHealTimeToLive
	local unitSelf = core.unitSelf
	
	if unitSelf:IsChanneling() then
		--dooo it
		return
	end
	
	
	
	if unitHealTarget then 
		if nHealTimeToLive <= nUltimateTTL and abilMelody:CanActivate() and unitHealTarget ~= unitSelf  then  --only attempt ult for other players (not for self, lol)
			ProtectiveMelodyExecute(botBrain)
		elseif itemAstrolabe and itemAstrolabe:CanActivate() then
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
	else
		return false
	end
	
	return
end


behaviorLib.HealBehavior = {}
behaviorLib.HealBehavior["Utility"] = behaviorLib.HealUtility
behaviorLib.HealBehavior["Execute"] = behaviorLib.HealExecute
behaviorLib.HealBehavior["Name"] = "Heal"
tinsert(behaviorLib.tBehaviors, behaviorLib.HealBehavior)



function object.GetUltimateTimeToLiveThreshold () 
--todo: modify according to ult level
	return 4
end
	

function object.GetProtectiveMelodyRadius()
	return 600
end

---------------------------------------- Function for finding the center of a group (used by ult)
	local function groupCenter(tGroup, nMinCount)
		if nMinCount == nil then nMinCount = 1 end
		 
		if tGroup ~= nil then
			local vGroupCenter = Vector3.Create()
			local nGroupCount = 0
			for id, creep in pairs(tGroup) do
				vGroupCenter = vGroupCenter + creep:GetPosition()
				nGroupCount = nGroupCount + 1
			end
			 
			if nGroupCount < nMinCount then
				return nil
			else
				return vGroupCenter/nGroupCount-- center vector
			end
		else
			return nil   
		end
	end
-------------------------------------Ultimate Execution 
-------------------------------------Rhapsody's ult can be activated for just 1 teammate
-------------------------------------but she will attemt to move to center of group before popping
													
function ProtectiveMelodyExecute(botBrain)
	local tTargets = core.CopyTable(core.localUnits["AllyHeroes"]) --re do
	for key, hero in pairs(tTargets) do
		if hero:GetUniqueID() ~= unitSelf:GetUniqueID() then
			local vAlliesCenter = groupCenter(tTargets, 1)
			--local vecTargetPosition = hero:GetPosition()
			local unitSelf = core.unitSelf
			local vecMyPosition = unitSelf:GetPosition()
			local nTimeToLive = behaviorLib.TimeToLiveUtilityFn(hero)
			local abilUlt = skills.abilR
			--local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
			local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vAlliesCenter)
	 
			
			local nRadius = object.GetProtectiveMelodyRadius()
			local nHalfRadiusSq = nRadius * nRadius * 0.25
			if nTargetDistanceSq <= nHalfRadiusSq then
				core.OrderAbility(botBrain, abilUlt)		
			else 
				core.OrderMoveToUnit(botBrain, unitSelf, vAlliesCenter)
			end
			
	
	
		end
	end
end

	--[[function ProtectiveMelodyExecute2(botBrain)  --from Djulio
		-- Using the groupCenter to fetch the center of the allied heroes, with min 1 ally
		local vAlliesCenter = groupCenter(core.localUnits["AllyHeroes"], 1)
     
		if vAlliesCenter == nil then
			return false
		end
     
        -- Fetching the ability and its range
			BotEcho ('im here!')
			local abilUlt = skills.abilR
			local nUltRange = abilUlt:GetRange()
			local nHalfUltRangeSqt = nUltRange * nUltRange * 0.25
			local nUltLevel = abilUlt:GetLevel()
			-- Defining threshold for ult depending on its level
			local nUltimateTimeToLiveThreshold = 4
			if nUltLevel == 2 then
				nUltimateTimeToLiveThreshold = 5
			elseif nUltLevel == 3 then
				nUltimateTimeToLiveThreshold = 6
			end
 
 
			-- Get the general TimeToLiveUtilityFn bevahior
			local nTimeToLive = behaviorLib.TimeToLiveUtilityFn(hero)
			-- Distance between bot and the center of the group
			local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vAlliesCenter)
			
				BotEcho ('checking ultttttttttttttttttttttttttttttttttttttt')
				if nTimeToLive <= nUltimateTimeToLiveThreshold and abilUlt:CanActivate() then
					if nTargetDistanceSq <= nHalfRadiusSq then
						core.OrderAbility(botBrain, abilUlt)
					else
						core.OrderMoveToUnit(botBrain, unitSelf, vAlliesCenter)
					end
				end 
	end
--]]
local nRadiuss = object.GetProtectiveMelodyRadius()
BotEcho ('success'..nRadiuss )



