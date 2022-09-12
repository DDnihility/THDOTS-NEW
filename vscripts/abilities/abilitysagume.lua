ability_thdots_sagume_1 = {}

function ability_thdots_sagume_1:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage") + FindTelentValue(caster,"special_bonus_unique_sagume_6")
	ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_loadout.vpcf", PATTACH_ABSORIGIN,target)
	target:EmitSound("sagume01")
	UtilSilence:UnitSilenceTarget( caster,target,self:GetSpecialValueFor("stuntime")+FindTelentValue(self:GetCaster(),"special_bonus_unique_sagume_3"))
	local damage_table = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
	--UtilStun:UnitStunTarget(caster,target,self:GetSpecialValueFor("stuntime"))
end




ability_thdots_sagume_2 = {}

function ability_thdots_sagume_2:GetBehavior()
	if self:GetCaster():HasModifier("modifier_ability_sagume_telent7_check") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_POINT
	end
end

function ability_thdots_sagume_2:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_ability_sagume_telent7_check") then
		return 0
	else
		return self.BaseClass.GetManaCost(self,level)
	end
end

function ability_thdots_sagume_2:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local cast_range = self:GetSpecialValueFor("cast_range") -- FindTelentValue(caster,"special_bonus_unique_sagume_6")
    if not caster:HasModifier("modifier_ability_sagume_telent7_check") then 
    local point = self:GetCursorPosition()
    self.point = caster:GetAbsOrigin()
    if caster:HasModifier("modifier_item_wanbaochui") then
	    local victims = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
	 	    ,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	    for hh,sb in pairs(victims) do
        	caster:PerformAttack(sb, true, true, true, true, true, false, false)
        end
    end
    caster:EmitSound("sagumeblink")
	ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_end.vpcf", PATTACH_ABSORIGIN,caster)
	if (point - self.point):Length2D() > cast_range then point = self.point + (point-self.point):Normalized()*cast_range end
    FindClearSpaceForUnit(caster,point,true)
		caster:AddNewModifier(caster, self, "modifier_ability_sagume_2_bounce", {duration = self:GetSpecialValueFor("bounce_duration")})
    if caster:HasModifier("modifier_item_wanbaochui") then
	    local victims = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
	 	    ,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	    for hh,sb in pairs(victims) do
        	caster:PerformAttack(sb, true, true, true, true, true, false, false)
        end
    end
    if FindTelentValue(caster,"special_bonus_unique_sagume_7") ~= 0 then
    	caster:AddNewModifier(caster,self,"modifier_ability_sagume_telent7_check",{duration = self:GetEffectiveCooldown(self:GetLevel())})
    	self:EndCooldown()
    end
    else
    if caster:HasModifier("modifier_item_wanbaochui") then
	    local victims = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
	 	    ,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	    for hh,sb in pairs(victims) do
        	caster:PerformAttack(sb, true, true, true, true, true, false, false)
        end
    end
    caster:EmitSound("sagumeblink")
	ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_end.vpcf", PATTACH_ABSORIGIN,caster)
    FindClearSpaceForUnit(caster,self.point,true)
    if caster:HasModifier("modifier_item_wanbaochui") then
	    local victims = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
	 	    ,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	    for hh,sb in pairs(victims) do
        	caster:PerformAttack(sb, true, true, true, true, true, false, false)
        end
    end
    caster:RemoveModifierByName("modifier_ability_sagume_telent7_check")
    end
end

