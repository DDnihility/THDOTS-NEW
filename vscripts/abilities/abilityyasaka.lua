--------------------------------------------------------
--「风神之神德」
--------------------------------------------------------
ability_thdots_yasakaEx = {}

function ability_thdots_yasakaEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_yasakaEx_passive"
end
function ability_thdots_yasakaEx:OnHeroLevelUp()
	local lvl=math.floor(1+(self:GetCaster():GetLevel()-1)/6)
	if lvl ~= self:GetLevel() and lvl< 5 then
		self:SetLevel(lvl)
	end
end
modifier_ability_thdots_yasakaEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_yasakaEx_passive","scripts/vscripts/abilities/abilityyasaka.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yasakaEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_yasakaEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_yasakaEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_yasakaEx_passive:IsDebuff()		return false end

function modifier_ability_thdots_yasakaEx_passive:GetAuraRadius()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	if self:GetCaster ():HasModifier("modifier_thdots_yasaka04_buff")then
		return radius + self:GetAbility():GetSpecialValueFor("radius_bouns") 
	else 
		return radius
	end 
end
function modifier_ability_thdots_yasakaEx_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ability_thdots_yasakaEx_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_thdots_yasakaEx_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_yasakaEx_passive:GetModifierAura() return "modifier_ability_thdots_yasakaEx_passive_aura" end
function modifier_ability_thdots_yasakaEx_passive:IsAura() return true end

function modifier_ability_thdots_yasakaEx_passive:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_ability_thdots_yasakaEx_passive:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() 
end

--光环效果
modifier_ability_thdots_yasakaEx_passive_buff = {}
LinkLuaModifier("modifier_ability_thdots_yasakaEx_passive_buff","scripts/vscripts/abilities/abilityyasaka.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yasakaEx_passive_buff:IsPurgable()		return false end
function modifier_ability_thdots_yasakaEx_passive_buff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yasakaEx_passive_buff:IsDebuff()		return false end
function modifier_ability_thdots_yasakaEx_passive:IsHidden() 		return false end

function modifier_ability_thdots_yasakaEx_passive_buff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ATTACK 
	}
end

function modifier_ability_thdots_yasakaEx_passive_buff:OnCreated()
	if not IsServer() then return end
	self.target = self:GetParent()
	self.caster = self:GetCaster()
	self.caster_buff = self.caster:FindModifierByName("modifier_ability_thdots_yasakaEx_passive")
	local caster_stack = self.caster_buff:GetStackCount()
	self.caster_buff:SetStackCount(caster_stack + self:GetAbility():GetSpecialValueFor("self_bonus"))
	self:StartIntervalThink(3)
end

function modifier_ability_thdots_yasakaEx_passive_buff:OnIntervalThink()
	if not IsServer() then return end
	if  not self.target:HasModifier("modifier_ability_thdots_yasakaEx_passive_aura") then
		self:DecrementStackCount()
	else
		self.aura = self.target:FindModifierByName("modifier_ability_thdots_yasakaEx_passive_aura")
	    if self.aura:GetStackCount() > 0 then return end		
	end
	if  self:GetStackCount() == 0 then
		self:Destroy()
		return
	end
	if  self:GetStackCount() > 0 then
		self:DecrementStackCount()
	end
end

function modifier_ability_thdots_yasakaEx_passive_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end
function modifier_ability_thdots_yasakaEx_passive_buff:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("armor_bonus")
end

function modifier_ability_thdots_yasakaEx_passive_buff:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker ~= self.target then return end
	local max_stack =self:GetAbility():GetSpecialValueFor("max_stack")
	if self:GetStackCount() < max_stack then
	self:IncrementStackCount()
	end
end

function modifier_ability_thdots_yasakaEx_passive_buff:OnDestroy()
	if not IsServer() then return end
	local caster_stack =self.caster_buff:GetStackCount()
	self.caster_buff:SetStackCount(caster_stack - self:GetAbility():GetSpecialValueFor("self_bonus"))
