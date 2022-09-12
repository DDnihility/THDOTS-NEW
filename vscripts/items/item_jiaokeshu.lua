item_jiaokeshu = {}

function item_jiaokeshu:GetIntrinsicModifierName()
	return "modifier_item_jiaokeshu_basic"
end

modifier_item_jiaokeshu_basic = {}
LinkLuaModifier("modifier_item_jiaokeshu_basic","items/item_jiaokeshu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_jiaokeshu_basic:IsHidden() return true end
function modifier_item_jiaokeshu_basic:IsPurgable() return false end
function modifier_item_jiaokeshu_basic:IsPurgeException() return false end
function modifier_item_jiaokeshu_basic:RemoveOnDeath() return false end
function modifier_item_jiaokeshu_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_jiaokeshu_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_jiaokeshu_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_jiaokeshu_passive", {})
	end
end

function modifier_item_jiaokeshu_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_jiaokeshu_basic:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")	
end

function modifier_item_jiaokeshu_basic:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_jiaokeshu_basic:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
--------------------
modifier_item_jiaokeshu_passive = {}
LinkLuaModifier("modifier_item_jiaokeshu_passive","items/item_jiaokeshu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_jiaokeshu_passive:IsHidden() return true end
function modifier_item_jiaokeshu_passive:IsPurgable() return false end
function modifier_item_jiaokeshu_passive:IsPurgeException() return false end
function modifier_item_jiaokeshu_passive:RemoveOnDeath() return false end
function modifier_item_jiaokeshu_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_jiaokeshu_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_jiaokeshu_basic") then
		self:Destroy()
		return
	end
end

function modifier_item_jiaokeshu_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE
	}
end

function modifier_item_jiaokeshu_passive:GetModifierPercentageRespawnTime()
	--百分比复活时间， 正数减少，负数增加。0.5表示减少50%复活时间
	if self:GetParent():HasModifier("modifier_ability_thdots_keineEx_passive")
    	or self:GetParent():HasModifier("modifier_ability_thdots_keineEx_passive_aura")
    	or self:GetParent():HasModifier("modifier_item_diary_passive") then
        return 0
    else
        return self:GetAbility():GetSpecialValueFor("percent_time") / 100
    end
end