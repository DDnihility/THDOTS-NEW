--[[一技能           早期产品经理代码

ability_thdots_miko01={}

function ability_thdots_miko01:OnSpellStart()
	if not IsServer() then return end
	self.light_slave_speed = self:GetSpecialValueFor( "speed" )
	self.light_slave_width = self:GetSpecialValueFor( "width" )
	self.light_slave_distance = self:GetSpecialValueFor( "distance" )
	self.light_slave_damage = self:GetSpecialValueFor( "damage" ) 
    
	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end

	local vDirection = vPos - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.light_slave_width,
		fEndRadius = self.light_slave_width,
		vVelocity = vDirection* self.light_slave_speed,
		fDistance = self.light_slave_distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		EffectName = "particles/thd2/heroes/miko/miko01p.vpcf",
	}
	ProjectileManager:CreateLinearProjectile( info )
end

function ability_thdots_miko01:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local vDirection = vLocation - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()
        local duration =self:GetSpecialValueFor("duration")
		hTarget:AddNewModifier(self:GetCaster(),self,"modifier_light_slave_DB",{duration=duration} )	
    end
    return false
end

modifier_light_slave_DB = {}
LinkLuaModifier("modifier_light_slave_DB", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_light_slave_DB:IsHidden() return false end
function modifier_light_slave_DB:IsDebuff() return true  end
function modifier_light_slave_DB:IsPurgable() return true end	
function modifier_light_slave_DB:RemoveOnDeath() return true end

function modifier_light_slave_DB:OnCreated()
	self:StartIntervalThink(0.5)
end

function modifier_light_slave_DB:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,	       
	        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_light_slave_DB:GetModifierMagicalResistanceBonus()
	return - self:GetAbility():GetSpecialValueFor("M_R")
end

function modifier_light_slave_DB:GetModifierMoveSpeedBonus_Percentage()
	return - self:GetAbility():GetSpecialValueFor("speed_slow")
end

function modifier_light_slave_DB:OnIntervalThink()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor("damage") * 0.2
	local damage_table = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
	if not self:GetCaster():HasModifier("modifier_miko_immortal") then return end
	UtilStun:UnitStunTarget(self:GetCaster(),self:GetParent(),0.1)
end


------------------------------------------------------------------------------------------------------二技能

ability_thdots_miko02={}

function ability_thdots_miko02:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end


function ability_thdots_miko02:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor( "duration" )
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    target:AddNewModifier(self:GetCaster(),self,"modifier_light_excuse",{duration=duration})
    if caster:HasModifier("modifier_miko_immortal") and caster ~= target then
    	caster:AddNewModifier(self:GetCaster(),self,"modifier_light_excuse",{duration=duration})
    end
end



modifier_light_excuse = {}
LinkLuaModifier("modifier_light_excuse", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_light_excuse:IsHidden() return false end
function modifier_light_excuse:IsDebuff() return false  end
function modifier_light_excuse:IsPurgable() return false end	
function modifier_light_excuse:RemoveOnDeath() return false end

function modifier_light_excuse:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_light_excuse:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("arm")
end

function modifier_light_excuse:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("arm")
end

function modifier_light_excuse:OnCreated()  
	if not IsServer() then return end
    self.eff = ParticleManager:CreateParticle("particles/thd2/heroes/miko/miko02p.vpcf", PATTACH_ABSORIGIN_FOLLOW,self:GetParent())
	self:StartIntervalThink(2)
end	

function modifier_light_excuse:OnRemoved()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.eff,true)
end

function modifier_light_excuse:OnIntervalThink()
	if not IsServer() then return end
	local stuntime = self:GetAbility():GetSpecialValueFor("stun_duration") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko05")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local caster = self:GetParent()
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetAbsOrigin(),							--find position
				   nil,										--find entity
				   radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0,
				   false
			    )					
	for hh,sb in pairs(targets) do	
		local damage_table = {
				ability = self:GetAbility(),
			    victim = sb,
			    attacker = caster,
			    damage = damage,
			    damage_type = DAMAGE_TYPE_MAGICAL,
		}	
 		UnitDamageTarget(damage_table)
        UtilStun:UnitStunTarget(caster,sb,stuntime)
        --print_r(damage_table)
    end
    ParticleManager:CreateParticle("particles/thd2/heroes/miko/miko03p.vpcf", PATTACH_ABSORIGIN,caster)
end
]]

