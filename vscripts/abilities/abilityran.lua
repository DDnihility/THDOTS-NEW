g_ran01_players_flag={}

function Ran01_OnSpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target_points[1]
	local playerid=caster:GetPlayerOwnerID()


	local flag_unit=nil
	if g_ran01_players_flag[playerid] and IsValidEntity(g_ran01_players_flag[playerid]) then
		if (g_ran01_players_flag[playerid]:GetOrigin()-target):Length2D()<=keys.BlinkSelectRange then
			flag_unit=g_ran01_players_flag[playerid]
		else
			g_ran01_players_flag[playerid]:Destroy()
			g_ran01_players_flag[playerid]=nil
		end
	end

	if flag_unit then
		-- blink
		caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
		local pos=flag_unit:GetOrigin()
		flag_unit:SetOrigin(caster:GetOrigin())
		FindClearSpaceForUnit(caster,pos,true)
		
		-- Play caster particle
		local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControlEnt(caster_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster_pfx, 1, flag_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", flag_unit:GetAbsOrigin(), true)

		-- Play target particle
		local target_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, flag_unit)
		ParticleManager:SetParticleControlEnt(target_pfx, 0, flag_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", flag_unit:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(target_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	else
		caster:EmitSound("Hero_Techies.Sign")
		-- create flag unit
		flag_unit=CreateUnitByName(
			keys.FlagUnitName,
			target,
			true,
			caster,
			caster,
			caster:GetTeam())

		g_ran01_players_flag[playerid]=flag_unit

		ability:ApplyDataDrivenModifier(caster,flag_unit,keys.AuraBuffName,{})
		ability:ApplyDataDrivenModifier(caster,flag_unit,keys.AuraDebuffName,{})
		ability:EndCooldown()
	end
end

function Ran03_OnSpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_ran_2"))

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/ran/ability_ran_03_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)

	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 9, caster, 5, "attach_hitloc", Vector(0,0,0), true)

	local damage_table={
			victim=target, 
			attacker=caster, 
			ability=ability,
			damage=ability:GetAbilityDamage(),
			damage_type=ability:GetAbilityDamageType(),
		}
	if caster:HasModifier("modifier_item_wanbaochui") and target:IsHero() then
		local deal_mana_damage=target:GetIntellect()*2
		target:ReduceMana(deal_mana_damage)
	end
	UnitDamageTarget(damage_table)


	local target_unit=target
	local targetLoc = target_unit:GetAbsOrigin()
	local jump_count=1
	local telentjumpCount = FindTelentValue(caster,"special_bonus_unique_ran_1")
	local jumpAmount = 1
	local jumpex = 0
	if caster:HasModifier("modifier_item_wanbaochui")  then
		jumpex = 2
		caster:ReduceMana(ability:GetManaCost(ability:GetLevel()))
	end
	
	if telentjumpCount > 0 then
		jumpAmount = (keys.JumpCount+jumpex) * telentjumpCount
	else
		jumpAmount = keys.JumpCount+jumpex
	end
	if jumpAmount>1 then
		caster:SetContextThink(
			"ran03_lazer_jumping",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				local enemies = FindUnitsInRadius(
					caster:GetTeamNumber(),
					targetLoc,
					nil,
					keys.JumpRadius,
					ability:GetAbilityTargetTeam(),
					ability:GetAbilityTargetType(),
					ability:GetAbilityTargetFlags(),
					FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
					false)
				local next_target=nil
				for _,v in pairs(enemies) do
					if v:IsAlive() then
						if v~=target_unit then
							next_target=v
							break
						end
					end
				end
				if next_target then
					effectIndex = ParticleManager:CreateParticle("particles/heroes/ran/ability_ran_03_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)

					if target_unit and not target_unit:IsNull() then
						target_unit:EmitSound("Hero_Tinker.Laser")
						ParticleManager:SetParticleControlEnt(effectIndex , 0, target_unit, 5, "attach_hitloc", Vector(0,0,0), true)
						ParticleManager:SetParticleControlEnt(effectIndex , 9, target_unit, 5, "attach_hitloc", Vector(0,0,0), true)
					else
						EmitSoundOnLocationWithCaster(targetLoc, "Hero_Tinker.Laser", caster)
						ParticleManager:SetParticleControl(effectIndex , 0, targetLoc)
						ParticleManager:SetParticleControl(effectIndex , 9, targetLoc)
					end
					ParticleManager:SetParticleControlEnt(effectIndex , 1, next_target, 5, "attach_hitloc", Vector(0,0,0), true)

					target_unit=next_target
					targetLoc = target_unit:GetAbsOrigin()
					damage_table.victim=target_unit
					if caster:HasModifier("modifier_item_wanbaochui") and target_unit:IsHero() then
						local deal_mana_damage=target_unit:GetIntellect()*1.4+30
						target_unit:ReduceMana(deal_mana_damage)
					end
					target_unit:EmitSound("Hero_Tinker.LaserImpact")
					UnitDamageTarget(damage_table)
				end

				if #enemies == 1 then return end
				jump_count=jump_count+1
				if jump_count>=jumpAmount or target_unit==nil then return nil end
				return keys.JumpInterval
			end,keys.JumpInterval)
	end
end
