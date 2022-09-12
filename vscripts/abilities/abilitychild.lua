if AbilityChild == nil then
	AbilityChild = class({})
end
CHILD03LIGHT_I = 0 --定义50个child03light
destroyUnit = {}
count = 0

function Child01OnSpellStart( keys )
	AbilityChild:Child01OnSpellStart(keys)
end

function Child03OnAttack( keys )
	AbilityChild:Child03OnAttack(keys)
end

function Child03OnLight(keys)
	AbilityChild:Child03OnLight(keys)
end


function AbilityChild:initLightData(num)
	-- body
	self.tChild03Light = self.tChild03Light or {}
	self.tChild03Light[num] = {
		Ball = {unit = nil , t = 0 , effect = nil},
		Target = nil,
	}
end

function Child01OnSpellStart( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	--particles/units/heroes/hero_sniper/sniper_assassinate.vpcf
	--particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf  3技能弹道
	info = {
		EffectName = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf",
		Ability = keys.ability,
		iMoveSpeed = 1000,
		Source = caster,
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		--ExtraData = {x = 10, y = 2, name = "abc"}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function Child01OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local type = keys.ability:GetAbilityDamageType()
	if caster:HasModifier("modifier_item_wanbaochui") then
		type = DAMAGE_TYPE_MAGICAL
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_child01_debuff", {Duration = keys.duration})
	local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.damage + caster:GetAttackDamage() * keys.attack_bonus,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
	UnitDamageTarget(damage_table)
end

function Child02OnSpellStart( keys )
	local caster = keys.caster
	local duration = keys.duration
	local radius = keys.radius
	local ability = keys.ability
	Child02targetPoint = keys.target_points[1]
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_entryportal.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Child02targetPoint)
	ParticleManager:DestroyParticleSystemTime(effectIndex,duration)
	if FindTelentValue(caster,"special_bonus_unique_child_1") ~= 0 then
		local point = caster:GetAbsOrigin()
		local vec = caster:GetForwardVector()
		local ABS_VEC = math.acos(vec.x) 
		for i=0,5 do
			local rad = Vector(math.cos(ABS_VEC+math.pi/2.5*i),math.sin(ABS_VEC+math.pi/2.5*i),0) --方向
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_entryportal.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex,0, Child02targetPoint + rad * 150)
			ParticleManager:DestroyParticleSystemTime(effectIndex,duration)
		end
	end
	CreateModifierThinker(caster, ability, "modifier_ability_thdots_child02_thinker", {duration = duration}, Child02targetPoint, caster:GetTeamNumber(), false)
	-- local targets = FindUnitsInRadius(caster:GetTeam(), Child02targetPoint, nil, 99999, keys.ability:GetAbilityTargetTeam(), keys.ability:GetAbilityTargetType(), 0, 0, false)
	-- for _,v in pairs(targets) do
	-- 	local child02Debuff_flag = v:FindModifierByName("modifier_ability_thdots_child02_debuff_flag")
	-- 	if child02Debuff_flag == nil then --全地图所有英雄添加flag，表示只触发一次眩晕
	-- 		ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_child02_debuff_flag", {Duration = duration})
	-- 		v:SetModifierStackCount("modifier_ability_thdots_child02_debuff_flag", caster, 2)
	-- 	end
	-- end
end

ability_thdots_child01 = class({})

function ability_thdots_child01:GetCastRange()
	return self:GetCaster():Script_GetAttackRange()+25
end

function ability_thdots_child01:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	self.attack_count = 0
	self.bonus_attack = false
	if self.target:HasModifier("modifier_ability_thdots_child02_thinker_sign") then
		self.bonus_attack = true
	end
	self:SetContextThink("child01Shooting",
		function()
		self.caster:EmitSound("Hero_Sniper.attack")
		info = {
			EffectName = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf",
			Ability = self,
			iMoveSpeed = 1000,
			Source = self.caster,
			Target = self.target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			--ExtraData = {x = 10, y = 2, name = "abc"}
		}
		ProjectileManager:CreateTrackingProjectile(info)
		self.attack_count = self.attack_count + 1
		if self.attack_count == 2 and not self.bonus_attack then
			return nil
		end
		if self.attack_count >= 3 then
			return nil
		end
		if self.bonus_attack then
			return 0.13
		else
			return 0.2
		end
		end
	,0)
