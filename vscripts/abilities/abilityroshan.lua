roshan_death = class({})
modifier_roshan_death_aura = class({})
modifier_roshan_death_buff = class({})
modifier_roshan_death = class({})
LinkLuaModifier("modifier_roshan_death_aura","scripts/vscripts/abilities/abilityroshan.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_roshan_death_buff","scripts/vscripts/abilities/abilityroshan.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_roshan_death","scripts/vscripts/abilities/abilityroshan.lua",LUA_MODIFIER_MOTION_NONE)
function roshan_death:GetIntrinsicModifierName() return "modifier_roshan_death" end
function modifier_roshan_death:IsHidden() 		return false end
function modifier_roshan_death:IsPurgable()		return false end
function modifier_roshan_death:RemoveOnDeath() 	return true end
function modifier_roshan_death:IsDebuff()		return false end
function modifier_roshan_death:OnDeath(keys)
    local team = keys.attacker:GetTeam()
    local units = FindUnitsInRadius(
        team,
        self:GetCaster():GetAbsOrigin(), 
        nil, 
        99999, 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_HERO, 
        0, 
        FIND_ANY_ORDER, 
        false)
    for _, hero in ipairs(units) do
        hero:AddNewModifier(hero, self:GetCaster(), "modifier_roshan_death_aura", {duration = self:GetSpecialValueFor("duration")})
    end
end


function modifier_roshan_death_aura:IsHidden() 		return false end
function modifier_roshan_death_aura:IsPurgable()		return false end
function modifier_roshan_death_aura:RemoveOnDeath() 	return true end
function modifier_roshan_death_aura:IsDebuff()		return false end

function modifier_roshan_death_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end -- global
function modifier_roshan_death_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_roshan_death_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_roshan_death_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_CREEP end
function modifier_roshan_death_aura:GetModifierAura() return "modifier_roshan_death_buff" end
function modifier_roshan_death_aura:IsAura() return true end

function modifier_roshan_death_buff:IsHidden() 		return false end
function modifier_roshan_death_buff:IsPurgable()		return false end
function modifier_roshan_death_buff:RemoveOnDeath() 	return true end
function modifier_roshan_death_buff:IsDebuff()		return false end

function modifier_roshan_death_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_roshan_death_buff:MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ()
    return self:GetAbility():GetSpecialValueFor("armor_bonus")
end

function modifier_roshan_death_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resistence")
end

function Ability_Roshan_Purge(keys)
	local Caster = keys.caster
	Caster:RemoveAllModifiers(1,true,true,true)
end
