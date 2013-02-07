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
-- Skelbot v0.0000006
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

BotEcho(object:GetName()..' Monkey King Gokuu Starting Up...')




--####################################################################
--####################################################################
--#                                                                 ##
--#                  bot constant definitions                       ##
--#                                                                 ##
--####################################################################
--####################################################################

-- Hero_<hero>  to reference the internal HoN name of a hero, Hero_Yogi ==Wildsoul
object.heroName = 'Hero_MonkeyKing'


--   Item Buy order. Internal names  
behaviorLib.StartingItems  = { "Item_RunesOfTheBlight", "Item_IronBuckler", "Item_LoggersHatchet"}
behaviorLib.LaneItems  = {"Item_Marchers","Item_ManaBattery"}
behaviorLib.MidItems  = {"Item_EnhancedMarchers","Item_PowerSupply","Item_Regen","Item_Stealth"}
behaviorLib.LateItems  = {"Item_Protect","Item_ManaBurn2","Item_Freeze","Item_Sasuke","Item_DaemonicBreastplate"}


-- Skillbuild table, 0=Q, 1=W, 2=E, 3=R, 4=Attri
object.tSkills = {
    0, 1, 2, 1, 1,
    3, 1, 2, 2, 2, 
    3, 0, 0, 0, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

--melee weight overrides
behaviorLib.nCreepPushbackMul = 0.5
behaviorLib.nTargetPositioningMul = 0.6

-- bonus agression points if a skill/item is available for use

object.nIllusiveUp = 20
object.nVaultUp = 30 
object.nSlamUp = 20
object.nStealthUp = 20
object.nIllusionUp = 20

-- bonus agression points that are applied to the bot upon successfully using a skill/item

object.nIllusiveUse = 25
object.nVaultUse = 30 
object.nSlamUse = 25
object.nStealthUse = 20
object.nIllusionUse = 20

--thresholds of aggression the bot must reach to use these abilities

object.nIllusiveThreshold = 60
object.nVaultThreshold = 20 
object.nVault2Threshold = 80 
object.nSlamThreshold = 100
object.nStealthThreshold = 30
object.nIllusionThreshold = 30
object.nTauntThreshold = 50

--retreat thresholds

object.nretreatStealthThreshold = 60


--####################################################################
--####################################################################
--#                                                                 ##
--#                  Kill Chat Override                    ##
--#                                                                 ##
--####################################################################
--####################################################################

object.killMessages = {}
object.killMessages.General = {
	"Didn't even break a sweat!","KA-ME-HA-ME-HA!!!","Wake me up when you're done monkeying around"
	}
object.killMessages.Hero_Accursed = {
	"Such a dull blade won't kill me", "You're just falling apart!"
	}
object.killMessages.Hero_Arachna = {
	"Ewww, I think I stepped on a bug", "That's one pest out of my hair"
	}
object.killMessages.Hero_Chronos = {
	"Bet you didn't see that coming!", "Not even time can stop me!"
	}
object.killMessages.Hero_Defiler = {
	"Ugh, get your slimy hands off me", "From what rock did you crawl out under from?"
	}
object.killMessages.Hero_Engineer = {
	"What the hell are you mumbling about!?", "What a waste of a good drink", "Your turret's your best friend? Forever alone much?", "Get a life basement dweller!"
	}
object.killMessages.Hero_Kunas = {
	"Monkey beats ape anytime!", "Here, have a banana!", "You ain't no King Kong", "Too busy eating lice off your back?"
	}
object.killMessages.Hero_Shaman = {
	"Wow you really must be demented to suck that much", "Keep the mask on, no one wants to see your ugly mug"
	}
object.killMessages.Hero_MonkeyKing = { 
	"I won't lose to my own clone!", "The original is always the best!", "There is only one true Monkey King!" 
	}
object.killMessages.Hero_Frosty = {
	"You don't tell me to chill!", "Let's break the ice shall we?", "Sorry pal, but I'm just cooler than you"
	}
object.killMessages.Hero_Gemini = {
	"Play Dead! Oh wait, you're not playing?", "Never was a dog-person"
	}
object.killMessages.Hero_Scout = {
	"You can't disarm me!", "Scouted and Routed!", "And here I thought I was the only monkey around here"
	}
object.killMessages.Hero_Rocky = {
	"I break rocks in my sleep", "Pebbles? Huh, guess your name speaks for you", "Duuuuuuude it's Stun THEN Chuck!!!"
	}
 
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
            local nMessage = random(#object.killMessages.General) 
            core.AllChat(format(object.killMessages.General[nMessage], sTargetPlayerName), nDelay)
        end
    end
     
    core.nNextChatEventTime = nCurrentTime + core.nChatEventInterval
end
core.ProcessKillChat = ProcessKillChatOverride 

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

-- takes care at load/reload, <name_#> to be replaced by some convinient name.
    local unitSelf = self.core.unitSelf
    if  skills.abilQ == nil then
        skills.abilQ = unitSelf:GetAbility(0)
        skills.abilW = unitSelf:GetAbility(1)
        skills.abilE = unitSelf:GetAbility(2)
        skills.abilR = unitSelf:GetAbility(3)
        skills.abilAttributeBoost = unitSelf:GetAbility(4)
	skills.abilT = unitSelf:GetAbility(8) -- Taunt
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
 
	local nAddBonus = 0
	
	if EventData.Type == "Ability" then
		if EventData.InflictorName == "Ability_MonkeyKing1" then
		    nAddBonus = nAddBonus + object.nIllusiveUse
		elseif EventData.InflictorName == "Ability_MonkeyKing2" then
		    nAddBonus = nAddBonus + object.nVaultUse
		elseif EventData.InflictorName == "Ability_MonkeyKing3" then
		    nAddBonus = nAddBonus + object.nSlamUse
		end
	elseif EventData.Type == "Item" then
		if core.itemStealth ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemStealth:GetName() then
			addBonus = addBonus + self.nStealthUse
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

------------------------------
--
------------------------------
function IsEnemyTowerNearby(unit)
	local nTowerRange = 821.6
	local vecMyPosition = unit:GetPosition() 
	local tBuildings = HoN.GetUnitsInRadius(vecMyPosition, nTowerRange, core.UNIT_MASK_ALIVE + core.UNIT_MASK_BUILDING)
	for key, unitBuilding in pairs(tBuildings) do
		if unitBuilding:IsTower() and unitBuilding:GetCanAttack() and (unitBuilding:GetTeam()==unit:GetTeam())==false then
			return true
		end
	end
	
	return false
end
------------------------------------------------------
-- Harass Values Based On Health   --
------------------------------------------------------
local function HarassExtraBonus(hero)
	local unitSelf = core.unitSelf
	local nUtil = 0
	local aggroRange = 500
	
	local vecMyPosition = unitSelf:GetPosition() 
	local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, hero)
	local nMyExtraRange = core.GetExtraRange(unitSelf)
	local nMySpeed = unitSelf:GetMoveSpeed()
	    
