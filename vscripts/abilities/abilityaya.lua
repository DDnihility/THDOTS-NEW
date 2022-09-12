if AbilityAya == nil then
	AbilityAya = class({})
end

function OnAya01SpellStart(keys)
	AbilityAya:OnAya01Start(keys)	
end

function OnAya01SpellMove(keys)
	AbilityAya:OnAya01Move(keys)
end

function OnAya01SpellStart_Back(keys)
	AbilityAya:OnAya01Back(keys)
end

function OnAya01SpellBacking(keys)
	AbilityAya:OnAya01Backing(keys)
end

function OnAya02SpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,keys.EffectName,{duration = keys.Duration})
	if FindTelentValue(keys.caster,"special_bonus_unique_aya_6") ~= 0 then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_thdots_aya02_buff_talent",{duration = keys.Duration})
	else
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,keys.BuffName,{duration = keys.Duration})
	end
end

function OnAya02Attack(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(keys.attacker~=caster)then
		return
	end
	local target = keys.target
	local damage = keys.BounsDamage + target:GetMaxHealth() * FindTelentValue(keys.caster,"special_bonus_unique_aya_7")/100
	--print(damage)
	local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	}
	UnitDamageTarget(damage_table)
end

function OnAya03SpellStart(keys)
	AbilityAya:OnAya03Start(keys)
end

function aya03check(keys)
	AbilityAya:OnAya03Check(keys)
end

function OnAya04SpellOrderMoved(keys)
	AbilityAya:OnAya04OrderMoved(keys)
end

function OnAya04SpellOrderAttack(keys)
	AbilityAya:OnAya04OrderAttack(keys)
end

function OnAya04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	--if caster:HasModifier("modifier_item_wanbaochui") then
	--	THDReduceCooldown(keys.ability,-22)
	--end
	local ability = caster:FindAbilityByName("ability_thdots_aya01") 
			ability:EndCooldown()
	--还原
	UnitNoPathingfix(caster,caster,keys.ability:GetSpecialValueFor("ability_duration"))

	--caster.aya04count = keys.Count
	--print("caster.aya04count",caster.aya04count)
end