end

function ability_thdots_child01:OnProjectileHit(Target,Location)
	if not IsServer() then return end
	if not Target or Target:IsNull() then return end
	AbilityChild:Child03OnAttack({target = Target,caster = self:GetCaster()})
	local caster = self:GetCaster()
	local type = self:GetAbilityDamageType()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		type = DAMAGE_TYPE_MAGICAL
	end
	if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_ability_thdots_child04") then
				ability01 = caster:FindAbilityByName("ability_thdots_child01")
				ability02 = caster:FindAbilityByName("ability_thdots_child02")
				ability04 = caster:FindAbilityByName("ability_thdots_child04")
				local new_cooldown01 = ability01:GetCooldownTimeRemaining()-1
				local new_cooldown02 = ability02:GetCooldownTimeRemaining()-1
				local new_cooldown04 = ability04:GetCooldownTimeRemaining()-1
				ability01:EndCooldown()
				ability02:EndCooldown()
				ability04:EndCooldown()
				if new_cooldown01 > 0 then
					ability01:StartCooldown(new_cooldown01)
				end
				if new_cooldown02 > 0 then
					ability02:StartCooldown(new_cooldown02)
				end
				if new_cooldown04 > 0 then
					ability04:StartCooldown(new_cooldown04)
				end
	end
	--self:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_child01_debuff", {Duration = keys.duration})
	if Target:HasModifier("modifier_ability_thdots_child01_debuff") then
		local count = Target:GetModifierStackCount("modifier_ability_thdots_child01_debuff",self:GetCaster())
		Target:SetModifierStackCount("modifier_ability_thdots_child01_debuff",self:GetCaster(),count+1)
	else
		Target:AddNewModifier(self:GetCaster(), self,"modifier_ability_thdots_child01_debuff", {duration = self:GetSpecialValueFor("duration") * (1 - Target:GetStatusResistance())})
		Target:SetModifierStackCount("modifier_ability_thdots_child01_debuff",self:GetCaster(),1)
	end
	local damage_table = {
					ability = self,
					victim = Target,
					attacker = self:GetCaster(),
					damage = self:GetSpecialValueFor("damage")+ self:GetCaster():GetAgility()*self:GetSpecialValueFor("attack_bonus"),
					damage_type = type, 
					damage_flags = 0
				}
	UnitDamageTarget(damage_table)
end

