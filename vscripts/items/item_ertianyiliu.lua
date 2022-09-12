item_ertianyiliu = {}

function item_ertianyiliu:GetIntrinsicModifierName()
	return "modifier_item_ertianyiliu_basic"
end

modifier_item_ertianyiliu_basic = {}
LinkLuaModifier("modifier_item_ertianyiliu_basic","items/item_ertianyiliu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_ertianyiliu_basic:IsHidden() return true end
function modifier_item_ertianyiliu_basic:IsPurgable() return false end
function modifier_item_ertianyiliu_basic:IsPurgeException() return false end
function modifier_item_ertianyiliu_basic:RemoveOnDeath() return false end
function modifier_item_ertianyiliu_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_ertianyiliu_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_ertianyiliu_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_ertianyiliu_passive", {})
	end
end
function modifier_item_ertianyiliu_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_item_ertianyiliu_basic:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


modifier_item_ertianyiliu_passive = {}
LinkLuaModifier("modifier_item_ertianyiliu_passive","items/item_ertianyiliu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_ertianyiliu_passive:IsHidden() return true end
function modifier_item_ertianyiliu_passive:IsPurgable() return false end
function modifier_item_ertianyiliu_passive:IsPurgeException() return false end
function modifier_item_ertianyiliu_passive:RemoveOnDeath() return false end
function modifier_item_ertianyiliu_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_ertianyiliu_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_ertianyiliu_basic") then
		self:Destroy()
		return
	end
end

function modifier_item_ertianyiliu_passive:DeclareFunctions()
	return {
		--MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		--MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end

function modifier_item_ertianyiliu_passive:GetModifierPreAttack_CriticalStrike()
	if self:GetParent():HasModifier("modifier_item_ertianyiliu_double_attack") then
		return self:GetAbility():GetSpecialValueFor("cooldown_crit_mult")
	else
		return 0
	end
end

function modifier_item_ertianyiliu_passive:OnAttackStart(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local chance = self:GetAbility():GetSpecialValueFor("crit_chance")
	caster:RemoveModifierByName("modifier_item_ertianyiliu_crit")
	if keys.attacker ~= caster then return end
	if RollPercentage(chance) then
		-- local particle_pact = "particles/units/heroes/hero_skeletonking/skeleton_king_weapon_blur_critical.vpcf"
		local particle_pact = "particles/econ/items/monkey_king/ti7_weapon/mk_ti7_crimson_strike_cast_motion_dark.vpcf"
		local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
		-- ParticleManager:SetParticleControl(particle_pact_fx, 0, target:GetAbsOrigin())
		-- ParticleManager:SetParticleControl(particle_pact_fx, 1, target:GetAbsOrigin())
		-- ParticleManager:SetParticleControl(particle_pact_fx, 5, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_pact_fx)

		caster:AddNewModifier(caster, self:GetAbility(),"modifier_item_ertianyiliu_crit", {})
	end
end
function modifier_item_ertianyiliu_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = keys.target
	local ability = self:GetAbility()
	local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	if keys.attacker ~= caster then return end
	local corruption_armor_duration = self:GetAbility():GetSpecialValueFor("corruption_armor_duration")
	caster:RemoveModifierByName("modifier_item_ertianyiliu_double_attack")
	--常规减甲
	if self:GetAbility() and (target and not target:IsOther() and not target:IsBuilding() and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber()) then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_item_ertianyiliu_decrease_armor", {duration = corruption_armor_duration * (1 - target:GetStatusResistance())})
	end
	--被动生效
	if ability:IsCooldownReady() and not caster:IsRangedAttacker() then
		print("IsCooldownReady")
		local particle_pact = "particles/units/heroes/hero_monkey_king/monkey_king_attack_01_blur_cud.vpcf"
		local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(particle_pact_fx)
		caster:AddNewModifier(caster, self:GetAbility(),"modifier_item_ertianyiliu_double_attack", {duration = 1})
		--target:AddNewModifier(caster, ability, "modifier_item_ertianyiliu_double_attack_debuff", {duration = slow_duration})
		ability:StartCooldown(ability:GetCooldown(0))
	end
end


modifier_item_ertianyiliu_crit = {}
LinkLuaModifier("modifier_item_ertianyiliu_crit","items/item_ertianyiliu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_ertianyiliu_crit:IsDebuff() return false end
function modifier_item_ertianyiliu_crit:IsHidden() return true end
function modifier_item_ertianyiliu_crit:IsPurgable() return false end
function modifier_item_ertianyiliu_crit:IsPurgeException() return false end
function modifier_item_ertianyiliu_crit:RemoveOnDeath() return false end

function modifier_item_ertianyiliu_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end

function modifier_item_ertianyiliu_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("crit_mult")	
end



modifier_item_ertianyiliu_decrease_armor = {}
LinkLuaModifier("modifier_item_ertianyiliu_decrease_armor","items/item_ertianyiliu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_ertianyiliu_decrease_armor:IsDebuff() return true end
function modifier_item_ertianyiliu_decrease_armor:IsHidden() return false end
function modifier_item_ertianyiliu_decrease_armor:IsPurgable() return true end
function modifier_item_ertianyiliu_decrease_armor:RemoveOnDeath() return true end

function modifier_item_ertianyiliu_decrease_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_item_ertianyiliu_decrease_armor:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("corruption_armor")	
end

modifier_item_ertianyiliu_double_attack = {}
LinkLuaModifier("modifier_item_ertianyiliu_double_attack","items/item_ertianyiliu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_ertianyiliu_double_attack:IsDebuff() return false end
function modifier_item_ertianyiliu_double_attack:IsHidden() return true end
function modifier_item_ertianyiliu_double_attack:IsPurgable() return false end
function modifier_item_ertianyiliu_double_attack:IsPurgeException() return false end
function modifier_item_ertianyiliu_double_attack:RemoveOnDeath() return false end

function modifier_item_ertianyiliu_double_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_ertianyiliu_double_attack:GetModifierAttackSpeedBonus_Constant()
	return 1000
end

function modifier_item_ertianyiliu_double_attack:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = keys.target
	if keys.attacker ~= caster then return end
	local ability = self:GetAbility()
	local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	local particle_pact = "particles/units/heroes/hero_monkey_king/monkey_king_attack_01_blur_cud.vpcf"
	local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(particle_pact_fx)
	--target:AddNewModifier(caster, ability, "modifier_item_ertianyiliu_double_attack_debuff", {duration = slow_duration})
	-- self:Destroy()
end

modifier_item_ertianyiliu_double_attack_debuff = {}
LinkLuaModifier("modifier_item_ertianyiliu_double_attack_debuff","items/item_ertianyiliu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_ertianyiliu_double_attack_debuff:IsDebuff() return true end
function modifier_item_ertianyiliu_double_attack_debuff:IsHidden() return false end
function modifier_item_ertianyiliu_double_attack_debuff:IsPurgable() return true end
function modifier_item_ertianyiliu_double_attack_debuff:RemoveOnDeath() return true end

function modifier_item_ertianyiliu_double_attack_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_ertianyiliu_double_attack_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_movespeed")
end