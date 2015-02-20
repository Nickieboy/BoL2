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
local _Q = Game.Slots.SPELL_1
local _W = Game.Slots.SPELL_2
local _E = Game.Slots.SPELL_3
local _R = Game.Slots.SPELL_4
local _S1 = Game.Slots.SUMMONER_1
local _S2 = Game.Slots.SUMMONER_2
local READY = Game.SpellState.READY
local DrawCirc = Graphics.DrawCircle


-- Initializing Classes
class 'Annie'
class 'Swain'
class 'Leblanc'
class 'Blitzcrank'
class 'Ryze'
class 'Lux'
class 'Morgana'
class 'Katarina'

local champ = nil
local activeClass = nil
local champions = {
						["Annie"] = "The Pedobear",--Annie(), 
						["Swain"] = "The Bird Scarer", 
						["Leblanc"] = "The Magnificent",
						["Blitzcrank"] = "The Hooker",
						["Ryze"] = "The Monk",
						["Lux"] = "The Eyehurter",
						["Morgana"] = "The Victorius",
						["Katarina"] = "The Assasinnator"
					}


function Say(text)
	printChat("<font color=\"#FF0000\"><b>Totally Series:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

Callback.Bind("Load", function()
	Callback.Bind("GameStart", function() OnLoad() end)
end)

function OnLoad()
	-- Checking whether the champions is supported
	if champions[myHero.charName] ~= nil then
		champ = myHero.charName
		-- Letting user know his champ is supported
		Say("Loading...")
 	else
 		return Say("Your champion is not supported in this series. You can try and request it on the thread.") 
 	end

	-- Making Menu cooler for naming it Totally + the supported champions
	-- Equals: Totally Annie, Totally Lux, ...
	name = "Totally " .. champ .. " - "

	-- Global Variables - Used with every champion
	InitializeGlobalVariables()

	-- Calling correct class
	if champ == "Annie" then
		activeClass = Annie()
	elseif champ == "Leblanc" then
		activeClass = Leblanc()
	elseif champ == "Blitzcrank" then
		activeClass = Blitzcrank()
	elseif champ == "Ryze" then
		activeClass = Ryze()
	elseif champ == "Lux" then
		activeClass = Lux()
	elseif champ == "Katarina" then
		activeClass = Katarina()
	end

	-- Drawing here because Spells are initialized within the class, so the class has to been called first
	DrawGlobalDrawings()

	-- Misc loading at the bottom, because it being on top of menu is stupido
	DrawGlobalMisc()

	-- Normal Callbacks used for every script
	Callback.Bind("Tick", function() OnTick() end)
	Callback.Bind("Draw", function() OnDraw() end)
	Callback.Bind("CreateObj", function(obj) OnCreateObj(obj) end)
	Callback.Bind("DeleteObj", function(obj) OnDeleteObj(obj) end)

	-- Script succesfully loaded, enjoy.
	Say("Welcome " Core.GetUser() . ", " . ". The script - " . champions[myHero.charName] . " - was succesfully loaded. Enjoy playing with the Series. If you have any kind of advise, make a detailed post on the post. If are there any bugs, explain in de detail what error was and what you were doing at that time. ")
end


function OnTick()
	SpellChecks()
	target = ts:GetTarget(Spells.Q.range)

	if Menu.comboKey:IsPressed() == true then
		if target ~= nil and Menu.combo.comboItems then
			UseItems(target)
		end
		activeClass:Combo()
	end

	if Menu.harassKey:IsPressed() == true then
		activeClass:Harass()
	end

	if heal ~= nil and Menu.misc.autoheal.useHeal:Value() == true and not isRecalling then
		AutoHeal()
	end

	if ignite ~= nil and Menu.misc.autoignite.useIgnite:Value() == true then
		AutoIgnite()
	end

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

	if Menu.misc.autolevel.autolevel:Value() == true then
		AutoLevel()
	end

	if Menu.misc.zhonyas.zhonyas:Value() == true then
		Zhonyas()
	end
end

function OnCreateObj(obj)
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

function OnDraw()
	if myHero.dead then return end
	if Menu.useDrawings:Value() == true then
		if Spells.Q.range and Menu.draw.drawQ:Value() == true then
			DrawCirc(myHero.x, myHero.y, myHero.z, Spells.Q.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Spells.W.range and Menu.draw.drawW:Value() == true then
			DrawCirc(myHero.x, myHero.y, myHero.z, Spells.W.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Spells.E.range and Menu.draw.drawE:Value() == true then
			DrawCirc(myHero.x, myHero.y, myHero.z, Spells.E.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Spells.R.range and Menu.draw.drawR:Value() == true then
			DrawCirc(myHero.x, myHero.y, myHero.z, Spells.R.range, Graphics.RGB(100, 200, 150):ToNumber())
		end
	end
end

function InitializeGlobalVariables()
	-- Item Table
	-- Copied from 1.0 (Obviously remains the same in 2.0)	
	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}

	-- Summoners
	ignite, heal = nil, nil
	Iready, Hready = false, false

	--Target
	target = nil

	-- Potions and Recalling
	usingHealthPot, usingManaPot, isRecalling = false, false, false

	-- Making table for KillText
	KillText = {}

	-- Soon™
	--EnemyMinions = MinionManager.new(MinionManager.Mode.ENEMY, Spells.W.range, myHero, MinionManager.Sort.HEALTH_DEC)

	-- Find the slot of the Summoners
	FindSummoners() 

	-- Loop through table to find enemy heroes, to improve performance later
	EnemyTable = GetEnemyHeroes()

	-- LevelUp Table (For AutoLevel)
	levelUpTable = {
				{_Q, _W, _E, _R},
				{_Q, _E, _W, _R},
				{_W, _Q, _E, _R},
				{_W, _E, _Q, _R},
				{_E, _Q, _W, _R},
				{_E, _W, _Q, _R}
	}

	-- For Autolevel
	lastLevel = myHero.level - 1

	-- Draw Menu Globally (Menu used by every script)
	DrawGlobalMenu()

end


function SpellChecks()
	Hready = (heal ~= nil and myHero:CanUseSpell(heal) == READY)	
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end 

function FindSummoners()
	heal = myHero:GetSpellData(_S1).name:find("summonerheal") and _S1 or myHero:GetSpellData(_S2).name:find("summonerheal") and _S2
	ignite = myHero:GetSpellData(_S1).name:find("summonerdot") and _S1 or myHero:GetSpellData(_S2).name:find("summonerdot") and _S2
end

function AutoIgnite()
	for i, hero in ipairs(EnemyTable) do
		if Iready and Menu.misc.autoignite[hero.charName]:Value() == true and hero.health < GetIgniteDamage() then
			myHero:CastSpell(ignite, hero)
		end
	end
end

function AutoHeal()
	if myHero.health / myHero.maxHealth <= Menu.misc.autoheal.hpPerc:Value() and Hready then
		myHero:CastSpell(heal)
	end
	if Menu.misc.autoheal.helpTeammate:Value() == true then
		for i, hero in ipairs(EnemyTable) do
			if Menu.misc.autoheal.teammates[hero.charName]:Value() then
				if hero.health / hero.maxHealth <= Menu.misc.autoheal.hpPerc:Value() and Hready then
					myHero:CastSpell(heal)
				end
			end
		end
	end
end 

function Zhonyas()
	if Menu.misc.zhonyas.zhonyasunder:Value() >= myHero.health / myHero.maxHealth then
		CastItem(3157)
	end
end

function GetIgniteDamage()
	return (50 + (20 * myHero.level))
end 

function DrawFont(msg)
	return '<font color="#99EBD6">' .. tostring(msg) .. '</font>' 
end

function DrawGlobalMenu()
	Menu = MenuConfig("TotallySeries" .. champ, "Totally Series " .. champ):Icon("fa-hand-o-right")

	Menu:Section("info", DrawFont("Script Info"))
	Menu:Info("script", "Loaded: <i><font color=\"#99B2FF\">Totally " .. champ .. "</font></i>")
	Menu.script:Icon("fa-info")
	Menu:Info("author", "Author: <i><font color=\"#99B2FF\">Totally Legit</font></i>")
	Menu.author:Icon("fa-info")

	Menu:Section("keybindingSection", DrawFont("Key Bindings"))
	Menu:KeyBinding("comboKey", "Combo Key", "SPACE")
	Menu:KeyBinding("harassKey", "Harass Key", "T")
	Menu:KeyBinding("farmKey", "Farm Key", "K")
	Menu:KeyBinding("laneclearKey", "LaneClear Key", "L")

	-- Drawings
	Menu:Section("drawingSection", DrawFont("Draw Settings"))
	Menu:Boolean("useDrawings", "Draw", true)
	Menu:Menu("draw", "Drawings")
	Menu.draw:Icon("fa-eye")

	-- Fight Settings
	Menu:Section("comboSection", DrawFont("Fight Settings"))
	
	Menu:Menu("combo", "Combo")
	Menu.combo:Icon("fa-bomb");
	Menu.combo:Boolean("comboItems", "Use Items", true)

	-- Harass
	Menu:Menu("harass", "Harass")
	Menu.harass:Icon("fa-bomb");

	-- KillSteal
	Menu:Menu("killsteal", "KillSteal")
	Menu.killsteal:Icon("fa-bullseye")
	Menu.killsteal:Section("killstealSection1", DrawFont("Activation"))
	Menu.killsteal:Boolean("killsteal", "Perform KillSteal", false)
	Menu.killsteal:Section("killstealSection2", DrawFont("Spell Settings"))


	Menu:Section("farmSection", DrawFont("Farming Settings"))
	-- Farming
	Menu:Menu("farm", "Farming")
	-- Laneclear
	Menu:Menu("laneclear", "LaneClear")


	Menu:Section("spellspecific", DrawFont("Champ Specific Settings"))

end

-- Drawing Global Misc Settings -- Same in every script --
function DrawGlobalMisc()
	-- Misc Icon
	Menu.misc:Icon("fa-star-o")


	-- Ignite
	if ignite ~= nil then
		Menu.misc:Menu("autoignite", "Auto Ignite")
		Menu.misc.autoignite:Boolean("useIgnite", "Automatically Use Ignite", false)
		for i, hero in ipairs(EnemyTable) do
			Menu.misc.autoignite:Boolean(hero.charName, "Use Ignite on " .. hero.charName, true)
		end
	end

	-- Heal
	if heal ~= nil then
		Menu.misc:Menu("autoheal", "Auto Heal")
		Menu.misc.autoheal:Icon("fa-heart")
		Menu.misc.autoheal:Boolean("useHeal", "Automatically use Heal", true)
		Menu.misc.autoheal:Slider("hpPerc", "Min percentage to cast Heal", 0.15, 0, 1, 0.01)
		Menu.misc.autoheal:Boolean("helpTeammate", "Use Heal to Help teammates", false)
		Menu.misc.autoheal:Menu("teammates", "Teammates to Heal")
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
			if hero.team == myHero.team and not hero.isMe then
				Menu.misc.autoheal.teammates:Boolean(hero.charName, "Use Heal on " .. hero.charName, true)
			end
		end
	end 

	-- AutoPotions
	Menu.misc:Menu("autopotions", "Auto Potions")
	Menu.misc.autopotions:Icon("fa-heart")
	Menu.misc.autopotions:Boolean("useHealthPotion", "Use Health Potion", true)
	Menu.misc.autopotions:Slider("hpPerc", "Min Health % to use Potion", 0.60, 0, 1, 0.01)
	Menu.misc.autopotions:Boolean("useManaPotion", "Use Mana Potion", true)
	Menu.misc.autopotions:Slider("manaPerc", "Min Mana % to use Potion", 0.60, 0, 1, 0.01)

	-- Zhonyas
	Menu.misc:Menu("zhonyas", "Zhonyas")
 	Menu.misc.zhonyas:Boolean("zhonyas", "Auto Zhonyas", true)
 	Menu.misc.zhonyas:Slider("zhonyasunder", "Use Zhonyas under % health", 0.20, 0, 1, 2)

 	-- Auto Leveling
	Menu.misc:Menu("autolevel", "Auto Level Skills")
	Menu.misc.autolevel:Boolean("autolevel", "Auto Level Spells", false)
	Menu.misc.autolevel:Section("level1", DrawFont("Level 1 - 4"))
	Menu.misc.autolevel:DropDown("level1sequence", "Level sequence", 1, {"Q-W-E-R", "Q-E-W-R", "W-Q-E-R", "W-E-Q-R", "E-Q-W-R", "E-W-Q-R"})
	Menu.misc.autolevel:Section("level2", DrawFont("Level 4 - 18"))
	Menu.misc.autolevel:DropDown("level2sequence", "Level sequence", 1, {"Q-W-E-R", "Q-E-W-R", "W-Q-E-R", "W-E-Q-R", "E-Q-W-R", "E-W-Q-R"})
end

-- Global Drawing settings -- Same in every script -- obv
function DrawGlobalDrawings()
	Menu.draw:Section("drawingSection2", DrawFont("Spell Settings"))
	Menu.draw:Boolean("drawQ", "Draw " .. Spells.Q.name .. " range", true)
	Menu.draw:Boolean("drawW", "Draw " .. Spells.W.name .. " range", true)
	Menu.draw:Boolean("drawE", "Draw " .. Spells.E.name .. " range", true)
	Menu.draw:Boolean("drawR", "Draw " .. Spells.R.name .. " range", true)
end

function AutoLevel()
	if myHero.level > lastLevel then
		if lastLevel <= 4 then
			for i = 1, #levelUpTable[Menu.misc.autolevel.level1sequence:Value()], 1 do
				local slot = levelUpTable[Menu.misc.autolevel.level1sequence:Value()][i]
				Game.LevelSpell(slot)
			end
		else 
			for i = 1, #levelUpTable[Menu.misc.autolevel.level1sequence:Value()], 1 do
				local slot = levelUpTable[Menu.misc.autolevel.level2sequence:Value()][i]
				Game.LevelSpell(slot)
			end
		end
		lastLevel = myHero.level
	end
end




--[[

		Script details:
			Champion: Annie
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 1.0	

		Changelog:
			1.0:
				Released champ
			1.1:
				Now included in AIO format
--]]
function Annie:__init()

	Spells = {
		["Q"] = {name = "Disintegrate", range = 625, ready = false},
		["W"] = {name = "Incinerate", range = 625, ready = false},
		["E"] = {name = "Molten Shield", ready = false},
		["R"] = {name = "Summon: Tibbers", range = 600, radius = 150, delay = 0.25, ready = false, speed = math.huge}
	}

	self.canStun = false
	self.passiveStacks = 0
	self.hasTibbers = false

	self.Q = Spell(_Q, Spells.Q.range)
	self.W = Spell(_W, Spells.W.range)
	self.E = Spell(_E)
	self.R = Spell(_R, Spells.R.range)
	--self.R:SetSkillShot(Spells.R.delay, Spells.R.radius, Spells.R.speed, false, "aoe")

	self:ExtraMenu()

	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 
	--BasicPrediction.EnablePrediction()
	

	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("CreateObj", function(obj) self:OnCreateObj(obj) end)
	Callback.Bind("DeleteObj", function(obj) self:OnDeleteObj(obj) end)
	Callback.Bind("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)
	Callback.Bind("Draw", function() self:OnDraw() end)
	Callback.Bind("GainBuff", function(unit, buff) self:OnGainBuff(unit, buff) end)
	Callback.Bind("LoseBuff", function(unit, buff) self:OnLoseBuff(unit, buff) end)
end

function Annie:OnTick()
	self:CalcDamageCalculations()

	if Menu.autokill.autokill:Value() == true then
		self:AutoKill()
	end 

	if Menu.autoR.autoUlt:Value() == true then
		self:AutoR()
	end
end


function Annie:OnCreateObj(obj)
	if obj.name == "StunReady.troy" and myHero:DistanceTo(obj) < 50 then
        self.canStun = true
    end
end

function Annie:OnDeleteObj(obj)
	if obj.name == "StunReady.troy" and myHero:DistanceTo(obj) < 50 then
        self.canStun = false
    end
end

function Annie:OnProcessSpell(unit, spell)
	if spell.target == myHero and string.find(spell.name, "BasicAttack") and unit.type == "Obj_AI_Hero" and Menu.misc.autoE.onAA:Value() == true then
	    self.E:Cast()
	end
end

function Annie:OnGainBuff(unit, buff)
	if unit.isMe and (buff.name == "infernalguardiantimer") then
		self.hasTibbers = true
	end
end

function Annie:OnLoseBuff(unit, buff)
	if unit.isMe and (buff.name == "infernalguardiantimer") then
		self.hasTibbers = false
	end
end

function Annie:OnDraw()
	if myHero.dead then return end
	if Menu.draw.drawKilltext:Value() == true then
		for i, enemy in ipairs(EnemyTable) do
			if ValidTarget(enemy) then
				local barPos = Graphics.WorldToScreen(Geometry.Vector3(enemy.x, enemy.y, enemy.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 50  
				Graphics.DrawText(KillText[i], 15, PosX, PosY, Graphics.ARGB(255,255,204,0))
			end
		end
	end
end

function Annie:Combo()
	if target ~= nil then
		if Menu.combo.comboItems:Value() == true then
			UseItems(target)
		end
		if Menu.combo.comboWay:Value() == 1 then
			self:ExecuteCombo({"Q", "W", "R"}, target)
		elseif Menu.combo.comboWay:Value() == 2 then
			self:ExecuteCombo({"Q", "R", "W"}, target)
		elseif Menu.combo.comboWay:Value() == 3 then
			self:ExecuteCombo({"W", "Q", "R"}, target)
		elseif Menu.combo.comboWay:Value() == 4 then
			self:ExecuteCombo({"W", "R", "Q"}, target)
		elseif Menu.combo.comboWay:Value() == 5 then
			self:ExecuteCombo({"R", "Q", "W"}, target)
		elseif Menu.combo.comboWay:Value() == 6 then
			self:ExecuteCombo({"R", "W", "Q"}, target)
		end
	end
end


function Annie:ExecuteCombo(comboTable, target)
	for i, combo in ipairs(comboTable) do
		if ValidTarget(target) then
			if combo == "Q" then
				self.Q:Cast(target)
			elseif combo == "W" then
				self.W:Cast(target)
			elseif combo == "E" then
				self.E:Cast()
			elseif combo == "R" then
				self.R:Cast(target)
			end 
		end
	end
end

function Annie:Harass()
	if target ~= nil then
		if Menu.harass.harassQ:Value() then
			self.Q:Cast(target)
		end 

		if Menu.harass.harassW:Value() then
			self.W:Cast(target)
		end 

	end
end

function Annie:CanComboR()
	if Menu.combo.rsettings.mode:Value() == 1 then
		return true
	elseif Menu.combo.rsettings.mode:Value() == 2 then
		if target.health >= CalculateAPDamage("R", 125, 50, 0.8, target) then
			return false
		end 
	elseif Menu.combo.rsettings.mode:Value() == 3 then
		if not canStun then return false end
	end
	return true
end

function Annie:AutoKill()
	if myHero.dead then return end
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) and myHero:DistanceTo(enemy) < Spells.Q.range then
			local Qdmg = (((Menu.autokill.autokillQ:Value() == true) and self.Q:CanCast() and CalculateAPDamage("Q", 35, 45, 0.8, enemy)) or 0)
			local Wdmg = (((Menu.autokill.autokillW:Value() == true) and self.W:CanCast()  and CalculateAPDamage("W", 45, 25, 0.85, enemy)) or 0)
			local Rdmg = (((Menu.autokill.autokillR:Value() == true) and self.E:CanCast()  and not self.hasTibbers and CalculateAPDamage("R", 125, 50, 0.8, enemy)) or 0)
			local Idmg = (((Menu.autokill.autokillIgnite:Value() == true) and Iready and GetIgniteDamage()) or 0)

			if Wdmg > Qdmg and Qdmg > enemy.health and self:HasMana("Q") then
				self.Q:Cast(target)
			elseif Wdmg > enemy.health and self:HasMana("W") then
				self.W:Cast(target)
			elseif Qdmg + Wdmg > enemy.health and self:HasMana("QW") then
				self.Q:Cast(target)
				self.W:Cast(target)
			elseif ignite ~= nil and Qdmg + Wdmg + Idmg > enemy.health and self:HasMana("QW") then
				myHero:CastSpell(ignite, enemy)
				self.Q:Cast(target)
				self.W:Cast(target)
			elseif Wdmg > Qdmg and Qdmg + Rdmg > enemy.health and self:HasMana("QR") then
				self.Q:Cast(target)
				self.R:Cast(target)
			elseif Wdmg + Rdmg > enemy.health and self:HasMana("WR") then
				self.W:Cast(target)
				self.R:Cast(target)
			elseif ignite ~= nil and Wdmg > Qdmg and Qdmg + Rdmg + Idmg > enemy.health and self:HasMana("QR") then
				myHero:CastSpell(ignite, enemy)
				self.Q:Cast(target)
				self.R:Cast(target)
			elseif ignite ~= nil and Wdmg + Rdmg + Idmg > enemy.health and self:HasMana("WR") then
				myHero:CastSpell(ignite, enemy)
				self.W:Cast(target)
				self.R:Cast(target)
			elseif Qdmg + Rdmg + Wdmg > enemy.health and self:HasMana("QWR") then
				self.Q:Cast(target)
				self.W:Cast(target)
				self.R:Cast(target) 
			elseif ignite ~= nil and Qdmg + Rdmg + Wdmg + Idmg > enemy.health and self:HasMana("QWR") then
				myHero:CastSpell(ignite, enemy)
				self.Q:Cast(target)
				self.W:Cast(target)
				self.R:Cast(target)
			end 
		end 
	end 
end 

function Annie:HasMana(input)
	if input == "Q" then
		return myHero.mana > myHero:GetSpellData(_Q).mana
	elseif input == "W" then
		return myHero.mana > myHero:GetSpellData(_W).mana
	elseif input == "E" then
		return myHero.mana > myHero:GetSpellData(_E).mana
	elseif input == "R" then
		return myHero.mana > myHero:GetSpellData(_R).mana
	elseif input == "QW" then
		return myHero.mana > (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana)
	elseif input == "QR" then
		return myHero.mana > (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana)
	elseif input == "WR" then
		return myHero.mana > (myHero:GetSpellData(_W).mana + myHero:GetSpellData(_R).mana)
	elseif input == "QWR" then
		return myHero.mana > (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana + myHero:GetSpellData(_R).mana)
	end
	return true
end

function Annie:AutoR()
	if not self:CanAutoR() then return end
	local position, enemyCount = CountEnemiesWithinRadius(Spells.R.range, Spells.R.radius)
	if enemyCount >= Menu.autoR.amount:Value() then
		if position ~= nil then
			self.R:Cast(target, position.x, position.z)
		end
	end  
end

function Annie:CanAutoR()
	if Menu.autoR.optional.useOptional:Value() == true then
		return CountAllies(Menu.autoR.optional.alliesrange:Value()) >= Menu.autoR.optional.allies:Value()
	end
	return true
end

function Annie:CalcDamageCalculations()
	if myHero.dead then return end
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = ((self.Q:CanCast() and CalculateAPDamage("Q", 35, 45, 0.8, enemy)) or 0)
			local Wdmg = ((self.W:CanCast()  and CalculateAPDamage("W", 45, 25, 0.85, enemy)) or 0)
			local Rdmg = ((self.R:CanCast()  and not self.hasTibbers and CalculateAPDamage("R", 125, 50, 0.8, enemy)) or 0)
			local Idmg = ((Iready and GetIgniteDamage()) or 0)
			if myHero:CalcDamage(enemy, myHero.totalDamage) > enemy.health then
				KillText[i] = "Murder him"
			elseif Idmg > enemy.health then
				KillText[i] = "Ignite = kill"
			elseif Qdmg > enemy.health then
				KillText[i] = "Q = kill"
			elseif Wdmg > enemy.health then
				KillText[i] = "W = kill"
			elseif Rdmg > enemy.health then
				KillText[i] = "R = kill"
			elseif Qdmg + myHero.totalDamage > enemy.health then
				KillText[i] = "Q + AA = kill"
			elseif Qdmg + Idmg > enemy.health then
				KillText[i] = "Q + Ignote = kill"
			elseif Wdmg + myHero.totalDamage > enemy.health then
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

function Annie:ExtraMenu()
	-- Combo
	Menu.combo:Section("comboSection", DrawFont("Spell Settings"))
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboW", "Use " .. Spells.W.name .. " (Q)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Section("comboSection2", DrawFont("Modes"))
	Menu.combo:DropDown("comboWay", "Combo", 1, {"QWR", "QRW", "WQR", "WRQ", "RQW", "RWQ"})
	Menu.combo:Menu("rsettings", "R Settings")
	Menu.combo.rsettings:DropDown("mode", "R Cast Mode", 1, {"Instantly", "Killable", "Stun"})

	-- Auto R
	Menu:Menu("autoR", name .. "Auto R")
	Menu.autoR:Icon("fa-fighter-jet")
	Menu.autoR:Section("autoRSection", DrawFont("Activation"))
	Menu.autoR:Boolean("autoUlt", "Use Automatic R", true)
	Menu.autoR:Section("autoRSection2", DrawFont("Optional"))
	Menu.autoR:Menu("optional", "Optional Settings")
	Menu.autoR.optional:Boolean("useOptional", "Use Optional Settings", true)
	Menu.autoR.optional:Slider("allies", "Min Allies Nearby", 3, 0, 5, 1)
	Menu.autoR.optional:Slider("alliesrange", "Range of enemies", 500, 0, 2000, 100)
	Menu.autoR:Slider("amount", "Min targets", 3, 1, 5, 1)

	-- Extra harass settings
	Menu.harass:Boolean("harassQ", Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassR", Spells.R.name .. " (R)", true)

	-- Autokill settings
	Menu:Menu("autokill", name .. "Autokill")
	Menu.autokill:Icon("fa-trophy")
	Menu.autokill:Section("autokillSection", DrawFont("Activation"))
	Menu.autokill:Boolean("autokill", "Perform AutoKill", false)
	Menu.autokill:Section("autokillSection2", DrawFont("Spell Settings"))
	Menu.autokill:Boolean("autokillQ", Spells.Q.name .. " (Q)", true)
	Menu.autokill:Boolean("autokillW", Spells.W.name .. " (W)", true)
	Menu.autokill:Boolean("autokillR", Spells.R.name .. " (R)", true)
	Menu.autokill:Boolean("autokillIgnite", "Use IGNITE", true)

	-- Farm
	Menu.farm:Boolean("farmQ", Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmW", Spells.W.name .. " (Q)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearQ ", Spells.Q.name .. " (Q)", true)
	Menu.laneclear:Boolean("laneclearW ", Spells.W.name .. " (Q)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("autoE", "Auto E")
	Menu.misc.autoE:Icon("fa-shield")
	Menu.misc.autoE:Boolean("onAA", "Auto E when attacked", false)
	Menu.misc.autoE:Boolean("stackStun", "Auto E to stack stun", false)


	--Draws
	Menu.draw:Section("sectionKillText", "Specific settings")
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)

	Menu.killsteal:Hide(true)


end



--[[

		Script details:
			Series: Totally Series AIO
			Champion: Swain
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]


function Swain:__init()
	Spells = {
		["Q"] = {name = "Decrepify", range = 625, radius = 0, delay = 0, speed = 0, ready = false},
		["W"] = {name = "Nevermore", range = 900, radius = 125, delay = 0.85, speed = math.huge, ready = false},
		["E"] = {name = "Torment", range = 625, radius = 0, delay = 0, speed = 1400, ready = false},
		["R"] = {name = "Ravenous Flock", range = 800, delay = 0, speed = 0, ready = false}
	}
	

	--BasicPrediction.EnablePrediction()
	self.RcastedThroughBot = false

	self.Q = Spell(_Q, Spells.Q.range)
	self.W = Spell(_W, Spells.W.range)
	self.W:SetSkillShot(Spells.W.delay, Spells.W.radius, Spells.W.speed, false, "aoe")
	self.E = Spell(_E, Spells.E.range)
	self.R = Spell(_R)

	self:ExtraMenu()
	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	Callback.Bind("Tick", function() self:OnTick() end)
	--Callback.Bind("CreateObj", function(obj) self:OnCreateObj(obj) end)
	--Callback.Bind("DeleteObj", function(obj) self:OnDeleteObj(obj) end)

end

function Swain:OnTick()
	if self.RcastedThroughBot and not Menu.combo.combo:IsPressed() and not Menu.laneclear.laneclear:IsPressed() and self:UltActive() and CountEnemies(Spells.R.range) < 1 then
 		myHero:CastSpell(_R)
 		self.RcastedThroughBot = false
 	end

	if myHero.dead and self.RcastedThroughBot then 
		self.RcastedThroughBot = false
	end

end


function Swain:Combo()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.comboItems:Value() == true then
			UseItems(target)
		end

		if Menu.combo.comboR:Value() == true and not self:UltActive() and CountEnemies(Spells.R.range) >= Menu.combo.comboRx:Value() then
			self.R:Cast()
		elseif Menu.combo.comboR:Value() == true and self:UltActive() and CountEnemies(Spells.R.range) < Menu.combo.comboRx:Value() then
			self.R:Cast()
		end
		if Menu.combo.comboE:Value() == true then
			self.E:Cast(target)
		end
		if Menu.combo.comboQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.combo.comboW:Value() == true then
			self.W:Cast(target)
		end
	else
		if self:UltActive() and CountEnemies(Spells.R.range) < Menu.combo.comboRx:Value() then
			self.R:Cast(target)
		end
	end
end

function Swain:Harass()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.harass.harassE:Value() == true then
			self.E:Cast(target)
		end

		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast(target)
		end

		if Menu.harass.harassW:Value() == true then
			self.W:Cast(target)
		end
	end
end

function Swain:UltActive()
	return (myHero:GetSpellData(_R).range + myHero:DistanceTo(myHero.minBBox)/2) > 60
end

function Swain:ExtraMenu()
	-- Combo
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Slider("comboRx", "Min amount of people nearby to cast R", 1, 0, 5, 0)

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- No Farm
	Menu.farm:Hide()

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")

end










--[[

		Script details:
			Series: Totally Series AIO
			Champion: LeBlanc
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]

function Leblanc:__init()
	Spells = 	{
					["P"] = {name = "LeBlanc_Base_P_poof.troy"},
					["AA"] = {range = 525, name = "BasicAttack"},
					["Q"] = {name = "Sigil of Malice", spellname = "LeblancChaosOrb", range = 700, speed = 2000, markTimer = 3.5, activated = 0}, 
					["W"] = {name = "Distortion", spellname = "LeblancSlide", range = 600, radius = 250, speed = 2000, delay = 0.25, duration = 4, timeActivated = 0, isActivated = false, startPos = myHero.pos}, 
					["E"] = {name = "Ethereal Chains", spellname = "LeblancSoulShackle", range = 950, speed = 1600, delay = 0.25, radius = 95}, 
					["R"] = {name = "Mimic", spellname = "LeblancMimic", Qname = "LeblancChaosOrbM", Wname = "LeBlancSlideM",  Wreturnname = "leblancslidereturnm", Ename = "LeblancSoulShackleM", ready = false},
					["WR"] = {duration = 4, spellname = "LeblancSlideM", timeActivated = 0, isActivated = false, startPos = myHero.pos}
				}

	-- Drawing LeBlancs Menu
	self:ExtraMenu()

	-- Initializing Spells
	self.Q = Spell(_Q, Spells.Q.range)
	self.W = Spell(_W, Spells.W.range)
	--self.W:SetSkillShot(Spells.W.delay, Spells.W.radius, Spells.W.speed, false, "aoe")
	self.E = Spell(_E, Spells.E.range)
	--self.E:SetSkillShot(Spells.E.delay, Spells.E.radius, Spells.E.speed, true, "normal")


	-- Initializing TargetSelector
	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	-- Last activated Spell
	self.lastActivated = nil

	-- Better combos
	self.comboTable = nil
	self.smartComboTime = os.clock()
	self.CanCastSpells = true

	-- Better smart W
	self.lastChainCast = os.clock()
	self.chainTarget = nil

			
	-- Regular Callback binds
	Callback.Bind("Tick", function() self:OnTick() end)
	--Callback.Bind("CreateObj", function(obj) self:OnCreateObj(obj) end)
	--Callback.Bind("DeleteObj", function(obj) self:OnDeleteObj(obj) end)
	Callback.Bind("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)
	Callback.Bind("Draw", function() self:OnDraw() end)
	Callback.Bind("ApplyBuff", function(unit, target, buff) self:OnApplyBuff(unit, target, buff) end)
	Callback.Bind("RemoveBuff", function(unit, buff) self:RemoveBuff(unit, buff) end)
	Callback.Bind("CastSpell", function(iSpell, startPos, endPos, targetUnit) self:OnCastSpell(iSpell,startPos,endPos,targetUnit) end)
end

function Leblanc:OnTick()
	self:RCheck()
	self:CalcDamageCalculations()

	-- Checking whether the last entry was longer than 3secs ago to make sure the data isnt oudated
	if self.CanCastSpell == false and self.smartComboTime + 3 > os.clock() then self.CanCastSpells = true end

	if Menu.settingsW.useOptional:Value() == true then
		self:SpecificSpellChecks()
	end

	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end
end

function Leblanc:RCheck()
	Spells.R.ready = (myHero:CanUseSpell(_R) == READY)
end

function Leblanc:OnProcessSpell(unit, spell)
	-- Smart W
	if unit.isMe and spell.name == Spells.W.spellname then
		Spells.W.startPos = spell.startPos
	end

	-- Smart W
	if unit.isMe and spell.name == Spells.WR.spellname then
		Spells.WR.startPos = spell.startPos
	end

	-- Smart W
	if unit.isMe and spell.name == Spells.E.name then
		self.lastChainCast = os.clock()
	end

	-- Smart Combo and KillSteal
	if unit.isMe and (spell.name == Spells.Q.spellname or spell.name == Spells.W.spellname or spell.name == Spells.E.spellname) then
    	self.lastActivated = spell.name
    end
end

function Leblanc:OnCastSpell(iSpell,startPos,endPos,targetUnit) 
	if iSpell == _R and not self.CanCastSpell then
		self.CanCastSpells = true 
		self.RSkill = nil
	end

end

function Leblanc:OnApplyBuff(unit, target, buff)
	if unit.isMe and ValidTarget(target) and buff.name == "" then
		self.chainTarget = target
	end
end

function Leblanc:RemoveBuff(unit, buff)
	if unit == self.chainTarget and buff.name == "" then
		self.chainTarget = nil
	end
end

function Leblanc:SpecificSpellChecks()

	-- Giving process time for the E Cast
	if self.lastChainCast + 2 < os.clock() then return end
	-- Checking whether the target has a chain 
	if self:wUsed() and self.chainTarget ~= nil and GetCustomDistance(Spells.W.startPos, chainTarget) <= Spells.E.range + 400 then return end 
	if self:wrUsed() and not self:wUsed() and self.chainTarget ~= nil and GetCustomDistance(Spells.WR.startPos, chainTarget) <= Spells.E.range + 400 then return end

	-- When there is no chain, entering functions
	if Menu.settingsW.useOptionalW:Value() == 1 then 
		if self:wUsed() and self:wrUsed() then
			if CountEnemies(600, Spells.WR.startPos) < CountEnemies(600) and not self.Q:CanCast()  and not self.E:CanCast() then
				self.W:Cast()
			end
		elseif self:wUsed() and CountEnemies(600, Spells.W.startPos) < CountEnemies(600) then
			self.W:Cast()
		elseif self:wrUsed() and CountEnemies(600, Spells.WR.startPos) < CountEnemies(600) then
			myHero:CastSpell(_R)
		end
	elseif Menu.settingsW.useOptionalW:Value() == 3 or Menu.settingsW.useOptionalW:Value() == 4 then
		if self:wUsed() and self:wrUsed() then
			if not self.Q:CanCast()  and not self.E:CanCast() then
				self.W:Cast()
			end
		elseif self:wUsed() then
			if not self.Q:CanCast() and not self.E:CanCast() then
				self.W:Cast()
			end
		elseif self:wrUsed() then
			if not self.Q:CanCast() and not self.E:CanCast() then
				myHero:CastSpell(_R)
			end
		end
	end
end


function Leblanc:Combo()
	if myHero.dead then return end
	-- Checking target
	if target ~= nil and ValidTarget(target) then

		-- Casting combo
		-- Getting time of last pick
		self.smartComboTime = os.clock()

		-- Making sure there aren't entries already - forcing R cast
		-- Have to do this because BoL is too fast 4 rito and therefore sometimes not casting R properly as it has a change delay
		if not self.CanCastSpells and self.RSkill ~= nil then
			if self.RSkill == "RQ" then
				self:CastR("Q", target)
			elseif self.RSkill == "RW" then
				self:CastR("W", target)
			end
			return
		end

		-- Not going inside the loop when the R is still being processed
		if self.CanCastSpells ~= true and self.RSkill ~= nil then return end

		if Menu.combo.comboWay:Value() == 1 then
			self:SmartCombo(target)
		elseif Menu.combo.comboWay:Value() == 2 then
			-- "Q", "RQ", "W", "E"
			self:Combo1(target)
		elseif Menu.combo.comboWay:Value() == 3 then
			-- "Q", "W", "RW", "E"
			self:Combo2(target)
		elseif Menu.combo.comboWay:Value() == 4 then
			-- "W", "Q", "RQ", "E"
			self:Combo3(target)
		elseif Menu.combo.comboWay:Value() == 5 then
			-- "W", "RW", "Q", "E"
			self:Combo4(target)
		end
	end
end

function Leblanc:Combo1(target)
	if self.Q:CanCast() and self.R:CanCast() then
		if self.Q:Cast(target) then
			self.CanCastSpell = false
			self.RSkill = "Q"
		end
		return
	end
	-- This is here, because Q still has to casted. The earlier condition only gets called when Q and W are ready
	self.Q:Cast(target)
	-- Casting R
	if self.lastActivated == Spells.Q.spellName and Spells.R.ready then
		self:CastR("Q", target)
	end
	-- Casting W
	if not self:wUsed() then
		self.W:Cast(target)
	end
	-- Casting E
	self.E:Cast(target)	
end

function Leblanc:Combo2(target)
	-- Casting Q
	self.Q:Cast(target)
	-- Casting W and RW
	if self.W:CanCast() and self.R:CanCast() then
		if not self:wUsed() and self.W:Cast(target) then
			self.CanCastSpell = false
			self.RSkill = "W"
		end
		return
	end
	-- This is here, because W still has to casted. The earlier condition only gets called when R and W are ready
	if not self:wUsed() then
		self.W:Cast(target)
	end
	-- Casting R
	if self.lastActivated == Spells.W.spellName and Spells.R.ready and not self:wrUsed() then
		self:CastR("W", target)
	end
	-- Casting E
	self.E:Cast(target)
end

function Leblanc:Combo3(target)
	-- Casting W
	if not self:wUsed() then self.W:Cast(target) end
	-- Casting Q and R
	if self.Q:CanCast() and self.R:CanCast() then
		if self.Q:Cast(target) then
			self.CanCastSpell = false
			self.RSkill = "Q"
		end
		return
	end
	-- Casting Q
	self.Q:Cast(target)
	-- Casting R
	if self.lastActivated == Spells.Q.spellName and Spells.R.ready then
		self:CastR("Q", target)
	end
	-- Casting E
	self.E:Cast(target)
end

function Leblanc:Combo4(target)
	-- Casting W and RW
	if self.W:CanCast() and self.R:CanCast() then
		if not self:wUsed() and self.W:Cast(target) then
			self.CanCastSpell = false
			self.RSkill = "W"
		end
		return
	end
	-- Casting W
	if not self:wUsed() then self.W:Cast(target) end
	-- Casting RW
	if self.lastActivated == Spells.W.spellName and Spells.R.ready and not self:wrUsed() then
		self:CastR("W", target)
	end
	-- Casting Q
	self.Q:Cast(target)
	-- Casting E
	self.E:Cast(target)
end

function Leblanc:Harass()
	if myHero.dead then return end
	-- Checking target
	if target ~= nil and ValidTarget(target) then
		-- Harassing
		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.harass.harassW:Value() == true then
			if not self:wUsed() then
				self.W:Cast(target)
			end
		end
		if Menu.harass.harassE:Value() == true then
			self.E:Cast(target)
		end

		if self:wUsed() and not self.Q:CanCast() and not self.E:CanCast() then
			self.W:Cast()
		end

	end
end


function Leblanc:OnDraw()
	if Menu.draw.drawKilltext:Value() == true then
		for i, enemy in ipairs(EnemyTable) do
	 		if ValidTarget(enemy) then
	 			local barPos = Graphics.WorldToScreen(Gemotry.Vector3(enemy.x, enemy.y, enemy.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 35  
				Graphics.DrawText(KillText[i], 10, PosX, PosY, Graphics.ARGB(255,255,204,0))
			end 
		end 
	end 
end

-- Returns if W has been used or not
function Leblanc:wUsed()
	return myHero:GetSpellData(_W).name == "leblancslidereturn"
end
-- Returns if WR has been used or not
function Leblanc:wrUsed()
	return myHero:GetSpellData(_R).name == "leblancslidereturnm"
end 

-- Calculates damage to other heroes for KillText
function Leblanc:CalcDamageCalculations()
	if myHero.dead then return end
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = ((self.Q:CanCast() and CalculateAPDamage("Q", 25, 30, 0.4, enemy)) or 0)
			local Wdmg = ((self.W:CanCast() and not self:wUsed() and CalculateAPDamage("W", 40, 45, 0.6, enemy)) or 0)
			local Edmg = ((self.E:CanCast() and CalculateAPDamage("E", 25, 15, 0.5, enemy)) or 0)
			local Idmg = ((Iready and GetIgniteDamage()) or 0)
			local RQdmg = ((Spells.R.ready and self.lastActivated == Spells.Q.spellname and self:SpellCalc("RQ", enemy)) or 0)
			local RWdmg = ((Spells.R.ready and not self:wrUsed() and self.lastActivated == Spells.W.spellname and self:SpellCalc("RW", enemy)) or 0)
			local QMark = ((self.Q:CanCast() and self:SpellCalc("QMark", enemy)) or 0)

			if myHero.totalDamage > enemy.health then
				KillText[i] = "MURDER HIM"
			elseif Idmg > enemy.health then
				KillText[i] = "Ignite = kill"
			elseif Qdmg > enemy.health then
				KillText[i] = "Q = kill"
			elseif Wdmg > enemy.health then
				KillText[i] = "W = kill"
			elseif Edmg > enemy.health then
				KillText[i] = "E = kill"
			elseif RQdmg > enemy.health then
				KillText[i] = "R(Q) = kill"
			elseif RWdmg > enemy.health then
				KillText[i] = "R(W) = kill"
			elseif Qdmg + myHero.totalDamage > enemy.health then
				KillText[i] = "Q + AA = kill"
			elseif Qdmg + Idmg > enemy.health then
				KillText[i] = "Q + Ignite = kill"
			elseif Wdmg + myHero.totalDamage > enemy.health then
				KillText[i] = "W + AA = kill"
			elseif Wdmg + Idmg > enemy.health then
				KillText[i] = "W + Ignite = kill" 
			elseif Edmg + Idmg > enemy.health then
				KillText[i] = "E + Ignite = kill"
			elseif RQdmg + Idmg > enemy.health then
				KillText[i] = "R(Q) + Ignite = kill"
			elseif RWdmg + Idmg > enemy.health then
				KillText[i] = "R(W) + Ignite = kill"
			elseif Qdmg + QMark + Wdmg > enemy.health then
				KillText[i] = "Q + W = kill"
			elseif Wdmg + Qdmg + QMark + Idmg > enemy.health then
				KillText[i] = "Q + W + Ignite = kill"
			elseif Qdmg + RQdmg + QMark > enemy.health then
				KillText[i] = "Q + R(Q) = kill"
			elseif Qdmg + RQdmg + Idmg + QMark > enemy.health then
				KillText[i] = "Q + R(Q) + Ignite = kill"
			elseif Wdmg + RWdmg > enemy.health then
				KillText[i] = "W + R(W) = kill"
			elseif Wdmg + RWdmg + Idmg > enemy.health then
				KillText[i] = "W + R(W) + Ignite = kill"
			elseif Qdmg + RQdmg + QMark + QMark + Wdmg > enemy.health then
				KillText[i] = "Q + R(Q) + W = kill"
			elseif Qdmg + RQdmg + QMark + QMark + Wdmg + Edmg > enemy.health then
				KillText[i] = "Q + R(Q) + W + E = kill"
			else
				KillText[i] = "Harass him!"
			end

		end
	end
end

-- KillSteals
function Leblanc:KillSteal()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) and Menu.killsteal.enemies[enemy.charName]:Value() == true then
			local Qdmg = ((self.Q:CanCast() and CalculateAPDamage("Q", 25, 30, 0.4, enemy)) or 0)
			local Wdmg = ((self.W:CanCast() and not self:wUsed() and CalculateAPDamage("W", 40, 45, 0.6, enemy)) or 0)
			local Edmg = ((self.E:CanCast() and CalculateAPDamage("E", 25, 15, 0.5, enemy)) or 0)
			local Idmg = ((Iready and GetIgniteDamage()) or 0)
			local RQdmg = ((Spells.R.ready and self.lastActivated == Spells.Q.spellname and self:SpellCalc("RQ", enemy)) or 0)
			local RWdmg = ((Spells.R.ready and not self:wrUsed() and self.lastActivated == Spells.W.spellname and self:SpellCalc("RW", enemy)) or 0)
			
			if Qdmg > enemy.health then
				self.Q:Cast(enemy)
			elseif Wdmg > enemy.health then
				self.W:Cast(enemy)
			elseif Edmg > enemy.health then
				self.E:Cast(target)
			elseif RQdmg > enemy.health then
				self:CastR("Q", enemy)
			elseif RWdmg > enemy.health then
				self:CastR("W", enemy)
			end 
		end
	end
end

-- Calculates Damage for specific LeBlanc spells
function Leblanc:SpellCalc(spell, target)
	local dmg = 0
	if spell == "RQ" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif spell == "RW" then
		dmg = 150 * myHero:GetSpellData(_R).level + 0.975 * myHero.ap 
	elseif spell == "RE" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif spell == "QMark" then
		dmg = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap
	end 
	return ((myHero:CalcMagicDamage(target, dmg) and myHero:CalcMagicDamage(target, dmg)) or 0)
end


-- Specific LeBlancs Menu
function Leblanc:ExtraMenu()

	-- Combo
	Menu.combo:DropDown("comboWay", "Perform Combo:", 1, {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"})

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- W Settings
	Menu:Menu("settingsW", name .. "Settings: W")
	Menu.settingsW:Boolean("useOptional", "Use Optional W Settings", true)
	Menu.settingsW:DropDown("useOptionalW", "Return Way: ", 1, {"Smart", "Target dead", "Skills used", "Both"})

	--Farming
	Menu.farm:Boolean("farmQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.farm:Boolean("farmRange", "Minions outside AA range only", false)
	Menu.farm:Boolean("farmAA", "Farm if AA is on CD", false)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	--Drawings
	Menu.draw:Section("sectionKillText", "Specific settings")
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)
	
	-- Killsteal settings
	Menu.killsteal:Boolean("killsteal", "Perform KillSteal", false)
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.killsteal:Boolean("killstealE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.killsteal:Boolean("killstealR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.killsteal:Menu("enemies", "Perform KillSteal On")
	for i, hero in ipairs(EnemyTable) do
		Menu.killsteal.enemies:Boolean(hero.charName, hero.charName, true)
	end

	-- Misc
	Menu:Menu("misc", name .. "Misc")
end


function Leblanc:SmartCombo(target) 

	if not self.CanCastSpells and self.RSkill ~= nil then return end

	-- Calculating damage
	local Wdmg = ((self.W:CanCast() and not self:wUsed() and CalculateAPDamage("W", 40, 45, 0.6, target)) or 0)
	local RWdmg = ((Spells.R.ready and not self:wrUsed() and self:SpellCalc("RW", target)) or 0)

	-- Casting W and R to maximize damage output in a teamfight when W+R will hit more than three people
	if self.W:CanCast() and Spells.R.ready then
		local position, enemyCount = CountEnemiesWithinRadius(Spells.W.range, Spells.W.radius)
		if enemyCount >= 3 and position ~= nil then
			if self.W:Cast(position.x, position.z) and not self:wUsed() then 
				self.CanCastSpells = false
				self.RSkill = "RW"
			end
			return
		end
	end

	-- Declaring other damages here, because it isn't needed earlier
	local Qdmg = ((self.Q:CanCast() and CalculateAPDamage("Q", 25, 30, 0.4, target)) or 0)
	local RQdmg = ((Spells.R.ready and self:SpellCalc("RQ", target)) or 0)
	local QMark = (((self.Q:CanCast() or Spells.R.ready) and self:SpellCalc("QMark", target)) or 0)

	-- Checking whether Q + R does more damage than W + R
	if myHero:DistanceTo(target) < Spells.Q.range and self.Q:CanCast() and Spells.R.ready and Qdmg + RQdmg + QMark + QMark + Wdmg > Wdmg + RWdmg + Qdmg then
		if self.Q:Cast(target) then
			self.CanCastSpells = false
			self.RSkill = "RQ"
		end
		return
	-- Otherwise do W + R
	elseif myHero:DistanceTo(target) < Spells.W.range and self.W:CanCast() and Spells.R.ready and Wdmg + RWdmg > Qdmg + RQdmg + QMark then
		if self.W:Cast(target) then 
			self.CanCastSpells = false
			self.RSkill = "RW"
		end
		return
	-- Casting E, if possible, to targets further from W range and closer to E range
	elseif myHero:DistanceTo(target) > Spells.Q.range and myHero:DistanceTo(target) < Spells.E.range and self.E:CanCast() then
		self.E:Cast(target) 
		return
	else
		-- Possible other skills to make all skills are fired at all times
		self.Q:Cast(target)
		self:CastR("Q", target)
		self.W:Cast(target)
		self:CastR("W", target)
		self.E:Cast(target)
		return
	end
end 

function Leblanc:CastR(skill, target)
	if skill == "Q" and self.lastActivated == Spells.Q.spellname then
		if Spells.R.ready and myHero:DistanceTo(target) < Spells.Q.range then
			myHero:CastSpell(_R, target)
		end
	elseif skill == "W" and self.lastActivated == Spells.W.spellname then
		if Spells.R.ready and not self:wrUsed() and myHero:DistanceTo(target) < Spells.W.range then
			myHero:CastSpell(_R, target.x, target.z)
		end
	end
end






--[[

		Script details:
			Series: Totally Series AIO
			Champion: BlitzCrank
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]

function Blitzcrank:__init()
	Spells = {
		["Q"] = {name = "Rocket Grab", range = 900, width = 100, radius = 0, delay = 0.25, speed = 1800, ready = false},
		["W"] = {name = "Overdrive", ready = false},
		["E"] = {name = "Power Fist", range = 125, ready = false},
		["R"] = {name = "Static Field", range = 600, speed = math.huge, ready = false}
	}
	
	self.Q = Spell(_Q, Spells.Q.range)
	--self.Q:SetSkillShot(Spells.Q.delay, Spells.Q.radius, Spells.Q.speed, false, "line")
	self.W = Spell(_W)
	self.E = Spell(_E)
	self.R = Spell(_R, Spells.R.range)

	self:ExtraMenu()

	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	Callback.Bind("Tick", function() self:OnTick() end)
end

function Blitzcrank:OnTick()
	if myHero.dead then return end
	if Menu.autoR.autoR:Value() == true then
		self:AutoR()
	end

	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end

end

function Blitzcrank:Combo()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.combo.comboE:Value() == true then
			if myHero:DistanceTo(target) < Spells.E.range then
				self.E:Cast()
			end
		end
		if Menu.combo.comboQ:Value() == true and Menu.combo.comboBlock[target.charName]:Value() == false then
			self.Q:Cast(target, target.x, target.z)
		end
		if Menu.combo.comboR:Value() == true and CountEnemies(Spells.R.range) >= Menu.combo.comboRx:Value() then
			self.R:Cast()
		end
	end
end

function Blitzcrank:Harass()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.harass.harassE:Value() == true then
			self.E:Cast(target)
		end
	end
end

function Blitzcrank:AutoR()
	if CountEnemies(Spells.R.range) >= tonumber(Menu.autoR.autoRx:Value()) then
		self.R:Cast()
	end
end

function Blitzcrank:KillSteal()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = CalculateAPDamage("Q", 25, 55, 1, enemy)
			local Rdmg = CalculateAPDamage("R", 125, 125, 1, enemy)
			if Qdmg > enemy.health then
				self.Q:Cast(enemy)
			elseif Rdmg > enemy.health and myHero:DistanceTo(enemy) <= Spells.R.range then
				self.R:Cast()
			end
		end
	end
end

function Blitzcrank:ExtraMenu()
	-- Combo
	Menu.combo:Section("comboSpellSection", DrawFont("Spell Settings"))
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Section("comboSection2", DrawFont("Modes"))
	Menu.combo:Slider("comboRx", "Min amount of people nearby to cast R", 1, 1, 5, 0)
	Menu.combo:Menu("comboBlock", "Block Q List")
	for i, enemy in ipairs(EnemyTable) do 
		Menu.combo.comboBlock:Boolean(enemy.charName, "Block Q on " .. enemy.charName, false)
	end

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	-- Auto R
	Menu:Menu("autoR", "Automatic R")
	Menu.autoR:Section("autoRSection", DrawFont("Activation"))
	Menu.autoR:Boolean("autoR", "Automatically Activate R")
	Menu.autoR:Section("autoRSection2", DrawFont("Modes"))
	Menu.autoR:Slider("autoRx", "Enemies In Range to R", 5, 1, 5, 0)

	-- KillSteal settings
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealR", "Use " .. Spells.R.name .. " (R)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("interrupt", "Interrupter")
	Interrupter(Menu.misc.interrupt, function(unit) self:BlitzInterrupter(unit) end)
end

function Blitzcrank:BlitzInterrupter(unit)
	if ValidTarget(unit) then
		if not self.Q:Cast(unit) and myHero:DistanceTo(unit) <= Spells.R.range then
			self.R:Cast()
		end
	end
end







--[[

		Script details:
			Series: Totally Series AIO
			Champion: Ryze
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]

function Ryze:__init()
	Spells = {
		["Q"] = {name = "Overload", range = 625, ready = false},
		["W"] = {name = "Rune Prison", range = 600, ready = false},
		["E"] = {name = "Spell Flux", range = 600, ready = false},
		["R"] = {name = "Desperate Power", ready = false}
	}
	
	--BasicPrediction.EnablePrediction()

	self.Q = Spell(_Q, Spells.Q.range)
	self.W = Spell(_W, Spells.W.range)
	self.E = Spell(_E, Spells.E.range)
	self.R = Spell(_R)

	self:ExtraMenu()
	self.lastValueMenu = Menu.combo.settingsR.RMode:Value()

	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("Draw", function() self:OnDraw() end)
end

function Ryze:OnDraw()
	if Menu.draw.drawKilltext:Value() == true then
		for i, enemy in ipairs(EnemyTable) do
	 		if ValidTarget(enemy) then
	 			local barPos = Graphics.WorldToScreen(Gemotry.Vector3(enemy.x, enemy.y, enemy.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 50  
				Graphics.DrawText(KillText[i], 10, PosX, PosY, Graphics.ARGB(255,255,204,0))
			end 
		end 
	end 
end

function Ryze:OnTick()
	if myHero.dead then return end
	self:CalcDamageCalculations()
	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end
end

function Ryze:Combo()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.combo.comboR:Value() == true and self:RMangement(target) then
			self.R:Cast()
		end
		if Menu.combo.comboMode:Value() == 1 then
			self:ComboBurst(target)
		else
			self:ComboLong(target)
		end
	end
end

function Ryze:ComboBurst(target)
	if Menu.combo.comboQ:Value() == true then
		self.Q:Cast(target)
	end
	if Menu.combo.comboE:Value() == true then
		self.W:Cast(target)
	end
	if Menu.combo.comboQ:Value() == true then
		self.E:Cast(target)
	end
end

function Ryze:ComboLong(target)
	if Menu.combo.comboQ:Value() == true then
		self.Q:Cast(target)
	end

	if myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_Q).currentCd < 2 and not self.E:CanCast() and self.W:CanCast() then return end

	if Menu.combo.comboE:Value() == true then
		self.W:Cast(target)
	end

	if myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_Q).currentCd < 2 and not self.W:CanCast() and self.E:CanCast() then return end

	if Menu.combo.comboQ:Value() == true then
		self.E:Cast(target)
	end
end

function Ryze:Harass()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.harass.harassW:Value() == true then
			self.W:Cast(target)
		end
		if Menu.harass.harassE:Value() == true then
			self.E:Cast(target)
		end
	end
end

function Ryze:KillSteal()
	for i, hero in ipairs(EnemyTable) do
		if ValidTarget(hero) then
			local Qdmg = self.Q:CanCast() and self:CalculateAPDamage("Q", hero)
			local Wdmg = self.W:CanCast() and self:CalculateAPDamage("W", hero)
			local Edmg = self.R:CanCast() and self:CalculateAPDamage("E", hero)
			if Edmg > enemy.health then
				self.E:Cast(hero)
			elseif Qdmg > enemy.health then
				self.Q:Cast(hero)
			elseif Wdmg > enemy.health then
				self.W:Cast(hero)
			end
		end
	end
end

function Ryze:CalculateAPDamage(skill, target)
	local dmg = 0
	if skill == "Q" then
		dmg = 20 * myHero:GetSpellData(_Q).level + 20 + 0.4 * myHero.ap
		dmg = dmg + ((myHero.maxMana / 100) * 6.5)
	elseif skill == "W" then
		dmg = 25 * myHero:GetSpellData(_W).level + 35 + 0.6 * myHero.ap
		dmg = dmg + ((myHero.maxMana / 100) * 4.5)
	elseif skill == "E" then
		dmg = 30 * myHero:GetSpellData(_E).level + 20 + 0.35 * myHero.ap
		dmg = dmg + ((myHero.maxMana / 100) * 1)
	end
	return myHero:CalcMagicDamage(target, dmg)
end

function Ryze:CalcDamageCalculations()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = ((self.Q:CanCast() and self:CalculateAPDamage("Q", enemy)) or 0)
			local Wdmg = ((self.W:CanCast() and self:CalculateAPDamage("W", enemy)) or 0)
			local Edmg = ((self.E:CanCast() and self:CalculateAPDamage("E", enemy)) or 0)
			if myHero.totalDamage > enemy.health then
				KillText[i] = "Murder him"
			elseif Qdmg > enemy.health then
				KillText[i] = "Q = kill"
			elseif Wdmg > enemy.health then
				KillText[i] = "W = kill"
			elseif (Edmg * 2) > enemy.health then
				KillText[i] = "E = kill"
			elseif Qdmg + Wdmg > enemy.health then
				KillText[i] = "Q + W = kill"
			elseif Qdmg + Wdmg + Edmg > enemy.health then
				KillText[i] = "Q + W + E = kill"
			elseif Qdmg + Wdmg + Qdmg > enemy.health then
				KillText[i] = "Q + W + Q = kill"
			elseif Qdmg + Wdmg + Edmg + Qdmg > enemy.health then
				KillText[i] = "Q + W + E + Q = kill"
			elseif Qdmg + Wdmg + Qdmg + Edmg + Qdmg > enemy.health then
				KillText[i] = "Q + W + Q + E + Q = kill"
			else
				KillText[i] = "Harass him"
			end
		end
	end
end

function Ryze:RMangement(target)
	return Menu.combo.settingsR.RMode:Value() == 1 or (Menu.combo.settingsR.RMode:Value() == 2 and Menu.combo.settingsR.hitX >= self:CalcEnemiesNearTarget(target, Spells.R.radius))
end

function Ryze:CalcEnemiesNearTarget(target, radius)
	local count = 1
	for i, enemy in ipairs(EnemyTable) do
		if enemy ~= target then
			if target:distanceTo(enemy) < radius then 
				count = count + 1
			end
		end
	end
	return count
end

function Ryze:Gapcloser(unit) 
	self.W:Cast(unit)
end


function Ryze:ExtraMenu()
	-- Combo
	Menu.combo:Section("comboSection", DrawFont("Spell Settings"))
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Section("comboMode", DrawFont("Modes"))
	Menu.combo:DropDown("comboMode", "Mode", 1, {"Burst", "Long"})
	Menu.combo:Menu("settingsR", "R Settings")
	Menu.combo.settingsR:DropDown("RMode", "Mode", 1, {"Instantly", "Hit x"}, function(newvalue) if newvalue == 1 then Menu.combo.settingsR.hitX:Hide(true) else Menu.combo.settingsR.hitX:Hide(false) end end)
	Menu.combo.settingsR:Slider("hitX", "Min X amount of champs", 2, 1, 5, 1)

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- Farm
	Menu.farm:Boolean("farmQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmW", "Use " .. Spells.W.name .. " (W)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	-- KillSteal settings
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealW", "Use " .. Spells.W.name .. " (Q)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("gapcloser", "GapCloser")
	Gapcloser(Menu.misc.gapcloser, function(unit) self:Gapcloser(unit) end)

	--Draws
	Menu.draw:Section("drawKillSection", DrawFont("Misc Drawings"))
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)
end

function Ryze:MenuChecks()
	if self.lastValueMenu ~= Menu.combo.settingsR.RMode:Value() then
		if Menu.combo.settingsR.Mode:Value() == 1 then
			Menu.combo.settingsR.hitX:Hide(true)
		else
			Menu.combo.settingsR.hitX:Hide(false)
		end
		self.lastValueMenu = Menu.combo.SettingsR.RMode:Value()
	end
end






--[[

		Script details:
			Series: Totally Series AIO
			Champion: Lux
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
²			0.1
				Started coding
--]]

function Lux:__init()
	Spells = 	{
					["Q"] = {name = "Light Binding", range = 1175, speed = 1200}, 
					["W"] = {name = "Prismatic Barrier", range = 1075, speed = 1400}, 
					["E"] = {name = "Lucent Singularity", range = 1100, speed = 1600, radius = 322, delay = 0.25}, 
					["R"] = {name = "Final Spark", range = 3340}
				}

	-- Drawing LeBlancs Menu
	self:ExtraMenu()

	-- Intializing max range just to be sure for Menu
	self.maxRange = Spells.R.range

	-- Initializing Spells
	self.Q = Spell(_Q, Spells.Q.range)
	self.W = Spell(_W, Spells.W.range)
	self.E = Spell(_E, Spells.E.range)
	--self.E:SetSkillShot(Spells.E.delay, Spells.E.radius, Spells.E.speed, false, "aoe")
	self.R = Spell(_R, Spells.R.range)
	--self.R:SetSkillShot(Spells.E.delay, Spells.E.radius, Spells.E.speed, false, "normal")

	-- Ball information
	self.EBall = nil

	-- Lux Passive name
	self.LuxPassive = "luxilluminatingfraulein"
	self.EnemiesBuff = {}

	for i, enemy in ipairs(EnemyTable) do
		self.EnemiesBuff[enemy.charName] = false
	end

	-- Initializing TargetSelector
	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 
	
	-- Making the change smoother
	self.lastRange = Menu.lazer.range:Value()

	-- Regular Callback binds
	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("CreateObj", function(obj) self:OnCreateObj(obj) end)
	Callback.Bind("ApplyBuff", function(unit, target, buff) self:OnApplyBuff(unit, target, buff) end)
	Callback.Bind("RemoveBuff", function(unit, buff) self:OnRemoveBuff(unit, buff) end)
	Callback.Bind("DeleteObj", function(obj) self:OnDeleteObj(obj) end)
	Callback.Bind("Draw", function() self:OnDraw() end)
end

function Lux:OnDraw()
	if myHero.dead then return end
	if Menu.draw.drawKilltext:Value() == true then
		for i, enemy in ipairs(EnemyTable) do
	 		if ValidTarget(enemy) then
	 			local barPos = Graphics.WorldToScreen(Gemotry.Vector3(enemy.x, enemy.y, enemy.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 50  
				Graphics.DrawText(KillText[i], 10, PosX, PosY, Graphics.ARGB(255,255,204,0))
			end 
		end 
	end 
	if self.EBall ~= nil then
		DrawCirc(self.EBall.x, self.EBall.y, self.EBall.z, Spells.E.radius, Graphics.RGB(100, 200, 150):ToNumber())
	end
end

function Lux:OnTick()
	self:CalcDamageCalculations()

	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end

	if self.EBall and not Menu.comboKey:IsPressed() then
		self:ProcE()
	end
end

function Lux:OnApplyBuff(unit, target, buff)
	if unit and unit.isMe and target and ValidTarget(target) and buff.name == self.LuxPassive then
		self.EnemiesBuff[target.charName] = true
	end
end

function Lux:OnRemoveBuff(unit, buff)
	if unit and unit.team ~= myHero.team and unit.type == myHero.type and buff.name == self.LuxPassive and self.EnemiesBuff[unit.charName] == true then
		self.EnemiesBuff[unit.charName] = false
	end
end

function Lux:OnCreateObj(obj)
	if obj and obj.valid and obj.spellOwner and obj.spellOwner.type and obj.spellOwner.type == myHero.type then
		printChat(obj.spellOwner.charName)
	end
	if self.EBall then
		if self.EBall.spellOwner then
			printChat(ob.spellOwner.charName)
			if spell.EBall.spellOwner.isMe then
				self.EBall = obj
			else
				self.EBall = nil
			end
		end
	end
    if not self.EBall and obj and obj.name == "LuxLightstrike_mis.troy" and myHero:DistanceTo(obj) <= 50 then
    	self.EBall = obj
    end
    
   -- if obj and obj.valid and obj.spellOwner and obj.spellOwner.networkID == myHero.networkID and obj.name and obj.name == "LuxLightstrike_mis.troy" then
    --    self.EBall = obj
    --end
    
end

function Lux:OnDeleteObj(obj)
	if obj == self.EBall then
		self.EBall = nil 
	end 
end

function Lux:Combo()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target) then

		if Menu.combo.comboQ:Value() == true then
			self.Q:Cast(target)
		end

		if Menu.combo.comboPassive:Value() and InAARange(target) and TargetHaveBuff(Buffname, target) then return end
		
		if Menu.combo.comboE:Value() == true then
			self.E:Cast(target)
		end

		if Menu.combo.comboPassive:Value() and InAARange(target) and TargetHaveBuff(Buffname, target) then return end
		if Menu.combo.comboR:Value() == true  then
			if not self:CanComboR(target) then return end
			self.R:Cast(target)
		end
	end
end

function Lux:ProcE(target)
	if myHero.dead then return end
	if target and target.type == myHero.type then
		if self.E:CanCast() and GetCustomDistance(self.EBall, target) <= Spells.E.radius then
			self.E:Cast()
		end
	else
		if self.E:CanCast() and CountEnemies(Spells.E.radius, self.EBall) >= 1 then
			self.E:Cast()
		end
	end
end

function Lux:Harass()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target) then
		if Menu.harass.harassQ:Value() == true and not (Menu.harass.harassPassive:Value() and InAARange(target) and TargetHaveBuff(Buffname, target)) then
			self.Q:Cast(target)
		end
		if Menu.harass.harassE:Value() == true and not (Menu.harass.harassPassive:Value() and InAARange(target) and TargetHaveBuff(Buffname, target)) then
			self.E:Cast(target)
		end
	end
end

function Lux:CalcDamageCalculations()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = ((Menu.killsteal.killstealQ:Value() and self.Q:CanCast() and CalculateAPDamage("Q", 10, 50, 0.7, enemy)) or 0)
			local Edmg = ((Menu.killsteal.killstealE:Value() and self.W:CanCast() and CalculateAPDamage("E", 15, 45, 0.6, enemy)) or 0)
			local Rdmg = ((Menu.killsteal.killstealR:Value() and self.R:CanCast() and CalculateAPDamage("R", 200, 100, 0.75, enemy)) or 0)
			local Pdmg = (((self.Q:CanCast() or self.E:CanCast()) and self:PassiveDamage()) or 0)
			if myHero.totalDamage > enemy.health then
				KillText[i] = "Murder him"
			elseif Qdmg > enemy.health then
				KillText[i] = "Q = kill"
			elseif Edmg > enemy.health then
				KillText[i] = "E = kill"
			elseif Qdmg + Pdmg > enemy.health then
				KillText[i] = "Q + P = kill"
			elseif Edmg + Pdmg > enemy.health then
				KillText[i] = "E + P = kill"
			elseif Qdmg + Edmg > enemy.health then
				KillText[i] = "Q + E = kill"
			elseif Qdmg + Pdmg + Edmg > enemy.health then
				KillText[i] = "Q + P + E = kill"
			elseif Qdmg + Pdmg + Edmg + Pdmg > enemy.health then
				KillText[i] = "Q + P + E + P = kill"
			elseif Qdmg + Edmg + Rdmg > enemy.health then
				KillText[i] = "Q + E + R = kill"
			elseif Qdmg + Pdmg + Edmg + Rdmg + Pdmg > enemy.health then
				KillText[i] = "Q + P + E + P + R + P = kill"
			else
				KillText[i] = "Harass him"
			end
		end
	end
end

function Lux:KillSteal()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			if Qdmg > enemy.health then
				self.Q:Cast(enemy)
			elseif self.EBall and Edmg > enemy.health then
				self.EProc(enemy)
			elseif Edmg > enemy.health then
				self.E:Cast(enemy)
			elseif Rdmg > enemy.health then
				self.R:Cast(enemy)
			end
		end
	end
end

function Lux:CanComboR(target)
		return not (Menu.lazer.combo:Value() == 2 and CalculateAPDamage() <= target.health) 
end

function Lux:PassiveDamage()
	return ((10 + (8 * myHero.level)) + (myHero.ap * 0.2))
end


function Lux:ExtraMenu()
	-- Combo
	Menu.combo:Section("comboSection", DrawFont("Spell Settings"))
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Section("comboModeSection", DrawFont("Modes"))
	Menu.combo:Boolean("comboPassive", "Proc Passive", false)

	-- Harass
	Menu.harass:Section("harassSection", DrawFont("Spell Settings"))
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.harass:Section("harassModeSection", DrawFont("Modes"))
	Menu.harass:Boolean("harassPassive", "Proc Passive", false)

	--Farming
	Menu.farm:Boolean("farmQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmE", "Use " .. Spells.E.name .. " (E)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearE", "Use " .. Spells.E.name .. " (E)", true)

	--Drawings
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)
	Menu.draw:Separator()

	-- Ult Settings
	Menu:Menu("lazer", "Ultimate Settings")
	Menu.lazer:Icon("fa-crosshairs")
	Menu.lazer:Slider("range", "Range", 1500, 100, self.maxRange, 1, function(newvalue) Spells.R.range = newvalue; self.R:AdjustRange(newvalue); end)
	Menu.lazer.range:Icon("fa-plus")
	Menu.lazer:Separator()
	Menu.lazer:DropDown("combo", "Use in Combo", 1, {"Instantly", "KillAble"})

	-- Killsteal settings
	Menu:Menu("killsteal", name .. "KillSteal")
	Menu.killsteal:Section("killstealSection1", "Activation")
	Menu.killsteal:Boolean("killsteal", "Perform KillSteal", false)
	Menu.killsteal:Section("killstealSection2", "Spell Settings")
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.killsteal:Boolean("killstealR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.killsteal:Section("killstealSection2", "Enemies")
	Menu.killsteal:Menu("enemies", "Perform KillSteal On")
	for i, hero in ipairs(EnemyTable) do
		Menu.killsteal.enemies:Boolean(hero.charName, hero.charName, true)
	end

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("antigapcloser", "Anti-GapCloser")
	Menu.misc:Separator()
	Menu.misc:Menu("interrupter", "Interrupter")
	Menu.misc:Separator()
	Interrupter(Menu.misc.interrupter, function(unit) self:Interrupter(unit) end)
	Gapcloser(Menu.misc.antigapcloser, function(unit) self:Gapcloser(unit) end)
end

function Lux:Interrupter(unit)
	self.Q:Cast(unit)
end

function Lux:Gapcloser(unit) 
	self.Q:Cast(unit)
end




--[[

		Script details:
			Series: Totally Series AIO
			Champion: Morgana
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]

function Morgana:__init()
	Spells = 	{
					["Q"] = {name = "Dark Binding", range = 1175, speed = 1200}, 
					["W"] = {name = "Tormented Soil", range = 900, speed = math.huge, radius = 175, delay = 0, collision = false}, 
					["E"] = {name = "Black Shield", range = 750}, 
					["R"] = {name = "Soul Shackles", range = 600, radius = 1050}
				}

	-- Drawing Morgana Menu
	self:ExtraMenu()

	-- Menu
	self.ultMode = 1

	-- Initializing Spells
	self.Q = Spell(_Q, Spells.Q.range)
	--self.Q:SetSkillShot(Spells.Q.delay, Spells.Q.radius, Spells.Q.speed, true, "line")
	self.W = Spell(_W, Spells.W.range)
	self.E = Spell(_E, Spells.E.range)
	self.R = Spell(_R, Spells.R.range)

	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	-- Regular Callback binds
	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("Draw", function() self:OnDraw() end)
end

function Morgana:OnTick()
	self:CalcDamageCalculations()
	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end
end

function Morgana:Combo()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target) then
		if Menu.combo.comboQ:Value() == true then
			self.Q:Cast(target)
		end

		if Menu.combo.comboE:Value() == true then
			self.E:Cast(target)
		end

		if Menu.combo.comboR:Value() == true and self:UltManagement(target) then
			self.R:Cast()
		end
	end
end

function Morgana:Harass()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target) then
		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.harass.harassW:Value() == true then
			self.W:Cast(target)
		end
	end
end

function Morgana:OnDraw()
	if myHero.dead then return end
	if Menu.draw.drawKilltext:Value() == true then
		for i, enemy in ipairs(EnemyTable) do
	 		if ValidTarget(enemy) then
	 			local barPos = Graphics.WorldToScreen(Geometry.Vector3(enemy.x, enemy.y, enemy.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 50  
				Graphics.DrawText(KillText[i], 10, PosX, PosY, Graphics.ARGB(255,255,204,0))
			end 
		end 
	end 
end


function Morgana:CalcDamageCalculations()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			KillText[i] = self:CalculatePreciseDamageText(enemy)
		end
	end
end

function Morgana:CalculatePreciseDamageText(target)
	local Qdmg = ((Menu.killsteal.killstealQ:Value() and self.Q:CanCast() and CalculateAPDamage("Q", 25, 55, 0.9, target)) or 0)
	local WdmgN = ((self.W:CanCast() and CalculateAPDamage("W", 15, 45, 0.6, target)) or 0)
	local Rdmg = ((Menu.killsteal.killstealR:Value() and self.R:CanCast() and CalculateAPDamage("R", 75, 75, 0.7, target)) or 0)
	local Rdmg2 = ((Menu.killsteal.killstealR:Value() and CalculateAPDamage("R", 150, 150, 1.40, target)))

	for i = 1, 5, 1 do

		local Wdmg = WdmgN * i

		if Wdmg > target.health then 
			return " W(" .. i .. "s) "
		end

		if Wdmg > Qdmg then
			if Qdmg > target.health then
				return " Q "
			end
		end

		if Qdmg > target.health then
			return " Q "
		end

		if (Wdmg + Qdmg) > target.health then
			return " Q + W(" .. i .. "s) "
		end

		if Rdmg > target.health then
			return " R "
		end

		if Rdmg + Wdmg > target.health then
			if Wdmg > Qdmg and Rdmg + Qdmg > target.health then
				return " Q + R "
			end
			return " R + W(" .. i .. "s) "
		end

		if Rdmg2 + Wdmg > target.health then
			if Wdmg > Qdmg and Rdmg2 + Qdmg > target.health then
				return " Q + R Full "
			end
			return " R Full + W(" .. i .. "s) "
		end

		if Rdmg2 + Wdmg + Qdmg > target.health then
			return " Q + W(" .. i .. "s) + R Full "
		end
	end

	return " Harass Him "
end

function Morgana:KillSteal()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) and Menu.killsteal.enemies[enemy.charName] then
			local Qdmg = ((Menu.killsteal.killstealQ:Value() and self.Q:CanCast() and CalculateAPDamage("Q", 25, 55, 0.9, enemy)) or 0)
			local Rdmg = ((Menu.killsteal.killstealR:Value() and self.R:CanCast() and CalculateAPDamage("R", 75, 75, 0.7, enemy)) or 0)
			if Qdmg > enemy.health then
				self.Q:Cast(enemy)
			elseif Rdmg > enemy.health then
				self.R:Cast(enemy)
			end
		end
	end
end

function Morgana:UltManagement(target)
	return (self.ultMode == 1) or (self.ultMode == 2 and target.health < CalculateAPDamage("R", 75, 75, 0.7, target)) or (self.ultMode == 3 and CountEnemies(Spells.R.range) >= Menu.combo.ult.hitX:Value())
end

function Morgana:ExtraMenu()
	-- Combo
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Separator()
	Menu.combo:Menu("ult", "Ult Settings")
	Menu.combo.ult:DropDown("ultMode", "Selected Mode", 1, {"Instant", "KillAble", "Hit X"}, function (newvalue) self.ultMode = newvalue end)
	Menu.combo.ult:Slider("hitX", "Hit X", 1, 1, #EnemyTable, 1)

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)
	

	--Farming
	Menu.farm:Boolean("farmQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmE", "Use " .. Spells.E.name .. " (E)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearE", "Use " .. Spells.E.name .. " (E)", true)

	--Drawings
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)
	Menu.draw:Separator()

	--Specific KillSteal Settings
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.killsteal:Section("killstealSection2", DrawFont("Enemies"))
	Menu.killsteal:Menu("enemies", "Perform KillSteal On")
	for i, hero in ipairs(EnemyTable) do
		Menu.killsteal.enemies:Boolean(hero.charName, hero.charName, true)
	end

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("antigapcloser", "Anti-GapCloser")
	Menu.misc:Separator()
	Menu.misc:Menu("interrupter", "Interrupter")
	Menu.misc:Separator()
	Interrupter(Menu.misc.interrupter, function(unit) self:Interrupter(unit) end)
	Gapcloser(Menu.misc.antigapcloser, function(unit) self:Gapcloser(unit) end)
end

function Morgana:Interrupter(unit)
	self.Q:Cast(unit)
end

function Morgana:Gapcloser(unit) 
	self.Q:Cast(unit)
end




--[[

		Script details:
			Series: Totally Series AIO
			Champion: Katarina
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	


		Changelog:
			0.1
				Started coding
--]]

function Katarina:__init()
	Spells = {
		["Q"] = {name = "Bouncing Blades", range = 675},
		["W"] = {name = "Sinister Steel", range = 375},
		["E"] = {name = "Shunpo", range = 700},
		["R"] = {name = "Death Lotus", range = 550}
	}
	
	self.Q = Spell(_Q, Spells.Q.range)
	self.W = Spell(_W, Spells.W.range)
	self.E = Spell(_E, Spells.E.range)
	self.R = Spell(_R, Spells.R.range)

	-- Drawing Menu
	self:ExtraMenu()

	-- TargetSelector
	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	-- Callbacks
	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("Animation", function(anim) self:OnAnimation(anim) end)
	--Callback.Bind("Draw", function() self:OnDraw() end)
end

function Katarina:OnAnimation(anim)
	printChat(anim.name)
end

function Katarina:OnDraw()
	if myHero.dead then return end
	if Menu.draw.drawKilltext:Value() == true then
		for i, enemy in ipairs(EnemyTable) do
	 		if ValidTarget(enemy) then
	 			local barPos = Graphics.WorldToScreen(Geometry.Vector3(enemy.x, enemy.y, enemy.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 50  
				Graphics.DrawText(KillText[i], 10, PosX, PosY, Graphics.ARGB(255,255,204,0))
			end 
		end 
	end 
end

function Katarina:OnTick()
	if myHero.dead then return end
	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end

end

function Katarina:Combo()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.combo.comboQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.combo.comboW:Value() == true then
			if myHero:DistanceTo(target) <= Spells.W.range then
				self.W:Cast()
			end
		end
		if Menu.combo.comboE:Value() == true then
			self.E:Cast(target)
		end
		if Menu.combo.comboR:Value() == true then
			self.R:Cast()
		end
	end
end

function Katarina:Harass()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast(target)
		end
		if Menu.harass.harassW:Value() == true then
			self.W:Cast(target)
		end
		if Menu.harass.harassE:Value() == true then
			self.E:Cast(target)
		end
	end
end

function Katarina:KillSteal()
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = CalculateAPDamage("Q", 25, 55, 1, enemy)
			local Rdmg = CalculateAPDamage("R", 125, 125, 1, enemy)
			if Qdmg > enemy.health then
				self.Q:Cast(enemy)
			elseif Rdmg > enemy.health and myHero:DistanceTo(enemy) <= Spells.R.range then
				self.R:Cast()
			end
		end
	end
end

function Katarina:ExtraMenu()
	-- Combo
	Menu.combo:Section("comboSpellSection", DrawFont("Spell Settings"))
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	-- KillSteal settings
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")
end















































class 'TargetSelector'

TargetSelector_Modes = {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"}
function TargetSelector:__init(mode, range, menu)
	self.mode = mode
	self.range = range
	if menu then
		self:LoadToMenu(menu)
		self.mode = self.menu.mode:Value()
	end
	self.selected = nil
	Callback.Bind("WndMsg", function(msg, key) self:OnWndMsg(msg, key) end)
end

function TargetSelector:OnWndMsg(msg, key)
	if msg == WM_LBUTTONDOWN then
		local selected = nil
		for i = 1, Game.HeroCount(), 1 do
			local hero = Game.Hero(i)
			if ValidTarget(hero) then
				selected = hero
				if selected ~= nil and myHero:DistanceTo(selected) <= self.range then
					self.selected = selected
					break
				end
			end
		end
	end
end

function TargetSelector:GetTarget(range)
	self.mode = self.menu.mode:Value()
	local range = range and range or self.range
	local target = nil
	if self.selected and self.selected.type == myHero.type and myHero:DistanceTo(self.selected) <= self.range  and self.selected.visible then return self.selected end

	if self.mode == 1 then
		target = self:Mode1(range)
	elseif self.mode == 2 then
		target = self:Mode2(range)
	elseif self.mode == 3 then
		target = self:Mode3(range)
	elseif self.mode == 4 then
		target = self:Mode4(range)
	elseif self.mode == 5 then
		target = self:Mode5(range)
	end

	return target
end

function TargetSelector:Mode1(range)
	local target = nil
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero) and myHero:DistanceTo(hero) < range then
			if target == nil then
				target = hero
			end
			-- LESS_HP
			if target.health > hero.health then
				target = hero
			end
		end
	end
	return target
end

function TargetSelector:Mode2(range)
	local target = nil
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero) and myHero:DistanceTo(hero) < range then
			if target == nil then
				target = hero
			end
			-- LESS_AD
			if target.ad > hero.ad then
				target = hero
			end
		end
	end
	return target
end
function TargetSelector:Mode3(range)
	local target = nil
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero) and myHero:DistanceTo(hero) < range then
			if target == nil then
				target = hero
			end
			-- LESS_AP
			if target.ap > hero.ap then
				target = hero
			end
		end
	end
	return target
end
function TargetSelector:Mode4(range)
	local target = nil
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero) and myHero:DistanceTo(hero) < range then
			if target == nil then
				target = hero
			end
			-- MOST DAMAGE
			if myHero:CalcDamage(target) > myHero:CalcDamage(hero) then
				target = hero
			end 
		end
	end
	return target
end
function TargetSelector:Mode5(range)
	local target = nil
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero) and myHero:DistanceTo(hero) < range then
			if target == nil then
				target = hero
			end
			-- PRIORITY
			if self.mode == 5 then
				if self.menu.prioritysettings[hero.charName]:Value() < self.menu.prioritysettings[target.charName]:Value() then
					target = hero
				end
			end
		end
	end
	return target
end

function TargetSelector:LoadToMenu(menu)
	self.menu = menu
	self.menu:Section("targetselectorsection", DrawFont("Target Selector"))
	if self.mode == "LESS_HP" then
		self.menu:DropDown("mode", "Mode: ", 1, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	elseif self.mode == "LESS_AD" then
		self.menu:DropDown("mode", "Mode: ", 2, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	elseif self.mode == "LESS_AP" then
		self.menu:DropDown("mode", "Mode: ", 3, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	elseif self.mode == "MOST_DAMAGE" then
		self.menu:DropDown("mode", "Mode: ", 4, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	end
	self.menu:Menu("prioritysettings", "Priority Settings")
	for i, hero in ipairs(EnemyTable) do
		self.menu.prioritysettings:Slider(hero.charName, hero.charName, 1, 1, 5, 0)
	end
end


function TargetSelector:Mode(mode)
	if not mode then return self.mode end
	self.mode = mode
end







--[[
		SpellHandler, because writing class:CastSkill is getting stupid to do for every champion on its own while the principes for every spell is basically the same
--]]

class 'Spell'
function Spell:__init(slot, range)
	self.range = range and range or 0
	self.slot = slot
	self.skillShot = false
end
--Enabling Prediction and prediction values
function Spell:SetSkillShot(delay, width, speed, collision, type)
	self.delay = delay
	self.width = width 
	self.speed = speed 
	self.collision = collision
	self.type = type
	self.skillShot = true
	--BasicPrediction.EnablePrediction()
end
-- Checking whether the target is in spell range
function Spell:InRange(target)
	return myHero:DistanceTo(target) <= self.range
end
-- Checking whether the spell can be casted
function Spell:CanCast()
	return myHero:CanUseSpell(self.slot) == READY
end
-- Not sure if I will ever need this
function Spell:AdjustRange(range)
	self.range = range
end
-- Param1 = target
-- Param2 = possible X value
-- Param3 = possible Z value
function Spell:Cast(param1, param2, param3)
	if self.skillShot then
		if param1 then
			if self:InRange(param1) and self:CanCast() then
				if self.type == "aoe" then
					local castPos, enemies, amount = BasicPrediction.GetBestAoEPositionForce(param1, self.range, self.speed, self.delay, self.width, self.collision, self.collision, myHero)
					if type(castPos) == "Vector3" and HitChance > 0 then
		            	myHero:CastSpell(self.slot, castPos.x, castPos.z)
		            	return true
		       		end    
				elseif self.type == "normal" then
					local castPos, hitchance = BasicPrediction.GetPredictedPosition(param1, self.range, self.speed, self.delay, self.width, self.collision, self.collision, myHero)
		       		if type(castPos) == "Vector3" and hitchance > 0 then
		            	myHero:CastSpell(self.slot, castPos.x, castPos.z)
		            	return true
		        	end    
				elseif self.type == "" then
				end	
			end
		else
			if self:CanCast() then
				myHero:CastSpell(self.slot)
			end
		end
	else
		if param1 and param2 and param3 then
			if self:InRange(param1) and self:CanCast() then
				myHero:CastSpell(self.slot, param2, param3)
				return true
			end
		elseif param1 then
			if self:InRange(param1) and self:CanCast() then
				myHero:CastSpell(self.slot, param1)
				return true
			end
		else
			if self:CanCast() and self:CanCast() then
				myHero:CastSpell(self.slot)
				return true
			end
		end
	end
	return false
end


class 'Interrupter'
function Interrupter:__init(menu, cb)
	self.interrupt = {
						["KatarinaR"]                  = { charName = "Katarina",     duration = 2.5, spell = "R"},
					    ["Meditate"]                   = { charName = "MasterYi",     duration = 2.5, spell = "W"},
					    ["Drain"]                      = { charName = "FiddleSticks", duration = 2.5, spell = "W"},
					    ["Crowstorm"]                  = { charName = "FiddleSticks", duration = 2.5, spell = "R"},
					    ["GalioIdolOfDurand"]          = { charName = "Galio",        duration = 2.5, spell = "R"},
					    ["MissFortuneBulletTime"]      = { charName = "MissFortune",  duration = 2.5, spell = "R"},
					    ["VelkozR"]                    = { charName = "Velkoz",       duration = 2.5, spell = "R"},
					    ["InfiniteDuress"]             = { charName = "Warwick",      duration = 2.5, spell = "R"},
					    ["AbsoluteZero"]               = { charName = "Nunu",         duration = 2.5, spell = "R"},
					    ["ShenStandUnited"]            = { charName = "Shen",         duration = 2.5, spell = "R"},
					    ["FallenOne"]                  = { charName = "Karthus",      duration = 2.5, spell = "R"},
					    ["AlZaharNetherGrasp"]         = { charName = "Malzahar",     duration = 2.5, spell = "R"},
					    ["Pantheon_GrandSkyfall_Jump"] = { charName = "Pantheon",     duration = 2.5, spell = "R"},
					    ["AceInTheHole"] 			   = { charName = "Caitlyn",      duration = 1.0, spell = "R"}
					}

	self.ActiveSpells = {}
	self.callbacks = {}
	self.Heroes = {}

	self:ApplyToMenu(menu)

	if cb then
		table.insert(self.callbacks, cb)
	end

	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)

end

function Interrupter:ApplyToMenu(MenuInt)
	local hasAdded = false

	MenuInt:Section("h85", DrawFont("Activation"))
	MenuInt:Boolean("interrupter", "Interrupt Spells", false)
	MenuInt:Section("h86", DrawFont("Spells To Interrupt"))
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			table.insert(self.Heroes, hero.charName)
		end
	end
	for spell, data in pairs(self.interrupt) do
		if table.contains(self.Heroes, data.charName) then
			MenuInt:Boolean(spell, spell .. " " .. data.charName .. " (" .. data.spell .. ")", true)
			hasAdded = true
		end
	end
	if not hasAdded then
		MenuInt:Info("info", "No spells found to interrupt")
	end

	self.menu = MenuInt
end

function Interrupter:Callback(unit)
	for i, cb in ipairs(self.callbacks) do
		cb(unit)
	end
end

function Interrupter:OnProcessSpell(unit, spell)
	if self.menu.interrupter:Value() == true then
		if self.menu and self.menu[spell.name] and unit.team ~= myHero.team then
			local data = {unit = unit, endTime = os.clock + self.interrupt[spell.name].duration}
			table.insert(self.activeSpells, data)
		end
	end
end

function Interrupter:OnTick()
	if self.activeSpells == nil or #self.activeSpells == 0 then return end
	for i = 1, #self.activeSpells, 1 do
		if self.activeSpells[i].endTime > os.clock  then
			self:Callback(self.activeSpells[i].unit)
		else
			table.remove(self.activeSpells, i)
		end
	end
end


class 'Gapcloser'
function Gapcloser:__init(menu, cb)
	self.GapcloserSpells = {
							["aatroxq"]              = {charName = "Aatrox", spell = "Q"},
						    ["akalishadowdance"]     = {charName = "Akali", spell = "R"},
						    ["headbutt"]             = {charName = "Alistar", spell = "W"},
						    ["fioraq"]               = {charName = "Fiora", spell = "Q"},
						    ["dianateleport"]        = {charName = "Diana", spell = "R"},
						    ["elisespiderqcast"]     = {charName = "Elise", spell = "Q"},
						    ["fizzpiercingstrike"]   = {charName = "Fizz", spell = "Q"},
						    ["gragase"]              = {charName = "Gragas", spell = "E"},
						    ["hecarimult"]           = {charName = "Hecarim", spell = "R"},
						    ["jarvanivdragonstrike"] = {charName = "JarvanIV", spell = "Q"},
						    ["ireliagatotsu"]        = {charName = "Irelia", spell = "Q"},
						    ["jaxleapstrike"]        = {charName = "Jax", spell = "Q"},
						    ["shazixe"]              = {charName = "Khazix", spell = "E"},
						    ["khazixelong"]          = {charName = "Khazix", spell = "E"},
						    ["leblancslide"]         = {charName = "LeBlanc", spell = "W"},
						    ["leblancslidem"]        = {charName = "LeBlanc", spell = "R"},
						    ["blindmonkqtwo"]        = {charName = "LeeSin", spell = "Q"},
						    ["leonazenithblade"]     = {charName = "Leona", spell = "E"},
						    ["ufslash"]              = {charName = "Malphite", spell = "R"},
						    ["pantheon_leapbash"]    = {charName = "Pantheon", spell = ""},
						    ["poppyheroiccharge"]    = {charName = "Poppy", spell = "E"},
						    ["renektonsliceanddice"] = {charName = "Renekton", spelll = "E"},
						    ["riventricleave"]       = {charName = "Riven", spell = "Q"},
						    ["sejuaniarcticassault"] = {charName = "Sejuani", spell = "Q"},
						    ["slashcast"]            = {charName = "Tryndamere", spell = "E"},
						    ["viq"]                  = {charName = "Vi", spell = "Q"},
						    ["monkeykingnimbus"]     = {charName = "MonkeyKing", spell = "Q"},
						    ["xenzhaosweep"]         = {charName = "XinZhao", spell = "E"},
						    ["yasuodashwrapper"]     = {charName = "Yasuo", spell = "E"},
						    ["ahritumble"] 			 = {charName = "Ahri", spell = "R"},
							["caitlynentrapment"]	 = {charName = "Caitlyn", spell = "E"},
							["carpetbomb"]			 = {charName = "Corki", spell = "W"},
							["gravesmove"]			 = {charName = "Graves", spell = "E"},
							["blindmonkwone"]		 = {charName = "Lee Sin", spell = "W"},
							["luciane"]				 = {charName = "Lucian", spell = "E"},
							["maokaiunstablegrowth"] = {charName = "Maokai", spell = "W"},
							["nocturneparanoia2"]	 = {charName = "Nocturne", spell = "R"},
							["rivenfeint"]			 = {charName = "Riven", spell = "E"},
							["shenshadowdash"]		 = {charName = "Shen", spell = "E"},
							["shyvanatransformcast"] = {charName = "Shyvana", spell = "R"},
							["rocketjump"]			 = {charName = "Tristana", spell = "W"},
							["vaynetumble"]			 = {charName = "Vayne", spell = "Q"}
						   }
    if menu then
		self:ApplyToMenu(menu)
	end

	self.callbacks = {}

	if cb then
		table.insert(self.callbacks, cb)
	end

	Callback.Bind("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)
end

function Gapcloser:ApplyToMenu(MenuGap)
	local hasAdded = false

	MenuGap:Boolean("gapcloser", "GapCloser", false)
	for spell, data in pairs(self.GapcloserSpells) do
		if table.contains(EnemyTable, data.charName) then
			MenuGap:Boolean(spell, data.charName .. " - " .. data.spell, false)
			hasAdded = true
		end
	end
	if not hasAdded then
		MenuGap:Info("hue", "No Spells To GapClose")
	end
	self.Menu = MenuGap
end

function Gapcloser:Callback(unit)
	for i, cb in ipairs(self.callbacks) do
		cb(unit)
	end
end


function Gapcloser:OnProcessSpell(unit, spell)
	if self.Menu.gapcloser then
		local spellname = spell.name:lower()
		if self.Menu and self.Menu[spellname] and unit.team ~= myHero.team then
			if myHero:DistanceTo(unit) > myHero:DistanceTo(spell.endPos) then
				self:Callback(unit)
			end
		end
	end
end


--[[
		Useful functions written in the script to avoid writing them each class
		Not all functions are used every class, it's just easier to have them written somewhere once and then use it
--]]


function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			if item.reqTarget and myHero:DistanceTo(unit) < item.range then
				CastItem(item.id, unit)
			elseif not item.reqTarget then
				if (myHero:DistanceTo(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
					CastItem(item.id)
				end
			end
		end
	end
end

function getHitBoxRadius(target)
    return GetCustomDistance(target.minBBox, target.maxBBox)/2
end

function GetEnemyHeroes()
	local enemies = {}
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			table.insert(enemies, hero)
		end
	end
	return enemies
end

function GetCustomDistance(p1, p2)
	p2 = p2 or myHero.visionPos
	return math.sqrt((p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2)
end

function CountEnemies(range, object)
	local object = object and object or myHero
	local count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero) then 
			if GetCustomDistance(object, hero) <= range then
				count = count + 1
			end
		end
	end
	return count
end

function CountEnemiesWithinRadius(range, radius)
	local normalCount = 0
	local enemyCount = 0
	local position = nil
	for i, hero in ipairs(EnemyTable) do
		if myHero:DistanceTo(hero) < range then
			enemyCount = 1
			for i, otherHero in ipairs(EnemyTable) do
				if otherHero.team ~= myHero.team then
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

function CountAllies(range)
	local range = range and range or myHero.range
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


function GetBestAOEPosition(objects, range, radius, source)
	local pos = nil 
	local count2 = 0
	local source = source or myHero
	local range = (range and range) or myHero.range 

	for i, object in ipairs(objects) do
		if GetCustomDistance(source, object) < range then
			local count = 0
			for i, ob in ipairs(objects) do
				if GetCustomDistance(ob, object) <= radius * radius then
					count = count + 1
				end 
			end 
			if count > count2 then
				count2 = count
				pos = object.pos
			end 
		end
	end 

	return pos, count2
end 

function CountMinions(objectTable, range)
	local range = range and range or myHero.range
    local count = 0
    for i, object in ipairs(objectTable) do
        if ValidTarget(object) and myHero:DistanceTo(object) <= range then
            count = count + 1
        end
    end
    return count
end



function GetItemSlot(id, unit)
	local unit = unit or myHero
	for i = 4, 10, 1 do
		if unit:GetItem(i) and unit:GetItem(i).id == id then
			return i
		end
	end
end

function CastItem(ItemID, var1, var2)
	local slot = GetItemSlot(ItemID)
	if slot == nil then return end
	if (myHero:CanUseSpell(slot) == READY) then
		if (var2 ~= nil) then
			myHero:CastSpell(slot, var1, var2)
		elseif (var1 ~= nil) then
			myHero:CastSpell(slot, var1)
		else
			myHero:CastSpell(slot)
		end
	end
end

function ValidTarget(target)
	return target ~= nil and target.team ~= myHero.team and not target.dead and target.type == myHero.type and target.visible and not TargetHaveBuff("UndyingRage") and not TargetHaveBuff("JudicatorIntervention")
end

function CalculateAPDamage(skill, base_damage, damage, APratio, target)
	local dmg = 0
	if skill == "Q" then
		dmg = base_damage * myHero:GetSpellData(_Q).level + damage + APratio * myHero.ap
	elseif skill == "W" then
		dmg = base_damage * myHero:GetSpellData(_W).level + damage + APratio * myHero.ap
	elseif skill == "E" then
		dmg = base_damage * myHero:GetSpellData(_E).level + damage + APratio * myHero.ap
	elseif skill == "R" then
		dmg = base_damage * myHero:GetSpellData(_R).level + damage + APratio * myHero.ap
	end
	return myHero:CalcMagicDamage(target, dmg)
end

function InAARange(target) 
	return myHero:DistanceTo(target) <= myHero.range
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