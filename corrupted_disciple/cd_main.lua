-------------------------------------------------------------------
-------------------------------------------------------------------
--   ____     __               ___    ____             __        --
--  /\  _`\  /\ \             /\_ \  /\  _`\          /\ \__     --
--  \ \,\L\_\\ \ \/'\       __\//\ \ \ \ \L\ \    ___ \ \ ,_\    --
--   \/_\__ \ \ \ , <     /'__`\\ \ \ \ \  _ <'  / __`\\ \ \/    --
--     /\ \L\ \\ \ \\`\  /\  __/ \_\ \_\ \ \L\ \/\ \L\ \\ \ \_   --
--     \ `\____\\ \_\ \_\\ \____\/\____\\ \____/\ \____/ \ \__\  --
--      \/_____/ \/_/\/_/ \/____/\/____/ \/___/  \/___/   \/__/  --
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Skelbot v0.0000008
-- This bot represent the BARE minimum required for HoN to spawn a bot
-- and contains some very basic overrides you can fill in
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


BotEcho(object:GetName()..' loading <hero>_main...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, Hero_Yogi ==wildsoul
object.heroName = 'Hero_CorruptedDisciple'


--   item buy order. internal names  
behaviorLib.StartingItems  = {}
behaviorLib.LaneItems  = {}
behaviorLib.MidItems  = {}
behaviorLib.LateItems  = {}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 1, 0, 1, 0,
    3, 0, 1, 1, 2, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

object.nElectricTideUp = 25
object.nConduitUp = 25
object.nUltUp = 35

object.nElectricTideUse = 5
object.nConduitUse = 20
object.nUltUse = 25

object.nElectricTideThreshold = 25
object.nConduitThreshold = 25
object.nUltThreshold = 45





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

	local bDebugEchos = false
	local nAddBonus = 0
	
	if EventData.Type == "Ability" then
		if bDebugEchos then BotEcho("  ABILILTY EVENT!  InflictorName: "..EventData.InflictorName) end
		if EventData.InflictorName == "Ability_CorruptedDisciple1" then
			nAddBonus = nAddBonus + object.nElectricTideUse
		elseif EventData.InflictorName == "Ability_CorruptedDisciple2" then
			nAddBonus = nAddBonus + object.nConduitUse
		elseif EventData.InflictorName == "Ability_CorruptedDisciple4" then
			nAddBonus = nAddBonus + object.nUltUse
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
    local bDebugEchos = false
	
	local val = 0
	
	if skills.abilQ:CanActivate() then
		val = val + object.nElectricTideUp
	end
	
	if skills.abilW:CanActivate() then
		val = val + object.nConduitUp
	end

	if skills.abilR:CanActivate() then
		val = val + object.nUltUp
	end
	
	if bDebugEchos then BotEcho(" HARASS - abilitiesUp: "..val) end

    return val
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
    
	local bDebugEchos = false
	
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
    
    
   	BotEcho("Corrupted Disciple HarassHero at "..nLastHarassUtility)

	if core.CanSeeUnit(botBrain, unitTarget) then
		if not bActionTaken and nLastHarassUtility > object.nElectricTideThreshold then
			BotEcho('Checking Electric Tide')
			local abilElectricTide= skills.abilQ
			if abilElectricTide:CanActivate() then
				local nRange = abilElectricTide:GetRange()
				if nTargetDistanceSq < (700 * 700) then
					BotEcho('Electric Tide activated')
					bActionTaken = core.OrderAbility(botBrain, abilElectricTide)
				end
			end
		end
	end

		if core.CanSeeUnit(botBrain, unitTarget) then
		if not bActionTaken and nLastHarassUtility > object.nConduitThreshold then
			BotEcho('Checking Conduit')
			local abilConduit = skills.abilW
			if abilConduit:CanActivate() then
				local nRange = abilConduit:GetRange()
				if nTargetDistanceSq < (nRange * nRange) then
					BotEcho('Conduit activated')
					bActionTaken = core.OrderAbilityEntity(botBrain, abilConduit, unitTarget)
				end
			end
		end
	end

	if core.CanSeeUnit(botBrain, unitTarget) then
		if not bActionTaken and nLastHarassUtility > object.nUltThreshold then
			local abilUlt = skills.abilR
			if abilUlt:CanActivate() then
				local nRange = abilUlt:GetRange()
				if nTargetDistanceSq < (nAttackRange * nAttackRange) then
					BotEcho('Overload activated')
					bActionTaken = core.OrderAbility(botBrain, abilUlt)
				end
			end
		end
	end
    
    
    
    
    if not bActionTaken then
		if bDebugEchos then BotEcho("  No action yet, proceeding with normal harass execute.") end
        return object.harassExecuteOld(botBrain)
    end 
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride


behaviorLib.StartingItems = {"2 Item_DuckBoots", "2 Item_MinorTotem", "Item_HealthPotion", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = {"Item_Marchers", "Item_Shield2", "Item_EnhancedMarchers", "Item_MysticVestments"} --Item_Shield2 = Helm of the black legion
behaviorLib.MidItems = {"Item_Dawnbringer", "Item_MagicArmo2"} -- Item_MagicArmo2 = Shaman's Headdress
behaviorLib.LateItems = {"Item_Weapon3", "Item_Lightning2", "Item_Evasion" } --Weapon3 is Savage Mace. Item_Lightning2 = Charged Hammer, Item_Evasion = Wingbow

BotEcho('finished loading corrupted')



