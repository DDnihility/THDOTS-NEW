ability_thdots_miko2_1 = {}

function ability_thdots_miko2_1:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster,self,"modifier_ability_miko2_1check",{})
	else
		caster:RemoveModifierByName("modifier_ability_miko2_1check")
	end
end

function ability_thdots_miko2_1:OnProjectileHit(target, location)
	if not IsServer() then return end
	self.damage = self:GetSpecialValueFor("damage") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_8") + self:GetCaster():GetMaxMana()*self:GetSpecialValueFor("mana_damage_percent")*0.01
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_6") ~= 0 then self.damage = self.damage + self:GetCaster():GetMaxMana()*0.03 end
	local damage_table = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	target:EmitSound("miko2spell1")
	UnitDamageTarget(damage_table)
end


function ability_thdots_miko2_1:GetIntrinsicModifierName()
	return "modifier_ability_miko2_1ball"
end

modifier_ability_miko2_1ball = {}
LinkLuaModifier("modifier_ability_miko2_1ball", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_1ball:IsHidden() return true end
function modifier_ability_miko2_1ball:IsDebuff() return false end
function modifier_ability_miko2_1ball:IsPurgable() return false end
function modifier_ability_miko2_1ball:RemoveOnDeath() return false end

modifier_ability_miko2_1check = {}
LinkLuaModifier("modifier_ability_miko2_1check", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_1check:IsHidden() return false end
function modifier_ability_miko2_1check:IsDebuff() return false end
function modifier_ability_miko2_1check:IsPurgable() return false end
function modifier_ability_miko2_1check:RemoveOnDeath() return false end


function modifier_ability_miko2_1ball:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1) 
end

function modifier_ability_miko2_1ball:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
    if not caster:HasModifier("modifier_ability_miko2_1check") then return end
    if not (caster:GetMana() >= (caster:GetMaxMana() * self:GetAbility():GetSpecialValueFor("mana_cost_percent") * 0.01 + self:GetAbility():GetSpecialValueFor("mana_cost_constant"))) then
   	return
   end
	local heroes = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetAbsOrigin(),							--find position
				   nil,										--find entity
				   self:GetAbility():GetSpecialValueFor("radius"),						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   0, 1, -- 1是最近 2是最远
				   false
			    )
	if #heroes == 0 then return end
   caster:SpendMana((caster:GetMaxMana() * self:GetAbility():GetSpecialValueFor("mana_cost_percent") * 0.01 + self:GetAbility():GetSpecialValueFor("mana_cost_constant")),self:GetAbility())
	if caster:HasModifier("modifier_ability_miko2_2c") then 
		local projectile = {Target = caster:FindModifierByName("modifier_ability_miko2_2c"):GetCaster(),
				Source = caster,
				Ability = self:GetAbility(),
				EffectName = "particles/thd2/heroes/miko2/miko_fx/miko_fx1.vpcf",
				iMoveSpeed = 600,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = true,
		}
	ProjectileManager:CreateTrackingProjectile(projectile)
	caster:EmitSound("miko2spell1start")
	else
	local projectile = {Target = heroes[1],
				Source = caster,
				Ability = self:GetAbility(),
				EffectName = "particles/thd2/heroes/miko2/miko_fx/miko_fx1.vpcf",
				iMoveSpeed = 600,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = true,
			}
	ProjectileManager:CreateTrackingProjectile(projectile)
	caster:EmitSound("miko2spell1start")
end
end

ability_thdots_miko2_2 = {}

function ability_thdots_miko2_2:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function ability_thdots_miko2_2:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

function ability_thdots_miko2_2:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	if is_spell_blocked(self.target) then return end
	self.target:AddNewModifier(caster,self,"modifier_ability_miko2_2t",{})
end

function ability_thdots_miko2_2:OnChannelFinish(bInterrupted)
	
	self.target:RemoveModifierByName("modifier_ability_miko2_2t")
end

