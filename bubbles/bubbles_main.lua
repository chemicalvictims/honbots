-- BubBot by Eserem.

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

runfile "bots/bubbles/circulararray.lua"


local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho(object:GetName()..' loading bubbles_main...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, Hero_Yogi ==wildsoul
object.heroName = 'Hero_Bubbles'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_GuardianRing", "Item_RunesOfTheBlight", "Item_HealthPotion", "Item_ManaPotion", "2 Item_MinorTotem", }
behaviorLib.LaneItems  = {"Item_ManaRegen3", "Item_ManaBattery", "Item_Marchers", "Item_PowerSupply", "Item_GraveLocket", "Item_Steamboots"}
behaviorLib.MidItems  = {"Item_PortalKey", "Item_Silence"} --Silence == Hellflower
behaviorLib.LateItems  = {"Item_Weapon3", "Item_WhisperingHelm", "Item_Critical4", "Item_Lifesteal4"} --Weapon3 == Savage Mace, Critical4 == Riftshards 4, Lifesteal4 == Symbol of Rage


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 2, 0, 1, 0,
    3, 0, 1, 1, 1, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use
object.nShellSurfUp = 12
object.nSongOfTheSeaUp = 12
object.nTakeCoverUp = 2
object.nKelpFieldUp = 18
object.nPortalKeyUp = 12
object.nHellflowerUp = 16

-- bonus agression points that are applied to the bot upon successfully using a skill/item
object.nShellSurfUse = 18
object.nSongOfTheSeaUse = 18
object.nKelpFieldUse = 24
object.nHellflowerUse = 28

--thresholds of aggression the bot must reach to use these abilities
object.nShellSurfThreshold = 12
object.nSongOfTheSeaThreshold = 20
object.nKelpFieldThreshold = 45
object.nHellflowerThreshold = 30



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
    local nAddBonus = 0
 
 --Self spells
    if EventData.Type == "Ability" then
        if EventData.InflictorName == "Ability_Bubbles1" then
            nAddBonus = nAddBonus + object.nShellSurfUse
        elseif EventData.InflictorName == "Ability_Bubbles2" then
            nAddBonus = nAddBonus + object.nSongOfTheSeaUse
        elseif EventData.InflictorName == "Ability_Bubbles3" then
            nAddBonus = nAddBonus + object.nTakeCoverUse
        elseif EventData.InflictorName == "Ability_Bubbles4" then
            nAddBonus = nAddBonus + object.nKelpFieldUse
        end
        --Self items
    elseif EventData.Type == "Item" then
        if core.itemHellflower ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemHellflower:GetName() then
            nAddBonus = nAddBonus + self.nHellflowerUse
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
        nUtil = nUtil + object.nShellSurfUp
    end
 
    if skills.abilW:CanActivate() then
        nUtil = nUtil + object.nSongOfTheSeaUp
    end
    
    if skills.abilE:CanActivate() then
        nUtil = nUtil + object.nTakeCoverUp
    end
 
    if skills.abilR:CanActivate() then
        nUtil = nUtil + object.nKelpFieldUp
    end
 
    if object.itemHellflower and object.itemHellflower:CanActivate() then
        nUtil = nUtil + object.nHellflowerUp
    end
 
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
    
    
    --- Insert abilities code here, set bActionTaken to true 
    --- if an ability command has been given successfully
    
    --Shell Surf
--    if not bActionTaken then
--    	local abilShellSurf = skills.abilQ
--    	if abilShellSurf:CanActivate() and nLastHarassUtility > botBrain.nShellSurfThreshold then --Fortsätt med om inte magic immune
--    		local nRange = abilShellSurf:GetRange() --e.er.earöea. 850 speed shell btw.
--    	end  		
    
    if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

-----------------------------------------------------------------------------------------------------
--Eserem's attempt at more predictive last hitting.

nProjectileSpeed = 900 -- Bubbles' projectile speed.
nAttackRange = 550 -- Bubbles' attack range.
oldEnemyCreep = 0

function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep)
   unitSelf=core.unitSelf
    local bDebugEchos = false

    local unitSelf = core.unitSelf
    local nDamage = unitSelf:GetFinalAttackDamageMin()
    core.FindItems(botBrain)
    if core.itemHatchet then
        nDamage = nDamage * core.itemHatchet.creepDamageMul -- Does this work if a ranged buys hatchet..?
    end   
    
    local nAttackTime = unitSelf:GetAdjustedAttackActionTime() -- Time from start of attack to projectile launch.
       
    --local i = buffer:Count() - 1
    --BotEcho(buffer:Count())
    --while (i >= 0) do
    	--BotEcho(buffer:Get(i))
    	--i = i - 1;
    	--end
    
    if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
    	if unitEnemyCreep:GetUniqueID() ~= oldEnemyCreep then buffer:Reset(); timeBuffer:Reset() end
    	
    	buffer:Add(unitEnemyCreep:GetHealth()/(1-unitEnemyCreep:GetPhysicalResistance()))
    	
    	timeBuffer:Add(GetTime())    	
    	
        local nAttackOverhead = (Vector3.Distance2D(unitSelf:GetPosition(), unitEnemyCreep:GetPosition()) / nProjectileSpeed * 1000) + nAttackTime
		local nFrameLookBack = timeBuffer:Count() - 1
    	
		while ((GetTime() - timeBuffer:Get(nFrameLookBack)) < nAttackOverhead and nFrameLookBack > 0) do
       		nFrameLookBack = nFrameLookBack - 1
       	end
        --BotEcho(GetTime() - timeBuffer:Get(nFrameLookBack))
        local nCreepThreshold 
        if buffer:Count() >= nFrameLookBack then 
        	nCreepThreshold = 2*unitEnemyCreep:GetHealth() - buffer:Get(nFrameLookBack)
        end
    	if bDebugEchos and nCreepThreshold then BotEcho(nDamage.. " || ".. nCreepThreshold.. " || ".. unitEnemyCreep:GetHealth()) end
        if buffer:Count() >= nFrameLookBack and nDamage >= nCreepThreshold then
            local bActuallyLH = true
            --if bDebugEchos then BotEcho("Difference is ".. nCreepThreshold) end
            oldEnemyCreep = unitEnemyCreep:GetUniqueID()
            return unitEnemyCreep
        end
    end
 
 
    if unitAllyCreep then
        local nTargetHealth = unitAllyCreep:GetHealth()
        if nDamage >= nTargetHealth then
            local bActuallyDeny = false
 
 
            --[Difficulty: Easy] Don't deny
            if core.nDifficulty == core.nEASY_DIFFICULTY then
                bActuallyDeny = false
            end           
  
            if bActuallyDeny then
                if bDebugEchos then BotEcho("Returning an ally") end
                return unitAllyCreep
            end
        end
    end
    if unitEnemyCreep then oldEnemyCreep = unitEnemyCreep:GetUniqueID() end
    return nil