----------------------------------------------------------------------------------------------------

ability_thdots_mikoEx = {}

function ability_thdots_mikoEx:GetIntrinsicModifierName()
	return "modifier_ability_mikoEx_vision"
end

modifier_ability_mikoEx_vision = {}
LinkLuaModifier("modifier_ability_mikoEx_vision", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_mikoEx_vision:IsHidden() return true end
function modifier_ability_mikoEx_vision:IsDebuff() return false end
function modifier_ability_mikoEx_vision:IsPurgable() return false end
function modifier_ability_mikoEx_vision:RemoveOnDeath() return false end

function modifier_ability_mikoEx_vision:OnCreated()
	self:StartIntervalThink(0.3)
	self:OnIntervalThink()
end

function modifier_ability_mikoEx_vision:OnIntervalThink()        -- 每0.3秒添加一次0.31秒的高空视野
	if not IsServer() then return end
	if not self:GetCaster():IsAlive() then return end
	local caster = self:GetCaster()
	local radius = self:GetAbility():GetSpecialValueFor("radius") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko03")
	local heros = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetAbsOrigin(),							--find position
				   nil,										--find entity
				   radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   0, 0,
				   false
			    )
	for hh,sb in pairs(heros) do
		if not sb:IsInvisible() then
			AddFOWViewer( caster:GetTeam(), sb:GetAbsOrigin(), 100, 0.31, false)
		end
	end
	if not (self:GetCaster():FindAbilityByName("ability_thdots_miko04"):GetLevel() == 3) then return end
	self.castrange = 200
end

function modifier_ability_mikoEx_vision:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_mikoEx_vision:GetModifierCastRangeBonus()
	return self.castrange
end

function modifier_ability_mikoEx_vision:OnTakeDamage(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	--[[
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then  --这一段是万宝槌折射
		if keys.unit == caster then 
		    local radius = 650
		    local damage = keys.damage * 0.16
	        local heroes = FindUnitsInRadius(
					   caster:GetTeam(),						--caster team
					   caster:GetAbsOrigin(),							--find position
					   nil,										--find entity
					   radius,						--find radius
					   DOTA_UNIT_TARGET_TEAM_ENEMY,
					   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
					   DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0,
					   false
				    )
		    for hh,sb in pairs(heroes) do
		        local damage_table = {
		        	victim = sb,
		        	attacker = caster,
		    	    damage = damage,
		    	    damage_type = DAMAGE_TYPE_PURE,
		        }
		        --直接无视反伤
		       -- if sb:HasModifier("modifier_thdots_medicine03_OnTakeDamage") or sb:HasModifier("modifier_item_frock_OnTakeDamage") then return end
		        UnitDamageTarget(damage_table)
		    end
	    	if caster:GetHealth() == 0 then return end
		    caster:Heal(damage,caster)
	    end
	end
	]]
    if self:GetCaster():FindAbilityByName("ability_thdots_miko03"):GetLevel() ~= 4 then return end  --这一段是全能吸血 根据造成的伤害进行一个heal
    if keys.attacker == caster then
    	if caster:GetHealth() == 0 then return end
        caster:Heal(keys.damage*0.1,caster)
        SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,keys.damage*0.1,nil) 
    end
end

----------------------------------------------------------------------------------------------------

ability_thdots_miko03 = {}

function ability_thdots_miko03:GetIntrinsicModifierName()
	return "modifier_ability_miko03_passive"
end

modifier_ability_miko03_passive = {}
LinkLuaModifier("modifier_ability_miko03_passive", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko03_passive:IsHidden()
	if not IsServer() then return end
	if self:GetAbility():IsCooldownReady() then 
		return false
	else
		return true
	end 
end
function modifier_ability_miko03_passive:IsDebuff() return false end
function modifier_ability_miko03_passive:IsPurgable() return false end
function modifier_ability_miko03_passive:RemoveOnDeath() return false end

function modifier_ability_miko03_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_ability_miko03_passive:OnAttackStart(keys)
	if not IsServer() then return end
	if keys.attacker:HasModifier("modifier_miko_immortal") then return end
	if keys.attacker ~= self:GetCaster() then return end
	if not keys.attacker:HasModifier("modifier_ability_miko03_next") then return end
	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3,1.8)
end

