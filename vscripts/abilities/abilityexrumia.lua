ability_thdots_exrumia01 = {}

function ability_thdots_exrumia01:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_exrumia01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	--print(duration)
    local thinker = CreateModifierThinker(caster,self,"modifier_ability_exrumia01_effect",{duration = duration},target:GetAbsOrigin(),target:GetTeamNumber(),false)
    ParticleManager:CreateParticle("particles/thd2/heroes/rumia/ability_rumia01_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, thinker)
    target:AddNewModifier(thinker,self,"modifier_ability_exrumia01_shadow",{duration = duration})
    if target:GetTeam() ~= caster:GetTeam() then target:AddNewModifier(caster,self,"modifier_ability_exrumia01_disable",{duration = duration / 2}) end
	caster:EmitSound("Voice_Thdots_Rumia.AbilityRumia01")
end


modifier_ability_exrumia01_effect = {}
LinkLuaModifier("modifier_ability_exrumia01_effect","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)

modifier_ability_exrumia01_shadow = {}
LinkLuaModifier("modifier_ability_exrumia01_shadow","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia01_shadow:IsHidden() return false end
function modifier_ability_exrumia01_shadow:IsPurgable() return false end
function modifier_ability_exrumia01_shadow:IsDebuff() return false end
function modifier_ability_exrumia01_shadow:RemoveOnDeath() return true end

function modifier_ability_exrumia01_shadow:OnCreated()	
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
	self:OnIntervalThink()
end

function modifier_ability_exrumia01_shadow:OnIntervalThink()
	if not IsServer() then return end
	if self:GetCaster()~=nil and self:GetCaster():IsNull() == false then
		self:GetCaster():SetOrigin(self:GetParent():GetAbsOrigin())
	end
end

function modifier_ability_exrumia01_shadow:OnRemoved()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_ability_exrumia01_effect")
end

function modifier_ability_exrumia01_shadow:DeclareFunctions()
	if not IsServer() then return end
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
 end

function modifier_ability_exrumia01_shadow:CheckState()
	if not IsServer() then return end
	return {
		[MODIFIER_STATE_INVISIBLE] = true ,
	}
end

function modifier_ability_exrumia01_shadow:GetModifierEvasion_Constant()
	if not IsServer() then return end
	return self:GetAbility():GetSpecialValueFor("evasion")
end

modifier_ability_exrumia01_disable = {}
LinkLuaModifier("modifier_ability_exrumia01_disable","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia01_disable:IsHidden() return false end
function modifier_ability_exrumia01_disable:IsPurgable() return true end
function modifier_ability_exrumia01_disable:IsDebuff() return true end
function modifier_ability_exrumia01_disable:RemoveOnDeath()return true end

function modifier_ability_exrumia01_disable:CheckState()
	if not IsServer() then return end
	return {
		[MODIFIER_STATE_DISARMED] = true ,
		[MODIFIER_STATE_SILENCED] = true ,
		[MODIFIER_STATE_MUTED] = true ,
	}
end

function modifier_ability_exrumia01_disable:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_exrumia01_disable:GetModifierMoveSpeedBonus_Percentage()
	return - self:GetAbility():GetSpecialValueFor("slow")
end


ability_thdots_exrumia02 = {} 

--[[function ability_thdots_exrumia02:GetIntrinsicModifierName()
	return "modifier_ability_exrumia02_attackspeed"
end]]

function ability_thdots_exrumia02:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	if self:GetCaster():HasModifier("modifier_ability_exrumiaEx_telent2") then duration = duration + 2 end
	self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_exrumia02_attack",{duration = duration})
	self:GetCaster():EmitSound("exrumia02")
end

--[[modifier_ability_exrumia02_attackspeed = {}
LinkLuaModifier("modifier_ability_exrumia02_attackspeed","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia02_attackspeed:IsHidden() return true end
function modifier_ability_exrumia02_attackspeed:IsDebuff() return false end
function modifier_ability_exrumia02_attackspeed:IsPurgable() return false end
function modifier_ability_exrumia02_attackspeed:RemoveOnDeath() return false end

function modifier_ability_exrumia02_attackspeed:OnCreated()
	self:StartIntervalThink(0.03)
	self:OnIntervalThink()
end

function modifier_ability_exrumia02_attackspeed:OnIntervalThink()
	local caster = self:GetCaster()
	caster:SetBaseAttackTime(self:GetAbility():GetSpecialValueFor("attack_speed"))
end]]

modifier_ability_exrumia02_attack = {}
LinkLuaModifier("modifier_ability_exrumia02_attack","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia02_attack:IsHidden() return false end
function modifier_ability_exrumia02_attack:IsDebuff() return false end
function modifier_ability_exrumia02_attack:IsPurgable() return false end
function modifier_ability_exrumia02_attack:RemoveOnDeath() return true end

function modifier_ability_exrumia02_attack:OnCreated()
	if not IsServer() then return end
	if self:GetCaster():GetClassname()=="npc_dota_hero_life_stealer" then
		self:GetCaster():SetOriginalModel("models/exrumia/exrumia2.vmdl")
		self.attackanimation = 1
	end
	self.exrumia02eff = ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia04/exrumia02.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
end

function modifier_ability_exrumia02_attack:OnRemoved()	
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.exrumia02eff,true)
	self.exrumia02eff = ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia04/abaddon_borrowed_time_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	if self:GetCaster():GetClassname()=="npc_dota_hero_life_stealer" then
		self:GetCaster():SetOriginalModel("models/exrumia/exrumia.vmdl")
	end
end


function modifier_ability_exrumia02_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_exrumia02_attack:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end


function modifier_ability_exrumia02_attack:OnAttackLanded(keys)
	if not IsServer() then return end
	 self.count = 0
	local caster = self:GetCaster()
	local radio = self:GetAbility():GetSpecialValueFor("radio")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
--============2021.9.5 by 好汉============================================================================
	local attackAngle = self:GetAbility():GetSpecialValueFor("attack_angle")	--攻击扇角
	local casterPos = caster:GetAbsOrigin()						--ex10坐标 （圆心坐标）
	local caster_face = caster:GetForwardVector()					--面朝向量
	local caster_angle = VectorToAngles(caster_face)					--设置角度
	local caster_angle_min = caster_angle.y - attackAngle/2
	local caster_angle_max = caster_angle.y + attackAngle/2
--========================================================================================================

	if keys.attacker ~= caster then return end
	keys.attacker:EmitSound("exrumia02attack")
	ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia02.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia022.vpcf", PATTACH_ABSORIGIN, caster)
	local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
		,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
       	for hh,sb in pairs(heros) do

--============2021.9.5 by 好汉============================================================================
	            	local sb_abs_pos = sb:GetAbsOrigin()
	            	local face = (sb_abs_pos - casterPos):Normalized()
	            	local angle = VectorToAngles(face)
	            	local length = (sb_abs_pos - casterPos):Length()

	            	if angle.y < caster_angle_max and angle.y > caster_angle_min and length <= radio then
--========================================================================================================
		            	
		            	local damage_table = {
		            		victim = sb,
		            		attacker = caster,
		            		damage = damage,
		            		damage_type = DAMAGE_TYPE_MAGICAL,
		            	}
		            	UnitDamageTarget(damage_table)
                     self.count = self.count + 1
--============2021.9.5 by 好汉============================================================================
		       end
--========================================================================================================
end
    local heal = damage * self.count / 2
    if self:GetCaster():HasModifier("modifier_ability_exrumiaEx_telent4") then heal = heal * 1.5 end
    caster:Heal(heal ,caster) 
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetParent(),heal,nil)
end


ability_thdots_exrumia03 = {}

function ability_thdots_exrumia03:GetChannelTime()  --持续施法
	return self:GetSpecialValueFor("duration")
end

function ability_thdots_exrumia03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster,self,"modifier_ability_exrumia03_block",{duration = duration})
	--print(duration)
	caster:EmitSound("exrumia03")
end

function ability_thdots_exrumia03:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_ability_exrumia03_block")
end

modifier_ability_exrumia03_block = {}
LinkLuaModifier("modifier_ability_exrumia03_block","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia03_block:IsHidden() return false end
function modifier_ability_exrumia03_block:IsPurgable() return false end
function modifier_ability_exrumia03_block:IsDebuff() return false end
function modifier_ability_exrumia03_block:RemoveOnDeath() return true end

function modifier_ability_exrumia03_block:DeclareFunctions()  
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_exrumia03_block:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = false,
	}
end

function modifier_ability_exrumia03_block:OnCreated()
	if not IsServer() then return end
    self.count = self:GetAbility():GetSpecialValueFor("block_constant")  --获取盾的值
    self:GetCaster():SetModifierStackCount("modifier_ability_exrumia03_block",self:GetAbility(),self.count) 
    --print("2")
	self.exrumiaShield = ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.exrumiaShield, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.exrumiaShield, 1, self:GetCaster():GetAbsOrigin())
end

function modifier_ability_exrumia03_block:OnRemoved()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.exrumiaShield,true)
end

function modifier_ability_exrumia03_block:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end --被打的人是exrumia
	--print_r(keys)
	local caster = self:GetCaster()
	local count = caster:GetModifierStackCount("modifier_ability_exrumia03_block",nil)
		if keys.damage > count then  --判定伤害和盾的剩余额
			self.block_damage = count
			ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia03break/exrumia03.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			caster:EmitSound("exrumia03break")
			self:GetCaster():RemoveModifierByName("modifier_ability_exrumia03_block") --return一定要写在最底下
		    self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia03_animation",{}) --被击破播放
    	local radio = self:GetAbility():GetSpecialValueFor("radio")
	    local stuntime = self:GetAbility():GetSpecialValueFor("stuntime")
	    local regen_mana = self:GetAbility():GetSpecialValueFor("regen_mana")
	    local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
		,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	       for hh,sb in pairs(heros) do
	        	sb:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia03_stun",{duration = stuntime})
	      end
	  self:GetCaster():GiveMana(regen_mana) --回蓝	  
	     	caster:InterruptChannel() --停止咏唱
			if not (caster:GetHealth() <= 0) then 
			    local nexthealth = caster:GetHealth() + self.block_damage
			    caster:SetHealth(nexthealth)
	     	end
		else
			self.block_damage = keys.damage
			--print(self.block_damage)
			caster:SetModifierStackCount("modifier_ability_exrumia03_block", self:GetAbility(), count - keys.damage )
			if not (caster:GetHealth() <= 0) then 
			    local nexthealth = caster:GetHealth() + self.block_damage
			    caster:SetHealth(nexthealth)
			end
		end
end

--[[function modifier_ability_exrumia03_block:OnRemoved() 无条件播放
	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia03_animation",{})
end]]

--[[function modifier_ability_exrumia03_block:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	if self.block_damage == self:GetCaster():GetModifierStackCount("modifier_ability_exrumia03_block",nil) then
		self:GetCaster():RemoveModifierByName("modifier_ability_exrumia03_block") --return一定要写在最底下
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia03_animation",{}) --被击破播放
		local caster = self:GetCaster()
    	local radio = self:GetAbility():GetSpecialValueFor("radio")
	    local stuntime = self:GetAbility():GetSpecialValueFor("stuntime")
	    local regen_mana = self:GetAbility():GetSpecialValueFor("regen_mana")
	    local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM --对范围内的敌人造成效果
		,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	       for hh,sb in pairs(heros) do
	        	sb:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia03_stun",{duration = stuntime})
	      end
	  self:GetCaster():GiveMana(regen_mana) --回蓝	  
	  	caster:InterruptChannel() --停止咏唱
		return self.block_damage
	else
		return self.block_damage
	end
end]]

modifier_ability_exrumia03_animation = {}
LinkLuaModifier("modifier_ability_exrumia03_animation","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia03_animation:IsPurgable() return false end
function modifier_ability_exrumia03_animation:IsDebuff() return false end
function modifier_ability_exrumia03_animation:IsHidden() return true end
function modifier_ability_exrumia03_animation:RemoveOnDeath() return true end

function modifier_ability_exrumia03_animation:OnCreated() 
	--self:GetCaster():RemoveModifierByName("modifier_ability_exrumia03_animation")
end

function modifier_ability_exrumia03_animation:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_ability_exrumia03_animation:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_3_END
end



--[[function modifier_ability_exrumia03_block:OnRemoved() --盾破碎
	
	  --self:GetCaster():RemoveAbility("ability_thdots_exrumia03") 并不好用
end]]

modifier_ability_exrumia03_stun = {}
LinkLuaModifier("modifier_ability_exrumia03_stun","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia03_stun:IsHidden()  return true end
function modifier_ability_exrumia03_stun:IsPurgable() return true end
function modifier_ability_exrumia03_stun:RemoveOnDeath() return true end
function modifier_ability_exrumia03_stun:IsDebuff() return true end

function modifier_ability_exrumia03_stun:OnCreated() 
	if not IsServer() then return end
	local target = self:GetParent()
	local caster = self:GetCaster()
	local damage = self:GetAbility():GetSpecialValueFor("break_damage")
	local damage_table = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
end

function modifier_ability_exrumia03_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true ,
	}
end

ability_thdots_exrumia04 = {}

function ability_thdots_exrumia04:GetIntrinsicModifierName()
	return "modifier_ability_exrumia04_wanbaochui"
end

function ability_thdots_exrumia04:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_exrumia04:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster,self,"modifier_ability_exrumia04_lastjudge",{})
    caster:MoveToTargetToAttack(target)
	caster:EmitSound("Voice_Thdots_Rumia.AbilityRumia04")
	target:EmitSound("exrumialastjudge")
	target:AddNewModifier(caster,self,"modifier_ability_exrumia04_vision",{})
	ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/lastjudge/exrumia04.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
end


modifier_ability_exrumia04_wanbaochui = {}
LinkLuaModifier("modifier_ability_exrumia04_wanbaochui","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_wanbaochui:IsHidden() return true end
function modifier_ability_exrumia04_wanbaochui:IsDebuff() return false end
function modifier_ability_exrumia04_wanbaochui:IsPurgable() return false end
function modifier_ability_exrumia04_wanbaochui:RemoveOnDeath() return false end

function modifier_ability_exrumia04_wanbaochui:OnCreated()
	self.i = 100
end

function modifier_ability_exrumia04_wanbaochui:DeclareFunctions()
       return {
       	MODIFIER_EVENT_ON_ATTACK_START,
       	MODIFIER_EVENT_ON_ATTACK_LANDED,
       }
end

function modifier_ability_exrumia04_wanbaochui:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsBuilding() then return end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	if self.i >= chance then return end
	keys.target:RemoveModifierByName("modifier_ability_exrumia04_wanbaochuicrit")
	keys.attacker:EmitSound("Voice_Thdots_Rumia.AbilityRumia04")
	keys.target:EmitSound("exrumialastjudge")
	ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/lastjudge/exrumia04.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	if keys.target:HasModifier("modifier_ability_exrumia04_wanbaochuimoredamage") then self.damage = self.damage * 2 end
    local damage_table = {
		victim = keys.target,
		attacker = keys.attacker,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
end

function modifier_ability_exrumia04_wanbaochui:OnAttackStart(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	if not self:GetParent():HasModifier("modifier_item_wanbaochui") then return end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	self.i = RandomInt(0,99)
	--print(self.i)
	if self. i >= chance then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	keys.target:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_exrumia04_wanbaochuicrit",{})
	if keys.target:GetHealth() / keys.target:GetMaxHealth() < 0.35 then 
	self.damage = self.damage * 2
end
end


--[[function modifier_ability_exrumia04_wanbaochui:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsBuilding() then return end
	if not self:GetParent():HasModifier("modifier_item_wanbaochui") then return end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	if self.i >= chance then return end
	ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/lastjudge/exrumia04.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	keys.target:EmitSound("exrumialastjudge") 
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	if keys.target:GetHealth() / keys.target:GetMaxHealth() < 0.35 then
	  self.damage =self.damage * 2  
	end
		local damage_table = {
			victim = keys.target,
			attacker = keys.attacker,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		UnitDamageTarget(damage_table)
	--keys.attacker:RemoveModifierByName("modifier_ability_exrumia04_wanbaochuicrit")
end]]

modifier_ability_exrumia04_wanbaochuicrit = {}
LinkLuaModifier("modifier_ability_exrumia04_wanbaochuicrit","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_wanbaochuicrit:IsHidden() return true end
function modifier_ability_exrumia04_wanbaochuicrit:IsDebuff() return false end
function modifier_ability_exrumia04_wanbaochuicrit:IsPurgable() return false end
function modifier_ability_exrumia04_wanbaochuicrit:RemoveOnDeath() return false end

function modifier_ability_exrumia04_wanbaochuicrit:OnCreated()
	if not IsServer() then return end
     self.crit = self:GetAbility():GetSpecialValueFor("crit")
     if self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() < 0.35 then self.crit = self.crit * 2 end
end

function modifier_ability_exrumia04_wanbaochuicrit:DeclareFunctions()
	return {
       	MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE,
       	MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_ability_exrumia04_wanbaochuicrit:OnAttackStart(keys)
	if self:GetParent() == keys.target then 
		if keys.attacker  ~= self:GetCaster() then
	        self:GetParent():RemoveModifierByName("modifier_ability_exrumia04_wanbaochuicrit") end end
end

function modifier_ability_exrumia04_wanbaochuicrit:GetModifierPreAttack_Target_CriticalStrike()
	--print(modifier_ability_exrumia04_wanbaochui.crit)
	--print(self.crit)
    return self.crit
end

--[[modifier_ability_exrumia04_wanbaochuimoredamage = {}
LinkLuaModifier("modifier_ability_exrumia04_wanbaochuimoredamage","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_wanbaochuimoredamage:RemoveOnDeath() return true end]]

modifier_ability_exrumia04_lastjudge = {}
LinkLuaModifier("modifier_ability_exrumia04_lastjudge","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_lastjudge:IsHidden() return true end
function modifier_ability_exrumia04_lastjudge:IsDebuff() return false end
function modifier_ability_exrumia04_lastjudge:IsPurgable() return false end
function modifier_ability_exrumia04_lastjudge:RemoveOnDeath() return true end

function modifier_ability_exrumia04_lastjudge:DeclareFunctions()
	if not IsServer() then return end
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_exrumia04_lastjudge:OnDeath(keys)
	if keys.unit == self:GetCaster() then self:GetCaster():RemoveModifierByName("modifier_ability_exrumia04_lastjudge") end
	if keys.unit == self.target then self:GetCaster():RemoveModifierByName("modifier_ability_exrumia04_lastjudge") end
end

function modifier_ability_exrumia04_lastjudge:GetModifierMoveSpeed_Absolute()
	return 800
end


function modifier_ability_exrumia04_lastjudge:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_STUNNED] = false,
	}
end

function modifier_ability_exrumia04_lastjudge:OnCreated()
	if not IsServer() then return end
	self.crit = self:GetAbility():GetSpecialValueFor("crit")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.target = self:GetAbility():GetCursorTarget()
	local caster = self:GetCaster()
	local duration = self:GetAbility():GetSpecialValueFor("duration")
    if self.target:GetHealth() / self.target:GetMaxHealth() < 0.35 then
		     self.damage = self.damage * 2
		     self.crit = self.crit * 2
		     --print(self.crit)
	end
	local damage_table = {
		victim = self.target,
		attacker = caster,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
end

function modifier_ability_exrumia04_lastjudge:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end 	
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local target = keys.target
	target:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_exrumia04_debuff",{duration = duration})
    if keys.attacker:HasModifier("modifier_ability_exrumiaEx_telent7") then 
       self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia04_strength",{duration = duration})
       keys.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumia04_loststrength",{duration = duration})
    end
	keys.attacker:RemoveModifierByName("modifier_ability_exrumia04_lastjudge")
end

function modifier_ability_exrumia04_lastjudge:GetModifierPreAttack_CriticalStrike()
	return self.crit
end

function modifier_ability_exrumia04_lastjudge:OnRemoved()
	if not IsServer() then return end
	self.target:RemoveModifierByName("modifier_ability_exrumia04_vision")
end

modifier_ability_exrumia04_vision = {}
LinkLuaModifier("modifier_ability_exrumia04_vision","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_vision:IsHidden() return true end
function modifier_ability_exrumia04_vision:IsPurgable() return false end
function modifier_ability_exrumia04_vision:IsDebuff() return true end
function modifier_ability_exrumia04_vision:RemoveOnDeath() return true end

function modifier_ability_exrumia04_vision:OnCreated()
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_ability_exrumia04_vision:OnIntervalThink()
	if not IsServer() then return end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 100, 0.51, false)
	if self.point == self:GetCaster():GetAbsOrigin() then self:GetCaster():RemoveModifierByName("modifier_ability_exrumia04_lastjudge") end
	self.point = self:GetCaster():GetAbsOrigin()
	if not self:GetCaster():HasModifier("modifier_ability_exrumia04_lastjudge") then self:GetParent():RemoveModifierByName("modifier_ability_exrumia04_vision") end
end

modifier_ability_exrumia04_strength = {}
LinkLuaModifier("modifier_ability_exrumia04_strength","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_strength:IsHidden() return true end
function modifier_ability_exrumia04_strength:IsPurgable() return false end
function modifier_ability_exrumia04_strength:IsDebuff() return false end
function modifier_ability_exrumia04_strength:RemoveOnDeath() return false end

function modifier_ability_exrumia04_strength:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_ability_exrumia04_strength:GetModifierBonusStats_Strength()
	return 40
end

modifier_ability_exrumia04_loststrength = {}
LinkLuaModifier("modifier_ability_exrumia04_loststrength","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_loststrength:IsHidden() return true end
function modifier_ability_exrumia04_loststrength:IsPurgable() return false end
function modifier_ability_exrumia04_loststrength:IsDebuff() return true end
function modifier_ability_exrumia04_loststrength:RemoveOnDeath() return true end

function modifier_ability_exrumia04_loststrength:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_ability_exrumia04_loststrength:GetModifierBonusStats_Strength()
	return -40
end

function modifier_ability_exrumia04_loststrength:OnRemoved()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_ability_exrumia04_strength")
end

modifier_ability_exrumia04_debuff = {}
LinkLuaModifier("modifier_ability_exrumia04_debuff","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumia04_debuff:IsHidden() return false end
function modifier_ability_exrumia04_debuff:IsPurgable() return true end
function modifier_ability_exrumia04_debuff:IsDebuff() return true end
function modifier_ability_exrumia04_debuff:RemoveOnDeath() return true end

function modifier_ability_exrumia04_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_exrumia04_debuff:OnDeath(keys)
	if not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end
	local healcount = self:GetCaster():GetMaxHealth() * 0.25
	self:GetCaster():Heal(healcount,self:GetCaster())
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetCaster(),healcount,nil)
end

function modifier_ability_exrumia04_debuff:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	local damage = keys.damage
	local block = damage * self:GetAbility():GetSpecialValueFor("block") / 100
	keys.unit:Heal(block,self:GetCaster())
end

ability_thdots_exrumiaEx = {}

function ability_thdots_exrumiaEx:GetIntrinsicModifierName()
	return "modifier_ability_exrumiaEx_ambient"--,"modifier_ability_exrumiaEx_telent"
end

modifier_ability_exrumiaEx_ambient = {}
LinkLuaModifier("modifier_ability_exrumiaEx_ambient","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_ambient:IsDebuff() return true end
function modifier_ability_exrumiaEx_ambient:IsPurgable() return false end
function modifier_ability_exrumiaEx_ambient:RemoveOnDeath() return false end
function modifier_ability_exrumiaEx_ambient:IsHidden() return true end

function modifier_ability_exrumiaEx_ambient:OnCreated()
	if not IsServer() then return end
	self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_exrumiaEx_night",{})
	self.exrumiaAmbient = ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	--ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia_flower.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_ability_exrumiaEx_ambient:OnRemoved()
	if not IsServer() then return end
		ParticleManager:DestroyParticle(self.exrumiaAmbient,true)
end

function modifier_ability_exrumiaEx_ambient:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_exrumiaEx_ambient:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
	keys.attacker:EmitSound("exrumiaattack")
end


modifier_ability_exrumiaEx_night = {}
LinkLuaModifier("modifier_ability_exrumiaEx_night","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_night:IsHidden() 
	if not IsServer() then return end
	if GameRules:IsDaytime() then return true else return false end end
function modifier_ability_exrumiaEx_night:IsDebuff() return false end
function modifier_ability_exrumiaEx_night:IsPurgable() return false end
function modifier_ability_exrumiaEx_night:RemoveOnDeath() return false end

function modifier_ability_exrumiaEx_night:OnCreated()
	if not IsServer() then return end 
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_ability_exrumiaEx_night:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
    if not GameRules:IsDaytime() then 
    	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_exrumiaEx_bonus",{})
    else 
    	self:GetCaster():RemoveModifierByName("modifier_ability_exrumiaEx_bonus") 
    end
    if FindTelentValue(self:GetParent(),"special_bonus_unique_exrumia_01") ~= 0 and not caster:HasModifier("modifier_ability_exrumiaEx_telent1") then 
    	self:GetParent():AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent1",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_02") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent2") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent2",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_03") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent3") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent3",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_04") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent4") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent4",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_05") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent5") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent5",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_06") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent6") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent6",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_07") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent7") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent7",{}) end
    if FindTelentValue(caster,"special_bonus_unique_exrumia_08") ~= 0 and not caster :HasModifier("modifier_ability_exrumiaEx_telent8") then
    	caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_exrumiaEx_telent8",{}) end
end


modifier_ability_exrumiaEx_bonus = {}
LinkLuaModifier("modifier_ability_exrumiaEx_bonus","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_bonus:IsHidden() return true end
function modifier_ability_exrumiaEx_bonus:IsDebuff() return false end
function modifier_ability_exrumiaEx_bonus:IsPurgable() return false end
function modifier_ability_exrumiaEx_bonus:RemoveOnDeath() return false end

function modifier_ability_exrumiaEx_bonus:DeclareFunctions()
     return {
     	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
     	MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
     }
end

function modifier_ability_exrumiaEx_bonus:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetParent():HasModifier("modifier_ability_exrumiaEx_telent5") then
 	    return self:GetAbility():GetSpecialValueFor("speed")
    else 
        return self:GetAbility():GetSpecialValueFor("speed") * 2
    end
end

function modifier_ability_exrumiaEx_bonus:GetModifierDamageOutgoing_Percentage()
	if not self:GetParent():HasModifier("modifier_ability_exrumiaEx_telent5") then
 	    return self:GetAbility():GetSpecialValueFor("speed")
    else 
        return self:GetAbility():GetSpecialValueFor("speed") * 2
    end
end

modifier_ability_exrumiaEx_telent1 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent1","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent1:IsHidden() return true end
function modifier_ability_exrumiaEx_telent1:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent1:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent1:RemoveOnDeath() return false end

function modifier_ability_exrumiaEx_telent1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_ability_exrumiaEx_telent1:GetModifierBonusStats_Agility()
	return 15
end

modifier_ability_exrumiaEx_telent2 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent2","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent2:IsHidden() return true end
function modifier_ability_exrumiaEx_telent2:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent2:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent2:RemoveOnDeath() return false end

--[[function modifier_ability_exrumiaEx_telent2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_exrumiaEx_telent2:GetModifierMoveSpeedBonus_Constant()
	return 15
end]]

modifier_ability_exrumiaEx_telent3 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent3","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent3:IsHidden() return true end
function modifier_ability_exrumiaEx_telent3:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent3:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent3:RemoveOnDeath() return false end

function modifier_ability_exrumiaEx_telent3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_exrumiaEx_telent3:GetModifierMoveSpeedBonus_Constant()
	return 35
end

modifier_ability_exrumiaEx_telent4 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent4","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent4:IsHidden() return true end
function modifier_ability_exrumiaEx_telent4:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent4:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent4:RemoveOnDeath() return false end

--[[function modifier_ability_exrumiaEx_telent4:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_ability_exrumiaEx_telent4:GetModifierPreAttack_BonusDamage()
	return 25
end]]

modifier_ability_exrumiaEx_telent5 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent5","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent5:IsHidden() return true end
function modifier_ability_exrumiaEx_telent5:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent5:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent5:RemoveOnDeath() return false end

modifier_ability_exrumiaEx_telent6 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent6","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent6:IsHidden() return true end
function modifier_ability_exrumiaEx_telent6:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent6:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent6:RemoveOnDeath() return false end

function modifier_ability_exrumiaEx_telent6:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_ability_exrumiaEx_telent6:GetModifierPhysicalArmorBonus()
	return 15
end

modifier_ability_exrumiaEx_telent7 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent7","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent7:IsHidden() return true end
function modifier_ability_exrumiaEx_telent7:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent7:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent7:RemoveOnDeath() return false end

modifier_ability_exrumiaEx_telent8 = {}
LinkLuaModifier("modifier_ability_exrumiaEx_telent8","scripts/vscripts/abilities/abilityexrumia.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_exrumiaEx_telent8:IsHidden() return true end
function modifier_ability_exrumiaEx_telent8:IsDebuff() return false end
function modifier_ability_exrumiaEx_telent8:IsPurgable() return false end
function modifier_ability_exrumiaEx_telent8:RemoveOnDeath() return false end

function modifier_ability_exrumiaEx_telent8:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_exrumiaEx_telent8:GetModifierAttackSpeedBonus_Constant()
	return 55
end