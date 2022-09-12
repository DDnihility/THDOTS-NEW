ability_thdots_flandrev2_01 = {}

function ability_thdots_flandrev2_01:GetCastRange()
	if not IsServer() then return end
	return max((self:GetCaster():Script_GetAttackRange() + 50)*5/7,220)
end

function ability_thdots_flandrev2_01:GetAbilityTextureName()
    if not self:GetCaster():HasModifier("modifier_ability_thdots_flandrev2_01_change") then
		return "custom/ability_thdots_flandrev2_01"
	else
		return "custom/ability_thdots_flandrev2_01_1"
	end
end

function ability_thdots_flandrev2_01:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_ability_thdots_flandrev2_01_change") then
	    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	 else
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
end

function ability_thdots_flandrev2_01:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_flandrev2_01_change") then
	 	return 0
	else
	 	return self.BaseClass.GetManaCost(self, level )
	end
end

function ability_thdots_flandrev2_01:GetCooldown(level)  
	--if not IsServer() then return end   直接写	FindTelentValue(self:GetCaster(),"special_bonus_unique_flandrev2_01")客户端不正常显示 直接加数字可能是权宜之计
	if self:GetCaster():HasModifier("modifier_ability_flandrev2_telent1") then
	      return self.BaseClass.GetCooldown(self, level) - 3
     else
	      return self.BaseClass.GetCooldown(self, level)
     end
end

function ability_thdots_flandrev2_01:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	if not self.caster:HasModifier("modifier_ability_thdots_flandrev2_01_change") then
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_ALLY,1)
		if is_spell_blocked(self.target) then return end
		self.target:EmitSound("flandrev201")
		ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_01/01p.vpcf", PATTACH_ABSORIGIN, self.target)
		ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_01/01p.vpcf", PATTACH_ABSORIGIN, self.target)
		ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_01/01p.vpcf", PATTACH_ABSORIGIN, self.target)
		ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_01/01p.vpcf", PATTACH_ABSORIGIN, self.target)
		ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_01/01p.vpcf", PATTACH_ABSORIGIN, self.target)
		UtilStun:UnitStunTarget(self.caster,self.target,self:GetSpecialValueFor("stuntime"))
		if self.target:IsRealHero() then
				local excount = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
				self:GetCaster():SetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire",self, excount + 1)
		end
		if self.target:GetHealth() / self.target:GetMaxHealth() < 0.5 then
				self.remain_time = self:GetCooldownTimeRemaining()
			self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_01_change",{duration = self.remain_time})
			self.nexttarget = self.target
			self:EndCooldown()
		end
		local damage_table = {
			victim = self.target,
			attacker = self.caster,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_PURE,
		}
		UnitDamageTarget(damage_table)
	else
		if  (self.nexttarget:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D() < self:GetSpecialValueFor("distance") then
			self.caster:EmitSound("flandrev201_2")
			self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1_END,1)
				self:EndCooldown()
			self.nexteff = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_01/01releasep.vpcf", PATTACH_ABSORIGIN, self.nexttarget)
			ParticleManager:SetParticleControlEnt(self.nexteff, 0, self.nexttarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self.nexttarget:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.nexteff, 2, self.nexttarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self.nexttarget:GetAbsOrigin(), true)
			self:GetCaster():RemoveModifierByName("modifier_ability_thdots_flandrev2_01_change")
			self.nexttarget:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_01_nextdamage",{duration = duration})
			if self.nexttarget:IsRealHero() then
					local excount = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
					self:GetCaster():SetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire",self, excount + 1)
			end
		else
			self:EndCooldown()
		end
	end  
end

modifier_ability_thdots_flandrev2_01_change = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_01_change","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_01_change:IsHidden() return false end
function modifier_ability_thdots_flandrev2_01_change:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_01_change:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_01_change:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_01_change:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_01_change:OnIntervalThink()
	if not IsServer() then return end
	self.count = self:GetParent():GetModifierStackCount("modifier_ability_thdots_flandrev2_01_change", nil) + 1
    self:GetCaster():SetModifierStackCount("modifier_ability_thdots_flandrev2_01_change",self:GetAbility(), self.count)
