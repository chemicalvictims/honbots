--***************************************--
--******** \KrakenBot v0.000002/ ********--
--************** \Created/ **************--
--************* \Geramie A/ *************--
--********** \[RC2W]optx_2000/ **********--
--***************************************--
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

BotEcho('loading kraken_main...')

object.heroName = 'Hero_Kraken'

--------------------------------
-- Kraken Skills
--------------------------------
function object:SkillBuild()
	local unitSelf = self.core.unitSelf

	if skills.abilTorrent == nil then
		skills.abilTorrent = unitSelf:GetAbility(0)
		skills.abilTsunamiCharge = unitSelf:GetAbility(1)
		skills.abilSplash = unitSelf:GetAbility(2)
		skills.abilKraken = unitSelf:GetAbility(3)
		skills.abilAttributeBoost = unitSelf:GetAbility(4)
	end
	
	if unitSelf:GetAbilityPointsAvailable() <= 0 then
		return
	end
	
	--speicific level ordering first {torrent, tsunamiCharge, splash, splash, splash}
	if not (skills.abilTorrent:GetLevel() >= 1) then
		skills.abilTorrent:LevelUp()
	elseif not (skills.abilTsunamiCharge:GetLevel() >= 1) then
		skills.abilTsunamiCharge:LevelUp()
	elseif not (skills.abilSplash:GetLevel() >= 3) then
		skills.abilSplash:LevelUp()
	--max in this order {ult, splash, torrent, tsunamiCharge, stats}
	elseif skills.abilKraken:CanLevelUp() then
		skills.abilKraken:LevelUp()
	elseif skills.abilSplash:CanLevelUp() then
		skills.abilSplash:LevelUp()
	elseif skills.abilTorrent:CanLevelUp() then
		skills.abilTorrent:LevelUp()
	elseif skills.abilTsunamiCharge:CanLevelUp() then
		skills.abilTsunamiCharge:LevelUp()
	else
		skills.abilAttributeBoost:LevelUp()
	end	
end

-------------------------------------------------------
--	Kraken specific harass bonuses
--
--  Abilities off cd increase harass util
--  Ability use increases harass util for a time
-------------------------------------------------------

object.abilTorrentUpBonus = 20
object.abilTsunamiChargeUpBonus = 20
object.abilSplashUpBonus = 15
object.abilKrakenUpBonus = 40

object.abilTorrentUseBonus = 25
object.abilTsunamiChargeUseBonus = 20
object.abilSplashUseBonus = 0
object.abilKrakenUseBonus = 50

object.abilTorrentUtilThreshold = 55
object.abilTsunamiChargeUtilThreshold = 40
object.abilKrakenUtilThreshold = 50

local function AbilitiesUpUtilityFn(hero)
	local bDebugLines = false
	local bDebugEchos = false
	
	local val = 0
	
	if skills.abilTorrent:CanActivate() then
		val = val + object.abilTorrentUpBonus
	end
	
	if skills.abilTsunamiCharge:CanActivate() then
		val = val + object.abilTsunamiChargeUpBonus
	end
	
	if skills.abilSplash:CanActivate() then
		val = val + object.abilSplashUpBonus
	end
	
	if skills.abilKraken:CanActivate() then
		val = val + object.abilKrakenUpBonus
	end
	
	return val
end

-----------------------------------------------------------------
-- Kraken ability use gives bonus to harass util for a while
-----------------------------------------------------------------
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)
	
	local addBonus = 0
	
	if EventData.Type == "Ability" then
		--BotEcho("ABILILTY EVENT!  InflictorName: "..EventData.InflictorName)		
		if EventData.InflictorName == "Ability_Kraken1" then
			addBonus = addBonus + object.abilTorrentUseBonus
		elseif EventData.InflictorName == "Ability_Kraken2" then
			addBonus = addBonus + object.abilTsunamiChargeUseBonus
		elseif EventData.InflictorName == "Ability_Kraken3" then
			addBonus = addBonus + object.abilSplashUseBonus
		elseif EventData.InflictorName == "Ability_Kraken4" then
			addBonus = addBonus + object.abilKrakenUseBonus
		end
	end
	
	if addBonus > 0 then
		--decay before we add
		core.DecayBonus(self)
	
		core.nHarassBonus = core.nHarassBonus + addBonus
	end
end

object.oncombateventOld = object.oncombatevent
object.oncombatevent 	= object.oncombateventOverride

