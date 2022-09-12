if AbilityEirin == nil then
	AbilityEirin = class({})
end

ability_thdots_eirin02 = {}

function ability_thdots_eirin02:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self, level)
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_eirin_3")
	if telent ~= nil then
		cd = cd + telent:GetSpecialValueFor("value")
	end
	return cd
end

function ability_thdots_eirin02:OnSpellStart()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.position = self:GetCursorPosition()
	self.origin = self.caster:GetOrigin()
	self.radius = self:GetSpecialValueFor("radius")
	self.damage = self:GetSpecialValueFor("damage")

	--THDReduceCooldown(self, FindTelentValue(self.caster, "special_bonus_unique_eirin_3"))

	local velocity = (self.position - self.origin):Normalized() * self:GetSpecialValueFor("move_speed")
	velocity.z = 0

	self.projectile = ProjectileManager:CreateLinearProjectile({
		EffectName = "particles/heroes/eirin/ability_eirin_02.vpcf",
		Ability = self,
		Source = self.caster,
		vSpawnOrigin = self.origin,
		vVelocity = velocity,
		fDistance = self:GetSpecialValueFor("length"),
		fStartRadius = self:GetSpecialValueFor("collision_radius"),
		fEndRadius = self:GetSpecialValueFor("collision_radius"),
		bIgnoreSource = true,
		bDeleteOnHit = true,
		bReplaceExisting = false,
		bHasFrontalCone = false,
		bProvidesVision = true,
		iVisionRadius = 300,
		iVisionTeamNumber = self.caster:GetTeamNumber(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO
	})

	EmitSoundOn("Hero_Mirana.Arrow", self.caster)
	-- self.caster:AddNewModifier(self.caster, self, "modifier_thdots_eirin02_magic_immune", {duration = 0.1})
end

function ability_thdots_eirin02:OnProjectileHit(target, location)
	if not IsServer() then return end
	if target == nil then return end

	ProjectileManager:DestroyLinearProjectile(self.projectile)

	local vecTarget = target:GetOrigin()
	local spellPoint = Vector(self.origin.x, self.origin.y, self.origin.z)
	local dis = GetDistanceBetweenTwoVec2D(spellPoint, location)
	local dealdamage = self:GetAbilityDamage()
	if self.caster:HasModifier("modifier_item_wanbaochui") then
		dealdamage = dealdamage + self.caster:GetIntellect() * (dis / 1000 + 1.75)
	end

	EmitSoundOn("Hero_Mirana.ArrowImpact", target)

	if target:GetTeam() ~= self.caster:GetTeam() then
		local duration = (dis - dis % 150) / 150 * self:GetSpecialValueFor("stun_duration")
		if duration >= 2.0 then
			duration = 2.0
		end
		duration = duration * (FindTelentValue(self.caster, "special_bonus_unique_eirin_2") + 1)
		UtilStun:UnitStunTarget(self.caster, target, duration)
		local damage_table = {
			ability = self,
			victim = target,
			attacker = self.caster,
			damage = dealdamage,
			damage_type = self:GetAbilityDamageType(), 
			damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	else
		target:Heal(dealdamage, self.caster)
	end
	
	local effectIndex = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", 
		PATTACH_WORLDORIGIN, 
		nil)
	for i = 0, 61 do
		ParticleManager:SetParticleControl(effectIndex, i, vecTarget)
	end
	ParticleManager:DestroyParticleSystem(effectIndex, false)

	EmitSoundOn("Hero_Puck.Dream_Coil", target)

	local time = 0
	self.caster:SetContextThink(DoUniqueString("ability_eirin02_spell_heal"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			local targets = FindUnitsInRadius(
				self.caster:GetTeam(),		--caster team
				vecTarget,				--find position
				nil,						--find entity
				self.radius,				--find radius
				DOTA_UNIT_TARGET_TEAM_BOTH,
				self:GetAbilityTargetType(),
				0, FIND_CLOSEST,
				false
			)
			if GetDistanceBetweenTwoVec2D(vecTarget, self.caster:GetOrigin()) <= self.radius then
				self.caster:Heal(self.damage / 5, self.caster)
			end
			for k,v in pairs(targets) do
				if v:GetTeam() ~= self.caster:GetTeam() then
					local damage_table_heal = {
						ability = self,
						victim = v,
						attacker = self.caster,
						damage = self.damage / 5,
						damage_type = self:GetAbilityDamageType(), 
						damage_flags = 0
					}
					UnitDamageTarget(damage_table_heal)
				else
					v:Heal(self.damage / 5, self.caster)
					local healEffectIndex = ParticleManager:CreateParticle(
						"particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf", 
						PATTACH_CUSTOMORIGIN, 
					v)
					ParticleManager:SetParticleControl(healEffectIndex, 0, v:GetOrigin())
					Timer.Wait 'ability_eirin02_remove_heal_effect' (1,
						function()
							ParticleManager:DestroyParticleSystem(healEffectIndex, true)
						end
					)
				end
			end

			time = time + 0.2
			if time > 4 then 
				ParticleManager:DestroyParticleSystem(effectIndex, true)
				return nil 
			end
			return 0.2
		end
	, 0)
--[[
	Timer.Loop 'ability_eirin02_spell_heal' (0.2, 20,
			function(i)
				local targets = FindUnitsInRadius(
				   caster:GetTeam(),		--caster team
				   vecTarget,				--find position
				   nil,						--find entity
				   keys.Radius,				--find radius
				   DOTA_UNIT_TARGET_TEAM_BOTH,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			    )
			    if(GetDistanceBetweenTwoVec2D(vecTarget,caster:GetOrigin()) <= keys.Radius)then
					caster:Heal(keys.Damage/5,caster)
			    end
				for k,v in pairs(targets) do
					if(v:GetTeam()~=caster:GetTeam())then
						local damage_table_heal = {
							ability = keys.ability,
				   	 		victim = v,
				   	 		attacker = caster,
				   			damage = keys.Damage/5,
				   	 		damage_type = keys.ability:GetAbilityDamageType(), 
		    	  	 		damage_flags = 0
						}
				   		UnitDamageTarget(damage_table_heal)
				   	else
						v:Heal(keys.Damage/5,caster)

				   		local healEffectIndex = ParticleManager:CreateParticle(
							"particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf", 
							PATTACH_CUSTOMORIGIN, 
						v)

						ParticleManager:SetParticleControl(healEffectIndex, 0, v:GetOrigin())
				   		Timer.Wait 'ability_eirin02_remove_heal_effect' (1,
							function()
								ParticleManager:DestroyParticleSystem(healEffectIndex,true)
							end
						)
				   	end
			    end
			end
	)
	Timer.Wait 'ability_eirin02_remove_effect' (4,
			function()
				ParticleManager:DestroyParticleSystem(effectIndex,true)
			end
		)
]]
end

ability_thdots_eirin03 = {}

function ability_thdots_eirin03:OnSpellStart()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	self.duration = self:GetSpecialValueFor("ability_duration")

	EmitSoundOn("Hero_Treant.NaturesGuise.On", self.target)
	ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
	self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_eirin03_effect", {duration = self.duration})

	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_1") then
		ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
		self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_eirin03_effect", {duration = self.duration})
	end
end

modifier_ability_thdots_eirin03_effect = {}
LinkLuaModifier("modifier_ability_thdots_eirin03_effect", "scripts/vscripts/abilities/abilityeirin.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_eirin03_effect:IsHidden() return false end
function modifier_ability_thdots_eirin03_effect:IsDebuff() return false end
function modifier_ability_thdots_eirin03_effect:IsPurgable() return true end
function modifier_ability_thdots_eirin03_effect:RemoveOnDeath() return true end

function modifier_ability_thdots_eirin03_effect:GetEffectName()
	return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end

function modifier_ability_thdots_eirin03_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_thdots_eirin03_effect:OnCreated()
	if not IsServer() then return end
	local parent = self:GetParent()
	parent:AddNewModifier(nil, nil, "modifier_invisible", {duration = self:GetAbility().duration})
end

function modifier_ability_thdots_eirin03_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
end

function modifier_ability_thdots_eirin03_effect:GetModifierBaseAttack_BonusDamage()
	local ability = self:GetAbility()
	local value = ability:GetSpecialValueFor("attack_bonus")
	local caster = ability.caster
	local target = ability.target
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_1") and caster == target then
		value = value * 2
	end
	return value
end

function modifier_ability_thdots_eirin03_effect:GetModifierBonusStats_Intellect()
	local ability = self:GetAbility()
	local value = ability:GetSpecialValueFor("int_bonus")
	local caster = ability.caster
	local target = ability.target
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_1") and caster == target then
		value = value * 2
	end
	return value
end

function modifier_ability_thdots_eirin03_effect:GetBonusNightVision()
	local ability = self:GetAbility()
	local caster = ability.caster
	local target = ability.target
	local value = 0
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_5") then
		value = self:GetCaster():FindModifierByName("modifier_special_bonus_unique_eirin_5"):GetStackCount()
	end
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_1") and caster == target then
		value = value * 2
	end
	return value
end

function OnEirin04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_eirin_6"))
	keys.ability.target = keys.target
	local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/eirin/ability_eirin_04.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			keys.target)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, keys.target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndex, 1, keys.target:GetOrigin())
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)
	keys.ability.effectIndex = effectIndex
