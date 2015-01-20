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

local champions = {
					["Annie"] = true, 
					["Swain"] = true, 
					["Leblanc"] = true,
					["Blitzcrank"] = true,
					["Ryze"] = true
				}

local champ = nil
local activeClass = nil

function Say(text)
	Game.Chat.Print("<font color=\"#FF0000\"><b>Totally Series:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

Callback.Bind("Load", function()
	Callback.Bind("GameStart", function() OnLoad() end)
end)

function OnLoad()
	-- Looping through Array to find a match
	if champions[myHero.charName] == true then
		champ = myHero.charName
	end


	--[[ UGLY CODE INCOMING --]] --[[ UGLY CODE INCOMING --]] --[[ UGLY CODE INCOMING --]] --[[ UGLY CODE INCOMING --]]

	-- Poor user, his champ isn't supported. 404'd
	if champ == nil then return Say("Your champion is not supported in this series. You can try and request it on the thread.") end

	-- Letting user know his champ is supported
	Say("Found " .. champ .. ". Loading....")

	-- Making Menu cooler
	name = "Totally " .. champ .. " - "

	-- Global Variables
	InitializeGlobalVariables()

	-- Calling correct class -- champ contains myHero.charName --
	-- Sadly, champ() or _G[myHero.charName]() didn't work to more efficient call the correct className...
	if champ == "Annie" then
		activeClass = Annie()
	elseif champ == "Swain" then
		activeClass = Swain()
	elseif champ == "Leblanc" then
		activeClass = LeBlanc()
	elseif champ == "Blitzcrank" then
		activeClass = Blitzcrank()
	elseif champ == "Ryze" then
		activeClass = Ryze()
	end

	--[[ UGLY CODE ENDS HERE --]] --[[ UGLY CODE ENDS HERE --]] --[[ UGLY CODE ENDS HERE --]] --[[ UGLY CODE ENDS HERE --]]
	
	-- Drawing here because Spells is initialized within the class, so the class has to been called first
	DrawGlobalDrawings()

	-- Misc loading at the bottom, because it being on top of menu is stupido
	DrawGlobalMisc()

	-- Normal Callbacks used for every script
	Callback.Bind("Tick", function() OnTick() end)
	Callback.Bind("Draw", function() OnDraw() end)
	Callback.Bind("CreateObj", function(obj) OnCreateObj(obj) end)
	Callback.Bind("DeleteObj", function(obj) OnDeleteObj(obj) end)

	-- Script succesfully loaded, enjoy.
	Say("Succesfully loaded " .. champ)
end


function OnTick()
	Checks()
	SpellChecks()
	target = ts:GetTarget(Spells.Q.range)

	if Menu.combo.combo:IsPressed() == true then
		activeClass:Combo()
	end
	if Menu.harass.harass:IsPressed() == true then
		activeClass:Harass()
	end

	if heal ~= nil and Menu.misc.autoheal.useHeal:Value() == true and not isRecalling then
		AutoHeal()
	end

	if ignite ~= nil and Menu.misc.autoignite.useIgnite:Value() == true then
		AutoIgnite()
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
	if Menu.draw.useDrawings:Value() == true then
		if Spells.Q.range and Menu.draw.drawQ:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Spells.W.range and Menu.draw.drawW:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Spells.E.range and Menu.draw.drawE:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Spells.R.range and Menu.draw.drawR:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.R.range, Graphics.RGB(100, 200, 150):ToNumber())
		end
	end
end

function InitializeGlobalVariables()	
	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}
	ignite, heal = nil, nil
	target = nil
	Iready, Hready = false, false
	usingHealthPot, usingManaPot, isRecalling = false, false, false
	KillText = {}
	--EnemyMinions = MinionManager.new(MinionManager.Mode.ENEMY, Spells.W.range, myHero, MinionManager.Sort.HEALTH_DEC)
	FindSummoners() 
	DrawGlobalMenu()

	EnemyTable = GetEnemyHeroes()
end

function SpellChecks()
	Hready = (heal ~= nil and myHero:CanUseSpell(heal) == Game.SpellState.READY)	
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == Game.SpellState.READY)
end 

function Checks()
	Spells.Q.ready = (myHero:CanUseSpell(Game.Slots.SPELL_1) == Game.SpellState.READY)
	Spells.W.ready = (myHero:CanUseSpell(Game.Slots.SPELL_2) == Game.SpellState.READY)
	Spells.E.ready = (myHero:CanUseSpell(Game.Slots.SPELL_3) == Game.SpellState.READY)
	Spells.R.ready = (myHero:CanUseSpell(Game.Slots.SPELL_4) == Game.SpellState.READY)
end

