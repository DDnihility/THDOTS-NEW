ability_thdots_larvaEx = {}

function ability_thdots_larvaEx:GetIntrinsicModifierName()  --内置modifier
	if not IsServer() then return end
	return "modifier_ability_larvaEx_passive"
end

modifier_ability_larvaEx_passive = {}
LinkLuaModifier("modifier_ability_larvaEx_passive","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)  --必要步骤  
function modifier_ability_larvaEx_passive:IsHidden() 		return true end     --是否隐藏
function modifier_ability_larvaEx_passive:IsPurgable()     return false end     --是否可净化
function modifier_ability_larvaEx_passive:RemoveOnDeath() 	return true  end     --死亡移除
function modifier_ability_larvaEx_passive:IsDebuff()	   	return false end     --是否是DEBUFF

function modifier_ability_larvaEx_passive:DeclareFunctions() --宣布将要使用哪些效果
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,            
	}   
end

function modifier_ability_larvaEx_passive:OnCreated() --天赋监听
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end
function modifier_ability_larvaEx_passive:OnIntervalThink()
	if not IsServer() then return end
	--if FindTelentValue(self:GetCaster(),"special_bonus_unique_larva_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_larva_telent_1") then
	--	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_larva_telent_1",{})
	--end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_larva_6") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_larva_telent_2") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_larva_telent_2",{})
	end
end


function modifier_ability_larvaEx_passive:OnAttackLanded(keys)  
	if not IsServer() then return end
	local attacker = keys.attacker
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	if keys.target ~= self:GetParent() then return end  --判断被攻击者是否为拉尔瓦
	--print_r(keys)
	attacker:RemoveModifierByName("modifier_ability_larvaEx_buff") --刷新持续时间
	attacker:AddNewModifier(keys.target,self:GetAbility(),"modifier_ability_larvaEx_buff",{duration = duration})
end

