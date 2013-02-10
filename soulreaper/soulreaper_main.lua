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

object.core         = {}
object.eventsLib    = {}
object.metadata     = {}
object.behaviorLib  = {}
object.skills       = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventslib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorlib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random, sqrt
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random, _G.math.sqrt

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

local sqrtTwo = math.sqrt(2)
local gold=0

BotEcho('loading soulreaper_main...')

--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- hero_<hero>  to reference the internal hon name of a hero, Hero_Yogi ==wildsoul
object.heroName = 'Hero_HellDemon'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"3 Item_MinorTotem", "Item_MarkOfTheNovice", "Item_RunesOfTheBlight", "Item_GuardianRing"}
behaviorLib.LaneItems  = {"Item_ManaRegen3", "Item_Marchers", "Item_Intelligence5", "Item_Replenish"}
behaviorLib.MidItems  = {"Item_Steamboots", "Item_HealthMana2", "Item_Morph "}
behaviorLib.LateItems  = {"Item_FrostfieldPlate", "Item_BehemothsHeart", "Item_BarrierIdol"}


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
    core.VerboseLog("SkillBuild()")

    local unitSelf = self.core.unitSelf
    if  skills.abilJudgement == nil then
        skills.abilJudgement = unitSelf:GetAbility(0)
        skills.abilWitheringPresence = unitSelf:GetAbility(1)
        skills.abilInhumanNature = unitSelf:GetAbility(2)
        skills.abilDemonicExecution = unitSelf:GetAbility(3)
        skills.abilAttributeBoost = unitSelf:GetAbility(4)
    end
    if unitSelf:GetAbilityPointsAvailable() <= 0 then
        return
    end
    
    
    -- automatically levels stats in the end
    -- stats have to be leveld manually if needed inbetween
    tSkills ={
                0, 2, 0, 2, 0,
                3, 0, 2, 2, 1, 
                3, 1, 1, 1, 4,
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


local nHiding=false;
------------------------------------------------------
--            onthink override                      --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
    self:onthinkOld(tGameVariables)

    --BotEcho("thinking");
    --core.nHarassBonus=1000
    
    
    
    if (nHiding) then
        --run to jokespot and teleport
    end
end
object.onthinkOld = object.onthink
object.onthink  = object.onthinkOverride


-- These are bonus agression points if a skill/item is available for use
object.nHealUp = 5
object.nExecute1Up = 10 
object.nExecute2Up = 15 
object.nExecute3Up = 20
object.nSheepUp = 18
object.nFrostfieldUp = 12
object.nBarrierUp = 16
 
-- These are bonus agression points that are applied to the bot upon successfully using a skill/item
object.nHealUse = 5
object.nExecute1Use = 20
object.nExecute2Use = 30
object.nExecute3Use = 40
object.nSheepUse = 18
object.nFrostfieldUse = 10
object.nBarrierUse = 22
 
--These are thresholds of aggression the bot must reach to use these abilities
object.nHealThreshold = 12
object.nExecute1Threshold = 30
object.nExecute2Threshold = 25
object.nExecute3Threshold = 20
object.nSheepThreshold = 20
object.nFrostfieldThreshold = 12
object.nBarrierThreshold = 25


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
        if EventData.InflictorName == "Ability_HellDemon1" then
            nAddBonus = nAddBonus + object.nHealUse
        elseif EventData.InflictorName == "Ability_HellDemon4" then
            local nExecuteUseBonus = object.nExecute1Use
            if skills.abilDemonicExecution:GetLevel() == 2 then
                nExecuteUseBonus = object.nExecute2Use
            elseif skills.abilDemonicExecution:GetLevel() == 3 then
                nExecuteUseBonus = object.nExecute3Use
            end
            nAddBonus = nAddBonus + nExecuteUseBonus
        end
    elseif EventData.Type == "Item" then
        if core.itemSheepstick ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemSheepstick:GetName() then
            nAddBonus = nAddBonus + self.nSheepUse
        end
        if core.itemFrostfieldPlate ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemFrostfieldPlate:GetName() then
            nAddBonus = nAddBonus + self.nFrostfieldUse
        end
        if core.itemBarrierIdol ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemBarrierIdol:GetName() then
            nAddBonus = nAddBonus + self.nBarrierUse
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



local function funcFindItemsOverride(botBrain)
    local bUpdated = object.FindItemsOld(botBrain)

    if core.itemRoT ~= nil and not core.itemRoT:IsValid() then
        core.itemRoT = nil
    end
    if core.itemManaRing ~= nil and not core.itemManaRing:IsValid() then
        core.itemManaRing = nil
    end
    if core.itemSheepstick ~= nil and not core.itemSheepstick:IsValid() then
        core.itemSheepstick = nil
    end
    if core.itemFrostfieldPlate ~= nil and not core.itemFrostfieldPlate:IsValid() then
        core.itemFrostfieldPlate = nil
    end
    if core.itemBarrierIdol ~= nil and not core.itemBarrierIdol:IsValid() then
        core.itemBarrierIdol = nil
    end

    if bUpdated then
        if core.itemRoT and core.itemManaRing and core.itemSheepstick and core.itemFrostfieldPlate and core.itemBarrierIdol then
            return
        end

        local inventory = core.unitSelf:GetInventory(true)
        for slot = 1, 12, 1 do
            local curItem = inventory[slot]
            if curItem then
                if core.itemRoT == nil and curItem:GetName() == "Item_ManaRegen3" then
                    core.itemRoT = core.WrapInTable(curItem)
                end
                if core.itemManaRing == nil and curItem:GetName() == "Item_Replenish" then
                    core.itemManaRing = core.WrapInTable(curItem)
                end
                if core.itemSheepstick == nil and curItem:GetName() == "Item_Morph" then
                    core.itemSheepstick = core.WrapInTable(curItem)
                end
                if core.itemFrostfieldPlate == nil and curItem:GetName() == "Item_FrostfieldPlate" then
                    core.itemFrostfieldPlate = core.WrapInTable(curItem)
                end
                if core.itemBarrierIdol == nil and curItem:GetName() == "Item_BarrierIdol" then
                    core.itemBarrierIdol = core.WrapInTable(curItem)
                end
            end
        end
    end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function CustomHarassUtilityOverride(hero) --how much to harrass, doesn't change combo order or anything
    local nUtil = 0 --midly aggressive
    
    --BotEcho("Rethinking hass")
    
    local unitSelf = core.unitSelf
    
    if skills.abilJudgement:CanActivate() then
        nUnil = nUtil + object.nHealUp
    end
 
    if skills.abilDemonicExecution:CanActivate() then
        local nExecuteUpBonus = object.nExecute1Up
        if skills.abilDemonicExecution:GetLevel() == 2 then
            nExecuteUseBonus = object.nExecute2Up
        elseif skills.abilDemonicExecution:GetLevel() == 3 then
            nExecuteUseBonus = object.nExecute3Up
        end
        nUtil = nUtil + nExecuteUpBonus
    end
    
    if object.itemSheepstick and object.itemSheepstick:CanActivate() then
        nUtil = nUtil + object.nSheepUp
    end
    
    if object.itemFrostfieldPlate and object.itemFrostfieldPlate:CanActivate() then
        nUtil = nUtil + object.nFrostfieldUp
    end
    
    if object.itemBarrierIdol and object.itemBarrierIdol:CanActivate() then
        nUtil = nUtil + object.nBarrierUp
    end
    
    --BotEcho("health:" .. hero:GetHealth());
    --local potentialDamage = (skills.abilJudgement:GetLevel()*60+40+skills.abilW:GetLevel()*75)/hero:GetMagicResistance()+unitSelf:GetFinalAttackDamageMin()*2/hero:GetPhysicalResistance()
    --BotEcho("potential damage:" .. potentialDamage );
    
    --calculate whether a kill is possible and probable.
    --[[if (unitSelf:GetMana()>240 and skills.abilJudgement:CanActivate() and skills.abilW:CanActivate() and hero:GetHealth()< potentialDamage ) then
        nUtil=100
    end]]--Old pebbs bot code
    -- if hero hp is low, combo up and in range, perhaps if someone is nearby and ping?(?)  
    return nUtil -- no desire to attack AT ALL if 0.
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityOverride  

--[[
    Assumes 1 cast of Judgement and 1 (or more) auto attacks can be hit after
    Demonic Execution is cast.

    bExecutionFirst = true means that the bot thinks it can't get a cast of
    Judgement to hit before casting Demonic Execution
]]--
local function GetPotentialDamage(unitTarget, bExecutionFirst)
    BotEcho("Calculating potential damage")

    bExecutionFirst = bExecutionFirst or true
    local unitSelf = core.unitSelf
    
    --Position and range information
    local vecMyPosition = unitSelf:GetPosition()
    local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
    nAttackRangeSq = nAttackRangeSq * nAttackRangeSq
    
    local vecTargetPosition = unitTarget:GetPosition()
    local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)

    local nCurMana = unitSelf:GetMana()

    --Skills
    local abilJudgement = skills.abilJudgement
    local abilDemonicExecution = skills.abilDemonicExecution

    if not abilJudgement then BotEcho("Can't find abilJudgement") end
    if not abilDemonicExecution then BotEcho("Can't find abilDemonicExecution") end

    --Get skill ranges
    local nExecutionRangeSq = abilDemonicExecution:GetRange()
    nExecutionRangeSq = nExecutionRangeSq * nExecutionRangeSq
    local nJudgementRangeSq = abilJudgement:GetTargetRadius()
    nJudgementRangeSq = nJudgementRangeSq * nJudgementRangeSq

    --Determine what the Demonic Execution damage multiplier is
    local nExecuteLevelDamageMultiplier = 0.4
    if abilDemonicExecution:GetLevel() == 2 then
        nExecuteLevelDamageMultiplier = 0.6
    elseif abilDemonicExecution:GetLevel() == 3 then
        nExecuteLevelDamageMultiplier = 0.9
    end

    local nTargetMagicResistance = unitTarget:GetMagicResistance()
    local nTargetPhysResistance = unitTarget:GetPhysicalResistance()
    local nAttackDamage = unitSelf:GetFinalAttackDamageMin() * nTargetPhysResistance
    local nTargetMissingHealth = unitTarget:GetMaxHealth() - unitTarget:GetHealth()
    local nPotentialDamage = 0
    local nPotentialAttacks = 1

    if not bExecutionFirst and abilJudgement:CanActivate() and nTargetDistanceSq < nJudgementRangeSq and nCurMana > abilJudgement:GetManaCost() then
        --If we aren't opening with Execution, assume we can cast a heal and apply an auto attack
        local nJudgementDamage = abilJudgement:GetLevel() * 70 * (1 - nTargetMagicResistance)
        nPotentialDamage = nPotentialDamage + nJudgementDamage + nAttackDamage

        --Adjust the targets missing health for the damage we just did
        nTargetMissingHealth = nTargetMissingHealth + nJudgementDamage + nAttackDamage

        --Adjust for mana just used
        nCurMana = nCurMana - abilJudgement:GetManaCost()
    end

    if abilDemonicExecution:CanActivate() and nTargetDistanceSq < nExecutionRangeSq and nCurMana > abilDemonicExecution:GetManaCost() then
        --Calculate the amount of damage that can be dealt by casting Demonic Execution
        nPotentialDamage = (1 - nTargetMagicResistance) * nExecuteLevelDamageMultiplier * nTargetMissingHealth
        BotEcho("Missing health: " .. nTargetMissingHealth)
        BotEcho("Damage from ult: " .. nPotentialDamage)

        --Adjust for mana just used
        nCurMana = nCurMana - abilDemonicExecution:GetManaCost()
    end

    --[[
        Take an estimate at how many auto attacks we can get in once we cast
        Demonic Execution and the target gets stunned for 1.5s
    ]]--
    if nAttackRangeSq > nTargetDistanceSq  * 0.25 then
        nPotentialAttacks = nPotentialAttacks + 4
    elseif nAttackRangeSq > nTargetDistanceSq * 0.50 then
        nPotentialAttacks = nPotentialAttacks + 3
    elseif nAttackRangeSq > nTargetDistanceSq * 0.75 then
        nPotentialAttacks = nPotentialAttacks + 2
    elseif nAttackRangeSq > nTargetDistanceSq then
        nPotentialAttacks = nPotentialAttacks + 1
    end

    nPotentialDamage = nPotentialDamage + nPotentialAttacks * nAttackDamage
    BotEcho("Damage from attacks: " .. nPotentialAttacks * nAttackDamage)    

    local nDistanceWalkingSq = unitSelf:GetMoveSpeed()
    nDistanceWalkingSq = nDistanceWalkingSq * nDistanceWalkingSq
    --Put in another heal if we can walk in range in 1 second just for good measure
    if abilJudgement:CanActivate() and nTargetDistanceSq - nDistanceWalkingSq < nJudgementRangeSq and nCurMana > abilJudgement:GetManaCost() then
        nPotentialDamage = nPotentialDamage + abilJudgement:GetLevel() * 70 * (1 - nTargetMagicResistance)
        BotEcho("Damage from heal: " .. abilJudgement:GetLevel() * 70 * (1 - nTargetMagicResistance))  
    end

    return nPotentialDamage
