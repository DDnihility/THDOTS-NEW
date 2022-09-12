--------------------------------------------------------
--迷符「半身大悟」
--------------------------------------------------------
ability_thdots_youmu2_Ex = {}

function ability_thdots_youmu2_Ex:GetIntrinsicModifierName()
	return "modifier_ability_thdots_youmu2_Ex_passive"
end

modifier_ability_thdots_youmu2_Ex_passive = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_passive","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_passive:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_passive:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_Ex_passive:IsHidden()
	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_05_passive") then
		return true
	else
		return false
	end
end
function modifier_ability_thdots_youmu2_Ex_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_ability_thdots_youmu2_Ex_passive:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("decrease_damage") + self:GetAbility():GetSpecialValueFor("decrease_damage_per_level") * self:GetCaster():GetLevel()
end
function modifier_ability_thdots_youmu2_Ex_passive:GetAuraRadius() return 99999 end -- global
function modifier_ability_thdots_youmu2_Ex_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_ability_thdots_youmu2_Ex_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_youmu2_Ex_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_ability_thdots_youmu2_Ex_passive:GetModifierAura() return "modifier_ability_thdots_youmu2_Ex_damage" end
function modifier_ability_thdots_youmu2_Ex_passive:IsAura() return true end

function modifier_ability_thdots_youmu2_Ex_passive:OnCreated()
	if not IsServer() then return end
	local youmu2_weapon = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_serrakura/jugg_serrakurra_ambient_blade_petal.vpcf", PATTACH_POINT_FOLLOW,self:GetCaster())
    ParticleManager:SetParticleControlEnt(youmu2_weapon,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_attack1",Vector(0,0,0),true)
	-- local youmu2_weapon = ParticleManager:CreateParticle("particles/econ/items/juggernaut/pw_blossom_sword/jadehoof_special_blossoms.vpcf", PATTACH_POINT_FOLLOW,self:GetCaster())
 	-- ParticleManager:SetParticleControlEnt(youmu2_weapon,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_attack1",Vector(0,0,0),true)
	self:StartIntervalThink(FrameTime())
end


function modifier_ability_thdots_youmu2_Ex_passive:OnIntervalThink()
	if not IsServer() then return end
	-- if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_2") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_1") then
	-- 	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_1",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_2"))
	-- end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_4") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_2") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_2",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_4"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_3") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_3") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_3",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_3"))
	end
	-- if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_4") then
	-- 	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_4",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_1"))
	-- end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_6") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_6") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_6",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_6"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_7") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_7") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_7",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_7"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_8") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_8") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_youmu2_Ex_telent_8",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_8"))
	end
end

modifier_ability_thdots_youmu2_Ex_telent_1 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_1","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_telent_1:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_telent_1:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_telent_1:IsDebuff()		return false end

modifier_ability_thdots_youmu2_Ex_telent_2 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_2","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_telent_2:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_telent_2:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_telent_2:IsDebuff()		return false end

modifier_ability_thdots_youmu2_Ex_telent_3 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_3","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_telent_3:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_telent_3:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_3:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_telent_3:IsDebuff()		return false end

modifier_ability_thdots_youmu2_Ex_telent_8 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_8","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_telent_8:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_telent_8:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_8:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_telent_8:IsDebuff()		return false end

modifier_ability_thdots_youmu2_Ex_telent_6 = {}  --天赋监听 + 150生命
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_6","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_telent_6:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_telent_6:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_6:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_telent_6:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_6:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end
function modifier_ability_thdots_youmu2_Ex_telent_6:GetModifierHealthBonus()
	return 150
end

modifier_ability_thdots_youmu2_Ex_telent_7 = {}  --天赋监听 + 20移速
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_7","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_telent_7:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_telent_7:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_7:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_telent_7:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_Ex_telent_7:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end
function modifier_ability_thdots_youmu2_Ex_telent_7:GetModifierMoveSpeedBonus_Constant()
	return 20
end

-- modifier_ability_thdots_youmu2_Ex_telent_8 = {}  --天赋监听 + 80攻速
-- LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_8","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_youmu2_Ex_telent_8:IsHidden() 		return true end
-- function modifier_ability_thdots_youmu2_Ex_telent_8:IsPurgable()		return false end
-- function modifier_ability_thdots_youmu2_Ex_telent_8:RemoveOnDeath() 	return false end
-- function modifier_ability_thdots_youmu2_Ex_telent_8:IsDebuff()		return false end
-- function modifier_ability_thdots_youmu2_Ex_telent_8:DeclareFunctions()
-- 	return {
-- 		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
-- 	}
-- end
-- function modifier_ability_thdots_youmu2_Ex_telent_8:GetModifierAttackSpeedBonus_Constant()
-- 	return 80
-- end