function OnAya04SpellRefresh(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	--判断
	--if caster.aya04count <= 0 then return end
	local ability = caster:FindAbilityByName("ability_thdots_aya01") 
		--if(ability~=nil)then
			ability:EndCooldown()
		--end
end


function AbilityAya:OnAya01Start(keys)
	--local caster = EntIndexToHScript(keys.caster_entindex)
	local caster = keys.caster
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_aya_1"))
	--计数
	--if caster:HasModifier("modifier_thdots_aya04_blink") then		
		--caster.aya04count = caster.aya04count - 1	
		--print("caster.aya04count",caster.aya04count)
	--end
	--if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_thdots_aya04_blink") then
	--	caster:SetMana(caster:GetMana()*0.94)
	--end	
	local targetPoint = keys.target_points[1]
	local Aya01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local Aya01dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	if(Aya01dis>keys.FixDis)then
		Aya01dis = keys.FixDis
	end
	keys.ability:SetContextNum("ability_Aya01_Rad",Aya01rad,0)
	keys.caster:FindAbilityByName("ability_thdots_aya03"):SetContextNum("ability_Aya01_Rad",Aya01rad,0)
	keys.ability:SetContextNum("ability_Aya01_Dis",Aya01dis,0)
	keys.caster:FindAbilityByName("ability_thdots_aya03"):SetContextNum("ability_Aya01_Dis",Aya01dis,0)
end

function AbilityAya:OnAya01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	--if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_thdots_aya04_blink") then
	--	local ability = caster:FindAbilityByName("ability_thdots_aya01")
	--	ability:EndCooldown()
		
	--end
	local flyspeed=keys.caster:FindAbilityByName("ability_thdots_aya01"):GetSpecialValueFor("move_speed") + FindTelentValue(keys.caster,"special_bonus_unique_aya_4")
	if caster:HasModifier("modifier_thdots_aya04_blink") then
		flyspeed=flyspeed+400*caster:GetModifierStackCount("modifier_thdots_aya04_blink", nil)
	end

	for _,v in pairs(targets) do
		if(v:GetContext("ability_Aya01_damage")==nil)then
			v:SetContextNum("ability_Aya01_damage",TRUE,0)
		end
		if(v:GetContext("ability_Aya01_damage")==TRUE)then
			if FindTelentValue(keys.caster,"special_bonus_unique_aya_5") ~= 0 then
				local ability02 = keys.caster:FindAbilityByName("ability_thdots_aya02")
				OnAya02SpellStart({caster = keys.caster,target = v,ability = ability02,EffectName = "modifier_thdots_aya02_effect",BuffName = "modifier_thdots_aya02_buff",Duration = 11})
			end
			if v:HasModifier("modifier_thdots_aya02_buff_talent") or v:HasModifier("modifier_thdots_aya02_buff") then
				local fixed_damage = keys.caster:FindAbilityByName("ability_thdots_aya02"):GetSpecialValueFor("bouns_damage") + v:GetMaxHealth() * FindTelentValue(keys.caster,"special_bonus_unique_aya_7")/100
				--print(fixed_damage)
				local damage_table_2 = {
					ability = keys.caster:FindAbilityByName("ability_thdots_aya02"),
					victim = v,
					attacker = caster,
					damage = fixed_damage,
					damage_type = keys.caster:FindAbilityByName("ability_thdots_aya02"):GetAbilityDamageType(),
	    	    	damage_flags = 0
				}
				UnitDamageTarget(damage_table_2)
			end
			if FindTelentValue(keys.caster,"special_bonus_unique_aya_8") ~= 0 then
				--[[keys.caster:PerformAttack(v,
						true,
						true,
						true,
						true,
						false,
						false,
						false
						)-- do not trigger crit items]]
				THDPerformAttack(keys.caster,v,false)
			end
			local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.caster:FindAbilityByName("ability_thdots_aya01"):GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_aya_2"),
			    damage_type = keys.caster:FindAbilityByName("ability_thdots_aya01"):GetAbilityDamageType(), 
	    	    damage_flags = 0
		    }
			UnitDamageTarget(damage_table)
			if v:IsRealHero() then
				if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_thdots_aya04_blink") then
					SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,caster,20,nil)
					caster:SetMana(caster:GetMana()+20)
					caster:FindModifierByName("modifier_thdots_aya04_blink"):SetDuration(math.min(caster:FindModifierByName("modifier_thdots_aya04_blink"):GetRemainingTime()+0.5,10.0),true)
					caster:SetModifierStackCount("modifier_thdots_aya04_blink", caster, math.min(caster:GetModifierStackCount("modifier_thdots_aya04_blink", nil) + 1 ,25))
				end
			end

			if v and not v:IsNull() then
				--if FindTelentValue(keys.caster,"special_bonus_unique_aya_7") ~= 0 then 
				--	keys.caster:FindAbilityByName("ability_thdots_aya01"):ApplyDataDrivenModifier( caster, v, "modifier_aya01_slow", {Duration=3} )
				--end
				
				--if v:IsHero() and caster:HasModifier("modifier_thdots_aya04_blink") and caster:GetClassname()=="npc_dota_hero_slark" then
				--	local ability = caster:FindAbilityByName("ability_thdots_aya01")
				--	ability:EndCooldown()
				--end

				v:SetContextNum("ability_Aya01_damage",FALSE,0)
				Timer.Wait 'ability_Aya01_damage_timer' (0.25/flyspeed*2000,
				function()
					v:SetContextNum("ability_Aya01_damage",TRUE,0)
				end
					)
			end
		end
	end

	local Aya01rad = keys.ability:GetContext("ability_Aya01_Rad")
	local vec = Vector(vecCaster.x+math.cos(Aya01rad)*flyspeed/50,vecCaster.y+math.sin(Aya01rad)*flyspeed/50,vecCaster.z)
	caster:SetOrigin(vec)
	
	local aya01dis = keys.ability:GetContext("ability_Aya01_Dis")
	if(aya01dis<0)then
		SetTargetToTraversable(caster)
		keys.ability:SetContextNum("ability_Aya01_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_aya01_think_interval")
	else
	    aya01dis = aya01dis -flyspeed/50
	    keys.ability:SetContextNum("ability_Aya01_Dis",aya01dis,0)
	end
end

