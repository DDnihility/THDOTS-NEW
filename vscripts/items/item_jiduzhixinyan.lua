item_jiduzhixinyan = {}

function item_jiduzhixinyan:GetIntrinsicModifierName()
	return "modifier_item_jiduzhixinyan_passive"
end

--[[function item_jiduzhixinyan:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end]]

modifier_item_jiduzhixinyan_passive = {}
LinkLuaModifier("modifier_item_jiduzhixinyan_passive","items/item_jiduzhixinyan.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_jiduzhixinyan_passive:IsHidden() return false end
function modifier_item_jiduzhixinyan_passive:IsPurgable() return false end
function modifier_item_jiduzhixinyan_passive:IsPurgeException() return false end
function modifier_item_jiduzhixinyan_passive:RemoveOnDeath() return false end

function modifier_item_jiduzhixinyan_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_RESPAWN,
	}
end

function modifier_item_jiduzhixinyan_passive:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_jiduzhixinyan_passive:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

modifier_item_jiduzhixinyan_debuff_exposed = {}
LinkLuaModifier("modifier_item_jiduzhixinyan_debuff_exposed","items/item_jiduzhixinyan.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_jiduzhixinyan_debuff_exposed:IsHidden() 		return false end
function modifier_item_jiduzhixinyan_debuff_exposed:IsPurgable()		return true end
function modifier_item_jiduzhixinyan_debuff_exposed:RemoveOnDeath() 	return true end
function modifier_item_jiduzhixinyan_debuff_exposed:IsDebuff()		return true end
--暴露视野
function modifier_item_jiduzhixinyan_debuff_exposed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    }
end

function modifier_item_jiduzhixinyan_debuff_exposed:GetModifierProvidesFOWVision()
	return self:GetAbility():GetSpecialValueFor("Vision")
end