modifier_ability_thdots_child01_debuff = {}
LinkLuaModifier("modifier_ability_thdots_child01_debuff","scripts/vscripts/abilities/abilitychild.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_child01_debuff:IsHidden() 		return false end
function modifier_ability_thdots_child01_debuff:IsPurgable()		return true end
function modifier_ability_thdots_child01_debuff:RemoveOnDeath() 	return true  end
function modifier_ability_thdots_child01_debuff:IsDebuff()		return true end

function modifier_ability_thdots_child01_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_thdots_child01_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_slow")*self:GetStackCount()
end

function modifier_ability_thdots_child01_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attackspeed_slow")*self:GetStackCount()
end

modifier_ability_thdots_child02_thinker = {}
LinkLuaModifier("modifier_ability_thdots_child02_thinker","scripts/vscripts/abilities/abilitychild.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_child02_thinker:IsHidden() 		return false end
function modifier_ability_thdots_child02_thinker:IsPurgable()		return false end
function modifier_ability_thdots_child02_thinker:RemoveOnDeath() 	return false end
function modifier_ability_thdots_child02_thinker:IsDebuff()		return false end
-- function modifier_ability_thdots_child02_thinker:GetAuraRadius() return self.radius end -- global
-- function modifier_ability_thdots_child02_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
-- function modifier_ability_thdots_child02_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
-- function modifier_ability_thdots_child02_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
-- function modifier_ability_thdots_child02_thinker:GetModifierAura() return "modifier_ability_thdots_child02_thinker_debuff" end
-- function modifier_ability_thdots_child02_thinker:IsAura() return true end
function modifier_ability_thdots_child02_thinker:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.radius = self:GetAbility():GetSpecialValueFor("radius") + FindTelentValue(caster,"special_bonus_unique_child_1")
	self.point = self:GetParent():GetOrigin()
	self.ability = self:GetAbility()
	self.duration 	= self.ability:GetSpecialValueFor("duration")
	self:StartIntervalThink(0.1)
end

function modifier_ability_thdots_child02_thinker:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

function modifier_ability_thdots_child02_thinker:OnAbilityExecuted(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = keys.unit
	print(target:GetName())
	if keys.ability:IsItem() then return end
	if target:GetTeam() ~= caster:GetTeam() and (target:GetOrigin() - self.point):Length2D() <= self.radius then
		target:AddNewModifier(caster, self.ability,"modifier_ability_thdots_child02_thinker_debuff", {duration = self.duration})
	end
end

function modifier_ability_thdots_child02_thinker:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local targets = FindUnitsInRadius(
		   		caster:GetTeam(),		--caster team
		  		self.point,		--find position
		   		nil,					--find entity
		   		self.radius,		--find radius
		   		DOTA_UNIT_TARGET_TEAM_ENEMY,
		   		DOTA_UNIT_TARGET_ALL,
		   		0, 
		   		FIND_CLOSEST,
		   		false
	)
	for _,v in pairs(targets) do
		v:AddNewModifier(caster, self.ability,"modifier_ability_thdots_child02_thinker_sign", {duration = 0.2})
	end
end

modifier_ability_thdots_child02_thinker_sign = {}
LinkLuaModifier("modifier_ability_thdots_child02_thinker_sign","scripts/vscripts/abilities/abilitychild.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_child02_thinker_sign:IsHidden() 		return true end
function modifier_ability_thdots_child02_thinker_sign:IsPurgable()		return false end
function modifier_ability_thdots_child02_thinker_sign:RemoveOnDeath() 	return false end
function modifier_ability_thdots_child02_thinker_sign:IsDebuff()		return true end

modifier_ability_thdots_child02_thinker_debuff = {}
LinkLuaModifier("modifier_ability_thdots_child02_thinker_debuff","scripts/vscripts/abilities/abilitychild.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_child02_thinker_debuff:IsHidden() 		return false end
function modifier_ability_thdots_child02_thinker_debuff:IsPurgable()		return false end
function modifier_ability_thdots_child02_thinker_debuff:RemoveOnDeath() 	return false end
function modifier_ability_thdots_child02_thinker_debuff:IsDebuff()		return true end

function modifier_ability_thdots_child02_thinker_debuff:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	local stun_duration 	= ability:GetSpecialValueFor("stun_duration")
	local damage 			= ability:GetSpecialValueFor("damage")
	UtilStun:UnitStunTarget(caster,target,stun_duration)
	target:EmitSound("Hero_Wisp.Spirits.Target")
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge.vpcf", PATTACH_POINT, target)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	local damage_table = {
				ability = ability,
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
	UnitDamageTarget(damage_table)
end



-- function Child02OIntervalThink( keys ) --循环计时判断是否在范围内
-- 	local caster = keys.caster
-- 	local duration = keys.duration
-- 	local radius = keys.radius +FindTelentValue(caster,"special_bonus_unique_child_1")
-- 	local ability = keys.ability
-- 	local targets = FindUnitsInRadius(caster:GetTeam(), Child02targetPoint, nil, 99999, keys.ability:GetAbilityTargetTeam(), keys.ability:GetAbilityTargetType(), 0, 0, false)
-- 	for _,v in pairs(targets) do
-- 		local distance = GetDistanceBetweenTwoVec2D(Child02targetPoint,v:GetOrigin())
-- 		local child02Debuff = v:FindModifierByName("modifier_ability_thdots_child02_debuff")
-- 		local child02Debuff_flag = v:FindModifierByName("modifier_ability_thdots_child02_debuff_flag")
-- 		if distance <= radius then --检测英雄是否在范围内，在则添加debuff，不在则清除debuff
-- 			ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_child02_debuff", {Duration = 0.1})
-- 		else
-- 			v:RemoveModifierByName("modifier_ability_thdots_child02_debuff")
-- 		end
-- 	end
-- end

-- function child02DebuffOnSpellStart( keys )
-- 	local caster = keys.caster
-- 	local target = keys.unit
-- 	local stun_duration = keys.stun_duration
-- 	if target:FindModifierByName("modifier_ability_thdots_child02_debuff_flag") == 1 then return end
-- 	if keys.event_ability:IsItem() then return end
-- 	if target:GetModifierStackCount("modifier_ability_thdots_child02_debuff_flag", caster) == 2 then 
-- 		local damage_table = {
-- 					ability = keys.ability,
-- 					victim = target,
-- 					attacker = caster,
-- 					damage = keys.damage,
-- 					damage_type = keys.ability:GetAbilityDamageType(), 
-- 					damage_flags = 0
-- 				}
-- 		UnitDamageTarget(damage_table)
-- 		UtilStun:UnitStunTarget(caster,target,stun_duration)
-- 		target:EmitSound("Hero_Wisp.Spirits.Target")
-- 		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge.vpcf", PATTACH_POINT, target)
-- 		ParticleManager:DestroyParticleSystem(effectIndex,false)
-- 		target:SetModifierStackCount("modifier_ability_thdots_child02_debuff_flag", caster, 1)
-- 	end
-- end

function AbilityChild:Child03OnAttack( keys ) --命中触发光效
	-- body
	local caster = keys.caster
	local target = keys.target
	local minHealth = 1
	local FlagAbility = caster:FindAbilityByName("ability_thdots_child03")
	if FlagAbility:GetLevel() == 0 or FlagAbility == nil then return end --判断是否学习3技能
	if (FlagAbility:GetContext("ability_Child03_Count") == nil) then
	    FlagAbility:SetContextNum("ability_Child03_Count",count,0)
	end
	-- CHILD03LIGHT_I = CHILD03LIGHT_I + 1
	count = count + 1
	FlagAbility:SetContextNum("ability_Child03_Count",count,0)
	AbilityChild:initLightData(count)
	self.tChild03Light[count].Ball.unit = CreateUnitByName(
			"npc_ability_child_03_light"
			,target:GetOrigin()
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
	destroyUnit[count] = self.tChild03Light[count].Ball.unit
	self.tChild03Light[count].Ball.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.tChild03Light[count].Ball.unit)		
	-- ParticleManager:DestroyParticleSystemTime(self.tChild03Light[count].Ball.effect,60)
	local modefei = FlagAbility:ApplyDataDrivenModifier(caster, self.tChild03Light[count].Ball.unit, "modifier_ability_thdots_child03_light", {Duration = 5})
	self.tChild03Light[count].Ball.unit:SetModifierStackCount("modifier_ability_thdots_child03_light", caster, count)
	local ability_dummy_unit = self.tChild03Light[count].Ball.unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	target:SetContextThink("ability_child03",
			function()
				if GameRules:IsGamePaused() then return 0.03 end
				local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 500, FlagAbility:GetAbilityTargetTeam(), FlagAbility:GetAbilityTargetType(), 0, 0, false)
				for _,v in pairs(targets) do
					if v:GetHealth()/v:GetMaxHealth() <= minHealth then
						minHealth = v:GetHealth()/v:GetMaxHealth()
						self.tChild03Light[count].Target = v
					end
				end
			end,0.04
		)
end

function AbilityChild:Child03OnLight( keys ) --光效移动，计时器0.03，光效击中造成伤害
	local caster = keys.caster
	local unit = keys.target
	if not unit or unit:IsNull() then return end
	local duration = keys.duration
	local i = unit:GetModifierStackCount("modifier_ability_thdots_child03_light", caster)
	if self.tChild03Light[i] == nil then return end
	if self.tChild03Light[i].Target == nil then 
		self.tChild03Light[i].Ball.unit:RemoveSelf()
		self.tChild03Light[i].Ball.unit = nil
		return 
	end
	local target = self.tChild03Light[i].Target 
	if self.tChild03Light[i].Ball.unit == nil then
		return
	end
	local vec = self.tChild03Light[i].Ball.unit:GetAbsOrigin() 

	if not target or target:IsNull() then
		self.tChild03Light[i].Ball.unit:RemoveSelf()
		return
	end

	local rad = GetRadBetweenTwoVec2D(vec,target:GetAbsOrigin())
	self.tChild03Light[i].Ball.t = self.tChild03Light[i].Ball.t + 0.15 --时间
	local t = self.tChild03Light[i].Ball.t
	if t >= 25 then --超过时间删除dummy
		destroyUnit[i]:RemoveSelf()
		-- self.tChild03Light[i].Ball.unit:RemoveSelf()
		self.tChild03Light[i].Ball.unit = nil
		return
	end
	if t < math.pi then --固定转的弧度，pi为半圈
		vec = Vector(vec.x + math.cos(t)*20,vec.y + math.sin(t)*20,vec.z+1)
		self.tChild03Light[i].Ball.unit:SetOrigin(vec)
			if FindTelentValue(caster,"special_bonus_unique_child_2") == 1 then --根据天赋判定一次是否为英雄
				local heroes = FindUnitsInRadius(caster:GetTeam(), vec, nil, 500, keys.ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, 0, false)
				if #heroes > 0 then 
					local HeroMinHealth = 1
					for _,h in pairs(heroes) do
						if h:GetHealth()/h:GetMaxHealth() <= HeroMinHealth then
							HeroMinHealth = h:GetHealth()/h:GetMaxHealth()
							self.tChild03Light[i].Target = h
						end
					end
				end
			end
	elseif t < math.pi*2 then --转完了冲目标而去
		if math.abs(t - math.pi*2) < 0.15 then  --另外加一次判定，若原目标死亡则转半圈后更新目标
			local targets = FindUnitsInRadius(caster:GetTeam(), vec, nil, 500, keys.ability:GetAbilityTargetTeam(), keys.ability:GetAbilityTargetType(), 0, 0, false)
			local minHealth = 1
			for _,v in pairs(targets) do
				if v:GetHealth()/v:GetMaxHealth() <= minHealth then
					minHealth = v:GetHealth()/v:GetMaxHealth()
					self.tChild03Light[i].Target = v
					if FindTelentValue(caster,"special_bonus_unique_child_2") == 1 then --再根据天赋判定一次是否为英雄
						local heroes = FindUnitsInRadius(caster:GetTeam(), vec, nil, 500, keys.ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, 0, false)
						if #heroes > 0 then 
							local HeroMinHealth = 1
							for _,h in pairs(heroes) do
								if h:GetHealth()/h:GetMaxHealth() <= HeroMinHealth then
									HeroMinHealth = h:GetHealth()/h:GetMaxHealth()
									self.tChild03Light[i].Target = h
								end
							end
						end
					end
				end
			end
		end
		vec = Vector(vec.x + (math.cos(rad) + math.cos(t)) *(20-math.pi*2+t),vec.y + (math.sin(rad) + math.sin(t)) *(20-math.pi*2+t),vec.z-1)
		self.tChild03Light[i].Ball.unit:SetOrigin(vec)
	elseif t > math.pi*2 then
		vec = Vector(vec.x + math.cos(rad)*(20+t),vec.y + math.sin(rad)*(20+t),vec.z)
		self.tChild03Light[i].Ball.unit:SetOrigin(vec)
		if not target or target:IsNull() or not target:IsAlive() then
			self.tChild03Light[i].Ball.unit:RemoveSelf()
			self.tChild03Light[i].Ball.unit = nil
			return
		elseif GetDistanceBetweenTwoVec2D(self.tChild03Light[i].Ball.unit:GetAbsOrigin(),target:GetAbsOrigin()) < 50 then --击中距离判定
			unit:EmitSound("Hero_Wisp.Spirits.Target")
			self.tChild03Light[i].Ball.unit:RemoveSelf()
			self.tChild03Light[i].Ball.unit = nil
			--添加debuff，带层数的
			if not target:IsBuilding() then
				local child03Modifier = target:FindModifierByName("modifier_ability_thdots_child03_debuff")
				if not child03Modifier then
					local child03Modifier = keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_child03_debuff", {Duration = duration})
					target:SetModifierStackCount("modifier_ability_thdots_child03_debuff", keys.ability,1 + FindTelentValue(caster,"special_bonus_unique_child_4"))
				else
					local count = target:GetModifierStackCount("modifier_ability_thdots_child03_debuff", nil)
					child03Modifier:SetDuration(duration, true)
					target:SetModifierStackCount("modifier_ability_thdots_child03_debuff", keys.ability, count + 1 + FindTelentValue(caster,"special_bonus_unique_child_4"))
					if count >= 3 and FindTelentValue(caster,"special_bonus_unique_child_4") ~= 2 then --层数上限
						target:SetModifierStackCount("modifier_ability_thdots_child03_debuff", keys.ability, 3)
					end
				end
			end
			--
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_child03_debuff", {Duration = duration})
			local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.damage * (FindTelentValue(caster,"special_bonus_unique_child_4")+1),
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
			UnitDamageTarget(damage_table)
			return
		end
	end
end

function Child03Destory( keys )
	keys.target:RemoveSelf()
end


-- function Child04OnSpellStart( keys )
-- 	local caster = keys.caster
-- 	caster.point = caster:GetAbsOrigin()
-- 	local targetPoint = keys.target_points[1]
-- 	keys.ability.point = targetPoint
-- 	local vecCaster = caster:GetOrigin()
-- 	local maxRange = keys.range
-- 	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
-- 	local light = CreateUnitByName(
-- 						"npc_ability_child_04_light"
-- 						,caster:GetAbsOrigin() + caster:GetForwardVector()*10
-- 						,false
-- 						,caster
-- 						,caster
-- 						,caster:GetTeam()
-- 					)
-- 	local ability_dummy_unit = light:FindAbilityByName("ability_dummy_unit")
-- 	ability_dummy_unit:SetLevel(1)
-- 	light:SetContextThink("ability_child04",
-- 			function()
-- 				if GameRules:IsGamePaused() then return 0.03 end
-- 					local lightModifier = keys.ability:ApplyDataDrivenModifier(caster, light, "modifier_ability_thdots_child04_light", {}) 
-- 			end,0.04
-- 		)
-- end

-- function Child04Light( keys )
-- 	local caster = keys.caster
-- 	local ability = keys.ability
-- 	local range = keys.range + FindTelentValue(caster,"special_bonus_unique_child_3")
-- 	local radius = keys.radius
-- 	local targetPoint = keys.ability.point
-- 	local light = keys.target
-- 	local vector_distance = light:GetAbsOrigin() - caster.point
-- 	local distance = (vector_distance):Length2D()
-- 	local direction = (vector_distance):Normalized()
-- 	local lightModifier = light:FindModifierByName("modifier_ability_thdots_child04_light")
-- 	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/void_spirit_warp_travel_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, light)
-- 	local effectIndex2 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg_shock.vpcf", PATTACH_ABSORIGIN_FOLLOW, light)
-- 	ParticleManager:DestroyParticleSystemTime(effectIndex, 0.5)
-- 	ParticleManager:DestroyParticleSystem(effectIndex2, false)
-- 	light:SetOrigin(light:GetAbsOrigin()+direction*100)
-- 	local targets = FindUnitsInRadius(caster:GetTeam(), light:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
-- 	for _,v in pairs(targets) do
-- 		if caster:FindModifierByName("modifier_ability_thdots_child04") == nil then
-- 			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_child04", {Duration = keys.duration})
-- 		end
-- 		if v:FindModifierByName("modifier_ability_thdots_child04_damage") == nil then
-- 			ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_child04_damage", {Duration = 10})
-- 			local count = caster:GetModifierStackCount("modifier_ability_thdots_child04", caster)
-- 			caster:SetModifierStackCount("modifier_ability_thdots_child04", caster, count + 1)
-- 		end
-- 	end
-- 	if distance >= range then
-- 		light:ForceKill(true)
-- 		return
-- 	end
-- end

-- function Child04Damage( keys )
-- 	local caster = keys.caster
-- 	local count = caster:GetModifierStackCount("modifier_ability_thdots_child04", caster)
-- 	local damage_table = {
-- 					ability = keys.ability,
-- 					victim = keys.target,
-- 					attacker = caster,
-- 					damage = keys.damage + keys.damage_bonus * count,
-- 					damage_type = keys.ability:GetAbilityDamageType(), 
-- 					damage_flags = 0
-- 				}
-- 	UnitDamageTarget(damage_table)
-- end

function Child04FixStart( keys )
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local range = keys.range + FindTelentValue(caster,"special_bonus_unique_child_3")
	local radius = keys.radius
	local vector_distance = targetPoint - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
	local targets = FindUnitsInLine(caster:GetTeam(), caster:GetAbsOrigin(), caster:GetAbsOrigin()+direction*range, nil, radius, ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(), 0)
	local num = 100
	for i=0,range/num do
		local dummy = CreateUnitByName(
			"npc_dummy_unit"
			,caster:GetAbsOrigin() + direction * num * i
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
		local ability_dummy_unit = dummy:FindAbilityByName("ability_dummy_unit")
		ability_dummy_unit:SetLevel(1)
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_explode_b_ti_5_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW,dummy)
		ParticleManager:DestroyParticleSystem(effectIndex, false)
		local effectIndex2 = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg_shock.vpcf", PATTACH_ABSORIGIN_FOLLOW,dummy)
		ParticleManager:DestroyParticleSystem(effectIndex2, false)
		dummy:ForceKill(true)
	end
	if #targets > 0 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_child04", {Duration = keys.duration})
		caster:SetModifierStackCount("modifier_ability_thdots_child04", caster, #targets)
		local type = ability:GetAbilityDamageType()
		if caster:HasModifier("modifier_item_wanbaochui") then
			type = DAMAGE_TYPE_MAGICAL
		end
		for _,v in pairs (targets) do
			v:EmitSound("Hero_Rubick.FadeBolt.Target")
			local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = keys.damage + (keys.damage_bonus+FindTelentValue(caster,"special_bonus_unique_child_3")) * #targets,
					damage_type = type, 
					damage_flags = 0
				}
			UnitDamageTarget(damage_table)
		end
	end
end

ability_thdots_childEx = {}

function ability_thdots_childEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_childEx"
end
modifier_ability_thdots_childEx = {}
modifier_ability_thdots_childEx_blur = {}
LinkLuaModifier("modifier_ability_thdots_childEx","scripts/vscripts/abilities/abilitychild.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_childEx_blur","scripts/vscripts/abilities/abilitychild.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_childEx:IsHidden() 		return false end
function modifier_ability_thdots_childEx:IsPurgable()		return false end
function modifier_ability_thdots_childEx:RemoveOnDeath() 	return false end
function modifier_ability_thdots_childEx:IsDebuff()		return false end

function modifier_ability_thdots_childEx:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.modifier_aura = "modifier_ability_thdots_childEx_blur" -- Not on mini-map modifier

	-- Ability specials
	self.radius = self:GetAbility():GetSpecialValueFor("radius")

	if IsServer() then
	
		-- Start thinking
		self:StartIntervalThink(0.2)
	end
end
function modifier_ability_thdots_childEx:OnRefresh()
	self:OnCreated()
end

function modifier_ability_thdots_childEx:OnIntervalThink()
	if IsServer() then

		-- Find nearby enemies
		local nearby_enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		-- If there is at least one, apply the blur modifier
		if #nearby_enemies > 0 and self.caster:HasModifier(self.modifier_aura) then
			self.caster:RemoveModifierByName(self.modifier_aura)

			-- Else, if there are no enemies, remove the modifier
		elseif #nearby_enemies == 0 and not self.caster:HasModifier(self.modifier_aura) then
			self.caster:AddNewModifier(self.caster, self:GetAbility(), self.modifier_aura, {})
		end
	end
end

function modifier_ability_thdots_childEx_blur:IsHidden() return true end
function modifier_ability_thdots_childEx_blur:IsDebuff() return false end
function modifier_ability_thdots_childEx_blur:IsPurgable() return false end
function modifier_ability_thdots_childEx_blur:StatusEffectPriority()  return 11 end

function modifier_ability_thdots_childEx_blur:GetStatusEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
end

function modifier_ability_thdots_childEx_blur:CheckState()
	return {[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true}
end