end
--光环标记
modifier_ability_thdots_yasakaEx_passive_aura = {}
LinkLuaModifier("modifier_ability_thdots_yasakaEx_passive_aura","scripts/vscripts/abilities/abilityyasaka.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yasakaEx_passive_aura:IsHidden() 		return false end
function modifier_ability_thdots_yasakaEx_passive_aura:IsPurgable()		return false end
function modifier_ability_thdots_yasakaEx_passive_aura:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yasakaEx_passive_aura:IsDebuff()		return false end
function modifier_ability_thdots_yasakaEx_passive_aura:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK, 
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
	}
end
function modifier_ability_thdots_yasakaEx_passive_aura:OnCreated()
	if not IsServer() then return end
	self.target = self:GetParent()
	self.caster = self:GetCaster()
	self.healregen = 0
	self.manaregen = 0
	self:StartIntervalThink(1)
end

function modifier_ability_thdots_yasakaEx_passive_aura:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker ~= self.target then return end
	if not self.target:HasModifier("modifier_ability_thdots_yasakaEx_passive_buff") then
	local buff = self.target:AddNewModifier(self.caster, self:GetAbility(),  "modifier_ability_thdots_yasakaEx_passive_buff", {})
	buff:SetStackCount(1)
	end
	self:SetStackCount(3)--攻击标记
end
function modifier_ability_thdots_yasakaEx_passive_aura:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self.caster,"special_bonus_unique_yasaka_5") ~= 0 then
		self.healregen = self:GetAbility():GetSpecialValueFor("health_regen_pct")
		self.manaregen = self:GetAbility():GetSpecialValueFor("mana_regen_pct")
	end
	if  self:GetStackCount() > 0 then
		self:DecrementStackCount()
	end
end
function modifier_ability_thdots_yasakaEx_passive_aura:GetModifierHealthRegenPercentage()
	return self.healregen
end
function modifier_ability_thdots_yasakaEx_passive_aura:GetModifierTotalPercentageManaRegen()
	return self.manaregen
end
--------------------------------------------------------
--神祭「扩散御柱」
--------------------------------------------------------
function Yasaka01_OnSpellStart(keys)	
	local Ability=keys.ability
	local Caster=keys.caster
	local StunDuration = keys.StunDuration + FindTelentValue(Caster,"special_bonus_unique_yasaka_1")
	local Damage =Ability:GetAbilityDamage()+ FindTelentValue(Caster,"special_bonus_unique_yasaka_4")
	local TargetPoint=keys.target_points[1]	
	Caster:SetContextThink(
		"yasaka01_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			local enemies=FindUnitsInRadius(
						Caster:GetTeamNumber(),
						TargetPoint,
						nil,
						keys.DamageRadius,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_ANY_ORDER,
						false)
			for _,v in pairs(enemies) do
				damage_table={
					victim=v, 
					attacker=Caster, 
					damage=Damage,
					damage_type=Ability:GetAbilityDamageType(),
				}
				UtilStun:UnitStunTarget(Caster,v,StunDuration)
				UnitDamageTarget(damage_table)
			end
			Caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
			return nil
		end,0.5)	
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_041.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 1, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 3, TargetPoint)
	ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
	Caster:EmitSound("Visage_Familar.StoneForm.Cast")
	GridNav:DestroyTreesAroundPoint(TargetPoint, keys.DamageRadius, true)
end
function Onyasaka01upgrade(keys)
	if not IsServer() then return end
	local spell = keys.caster:FindAbilityByName("ability_thdots_yasaka41")
	if spell then
		spell:SetLevel(keys.ability:GetLevel())
	end