-----------------------------------
-- Util calc override
-----------------------------------
local function CustomHarassUtilityOverride(hero)
	local nUtility = AbilitiesUpUtilityFn(hero)
	-- combo abilities
	return nUtility
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityOverride

----------------------------------
--	Kraken ability radius
----------------------------------
function object.GetKrakenRadius()
	return 300
end

----------------------------------
--	Kraken harass actions
----------------------------------
local function HarassHeroExecuteOverride(botBrain)
	local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return false
    end
	
	local unitSelf = core.unitSelf
	local unitTarget = behaviorLib.heroTarget 
	
	local bActionTaken = false
	local nLastHarassUtility = behaviorLib.lastHarassUtil
	
	if core.CanSeeUnit(botBrain, unitTarget) then
		if not bActionTaken then
			-- ability variables
			local abilTorrent = skills.abilTorrent
			local abilTsunamiCharge = skills.abilTsunamiCharge
			local abilSplash = skills.abilSplash
			local abilKraken = skills.abilKraken

			--abilKraken RELEASE THE KRAKEN!!!!
			if abilKraken:CanActivate() then
				
				--find ally heroes
				local tAllies = core.localUnits["AllyUnits"]
				local bVisableAlly = false
				
				for id, unitAlly in pairs(tAllies) do
					if core.CanSeeUnit(botBrain, unitAlly) then
						bVisableAlly = true
					end
				end
				
				--see if targetEnemy is rooted
				local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
				
				if bTargetRooted and bVisableAlly then
					if nLastHarassUtility > botBrain.abilKrakenUtilThreshold then
						--find best vectorTarget to ulti
						local abilKrakenRange = abilKraken and abilKraken:GetRange() or nil
						local vecTarget = core.AoETargeting(unitSelf, abilKrakenRange, botBrain.GetKrakenRadius() + core.GetExtraRange(unitSelf), true, unitTarget, core.enemyTeam, nil)

						if vecTarget then
							BotEcho("***Releasing The Kraken***")
							bActionTaken = core.OrderAbilityPosition(botBrain, abilKraken, vecTarget)
						end
					end
				end
			end
			
			--abilTsunamiCharge
			if abilTsunamiCharge:CanActivate() and abilSplash:CanActivate() then
				--find distance from self to target
				local distTarget = Vector3.Distance2D(unitSelf:GetPosition(), unitTarget:GetPosition())
				--see if targetEnemy is rooted
				local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
				
				local abilTsunamiChargeRange = abilTsunamiCharge:GetRange() + core.GetExtraRange(unitSelf) + core.GetExtraRange(target)
				
				if distTarget <= abilTsunamiChargeRange and not bTargetRooted then
					if nLastHarassUtility > botBrain.abilTsunamiChargeUtilThreshold then
						BotEcho("***Charging The Enemy***")
						bActionTaken = core.OrderAbilityPosition(botBrain, abilTsunamiCharge, unitTarget:GetPosition())
					end
				end
			end
			
			--abiltorrent
			if abilTorrent:CanActivate() then
				--find distance from self to target
				local distTarget = Vector3.Distance2D(unitSelf:GetPosition(), unitTarget:GetPosition())
				--see if targetEnemy is rooted
				local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200
				
				local abilTorrentRange = abilTorrent and abilTorrent:GetRange() + core.GetExtraRange(unitSelf) + core.GetExtraRange(target)
				
				if distTarget <= abilTorrentRange and not bTargetRooted then
					if nLastHarassUtility > botBrain.abilTorrentUtilThreshold then
						BotEcho("***Slowing The Enemy***")
						bActionTaken = core.OrderAbilityEntity(botBrain, abilTorrent, unitTarget)
					end
				end
			end
		end
	end
end  
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

----------------------------------
--	Kraken items
----------------------------------
--[[ list code:
	"# Item" is "get # of these"
	"Item #" is "get this level of the item" --]]
behaviorLib.StartingItems = {"Item_LoggersHatchet", "Item_IronBuckler", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems = {"Item_Steamboots", "Item_MysticVestments", "Item_HelmOfTheVictim", "Item_TrinketOfRestoration", "Item_TrinketOfRestoration", "Item_HomecomingStone"}
behaviorLib.MidItems = {"Item_Lifetube", "Item_Beastheart"}
behaviorLib.LateItems = {"Item_Freeze", "Item_DaemonicBreastplate", "Item_Critical 4"}


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

BotEcho('finished loading kraken_main')