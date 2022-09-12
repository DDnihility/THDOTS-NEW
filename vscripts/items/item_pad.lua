item_pad={}
function item_pad:GetIntrinsicModifierName()
	return "modifier_item_pad"
end

modifier_item_pad={}
LinkLuaModifier("modifier_item_pad","items/item_pad.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_pad:IsHidden() return true end
function modifier_item_pad:IsPurgable() return false end
function modifier_item_pad:IsPurgeException() return false end
function modifier_item_pad:RemoveOnDeath() return false end
function modifier_item_pad:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_pad:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
    }
end

function modifier_item_pad:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_pad:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

function modifier_item_pad:GetModifierPhysical_ConstantBlock(events)--被攻击时触发
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

function modifier_item_pad:OnCreated()
    if not IsServer() then return end
    self.block_chance = self:GetAbility():GetSpecialValueFor("chance")
    self.block_damage_melee = self:GetAbility():GetSpecialValueFor("block")
    self.block_damage_ranged = self:GetAbility():GetSpecialValueFor("block")
    self.block_percent = self:GetAbility():GetSpecialValueFor("percent")/100
end