modifier_ability_miko2_2t = {}
LinkLuaModifier("modifier_ability_miko2_2t", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_2t:IsHidden() return false end
function modifier_ability_miko2_2t:IsDebuff() return true end
function modifier_ability_miko2_2t:IsPurgable() return true end
function modifier_ability_miko2_2t:RemoveOnDeath() return true end

function modifier_ability_miko2_2t:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():InterruptChannel()
	self:GetCaster():RemoveModifierByName("modifier_ability_miko2_2c")
   ParticleManager:DestroyParticle(self.kun,true)
   self:GetParent():StopSound("miko2spell2")
end

function modifier_ability_miko2_2t:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_ability_miko2_2t:OnCreated()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_miko2_2c",{})
	self:StartIntervalThink(0.1)
	self.kun = ParticleManager:CreateParticle("particles/thd2/heroes/miko2/miko_fx/miko_fx2.vpcf", PATTACH_ABSORIGIN,self:GetParent())
	--[[self.kun = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_ABSORIGIN,self:GetParent())
	ParticleManager:SetParticleControlEnt(self.kun, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.kun, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.kun, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.kun, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.kun, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)	]]
	self:GetParent():EmitSound("miko2spell2")
end

function modifier_ability_miko2_2t:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
    local target = self:GetParent()
	local damage = self:GetAbility():GetSpecialValueFor("damage") * 0.1
    local damage_table = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
	UnitDamageTarget(damage_table)
end

modifier_ability_miko2_2c = {}
LinkLuaModifier("modifier_ability_miko2_2c", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_2c:IsHidden() return false end
function modifier_ability_miko2_2c:IsDebuff() return false end
function modifier_ability_miko2_2c:IsPurgable() return false end
function modifier_ability_miko2_2c:RemoveOnDeath() return false end

ability_thdots_miko2_3 = {}

--[[function ability_thdots_miko2_3:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_5
end]]

function ability_thdots_miko2_3:GetIntrinsicModifierName()
	return "modifier_ability_miko2_3passive"
end

function ability_thdots_miko2_3:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:AddNewModifier(caster,self,"modifier_ability_miko2_3check",{duration = self:GetSpecialValueFor("duration")})
end

modifier_ability_miko2_3passive = {}
LinkLuaModifier("modifier_ability_miko2_3passive", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_3passive:IsHidden() return true end
function modifier_ability_miko2_3passive:IsDebuff() return false end
function modifier_ability_miko2_3passive:IsPurgable() return false end
function modifier_ability_miko2_3passive:RemoveOnDeath() return false end

function modifier_ability_miko2_3passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_miko2_3passive:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	if keys.damage_type ~= 2 then return end
	if not self:GetCaster():IsAlive() then return end 
    local total = keys.damage
    local percent = self:GetAbility():GetSpecialValueFor("percent") * 0.01 + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_5") * 0.01
    local heal_count = total * percent
    keys.attacker:Heal(heal_count ,keys.attacker)
    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,keys.attacker,heal_count,nil)
end

modifier_ability_miko2_3check = {}
LinkLuaModifier("modifier_ability_miko2_3check", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_3check:IsHidden() return false end
function modifier_ability_miko2_3check:IsDebuff() return false end
function modifier_ability_miko2_3check:IsPurgable() return false end
function modifier_ability_miko2_3check:RemoveOnDeath() return false end

function modifier_ability_miko2_3check:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FINISHED,
	}
end

function modifier_ability_miko2_3check:OnAttackFinished(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	if keys.target:GetTeam() == keys.attacker:GetTeam() then return end
	if keys.attacker:GetName() == "npc_dota_hero_rubick" then return end
	keys.attacker:RemoveModifierByName("modifier_ability_miko2_3check")
end

function modifier_ability_miko2_3check:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	if keys.target:GetTeam() == keys.attacker:GetTeam() then return end
	local caster = self:GetCaster()
	caster:EmitSound("exrumiaattack")
	local point = keys.target:GetAbsOrigin()
	ParticleManager:CreateParticle("particles/thd2/heroes/miko/miko04p.vpcf", PATTACH_ABSORIGIN,keys.target)
	local heroes = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   point,							--find position
				   nil,										--find entity
				   self:GetAbility():GetSpecialValueFor("radius"),						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				   0, 0, -- 1是最近 2是最远
				   false
			    )
	for hh,sb in pairs(heroes) do
		local damage_table = {
			victim = sb,
			attacker = keys.attacker,
			damage = self:GetAbility():GetSpecialValueFor("damage")+self:GetCaster():GetStrength()*self:GetAbility():GetSpecialValueFor("strength_bonus"),
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		sb:AddNewModifier(caster,self:GetAbility(),"modifier_ability_miko2_3debuff",{duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
		UnitDamageTarget(damage_table)
	end
	if caster:GetName() == "npc_dota_hero_rubick" then caster:RemoveModifierByName("modifier_ability_miko2_3check") end
end

function modifier_ability_miko2_3check:OnCreated()
	if not IsServer() then return end
	if self:GetCaster():GetName() == "npc_dota_hero_rubick" then return end
	self:GetCaster():SetOriginalModel("models/miko/miko_b.vmdl")
	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5,1)
end

function modifier_ability_miko2_3check:OnDestroy()
	if not IsServer() then return end
	if self:GetCaster():GetName() == "npc_dota_hero_rubick" then return end
	self:GetCaster():SetOriginalModel("models/miko/miko.vmdl")
end

modifier_ability_miko2_3debuff = {}
LinkLuaModifier("modifier_ability_miko2_3debuff", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_3debuff:IsHidden() return false end
function modifier_ability_miko2_3debuff:IsDebuff() return true end
function modifier_ability_miko2_3debuff:IsPurgable() return true end
function modifier_ability_miko2_3debuff:RemoveOnDeath() return true end

function modifier_ability_miko2_3debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_miko2_3debuff:GetModifierMoveSpeedBonus_Percentage()
	return - self:GetAbility():GetSpecialValueFor("slow_percent")
end

ability_thdots_miko2_4 = {}

function ability_thdots_miko2_4:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_ability_miko2_4load") then
	 	return 0
	else
	 	return self.BaseClass.GetManaCost(self, level )
	end
end

function ability_thdots_miko2_4:GetCooldown(level) 
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then 
		return self.BaseClass.GetCooldown(self, level) - self:GetSpecialValueFor("wanbao_cool")
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_miko2_4:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_ability_miko2_4check") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function ability_thdots_miko2_4:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_ability_miko2_4check") then
		if is_spell_blocked(target) then return end
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5,1)
		target:AddNewModifier(caster,self,"modifier_ability_miko2_4debuff",{duration = self:GetSpecialValueFor("duration")})
		caster:AddNewModifier(caster,self,"modifier_ability_miko2_4check",{duration = self:GetSpecialValueFor("duration")+0.1})
		self.remain_time = self:GetCooldownTimeRemaining()
		self:EndCooldown()
	else
		self:EndCooldown()
		if not self:GetCaster():HasModifier("modifier_ability_miko2_4load") then
			if self:GetCaster():GetModelName() == "models/miko/miko.vmdl" then
        		caster:AddNewModifier(caster,self,"modifier_ability_miko2_4load",{duration = 0.4})
				self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3,1)
			else
        caster:AddNewModifier(caster,self,"modifier_ability_miko2_4load",{duration = 0.2})
      	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,1)
   		end
		end
	end
