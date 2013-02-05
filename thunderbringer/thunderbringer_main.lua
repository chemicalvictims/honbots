-- Just Thunderbringer v 0.2  Kunas = Thunderbringer... durp
-- By Atornius, just a random HoN-player
--Special thanks to Naib and his Bot Tutorial: Pyro
-- Special thanks to Anakonda and his BombardierBot because I used his bot as template
-- Special thanks to kairus101 and his PebblesBot because I took some variables and ideas from his bot
-- Special thanks to St0l3n_ID and his lua guide
-- Special thanks to Wards and his Farming Style Last Hits (Kais + Fixes)

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

BotEcho('loading thunderbringer_main.lua...')

object.heroName = 'Hero_Kunas'

------------------------------
--     skills               --
------------------------------
function object:SkillBuild()
core.VerboseLog("skillbuild()")


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
-- Skill build
tSkills ={
				0, 2, 1, 1, 1,
				3, 1, 2, 2, 2,
				3, 0, 0, 0, 4,
				3
			}
	local nLev = unitSelf:GetLevel()
    local nLevPts = unitSelf:GetAbilityPointsAvailable()
    --BotEcho(tostring(nLev + nLevPts))
    for i = nLev, nLev+nLevPts do
		local nSkill = tSkills[i]
		if nSkill == nil then nSkill = 4 end
		
        unitSelf:GetAbility(nSkill):LevelUp()
    end
end		

-- bonus agression points if a skill/item is available for use
object.abilQUp = 5
object.abilWUp = 10
object.abilRUp = 15
object.nSheepstickUp = 0

-- bonus agression points that are applied to the bot upon successfully using a skill/item
object.abilQUse = 0
object.abilWUse = 10
object.abilRUse = 5
object.nSheepstickUse = 0



object.abilQUseTime = 0
--Hero ability use gives bonus to harass util for a while
function object:oncombateventOverride(EventData)
    self:oncombateventOld(EventData)
	
	local bDebugEchos = false
    local addBonus = 0

    if EventData.Type == "Ability" then
		if bDebugEchos then BotEcho(" ABILITY EVENT! InflictorName: "..EventData.InflictorName) end
        if EventData.InflictorName == "Ability_Kunas1" then
            addBonus = addBonus + object.abilQUse
			object.abilQUseTime = EventData.TimeStamp
			BotEcho(object.abilQUseTime)
        elseif EventData.InflictorName == "Ability_Kunas2" then
            addBonus = addBonus + object.abilWUse
        elseif EventData.InflictorName == "Ability_Kunas4" then
            addBonus = addBonus + object.abilRUse
        end
	elseif EventData.Type == "Item" then
		if core.itemSheepstick ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSheepstick:GetName() then
			addBonus = addBonus + self.nSheepstickUse
		end
	end
    if addBonus > 0 then
        core.DecayBonus(self)
        core.nHarassBonus = core.nHarassBonus + addBonus
    end

end
object.oncombateventOld = object.oncombatevent
object.oncombatevent    = object.oncombateventOverride


--Util calc override
local function CustomHarassUtilityFnOverride(hero)
	local bDebugLines = false
	local self = core.unitSelf
	local selfMaxMana = self:GetMaxMana()
	local selfMana = self:GetMana()
	local selfManaPercentage = floor(selfMana * 100 / selfMaxMana)
	
	local nUtility = 0
	
	if skills.abilQ:CanActivate() then
		nUtility = nUtility + object.abilQUp
	end
	
	if skills.abilW:CanActivate() then
		nUtility = nUtility + object.abilWUp
	end
	
	if skills.abilR:CanActivate() then
		nUtility = nUtility + object.abilRUp
	end
	
	if object.itemSheepstick and object.itemSheepstick:CanActivate() then
		nUtility = nUtility + object.nSheepstickUp
	end
	if selfManaPercentage > 95 then
		nUtility = nUtility + 100
	end
	
	return nUtility
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   

----------------------------------
--  FindItems Override
----------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemSheepstick ~= nil and not core.itemSheepstick:IsValid() then
		core.itemSheepstick = nil
	end

	if bUpdated then
		--only update if we need to
		if core.itemSheepstick then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
					core.itemSheepstick = core.WrapInTable(curItem)
				end
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