end

function modifier_ability_thdots_flandrev2_01_change:OnRemoved()
	if not IsServer() then return end
	local remain_time = self:GetAbility().remain_time - self.count * 0.1
	self:GetAbility():StartCooldown(remain_time)
end

modifier_ability_thdots_flandrev2_01_nextdamage = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_01_nextdamage","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_01_nextdamage:IsHidden() return false end
function modifier_ability_thdots_flandrev2_01_nextdamage:IsDebuff() return true end
function modifier_ability_thdots_flandrev2_01_nextdamage:IsPurgable() return true end
function modifier_ability_thdots_flandrev2_01_nextdamage:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_01_nextdamage:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_01_nextdamage:OnIntervalThink()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor("nextdamage")
	--print(damage)
	local damage_table = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
	}
	UnitDamageTarget(damage_table)
end


ability_thdots_flandrev2_02 = {}

function ability_thdots_flandrev2_02:GetIntrinsicModifierName()
	return "modifier_ability_thdots_flandrev2_02_attackrange"
end

function ability_thdots_flandrev2_02:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self.caster = self:GetCaster()
	self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_02_lifesteal",{duration = duration})
	self.caster:EmitSound("flandrev202")
end

modifier_ability_thdots_flandrev2_02_lifesteal = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_02_lifesteal","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_02_lifesteal:IsHidden() return false end
function modifier_ability_thdots_flandrev2_02_lifesteal:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_02_lifesteal:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_02_lifesteal:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_02_lifesteal:OnCreated()
	if not IsServer() then return end
	self.baseattack = self:GetCaster():GetBaseAttackTime()
	self:GetParent():SetBaseAttackTime(1.5)
	ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_02/start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	self.flan02 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_02/02parent.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self.flan022 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_02/02parent.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_ability_thdots_flandrev2_02_lifesteal:OnRemoved()
	if not IsServer() then return end
	self:GetParent():SetBaseAttackTime(self.baseattack)
	ParticleManager:DestroyParticle(self.flan02,true)
	ParticleManager:DestroyParticle(self.flan022,true)
	ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_02/start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
end

function modifier_ability_thdots_flandrev2_02_lifesteal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_flandrev2_02_lifesteal:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("attack_damage")
end

function modifier_ability_thdots_flandrev2_02_lifesteal:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsBuilding() then return end
	local lifesteal_percent = self:GetAbility():GetSpecialValueFor("lifesteal") * 0.01
    local heal_count = keys.damage * lifesteal_percent
    keys.attacker:Heal(heal_count ,keys.attacker)
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetParent(),heal_count,nil)
end

modifier_ability_thdots_flandrev2_02_attackrange = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_02_attackrange","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_02_attackrange:IsHidden() return true end
function modifier_ability_thdots_flandrev2_02_attackrange:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_02_attackrange:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_02_attackrange:RemoveOnDeath() return false end

function modifier_ability_thdots_flandrev2_02_attackrange:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_flandrev2_02_attackrange:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
    ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN, keys.target)
end


function modifier_ability_thdots_flandrev2_02_attackrange:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attack_range")
end

ability_thdots_flandrev2_04 = {}

function ability_thdots_flandrev2_04:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	if not self.caster:HasModifier("modifier_ability_thdots_flandrev2_04") then
	      if not self.caster:HasModifier("modifier_ability_thdots_flandrev2_05") then
	      	self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_04",{})
	      else
	      	self.caster:RemoveModifierByName("modifier_ability_thdots_flandrev2_05")
	      	self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_04",{})
	      end
	  else
	  	self.caster:RemoveModifierByName("modifier_ability_thdots_flandrev2_04")
	end
end

function ability_thdots_flandrev2_04:OnUpgrade()
	if self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_04"):GetLevel() == self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_05"):GetLevel() then return end
	self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_05"):SetLevel(self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_04"):GetLevel())
end

ability_thdots_flandrev2_05 = {}