end

function ability_thdots_miko2_4:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local damage = self:GetSpecialValueFor("damage") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_4")
		local dmg_table = {
    		victim = hTarget,
    		attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
    	}
    	UnitDamageTarget(dmg_table)
    end
    return false
end

modifier_ability_miko2_4load = {}
LinkLuaModifier("modifier_ability_miko2_4load", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_4load:IsHidden() return true end
function modifier_ability_miko2_4load:IsDebuff() return false end
function modifier_ability_miko2_4load:IsPurgable() return false end 
function modifier_ability_miko2_4load:RemoveOnDeath() return false end

function modifier_ability_miko2_4load:OnDestroy()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
	local remaining_time = 30 - self:GetCaster():FindModifierByName("modifier_ability_miko2_4check"):GetStackCount() 
	print(remaining_time)
	    if self:GetCaster():GetModelName() == "models/miko/miko.vmdl" then
	       self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_miko2_4yanchu",{duration = remaining_time * 0.1 - 0.4})
	     else
          self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_miko2_4yanchu",{duration = remaining_time * 0.1 - 0.2})
       end
   end
	self:GetCaster():RemoveModifierByName("modifier_ability_miko2_4check")
end

modifier_ability_miko2_4yanchu = {}
LinkLuaModifier("modifier_ability_miko2_4yanchu", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_4yanchu:IsHidden() return true end
function modifier_ability_miko2_4yanchu:IsDebuff() return false end
function modifier_ability_miko2_4yanchu:IsPurgable() return false end 
function modifier_ability_miko2_4yanchu:RemoveOnDeath() return false end

function modifier_ability_miko2_4yanchu:OnDestroy()
	if not IsServer() then return end
	if self:GetCaster():GetModelName() == "models/miko/miko.vmdl" then
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3,1)
	else
      self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,1)
   end
