ability_thdots_byakuren01 = class ({})  

function ability_thdots_byakuren01:OnSpellStart()
	if not IsServer() then return end
	self.caster				= self:GetCaster()
	self.ability          = self
	self.target           = self:GetCursorTarget()
	self.cast_range 	= self:GetSpecialValueFor("cast_range") + self.caster:GetCastRangeBonus()
	self.point = self:GetCursorPosition()
	self.caster:RemoveModifierByName("modifier_byakuren03_byakuren01_cast_range_bonus")
	if is_spell_blocked(self.target) then return end
	if self.cast_range_bonus == nil then self.cast_range_bonus = false end

	if self.cast_range_bonus == true then
		local vector_distance = self.caster:GetAbsOrigin() - self.target:GetAbsOrigin()
		local direction = (vector_distance):Normalized()
		local distance = (vector_distance):Length2D()
		if distance > 190 then 
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_void_hit.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
			ParticleManager:SetParticleControl(effectIndex, 0, self.caster:GetAbsOrigin())
			--ParticleManager:DestroyParticleSystem(effectIndex,false)
			FindClearSpaceForUnit(self.caster, self.target:GetAbsOrigin() + direction * 190, true)
			ResolveNPCPositions(self.caster:GetAbsOrigin(), 128)
		end
		self.cast_range_bonus = false
	end	
	OnByakuren01SpellStart(self)
end

function OnByakuren01SpellStart(keys)	
	local ability = keys.ability
	local caster = keys.caster 
	local vecCaster = caster:GetOrigin()
	local target = keys.target
	local dealdamage = keys.ability:GetSpecialValueFor("damage") - ability:GetSpecialValueFor("aoe_damage")

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 5, keys.target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	caster:EmitSound("Hero_Luna.LucentBeam.Target")

	local damage_target = {
		victim = keys.target,
		attacker = caster,
		damage = dealdamage,
		damage_type = keys.ability:GetAbilityDamageType(), 
		damage_flags = 0
	}
	local targets = FindUnitsInRadius(
						caster:GetTeam(),		
						target:GetOrigin(),	
						nil,					
						ability:GetSpecialValueFor("radius"),		
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						keys.ability:GetAbilityTargetType(),
						0,
						FIND_CLOSEST,
						false
					)
	UnitDamageTarget(damage_target)
	for _,v in pairs(targets) do
		if v and not v:IsNull() then
			local damage_table = {
					ability = keys.ability,
						victim = v,
						attacker = caster,
						damage = ability:GetSpecialValueFor("aoe_damage"),
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = 0
			}
			UtilStun:UnitStunTarget(caster,v,ability:GetSpecialValueFor("stun_duration"))
			UnitDamageTarget(damage_table)
		end
	end
end

function ability_thdots_byakuren01:GetCastRange()
	if self.cast_range_bonus == true then
		local ByakurenAbility03 = self:GetCaster():FindAbilityByName("ability_thdots_byakuren03")
		local cast_range_bonus = ByakurenAbility03:GetSpecialValueFor("cast_range")		
		return self:GetSpecialValueFor("cast_range") + cast_range_bonus
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function ability_thdots_byakuren01:CastFilterResultTarget(target)
	self.caster				= self:GetCaster()
	if target:GetTeam()==self.caster:GetTeam() then
		return UF_FAIL_FRIENDLY
	end
	if self.cast_range_bonus == true then
		local vector_distance = self.caster:GetAbsOrigin() - target:GetAbsOrigin()
		local direction = (vector_distance):Normalized()
		local distance = (vector_distance):Length2D()
		if distance > 190 then 
			--print("success")
			if self.caster:IsRooted() then
				return UF_FAIL_CUSTOM
			else
				return UF_SUCCESS
			end
		end
	end	
end

ability_thdots_byakuren02 = class ({})  

