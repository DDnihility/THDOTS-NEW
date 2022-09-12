item_magic_mushroom = {}

-- function item_magic_mushroom:GetModelName()
-- 	return "models/items/shadowshaman/ti8_ss_mushroomer_head/ti8_ss_mushroomer_head.vmdl"
-- end
function item_magic_mushroom:GetIntrinsicModifierName()
	return "modifier_item_magic_mushroom_passive"
end

modifier_item_magic_mushroom_passive = {}
LinkLuaModifier("modifier_item_magic_mushroom_passive","items/item_magic_mushroom.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_magic_mushroom_passive:IsHidden() return true end
function modifier_item_magic_mushroom_passive:IsPurgable() return false end
function modifier_item_magic_mushroom_passive:IsPurgeException() return false end
function modifier_item_magic_mushroom_passive:RemoveOnDeath() return false end
function modifier_item_magic_mushroom_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_magic_mushroom_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_item_magic_mushroom_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")	
end


-- function item_magic_mushroom:GetBehavior()
-- 	if GameUI.IsCtrlDown() then
-- 		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
-- 	else
-- 		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
-- 	end
-- end

function item_magic_mushroom:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local bonus_health_regen = ability:GetSpecialValueFor("bonus_health_regen")
	local regen_mana = ability:GetSpecialValueFor("regen_mana")
	if target == nil then
		target = caster
	end

	target:EmitSound("DOTA_Item.Mango.Activate")
	local particle_name = "particles/items3_fx/mango_active.vpcf"
	local particle = ParticleManager:CreateParticle(particle_name,PATTACH_CUSTOMORIGIN,target)
	target:GiveMana(regen_mana)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,target,regen_mana,nil)
	self:RemoveSelf()
end