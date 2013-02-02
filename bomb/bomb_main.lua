
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

BotEcho('loading bomb_main.lua...')

object.heroName = 'Hero_Bombardier'

object.tSkills = {
    2, 1, 2, 0, 2,
    3, 2, 0, 0, 0, 
    3, 1, 1, 1, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

--------------------------------
-- Skills
--------------------------------
function object:SkillBuild()

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


---------------------------------------------------
--                    Items                      --
---------------------------------------------------
behaviorLib.StartingItems = {"Item_PretendersCrown", "Item_PretendersCrown", "Item_MinorTotem", "Item_ManaPotion", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = {"Item_Marchers", "Item_EnhancedMarchers", "Item_GraveLocket", "Item_Weapon1"} --ManaRegen3 is Ring of the Teacher
behaviorLib.MidItems =  {"Item_SpellShards", "Item_Lightbrand", "Item_Intelligence7"} --Intelligence7 is Staff of the Master
behaviorLib.LateItems = {"Item_Morph", "Item_BehemothsHeart", "Item_GrimoireOfPower"} --Morph is Sheepstick. Item_Damage9 is Doombringer

---------------------------------------------------
--                   Overrides                   --
---------------------------------------------------

----------------------------------
--	Hero specific harass bonuses
--
--  Abilities off cd increase harass util
--  Ability use increases harass util for a time
----------------------------------

object.abilQUp = 20
object.abilWUp = 15
object.abilEUp = 0
object.abilRUp = 20
object.nSheepstickUp = 25

object.abilQUse = 25
object.abilWUse = 20
object.abilEUse = 0
object.abilRUse = 35
object.nSheepstickUse = 30

local function AbilitiesUpUtility(hero)
	local bDebugLines = false
	local bDebugEchos = false
	
	local nUtility = 0
	
	if skills.abilQ:CanActivate() then
		nUtility = nUtility + object.abilQUp
	end
	
	if skills.abilW:CanActivate() then
		nUtility = nUtility + object.abilWUp
	end
	
	if skills.abilE:CanActivate() then
		nUtility = nUtility + object.abilEUp
	end
	
	if skills.abilR:CanActivate() then
		nUtility = nUtility + object.abilRUp
	end
	
	if object.itemSheepstick and object.itemSheepstick:CanActivate() then
		nUtility = nUtility + object.nSheepstickUp
	end
	return nUtility
end

--Hero ability use gives bonus to harass util for a while
object.abilEUseTime = 0
object.abilWUseTime = 0

--for ability que
object.UseQ = false
object.UseR = false
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)
	
	local bDebugEchos = false
	local nAddBonus = 0
	
	if EventData.Type == "Ability" then
		if bDebugEchos then BotEcho("  ABILILTY EVENT!  InflictorName: "..EventData.InflictorName) end
		if EventData.InflictorName == "Ability_Bombardier1" then
			nAddBonus = nAddBonus + object.abilQUse
		elseif EventData.InflictorName == "Ability_Bombardier2" then
			nAddBonus = nAddBonus + object.abilWUse
			object.abilWUseTime = EventData.TimeStamp
		elseif EventData.InflictorName == "Ability_Bombardier3" then
			nAddBonus = nAddBonus + object.abilEUse
			object.abilEUseTime = EventData.TimeStamp
			BotEcho(object.abilEUseTime)
		elseif EventData.InflictorName == "Ability_Bombardier4" then
			nAddBonus = nAddBonus + object.abilRUse
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

--Util calc override
local function CustomHarassUtilityFnOverride(hero)
	local nUtility = AbilitiesUpUtility(hero)
	return nUtility
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   

----------------------------------
--           Fights             --
local function HarassHeroExecuteOverride(botBrain)
	local target = behaviorLib.heroTarget
	if target == nil then
		return false --Eh nothing here
	end
	
	--fetch some variables 
	local self = core.unitSelf
	local selfPosition = self:GetPosition()
	
	local attackRange = core.GetAbsoluteAttackRangeToUnit(self, target)
	