modifier_ability_larvaEx_buff = {}
LinkLuaModifier("modifier_ability_larvaEx_buff","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larvaEx_buff:IsHidden() 		return false end     --是否隐藏
function modifier_ability_larvaEx_buff:IsPurgable()     return true end     --是否可净化
function modifier_ability_larvaEx_buff:RemoveOnDeath() 	return true  end     --死亡移除
function modifier_ability_larvaEx_buff:IsDebuff()	   	return true end     --是否是DEBUFF

function modifier_ability_larvaEx_buff:DeclareFunctions()   --技能增强
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_ability_larvaEx_buff:GetModifierSpellAmplify_Percentage() --给一个反的数就能达到降低技能伤害的效果了
	return -self:GetAbility():GetSpecialValueFor("damage_percent")
end 

------------------------------------------------------------------------------------------------
------------------------------蝶符  盛夏振翅 扑棱蛾子---------------------------------------------
------------------------------------------------------------------------------------------------
ability_thdots_larva01 = {}

function ability_thdots_larva01:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_ability_larva01_stop") then
		return "custom/ability_thdots_larva01stop"
	else
		return "custom/ability_thdots_larva01"
	end
end

function ability_thdots_larva01:GetBehavior()
	if self:GetCaster():HasModifier("modifier_ability_larva01_stop") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_POINT
	end
end

function ability_thdots_larva01:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_ability_larva01_stop") then
		return 0
	else
		return 0.2
	end
end


function ability_thdots_larva01:GetManaCost(level)
	 if self:GetCaster():HasModifier("modifier_ability_larva01_stop") then
	 	return 0
	 else
	 	return self.BaseClass.GetManaCost(self, level )
	 end
	end

function ability_thdots_larva01:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_ability_larva01_stop") then  --更替技能modifier
	local caster		= self:GetCaster()
	local position = self:GetCursorPosition()
    local distance = (position - caster:GetAbsOrigin()):Length2D()
	local dashLength	= self:GetSpecialValueFor("length") + FindTelentValue(caster,"special_bonus_unique_larva_2")  --findtelentvalue可以直接获取KV里的天赋数值
	if distance < dashLength then dashLength = distance end
	local dashWidth		= self:GetSpecialValueFor("width")
	local dashDuration	= self:GetSpecialValueFor("duration")
	local casterOrigin	= caster:GetAbsOrigin()
	local casterAngles	= caster:GetAngles()
	local forwardDir	= caster:GetForwardVector()
	local rightDir		= caster:GetRightVector()
	local damage = self:GetSpecialValueFor("damage")
	local statsdamage = 0
	local ellipseCenter	= casterOrigin + forwardDir * ( dashLength / 2 )
	caster:AddNewModifier(caster,self,"modifier_ability_larva01_fly",{duration = dashDuration})
	caster:EmitSound("larva01")
	local startTime = GameRules:GetGameTime()

		caster:SetContextThink( DoUniqueString("updateIcarusDive"), function ( )

		local elapsedTime = GameRules:GetGameTime() - startTime
		local progress = elapsedTime / dashDuration

		-- Interrupted
		if not caster:HasModifier("modifier_ability_larva01_fly") then
			return nil
		end

		-- Calculate potision
		local theta = -2 * math.pi * progress
		local x =  math.sin( theta ) * dashWidth * 0.5
		local y = -math.cos( theta ) * dashLength * 0.5

		local pos = ellipseCenter + rightDir * x + forwardDir * y
		local yaw = casterAngles.y + 90 + progress * -360  

		pos = GetGroundPosition( pos, caster )
		caster:SetAbsOrigin( pos )
		caster:SetAngles( casterAngles.x, yaw, casterAngles.z )
		local debuff_duration = self:GetSpecialValueFor("debuff_duration")

		local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM
		,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_CUSTOM + DOTA_UNIT_TARGET_COURIER,0,0,false)  --将沿途单位计入heros中
		  for _,v in pairs(heros) do  
		  if not v:HasModifier("modifier_ability_larva01_debuffcheck") then --防止一头把人创死了
		  	--v:AddNewModifier(caster,self,"modifier_ability_larva01_debuff",{duration = debuff_duration})
		  	v:AddNewModifier(caster,self,"modifier_ability_larva01_debuffcheck",{duration = debuff_duration})
            if v:IsRealHero() then statsdamage = v:GetStrength() + v:GetAgility() + v:GetIntellect() - ( caster:GetStrength() + caster:GetAgility() + caster:GetIntellect() ) end --对英雄计算属性差伤害
            if statsdamage <= 0 then statsdamage = 0 end --无可厚非
		  	local damage_table = {
		  		victim = v,
		  		attacker = caster,
		  		damage = damage + statsdamage * 2,
		  		damage_type = DAMAGE_TYPE_MAGICAL,
		  	}
		  	UnitDamageTarget(damage_table)
           end
       end
		return 0.03
	end, 0 )
		caster:AddNewModifier(caster,self,"modifier_ability_larva01_stop",{duration = dashDuration}) --更替技能modifier
	    caster:SetModifierStackCount("modifier_ability_larva01_fly", self, 0 )
		self.remain_time = self:GetCooldownTimeRemaining()
    self:EndCooldown() --直接结束冷却 这时身上的技能切换为中途停止按钮
else
	self:GetCaster():EmitSound("larva01stop")
	self:GetCaster():RemoveModifierByName("modifier_ability_larva01_fly")
	FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true) --安全着陆，防止与建筑物合体	
end
end

modifier_ability_larva01_fly = {}
LinkLuaModifier("modifier_ability_larva01_fly","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva01_fly:IsHidden() 		return true end     --是否隐藏
function modifier_ability_larva01_fly:IsPurgable()     return false end     --是否可净化
function modifier_ability_larva01_fly:RemoveOnDeath() 	return true  end     --死亡移除
function modifier_ability_larva01_fly:IsDebuff()	   	return false end     --是否是DEBUFF

function modifier_ability_larva01_fly:OnCreated()
	if not IsServer() then return end
    local caster = self:GetParent()
	self.larva01 = ParticleManager:CreateParticle("particles/units/larva/larva01.vpcf", PATTACH_ABSORIGIN, caster)
	        ParticleManager:SetParticleControlEnt(self.larva01 , 0, caster, 5, "attach_hitloc", caster:GetAbsOrigin(), true)
	        ParticleManager:SetParticleControlEnt(self.larva01 , 3, caster, 5, "attach_hitloc", caster:GetAbsOrigin(), true)
	        self:StartIntervalThink(0.1)
	        self:OnIntervalThink()
end

function modifier_ability_larva01_fly:OnIntervalThink()
	local count = self:GetParent():GetModifierStackCount("modifier_ability_larva01_fly", nil) + 1
    self:GetCaster():SetModifierStackCount("modifier_ability_larva01_fly",self:GetAbility(), count)
end




function modifier_ability_larva01_fly:OnRemoved()  --结束后为自身添加飞行状态、高空视野
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.larva01,true)
	self:GetParent():RemoveModifierByName("modifier_ability_larva01_stop")  --更替技能modifier
	if FindTelentValue(self:GetParent(),"special_bonus_unique_larva_4") ~= 0 then
           local duration = self:GetAbility():GetSpecialValueFor("fly_duration")
           self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_larva01_flyvision",{duration = duration})
    end
