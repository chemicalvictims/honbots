----------------------------------------------------------------------
----------------------------------------------------------------------
-- 	 ____	 _		 _____   _____   _____     ____    ________  -----
--	|    \	| |		/	  \ /     \ |	  \   /	   \  |  _  _  | -----
--  | Ѻ _|	| |___  |  Ѻ  | |  Ѻ  | |  ѻ__/	 |   _  | |__    __| -----
--	|   \	|  _  \ |  _  | |  ___/ 3      \ |  (Ѻ) |    |  |    -----
--  | |\ \	| |	| | | | | | | | 	|  Ѻ   | |	 ¯ 	|    |  |	 -----
--  |_| \_\ |_| |_| |_| |_| |_,     |______,  \____,     |__|	 -----
--																 -----
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Rhapbot v0.9
-- Based on Scorcher, Demented Shaman, Glacius and so on.
-- I think i stole stuff from most of the s2 bots to make this
-- Flint, Ra, Hammer... and so on
-- Also i have a new respect for ASCII artists (a damn pain do the header here)
-- Special thanks to: Zerotorescue, spennerino, fahna, etc , etc
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

runfile "bots/Libraries/LibWarding/LibWarding.lua"
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
behaviorLib.StartingItems  = {"Item_MinorTotem", "Item_HealthPotion", "Item_RunesOfTheBlight", "Item_PretendersCrown"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_Striders", "Item_Astrolabe"}
behaviorLib.MidItems  = {"Item_Immunity" }
behaviorLib.LateItems  = {"Item_BehemothsHeart", "Item_Damage9"}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 1, 0, 1, 0, 
	3, 0, 1, 1, 2, 
	2, 2, 2, 3, 4, 
	3, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 
}

-- These are bonus agression points if a skill/item is available for use
object.nabilQUp = 59
object.nabilWUp = 69
object.nabilEUp = 5



-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nabilQUse = 15
object.nabilWUse = 15



--These are thresholds of aggression the bot must reach to use these abilities
object.nabilQThreshold = 20
object.nabilWThreshold = 40
object.MoMThreshold = 70 --i don't want my bot to get extra aggresive if she has this item, just use it
						 --if situation is aggresive enough
object.nTime = 0		--used for staccato timings
object.nWardTime = 0	--remembers moment of game when bot has warded
object.bWarded = false

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
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

    -- nothing to see here
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride

----------------------------------------------
--            oncombatevent override        --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
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

------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
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
--  														--
--------------------------------------------------------------
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
   
	local abilStun = skills.abilQ
	local abilDance = skills.abilW
	
	--BotEcho (nLastHarassUtility..' lastharassutil')
	----------------------------------------------------- Staccato / Stun
	if core.CanSeeUnit(botBrain, unitTarget) then
		if not bActionTaken then --and bTargetVuln then
            if abilStun:CanActivate() and nLastHarassUtility > botBrain.nabilQThreshold and not unitSelf:HasState("State_Rhapsody_Ability1_Self") then
                local nRange = abilStun:GetRange()												-- state_rhapsody_ability1_self means that rhapsody has staccato charges
                if nTargetDistanceSq < (nRange * nRange) then
                    bActionTaken = core.OrderAbilityEntity(botBrain, abilStun, unitTarget)
					object.nTime = HoN.GetGameTime()			--the moment in the game that rhapsody used the orginal stun (used for staccato stagger)
                else
                    bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					
                end
            end
        end 
    end 
	----------------------------------------------------- Dance dance 
	if not bActionTaken then
		if abilDance:CanActivate() then and unitTarget:GetHealthPercent() > 0.1 then
			if nLastHarassUtility > botBrain.nabilWThreshold or bTargetVuln then
                local nRange = abilDance:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then
                    bActionTaken = core.OrderAbilityPosition(botBrain, abilDance, vecTargetPosition)
					bDanceSuccess = true
				end
			end
		end
	end
	----------------------------------------------------- Staccato charges stagger
	local nStaccatoChargeThreshold = 250 --the stagger interval in ms
    if not bActionTaken then
		if unitSelf:HasState("State_Rhapsody_Ability1_Self") and not bTargetVuln then 
			local nCurTime = HoN.GetGameTime()
			if nCurTime - object.nTime >= nStaccatoChargeThreshold then --if current time 250ms after last stun, do another stun!
				core.OrderAbility(botBrain, abilStun)
				object.nTime = nCurTime
			end
		end  	  
	end
	----------------------------------------------------- Elder Parasite usage
	if not bActionTaken then
		core.FindItems()
		local itemMoM = core.itemMoM
		if itemMoM and itemMoM:CanActivate() and nLastHarassUtility > botBrain.MoMThreshold then
			core.OrderItem (itemMoM)
		end
	end
	
	if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end 
	
	if unitSelf:IsChanneling() then
    --dooo it, the ultimate is called someplace else, but this is 
	--here in case behaviors change during channel time for some reason
    return
    end
end
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


