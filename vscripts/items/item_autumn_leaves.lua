item_autumn_leaves = {}

function item_autumn_leaves:GetIntrinsicModifierName()
	return "modifier_item_autumn_leaves_basic"
end

modifier_item_autumn_leaves_basic = {}
LinkLuaModifier("modifier_item_autumn_leaves_basic","items/item_autumn_leaves.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_autumn_leaves_basic:IsHidden() return true end
function modifier_item_autumn_leaves_basic:IsPurgable() return false end
function modifier_item_autumn_leaves_basic:IsPurgeException() return false end
function modifier_item_autumn_leaves_basic:RemoveOnDeath() return false end
function modifier_item_autumn_leaves_basic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_autumn_leaves_basic:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_illusion") and not self:GetCaster():HasModifier("modifier_item_autumn_leaves_passive") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_autumn_leaves_passive", {})
	end
end



function modifier_item_autumn_leaves_basic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_item_autumn_leaves_basic:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_autumn_leaves_basic:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


modifier_item_autumn_leaves_passive = {}
LinkLuaModifier("modifier_item_autumn_leaves_passive","items/item_autumn_leaves.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_autumn_leaves_passive:IsHidden() return true end
function modifier_item_autumn_leaves_passive:IsPurgable() return false end
function modifier_item_autumn_leaves_passive:IsPurgeException() return false end
function modifier_item_autumn_leaves_passive:RemoveOnDeath() return false end
function modifier_item_autumn_leaves_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_item_autumn_leaves_passive:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_autumn_leaves_basic") then
		self:Destroy()
		return
	end
end



function modifier_item_autumn_leaves_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

--吸血
function modifier_item_autumn_leaves_passive:CheckState()
	if self:GetStackCount() == 1 then
		return {
			[MODIFIER_STATE_CANNOT_MISS] 	= true,
		}
	else
		return
	end
end

function modifier_item_autumn_leaves_passive:OnAttackStart(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() then
		local chance = self:GetAbility():GetSpecialValueFor("change")
		if RollPercentage(chance) then
			self:SetStackCount(1)
		end
	end
end
--[[
function modifier_item_autumn_leaves_passive:OnAttackLanded(keys)
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
	self:SetStackCount(0)
	local deal_damage = keys.damage
	print("deal_damage")
	print(deal_damage)
	print(self:GetAbility():GetSpecialValueFor("bonus_attack_speed"))
	print(self:GetAbility():GetSpecialValueFor("bonus_damage"))
	--判断血晶石派生道具最高吸血覆盖，不重复
	if attacker:HasModifier("modifier_item_laevateinn_passive") then return end

	local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
	local health_regen = deal_damage * lifesteal_percent
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
	attacker:Heal(health_regen,attacker)
	local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(particle, 0, Vector(attacker:GetAbsOrigin().x, attacker:GetAbsOrigin().y, attacker:GetAbsOrigin().z))
end
]]


--税后吸血
function modifier_item_autumn_leaves_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target
	if attacker ~= self:GetParent() 
		or attacker:GetTeam() == target:GetTeam()
		or target:IsBuilding()
		or target:IsIllusion()		
		or attacker:HasModifier("modifier_item_laevateinn_passive")
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
	target:AddNewModifier(attacker, self:GetAbility(), "modifier_item_autumn_leaves_target",{})
	self:SetStackCount(0)
	--[[local deal_damage = keys.damage
			print(deal_damage)
			local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
			local health_regen = deal_damage * lifesteal_percent
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
			attacker:Heal(health_regen,attacker)]]
	local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(particle, 0, Vector(attacker:GetAbsOrigin().x, attacker:GetAbsOrigin().y, attacker:GetAbsOrigin().z))
end

modifier_item_autumn_leaves_target = {}
LinkLuaModifier("modifier_item_autumn_leaves_target","items/item_autumn_leaves.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_autumn_leaves_target:IsHidden() return true end
function modifier_item_autumn_leaves_target:IsPurgable() return false end

function modifier_item_autumn_leaves_target:DeclareFunctions()	
	return {
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

--吸血
function modifier_item_autumn_leaves_target:OnAttacked(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target
	--[[print("attacker="..attacker:GetClassname())
			print("target="..target:GetClassname())	
			if attacker:HasModifier("modifier_item_autumn_leaves_passive") then
				print("p=t")
			end
			if target:HasModifier("modifier_item_autumn_leaves_target") then
				print("t=t")
			end	]]
	if attacker:GetTeam() == target:GetTeam()
		or target:IsBuilding()
		or target:IsIllusion()
		or attacker:HasModifier("modifier_item_laevateinn_passive")		
	then 
		return 
	end	

	local deal_damage = keys.damage
	local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
	local health_regen = deal_damage * lifesteal_percent
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
	attacker:Heal(health_regen,attacker)
	target:RemoveModifierByName("modifier_item_autumn_leaves_target")
end