-- Dont work..?
local function funcGoingToWellOverride(botBrain)
	local self = core.unitSelf
	local selfMaxHealth = self:GetMaxHealth()
	local selfHealth = self:GetHealth()
	local selfHealthPercentage = floor(selfHealth * 100 / selfMaxHealth)
	if selfHealthPercentage < 20 or self:GetMana() < 75 then
		local wellPos = core.allyWell and core.allyWell:GetPosition() or behaviorLib.PositionSelfBackUp()
		return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, wellPos, false)
	end

end
behaviorLib.funcGoingToWell = funcGoingToWellOverride

--------------------------------------------------------------
--                    Harass Behavior                       --
-- All code how to use abilities against enemies goes here  --
--------------------------------------------------------------
local function HarassHeroExecuteOverride(botBrain)
	
	local target = behaviorLib.heroTarget
	if target == nil then
		return object.harassExecuteOld(botBrain) --Eh nothing here
	end
	
	--fetch some variables 
	local self = core.unitSelf
	local selfPosition = self:GetPosition()
	
	local cantDodge = target:IsStunned() or target:IsImmobilized() or target:IsPerplexed() or target:IsChanneling()
	local canSee = core.CanSeeUnit(botBrain, target)
	
	local targetPosition = target:GetPosition()
	local distance = Vector3.Distance2DSq(selfPosition, targetPosition)
	
	local aggroValue = behaviorLib.lastHarassUtil
	local actionTaken = false

	local targetMaxHealth = target:GetMaxHealth()
	local targetHealth = target:GetHealth()
	local targetHealthPercentage = targetHealth * 100 / targetMaxHealth -- floor(blah blah)
	
	local useQ = skills.abilQ:CanActivate()
	local useW = skills.abilW:CanActivate()
	local chain = skills.abilQ:GetRange()
	local blast = skills.abilW:GetRange()
	local LevelE = skills.abilE:GetLevel()
	local LevelW = skills.abilW:GetLevel()
	local LevelR = skills.abilE:GetLevel()
	
	
	local DamageW = 110
	if LevelW == 2 then
		DamageW = 190
	elseif LevelW == 3 then
		DamageW = 270
	elseif LevelW == 4 then
		DamageW =350
	end
	
	local DamageR = 225
	if LevelR == 2 then
		DamageR = 325
	elseif LevelR == 3 then
		DamageR = 425
	end	
	
	local DamageE = 0.04
	if LevelE == 2 then
		DamageE = 0.06
	elseif LevelE == 3 then
		DamageE = 0.08
	elseif LevelE == 4 then
		DamageE = 0.1
	end
	
	core.FindItems(botBrain)
	
	
	local extraDmg = targetHealth * DamageE
	local MagicResistance = 0.716 --1 - target:GetMagicResistance()   got nil value from target:GetMagicResistance(), replaced it with tb's starting magic armor (6.5)
	local TrueDamageW = (DamageW + extraDmg) * MagicResistance
	local TrueDamageR = (DamageR + extraDmg) * MagicResistance
	
	if aggroValue < 0 then
		aggroValue = 1
	end
	
	aggroValue = aggroValue + (1000 / targetHealthPercentage) - 1 
	
	if not actionTaken and LevelE <= 1 and targetHealthPercentage > 85 then
		if useQ then
			if distance < (chain * chain) then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilQ, target)
			end
		end
	end
	
	
	if cantDodge and canSee then
		if useW then 
			if distance < (blast * blast) then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilW, target)
			end
		end
	end
	
	-- Ks if he is in range, hava mana and no cd on W
	if not actionTaken and canSee and TrueDamageW > targetHealth then
		if useW then
			if distance < (blast * blast) then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilW, target)
			end
		end
	end
	
	--Ults when "target" is low, so not when someone accross the map is low
	-- Ks if he have mana and no cd, durp dont hate 
	if not actionTaken and canSee and TrueDamageR > targetHealth then
		if skills.abilR:CanActivate() then
			actionTaken = core.OrderAbility(botBrain, skills.abilR)  --Warning: Usage - self:OrderAbility(Abilityability, [bool queueCommand = false])
		end
	end

	
	
	
	if not actionTaken and not cantDodge then
		if canSee then
				--sheepstick
			local itemSheepstick = core.itemSheepstick
			if itemSheepstick then
				local sRange = itemSheepstick:GetRange()
				if itemSheepstick:CanActivate() and aggroValue > 40 then
					if distance < (sRange * sRange) then
						actionTaken = core.OrderItemEntityClamp(botBrain, self, itemSheepstick, target)
					end
				end
			end
		end
	end
	
	if not actionTaken and canSee then
		if aggroValue > 40 then
			if distance < (blast * blast) and useW then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilW, target)
			elseif distance < (chain * chain) and useQ then
				actionTaken = core.OrderAbilityEntity(botBrain, skills.abilQ, target)
			end
		end
	end
	
	if not actionTaken and canSee then
		if targetHealthPercentage < 50 then
			if useW then 
				if distance < (blast * blast) then
					actionTaken = core.OrderAbilityEntity(botBrain, skills.abilW, target)
				end
			end
		end
	end
	
	if not actionTaken and canSee then
		if targetHealthPercentage < 40 then
			if useQ then
				if distance < (chain * chain) then
					actionTaken = core.OrderAbilityEntity(botBrain, skills.abilQ, target)
				end
			end
		end
	end
	
	if not actionTaken and canSee then
		if object.abilQUseTime + 12500 < HoN.GetGameTime() then
			if useQ then
				if distance < (chain * chain) then
					actionTaken = core.OrderAbilityEntity(botBrain, skills.abilQ, target)
				end
			end
		end
	end
	
	
	if not actionTaken then
		return object.harassExecuteOld(botBrain)
	end

	