end

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
    --local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
    
    local nLastHarassUtility = behaviorLib.lastHarassUtil
    --local bCanSee = core.CanSeeUnit(botBrain, unitTarget) 
    
    local abilJudgement = skills.abilJudgement
    local abilDemonicExecution = skills.abilDemonicExecution
    
    if bDebugEchos then BotEcho("SoulReaper HarassHero at "..nLastHarassUtility) end
    local bActionTaken = false

    --since we are using an old pointer, ensure we can still see the target for entity targeting
    if core.CanSeeUnit(botBrain, unitTarget) then
        local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized()
    
        --Sheepstick
        if not bTargetVuln then 
            core.FindItems()
            local itemSheepstick = core.itemSheepstick
            if itemSheepstick then
                local nRange = itemSheepstick:GetRange()
                if itemSheepstick:CanActivate() and nLastHarassUtility > botBrain.nSheepThreshold then
                    if nTargetDistanceSq < (nRange * nRange) then
                        if bDebugEchos then BotEcho("Using sheepstick") end
                        bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemSheepstick, unitTarget)
                    end
                end
            end
        end
    
        --Frostfield
        if not bTargetVuln then 
            core.FindItems()
            local itemFrostfieldPlate = core.itemFrostfieldPlate
            if itemFrostfieldPlate then
                local nRange = itemFrostfieldPlate:GetTargetRadius()
                if itemFrostfieldPlate:CanActivate() and nLastHarassUtility > botBrain.nFrostfieldThreshold then
                    if nTargetDistanceSq < (nRange * nRange) * 0.9 then
                        if bDebugEchos then BotEcho("Using frostfield") end
                        bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemFrostfieldPlate)
                    end
                end
            end
        end

        --Demonic Execution
        local nExecuteLevelThreshold = botBrain.nExecute1Threshold
        local nExecuteLevelDamageMultiplier = 0.4
        if abilDemonicExecution:GetLevel() == 2 then
            nExecuteLevelThreshold = botBrain.nExecute2Threshold
            nExecuteLevelDamageMultiplier = 0.6
        elseif abilDemonicExecution:GetLevel() == 3 then
            nExecuteLevelThreshold = botBrain.nExecute3Threshold
            nExecuteLevelDamageMultiplier = 0.9
        end
        if nLastHarassUtility > nExecuteLevelThreshold then
            if bDebugEchos then BotEcho("  No action yet, checking demonic execution - current threshold is " .. nExecuteLevelThreshold) end

            --Only do calcs if in range
            local nRange = abilDemonicExecution:GetRange()
            if nTargetDistanceSq < (nRange * nRange) then
                local nPotentialDamage = GetPotentialDamage(unitTarget, true)
                if bDebugEchos then 
                    BotEcho("Potential damage: " .. nPotentialDamage)
                    BotEcho("Target Health: " .. unitTarget:GetHealth())
                end

                if abilDemonicExecution:CanActivate() and unitTarget:GetHealth() < nPotentialDamage then
                    if bDebugEchos then BotEcho("Using demonic execution") end
                    bActionTaken = core.OrderAbilityEntity(botBrain, abilDemonicExecution, unitTarget)
                end
            end
        end
    end
    
    --Judgement
    local nJudgementDamage = 0
    if unitTarget and unitTarget:GetMagicResistance() then
        nJudgementDamage = abilJudgement:GetLevel() * 70 * (1 - unitTarget:GetMagicResistance())
    end 
    if nLastHarassUtility > botBrain.nHealThreshold or nJudgementDamage > unitTarget:GetHealth() then
        --if bDebugEchos then BotEcho("  No action yet, checking judgement") end
        if abilJudgement:CanActivate() then
            local nRange = abilJudgement:GetTargetRadius()
            nRange = nRange * 0.8
            if nTargetDistanceSq < (nRange * nRange) then
                if bDebugEchos then BotEcho("Using judgement") end
                bActionTaken = core.OrderAbility(botBrain, abilJudgement)
            end
        end
    end
    
    if not bActionTaken then
        --if bDebugEchos then BotEcho("  No action yet, proceeding with normal harass execute.") end
        return object.harassExecuteOld(botBrain)
    end