function modifier_ability_miko03_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	--print(1)
	--print(2)
	if keys.attacker ~= self:GetCaster() then return end
		if keys.attacker:HasModifier("modifier_miko_immortal") then 
	    keys.attacker:EmitSound("exrumiaattack") end
	if not self:GetAbility():IsCooldownReady() then return end --检测是否是CD中 CD中无法触发效果
	self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel() - 1))
	--print(self:GetAbility():GetCooldownTime())
	local damage = self:GetAbility():GetSpecialValueFor("damage") 
	local dmg_type = DAMAGE_TYPE_MAGICAL
	if keys.attacker:HasModifier("modifier_miko_immortal") then dmg_type = DAMAGE_TYPE_PURE end
	if keys.attacker:HasModifier("modifier_ability_miko03_next") then
	    keys.attacker:EmitSound("exrumiaattack")
		if not keys.target or keys.target:IsNull() then return end
		if keys.target:IsBuilding() then damage = damage * 0.2 end
		if keys.target:GetTeam() == keys.attacker:GetTeam() then damage = 0 end
		local damage_table = {
			victim = keys.target,
			attacker = keys.attacker,
			damage = damage,
			damage_type = dmg_type,
		}
		--SendOverheadEventMessage(nil,OVERHEAD_ALERT_DAMAGE,keys.target,damage,nil)
		ParticleManager:CreateParticle("particles/thd2/heroes/miko/miko04p.vpcf", PATTACH_ABSORIGIN,keys.target)
		UnitDamageTarget(damage_table)
		--print_r(damage_table)
		--[[if keys.target:HasModifier("modifier_ability_miko03_debuff") then      
	        local count = keys.target:GetModifierStackCount("modifier_ability_miko03_debuff", nil) + 1
	        if count == 5 then count = 4 end
            keys.target:SetModifierStackCount("modifier_ability_miko03_debuff",self:GetAbility(),count)
            keys.target:FindModifierByName("modifier_ability_miko03_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("duration"),true)
		else
	    	keys.target:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_miko03_debuff",{duration = self:GetAbility():GetSpecialValueFor("duration")})
            keys.target:SetModifierStackCount("modifier_ability_miko03_debuff",self:GetAbility(),1)
     	end]]
		if ( FindTelentValue(self:GetCaster(),"special_bonus_unique_miko08") ~= 0 ) and ( self.checkatt == 0 ) then --天赋多A一刀
			self:GetAbility():EndCooldown()
			self.checkatt = 1
		else
			self.checkatt = 0
			keys.attacker:RemoveModifierByName("modifier_ability_miko03_next")
		end
		if keys.target and not keys.target:IsNull() and FindTelentValue(self:GetCaster(),"special_bonus_unique_miko04") ~= 0 then
			local duration = keys.target:GetModifierStackCount("modifier_ability_miko03_stun", nil) * 0.1
			if keys.attacker:IsRealHero() then duration = duration + 0.5 end --眩晕叠加机制类似拉尔瓦02 duration为剩余眩晕时间
			keys.target:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_miko03_stun",{duration = duration})
			keys.target:SetModifierStackCount("modifier_ability_miko03_stun", self, duration * 10 )
			--print(duration)
		end
	else
		keys.attacker:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_ability_miko03_next",{})
		self:GetAbility():EndCooldown() --添加连击BUG 结束冷却
	end
end

modifier_ability_miko03_stun = {}
LinkLuaModifier("modifier_ability_miko03_stun", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko03_stun:IsHidden() return true end
function modifier_ability_miko03_stun:IsDebuff() return true end
function modifier_ability_miko03_stun:IsPurgable() return true end
function modifier_ability_miko03_stun:RemoveOnDeath() return true end

function modifier_ability_miko03_stun:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_ability_miko03_stun:OnIntervalThink()
	if not IsServer() then return end
	local count = self:GetParent():GetModifierStackCount("modifier_ability_miko03_stun", nil)
	self:GetParent():SetModifierStackCount("modifier_ability_miko03_stun", self, count - 1 )
end

function modifier_ability_miko03_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

modifier_ability_miko03_next = {}
LinkLuaModifier("modifier_ability_miko03_next", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko03_next:IsHidden() return true end
function modifier_ability_miko03_next:IsDebuff() return false end
function modifier_ability_miko03_next:IsPurgable() return false end
function modifier_ability_miko03_next:RemoveOnDeath() return true end

function modifier_ability_miko03_next:OnCreated()
	if not IsServer() then return end
	self.original_attacktime = self:GetCaster():GetBaseAttackTime()
	self:GetCaster():SetBaseAttackTime(1.0)
end

function modifier_ability_miko03_next:OnRemoved()
	if not IsServer() then return end
	self:GetCaster():SetBaseAttackTime(self.original_attacktime)
end

function modifier_ability_miko03_next:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_ability_miko03_next:GetModifierAttackSpeedBonus_Constant()
	return 400
end

function modifier_ability_miko03_next:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attack_range")
end

--[[modifier_ability_miko03_debuff = {}
LinkLuaModifier("modifier_ability_miko03_debuff", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko03_debuff:IsHidden() return false end
function modifier_ability_miko03_debuff:IsDebuff() return true end
function modifier_ability_miko03_debuff:IsPurgable() return true end
function modifier_ability_miko03_debuff:RemoveOnDeath() return true end

function modifier_ability_miko03_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_ability_miko03_debuff:GetModifierMagicalResistanceBonus()
	local count = self:GetParent():GetModifierStackCount("modifier_ability_miko03_debuff", nil)
	return - self:GetAbility():GetSpecialValueFor("magic_armor") * count
end]]


---------------------------------------------------------------------------------------------------------------------------------

ability_thdots_miko04 = {}

function ability_thdots_miko04:GetChannelTime()
	return 2
end

function ability_thdots_miko04:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function ability_thdots_miko04:OnSpellStart()
	if not IsServer() then return end
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    self.caster:AddNewModifier(self.caster,self,"modifier_ability_miko04_cready",{})
	self.target:AddNewModifier(self.caster,self,"modifier_ability_miko04_tready",{})
	self.ceff = ParticleManager:CreateParticle("particles/thd2/heroes/miko/miko05p.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.caster)
	self.teff = ParticleManager:CreateParticle("particles/thd2/heroes/miko/miko05p.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.target)
	self.teff2 = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.target)
    ParticleManager:SetParticleControl(self.teff2,2,Vector(500,500,0))
    self.caster:EmitSound("miko04cc")
    self.target:EmitSound("miko04tc")
end

function ability_thdots_miko04:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	if self.caster:IsAlive() and ( self.caster:GetModifierStackCount("modifier_ability_miko04_cready",nil) >= 100 ) then  --检测是否满足各项条件
		if self.target:IsAlive() then
			self.tp = self.target:GetAbsOrigin()
			local speed_duration = self:GetSpecialValueFor("speed_duration")
			self.caster:AddNewModifier(self.caster,self,"modifier_ability_miko04_speed",{duration = speed_duration})
			self.target:AddNewModifier(self.caster,self,"modifier_ability_miko04_speed",{duration = speed_duration})
			--self.caster:SetAbsOrigin(self.tp)
			FindClearSpaceForUnit(self.caster,self.tp,true)
			ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_divine_favor.vpcf", PATTACH_ABSORIGIN,self.target)
			--[[if self.caster:HasModifier("modifier_miko_immortal") then
				local heroes = FindUnitsInRadius(
				   self.caster:GetTeam(),						--caster team
				   self.caster:GetAbsOrigin(),							--find position
				   nil,										--find entity
				   500,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0,
				   false
			    )
			    for hh,sb in pairs(heroes) do
			    UtilStun:UnitStunTarget(self.caster,sb,1)
			end
		  end	]]
		end
		self.caster:EmitSound("miko04layer")
    end
	ParticleManager:DestroyParticle(self.ceff,true)
	ParticleManager:DestroyParticle(self.teff,true)
	ParticleManager:DestroyParticle(self.teff2,true)
	self.caster:RemoveModifierByName("modifier_ability_miko04_cready")
	self.target:RemoveModifierByName("modifier_ability_miko04_tready")
end

modifier_ability_miko04_speed = {}
LinkLuaModifier("modifier_ability_miko04_speed", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko04_speed:IsHidden() return false end
function modifier_ability_miko04_speed:IsPurgable() return true end
function modifier_ability_miko04_speed:IsDebuff() return false end
function modifier_ability_miko04_speed:RemoveOnDeath() return true end

function modifier_ability_miko04_speed:OnCreated()
	self.eff = ParticleManager:CreateParticle("particles/thd2/items/item_tsundere.vpcf", PATTACH_ABSORIGIN_FOLLOW,self:GetParent())
end

function modifier_ability_miko04_speed:OnRemoved()
   ParticleManager:DestroyParticle(self.eff,true)
end

function modifier_ability_miko04_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_miko04_speed:GetModifierIncomingDamage_Percentage()
	return -999
end

function modifier_ability_miko04_speed:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_STUNNED] = false,
	}
end

modifier_ability_miko04_cready = {}
LinkLuaModifier("modifier_ability_miko04_cready", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko04_cready:IsHidden() return false end
function modifier_ability_miko04_cready:IsPurgable() return false end
function modifier_ability_miko04_cready:IsDebuff() return false end
function modifier_ability_miko04_cready:RemoveOnDeath() return true end

function modifier_ability_miko04_cready:OnCreated()
	self:StartIntervalThink(0.04)
	self:OnIntervalThink()
end

function modifier_ability_miko04_cready:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local count = caster:GetModifierStackCount("modifier_ability_miko04_cready",nil) + 2
	if count >= 100 then count = 100 end
	caster:SetModifierStackCount("modifier_ability_miko04_cready", self:GetAbility(),count)
	local heal = self:GetAbility():GetSpecialValueFor("heal")
	caster:Heal(heal,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,heal,nil)
end

modifier_ability_miko04_tready = {}
LinkLuaModifier("modifier_ability_miko04_tready", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko04_tready:IsHidden() return false end
function modifier_ability_miko04_tready:IsPurgable() return false end
function modifier_ability_miko04_tready:IsDebuff() return false end
function modifier_ability_miko04_tready:RemoveOnDeath() return true end

function modifier_ability_miko04_tready:OnCreated()
	self:StartIntervalThink(0.05)
	self:OnIntervalThink()
end

function modifier_ability_miko04_tready:OnIntervalThink()
	if not IsServer() then return end
	local count = self:GetCaster():GetModifierStackCount("modifier_ability_miko04_cready",nil) + 2
	if count >= 100 then count = 100 end
	self:GetParent():SetModifierStackCount("modifier_ability_miko04_tready", self:GetAbility(),count)
	if not self:GetCaster():IsAlive() then 
		self:GetParent():RemoveModifierByName("modifier_ability_miko04_tready")
	end
	local heal = self:GetAbility():GetSpecialValueFor("heal")
	if self:GetCaster():HasModifier("modifier_miko_immortal") then
		local heros = FindUnitsInRadius(
				   self:GetCaster():GetTeam(),						--caster team
				   self:GetParent():GetAbsOrigin(),							--find position
				   nil,										--find entity
				   500,						--find radius
				   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   0, 0,
				   false
			    ) 
		   for hh,sb in pairs(heros) do
			 sb:Heal(heal,self:GetCaster())
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,sb,heal,nil)
		   end
		else
	       self:GetParent():Heal(heal,self:GetCaster())
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetParent(),heal,nil)
    end
end

--[[function modifier_ability_miko04_tready:OnRemoved()
	if self:GetParent():IsAlive() and self:GetCaster():GetModifierStackCount("modifier_ability_miko04_cready",nil) >= 100 then
		self:GetCaster():RemoveModifierByName("modifier_ability_miko04_cready")
		if self:GetCaster():IsAlive() then
	     	self.tpoint = self:GetParent():GetAbsOrigin()
		    self:GetCaster():SetOrigin(self.tpoint)
		    FindClearSpaceForUnit(self:GetCaster(),self.tpoint,true)
		end
	else
		self:GetCaster():RemoveModifierByName("modifier_ability_miko04_cready")
	end
end]]

------------------------------------------------------------------------------------------------------------------------------------------

ability_thdots_mikoWanbao = {}

function ability_thdots_mikoWanbao:GetIntrinsicModifierName()
	return "modifier_miko_telent"
end

function ability_thdots_mikoWanbao:GetCastRange()
	return 700
end

function ability_thdots_mikoWanbao:OnInventoryContentsChanged() --无万宝槌时隐藏
	if not IsServer() then return end
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			self:SetHidden(true)
		end
end

function ability_thdots_mikoWanbao:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster,self,"modifier_ability_mikoWanbao_disable",{duration = duration})
	target:AddNewModifier(caster,self,"modifier_ability_mikoWanbao_disable",{duration = duration})
end

modifier_ability_mikoWanbao_disable = {}
LinkLuaModifier("modifier_ability_mikoWanbao_disable", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_mikoWanbao_disable:IsHidden() return false end
function modifier_ability_mikoWanbao_disable:IsPurgable() return false end
function modifier_ability_mikoWanbao_disable:RemoveOnDeath() return true end
function modifier_ability_mikoWanbao_disable:IsDebuff()
	if not IsServer() then return end
	if self:GetParent():GetTeam() == self:GetCaster():GetTeam() then return false end
	return true
end

function modifier_ability_mikoWanbao_disable:CheckState()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_miko_immortal") then
	    self.tableskill = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
	   }
    else
	   self.tableskill = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
	   }
    end
	return self.tableskill
end

function modifier_ability_mikoWanbao_disable:OnCreated()
	self.eff = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_blade_fury_disk.vpcf", PATTACH_ABSORIGIN_FOLLOW,self:GetParent())
	self:GetParent():EmitSound("mikowanbao")
end

function modifier_ability_mikoWanbao_disable:OnRemoved()
	ParticleManager:DestroyParticle(self.eff,true)
end

----------------------------------------------------------------------------------------------------------------------------------

modifier_miko_telent = {}
LinkLuaModifier("modifier_miko_telent", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_miko_telent:IsHidden() return true end
function modifier_miko_telent:IsPurgable() return false end
function modifier_miko_telent:RemoveOnDeath() return false end
function modifier_miko_telent:IsDebuff() return false end

function modifier_miko_telent:OnCreated()
	self:StartIntervalThink(0.03)
	self:OnIntervalThink()
end

function modifier_miko_telent:OnIntervalThink() -- 天赋监听
	if not IsServer() then return end
	local caster = self:GetCaster()
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miko06") ~= 0 and (self:GetCaster():HasModifier("modifier_miko_immortal") == false) then self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_miko_immortal",{}) end
    if FindTelentValue(self:GetCaster(),"special_bonus_unique_miko01") ~= 0 and (self:GetCaster():HasModifier("modifier_miko_telent1") == false) then self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_miko_telent1",{}) end
    if FindTelentValue(self:GetCaster(),"special_bonus_unique_miko05") ~= 0 and (self:GetCaster():HasModifier("modifier_miko_telent5") == false) then self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_miko_telent5",{}) end
    if self:GetCaster():FindAbilityByName("ability_thdots_miko01"):GetLevel() == 0 then return end --1技能满级特殊效果
    if self:GetCaster():HasModifier("modifier_miko_immortal") then
    	caster:Heal(caster:GetMaxHealth()*0.0003,caster)
    end
end

function modifier_miko_telent:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EXP_RATE_BOOST,
		--MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

--[[function modifier_miko_telent:GetModifierMoveSpeedBonus_Constant()
	if not IsServer() then return end
	if not (FindTelentValue(self:GetCaster(),"special_bonus_unique_miko01") ~= 0) then return end
	--print(self:GetAbility():GetSpecialValueFor("speed"))
	return 25 --self:GetAbility():GetSpecialValueFor("speed")
end]]

function modifier_miko_telent:GetModifierPercentageExpRateBoost()
	if not IsServer() then return end
	if not (FindTelentValue(self:GetCaster(),"special_bonus_unique_miko02") ~= 0) then return end
	return self:GetAbility():GetSpecialValueFor("exp")
end

modifier_miko_immortal = {}
LinkLuaModifier("modifier_miko_immortal", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_miko_immortal:IsHidden() return false end
function modifier_miko_immortal:IsPurgable() return false end
function modifier_miko_immortal:RemoveOnDeath() return false end
function modifier_miko_immortal:IsDebuff() return false end

function modifier_miko_immortal:OnCreated()
	if not IsServer() then return end
	self:GetCaster():SetOriginalModel("models/miko/miko_b.vmdl")
	self:StartIntervalThink(0.03)
end

function modifier_miko_immortal:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
       -- MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

--[[function modifier_miko_immortal:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_bonus")
end]]

function modifier_miko_immortal:GetModifierAttackRangeBonus()
	if self:GetCaster():FindAbilityByName("ability_thdots_miko03"):GetLevel() == 0 then return end
	return self:GetAbility():GetSpecialValueFor("attack_range")
end

modifier_miko_telent1 = {}
LinkLuaModifier("modifier_miko_telent1", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_miko_telent1:IsHidden() return true end
function modifier_miko_telent1:IsDebuff() return false end
function modifier_miko_telent1:IsPurgable() return false end
function modifier_miko_telent1:RemoveOnDeath() return false end

function modifier_miko_telent1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end

function modifier_miko_telent1:GetModifierConstantManaRegen()
	return self:GetCaster():FindAbilityByName("special_bonus_unique_miko01"):GetSpecialValueFor("value")
end

modifier_miko_telent5 = {}
LinkLuaModifier("modifier_miko_telent5", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_miko_telent5:IsHidden() return true end
function modifier_miko_telent5:IsDebuff() return false end
function modifier_miko_telent5:IsPurgable() return false end
function modifier_miko_telent5:RemoveOnDeath() return false end

function modifier_miko_telent5:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miko05"))
end

ability_thdots_miko01 = {}

function ability_thdots_miko01:GetCooldown(level) 
	if self:GetCaster():HasModifier("modifier_miko_telent5") then
		return self.BaseClass.GetCooldown(self, level) - 5
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_miko01:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_miko01:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_miko01:OnSpellStart() --施法时就转移到目的地了
	self.tpoint = self:GetCursorPosition()
	self.caster = self:GetCaster()
	local vision = self.caster:GetCurrentVisionRange()
	local duration = self:GetSpecialValueFor("disappear_duration")
	self.caster:AddNewModifier(self.caster,self,"modifier_ability_miko01_disappearing",{duration = duration})
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miko07") ~= 0 then
		self.Particle = "particles/thd2/heroes/miko/miko1_600/miko1_600.vpcf"
	else
		self.Particle = "particles/thd2/heroes/miko/miko1_300/miko1_300.vpcf"
	end
    local thinker = CreateModifierThinker(self.caster,self,"modifier_ability_miko01_effect",{duration = duration},self.tpoint,self.caster:GetTeamNumber(),false)
    ParticleManager:CreateParticle(self.Particle, PATTACH_ABSORIGIN,thinker)
	self.caster:AddNoDraw()
	FindClearSpaceForUnit(self.caster,self.tpoint,true)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self.tpoint, vision, duration, false)
	self.caster:EmitSound("miko01c")
end

modifier_ability_miko01_disappearing = {}
LinkLuaModifier("modifier_ability_miko01_disappearing", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko01_disappearing:IsHidden() return false end
function modifier_ability_miko01_disappearing:IsDebuff() return false end
function modifier_ability_miko01_disappearing:IsPurgable() return false end
function modifier_ability_miko01_disappearing:RemoveOnDeath() return false end

function modifier_ability_miko01_disappearing:CheckState()
	return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = false,
	}
end

function modifier_ability_miko01_disappearing:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
end

function modifier_ability_miko01_disappearing:GetBonusNightVision()
	return -99999
end

function modifier_ability_miko01_disappearing:GetBonusDayVision()
	return -99999
end

function modifier_ability_miko01_disappearing:OnDestroy() --状态移除时造成各项效果
	if not IsServer() then return end
	self:GetCaster():RemoveNoDraw()
	self.eff = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_ABSORIGIN,self:GetParent())
	if not self:GetCaster():IsAlive() then return end
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	if self:GetParent():FindAbilityByName("ability_thdots_miko01"):GetLevel() == 4 then damage = damage + 100 end
	local stuntime = self:GetAbility():GetSpecialValueFor("stuntime")
	local heroes = FindUnitsInRadius(
				   self:GetCaster():GetTeam(),						--caster team
				   self:GetCaster():GetAbsOrigin(),							--find position
				   nil,										--find entity
				   radius+FindTelentValue(self:GetCaster(),"special_bonus_unique_miko07"),						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0,
				   false
			    )
	for hh,sb in pairs(heroes) do
		UtilStun:UnitStunTarget(self:GetCaster(),sb,stuntime)
		local damage_table = {
			victim = sb,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		UnitDamageTarget(damage_table)
	end
	self:GetCaster():EmitSound("miko01i")
end

modifier_ability_miko01_effect = {}
LinkLuaModifier("modifier_ability_miko01_effect", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)

ability_thdots_miko02 = {}

function ability_thdots_miko02:GetCastRange()
	return 800
end

function ability_thdots_miko02:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster,self,"modifier_ability_miko02_check",{})
	else
		caster:RemoveModifierByName("modifier_ability_miko02_check")
	end
end

modifier_ability_miko02_check = {}
LinkLuaModifier("modifier_ability_miko02_check", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko02_check:IsHidden() 		return true end
function modifier_ability_miko02_check:IsPurgable()		return false end
function modifier_ability_miko02_check:RemoveOnDeath() 	return true end
function modifier_ability_miko02_check:IsDebuff()		return false end

function modifier_ability_miko02_check:OnCreated()
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_ability_miko02_check:OnIntervalThink() --判断蓝量是否满足添加BUFF的要求
	if not IsServer() then return end
	local caster = self:GetCaster()
	local mana = caster:GetMana()
	local spend = 32
	if self:GetCaster():HasModifier("modifier_miko_immortal") then spend = 0 end
	if not (mana >= spend) then
	caster:RemoveModifierByName("modifier_ability_miko02_aura")
	return end
    caster:SpendMana(spend,self:GetAbility())
    if not caster:HasModifier("modifier_ability_miko02_aura") then
    	if not caster:HasModifier("modifier_miko_immortal") then
    caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_miko02_aura",{}) end end
    caster:AddNewModifier(caster,self:GetAbility(),"modifier_ability_miko02_bonus",{duration = 1.1})
end

function modifier_ability_miko02_check:OnRemoved()
	if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_ability_miko02_aura")
end


modifier_ability_miko02_aura = {}
LinkLuaModifier("modifier_ability_miko02_aura", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko02_aura:IsHidden() 		return false end
function modifier_ability_miko02_aura:IsPurgable()		return false end
function modifier_ability_miko02_aura:RemoveOnDeath() 	return true end
function modifier_ability_miko02_aura:IsDebuff()		return false end

function modifier_ability_miko02_aura:GetAuraRadius() return 800 end -- global
function modifier_ability_miko02_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_miko02_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ability_miko02_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_miko02_aura:GetModifierAura() return "modifier_ability_miko02_bonus" end
function modifier_ability_miko02_aura:IsAura() return true end

modifier_ability_miko02_bonus = {}
LinkLuaModifier("modifier_ability_miko02_bonus", "scripts/vscripts/abilities/abilitymiko.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko02_bonus:IsHidden() 		return true end
function modifier_ability_miko02_bonus:IsPurgable()		return false end
function modifier_ability_miko02_bonus:RemoveOnDeath() 	return true end
function modifier_ability_miko02_bonus:IsDebuff()		return false end

function modifier_ability_miko02_bonus:DeclareFunctions()
	return {
		--MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end
--[[
function modifier_ability_miko02_bonus:GetModifierMoveSpeedBonus_Percentage()
    local bonus = self:GetStackCount() / 10	
	return bonus
end

function modifier_ability_miko02_bonus:GetModifierSpellAmplify_Percentage()
	local bonus = self:GetStackCount() / 10	
	return bonus
end
]]
function modifier_ability_miko02_bonus:GetModifierMoveSpeedBonus_Constant()
	local speed_bonus = self:GetStackCount() / 10 * self:GetAbility():GetSpecialValueFor("speed_bonus")
	return speed_bonus
end

function modifier_ability_miko02_bonus:GetModifierSpellAmplify_Percentage()
	local bonus = self:GetStackCount() / 10	* self:GetAbility():GetSpecialValueFor("bonus")
	return bonus
end 

function modifier_ability_miko02_bonus:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ability_miko02_bonus:OnIntervalThink() --将数值存在count中 否则client读取不到
	--换成用层数代表是否半数效果(5)、全效果(10)、1.5倍效果(15)，再直接乘以提升属性
	if not IsServer() then return end
	local bonus = self:GetAbility():GetSpecialValueFor("bonus")
	local speed_bonus = self:GetAbility():GetSpecialValueFor("speed_bonus")
	--local num = FindTelentValue(self:GetCaster(),"special_bonus_unique_miko05")
	local count = 10--层数
	if self:GetParent() ~= self:GetCaster() then 
		--bonus = bonus * ( 0.5 + num )
		count = count * ( 0.5 )
	else
		if self:GetParent():FindAbilityByName("ability_thdots_miko02"):GetLevel() == 4 then 
			--bonus = bonus * 1.5 
			count = count * 1.5
		end
    end
    --self:SetStackCount(bonus * 10)
    self:SetStackCount(count)
end