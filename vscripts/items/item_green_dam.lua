item_green_dam = {}

function item_green_dam:GetIntrinsicModifierName()
	return "modifier_item_green_dam"
end

modifier_item_green_dam = {}
LinkLuaModifier("modifier_item_green_dam","items/item_green_dam.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_green_dam:IsHidden() return true end
function modifier_item_green_dam:IsPurgable() return false end
function modifier_item_green_dam:IsPurgeException() return false end
function modifier_item_green_dam:RemoveOnDeath() return false end
function modifier_item_green_dam:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_green_dam:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_item_green_dam:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")	
end

function modifier_item_green_dam:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")	
end

function item_green_dam:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("barrier_duration")
	target:AddNewModifier(caster, self, "modifier_item_green_dam_barrier", {duration = duration})
	target:EmitSound("THD_ITEM.GreenDam_Cast")
end

modifier_item_green_dam_barrier = {}
LinkLuaModifier("modifier_item_green_dam_barrier","items/item_green_dam.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_green_dam_barrier:IsHidden() 		return false end
function modifier_item_green_dam_barrier:IsPurgable()		return true end
function modifier_item_green_dam_barrier:RemoveOnDeath() 	return true end
function modifier_item_green_dam_barrier:IsDebuff()		return false end

function modifier_item_green_dam_barrier:GetEffectName()
	return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function modifier_item_green_dam_barrier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
	}
end

function modifier_item_green_dam_barrier:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local caster 				= self:GetCaster()
	local original_shield_amount	= self.defence
	if kv.damage_type == DAMAGE_TYPE_MAGICAL and not kv.attacker:HasModifier("modifier_item_pomojinlingli") then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, caster, kv.damage, nil)
		return kv.damage
	else
		return
	end
end