function ability_thdots_flandrev2_05:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	if not self.caster:HasModifier("modifier_ability_thdots_flandrev2_05") then
	   if not self.caster:HasModifier("modifier_ability_thdots_flandrev2_04") then
	      	self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_05",{})
	      else
	      	self.caster:RemoveModifierByName("modifier_ability_thdots_flandrev2_04")
	      	self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_05",{})
	      end
	  else
	  	self.caster:RemoveModifierByName("modifier_ability_thdots_flandrev2_05")
	end
end

function ability_thdots_flandrev2_05:OnUpgrade()
	if self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_05"):GetLevel() == self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_04"):GetLevel() then return end
	self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_04"):SetLevel(self:GetCaster():FindAbilityByName("ability_thdots_flandrev2_05"):GetLevel())
end

modifier_ability_thdots_flandrev2_04 = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_04","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_04:IsHidden() return false end
function modifier_ability_thdots_flandrev2_04:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_04:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_04:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_04:OnCreated()
	self:StartIntervalThink(1.0)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_04:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_flandrev2_07") ~= 0 then return end
	local caster = self:GetCaster()
	local health = self:GetCaster():GetHealth()
	local damage = caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("lostpercent") * 0.01
	local nexthealth = health - damage
	if damage >= health then nexthealth = 1 end
	caster:SetHealth(nexthealth)
end

function modifier_ability_thdots_flandrev2_04:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_thdots_flandrev2_04:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() then return end
	if keys.unit ~= self:GetParent() then return end
	local healcount = keys.damage * self:GetAbility():GetSpecialValueFor("blockdamage") * 0.01
	local health = self:GetCaster():GetHealth() + healcount
	if not (keys.damage > self:GetCaster():GetHealth()) then keys.unit:SetHealth(health) end
	local cooldown = self:GetAbility():GetSpecialValueFor("cooldown") - FindTelentValue(self:GetCaster(),"special_bonus_unique_flandrev2_04")
	if keys.unit:HasModifier("modifier_ability_thdots_flandrev2_0405") then return end
	keys.unit:AddNewModifier(keys.unit,self:GetAbility(),"modifier_ability_thdots_flandrev2_0405",{duration = cooldown})
end

modifier_ability_thdots_flandrev2_05 = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_05","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_05:IsHidden() return false end
function modifier_ability_thdots_flandrev2_05:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_05:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_05:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_05:OnCreated()
	self:StartIntervalThink(1.0)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_05:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_flandrev2_07") ~= 0 then return end
	local caster = self:GetCaster()
	local health = self:GetCaster():GetHealth()
	local damage = caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("lostpercent") * 0.01
	local nexthealth = health - damage
	if damage >= health then nexthealth = 1 end
	caster:SetHealth(nexthealth)
end

function modifier_ability_thdots_flandrev2_05:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_flandrev2_05:OnAttackLanded(keys)	
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	--print((keys.attacker:GetAbsOrigin() - keys.target:GetAbsOrigin()):Length2D())
	local cooldown = self:GetAbility():GetSpecialValueFor("cooldown") - FindTelentValue(self:GetCaster(),"special_bonus_unique_flandrev2_04")
	if keys.attacker:HasModifier("modifier_ability_thdots_flandrev2_0405") then return end
	keys.attacker:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_thdots_flandrev2_0405",{duration = cooldown})
end

modifier_ability_thdots_flandrev2_0405 = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_0405","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_0405:IsHidden() return true end
function modifier_ability_thdots_flandrev2_0405:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_0405:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_0405:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_0405:OnCreated()
	if not IsServer() then return end
	ParticleManager:CreateParticle("particles/heroes/flandre/ability_flandre_04_buff.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	self:GetCaster():EmitSound("flandrev20405")
	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_7,1)
	local caster = self:GetCaster()
	local radiu = self:GetCaster():Script_GetAttackRange() + 50 --脚底下那个圈的半径
	--print(self:GetCaster():Script_GetAttackRange())
	local damage = self:GetCaster():GetDamageMax() * self:GetAbility():GetSpecialValueFor("percent") * 0.01
	local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radiu,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
		,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	for hh,sb in pairs(heros) do 
		local damage_table = {
			victim = sb,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		UnitDamageTarget(damage_table)
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_flandrev2_08") ~= 0 then
		    caster:Heal(damage * 0.3 ,caster)
            SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetParent(),damage * 0.3,nil)
		end
		if sb and not sb:IsNull() and sb:IsRealHero() then 
                local excount = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
                self:GetCaster():SetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire",self, excount + 1)
        end  
	end
