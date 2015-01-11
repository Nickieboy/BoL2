--[[

		Script details:
			Series: Totally Series AIO
			Champion: Swain
			Author: Totally Legit
			Designed for: Cloudrop
			Current version: 0.1	

			Features:

				Combo
					Normal Combo

				Harass
					Option to poke enemy with:
						Q
						W
						E

				LaneClear
					LaneClear with W
					LaneClear with R

				Auto Ignite
				Auto Heal
				Auto Potions

				Script has prediction on W

		Changelog:
			0.1
				Started coding
--]]


function Say(text)
	Game.Chat.Print("<font color=\"#FF0000\"><b>Totally Swain:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

Callback.Bind("Load", function()
	Callback.Bind("GameStart", function() OnLoad() end)
end)

function OnLoad()
	if myHero.charName ~= "Swain" then return end
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
	
	--EnemyMinions:update()

	SpellChecks()

	if Menu.combo.combo:IsPressed() == true then Combo() end
	if Menu.harass.harass:IsPressed() == true then Harass() end
	--if Menu.laneclear.laneclear:IsPressed() == true then LaneClear() end

	if heal ~= nil and Menu.misc.autoheal.useHeal:Value() == true and not isRecalling then
		AutoHeal()
	end

	if ignite ~= nil and Menu.misc.autoignite.useIgnite:Value() == true then
		AutoIgnite()
	end

	if RcastedThroughBot and not Menu.combo.combo:IsPressed() == true and not Menu.laneclear.laneclear:IsPressed() and ultActive and CountEnemiesInRange(Spells.R.range) < 1 then
 		myHero:CastSpell(Game.Slots.SPELL_4)
 		RcastedThroughBot = false

 	end

	if myHero.dead then ultActive = false end

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

function OnProcessSpell(unit, spell)
    if unit.isMe then
    	if spell.name == "SwainMetamorphism" and ultActive then
    		 ultActive = false
    		 return
    	end 

    	if spell.name == "SwainMetamorphism" and not ultActive then
    		ultActive = true
    		return
    	end 
    end 
end


function OnDraw()
	if myHero.dead then return end
	if Menu.draw.useDrawings:Value() == true then
		if Menu.draw.drawQ:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawW:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawE:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawR:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.R.range, Graphics.RGB(100, 200, 150):ToNumber())
		end
	end
end


function Combo()
	if myHero.dead then return end
	if target ~= nil then

		if Menu.combo.comboR:Value() == true then
			CastR(target)
		end

		if Menu.combo.comboE:Value() == true then
			CastE(target)
		end

		if Menu.combo.comboQ:Value() == true then
			CastQ(target)
		end

		if Menu.combo.comboW:Value() == true then
			CastW(target)
		end

	end
end 


function Harass()
	if target ~= nil then
		if Menu.harass.harassE:Value() == true then
			CastE(target)
		end

		if Menu.harass.harassQ:Value() == true then
			CastQ(target)
		end

		if Menu.harass.harassW:Value() == true then
			CastW(target)
		end
	end
end


function LaneClear()
	if Menu.laneclear.laneclearW:Value() == true then
		local position, count = GetBestAOEPosition(EnemyMinions, Spells.W.range, Spells.W.radius, myHero)
		CastSpell(Game.Slots.SPELL_2, position.x, position.z)
	end

	if Menu.laneclear.laneclearR:Value() == true and CountMinions(EnemyMinions, range) >= 1 and not ultActive then
		CastSpell(Game.Slots.SPELL_4)
	end

	if Menu.laneclear.laneclearR:Value() == true and CountMinions(EnemyMinions, range) < 1 and ultActive then
		CastSpell(Game.Slots.SPELL_4)
	end
end



function CountEnemiesInRange(range)
	local count = 0
	for i = 1, Game.HeroCount(), 1 do
		local enemy = Game.Hero(i)
		if ValidTarget(enemy) and myHero:DistanceTo(enemy) <= range then
			count = count + 1
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
		if source:DistanceTo(object) < range then
			local count = 0
			for i, ob in ipairs(objects) do
				if object:DistanceTo(ob) <= radius * radius then
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
        if ValidTarget(object) and myHero:distanceTo(object) <= range then
            count = count + 1
        end
    end
    return count
end

function CastQ(target)
	if ValidTarget(target) and myHero:DistanceTo(target) <= Spells.Q.range and Spells.Q.ready then
		myHero:CastSpell(Game.Slots.SPELL_1, target)
	end
end 

function CastW(target)
	if ValidTarget(target) and myHero:DistanceTo(target) <= Spells.W.range and Spells.W.ready then
		--local PredictionPosition, enemies, count = BasicPrediction.GetBestAoEPositionForce(target, Spells.W.range, Spells.W.speed, Spells.W.delay, Spells.W.radius, false, false, myHero)
		--if type(PredictionPosition) == "Vector3" and Hitchance >= 1 then
		--	CastSpell(Game.Slots.SPELL_2, PredictionPosition.x, PredictionPosition.z)
		--end
		CastSpell(Game.Slots.SPELL_2, target)
	end
end

function CastE(target)
	if ValidTarget(target) and myHero:DistanceTo(target) <= Spells.E.range and Spells.E.ready then
		myHero:CastSpell(Game.Slots.SPELL_3, target)
	end
end 

function CastR()
	if Spells.R.ready and not ultActive then
		RcastedThroughBot = true
		myHero:CastSpell(Game.Slots.SPELL_4)
	end 
end