	local vecTargetPosition = hero:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(hero)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	local nTargetSpeed = hero:GetMoveSpeed()
	
	-- Health Related Bonuses
	
	if unitSelf:GetHealthPercent() <= 0.15 then
		nUtil = -200
	elseif unitSelf:GetHealthPercent() <=0.25 then
		if hero:GetHealthPercent() >=0.8 then
			nUtil = -100
		elseif hero:GetHealthPercent() >=0.5 then
			nUtil = -50
		else
			nUtil = -25
		end
	elseif unitSelf:GetHealthPercent() <=0.50 then
		if hero:GetHealthPercent() >=0.8 then
			nUtil = -25
		elseif hero:GetHealthPercent() >=0.5 then
			nUtil = 0
		else
			nUtil = 25
		end
	elseif unitSelf:GetHealthPercent() <= 1 then
		if hero:GetHealthPercent() <=0.5 then
			nUtil = 50
		elseif hero:GetHealthPercent() <=0.8 then
			nUtil = 25
		else
			nUtil = 10
		end
	end
	
	-- Mana Related Bonus
	
	nUtil = nUtil + (unitSelf:GetManaPercent() * 50)
	
	-- Movement and Distance Related Bonus
	
	if (nTargetDistanceSq <= (aggroRange * aggroRange)) and (nMySpeed > nTargetSpeed) then
		nUtil = nUtil + (nMySpeed - nTargetSpeed) + 10
	elseif (nTargetDistanceSq > (aggroRange * aggroRange)) and (nMySpeed < nTargetSpeed) then
		--nUtil = -5000
		nUtil = nUtil + (nMySpeed - nTargetSpeed) - 10
	end
	