end

modifier_ability_larva01_stop = {}
LinkLuaModifier("modifier_ability_larva01_stop","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva01_stop:IsHidden()  return true end
function modifier_ability_larva01_stop:IsPurgable() return false end
function modifier_ability_larva01_stop:RemoveOnDeath()  return true end
function modifier_ability_larva01_stop:IsDebuff()  return false end

function modifier_ability_larva01_stop:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
	}
end

function modifier_ability_larva01_stop:GetModifierIgnoreCastAngle()
	return 360
end

function modifier_ability_larva01_stop:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function modifier_ability_larva01_stop:OnRemoved()
	if not IsServer() then return end
	local count = self:GetParent():GetModifierStackCount("modifier_ability_larva01_fly", nil)
	--print(count)
	local remain_time = self:GetAbility().remain_time - count * 0.1
	self:GetAbility():StartCooldown(remain_time)
end

modifier_ability_larva01_debuff = {}
LinkLuaModifier("modifier_ability_larva01_debuff","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva01_debuff:IsHidden() return false end
function modifier_ability_larva01_debuff:IsPurgable()  return true end
function modifier_ability_larva01_debuff:RemoveOnDeath() return true end
function modifier_ability_larva01_debuff:IsDebuff()  return true end

function modifier_ability_larva01_debuff:DeclareFunctions()  --目前还没有成功使用这个功能
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end


function modifier_ability_larva01_debuff:GetModifierPercentageCooldown()  
	if not IsServer() then return end
	return -self:GetAbility():GetSpecialValueFor("slow_percent")
end

modifier_ability_larva01_debuffcheck = {}
LinkLuaModifier("modifier_ability_larva01_debuffcheck","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva01_debuffcheck:IsHidden() return true end
function modifier_ability_larva01_debuffcheck:IsPurgable()  return false end
function modifier_ability_larva01_debuffcheck:RemoveOnDeath() return true end
function modifier_ability_larva01_debuffcheck:IsDebuff()  return true end

modifier_ability_larva01_flyvision = {}
LinkLuaModifier("modifier_ability_larva01_flyvision","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva01_flyvision:IsDebuff() return false end
function modifier_ability_larva01_flyvision:IsPurgable() return true end
function modifier_ability_larva01_flyvision:IsHidden() return false end
function modifier_ability_larva01_flyvision:RemoveOnDeath() return true end
function modifier_ability_larva01_flyvision:CheckState()  --飞行 没有高空视野
	return{
		[MODIFIER_STATE_FLYING]  = true,
	}
end

function modifier_ability_larva01_flyvision:OnCreated()  --高空视野
	if not IsServer() then return end
	self:StartIntervalThink(0.05)
	self:OnIntervalThink()
end

function modifier_ability_larva01_flyvision:OnIntervalThink()  
	if not IsServer() then return end
	local caster = self:GetParent()
    AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:GetCurrentVisionRange(), 0.051, false)  --高空视野
end

---------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------蝶符  沾身难下的鳞粉----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

ability_thdots_larva02 = {}

function ability_thdots_larva02:GetAOERadius()
	return self:GetSpecialValueFor("radio")
end

function ability_thdots_larva02:GetIntrinsicModifierName()  --天赋被动
	if not IsServer() then return end
	--if not self:GetCaster():FindTelentValue(self:GetCaster(),"special_bonus_unique_larva_6") ~= 0 then return end
	    return "modifier_ability_larva02_attack"
end

function ability_thdots_larva02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:EmitSound("larva02")
	local duration = self:GetSpecialValueFor("duration")  
	local radio = self:GetSpecialValueFor("radio")
	local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM  --[[搜索施法者350码内的敌人]]
		,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_CUSTOM,0,0,false)
	for _,v in pairs(heros) do   
		if not v:HasModifier("modifier_ability_larva02_debuff") then
			v:AddNewModifier(caster,self,"modifier_ability_larva02_debuff",{duration = duration})
	end
end
	local larva02 = ParticleManager:CreateParticle("particles/units/larva/larva02.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	        ParticleManager:SetParticleControlEnt(larva02 , 0, caster, 5, "attach_hitloc", caster:GetAbsOrigin(), true)
	    end

modifier_ability_larva02_attack = {}
LinkLuaModifier("modifier_ability_larva02_attack","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva02_attack:IsHidden() 
	if self:GetCaster():HasModifier("modifier_ability_thdots_larva_telent_2") then
	return false else return true end end
function modifier_ability_larva02_attack:IsPurgable() return true end
function modifier_ability_larva02_attack:IsDebuff() return false end
function modifier_ability_larva02_attack:RemoveOnDeath() return true end

function modifier_ability_larva02_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_larva02_attack:OnAttackLanded(keys)  --天赋普攻附带2技能 ，实现方法与技能一致
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_ability_thdots_larva_telent_2") then return end
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsBuilding() then return end
	 --print_r(keys)
	 local duration = self:GetAbility():GetSpecialValueFor("duration")
	 local addduration = self:GetAbility():GetSpecialValueFor("addduration")
	 local caster = keys.attacker
	 local target = keys.target
	 if not target:HasModifier("modifier_ability_larva02_debuff") then
	 	target:AddNewModifier(caster,self:GetAbility(),"modifier_ability_larva02_debuff",{duration = duration})
	 else
	    local count = target:GetModifierStackCount("modifier_ability_larva02_debuff", nil) + 1 --读取目标层数
	    target:SetModifierStackCount("modifier_ability_larva02_debuff", self, count ) 
	    target:FindModifierByName("modifier_ability_larva02_debuff"):SetDuration( duration, true)
	end
end
     

modifier_ability_larva02_debuff = {}
LinkLuaModifier("modifier_ability_larva02_debuff","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva02_debuff:IsHidden()   return false end
function modifier_ability_larva02_debuff:IsPurgable()  return true end
function modifier_ability_larva02_debuff:IsDebuff()  return true end
function modifier_ability_larva02_debuff:RemoveOnDeath()  return true end
function  modifier_ability_larva02_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_larva02_debuff:OnAbilityExecuted(keys)  --使用技能时
	if not IsServer() then return end
	--print_r(keys.ability:GetName())
	local addduration = self:GetAbility():GetSpecialValueFor("addduration")
	if keys.unit ~= self:GetParent() or keys.ability:IsItem() or keys.ability:IsToggle() then  --判断是否为buff携带者 使用的是否是技能
		return
	end
        local CurrentActiveAbility=keys.ability
		if IsNotLunchbox_ability(CurrentActiveAbility) then return end
	local count = self:GetParent():GetModifierStackCount("modifier_ability_larva02_debuff", nil) + 1 --读取目标层数
	self:GetParent():SetModifierStackCount("modifier_ability_larva02_debuff", self, count )  --层数 + 额外持续时间
	self:GetParent():FindModifierByName("modifier_ability_larva02_debuff"):SetDuration( self:GetDuration(), true)  --层数 + 额外持续时间
end

function modifier_ability_larva02_debuff:OnCreated()  
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_ability_larva02_debuff:OnIntervalThink()
	if not IsServer() then return end
	local count = self:GetParent():GetModifierStackCount("modifier_ability_larva02_debuff", nil)  
	local damage = self:GetAbility():GetSpecialValueFor("damage") * ( 1.3 ^ count )
	--print(damage)
	local damage_table ={
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
	--if count == 0 then self:GetParent():RemoveModifierByName("modifier_ability_larva02_debuff") end
end

function modifier_ability_larva02_debuff:GetModifierMoveSpeedBonus_Percentage()  --加速给一个负的值就是减速了
	--if not IsServer() then return end
	local count = self:GetParent():GetModifierStackCount("modifier_ability_larva02_debuff", nil)
	local slow = self:GetAbility():GetSpecialValueFor("slow") * ( count / self:GetDuration() )
	--print(num/count)
	return - slow
end

---------------------------------------------------------------------------------------------------------
-------------------------------------梦蝶  Crazy Butterfly-----------------------------------------------
---------------------------------------------------------------------------------------------------------

ability_thdots_larva03 = {}

function ability_thdots_larva03:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_larva03:GetCooldown(level)  
	local cd = self.BaseClass.GetCooldown(self, level)
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_larva_1")
	if telent then
		cd = cd + telent:GetSpecialValueFor("value")
	end
	return cd
end


function ability_thdots_larva03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:EmitSound("larva03")
	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster,self,"modifier_ability_larva03_buff",{duration = duration})
end

modifier_ability_larva03_buff = {}
LinkLuaModifier("modifier_ability_larva03_buff","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva03_buff:IsDebuff() return false end
function modifier_ability_larva03_buff:IsHidden() return false end
function modifier_ability_larva03_buff:IsPurgable() return true end
function modifier_ability_larva03_buff:RemoveOnDeath() return true end
function modifier_ability_larva03_buff:GetEffectName() return "particles/heroes/larva/lotus_orb_shield.vpcf" end
function modifier_ability_larva03_buff:GetEffectAttachType() return PATTACH_CENTER_FOLLOW end
function modifier_ability_larva03_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_larva03_buff:OnTakeDamage(keys)
	if not IsServer() then return end
	if not keys.attacker:IsRealHero() then return end
	if keys.attacker:GetTeam() == self:GetCaster() then return end
	if keys.unit ~= self:GetParent() then return end
	if keys.damage <= 50 then return end
	--print_r(keys)
	local lasthealth = keys.unit:GetHealth() + keys.damage
	if keys.unit:GetHealth() == 0 then
		if keys.damage > 150 then lasthealth = 150
		else
			lasthealth = keys.damage
		end
	end
	keys.unit:SetHealth(lasthealth)
	if keys.attacker:IsNull() or not keys.attacker:IsAlive() or keys.attacker:IsMagicImmune() or IsTHDImmune(keys.attacker) then return end--魔免检测
	UtilStun:UnitStunTarget(self:GetCaster(),keys.attacker,self:GetAbility():GetSpecialValueFor("stuntime"))
	local damage_table = {
		victim = keys.attacker,
		damage = keys.damage,
		damage_type = DAMAGE_TYPE_PURE,
		attacker = self:GetCaster(),
	}
	self:GetParent():RemoveModifierByName("modifier_ability_larva03_buff")
	UnitDamageTarget(damage_table)
end
function modifier_ability_larva03_buff:OnRemoved()
	if not IsServer() then return end
	local shield_particle = ParticleManager:CreateParticle("particles/heroes/larva/medusa_daughters_mana_shield_shell_impact_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(shield_particle)
end
---------------------------------------------------------------------------------------------------------
-----------------------------------------仲夏的妖精梦-----------------------------------------------------
---------------------------------------------------------------------------------------------------------

ability_thdots_larva04 = {}

function ability_thdots_larva04:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_larva04:GetAOERadius()
	return self:GetSpecialValueFor("radio")
end

function ability_thdots_larva04:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    --local damage = self:GetSpecialValueFor("damage")
    --local stuntime = self:GetSpecialValueFor("stuntime")
    local point = self:GetCursorPosition()
    --local range = self:GetSpecialValueFor("range")
    local thinker = CreateModifierThinker(caster,self,"modifier_ability_larva04_catch",{duration = duration},point,caster:GetTeamNumber(),false)  --为鼠标选中地点创建一个有坐标的替身（？）
    self.dream = ParticleManager:CreateParticle("particles/units/larva/larva04.vpcf", PATTACH_ABSORIGIN, thinker)
    thinker:EmitSound("larva04")
    if caster:HasModifier("modifier_item_wanbaochui") then thinker:AddNewModifier(caster,self,"modifier_larva_wanbaochui",{duration = duration}) end
    if FindTelentValue(self:GetCaster(),"special_bonus_unique_larva_5") ~= 0 then thinker:AddNewModifier(caster,self,"modifier_larva_telent5",{duration = duration}) end
    --[[local heros = FindUnitsInRadius(caster:GetTeam(),point,nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,0,0,false)
            for _,v in pairs(heros) do
            	v:AddNewModifier(caster,self,"modifier_ability_larva04_catch",{duration = duration})
            end]]
end

modifier_larva_wanbaochui = {}
LinkLuaModifier("modifier_larva_wanbaochui","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_larva_wanbaochui:IsPurgable() return false end
function modifier_larva_wanbaochui:IsHidden() return true end
function modifier_larva_wanbaochui:IsDebuff() return false end
function modifier_larva_wanbaochui:RemoveOnDeath() return true end

modifier_larva_telent5 = {}
LinkLuaModifier("modifier_larva_telent5","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_larva_telent5:IsPurgable() return false end
function modifier_larva_telent5:IsHidden() return true end
function modifier_larva_telent5:IsDebuff() return false end
function modifier_larva_telent5:RemoveOnDeath() return true end

modifier_ability_larva04_catch = {}
LinkLuaModifier("modifier_ability_larva04_catch","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva04_catch:IsDebuff() return true end
function modifier_ability_larva04_catch:IsHidden() return false end
function modifier_ability_larva04_catch:IsPurgable() return true end
function modifier_ability_larva04_catch:RemoveOnDeath() return true end

function modifier_ability_larva04_catch:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
    local radio = self:GetAbility():GetSpecialValueFor("radio")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local heros = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,0,0,false)
            for _,v in pairs(heros) do
            	v:AddNewModifier(caster,self:GetAbility(),"modifier_ability_larva04_caught",{duration = duration})
            	v:SetModifierStackCount("modifier_ability_larva04_caught", self:GetAbility(), 1 )
            end
end

modifier_ability_larva04_stun = {}
LinkLuaModifier("modifier_ability_larva04_stun","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva04_stun:IsHidden() return false end
function modifier_ability_larva04_stun:IsDebuff() return true end
function modifier_ability_larva04_stun:IsPurgable() 
	if self:GetCaster():HasModifier("modifier_larva_telent5") then
	    return false
    else
    	return true
	 end
end

function modifier_ability_larva04_stun:RemoveOnDeath() return true end

function modifier_ability_larva04_stun:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_larva04_stun:OnTakeDamage(keys)
	if keys.unit ~= self:GetParent() then return end
	if self.lock == 0 then return end
	local count = self:GetParent():GetModifierStackCount("modifier_ability_larva04_stun", nil) - keys.damage
	if count <= 0 then
	 self:GetParent():RemoveModifierByName("modifier_ability_larva04_stun")
	else
	 self:GetParent():SetModifierStackCount("modifier_ability_larva04_stun",self:GetAbility(),count)
	end
end

function modifier_ability_larva04_stun:OnCreated()
	if not IsServer() then return end
	self.lock = 0
	local count =  self:GetParent():GetModifierStackCount("modifier_ability_larva04_caught", nil)
    local damage = self:GetAbility():GetSpecialValueFor("damage") + FindTelentValue(self:GetCaster(),"special_bonus_unique_larva_3")
    local damage_table = {
	        	victim = self:GetParent(),
		        attacker = self:GetCaster(),
	        	damage = damage * count,
		        damage_type = DAMAGE_TYPE_MAGICAL,
	           }
    UnitDamageTarget(damage_table)
	self.lock = 1
	if not self:GetParent() or self:GetParent():IsNull() then
		self:Destroy()
		return
	end
	if self:GetCaster():HasModifier("modifier_larva_wanbaochui") then self:GetParent():SetModifierStackCount("modifier_ability_larva04_caught", self:GetAbility(), count + 1 ) end
	local limit = self:GetAbility():GetSpecialValueFor("damagelimit")
	self:GetParent():SetModifierStackCount("modifier_ability_larva04_stun",self:GetAbility(),limit)
end

function modifier_ability_larva04_stun:CheckState()
	return{
		[MODIFIER_STATE_NIGHTMARED]  = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
end

modifier_ability_larva04_caught = {}
LinkLuaModifier("modifier_ability_larva04_caught","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_larva04_caught:IsDebuff() return true end
function modifier_ability_larva04_caught:IsHidden() return false end
function modifier_ability_larva04_caught:IsPurgable() return false end
function modifier_ability_larva04_caught:RemoveOnDeath() return true end

function modifier_ability_larva04_caught:OnCreated()
      local caster = self:GetCaster()
      local target = self:GetParent()
     self.larvaline = ParticleManager:CreateParticle("particles/units/larva/larva04line.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	        ParticleManager:SetParticleControlEnt(self.larvaline , 0, caster, 5, "attach_hitloc", caster:GetAbsOrigin(), true)
	        ParticleManager:SetParticleControlEnt(self.larvaline , 1, target, 5, "attach_hitloc", target:GetAbsOrigin(), true)
	    end

function modifier_ability_larva04_caught:OnRemoved()
   	ParticleManager:DestroyParticle(self.larvaline,true)
end

function modifier_ability_larva04_caught:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_larva04_caught:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_ability_larva04_caught:OnUnitMoved()
	if not IsServer() then return end
	local caster = self:GetCaster()  --这是替身
	local target = self:GetParent()	
	local movelimit = self:GetAbility():GetSpecialValueFor("movelimit")
	local duration  = self:GetAbility():GetSpecialValueFor("duration")
    local stuntime = self:GetAbility():GetSpecialValueFor("stuntime")
    local radio = self:GetAbility():GetSpecialValueFor("radio")
    local distance = (self:GetParent():GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()  --判断玩家距离替身的位置
    if distance > movelimit then
    	caster:EmitSound("larva04_break")
        self:GetParent():RemoveModifierByName("modifier_ability_larva04_caught")  --没有惩罚的逃离
        local heros = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,0,0,false)
        --[[for _,v in pairs(heros) do  --连坐
        	if v:HasModifier("modifier_ability_larva04_caught") then
               v:AddNewModifier(caster,self:GetAbility(),"modifier_ability_larva04_stun",{duration = stuntime})
               if not caster:HasModifier("modifier_larva_wanbaochui") then
                     v:RemoveModifierByName("modifier_ability_larva04_caught")
                 else
                 	v:FindModifierByName("modifier_ability_larva04_caught"):SetDuration( duration , true)
                 	caster:FindModifierByName("modifier_larva_wanbaochui"):SetDuration( duration ,true )
                end
           end
       end]]

       if caster:HasModifier("modifier_larva_wanbaochui") then
       	for _,v in pairs(heros) do
       		if v:HasModifier("modifier_ability_larva04_caught") then
               v:FindModifierByName("modifier_ability_larva04_caught"):SetDuration( duration , true)
               v:AddNewModifier(caster,self:GetAbility(),"modifier_ability_larva04_stun",{duration = stuntime})
           else
           	   v:AddNewModifier(caster,self:GetAbility(),"modifier_ability_larva04_caught",{duration = duration})
            	v:SetModifierStackCount("modifier_ability_larva04_caught", self:GetAbility(), 1 )
           	end
               caster:FindModifierByName("modifier_larva_wanbaochui"):SetDuration( duration ,true )
               caster:FindModifierByName("modifier_larva_telent5"):SetDuration( duration ,true )
           end
       else
       	 for _,v in pairs(heros) do
       	 	if v:HasModifier("modifier_ability_larva04_caught") then
       	 		v:AddNewModifier(caster,self:GetAbility(),"modifier_ability_larva04_stun",{duration = stuntime})
       	 		v:RemoveModifierByName("modifier_ability_larva04_caught")
       	 	end
       	 end
    end
end
end

--modifier_ability_thdots_larva_telent_1 = {}
--LinkLuaModifier("modifier_ability_thdots_larva_telent_1","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
--function modifier_ability_thdots_larva_telent_1:IsHidden() 		return true end     --是否隐藏
--function modifier_ability_thdots_larva_telent_1:IsPurgable()     return false end     --是否可净化
--function modifier_ability_thdots_larva_telent_1:RemoveOnDeath() 	return false  end     --死亡移除
--function modifier_ability_thdots_larva_telent_1:IsDebuff()	   	return false end     --是否是DEBUFF

modifier_ability_thdots_larva_telent_2 = {}
LinkLuaModifier("modifier_ability_thdots_larva_telent_2","scripts/vscripts/abilities/abilitylarva.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_larva_telent_2:IsHidden() 		return true end     --是否隐藏
function modifier_ability_thdots_larva_telent_2:IsPurgable()     return false end     --是否可净化
function modifier_ability_thdots_larva_telent_2:RemoveOnDeath() 	return false  end     --死亡移除
function modifier_ability_thdots_larva_telent_2:IsDebuff()	   	return false end     --是否是DEBUFF














