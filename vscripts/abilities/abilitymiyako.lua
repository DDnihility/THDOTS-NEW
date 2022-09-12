--------------------------------------------------------
--「借由欲望的恢复」
--------------------------------------------------------
ability_thdots_miyakoEx = {}

function ability_thdots_miyakoEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_miyakoEx_passive"
end

function ability_thdots_miyakoEx:OnSpellStart()
	if not IsServer() then return end
	-- self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_miyakoEx_passive", {duration = 10})
	local caster = self:GetCaster()
	local dummy = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local ability_dummy_unit = dummy:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	
	dummy:AddAbility("phoenix_supernova") 
	local darkness = dummy:FindAbilityByName("phoenix_supernova")
	darkness:SetLevel(3)
	dummy:CastAbilityImmediately(darkness, caster:GetPlayerOwnerID())
	dummy:RemoveSelf()
end

modifier_ability_thdots_miyakoEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_miyakoEx_passive","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyakoEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_miyakoEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_miyakoEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyakoEx_passive:IsDebuff()		return false end
function modifier_ability_thdots_miyakoEx_passive:OnCreated()
	self:SetStackCount(1)
end

function modifier_ability_thdots_miyakoEx_passive:DeclareFunctions()	
	return {
		--这一行是增加技能治疗量
		-- MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

-- function modifier_ability_thdots_miyakoEx_passive:GetModifierHealAmplify_PercentageTarget()
-- 	if self:GetStackCount() == 1 then
-- 		return self:GetAbility():GetSpecialValueFor("day_regen")
-- 	else
-- 		return self:GetAbility():GetSpecialValueFor("unday_regen")
-- 	end
-- end

function modifier_ability_thdots_miyakoEx_passive:GetModifierHPRegenAmplify_Percentage()
	if self:GetStackCount() == 1 then
		return self:GetAbility():GetSpecialValueFor("day_regen")
	else
		return self:GetAbility():GetSpecialValueFor("unday_regen")
	end
end

function modifier_ability_thdots_miyakoEx_passive:OnTooltip()
	if self:GetStackCount() == 1 then
		return self:GetAbility():GetSpecialValueFor("day_regen")
	else
		return self:GetAbility():GetSpecialValueFor("unday_regen")
	end
end


function modifier_ability_thdots_miyakoEx_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_ability_thdots_miyakoEx_passive:OnIntervalThink()
	if not IsServer() then return end
	if GameRules:IsDaytime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_3") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_3") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_miyakoEx_telent_3",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_3"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_2") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_2") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_miyakoEx_telent_2",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_2"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_6") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_6") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_miyakoEx_telent_6",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_6"))
	end
end

modifier_ability_thdots_miyakoEx_telent_3 = modifier_ability_thdots_miyakoEx_telent_3 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_miyakoEx_telent_3","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyakoEx_telent_3:IsHidden() 		return true end
function modifier_ability_thdots_miyakoEx_telent_3:IsPurgable()		return false end
function modifier_ability_thdots_miyakoEx_telent_3:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyakoEx_telent_3:IsDebuff()		return false end

modifier_ability_thdots_miyakoEx_telent_2 = modifier_ability_thdots_miyakoEx_telent_2 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_miyakoEx_telent_2","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyakoEx_telent_2:IsHidden() 		return true end
function modifier_ability_thdots_miyakoEx_telent_2:IsPurgable()		return false end
function modifier_ability_thdots_miyakoEx_telent_2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyakoEx_telent_2:IsDebuff()		return false end

modifier_ability_thdots_miyakoEx_telent_6 = modifier_ability_thdots_miyakoEx_telent_6 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_miyakoEx_telent_6","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyakoEx_telent_6:IsHidden() 		return true end
function modifier_ability_thdots_miyakoEx_telent_6:IsPurgable()		return false end
function modifier_ability_thdots_miyakoEx_telent_6:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyakoEx_telent_6:IsDebuff()		return false end


--------------------------------------------------------
--欲符「稼欲灵招来」
--------------------------------------------------------
ability_thdots_miyako01 = {}

function ability_thdots_miyako01:GetCastRange()
	if self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_6") then
		return self:GetSpecialValueFor("radius") + 200
	else
		return self:GetSpecialValueFor("radius")
	end
end

