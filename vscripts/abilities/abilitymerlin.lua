MERLINEX_BONUS_COUNT = nil --小号EX层数记录


function Merlin01( keys )
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(keys.target) then return end
	target:SetForceAttackTarget(nil)

	target:Stop()


	if caster:IsAlive() then 
		local order = {
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else 
		target:Stop()
	end

	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin01.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW,target)
	-- ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())		
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)
	target:SetForceAttackTarget(caster)
	if target:IsHero() then
		local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = keys.ability:GetSpecialValueFor("spell_damage") + caster:GetIntellect()*1.5,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
			}
		UnitDamageTarget(damage_table) 
	elseif target:IsNeutralUnitType() and target:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
		target:Kill(keys.ability,caster)
	else
		local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = keys.ability:GetSpecialValueFor("spell_damage") + caster:GetIntellect()*1.5 + keys.ability:GetSpecialValueFor("extra_damage"),
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
			}
		UnitDamageTarget(damage_table) 

		caster:SetMana(caster:GetMana() + 70)
	end

end


function Merlin01End( keys )
	local target = keys.target
	target:SetForceAttackTarget(nil)	
end


function Merlin02( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(target,caster) then return end
	target:EmitSound("Voice_Thdots_Merlin.AbilityMerlin02")
	if(FindTelentValue(caster,"special_bonus_unique_merlin") == 1)then
		if(caster:GetTeam() ~= target:GetTeam()) then
			print("telent debuff")
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin02_debuff_telent", {duration = keys.buff_time})
		else
			print("telent buff")
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin02_buff", {duration = keys.buff_time})
		end
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin02_debuff", {duration = keys.buff_time})
		print("no telent")
		--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions)
		--target:Purge(false,true,false,true,false)
	end
end

ability_thdots_Merlin03 = {}

function ability_thdots_Merlin03:GetIntrinsicModifierName()		
	return "modifier_merlin03_arua"
end
function ability_thdots_Merlin03:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE
	else
		return self.BaseClass.GetBehavior(self)
	end
end
function ability_thdots_Merlin03:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_thdots_Merlin03_wanbaochui", {})
	else
		self:GetCaster():RemoveModifierByName("modifier_thdots_Merlin03_wanbaochui")
	end
end
function ability_thdots_Merlin03:ResetToggleOnRespawn()	return true end