-- modifier_ability_thdots_youmu2_Ex_telent_4 = {}  --天赋监听
-- LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_telent_4","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_youmu2_Ex_telent_4:IsHidden() 		return true end
-- function modifier_ability_thdots_youmu2_Ex_telent_4:IsPurgable()		return false end
-- function modifier_ability_thdots_youmu2_Ex_telent_4:RemoveOnDeath() 	return false end
-- function modifier_ability_thdots_youmu2_Ex_telent_4:IsDebuff()		return false end
-- function modifier_ability_thdots_youmu2_Ex_telent_4:DeclareFunctions()
-- 	return {
-- 		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
-- 	}
-- end
-- function modifier_ability_thdots_youmu2_Ex_telent_4:OnAbilityFullyCast(params)
-- 	if IsServer() then
-- 		if params.unit ~= self:GetParent() or params.ability:IsItem() then return end
-- 		-- self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_youmu2_double_attack",{})
-- 	end
-- end

modifier_ability_thdots_youmu2_double_attack = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_double_attack","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_double_attack:IsHidden() return false end
function modifier_ability_thdots_youmu2_double_attack:IsDebuff() return false end
function modifier_ability_thdots_youmu2_double_attack:IsPurgable() return false end
function modifier_ability_thdots_youmu2_double_attack:RemoveOnDeath() return false end

function modifier_ability_thdots_youmu2_double_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_youmu2_double_attack:GetModifierAttackSpeedBonus_Constant()
	return 1000
end

function modifier_ability_thdots_youmu2_double_attack:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	if keys.attacker ~= caster then return end
	print("Destroy()")
	self:Destroy()
end

