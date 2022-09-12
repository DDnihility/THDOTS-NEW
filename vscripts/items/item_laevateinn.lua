item_laevateinn = {}

function item_laevateinn:GetIntrinsicModifierName()
	return "modifier_item_laevateinn_basic"
end

modifier_item_laevateinn_basic = {}
LinkLuaModifier("modifier_item_laevateinn_basic","items/item_laevateinn.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_laevateinn_basic:IsHidden() return true end
function modifier_item_laevateinn_basic:IsPurgable() return false end
function modifier_item_laevateinn_basic:IsPurgeException() return false end
function modifier_item_laevateinn_basic:RemoveOnDeath() return false end
function modifier_item_laevateinn_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_laevateinn_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_laevateinn_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_laevateinn_passive", {})
	end
end

function modifier_item_laevateinn_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_laevateinn_basic:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")	
end

function modifier_item_laevateinn_basic:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_laevateinn_basic:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

modifier_item_laevateinn_passive = {}
LinkLuaModifier("modifier_item_laevateinn_passive","items/item_laevateinn.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_laevateinn_passive:IsHidden() return true end
function modifier_item_laevateinn_passive:IsPurgable() return false end
function modifier_item_laevateinn_passive:IsPurgeException() return false end
function modifier_item_laevateinn_passive:RemoveOnDeath() return false end

function modifier_item_laevateinn_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_item_laevateinn_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_laevateinn_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_laevateinn_basic") then
		self:Destroy()
		return
	end
end


function modifier_item_laevateinn_passive:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("amplify_percent")
end

function modifier_item_laevateinn_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target
	if attacker ~= self:GetParent() 
		or attacker:GetTeam() == target:GetTeam()
		or target:IsBuilding()
		or target:IsIllusion()
	then 
		return 
	end
	if attacker:HasModifier("modifier_ability_thdots_youmu2_05_passive") or attacker:HasModifier("modifier_ability_thdots_youmu2_Ex_passive") then 
		--print("youmu")
		local deal_damage = keys.damage * ( 1 - target:GetMagicalArmorValue() )
		local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
		local health_regen = deal_damage * lifesteal_percent
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
		attacker:Heal(health_regen,attacker)
	end
	target:AddNewModifier(attacker, self:GetAbility(), "modifier_item_laevateinn_target",{})
	--[[local deal_damage = keys.damage
			print(deal_damage)
			local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
			local health_regen = deal_damage * lifesteal_percent
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
			attacker:Heal(health_regen,attacker)]]
	local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(particle, 0, Vector(attacker:GetAbsOrigin().x, attacker:GetAbsOrigin().y, attacker:GetAbsOrigin().z))
end

modifier_item_laevateinn_target = {}
LinkLuaModifier("modifier_item_laevateinn_target","items/item_laevateinn.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_laevateinn_target:IsHidden() return true end
function modifier_item_laevateinn_target:IsPurgable() return false end

function modifier_item_laevateinn_target:DeclareFunctions()	
	return {
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

--吸血
function modifier_item_laevateinn_target:OnAttacked(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target

	--[[print("attacker="..attacker:GetClassname())
			print("target="..target:GetClassname())	
			if attacker:HasModifier("modifier_item_bloodthirstiest_passive") then
				print("p=t")
			end
			if target:HasModifier("modifier_item_laevateinn_target") then
				print("t=t")
			end	]]
	if attacker:GetTeam() == target:GetTeam()
		or target:IsBuilding()
		or target:IsIllusion()		
	then 
		return 
	end		
	local deal_damage = keys.damage
	local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
	local health_regen = deal_damage * lifesteal_percent
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
	attacker:Heal(health_regen,attacker)
	target:RemoveModifierByName("modifier_item_laevateinn_target")
end