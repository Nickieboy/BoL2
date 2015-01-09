--[[

		Script details:
			Champion: Annie
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 1.0	

			Features:

				Combo
					6 Different combos
					Possibility to only R:
						Instant
						Enemy killable
						R Stuns

				Auto R
					Ability to automatically cast R if it'll hit multiple people

				Farm
					Farm with Q and w

				Auto Kill
					Possibility to autokill an enemy when it's killable
					Optional settings included

				Auto E Settings
					Stack Stun
					Auto E when attacked

				Auto Ignite
				Auto Heal


				Script has prediction on R

		Changelog:
			1.0:
				Released champ



--]]

function Say(text)
	Game.Chat.Print("<font color=\"#FF0000\"><b>Totally Annie:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

Callback.Bind("Load", function()
	Callback.Bind("GameStart", function() OnLoad() end)
end)

function OnLoad()
	if myHero.charName ~= "Annie" then return end
	InitializeVariables()
	Say("loaded version 0.1. Script is still in beta. More scripts will follow.")
	Callback.Bind("Tick", function() OnTick() end)
	Callback.Bind("Draw", function() OnDraw() end)
	Callback.Bind("CreateObj", function(obj) OnCreateObj(obj) end)
	Callback.Bind("DeleteObj", function(obj) OnDeleteObj(obj) end)
	Callback.Bind("ProcessSpell", function(unit, spell) OnProcessSpell(unit, spell) end)
end

function OnTick()
	target = ts:GetTarget(Spells.Q.range)
	SpellChecks()
	CalcDamageCalculations()

	if Menu.combo.combo:IsPressed() == true then
		Combo()
	end

	if Menu.harass.harass:IsPressed() == true then
		Harass()
	end

	if Menu.autokill.autokill:Value() == true then
		AutoKill()
	end 

	if Menu.autoR.autoUlt:Value() == true then
		AutoR()
	end

	if health ~= nil and Menu.misc.autoheal.useHeal:Value() == true and not isRecalling then
		AutoHeal()
	end

	if ignite ~= nil and Menu.misc.autoignite.useIgnite:Value() == true then
		AutoIgnite()
	end

	if Menu.misc.autoE.stackStun:Value() == true then
		if not canStun and Spells.E.ready then
			myHero:CastSpell(Game.Slots.SPELL_3)
		end
	end

	if Menu.misc.autopotions.usePotions:Value() == true then
		if not usingHealthPot and Menu.misc.autopotions.useHealthPotion:Value() == true then
			if myHero.health / myHero.maxHealth <= Menu.misc.autopotions.hpPerc:Value() then
				CastItem(2003)
			end
		end
		if not usingManaPot and Menu.misc.autopotions.useManaPotion:Value() == true then
			if myHero.mana / myHero.maxMana <= Menu.misc.autopotions.manaPerc:Value() then
				CastItem(2004)
			end
		end
	end
end

function OnDraw()
	if Menu.draw.useDrawings:Value() == true then
		if Menu.draw.drawQ:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawW:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawR:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.R.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawKilltext:Value() == true then
			for i = 1, Game.HeroCount(), 1 do
				local enemy = Game.Hero(i)
				if ValidTarget(enemy) then
					local barPos = Graphics.WorldToScreen(Geometry.Vector3(enemy.x, enemy.y, enemy.z))
					local PosX = barPos.x - 35
					local PosY = barPos.y - 50  
					--Graphics.DrawText(KillText[i], 15, PosX, PosY, Graphics.ARGB(255,255,204,0):ToNumber())
				end
			end
		end
	end
end

function OnCreateObj(obj)
	if obj.name == "StunReady.troy" and myHero:DistanceTo(obj) < 50 then
        canStun = true
    end

    if obj.name == "TeleportHome.troy" and myHero:DistanceTo(obj) < 50 then
    	isRecalling = true
    end

    if obj.name:find("Global_Item_HealthPotion.troy") and myHero:DistanceTo(obj) < 50 then
		usingHealthPot = true
	end
		
	if obj.name:find("Global_Item_ManaPotion.troy") and myHero:DistanceTo(obj) < 50 then
		usingManaPot = true
	end
end

function OnDeleteObj(obj)
	if obj.name == "StunReady.troy" and myHero:DistanceTo(obj) < 50 then
        canStun = false
    end

    if obj.name == "TeleportHome.troy" and myHero:DistanceTo(obj) < 50 then
    	isRecalling = false
    end

    if obj.name:find("Global_Item_HealthPotion.troy") and myHero:DistanceTo(obj) < 50 then
		usingHealthPot = false
	end
		
	if obj.name:find("Global_Item_ManaPotion.troy") and myHero:DistanceTo(obj) < 50 then
		usingManaPot = false
	end
    
end

function OnProcessSpell(unit, spell)
	if spell.target == myHero and string.find(spell.name, "BasicAttack") and unit.type == "Obj_AI_Hero" and Menu.misc.autoE.onAA:Value() == true then
	    if Spells.E.ready then
	    	myHero:CastSpell(Game.Slots.SPELL_3)
		end
	end
end


function InitializeVariables()
	Spells = {
		["Q"] = {name = "Disintegrate", range = 625, ready = false},
		["W"] = {name = "Incinerate", range = 625, ready = false},
		["E"] = {name = "Molten Shield", ready = false},
		["R"] = {name = "Summon: Tibbers", range = 600, radius = 150, delay = 0.25, ready = false}
	}

	ts = TargetSelector("LESS_AP", Spells.Q.range) 

	canStun = false
	ignite, heal, barrier, flash = nil, nil, nil, nil
	passiveStacks = 0
	hasTibbers = false
	isRecalling = false
	target, Rtarget = nil, nil
	Hready, Iready = false, false
	enemyJunglers = {}
	allyJunglers = {}
	usingHealthPot, usingManaPot = false, false
	AAdisabled = false
	KillText = {}
	--BasicPrediction.EnablePrediction()

	FindSummoners()
	DrawMenu()
end


function Combo()
	if target ~= nil then
		if Menu.combo.comboWay:Value() == 1 then
			PerformCombo(Combo1(), target)
		elseif Menu.combo.comboWay:Value() == 2 then
			PerformCombo(Combo2(), target)
		elseif Menu.combo.comboWay:Value() == 3 then
			PerformCombo(Combo3(), target)
		elseif Menu.combo.comboWay:Value() == 4 then
			PerformCombo(Combo4(), target)
		elseif Menu.combo.comboWay:Value() == 5 then
			PerformCombo(Combo5(), target)
		elseif Menu.combo.comboWay:Value() == 6 then
			PerformCombo(Combo6(), target)
		end
	end
end

function Combo1()
	return {"Q", "W", "R"}
end

function Combo2()
	return {"Q", "R", "W"}
end

function Combo3()
	return {"W", "Q", "R"}
end
function Combo4()
	return {"W", "R", "Q"}
end

function Combo5()
	return {"R", "Q", "W"}
end

function Combo6()
	return {"R", "W", "Q"}
end

function PerformCombo(comboTable, target)
	for i, combo in ipairs(comboTable) do
		if combo == "Q" then
			CastQ(target)
		elseif combo == "W" then
			CastW(target)
		elseif combo == "E" then
			CastE()
		elseif combo == "R" then
			CastR(target)
		end 
	end
end


function Harass()
	if target ~= nil then
		if Menu.harass.harassQ:Value() then
			PerformCombo({"Q"}, target)
		end 

		if Menu.harass.harassW:Value() then
			PerformCombo({"W"}, target)
		end 

	end
end

function CastQ(target)
	if ValidTarget(target) and myHero:DistanceTo(target) <= Spells.Q.range and Spells.Q.ready then
		myHero:CastSpell(Game.Slots.SPELL_1, target)
	end
end 

function CastW(target)
	if ValidTarget(target) and myHero:DistanceTo(target) <= Spells.W.range and Spells.W.ready then
		myHero:CastSpell(Game.Slots.SPELL_2, target)
	end
end

function CastE()
	if Spells.E.ready then
		myHero:CastSpell(Game.Slots.SPELL_3)
	end
end 

function CastR(target)
 	if not CanComboR() == true then return end
	if ValidTarget(target) and myHero:DistanceTo(target) <= Spells.R.range and Spells.R.ready then
		--local PredictionPosition, enemies, count = BasicPrediction.GetBestAoEPositionForce(target, Spells.R.range, math.huge, Spells.R.delay, Spells.R.radius, false, false, myHero)
		--if type(PredictionPosition) == "Vector3" and Hitchance >= 1 then
			--myHero:CastSpell(Game.Slots.SPELL_4, PredictionPosition.x, PredictionPosition.y)
		--end
		myHero:CastSpell(Game.Slots.SPELL_4, target)
	end 
end

function AutoKill()
	for i = 1, Game.HeroCount(), 1 do
		local enemy = Game.Hero(i)
		if ValidTarget(enemy) and myHero:DistanceTo(enemy) < Spells.Q.range then
			local Qdmg = (((Menu.autokill.autokillQ:Value() == true) and Spells.Q.ready and CalculateDamage("Q", enemy)) or 0)
			local Wdmg = (((Menu.autokill.autokillW:Value() == true) and Spells.W.ready and CalculateDamage("W", enemy)) or 0)
			local Rdmg = (((Menu.autokill.autokillR:Value() == true) and Spells.R.ready and CalculateDamage("R", enemy)) or 0)
			local Idmg = (((Menu.autokill.autokillIgnite:Value() == true) and Iready and GetIgniteDamage()) or 0)

			if Wdmg > Qdmg and Qdmg > enemy.health then
				CastQ(enemy)
			elseif Wdmg > enemy.health then
				Castw(enemy)
			elseif Qdmg + Wdmg > enemy.health then
				CastQ(enemy)
				CastW(enemy)
			elseif Qdmg + Wdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				CastQ(enemy)
				CastW(enemy)
			elseif Wdmg > Qdmg and Qdmg + Rdmg > enemy.health then
				CastQ(enemy)
				CastR(enemy)
			elseif Wdmg + Rdmg > enemy.health then
				CastW(enemy)
				CastR(enemy)
			elseif Wdmg > Qdmg and Qdmg + Rdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				CastQ(enemy)
				CastR(enemy)
			elseif Wdmg + Rdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				CastW(enemy)
				CastR(enemy)
			elseif Qdmg + Rdmg + Wdmg > enemy.health then
				CastQ(enemy)
				CastW(enemy)
				CastR(enemy) 
			elseif Qdmg + Rdmg + Wdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				CastQ(enemy)
				CastW(enemy)
				CastR(enemy)
			end 
		end 
	end 
end

function CalcDamageCalculations()
	for i = 1, Game.HeroCount(), 1 do
		local enemy = Game.Hero(i)
		if ValidTarget(enemy) then
			local Qdmg = ((Spells.Q.ready and CalculateDamage("Q", enemy)) or 0)
			local Wdmg = ((Spells.W.ready and CalculateDamage("W", enemy)) or 0)
			local Rdmg = ((Spells.R.ready and CalculateDamage("R", enemy)) or 0)
			local Idmg = ((Iready and GetIgniteDamage()) or 0)
			if myHero.totalDamage > enemy.health then
				KillText[i] = "Murder him"
			elseif Idmg > enemy.health then
				KillText[i] = "Ignite = kill"
			elseif Qdmg > enemy.health then
				KillText[i] = "Q = kill"
			elseif Wdmg > enemy.health then
				KillText[i] = "W = kill"
			elseif Rdmg > enemy.health then
				KillText[i] = "R = kill"
			elseif Qdmg + myHero.totalDamage then
				KillText[i] = "Q + AA = kill"
			elseif Qdmg + Idmg > enemy.health then
				KillText[i] = "Q + Ignote = kill"
			elseif Wdmg + myHero.totalDamage then
				KillText[i] = "W + AA = kill"
			elseif Wdmg + Idmg > enemy.health then
				KillText[i] = "W + Ignite = kill" 
			elseif Rdmg + myHero.totalDamage > enemy.health then
				KillText[i] = "R + AA = kill"
			elseif Rdmg + Idmg > enemy.health then
				KillText[i] = "R + Ignite = kill"
			elseif Wdmg + Qdmg > enemy.health then
				KillText[i] = "W + Q = kill"
			elseif Wdmg + Qdmg + Idmg > enemy.health then
				KillText[i] = "W + Q + Ignite = kill"
			elseif Qdmg + Rdmg > enemy.health then
				KillText[i] = "Q + R = kill"
			elseif Qdmg + Rdmg + Idmg > enemy.health then
				KillText[i] = "Q + R + Ignite = kill"
			elseif Wdmg + Rdmg > enemy.health then
				KillText[i] = "W + R = kill"
			elseif Wdmg + Rdmg + Idmg > enemy.health then
				KillText[i] = "W + R + Ignite = kill"
			elseif Qdmg + Rdmg + Wdmg > enemy.health then
				KillText[i] = "Q + W + R = kill"
			elseif Qdmg + Rdmg + Wdmg + Idmg > enemy.health then
				KillText[i] = "Full combo = kill"
			else
				KillText[i] = "Harass him!"
			end
		end
	end
end

function SpellChecks()
	Spells.Q.ready = (myHero:CanUseSpell(Game.Slots.SPELL_1) == Game.SpellState.READY)
	Spells.W.ready = (myHero:CanUseSpell(Game.Slots.SPELL_2) == Game.SpellState.READY)
	Spells.E.ready = (myHero:CanUseSpell(Game.Slots.SPELL_3) == Game.SpellState.READY)
	Spells.R.ready = (myHero:CanUseSpell(Game.Slots.SPELL_4) == Game.SpellState.READY)

	Hready = (heal ~= nil and myHero:CanUseSpell(heal) == Game.SpellState.READY)	
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == Game.SpellState.READY)
end 