modifier_merlin03_arua = {}
LinkLuaModifier("modifier_merlin03_arua", "scripts/vscripts/abilities/abilitymerlin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_merlin03_arua:IsHidden() 		return true end
function modifier_merlin03_arua:IsPurgable()		return false end
function modifier_merlin03_arua:RemoveOnDeath() 	return true end
function modifier_merlin03_arua:IsDebuff()		return false end
function modifier_merlin03_arua:AllowIllusionDuplicate() return false end

function modifier_merlin03_arua:IsAura() return true end
function modifier_merlin03_arua:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_range") end -- global
function modifier_merlin03_arua:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_merlin03_arua:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_merlin03_arua:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_merlin03_arua:GetModifierAura() return "modifier_merlin03_buff" end

function modifier_merlin03_arua:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self:StartIntervalThink(0.1)
end
function modifier_merlin03_arua:OnIntervalThink()
	if not IsServer() then return end
	local currentHealth = self.caster:GetHealth()
	local maxHealth = self.caster:GetMaxHealth()
	local tmp1 = math.modf( (1 - (currentHealth / maxHealth ) ) / self.ability:GetSpecialValueFor("spell_rate") )

	local buffstack = tmp1 + 1
	local targets = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetOrigin(), self, self.ability:GetSpecialValueFor("aura_range"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for _,u in pairs (targets) do
			u:SetModifierStackCount("modifier_merlin03_buff", self.caster, buffstack)
		end
end

modifier_merlin03_buff = {}
LinkLuaModifier("modifier_merlin03_buff", "scripts/vscripts/abilities/abilitymerlin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_merlin03_buff:IsHidden() 		return false end
function modifier_merlin03_buff:IsPurgable()		return false end
function modifier_merlin03_buff:RemoveOnDeath() 	return true end
function modifier_merlin03_buff:IsDebuff()		return false end

function modifier_merlin03_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function modifier_merlin03_buff:OnCreated()
	if not IsServer() then return end
end

function modifier_merlin03_buff:GetModifierConstantHealthRegen()
	local bonus = self:GetAbility():GetSpecialValueFor("hp_regen")
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_merlin_2")
	if telent then
		bonus = bonus + telent:GetSpecialValueFor("value")
	end
	return bonus * self:GetStackCount()
end
function modifier_merlin03_buff:GetModifierPhysicalArmorBonus()
	local bonus = 0
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_merlin_3")
	if telent then
		bonus = telent:GetSpecialValueFor("armor")
	end
	return bonus * self:GetStackCount()
end
function modifier_merlin03_buff:GetModifierMagicalResistanceBonus()
	local bonus = 0
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_merlin_3")
	if telent then
		bonus = telent:GetSpecialValueFor("magic")
	end
	return bonus * self:GetStackCount()
end

modifier_thdots_Merlin03_wanbaochui = {}
LinkLuaModifier("modifier_thdots_Merlin03_wanbaochui", "scripts/vscripts/abilities/abilitymerlin.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_thdots_Merlin03_wanbaochui:IsAura()						return true end
function modifier_thdots_Merlin03_wanbaochui:IsAuraActiveOnDeath() 			return false end
function modifier_thdots_Merlin03_wanbaochui:IsHidden() 					return true end

function modifier_thdots_Merlin03_wanbaochui:GetAuraRadius()				return self:GetAbility():GetSpecialValueFor("aura_range") end
function modifier_thdots_Merlin03_wanbaochui:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_thdots_Merlin03_wanbaochui:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_thdots_Merlin03_wanbaochui:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_thdots_Merlin03_wanbaochui:GetModifierAura()				return "modifier_thdots_Merlin03_wanbaochui_slow" end
function modifier_thdots_Merlin03_wanbaochui:IsPurgable() 			        return false end

function modifier_thdots_Merlin03_wanbaochui:OnCreated()
	if not IsServer() then return end

	if not self:GetAbility() then self:Destroy() return end
	
	self.radius			= self:GetAbility():GetSpecialValueFor("radius")
	self.tick			= self:GetAbility():GetSpecialValueFor("tick")
	self.damage_percent	= self:GetAbility():GetSpecialValueFor("damage_percent") 

	
	self.damage_per_tick	= self:GetCaster():GetMaxHealth() * self.damage_percent * 0.01 * self.tick
	
	self.pfx = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/naga_siren_song_aura.vpcf", PATTACH_CENTER_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius, 0, 0))
	self:AddParticle(self.pfx, false, false, -1, false, false)	
	
	self:StartIntervalThink(self.tick)
	
	EmitSoundOn("Hero_Pudge.Rot", self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_CHANNEL_ABILITY_2)
end

function modifier_thdots_Merlin03_wanbaochui:OnIntervalThink()
	if not IsServer() then return end

	self.damage_per_tick	= self:GetCaster():GetMaxHealth() * self.damage_percent * 0.01 * self.tick
	
	if self.pfx then
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius, 0, 0))
	end
	
	ApplyDamage({
		victim 			= self:GetParent(),
		damage 			= self.damage_per_tick,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	})
		
	-- Area damage
	
	-- Global radius due to Rot being able to damage units from anywhere as long as they have the debuff
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if enemy:FindModifierByNameAndCaster("modifier_thdots_Merlin03_wanbaochui_slow", self:GetCaster()) then
			ApplyDamage({
				victim 			= enemy,
				damage 			= self.damage_per_tick,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self:GetAbility()
			})
		end
	end
end

function modifier_thdots_Merlin03_wanbaochui:OnDestroy()
	if not IsServer() then return end
	
	StopSoundOn("Hero_Pudge.Rot", self:GetParent())
	self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_2)
end

modifier_thdots_Merlin03_wanbaochui_slow = {}
LinkLuaModifier("modifier_thdots_Merlin03_wanbaochui_slow", "scripts/vscripts/abilities/abilitymerlin.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_thdots_Merlin03_wanbaochui_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET
	}
end

function modifier_thdots_Merlin03_wanbaochui_slow:GetModifierMoveSpeedBonus_Percentage()
	self.slow			= -self:GetAbility():GetSpecialValueFor("slow")* (1 - self:GetParent():GetStatusResistance())
	return self.slow
end

function modifier_thdots_Merlin03_wanbaochui_slow:GetModifierHealAmplify_PercentageTarget()
	self.heal_reduce			= -self:GetAbility():GetSpecialValueFor("heal_reduce")
	return self.heal_reduce
end




function Merlin04SpellStart( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, caster, "OnMerlin04TakeDamage", {})
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin04_enemy", {})
	merlin04target = target
	caster:EmitSound("Voice_Thdots_Merlin.AbilityMerlin04")
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_merlin_4"))
--customorigin
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_target.vpcf", PATTACH_OVERHEAD_FOLLOW,target)
	--ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin() + Vector(0,0,100))		
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

    local effectIndex1 = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_self.vpcf", PATTACH_OVERHEAD_FOLLOW,caster)
	--ParticleManager:SetParticleControl(effectIndex1, 0, caster:GetOrigin() + Vector(0,0,100))		
	ParticleManager:DestroyParticleSystemTime(effectIndex1,keys.duration)

