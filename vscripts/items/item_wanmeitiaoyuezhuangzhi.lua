item_wanmeitiaoyuezhuangzhi = item_wanmeitiaoyuezhuangzhi or class({})
LinkLuaModifier("modifier_item_wanmeitiaoyuezhuangzhi_buff", "items/item_wanmeitiaoyuezhuangzhi", LUA_MODIFIER_MOTION_NONE)

function item_wanmeitiaoyuezhuangzhi:GetIntrinsicModifierName()
	return "modifier_wanmeitiaoyuezhuangzhi_basic"
end

modifier_wanmeitiaoyuezhuangzhi_basic = {}
LinkLuaModifier("modifier_wanmeitiaoyuezhuangzhi_basic","items/item_wanmeitiaoyuezhuangzhi.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_wanmeitiaoyuezhuangzhi_basic:IsHidden() return true end
function modifier_wanmeitiaoyuezhuangzhi_basic:IsPurgable() return false end
function modifier_wanmeitiaoyuezhuangzhi_basic:IsPurgeException() return false end
function modifier_wanmeitiaoyuezhuangzhi_basic:RemoveOnDeath() return false end
function modifier_wanmeitiaoyuezhuangzhi_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wanmeitiaoyuezhuangzhi_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_wanmeitiaoyuezhuangzhi_buff") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_wanmeitiaoyuezhuangzhi_buff", {})
	end
end

function modifier_wanmeitiaoyuezhuangzhi_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierMoveSpeedBonus_Special_Boots()
	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_wanmeitiaoyuezhuangzhi_basic:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
---------

function item_wanmeitiaoyuezhuangzhi:OnSpellStart()
	if self:GetCursorTarget() or self:GetCursorTarget() == self:GetCaster() then self:EndCooldown() return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local distance = self:GetSpecialValueFor("distance") + caster:GetCastRangeBonus()
	local vecCaster = caster:GetOrigin()
	local pointRad = GetRadBetweenTwoVec2D(vecCaster,point)
	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_end_ti7.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex, false)
	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	if(GetDistanceBetweenTwoVec2D(vecCaster,point)<=distance)then
		FindClearSpaceForUnit(caster,point,true)
	else
		local blinkVector = Vector(math.cos(pointRad)*distance,math.sin(pointRad)*distance,0) + vecCaster
		FindClearSpaceForUnit(caster,blinkVector,true)
		ProjectileManager:ProjectileDodge(caster)
	end
end

modifier_item_wanmeitiaoyuezhuangzhi_buff = modifier_item_wanmeitiaoyuezhuangzhi_buff or class({})


function modifier_item_wanmeitiaoyuezhuangzhi_buff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_wanmeitiaoyuezhuangzhi_buff:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_wanmeitiaoyuezhuangzhi_basic") then
		self:Destroy()
		return
	end
end

function modifier_item_wanmeitiaoyuezhuangzhi_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end
function modifier_item_wanmeitiaoyuezhuangzhi_buff:IsHidden() return true end
function modifier_item_wanmeitiaoyuezhuangzhi_buff:IsPurgable() return false end

function modifier_item_wanmeitiaoyuezhuangzhi_buff:OnTakeDamage(keys)
	if not keys.attacker then return end
	if self:GetParent() == keys.unit and keys.attacker:IsHero() then
		local ability = self:GetAbility()
		local blink_damage_cooldown = ability:GetSpecialValueFor("blink_damage_cooldown")
		local parent = self:GetParent()
		local unit = keys.unit
		--被伤害打断
		-- if parent == unit and keys.attacker:GetTeam() ~= parent:GetTeam() then
		-- 	if ability:GetCooldownTimeRemaining() < blink_damage_cooldown then
		-- 		ability:StartCooldown(blink_damage_cooldown)
		-- 	end
		-- end
	end
end