end
--------------------------------------------------------
--神秘「大和环面」
--------------------------------------------------------
function Yasaka02_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster

	local radius=keys.radius
	local tick_interval=keys.tick_interval
	local offset=60
	local damage = Ability:GetAbilityDamage() + FindTelentValue(Caster,"special_bonus_unique_yasaka_2")
	local heal = damage * tick_interval
	local damage_table={
		victim=nil, 
		attacker=Caster, 
		ability=Ability, 
		damage=damage*tick_interval,
		damage_type=Ability:GetAbilityDamageType(),
	}

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

	Ability:ApplyDataDrivenModifier(Caster, Caster, keys.icon_name, {duration=keys.duration})
	local inside_enemies=FindUnitsInRadius(
			Caster:GetTeamNumber(),
			Caster:GetOrigin(),
			nil,
			radius,
			Ability:GetAbilityTargetTeam(),
			Ability:GetAbilityTargetType(),
			Ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false)
	for _,v in pairs(inside_enemies) do
		Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_name, {duration=keys.duration})
	end

	local OnThinkEnd=function ()
		-- 
	end

	Caster:SetContextThink(
		"yasaka02_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() or not Caster:HasModifier(keys.icon_name)  then 
				OnThinkEnd()
				return nil
			end
			local origin=Caster:GetOrigin()

			ProjectileManager:ProjectileDodge(Caster)

			for k,v in pairs(inside_enemies) do
				if not v:HasModifier(keys.debuff_name) or v:IsNull() or not v:IsAlive() then
					inside_enemies[k]=nil
				else
					if not v:IsPositionInRange(origin,radius) and (v:HasModifier("modifier_thdots_yugi04_think_interval") == false) and v:IsHero() and v:IsPositionInRange(origin,1000) then
						local new_pos=origin+(origin-v:GetOrigin()):Normalized()*(radius-offset)
						FindClearSpaceForUnit(v, new_pos, true)
						local effectIndex1 = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_l.vpcf", PATTACH_CUSTOMORIGIN, nil)
						ParticleManager:SetParticleControl(effectIndex1, 0, new_pos)
						ParticleManager:SetParticleControl(effectIndex1, 1, new_pos)
						Caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start")
					end
				end
			end

			local enemies=FindUnitsInRadius(
				Caster:GetTeamNumber(),
				Caster:GetOrigin(),
				nil,
				radius,
				Ability:GetAbilityTargetTeam(),
				Ability:GetAbilityTargetType(),
				Ability:GetAbilityTargetFlags(),
				FIND_ANY_ORDER,
				false)
			for _,v in pairs(enemies) do
				
				if not v:HasModifier(keys.debuff_name) and (v:HasModifier("modifier_thdots_yugi04_think_interval") == false) and v:IsHero() then
					local new_pos=origin+(origin-v:GetOrigin()):Normalized()*(radius+offset)
					FindClearSpaceForUnit(v, new_pos, true)
					local effectIndex2 = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_l.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(effectIndex2, 0, new_pos)
					ParticleManager:SetParticleControl(effectIndex2, 1, new_pos)
					Caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start")
				end

				if v:GetTeam() ~= Caster:GetTeam() then
					damage_table.victim=v
					UnitDamageTarget(damage_table)
				end
				if v:GetTeam() == Caster:GetTeam() then
					ProjectileManager:ProjectileDodge(v)
				end
			end
			return keys.tick_interval
		end,0)
end
function Onyasaka02upgrade(keys)
	if not IsServer() then return end
	local spell = keys.caster:FindAbilityByName("ability_thdots_yasaka42")
	if spell then
		spell:SetLevel(keys.ability:GetLevel())
	end
end
--------------------------------------------------------
--神谷「神灵之谷」
--------------------------------------------------------
function Yasaka03_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	if Caster:HasModifier("modifier_item_wanbaochui") then
		THDReduceCooldown(keys.ability,-6)
	end

	if Target: IsBuilding() then
		if Caster:HasModifier("modifier_item_wanbaochui") and Caster:GetTeam()==Target:GetTeam() then
			Target:Heal(keys.heal_amt, Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Target,keys.heal_amt,nil)
			Ability:ApplyDataDrivenModifier(Caster, Target, keys.buff_name, {})
		else
			Ability:RefundManaCost()
			Ability:EndCooldown()
			return
		end		
	
	else	
		if Caster:GetTeam()==Target:GetTeam() then
			Target:Heal(keys.heal_amt, Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Target,keys.heal_amt,nil)
			Ability:ApplyDataDrivenModifier(Caster, Target, keys.buff_name, {})
		else
			if not is_spell_blocked(Target) then
				Ability:ApplyDataDrivenModifier(Caster, Target, keys.debuff_name, {duration = keys.debuff_duration})
				local damage_table = {
				ability = keys.ability,
				victim = Target,
				attacker = Caster,
				damage = keys.ability:GetAbilityDamage(),
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = keys.ability:GetAbilityTargetFlags()
				}
			UnitDamageTarget(damage_table) 			
			end
		end
	end
