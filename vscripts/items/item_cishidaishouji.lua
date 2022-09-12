item_cishidaishouji = {}

function item_cishidaishouji:GetIntrinsicModifierName()
	return "modifier_item_cishidaishouji_basic"
end

modifier_item_cishidaishouji_basic = {}
LinkLuaModifier("modifier_item_cishidaishouji_basic","items/item_cishidaishouji.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_cishidaishouji_basic:IsHidden() return true end
function modifier_item_cishidaishouji_basic:IsPurgable() return false end
function modifier_item_cishidaishouji_basic:IsPurgeException() return false end
function modifier_item_cishidaishouji_basic:RemoveOnDeath() return false end
function modifier_item_cishidaishouji_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_cishidaishouji_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_cishidaishouji_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_cishidaishouji_passive", {})
	end
end
function modifier_item_cishidaishouji_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_item_cishidaishouji_basic:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_cishidaishouji_basic:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_cishidaishouji_basic:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end


modifier_item_cishidaishouji_passive = {}
LinkLuaModifier("modifier_item_cishidaishouji_passive","items/item_cishidaishouji.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_cishidaishouji_passive:IsHidden() return true end
function modifier_item_cishidaishouji_passive:IsPurgable() return false end
function modifier_item_cishidaishouji_passive:IsPurgeException() return false end
function modifier_item_cishidaishouji_passive:RemoveOnDeath() return false end
function modifier_item_cishidaishouji_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_cishidaishouji_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_cishidaishouji_basic") then
		self:Destroy()
		return
	end
end

function modifier_item_cishidaishouji_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_cishidaishouji_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = keys.target
	local ability = self:GetAbility()
	local max_count = self:GetAbility():GetSpecialValueFor("max_count")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
	if keys.attacker ~= caster then return end
	print("do it")
	caster:SetMana(caster:GetMana() + mana_regen)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,caster,mana_regen,nil)
	if not caster:HasModifier("modifier_item_cishidaishouji_buff")  then
		
		caster:AddNewModifier(caster, ability, "modifier_item_cishidaishouji_buff",{duration = duration})
		local modifier = caster:FindModifierByName("modifier_item_cishidaishouji_buff")
		modifier:SetStackCount(1)
	else
		local modifier = caster:FindModifierByName("modifier_item_cishidaishouji_buff")
		local count = modifier:GetStackCount()
		if count < max_count then
			modifier:IncrementStackCount()
			modifier:SetDuration(duration,true)
		else
			modifier:SetStackCount(max_count)
			modifier:SetDuration(duration,true)
		end
	end
end


modifier_item_cishidaishouji_buff = {}
LinkLuaModifier("modifier_item_cishidaishouji_buff","items/item_cishidaishouji.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_cishidaishouji_buff:IsDebuff() return false end
function modifier_item_cishidaishouji_buff:IsHidden() return false end
function modifier_item_cishidaishouji_buff:IsPurgable() return true end
function modifier_item_cishidaishouji_buff:RemoveOnDeath() return true end

function modifier_item_cishidaishouji_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_cishidaishouji_buff:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("pre_bonus_damage") * self:GetStackCount()
end

function modifier_item_cishidaishouji_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("pre_bonus_attack_speed") * self:GetStackCount()
end

