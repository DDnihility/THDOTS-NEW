item_diary = {}

function item_diary:GetIntrinsicModifierName()
	return "modifier_item_diary_basic"
end

modifier_item_diary_basic = {}
LinkLuaModifier("modifier_item_diary_basic","items/item_diary.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_diary_basic:IsHidden() return true end
function modifier_item_diary_basic:IsPurgable() return false end
function modifier_item_diary_basic:IsPurgeException() return false end
function modifier_item_diary_basic:RemoveOnDeath() return false end
function modifier_item_diary_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_diary_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_diary_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_diary_passive", {})
	end
end
function modifier_item_diary_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_item_diary_basic:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")	
end

function modifier_item_diary_basic:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_diary_basic:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_diary_basic:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_diary_basic:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magical_armor")
end


modifier_item_diary_passive = {}
LinkLuaModifier("modifier_item_diary_passive","items/item_diary.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_diary_passive:IsHidden() return true end
function modifier_item_diary_passive:IsPurgable() return false end
function modifier_item_diary_passive:IsPurgeException() return false end
function modifier_item_diary_passive:RemoveOnDeath() return false end
function modifier_item_diary_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	print(self:GetAbility():GetSpecialValueFor("percent_time"))
end
function modifier_item_diary_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_diary_basic") then
		self:Destroy()
		return
	end
end


function modifier_item_diary_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_RESPAWN,
	}
end

function modifier_item_diary_passive:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus")
end

function modifier_item_diary_passive:GetModifierPercentageRespawnTime()
	--百分比复活时间， 正数减少，负数增加。0.5表示减少50%复活时间
	if self:GetParent():HasModifier("modifier_ability_thdots_keineEx_passive")
    	or self:GetParent():HasModifier("modifier_ability_thdots_keineEx_passive_aura") then
        return 0
    else
        return self:GetAbility():GetSpecialValueFor("percent_time") / 100
    end
end

function modifier_item_diary_passive:OnRespawn(keys)
	if not IsServer() then return end
	--死亡增加全属性
	if keys.unit == self:GetParent() then
	-- if keys.attacker == self:GetParent() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("duration")
		print(duration)
		caster:AddNewModifier(caster, ability,"modifier_item_diary_passive_death", {Duration = duration})
	end
end

modifier_item_diary_passive_death = {}
LinkLuaModifier("modifier_item_diary_passive_death","items/item_diary.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_diary_passive_death:IsDebuff() return false end
function modifier_item_diary_passive_death:IsHidden() return false end
function modifier_item_diary_passive_death:IsPurgable() return false end
function modifier_item_diary_passive_death:RemoveOnDeath() return false end

function modifier_item_diary_passive_death:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_diary_passive_death:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("death_bonus_all_stats")	
end

function modifier_item_diary_passive_death:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("death_bonus_all_stats")
end

function modifier_item_diary_passive_death:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("death_bonus_all_stats")
end