modifier_ability_thdots_youmu2_Ex_damage = {}  --所有伤害转化为魔法伤害
LinkLuaModifier("modifier_ability_thdots_youmu2_Ex_damage","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_Ex_damage:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_Ex_damage:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_Ex_damage:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_Ex_damage:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_Ex_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end
function modifier_ability_thdots_youmu2_Ex_damage:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local caster = self:GetCaster()
	local target = kv.target
	local ability = self:GetAbility()
	local Ex_damage_type = DAMAGE_TYPE_MAGICAL
	if kv.attacker:HasModifier("modifier_ability_thdots_youmu2_05_passive") then
		Ex_damage_type = DAMAGE_TYPE_PHYSICAL
	end
	if kv.attacker ~= caster or target:IsBuilding() then return end
	if kv.attacker:HasModifier("modifier_ability_thdots_youmu2_Ex_passive") and kv.damage_type ~= Ex_damage_type then
		local damage_table = {
					ability = ability,
				    victim = target,
				    attacker = caster,
				    damage = kv.original_damage,
				    damage_type = Ex_damage_type, 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
		return kv.damage
	else
		return
	end
end

--------------------------------------------------------
--人符「现世斩」
--------------------------------------------------------
ability_thdots_youmu2_01 = {}

function ability_thdots_youmu2_01:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

function ability_thdots_youmu2_01:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_8") then
		return self.BaseClass.GetCooldown(self, level) - 4
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end
function ability_thdots_youmu2_01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	local cast_range = self:GetSpecialValueFor("cast_range") + caster:GetCastRangeBonus()
	local damage = self:GetSpecialValueFor("damage")
	local invin_time = self:GetSpecialValueFor("invin_time")
	local distance = (self:GetCursorPosition() - caster:GetOrigin()):Length2D()
	if distance >= cast_range then
		distance = cast_range
	end
	self.point = self.caster:GetOrigin() + (self:GetCursorPosition() - self.caster:GetOrigin()):Normalized() * distance
	self.mid_point = self.caster:GetOrigin() + (self:GetCursorPosition() - self.caster:GetOrigin()):Normalized() * distance/2
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_01_invin", {duration = 0.1})

	caster:EmitSound("Hero_Antimage.Blink_out")
	local particle_name = "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf"
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	-- ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
	ParticleManager:ReleaseParticleIndex(particle)
end

modifier_ability_thdots_youmu2_01_invin = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_01_invin","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_01_invin:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_01_invin:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_01_invin:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_01_invin:IsDebuff()		return false end

function modifier_ability_thdots_youmu2_01_invin:CheckState()
	local state =
	{
		-- [MODIFIER_STATE_INVULNERABLE] 	= true,
		-- [MODIFIER_STATE_ROOTED]			= true,
		-- [MODIFIER_STATE_UNSELECTABLE]	= true,
		[MODIFIER_STATE_DISARMED]		= true,
		-- [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end
function modifier_ability_thdots_youmu2_01_invin:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.point = self:GetAbility().point
	self.mid_point = self:GetAbility().mid_point
	-- FindClearSpaceForUnit(self.caster, self.mid_point, true)
	self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
	self.caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,2)
end

function modifier_ability_thdots_youmu2_01_invin:OnDestroy()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	FindClearSpaceForUnit(self.caster, self.point, true)
	local damage_radius = self:GetAbility():GetSpecialValueFor("damage_radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage") / 2
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self:GetParent():GetOrigin(),nil,damage_radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)

	--特效
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControl(effectIndex, 5, Vector(damage_radius,damage_radius,damage_radius))
	-- ParticleManager:DestroyParticleSystemTime(effectIndex,0.1)

	self.caster:SetContextThink("youmu2_01_particle", function ()
		ParticleManager:DestroyParticle(effectIndex, false)
	end,0.1)
	--增加一次连击刀效果
	-- self.caster:SetContextThink("youmu2_01_double", function ()
	-- 	if FindTelentValue(self.caster,"special_bonus_unique_youmu2_1") ~= 0 then
	-- 		print("addddddddddddddddddddddddddddddd")
	-- 		self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_youmu2_double_attack",{})
	-- 	end
	-- end,0.3)
	-- local particle_name_1 = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold_r_stab.vpcf"
	-- local particle_name_2 = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold_stab.vpcf"
	local particle_name_1 = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold_stab_core.vpcf"
	local particle_name_2 = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold_r_stab_core.vpcf"
	for _,victim in pairs(targets) do
		local particle_1 = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,victim)
		local particle_1 = ParticleManager:CreateParticle(particle_name_1, PATTACH_WORLDORIGIN,victim)
		-- local particle_1 = ParticleManager:CreateParticle(particle_name_1, PATTACH_ABSORIGIN_FOLLOW,victim)
		ParticleManager:SetParticleControl(particle_1, 0, victim:GetOrigin())
		ParticleManager:SetParticleControl(particle_1, 1, victim:GetOrigin())
		ParticleManager:ReleaseParticleIndex(particle_1)
		victim:EmitSound("Voice_Thdots_Youmu.AbilityYoumu2_01")
		local damage_table = {
					ability = self.ability,
				    victim = victim,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		-- self.caster:PerformAttack(victim, true, true, true, true, false, false, false)
		UnitDamageTarget(damage_table)
	end
	self.caster:SetContextThink("Youmu2_01_damage", function()
		for _,victim in pairs(targets) do
			local particle_2 = ParticleManager:CreateParticle(particle_name_2, PATTACH_CUSTOMORIGIN_FOLLOW,victim)
			-- ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
			ParticleManager:SetParticleControl(particle_2, 0, victim:GetOrigin())
			ParticleManager:SetParticleControl(particle_2, 1, victim:GetOrigin())
			ParticleManager:ReleaseParticleIndex(particle_2)
			victim:EmitSound("Voice_Thdots_Youmu.AbilityYoumu2_01")
			local damage_table = {
					ability = self.ability,
				    victim = victim,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
			-- self.caster:PerformAttack(victim, true, true, true, true, false, false, false)
			UnitDamageTarget(damage_table)
		end
	end,0.1)
end


--------------------------------------------------------
--断命剑「冥想斩」
--------------------------------------------------------
ability_thdots_youmu2_02 = {}

function ability_thdots_youmu2_02:GetIntrinsicModifierName()
	return "modifier_ability_thdots_youmu2_02_passive"
end

modifier_ability_thdots_youmu2_02_passive = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_02_passive","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_02_passive:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_02_passive:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_02_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_02_passive:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_02_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_ability_thdots_youmu2_02_passive:OnCreated()
	if not IsServer() then return end
end
function modifier_ability_thdots_youmu2_02_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = keys.attacker
	local target = keys.target
	local ability = self:GetAbility()
	local damage = ability:GetSpecialValueFor("damage")
	local silence_time = ability:GetSpecialValueFor("silence_time")
	if caster ~= self:GetParent() or target:IsBuilding() or caster:GetTeamNumber() == target:GetTeamNumber() then return end
	if FindTelentValue(caster,"special_bonus_unique_youmu2_5") ~= 0 then
		damage = damage * 2
		silence_time = silence_time * 2
	end
	--print("do it")
	--print(damage)
	--print(silence_time)
	--print("232222222222222")
	if self:GetStackCount() == 1 then
		--特效
		local effectIndex4 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_explosion.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(effectIndex4, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex4, 2, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex4, 3, target:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex4,false)
		
		target:EmitSound("Voice_Thdots_Youmu.AbilityYoumu2_02")
		target:AddNewModifier(caster,ability,"modifier_ability_thdots_youmu2_02_debuff", {duration = silence_time * (1 - target:GetStatusResistance())})
		local damage_table = {
				ability = ability,
			    victim = target,
			    attacker = caster,
			    damage = damage,
			    damage_type = ability:GetAbilityDamageType(), 
			}
		UnitDamageTarget(damage_table)
		self:SetStackCount(0)
		ParticleManager:DestroyParticle(self.youmu2_weapon,true)
	else
		self:SetStackCount(1)
		self.youmu2_weapon = ParticleManager:CreateParticle("particles/econ/items/witch_doctor/wd_ti10_immortal_weapon_gold/wd_ti10_immortal_ambient_gold_glint.vpcf", PATTACH_POINT_FOLLOW,self:GetCaster())
    	ParticleManager:SetParticleControlEnt(self.youmu2_weapon,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_attack1",Vector(0,0,0),true)
	end
end


modifier_ability_thdots_youmu2_02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_02_debuff","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_youmu2_02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_02_debuff:IsDebuff()		return true end
function modifier_ability_thdots_youmu2_02_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

function ability_thdots_youmu2_02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	self.ability = self
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_02_buff", {duration = duration})
end

modifier_ability_thdots_youmu2_02_buff = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_02_buff","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_02_buff:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_02_buff:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_02_buff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_02_buff:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_02_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_youmu2_02_buff:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then return end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local caster = keys.target
	local target = keys.attacker
	local bonus_duration = self:GetAbility():GetSpecialValueFor("bonus_duration")
	if caster == self:GetCaster() and keys.attacker:IsHero() then
		-- print_r(keys)
		-- print(keys.damage_type == DAMAGE_TYPE_PHYSICAL)
		-- print(keys.inflictor)

		EmitSoundOn("Voice_Thdots_Youmu.AbilityYoumu2_04_flick",caster)	--播放声音
		local Position = caster:GetOrigin()
		local effectIndex = ParticleManager:CreateParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, Position)
		ParticleManager:SetParticleControl(effectIndex, 1, Position)
		ParticleManager:SetParticleControl(effectIndex, 2, Position)
		ParticleManager:SetParticleControl(effectIndex, 3, Position)
		ParticleManager:SetParticleControl(effectIndex, 5, Position)
		ParticleManager:SetParticleControl(effectIndex, 6, Position)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,4)

		local particle_name = "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf"
		local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW,caster)
		-- ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
		ParticleManager:ReleaseParticleIndex(particle)

		local cast_point = target:GetOrigin() - target:GetForwardVector() * 150
		FindClearSpaceForUnit(caster, cast_point, true)
		caster:SetForwardVector(target:GetForwardVector())

		self:Destroy()
		return keys.damage
	end
end
--------------------------------------------------------
--人符「现世斩」
--------------------------------------------------------
ability_thdots_youmu2_03 = {}

function ability_thdots_youmu2_03:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

-- function ability_thdots_youmu2_03:GetCooldown(level)
-- 	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_1") then
-- 		return self.BaseClass.GetCooldown(self, level) - 10
-- 	else
-- 		return self.BaseClass.GetCooldown(self, level)
-- 	end
-- end


-- function ability_thdots_youmu2_03:GetAbilityTextureName()
-- 	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_03_release") then
-- 		return "custom/sumireko/ability_thdots_youmu2_03"
-- 	else
-- 		return "custom/sumireko/ability_thdots_youmu2_03_release"
-- 	end
-- end

function ability_thdots_youmu2_03:GetCastPoint()
	if not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_03_release") then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0.3
	end
end

function ability_thdots_youmu2_03:GetManaCost(level)
	if not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_03_release") then
		return self.BaseClass.GetManaCost(self, level)
	else
		return 0
	end
end

function ability_thdots_youmu2_03:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_03_release") then
		return self.BaseClass.GetBehavior(self)
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	end
end

function ability_thdots_youmu2_03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	self.ability = self
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local count = self:GetSpecialValueFor("count")
	local duration = self:GetSpecialValueFor("duration") + FindTelentValue(self:GetCaster(),"special_bonus_unique_youmu2_2")
	if not caster:HasModifier("modifier_ability_thdots_youmu2_03_release") then
		self.dummy = CreateUnitByName("npc_thdots_unit_youmu03_unit", 
		    	                        caster:GetOrigin(), 
										false, 
									    caster, 
										caster, 
										caster:GetTeamNumber()
										)
		FindClearSpaceForUnit(self.dummy, caster:GetOrigin(),true)
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_03_release", {duration = duration})
		self.dummy:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_03_dummy", {duration = duration})
		ResolveNPCPositions(self.caster:GetAbsOrigin(), 128)
		self:EndCooldown()
	else
		local target_point = self.dummy:GetOrigin()
		if caster.youmu2_05_wanbaochui_target ~= nil then
			target_point = caster.youmu2_05_wanbaochui_target:GetOrigin()
		end
		FindClearSpaceForUnit(caster, target_point,true)
		caster:RemoveModifierByName("modifier_ability_thdots_youmu2_03_release")
		self.dummy:RemoveSelf()

		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.caster)
		ParticleManager:SetParticleControl(effectIndex, 5, Vector(radius,radius,radius))
		-- ParticleManager:DestroyParticleSystemTime(effectIndex,0.2)

		self.caster:SetContextThink("youmu2_03_particle", function ()
			ParticleManager:DestroyParticle(effectIndex, false)
		end,0.2)
		--增加一次连击刀效果
		-- self.caster:SetContextThink("youmu2_03_double", function ()
		-- 	if FindTelentValue(self.caster,"special_bonus_unique_youmu2_1") ~= 0 then
		-- 		self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_youmu2_double_attack",{})
		-- 	end
		-- end,0.3)


		local particle_name_1 = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold_r_stab.vpcf"
		local particle_name_2 = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_gold_stab.vpcf"

		caster:EmitSound("Hero_Antimage.Blink_out")
		local particle_name = "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf"
		local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
		-- ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
		ParticleManager:ReleaseParticleIndex(particle)

		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,2)
		--造成伤害
		local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
		for _,victim in pairs(targets) do
			local particle_1 = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,victim)
			-- local particle_1 = ParticleManager:CreateParticle(particle_name_1, PATTACH_ABSORIGIN_FOLLOW,victim)
			ParticleManager:SetParticleControl(particle_1, 0, victim:GetOrigin())
			ParticleManager:SetParticleControl(particle_1, 1, victim:GetOrigin())
			ParticleManager:ReleaseParticleIndex(particle_1)
			local damage_table = {
						ability = self.ability,
					    victim = victim,
					    attacker = self.caster,
					    damage = damage,
					    damage_type = self.ability:GetAbilityDamageType(), 
						damage_flags = 0
					}
			self.caster:PerformAttack(victim, true, true, true, true, false, false, false)
			UnitDamageTarget(damage_table)
		end
		if count > 1 then
			self.caster:SetContextThink("Youmu2_03_damage", function()
				for _,victim in pairs(targets) do
					local particle_2 = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,victim)
					-- local particle_2 = ParticleManager:CreateParticle(particle_name_1, PATTACH_ABSORIGIN_FOLLOW,victim)
					ParticleManager:SetParticleControl(particle_2, 0, victim:GetOrigin())
					ParticleManager:SetParticleControl(particle_2, 1, victim:GetOrigin())
					ParticleManager:ReleaseParticleIndex(particle_2)
					local damage_table = {
							ability = self.ability,
						    victim = victim,
						    attacker = self.caster,
						    damage = damage,
						    damage_type = self.ability:GetAbilityDamageType(), 
							damage_flags = 0
						}
					self.caster:PerformAttack(victim, true, true, true, true, false, false, false)
					UnitDamageTarget(damage_table)
				end
			end,0.1)
		end
		self:StartCooldown(self:GetCooldown(self:GetLevel() - 1))
	end
