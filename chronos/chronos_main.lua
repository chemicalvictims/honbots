--ChronosBot v0.000001
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

object.bReportBehavior = true
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

BotEcho('loading chronos_main...')

object.heroName = 'Hero_Chronos'

--------------------------------
-- Skills
--------------------------------
function object:SkillBuild()
	--core.VerboseLog("SkillBuild()")

	local unitSelf = self.core.unitSelf	
	
	if  skills.abilTimeLeap == nil then
		skills.abilTimeLeap			= unitSelf:GetAbility(0)
		skills.abilRewind			= unitSelf:GetAbility(1)
		skills.abilCurseOfAges		= unitSelf:GetAbility(2)
		skills.abilChronosphere		= unitSelf:GetAbility(3)
		skills.abilAttributeBoost	= unitSelf:GetAbility(4)
	end
	
	if unitSelf:GetAbilityPointsAvailable() <= 0 then
		return
	end
	
	if skills.abilChronosphere:CanLevelUp() then
		skills.abilChronosphere:LevelUp()
	elseif skills.abilTimeLeap:CanLevelUp() then
		skills.abilTimeLeap:LevelUp()
	elseif skills.abilRewind:GetLevel() < 1 then
		skills.abilRewind:LevelUp()
	elseif skills.abilCurseOfAges:CanLevelUp() then
		skills.abilCurseOfAges:LevelUp()
	elseif skills.abilRewind:CanLevelUp() then
		skills.abilRewind:LevelUp()
	else
		skills.abilAttributeBoost:LevelUp()
	end
end

local function GetTimeLeapRadius()
	return 300
end

local function GetChronosphereRadius()
	return 400
end

---------------------------------------------------
--                   Overrides                   --
---------------------------------------------------

--[[for testing
function object:onthinkOverride(tGameVariables)
	self:onthinkOld(tGameVariables)
	
	--behaviorLib.HarassHeroBehavior["Utility"](self)
	--behaviorLib.HarassHeroBehavior["Execute"](self)
	
	BotEcho("Harass: "..behaviorLib.lastHarassUtil)
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride
--]]

--melee weight overrides
behaviorLib.nCreepPushbackMul = 0.5
behaviorLib.nTargetPositioningMul = 0.6

----------------------------------
--	Chronos' specific harass bonuses
--
--  Abilities off cd increase harass util
--  Ability use increases harass util for a time
----------------------------------

object.nTimeLeapUp = 13
object.nChronosphereUp = 40

object.nTimeLeapUse = 45
object.nChronosphereUse = 70

object.nCurseOfAgesNext = 6

object.nTimeLeapThreshold = 35
object.nTimeLeapHPThreshold = 0.35
object.nChronosphereThreshold = 50
object.nChronosphereRetreatHPThreshold = 0.15

local function IsCurseOfAgesNext()
	return skills.abilCurseOfAges:GetCharges() <= 1 
end

local function AbilitiesUpUtility(hero)
	local bDebugLines = false
	local bDebugEchos = false
	
	local nUtility = 0
	
	if skills.abilTimeLeap:CanActivate() then
		nUtility = nUtility + object.nTimeLeapUp
	end
	
	if IsCurseOfAgesNext() then
		nUtility = nUtility + object.nCurseOfAgesNext
	end
	
	if skills.abilChronosphere:CanActivate() then
		nUtility = nUtility + object.nChronosphereUp
	end
	
	if bDebugEchos then BotEcho(" HARASS - abilitiesUp: "..nUtility) end
	if bDebugLines then
		local lineLen = 150
		local myPos = core.unitSelf:GetPosition()
		local vTowards = Vector3.Normalize(hero:GetPosition() - myPos)
		local vOrtho = Vector3.Create(-vTowards.y, vTowards.x) --quick 90 rotate z
		core.DrawDebugArrow(myPos - vOrtho * lineLen * 1.4, (myPos - vOrtho * lineLen * 1.4 ) + vTowards * nUtility * (lineLen/100), 'cyan')
	end
	
	return nUtility
end








-- attetntion:
--[[
x               x
 x       -
			  x
			  
	Imagine x are creeps, and - is their center
	this will be correctly calculated, however
	it does not state that creeps are in range
	of certain abilities
]]
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