function ability_thdots_byakuren02:GetAOERadius()
	if ( self:GetCaster():HasScepter() ) then
		return self:GetSpecialValueFor( "wanbaochui_radius" )
	end
	return 0
end


--function ability_thdots_youmu04:GetCooldown( nLevel )
--	local ability = self:GetCaster():FindAbilityByName("special_bonus_unique_juggernaut")
--	local telent_val = 0
    --if ability~=nil then
    --    telent_val = ability:GetSpecialValueFor("value")
    --end
--	return self.BaseClass.GetCooldown( self, nLevel ) + telent_val -- + FindTelentValue(self:GetCaster(),"special_bonus_unique_juggernaut")
--end


function ability_thdots_byakuren02:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability          = self
	self.target           = self:GetCursorTarget()
	self.AbilityMulti     = self:GetSpecialValueFor("ability_multi")
	self.ManaCost   = self:GetSpecialValueFor("mana_cost")
	self.WanbaochuiRadius = self:GetSpecialValueFor("wanbaochui_radius")
	self.caster:EmitSound("Hero_LegionCommander.PressTheAttack")
	OnByakuren02SpellStart(self)
end

function OnByakuren02SpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	local caster = keys.caster
	local manaCost = keys.ManaCost * caster:GetMana()		--?????????????????????*????????????
	caster:SetMana(caster:GetMana()-manaCost)
	local vecCaster = caster:GetOrigin()
	local target = keys.target
	local dealdamage = keys.AbilityMulti * caster:GetMaxMana() --?????????????????????*???????????????

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_02.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	ParticleManager:ReleaseParticleIndex(effectIndex)

	if caster:HasModifier("modifier_item_wanbaochui") then
		local targets = FindUnitsInRadius(
						caster:GetTeam(),		
						target:GetOrigin(),	
						nil,					
						keys.WanbaochuiRadius,		
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						keys.ability:GetAbilityTargetType(),
						0,
						FIND_CLOSEST,
						false
					)
			for k,v in pairs(targets) do
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = dealdamage,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)
			end
	else

		local damage_target = {
			victim = keys.target,
			attacker = caster,
			damage = dealdamage,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
		}
		UnitDamageTarget(damage_target)
	end
end

function OnByakuren03SpellStart(keys)
	if keys.caster:GetTeam()~=keys.target:GetTeam() and is_spell_blocked(keys.target) then return end
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local target = keys.target
	local vecTarget = target:GetOrigin()

	
	if(target:GetTeam()==caster:GetTeam())then
		target:Purge(false,true,false,true,false)
		local vecMove = vecCaster + caster:GetForwardVector() * 60
		target:SetOrigin(vecMove)
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova_h.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
		ParticleManager:SetParticleControl(effectIndex, 1, vecTarget)
		ParticleManager:SetParticleControl(effectIndex, 2, vecTarget)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		ParticleManager:ReleaseParticleIndex(effectIndex)
		SetTargetToTraversable(target)
		target:EmitSound("Hero_Weaver.TimeLapse")
	else
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_03.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
		local time = 0
		target:SetThink(
				function()
					if GameRules:IsGamePaused() then return 0.03 end
					if time >= 3.0 then
						target:SetOrigin(vecTarget)
						target:EmitSound("Hero_Weaver.TimeLapse")
						SetTargetToTraversable(target)
						ParticleManager:DestroyParticleSystem(effectIndex,true)
						return nil
					end
					time = time + 0.1
					return 0.1
				end, 
		"ability_byakuren_03_return",
		0)
	end
end

function OnByakuren04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local dealdamage = keys.ability:GetAbilityDamage() + keys.AbilityMulti * ( caster:GetMaxHealth() - caster:GetHealth())
	if keys.target:IsBuilding() then return end
	local damage_target = {
		ability = keys.ability,
		victim = keys.target,
		attacker = caster,
		damage = dealdamage/2,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = 0
	}
	UnitDamageTarget(damage_target)
	for _,v in pairs(targets) do
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = dealdamage/2,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_04_attack.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		UnitDamageTarget(damage_table)
	end
	-- caster:SetHealth(caster:GetHealth()+dealdamage)
	caster:Heal(dealdamage,caster)
