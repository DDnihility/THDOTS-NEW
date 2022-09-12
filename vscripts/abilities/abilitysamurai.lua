ability_thdots_samurai01 = {}

function ability_thdots_samurai01:GetIntrinsicModifierName()
	return "modifier_samurai_telent5"
end

function ability_thdots_samurai01:GetCastAnimation()
	if self:GetCaster():HasModifier("modifier_samurai_special") then
	    return ACT_DOTA_CAST_ABILITY_1_END
    else
    	return ACT_DOTA_CAST_ABILITY_1
    end
end

function ability_thdots_samurai01:GetCooldown(level) 
	return self.BaseClass.GetCooldown(self, level) - self:GetCaster():GetModifierStackCount("modifier_samurai_telent5", nil)/10 - self:GetCaster():GetModifierStackCount("modifier_samurai_telent8", nil)/10
end

function ability_thdots_samurai01:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_samurai_special") then
		return 0.6
	else
	    return 0.2222
    end
end

function ability_thdots_samurai01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local distance = caster:Script_GetAttackRange()+50
	local width = 70
	self.swidth = 70
	if caster:HasModifier("modifier_samurai_special") then
	    distance = self:GetSpecialValueFor("special_length")
	    width = 288.6751345948129
	    self.swidth = 0
	    caster:RemoveModifierByName("modifier_samurai_special")
	    caster:EmitSound("samuraibreeze")
	    ParticleManager:CreateParticle("particles/thd2/heroes/exrumia/exrumia02.vpcf", PATTACH_ABSORIGIN, caster)
	end
	local damage = self:GetSpecialValueFor("bonus_damage")
	local percent = self:GetSpecialValueFor("damage_percent")
	caster:AddNewModifier(caster,self,"modifier_samurai01_damage_bonus",{duration = 0.2})
	caster:SetModifierStackCount("modifier_samurai01_damage_bonus",nil,damage)
	caster:AddNewModifier(caster,self,"modifier_samurai01_damage_percent",{duration = 0.2})
	caster:SetModifierStackCount("modifier_samurai01_damage_percent",nil,percent)
	--print(caster:GetModifierStackCount("modifier_samurai01_damage_percent",nil))
	ProjectileManager:CreateLinearProjectile({
				Ability = self,
				EffectName = "",
				vSpawnOrigin = caster:GetAbsOrigin(),
				fDistance = distance,
				fStartRadius = self.swidth,
				fEndRadius = width,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = self:GetAbilityTargetTeam(),							
				iUnitTargetType = self:GetAbilityTargetType(),							
				bDeleteOnHit = false,
				vVelocity = ((point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * 7500,
				bProvidesVision = false,	
		})
	self.lock = 0
end

function ability_thdots_samurai01:OnProjectileHit(target,location)
	if not IsServer() then return end
	if target == nil then return end
	local caster = self:GetCaster()
	if self.lock ~= 1 then 
        caster:EmitSound("samuraiattack1")
        if caster:GetModifierStackCount("modifier_samurai02_passive",nil) ~= caster:FindAbilityByName("ability_thdots_samurai02"):GetSpecialValueFor("limit") then
            if target:IsRealHero() and (caster:FindAbilityByName("ability_thdots_samurai02"):GetSpecialValueFor("limit") - caster:GetModifierStackCount("modifier_samurai02_passive",nil) >=2) then
                caster:SetModifierStackCount("modifier_samurai02_passive",nil,caster:GetModifierStackCount("modifier_samurai02_passive",nil)+2)
            else
                caster:SetModifierStackCount("modifier_samurai02_passive",nil,caster:GetModifierStackCount("modifier_samurai02_passive",nil)+1)
            end
        end
        self.lock = 1
    end
    local cp = caster:GetAbsOrigin()
    local tp = target:GetAbsOrigin() 
    caster:SetOrigin(tp)
    THDPerformAttack(caster,target,false)
    caster:SetOrigin(cp)
    if self.swidth == 70 then return end
    target:AddNewModifier(caster,self,"modifier_samurai01_slow",{duration = self:GetSpecialValueFor("slow_duration")})
    target:SetModifierStackCount("modifier_samurai01_slow",nil,self:GetSpecialValueFor("slow_percent"))
end

modifier_samurai01_slow = {}
LinkLuaModifier("modifier_samurai01_slow","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai01_slow:IsHidden() return false end
function modifier_samurai01_slow:IsPurgable() return true end
function modifier_samurai01_slow:IsDebuff() return true end
function modifier_samurai01_slow:RemoveOnDeath() return true end

function modifier_samurai01_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_samurai01_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetStackCount()
end

modifier_samurai01_damage_bonus = {}
LinkLuaModifier("modifier_samurai01_damage_bonus","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai01_damage_bonus:IsHidden() return true end
function modifier_samurai01_damage_bonus:IsPurgable() return false end
function modifier_samurai01_damage_bonus:IsDebuff() return false end
function modifier_samurai01_damage_bonus:RemoveOnDeath() return true end

function modifier_samurai01_damage_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_samurai01_damage_bonus:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

modifier_samurai01_damage_percent = {}
LinkLuaModifier("modifier_samurai01_damage_percent","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai01_damage_percent:IsHidden() return true end
function modifier_samurai01_damage_percent:IsPurgable() return false end
function modifier_samurai01_damage_percent:IsDebuff() return false end
function modifier_samurai01_damage_percent:RemoveOnDeath() return true end

function modifier_samurai01_damage_percent:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_samurai01_damage_percent:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount() - 100
end

modifier_samurai01_crit = {}
LinkLuaModifier("modifier_samurai01_crit","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai01_crit:IsHidden() return true end
function modifier_samurai01_crit:IsPurgable() return false end
function modifier_samurai01_crit:IsDebuff() return false end
function modifier_samurai01_crit:RemoveOnDeath() return true end

function modifier_samurai01_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end

function modifier_samurai01_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetStackCount()
end

ability_thdots_samurai02 = {}

function ability_thdots_samurai02:GetIntrinsicModifierName()
	return "modifier_samurai02_passive"
end

modifier_samurai02_passive = {}
LinkLuaModifier("modifier_samurai02_passive","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai02_passive:IsPurgable() return false end
function modifier_samurai02_passive:IsDebuff() return false end
function modifier_samurai02_passive:RemoveOnDeath() return false end
function modifier_samurai02_passive:IsHidden()
	if self:GetStackCount() > 0 then
		return false
	else
		return true
	end
end

function modifier_samurai02_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_samurai02_passive:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	self.check = 0
end

function modifier_samurai02_passive:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetCaster() then return end
    local caster = keys.attacker
    local count = self:GetStackCount()
    local lifeSteal = (self:GetAbility():GetSpecialValueFor("lifesteal") + self:GetCaster():GetModifierStackCount("modifier_samurai_telent4",self:GetCaster())/10) * 0.01 * self:GetStackCount()
    local limit = self:GetAbility():GetSpecialValueFor("limit")
    local add = self:GetAbility():GetSpecialValueFor("add")
    if keys.target:IsRealHero() then add = add*2 end
    local heal_count = keys.damage * lifeSteal
    caster:Heal(heal_count,caster)
    --print(heal_count)
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,heal_count,nil)
    if caster:HasModifier("modifier_samurai01_damage_bonus") then return end
    if count >= limit then return end
    if count+add >limit then self:SetStackCount(limit) return end
    self:SetStackCount(count+add)
end

function modifier_samurai02_passive:GetModifierMoveSpeedBonus_Percentage()
	return (self:GetAbility():GetSpecialValueFor("move_speed") + self:GetCaster():GetModifierStackCount("modifier_samurai_telent4",self:GetCaster())/10) * self:GetStackCount()
end

function modifier_samurai02_passive:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then return end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local block = (self:GetAbility():GetSpecialValueFor("block_percent") + self:GetCaster():GetModifierStackCount("modifier_samurai_telent4",self:GetCaster())/10) * 0.01 * self:GetStackCount()
	--print(block)
	--print(keys.damage * block)
	return keys.damage * block
end

function modifier_samurai02_passive:OnCreated()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier(caster,self:GetAbility(),"modifier_samurai_telent4",{})
    self:StartIntervalThink(0.05)
    self.check = 0
end

function modifier_samurai02_passive:OnIntervalThink()
	if not IsServer() then return end
	self.check = self.check + 0.05
        if self:GetStackCount() == self:GetAbility():GetSpecialValueFor("limit") then 
        	if self.lock == 0 then
	            self.eff = ParticleManager:CreateParticle("particles/thd2/heroes/samurai/fight.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
                ParticleManager:SetParticleControl(self.eff, 0, self:GetCaster():GetAbsOrigin())
                ParticleManager:SetParticleControl(self.eff, 2, self:GetCaster():GetAbsOrigin())
	            self.lock = 1
	            print(1)
	        end
	    else
	    	if self.eff ~= nil then
	            ParticleManager:DestroyParticle(self.eff,true)
	        end
            self.lock = 0
	    end
	if self.check < self:GetAbility():GetSpecialValueFor("delay") then return end
	self.check = 0
	if self:GetCaster():HasModifier("modifier_samurai_special") then return end
	if self:GetStackCount() == 0 then return end
	self:SetStackCount(self:GetStackCount()-1)
end

ability_thdots_samurai03 = {}

function ability_thdots_samurai03:GetIntrinsicModifierName()
	return "modifier_samurai03_cooldown"
end

function ability_thdots_samurai03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local cpoint = caster:GetAbsOrigin()
	local tpoint = self:GetCursorPosition()
	if (tpoint - cpoint):Length2D() > self:GetSpecialValueFor("limit") then
		self.length = self:GetSpecialValueFor("limit")
	else
		self.length = (tpoint - cpoint):Length2D()
	end
	self.vec = tpoint - cpoint
	caster:AddNewModifier(caster,self,"modifier_samurai03_boost",{duration = 2})
	caster:EmitSound("samuraidash")
end

modifier_samurai03_cooldown = {}
LinkLuaModifier("modifier_samurai03_cooldown","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai03_cooldown:IsHidden() return true end
function modifier_samurai03_cooldown:IsPurgable() return false end
function modifier_samurai03_cooldown:IsDebuff() return false end
function modifier_samurai03_cooldown:RemoveOnDeath() return true end

function modifier_samurai03_cooldown:DeclareFunctions()
	return {		
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_samurai03_cooldown:OnAttackLanded(keys)
	if not IsServer() then return end
    if keys.attacker ~= self:GetCaster() then return end
    if keys.target:IsBuilding() then return end
    if keys.attacker:HasModifier("modifier_samurai01_damage_bonus") then return end
    local ability = self:GetAbility()
    if ability:IsCooldownReady() then return end
    local cooldown = ability:GetCooldownTimeRemaining()-1
    if cooldown < 0 then ability:EndCooldown() return end
    ability:EndCooldown()
    ability:StartCooldown(cooldown)
end


modifier_samurai03_boost = {}
LinkLuaModifier("modifier_samurai03_boost","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai03_boost:IsHidden() return true end
function modifier_samurai03_boost:IsPurgable() return false end
function modifier_samurai03_boost:IsDebuff() return false end
function modifier_samurai03_boost:RemoveOnDeath() return true end

function modifier_samurai03_boost:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}
end

function modifier_samurai03_boost:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
	self.length = 0
	ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/ti7_immortal_shoulder/pl_ti7_edge_boost.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
	ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/ti7_immortal_shoulder/pl_ti7_edge_boost.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
	ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/ti7_immortal_shoulder/pl_ti7_edge_boost.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
end

function modifier_samurai03_boost:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local casterPoint = caster:GetAbsOrigin()
	local speed = self:GetAbility():GetSpecialValueFor("speed") * 0.03
	local tp = casterPoint + self:GetAbility().vec:Normalized() * speed
	caster:SetOrigin(tp)
	self.length = self.length + speed
	if self.length < self:GetAbility().length then return end
	caster:RemoveModifierByName("modifier_samurai03_boost")
end

function modifier_samurai03_boost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_samurai03_boost:GetModifierTotal_ConstantBlock(keys)
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	return keys.damage
end


function modifier_samurai03_boost:OnRemoved()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_samurai_special") then return end
	local limit = caster:FindAbilityByName("ability_thdots_samurai02"):GetSpecialValueFor("limit")
    caster:SetModifierStackCount("modifier_samurai02_passive",nil,limit)
end


ability_thdots_samurai04 = {}

function ability_thdots_samurai04:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_samurai04:OnUpgrade()
	if not IsServer() then return end
	local level = self:GetLevel()+1
    local caster = self:GetCaster()
    caster:FindAbilityByName("ability_thdots_samuraiEx"):SetLevel(level)
end

function ability_thdots_samurai04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:AddNewModifier(target,self,"modifier_samurai04_rush",{})
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1)
	caster:EmitSound("samuraidash")
end

modifier_samurai_special = {}
LinkLuaModifier("modifier_samurai_special","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai_special:IsHidden() return true end
function modifier_samurai_special:IsPurgable() return false end
function modifier_samurai_special:IsDebuff() return false end
function modifier_samurai_special:RemoveOnDeath() return true end

modifier_samurai04_rush = {}
LinkLuaModifier("modifier_samurai04_rush","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai04_rush:IsHidden() return true end
function modifier_samurai04_rush:IsPurgable() return false end
function modifier_samurai04_rush:IsDebuff() return false end
function modifier_samurai04_rush:RemoveOnDeath() return true end

function modifier_samurai04_rush:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}
end

function modifier_samurai04_rush:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
	ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/ti7_immortal_shoulder/pl_ti7_edge_boost.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) 
	ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/ti7_immortal_shoulder/pl_ti7_edge_boost.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) 
	ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/ti7_immortal_shoulder/pl_ti7_edge_boost.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) 
end

function modifier_samurai04_rush:OnIntervalThink()
	if not IsServer() then return end
	local speed = self:GetAbility():GetSpecialValueFor("speed") * 0.03
	local caster = self:GetParent()
	local target = self:GetCaster()
	local cp = caster:GetAbsOrigin()
	local tp = target:GetAbsOrigin()
	local vec = tp - cp
    local lp = cp + vec:Normalized()*speed
    caster:SetOrigin(lp)
    if (lp - tp):Length2D() > caster:Script_GetAttackRange() then return end
    if caster:HasModifier("modifier_samurai_special") then
    	caster:AddNewModifier(target,self:GetAbility(),"modifier_samurai04_UPslash",{duration = 0.2})
    	caster:RemoveModifierByName("modifier_samurai_special")
    else
        caster:AddNewModifier(target,self:GetAbility(),"modifier_samurai04_slash",{duration = 0.33})
    end
    self:Destroy()
end

modifier_samurai04_UPslash = {}
LinkLuaModifier("modifier_samurai04_UPslash","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai04_UPslash:IsHidden() return true end
function modifier_samurai04_UPslash:IsPurgable() return false end
function modifier_samurai04_UPslash:IsDebuff() return false end
function modifier_samurai04_UPslash:RemoveOnDeath() return true end

function modifier_samurai04_UPslash:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = self:GetCaster()
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_7,1)
end

function modifier_samurai04_UPslash:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end

function modifier_samurai04_UPslash:OnRemoved()
	if not IsServer() then return end
	local caster = self:GetParent()
	if not caster:IsAlive() then return end
	if not self:GetCaster():IsAlive() then return end
	local damage_table = {
	        	victim = self:GetCaster(),
		        attacker = caster,
	        	damage = self:GetAbility():GetSpecialValueFor("damage")+caster:GetAttackDamage(),
		        damage_type = DAMAGE_TYPE_PHYSICAL,
	           }
    UnitDamageTarget(damage_table)
    caster:EmitSound("samuraiattack2")
    local duration = self:GetAbility():GetSpecialValueFor("knocktime")
	local knockback_properties = {
			 center_x 			= caster:GetOrigin().x,
			 center_y 			= caster:GetOrigin().y,
			 center_z 			= caster:GetOrigin().z,
			 duration 			= duration,
			 knockback_duration = 0.6,
			 knockback_distance = 50,
			 knockback_height 	= 150,
		}
	self:GetCaster():AddNewModifier(caster, self, "modifier_knockback", knockback_properties)
	caster:AddNewModifier(caster,self:GetAbility(),"modifier_samurai_special",{})
	if self:GetCaster():IsAlive() then return end
	if not self:GetCaster():IsRealHero() then return end
	self:GetAbility():EndCooldown()
end

modifier_samurai04_slash = {}
LinkLuaModifier("modifier_samurai04_slash","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samurai04_slash:IsHidden() return true end
function modifier_samurai04_slash:IsPurgable() return false end
function modifier_samurai04_slash:IsDebuff() return false end
function modifier_samurai04_slash:RemoveOnDeath() return true end

function modifier_samurai04_slash:OnCreated()
	if not IsServer() then return end
	self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5,1)
end
 
function modifier_samurai04_slash:OnRemoved()
	if not IsServer() then return end
	local caster = self:GetParent()
	if not caster:IsAlive() then return end
	local damage_table = {
	        	victim = self:GetCaster(),
		        attacker = caster,
	        	damage = self:GetAbility():GetSpecialValueFor("damage")+caster:GetAttackDamage(),
		        damage_type = DAMAGE_TYPE_PHYSICAL,
	           }
    UnitDamageTarget(damage_table)
    caster:EmitSound("samuraiattack3")
	caster:AddNewModifier(caster,self:GetAbility(),"modifier_samurai_special",{})
	if self:GetCaster():IsAlive() then return end
	if not self:GetCaster():IsRealHero() then return end
	self:GetAbility():EndCooldown()
end

function modifier_samurai04_slash:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end

ability_thdots_samuraiEx = {}

function ability_thdots_samuraiEx:GetIntrinsicModifierName()
	return "modifier_samuraiEx_basic"
end

modifier_samuraiEx_basic = {}
LinkLuaModifier("modifier_samuraiEx_basic","scripts/vscripts/abilities/abilitysamurai.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_samuraiEx_basic:IsHidden() return true end
function modifier_samuraiEx_basic:IsPurgable() return false end
function modifier_samuraiEx_basic:IsDebuff() return false end
function modifier_samuraiEx_basic:RemoveOnDeath() return false end

function modifier_samuraiEx_basic:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self:StartIntervalThink(0.03)
	self.spd = 0
	caster:AddNewModifier(caster,self:GetAbility(),"modifier_samurai_ExSpd",{})
	caster:AddNewModifier(caster,self:GetAbility(),"modifier_samurai_ExAgi",{})
end

function modifier_samuraiEx_basic:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.agi = caster:GetAgility()*self:GetAbility():GetSpecialValueFor("bonus_damage")
	caster:SetModifierStackCount("modifier_samurai_ExAgi",nil,self.agi*1000)
end

function modifier_samuraiEx_basic:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_samuraiEx_basic:OnAttackLanded(keys)
	if not IsServer() then return end
    local caster = self:GetCaster()
    if keys.attacker ~= caster then return end 
    if caster:HasModifier("modifier_samurai01_damage_bonus") then
    	return
    end
    local num = RandomInt(1,99)
    if num <= 34 then
    	caster:EmitSound("samuraiattack1")
    elseif num <= 67 then
    	caster:EmitSound("samuraiattack2")
    elseif num <= 100 then
    	caster:EmitSound("samuraiattack3")
    end
end

modifier_samurai_ExSpd = {}
LinkLuaModifier("modifier_samurai_ExSpd", "scripts/vscripts/abilities/abilitysamurai.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_samurai_ExSpd:IsHidden() return true end
function modifier_samurai_ExSpd:IsDebuff() return false end
function modifier_samurai_ExSpd:IsPurgable() return false end
function modifier_samurai_ExSpd:RemoveOnDeath() return false end

function modifier_samurai_ExSpd:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_samurai_ExSpd:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_samurai_ExSpd:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
	self.spd = 0
end

function modifier_samurai_ExSpd:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local limit = self:GetAbility():GetSpecialValueFor("attack_speed")
	local chui = 0
	if caster:HasModifier("modifier_item_wanbaochui") then chui = self:GetAbility():GetSpecialValueFor("wanbaochui") end
	--print(caster:GetAttacksPerSecond())
	if caster:GetAttacksPerSecond()/(1/(limit-chui)) == 1 then return end
	if caster:GetAttacksPerSecond()/(1/(limit-chui)) > 1 then
		self.spd = self.spd - 1
	else
		self.spd = self.spd + 1
	end
	if caster:GetAttacksPerSecond() > 2 then self.spd = self.spd - 100 end
	if caster:GetAttacksPerSecond() < 0.2 then self.spd = self.spd + 100 end
	self:SetStackCount(self.spd)
end

modifier_samurai_ExAgi = {}
LinkLuaModifier("modifier_samurai_ExAgi", "scripts/vscripts/abilities/abilitysamurai.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_samurai_ExAgi:IsHidden() return true end
function modifier_samurai_ExAgi:IsDebuff() return false end
function modifier_samurai_ExAgi:IsPurgable() return false end
function modifier_samurai_ExAgi:RemoveOnDeath() return false end

function modifier_samurai_ExAgi:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_samurai_ExAgi:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()/1000
end

modifier_samurai_telent4 = {}
LinkLuaModifier("modifier_samurai_telent4", "scripts/vscripts/abilities/abilitysamurai.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_samurai_telent4:IsHidden() return true end
function modifier_samurai_telent4:IsDebuff() return false end
function modifier_samurai_telent4:IsPurgable() return false end
function modifier_samurai_telent4:RemoveOnDeath() return false end

function modifier_samurai_telent4:OnCreated()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_samurai_telent8",{})
	self:StartIntervalThink(0.03)
end

function modifier_samurai_telent4:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_samurai_04")*10)
end

modifier_samurai_telent5 = {}
LinkLuaModifier("modifier_samurai_telent5", "scripts/vscripts/abilities/abilitysamurai.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_samurai_telent5:IsHidden() return true end
function modifier_samurai_telent5:IsDebuff() return false end
function modifier_samurai_telent5:IsPurgable() return false end
function modifier_samurai_telent5:RemoveOnDeath() return false end

function modifier_samurai_telent5:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end

function modifier_samurai_telent5:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_samurai_05")*10) 
end

modifier_samurai_telent8 = {}
LinkLuaModifier("modifier_samurai_telent8", "scripts/vscripts/abilities/abilitysamurai.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_samurai_telent8:IsHidden() return true end
function modifier_samurai_telent8:IsDebuff() return false end
function modifier_samurai_telent8:IsPurgable() return false end
function modifier_samurai_telent8:RemoveOnDeath() return false end

function modifier_samurai_telent8:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end

function modifier_samurai_telent8:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_samurai_08")*10) 
end