function FindSummoners() 
	heal = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerheal") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerheal") and Game.Slots.SUMMONER_2
	ignite = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerdot") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerdot") and Game.Slots.SUMMONER_2
end


-- Thanks BilGod for reducing my code to only 7 lines 
function FindJunglers()
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if (hero:GetSpellData(Game.Slots.SUMMONER_1).name:find("smite") or hero:GetSpellData(Game.Slots.SUMMONER_2).name:find("smite")) then
			table.insert((hero.team == myHero.team and allyJunglers) or enemyJunglers, hero)
    	end
	end 
end 

function AutoR()
	if not CanAutoR() then return end
	local position, enemyCount = CountEnemiesWithinRadius(Spells.R.range, Spells.R.radius)
	if enemyCount >= Menu.autoR.amount:Value() then
		if position ~= nil then
			myHero:CastSpell(Game.Slots.SPELL_4, position.x, position.z)
		end
	end  
end

function CanAutoR()
	if Menu.autoR.optional.useOptional:Value() == true then
		return CountAllies(Menu.autoR.optional.alliesrange:Value()) >= Menu.autoR.optional.allies:Value()
	end
	return true
end

function CountEnemiesWithinRadius(range, radius)
	local normalCount = 0
	local enemyCount = 0
	local position = nil
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team and myHero:DistanceTo(hero) < range and hero.type == myHero.type then
			enemyCount = 1
			for i = 1, Game.HeroCount(), 1 do
				local otherHero = Game.Hero(i)
				if otherHero ~= hero and otherHero.team ~= myHero.team and otherHero.type == myHero.type then
					if hero:DistanceTo(otherHero) < radius then
						enemyCount = enemyCount + 1
					end
				end
			end
		end
		if enemyCount > normalCount then
			normalCount = enemyCount
			position = hero.pos
		end
		if enemyCount == 5 then
			break
		end 
	end
	return position, normalCount
