function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
end

function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({name = " ", drop = {"2 ComboModes"}})
	Menu.Combo:MenuElement({name = " ", drop = {"BasicCombo if not Ready[E]"}})
	Menu.Combo:MenuElement({name = " ", drop = {"BurstCombo if Ready[E]"}})	
	Menu.Combo:MenuElement({name = " ", drop = {"BasicCombo/Q+R+W+AA+E+(ROut if not kill...)"}})
	Menu.Combo:MenuElement({name = " ", drop = {"Burst Combo/R3+E+W+AA+Q"}})			

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "UseWM", name = "[W] minion if no Enemy in AArange", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "LastHit[Q] if out of AArange", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "LastHit[W]", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 	
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 

	--LastHit
	Menu:MenuElement({type = MENU, id = "Last", name = "LastHit Minion"})
	Menu.Last:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Last:MenuElement({id = "UseQ", name = "[Q] if out of AArange", value = true})	
	Menu.Last:MenuElement({id = "Mana", name = "Min Mana to LastHit", value = 20, min = 0, max = 100, identifier = "%"})
	Menu.Last:MenuElement({id = "Active", name = "LastHit Key", key = string.byte("X")})	
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseRW", name = "[R]+[W] if in range", value = true})	
	Menu.ks:MenuElement({id = "UseRQ", name = "[R]+[Q] if range bigger", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	EData =
	{
	Type = _G.SPELLTYPE_CONE, Collision = false, Delay = 0.4, Radius = 80, Range = 600, Speed = 1000, Type = 2
	}

  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end  
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 650, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 125, 10))
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		if Menu.Last.Active:Value() then
			LastHit()	
		end
			
	end	

	KillSteal()
end

function Combo()
	
	if not Ready(_E) then
		ComboBasic()
	else
		ComboBurst()
	end	
end

function ComboBasic()
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
   
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			Control.CastSpell(HK_Q, target)
        end
       
        if Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_R) then
			Control.CastSpell(HK_R, target.pos)
		end		

		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 200 and Ready(_W) then
			Control.CastSpell(HK_W)	
        end		
		
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 600 and Ready(_E) and HasBuff(myHero, "forcepulsecancast") then
            local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
			end	
        end
		
		if myHero.pos:DistanceTo(target.pos) < 500 and Ready(_R) and not Ready(_Q) and not Ready(_E) then
			if target.health > (4 * myHero.totalDamage) then
			local castPos = target.pos:Extended(myHero.pos, 500) 
				Control.CastSpell(HK_R, castPos)
			end	
        end				
	end
end

function ComboBurst()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) and Ready(_E) and HasBuff(myHero, "forcepulsecancast") then
	local stacks = GotBuff(myHero, "RiftWalk")     
        if Menu.Combo.UseR:Value() and Ready(_R) then
			if stacks >= 2 then 
				if myHero.pos:DistanceTo(target.pos) < 650 then
					Control.CastSpell(HK_R, target.pos)
				end	
			else
				if myHero.pos:DistanceTo(target.pos) > 900 and myHero.pos:DistanceTo(target.pos) < 1200 then
					Control.CastSpell(HK_R, target.pos)
				else
					if myHero.pos:DistanceTo(target.pos) < 900 then
					local castPos = target.pos:Extended(myHero.pos, 500) 
						Control.CastSpell(HK_R, castPos)
					end	
				end				
			end	
		end

		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 600 then
            local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
			end	
        end

		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 200 and Ready(_W) then
			Control.CastSpell(HK_W)	
        end			
		
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			Control.CastSpell(HK_Q, target)
        end					
	end
end

function Harass()
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if Menu.Harass.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			Control.CastSpell(HK_Q, target)
        end
		
        if Menu.Harass.UseW:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 200 and Ready(_W) then			
			Control.CastSpell(HK_W)
        end	
		
        if Menu.Harass.UseWM:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) > 200 and Ready(_W) then			
			CastWMinion()
        end	

		if Menu.Harass.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 600 and Ready(_E) and HasBuff(myHero, "forcepulsecancast") then
            local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
			end	
        end				
	end
end	

function CastWMinion()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY then
			if myHero.pos:DistanceTo(minion.pos) < 200 and IsValid(minion) then
				Control.CastSpell(HK_W)
				Control.Attack(minion)
			end
		end
	end
end	

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > 200 and IsValid(minion) and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q, minion)
				end	
            end
			
            if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 600 and IsValid(minion) and Ready(_E) and HasBuff(myHero, "forcepulsecancast") then
                local count = GetMinionCount(300, minion)
				if count >= Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E, minion.pos)
				end
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 200 and IsValid(minion) and Ready(_W) then
				local Dmg = getdmg("W", minion, myHero, 1) + getdmg("W", minion, myHero, 2)
				if Dmg >= minion.health then	
					Control.CastSpell(HK_W)
				end	
            end			
        end
    end
end

function JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and IsValid(minion) and Ready(_Q) then
                Control.CastSpell(HK_Q, minion)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 200 and IsValid(minion) and Ready(_W) then	
				Control.CastSpell(HK_W)	
            end
			
            if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 600 and IsValid(minion) and Ready(_E) and HasBuff(myHero, "forcepulsecancast") then
				Control.CastSpell(HK_E, minion.pos)
            end			
        end
    end
end

function LastHit()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Last.Mana:Value() / 100
            
			if Menu.Last.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > 200 and IsValid(minion) and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q, minion)
				end	
            end
			
            if Menu.Last.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 200 and IsValid(minion) and Ready(_W) then
				local Dmg = getdmg("W", minion, myHero, 1) + getdmg("W", minion, myHero, 2)
				if Dmg >= minion.health then	
					Control.CastSpell(HK_W)
				end	
            end			
        end
    end
end

function KillSteal()	
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
       
	local stacks = GotBuff(myHero, "RiftWalk")
	local QDmg = getdmg("Q", target, myHero)
	local RminDmg = getdmg("R", target, myHero)
	local WDmg = (getdmg("W", target, myHero, 1) + getdmg("W", target, myHero, 2))
	local RDmg = (stacks * RminDmg)
	local RWDmg = (WDmg + Rdmg)
	local HP = (target.health + (target.hpRegen * 2))	
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			if QDmg >= HP then
				Control.CastSpell(HK_Q, target)
			end	
        end
		
        if Menu.ks.UseRW:Value() and myHero.pos:DistanceTo(target.pos) < 650 then
	
			if stacks >= 1 then

				if Ready(_R) and Ready(_W) and RWDmg >= HP then
					Control.CastSpell(HK_R, target.pos)
				end	
				if Ready(_W) myHero.pos:DistanceTo(target.pos) < 200 and WDmg >= target.health then
					Control.CastSpell(HK_W)
				end
			else
				if Ready(_R) and Ready(_W) and (RminDmg + WDmg) >= HP then
					Control.CastSpell(HK_R, target.pos)
				end	
				if Ready(_W) myHero.pos:DistanceTo(target.pos) < 200 and WDmg >= target.health then
					Control.CastSpell(HK_W)
				end				
			end
		end
		
		if Menu.ks.UseRQ:Value() and myHero.pos:DistanceTo(target.pos) > 650 and myHero.pos:DistanceTo(target.pos) < 1100 then
			if Ready(_R) and Ready(_Q) and QDmg >= HP then
				Control.CastSpell(HK_R, target.pos)
			end			
        end
	end	
end
