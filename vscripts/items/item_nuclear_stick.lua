item_nuclear_stick = {}

LinkLuaModifier("modifier_item_nuclear_stick", "items/item_nuclear_stick", LUA_MODIFIER_MOTION_NONE)

function item_nuclear_stick:GetIntrinsicModifierName()
	return "modifier_item_nuclear_stick_basic"
end

modifier_item_nuclear_stick_basic = {}
LinkLuaModifier("modifier_item_nuclear_stick_basic","items/item_nuclear_stick.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_nuclear_stick_basic:IsHidden() return true end
function modifier_item_nuclear_stick_basic:IsPurgable() return false end
function modifier_item_nuclear_stick_basic:IsPurgeException() return false end
function modifier_item_nuclear_stick_basic:RemoveOnDeath() return false end
function modifier_item_nuclear_stick_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_nuclear_stick_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_nuclear_stick_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_nuclear_stick_passive", {})
	end
end

function modifier_item_nuclear_stick_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,		
		MODIFIER_PROPERTY_MANA_BONUS,				
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,	
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
		-- MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE
	}
end
function modifier_item_nuclear_stick_basic:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_nuclear_stick_basic:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_nuclear_stick_basic:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end
function modifier_item_nuclear_stick_basic:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
function modifier_item_nuclear_stick_basic:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("regen_amplify")
end
function modifier_item_nuclear_stick_basic:GetModifierHealAmplify_PercentageTarget()
	return self:GetAbility():GetSpecialValueFor("regen_amplify")
end
function modifier_item_nuclear_stick_basic:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end


modifier_item_nuclear_stick = {}

modifier_item_nuclear_stick_passive = {}
LinkLuaModifier("modifier_item_nuclear_stick_passive","items/item_nuclear_stick.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_nuclear_stick_passive:IsHidden() return false end
function modifier_item_nuclear_stick_passive:IsPurgable() return false end
function modifier_item_nuclear_stick_passive:IsPurgeException() return false end
function modifier_item_nuclear_stick_passive:RemoveOnDeath() return false end
function modifier_item_nuclear_stick_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_nuclear_stick_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_nuclear_stick_basic") then
		self:Destroy()
		return
	end
end

function modifier_item_nuclear_stick_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		-- MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE
	}
end

function modifier_item_nuclear_stick_passive:GetModifierPercentageCooldown()
	return self:GetAbility():GetSpecialValueFor("reduction_cooldown")
end


-- function modifier_item_nuclear_stick:GetModifierHPRegenAmplify_Percentage()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_regen_amplify")
-- end
-- function modifier_item_nuclear_stick:GetModifierPercentageManaRegen()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_regen_amplify")
-- end