end

function OnEirin04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.ability.target
	local VecCaster = caster:GetOrigin()
		if target:GetHealth() == 0 and target:IsRealHero() then
			target:RemoveModifierByName("modifier_ability_thdots_eirin04_effect")
			
			local effectIndex = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", 
				PATTACH_CUSTOMORIGIN, 
				target)
			ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
			ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()/5)
			ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			ParticleManager:DestroyParticleSystem(keys.ability.effectIndex,true)
			if target:GetClassname()=="npc_dota_hero_chaos_knight" then
				target:SetRespawnPosition(VecCaster)
				target:RespawnUnit()
			end
			target:SetHealth(target:GetMaxHealth())
		end	
end

ability_thdots_eirinex = {}

function ability_thdots_eirinex:GetIntrinsicModifierName()
	return "modifier_ability_thdots_eirinex_passive"
end

function ability_thdots_eirinex:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	self.duration = self:GetSpecialValueFor("ability_duration")
	self.effectIndex = ParticleManager:CreateParticle(
		"particles/items_fx/healing_flask.vpcf", 
		PATTACH_CUSTOMORIGIN,
		self.target)
	ParticleManager:SetParticleControlEnt(self.effectIndex , 0, self.target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effectIndex, 1, self.target:GetOrigin())
	ParticleManager:DestroyParticleSystemTime(self.effectIndex, self.duration)
	self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_eirinex", {duration = self.duration})
