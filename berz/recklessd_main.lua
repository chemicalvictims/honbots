--------------------------------------------------------------------- -- -- 
--------------------------------------------------------------------- -- -- 
--  ____                      __       ___                              
-- /\  _`\                   /\ \     /\_ \                             
-- \ \ \L\ \      __     ___ \ \ \/'\ \//\ \       __     ____    ____  
--  \ \ ,  /    /'__`\  /'___\\ \ , <   \ \ \    /'__`\  /',__\  /',__\ 
--   \ \ \\ \  /\  __/ /\ \__/ \ \ \\`\  \_\ \_ /\  __/ /\__, `\/\__, `\
--    \ \_\ \_\\ \____\\ \____\ \ \_\ \_\/\____\\ \____\\/\____/\/\____/
--     \/_/\/ / \/____/ \/____/  \/_/\/_/\/____/ \/____/ \/___/  \/___/                                                                                                                                           
--  ____                                     __                    
-- /\  _`\    __                            /\ \__                 
-- \ \ \/\ \ /\_\     ____     __       ____\ \ ,_\     __   _ __  
--  \ \ \ \ \\/\ \   /',__\  /'__`\    /',__\\ \ \/   /'__`\/\`'__\
--   \ \ \_\ \\ \ \ /\__, `\/\ \L\.\_ /\__, `\\ \ \_ /\  __/\ \ \/ 
--    \ \____/ \ \_\\/\____/\ \__/.\_\\/\____/ \ \__\\ \____\\ \_\ 
--     \/___/   \/_/ \/___/  \/__/\/_/ \/___/   \/__/ \/____/ \/_/ 
--                                                                 
--                                                                 
--------------------------------------------------------------------- -- -- 
--------------------------------------------------------------------- -- -- 
-- Reckless Disaster v0.0000001

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

BotEcho(object:GetName()..' loading recklessd_main...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  Bot Constant Definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- Hero_<hero>  to reference the internal HoN name of a hero, Hero_Yogi ==Wildsoul
object.heroName = 'Hero_Berzerker'


--   Item Buy order. Internal names  
behaviorLib.StartingItems  = { "Item_RunesOfTheBlight", "Item_IronBuckler", "Item_LoggersHatchet"}
behaviorLib.LaneItems  = {"Item_MysticVestments","Item_EnhancedMarchers","Item_ElderParasite"}
behaviorLib.MidItems  = {"Item_Insanitarius","Item_Brutalizer"}
behaviorLib.LateItems  = {"Item_BehemothsHeart","Item_Critical1"}


-- Skillbuild table, 0=Q, 1=W, 2=E, 3=R, 4=Attri
object.tSkills = {
    0, 1, 0, 2, 0,
    3, 0, 1, 1, 1, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use

object.nChainUp = 25
object.nSapUp = 10 
object.nMarkUp = 25
object.nCarnageUp = 35

-- bonus agression points that are applied to the bot upon successfully using a skill/item

object.nChainUse = 35
object.nSapUse = 10 
object.nMarkUse = 40
object.nCarnageUse = 55

--thresholds of aggression the bot must reach to use these abilities

object.nChainThreshold = 25
object.nSapThreshold = 60 
object.nMarkThreshold = 70 
object.nCarnageThreshold = 50
object.nElderParasiteThreshold = 70
object.nInsanitariusThreshold = 70
object.nInsanitariusOffThreshold = 10
object.nEnhancedMarchersThreshold = 70

behaviorLib.nCreepPushbackMul = 0.5
behaviorLib.nTargetPositioningMul = 0.6

--####################################################################
--####################################################################
--#                                                                 ##
--#   Bot Function Overrides                                        ##
--#                                                                 ##
--####################################################################
--####################################################################

------------------------------
--     Skills               --
------------------------------
-- @param: none
-- @return: none
function object:SkillBuild()
    core.VerboseLog("SkillBuild()")

-- takes care at load/reload, <NAME_#> to be replaced by some convinient name.
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
    
   
    local nLev = unitSelf:GetLevel()
    local nLevPts = unitSelf:GetAbilityPointsAvailable()
    for i = nLev, nLev+nLevPts do
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
		if EventData.InflictorName == "Ability_Berzerker1" then
		    nAddBonus = nAddBonus + object.nChainUse
		elseif EventData.InflictorName == "Ability_Berzerker2" then
		    nAddBonus = nAddBonus + object.nSapUse
		elseif EventData.InflictorName == "Ability_Berzerker3" then
		    nAddBonus = nAddBonus + object.nMarkUse
		elseif EventData.InflictorName == "Ability_Berzerker4" then
		    nAddBonus = nAddBonus + object.nCarnageUse
		end
	end
 
	if nAddBonus > 0 then
		core.DecayBonus(self)
		core.nHarassBonus = core.nHarassBonus + nAddBonus
	end
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent     = object.oncombateventOverride




------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function CustomHarassUtilityFnOverride(hero)
    local nUtil = 0
     
    if skills.abilQ:CanActivate() then
        nUnil = nUtil + object.nChainUp
    end
 
    if skills.abilW:CanActivate() then
        nUtil = nUtil + object.nSapUp
    end
    
    if skills.abilE:CanActivate() then
        nUtil = nUtil + object.nMarkUp
    end

    if skills.abilR:CanActivate() then
        nUtil = nUtil + object.nCarnageUp
    end
       
    if object.itemElderParasite and object.itemElderParasite:CanActivate() then
        nUtil = nUtil + object.nElderParasiteUp
    end

    if object.itemInsanitarius and object.itemInsanitarius:CanActivate() then
        nUtil = nUtil + object.nInsanitariusUp
    end

    if object.itemEnhancedMarchers and object.itemEnhancedMarchers:CanActivate() then
        nUtil = nUtil + object.nEnhancedMarchersUp
    end
 
    return nUtil
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   


----------------------------------
--  FindItems Override
----------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.EnhancedMarchers ~= nil and not core.itemEnhancedMarchers:IsValid() then
		core.EnhancedMarchers = nil
	end
	if core.Insanitarius ~= nil and not core.itemInsanitarius:IsValid() then
		core.Insanitarius = nil
	end
	if core.ElderParasite ~= nil and not core.itemElderParasite:IsValid() then
		core.ElderParasite = nil
	end
	
	if bUpdated then
		--only update if we need to
		if core.itemEnhancedMarchers and core.itemInsanitarius and core.itemElderParasite then
			return
		end
		
		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemEnhancedMarchers == nil and curItem:GetName() == "Item_EnhancedMarchers" then
					core.itemEnhancedMarchers = core.WrapInTable(curItem)
				elseif core.itemInsanitarius == nil and curItem:GetName() == "Item_Insanitarius" then
					core.itemInsanitarius = core.WrapInTable(curItem)
				elseif core.itemElderParasite == nil and curItem:GetName() == "Item_ElderParasite" then
					core.itemElderParasite = core.WrapInTable(curItem)
				end
			end
		end
	end
end

object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride



--------------------------------------------------------------
--                    Harass Behavior                       --
-- All code how to use abilities against enemies goes here  --
--------------------------------------------------------------
-- @param botBrain: CBotBrain
-- @return: none
--
local function HarassHeroExecuteOverride(botBrain)
    local bDebugEchos = true
	
    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain)  --Target is invalid, move on to the next behavior
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
    
    
    --- Insert abilities code here, set bActionTaken to true 
    --- if an ability command has been given successfully
    
     -- Chain Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
        local abilChain = skills.abilQ
        if not bActionTaken then
            if abilChain:CanActivate() and nLastHarassUtility > botBrain.nChainThreshold and not unitSelf:HasState("State_Berzerker_Ability1_Self") then
                local nRange = abilChain:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then 
                    bActionTaken = core.OrderAbilityEntity(botBrain, abilChain, unitTarget)
                end
            end
        end 
    end 

     -- Chain Desactivation
     
    if core.CanSeeUnit(botBrain, unitTarget) then
	    if not bActionTaken and unitSelf:HasState("State_Berzerker_Ability1_Self") and abilChain:CanActivate() and (nTargetDistanceSq <= ( 290 * 290 ) or nTargetDistanceSq >= ( 780 * 780 ) ) then
			local abilChain = skills.abilQ
			bActionTaken = core.OrderAbility(botBrain, abilChain)
	    end    end
     -- Chain for Damage
     
     -- Sap Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
        local abilSap = skills.abilW
        if not bActionTaken then --and bTargetVuln then
            if abilSap:CanActivate() and nLastHarassUtility > botBrain.nSapThreshold then
                if nTargetDistanceSq < (500 * 500) then --- distance?
					bActionTaken = core.OrderAbility(botBrain, abilSap)
                end
            end
        end 
    end
     
     -- Mark Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
        local abilMark = skills.abilE
        if not bActionTaken then --and bTargetVuln then
            if abilMark:CanActivate() and nLastHarassUtility > botBrain.nMarkThreshold then
                local nRange = abilMark:GetRange()
                if nTargetDistanceSq < (nRange * nRange) then --- distance?
                    bActionTaken = core.OrderAbilityEntity(botBrain, abilMark, unitTarget)
                end
            end
        end 
    end 

     -- Carnage Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
        local abilCarnage = skills.abilR
        if not bActionTaken then --and bTargetVuln then
            if abilCarnage:CanActivate() and nLastHarassUtility > botBrain.nCarnageThreshold then
                if nTargetDistanceSq < (650 * 650) then --- distance?
					bActionTaken = core.OrderAbility(botBrain, abilCarnage)
                end
            end
        end 
    end

     -- ElderParasite Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
    	core.FindItems()
	local itemElderParasite = core.itemElderParasite -- reel name?
        if not bActionTaken then --and bTargetVuln then
            if itemElderParasite:CanActivate() and nLastHarassUtility > botBrain.nElderParasiteThreshold then
                if nTargetDistanceSq < (540 * 540) then --- distance?
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemElderParasite)
                end
            end
        end 
    end

     -- Insanitarius Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
    	core.FindItems()
	local itemInsanitarius = core.itemInsanitarius -- reel name?
        if not bActionTaken then --and bTargetVuln then
            if itemInsanitarius:CanActivate() and nLastHarassUtility > botBrain.nInsanitariusThreshold and not unitSelf:HasState("State_Insanitarius") then
                if nTargetDistanceSq < (300 * 300) then --- distance?
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemInsanitarius)
                end
            end
        end 
    end
    
    -- Insanitarius Desactivation

        if not bActionTaken and unitSelf:HasState("State_Insanitarius") and itemInsanitarius:CanActivate() then --and bTargetVuln then
    	core.FindItems()
            local itemInsanitarius = core.itemInsanitarius -- reel name?
            if itemInsanitarius:CanActivate() and (nLastHarassUtility < botBrain.nInsanitariusOffThreshold or unitSelf:GetHealthPercent() < 15) then
				bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemInsanitarius)
            end
        end 
            
     -- Ghost Marchers Offensive Activation
    if core.CanSeeUnit(botBrain, unitTarget) then
    	core.FindItems()
	local itemMarchers = core.itemEnhancedMarchers -- reel name?
        if not bActionTaken then 
            if itemMarchers:CanActivate() and nLastHarassUtility > botBrain.nMarchersThreshold then
                if nTargetDistanceSq < (750 * 750) then --- distance?
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemMarchers)
                end
            end
        end 
    end
    
    if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end 
end

-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

--Kairus101's last hitter
function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep) 
--called pretty much constantly 
   unitSelf=core.unitSelf
    local bDebugEchos = false
    -- predictive last hitting, don't just wait and react when they have 1 hit left (that would be stupid. T_T)
 
 
    local unitSelf = core.unitSelf
    local nDamageAverage = unitSelf:GetFinalAttackDamageMin()+40 --make the hero go to the unit when it is 40 hp away
    core.FindItems(botBrain)
    if core.itemHatchet then
        nDamageAverage = nDamageAverage * core.itemHatchet.creepDamageMul
    end   
    -- [Difficulty: Easy] Make bots worse at last hitting
    if core.nDifficulty == core.nEASY_DIFFICULTY then
        nDamageAverage = nDamageAverage + 120
    end
    if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
        local nTargetHealth = unitEnemyCreep:GetHealth()
        if nDamageAverage >= nTargetHealth then
            local bActuallyLH = true
            if bDebugEchos then BotEcho("Returning an enemy") end
            return unitEnemyCreep
        end
    end
 
 
    if unitAllyCreep then
        local nTargetHealth = unitAllyCreep:GetHealth()
        if nDamageAverage >= nTargetHealth then
            local bActuallyDeny = true
 
 
            --[Difficulty: Easy] Don't deny
            if core.nDifficulty == core.nEASY_DIFFICULTY then
                bActuallyDeny = false
            end           
 
 
            -- [Tutorial] Hellbourne *will* deny creeps after **** gets real
            if core.bIsTutorial and core.bTutorialBehaviorReset == true and core.myTeam == HoN.GetHellbourneTeam() then
                bActuallyDeny = true
            end
 
 
            if bActuallyDeny then
                if bDebugEchos then BotEcho("Returning an ally") end
                return unitAllyCreep
            end
        end
    end
    return nil
end

function KaiAttackCreepsExecuteOverride(botBrain)
    local unitSelf = core.unitSelf
    local currentTarget = core.unitCreepTarget
 
 
    if currentTarget and core.CanSeeUnit(botBrain, currentTarget) then       
        local vecTargetPos = currentTarget:GetPosition()
        local nDistSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecTargetPos)
        local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)
         
        local nDamageAverage = unitSelf:GetFinalAttackDamageMin()
 
 
        if currentTarget ~= nil then
            if nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() and nDamageAverage>=currentTarget:GetHealth() then --only kill if you can get gold
                --only attack when in nRange, so not to aggro towers/creeps until necessary, and move forward when attack is on cd
                core.OrderAttackClamp(botBrain, unitSelf, currentTarget)
            elseif (nDistSq > nAttackRangeSq) then
                local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
                core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false) --moves hero to target
            else
                core.OrderHoldClamp(botBrain, unitSelf, false) --this is where the magic happens. Wait for the kill.
            end
        end
    else
        return false
    end
end
object.AttackCreepsExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = KaiAttackCreepsExecuteOverride


