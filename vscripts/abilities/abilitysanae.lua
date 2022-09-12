----------------------------------------------------------------------------------------------
-- Global

if AbilitySanae == nil then
	AbilitySanae = class({})
end

-- Global End
----------------------------------------------------------------------------------------------
-- Sanae01

-- Ability Initialization
ability_thdots_sanae01 = class({})

-- Modifiers
modifier_thdots_sanae01_slow = class({})
LinkLuaModifier("modifier_thdots_sanae01_slow", "scripts/vscripts/abilities/abilitysanae.lua", LUA_MODIFIER_MOTION_NONE)

-- Ability Basic Parameter
function ability_thdots_sanae01:GetAbilityDamage()
	local damage = self:GetSpecialValueFor("damage")
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_sanae_2")
	if talent ~= nil and talent:GetLevel() ~= 0 then
		damage = damage + talent:GetSpecialValueFor("value")
	end
	return damage
end

function ability_thdots_sanae01:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_sanae01:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

-- Ability Script
function ability_thdots_sanae01:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")
	local interval = self:GetSpecialValueFor("interval")
	local slowDuration = self:GetSpecialValueFor("slow_duration")
	local scepterBouns = 1 + self:GetSpecialValueFor("scepter_bouns") * 0.01

	local time = 0
	local creationTime = GameRules:GetGameTime()
	local targetPosition = self:GetCursorPosition()
	local radius = self:GetAOERadius()

	EmitSoundOnLocationWithCaster(targetPosition, "Hero_Invoker.Tornado.Cast", caster)

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cyclone.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, targetPosition)
	ParticleManager:DestroyParticleSystem(effectIndex, false)
	caster:SetContextThink(DoUniqueString("sanae_01_particle"),
		function()
			if GameRules:IsGamePaused() then return 0.04 end

			if GameRules:GetGameTime() - creationTime >= 1.5 then
				effectIndex = ParticleManager:CreateParticle("particles/items_fx/cyclone.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, targetPosition)
				ParticleManager:SetParticleControl(effectIndex, 1, targetPosition)
				ParticleManager:DestroyParticleSystem(effectIndex, false)
			end
		end,
		1.5
	)

	caster:SetContextThink(DoUniqueString("sanae_01_SpellStart"),
		function()
			if GameRules:IsGamePaused() then return 0.04 end

			if time >= duration then
				return nil
			end

			local targets = FindUnitsInRadius(
		   		caster:GetTeamNumber(),
		  		targetPosition,
		   		nil,
		   		radius,
		   		self:GetAbilityTargetTeam(),
		   		self:GetAbilityTargetType(),
		   		DOTA_UNIT_TARGET_FLAG_NONE, 
		   		FIND_ANY_ORDER,
		   		false
	    	)
	    	for _, target in pairs(targets) do
    			local damageTable = {
    				ability = self,
    				victim = target,
    				attacker = caster,
    				damage = self:GetAbilityDamage(),
    				damage_type = self:GetAbilityDamageType(),
    				damage_flags = DOTA_DAMAGE_FLAG_NONE,
    			}
	    		if target:IsHero() and caster:HasModifier("modifier_item_wanbaochui") then
	    			damageTable.damage = damageTable.damage * scepterBouns
	    		end
    			UnitDamageTarget(damageTable)

    			target:AddNewModifier(caster, self, "modifier_thdots_sanae01_slow", {duration = slowDuration})
    		end

    		time = time + interval
			return interval
		end,
		0
	)
end

-- Modifier Basic Parameter
function modifier_thdots_sanae01_slow:IsHidden() return false end
function modifier_thdots_sanae01_slow:IsDebuff() return true end
function modifier_thdots_sanae01_slow:IsPurgable() return true end
function modifier_thdots_sanae01_slow:RemoveOnDeath() return true end

-- Modifier functions
function modifier_thdots_sanae01_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_thdots_sanae01_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_slow")
end

-- Sanae01 End
----------------------------------------------------------------------------------------------
-- Sanae02

-- Ability Initialization
ability_thdots_sanae02 = class({})

-- Ability Basic Parameter
function ability_thdots_sanae02:GetAbilityDamage()
	local damage = self:GetSpecialValueFor("damage")
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_sanae_4")
	if talent ~= nil and talent:GetLevel() ~= 0 then
		damage = damage + talent:GetSpecialValueFor("value")
	end
	return damage
end

function ability_thdots_sanae02:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_sanae02:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

-- Ability Script
function ability_thdots_sanae02:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

	local delayTime = self:GetSpecialValueFor("delay_time")
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local scepterBouns = 1 + self:GetSpecialValueFor("scepter_bouns") * 0.01

	local creationTime = GameRules:GetGameTime()
	local targetPosition = self:GetCursorPosition()

	caster:SetContextThink('sanae02_delay',
		function()
			if GameRules:IsGamePaused() or GameRules:GetGameTime() - creationTime < delayTime then return 0.04 end

			local targets = FindUnitsInRadius(
		   		caster:GetTeamNumber(),
		  		targetPosition,
		   		nil,
		   		self:GetAOERadius(),
		   		self:GetAbilityTargetTeam(),
		   		self:GetAbilityTargetType(),
		   		DOTA_UNIT_TARGET_FLAG_NONE, 
		   		FIND_ANY_ORDER,
		   		false
	    	)
	    	for _, target in pairs(targets) do
    			local damageTable = {
    				ability = self,
    				victim = target,
    				attacker = caster,
    				damage = self:GetAbilityDamage(),
    				damage_type = self:GetAbilityDamageType(),
    				damage_flags = DOTA_DAMAGE_FLAG_NONE,
    			}
	    		if target:IsHero() and caster:HasModifier("modifier_item_wanbaochui") then
	    			damageTable.damage = damageTable.damage * scepterBouns
	    		end
    			UnitDamageTarget(damageTable)

    			local talent = caster:FindAbilityByName("special_bonus_unique_sanae_3")
    			if talent ~= nil and talent:GetLevel() ~= 0 then
    				UtilStun:UnitStunTarget(caster, target, stunDuration)
    			else
    				UtilStun:UnitStunTarget(caster, target, stunDuration + talent:GetSpecialValueFor("value"))
    			end
    		end

    		EmitSoundOnLocationWithCaster(targetPosition, "Hero_Zuus.GodsWrath.PreCast", caster)
    		EmitSoundOnLocationWithCaster(targetPosition, "Ability.Torrent", caster)

			local effectIndex = ParticleManager:CreateParticle("particles/heroes/sanae/ability_sanea_02_effect.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(effectIndex, 0, targetPosition)
			ParticleManager:SetParticleControl(effectIndex, 1, targetPosition)
			ParticleManager:DestroyParticleSystem(effectIndex, false)

    		return nil
    	end,
    	delayTime
	)
end

-- Sanae02 End
----------------------------------------------------------------------------------------------
-- Sanae03

-- Ability Initialization
ability_thdots_sanae03 = class({})

-- Modifiers
modifier_thdots_sanae03_caster = class({})
LinkLuaModifier("modifier_thdots_sanae03_caster", "scripts/vscripts/abilities/abilitysanae.lua", LUA_MODIFIER_MOTION_NONE)
modifier_thdots_sanae03_target = class({})
LinkLuaModifier("modifier_thdots_sanae03_target", "scripts/vscripts/abilities/abilitysanae.lua", LUA_MODIFIER_MOTION_NONE)

-- Ability Intrinsic Modifier
function ability_thdots_sanae03:GetIntrinsicModifierName() return "modifier_thdots_sanae03_caster" end

-- Modifier Basic Parameter
function modifier_thdots_sanae03_caster:IsHidden() return not self:GetCaster():IsRealHero() end
function modifier_thdots_sanae03_caster:IsDebuff() return false end
function modifier_thdots_sanae03_caster:IsPurgable() return false end
function modifier_thdots_sanae03_caster:RemoveOnDeath() return true end

-- Modifier Script
function modifier_thdots_sanae03_caster:OnCreated()
	if not IsServer() then return end

	if not self:GetCaster():IsRealHero() then return end

	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor("global_radius")

	self:StartIntervalThink(0.5)
end

function modifier_thdots_sanae03_caster:OnIntervalThink()
	if not IsServer() then return end

	if not self.caster:IsAlive() then return end

	local targets = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		self.caster:GetOrigin(),
		nil,
		self.radius,
		self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	for _, target in pairs(targets) do
		if not target:HasModifier("modifier_thdots_sanae03_target") then
			target:AddNewModifier(self.caster, self.ability, "modifier_thdots_sanae03_target", {})
		end
	end
end

-- Modifier functions
function modifier_thdots_sanae03_caster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
end

function modifier_thdots_sanae03_caster:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_thdots_sanae03_caster:GetModifierTotalPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen_pct")
end

-- Modifier Basic Parameter
function modifier_thdots_sanae03_target:IsHidden() return false end
function modifier_thdots_sanae03_target:IsDebuff() return false end
function modifier_thdots_sanae03_target:IsPurgable() return false end
function modifier_thdots_sanae03_target:RemoveOnDeath() return true end

-- Modifier Script
function modifier_thdots_sanae03_target:OnCreated()
	if not IsServer() then return end

	self.caster = self:GetCaster()

	self:StartIntervalThink(0.5)
end

function modifier_thdots_sanae03_target:OnIntervalThink()
	if not IsServer() then return end

	if self.caster == nil or self.caster:IsNull() or not self.caster:IsAlive() then
		self:Destroy()
	end
end

-- Modifier functions
function modifier_thdots_sanae03_target:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
end

function modifier_thdots_sanae03_target:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_thdots_sanae03_target:GetModifierTotalPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen_pct")
end

-- Sanae03 End
----------------------------------------------------------------------------------------------
-- Sanae04

-- Ability Initialization
ability_thdots_sanae04 = class({})

-- Modifiers
modifier_thdots_sanae04_caster = class({})
LinkLuaModifier("modifier_thdots_sanae04_caster", "scripts/vscripts/abilities/abilitysanae.lua", LUA_MODIFIER_MOTION_NONE)
modifier_thdots_sanae04_target = class({})
LinkLuaModifier("modifier_thdots_sanae04_target", "scripts/vscripts/abilities/abilitysanae.lua", LUA_MODIFIER_MOTION_NONE)

-- Ability Basic Parameter
function ability_thdots_sanae04:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self, level)
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_sanae_1")
	if talent ~= nil then
		cd = cd + talent:GetSpecialValueFor("value")
	end
	return cd
end

-- Ability Script
function ability_thdots_sanae04:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound("Hero_Dazzle.Shallow_Grave")
	caster:EmitSound("Voice_Thdots_Sanae.AbilitySanae04")

	caster:AddNewModifier(caster, self, "modifier_thdots_sanae04_caster", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_thdots_sanae04_target", {duration = duration})
end

-- Modifier Basic Parameter
function modifier_thdots_sanae04_caster:IsHidden() return false end
function modifier_thdots_sanae04_caster:IsDebuff() return false end
function modifier_thdots_sanae04_caster:IsPurgable() return false end
function modifier_thdots_sanae04_caster:RemoveOnDeath() return true end

-- Modifier Script
function modifier_thdots_sanae04_caster:OnCreated()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor("radius")

	self.effectIndex = ParticleManager:CreateParticle("particles/heroes/sanae/ability_sanea_04_effect_b.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.effectIndex , 0, self.caster, 5, "follow_origin", Vector(0, 0, 0), true)

	self:StartIntervalThink(0.1)
	self:OnIntervalThink()
end

function modifier_thdots_sanae04_caster:OnIntervalThink()
	if not IsServer() then return end

	local targets = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		self.caster:GetOrigin(),
		nil,
		self.radius,
		self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	for _, target in pairs(targets) do
		if not target:HasModifier("modifier_thdots_sanae04_target") 
			and GetDistanceBetweenTwoVec2D(target:GetOrigin(), self.caster:GetOrigin()) <= self.radius then

			target:AddNewModifier(self.caster, self.ability, "modifier_thdots_sanae04_target", {duration = self:GetRemainingTime()})
		end
	end
end

function modifier_thdots_sanae04_caster:OnDestroy()
	if not IsServer() then return end

	ParticleManager:DestroyParticleSystem(self.effectIndex, true)
end

-- Modifier Basic Parameter
function modifier_thdots_sanae04_target:IsHidden() return false end
function modifier_thdots_sanae04_target:IsDebuff() return false end
function modifier_thdots_sanae04_target:IsPurgable() return false end
function modifier_thdots_sanae04_target:RemoveOnDeath() return true end

-- Modifier Attributes
function modifier_thdots_sanae04_target:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

-- Modifier State
function modifier_thdots_sanae04_target:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

-- Modifier Functions
function modifier_thdots_sanae04_target:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}
end

function modifier_thdots_sanae04_target:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_thdots_sanae04_target:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_thdots_sanae04_target:GetAbsoluteNoDamagePure()
	return 1
end

-- Modifier Script
function modifier_thdots_sanae04_target:OnCreated()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

	self.radius = self.ability:GetSpecialValueFor("radius")

	self.effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_tsundere.vpcf", PATTACH_CUSTOMORIGIN, self.parent)
	ParticleManager:SetParticleControlEnt(self.effectIndex, 0, self.parent, PATTACH_POINT_FOLLOW, "follow_origin", self.parent:GetOrigin(), false)

	self:StartIntervalThink(0.1)
end

function modifier_thdots_sanae04_target:OnIntervalThink()
	if not IsServer() then return end

	if self.caster:IsNull() or not self.caster:HasModifier("modifier_thdots_sanae04_caster")
		or GetDistanceBetweenTwoVec2D(self.caster:GetOrigin(), self.parent:GetOrigin()) > self.radius then

		self:Destroy()
		return
	end
end

function modifier_thdots_sanae04_target:OnDestroy()
	if not IsServer() then return end

	ParticleManager:DestroyParticleSystem(self.effectIndex, true)
end

-- Sanae04 End
----------------------------------------------------------------------------------------------