end
function Onyasaka03upgrade(keys)
	if not IsServer() then return end
	local spell = keys.caster:FindAbilityByName("ability_thdots_yasaka43")
	if spell then
		spell:SetLevel(keys.ability:GetLevel())
	end
end
--------------------------------------------------------
--「神圣庄严的古战场」
--------------------------------------------------------
ability_thdots_yasaka04_release = ({})
function Yakasa04_SwapAbilities(caster,is_ultimate)
	if is_ultimate then
		caster:SwapAbilities("ability_thdots_yasaka01","ability_thdots_yasaka41",false,true)
		caster:SwapAbilities("ability_thdots_yasaka02","ability_thdots_yasaka42",false,true)
		caster:SwapAbilities("ability_thdots_yasaka03","ability_thdots_yasaka43",false,true)
        caster:SwapAbilities("ability_thdots_yasaka04_release","ability_thdots_yasaka04_quit",false,true)
	else
		caster:SwapAbilities("ability_thdots_yasaka41","ability_thdots_yasaka01",false,true)
		caster:SwapAbilities("ability_thdots_yasaka42","ability_thdots_yasaka02",false,true)
		caster:SwapAbilities("ability_thdots_yasaka43","ability_thdots_yasaka03",false,true)
		caster:SwapAbilities("ability_thdots_yasaka04_quit","ability_thdots_yasaka04_release",false,true)
	end
end

function ability_thdots_yasaka04_release:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self, level)
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_yasaka_3")
	if telent then
		cd = cd + telent:GetSpecialValueFor("value")
	end
	return cd
end

function ability_thdots_yasaka04_release:OnSpellStart()
	if not IsServer() then return end
	local Caster=self:GetCaster()
	self.buff_name=Caster:AddNewModifier(Caster,self, "modifier_thdots_yasaka04_buff", {duration=self:GetSpecialValueFor("duration"),
																						cooldown=self:GetEffectiveCooldown(self:GetLevel()-1)})
    Caster:EmitSound("Voice_Thdots_Kanako.AbilityKanako04")
end

function ability_thdots_yasaka04_release:OnAbilityPhaseStart()
	if not IsServer() then return end
	local Caster=self:GetCaster()
	print("began")
	--Caster:SetModel("models/thd2/kanako/kanako_mmd_transforming.vmdl")
    Caster:EmitSound("Hero_ElderTitan.EchoStomp.Channel")
	Caster:SetOriginalModel("models/thd2/kanako/kanako_mmd_transforming.vmdl")
    Caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	return true
end

function ability_thdots_yasaka04_release:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	local Caster=self:GetCaster()
	Caster:SetOriginalModel("models/thd2/kanako/kanako_mmd.vmdl")
	self:EndCooldown()
end