end

modifier_ability_thdots_youmu2_03_release = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_03_release","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_03_release:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_03_release:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_03_release:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_03_release:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_03_release:OnDestroy()
	if not IsServer() then return end
	ability = self:GetAbility()
	ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
end
function modifier_ability_thdots_youmu2_03_release:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end
function modifier_ability_thdots_youmu2_03_release:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movement_bonus")
end

modifier_ability_thdots_youmu2_03_dummy = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_03_dummy","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_03_dummy:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_03_dummy:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_03_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_03_dummy:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_03_dummy:CheckState()
	return {
		[MODIFIER_STATE_ROOTED]					 = true,
		[MODIFIER_STATE_DISARMED]				 = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED]      = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]       = true,
	}
end

function modifier_ability_thdots_youmu2_03_dummy:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveSelf()
end


--------------------------------------------------------
--空观剑「六根清净斩」
--------------------------------------------------------
ability_thdots_youmu2_04 = {}

function ability_thdots_youmu2_04:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_2") then
		return self:GetSpecialValueFor("talent_range")
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function ability_thdots_youmu2_04:GetAOERadius()
	return self:GetSpecialValueFor("damage_radius")
end

function ability_thdots_youmu2_04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if is_spell_blocked(target) then return end
	self.caster = self:GetCaster()
	self.youmu2_04target = target
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration") + FindTelentValue(self.caster,"special_bonus_unique_youmu2_1")
	local break_duration = self:GetSpecialValueFor("break_duration")
	local flick_time = self:GetSpecialValueFor("flick_time")
	local decrease_magical_armor = -self:GetSpecialValueFor("decrease_magical_armor")
	local cast_point = target:GetOrigin() - target:GetForwardVector() * 150
	local magical_armor = target:GetMagicalArmorValue() *100
	local xxxxxxxxxx = target:GetBaseMagicalResistanceValue()
	print("==================")
	print("==================")
	print(xxxxxxxxxx)
	print(magical_armor)
	print("==================")
	print("==================")
	local particle_name = "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf"
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(particle, 0, self.caster:GetOrigin())

	local target_magical_modifier = target:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_04_target", {duration = break_duration})
	target_magical_modifier:SetStackCount(decrease_magical_armor)
	if magical_armor > 0 then
	end
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_04_caster",{duration = duration})
	target:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_04_lock", {duration = duration})
	self.burstParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.burstParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.burstParticle, 1, Vector(duration, 0, 0))
	ParticleManager:DestroyParticleSystemTime(self.burstParticle,duration)
	-- ParticleManager:SetParticleControl(self.burstParticle, 2, Vector(128, 1, 1))
	FindClearSpaceForUnit(caster, cast_point, true)

	target:EmitSound("Voice_Thdots_Youmu.AbilityYoumu2_04_target")
	--动画演出
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_04_invin", {duration = 0.5})
	--设置6个点
	local num = 6
	local point = target:GetOrigin()
	local qangle = QAngle(0, 60, 0)
	local distance = 500
	local position = target:GetOrigin() + target:GetForwardVector() * distance
	self.pt = {}
	for i=1,num do
		self.pt[i] = position
		position = RotatePosition(point, qangle, position)
		local dummy = CreateUnitByName("npc_thdots_unit_youmu03_unit", 
		-- local dummy = CreateUnitByName("npc_dota_hero_antimage", 
		    	                     	position, 
										false, 
									    caster, 
										caster, 
										caster:GetTeamNumber()
										)
		dummy:StartGestureWithPlaybackRate(ACT_DOTA_RUN,4)
		dummy:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_04_dummy",{duration = 0.6})
	end
end
--dummy演出
modifier_ability_thdots_youmu2_04_dummy = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_dummy","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_dummy:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_04_dummy:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_04_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_04_dummy:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_04_dummy:OnCreated()
	if not IsServer() then return end
	self.ability = self:GetAbility()
	self.target_point = self.ability.youmu2_04target:GetOrigin()
	self.point = self:GetParent():GetOrigin()
	self.distance = (self.point - self.target_point):Length2D()
	self.move_point = RotatePosition(self.target_point, QAngle(0, 60, 0), self.point)
	self.forward = (self.move_point - self.point):Normalized()
	self:GetParent():SetForwardVector(self.forward)
	self:StartIntervalThink(FrameTime())
	local particle_name = "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf"
	-- local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW,self:GetParent())
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetOrigin())
	-- ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
	ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_ability_thdots_youmu2_04_dummy:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():SetOrigin(self.point + self.forward * 50)
	self.point = self:GetParent():GetOrigin()
	self.move_point = RotatePosition(self.target_point, QAngle(0, 60, 0), self.point)
	self.forward = (self.move_point - self.point):Normalized()
	self:GetParent():SetForwardVector(self.forward)
