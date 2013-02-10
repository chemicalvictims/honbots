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
-- SlitherBot 0.3
-- Basic SlitherBot mainly for my personal use of learning 
-- uses code from many sources
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
object.heroName = 'Hero_Ebulus'


--   item buy order. internal names
----------------------------------
--	Slither items
----------------------------------
--[[ list code:
	"# Item" is "get # of these"
	"Item #" is "get this level of the item" --]]
behaviorLib.StartingItems = 
	{"Item_DuckBoots", "Item_DuckBoots", "Item_ManaPotion", "Item_MinorTotem", "Item_RunesOfTheBlight", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = 
	{"Item_ManaRegen3", "Item_IronShield", "Item_Marchers", "Item_Striders", "Item_MajorTotem", "Item_NomesWisdom", "Item_Lifetube"} --ManaRegen3 is Ring of the Teacher, Item_Strength5 is Fortified Bracer
behaviorLib.MidItems = 
	{"Item_Manatube", "Item_Steamstaff", "Item_Protect"} 
behaviorLib.LateItems = 
	{"Item_Evasion", "Item_Intelligence7"} 


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    1, 0, 0, 2, 0,
    3, 0, 1, 2, 1, 
    3, 2, 2, 2, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- These are bonus agression points if a skill/item is available for use
object.nQUp = 20
object.nEUp = 12 
object.nRUp = 35
-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nQUse = 40
object.nEUse = 10
object.nRUse = 55
--These are thresholds of aggression the bot must reach to use these abilities
object.nQThreshold = 20
object.nEThreshold = 10
object.nRThreshold = 60


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
-- OncombatEvent Override --
-- Use to check for Infilictors (fe. Buffs) --
----------------------------------------------
-- @param: EventData
-- @return: none 
function object:oncombateventOverride(EventData)
self:oncombateventOld(EventData)
local nAddBonus = 0
if EventData.Type == "Ability" then
if EventData.InflictorName == "Ability_Ebulus1" then
nAddBonus = nAddBonus + object.nQUse
elseif EventData.InflictorName == "Ability_Ebulus3" then
nAddBonus = nAddBonus + object.nEUse
elseif EventData.InflictorName == "Ability_Ebulus4" then
nAddBonus = nAddBonus + object.nRUse
end
end
if nAddBonus > 0 then
core.DecayBonus(self)
core.nHarassBonus = core.nHarassBonus + nAddBonus
end
end
-- override combat event trigger function.
object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride




------------------------------------------------------
--            CustomHarassUtility Override          --
-- Change Utility according to usable spells here   --
------------------------------------------------------
-- @param: IunitEntity hero
-- @return: number
local function CustomHarassUtilityFnOverride(hero)
    local nUtil = 0
    
    if skills.abilQ:CanActivate() then
        nUtil = nUtil + object.nQUp
    end

    if skills.abilE:CanActivate() then
        nUtil = nUtil + object.nEUp
    end

    if skills.abilR:CanActivate() then
        nUtil = nUtil + object.nRUp
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
function object.GetBurstRadius()
	return 700
end

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
    
-- Poison Spray
if not bActionTaken then
local abilSpray = skills.abilQ
if abilSpray:CanActivate() and nLastHarassUtility > botBrain.nQThreshold then
local nRange = abilSpray:GetRange()
if nTargetDistanceSq < (nRange * nRange) then
bActionTaken = core.OrderAbilityPosition(botBrain, abilSpray, vecTargetPosition)
else
bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
end
end
end
    
-- Toxin Ward
if not bActionTaken then
local abilWard = skills.abilE
if abilWard:CanActivate() and nLastHarassUtility > botBrain.nEThreshold then
local nRange = abilWard:GetRange()
if nTargetDistanceSq < (nRange * nRange) then
bActionTaken = core.OrderAbilityPosition(botBrain, abilWard, vecTargetPosition)
else
bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
end
end
end

--ult

if not bActionTaken then
		local abilBurst = skills.abilR
		if abilBurst:CanActivate() then
			--get the target well within the radius
			local nRadius = botBrain.GetBurstRadius()
			local nHalfRadiusSq = nRadius * nRadius * 0.25
			if nTargetDistanceSq <= nHalfRadiusSq then
				bActionTaken = core.OrderAbility(botBrain, abilBurst)
			elseif not unitSelf:IsAttackReady() then
				--move in when we aren't attacking
				core.OrderMoveToUnit(botBrain, unitSelf, unitTarget)
				bActionTaken = true
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






