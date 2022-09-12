item_bra={}
function item_bra:GetIntrinsicModifierName()
	return "modifier_item_bra"
end

modifier_item_bra={}
LinkLuaModifier("modifier_item_bra","items/item_bra.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_bra:IsHidden() return true end
function modifier_item_bra:IsPurgable() return false end
function modifier_item_bra:IsPurgeException() return false end
function modifier_item_bra:RemoveOnDeath() return false end
function modifier_item_bra:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bra:DeclareFunctions() return
    {

        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
    }
end

function modifier_item_bra:GetModifierPhysical_ConstantBlock(events)--被攻击时触发,不必做来源检测
    if IsClient() then return end
	if RollPercentage(self.block_chance) then
        if events.damage * self.block_percent <= self.block_damage_melee then return events.damage * self.block_percent end
		if not self:GetParent():IsRangedAttacker() then
			return self.block_damage_melee
		else
			return self.block_damage_ranged
		end
	end
end

function modifier_item_bra:OnCreated()
    if not IsServer() then return end
    self.block_chance = self:GetAbility():GetSpecialValueFor("chance")
    self.block_damage_melee = self:GetAbility():GetSpecialValueFor("block")
    self.block_damage_ranged = self:GetAbility():GetSpecialValueFor("block")
    self.block_percent = self:GetAbility():GetSpecialValueFor("percent")/100
end