--------------------------------------------------------------
--                    FindItems Override                    --
--  														--
--------------------------------------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemAstrolabe ~= nil and not core.itemAstrolabe:IsValid() then
		core.itemAstrolabe = nil
	end
	if core.itemWardOfSight ~= nil and not core.itemWardOfSight:IsValid() then
		core.itemWardOfSight = nil
	end
	if core.itemBkB ~= nil and not core.itemBkB:IsValid() then
		core.itemBkB = nil
	end
	if core.itemMoM ~= nil and not core.itemMoM:IsValid() then
		core.itemMoM = nil
	end
	
	if bUpdated then
		if core.itemWardOfSight and core.itemAstrolabe and core.itemMoM and core.itemBkB then
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
				elseif core.itemWardOfSight == nil and curItem:GetName() == "Item_FlamingEye" then
					core.itemWardOfSight = core.WrapInTable(curItem)
					core.itemWardOfSight.nRadius = 600
				elseif core.itemBkB == nil and curItem:GetName() == "Item_Immunity" then
					core.itemBkB = core.WrapInTable(curItem)
				elseif core.itemMoM == nil and curItem:GetName() == "Item_ElderParasite" then
					core.itemMoM = core.WrapInTable(curItem)
					
				end
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

--------------------------------------------------------------
--                RetreatFromThreat Override     	        --
--  		     --Use staccato defensively--				--
--------------------------------------------------------------
object.nRetreatStunThreshold = 43

--Unfortunately this utility is kind of volatile, so we basically have to deal with util spikes
function funcRetreatFromThreatExecuteOverride(botBrain)
	local bDebugEchos = false
	local bActionTaken = false
	local nStaccatoChargeThreshold = 500 --ms
	local unitSelf = core.unitSelf
	local abilStun = skills.abilQ

	--BotEcho("Checkin defensive Stun")
	if not bActionTaken then
		--Stun use
		
		if abilStun:CanActivate() and not unitSelf:HasState("State_Rhapsody_Ability1_Self") then
			--BotEcho("CanActivate!  nRetreatUtil: "..behaviorLib.lastRetreatUtil.."  thresh: "..object.nRetreatStunThreshold)
			if behaviorLib.lastRetreatUtil >= object.nRetreatStunThreshold then
				local tTargets = core.CopyTable(core.localUnits["EnemyHeroes"])
				if tTargets then
					local vecMyPosition = unitSelf:GetPosition() 
					local nRange = abilStun:GetRange()					
					for key, hero in pairs(tTargets) do
						local heroPos = hero:GetPosition()
						local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, heroPos)
						if nTargetDistanceSq < (nRange * nRange) and abilStun:CanActivate() then
							core.OrderAbilityEntity(botBrain, abilStun, hero) -- will only attempt to stun if he is in range, no turning back!
							object.nTime = HoN.GetGameTime()
						end

					end
				end	
			end
		end
	end
	--Staccato charges stagger
	if not bActionTaken then
		if unitSelf:HasState("State_Rhapsody_Ability1_Self") and not bTargetVuln then 
			local nCurTime = HoN.GetGameTime()
			if nCurTime - object.nTime >= nStaccatoChargeThreshold then --if current time X ms after last stun, do another stun!
				core.OrderAbility(botBrain, abilStun)
				object.nTime = nCurTime
			end
		end  	  
	end
	

	if not bActionTaken then
		return object.RetreatFromThreatExecuteOld(botBrain)
	end
end
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatExecute
behaviorLib.RetreatFromThreatBehavior["Execute"] = funcRetreatFromThreatExecuteOverride


--------------------------------------------------------------
--              	  PushExecute Override     		        --
--    needed to make rhapbot use dance inferno on pushes	--
--------------------------------------------------------------
------------ Function for finding the center of a group (used by ult and some other places). Kudos to Stolen_id for this
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

function AbilityPush(botBrain)
	local bSuccess = false
	local abilDance = skills.abilW
	local unitSelf = core.unitSelf
	local vCreepCenter = groupCenter(core.localUnits["EnemyCreeps"], 3) -- the 3 basicly wont allow abilities under 3 creeps
	if abilDance:CanActivate() and vCreepCenter and unitSelf:GetManaPercent() > 0.30 then 
	
		core.OrderAbilityPosition(botBrain, abilDance, vCreepCenter)
		bSuccess = true
	end
	return bSuccess
end

local function PushExecuteOverride(botBrain)
	if not AbilityPush(botBrain) then 
		object.PushExecuteOld(botBrain)
	end

end
object.PushExecuteOld = behaviorLib.PushBehavior["Execute"]
behaviorLib.PushBehavior["Execute"] = PushExecuteOverride


local function TeamGroupBehaviorOverride(botBrain)
	AbilityPush(botBrain)
	object.TeamGroupBehaviorOld(botBrain)
	
end
object.TeamGroupBehaviorOld = behaviorLib.TeamGroupBehavior["Execute"]
behaviorLib.TeamGroupBehavior["Execute"] = TeamGroupBehaviorOverride