end

modifier_ability_miko2_4debuff = {}
LinkLuaModifier("modifier_ability_miko2_4debuff", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_4debuff:IsHidden() return false end
function modifier_ability_miko2_4debuff:IsDebuff() return true end
function modifier_ability_miko2_4debuff:IsPurgable() return false end 
function modifier_ability_miko2_4debuff:RemoveOnDeath() return false end

function modifier_ability_miko2_4debuff:OnCreated()
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle("particles/heroes/miko2/miko04s1.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	self:GetParent():EmitSound("miko2_04slow")
	self:SetStackCount(100)
	self:StartIntervalThink(0.03)
	self.mikoc = true
	    local start_position = self:GetParent():GetAbsOrigin()
		start_position = start_position + Vector(1,0,0):Normalized() * 300
   	 local unit = CreateUnitByName(
		"npc_miko_04_dummy_unit"
		,start_position
		,false
		,self:GetCaster()
		,self:GetCaster()
		,self:GetCaster():GetTeam()
	)
		local vec = unit:GetAbsOrigin()
		unit:SetAbsOrigin(Vector(vec.x,vec.y,vec.z+100))
   	 unit:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_miko2_4ball",{duration = 0.3})
	 --[[  local projectile = {Target = self:GetParent(),
				Source = unit,
				Ability = self:GetAbility(),
				EffectName = "particles/units/heroes/hero_void_spirit/guandao_strike_projectile_initial.vpcf",
				iMoveSpeed = 400,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = true,
			}
	   ProjectileManager:CreateTrackingProjectile(projectile)]]
	   --unit:RemoveSelf()
end

function modifier_ability_miko2_4debuff:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(self:GetStackCount() - 1)
	local start_position = self:GetParent():GetAbsOrigin()
	if self:GetStackCount() == 90 then
		start_position = start_position + Vector(0,1,0):Normalized() * 300
		local unit = CreateUnitByName(
		"npc_miko_04_dummy_unit"
		,start_position	
		,false
		,self:GetCaster()
		,self:GetCaster()
		,self:GetCaster():GetTeam()
	)
		local vec = unit:GetAbsOrigin()
		unit:SetAbsOrigin(Vector(vec.x,vec.y,vec.z+100))
   	 unit:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_miko2_4ball",{duration = 0.3})
   	elseif self:GetStackCount() == 80 then
		start_position = start_position + Vector(-1,0,0):Normalized() * 300
   		local unit = CreateUnitByName(
		"npc_miko_04_dummy_unit"
		,start_position
		,false
		,self:GetCaster()
		,self:GetCaster()
		,self:GetCaster():GetTeam()
	)
		local vec = unit:GetAbsOrigin()
		unit:SetAbsOrigin(Vector(vec.x,vec.y,vec.z+100))
   	 unit:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_miko2_4ball",{duration = 0.3})
   	elseif self:GetStackCount() == 70 then
		start_position = start_position + Vector(0,-1,0):Normalized() * 300
   		local unit = CreateUnitByName(
		"npc_miko_04_dummy_unit"
		,start_position
		,false
		,self:GetCaster()
		,self:GetCaster()
		,self:GetCaster():GetTeam()
	)
		local vec = unit:GetAbsOrigin()
		unit:SetAbsOrigin(Vector(vec.x,vec.y,vec.z+100))
   	 unit:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_miko2_4ball",{duration = 0.3})
   	end
	--if self:GetStackCount() >= 66 then return end
	if self.mikoc == false then return end
	if self:GetCaster():HasModifier("modifier_ability_miko2_4check") then return end
	if not self:GetCaster():IsAlive() and self:GetParent():IsAlive() then return end
	local count = 0
	if not (self:GetCaster():GetName() == "npc_dota_hero_rubick") then count = self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):GetStackCount() end
	--self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):SetStackCount(count + 1)
	-- if not (FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_7") ~= 0) and (count > self:GetAbility():GetSpecialValueFor("limit")) then count = self:GetAbility():GetSpecialValueFor("limit") end
	local cpoint = self:GetCaster():GetAbsOrigin()
	local tpoint = self:GetParent():GetAbsOrigin()
	local heroes = FindUnitsInLine(self:GetCaster():GetTeam(), cpoint, tpoint, nil,100,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0)
	for hh,sb in pairs(heroes) do
	  local damage_table = {
		victim = sb,
		attacker = self:GetCaster(),
		damage = self:GetAbility():GetSpecialValueFor("last_damage") + count * self:GetAbility():GetSpecialValueFor("stack_damage") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_7"),
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	   UnitDamageTarget(damage_table)
	  -- print(count)
   end
	local vec = cpoint - tpoint
	local fpoint = tpoint - vec:Normalized() * 150
	FindClearSpaceForUnit(self:GetCaster(), fpoint, true)
	self.mikoc = false
	local step_particle = ParticleManager:CreateParticle("particles/heroes/miko2/miko04.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(step_particle, 0, cpoint)
	ParticleManager:SetParticleControl(step_particle, 1, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(step_particle)
	self:GetCaster():EmitSound("Hero_VoidSpirit.AstralStep.Start")
	--print(self:GetCaster():GetModelName())
end

function modifier_ability_miko2_4debuff:OnDestroy()
	if not IsServer() then return end
	if not self:GetParent():IsAlive() then return end
	ParticleManager:DestroyParticle(self.particle,true)
   self:GetParent():StopSound("miko2_04slow")
	if not self:GetCaster():HasModifier("modifier_item_wanbaochui") then return end
	if self:GetCaster():HasModifier("modifier_ability_miko2_4check") then return end
	if not self:GetCaster():IsAlive() and self:GetParent():IsAlive() then return end
	local count = 0
	if not (self:GetCaster():GetName() == "npc_dota_hero_rubick") then count = self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):GetStackCount() end
	--self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):SetStackCount(count + 1)
	--if not (FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_7") ~= 0) and (count > self:GetAbility():GetSpecialValueFor("limit")) then count = self:GetAbility():GetSpecialValueFor("limit") end
	local cpoint = self:GetCaster():GetAbsOrigin()
	local tpoint = self:GetParent():GetAbsOrigin()
	local heroes = FindUnitsInLine(self:GetCaster():GetTeam(), cpoint, tpoint, nil,100,DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_CUSTOM,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0)
	for hh,sb in pairs(heroes) do
	  local damage_table = {
		victim = sb,
		attacker = self:GetCaster(),
		damage = self:GetAbility():GetSpecialValueFor("last_damage") + count * self:GetAbility():GetSpecialValueFor("stack_damage") + FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_7"),
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	   UnitDamageTarget(damage_table)
	   --print(count)
   end
	local vec = cpoint - tpoint
	local fpoint = tpoint - vec:Normalized() * 150
	FindClearSpaceForUnit(self:GetCaster(), fpoint, true)
	local step_particle = ParticleManager:CreateParticle("particles/heroes/miko2/miko04.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(step_particle, 0, cpoint)
	ParticleManager:SetParticleControl(step_particle, 1, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(step_particle)
	self:GetCaster():EmitSound("Hero_VoidSpirit.AstralStep.Start")
	if self:GetParent():IsAlive() then return end
	if not self:GetParent():IsRealHero() then return end
	if self:GetCaster():GetName() == "npc_dota_hero_rubick" then return end
    local count = self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):GetStackCount()
    self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):SetStackCount(count + 1)
	--print(self:GetCaster():GetModelName())
	--[[if self:GetCaster():GetModelName() == "models/miko/miko.vmdl" then
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3,1.5)
	else
      self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,1.5)
   end]]
end

function modifier_ability_miko2_4debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_miko2_4debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetStackCount()
end

function modifier_ability_miko2_4debuff:OnDeath(event)
	if not IsServer() then return end
	if event.unit ~= self:GetParent() then return end
	if not self:GetParent():IsRealHero() then return end
	if self:GetCaster():GetName() == "npc_dota_hero_rubick" then return end
    local count = self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):GetStackCount()
    self:GetCaster():FindModifierByName("modifier_ability_miko2_Ex"):SetStackCount(count + 1)
end

--[[function modifier_ability_miko2_4debuff:OnRemoved()
	if self:GetCaster():HasModifier("modifier_ability_miko2_4check") then return end
	if self:GetStackCount() >= 2 then return end
	local damage_table = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = 200,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	UnitDamageTarget(damage_table)
	local cpoint = self:GetCaster():GetAbsOrigin()
	local tpoint = self:GetParent():GetAbsOrigin()
	local vec = cpoint - tpoint
	local fpoint = tpoint - vec:Normalized() * 150
	FindClearSpaceForUnit(self:GetCaster(), fpoint, true)
end]]


modifier_ability_miko2_4check = {}
LinkLuaModifier("modifier_ability_miko2_4check", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_4check:IsHidden() return true end
function modifier_ability_miko2_4check:IsDebuff() return false end
function modifier_ability_miko2_4check:IsPurgable() return false end
function modifier_ability_miko2_4check:RemoveOnDeath() return false end

function modifier_ability_miko2_4check:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
	--self:OnIntervalThink()
end

function modifier_ability_miko2_4check:OnIntervalThink()
	if not IsServer() then return end
	self.count = self:GetParent():GetModifierStackCount("modifier_ability_miko2_4check", nil) + 1
    self:GetCaster():SetModifierStackCount("modifier_ability_miko2_4check",self:GetAbility(), self.count)
end

function modifier_ability_miko2_4check:OnDestroy()
	if not IsServer() then return end
	local remain_time = self:GetAbility().remain_time - self.count * 0.1
	self:GetAbility():StartCooldown(remain_time)
end


modifier_ability_miko2_4ball = {}
LinkLuaModifier("modifier_ability_miko2_4ball", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_4ball:IsHidden() return false end
function modifier_ability_miko2_4ball:IsDebuff() return false end
function modifier_ability_miko2_4ball:IsPurgable() return false end
function modifier_ability_miko2_4ball:RemoveOnDeath() return false end

function modifier_ability_miko2_4ball:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end

function modifier_ability_miko2_4ball:OnCreated()
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle("particles/thd2/heroes/miko2/miko_fx/miko_fx1.vpcf", PATTACH_ABSORIGIN, self:GetParent())
end

function modifier_ability_miko2_4ball:OnDestroy()
	if not IsServer() then return end
	local projectile = {Target = self:GetCaster(),
				Source = self:GetParent(),
				Ability = self:GetAbility(),
				EffectName = "particles/thd2/heroes/miko2/miko_fx/miko_fx1.vpcf",
				iMoveSpeed = 700,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = true,
			}
	self:GetParent():EmitSound("miko2_01")
	ProjectileManager:CreateTrackingProjectile(projectile)
	self:GetParent():RemoveSelf()
end

ability_thdots_miko2_Ex = {}

function ability_thdots_miko2_Ex:GetIntrinsicModifierName()
	return "modifier_ability_miko2_Ex"
end

modifier_ability_miko2_Ex = {}
LinkLuaModifier("modifier_ability_miko2_Ex", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_Ex:IsHidden() return false end
function modifier_ability_miko2_Ex:IsDebuff() return false end
function modifier_ability_miko2_Ex:IsPurgable() return false end
function modifier_ability_miko2_Ex:RemoveOnDeath() return false end

function modifier_ability_miko2_Ex:OnCreated()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_miko2_telent1",{})
	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_miko2_telent2",{})
	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_miko2_telent3",{})
end

function modifier_ability_miko2_Ex:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		--MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end

function modifier_ability_miko2_Ex:GetModifierHealthBonus()
	return -20 * self:GetCaster():GetLevel() - 200
end

function modifier_ability_miko2_Ex:GetModifierPhysicalArmorBonus()
	return self:GetCaster():GetModifierStackCount("modifier_ability_miko2_telent2",nil)
end

function modifier_ability_miko2_Ex:GetModifierMagicalResistanceBonus()
	return self:GetCaster():GetModifierStackCount("modifier_ability_miko2_telent3",nil)
end

function modifier_ability_miko2_Ex:GetModifierConstantManaRegen()
	return self:GetCaster():GetModifierStackCount("modifier_ability_miko2_telent1",nil)
end

function modifier_ability_miko2_Ex:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.unit ~= self:GetCaster() then return end
	if not self:GetAbility():IsCooldownReady() then return end
	if keys.unit:GetHealth() == 0 then
		keys.unit:Purge(false,true,false,true,false)
		self:GetAbility():StartCooldown(120)
		if keys.unit:HasModifier("modifier_thdots_komachi_04") then return end
		keys.unit:SetHealth(1)
		keys.unit:AddNewModifier(keys.unit,self:GetAbility(),"modifier_ability_miko2_ExShield",{duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
end

modifier_ability_miko2_ExShield = {}
LinkLuaModifier("modifier_ability_miko2_ExShield", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_ExShield:IsHidden() return false end
function modifier_ability_miko2_ExShield:IsDebuff() return false end
function modifier_ability_miko2_ExShield:IsPurgable() return false end
function modifier_ability_miko2_ExShield:RemoveOnDeath() return true end

function modifier_ability_miko2_ExShield:OnCreated()
	if not IsServer() then return end
	self.eff = ParticleManager:CreateParticle("particles/thd2/items/item_tsundere.vpcf", PATTACH_ABSORIGIN_FOLLOW,self:GetParent())
	self:SetStackCount(self:GetCaster():GetLevel()*self:GetAbility():GetSpecialValueFor("shield"))
	self:StartIntervalThink(0.05)
end

function modifier_ability_miko2_ExShield:OnIntervalThink()
	if not IsServer() then return end
	if self:GetCaster():GetLevel()*self:GetAbility():GetSpecialValueFor("shield")*0.05 > self:GetStackCount() then
	    self:GetCaster():RemoveModifierByName("modifier_ability_miko2_ExShield")
		return 
	end
	self:SetStackCount(self:GetStackCount()-self:GetCaster():GetLevel()*self:GetAbility():GetSpecialValueFor("shield")*0.05)
end

function modifier_ability_miko2_ExShield:OnDestroy()
	if not IsServer() then return end
   ParticleManager:DestroyParticle(self.eff,true)
end

function modifier_ability_miko2_ExShield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_miko2_ExShield:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then return end
	--print_r(keys)
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	if keys.damage >= self:GetStackCount() then
		self:GetCaster():RemoveModifierByName("modifier_ability_miko2_ExShield")
        return self:GetStackCount()
    else
    	self:SetStackCount(self:GetStackCount()-keys.damage)
    	return keys.damage
    end
end


modifier_ability_miko2_telent1 = {}
LinkLuaModifier("modifier_ability_miko2_telent1", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_telent1:IsHidden() return true end
function modifier_ability_miko2_telent1:IsDebuff() return false end
function modifier_ability_miko2_telent1:IsPurgable() return false end
function modifier_ability_miko2_telent1:RemoveOnDeath() return false end

function modifier_ability_miko2_telent1:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ability_miko2_telent1:OnIntervalThink()
	if not IsServer() then return end
	--print(self:GetCaster():FindModifierByName("modifier_ability_miko2_telent1"):GetStackCount())
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_1"))
end

modifier_ability_miko2_telent2 = {}
LinkLuaModifier("modifier_ability_miko2_telent2", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_telent2:IsHidden() return true end
function modifier_ability_miko2_telent2:IsDebuff() return false end
function modifier_ability_miko2_telent2:IsPurgable() return false end
function modifier_ability_miko2_telent2:RemoveOnDeath() return false end

function modifier_ability_miko2_telent2:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ability_miko2_telent2:OnIntervalThink()
	if not IsServer() then return end
	--print(self:GetCaster():FindModifierByName("modifier_ability_miko2_telent2"):GetStackCount())
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_2"))
end

modifier_ability_miko2_telent3 = {}
LinkLuaModifier("modifier_ability_miko2_telent3", "scripts/vscripts/abilities/abilitymiko2.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_miko2_telent3:IsHidden() return true end
function modifier_ability_miko2_telent3:IsDebuff() return false end
function modifier_ability_miko2_telent3:IsPurgable() return false end
function modifier_ability_miko2_telent3:RemoveOnDeath() return false end

function modifier_ability_miko2_telent3:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ability_miko2_telent3:OnIntervalThink()
	if not IsServer() then return end
	--print(self:GetCaster():FindModifierByName("modifier_ability_miko2_telent3"):GetStackCount())
	self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_miko2_3"))
end