-- Filters given Group of enemies for range to their center, returns table
-- we dont filter for any count of heroes, thats a thing we do later on. (PERFORMANCE?)
local function filterRange(tGroup, vecGroupCenter, nRange)
	if tGroup == nil or vecGroupCenter == nil or nRange == nil then return nil end
	
	
	local tTableTemp = {}
	for id, creep in pairs(tGroup) do
		---BotEcho('ID: '..id..' creep: '..creep)
		if Vector3.Distance2D(creep:GetPosition(), vecGroupCenter) < (nRange*nRange) then
			tinsert(tTableTemp, creep)
		end
	end

	if #tTableTemp <= 0 then 
		return nil
	else
		return tTableTemp -- table containing only relevant units for the ultimate
	end
end


local function executeChronosphere(botBrain, unitSelf, nMinEnemies)
	if nMinEnemies == nil then nMinEnemies = 1 end

	local abilChronosphere = skills.abilChronosphere
	local nCheckRange = abilChronosphere:GetRange() + object.nChronosphereCheckRangeBuffer
	local nRadius = GetChronosphereRadius()

	local tEnemies = core.localUnits["EnemyHeroes"]
	if tEnemies == nil then return false end
	
	local nTargetRange = abilChronosphere:GetTargetRadius()
	local nRange = abilChronosphere:GetRange()
	local vGroupCenter = groupCenter(tEnemies) -- gives center of enemy heroes	
	
	if vGroupCenter == nil then return false end
	-- TODO: Add leap mechanics here, so we might leap in and do the ultimate
	if nRange*nRange >= Vector3.Distance2DSq(unitSelf:GetPosition(), vGroupCenter) then
		tEnemies = filterRange(tEnemies, vGroupCenter, nTargetRange)
	end
	
	local nEnemyCount = #tEnemies	
	if nEnemyCount >= 4 then 
		return  core.OrderAbilityPosition(botBrain, abilChronosphere, vGroupCenter) 
	end 
	
	
	local tAllies = core.localUnits["AllyHeroes"]
	local nAllyCount = 0
	if not tAllies == nil then
		tAllies = filterRange(tAllies, vGroupCenter, nTargetRange)
		nAllyCount = #tAllies
	end
		
	if nEnemyCount > nMinEnemies  and  nEnemyCount >= nAllyCount then -- check low life enemies too, if leap is on cd
		return  core.OrderAbilityPosition(botBrain, abilChronosphere, vGroupCenter) -- order ultimate in center of group, it has proofen worthy enough :)
	end
end



--Chronos ability use gives bonus to harass util for a while
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)
	
	local bDebugEchos = false
	local nAddBonus = 0
	
	if EventData.Type == "Ability" then
		if bDebugEchos then BotEcho("  ABILILTY EVENT!  InflictorName: "..EventData.InflictorName) end
		if EventData.InflictorName == "Ability_Chronos1" then
			nAddBonus = nAddBonus + self.nTimeLeapUse
		elseif EventData.InflictorName == "Ability_Chronos4" then
			nAddBonus = nAddBonus + self.nChronosphereUse
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
local function CustomHarassUtilityFnOverride(hero)
	local nUtility = AbilitiesUpUtility(hero)
	
	return nUtility
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   