end

ability_thdots_flandrev2_03 = {}

function ability_thdots_flandrev2_03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_flandrev2_03_bloodfire"
end

modifier_ability_thdots_flandrev2_03_bloodfire = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_03_bloodfire","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_03_bloodfire:IsHidden() return false end
function modifier_ability_thdots_flandrev2_03_bloodfire:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_03_bloodfire:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_03_bloodfire:RemoveOnDeath() return false end

function modifier_ability_thdots_flandrev2_03_bloodfire:OnCreated()
	if not IsServer() then return end
	-- self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_thdots_flandrev2_lvlup",{})
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_03_bloodfire:OnIntervalThink()
	if not IsServer() then return end
	   if  self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil) >= 200 then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_flandrev2_03_thirst",{})
	end
	    if FindTelentValue(self:GetParent(),"special_bonus_unique_flandrev2_03") ~= 0 and not self:GetParent():HasModifier("modifier_ability_flandrev2_telent3") then 
    	self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_flandrev2_telent3",{}) end
    	if FindTelentValue(self:GetParent(),"special_bonus_unique_flandrev2_06") ~= 0 and not self:GetParent():HasModifier("modifier_ability_flandrev2_telent6") then 
    	self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_flandrev2_telent6",{}) end
    	if FindTelentValue(self:GetParent(),"special_bonus_unique_flandrev2_01") ~= 0 and not self:GetParent():HasModifier("modifier_ability_flandrev2_telent1") then 
    	self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_flandrev2_telent1",{}) end
    	if FindTelentValue(self:GetParent(),"special_bonus_unique_flandrev2_02") ~= 0 and not self:GetParent():HasModifier("modifier_ability_flandrev2_telent2") then 
    	self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_flandrev2_telent2",{}) end
end

function modifier_ability_thdots_flandrev2_03_bloodfire:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_thdots_flandrev2_03_bloodfire:GetModifierMoveSpeedBonus_Constant()
	local count = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
	return count * 0.2
end

function modifier_ability_thdots_flandrev2_03_bloodfire:GetModifierPreAttack_BonusDamage()
	local count = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
	return count * 0.25
end

function modifier_ability_thdots_flandrev2_03_bloodfire:GetModifierHealthBonus()
	local count = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
	return count * ( 1 + FindTelentValue(self:GetParent(),"special_bonus_unique_flandrev2_05") )
end

function modifier_ability_thdots_flandrev2_03_bloodfire:OnDeath(event)
	if not event.unit:IsRealHero() then return end
	--print_r(event)
	if event.attacker == self:GetParent() then 
        local excount = self:GetCaster():GetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire", nil)
        self:GetCaster():SetModifierStackCount("modifier_ability_thdots_flandrev2_03_bloodfire",self, excount + 10)
    end
end