end
function modifier_ability_thdots_youmu2_04_dummy:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveSelf()
end


--动画演出modifier
modifier_ability_thdots_youmu2_04_invin = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_invin","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_invin:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_04_invin:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_04_invin:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_04_invin:IsDebuff()		return false end

function modifier_ability_thdots_youmu2_04_invin:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] 	= true,
		[MODIFIER_STATE_OUT_OF_GAME]	= true,
		[MODIFIER_STATE_UNSELECTABLE]	= true,
		[MODIFIER_STATE_DISARMED]		= true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end
function modifier_ability_thdots_youmu2_04_invin:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	print("11111111111111111111")
	self:GetParent():AddNoDraw()
end
function modifier_ability_thdots_youmu2_04_invin:OnDestroy()
	if not IsServer() then return end
	print("AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)")
	self:GetParent():RemoveNoDraw()
	local vec = self.caster:GetOrigin()
	local ability = self:GetAbility()
	ability.youmu2_04high = 150
	self.caster:SetOrigin(Vector(vec.x,vec.y,vec.z+ability.youmu2_04high))
	self.caster:AddNewModifier(self.caster, self:GetAbility(),"modifier_ability_thdots_youmu2_04_caster_dummy", {duration = 0.2})

end

--caster演出，从天而降
modifier_ability_thdots_youmu2_04_caster_dummy = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_caster_dummy","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_caster_dummy:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_04_caster_dummy:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_04_caster_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_04_caster_dummy:IsDebuff()		return false end