	-- Debuff Modifiers
	
	if unitSelf:IsDisarmed() then
		nUtil = nUtil - 10
	end
	
	if unitSelf:IsSilenced() then
		nUtil = nUtil - 10
	end
	
	-- NearTower Modifiers
	if IsEnemyTowerNearby(unitSelf) then
		--BotEcho("Enemy Tower Nearby - Lowering Harass")
		nUtil = nUtil + ( (unitSelf:GetHealthPercent() - hero:GetHealthPercent()) * 100 ) - 20
	elseif IsEnemyTowerNearby(hero) then
		--BotEcho("Ally Tower Nearby - Raising Harass")
		nUtil = nUtil + ( (unitSelf:GetHealthPercent() - hero:GetHealthPercent()) * 100 ) + 20
	end
	
		--BotEcho ("Bonus nUtil = ".. nUtil) 
	
	return nUtil
end

------------------------------------------------------
--            customharassutility override          --
-- change utility according to usable spells here   --
------------------------------------------------------
-- @param: iunitentity hero
-- @return: number
local function CustomHarassUtilityFnOverride(hero)
    local nUtil = 0
    local unitSelf = core.unitSelf
       
	nUtil = HarassExtraBonus(hero)
     
    if skills.abilQ:CanActivate() then
        nUnil = nUtil + object.nIllusiveUp
    end
 
    if skills.abilW:CanActivate() then
        nUtil = nUtil + object.nVaultUp
    end
    
    if skills.abilE:CanActivate() then
        nUtil = nUtil + object.nSlamUp
    end
    
    if object.itemStealth and object.itemStealth:CanActivate() then
        nUtil = nUtil + object.nStealthUp
    end
    
    if object.itemIllusion and object.itemIllusion:CanActivate() then
        nUtil = nUtil + object.nIllusionUp
    end
    
    BotEcho ("Total nUtil = ".. nUtil) 
 
    return nUtil
end
-- assisgn custom Harrass function to the behaviourLib object
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride   




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
    
    
    --- Insert abilities code here, set bActionTaken to true 
    --- if an ability command has been given successfully
    
    if bCanSee then
	local bStealth = unitSelf:HasState("State_Item3G") or unitSelf:HasState("State_Sasuke")
	core.FindItems()
        local itemStealth = core.itemStealth
	local itemIllusion = core.itemIllusion
	local itemBattery = core.itemBattery
	local itemGhostMarchers = core.itemGhostMarchers
	local abilTaunt = skills.abilT
	
	--BotEcho("Attacking - ".. nLastHarassUtility)
	
		if unitTarget:GetHealthPercent()<0.15 and abilTaunt:CanActivate() then
			if nTargetDistanceSq <= ( 300 * 300 ) and nLastHarassUtility > botBrain.nTauntThreshold then
				bActionTaken = core.OrderAbilityEntity(botBrain, abilTaunt, unitTarget)
			end
		end
		
