--[[

		Script details:
			Series: Totally Series AIO
			Champions included: Annie, Swain, LeBlanc
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]

local printChat = Game.Chat.Print
local _S1 = Game.Slots.SUMMONER_1
local _S2 = Game.Slots.SUMMONER_2
local READY = Game.SpellState.READY


function Say(text)
	printChat("<font color=\"#FF0000\"><b>Totally Summoners:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

Callback.Bind("Load", function()
	Callback.Bind("GameStart", function() OnLoad() end)
end)

function OnLoad()

	-- Global Variables - Used with every champion
	InitializeGlobalVariables()

	-- Normal Callbacks used for every script
	Callback.Bind("Tick", function() OnTick() end)
	Callback.Bind("CreateObj", function(obj) OnCreateObj(obj) end)
	Callback.Bind("DeleteObj", function(obj) OnDeleteObj(obj) end)
	Callback.Bind("ApplyBuff", function(unit, target, buff) OnApplyBuff(unit, target, buff) end)

	-- Script succesfully loaded, enjoy.
	Say("Succesfully loaded ")
end


function OnTick()
	if myHero.dead then return end

	SummonerReady()

	if heal ~= nil and Menu.autoheal.useHeal:Value() == true and not isRecalling then
		AutoHeal()
	end

	if ignite ~= nil and Menu.autoignite.useIgnite:Value() == true then
		AutoIgnite()
	end

	if revive ~= nil and Menu.autorevive.useRevive:Value() == true then
		if myHero.dead and reviveReady then
			myHero:CastSpell(revive)
		end
	end
end

function OnApplyBuff(unit, target, buff)
	if Menu.autocleanse.useCleanse:Value() == true then
		if Menu.autocleanse[buff.name] then
			if cleanseReady then
				myHero:CastSpell(cleanse)
			end
		end
	end
end

function OnCreateObj(obj)
    if obj.name == "TeleportHome.troy" and myHero:DistanceTo(obj) < 50 then
    	isRecalling = true
    end
end

function OnDeleteObj(obj)
    if obj.name == "TeleportHome.troy" and myHero:DistanceTo(obj) < 50 then
    	isRecalling = false
    end
end

function InitializeGlobalVariables()
	heal, healReady = GetSummonerSlot("summonerheal"), false
   	ignite, igniteReady = GetSummonerSlot("summonerdot"), false
   	barrier, barrierReady = GetSummonerSlot("summonerbarrier"), false
   	cleanse, cleanseReady = GetSummonerSlot("summonerboost"), false
   	revive, reviveReady = GetSummonerSlot("summonerevive"), false

   	EnemyTable = {}
   	isRecalling = false

   	bufflist = {
		["zedulttargetmark"] = {spellname = "Death Mark", spell = "R", charName = "Zed"}, --correct
		["paranoiamisschance"] = {spellname = "Terrify", spell = "Q", charName = "Fiddlestick"}, --correct
		["puncturingtauntarmordebuff"] = {spellname = "Puncturing Taunt", spell = "E", charName = "Rammus"}, --
 		--["Teemo"] = {spellname = "Blinding Dart", spell = "R", charName = "Teemo"}, --
		--["Ahri"] = {spellname = "Charm", spell = "E", charName = "Ahri"}, --
		["curseofthesadmummy"] = {spellname = "Curse of the Sad Mummy", spell = "R", charName = "Amumu"}, --correct
		["enchantedcrystalarrow"] = {spellname = "Enchanted Crystal Arrow", spell = "R", charName = "Ashe"}, --correct
		["Malzahar"] = {spellname = "Nether Grasp", spell = "R", charName = "Malzahar"}, --
		--["Skarner"] = {spellname = "Impale", spell = "R", charName = "Skarner"}, --
		["veigarstun"] = {spellname = "Primordial Burst", spell = "E", charName = "Veigar"}, --correct
		["nasusw"] = {spellname = "Wither", spell = "W", charName = "Nasus"}
	}

   	DrawGlobalMenu()
end

function AutoHeal()
	if myHero.health / myHero.maxHealth <= Menu.autoheal.hpPerc:Value() and healReady then
		myHero:CastSpell(heal)
	end

	if Menu.autoheal.helpTeammate:Value() == true then
		for i, hero in ipairs(EnemyTable) do
			if Menu.autoheal.teammates[hero.charName]:Value() and myHero:DistanceTo(hero) < 600 then
				if hero.health / hero.maxHealth <= Menu.autoheal.hpPerc:Value() and healReady then
					myHero:CastSpell(heal)
				end
			end
		end
	end
end 

function AutoIgnite()
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team and myHero:DistanceTo(hero) <= 600 then
			if igniteReady and Menu.autoignite[hero.charName]:Value() == true and hero.health < GetIgniteDamage() then
				myHero:CastSpell(ignite, hero)
			end
		end
	end
end


function GetIgniteDamage()
	return (50 + (20 * myHero.level))
end 

function SummonerReady() 
	healReady = IsReady(heal)
	igniteReady = IsReady(ignite)
	barrierReady = IsReady(barrier)
	cleanseReady = IsReady(cleanse)
	reviveReady = IsReady(revive)
end

function DrawFont(msg)
	return "<font color=\"#99EBD6\">" .. tostring(msg) .. "</font>" 
end

function GetSummonerSlot(name)
	return ((myHero:GetSpellData(_S1).name:find(name) and _S1) or (myHero:GetSpellData(_S2).name:find(name) and _S2))
end

function IsReady(slot) 
	return myHero:CanUseSpell(slot) == READY
end

function DrawGlobalMenu()
	Menu = MenuConfig("Totally Summoners");

	if ignite ~= nil then
		Menu:Menu("autoignite", "Auto Ignite")
		Menu.autoignite:Section("hue", DrawFont("Activation"))
		Menu.autoignite:Boolean("useIgnite", "Automatically Use Ignite", false)
		Menu.autoignite:Section("hue2", DrawFont("Additionnel Settings"))
		for i, hero in ipairs(EnemyTable) do
			Menu.autoignite:Boolean(hero.charName, "Use Ignite on " .. hero.charName, true)
		end
	end

	if heal ~= nil then
		Menu:Menu("autoheal", "Auto Heal")
		Menu.autoheal:Section("hue3", DrawFont("Activation"))
		Menu.autoheal:Boolean("useHeal", "Automatically use Heal", true)
		Menu.autoheal:Slider("hpPerc", "Min percentage to cast Heal", 0.15, 0, 1, 0.01)
		Menu.autoheal:Section("hue4", DrawFont("Additionnel Settings"))
		Menu.autoheal:Boolean("helpTeammate", "Use Heal to Help teammates", false)
		Menu.autoheal:Menu("teammates", "Teammates to Heal")
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
			if hero.team == myHero.team and not hero.isMe then
				Menu.autoheal.teammates:Boolean(hero.charName, "Use Heal on " .. hero.charName, true)
			end
		end
	end 

	if cleanse ~= nil then
		Menu:Menu("autocleanse", "Auto Cleanse")
		Menu.autocleanse:Section("hue5", DrawFont("Activation"))
		Menu.autocleanse:Boolean("useCleanse", "Automatically Use Cleanse", true)
		Menu.autocleanse:Section("hue6", DrawFont("Buffs"))
		for i = 1, Game.HeroCount(), 1 do
			local hero = Game.Hero(i)
			if not (myHero.team == hero.team) then
				table.insert(EnemyTable, hero.charName)
			end
		end
		local hasAdded = false
		for buff, data in pairs(bufflist) do
			if table.contains(EnemyTable, data.charName) then
				hasAdded = true 
				Menu.autocleanse:Boolean(buff, data.spellname .. " - " .. data.charName .. " (" .. data.spell .. ")", true)
			end
		end

	end

	if revive ~= nil then
		Menu:Menu("autorevive", "Auto Revive")
		Menu.autorevive:Section("hue7", DrawFont("Activation"))
		Menu.autorevive:Boolean("useRevive", "Automatically Use Revive", true)
	end

end




function TargetHaveBuff(Buffname, unit)
	local unit = unit and unit or myHero
	local hasBuff = false
	for i = 1, unit.buffCount, 1 do
		local buff = unit:GetBuff(i)
		if buff.name == Buffname then
			hasBuff = true
			break
		end
	end
	return hasBuff
end