function modifier_ability_thdots_youmu2_04_caster_dummy:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] 	= true,
		[MODIFIER_STATE_UNSELECTABLE]	= true,
		-- [MODIFIER_STATE_DISARMED]		= true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end
function modifier_ability_thdots_youmu2_04_caster_dummy:OnCreated()
	if not IsServer() then return end
	self.high = self:GetAbility().youmu2_04high
	self.caster = self:GetParent()
	self.vec = self.caster:GetOrigin()
	self.vec.z = self.vec.z + self.high
	self.caster:SetOrigin(self.vec)
	self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1)
	self:StartIntervalThink(FrameTime())
	local particle_name = "particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf"
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	-- ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
	ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_ability_thdots_youmu2_04_caster_dummy:OnIntervalThink()
	if not IsServer() then return end
	self.caster:SetOrigin(self.vec)
	self.vec.z = self.high
	self.high = self.high - 20
end
function modifier_ability_thdots_youmu2_04_caster_dummy:OnDestroy()
	if not IsServer() then return end
	self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
	local target = self:GetAbility().youmu2_04target
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetOrigin(), true)
	self.caster:SetForwardVector((target:GetOrigin() - self.caster:GetOrigin()):Normalized())
	local damage_table = {
				ability = self:GetAbility(),
			    victim = target,
			    attacker = self.caster,
			    damage = damage,
			    damage_type = DAMAGE_TYPE_MAGICAL, 
			}
	UnitDamageTarget(damage_table)
end

--弹刀MODIFIER
modifier_ability_thdots_youmu2_04_caster = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_caster","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_caster:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_04_caster:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_04_caster:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_04_caster:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_04_caster:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_youmu2_04_caster:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then return end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local caster = keys.target
	local bonus_duration = self:GetAbility():GetSpecialValueFor("bonus_duration")
	if caster == self:GetCaster() and keys.attacker:IsHero() then
		-- print_r(keys)
		-- print(keys.damage_type == DAMAGE_TYPE_PHYSICAL)
		-- print(keys.inflictor)
		if keys.damage_type == DAMAGE_TYPE_PHYSICAL and keys.inflictor == nil then

			EmitSoundOn("Voice_Thdots_Youmu.AbilityYoumu2_04_flick",caster)	--播放声音
			local Position = caster:GetOrigin()
			local effectIndex = ParticleManager:CreateParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(effectIndex, 0, Position)
			ParticleManager:SetParticleControl(effectIndex, 1, Position)
			ParticleManager:SetParticleControl(effectIndex, 2, Position)
			ParticleManager:SetParticleControl(effectIndex, 3, Position)
			ParticleManager:SetParticleControl(effectIndex, 5, Position)
			ParticleManager:SetParticleControl(effectIndex, 6, Position)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,4)

			caster:AddNewModifier(caster, self:GetAbility(),"modifier_ability_thdots_youmu2_04_bonus",{duration = bonus_duration})
			self:Destroy()
			return keys.damage
		end
	end