modifier_ability_thdots_flandrev2_03_thirst = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_03_thirst","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_03_thirst:IsHidden() return false end
function modifier_ability_thdots_flandrev2_03_thirst:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_03_thirst:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_03_thirst:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_03_thirst:OnCreated()
	local caster = self:GetCaster()
	self.flan03 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	self.flan04 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	self.flan05 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	self.flan06 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	    ParticleManager:DestroyParticle(self.flan03,true)
	    ParticleManager:DestroyParticle(self.flan04,true)
	    ParticleManager:DestroyParticle(self.flan05,true)
	    ParticleManager:DestroyParticle(self.flan06,true)
	self.flan03think = 0
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_bloodseeker_thirst", {})
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_03_thirst:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_thdots_flandrev2_03_thirst:OnIntervalThink()
	if not IsServer() then return end
	local totalheal = 0
	local totalmaxheal = 1
	local caster = self:GetCaster()
	local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,999999,DOTA_UNIT_TARGET_TEAM_ENEMY --对范围内的敌人造成效果
		,DOTA_UNIT_TARGET_HERO,0,0,false)
	for hh,sb in pairs(heros) do
		totalheal = totalheal + sb:GetHealth()
		totalmaxheal = totalmaxheal + sb:GetMaxHealth()
		if sb:GetHealth() / sb:GetMaxHealth() < 0.4 then
		 sb:AddNewModifier(caster,self:GetAbility(),"modifier_ability_thdots_flandrev2_03_sight",{}) 
         AddFOWViewer( caster:GetTeam(), sb:GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("radiu"), 0.51, false)
		else
		 sb:RemoveModifierByName("modifier_ability_thdots_flandrev2_03_sight") end
	end
	local bloodpercent = 1 - totalheal / totalmaxheal
	--print(bloodpercent)
	local speednum = self:GetAbility():GetSpecialValueFor("speedbonus")
	self.speedbonus = speednum * bloodpercent
	if #heros == 0 then self.speedbonus = 0 end
	self:GetCaster():SetModifierStackCount("modifier_ability_thdots_flandrev2_03_thirst",self:GetAbility(), self.speedbonus)
	if self:GetCaster():GetIdealSpeed() > 580 then 
		if self.flan03think == 0 then
	         self.flan03 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())  
	         ParticleManager:DestroyParticle(self.flan04,true)
	    end 
		if self.flan03think == 1 then
	         self.flan04 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
	         ParticleManager:DestroyParticle(self.flan05,true) 
	    end 
		if self.flan03think == 2 then
	         self.flan05 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())  
	         ParticleManager:DestroyParticle(self.flan06,true)
	    end  
		if self.flan03think == 3 then
	         self.flan06 = ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())  
	         ParticleManager:DestroyParticle(self.flan03,true)
	         self.flan03think = -1 
	    end 
	self.flan03think = self.flan03think + 1 end
end

function modifier_ability_thdots_flandrev2_03_thirst:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end

function modifier_ability_thdots_flandrev2_03_thirst:GetModifierMoveSpeed_Limit()
	return 999999
end

modifier_ability_thdots_flandrev2_03_sight = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_03_sight","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_03_sight:IsHidden() return false end
function modifier_ability_thdots_flandrev2_03_sight:IsDebuff() return true end
function modifier_ability_thdots_flandrev2_03_sight:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_03_sight:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_03_sight:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]  = false,
	}
end

ability_thdots_flandrev2_06 = {}

function ability_thdots_flandrev2_06:GetIntrinsicModifierName()
	return "modifier_ability_thdots_flandrev2_06_passive"
end

function ability_thdots_flandrev2_06:GetCastRange()
	return self:GetCaster():Script_GetAttackRange() * 2
end

function ability_thdots_flandrev2_06:GetCooldown(level)  
	--if not IsServer() then return end   加了客户端就显示不了了	
	if self:GetCaster():HasModifier("modifier_ability_flandrev2_telent2") then
	      return self.BaseClass.GetCooldown(self, level) - 10
     else
	      return self.BaseClass.GetCooldown(self, level)
     end
end

function ability_thdots_flandrev2_06:OnSpellStart()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
    self.caster:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_06_active",{})
    self.caster:MoveToNPC(self.target)
	self.caster:EmitSound("Voice_Thdots_Flandre.AbilityFlandre04")
    self.target:AddNewModifier(self.caster,self,"modifier_ability_thdots_flandrev2_06_vision",{})
end

modifier_ability_thdots_flandrev2_06_active = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_06_active","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_06_active:IsHidden() return true end
function modifier_ability_thdots_flandrev2_06_active:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_06_active:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_06_active:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_06_active:OnCreated()
	ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_04.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end


