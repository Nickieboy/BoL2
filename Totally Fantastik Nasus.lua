-- uwotfunction Say(text) gg
function Say(text)
	Game.Chat.Print("<font color=\"#FF0000\"><b>Totally Fantasik Nasus:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

Callback.Bind("Load", function()
	Callback.Bind("GameStart", function() OnLoad() end)
end)

Spells = {Q = {name = ""}, W = {name = ""}, E = {name = ""}, R = {name = ""}}

function OnLoad()
	if myHero.charName ~= "Nasus" then return end

	InitializeVariables() 

	Callback.Bind("Tick", function() OnTick() end)
	Callback.Bind("Draw", function() OnDraw() end)
	Callback.Bind("CreateObj", function(obj) OnCreateObj(obj) end)
  	Callback.Bind("UpdateObj", function(obj) OnUpdateObj(obj) end)
	Callback.Bind("DeleteObj", function(obj) OnDeleteObj(obj) end)
	Callback.Bind("ProcessSpell", function(unit, spell) OnProcessSpell(unit, spell) end)
    Callback.Bind("GainBuff", function(unit, buff) OnGainBuff(unit, buff) end)
end

function OnTick()
	target = ts:GetTarget(Spells.Q.range)
	SpellChecks()


end


function OnGainBuff(unit, buff)
  Game.Chat.Print("Gained : " .. buff.name)
end

function OnDraw()
	if Menu.draw.useDrawings:Value() == true then
		if Menu.draw.drawQ:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

		if Menu.draw.drawW:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, Graphics.RGB(100, 200, 150):ToNumber())
		end
    
    	if Menu.draw.drawE:Value() == true then
			Graphics.DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, Graphics.RGB(100, 200, 150):ToNumber())
		end

	end
end


function OnCreateObj(obj)
  if myHero:DistanceTo(obj) < 50 then
    Game.Chat.Print("Fantasik has obtain the awesome: " .. obj.name)
  end
end

function OnUpdateObj(obj)
  if obj.name ~= "Maikie61" and myHero:DistanceTo(obj) < 50 then
    Game.Chat.Print("Fantasik has updated the awesome: " .. obj.name)
  end
end


function OnDeleteObj(obj)
  if myHero:DistanceTo(obj) < 50 then
    Game.Chat.Print("Fantasik has lost the awesome: " .. obj.name)
  end  
end

function OnProcessSpell(unit, spell)
end


function InitializeVariables()
  Spells = {
		["Q"] = {name = "Siphoning Strike", range = 125, ready = false},
		["W"] = {name = "Wither", range = 600, ready = false},
		["E"] = {name = "Spirit Fire", range = 650, radius = 400, speed = math.huge, delay = 0.20, ready = false},
		["R"] = {name = "Fury Of The Sands", ready = false}
	}
 DrawMenu()
 ts = TargetSelector("LESS_AP", Spells.Q.range, Menu)
 FindSummoners() 
 EnemyTable = GetEnemyHeroes()
end

function Combo()
	if ValidTarget(target) then
    	if myHero:DistanceTo(target) < Spells.E.range and Spells.E.ready then
      		myHero:CastSpell(2, target.x, target.z)
      	end
    	if myHero:DistanceTo(target) < Spells.W.range and Spells.W.ready then
      		myHero:CastSpell(1, target)
      	end
    	if myHero:DistanceTo(target) < Spells.Q.range and Spells.Q.ready then
      		myHero:CastSpell(0)
      	end
    end
end


function Harass()
	
end

function SpellChecks()
	Spells.Q.ready = (myHero:CanUseSpell(Game.Slots.SPELL_1) == Game.SpellState.READY)
	Spells.W.ready = (myHero:CanUseSpell(Game.Slots.SPELL_2) == Game.SpellState.READY)
	Spells.E.ready = (myHero:CanUseSpell(Game.Slots.SPELL_3) == Game.SpellState.READY)
	Spells.R.ready = (myHero:CanUseSpell(Game.Slots.SPELL_4) == Game.SpellState.READY)
	
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == Game.SpellState.READY)
end 

function FindSummoners() 
	ignite = myHero:GetSpellData(Game.Slots.SUMMONER_1).name:find("summonerdot") and Game.Slots.SUMMONER_1 or myHero:GetSpellData(Game.Slots.SUMMONER_2).name:find("summonerdot") and Game.Slots.SUMMONER_2
end