function ability_thdots_sagume_2:OnBouncing(source, times)
	if not IsServer() then return end
	local bounce_target = nil
	local targets = FindUnitsInRadius(
		self:GetCaster():GetTeam(),
		source:GetAbsOrigin(),
		nil,
		self:GetSpecialValueFor("bounce_range"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
		FIND_ANY_ORDER,
		false
	)
	for _, t in pairs(targets) do
		if t ~= source then
			bounce_target = t
			break
		end
	end
	if bounce_target == nil then return end
	ProjectileManager:CreateTrackingProjectile({
		Ability = self,
		Target = bounce_target,
		Source = source,
		EffectName = "particles/units/heroes/hero_queenofpain/queen_base_attack.vpcf",
		iMoveSpeed = self:GetCaster():IsRangedAttacker() and self:GetCaster():GetProjectileSpeed() or 900,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = { bounce_times = times }
	})
end

function ability_thdots_sagume_2:OnProjectileHit_ExtraData(target, loc, data)
	if not IsServer() then return end

	if target and not target:IsNull() then
		local rate = 1 - self:GetSpecialValueFor("bounce_decay") / 100
		local damage = self:GetCaster():GetAttackDamage() * rate ^ data.bounce_times
		UnitDamageTarget({
			victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL
		})

		if target and not target:IsNull() then
			local sagume03 = self:GetCaster():FindModifierByName("modifier_ability_sagume3_passive")
			if sagume03 then
				local extra_damage = self:GetCaster():GetIntellect() * (sagume03:GetAbility():GetSpecialValueFor("intellect_bonus") + FindTelentValue(self:GetCaster(), "special_bonus_unique_sagume_4"))
				local damage_type = sagume03:GetAbility():GetAbilityDamageType() 
				if FindTelentValue(self:GetCaster(), "special_bonus_unique_sagume_8") ~= 0 then
					damage_type = DAMAGE_TYPE_PURE
				end
				UnitDamageTarget({
					victim = target,
					attacker = self:GetCaster(),
					damage = extra_damage,
					damage_type = damage_type
				})
			end
			local max_bounce_times = self:GetSpecialValueFor("max_bounce_times")+FindTelentValue(self:GetCaster(),"special_bonus_unique_sagume_5")
			if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
				max_bounce_times = max_bounce_times - 1
			end
			if data.bounce_times >= max_bounce_times then return end
			self:OnBouncing(target, data.bounce_times + 1)
		end
	end
end

modifier_ability_sagume_2_bounce = {}
LinkLuaModifier("modifier_ability_sagume_2_bounce", "scripts/vscripts/abilities/abilitysagume.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_sagume_2_bounce:IsHidden() return false end
function modifier_ability_sagume_2_bounce:IsDebuff() return false end
function modifier_ability_sagume_2_bounce:IsPurgable() return true end
function modifier_ability_sagume_2_bounce:RemoveOnDeath() return true end

function modifier_ability_sagume_2_bounce:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_sagume_2_bounce:OnAttackLanded(event)
	if not IsServer() then return end
	if event.attacker ~= self:GetParent() or event.target:IsOther() then return end
	self:GetAbility():OnBouncing(event.target, 1)
end

modifier_ability_sagume_telent7_check = {}
LinkLuaModifier("modifier_ability_sagume_telent7_check","scripts/vscripts/abilities/abilitysagume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_sagume_telent7_check:IsHidden() return false end
function modifier_ability_sagume_telent7_check:IsDebuff() return false end
function modifier_ability_sagume_telent7_check:IsPurgable() return false end
function modifier_ability_sagume_telent7_check:RemoveOnDeath() return false end

function modifier_ability_sagume_telent7_check:OnRemoved()
	if not IsServer() then return end
	self:GetAbility():StartCooldown(self:GetRemainingTime())
end

ability_thdots_sagume_3 = {}

function ability_thdots_sagume_3:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local mana = self:GetCaster():GetMana()
	if self:GetToggleState() then
	 	caster:AddNewModifier(caster,self,"modifier_ability_sagume3_passive",{})
	    caster:SetMana(mana + self:GetManaCost(self:GetLevel()))
	else
		caster:RemoveModifierByName("modifier_ability_sagume3_passive")
	end
end

modifier_ability_sagume3_passive = {}
LinkLuaModifier("modifier_ability_sagume3_passive","scripts/vscripts/abilities/abilitysagume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_sagume3_passive:IsHidden() return true end
function modifier_ability_sagume3_passive:IsDebuff() return false end
function modifier_ability_sagume3_passive:IsPurgable() return false end
function modifier_ability_sagume3_passive:RemoveOnDeath() return false end

function modifier_ability_sagume3_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_sagume3_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if keys.attacker ~= caster then return end
	if keys.target:GetTeam() == caster:GetTeam() then return end
	if keys.target:IsBuilding() then return end
	local mana_cost = self:GetAbility():GetManaCost(self:GetAbility():GetLevel())
	if self:GetCaster():GetMana() < mana_cost then return end
	caster:SpendMana(mana_cost,self:GetAbility())
	local damage = caster:GetIntellect() * (self:GetAbility():GetSpecialValueFor("intellect_bonus") + FindTelentValue(self:GetCaster(),"special_bonus_unique_sagume_4"))
	local damage_type = self:GetAbility():GetAbilityDamageType() 
	if FindTelentValue(caster,"special_bonus_unique_sagume_8") ~= 0 then
		damage_type = DAMAGE_TYPE_PURE
	end
	local damage_table = {
		victim = keys.target,
		attacker = caster,
		damage = damage,
		damage_type = damage_type,
	}
	if damage_type == DAMAGE_TYPE_PURE then
	    SendOverheadEventMessage(nil,OVERHEAD_ALERT_DAMAGE,keys.target,damage,nil)
    else
	    SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,keys.target,damage,nil)
	end
	UnitDamageTarget(damage_table)
end

ability_thdots_sagume_4 = {}

function ability_thdots_sagume_4:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_sagume_telent5") then
	    return self.BaseClass.GetCooldown(self, level) - 20
    else
	    return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_sagume_4:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN,target)
    target:EmitSound("sagume04")
	print(target:GetAbilityCount())
    for spell_id = 0,target:GetAbilityCount()-1 do
    	local ability = target:GetAbilityByIndex(spell_id)
    	if ability ~= nil then
    	    if ability:GetCooldownTimeRemaining() ~= 0 then
    		    ability:EndCooldown()
        	else
        		if ability:GetCooldownTime() ~= nil then 
    		        ability:StartCooldown(ability:GetEffectiveCooldown(self:GetLevel()))
    		    end
    	    end
    	end
    end

    for item_id = 0, 20 do
		local item_in_target = target:GetItemInSlot(item_id)	
		if item_in_target ~= nil then
		    if item_in_target:GetCooldownTimeRemaining() ~= 0 then
		    	item_in_target:EndCooldown()
		    else
		    	if item_in_target:GetCooldownTime() ~= nil then
		    	    item_in_target:StartCooldown(item_in_target:GetEffectiveCooldown(self:GetLevel()))
		    	end
		    end
		end
	end

	if caster == target then self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel())) end
	if caster:HasModifier("modifier_ability_sagume_telent7_check") then
		caster:RemoveModifierByName("modifier_ability_sagume_telent7_check")
		caster:GetAbilityByIndex(1):EndCooldown()
	end