modifier_thdots_yasaka04_buff = {}
LinkLuaModifier("modifier_thdots_yasaka04_buff","scripts/vscripts/abilities/abilityyasaka.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_yasaka04_buff:IsHidden() 		return false end
function modifier_thdots_yasaka04_buff:IsPurgable()		return false end
function modifier_thdots_yasaka04_buff:RemoveOnDeath() 	return true end
function modifier_thdots_yasaka04_buff:IsDebuff()		return false end
function modifier_thdots_yasaka04_buff:GetEffectName()  return "particles/heroes/kanako/ability_kanako_04.vpcf" end
function modifier_thdots_yasaka04_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_thdots_yasaka04_buff:OnCreated(parma)
	if not IsServer() then return end
	self.caster =self:GetCaster()
	self.pos=self:GetCaster():GetAbsOrigin()
	self.Ability=self:GetAbility()
	self.attack_speed = self.Ability:GetSpecialValueFor("attack_speed_down")
	self.attack_range = self.Ability:GetSpecialValueFor("attack_range_bonus")
	self.radius =self.Ability:GetSpecialValueFor("damage_radius")
	self.Damage_percent = self.Ability:GetSpecialValueFor("damage_percent")
	self.Cooldown = parma.cooldown
	self.time = self.Ability:GetSpecialValueFor("slow_duration")
    self:StartIntervalThink(0.1)
	self.caster:SetModel("models/thd2/kanako/kanako_mmd_transform.vmdl")
	self.caster:SetOriginalModel("models/thd2/kanako/kanako_mmd_transform.vmdl")
    Yakasa04_SwapAbilities(self.caster, true)
end
function modifier_thdots_yasaka04_buff:OnIntervalThink()
	if not IsServer() then return end
    if not self.caster:IsPositionInRange(self.pos,600) then
        self.caster:SetOrigin(self.pos)
		--print(self.pos)
    end
end
function modifier_thdots_yasaka04_buff:OnDestroy() 
	if not IsServer() then return end
	self.caster:SetModel("models/thd2/kanako/kanako_mmd.vmdl")
	self.caster:SetOriginalModel("models/thd2/kanako/kanako_mmd.vmdl")
    Yakasa04_SwapAbilities(self.caster, false)
    self:GetAbility():StartCooldown(self.Cooldown)
end

function modifier_thdots_yasaka04_buff:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_thdots_yasaka04_buff:OnAttacked(keys)
	if not IsServer() then return end
	local target = keys.target
	if keys.attacker ~= self.caster or target:IsHero()==false then return end
	local damage=keys.damage* self.Damage_percent
	local TargetPoint=target:GetOrigin()
	local enemies=FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		TargetPoint,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
	for _,v in pairs(enemies) do
		damage_table={
			victim		= v, 
			attacker	= self.caster, 
			damage		= damage,
			damage_type	= DAMAGE_TYPE_MAGICAL,
			ability 	= self.ability,
			damage_flags = DOTA_DAMAGE_FLAG_NONE
		}
	UnitDamageTarget(damage_table)
	v:AddNewModifier(self.caster, self.Ability,"modifier_thdots_yasaka04_debuff", {duration=self.time * (1 - v:GetStatusResistance())})
    end
	self.caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_041.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 1, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 3, TargetPoint)
	ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
	self.caster:EmitSound("Visage_Familar.StoneForm.Cast")
	GridNav:DestroyTreesAroundPoint(TargetPoint, self.radius, true)
end
function modifier_thdots_yasaka04_buff:GetModifierAttackRangeBonus()
    return self.attack_range
end
function modifier_thdots_yasaka04_buff:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