		if itemBattery then
			if not bActionTaken then
				if itemBattery:CanActivate() and itemBattery:GetCharges() >= 10 and unitSelf:GetHealthPercent() < 0.8 then
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBattery)
				elseif itemBattery:CanActivate() and itemBattery:GetCharges() >= 1 and unitSelf:GetHealthPercent() < 0.5 then
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBattery)
				end
			end
		end
	
		if itemIllusion then
			if not bActionTaken then
				if itemIllusion:CanActivate() and nTargetDistanceSq <= ( 250 * 250 ) then
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemIllusion)
				end
			end
		end
		
		if itemStealth then
			if not bActionTaken then
				if not (unitSelf:HasState("State_Item3G") or unitSelf:HasState("State_Sasuke")) and itemStealth:CanActivate() then
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemStealth)
				end
			end
		end
		
		if not bActionTaken and not bStealth then
		
			if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Checking Vault") end
			local abilVault = skills.abilW
			if abilVault:CanActivate() and ( (nLastHarassUtility > botBrain.nVaultThreshold) or (nLastHarassUtility > botBrain.nVault2Threshold) )  then
				local nRange = abilVault:GetRange() 
				if nTargetDistanceSq <= ((nRange * nRange)) then
					bActionTaken = core.OrderAbilityEntity(botBrain, abilVault, unitTarget)
				else
					if itemGhostMarchers and itemGhostMarchers:CanActivate() and not bStealth then 
						bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemGhostMarchers)
					end
					bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
				end
			end
			
		end
		
		if not bActionTaken then
			if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Checking Illusive") end
			local abilIllusive = skills.abilQ
			if abilIllusive:CanActivate() and nLastHarassUtility > botBrain.nIllusiveThreshold  then
			    local nRange = abilIllusive:GetRange() 
			    if nTargetDistanceSq <= ( 300 * 300 ) then
				bActionTaken = core.OrderAbility(botBrain, abilIllusive)
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Casting Illusive") end
				bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Facing Enemy") end
				bActionTaken = core.OrderAbility(botBrain, abilIllusive)
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Casting Illusive 2") end
			    else
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Can't Illusive, Target Too Far") end
				bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
			    end
			end
		end
    
		if not bActionTaken then
			if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Checking Slam") end
			local abilSlam = skills.abilE
			if abilSlam:CanActivate() and nLastHarassUtility > botBrain.nSlamThreshold  then
			    if nTargetDistanceSq <= ( 200 * 200 ) then
				bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Facing Enemy") end
				bActionTaken = core.OrderAbility(botBrain, abilSlam)
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Casting Slam") end
			    else
				if bDebugEchos then BotEcho("(" .. nLastHarassUtility .. ") Can't Slam Target Too Far") end
				bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
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

---------------------------------------------
-- Attack Creeps Override
---------------------------------------------

function AttackCreepsExecuteCustom(botBrain)

local unitSelf = core.unitSelf
	local currentTarget = core.unitCreepTarget
	local bActionTaken = false
	core.FindItems()
	
	local itemHatchet = core.itemHatchet

	if currentTarget and core.CanSeeUnit(botBrain, currentTarget) then		
		local vecTargetPos = currentTarget:GetPosition()
		local nDistSq = Vector3.Distance2DSq(unitSelf:GetPosition(), vecTargetPos)
		local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)

		if currentTarget ~= nil then			
			
			if nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() then
				--BotEcho("Attacking Creep")
				--only attack when in nRange, so not to aggro towers/creeps until necessary, and move forward when attack is on cd
				bActionTaken = core.OrderAttackClamp(botBrain, unitSelf, currentTarget)
			
			elseif itemHatchet then
				local nHatchRange = itemHatchet:GetRange()
				if nDistSq < ( nHatchRange * nHatchRange ) and itemHatchet:CanActivate() and currentTarget:GetTeam() ~= unitSelf:GetTeam() then
				--BotEcho("Attempting Hatchet")
				bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, itemHatchet, currentTarget)
				end			
			else
				--BotEcho("MOVIN OUT")
				local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
				bActionTaken = core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false)
			end
		end
	else
		return false
	end
	
	if not bActionTaken then
		return object.AttackCreepsExecuteOld(botBrain)
	end 