end

function CanComboR()
	if Menu.combo.rsettings.mode:Value() == 1 then
		return true
	elseif Menu.combo.rsettings.mode:Value() == 2 then
		if target.health >= CalculateDamage("R", target) then
			return false
		end 
	elseif Menu.combo.rsettings.mode:Value() == 3 then
		if not canStun then return false end
	end
	return true
end 

function CountAllies(range)
	local range = range or Spells.Q.range
	local count = 0
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if hero.team == myHero.team then
			if myHero:DistanceTo(hero) <= range then
				count = count + 1
			end
		end
	end
	return count
end 

function AutoIgnite()
	for i = 1, Game.HeroCount() do 
		hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			if Iready and Menu.misc.autoignite[hero.charName]:Value() == true and hero.health < GetIgniteDamage() then
				myHero:CastSpell(ignite, hero)
			end
		end
	end
end

function AutoHeal()
	if myHero.health / myHero.maxHealth < Menu.misc.autoheal.hpPerc:Value() and Hready then
		CastSpell(heal)
	end
	if Menu.misc.autoheal.helpTeammate:Value() == true then
		for i = 1, Game.HeroCount(), 1 do
			local hero = Game.Hero(i)
			if hero.team == myHero.team and Menu.misc.autoheal.teammates[hero.charName]:Value() then
				if hero.health / hero.maxHealth <= Menu.misc.autoheal.hpPerc:Value() and Hready then
					myHero:CastSpell(heal)
				end
			end
		end
	end
