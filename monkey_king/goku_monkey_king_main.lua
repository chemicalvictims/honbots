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
behaviorLib.MidItems  = {"Item_EnhancedMarchers","Item_PowerSupply","Item_SolsBulwark","Item_Stealth"}
behaviorLib.LateItems  = {"Item_ManaBurn2","Item_Freeze","Item_Sasuke","Item_DaemonicBreastplate"}


-- Skillbuild table, 0=Q, 1=W, 2=E, 3=R, 4=Attri
object.tSkills = {
    0, 1, 2, 1, 1,
    3, 1, 2, 2, 2, 
    3, 0, 0, 0, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4,
}

-- bonus agression points if a skill/item is available for use

object.nIllusiveUp = 20
object.nVaultUp = 40 
object.nSlamUp = 20
object.nStealthUp = 20

-- bonus agression points that are applied to the bot upon successfully using a skill/item

object.nIllusiveUse = 20
object.nVaultUse = 50 
object.nSlamUse = 20
object.nStealthUse = 20

--thresholds of aggression the bot must reach to use these abilities

object.nIllusiveThreshold = 60
object.nVaultThreshold = 20 
object.nVault2Threshold = 80 
object.nSlamThreshold = 100
object.nStealthThreshold = 30


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
object.killMessages.Hero_MonkeyKing       = { "I won't lose to my own clone!", "The original is always the best!", 
					"There is only one true Monkey King!" }
 
local function ProcessKillChatOverride(unitTarget, sTargetPlayerName)
    local nCurrentTime = HoN.GetGameTime()
    if nCurrentTime < core.nNextChatEventTime then
        return
    end   
     
    local nToSpamOrNotToSpam = random()
         
    if(nToSpamOrNotToSpam < core.nKillChatChance) then
        local nDelay = random(core.nChatDelayMin, core.nChatDealyMax) 
        local tHeroMessages = object.killMessages[unitTarget:GetTypeName()]
         
        if tHeroMessages ~= nil and random() >= 0.7 then
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
    
    BotEcho(hero:GetHealthPercent())
	if (hero:GetHealthPercent()<50) then
		nUtil = nUtil + 80
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
		
		if itemBattery then
			if not bActionTaken then
				if itemBattery:CanActivate() and itemBattery:GetCharges() >= 10 and unitSelf:GetHealthPercent() < 0.8 then
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
				BotEcho("Vault Range".. nRange)
				BotEcho("Distance from Target".. nTargetDistanceSq)
				if nTargetDistanceSq <= ((nRange * nRange)) then
					bActionTaken = core.OrderAbilityEntity(botBrain, abilVault, unitTarget)
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
		bActionTaken = core.OrderMoveToUnit(botBrain, unitSelf, unitTarget)
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
--  FindItems Override
----------------------------------
local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.Stealth ~= nil and not core.itemStealth:IsValid() then
		core.Stealth = nil
	end
	if core.Illusion ~= nil and not core.itemIllusion:IsValid() then
		core.Illusion = nil
	end
	if core.Battery ~= nil and not core.itemBattery:IsValid() then
		core.Battery = nil
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