end

-- function modifier_ability_thdots_youmu2_04_caster:OnAttacked(keys)
-- 	if not IsServer() then return end
-- 		--特效音效
-- 		print("dddddddddddddddd")
-- 		print(bonus_duration)
-- 	end
-- end

--弹刀后增加攻速
modifier_ability_thdots_youmu2_04_bonus = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_bonus","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_bonus:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_04_bonus:IsPurgable()		return true end
function modifier_ability_thdots_youmu2_04_bonus:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_04_bonus:IsDebuff()		return false end
function modifier_ability_thdots_youmu2_04_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_ability_thdots_youmu2_04_bonus:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


--破坏效果，记录永久BUFF的技能,并删除MODIFIER。最后再设置技能等级，以重置MODIFIER
modifier_ability_thdots_youmu2_04_target = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_target","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_target:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_04_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_04_target:IsDebuff()		return true end
function modifier_ability_thdots_youmu2_04_target:GetEffectName()
	return "particles/item/silver_edge/silver_edge_panic_debuff.vpcf"
end

function modifier_ability_thdots_youmu2_04_target:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_ability_thdots_youmu2_04_target:IsPurgable()
	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_3") then
		return false
	else
		return true
	end
end


-- 破坏被动效果有大量BUG,会删除像骚灵三姐妹的天生积累层数。
-- function modifier_ability_thdots_youmu2_04_target:OnCreated()
-- 	if not IsServer() then return end
-- 	local target = self:GetParent()
-- 	self.duration = self:GetAbility():GetSpecialValueFor("duration")
-- 	self.target_point = target:GetOrigin()
-- 	self.youmu04_modifier_table = {}
--     local table_1 = {}
--     local table_2 = {}
-- 	local modifier_num = 1
-- 	for i=0,20 do 
-- 		if target:GetModifierNameByIndex(i) ~= "" then
-- 			-- print("==============")
-- 			-- print(target:GetModifierNameByIndex(i))
-- 			-- print(target:GetModifierNameByIndex(i))
-- 			local modifier = target:FindModifierByName(target:GetModifierNameByIndex(i))
-- 			-- print("==============================")
-- 			if modifier:GetRemainingTime() < -1 then
-- 				-- print(modifier:GetName() .. " :is modifier")
-- 				-- print(modifier:GetAbility())
-- 				-- print(modifier:GetAbility():IsItem())
-- 				if modifier:GetAbility():IsItem() == false and modifier:IsDebuff() == false 
-- 					--有些技能有BUG
-- 					and modifier:GetAbility():GetName() ~= "debug_name"
-- 					then
-- 					-- table_1[modifier_num] = {modifier_name = modifier:GetName(),modifier_ability = modifier:GetAbility()}
-- 					table_1[modifier_num] = modifier:GetAbility()
-- 					modifier_num = modifier_num + 1
-- 					modifier:Destroy()
-- 				end
-- 			end
-- 			-- print("==============================")
-- 		end
--     end
--     for key,val in pairs (table_1) do
--     	table_2[val] = true
--     end
--     for key,val in pairs(table_2) do
--     	table.insert(self.youmu04_modifier_table,key)--将key插入到新的table，构成最终的结果
--  	end
--     -- print_r(self.youmu04_modifier_table)
--     self:StartIntervalThink(FrameTime())


-- 	self.particle_fx = ParticleManager:CreateParticle("particles/items3_fx/silver_edge.vpcf", PATTACH_ABSORIGIN,target)
-- 	ParticleManager:SetParticleControl(self.particle_fx, 0,target:GetAbsOrigin())
-- end

-- function modifier_ability_thdots_youmu2_04_target:OnDestroy()
-- 	if not IsServer() then return end
-- 	local target = self:GetParent()
--     -- print_r(self.youmu04_modifier_table)
-- 	ParticleManager:DestroyParticle(self.particle_fx, false)
-- 	for i=1,#self.youmu04_modifier_table do
-- 		local ability = self.youmu04_modifier_table[i]
-- 		-- print("self.youmu04_modifier_table[i]")
-- 		-- print(self.youmu04_modifier_table[i])
-- 		-- target:AddNewModifier(target,self.youmu04_modifier_table[i].modifier_ability,tostring(self.youmu04_modifier_table[i].modifier_name), {duration = 20})
-- 		ability:SetLevel(ability:GetLevel())
-- 	end
-- end

-- function modifier_ability_thdots_youmu2_04_target:CheckState()
-- 	return {
-- 		[MODIFIER_STATE_PASSIVES_DISABLED] = true
-- 	}
-- end
function modifier_ability_thdots_youmu2_04_target:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_ability_thdots_youmu2_04_target:GetModifierMagicalResistanceBonus()
	return -self:GetStackCount()
end