function KillSteal()
  for i, enemy in ipairs(EnemyTable) do
    if ValidTarget(enemy) then
      local Qdmg = Spells.Q.ready and CalcDamage("Q", enemy)
      local Edmg = Spells.E.ready and CalcDamage("E", enemy)
      if myHero:DistanceTo(enemy) <= Spells.Q.range and Qdmg > enemy.health then
        myHero:CastSpell(0, enemy)
       elseif myHero:DistanceTo(enemy) <= Spells.E.range and Edmg > enemy.health then
        myHero:CastSpell(2, enemy.x, enemy.z)
       end
    end
  end
end

function CalcDamage(skill, target)
  local dmg = 0
  if skill = "Q" then
      dmg = 10 * myHero:GetSpellData(0).level + 20 
      dmg = dmg -- + qStacks
      dmg = myHero:CalcDamage(dmg, target)
  elseif skill = "E" then
    dmg = 15 * myHero:GetSpellData(2).level + 40 + 0.6 * myHero.ap
    dmg = myHero:CalcMagicDamage(dmg, target)
  end
  return dmg
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

function GetIgniteDamage()
	return (50 + (20 * myHero.level))
end 

function ValidTarget(target)
	return target.team ~= myHero.team and not target.dead and target.type == myHero.type
end

function DrawMenu()
	Menu = MenuConfig("Nasus", "Nasus")

	-- Combo
	Menu:Menu("combo", name ..  "Combo")
	Menu.combo:KeyBinding("combo", "Combo Key", "SPACE")
	Menu.combo:Boolean("comboQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.combo:Boolean("comboW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.combo:Boolean("comboE", "Use " .. Spells.E.name .. " (E)", true)
	Menu.combo:Boolean("comboR", "Use " .. Spells.R.name .. " (R)", true)


	-- Harass
	Menu:Menu("harass", name .. "Harass")
	Menu.harass:KeyBinding("harass", "Harass Key", "T")
	Menu.harass:Boolean("harassQ", "Use " .. Spells.Q.name .. " (Q)", true)
	Menu.harass:Boolean("harassW", "Use " .. Spells.W.name .. " (W)", true)
	Menu.harass:Boolean("harassE", "Use " .. Spells.E.name .. " (E)", true)

	-- Farm
	Menu:Menu("farm", name .. "Farm")
	Menu.farm:KeyBinding("farm", "Farm Key", "K")
	Menu.farm.farm:Toggle(true)
	Menu.farm:Boolean("farmQ", "Use" .. Spells.Q.name .. " (Q)", true)
	Menu.farm:Boolean("farmE", "Use" .. Spells.E.name .. " (E)", false)

	-- Laneclear
	Menu:Menu("laneclear", name .. "Laneclear")
	Menu.laneclear:KeyBinding("laneclear", "Harass Key", "K")
	Menu.laneclear:Boolean("laneclearQ", "Use" .. Spells.Q.name .. " (Q)", true)
	Menu.laneclear:Boolean("laneclearE", "Use" .. Spells.E.name .. " (E)", true)

	-- Drawings
	Menu:Menu("draw", name .. "Drawings")
	Menu.draw:Boolean("useDrawings", "Draw", true)
	Menu.draw:Boolean("drawQ", "Draw " .. Spells.Q.name .. " range", true)
	Menu.draw:Boolean("drawW", "Draw " .. Spells.W.name .. " range", true)
	Menu.draw:Boolean("drawE", "Draw " .. Spells.E.name .. " range", true)
	Menu.draw:Boolean("drawKilltext", "Draw KillText", true)

	-- Misc
	Menu:Menu("misc", name .. "Misc")

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

	Menu.misc:Menu("autopotions", "Auto Potions")
	Menu.misc.autopotions:Boolean("usePotions", "Automatically Use Potions", true)
	Menu.misc.autopotions:Boolean("useHealthPotion", "Use Health Potion", true)
	Menu.misc.autopotions:Slider("hpPerc", "Min Health % to use Potion", 0.60, 0, 1, 0.01)
	Menu.misc.autopotions:Boolean("useManaPotion", "Use Mana Potion", true)
	Menu.misc.autopotions:Slider("manaPerc", "Min Mana % to use Potion", 0.60, 0, 1, 0.01)

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
	if self.selected and self.selected.type == myHero.type and myHero:DistanceTo(self.selected) <= self.range then return self.selected end

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

function DrawFont(msg)
	return "<font color=\"#99EBD6\">" .. tostring(msg) .. "</font>" 
end



function GetEnemyHeroes()
	local enemies = {}
	for i = 1, Game.HeroCount(), 1 do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team and hero.type == myHero.type then
			table.insert(enemies, hero)
		end
	end
	return enemies
end