end
-- overload the behaviour stock function with custom 
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

--TODO: extract this out to behaviorLib
----------------------------------
--  Soul Reaper's Help behavior
--  
--  Utility: 
--  Execute: Use Astrolabe
----------------------------------
behaviorLib.nHealUtilityMul = 0.8
behaviorLib.nHealHealthUtilityMul = 1.0
behaviorLib.nHealTimeToLiveUtilityMul = 0.5

function behaviorLib.HealHealthUtilityFn(unitHero)
    local nUtility = 0
    
    local nYIntercept = 100
    local nXIntercept = 100
    local nOrder = 2

    nUtility = core.ExpDecay(unitHero:GetHealthPercent() * 100, nYIntercept, nXIntercept, nOrder)
    
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
    
    local nCost =       ability:GetManaCost()
    local nCooldownMS = ability:GetCooldownTime()
    local nRegen =      unitSelf:GetManaRegen()
    
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
    local bDebugEchos = true
    
    --[[
    if object.myName == "Bot1" then
        bDebugEchos = true
    end
    --]]
    --if bDebugEchos then BotEcho("HealUtility") end
    
    local nUtility = 0

    local unitSelf = core.unitSelf
    behaviorLib.unitHealTarget = nil
    
    local abilJudgement = skills.abilJudgement
    
    local nHighestUtility = 0
    local unitTarget = nil
    local nTargetTimeToLive = nil
    local sAbilName = ""
    if abilJudgement and abilJudgement:CanActivate() then
        local tTargets = core.CopyTable(core.localUnits["AllyHeroes"])
        tTargets[unitSelf:GetUniqueID()] = unitSelf --I am also a target
        for key, hero in pairs(tTargets) do
            --Don't heal ourself if we are going to head back to the well anyway, 
            --  as it could cause us to retrace half a walkback
            if bDebugEchos and core.GetCurrentBehaviorName(botBrain) == "HealAtWell" then BotEcho ("Current health %: "..unitSelf:GetHealthPercent()) end
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
                    --if bDebugEchos then BotEcho(format("%s Heal util: %d  health: %d  ttl:%d", hero:GetTypeName(), nCurrentUtility, nHealthUtility, nTimeToLiveUtility)) end
                end
            end
        end

        if unitTarget then
            nUtility = nHighestUtility              
            sAbilName = "Judgement"
        
            behaviorLib.unitHealTarget = unitTarget
            behaviorLib.nHealTimeToLive = nTargetTimeToLive
        end     
    end
    
    --if bDebugEchos then BotEcho(format("    abil: %s util: %d", sAbilName, nUtility)) end
    
    nUtility = nUtility * behaviorLib.nHealUtilityMul
    
    if botBrain.bDebugUtility == true and nUtility ~= 0 then
        BotEcho(format("  HelpUtility: %g", nUtility))
    end
    
    return nUtility