modifier_item_jiduzhixinyan_debuff = {}
LinkLuaModifier("modifier_item_jiduzhixinyan_debuff","items/item_jiduzhixinyan.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_jiduzhixinyan_debuff:IsHidden() 		return false end
function modifier_item_jiduzhixinyan_debuff:IsPurgable()		return false end
function modifier_item_jiduzhixinyan_debuff:RemoveOnDeath() 	return true end
function modifier_item_jiduzhixinyan_debuff:IsDebuff()		return true end
--减治疗、视野，增加受到的伤害
function modifier_item_jiduzhixinyan_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,	
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_item_jiduzhixinyan_debuff:GetModifierHealAmplify_PercentageTarget()
	return self:GetAbility():GetSpecialValueFor("heal_reduce")
end

function modifier_item_jiduzhixinyan_debuff:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("heal_reduce")
end

function modifier_item_jiduzhixinyan_debuff:GetBonusVisionPercentage()
	return self:GetAbility():GetSpecialValueFor("BonusVisionPercentage")
end

function modifier_item_jiduzhixinyan_debuff:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage_percentage")
end

--[[function modifier_item_jiduzhixinyan_passive:OnCreated()
	if not IsServer() then return end
	self.decrease_time = self:GetAbility():GetSpecialValueFor("decrease_time")
	self.time = 0
	self:StartIntervalThink(1)
end

function modifier_item_jiduzhixinyan_passive:OnIntervalThink()
	if not IsServer() then return end
	self.time = self.time + 1
	if self.time >= self.decrease_time then
		if self:GetStackCount() >= 0 then
			self:DecrementStackCount()
		end
		self.time = 0
	end
end]]
--死亡时触发
function modifier_item_jiduzhixinyan_passive:OnDeath(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = keys.attacker
	--[[local radius = self:GetAbility():GetSpecialValueFor("radius")
	if keys.attacker == self:GetCaster() and keys.unit:IsRealHero() then
		--击杀英雄，清零层数
		keys.unit:SetContextThink("HasAegis",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if keys.unit:GetTimeUntilRespawn() > 5 then
				self:SetStackCount(0)
				self.time = 0
				-- local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
				-- ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
				-- ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
				-- ParticleManager:ReleaseParticleIndex(effectIndex)
				-- caster:EmitSound("DOTA_Item.Hand_Of_Midas")
			end
		end
		,
		FrameTime())]]
	if keys.unit == self:GetCaster() and keys.unit:IsRealHero() then
		--本体死亡，增加层数并对击杀与助攻者造成伤害
		print("keys.attacker:GetName()")
		print(keys.attacker:GetName())
		print(keys.attacker:IsBuilding())
		if keys.attacker == caster or keys.attacker:GetLevel() < caster:GetLevel() then return end --自杀无效,被低级击杀无效。
		keys.unit:SetContextThink("HasAegis",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if keys.unit:GetTimeUntilRespawn() > 5 then
				print(keys.unit:GetTimeUntilRespawn())
				self:IncrementStackCount()
				self.time = 0
				if keys.attacker:IsRealHero() then
					local kill_dummy = CreateUnitByName("npc_dummy_unit", 
	                        caster:GetOrigin(), 
							false, 
						    caster, 
							caster, 
							caster:GetTeamNumber()
							)
					kill_dummy.jiduzhixinyan_target = keys.attacker
					kill_dummy.t = 0
					kill_dummy.even = even
					kill_dummy.IsKiller = true
					kill_dummy:AddNewModifier(kill_dummy, ability, "modifier_kill", {duration = 10})
					if not keys.attacker:IsBuilding() then
						caster:EmitSound("THD_ITEM.Jiduzhixinyan_Cast")
						kill_dummy:AddNewModifier(caster, self:GetAbility(), "modifier_item_jiduzhixinyan_dummy",{duration = 5})
						target:AddNewModifier(caster, self:GetAbility(), "modifier_item_jiduzhixinyan_debuff_exposed",{duration = 8})
						target:AddNewModifier(caster, self:GetAbility(), "modifier_item_jiduzhixinyan_debuff",{})
					end
				end

				--[[local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(),nil,radius,ability:GetAbilityTargetTeam()
						,ability:GetAbilityTargetType(),0,0,false)
				for _,victim in ipairs(targets) do
					if not victim:IsRealHero() then break end]]
					local dummy = CreateUnitByName("npc_dummy_unit", 
	                        caster:GetOrigin(), 
							false, 
						    caster, 
							caster, 
							caster:GetTeamNumber()
							)
					dummy.jiduzhixinyan_target = target
					dummy.t = 0
					dummy.even = even
					dummy:AddNewModifier(dummy, ability, "modifier_kill", {duration = 10})
					--[[if target ~= keys.attacker and victim:IsRealHero() and victim:GetLevel() > caster:GetLevel() then
						dummy.IsKiller = false
						dummy:AddNewModifier(caster, self:GetAbility(), "modifier_item_jiduzhixinyan_dummy",{duration = 5})
					end]]
				--end
				-- local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
				-- ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
				-- ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
				-- ParticleManager:ReleaseParticleIndex(effectIndex)
				-- caster:EmitSound("DOTA_Item.Hand_Of_Midas")
			end
		end
		,
		FrameTime())
	end
end
--复活时清除debuff
function modifier_item_jiduzhixinyan_passive:OnRespawn(keys)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(),nil,99999,ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
	for _,victim in ipairs(targets) do
		if not victim:IsRealHero() then break end
		victim:RemoveModifierByNameAndCaster("modifier_item_jiduzhixinyan_debuff",caster)
	end
end

modifier_item_jiduzhixinyan_dummy = {}
LinkLuaModifier("modifier_item_jiduzhixinyan_dummy","items/item_jiduzhixinyan.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_item_jiduzhixinyan_dummy:IsHidden() 		return false end
function modifier_item_jiduzhixinyan_dummy:IsPurgable()		return false end
function modifier_item_jiduzhixinyan_dummy:RemoveOnDeath() 	return true end
function modifier_item_jiduzhixinyan_dummy:IsDebuff()		return false end
function modifier_item_jiduzhixinyan_dummy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_jiduzhixinyan_dummy:OnCreated()
	if not IsServer() then return end
	-- body
	self.caster 				= self:GetCaster()
	local dummy = self:GetParent()
	self.target 				= dummy.jiduzhixinyan_target
	self.start_point 			= self:GetAbility().start_point
	self.damage 				= self:GetAbility():GetSpecialValueFor("damage")
	self.per_level_damage 		= self:GetAbility():GetSpecialValueFor("per_level_damage")
	self.per_count_damage 		= self:GetAbility():GetSpecialValueFor("per_count_damage")
	self.speed 					= 800 * FrameTime()
	--local count = self.caster:FindModifierByName("modifier_item_jiduzhixinyan_passive"):GetStackCount()
	self.damage = self.damage + (self.target:GetLevel() - self.caster:GetLevel()) * self.per_level_damage
	--[[if dummy.IsKiller == false then
		self.damage = self.damage * 0.5
	end]]
	print("self.damage")
	print(self.damage)
	print(self.target:GetLevel())
	print(count)
	-- self.angle = 0
	-- local particle = "particles/units/heroes/hero_pugna/pugna_base_attack.vpcf"
	-- local particle = "particles/econ/items/necrolyte/necrophos_sullen/necro_sullen_pulse_enemy.vpcf"
	local particle = "particles/econ/items/necrolyte/necrophos_sullen/necro_sullen_pulse_friend.vpcf"
	self.fxIndex = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, dummy)
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControlEnt(self.fxIndex , 0, dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.fxIndex, 1, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.fxIndex, 2, Vector(2000,0,0))
	self:StartIntervalThink(FrameTime())
end

function modifier_item_jiduzhixinyan_dummy:OnIntervalThink()
	if not IsServer() then return end
	local caster = self.caster
	local dummy = self:GetParent()
	local target = self.target
	local ability = self:GetAbility()
	local damage = self.damage

	-- local qangle = QAngle(0, 30, 0)
	-- local add_increase		= 1	--递增角度
	-- local max_angel			= 10--最大发射角度
	-- if self.angle <= max_angel then
	-- 	self.angle = self.angle + add_increase
	-- else
	-- 	self.angle = -self.angle
	-- 	self.angle = self.angle - add_increase
	-- end
	-- qangle = QAngle(0, self.angle, 0)
	-- local direct = (target:GetOrigin() - dummy:GetOrigin()):Normalized()
	-- --移动
	-- local next_point = dummy:GetOrigin() + direct * self.speed
	-- -- local next_point = dummy:GetOrigin() + Vector(10,10,0) * self.speed
	-- next_point.z = self.start_point.z
	-- -- dummy:SetOrigin(next_point)

	if not target:IsAlive() then
		self:Destroy()
	end
	if dummy:IsNull() then return end
	ParticleManager:SetParticleControl(self.fxIndex, 1, dummy:GetOrigin())
	local vec = dummy:GetOrigin() 
	local rad = GetRadBetweenTwoVec2D(vec,target:GetOrigin())
	local high = target:GetOrigin().z
	dummy.t = dummy.t + 0.15
	local t = dummy.t
	local even = 1
	--相反角度
	if dummy.even then
		even = 1
	else
		even = -1
	end
	if t < math.pi then --固定转的弧度，pi为半圈
		vec = Vector(vec.x + even*math.cos(t)*20,vec.y + math.sin(t)*20,400)
		dummy:SetOrigin(vec)
	elseif t < math.pi*1.2 then --转完了冲目标而去
			vec = Vector(vec.x + (math.cos(rad) + math.cos(t)) *(20-math.pi*2+t),vec.y + (math.sin(rad) + math.sin(t)) *(20-math.pi*2+t),vec.z)
			dummy:SetOrigin(vec)
	elseif t > math.pi*1.2 then
		dummy.t = dummy.t + 0.5
		vec = Vector(vec.x + math.cos(rad)*(20+t*2),vec.y + math.sin(rad)*(20+t*2),vec.z)
		dummy:SetOrigin(vec)
		if not target:IsAlive() then
			dummy:RemoveSelf()
			self:Destroy()
		elseif GetDistanceBetweenTwoVec2D(dummy:GetAbsOrigin(),target:GetAbsOrigin()) < 50 then --击中距离判定
			--特效音效
			local particle_name = "particles/econ/items/undying/undying_pale_augur/undying_pale_augur_decay_strength_xfer.vpcf"
			local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particle, 0, dummy:GetOrigin())
			ParticleManager:SetParticleControl(particle, 1, dummy:GetOrigin())
			ParticleManager:SetParticleControl(particle, 2, dummy:GetOrigin())
			ParticleManager:ReleaseParticleIndex(particle)
			dummy:EmitSound("THD_ITEM.Jiduzhixinyan_Damage")
			local damage_tabel = {
				victim 			= target,
				damage 			= damage,
				damage_type		= DAMAGE_TYPE_PURE,
				attacker 		= caster,
				ability 		= ability
			}
			UnitDamageTarget(damage_tabel)
			dummy:RemoveSelf()
			self:Destroy()
			return
		end
	end

	-----------------
	-- dummy.jiduzhixinyan_target:GetOrigin() = RotatePosition(self.start_point, qangle, dummy.jiduzhixinyan_target:GetOrigin())
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	-- ParticleManager:SetParticleControl(self.fxIndex, 2, Vector(2000,0,0))
end

function modifier_item_jiduzhixinyan_dummy:OnDestroy()
	if not IsServer() then return end
	local dummy = self:GetParent()
	
	dummy:RemoveSelf()
	-- ParticleManager:DestroyParticleSystem(self.fxIndex,true)
	ParticleManager:ReleaseParticleIndex(self.fxIndex)
end