	local cantDodge = target:IsStunned() or target:IsImmobilized() or target:GetMoveSpeed() < 160
	local canSee = core.CanSeeUnit(botBrain, target)
	
	local targetPosition = target:GetPosition()
	local distance = Vector3.Distance2DSq(selfPosition, targetPosition)^(0.5)
	
	local aggroValue = behaviorLib.lastHarassUtil
	local actionTaken = false

	local Qup = skills.abilQ:CanActivate()
	local Wup = skills.abilW:CanActivate()
	local Eup = skills.abilE:CanActivate()
	local Rup = skills.abilR:CanActivate()

	local targetMaxHealt = target:GetMaxHealth()
	local targetHealt = target:GetHealth()
	local targetHealtPercentage = floor(targetHealt * 100 / targetMaxHealt)
	
	aggroValue = aggroValue + targetHealtPercentage / 5
	
	if object.useQ then
		actionTaken = core.OrderAbilityPosition(botBrain, skills.abilQ, targetPosition)
		object.useQ = false
	end
	
	if not actionTaken then
		if object.useR or targetHealt <= 200 then
			--Do some math based targets runing direction
			botBrain:OrderAbilityVector(skills.abilR, Vector3.Create(targetPosition.x-100, targetPosition.y-100), targetPosition)
			actionTaken = true
			object.useR = false
		end
	end

	if cantDodge then
		if Qup then --No questions just do it
			if distance < skills.abilQ:GetRange() then
				actionTaken = core.OrderAbilityPosition(botBrain, skills.abilQ, targetPosition)
			end
		end
	end
	--[[
	if aggroValue > 0 and aggroValue < 25 and Eup then
		if object.abilEUseTime + 2000 < HoN.GetGameTime() then --Dont spam all charges at once
			if distance < skills.abilE:GetRange() then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilE, target)
				core.OrderAttack(botBrain, self, target, true)
			end
		end
	end
	]]--
	if not actionTaken then
		if aggroValue < 35 and aggroValue > 20 then
			if Qup and Wup then
				if distance < skills.abilQ:GetRange() and distance < skills.abilW:GetRange() then
					actionTaken = core.OrderAbilityPosition(botBrain, skills.abilW, targetPosition, true)
					object.useQ = false
				end
			end
		end
	end
	
	--Todo: MANA
	if not actionTaken then
		if aggroValue < 70 then
			if Qup and Wup and Rup then
				if distance < skills.abilQ:GetRange() and distance < skills.abilW:GetRange() then
					actionTaken = core.OrderAbilityPosition(botBrain, skills.abilW, targetPosition, true)
					object.useQ = true
					object.useR = true
				end
			end
		end
	end

	if not actionTaken then
		if object.abilEUseTime + 5000 < HoN.GetGameTime() then --Dont spam all charges at once
			if distance < skills.abilE:GetRange() then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilE, target)
				core.OrderAttack(botBrain, self, target, true)
			end
		end
	end
	
	if not actionTaken then
		return object.harassExecuteOld(botBrain)
	end
end

object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

--Run away. Run away
local function RetreatFromThreatExecuteOverride(botBrain)
	local heroes = HoN.GetUnitsInRadius(core.unitSelf:GetPosition(), 800, core.UNIT_MASK_ALIVE + core.UNIT_MASK_HERO)
	enemyHeroes = {}
	for i, hero in ipairs(heroes) do
		if hero:GetTeam() ~= core.unitSelf:GetTeam() then
			table.insert(enemyHeroes, hero)
		end
	end

	if #enemyHeroes > 0 then
		--Todo if multiple do some math
		core.OrderAbilityPosition(botBrain, skills.abilW, enemyHeroes[1].GetPosition())
	end

	--Activate ghost marchers if we can
	core.FindItems(botBrain)
	local itemGhostMarchers = core.itemGhostMarchers
	if behaviorLib.lastRetreatUtil >= behaviorLib.retreatGhostMarchersThreshold and itemGhostMarchers and itemGhostMarchers:CanActivate() then
		core.OrderItemClamp(botBrain, core.unitSelf, itemGhostMarchers)
		return
	end

	local vecPos = behaviorLib.PositionSelfBackUp()
	core.OrderMoveToPosClamp(botBrain, core.unitSelf, vecPos, false)
