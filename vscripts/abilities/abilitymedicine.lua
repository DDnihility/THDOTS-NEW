
ability_thdots_medicine00 = class({})
modifier_ability_thdots_medicine00_debuff = class({})
modifier_ability_thdots_medicine00_talent = class({})
LinkLuaModifier("modifier_ability_thdots_medicine00_debuff", "scripts/vscripts/abilities/abilitymedicine.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_medicine00_talent", "scripts/vscripts/abilities/abilitymedicine.lua", LUA_MODIFIER_MOTION_NONE)

ability_thdots_medicine01 = class({})
modifier_ability_thdots_medicine01_debuff = class({})
modifier_ability_thdots_medicine01_caster = class({})
LinkLuaModifier("modifier_ability_thdots_medicine01_debuff", "scripts/vscripts/abilities/abilitymedicine.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_medicine01_caster", "scripts/vscripts/abilities/abilitymedicine.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_medicine01_debuff:IsHidden() 		return false end
function modifier_ability_thdots_medicine01_debuff:IsPurgable()		return true end
function modifier_ability_thdots_medicine01_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_medicine01_debuff:IsDebuff()		return true end
function modifier_ability_thdots_medicine01_caster:IsHidden() 		return true end
function modifier_ability_thdots_medicine01_caster:RemoveOnDeath() 	return false end

function modifier_ability_thdots_medicine00_talent:RemoveOnDeath() return false end
function modifier_ability_thdots_medicine00_talent:IsHidden()  return true end 

modifier_ability_thdots_medicine0_talent = modifier_ability_thdots_medicine0_talent or {}  --�츳����
LinkLuaModifier("modifier_ability_thdots_medicine0_talent","scripts/vscripts/abilities/abilitymedicine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_medicine0_talent:IsHidden()       return false end
function modifier_ability_thdots_medicine0_talent:IsPurgable()     return false end
function modifier_ability_thdots_medicine0_talent:RemoveOnDeath()  return false end
function modifier_ability_thdots_medicine0_talent:IsDebuff()       return false end

modifier_ability_thdots_medicine1_talent = modifier_ability_thdots_medicine1_talent or {}   --�츳����
LinkLuaModifier("modifier_ability_thdots_medicine1_talent","scripts/vscripts/abilities/abilitymedicine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_medicine1_talent:IsHidden()       return false end
function modifier_ability_thdots_medicine1_talent:IsPurgable()     return false end
function modifier_ability_thdots_medicine1_talent:RemoveOnDeath()  return false end
function modifier_ability_thdots_medicine1_talent:IsDebuff()       return false end

modifier_ability_thdots_medicine2_talent = modifier_ability_thdots_medicine2_talent or {}   --�츳����
LinkLuaModifier("modifier_ability_thdots_medicine2_talent","scripts/vscripts/abilities/abilitymedicine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_medicine2_talent:IsHidden()       return false end
function modifier_ability_thdots_medicine2_talent:IsPurgable()     return false end
function modifier_ability_thdots_medicine2_talent:RemoveOnDeath()  return false end
function modifier_ability_thdots_medicine2_talent:IsDebuff()       return false end

ability_thdots_medicineEx = class({})
function ability_thdots_medicineEx:GetCastRange()
	local extra_radius = 0
	if self:GetCaster():HasModifier("modifier_ability_thdots_medicine0_talent") then
		extra_radius = 150
	end
	return self:GetSpecialValueFor("radius") +extra_radius
end
--[[
function ability_thdots_medicineEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_medicineEx_caster"
end
]]

function ability_thdots_medicineEx:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_thdots_medicineEx_caster",{duration = duration})
end
modifier_ability_thdots_medicineEx_caster = {}
LinkLuaModifier("modifier_ability_thdots_medicineEx_caster","scripts/vscripts/abilities/abilitymedicine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_medicineEx_caster:IsHidden() 		return false end
function modifier_ability_thdots_medicineEx_caster:IsPurgable()		return false end
function modifier_ability_thdots_medicineEx_caster:RemoveOnDeath() 	return false end
function modifier_ability_thdots_medicineEx_caster:IsDebuff()		return false end

function modifier_ability_thdots_medicineEx_caster:GetAuraRadius() return self:GetAbility():GetCastRange() end -- global
function modifier_ability_thdots_medicineEx_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_medicineEx_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_medicineEx_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_ability_thdots_medicineEx_caster:GetModifierAura() return "modifier_ability_thdots_medicineEx_target" end
function modifier_ability_thdots_medicineEx_caster:IsAura() return true end
function modifier_ability_thdots_medicineEx_caster:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	--��Ч
	self.parent:EmitSound("Voice_Thdots_Miyako.Abilitymiyako01_Loop")
	local particle_name_1 = "particles/heroes/medicine/medicine_ex4.vpcf"
	self:StartIntervalThink(FrameTime())
	self.medicineEx_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	--ParticleManager:SetParticleControlEnt(self.medicineEx_particle, 0, self.parent, PATTACH_ROOTBONE_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(self.medicineEx_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.medicineEx_particle, 1, Vector(self.ability:GetCastRange(),0,0))
end
function modifier_ability_thdots_medicineEx_caster:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_medicine_0")~=0 and not caster:HasModifier("modifier_ability_thdots_medicine0_talent") then
		caster:AddNewModifier(caster,ability,"modifier_ability_thdots_medicine0_talent",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_medicine_1")~=0 and not caster:HasModifier("modifier_ability_thdots_medicine1_talent")then
		caster:AddNewModifier(caster,ability,"modifier_ability_thdots_medicine1_talent",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_medicine_2")~=0 and not caster:HasModifier("modifier_ability_thdots_medicine2_talent")then
		caster:AddNewModifier(caster,ability,"modifier_ability_thdots_medicine2_talent",{})
	end
end

function modifier_ability_thdots_medicineEx_caster:OnDestroy()
	if not IsServer() then return end
	--ɾ����Ч
	self.parent:StopSound("Voice_Thdots_Miyako.AbilityMiyako01_Loop")
	ParticleManager:DestroyParticle(self.medicineEx_particle, false)
end
modifier_ability_thdots_medicineEx_target = {}
LinkLuaModifier("modifier_ability_thdots_medicineEx_target","scripts/vscripts/abilities/abilitymedicine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_medicineEx_target:IsHidden() 		return false end
function modifier_ability_thdots_medicineEx_target:IsPurgable()		return false end
function modifier_ability_thdots_medicineEx_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_medicineEx_target:IsDebuff()		return true end

function modifier_ability_thdots_medicineEx_target:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	local extra = 0
	if self:GetCaster():HasModifier("modifier_ability_thdots_medicine1_talent") then
		extra = 20
	end
	self.slow = -(self:GetAbility():GetSpecialValueFor("slow_amount")+extra)* (1 - self:GetParent():GetStatusResistance())
	self:StartIntervalThink(FrameTime())
	self.particle = ParticleManager:CreateParticle("particles/thd2/heroes/medicine/medicineex_target.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end

function modifier_ability_thdots_medicineEx_target:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle, false)
end

function modifier_ability_thdots_medicineEx_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
    }
    return funcs
end
function modifier_ability_thdots_medicineEx_target:GetModifierMoveSpeedBonus_Percentage()
    --if not IsServer() then return end
	local slow = self.slow
    return slow
end
function modifier_ability_thdots_medicineEx_target:GetModifierMagicalResistanceDecrepifyUnique()
    --if not IsServer() then return end
	local extra = 0
	if self:GetCaster():HasModifier("modifier_ability_thdots_medicine1_talent") then
		extra = 20
	end
    return -(self:GetAbility():GetSpecialValueFor("resistance_decrepify")+extra)
end

function ability_thdots_medicine01:GetIntrinsicModifierName()
	return "modifier_ability_thdots_medicine01_caster"
end
function ability_thdots_medicine01:GetCastRange()
	if self:GetCaster():HasModifier("modifier_special_bonus_cast_range") then
		return 850
	else
		return 700
	end
end
function ability_thdots_medicine01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local castrange = self:GetCastRange()
	if is_spell_blocked(target,caster) then return end
	caster:EmitSound("Hero_Viper.poisonAttack.Cast")
	--THDReduceCooldown(ability,FindTelentValue(caster,"special_bonus_unique_meepo_4"))
	-- if target:TriggerSpellAbsorb(ability) then return end
	info = {
				EffectName = "particles/econ/items/viper/viper_ti7_immortal/viper_poison_attack_ti7.vpcf",
				Ability = ability,
				iMoveSpeed = 1000,
				Source = caster,
				Target = target,
				bProvidesVision	= true,
				iVisionRadius = 300,
				bReplaceExisting 	= false,
				flExpireTime 		= GameRules:GetGameTime() + 10,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
	ProjectileManager:CreateTrackingProjectile(info)
end
function ability_thdots_medicine01:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget ~= nil and hTarget:IsAlive() then
		caster:EmitSound("Hero_Viper.PoisonAttack.Target")
		local mods = hTarget:FindAllModifiers()
		for _,m in pairs(mods) do
			if string.find(m:GetName(), "medicine") then
				UtilStun:UnitStunTarget(caster,hTarget,self:GetSpecialValueFor("stun_time"))
				break
			end
		end
		local modifier = hTarget:AddNewModifier(caster, self, "modifier_ability_thdots_medicine01_debuff",{duration = self:GetSpecialValueFor("duration")* (1 - hTarget:GetStatusResistance())})
	end
end
function modifier_ability_thdots_medicine01_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end
function modifier_ability_thdots_medicine01_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_ability_thdots_medicine01_debuff:GetModifierMoveSpeedBonus_Percentage()
    --if not IsServer() then return end
    return -self:GetAbility():GetSpecialValueFor("slow_amount")
end
function modifier_ability_thdots_medicine01_debuff:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self:StartIntervalThink(0.5)
end
function modifier_ability_thdots_medicine01_debuff:OnIntervalThink()
	if not IsServer() then return end
	local damage = self.ability:GetSpecialValueFor("damage") / 2
	if self:GetCaster():HasModifier("modifier_ability_thdots_medicine2_talent") then
		damage = damage + self.parent:GetHealth() * 0.1 / 2
	end
	local damageTable = {
		attacker = self.caster,
		ability = self.ability,
		victim = self.parent,
		damage = damage,
		damage_type = self.ability:GetAbilityDamageType(),
		damage_flags = 0
	}
	UnitDamageTarget(damageTable)
	self.caster:Heal(damage/2, self.caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.caster, damage/2, nil)
end
function modifier_ability_thdots_medicine01_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_ability_thdots_medicine01_caster:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	local mods = keys.target:FindAllModifiers()
	local ability = self:GetAbility()
	for _,m in pairs(mods) do
		if string.find(m:GetName(), "medicine") then
			local new_cooldown = ability:GetCooldownTimeRemaining()-self:GetAbility():GetSpecialValueFor("cooldown_decrease")
			ability:EndCooldown()
			if new_cooldown > 0 then
				ability:StartCooldown(new_cooldown)
			end
			return
		end
	end
end

--[[function ability_thdots_medicine00:GetBehavior()
	if GetMapName() == "dota" then
		return self.BaseClass.GetBehavior(self)
	end
	if self:GetCaster():HasModifier("modifier_ability_thdots_medicine00_talent") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return self.BaseClass.GetBehavior(self)
	end
end
function ability_thdots_medicine00:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local castrange = 700
	caster:EmitSound("Hero_Viper.poisonAttack.Cast")
	if caster:HasModifier("modifier_special_bonus_cast_range") then
		castrange = castrange + 150
	end
	local flag = caster:FindAbilityByName("special_bonus_unique_meepo_3"):GetLevel()
	if flag ~= 0 and caster:HasModifier("modifier_ability_thdots_medicine00_talent") == false then 
		local modifier = caster:AddNewModifier(caster, ability, "modifier_ability_thdots_medicine00_talent",{})
	end
	THDReduceCooldown(ability,FindTelentValue(caster,"special_bonus_unique_meepo_4"))
	if FindTelentValue(caster,"special_bonus_unique_meepo_3") ~= 0 then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil,castrange, ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
		-- print(#targets)
		for _,v in pairs(targets) do
			info = {
				EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
				Ability = ability,
				iMoveSpeed = 1200,
				Source = caster,
				Target = v,
				bProvidesVision	= true,
				iVisionRadius = 300,
				bReplaceExisting 	= false,
				flExpireTime 		= GameRules:GetGameTime() + 10,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
			ProjectileManager:CreateTrackingProjectile(info)
		end
	else
		-- if target:TriggerSpellAbsorb(ability) then return end
		info = {
					EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
					Ability = ability,
					iMoveSpeed = 1200,
					Source = caster,
					Target = target,
					bProvidesVision	= true,
					iVisionRadius = 300,
					bReplaceExisting 	= false,
					flExpireTime 		= GameRules:GetGameTime() + 10,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end
function ability_thdots_medicine00:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget ~= nil and hTarget:IsAlive() then
		local medicine00_modifier = hTarget:AddNewModifier(caster, self, "modifier_ability_thdots_medicine00_debuff",{duration = self:GetSpecialValueFor("duration")})
	end
	caster:EmitSound("Hero_Viper.PoisonAttack.Target")
end

function modifier_ability_thdots_medicine00_debuff:IsDebuff() return true end
function modifier_ability_thdots_medicine00_debuff:IsPurgable()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return false
	else
		return true
	end
end

function modifier_ability_thdots_medicine00_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

function modifier_ability_thdots_medicine00_debuff:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self:SetStackCount(1)
	self:StartIntervalThink(0.5)
end

function modifier_ability_thdots_medicine00_debuff:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_ability_thdots_medicine00_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_ability_thdots_medicine00_debuff:GetModifierMagicalResistanceDecrepifyUnique()
	return self.ability:GetSpecialValueFor("decrease_mgical_resistance") * self:GetStackCount()
end

function modifier_ability_thdots_medicine00_debuff:GetModifierPhysicalArmorBonus()
	return self.ability:GetSpecialValueFor("decrease_armor") * self:GetStackCount()
end

function modifier_ability_thdots_medicine00_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ability:GetSpecialValueFor("base_slow_movement") + self.ability:GetSpecialValueFor("slow_movement") * (self:GetStackCount() - 1 )
end

function modifier_ability_thdots_medicine00_debuff:OnIntervalThink()
	if not IsServer() then return end
	local damage = self.ability:GetSpecialValueFor("damage") / 2
	local damageTable = {
		attacker = self.caster,
		ability = self.ability,
		victim = self.parent,
		damage = damage,
		damage_type = self.ability:GetAbilityDamageType(),
		damage_flags = 0
	}
	UnitDamageTarget(damageTable)
end--]]

--[[function OnMedicine01Spellbegining(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local castrange = keys.AbilityCastRange
	if caster:HasModifier("modifier_special_bonus_cast_range") then
		castrange = castrange + 150
	end
	print(castrange)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_meepo_4"))
	if FindTelentValue(caster,"special_bonus_unique_meepo_3") ~= 0 then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil,castrange, ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
		for _,v in pairs(targets) do
			if v ~= target then 
			info = {
				EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
				Ability = keys.ability,
				iMoveSpeed = 1200,
				Source = caster,
				Target = v,
				bProvidesVision	= true,
				iVisionRadius = 300,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
			ProjectileManager:CreateTrackingProjectile(info)
		 	end
		end
	end
end


function OnMedicine01SpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local stackcount = 1	
	local deal_duration = keys.Duration
	if caster:HasModifier("modifier_item_wanbaochui") then
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_debuff_wanbaochui", {duration = deal_duration})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_move_debuff_wanbaochui", {duration = deal_duration})
		stackcount = target:GetModifierStackCount("modifier_medicine01_debuff_wanbaochui", caster)
		stackcount = stackcount + 1 
		target:SetModifierStackCount("modifier_medicine01_debuff_wanbaochui", keys.ability, stackcount)
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_debuff", {duration = deal_duration})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_move_debuff", {duration = deal_duration})
		stackcount = target:GetModifierStackCount("modifier_medicine01_debuff", caster)
		stackcount = stackcount + 1 
		target:SetModifierStackCount("modifier_medicine01_debuff", keys.ability, stackcount)
	end
end

function OnMedicine01SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	local targetLoc = target:GetAbsOrigin()
	local deal_damage = keys.Damage/2
	local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = deal_damage,
			damage_type = keys.ability:GetAbilityDamageType(),
	    	damage_flags = 0
	}
	UnitDamageTarget(damage_table)
	if caster:HasModifier("modifier_item_wanbaochui") then
		local RandomNumber = RandomInt(1,100)
		if RandomNumber<9 then
			local targets = FindUnitsInRadius(
			   		caster:GetTeam(),		--caster team
						targetLoc,		--find position
			   		nil,					--find entity
			   		400,		--find radius
			   		DOTA_UNIT_TARGET_TEAM_ENEMY,
			   		keys.ability:GetAbilityTargetType(),
			   		0, 
			   		FIND_CLOSEST,
			   		false
				)
			for _,v in pairs(targets) do
				if v~=target then
					local stackcount = 0
					local deal_duration = keys.Duration
					if caster:HasModifier("modifier_item_wanbaochui") then
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_debuff_wanbaochui", {duration = deal_duration})
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_move_debuff_wanbaochui", {duration = deal_duration})
						stackcount = v:GetModifierStackCount("modifier_medicine01_debuff_wanbaochui", caster)
						stackcount = stackcount + 1 + FindTelentValue(caster,"special_bonus_unique_meepo_3")
						v:SetModifierStackCount("modifier_medicine01_debuff_wanbaochui", keys.ability, stackcount)
					else
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_debuff", {duration = deal_duration})
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_move_debuff", {duration = deal_duration})
						stackcount = v:GetModifierStackCount("modifier_medicine01_debuff", caster)
						stackcount = stackcount + 1 + FindTelentValue(caster,"special_bonus_unique_meepo_3")
						v:SetModifierStackCount("modifier_medicine01_debuff", keys.ability, stackcount)
					end
				end
			end
		end
	end							

end--]]

function OnMedicine02SpellStart(keys)
	local caster = keys.caster
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/medicine/medicine02.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local Damage = keys.Damage+FindTelentValue(caster,"special_bonus_unique_medicine_3")
		ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
		local unit = CreateUnitByName(
			"npc_dota_unit_medicine02"
			,keys.target_points[1]
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
	unit:SetMaxHealth(keys.ability:GetSpecialValueFor("doll_hp"))
	unit:SetHealth(keys.ability:GetSpecialValueFor("doll_hp"))
	local time =0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnMedicine02Think"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if unit ~=nil and unit:IsNull() == false then
				if not unit:IsAlive() then
					ParticleManager:DestroyParticle(effectIndex,false)
					return nil
				end
			end
			if time<keys.Duration then
				time=time+0.5
				local targets = FindUnitsInRadius(
			   		caster:GetTeam(),		--caster team
			  		keys.target_points[1],		--find position
			   		nil,					--find entity
			   		keys.Radius,		--find radius
			   		DOTA_UNIT_TARGET_TEAM_ENEMY,
			   		keys.ability:GetAbilityTargetType(),
			   		0, 
			   		FIND_CLOSEST,
			   		false
		    	)

				for _,v in pairs(targets) do
					local damage_table = {
							ability = keys.ability,
						    victim = v,
						    attacker = caster,
						    damage = Damage/2,
						    damage_type = keys.ability:GetAbilityDamageType(), 
				    	    damage_flags = 0
					}					
					UnitDamageTarget(damage_table)					
				end
				--[[if FindTelentValue(caster,"special_bonus_unique_medicine_1") ~= 0 then
					targets = FindUnitsInRadius(
				   		caster:GetTeam(),		--caster team
				  		keys.target_points[1],		--find position
				   		nil,					--find entity
				   		keys.Radius,		--find radius
				   		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				   		DOTA_UNIT_TARGET_HERO,
				   		0, 
				   		FIND_CLOSEST,
				   		false
			    	)
			    	for _,v in pairs(targets) do
						if v == caster then
							v:Heal(Damage/2, caster)
							SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,v,Damage/2,nil)
						end
					end
				end]]
			else
				if unit ~=nil and unit:IsNull() == false then 
					ParticleManager:DestroyParticle(effectIndex,false)
					unit:ForceKill(false)
				end
				return nil
			end
			return 0.5
		end,
	0)
end
function OnMedicine03Created(keys)
	if not keys.target:HasModifier("modifier_ability_thdots_medicineEx_caster") then
		local mod = keys.target:AddNewModifier(keys.caster,keys.caster:FindAbilityByName("ability_thdots_medicineEx"),"modifier_ability_thdots_medicineEx_caster",{duration = 5})
	end
	if FindTelentValue(keys.caster,"special_bonus_unique_medicine_4")~=0 then
	    local call_enemy=FindUnitsInRadius(
         keys.caster:GetTeam(),
         keys.target:GetAbsOrigin(),
         nil,
         450, 
         DOTA_UNIT_TARGET_TEAM_ENEMY,
         DOTA_UNIT_TARGET_ALL,
         DOTA_UNIT_TARGET_FLAG_NONE,
         FIND_ANY_ORDER,
         false
		)
		for _,unit in pairs(call_enemy) do
         unit:AddNewModifier(keys.target,keys.ability,"modifier_ability_thdots_medicine_taunt",{duration=1.6})
		end
	end
end
modifier_ability_thdots_medicine_taunt=class({})
LinkLuaModifier("modifier_ability_thdots_medicine_taunt","scripts/vscripts/abilities/abilitymedicine.lua",LUA_MODIFIER_MOTION_NONE)
--modifier �����ж�
function modifier_ability_thdots_medicine_taunt:IsHidden()        return false end
function modifier_ability_thdots_medicine_taunt:IsPurgable()      return true end
function modifier_ability_thdots_medicine_taunt:RemoveOnDeath()   return true end
function modifier_ability_thdots_medicine_taunt:IsDebuff()        return true end


function modifier_ability_thdots_medicine_taunt:OnCreated()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local enemy=self:GetParent()
    enemy:AddNewModifier(caster,self:GetAbility(),"modifier_axe_berserkers_call",{duration=1.6})
end

function modifier_ability_thdots_medicine_taunt:OnDestroy()
    if not IsServer() then return end
    local enemy=self:GetParent()
    enemy:RemoveModifierByName("modifier_axe_berserkers_call")
end
function OnMedicine03Attacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	if (Attacker:IsBuilding()==false) then
		local damage_to_deal = 0
		if (Attacker:IsHero()) then
			local MaxAttribute = max(max(Attacker:GetStrength(),Attacker:GetAgility()),Attacker:GetIntellect())
			damage_to_deal = keys.PoisonDamageBase + MaxAttribute * keys.PoisonDamageFactor
		end
		damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
		if (damage_to_deal>0) then
			local damage_table = {
				ability = keys.ability,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
			UnitDamageTarget(damage_table)
		end
	end
end

function OnMedicine03TakeDamage(keys)
	local Caster = keys.caster
	local unit = keys.unit
	local Attacker = keys.attacker
	if Attacker == nil then return end
	if Attacker:IsNull() then return end
	--local damage_to_deal = keys.TakenDamage * (keys.BackDamage + FindTelentValue(Caster,"special_bonus_unique_medicine_3"))*0.01
	local damage_to_deal = keys.TakenDamage * keys.BackDamage*0.01
	-- if (Attacker:IsBuilding()==false) and Attacker ~= unit and Attacker:HasModifier("modifier_item_frock_OnTakeDamage") == false then
	if (Attacker:IsBuilding()==false) and Attacker ~= unit and not IsTHDReflect(Attacker) then
		if (damage_to_deal>0 and damage_to_deal<=unit:GetMaxHealth()) then
			local damage_table = {
				ability = keys.ability,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
			UnitDamageTarget(damage_table)
		end
	end
end

function OnMedicine04SpellStart(keys)
	local target = keys.target
	local caster = keys.caster
	--THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_medicine_4"))
	if target:HasModifier("modifier_ability_thdots_flandrev2_naotan") then return end
	if caster:HasModifier("modifier_item_wanbaochui") then 
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_delay", {})
		return
	end
	if is_spell_blocked(target) then return end
	if target:HasModifier("modifier_item_dragon_star_buff") then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_debuff", {})
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_damage", {})
end
function OnMedicine04DelayEnd(keys)
	local target = keys.target
	local caster = keys.caster
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_debuff", {})
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_damage", {})
end

function OnMedicine04Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local ability = keys.ability
	caster.medicine04caster = caster
	caster.medicine04target = target
	target.Team = target:GetTeam()
	target:SetTeam(caster:GetTeam())
	target:MoveToPosition(target:GetOrigin())
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_think", {})
end

function OnMedicine04Think(keys)
	local target = keys.target
	AddFOWViewer( target.Team, target:GetOrigin(), 1000, 0.1, false)
	local targets = FindUnitsInRadius(
				target.Team,	
				target:GetOrigin(),	
				nil,
				1200,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO,
				0, 
				FIND_CLOSEST,
				false
			)
	if targets[1] == nil then
		targets = FindUnitsInRadius(
				target.Team,	
				target:GetOrigin(),	
				nil,
				1200,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_BASIC,
				0, 
				FIND_CLOSEST,
				false
			)
	end
	for i=1,#targets do 
		if targets[i]~=nil and targets[i]:IsInvisible()==false and targets[i]:GetUnitName()~="npc_reimu_04_dummy_unit" and targets[i]:GetUnitName()~="ability_yuuka_flower" and targets[i]:GetUnitName()~="npc_dota_watch_tower" then
			target:MoveToTargetToAttack(targets[i])
			break
		end
	end
end

function OnMedicine04End(keys)
	local target = keys.target
	local caster = keys.caster
	target:SetTeam(target.Team)
	target:MoveToPosition(target:GetOrigin())
end

function OnTargetDealDamage(keys)
	local caster = keys.caster
	if keys.unit:GetHealth()==0 then
		keys.unit:SetHealth(1)
		keys.unit:Kill( keys.ability, caster.medicine04caster)
	end	
end

function OnTargetTakeDamage(keys)
	local caster = keys.caster
	local target = caster.medicine04target
	local Attacker = keys.attacker
	if Attacker:IsBuilding() then
		if target:HasModifier("modifier_fountain_fury_swipes_damage_increase") then
			target:SetHealth(target:GetHealth() + keys.DamageTaken + 1)
		else
			target:SetHealth(target:GetHealth() + keys.DamageTaken * keys.ability:GetSpecialValueFor("physical_block") / 100 + 1)
		end
	end
	
	if (target.medicine04lock == nil) then
		target.medicine04lock = false
	end

	if (target.medicine04lock == true) then
		return
	end

	target.medicine04lock = true
	if target:GetHealth()==0 then
		target:SetHealth(1)
		target:RemoveModifierByName("modifier_thdots_medicine04_debuff")
		target:Kill(keys.ability, caster.medicine04caster)
	end	
	target.medicine04lock = false
end