function InitializeVariables()
	Spells = {
		["Q"] = {name = "Decrepify", range = 625, radius = 0, delay = 0, speed = 0, ready = false},
		["W"] = {name = "Nevermore", range = 900, radius = 125, delay = 0.85, speed = math.huge, ready = false},
		["E"] = {name = "Torment", range = 625, radius = 0, delay = 0, speed = 1400, ready = false},
		["R"] = {name = "Ravenous Flock", range = 800, delay = 0, speed = 0, ready = false}

	}
	
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

	ts = TargetSelector("LESS_AP", Spells.W.range) 

	ultActive = false
	ignite, heal = nil, nil
	isRecalling = false
	target = nil
	Iready, Fready = false, false, false, false, false, false, false, false, false
	usingHealthPot, usingManaPot = false, false
	AAdisabled = false
	KillText = {}
	--BasicPrediction.EnablePrediction()
	--EnemyMinions = MinionManager.new(MinionManager.Mode.ENEMY, Spells.W.range, myHero, MinionManager.Sort.HEALTH_DEC)
	FindSummoners() 
	DrawMenu()
end

function SpellChecks()
	Spells.Q.ready = (myHero:CanUseSpell(Game.Slots.SPELL_1) == Game.SpellState.READY)
	Spells.W.ready = (myHero:CanUseSpell(Game.Slots.SPELL_2) == Game.SpellState.READY)
	Spells.E.ready = (myHero:CanUseSpell(Game.Slots.SPELL_3) == Game.SpellState.READY)
	Spells.R.ready = (myHero:CanUseSpell(Game.Slots.SPELL_4) == Game.SpellState.READY)

	Hready = (heal ~= nil and myHero:CanUseSpell(heal) == Game.SpellState.Ready)	
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == Game.SpellState.Ready)
end 

function FindSummoners()
	heal = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerheal") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerheal") and Game.Slots.SUMMONER_2
	ignite = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerdot") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerdot") and Game.Slots.SUMMONER_2
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
	if myHero.health / myHero <= Menu.misc.autoheal.hpPerc:Value() and Hready then
		myHero:CastSpell(heal)
	end
	if Menu.misc.autoheal.helpTeam:Value() == true then
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
		dmg = 15 * myHero:GetSpellData(Game.Slots.SPELL_1).level + 10 + 0.3 * myHero.ap
	elseif skill == "W" then
		dmg = 40 * myHero:GetSpellData(Game.Slots.SPELL_2).level + 40 + 0.7 * myHero.ap
	elseif skill == "E" then
		dmg = 40 * myHero:GetSpellData(Game.Slots.SPELL_3).level + 35 + 0.8 * myHero.ap
	elseif skill == "R" then
		dmg = 20 * myHero:GetSpellData(Game.Slots.SPELL_4).level + 30 + 0.2 * myHero.ap
	end
	return myHero:CalcMagicDamage(target, dmg)
end

function DrawMenu()
	Menu = MenuConfig("Totally Swain - The Scarecrow")
	local name = "Totally LeBlanc - " 

	-- Combo
	Menu:Menu("combo", name ..  "Combo")
	Menu.combo:KeyBinding("combo", "Combo Key", "SPACE")
	Menu.combo:Boolean("comboItesm", "Use Items", true)
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (W)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)

	-- Harass
	Menu:Menu("harass", name .. "Harass")
	Menu.harass:KeyBinding("harass", "Harass Key", "T")
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (Q)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (R)", true)

	-- Laneclear
	Menu:Menu("laneclear", name .. "Laneclear")
	Menu.laneclear:KeyBinding("laneclear", "Laneclear Key", "K")
	Menu.laneclear:Boolean("laneclearW", "Use " .. Spells.W.name .. " (Q)", true)
	Menu.laneclear:Boolean("laneclearR", "Use " .. Spells.R.name .. " (Q)", true)

	-- Drawings
	Menu:Menu("draw", name .. "Drawings")
	Menu.draw:Boolean("useDrawings", "Draw", true)
	Menu.draw:Boolean("drawQ", "Draw " .. Spells.Q.name .. " range", true)
	Menu.draw:Boolean("drawW", "Draw " .. Spells.W.name .. " range", true)
	Menu.draw:Boolean("drawE", "Draw " .. Spells.E.name .. " range", true)
	Menu.draw:Boolean("drawR", "Draw " .. Spells.R.name .. " range", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")

	if ignite ~= nil then
		Menu.misc:Menu("autoignite", "Auto Ignite")
		Menu.misc.autoheal:Boolean("useIgnite", "Automatically Use Ignite", false)
		for i, hero in ipairs(Game.HeroCount()) do
			if hero.team ~= myHero.team then
				Menu.misc.autoheal:Boolean(enemy.charName, "Use Ignite on " .. hero.charName, true)
			end
		end
	end

	if heal ~= nil then
		Menu.misc:Menu("autoheal", "Auto Heal")
		Menu.misc.autoheal:Boolean("useHeal", "Automatically use Heal", true)
		Menu.misc.autoheal:Slider("hpPerc", "Min percentage to cast Heal", 0.15, 0, 1, 0.01)
		Menu.misc.autoheal:Boolean("helpTeammate", "Use Heal to Help teammates", false)
		Menu.misc.autoheal:Menu("teammates", "Teammates to Heal")
		for i, hero in ipairs(Game.HeroCount()) do
			if hero.team == myHero.team and not hero.isMe then
				Menu.misc.autoheal.teammates:Boolean(enemy.charName, "Use Heal on " .. hero.charName, true)
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