end

object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatBehavior["Execute"]
behaviorLib.RetreatFromThreatBehavior["Execute"] = RetreatFromThreatExecuteOverride


--Get bot to defend

object.defTower = nil
local function DefenceUtility(botBrain)
	if core.unitSelf:GetLevel() > 6 then
		local allyTowers = core.allyTowers

		for i, building in ipairs(allyTowers) do
			local closeUnits = HoN.GetUnitsInRadius(building:GetPosition(), 2000, core.UNIT_MASK_ALIVE + core.UNIT_MASK_UNIT)
			sortedUnits = {}
			core.SortUnitsAndBuildings(closeUnits, sortedUnits, false)
			if core.NumberElements(sortedUnits.enemies) > 5 then
				object.defTower = building:GetPosition()
				--botBrain:ChatbotBrain:Chat("Defend towers")
				return 3.5 * core.NumberElements(sortedUnits.enemies) + 10 * core.NumberElements(sortedUnits.enemyHeroes)
			end
		end
	end
	return 0
end


local function DefenceExecute(botBrain)
	core.OrderMoveToPosClamp(botBrain, core.unitSelf, object.defTower, false, false)
	behaviorLib.nNextBehaviorTime = HoN.GetGameTime() + 10000
	--botBrain:Chat("Moving to defend")
	return
end

DefenceBehavior = {}
DefenceBehavior["Utility"] = DefenceUtility
DefenceBehavior["Execute"] = DefenceExecute
DefenceBehavior["Name"] = "Defence"
tinsert(behaviorLib.tBehaviors, DefenceBehavior)



--[[
function TeamGroupExecuteOverride(botBrain)
	core.AllChat("TeamGroupExecute")
	if object.defTowers then
		core.OrderAttackPositionClamp(botBrain, core.unitSelf, object.defTower, false)
		object.defTowers = false
		object.defTower = nil
		core.AllChat("Moving to defend")
		return
	end

	local unitSelf = core.unitSelf
	local teamBotBrain = core.teamBotBrain
	local nCurrentTimeMS = HoN.GetGameTime()
	
	local vecRallyPoint = teamBotBrain:GetGroupRallyPoint()
	if vecRallyPoint then
		local nCurrentTime = HoN.GetGameTime()
		--Chat about it
		if behaviorLib.nNextGroupMessage < nCurrentTime then
			if behaviorLib.nNextGroupMessage == 0 then
				behaviorLib.nNextGroupMessage = nCurrentTime
			end

			local nDelay = random(core.nChatDelayMin, core.nChatDelayMax)
			local tLane = teamBotBrain:GetDesiredLane(unitSelf.object or unitSelf)
			local sLane = tLane and tLane.sLaneName or "nil"
			core.TeamChatLocalizedMessage("group_up", {lane=sLane}, nDelay)
			--core.AllChat("Grouping up to push!", nDelay)
			behaviorLib.nNextGroupMessage = behaviorLib.nNextGroupMessage + (teamBotBrain.nPushInterval * 0.8)
		end
		
		--Do it
		local nDistanceSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecRallyPoint)
		local nCloseEnoughSq = teamBotBrain.nGroupUpRadius - 100
		nCloseEnoughSq = nCloseEnoughSq * nCloseEnoughSq
		if nDistanceSq < nCloseEnoughSq then
			core.OrderAttackPositionClamp(botBrain, unitSelf, vecRallyPoint, false)
		else
			behaviorLib.MoveExecute(botBrain, vecRallyPoint)
		end
	else
		BotEcho("nil rally point!")
	end

	return
end

object.TeamGroupExecuteOld = behaviorLib.TeamGroupExecute
behaviorLib.TeamGroupExecute = TeamGroupExecuteOverride

]]--

BotEcho('finished loading bomb_main.lua')
