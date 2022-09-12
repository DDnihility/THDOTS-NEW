item_mushroom_kebab={}

function item_mushroom_kebab:OnSpellStart()
    if not IsServer() then return end
    if GameRules:GetDOTATime(false,false)<300 then return end
	local Caster =self:GetCaster()
	Caster:SetBaseStrength(Caster:GetBaseStrength() + self:GetSpecialValueFor("increase_strength"))
	if (self:IsItem()) then
		Caster:RemoveItem(self)
	end
end

function item_mushroom_kebab:GetIntrinsicModifierName() return  "modifier_item_mushroom_kebab" end

modifier_item_mushroom_kebab = {}
LinkLuaModifier("modifier_item_mushroom_kebab","items/item_pie.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_mushroom_kebab:IsHidden() return true end
function modifier_item_mushroom_kebab:IsPurgable() return false end
function modifier_item_mushroom_kebab:IsPurgeException() return false end
function modifier_item_mushroom_kebab:RemoveOnDeath() return false end
function modifier_item_mushroom_kebab:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mushroom_kebab:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
end

function modifier_item_mushroom_kebab:GetModifierBonusStats_Strength()  return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_mushroom_kebab:GetModifierBonusStats_Agility()   return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_mushroom_kebab:GetModifierBonusStats_Intellect()   return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_mushroom_kebab:GetModifierStatusResistanceStacking()   return self:GetAbility():GetSpecialValueFor("bonus_resist") end





item_mushroom_pie={}

function item_mushroom_pie:OnSpellStart()
    if not IsServer() then return end
    if GameRules:GetDOTATime(false,false)<300 then return end
	local Caster =self:GetCaster()
	Caster:SetBaseAgility(Caster:GetBaseAgility() + self:GetSpecialValueFor("increase_agility"))
	if (self:IsItem()) then
		Caster:RemoveItem(self)
	end
end

function item_mushroom_pie:GetIntrinsicModifierName() return  "modifier_item_mushroom_pie" end

modifier_item_mushroom_pie = {}
LinkLuaModifier("modifier_item_mushroom_pie","items/item_pie.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_mushroom_pie:IsHidden() return true end
function modifier_item_mushroom_pie:IsPurgable() return false end
function modifier_item_mushroom_pie:IsPurgeException() return false end
function modifier_item_mushroom_pie:RemoveOnDeath() return false end
function modifier_item_mushroom_pie:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mushroom_pie:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_mushroom_pie:GetModifierBonusStats_Strength()  return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_mushroom_pie:GetModifierBonusStats_Agility()   return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_mushroom_pie:GetModifierBonusStats_Intellect()   return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_mushroom_pie:GetModifierMoveSpeedBonus_Percentage()   return self:GetAbility():GetSpecialValueFor("bonus_speed") end





item_mushroom_soup={}

function item_mushroom_soup:OnSpellStart()
    if not IsServer() then return end
    if GameRules:GetDOTATime(false,false)<300 then return end
	local Caster =self:GetCaster()
	Caster:SetBaseIntellect(Caster:GetBaseIntellect() + self:GetSpecialValueFor("increase_intellect"))
	if (self:IsItem()) then
		Caster:RemoveItem(self)
	end
end

function item_mushroom_soup:GetIntrinsicModifierName() return  "modifier_item_mushroom_soup" end

modifier_item_mushroom_soup = {}
LinkLuaModifier("modifier_item_mushroom_soup","items/item_pie.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_mushroom_soup:IsHidden() return true end
function modifier_item_mushroom_soup:IsPurgable() return false end
function modifier_item_mushroom_soup:IsPurgeException() return false end
function modifier_item_mushroom_soup:RemoveOnDeath() return false end
function modifier_item_mushroom_soup:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mushroom_soup:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
end

function modifier_item_mushroom_soup:GetModifierBonusStats_Strength()  return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_mushroom_soup:GetModifierBonusStats_Agility()   return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_mushroom_soup:GetModifierBonusStats_Intellect()   return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_mushroom_soup:GetModifierPercentageCooldown()   return self:GetAbility():GetSpecialValueFor("bonus_cooldown_reduction") end