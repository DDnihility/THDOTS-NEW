item_bloodthirstiest = {}

function item_bloodthirstiest:GetIntrinsicModifierName()
	return "modifier_item_bloodthirstiest_passive"
end

modifier_item_bloodthirstiest_passive = {}
LinkLuaModifier("modifier_item_bloodthirstiest_passive","items/item_bloodthirstiest.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_bloodthirstiest_passive:IsHidden() return true end
function modifier_item_bloodthirstiest_passive:IsPurgable() return false end
function modifier_item_bloodthirstiest_passive:IsPurgeException() return false end
function modifier_item_bloodthirstiest_passive:RemoveOnDeath() return false end

function modifier_item_bloodthirstiest_passive:DeclareFunctions()	
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

--吸血
function modifier_item_bloodthirstiest_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target
	if attacker ~= self:GetParent() 
		or attacker:GetTeam() == target:GetTeam()
		or target:IsBuilding()
		or target:HasModifier("modifier_illusion")
		or attacker:HasModifier("modifier_item_autumn_leaves_passive")
		or attacker:HasModifier("modifier_item_laevateinn_passive")
	then 
		return 
	end
	--print(target:GetMagicalArmorValue())
	--print(keys.damage)
	if attacker:HasModifier("modifier_ability_thdots_youmu2_05_passive") or attacker:HasModifier("modifier_ability_thdots_youmu2_Ex_passive") then 
		--print("youmu")
		local deal_damage = keys.damage * ( 1 - target:GetMagicalArmorValue() )
		local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
		local health_regen = deal_damage * lifesteal_percent
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
		attacker:Heal(health_regen,attacker)
	end
	target:AddNewModifier(attacker, self:GetAbility(), "modifier_item_bloodthirstiest_target",{})
	--[[local deal_damage = keys.damage
			print(deal_damage)
			local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
			local health_regen = deal_damage * lifesteal_percent
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
			attacker:Heal(health_regen,attacker)]]
	local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(particle, 0, Vector(attacker:GetAbsOrigin().x, attacker:GetAbsOrigin().y, attacker:GetAbsOrigin().z))
end

modifier_item_bloodthirstiest_target = {}
LinkLuaModifier("modifier_item_bloodthirstiest_target","items/item_bloodthirstiest.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_bloodthirstiest_target:IsHidden() return true end
function modifier_item_bloodthirstiest_target:IsPurgable() return false end

function modifier_item_bloodthirstiest_target:DeclareFunctions()	
	return {
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

--吸血
function modifier_item_bloodthirstiest_target:OnAttacked(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.target

	--[[print("attacker="..attacker:GetClassname())
			print("target="..target:GetClassname())	
			if attacker:HasModifier("modifier_item_bloodthirstiest_passive") then
				print("p=t")
			end
			if target:HasModifier("modifier_item_bloodthirstiest_target") then
				print("t=t")
			end	]]
	if attacker:GetTeam() == target:GetTeam()
		or target:IsBuilding()
		or target:HasModifier("modifier_illusion")
		or attacker:HasModifier("modifier_item_autumn_leaves_passive")
		or attacker:HasModifier("modifier_item_laevateinn_passive")
	then 
		return 
	end		
	local deal_damage = keys.damage
	local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal_percent") / 100
	local health_regen = deal_damage * lifesteal_percent
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,attacker,health_regen,nil)
	attacker:Heal(health_regen,attacker)
	target:RemoveModifierByName("modifier_item_bloodthirstiest_target")
end