end

object.AttackCreepsExecuteOld = behaviorLib.AttackCreepsBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteCustom

---------------------------------------------
-- Retreat From Threat Override
---------------------------------------------
local function RetreatFromThreatExecuteOverride(botBrain)
	local bDebugEchos = false
	local bActionTaken = false
	
	local nlastRetreatUtil = behaviorLib.lastRetreatUtil
	
	local unitSelf = core.unitSelf
	core.FindItems()
	
	if bDebugEchos then BotEcho("Running - ".. nlastRetreatUtil) end
	
	--Activate battery if we can
	local itemBattery = core.itemBattery
	if not bActionTaken then
		if itemBattery then
			if itemBattery:CanActivate() and itemBattery:GetCharges() >= 10 and unitSelf:GetHealthPercent() < 0.8 then
				if bDebugEchos then BotEcho("Running - Using Battery") end
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBattery)
				elseif itemBattery:CanActivate() and itemBattery:GetCharges() >= 1 and unitSelf:GetHealthPercent() < 0.5 then
					bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBattery)
			end
		end
	end
		
	if not bActionTaken then
		--Activate stealth if we can
		local itemStealth = core.itemStealth
		if bDebugEchos then BotEcho(behaviorLib.lastRetreatUtil.. "/- Stealth - /".. botBrain.nretreatStealthThreshold ) end
		if nlastRetreatUtil >= botBrain.nretreatStealthThreshold and itemStealth and itemStealth:CanActivate() then
			if bDebugEchos then BotEcho("Running - Attempting Stealth") end
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemStealth)
		end
	end
		
	if not bActionTaken then
		--Activate ghost marchers if we can
		local itemGhostMarchers = core.itemGhostMarchers
		if not (unitSelf:HasState("State_Item3G") or unitSelf:HasState("State_Sasuke")) then
			if behaviorLib.lastRetreatUtil >= behaviorLib.retreatGhostMarchersThreshold and itemGhostMarchers and itemGhostMarchers:CanActivate() then
				if bDebugEchos then BotEcho("Running - Using Ghost Marchers") end
				bActionTaken = core.OrderItemClamp(botBrain, core.unitSelf, itemGhostMarchers)
			end
		end
	end
	
	if not bActionTaken then
		return object.RetreatFromThreatExecuteOld(botBrain)
	end 
	
end

-- override the behaviour
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatBehavior["Execute"]
behaviorLib.RetreatFromThreatBehavior["Execute"] = RetreatFromThreatExecuteOverride

----------------------------------
--  FindItems Override
----------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemStealth ~= nil and not core.itemStealth:IsValid() then
		core.itemStealth = nil
	end
	if core.itemIllusion ~= nil and not core.itemIllusion:IsValid() then
		core.itemIllusion = nil
	end
	if core.itemBattery ~= nil and not core.itemBattery:IsValid() then
		core.itemBattery = nil
	end
	
	if bUpdated then
		--only update if we need to
		if core.itemStealth and core.itemIllusion and core.itemBattery then
			return
		end
		
		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemStealth == nil and (curItem:GetName() == "Item_Stealth" or curItem:GetName() == "Item_Sasuke") then
					core.itemStealth = core.WrapInTable(curItem)
				elseif core.itemIllusion == nil and curItem:GetName() == "Item_ManaBurn2" then
					core.itemIllusion = core.WrapInTable(curItem)
				elseif core.itemBattery == nil and (curItem:GetName() == "Item_ManaBattery" or curItem:GetName() == "Item_PowerSupply") then
					core.itemBattery = core.WrapInTable(curItem)
				end
			end
		end
	end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride