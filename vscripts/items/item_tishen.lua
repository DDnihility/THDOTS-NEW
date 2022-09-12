item_tishen = {}
function item_tishen:GetIntrinsicModifierName()
	return "modifier_item_tishen_passive"
end

modifier_item_tishen_passive = {}
LinkLuaModifier("modifier_item_tishen_passive","items/item_tishen.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_tishen_passive:IsHidden() return true end
function modifier_item_tishen_passive:IsPurgable() return false end
function modifier_item_tishen_passive:IsPurgeException() return false end
function modifier_item_tishen_passive:RemoveOnDeath() return false end
function modifier_item_tishen_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_tishen_passive:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_item_tishen_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_hp") end
function modifier_item_tishen_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mp") end

function modifier_item_tishen_passive:OnCreated()
end
function modifier_item_tishen_passive:OnTakeDamage(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if parent ~= keys.unit or (not ability:IsCooldownReady()) then return end
    local health = parent:GetHealth()
    local hp_pct = health/parent:GetMaxHealth()
    if hp_pct < ability:GetSpecialValueFor("hp_threshold_pct")*0.01 or keys.damage > health then
        parent:EmitSound("DOTA_Item.ComboBreaker")
        parent:SetHealth(health + keys.damage)
        parent:Purge(false,true,false,true,false)
        parent:AddNewModifier(parent,ability,"modifier_item_tishen",{duration = ability:GetSpecialValueFor("duration")})
        ability:UseResources(false, false, true)
        local level = ability:GetLevel() 
        if level < 5 then
            ability:SetLevel(level+1)
        end
    end
end

modifier_item_tishen = {}
LinkLuaModifier("modifier_item_tishen","items/item_tishen.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_tishen:IsHidden() return false end
function modifier_item_tishen:IsPurgable() return false end
function modifier_item_tishen:IsPurgeException() return false end
function modifier_item_tishen:RemoveOnDeath() return true end
function modifier_item_tishen:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_tishen:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
end

function modifier_item_tishen:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resist") end

function modifier_item_tishen:OnCreated() 
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.particle, false, false, -1, true, false)
end
function modifier_item_tishen:OnRemoved()
    if not IsServer() then return end
    ParticleManager:DestroyParticleSystem(self.particle,false)
end