end

function behaviorLib.HealExecute(botBrain)
    local abilJudgement = skills.abilJudgement

    if not abilJudgement then BotEcho("Can't find abilJudgement") end
    
    local unitHealTarget = behaviorLib.unitHealTarget
    local nHealTimeToLive = behaviorLib.nHealTimeToLive
    
    if unitHealTarget and abilJudgement and abilJudgement:CanActivate() then 
        local unitSelf = core.unitSelf
        local vecTargetPosition = unitHealTarget:GetPosition()
        local nDistance = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPosition)
        if nDistance < abilJudgement:GetTargetRadius() then
            core.OrderAbility(botBrain, abilJudgement)
        else
            core.OrderMoveToUnitClamp(botBrain, unitSelf, unitHealTarget)
        end
    else
        return false
    end
    
    return true
end

behaviorLib.HealBehavior = {}
behaviorLib.HealBehavior["Utility"] = behaviorLib.HealUtility
behaviorLib.HealBehavior["Execute"] = behaviorLib.HealExecute
behaviorLib.HealBehavior["Name"] = "Heal"
tinsert(behaviorLib.tBehaviors, behaviorLib.HealBehavior)

function GetClosestEnemyHero(botBrain)
    local unitClosestHero = nil
    local nClosestHeroDistSq = 99999*99999
    --core.printGetTypeNameTable(HoN.GetHeroes(core.enemyTeam))
    for id, unitHero in pairs(HoN.GetHeroes(core.enemyTeam)) do
        if unitHero ~= nil then
            if core.CanSeeUnit(botBrain, unitHero) then
        
                local nDistanceSq = Vector3.Distance2DSq(unitHero:GetPosition(), core.unitSelf:GetPosition())
                if nDistanceSq < nClosestHeroDistSq then
                    nClosestHeroDistSq = nDistanceSq
                    unitClosestHero = unitHero
                end
            end
        end
    end
    
    return unitClosestHero