end
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

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
		core.OrderAbilityEntity(botBrain, skills.abilW, enemyHeroes[1])
	end

	local vecPos = behaviorLib.PositionSelfBackUp()
	core.OrderMoveToPosClamp(botBrain, core.unitSelf, vecPos, false)
end

object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatBehavior["Execute"]
behaviorLib.RetreatFromThreatBehavior["Execute"] = RetreatFromThreatExecuteOverride


-- Harras and lasthit with Chain Lightning at the same time
--[[Dont work atm, but I am working on it
--------------------------------------------------------------
--                    Farming Behavior                      --
--                 All code how to last hit                 --
--------------------------------------------------------------
--Wards last hitter, based on Kairus101's original idea.
--Creep target function.

function WardsGetCreepAttackTargetOverride(botBrain, unitEnemyCreep, unitAllyCreep) 
 
	local self = self.core.unitSelf
   unitSelf=core.unitSelf
    local bDebugEchos = false
    local unitSelf = core.unitSelf
     
    --Damage/hatchet.
    local nDamageAverage = unitSelf:GetFinalAttackDamageMin()
	self:GetAbility(0)
 
 
    --Checking to see if Enemy creep is killable.
    if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
        local nTargetHealth = unitEnemyCreep:GetHealth()-100 --The -100 is for the -100 in the "moving" section below. It returns a creep as a possible target to move too even if you're 100 away from last hit damage.
        if nDamageAverage >= nTargetHealth then
            local bActuallyLH = true
            if bDebugEchos then BotEcho("Returning an enemy") end
            return unitEnemyCreep
        end
    end
     
    return nil
end
 
 
--Overrides
object.GetCreepAttackTargetOld = behaviorLib.GetCreepAttackTarget
behaviorLib.GetCreepAttackTarget = WardsGetCreepAttackTargetOverride
 
 
--Last hit utility function. Unchanged as of now.
 function WardsAttackCreepsUtilityeOverride(botBrain)    
    local nDenyVal = 21
    local nLastHitVal = 50
 
 
    local nUtility = 0
 
 
    --We don't want to deny if we are pushing. This isn't used because of no denies.
    local unitDenyTarget = core.unitAllyCreepTarget
    if core.GetCurrentBehaviorName(botBrain) == "Push" then
        unitDenyTarget = nil
    end
     
    local unitTarget = behaviorLib.GetCreepAttackTarget(botBrain, core.unitEnemyCreepTarget, unitDenyTarget)
     
    if unitTarget and (core.unitSelf:IsAttackReady() or core.itemHatchet:CanActivate()) then --Hatchet included in targetting ability. Even if attack is down, able to target with hatchet.
        if unitTarget:GetTeam() == core.myTeam then
            nUtility = nDenyVal
        else
            nUtility = nLastHitVal
        end
        core.unitCreepTarget = unitTarget
    end
 
 
    if botBrain.bDebugUtility == true and nUtility ~= 0 then
        BotEcho(format("  AttackCreepsUtility: %g", nUtility))
    end
 
 
    return nUtility
end
--Overrides
object.AttackCreepsUtilityOld = behaviorLib.AttackCreepsBehavior["Utility"]
behaviorLib.AttackCreepsBehavior["Utility"] = WardsAttackCreepsUtilityeOverride
 
 
--Attack execute function.
function WardsAttackCreepsExecuteOverride(botBrain)
    local unitSelf = core.unitSelf
    local currentTarget = core.unitCreepTarget
  
    if currentTarget and core.CanSeeUnit(botBrain, currentTarget) then  
		local self = self.core.unitSelf
        local vecTargetPos = currentTarget:GetPosition()
        local nDistSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecTargetPos)
        local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)
          
        --Damage/hatchet. 
        local nDamageAverage = unitSelf:GetFinalAttackDamageMin()
		self.GetAbility(0)
		
  
        if currentTarget ~= nil then
            if (750 * 750) > nDistSq > nAttackRangeSq and 75 >= currentTarget:GetHealth then --Onely kill with spell if target is out of normal attack range
				core.OrderAttackEntity(botBrain, self.GetAbility(0), currentTarget)
            elseif nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() and nDamageAverage>=currentTarget:GetHealth() then --Only kill if GUARANTEED last hit.
                core.OrderAttackClamp(botBrain, unitSelf, currentTarget)
            elseif nDistSq > nAttackRangeSq and unitSelf:IsAttackReady() and nDamageAverage>=currentTarget:GetHealth()-100 then --Move, even if 100 away from last hit. Matches with earlier targetting of -100.
                local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
                core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false) --Move.
            elseif allyCreeps then --Added the "allycreeps" if so that the bot wouldn't stand amongst enemy creeps while one was out of last hit range, and just AFK.
                core.OrderHoldClamp(botBrain, unitSelf, false) --Hold. Often interuppted by other behaviors.
            end
        end
    else
        return false
    end