function AbilityAya:OnAya03Check(keys)
	local ability = keys.ability
	if keys.caster:HasModifier("modifier_thdots_aya01_think_interval")==false and
	keys.caster:HasModifier("modifier_thdots_aya04_blink") then
		ability:SetActivated(true)
	else
		ability:SetActivated(false)
	end
end

function AbilityAya:OnAya01Back(keys)
	--keys.caster:RemoveModifierByName("modifier_thdots_aya01_back")
	if keys.caster:HasModifier("modifier_item_wanbaochui") then keys.caster:FindAbilityByName("ability_thdots_aya03"):EndCooldown() end
	local ability01 = keys.caster:FindAbilityByName("ability_thdots_aya01")
	local actual_move_speed = ability01:GetSpecialValueFor("move_speed")
	local actual_damage_radius = ability01:GetSpecialValueFor("damage_radius")
	local actual_move_duration = ability01:GetSpecialValueFor("move_duration")
	local actual_fix_distance = ability01:GetSpecialValueFor("fix_distance")
	--local actual_wanbaochui_slow = ability01:GetSpecialValueFor("wanbaochui_slow")
	local actual_abilitydamage = ability01:GetAbilityDamage()
	local actual_target_points = {}
	keys.caster:FindAbilityByName("ability_thdots_aya01"):SetContextNum("ability_Aya01_Dis",keys.ability:GetContext("ability_Aya01_Dis"),0)
	keys.caster:FindAbilityByName("ability_thdots_aya01"):SetContextNum("ability_Aya01_Rad",keys.caster:FindAbilityByName("ability_thdots_aya01"):GetContext("ability_Aya01_Rad")+math.pi,0)
	keys.caster:FindAbilityByName("ability_thdots_aya03"):SetContextNum("ability_Aya01_Rad",keys.ability:GetContext("ability_Aya01_Rad"),0)
	--OnAya01SpellStart({caster=keys.caster,ability=ability01,move_speed=actual_move_speed,damage_radius=actual_damage_radius,move_duration=actual_move_duration,FixDis=actual_fix_distance,wanbaochui_slow=actual_wanbaochui_slow,AbilityDamage=actual_abilitydamage,target_points=actual_target_points})
	keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_thdots_aya01_think_interval",{MoveSpeed=actual_move_speed,Radius=actual_damage_radius,Duration=actual_move_duration,FixDis=actual_fix_distance,AbilityDamage=actual_abilitydamage,target_points=actual_target_points})
end

function AbilityAya:OnAya01Backing(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local flyspeed=keys.caster:FindAbilityByName("ability_thdots_aya01"):GetSpecialValueFor("move_speed") + FindTelentValue(keys.caster,"special_bonus_unique_aya_4")
	if caster:HasModifier("modifier_thdots_aya04_blink") then
		flyspeed=flyspeed+400*caster:GetModifierStackCount("modifier_thdots_aya04_blink", nil)
	end
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		if(v:GetContext("ability_Aya01_damage")==nil)then
			v:SetContextNum("ability_Aya01_damage",TRUE,0)
		end
		if(v:GetContext("ability_Aya01_damage")==TRUE)then
			local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = (keys.caster:FindAbilityByName("ability_thdots_aya01"):GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_aya_2")) * (0.75 + 0.25 * FindTelentValue(caster,"special_bonus_unique_aya_3")),
			    damage_type = keys.caster:FindAbilityByName("ability_thdots_aya01"):GetAbilityDamageType(), 
	    	    damage_flags = 0
		    }
			UnitDamageTarget(damage_table)
			if v:IsRealHero() then
				if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_thdots_aya04_blink") then
					SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,caster,20,nil)
					caster:SetMana(caster:GetMana()+20)
					caster:FindModifierByName("modifier_thdots_aya04_blink"):SetDuration(math.min(caster:FindModifierByName("modifier_thdots_aya04_blink"):GetRemainingTime()+0.5,10.0),true)
					caster:SetModifierStackCount("modifier_thdots_aya04_blink", caster, math.min(caster:GetModifierStackCount("modifier_thdots_aya04_blink", nil) + 1 ,25))
				end
			end


			if v and not v:IsNull() then
				v:SetContextNum("ability_Aya01_damage",FALSE,0)
				Timer.Wait 'ability_Aya01_damage_timer' (0.25/flyspeed*2000,
				function()
					v:SetContextNum("ability_Aya01_damage",TRUE,0)
				end
					)
			end
		end
	end


	local Aya01rad = caster:FindAbilityByName("ability_thdots_aya01"):GetContext("ability_Aya01_Rad")
	local vec = Vector(vecCaster.x+math.cos(Aya01rad)*flyspeed/50,vecCaster.y+math.sin(Aya01rad)*flyspeed/50,vecCaster.z)
	caster:SetOrigin(vec)
	
	local aya01dis = caster:FindAbilityByName("ability_thdots_aya01"):GetContext("ability_Aya01_Dis")
	if(aya01dis<0)then
		--SetTargetToTraversable(caster)
		caster:FindAbilityByName("ability_thdots_aya01"):SetContextNum("ability_Aya01_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_aya01_think_interval")
	else
	    aya01dis = aya01dis -flyspeed/50
	    caster:FindAbilityByName("ability_thdots_aya01"):SetContextNum("ability_Aya01_Dis",aya01dis,0)
	end