function modifier_ability_thdots_flandrev2_06_active:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_ability_thdots_flandrev2_06_active:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_STUNNED] = false,
	}
end

function modifier_ability_thdots_flandrev2_06_active:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	keys.attacker:RemoveModifierByName("modifier_ability_thdots_flandrev2_06_active")
	keys.target:RemoveModifierByName("modifier_ability_thdots_flandrev2_06_vision")
	local night_duration = self:GetAbility():GetSpecialValueFor("night_duration")
	CreateModifierThinker(keys.attacker,self:GetAbility(),"modifier_ability_thdots_flandrev2_06_night",{duration = night_duration},keys.attacker:GetAbsOrigin(),keys.attacker:GetTeamNumber(),false)
	--print(night_duration)
end

function modifier_ability_thdots_flandrev2_06_active:GetModifierMoveSpeed_Absolute()
	return 1000
end

function modifier_ability_thdots_flandrev2_06_active:OnDeath(keys)
	if keys.unit == self:GetCaster() then self:GetCaster():RemoveModifierByName("modifier_ability_thdots_flandrev2_06_active") end
end

modifier_ability_thdots_flandrev2_06_night = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_06_night","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_06_night:IsHidden() return true end
function modifier_ability_thdots_flandrev2_06_night:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_06_night:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_06_night:RemoveOnDeath() return false end

function modifier_ability_thdots_flandrev2_06_night:OnCreated()
	if not IsServer() then return end
	if self.lasttime == nil then
		self.lasttime = GameRules:GetTimeOfDay()
	end
	GameRules:SetTimeOfDay(0)
	--print(self.lasttime)
end

function modifier_ability_thdots_flandrev2_06_night:OnRemoved()
	if not IsServer() then return end
	GameRules:SetTimeOfDay(self.lasttime)
	self.lasttime = nil
end

modifier_ability_thdots_flandrev2_06_passive = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_06_passive","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_06_passive:IsHidden()
	if not IsServer() then return end  
	if not GameRules:IsDaytime() then 
         return false
     else
     	return true
      end
end
function modifier_ability_thdots_flandrev2_06_passive:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_06_passive:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_06_passive:RemoveOnDeath() return false end

function modifier_ability_thdots_flandrev2_06_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_ability_thdots_flandrev2_06_passive:GetModifierConstantHealthRegen()
	if not IsServer() then return end
	if not GameRules:IsDaytime() then 
	    return self:GetAbility():GetSpecialValueFor("heal")
	else
		return 0
	end
end

function modifier_ability_thdots_flandrev2_06_passive:OnAttackStart(keys)
	if GameRules:IsDaytime() then return end
	if keys.attacker ~= self:GetCaster() then return end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	self.i = RandomInt(0,99)
	if self. i >= chance then return end
	keys.attacker:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_thdots_flandrev2_06_crit",{})
end

modifier_ability_thdots_flandrev2_06_crit = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_06_crit","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_06_crit:IsHidden() return true end
function modifier_ability_thdots_flandrev2_06_crit:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_06_crit:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_06_crit:RemoveOnDeath() return false end

function modifier_ability_thdots_flandrev2_06_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_flandrev2_06_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("crit")
end

function modifier_ability_thdots_flandrev2_06_crit:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
    keys.attacker:RemoveModifierByName("modifier_ability_thdots_flandrev2_06_crit")
end

modifier_ability_thdots_flandrev2_06_vision = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_06_vision","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_06_vision:IsHidden() return false end
function modifier_ability_thdots_flandrev2_06_vision:IsDebuff() return true end
function modifier_ability_thdots_flandrev2_06_vision:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_06_vision:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_06_vision:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_UNIT_MOVED,
	}
end