--####################################################################
--####################################################################
--#                                                                 ##
--#   bot added behaviors                                           ##
--#                                                                 ##
--####################################################################
--####################################################################
------------------------------------------------------------
--	Rhapsody Help behavior
--	
--	Execute: Use Astrolabe / Protective Melody
--  The following few functions are a necesary 
--  copy pasta from GlaciusBot(with adaptaions for rhapsody's skills, ofc)
------------------------------------------------------------
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

function behaviorLib.HealExecute(botBrain) -- this is used for Astrolabe ASWELL as Ultimate triggering
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
-- todo: modify according to ult level? 
-- trial and error convinced me not to do so
	return 4
end
	

function object.GetProtectiveMelodyRadius()
	return 600
end


-------------------------------------Ultimate Execution 
-------------------------------------Rhapsody's ult can be activated for just 1 teammate
-------------------------------------but she will attemt to move to center of group before popping
-------------------------------------Also pops Shrunken, if available
function ProtectiveMelodyExecute(botBrain)
	local unitSelf = core.unitSelf
	local tTargets = core.CopyTable(core.localUnits["AllyHeroes"])
	for key, hero in pairs(tTargets) do
		if hero:GetUniqueID() ~= unitSelf:GetUniqueID() then
			local vAlliesCenter = groupCenter(tTargets, 1)
			
			
			local vecMyPosition = unitSelf:GetPosition()
			local nTimeToLive = behaviorLib.TimeToLiveUtilityFn(hero)
			local abilUlt = skills.abilR
		
			local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vAlliesCenter)
	 
			
			local nRadius = object.GetProtectiveMelodyRadius()
			local nHalfRadiusSq = nRadius * nRadius * 0.25
			if nTargetDistanceSq <= nHalfRadiusSq then
				core.FindItems()
				local itemBkB = core.itemBkB
				if itemBkB and itemBkB:CanActivate() then		--see if Shrunken can pop, then pop it
					core.OrderItem(itemBkB)
				end
				core.OrderAbility(botBrain, abilUlt)		
			else 
				core.OrderMoveToUnit(botBrain, unitSelf, vAlliesCenter)
			end
			
	
	
		end
	end
end


--####################################################################
--####################################################################
--#                                                                 ##
--#   		 CHAT FUNCTIONSS                                        ##
--#                                                                 ##
--####################################################################
--####################################################################


object.killMessages = {}
object.killMessages.GeneralX = {
	"Theeeere's a laaaady who's sure... all that glitters is GOLD","Whanna whole lotta love!","OH! The song remains the saaame",
	"Close the doors, put out the light, You know you won't be home tonight...", "Babe, baby, baby, I'm Gonna Leave You. " ,
	"It's just a spring clean for the May queen", "Oh war is the common cry, Pick up your swords and fly."
	}
object.respawnMessagesX = {
	"I'm having a nervous breakdown, Drive me insane!",
	"I've been dazed and confused...",
	"Gonna love you baby, here I come again!! ",
	"Will your tongue wag so much when I send you the bill? ",
	"They hold no quarter."
	}
-- i love Led Zeppelin
--
--
local function ProcessKillChatOverride(unitTarget, sTargetPlayerName)
    local nCurrentTime = HoN.GetGameTime()
    if nCurrentTime < core.nNextChatEventTime then
        return
    end   
     
    local nToSpamOrNotToSpam = random()
         
    if(nToSpamOrNotToSpam < core.nKillChatChance) then
        local nDelay = random(core.nChatDelayMin, core.nChatDelayMax) 
        local tHeroMessages = object.killMessages[unitTarget:GetTypeName()]
	
	local sTargetName = sTargetPlayerName or unitTarget:GetDisplayName()
        if tHeroMessages ~= nil and random() <= 0.7 then
            local nMessage = random(#tHeroMessages)
            core.AllChat(format(tHeroMessages[nMessage], sTargetPlayerName), nDelay)
        else
            local nMessage = random(#object.killMessages.GeneralX) 
            core.AllChat(format(object.killMessages.GeneralX[nMessage], sTargetPlayerName), nDelay)
        end
    end
     
    core.nNextChatEventTime = nCurrentTime + core.nChatEventInterval
end
core.ProcessKillChat = ProcessKillChatOverride 

local function ProcessRespawnChatOverride()
	local nCurrentTime = HoN.GetGameTime()	
	if nCurrentTime < core.nNextChatEventTime then
		return
	end	
	
	if HoN.GetMatchTime() > 0 then
		local nDelay = random(core.nChatDelayMin, core.nChatDelayMax) 
		local sMessage = nil
		
		local nToSpamOrNotToSpam = random()
		if(nToSpamOrNotToSpam < core.nRespawnChatChance) then
			local nMessage = random(#object.respawnMessagesX) 
			sMessage = object.respawnMessagesX[nMessage]
		end
		
		
		if sMessage then
			core.AllChatLocalizedMessage(sMessage, nil, nDelay)
		end
	else 
		core.AllChat("Rock On!")
	end
	
	core.nNextChatEventTime = nCurrentTime + core.nChatEventInterval
end
core.ProcessRespawnChat = ProcessRespawnChatOverride

local function ProcessDeathChatOverride () 
--just to shut her up when she dies :>
end
core.ProcessDeathChat = ProcessDeathChatOverride


BotEcho ('success')