end

function AbilityAya:OnAya03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local Attacker = keys.attacker
	for _,v in pairs(targets) do
		--local deal_damage = keys.AbilityMulti * caster:GetPrimaryStatValue() + FindValueTHD("base_damage",keys.ability)
		local deal_damage = keys.AbilityMulti * caster:GetAgility() + FindValueTHD("base_damage",keys.ability)

		if Attacker:IsRealHero() then
			deal_damage = deal_damage
		else deal_damage = deal_damage* 0.35
		end
		
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = deal_damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	local effectIndex = ParticleManager:CreateParticle(
	"particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf", 
	PATTACH_CUSTOMORIGIN, 
	caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin() + caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin() + caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 3, caster:GetOrigin() + caster:GetForwardVector()*100)
	ParticleManager:DestroyParticleSystemTime(effectIndex,2)
end

function AbilityAya:OnAya04OrderMoved(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:IsStunned() == false and caster:HasModifier("modifier_item_yukkuri_stick_debuff") == false then
		if(keys.ability:GetContext("ability_Aya04_blink_lock")==FALSE)then
			return
		end

		keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_thdots_aya04_animation", {Duration=0.3} )
		

		local vecMove = caster:GetOrigin() + keys.BlinkRange * caster:GetForwardVector()
		caster:SetOrigin(vecMove)

		local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/aya/ability_aya_04.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecMove)
		ParticleManager:SetParticleControl(effectIndex, 3, vecMove)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		
		
			

		if(keys.ability:GetContext("ability_Aya04_blink_lock")==TRUE or keys.ability:GetContext("ability_Aya04_blink_lock")==nil)then
			keys.ability:SetContextNum("ability_Aya04_blink_lock",FALSE,0)
			Timer.Wait 'ability_Aya04_blink_lock' (0.1,
				function()
					keys.ability:SetContextNum("ability_Aya04_blink_lock",TRUE,0)
					
				end
		    	)
		end
	end
end

function AbilityAya:OnAya04OrderAttack(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:IsStunned() == false and caster:HasModifier("modifier_item_yukkuri_stick_debuff") == false then
		if(keys.ability:GetContext("ability_Aya04_blink_lock")==FALSE)then
			return
		end
		local vectarget = keys.target:GetOrigin()
		caster:SetOrigin(vectarget)

		local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/aya/ability_aya_04.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vectarget)
		ParticleManager:SetParticleControl(effectIndex, 3, vectarget)
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		if(keys.ability:GetContext("ability_Aya04_blink_lock")==TRUE or keys.ability:GetContext("ability_Aya04_blink_lock")==nil)then
			keys.ability:SetContextNum("ability_Aya04_blink_lock",FALSE,0)
			Timer.Wait 'ability_Aya04_blink_lock' (0.1,
				function()
					keys.ability:SetContextNum("ability_Aya04_blink_lock",TRUE,0)
				end
		    	)
		end
	end
end

function OnAya04upgrade(keys)
	local caster = keys.caster
	if caster:GetClassname() == "npc_dota_hero_slark" then
		caster:SetOriginalModel("models/new_touhou_model/aya/aya_with_wing.vmdl")
	end
end