function modifier_ability_thdots_flandrev2_06_vision:OnUnitMoved(keys)
     if keys.unit ~= self:GetCaster() then return end
     if ((keys.unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()) < 200 then
     	keys.unit:MoveToTargetToAttack(self:GetParent())
     end
end

function modifier_ability_thdots_flandrev2_06_vision:OnCreated()
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_06_vision:OnIntervalThink()
	if not IsServer() then return end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 100, 0.51, false)
	if self.point == self:GetCaster():GetAbsOrigin() then self:GetCaster():RemoveModifierByName("modifier_ability_thdots_flandrev2_06_active") end
	self.point = self:GetCaster():GetAbsOrigin()
end

function modifier_ability_thdots_flandrev2_06_vision:OnRemoved()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_ability_thdots_flandrev2_06_active")
end
 
ability_thdots_flandrev2_wanbaochui = {}

function ability_thdots_flandrev2_wanbaochui:OnInventoryContentsChanged()
	if not IsServer() then return end
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			self:SetHidden(true)
		end
end

function ability_thdots_flandrev2_wanbaochui:OnSpellStart()
	local duration = self:GetSpecialValueFor("duration") + 2
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_thdots_flandrev2_naotan",{duration = duration})
end

modifier_ability_thdots_flandrev2_naotan = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_naotan","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_naotan:IsHidden() return false end
function modifier_ability_thdots_flandrev2_naotan:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_naotan:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_naotan:RemoveOnDeath() return true end

function modifier_ability_thdots_flandrev2_naotan:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_DAMAGE_CALCULATED,
	}
end

function modifier_ability_thdots_flandrev2_naotan:CheckState()
	return {	
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end

function modifier_ability_thdots_flandrev2_naotan:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("stats")
end

function modifier_ability_thdots_flandrev2_naotan:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("stats")
end

function modifier_ability_thdots_flandrev2_naotan:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("stats")
end

function modifier_ability_thdots_flandrev2_naotan:OnCreated()
	if not IsServer() then return end
	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,1)
	self.wait = 0
	self.original_team = self:GetCaster():GetTeam()
	self:GetCaster():SetTeam(6)
	self:StartIntervalThink(0.1)
	self:OnIntervalThink()
end

function modifier_ability_thdots_flandrev2_naotan:OnRemoved()
	self:GetCaster():SetTeam(self.original_team)
end

function modifier_ability_thdots_flandrev2_naotan:OnIntervalThink()
	if not IsServer() then return end
	self.wait = self.wait + 0.1	
         AddFOWViewer( self.original_team, self:GetCaster():GetAbsOrigin(), 1000, 0.11, false)
	if self.wait < 2 then return end
		if self.wait < 2.03 then
	         ParticleManager:CreateParticle("particles/thd2/heroes/flandrev2/flandrev2_wanbaochui/omniknight_guardian_angel_omni.vpcf", PATTACH_ABSORIGIN, self:GetCaster())        
	         self:GetCaster():EmitSound("flandrev2wanbao")
             self:GetCaster():EmitSound("Voice_Thdots_Flandre.AbilityFlandre04")
	    end
	local caster = self:GetCaster()
	local targets

		targets = FindUnitsInRadius(
			caster:GetTeam(),	
			caster:GetOrigin(),	
			nil,	
			1000,		
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING,
			0, 
			FIND_CLOSEST,
			false
		)
	for i=1,#targets do 
		if targets[i]~=nil and targets[i]:IsInvisible()==false 
			and targets[i]:GetUnitName()~="npc_reimu_04_dummy_unit" 
			and targets[i]:GetUnitName()~="ability_yuuka_flower" 
			and targets[i]:GetUnitName()~="npc_dota_watch_tower" 
			and targets[i]:GetUnitName()~="npc_ability_parsee03_dummy" 
			and not targets[i]:IsAttackImmune()
			then
			caster:MoveToTargetToAttack(targets[i])
			break
		end
	end
end

function modifier_ability_thdots_flandrev2_naotan:OnDamageCalculated(keys)
	if keys.attacker ~= self:GetParent() then return end
	--print_r(keys)
	if not keys.target:IsRealHero() then return end
	if keys.target:GetHealth() <= keys.damage then
	   keys.target:SetHealth(1)
	   self:GetCaster():SetTeam(self.original_team)
	   keys.target:Kill(self:GetAbility(), keys.attacker)
	   self:GetCaster():SetTeam(4)
    end