end

function IsTowerThreateningUnit(unit)
    vecPosition = unit:GetPosition()
    --TODO: switch to just iterate through the enemy towers instead of calling GetUnitsInRadius
    
    local nTowerRange = 821.6 --700 + (86 * sqrtTwo)
    nTowerRange = nTowerRange
    local tBuildings = HoN.GetUnitsInRadius(vecPosition, nTowerRange, core.UNIT_MASK_ALIVE + core.UNIT_MASK_BUILDING)
    for key, unitBuilding in pairs(tBuildings) do
        if unitBuilding:IsTower() and unitBuilding:GetCanAttack() and (unitBuilding:GetTeam()==unit:GetTeam())==false then
            return true
        end
    end
    
    return false
end

function behaviorLib.GetCreepAttackTarget(botBrain, unitEnemyCreep, unitAllyCreep) --called pretty much constantly
    local unitSelf = core.unitSelf
    if gold>5600 then
        --BotEcho("Returning to well!")
        local wellPos = core.allyWell and core.allyWell:GetPosition() or behaviorLib.PositionSelfBackUp()
        core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, wellPos, false)
    end
    -- random stuff that should be called each frame!
    target = GetClosestEnemyHero(botBrain)
    --BotEcho(target:GetDisplayName())
    if (target==nil) then --cant use target != nill, weird
        --BotEcho("what")
        core.nHarassBonus=0
    else
        --                                               60
        --[[local potentialDamage = (skills.abilJudgement:GetLevel()*90+40+skills.abilW:GetLevel()*75)*(1-target:GetMagicResistance())+unitSelf:GetFinalAttackDamageMin()*3*(1-target:GetPhysicalResistance())
        --BotEcho("Looking at " .. target:GetHealth())
        if core.CanSeeUnit(botBrain, target) then
            --BotEcho("Looking at " .. potentialDamage .. " " .. target:GetHealth() .. " " .. target:GetMagicResistance())
            if target:HasState("State_HealthPotion") or IsTowerThreateningUnit(target) or (potentialDamage>target:GetHealth() and target:GetHealth()>0) then
                core.nHarassBonus=1000
                --BotEcho("Healing, in tower range or killable...... ATTACK!")
            else
                core.nHarassBonus=0
            end
        else
            core.nHarassBonus=0
        end]]
        core.nHarassBonus = 0
    end


    local bDebugEchos = false
    -- no predictive last hitting, just wait and react when they have 1 hit left
    -- prefers LH over deny

    local unitSelf = core.unitSelf
    local nDamageAverage = unitSelf:GetFinalAttackDamageMin()
    --BotEcho(nDamageAverage)
    gold=botBrain:GetGold()
    
    core.FindItems(botBrain)

    --[[ [Difficulty: Easy] Make bots worse at last hitting
    if core.nDifficulty == core.nEASY_DIFFICULTY then
        nDamageAverage = nDamageAverage + 120
    end
    ]]

    local nProjectileSpeed = unitSelf:GetAttackProjectileSpeed()

    if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
        local nTargetHealth = unitEnemyCreep:GetHealth()
        local tNearbyAllyCreeps = core.localUnits['AllyCreeps']
        local nExpectedCreepDamage = 0

        local vecTargetPos = unitEnemyCreep:GetPosition()
        local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
        if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end 

        --if bDebugEchos then BotEcho("Enemy creep is " .. tostring(unitEnemyCreep)) end
        
        --Determine the damage expcted on the creep by other creeps
        for i, unitCreep in pairs(tNearbyAllyCreeps) do
            if bDebugEchos and unitCreep then 
                --BotEcho ("Ally creep is attacking " .. tostring(unitCreep:GetAttackTarget()))
                --BotEcho (" for damage of " .. unitCreep:GetFinalAttackDamageMin())
                --BotEcho ("Attack is ready: " .. tostring(unitCreep:IsAttackReady()))
            end    
            if unitCreep:GetAttackTarget() == unitEnemyCreep and unitCreep:IsAttackReady() then
                
                local nCreepAttacks = unitCreep:GetAttackSpeed() / nProjectileTravelTime
                nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
            end
        end
        
        if bDebugEchos then BotEcho ("Excpecting ally creeps to damage enemy creep for " .. nExpectedCreepDamage .. " - using this to anticipate lasthit time") end
        
        if nDamageAverage >= (nTargetHealth - nExpectedCreepDamage) then
            local bActuallyLH = true
            
            -- [Tutorial] Make DS not mess with your last hitting before shit gets real
            if core.bIsTutorial and core.bTutorialBehaviorReset == false and core.unitSelf:GetTypeName() == "Hero_Shaman" then
                bActuallyLH = false
            end
            
            if bActuallyLH then
                if bDebugEchos then BotEcho("Returning an enemy") end
                return unitEnemyCreep
            end
        end
    end

    if unitAllyCreep then
        local nTargetHealth = unitAllyCreep:GetHealth()
        local tNearbyEnemyCreeps = core.localUnits['EnemyCreeps']
        local nExpectedCreepDamage = 0

        local vecTargetPos = unitAllyCreep:GetPosition()
        local nProjectileTravelTime = Vector3.Distance2D(unitSelf:GetPosition(), vecTargetPos) / nProjectileSpeed
        if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end 

        --if bDebugEchos then BotEcho("Ally creep is " .. tostring(unitAllyCreep)) end
        
        --Determine the damage expcted on the creep by other creeps
        for i, unitCreep in pairs(tNearbyEnemyCreeps) do
            if bDebugEchos and unitCreep then 
                --BotEcho ("Enemy creep is attacking " .. tostring(unitCreep:GetAttackTarget()))
                --BotEcho (" for damage of " .. unitCreep:GetFinalAttackDamageMin())
                --BotEcho ("Attack is ready: " .. tostring(unitCreep:IsAttackReady()))
            end    
            if unitCreep:GetAttackTarget() == unitAllyCreep and unitCreep:IsAttackReady() then
                local nCreepAttacks = unitCreep:GetAttackSpeed() / nProjectileTravelTime
                nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
            end
        end
        
        if bDebugEchos then BotEcho ("Excpecting enemy creeps to damage ally creep for " .. nExpectedCreepDamage .. " - using this to anticipate deny time") end
        
        if nDamageAverage >= (nTargetHealth - nExpectedCreepDamage) then
            local bActuallyDeny = true
            
            --[Difficulty: Easy] Don't deny
            if core.nDifficulty == core.nEASY_DIFFICULTY then
                bActuallyDeny = false
            end         
            
            -- [Tutorial] Hellbourne *will* deny creeps after shit gets real
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