end

ability_thdots_sagume_Ex = {}

function ability_thdots_sagume_Ex:GetIntrinsicModifierName()
	return "modifier_sagumeEx_basic"
end

modifier_sagumeEx_basic = {}
LinkLuaModifier("modifier_sagumeEx_basic","scripts/vscripts/abilities/abilitysagume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_sagumeEx_basic:IsHidden() return false end
function modifier_sagumeEx_basic:IsDebuff() return false end
function modifier_sagumeEx_basic:IsPurgable() return false end
function modifier_sagumeEx_basic:RemoveOnDeath() return false end

function modifier_sagumeEx_basic:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_sagumeEx_basic:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function modifier_sagumeEx_basic:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
	self:SetStackCount(0)
end

function modifier_sagumeEx_basic:OnDeath(keys)
	if not IsServer() then return end
    local caster = self:GetParent()
	if keys.unit:GetTeam() == caster:GetTeam() then return end
	if not keys.unit:IsRealHero() then return end
	if keys.attacker == caster then self:SetStackCount(self:GetStackCount()+2) return end
	if (keys.unit:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("limit") then return end
	self:SetStackCount(self:GetStackCount()+2)
end

function modifier_sagumeEx_basic:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_sagume_5") ~= 0 and not self:GetParent():HasModifier("modifier_ability_sagume_telent5") then 
    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_sagume_telent5",{}) end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_sagume_6") ~= 0 and not self:GetParent():HasModifier("modifier_ability_sagume_telent6") then 
    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_sagume_telent6",{}) end
end

modifier_ability_sagume_telent5 = {}
LinkLuaModifier("modifier_ability_sagume_telent5","scripts/vscripts/abilities/abilitysagume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_sagume_telent5:IsHidden() return true end
function modifier_ability_sagume_telent5:IsPurgable() return false end
function modifier_ability_sagume_telent5:IsDebuff() return false end
function modifier_ability_sagume_telent5:RemoveOnDeath() return false end

modifier_ability_sagume_telent6 = {}
LinkLuaModifier("modifier_ability_sagume_telent6","scripts/vscripts/abilities/abilitysagume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_sagume_telent6:IsHidden() return true end
function modifier_ability_sagume_telent6:IsPurgable() return false end
function modifier_ability_sagume_telent6:IsDebuff() return false end
function modifier_ability_sagume_telent6:RemoveOnDeath() return false end