end 

function GetIgniteDamage()
	return (50 + (20 * myHero.level))
end 

function ValidTarget(target)
	return target.team ~= myHero.team and not target.dead and target.type == myHero.type
end

function CalculateDamage(skill, target)
	local dmg = 0
	if skill == "Q" then
		dmg = 35 * myHero:GetSpellData(Game.Slots.SPELL_1).level + 45 + .8 * myHero.ap
	elseif skill == "W" then
		dmg = 45 * myHero:GetSpellData(Game.Slots.SPELL_2).level + 25 + .85 * myHero.ap
	elseif skill == "E" then
		dmg = 0
	elseif skill == "R" then
		dmg = math.max(125 * myHero:GetSpellData(Game.Slots.SPELL_4).level + 50 + .8 * myHero.ap)
	end
	return myHero:CalcMagicDamage(target, dmg)
end

function DrawMenu()
	Menu = MenuConfig("Annie - The Qtpie")
	local name = "Annie - " 

	-- Combo
	Menu:Menu("combo", name ..  "Combo")
	Menu.combo:KeyBinding("combo", "Combo Key", "SPACE")
	Menu.combo:DropDown("comboWay", "Combo", 1, {"QWR", "QRW", "WQR", "WRQ", "RQW", "RWQ"})
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboW", "Use " .. Spells.W.name .. " (Q)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Menu("rsettings", "R Settings")
	Menu.combo.rsettings:DropDown("mode", "R Cast Mode", 1, {"Instantly", "Killable", "Stun"})

	-- Auto R
	Menu:Menu("autoR", name .. "Auto R")
	Menu.autoR:Menu("optional", "Optional Settings")
	Menu.autoR.optional:Boolean("useOptional", "Use Optional Settings", true)
	Menu.autoR.optional:Slider("allies", "Min Allies Nearby", 3, 0, 5, 1)
	Menu.autoR.optional:Slider("alliesrange", "Range of enemies", 500, 0, 2000, 100)
	Menu.autoR:Boolean("autoUlt", "Use Automatic R", true)
	Menu.autoR:Slider("amount", "Min targets", 3, 1, 5, 1)

	-- Harass
	Menu:Menu("harass", name .. "Harass")
	Menu.harass:KeyBinding("harass", "Harass Key", "T")
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassR", "Use " .. Spells.R.name .. " (R)", true)

	Menu:Menu("autokill", name .. "Autokill")
	Menu.autokill:Boolean("autokill", "Perform AutoKill", false)
	Menu.autokill:Boolean("autokillQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.autokill:Boolean("autokillW", "Use " .. Spells.W.name .. " (Q)", true)
	Menu.autokill:Boolean("autokillR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.autokill:Boolean("autokillIgnite", "Use IGNITE", true)

	-- Farm
	Menu:Menu("farm", name .. "Farm")
	Menu.farm:KeyBinding("farm", "Farm Key", "K")
	Menu.farm.farm:Toggle(true)
	Menu.farm:Boolean("farmQ", "Use" .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmW", "Use" .. Spells.W.name .. " (Q)", true)

	-- Laneclear
	Menu:Menu("laneclear", name .. "Laneclear")
	Menu.laneclear:KeyBinding("laneclear", "Harass Key", "K")
	Menu.laneclear:Boolean("laneclearQ", "Use" .. Spells.Q.name .. " (Q)", true)
	Menu.laneclear:Boolean("laneclearW", "Use" .. Spells.W.name .. " (Q)", true)


	-- Drawings
	Menu:Menu("draw", name .. "Drawings")
	Menu.draw:Boolean("useDrawings", "Draw", true)
	Menu.draw:Boolean("drawQ", "Draw " .. Spells.Q.name .. " range", true)
	Menu.draw:Boolean("drawW", "Draw " .. Spells.W.name .. " range", true)
	Menu.draw:Boolean("drawR", "Draw " .. Spells.R.name .. " range", true)
	Menu.draw:Boolean("drawKilltext", "Draw KillText", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")

	Menu.misc:Menu("autoE", "Auto E")
	Menu.misc.autoE:Boolean("onAA", "Auto E when attacked", false)
	Menu.misc.autoE:Boolean("stackStun", "Auto E to stack stun", false)

	if ignite ~= nil then
		Menu.misc:Menu("autoignite", "Auto Ignite")
		Menu.misc.autoignite:Boolean("useIgnite", "Automatically Use Ignite", false)
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
			if hero.team ~= myHero.team then
				Menu.misc.autoignite:Boolean(hero.charName, "Use Ignite on " .. hero.charName, true)
			end
		end
	end

	if heal ~= nil then
		Menu.misc:Menu("autoheal", "Auto Heal")
		Menu.misc.autoheal:Boolean("useHeal", "Automatically use Heal", true)
		Menu.misc.autoheal:Slider("hpPerc", "Min percentage to cast Heal", 0.15, 0, 1, 0.01)
		Menu.misc.autoheal:Boolean("helpTeammate", "Use Heal to Help teammates", false)
		Menu.misc.autoheal:Menu("teammates", "Teammates to Heal")
		for i = 1, Game.HeroCount(), 1 do
			local hero = Game.Hero(i)
			if hero.team == myHero.team and not hero.isMe then
				Menu.misc.autoheal.teammates:Boolean(hero.charName, "Use Heal on " .. hero.charName, true)
			end
		end
	end

	Menu.misc:Menu("autopotions", "Auto Potions")
	Menu.misc.autopotions:Boolean("usePotions", "Automatically Use Potions", true)
	Menu.misc.autopotions:Boolean("useHealthPotion", "Use Health Potion", true)
	Menu.misc.autopotions:Slider("hpPerc", "Min Health % to use Potion", 0.60, 0, 1, 0.01)
	Menu.misc.autopotions:Boolean("useManaPotion", "Use Mana Potion", true)
	Menu.misc.autopotions:Slider("manaPerc", "Min Mana % to use Potion", 0.60, 0, 1, 0.01)

	ts:LoadToMenu(Menu)
end

function GetItemSlot(id, unit)
	local unit = unit or myHero
	for i = 4, 9, 1 do
		if unit:GetItem(i) and unit:GetItem(i).id == id then
			return i
		end
	end
end

function CastItem(ItemID, var1, var2)
	local slot = GetItemSlot(ItemID)
	if slot == nil then return end
	if (myHero:CanUseSpell(slot) == Game.SpellState.READY) then
		if (var2 ~= nil) then
			myHero:CastSpell(slot, var1, var2)
		elseif (var1 ~= nil) then
			myHero:CastSpell(slot, var1)
		else
			myHero:CastSpell(slot)
		end
	end
end


class 'TargetSelector'

TargetSelector_Modes = {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"}
function TargetSelector:__init(mode, range)
	self.mode = mode
	self.range = range
end

function TargetSelector:GetTarget(range)
	local range = range and range or self.range
	local target = nil
	if self.menu then
		self.mode = self.menu.targetselector.mode:Value()
	end
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team and myHero:DistanceTo(hero) < range then
			if target == nil then
				target = hero
			end
			if self.mode == "LESS_HP" then
				if target.health > hero.health then
					target = hero
				end
			elseif self.mode == "LESS_AD" then
				if target.ad > hero.ad then
					target = hero
				end
			elseif self.mode == "LESS_AP" then
				if target.ap > hero.ap then
					target = hero
				end
			elseif self.mode == "MOST_DAMAGE" then
				if myHero:CalcDamage(target) > myHero:CalcDamage(hero) then
					target = hero
				end 
			elseif self.mode == "PRIORITY" then
				if self.menu.targetselector[hero.charName]:Value() < self.menu.targetselector[target.charName]:Value() then
					target = hero
				end
			end
		end
	end

	return target
end

function TargetSelector:LoadToMenu(menu)
	self.menu = menu
	self.menu:Menu("targetselector", "TargetSelector")
	if self.mode == "LESS_HP" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 1, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE"})
	elseif self.mode == "LESS_AD" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 2, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE"})
	elseif self.mode == "LESS_AP" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 3, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE"})
	elseif self.mode == "MOST_DAMAGE" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 4, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE"})
	end
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if myHero.team ~= hero.team then
			self.menu.targetselector:Slider(hero.charName, hero.charName, 1, 0, 5, 0)
		end
	end
end


function TargetSelector:Mode(mode)
	if not mode then return self.mode end
	self.mode = mode
end