function AttackCreepsExecuteOverride(botBrain)
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
            elseif (nDistSq > nAttackRangeSq * 0.6) then 
                --SR is a ranged hero - get somewhat closer to creep to slow down projectile travel time
                --BotEcho("MOVIN OUT")
                local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
                core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false)
            else
                core.OrderHoldClamp(botBrain, unitSelf, false)
            end
        end
    else
        return false
    end
end
object.AttackCreepsExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteOverride

-- A fixed list seems to be better then to check on each cycle if its  exist
-- so we create it here
local tRelativeMovements = {}
local function createRelativeMovementTable(key)
    --BotEcho('Created a relative movement table for: '..key)
    tRelativeMovements[key] = {
        vLastPos = Vector3.Create(),
        vRelMov = Vector3.Create(),
        timestamp = 0
    }
--  BotEcho('Created a relative movement table for: '..tRelativeMovements[key].timestamp)
end
--createRelativeMovementTable("SoulReaperJudgement") -- for harrass judgement
createRelativeMovementTable("CreepPush") -- for creep-groups while pushing (judgement)

-- tracks movement for targets based on a list, so its reusable
-- key is the identifier for different uses (fe. RaMeteor for his path of destruction)
-- vTargetPos should be passed the targets position of the moment
-- to use this for prediction add the vector to a units position and multiply it
-- the function checks for 100ms cycles so one second should be multiplied by 20
local function relativeMovement(sKey, vTargetPos)
    local debugEchoes = false
    
    local gameTime = HoN.GetGameTime()
    local key = sKey
    local vLastPos = tRelativeMovements[key].vLastPos
    local nTS = tRelativeMovements[key].timestamp
    local timeDiff = gameTime - nTS 
    
    if debugEchoes then
        BotEcho('Updating relative movement for key: '..key)
        BotEcho('Relative Movement position: '..vTargetPos.x..' | '..vTargetPos.y..' at timestamp: '..nTS)
        BotEcho('Relative lastPosition is this: '..vLastPos.x)
    end
    
    if timeDiff >= 90 and timeDiff <= 140 then -- 100 should be enough (every second cycle)
        local relativeMov = vTargetPos-vLastPos
        
        if vTargetPos.LengthSq > vLastPos.LengthSq
        then relativeMov =  relativeMov*-1 end
        
        tRelativeMovements[key].vRelMov = relativeMov
        tRelativeMovements[key].vLastPos = vTargetPos
        tRelativeMovements[key].timestamp = gameTime
        
        
        if debugEchoes then
            BotEcho('Relative movement -- x: '..relativeMov.x..' y: '..relativeMov.y)
            BotEcho('^r---------------Return new-'..tRelativeMovements[key].vRelMov.x)
        end
        
        return relativeMov
    elseif timeDiff >= 150 then
        tRelativeMovements[key].vRelMov =  Vector3.Create(0,0)
        tRelativeMovements[key].vLastPos = vTargetPos
        tRelativeMovements[key].timestamp = gameTime
    end
    
    if debugEchoes then BotEcho('^g---------------Return old-'..tRelativeMovements[key].vRelMov.x) end
    return tRelativeMovements[key].vRelMov
