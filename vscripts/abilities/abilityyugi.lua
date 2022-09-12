if AbilityYugi == nil then
	AbilityYugi = class({})
end

function OnYugi03Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local Attacker = keys.attacker
	if(target:IsBuilding())then
		return
	end
	if not caster:HasModifier("ability_yugi03_animation") then return end
	caster:RemoveModifierByName("ability_yugi03_animation")

	local telentDamage = FindTelentValue(caster,"special_bonus_unique_yugi_1") * caster:GetStrength()

	local dealdamage = keys.BounsDamage + telentDamage

	if Attacker:IsRealHero() then
		dealdamage = dealdamage
	else dealdamage = dealdamage* 0.35
	end

	local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = dealdamage,
			damage_type = keys.ability:GetAbilityDamageType(),
	    	damage_flags = 0
	}
	local knockback_properties = {
			 center_x 			= caster:GetOrigin().x,
			 center_y 			= caster:GetOrigin().y,
			 center_z 			= caster:GetOrigin().z,
			 duration 			= 1 ,
			 knockback_duration = 1,
			 knockback_distance = keys.Distance,
			 knockback_height 	= 200,
		}
	UtilStun:UnitStunTarget( caster,target,1.0)
	target:AddNewModifier(caster, self, "modifier_knockback", knockback_properties)
	target:EmitSound("Hero_Spirit_Breaker.GreaterBash")
	UnitDamageTarget(damage_table)
end

function OnYugi03Refresh(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("ability_yugi03_animation")
end

function OnYugi03Fail(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if not caster:HasModifier("ability_yugi03_animation") then return end
	caster:RemoveModifierByName("ability_yugi03_animation")
end


function OnYugi04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecTarget = target:GetOrigin()
	local ability_radius = keys.ability:GetSpecialValueFor("ability_radius")
	local ability_duration = keys.ability:GetSpecialValueFor("ability_duration")
	target:SetContextNum("ability_yugi04_point_x",vecTarget.x,0)
	target:SetContextNum("ability_yugi04_point_y",vecTarget.y,0)
	keys.ability.Iscandan = false
	if target:IsHero() and caster:GetName() == "npc_dota_hero_centaur" then
		if RollPercentage(2) then
			caster:EmitSound("Voice_Thdots_Yugi.AbilityYugi04_1")
			keys.ability.Iscandan = true
		else
			caster:EmitSound("Voice_Thdots_Yugi.AbilityYugi04")
		end
	end
	--以下是特效
	local coil_thinker = CreateModifierThinker(
		caster,
		keys.ability,
		"modifier_yugi04_effect",
		{duration = ability_duration},
		vecTarget,
		caster:GetTeamNumber(),
		false
	)

	local coil_modifier = target:AddNewModifier(caster, keys.ability, "modifier_imba_puck_dream_coil", 
		{
			duration		= ability_duration,
			coil_thinker	= coil_thinker:entindex()
		})

	local coil_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_ABSORIGIN, coil_thinker)
	ParticleManager:SetParticleControlEnt(coil_particle, 0, coil_thinker, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", coil_thinker:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(coil_particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	local count = ability_duration

	target:SetContextThink("yugi04", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			local particle = ParticleManager:CreateParticle("particles/heroes/seija/seija04.vpcf", PATTACH_ABSORIGIN_FOLLOW, coil_thinker)
		    ParticleManager:SetParticleControl(particle, 2, Vector(ability_radius, ability_radius, ability_radius))
		    ParticleManager:ReleaseParticleIndex(particle)
		    count = count - 0.5
		    if count <= 0 then
		    	return nil
		    else
		    	return 0.5
		    end
		end,
		0)
end

modifier_yugi04_effect = {}
LinkLuaModifier("modifier_yugi04_effect", "scripts/vscripts/abilities/abilityYugi.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_yugi04_effect:GetEffectName()
	return "particles/units/heroes/hero_puck/puck_dreamcoil.vpcf"
end

function OnYugi04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:GetClassname()=="npc_dota_roshan")then
		return
	end
	if target:HasModifier("modifier_void_spirit_aether_remnant_pull") then
		target:RemoveModifierByName("modifier_void_spirit_aether_remnant_pull")
	end
	local vecPoint = Vector(target:GetContext("ability_yugi04_point_x"),target:GetContext("ability_yugi04_point_y"),0)
	local dis = GetDistanceBetweenTwoVec2D(target:GetOrigin(),vecPoint)




	if(dis>keys.AbilityRadius)then
		target:EmitSound("Ability.SandKing_CausticFinale")
		if target:IsRealHero() and keys.ability.Iscandan == true then
			target:EmitSound("Voice_Thdots_Yugi.AbilityYugi04_2")
			keys.ability.Iscandan = false
		end
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		-- local damage_table = {
		-- 	ability = keys.ability,
		-- 	victim = target,
		-- 	attacker = caster,
		-- 	damage = 99999,
		-- 	damage_type = DAMAGE_TYPE_HP_REMOVAL,
		-- 	damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION
		-- }
		-- UnitDamageTarget(damage_table)
		if(caster~=nil)then
			target:Kill(keys.ability, caster)
		else
			target:Kill(keys.ability, nil)
		end
	end
end

function OnYugi04SpellEnd(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if not target or target:IsNull() then return end

	local dealdamage = target:GetMaxHealth() * (keys.DamagePercent+FindTelentValue(caster,"special_bonus_unique_yugi_3")) / 100
	local damage_table = {
		ability = keys.ability,
		victim = target,
		attacker = caster,
		damage = dealdamage,
		damage_type = keys.ability:GetAbilityDamageType(),
	    damage_flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	}
	target:EmitSound("Ability.SandKing_CausticFinale")
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	UnitDamageTarget(damage_table)
end

function OnYugiKill(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = caster:FindAbilityByName("ability_thdots_yugi04")
	if FindTelentValue(caster,"special_bonus_unique_yugi_2") ~= 0 and keys.unit:IsHero()==true and keys.unit:HasModifier("modifier_illusion")==false then
		ability:EndCooldown()
	end
end

function OnYugi04wanbaochui(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	-- if is_spell_blocked(target) then return end
	target:EmitSound("Hero_Axe.JungleWeapon.Dunk")
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yugi/yugi_slam.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	local effectIndex1 = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex1, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex1,false)
	keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_thdots_yugi04_think_interval", {duration=keys.ability_duration} )
	if caster:HasModifier("modifier_item_wanbaochui") then
		local targets = FindUnitsInRadius(
			caster:GetTeam(),		
			target:GetOrigin(),	
			nil,					
			350,		
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			0,
			FIND_CLOSEST,
			false
		)
		for k,v in pairs(targets) do
			keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_thdots_yugi04_think_interval", {duration=keys.ability_duration} )
			
			if v~=target then
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yugi/yugi_slam.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)
			end
		end
	end
end