end
 
 
function AttackCreepsExecuteOverride(botBrain)
	local bDebugEchos = true

    local unitSelf = core.unitSelf
    local currentTarget = core.unitCreepTarget
    if currentTarget and core.CanSeeUnit(botBrain, currentTarget) then    
    	buffer:Add(currentTarget:GetHealth()/(1-currentTarget:GetPhysicalResistance()));
    	timeBuffer:Add(GetTime())
    	
        local vecTargetPos = currentTarget:GetPosition()
         
        local nDamage = unitSelf:GetFinalAttackDamageMin()
        if core.itemHatchet then
			nDamage = nDamage * core.itemHatchet.creepDamageMul
		end
 		local nAttackTime = unitSelf:GetAdjustedAttackActionTime() -- Attack duration? GetAdjustedAttackActionTime?
 		local nDist = Vector3.Distance2D(unitSelf:GetPosition(), currentTarget:GetPosition())
	 	local nAttackOverhead = (nDist / nProjectileSpeed * 1000) + nAttackTime
		
		local nFrameLookBack = timeBuffer:Count() - 1
		while ((GetTime() - timeBuffer:Get(nFrameLookBack)) < nAttackOverhead and nFrameLookBack > 0) do
       		nFrameLookBack = nFrameLookBack - 1
       	end
       	
       	local nCreepThreshold 
       	if buffer:Count() >= nFrameLookBack then 
	       	nCreepThreshold = 2*currentTarget:GetHealth() - buffer:Get(nFrameLookBack)
    	end
	    if nCreepThreshold and nDist <= nAttackRange and unitSelf:IsAttackReady() and nDamage >= nCreepThreshold then
       		core.OrderAttackClamp(botBrain, unitSelf, currentTarget)
    		if bDebugEchos and nCreepThreshold then BotEcho(nDamage.. " || ".. nCreepThreshold.. " || ".. currentTarget:GetHealth()) end
       		return true
--	        elseif (nDistSq > nAttackRangeSq) then
--            	local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
--            	core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false) --moves hero to target
			else					
               core.OrderHoldClamp(botBrain, unitSelf, false)
		end
	return false
    end
end
object.AttackCreepsExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteOverride



BotEcho(object:GetName()..'Finished loading bubbles_main!')

