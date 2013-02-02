-- Pebbs v0.1
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

object.core 		= {}
object.eventsLib 	= {}
object.metadata 	= {}
object.behaviorLib 	= {}
object.skills 		= {}

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

local sqrtTwo = math.sqrt(2)

BotEcho('loading pebbs_main...')

--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, hero_yogi ==wildsoul
object.heroName = 'Hero_Rocky'

--   item buy order. internal names  
behaviorLib.startingitems  = {}
behaviorLib.laneitems  = {}
behaviorLib.miditems  = {}
behaviorLib.lateitems  = {}


-- skillbuild table, 0=q, 1=w, 2=e, 3=r, 4=attri
object.tSkills = {
    0, 1, 0, 1, 0, 1,	-- 1-6
	0, 1, 3, 2, 3, 		-- 7-11
	2, 2, 2, 4, 3,		-- 12-16
	4, 4, 4, 4, 4, 4, 4, 4, 4,	--17-25
}

-- bonus agression points if a skill/item is available for use


-- bonus agression points that are applied to the bot upon successfully using a skill/item


--thresholds of aggression the bot must reach to use these abilities





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
    --core.verboselog("skillbuild()")

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

-- well=phaseboots, bad=striders
-- well=portalkey, terrible=tablet
-- well=demonic, bad=HotBL
-- well=heart, bad=shamans

local nHiding=false;
------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

	if (nHiding) then
		--run to jokespot and teleport
	end
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride



-- These are bonus agression points if a skill/item is available for use
object.nstunUp = 30--10
object.nChuckUp = 30--12
object.nPortalkeyUp = 40
 
-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nStunUse = 30
object.nChuckUse = 40
object.nPortalkeyUse = 20
 
 
--These are thresholds of aggression the bot must reach to use these abilities
object.nStunThreshold = 0
object.nChuckThreshold = 25
object.nPortalkeyThreshold = 0


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
        if EventData.InflictorName == "Ability_Rocky2" then
            nAddBonus = nAddBonus + object.nChuckUse
        elseif EventData.InflictorName == "Ability_Rocky1" then
            nAddBonus = nAddBonus + object.nStunUse
        end
    elseif EventData.Type == "Item" then
        if core.itemPortalkey ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemPortalkey:GetName() then
            nAddBonus = nAddBonus + self.nPortalkeyUse
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
local function CustomHarassUtilityFnOverride(hero) --how much to harrass, doesn't change combo order or anything
	local nUtil = 0
	
    if skills.abilQ:CanActivate() then
        nUnil = nUtil + object.nStunUp
    end
 
    if skills.abilW:CanActivate() then
        nUtil = nUtil + object.nChuckUp
    end
	
	if object.itemPortalkey and object.itemPortalkey:CanActivate() then
        nUtility = nUtility + object.nPortalkeyUp
    end
	BotEcho(hero:GetHealthPercent());
	if (hero:GetHealthPercent()<50) then
		nUtil=75
	end
	-- if hero hp is low, combo up and in range, perhaps if someone is nearby and ping?(?)	
    return nUtil -- no desire to attack AT ALL if 0.
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
    local vecMyPosition = unitSelf:GetPosition() --me
    local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
    local nMyExtraRange = core.GetExtraRange(unitSelf)
    
    local vecTargetPosition = unitTarget:GetPosition() --them
    local nTargetExtraRange = core.GetExtraRange(unitTarget)
    local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
    
    local nLastHarassUtility = behaviorLib.lastHarassUtil
    local bCanSee = core.CanSeeUnit(botBrain, unitTarget)    
    local bActionTaken = false
    
    --BotEcho('Attempting Harass')
    
    --- Insert abilities code here, set bActionTaken to true 
    --- if an ability command has been given successfully
    
     --since we are using an old pointer, ensure we can still see the target for entity targeting
    if core.CanSeeUnit(botBrain, unitTarget) then
		--BotEcho('Can see')
        local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:IsPerplexed()
        local abilStun = skills.abilQ
        local abilChuck = skills.abilW
        core.FindItems()
        local itemPortalkey = core.itemPortalkey
		
		--core.OrderAbilityPosition(botBrain, abilStun, vecTargetPosition)
		--bActionTaken=true
    
        -- PORTAL KEY IN!
        if not bActionTaken then-- and not bTargetVuln then -- TODO AND COMBO CAN KILL  
            if itemPortalkey then
                local nRange = itemPortalkey:GetRange()
                if itemPortalkey:CanActivate() and nLastHarassUtility > botBrain.nPortalkeyThreshold --[[ TODO make sure you can kill them! (perhaps ignore lastharassutility?) ]] then
                    if nTargetDistanceSq < (nRange*nRange) then
						bActionTaken = core.OrderAbilityPosition(botBrain, itemPortalkey, vecTargetPosition) --teleport on that mofo
					else
						bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
					end
				end
            end
			-- stun!
            if abilStun:CanActivate() then-- and nLastHarassUtility > botBrain.nStunThreshold then
                local nRange = abilStun:GetRange()
				--BotEcho( "Stun range is " .. abilStun:GetRange() )
                if nTargetDistanceSq < (nRange * nRange) then --TODO perhaps something smarter here. to account for distance and speed and direction etc.
                    bActionTaken = core.OrderAbilityPosition(botBrain, abilStun, vecTargetPosition)
                    bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget)
                end          
            end
        end
 
 
		 -- Chuck
		if not bActionTaken then
			if abilChuck:CanActivate() then--and nLastHarassUtility > botBrain.nChuckThreshold then
				--BotEcho('Chuck Available' .. nTargetDistanceSq)
				local nRange = abilChuck:GetRange()
				if nTargetDistanceSq < (60000--[[about 40 units away  NOT nRange * nRange     ]]) and not bTargetVuln then --stun when they come out of stun.
					--BotEcho('Trying to chuck!')
					--bActionTaken = core.OrderAbilityPosition(botBrain, abilChuck, vecTargetPosition)
                    --bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget)
                    bActionTaken = core.OrderAbilityEntity(botBrain, abilChuck, unitTarget)
                else
                    bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, unitTarget)
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


----------------------------------
--	Pebbles' items
----------------------------------
--[[ list code:
	"# Item" is "get # of these"
	"Item #" is "get this level of the item" --]]
behaviorLib.StartingItems = 
	{"Item_GuardianRing", "Item_PretendersCrown", "Item_MinorTotem", "Item_HealthPotion", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = 
	{"Item_Striders", "Item_Portalkey"} --ManaRegen3 is Ring of the Teacher, Item_Strength5 is Fortified Bracer
behaviorLib.MidItems = 
	{"Item_SolsBulwark", "Item_DaemonicBreastplate"} --Intelligence7 is Staff of the Master
behaviorLib.LateItems = 
	{"Item_BehemothsHeart", 'Item_Damage9'} --Morph is Sheepstick. Item_Damage9 is Doombringer




BotEcho('finished loading pebbs_main')