end

-- attention:
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

-- This function allowes soul reaper to use his ability while pushing
-- Has prediction, however it might need some repositioning so he is in correct range more often
local function abilityPush(botBrain, unitSelf)
    local debugAbilityPush = true
    local myPos = unitSelf:GetPosition()
    local tNearbyEnemyCreeps = core.localUnits["EnemyCreeps"]
    local tNearbyEnemyTowers = core.localUnits["EnemyTowers"]
    local vCreepCenter = groupCenter(tNearbyEnemyCreeps, 3) -- the 3 basicly wont allow abilities under 3 creeps
    
    if vCreepCenter == nil then 
        return false
    end
    
    local vMovePrediction = vCreepCenter + relativeMovement("CreepPush", vCreepCenter)*10
    
    --[[if debugAbilityPush  then -- to compare prediction vs normal center 
        core.DrawDebugArrow(myPos, vMovePrediction "purple")        
        core.DrawDebugArrow(myPos, vCreepCenter, "white")
        end]]
    

    local abilJudgement = skills.abilJudgement
    local nJudgementRangeSq = abilJudgement:GetTargetRadius()
    nJudgementRangeSq = nJudgementRangeSq * nJudgementRangeSq
    local nDistanceMiddleSq = Vector3.Distance2DSq(myPos,vMovePrediction)

    local nLowHealthCreepsInRange = 0
    local nCreepsInRange = 0
    for i, unitCreep in pairs(tNearbyEnemyCreeps) do
        nTargetDistanceSq = Vector3.Distance2DSq(myPos, unitCreep:GetPosition())
        if nTargetDistanceSq < nJudgementRangeSq then
            nCreepsInRange = nCreepsInRange + 1
            if unitCreep:GetHealth() < abilJudgement:GetLevel() * 70 then
                nLowHealthCreepsInRange = nLowHealthCreepsInRange + 1
            end
        end
    end
    
    if  abilJudgement:CanActivate() and unitSelf:GetMana() > abilJudgement:GetManaCost() * 2 then 
        
        local bNearTower = false
        for i, unitTower in pairs(tNearbyEnemyTowers) do
            if unitTower then
                bNearTower = true
            end
        end
        local bShouldCast = nLowHealthCreepsInRange > 1 or (nCreepsInRange > 3 and bNearTower)

        if debugAbilityPush then BotEcho("Should cast: " .. tostring(bShouldCast)) end
        if nDistanceMiddleSq < nJudgementRangeSq and bShouldCast then --range check for judgement push
            return core.OrderAbility(botBrain, abilJudgement)
        end
    end
    
    return false