end

modifier_ability_thdots_eirinex = {}
LinkLuaModifier("modifier_ability_thdots_eirinex","scripts/vscripts/abilities/abilityeirin.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_eirinex:IsHidden() 		return false end
function modifier_ability_thdots_eirinex:IsPurgable()		return true end
function modifier_ability_thdots_eirinex:RemoveOnDeath() 	return true end
function modifier_ability_thdots_eirinex:IsDebuff()		return false end

function modifier_ability_thdots_eirinex:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_ability_thdots_eirinex:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_ability_thdots_eirinex:GetModifierMoveSpeedBonus_Percentage()
	local parent = self:GetParent()
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_4") or parent:GetHealth() >= parent:GetMaxHealth() then
		return self:GetAbility():GetSpecialValueFor("move_speed")
	end
	return 0
end

function modifier_ability_thdots_eirinex:GetModifierAttackSpeedBonus_Constant()
	local parent = self:GetParent()
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_4") or parent:GetHealth() >= parent:GetMaxHealth() then
		return self:GetAbility():GetSpecialValueFor("attackspeed_bouns")
	end
	return 0
end

function modifier_ability_thdots_eirinex:OnTakeDamage(event)
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_4") then return end
	local attacker = event.attacker
	local unit = event.unit
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if not attacker:IsNull() and attacker:IsHero() and unit == parent then
		parent:RemoveModifierByName("modifier_ability_thdots_eirinex")
		ParticleManager:DestroyParticle(ability.effectIndex, true)
	end
end

-- 用于天赋监听
modifier_ability_thdots_eirinex_passive = {}
LinkLuaModifier("modifier_ability_thdots_eirinex_passive","scripts/vscripts/abilities/abilityeirin.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_eirinex_passive:IsHidden() 		return true end
function modifier_ability_thdots_eirinex_passive:IsPurgable()		return false end
function modifier_ability_thdots_eirinex_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_eirinex_passive:IsDebuff()		return false end

function modifier_ability_thdots_eirinex_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_eirinex_passive:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(), "special_bonus_unique_eirin_4") ~= 0 and not self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_4") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_special_bonus_unique_eirin_4", {})
	end
	if FindTelentValue(self:GetCaster(), "special_bonus_unique_eirin_5") ~= 0 and not self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_5") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_special_bonus_unique_eirin_5", {}):SetStackCount(FindTelentValue(self:GetCaster(), "special_bonus_unique_eirin_5"))
	end
	if FindTelentValue(self:GetCaster(), "special_bonus_unique_eirin_1") ~= 0 and not self:GetCaster():HasModifier("modifier_special_bonus_unique_eirin_1") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_special_bonus_unique_eirin_1", {})
	end
end

modifier_special_bonus_unique_eirin_4 = {}
LinkLuaModifier("modifier_special_bonus_unique_eirin_4", "scripts/vscripts/abilities/abilityeirin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_special_bonus_unique_eirin_4:IsHidden() 		return true end
function modifier_special_bonus_unique_eirin_4:IsPurgable()		return false end
function modifier_special_bonus_unique_eirin_4:RemoveOnDeath() 	return false end
function modifier_special_bonus_unique_eirin_4:IsDebuff()		return false end

modifier_special_bonus_unique_eirin_5 = {}
LinkLuaModifier("modifier_special_bonus_unique_eirin_5", "scripts/vscripts/abilities/abilityeirin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_special_bonus_unique_eirin_5:IsHidden() 		return true end
function modifier_special_bonus_unique_eirin_5:IsPurgable()		return false end
function modifier_special_bonus_unique_eirin_5:RemoveOnDeath() 	return false end
function modifier_special_bonus_unique_eirin_5:IsDebuff()		return false end

modifier_special_bonus_unique_eirin_1 = {}
LinkLuaModifier("modifier_special_bonus_unique_eirin_1", "scripts/vscripts/abilities/abilityeirin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_special_bonus_unique_eirin_1:IsHidden() 		return true end
function modifier_special_bonus_unique_eirin_1:IsPurgable()		return false end
function modifier_special_bonus_unique_eirin_1:RemoveOnDeath() 	return false end
function modifier_special_bonus_unique_eirin_1:IsDebuff()		return false end