modifier_thdots_yasaka04_debuff = {}
LinkLuaModifier("modifier_thdots_yasaka04_debuff","scripts/vscripts/abilities/abilityyasaka.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_yasaka04_debuff:IsHidden() 		return false end
function modifier_thdots_yasaka04_debuff:IsPurgable()		return true end
function modifier_thdots_yasaka04_debuff:RemoveOnDeath() 	return true end
function modifier_thdots_yasaka04_debuff:IsDebuff()			return true end
function modifier_thdots_yasaka04_debuff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_thdots_yasaka04_debuff:GetModifierMoveSpeedBonus_Percentage()
	return 	self:GetAbility():GetSpecialValueFor("slow")
end
ability_thdots_yasaka04_quit = {}

function ability_thdots_yasaka04_quit:OnSpellStart()
	local hero=self:GetCaster()
	if(hero:FindModifierByName("modifier_thdots_yasaka04_buff")~=nil)then
        hero:RemoveModifierByName("modifier_thdots_yasaka04_buff")
    end
end
--------------------------------------------------------
--奇祭「目处梃子乱舞」
--------------------------------------------------------
function Yasaka41_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local tick_interval=keys.tick_interval
	local rate_tick=keys.rate*keys.tick_interval
	local tick=0
	local last_down_tick=0
	local stun_duration = keys.stun_duration + FindTelentValue(Caster,"special_bonus_unique_yasaka_1")
	local Damage = Ability:GetAbilityDamage()+ FindTelentValue(Caster,"special_bonus_unique_yasaka_4")
	damage_table={
		victim=nil, 
		attacker=Caster, 
		damage= Damage,
		damage_type=Ability:GetAbilityDamageType(),
	}

	Ability:ApplyDataDrivenModifier(Caster, Caster, keys.icon_name, {})
	local origin=Caster:GetOrigin()
	local OnThinkEnd=function ()
		Caster:RemoveModifierByName(keys.icon_name)
	end

	Caster:SetContextThink(
		"yasaka41_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end
			if last_down_tick~=math.floor(tick*rate_tick) then
				last_down_tick=math.floor(tick*rate_tick)
				local rdpos=origin+RandomVector(keys.radius)*RandomFloat(0,1)

				local enemies=FindUnitsInRadius(
					Caster:GetTeamNumber(),
					rdpos,
					nil,
					keys.damage_radius,
					Ability:GetAbilityTargetTeam(),
					Ability:GetAbilityTargetType(),
					Ability:GetAbilityTargetFlags(),
					FIND_ANY_ORDER,
					false)
				for _,v in pairs(enemies) do
					damage_table.victim=v
					UtilStun:UnitStunTarget(Caster,v,stun_duration)
					UnitDamageTarget(damage_table)
				end
				local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_041.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(effectIndex, 0, rdpos)
				ParticleManager:SetParticleControl(effectIndex, 1, rdpos)
				ParticleManager:SetParticleControl(effectIndex, 3, rdpos)
				ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
				Caster:EmitSound("Visage_Familar.StoneForm.Cast")
				GridNav:DestroyTreesAroundPoint(rdpos, keys.damage_radius, true)
			end

			tick=tick+1
			if not Caster:HasModifier(keys.icon_name) then
				OnThinkEnd()
				return nil 
			end
			return tick_interval
		end,0)
end

function Yasaka42_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local TargetPoint=keys.target_points[1]
	local tick_interval=keys.tick_interval
	local max_tick=keys.duration /tick_interval
	local tick=0

	local OnThinkEnd=function ()
		-- 
	end

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_042.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 7, TargetPoint)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

	Caster:SetContextThink(
		"yasaka42_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end
			local enemies=FindUnitsInRadius(
				Caster:GetTeamNumber(),
				TargetPoint,
				nil,
				keys.effect_radius,
				Ability:GetAbilityTargetTeam(),
				Ability:GetAbilityTargetType(),
				Ability:GetAbilityTargetFlags(),
				FIND_ANY_ORDER,
				false)
			for _,v in pairs(enemies) do
				Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_name, {})
			end
			tick=tick+1
			if tick>=max_tick then 
				OnThinkEnd()
				return nil 
			end
			return tick_interval
		end,0)
end

function Yasaka43_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local tick_interval=keys.tick_interval
	local tick_mana_spend=keys.mana_spend*tick_interval
	local origin=Caster:GetOrigin()
	local effectIndex_2 = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_start_ring_flash_arcana.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex_2, 7, origin)
	Target:Purge(false, true, false, true, false)
	Ability:ApplyDataDrivenModifier(Caster, Caster, keys.aura_name, {})
	if Caster:HasModifier("modifier_item_wanbaochui") then
		Ability:ApplyDataDrivenModifier(Caster, Caster, keys.aura_name_2, {})
	end

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_vine_glow_trail.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, Target:GetOrigin())

	local OnThinkEnd=function ()
		Caster:StopSound("Hero_WitchDoctor.Voodoo_Restoration.Loop")
		ParticleManager:DestroyParticleSystemTime(effectIndex_2,0) 
	end

	Caster:SetContextThink(
		"yasaka43_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				Caster:RemoveModifierByName(keys.aura_name)
				Caster:RemoveModifierByName(keys.aura_name_2)
				OnThinkEnd()
				return nil
			end
			Caster:SpendMana(tick_mana_spend, Ability)
			if Caster:GetMana()<tick_mana_spend then
				Caster:InterruptChannel()
			end
			if not Caster:IsChanneling() then 
				Caster:RemoveModifierByName(keys.aura_name)
				Caster:RemoveModifierByName(keys.aura_name_2)
				OnThinkEnd()
				return nil 
			end
			return tick_interval
		end,0)

end