function ability_thdots_miyako01:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()

	if self:GetToggleState() then
		EmitSoundOn("Hero_Wisp.Overcharge", caster)
		caster:AddNewModifier( caster, self, "modifier_ability_thdots_miyako01_caster", {})
	else
		caster:StopSound("Hero_Wisp.Overcharge")
		caster:RemoveModifierByName("modifier_ability_thdots_miyako01_caster")
		self:StartCooldown(self:GetCooldown(self:GetLevel() - 1))
	end

end


modifier_ability_thdots_miyako01_caster = {}
LinkLuaModifier("modifier_ability_thdots_miyako01_caster","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako01_caster:IsHidden() 		return false end
function modifier_ability_thdots_miyako01_caster:IsPurgable()		return false end
function modifier_ability_thdots_miyako01_caster:RemoveOnDeath() 	return true end
function modifier_ability_thdots_miyako01_caster:IsDebuff()		return false end

function modifier_ability_thdots_miyako01_caster:GetAuraRadius() return self.radius end -- global
function modifier_ability_thdots_miyako01_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_miyako01_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_miyako01_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_thdots_miyako01_caster:GetModifierAura() return "modifier_ability_thdots_miyako01_target" end
function modifier_ability_thdots_miyako01_caster:IsAura() return true end

function modifier_ability_thdots_miyako01_caster:OnCreated()
	
	self.radius = self:GetAbility():GetCastRange()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self:StartIntervalThink(FrameTime())
	--特效
	self.caster:EmitSound("Voice_Thdots_Miyako.AbilityMiyako01_Loop")
	local particle_name_1 = "particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon_magic.vpcf"
	
	self.miyako01_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.miyako01_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako01_particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
end

function modifier_ability_thdots_miyako01_caster:OnDestroy()
	if not IsServer() then return end
	--删除特效
	self.caster:StopSound("Voice_Thdots_Miyako.AbilityMiyako01_Loop")
	ParticleManager:DestroyParticle(self.miyako01_particle, false)
end

function modifier_ability_thdots_miyako01_caster:OnIntervalThink()
	if not IsServer() then return end
	local lost_mana = self.caster:GetMaxMana() * 0.03
	if self.caster:GetMana() < lost_mana * FrameTime() then
		local miyako01 = self.caster:FindAbilityByName("ability_thdots_miyako01")
		if miyako01 ~= nil then
			miyako01:ToggleAbility()
		end
	end
	self.caster:SetMana(self.caster:GetMana() - lost_mana * FrameTime())
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,99999,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
	--计算周围有效非幻象单位
	local count = 0
	for _,target in pairs(targets) do
		if target:IsRealHero() and target:HasModifier("modifier_ability_thdots_miyako01_target") then
			count = count + 1
		end
	end
	self:SetStackCount(count)
end

modifier_ability_thdots_miyako01_target = {}
LinkLuaModifier("modifier_ability_thdots_miyako01_target","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako01_target:IsHidden() 		return false end
function modifier_ability_thdots_miyako01_target:IsPurgable()		return false end
function modifier_ability_thdots_miyako01_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_miyako01_target:IsDebuff()		return true end

function modifier_ability_thdots_miyako01_target:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.lost_mana = self.ability:GetSpecialValueFor("lost_mana")
	self.spend_mana = self.ability:GetSpecialValueFor("spend_mana")
	self:StartIntervalThink(1)
end

function modifier_ability_thdots_miyako01_target:OnDestroy()
	if not IsServer() then return end
	--删除特效
end

function modifier_ability_thdots_miyako01_target:OnIntervalThink()
	if not IsServer() then return end
	--天赋额外流失魔法值
	local lost_mana = self.lost_mana
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_5") ~= 0 then
		local ex_lost_mana = self.parent:GetMana() * FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_5") / 100
		lost_mana = self.lost_mana + ex_lost_mana
		print(lost_mana)
	end
	--若魔法值不够则return
	if self.caster:GetMana() < self.spend_mana or not self.caster:HasModifier("modifier_ability_thdots_miyako01_caster") then return end

	--若敌方魔法值不够则只治疗剩余的魔法值，但是芳香消耗的魔法还是一样
	if self.parent:GetMana() < lost_mana then
		lost_mana = self.parent:GetMana()
	end
	if self.parent:IsRealHero() then

		--特效使用莱恩的短暂抽蓝
		local particle_name_1 = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
	
		local miyako01_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.parent)
		ParticleManager:SetParticleControlEnt(miyako01_particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(miyako01_particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
		self.parent:SetContextThink("miyako01_particle",function ()
			ParticleManager:DestroyParticle(miyako01_particle, false)
		end, 0.2)

		local mana = self.parent:GetMana()
		local caster_mana = self.caster:GetMana()
		self.parent:SetMana(mana - lost_mana)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self.caster,lost_mana,nil)
		self.caster:Heal(lost_mana,self.caster)
		self.caster:SetMana(caster_mana - self.spend_mana)
		self.caster:EmitSound("Voice_Thdots_Miyako.AbilityMiyako01_Heal")
	end

end

--------------------------------------------------------
--欲灵「贪分欲吞噬者」
--------------------------------------------------------
ability_thdots_miyako02 = {}

function ability_thdots_miyako02:GetIntrinsicModifierName()
	return "modifier_ability_thdots_miyako02_caster"
end

function ability_thdots_miyako02:GetCastRange()
	if self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_3") then
		return self:GetSpecialValueFor("radius") + 1250
	else
		return self:GetSpecialValueFor("radius")
	end
end


modifier_ability_thdots_miyako02_caster = {}
LinkLuaModifier("modifier_ability_thdots_miyako02_caster","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako02_caster:IsHidden() 		return false end
function modifier_ability_thdots_miyako02_caster:IsPurgable()		return false end
function modifier_ability_thdots_miyako02_caster:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyako02_caster:IsDebuff()		return false end

function modifier_ability_thdots_miyako02_caster:GetAuraRadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_3") then
		return self.radius + 1250
	else
		return self.radius
	end
end

function modifier_ability_thdots_miyako02_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_miyako02_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_miyako02_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_thdots_miyako02_caster:GetModifierAura() return "modifier_ability_thdots_miyako02_target" end
function modifier_ability_thdots_miyako02_caster:IsAura() return true end

function modifier_ability_thdots_miyako02_caster:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_bloodseeker_thirst", {})
	self:GetAbility().miyako02_count = {}
	self:StartIntervalThink(FrameTime())
	self.miyako02_particle = nil
end

function modifier_ability_thdots_miyako02_caster:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	self.ability = self:GetAbility()
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,99999,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)

	--获取非幻象英雄target单位的有效层数
	local count = 0
	for _,target in pairs(targets) do
		if target:IsRealHero() and target:HasModifier("modifier_ability_thdots_miyako02_target") then
			count = count + target:FindModifierByName("modifier_ability_thdots_miyako02_target").add_bonus
		end
	end
	--设置层数，直接增加攻速和百分比移速
	self:SetStackCount(count)

	--特效
	if self:GetStackCount() > 0 then
		caster:AddNewModifier(caster, self.ability, "modifier_ability_thdots_miyako02_caster_paticle", {})
	else
		caster:RemoveModifierByName("modifier_ability_thdots_miyako02_caster_paticle")
	end
end


function modifier_ability_thdots_miyako02_caster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
end
function modifier_ability_thdots_miyako02_caster:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end

function modifier_ability_thdots_miyako02_caster:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_ability_thdots_miyako02_caster:GetModifierProvidesFOWVision()
	if self:GetCaster():HasModifier("modifier_ability_thdots_miyako02_caster_paticle") then
		return 1
	end
end

function modifier_ability_thdots_miyako02_caster:CheckState()
	if self:GetCaster():HasModifier("modifier_ability_thdots_miyako02_caster_paticle") then
		return {[MODIFIER_STATE_INVISIBLE] = false}
	end
end

--芳香特效MODIFIER，同时也是暴露视野给敌方的判定
modifier_ability_thdots_miyako02_caster_paticle = {}
LinkLuaModifier("modifier_ability_thdots_miyako02_caster_paticle","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako02_caster_paticle:IsHidden() 		return false end
function modifier_ability_thdots_miyako02_caster_paticle:IsPurgable()		return false end
function modifier_ability_thdots_miyako02_caster_paticle:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyako02_caster_paticle:IsDebuff()		return false end
function modifier_ability_thdots_miyako02_caster_paticle:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	local particle_name_1 = "particles/econ/items/lion/lion_demon_drain/lion_demon_drain_witness_ambient.vpcf"
	self.miyako02_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle, 4, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	self.miyako02_particle2 = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle2, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack2", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle2, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_attack2", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle2, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_attack2", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle2, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_attack2", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.miyako02_particle2, 4, self.caster, PATTACH_POINT_FOLLOW, "attach_attack2", self.caster:GetAbsOrigin(), true)
	self.caster:EmitSound("Voice_Thdots_Miyako.AbilityMiyako02_Active")
end

function modifier_ability_thdots_miyako02_caster_paticle:OnDestroy()
	if not IsServer() then return end
	--删除特效
	ParticleManager:DestroyParticle(self.miyako02_particle, false)
	ParticleManager:DestroyParticle(self.miyako02_particle2, false)
	self.caster:EmitSound("Voice_Thdots_Miyako.AbilityMiyako02_End")
end



--被影响的敌方单位
modifier_ability_thdots_miyako02_target = {}
LinkLuaModifier("modifier_ability_thdots_miyako02_target","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako02_target:IsHidden() 		return false end
function modifier_ability_thdots_miyako02_target:IsPurgable()		return false end
function modifier_ability_thdots_miyako02_target:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyako02_target:IsDebuff()		return true end
function modifier_ability_thdots_miyako02_target:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
end

function modifier_ability_thdots_miyako02_target:GetModifierProvidesFOWVision()
	if self:GetStackCount() > self:GetParent():GetHealthPercent() then
		return 1
	end
end

function modifier_ability_thdots_miyako02_target:CheckState()
	if self:GetStackCount() > self:GetParent():GetHealthPercent() then
		return {[MODIFIER_STATE_INVISIBLE] = false}
	end
end

function modifier_ability_thdots_miyako02_target:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.add_interval = 0.25
	self.stack_add_speed = self.ability:GetSpecialValueFor("stack_add_speed") * self.add_interval
	self.add_bonus = 0
	self:StartIntervalThink(self.add_interval)
end

function modifier_ability_thdots_miyako02_target:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local hp_percent = self.parent:GetHealthPercent()
	local stack_count = self:GetStackCount()
	stack_count = stack_count + self.stack_add_speed
	if stack_count >= 100 then
		stack_count = 100
	end
	self:SetStackCount(stack_count)
	--计算层数与百分比血量哪个多
	self.add_bonus = stack_count - hp_percent
	if self.add_bonus <= 0 then
		self.add_bonus = 0
	end
end


--------------------------------------------------------
--毒爪「剧毒杀害」
--------------------------------------------------------
ability_thdots_miyako03 = {}

function ability_thdots_miyako03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_miyako03"
end

function ability_thdots_miyako03:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ability_thdots_miyakoEx_telent_2") then
		return "touhoutd/thtd_yoshika_02"
	else
		return "touhoutd/thtd_yoshika_01"
	end
end

modifier_ability_thdots_miyako03 = {}
LinkLuaModifier("modifier_ability_thdots_miyako03","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako03:IsHidden() 		return false end
function modifier_ability_thdots_miyako03:IsPurgable()		return false end
function modifier_ability_thdots_miyako03:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyako03:IsDebuff()		return false end
function modifier_ability_thdots_miyako03:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_miyako03:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.duration = self.ability:GetSpecialValueFor("duration")
end

function modifier_ability_thdots_miyako03:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker == self.caster and not keys.target:IsBuilding() then
		-- and self.ability:GetAutoCastState() then

		local modifier = nil
		if keys.target:HasModifier("modifier_ability_thdots_miyako03_debuff") then
			modifier = keys.target:FindModifierByName("modifier_ability_thdots_miyako03_debuff")
			keys.target:FindModifierByName("modifier_ability_thdots_miyako03_debuff"):SetDuration(self.duration, true)
		else
			modifier = keys.target:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_miyako03_debuff", {duration = self.duration*(1 - keys.target:GetStatusResistance())})
		end
		modifier:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_1"))
	end
end

modifier_ability_thdots_miyako03_debuff = {}
LinkLuaModifier("modifier_ability_thdots_miyako03_debuff","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako03_debuff:IsHidden() 		return false end
function modifier_ability_thdots_miyako03_debuff:IsPurgable()		return true end
function modifier_ability_thdots_miyako03_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_miyako03_debuff:IsDebuff()		return true end
function modifier_ability_thdots_miyako03_debuff:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.radius = self.ability:GetSpecialValueFor("radius")
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.slow = -self.ability:GetSpecialValueFor("slow")
	self.percent_damage = self.ability:GetSpecialValueFor("percent_damage") / 100
	if not IsServer() then return end
    local particle_name_1 = "particles/econ/items/sand_king/sandking_ti7_arms/sandking_ti7_caustic_finale_debuff.vpcf"
	
	self.particle_debuff_fx = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.parent)
	ParticleManager:SetParticleControlEnt(self.particle_debuff_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle_debuff_fx, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end

function modifier_ability_thdots_miyako03_debuff:OnDestroy()
	if not IsServer() then return end
	--删除特效
	ParticleManager:DestroyParticle(self.particle_debuff_fx, false)
end

function modifier_ability_thdots_miyako03_debuff:OnDeath(keys)
	if not IsServer() then return end
	local target = keys.unit
	--被敌方反补不爆炸
	if target:GetTeamNumber() == keys.attacker:GetTeamNumber() and keys.attacker:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
	if target == self:GetParent() then
		local damage = self.damage
		--特效
		target:EmitSound("Voice_Thdots_Miyako.AbilityMiyako03_Death")
		local particle_name_1 = "particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf"
	
		local miyako03_debuff_exploer = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,target)
		ParticleManager:ReleaseParticleIndex(miyako03_debuff_exploer)


		--当一个拥有debuff的幻象死亡时，只会对区域内施加基础伤害，不会施加基于生命值的额外伤害
		if not target:HasModifier("modifier_illusion") then
			local max_health = self.parent:GetMaxHealth()
			damage = damage + max_health * self.percent_damage
		end

		local targets = FindUnitsInRadius(self.caster:GetTeam(), self:GetParent():GetOrigin(),nil,self.radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
		for _,victim in pairs(targets) do
			local damage_table = {
				ability = self.ability,
			    victim = victim,
			    attacker = self.caster,
			    damage = damage,
			    damage_type = self.ability:GetAbilityDamageType(), 
			}
			UnitDamageTarget(damage_table)
		end
		--天赋，爆炸治疗自己
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_2") ~= 0 then
			local distance = (target:GetOrigin() - self.caster:GetOrigin()):Length2D()
			if distance <= self.radius then
				SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self.caster,damage,nil)
				self.caster:Heal(damage,self.caster)
			end
		end
	end
end

function modifier_ability_thdots_miyako03_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_thdots_miyako03_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow - self:GetStackCount()
end

--------------------------------------------------------
--「不死杀人鬼」
--------------------------------------------------------
ability_thdots_miyako04 = {}

function ability_thdots_miyako04:GetIntrinsicModifierName()
	return "modifier_ability_thdots_miyako04_passive"
end

function ability_thdots_miyako04:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	local caster = self:GetCaster()
	local pre_damage_percent = self:GetSpecialValueFor("pre_damage_percent")
	local delay_time = self:GetSpecialValueFor("delay_time")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_miyako04_active", {duration = delay_time})
	caster:EmitSound("Voice_Thdots_Miyako.AbilityMiyako04_Cast")
end

modifier_ability_thdots_miyako04_passive = {}
LinkLuaModifier("modifier_ability_thdots_miyako04_passive","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako04_passive:IsHidden() 		return false end
function modifier_ability_thdots_miyako04_passive:IsPurgable()		return false end
function modifier_ability_thdots_miyako04_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyako04_passive:IsDebuff()		return false end
function modifier_ability_thdots_miyako04_passive:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_miyako04_passive:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	--self.killer是伤害来源
	self.killer = self.caster
	if not IsServer() then return end
	self:StartIntervalThink(1)
	--创建特效
	local particle_name_1 = "particles/units/heroes/hero_undying/undying_fg_aura_debuff.vpcf"
	
	self.particle_debuff_fx = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.particle_debuff_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
end

function modifier_ability_thdots_miyako04_passive:OnIntervalThink()
	if not IsServer() then return end
	local pre_damage_percent = self.ability:GetSpecialValueFor("pre_damage_percent") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miyako_4")
	pre_damage_percent = pre_damage_percent / 100
	--专门修复小5偷技能
	if self:GetParent():GetName() == "npc_dota_hero_rubick" then
		if self:GetParent():GetLevel() >= 6 then
			pre_damage_percent = 0.25
		end
		if self:GetParent():GetLevel() >= 12 then
			pre_damage_percent = 0.20
		end
		if self:GetParent():GetLevel() >= 18 then
			pre_damage_percent = 0.15
		end
	end
	--print(pre_damage_percent)
	local damage = self:GetStackCount() * pre_damage_percent
	--print("damage "..damage)
	local set_health = self.caster:GetHealth() - damage
	--print("set_health "..set_health)
	--若有主动BUFF则不执行伤害结算。
	if self.caster:HasModifier("modifier_ability_thdots_miyako04_active") then return end
	if self:GetStackCount() < 2 then
		self:SetStackCount(0)
		return
	end
	--若伤害比当前生命值高则直接杀死，若不高于当前生命则移除生命。 set_health = 0.5 实际生命去小数=0
	if set_health < 1 then
		self.caster:Kill(self.ability, self.killer)
		self:SetStackCount(0)
		--特效
		local particle_name_1 = "particles/units/heroes/hero_undying/undying_tower_destruction.vpcf"
	
		local miyako04_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
		ParticleManager:SetParticleControlEnt(miyako04_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(miyako04_particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(miyako04_particle)
	else
		self.caster:SetHealth(set_health)
		--self.caster:ModifyHealth(set_health, self.ability, true, 0) --bug时显示自杀
		self:SetStackCount(self:GetStackCount() - damage)
		--特效
		local particle_name_1 = "particles/units/heroes/hero_undying/undying_tower_destruct_flashbang.vpcf"
	
		local miyako04_particle_2 = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
		ParticleManager:SetParticleControlEnt(miyako04_particle_2, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(miyako04_particle_2)
	end
end

function modifier_ability_thdots_miyako04_passive:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_ability_thdots_hina01_shield") then return end
	if kv.attacker == kv.target then return end

	--将受到的伤害储存在层数里
	if kv.attacker ~= nil then
		self.killer = kv.attacker
	end
	
	--若是玩家的召唤物则攻击者改为玩家英雄，防止召唤物removeself后有BUG
	local plyid = self.killer:GetPlayerOwnerID()
	if plyid >= 0 then
	    self.killer = PlayerResource:GetPlayer(plyid):GetAssignedHero()
	end
	local cache_damage = kv.damage - 1
	self:SetStackCount(self:GetStackCount() + cache_damage)

	return kv.damage-1
end

modifier_ability_thdots_miyako04_active = {}
LinkLuaModifier("modifier_ability_thdots_miyako04_active","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako04_active:IsHidden() 		return false end
function modifier_ability_thdots_miyako04_active:IsPurgable()		return false end
function modifier_ability_thdots_miyako04_active:RemoveOnDeath() 	return false end
function modifier_ability_thdots_miyako04_active:IsDebuff()			return false end
function modifier_ability_thdots_miyako04_active:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	if not IsServer() then return end
	--创建特效
	self.particle_name_1 = "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
	self.miyako04_particle = ParticleManager:CreateParticle(self.particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.miyako04_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
end

function modifier_ability_thdots_miyako04_active:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.miyako04_particle, false)
end
--------------------------------------------------------
--僵尸「肉灵渴望」
--------------------------------------------------------
ability_thdots_miyako05 = {}

function ability_thdots_miyako05:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		-- if self:GetCaster():HasScepter() then
			self:SetHidden(false)
		else
			if self:GetCaster():HasModifier("modifier_ability_thdots_miyako05") then
				self:GetCaster():RemoveModifierByName("modifier_ability_thdots_miyako05")
			end
			self:SetHidden(true)
		end
	end
end

function ability_thdots_miyako05:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_miyako05:GetCastRange()
	return self:GetSpecialValueFor("radius")
end


function ability_thdots_miyako05:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	self.target = nil
	local radius = self:GetSpecialValueFor("radius")
	--若开启自动施法则寻找最近队友，否则寻找最近敌方，忽略幻象
	if not self:GetAutoCastState() then
		local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,0,FIND_CLOSEST,false)
		for _,target in pairs(targets) do
			if target:IsRealHero() then
				self.target = target
				break
			end
		end
	else
		local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,0,FIND_CLOSEST,false)
		for _,target in pairs(targets) do
			if target:IsRealHero() and target ~= caster then
				self.target = target
				break
			end
		end
	end
	if self.target == nil or self.target == caster then
		self.target = caster
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_miyako05_none", {duration = 0.2})
	else
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_miyako05_caster", {duration = 2})
	end
	caster:EmitSound("Voice_Thdots_Miyako.AbilityMiyako05_Cast")
	
end

--若范围内没有少女，则原地旋转一圈对周围敌人造成一次普攻
modifier_ability_thdots_miyako05_none = {}
LinkLuaModifier("modifier_ability_thdots_miyako05_none","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako05_none:IsHidden() 		return true end
function modifier_ability_thdots_miyako05_none:IsPurgable()		return false end
function modifier_ability_thdots_miyako05_none:RemoveOnDeath() 	return true end
function modifier_ability_thdots_miyako05_none:IsDebuff()		return false end
function modifier_ability_thdots_miyako05_none:OnRefresh(keys)
	if not IsServer() then return end
	self:OnCreated(keys)
end
function modifier_ability_thdots_miyako05_none:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	if self.caster:GetName() == "npc_dota_hero_undying" then
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,4)
	end
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,200,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
	for _,victim in pairs(targets) do
		victim:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_miyako05_target", {duration = 2})
	end
	--创建特效
	self.particle_name_1 = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_blade_fury_disk.vpcf"
	self.miyako05_particle = ParticleManager:CreateParticle(self.particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	-- ParticleManager:SetParticleControl(self.miyako05_particle, 5, Vector(250,1,1))
	ParticleManager:SetParticleControlEnt(self.miyako05_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
end

function modifier_ability_thdots_miyako05_none:OnDestroy()
	if not IsServer() then return end
	if self.caster:GetName() == "npc_dota_hero_undying" then
		self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	end
	ParticleManager:DestroyParticle(self.miyako05_particle, false)
end


modifier_ability_thdots_miyako05_caster = {}
LinkLuaModifier("modifier_ability_thdots_miyako05_caster","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako05_caster:IsHidden() 		return true end
function modifier_ability_thdots_miyako05_caster:IsPurgable()		return false end
function modifier_ability_thdots_miyako05_caster:RemoveOnDeath() 	return true end
function modifier_ability_thdots_miyako05_caster:IsDebuff()		return false end
function modifier_ability_thdots_miyako05_caster:OnRefresh(keys)
	if not IsServer() then return end
	self:OnCreated(keys)
end
function modifier_ability_thdots_miyako05_caster:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.target = self.ability.target
	self.point 	= self.target:GetOrigin()
	self.velocity = 40
	local distance = (self.point - self.caster:GetAbsOrigin()):Length2D()
	if distance >= 500 then
		self.velocity = self.velocity + (distance - 500)/10 
	end
	if self.caster:GetName() == "npc_dota_hero_undying" then
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,4)
	end
	self:StartIntervalThink(FrameTime())
	--创建特效
	self.particle_name_1 = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_blade_fury_disk.vpcf"
	self.miyako05_particle = ParticleManager:CreateParticle(self.particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	-- ParticleManager:SetParticleControl(self.miyako05_particle, 5, Vector(250,1,1))
	ParticleManager:SetParticleControlEnt(self.miyako05_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
end

function modifier_ability_thdots_miyako05_caster:OnIntervalThink()
	if not IsServer() then return end
	self.point 	= self.target:GetOrigin()
	local vec = (self.point - self.caster:GetAbsOrigin()):Normalized()
	--对沿途的单位造成一次普攻，以添加modifier的形式。
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,200,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
	for _,victim in pairs(targets) do
		victim:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_miyako05_target", {duration = 1})
	end
	if (self.caster:GetOrigin() - self.point):Length2D() <= 21 then
		-- FindClearSpaceForUnit(self.caster,self.caster:GetOrigin(),true)
		ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
		self:Destroy()
	else
		if (self.caster:GetOrigin() - self.point):Length2D() <= 150 then
			self.velocity = 40
		end
		self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + vec * self.velocity) 
	end
end
function modifier_ability_thdots_miyako05_caster:OnDestroy()
	if not IsServer() then return end
	if self.caster:GetName() == "npc_dota_hero_undying" then
		self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	end
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	ParticleManager:DestroyParticle(self.miyako05_particle, false)
end

modifier_ability_thdots_miyako05_target = {}
LinkLuaModifier("modifier_ability_thdots_miyako05_target","scripts/vscripts/abilities/abilitymiyako.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_miyako05_target:IsHidden() 		return true end
function modifier_ability_thdots_miyako05_target:IsPurgable()		return false end
function modifier_ability_thdots_miyako05_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_miyako05_target:IsDebuff()		return false end
function modifier_ability_thdots_miyako05_target:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target = self:GetParent()
	self.caster:PerformAttack(self.target, true, true, true, true, false, false, false)
end