end



modifier_ability_flandrev2_telent3 = {}
LinkLuaModifier("modifier_ability_flandrev2_telent3","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_flandrev2_telent3:IsHidden() return true end
function modifier_ability_flandrev2_telent3:IsDebuff() return false end
function modifier_ability_flandrev2_telent3:IsPurgable() return false end
function modifier_ability_flandrev2_telent3:RemoveOnDeath() return false end

function modifier_ability_flandrev2_telent3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_flandrev2_telent3:GetModifierMoveSpeedBonus_Percentage()
	return 10
end

modifier_ability_flandrev2_telent6 = {}
LinkLuaModifier("modifier_ability_flandrev2_telent6","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_flandrev2_telent6:IsHidden() return true end
function modifier_ability_flandrev2_telent6:IsDebuff() return false end
function modifier_ability_flandrev2_telent6:IsPurgable() return false end
function modifier_ability_flandrev2_telent6:RemoveOnDeath() return false end

function modifier_ability_flandrev2_telent6:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_ability_flandrev2_telent6:GetModifierAttackRangeBonus()
	return 150
end

modifier_ability_flandrev2_telent1 = {}
LinkLuaModifier("modifier_ability_flandrev2_telent1","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_flandrev2_telent1:IsHidden() return true end
function modifier_ability_flandrev2_telent1:IsDebuff() return false end
function modifier_ability_flandrev2_telent1:IsPurgable() return false end
function modifier_ability_flandrev2_telent1:RemoveOnDeath() return false end

modifier_ability_flandrev2_telent2 = {}
LinkLuaModifier("modifier_ability_flandrev2_telent2","scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_flandrev2_telent2:IsHidden() return true end
function modifier_ability_flandrev2_telent2:IsDebuff() return false end
function modifier_ability_flandrev2_telent2:IsPurgable() return false end
function modifier_ability_flandrev2_telent2:RemoveOnDeath() return false end

modifier_ability_thdots_flandrev2_lvlup = {}
LinkLuaModifier("modifier_ability_thdots_flandrev2_lvlup", "scripts/vscripts/abilities/abilityflandrev2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandrev2_lvlup:IsHidden() return false end
function modifier_ability_thdots_flandrev2_lvlup:IsDebuff() return false end
function modifier_ability_thdots_flandrev2_lvlup:IsPurgable() return false end
function modifier_ability_thdots_flandrev2_lvlup:RemoveOnDeath() return false end

function modifier_ability_thdots_flandrev2_lvlup:OnCreated()
	if not IsServer() then return end
	self:GetParent():SetBaseAttackTime(1.8)
	self:GetParent():SetBaseDamageMax(41)
	self:GetParent():SetBaseDamageMin(40)
	self:GetParent():SetBaseMoveSpeed(305)
	self:GetParent():SetBaseStrength(30)
    self:GetParent():SetBaseAgility(18)
    self:GetParent():SetBaseIntellect(18)
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
end

function modifier_ability_thdots_flandrev2_lvlup:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
		MODIFIER_PROPERTY_FIXED_DAY_VISION,
	}
end

function modifier_ability_thdots_flandrev2_lvlup:GetModifierAttackRangeBonus()
	return 30
end

function modifier_ability_thdots_flandrev2_lvlup:GetModifierBonusStats_Strength()
	return 0.5 * self:GetCaster():GetLevel()
end

function modifier_ability_thdots_flandrev2_lvlup:GetModifierBonusStats_Agility()
	return - 1 * self:GetCaster():GetLevel()
end

function modifier_ability_thdots_flandrev2_lvlup:GetModifierBonusStats_Intellect()
	return 0.2 * self:GetCaster():GetLevel()
end

function modifier_ability_thdots_flandrev2_lvlup:GetFixedNightVision()
    return 1500
end

function modifier_ability_thdots_flandrev2_lvlup:GetFixedDayVision()
	return 600
end