----------------------------------
--	Chronos harass actions
----------------------------------
object.nTimeLeapRadiusBuffer = 100
object.nChronosphereCheckRangeBuffer = 200
local function HarassHeroExecuteOverride(botBrain)
	local bDebugEchos = false
	
	local unitTarget = behaviorLib.heroTarget
	if unitTarget == nil then
		return false --can not execute, move on to the next behavior
	end
	
	
	local unitSelf = core.unitSelf
	
	local vecMyPosition = unitSelf:GetPosition()
	local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
	nAttackRangeSq = nAttackRangeSq * nAttackRangeSq
	local nMyExtraRange = core.GetExtraRange(unitSelf)
	
	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(unitTarget)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
	local nHPPercentage = unitSelf:GetHealthPercent()
	
	local nLastHarassUtility = behaviorLib.lastHarassUtil
	
	if bDebugEchos then BotEcho("Chronos HarassHero at "..nLastHarassUtility) end
	local bActionTaken = false
	
	--Time Leap
	local nLeapRange = skills.abilTimeLeap:GetRange()
	if not bActionTaken and Vector3.Distance2DSq(vecMyPosition, vecTargetPosition) >= nLeapRange*nLeapRange*0.3 and not bTargetRooted and nLastHarassUtility > botBrain.nTimeLeapThreshold then
		if bDebugEchos then BotEcho("  No action yet, checking time leap") end
		local abilTimeLeap = skills.abilTimeLeap
		
		if abilTimeLeap:CanActivate() then
			if object.nTimeLeapHPThreshold >= nHPPercentage then
				local vecTargetTraveling = nil
				if unitTarget.bIsMemoryUnit and unitTarget.lastStoredPosition then
					vecTargetTraveling = Vector3.Normalize(vecTargetPosition - unitTarget.lastStoredPosition)
				else
					local unitEnemyWell = core.enemyWell
					if unitEnemyWell then
						--TODO: use heading
						vecTargetTraveling = Vector3.Normalize(unitEnemyWell:GetPosition() - vecTargetPosition)
					end
				end
				
				local vecAbilityTarget = vecTargetPosition
				if vecTargetTraveling then
					vecAbilityTarget = vecTargetPosition + vecTargetTraveling * (GetTimeLeapRadius() - object.nTimeLeapRadiusBuffer)
				end
				
				bActionTaken = core.OrderAbilityPosition(botBrain, abilTimeLeap, vecAbilityTarget)
			--else
				
			end
		end
	end
	
	--Chronosphere
	local abilChronosphere = skills.abilChronosphere
	if not bActionTaken and abilChronosphere:CanActivate() then
	
		--	BotEcho('Prepare to be sphered')
		if bDebugEchos then BotEcho("  No action yet, checking chronosphere") end
		
		-- Chronos uses chronosphere if he and one other enemy are both low, so he tries to finish him with ultimate safly
		if object.nChronosphereRetreatHPThreshold+0.20 >= nHPPercentage and unitTarget:GetHealthPercent() <= object.nChronosphereRetreatHPThreshold+0.20  then
			BotEcho('Use it'..unitTarget:GetHealthPercent())
			bActionTaken = executeChronosphere(botBrain, unitSelf, 0)
			
		elseif nLastHarassUtility > botBrain.nChronosphereThreshold then
			--[[ 
				Chronosphere execution
				Gets group center
				then checks for valid ultimate, first if enough are in range, then if there arent to much allies
			]]
			bActionTaken = executeChronosphere(botBrain, unitSelf)
		end 
	end
		
	if not bActionTaken then
		if bDebugEchos then BotEcho("  No action yet, proceeding with normal harass execute.") end
		return object.harassExecuteOld(botBrain)
	end
end
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride





local function HealAtWellUtilityOverride(botBrain)
	local abilChronosphere = skills.abilChronosphere
	local unitSelf = core.unitSelf 
	local nHPPercentage = unitSelf:GetHealthPercent()

	-- Chronos uses chronosphere for emergency retreat if he still has it aviable
	if abilChronosphere:CanActivate() and object.nChronosphereRetreatHPThreshold >= nHPPercentage  then
		executeChronosphere(botBrain, core.unitSelf, 0)
	end 
	
	object.HealAtWellUtilityOld(botBrain)
end
object.HealAtWellUtilityOld = behaviorLib.HealAtWellBehavior["Execute"]
behaviorLib.HealAtWellBehavior["Execute"] = HealAtWellUtilityOverride













----------------------------------
--	Chronos items
----------------------------------
--[[ list code:
	"# Item" is "get # of these"
	"Item #" is "get this level of the item" --]]
	
behaviorLib.StartingItems = 
	{"Item_LoggersHatchet", "Item_IronBuckler", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = 
	{"Item_IronShield", "Item_Marchers", "Item_Steamboots", "Item_ElderParasite"}
behaviorLib.MidItems = 
	{"Item_SolsBulwark", "Item_Weapon3", "Item_Critical1 4"} --Item_Weapon3 is Savage Mace, Item_Critical1 is Riftshards
behaviorLib.LateItems = 
	{"Item_DaemonicBreastplate", "Item_Lightning2", "Item_BehemothsHeart", 'Item_Damage9'} --Item_Lightning2 is Charged Hammer. Item_Damage9 is Doombringer



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

BotEcho('finished loading chronos_main')