end


function object.CreepPush(botBrain)
    VerboseLog("PushExecute("..tostring(botBrain)..")")
    local debugPushLines = false
    if debugPushLines then BotEcho('^yGotta execute em *greedy*') end
    
    local bSuccess = false
        
    local unitSelf = core.unitSelf
    if unitSelf:IsChanneling() then 
        return
    end

    local unitTarget = core.unitEnemyCreepTarget
    if unitTarget then
        bSuccess = abilityPush(botBrain, unitSelf)
        if debugPushLines then 
            BotEcho('^p-----------------------------Got em')
            if bSuccess then BotEcho('Gotemhard') else BotEcho('at least i tried') end
        end
    end
    
    return bSuccess
end

-- both functions below call for the creep push, however 
function object.PushExecuteOverride(botBrain)
    if not object.CreepPush(botBrain) then 
        object.PushExecuteOld(botBrain)
    end
end
object.PushExecuteOld = behaviorLib.PushBehavior["Execute"]
behaviorLib.PushBehavior["Execute"] = object.PushExecuteOverride


local function TeamGroupBehaviorOverride(botBrain)
    object.TeamGroupBehaviorOld(botBrain)
    object.CreepPush(botBrain)
end
object.TeamGroupBehaviorOld = behaviorLib.TeamGroupBehavior["Execute"]
behaviorLib.TeamGroupBehavior["Execute"] = TeamGroupBehaviorOverride

BotEcho('finished loading soulreaper_main')