function FindSummoners()
	heal = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerheal") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerheal") and Game.Slots.SUMMONER_2
	ignite = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerdot") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerdot") and Game.Slots.SUMMONER_2
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

function GetIgniteDamage()
	return (50 + (20 * myHero.level))
end 

function DrawGlobalMenu()
	Menu = MenuConfig("Totally Series " .. champ)

	-- Combo
	Menu:Menu("combo", name ..  "Combo")
	Menu.combo:KeyBinding("combo", "Combo Key", "SPACE")
	Menu.combo:Boolean("comboItems", "Use Items", true)

	-- Harass
	Menu:Menu("harass", name .. "Harass")
	Menu.harass:KeyBinding("harass", "Harass Key", "T")

	-- Farming
	Menu:Menu("farm", name .. "Farm")
	Menu.farm:KeyBinding("farm", "Farm Key", "K")
	Menu.farm.farm:Toggle(true)

	-- Laneclear
	Menu:Menu("laneclear", name .. "LaneClear")
	Menu.laneclear:KeyBinding("laneclear", "LaneClear Key", "L")

	-- Drawings
	Menu:Menu("draw", name .. "Drawings")
	Menu.draw:Boolean("useDrawings", "Draw", true)

end

-- Drawing Global Misc Settings -- Same in every script --
function DrawGlobalMisc()
	if ignite ~= nil then
		Menu.misc:Menu("autoignite", "Auto Ignite")
		Menu.misc.autoignite:Boolean("useIgnite", "Automatically Use Ignite", false)
		for i, hero in ipairs(EnemyTable) do
			Menu.misc.autoignite:Boolean(hero.charName, "Use Ignite on " .. hero.charName, true)
		end
	end

	if heal ~= nil then
		Menu.misc:Menu("autoheal", "Auto Heal")
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

	Menu.misc:Menu("autopotions", "Auto Potions")
	Menu.misc.autopotions:Boolean("usePotions", "Automatically Use Potions", true)
	Menu.misc.autopotions:Boolean("useHealthPotion", "Use Health Potion", true)
	Menu.misc.autopotions:Slider("hpPerc", "Min Health % to use Potion", 0.60, 0, 1, 0.01)
	Menu.misc.autopotions:Boolean("useManaPotion", "Use Mana Potion", true)
	Menu.misc.autopotions:Slider("manaPerc", "Min Mana % to use Potion", 0.60, 0, 1, 0.01)
end

-- Global Drawing settings -- Same in every script -- obv
function DrawGlobalDrawings()
	Menu.draw:Boolean("drawQ", "Draw " .. Spells.Q.name .. " range", true)
	Menu.draw:Boolean("drawW", "Draw " .. Spells.W.name .. " range", true)
	Menu.draw:Boolean("drawE", "Draw " .. Spells.E.name .. " range", true)
	Menu.draw:Boolean("drawR", "Draw " .. Spells.R.name .. " range", true)
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
class 'Annie'
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

	self.Q = Spell(Game.Slots.SPELL_1, Spells.Q.range)
	self.W = Spell(Game.Slots.SPELL_2, Spells.W.range)
	self.E = Spell(Game.Slots.SPELL_3)
	self.R = Spell(Game.Slots.SPELL_4, Spells.R.range)
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
	    if Spells.E.ready then
	    	self.E:Cast()
		end
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
			self:ExecuteCombo(self:Combo1(), target)
		elseif Menu.combo.comboWay:Value() == 2 then
			self:ExecuteCombo(self:Combo2(), target)
		elseif Menu.combo.comboWay:Value() == 3 then
			self:ExecuteCombo(self:Combo3(), target)
		elseif Menu.combo.comboWay:Value() == 4 then
			self:ExecuteCombo(self:Combo4(), target)
		elseif Menu.combo.comboWay:Value() == 5 then
			self:ExecuteCombo(self:Combo5(), target)
		elseif Menu.combo.comboWay:Value() == 6 then
			self:ExecuteCombo(self:Combo6(), target)
		end
	end
end

function Annie:Combo1()
	return {"Q", "W", "R"}
end

function Annie:Combo2()
	return {"Q", "R", "W"}
end

function Annie:Combo3()
	return {"W", "Q", "R"}
end
function Annie:Combo4()
	return {"W", "R", "Q"}
end

function Annie:Combo5()
	return {"R", "Q", "W"}
end