end


function OnMerlin04TakeDamage( keys )
	local caster = keys.caster
	local target = merlin04target
	local attacker = keys.attacker
	if target:HasModifier("modifier_merlin04_enemy") then
		local damage_to_deal = keys.TakenDamage * (keys.ability:GetSpecialValueFor("back_factor") + FindTelentValue(caster,"special_bonus_unique_merlin_5"))


		if (attacker:IsBuilding()==false and attacker:IsRealHero()) and attacker ~= caster then
			if (damage_to_deal > 0) then

				local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = damage_to_deal,
					damage_type = keys.ability:GetAbilityDamageType(),
					damage_flags = 0
				}
				SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,target,damage_to_deal,nil)
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_thin.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+Vector(0, 0, 100))
				ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()+Vector(0, 0, 100))
				ParticleManager:DestroyParticleSystem(effectIndex,false)
				UnitDamageTarget(damage_table)
			end
		end
	else
		caster:RemoveModifierByName("OnMerlin04TakeDamage")
	end
end


function MerlinExOnCreated ( keys )
	-- 天生, 每击杀一个单位增加4的生命值, 250次击杀后收益减半。
	local caster = EntIndexToHScript(keys.caster_entindex)
	local MerlinExModifier = caster:FindModifierByName("modifier_MerlinEx_HealthBonus")
	if MerlinExModifier and not caster:HasModifier("modifier_illusion") then
		if MERLINEX_BONUS_COUNT == nil then
			MERLINEX_BONUS_COUNT = caster:GetModifierStackCount("modifier_MerlinEx_HealthBonus", caster)
		end
		if MERLINEX_BONUS_COUNT >= 250 then
			MERLINEX_BONUS_COUNT = MERLINEX_BONUS_COUNT + 1
			--caster:SetMaxHealth(caster:GetMaxHealth() + 2)
		else
			MERLINEX_BONUS_COUNT = MERLINEX_BONUS_COUNT + 2
			--caster:SetMaxHealth(caster:GetMaxHealth() + 4)
		end
	end
end

function MerlinExOnIntervalThink( keys )
	-- body
		local caster = EntIndexToHScript(keys.caster_entindex)
		if MERLINEX_BONUS_COUNT ~= nil then
		caster:SetModifierStackCount("modifier_MerlinEx_HealthBonus", caster, MERLINEX_BONUS_COUNT)
		end
end


function MerlinExOnattackLanded( keys )
	-- 天生，第四次攻击附带法术伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if not target:IsBuilding() then
		local MerlinExModifier = caster:FindModifierByName("modifier_MerlinEx_AttackBonus")
		local count = caster:GetModifierStackCount("modifier_MerlinEx_AttackBonus", caster)
		if count >= 3 then
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram_hit.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			caster:SetModifierStackCount("modifier_MerlinEx_AttackBonus", keys.ability, 0)
			local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = caster:GetMaxHealth() * FindValueTHD("health_percent_bonus",keys.ability)/100,
				damage_type = keys.ability:GetAbilityDamageType()
			}
			UnitDamageTarget(damage_table)
		else
			caster:SetModifierStackCount("modifier_MerlinEx_AttackBonus", keys.ability, count + 1)
		end
	end
end