end
--Overrides
object.AttackCreepsExecuteOld = behaviorLib.AttackCreepsBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = WardsAttackCreepsExecuteOverride
--]]

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


-- From St0l3n_ID's amunra
local function ProcessRespawnChatOverride()
	local nCurrentTime = HoN.GetGameTime()	
	if nCurrentTime < core.nNextChatEventTime then
		return
	end	
	
	if HoN.GetMatchTime() > 0 then
		local nDelay = random(core.nChatDelayMin, core.nChatDelayMax) 
		local sMessage = nil
		
		if object.bUltWasUpLately then
			local nMessage = random(#object.respawnUltMessages) 
			sMessage = object.respawnUltMessages[nMessage]
			nDelay = 200
		else
			local nToSpamOrNotToSpam = random()
			if(nToSpamOrNotToSpam < core.nRespawnChatChance) then
				local nMessage = random(#object.respawnMessages) -- attempt to get length of field 'respawnMessages' (a nil value)
				sMessage = object.respawnMessages[nMessage]
			end
		end
		
		if sMessage then
			core.AllChatLocalizedMessage(sMessage, nil, nDelay)
		end
	else 
		core.AllChat("HF 'n GL")
	end
	
	core.nNextChatEventTime = nCurrentTime + core.nChatEventInterval
end
core.ProcessRespawnChat = ProcessRespawnChatOverride

--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_RunesOfTheBlight", "Item_RunesOfTheBlight", "Item_MinorTotem", "Item_MinorTotem", "Item_MinorTotem", "Item_MinorTotem", "Item_MarkOfTheNovice"}
behaviorLib.LaneItems  = {"Item_Marchers", "Item_Scarab", "Item_Striders", "Item_GraveLocket"}
behaviorLib.MidItems  = {"Item_SpellShards", "Item_SpellShards", "Item_SpellShards", "Item_Lightbrand", "Item_Intelligence7"}
behaviorLib.LateItems  = {"Item_Morph", "Item_GrimoireOfPower", "Item_PostHaste"}

BotEcho(object:GetName()..'finished loading thunderbringer_main.lua')