function Annie:Combo6()
	return {"R", "W", "Q"}
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
			local Qdmg = (((Menu.autokill.autokillQ:Value() == true) and Spells.Q.ready and CalculateAPDamage("Q", 35, 45, 0.8, enemy)) or 0)
			local Wdmg = (((Menu.autokill.autokillW:Value() == true) and Spells.W.ready and CalculateAPDamage("W", 45, 25, 0.85, enemy)) or 0)
			local Rdmg = (((Menu.autokill.autokillR:Value() == true) and Spells.R.ready and not self.hasTibbers and CalculateAPDamage("R", 125, 50, 0.8, enemy)) or 0)
			local Idmg = (((Menu.autokill.autokillIgnite:Value() == true) and Iready and GetIgniteDamage()) or 0)

			if Wdmg > Qdmg and Qdmg > enemy.health then
				self.Q:Cast(target)
			elseif Wdmg > enemy.health then
				self.W:Cast(target)
			elseif Qdmg + Wdmg > enemy.health then
				self.Q:Cast(target)
				self.W:Cast(target)
			elseif ignite ~= nil and Qdmg + Wdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				self.Q:Cast(target)
				self.W:Cast(target)
			elseif Wdmg > Qdmg and Qdmg + Rdmg > enemy.health then
				self.Q:Cast(target)
				self.R:Cast(target)
			elseif Wdmg + Rdmg > enemy.health then
				self.W:Cast(target)
				self.R:Cast(target)
			elseif ignite ~= nil and Wdmg > Qdmg and Qdmg + Rdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				self.Q:Cast(target)
				self.R:Cast(target)
			elseif ignite ~= nil and Wdmg + Rdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				self.W:Cast(target)
				self.R:Cast(target)
			elseif Qdmg + Rdmg + Wdmg > enemy.health then
				self.Q:Cast(target)
				self.W:Cast(target)
				self.R:Cast(target) 
			elseif ignite ~= nil and Qdmg + Rdmg + Wdmg + Idmg > enemy.health then
				myHero:CastSpell(ignite, enemy)
				self.Q:Cast(target)
				self.W:Cast(target)
				self.R:Cast(target)
			end 
		end 
	end 
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
			local Qdmg = ((Spells.Q.ready and CalculateAPDamage("Q", 35, 45, 0.8, enemy)) or 0)
			local Wdmg = ((Spells.W.ready and CalculateAPDamage("W", 45, 25, 0.85, enemy)) or 0)
			local Rdmg = ((Spells.R.ready and not self.hasTibbers and CalculateAPDamage("R", 125, 50, 0.8, enemy)) or 0)
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

	-- Extra harass settings
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassR", "Use " .. Spells.R.name .. " (R)", true)

	-- Autokill settings
	Menu:Menu("autokill", name .. "Autokill")
	Menu.autokill:Boolean("autokill", "Perform AutoKill", false)
	Menu.autokill:Boolean("autokillQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.autokill:Boolean("autokillW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.autokill:Boolean("autokillR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.autokill:Boolean("autokillIgnite", "Use IGNITE", true)

	-- Farm
	Menu.farm:Boolean("farmQ", "Use" .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmW", "Use" .. Spells.W.name .. " (Q)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearQ", "Use" .. Spells.Q.name .. " (Q)", true)
	Menu.laneclear:Boolean("laneclearW", "Use" .. Spells.W.name .. " (Q)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("autoE", "Auto E")
	Menu.misc.autoE:Boolean("onAA", "Auto E when attacked", false)
	Menu.misc.autoE:Boolean("stackStun", "Auto E to stack stun", false)

	--Draws
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)


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

class 'Swain'
function Swain:__init()
	Spells = {
		["Q"] = {name = "Decrepify", range = 625, radius = 0, delay = 0, speed = 0, ready = false},
		["W"] = {name = "Nevermore", range = 900, radius = 125, delay = 0.85, speed = math.huge, ready = false},
		["E"] = {name = "Torment", range = 625, radius = 0, delay = 0, speed = 1400, ready = false},
		["R"] = {name = "Ravenous Flock", range = 800, delay = 0, speed = 0, ready = false}
	}
	

	--BasicPrediction.EnablePrediction()
	self.RcastedThroughBot = false

	self.Q = Spell(Game.Slots.SPELL_1, Spells.Q.range)
	self.W = Spell(Game.Slots.SPELL_2, Spells.W.range)
	self.W:SetSkillShot(Spells.W.delay, Spells.W.radius, Spells.W.speed, false, "aoe")
	self.E = Spell(Game.Slots.SPELL_3, Spells.E.range)
	self.R = Spell(Game.Slots.SPELL_4)

	self:ExtraMenu()
	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	Callback.Bind("Tick", function() self:OnTick() end)
	--Callback.Bind("CreateObj", function(obj) self:OnCreateObj(obj) end)
	--Callback.Bind("DeleteObj", function(obj) self:OnDeleteObj(obj) end)

end

function Swain:OnTick()
	if self.RcastedThroughBot and not Menu.combo.combo:IsPressed() and not Menu.laneclear.laneclear:IsPressed() and self:UltActive() and CountEnemies(Spells.R.range) < 1 then
 		myHero:CastSpell(Game.Slots.SPELL_4)
 		self.RcastedThroughBot = false
 	end

	if myHero.dead and self.RcastedThroughBot then 
		self.RcastedThroughBot = false
	end

end


function Swain:Combo()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.combo.comboItems:Value() == true then
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
	return (myHero:GetSpellData(Game.Slots.SPELL_1).range + myHero:DistanceTo(myHero.minBBox)/2) > 60
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
class 'LeBlanc'
function LeBlanc:__init()
	Spells = 	{
					["P"] = {name = "LeBlanc_Base_P_poof.troy"},
					["AA"] = {range = 525, name = "BasicAttack"},
					["Q"] = {name = "Sigil of Malice", spellname = "LeblancChaosOrb", range = 700, speed = 2000, markTimer = 3.5, activated = 0}, 
					["W"] = {name = "Distortion", spellname = "LeblancSlide", range = 600, radius = 250, speed = 2000, delay = 0.25, duration = 4, timeActivated = 0, isActivated = false, startPos = myHero.pos}, 
					["E"] = {name = "Ethereal Chains", spellname = "LeblancSoulShackle", range = 950, speed = 1600, delay = 0.25, radius = 95}, 
					["R"] = {name = "Mimic", spellname = "LeblancMimic", Qname = "LeblancChaosOrbM", Wname = "LeBlancSlideM",  Wreturnname = "leblancslidereturnm", Ename = "LeblancSoulShackleM"},
					["WR"] = {duration = 4, spellname = "LeblancSlideM", timeActivated = 0, isActivated = false, startPos = myHero.pos}
				}

	-- Drawing LeBlancs Menu
	self:ExtraMenu()

	-- Initializing Spells
	self.Q = Spell(Game.Slots.SPELL_1, Spells.Q.range)
	self.W = Spell(Game.Slots.SPELL_2, Spells.W.range)
	self.W:SetSkillShot(Spells.W.delay, Spells.W.radius, Spells.W.speed, false, "aoe")
	self.E = Spell(Game.Slots.SPELL_3, Spells.E.range)
	self.E:SetSkillShot(Spells.E.delay, Spells.E.radius, Spells.E.speed, true, "normal")


	-- Initializing TargetSelector
	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	-- Last activated Spell
	self.lastActivated = nil
			
	-- Regular Callback binds
	Callback.Bind("Tick", function() self:OnTick() end)
	--Callback.Bind("CreateObj", function(obj) self:OnCreateObj(obj) end)
	--Callback.Bind("DeleteObj", function(obj) self:OnDeleteObj(obj) end)
	Callback.Bind("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)
	Callback.Bind("Draw", function() self:OnDraw() end)
	--Callback.Bind("GainBuff", function(unit, buff) self:OnGainBuff(unit, buff) end)
	--Callback.Bind("LoseBuff", function(unit, buff) self:OnLoseBuff(unit, buff) end)
end

function LeBlanc:OnTick()
	self:CalcDamageCalculations()

	if Menu.settingsW.useOptional:Value() == true then
		self:WChecks()
		self:SpecificSpellChecks()
	end
	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end
	if Menu.misc.zhonyas.zhonyas:Value() == true then
		self:Zhonyas()
	end
end

function LeBlanc:OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == Spells.W.spellname then
		Spells.W.startPos = spell.startPos
	end
	if unit.isMe and spell.name == Spells.WR.spellname then
		Spells.WR.startPos = spell.startPos
	end
	if (unit.isMe and spell.name == Spells.Q.spellname) or (unit.isMe and spell.name == Spells.W.spellname) or (unit.isMe and spell.name == Spells.E.spellname) then
    	self.lastActivated = spell.name
    end
end

function LeBlanc:SpecificSpellChecks()
	if Menu.settingsW.useOptionalW:Value() == 1 then
		if self:wUsed() and self:wrUsed() then
			if CountEnemies(600, Spells.WR.startPos) < CountEnemies(600) then
				if not Spells.Q.ready and not Spells.E.ready then
					self.W:Cast()
				end
			end
		elseif self:wUsed() and CountEnemies(600, Spells.W.startPos) < CountEnemies(600) then
			self.W:Cast()
		elseif self:wrUsed() and CountEnemies(600, Spells.WR.startPos) < CountEnemies(600) then
			myHero:CastSpell(Game.Slots.SPELL_4)
		end
	elseif Menu.settingsW.useOptionalW:Value() == 3 or Menu.settingsW.useOptionalW:Value() == 4 then
		if self:wUsed() and self:wrUsed() then
			if not Spells.Q.ready and not Spells.E.ready then
				self.W:Cast()
			end
		elseif self:wUsed() then
			if not Spells.Q.ready and not Spells.E.ready then
				self.W:Cast()
			end
		elseif self:wrUsed() then
			if not Spells.Q.ready and not Spells.E.ready then
				myHero:CastSpell(Game.Slots.SPELL_4)
			end
		end
	end
end


function LeBlanc:Combo()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target) then
		if Menu.combo.comboItems:Value() == true then
			UseItems(target)
		end
		if Menu.combo.comboWay == 1 then
			self:ExecuteCombo(self:SmartCombo(target), target)
		elseif Menu.combo.comboWay == 2 then
			self:ExecuteCombo({"Q", "R", "W", "E"}, target)
		elseif Menu.combo.comboWay == 3 then
			self:ExecuteCombo({"Q", "W", "R", "E"}, target)
		elseif Menu.combo.comboWay == 4 then
			self:ExecuteCombo({"W", "Q", "R", "E"}, target)
		elseif Menu.combo.comboWay == 5 then
			self:ExecuteCombo({"W", "R", "Q", "E"}, target)
		end
	end
end

function LeBlanc:Harass()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target) then
		if Menu.harass.harassQ:Value() == true then
			self.Q:Cast()
		end
		if Menu.harass.harassW:Value() == true then
			if not self:wUsed() then
				self.W:Cast()
			end
		end
		if Menu.harass.harassE:Value() == true then
			self.E:Cast()
		end
	end
end


function LeBlanc:OnDraw()
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

function LeBlanc:ExecuteCombo(table, target)
	for i = 1, #table, 1 do
		local skill = table[i]
		if skill ~= nil then
			self:CastSkill(skill, target)
		end
	end
end

-- Sadly I can't really delete CastSkill here, cause the R is special. Goddamnit, Riot
function LeBlanc:CastSkill(skill, target)
	if skill == "Q" then
		self.Q:Cast(target)
	elseif skill == "W" and not self:wUsed() then
		self.W:Cast(target)
	elseif skill == "E" then
		self.E:Cast(target)
	elseif skill == "R" then
		if Spells.R.ready then
			if self.lastActivated == Spells.Q.spellname and myHero:DistanceTo(target) < Spells.Q.range then
				myHero:CastSpell(Game.Slots.SPELL_4, target)
			elseif self.lastActivated == Spells.W.spellname and myHero:DistanceTo(target) < Spells.W.range + 100 then
				myHero:CastSpell(Game.Slots.SPELL_4, target)
			end
		end
	end
end

-- Returns if W has been used or not
function LeBlanc:wUsed()
	if myHero:GetSpellData(_W).name == "leblancslidereturn" then
		return true
	end 
	return false
end
-- Returns if WR has been used or not
function LeBlanc:wrUsed()
	if myHero:GetSpellData(_R).name == "leblancslidereturnm" then
		return true
	end 
	return false
end 

-- Calculates damage to other heroes for KillText
function LeBlanc:CalcDamageCalculations()
	if myHero.dead then return end
	for i, enemy in ipairs(EnemyTable) do
		if ValidTarget(enemy) then
			local Qdmg = ((Spells.Q.ready and CalculateAPDamage("Q", 25, 30, 0.4, enemy)) or 0)
			local Wdmg = ((Spells.W.ready and not self:wUsed() and CalculateAPDamage("W", 40, 45, 0.6, enemy)) or 0)
			local Edmg = ((Spells.E.ready and CalculateAPDamage("E", 25, 15, 0.5, enemy)) or 0)
			local Idmg = ((Iready and GetIgniteDamage()) or 0)
			local RQdmg = Spells.R.ready and self.lastActivated == Spells.Q.spellname and self:SpellCalc("RQ")
			local RWdmg = Spells.R.ready and not self:wrUsed() and self.lastActivated == Spells.W.spellname and self:SpellCalc("RW")
			local QMark = Spells.Q.ready and self:SpellCalc("QMark")

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
				KillText[i] = "Q + R + W = kill"
			elseif Qdmg + RQdmg + QMark + QMark + Wdmg + Edmg > enemy.health then
				KillText[i] = "Q + R + W + E = kill"
			elseif Qdmg + Rdmg + Wdmg + Idmg > enemy.health then
				KillText[i] = "Full combo = kill"
			else
				KillText[i] = "Harass him!"
			end

		end
	end
end

-- KillSteals
function LeBlanc:KillSteal()
	for i = 1, Game.HeroCount(), 1 do
		local enemy = Game.Hero(i)
		if enemy.team ~= myHero.team and Menu.killsteal.enemies[enemy.charName]:Value() == true then
			local Qdmg = ((Spells.Q.ready and CalculateAPDamage("Q", 25, 30, 0.4, enemy)) or 0)
			local Wdmg = ((Spells.W.ready and not self:wUsed() and CalculateAPDamage("W", 40, 45, 0.6, enemy)) or 0)
			local Edmg = ((Spells.E.ready and CalculateAPDamage("E", 25, 15, 0.5, enemy)) or 0)
			local Idmg = ((Iready and GetIgniteDamage()) or 0)
			local RQdmg = Spells.R.ready and self.lastActivated == Spells.Q.spellname and self:SpellCalc("RQ")
			local RWdmg = Spells.R.ready and not self:wrUsed() and self.lastActivated == Spells.W.spellname and self:SpellCalc("RW")
			
			if Qdmg > enemy.health then
				self.Q:Cast(target)
			elseif Wdmg > enemy.health then
				self.W:Cast(target)
			elseif Edmg > enemy.health then
				self.E:Cast(target)
			elseif self.lastActivated == Spells.Q.spellname and RQdmg > enemy.health then
				CastSkill("R", enemy)
			elseif self.lastActivated == Spells.W.spellname and RWdmg > enemy.health then
				CastSkill("R", enemy)
			end 
		end
	end
end

-- Calculates Damage for specific LeBlanc spells
function LeBlanc:SpellCalc(spell)
	local dmg = 0
	if parameter == "RQ" then
		dmg = 100 * myHero:GetSpellData(Game.Slots.SPELL_4).level + 0.65 * myHero.ap
	elseif parameter == "RW" then
		dmg = 150 * myHero:GetSpellData(Game.Slots.SPELL_4).level + 0.975 * myHero.ap 
	elseif parameter == "RE" then
		dmg = 100 * myHero:GetSpellData(Game.Slots.SPELL_4).level + 0.65 * myHero.ap
	elseif parameter == "QMark" then
		dmg = 25 * myHero:GetSpellData(Game.Slots.SPELL_1).level + 30 + 0.4 * myHero.ap
	end 
	return myHero:CalcMagicDamage(target, dmg)
end


-- Specific LeBlancs Menu
function LeBlanc:ExtraMenu()

	-- Combo
	Menu.combo:Boolean("comboItems", "Use Items", true)
	Menu.combo:Slider("comboWay", "Perform Combo:", 1, {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"})

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- W Settings
	Menu:Menu("settingsW", name .. "Settings: W")
	Menu.settingsW:Boolean("useOptional", "Use Optional W Settings", true)
	Menu.settingsW:Slider("useOptionalW", "Return Way: ", 1, {"Smart", "Target dead", "Skills used", "Both"})

	--Farming
	Menu.farm:Boolean("farmQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.farm:Boolean("farmRange", "Minions outside AA range only", false)
	Menu.farm:Boolean("farmAA", "Farm if AA is on CD", SCRIPT_PARAM_ONOFF, false)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	--Drawings
	Menu.draw:Boolean("drawKilltext", "Draw KillText", false)
	
	-- Killsteal settings
	Menu:Menu("killsteal", name .. "KillSteal")
	Menu.killsteal:Boolean("killsteal", "Perform KillSteal", false)
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.killsteal:Boolean("killstealE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.killsteal:Boolean("killstealR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.killsteal:Menu("enemies", "Perform KillSteal On")
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if ValidTarget(hero) then
			Menu.killsteal.enemies:Boolean(hero.charName, hero.charName, true)
		end
	end

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("zhonyas", "Zhonyas")
 	Menu.misc.zhonyas:Boolean("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 	Menu.misc.zhonyas:Slider("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 ,2)
end

function LeBlanc:Zhonyas()
	if Menu.misc.zhonyas.zhonyasunder:Value() >= myHero.health / myHero.maxHealth then
		CastItem(3157)
	end
end

-- Will do this in February 
function LeBlanc:SmartCombo(target) 
	
end



class 'Blitzcrank'
function Blitzcrank:__init()
	Spells = {
		["Q"] = {name = "Rocket Grab", range = 925, radius = 0, delay = 0.25, speed = 1800, ready = false},
		["W"] = {name = "Overdrive", ready = false},
		["E"] = {name = "Power Fist", range = 125, ready = false},
		["R"] = {name = "Static Field", range = 600, speed = math.huge, ready = false}
	}
	

	--BasicPrediction.EnablePrediction()

	self.Q = Spell(Game.Slots.SPELL_1, Spells.Q.range)
	self.Q:SetSkillShot(Spells.Q.delay, Spells.Q.radius, Spells.Q.speed, false, "aoe")
	self.W = Spell(Game.Slots.SPELL_2)
	self.E = Spell(Game.Slots.SPELL_3, Spells.E.range)
	self.R = Spell(Game.Slots.SPELL_4, Spells.R.range)

	self:ExtraMenu()

	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	Callback.Bind("Tick", function() self:OnTick() end)
end

function Blitzcrank:OnTick()
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
		if Menu.combo.comboItems:Value() == true then
			UseItems(target)
		end
		if Menu.combo.comboE:Value() == true then
			self.E:Cast(target)
		end
		if Menu.combo.comboQ:Value() == true then
			self.Q:Cast(target)
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

function Blitzcrank:Interrupt(unit)
	if ValidTarget(unit) then
		self.Q:Cast(unit)
	end
end

function Blitzcrank:AutoR()
	if CountEnemies(Spells.R.range) >= Menu.autoR.autoRx then
		self.R:Cast()
	end
end

function Blitzcrank:KillSteal()
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if ValidTarget(hero) then
			local Qdmg = CalculateAPDamage("Q", 25, 55, 1, hero)
			local Rdmg = CalculateAPDamage("R", 125, 125, 1, hero)
			if Qdmg > enemy.health then
				self.Q:Cast(hero)
			elseif Rdmg > enemy.health and myHero:DistanceTo(hero) <= Spells.R.range then
				self.R:Cast()
			end
		end
	end
end

function Blitzcrank:ExtraMenu()
	-- Combo
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Slider("comboRx", "Min amount of people nearby to cast R", 1, 1, 5, 0)

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	-- Auto R
	Menu:Menu("autoR", "Automatic R")
	Menu.autoR:Boolean("autoR", "Automatically Activate R")
	Menu.autoR:Slider("autoRx", "Enemies In Range to R", 5, 1, 5, 0)

	-- KillSteal settings
	Menu:Menu("killsteal", name .. "KillSteal")
	Menu.killsteal:Boolean("killsteal", "Perform KillSteal", false)
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealR", "Use " .. Spells.R.name .. " (R)", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")
	Menu.misc:Menu("interrupt", "Interrupter")
	Interrupter(Menu.misc.interrupt, self:Interrupt(unit))

end


class 'Ryze'
function Ryze:__init()
	Spells = {
		["Q"] = {name = "Overload", range = 625, ready = false},
		["W"] = {name = "Rune Prison", range = 600, ready = false},
		["E"] = {name = "Spell Flux", range = 600, ready = false},
		["R"] = {name = "Desperate Power", ready = false}
	}
	

	--BasicPrediction.EnablePrediction()

	self.Q = Spell(Game.Slots.SPELL_1, Spells.Q.range)
	self.W = Spell(Game.Slots.SPELL_2, Spells.W.range)
	self.E = Spell(Game.Slots.SPELL_3, Spells.E.range)
	self.R = Spell(Game.Slots.SPELL_4)

	self:ExtraMenu()

	ts = TargetSelector("LESS_AP", Spells.Q.range, Menu) 

	Callback.Bind("Tick", function() self:OnTick() end)
end

function Ryze:OnTick()
	if Menu.killsteal.killsteal:Value() == true then
		self:KillSteal()
	end
end

function Ryze:Combo()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.combo.comboMode:Value() == 1
			self:ComboLong(target)
		else
			self:ComboBurst(target)
		end
	end
end

function Ryze:ComboBurst(target)
	if Menu.combo.comboItems:Value() == true then
		UseItems(target)
	end
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
	if Menu.combo.comboE:Value() == true then
		self.W:Cast(target)
	end
	if Menu.combo.comboQ:Value() == true then
		self.Q:Cast(target)
	end
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
			local Qdmg = Spells.Q.ready and CalculateAPDamage("Q", 20, 20, 0.4, hero)
			local Wdmg = Spells.W.ready and CalculateAPDamage("W", 25, 35, 0.6, hero)
			if Qdmg > enemy.health then
				self.Q:Cast(hero)
			elseif Wdmg > enemy.health then
				self.W:Cast(hero)
			end
		end
	end
end

function Ryze:ExtraMenu()
	-- Combo
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)
	Menu.combo:Dropdown("comboMode", "Mode", 1, {"Burst", "Long"})

	-- Harass
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- Laneclear
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (R)", true)

	-- KillSteal settings
	Menu:Menu("killsteal", name .. "KillSteal")
	Menu.killsteal:Boolean("killsteal", "Perform KillSteal", false)
	Menu.killsteal:Boolean("killstealQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.killsteal:Boolean("killstealW", "Use " .. Spells.W.name .. " (Q)", true)

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
		self.mode = self.menu.targetselector.mode:Value()
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
	self.mode = self.menu.targetselector.mode:Value()
	local range = range and range or self.range
	local target = nil
	if self.selected and myHero:DistanceTo(self.selected) <= self.range then return self.selected end

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
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 1, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	elseif self.mode == "LESS_AD" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 2, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	elseif self.mode == "LESS_AP" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 3, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	elseif self.mode == "MOST_DAMAGE" then
		self.menu.targetselector:DropDown("mode", "TargetSelector: ", 4, {"LESS_HP", "LESS_AD", "LESS_AP", "MOST_DAMAGE", "PRIORITY"})
	end
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if myHero.team ~= hero.team then
			self.menu.targetselector:Slider(hero.charName, hero.charName, 1, 1, 5, 0)
		end
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
	BasicPrediction.EnablePrediction()
end
-- Checking whether the target is in spell range
function Spell:InRange(target)
	return myHero:DistanceTo(target) <= self.range
end
-- Checking whether the spell can be casted
function Spell:CanCast()
	return myHero:CanUseSpell(self.slot) == Game.SpellState.READY
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
			if self:CanCast() then
				myHero:CastSpell(self.slot)
				return true
			end
		end
	end
	return false
end


class 'Interrupter'
function Interrupter:__init(menu, callback)
	self.interrupt = {
						["KatarinaR"]                  = { charName = "Katarina",     duration = 2.5},
					    ["Meditate"]                   = { charName = "MasterYi",     duration = 2.5},
					    ["Drain"]                      = { charName = "FiddleSticks", duration = 2.5},
					    ["Crowstorm"]                  = { charName = "FiddleSticks", duration = 2.5},
					    ["GalioIdolOfDurand"]          = { charName = "Galio",        duration = 2.5},
					    ["MissFortuneBulletTime"]      = { charName = "MissFortune",  duration = 2.5},
					    ["VelkozR"]                    = { charName = "Velkoz",       duration = 2.5},
					    ["InfiniteDuress"]             = { charName = "Warwick",      duration = 2.5},
					    ["AbsoluteZero"]               = { charName = "Nunu",         duration = 2.5},
					    ["ShenStandUnited"]            = { charName = "Shen",         duration = 2.5},
					    ["FallenOne"]                  = { charName = "Karthus",      duration = 2.5},
					    ["AlZaharNetherGrasp"]         = { charName = "Malzahar",     duration = 2.5},
					    ["Pantheon_GrandSkyfall_Jump"] = { charName = "Pantheon",     duration = 2.5},
					    ["AceInTheHole"] 			   = { charName = "Caitlyn",      duration = 1.0}
					}
	self.ActiveSpells = {}

	self:ApplyToMenu(menu)
	self.callback = callback

	Callback.Bind("Tick", function() self:OnTick() end)
	Callback.Bind("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)

end

function Interrupter:ApplyToMenu(menu)
	local hasAdded = false
	local Menu = menu

	Menu:Boolean("gapclose", "GapCloser Spells", false)
	for spell, data in pairs(self.interrupt) do
		Menu:Boolean(spell, spell .. " " .. data.charName, false)
		hasAdded = true
	end
	if not hasAdded then
		Menu:Info("info", "No spells found")
	end

	self.menu = Menu
end

function Interrupter:OnProcessSpell(unit, spell)
	if Menu.gapclose:Value() == true then
		if self.menu and self.menu[spell.name] then
			local data = {unit = unit, endTime = os.clock + self.interrupt[spell.name].duration}
			table.insert(self.activeSpells, data)
		end
	end
end

function Interrupter:OnTick()
	for i = 1, #self.activeSpells, 1 do
		if self.activeSpells[i].endTime > os.clock  then
			self.callback(self.activeSpells[i].unit)
		else
			table.remove(self.activeSpells, i)
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
		if ValidTarget(hero) then
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

function ValidTarget(target)
	return target.team ~= myHero.team and not target.dead and target.type == myHero.type
end

function CalculateAPDamage(skill, base_damage, damage, APratio, target)
	local dmg = 0
	if skill == "Q" then
		dmg = base_damage * myHero:GetSpellData(Game.Slots.SPELL_1).level + damage + APratio * myHero.ap
	elseif skill == "W" then
		dmg = base_damage * myHero:GetSpellData(Game.Slots.SPELL_2).level + damage + APratio * myHero.ap
	elseif skill == "E" then
		dmg = base_damage * myHero:GetSpellData(Game.Slots.SPELL_3).level + damage + APratio * myHero.ap
	elseif skill == "R" then
		dmg = base_damage * myHero:GetSpellData(Game.Slots.SPELL_4).level + damage + APratio * myHero.ap
	end
	return myHero:CalcMagicDamage(target, dmg)
end