--魔人效果，定在原地
modifier_ability_thdots_youmu2_04_lock = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_04_lock","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_04_lock:IsHidden() 		return false end
function modifier_ability_thdots_youmu2_04_lock:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_04_lock:IsDebuff()		return true end
function modifier_ability_thdots_youmu2_04_lock:IsPurgable()
	if self:GetCaster():HasModifier("modifier_ability_thdots_youmu2_Ex_telent_3") then
		return false
	else
		return true
	end
end

function modifier_ability_thdots_youmu2_04_lock:OnCreated()
	if not IsServer() then return end
	local target = self:GetParent()
	self.target_point = target:GetOrigin()
	self:StartIntervalThink(FrameTime())

	self.effectIndex2 = ParticleManager:CreateParticle("particles/thd2/items/item_morenjingjuan.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(self.effectIndex2 , 0, target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effectIndex2, 1, Vector(0,0,0))
	ParticleManager:SetParticleControl(self.effectIndex2, 6, Vector(1,1,1))
end

function modifier_ability_thdots_youmu2_04_lock:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent().is_Iku_02_knock == true then
		self:GetParent():SetOrigin(self.target_point)
	end
end
function modifier_ability_thdots_youmu2_04_lock:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effectIndex2,false)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

--------------------------------------------------------
--迷符「半身大悟」
--------------------------------------------------------
ability_thdots_youmu2_05 = {}

function ability_thdots_youmu2_05:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			self:SetHidden(true)
		end
	end
end

function ability_thdots_youmu2_05:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_youmu2_05:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end
function ability_thdots_youmu2_05:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster.youmu2_05_wanbaochui_target = target
	self.youmu2_05_wanbaochui_target = target
	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_05_passive",{duration = duration})
	if target == caster then
		--print("1111111111")
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_youmu2_05_self",{duration = duration})
		caster.youmu2_05_wanbaochui_target = nil
	end
	caster:EmitSound("Voice_Thdots_Youmu.AbilityYoumu2_05_cast")
	local particle_name = "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff_ground.vpcf"
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW,target)
	-- ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
	ParticleManager:ReleaseParticleIndex(particle)
end

modifier_ability_thdots_youmu2_05_self = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_05_self","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_youmu2_05_passive = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_05_passive","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_05_passive:IsPurgable()		return true end
function modifier_ability_thdots_youmu2_05_passive:RemoveOnDeath() 	return true end
function modifier_ability_thdots_youmu2_05_passive:IsHidden()
	if self:GetParent():HasModifier("modifier_ability_thdots_youmu2_Ex_passive") then
		return true
	else
		return false
	end
end
function modifier_ability_thdots_youmu2_05_passive:IsDebuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return false
	else
		return true
	end
end
function modifier_ability_thdots_youmu2_05_passive:OnCreated()
	if not IsServer() then return end
	self.youmu2_05_particle = ParticleManager:CreateParticle("particles/econ/items/natures_prophet/natures_prophet_weapon_primeval_staff/natures_prophet_primeval_staff.vpcf", PATTACH_POINT_FOLLOW,self:GetParent())
 	ParticleManager:SetParticleControlEnt(self.youmu2_05_particle,0,self:GetParent(),PATTACH_POINT_FOLLOW,"attach_attack1",Vector(0,0,0),true)

end
function modifier_ability_thdots_youmu2_05_passive:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.youmu2_05_particle,false)
	self:GetCaster().youmu2_05_wanbaochui_target = nil
end

function modifier_ability_thdots_youmu2_05_passive:GetAuraRadius() return 99999 end -- global
function modifier_ability_thdots_youmu2_05_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_ability_thdots_youmu2_05_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_youmu2_05_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_ability_thdots_youmu2_05_passive:GetModifierAura() return "modifier_ability_thdots_youmu2_05_damage" end
function modifier_ability_thdots_youmu2_05_passive:IsAura() return true end


--所有伤害转化为魔法伤害
modifier_ability_thdots_youmu2_05_damage = {}
LinkLuaModifier("modifier_ability_thdots_youmu2_05_damage","scripts/vscripts/abilities/abilityyoumu2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_youmu2_05_damage:IsHidden() 		return true end
function modifier_ability_thdots_youmu2_05_damage:IsPurgable()		return false end
function modifier_ability_thdots_youmu2_05_damage:RemoveOnDeath() 	return false end
function modifier_ability_thdots_youmu2_05_damage:IsDebuff()		return true end
function modifier_ability_thdots_youmu2_05_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end
function modifier_ability_thdots_youmu2_05_damage:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local ability = self:GetAbility()
	local caster = ability.youmu2_05_wanbaochui_target
	local target = kv.target
	if kv.attacker ~= caster then return end
	if kv.attacker:HasModifier("modifier_ability_thdots_youmu2_05_passive") and kv.damage_type ~= DAMAGE_TYPE_MAGICAL then

		if kv.attacker:HasModifier("modifier_ability_thdots_youmu2_Ex_passive") then return end --万宝槌给自己上由EX技能变伤害。

		local damage_table = {
					ability = nil,
				    victim = target,
				    attacker = caster,
				    damage = kv.original_damage,
				    damage_type = DAMAGE_TYPE_MAGICAL, 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
		return kv.damage
	else
		return
	end
end