end

function OnByakuren04SpellThinkStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	
	if(caster.ability_byakuren04_health_old==nil)then
		caster.ability_byakuren04_health_old = 0
		--local effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_04.vpcf", PATTACH_CUSTOMORIGIN, caster)
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_04_circle.vpcf", PATTACH_CUSTOMORIGIN, caster)
		caster.effectIndex = effectIndex
		caster.isReborn = true
		ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
		--ParticleManager:SetParticleControlEnt(effectIndex , 1, caster, 5, "follow_origin", Vector(0,0,0), true)

		caster:SetContextThink("ability_byakuren04_think", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			OnByakuren04SpellThink(keys)
			return 0.05
		end, 
		0.05)
	end
end


function OnByakuren04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = keys.ability
	local increaseHealth = caster:GetMaxMana() * ( keys.BounsHealth + ( ability:GetLevel() - 1 ) * 0.2 ) 
	local effectIndex
	caster:SetModifierStackCount("passive_byakuren04_bonus_health", ability, increaseHealth)
	if(caster:GetHealth()<1 and caster.isReborn == true)then
		print("destory!")
		ParticleManager:DestroyParticleSystem(caster.effectIndex,true)
		caster.isReborn = false
	else
		if(caster:GetHealth()>=1 and caster.isReborn == false)then
			print("restart!")
			--effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_04.vpcf", PATTACH_CUSTOMORIGIN, caster)
			effectIndex = ParticleManager:CreateParticle("particles/heroes/byakuren/ability_byakuren_04_circle.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
			--ParticleManager:SetParticleControlEnt(effectIndex , 1, caster, 5, "follow_origin", Vector(0,0,0), true)
			caster.effectIndex = effectIndex
			caster.isReborn = true
		end
	end
	
--[[
	if caster:HasModifier("modifier_item_wanbaochui") then
		local stack_count = math.floor(100-(caster:GetHealth() / caster:GetMaxHealth()) * 100 )
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_byakuren04_wanbaochui_buff", {})
		caster:SetModifierStackCount("modifier_thdots_byakuren04_wanbaochui_buff", ability, stack_count)
	else
		caster:RemoveModifierByName("modifier_thdots_byakuren04_wanbaochui_buff")	
	end
	]]--  
			
	
	--ParticleManager:SetParticleControlEnt(caster.effectIndex , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
	--ParticleManager:SetParticleControlEnt(caster.effectIndex , 1, caster, 5, "follow_origin", Vector(0,0,0), true)
end
--???????????????addon_game_mode.lua ??????function THDOTSGameMode:Levelup(keys)
--[[
function byakuren04_OnIntervalThink(keys)
	local ability=keys.ability
	local caster=keys.caster
	local ability_lvl=math.floor(caster:GetLevel()/6) + 1
	if ability_lvl~=ability:GetLevel() then
		ability:SetLevel(ability_lvl)
	end
end
]]
function OnByakuren05SpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target
	caster:EmitSound("Voice_Thdots_Byakuren.AbilityByakuren04")
	if is_spell_blocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_byakuren05_debuff", {Duration = keys.Duration}) 
end

function OnByakuren03Order(keys)
	if keys.target~=nil and keys.event_ability~=nil then
		if keys.target:HasModifier("modifier_byakuren03_effect") and keys.event_ability:GetAbilityName() == "ability_thdots_byakuren01" then
			--print("target="..keys.target:GetClassname())
			--print("keys.event_ability="..keys.event_ability:GetAbilityName())				
			keys.event_ability.cast_range_bonus = true			
		else
			keys.event_ability.cast_range_bonus = false
		end
	end
end