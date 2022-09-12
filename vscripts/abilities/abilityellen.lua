

--天赋modifier
LinkLuaModifier("modifier_ability_thdots_ellen_telent", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_ellen_telent	=  {}

modifier_ability_thdots_ellen_telent = {}
LinkLuaModifier("modifier_ability_thdots_ellen_telent","scripts/vscripts/abilities/abilityellen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_ellen_telent:IsHidden() 		return true end
function modifier_ability_thdots_ellen_telent:IsPurgable()		return false end
function modifier_ability_thdots_ellen_telent:RemoveOnDeath() 	return false end
function modifier_ability_thdots_ellen_telent:IsDebuff()		return false end
function modifier_ability_thdots_ellen_telent:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_ability_thdots_ellen_telent:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_ellen_4") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_ellen_telent_1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_ellen_telent_1",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_ellen_4"))
	end
end

modifier_ability_thdots_ellen_telent_1 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_ellen_telent_1","scripts/vscripts/abilities/abilityellen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_ellen_telent_1:IsHidden() 		return true end
function modifier_ability_thdots_ellen_telent_1:IsPurgable()		return false end
function modifier_ability_thdots_ellen_telent_1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_ellen_telent_1:IsDebuff()		return false end
function modifier_ability_thdots_ellen_telent_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end
function modifier_ability_thdots_ellen_telent_1:GetModifierBonusStats_Strength()
	return 100
end


ability_thdots_ellen01	= {}

LinkLuaModifier("ability_thdots_ellen01_thinker", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_ellen01_purge", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_ellen01_purge	=  class({})
ability_thdots_ellen01_thinker	= ability_thdots_ellen01_thinker or class({})

function ability_thdots_ellen01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
	-- return 99999
end

function ability_thdots_ellen01:OnSpellStart()
        if not IsServer() then return end
				-- print(self:GetCursorPosition())
	    self:GetCaster():EmitSound("Hero_ArcWarden.SparkWraith.Cast")
    	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_ArcWarden.SparkWraith.Appear", self:GetCaster())
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), 275, 5, true)
      	if not self:GetCaster():HasModifier("modifier_ability_thdots_ellen_telent") then
      		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_ellen_telent", {})
      	end
        CreateModifierThinker(self:GetCaster(), self, "ability_thdots_ellen01_thinker", {duration =  self:GetSpecialValueFor("duration")+FindTelentValue(self:GetCaster(),"special_bonus_unique_ellen_2") },  self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)

    		ProjectileManager:CreateLinearProjectile({
    			Ability		= self,
    			Source		= self:GetCaster(),
    			vSpawnOrigin	= self:GetCaster():GetAbsOrigin(),
    			vVelocity	= ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * self:GetSpecialValueFor("wraith_speed"),
    			vAcceleration	= nil, --hmm...
    			fMaxSpeed	= nil, -- What's the default on this thing?
    			fDistance	= self.BaseClass.GetCastRange(self, self:GetCursorPosition(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus(),
    			fStartRadius	= 100,
    			fEndRadius		= 100,
    			fExpireTime		= nil,
    			iUnitTargetTeam	= DOTA_UNIT_TARGET_TEAM_ENEMY,
    			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
    			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
    			bIgnoreSource		= true,
    			bHasFrontalCone		= false,
    			bDrawsOnMinimap		= false,
    			bVisibleToEnemies	= true,
    			bProvidesVision		= true,
    			iVisionRadius		= 300,
    			iVisionTeamNumber	= self:GetCaster():GetTeamNumber(),
    			ExtraData			= {
    				spark_damage		= self:GetSpecialValueFor("spark_damage"),
    				auto_cast			= 1
    			}
    		})

    end


function ability_thdots_ellen01:OnProjectileHit_ExtraData(target, location, ExtraData)
       if not IsServer() then return end
	if target then
		AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("wraith_vision_radius"), self:GetSpecialValueFor("wraith_vision_duration"), true)

		if not target:IsMagicImmune() then
			target:EmitSound("Hero_ArcWarden.SparkWraith.Damage")

			if ExtraData.auto_cast == 1 then
				local burst_particle = ParticleManager:CreateParticle("particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_golden_immortal_ambient_head_fire_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:ReleaseParticleIndex(burst_particle)
			end

			UnitDamageTarget({
				victim 			= target,
				damage 			= ExtraData.spark_damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self
			})

			if target and not target:IsNull() then
				if(target:HasModifier("modifier_ability_thdots_ellen01_purge")) then
					local s = target:GetModifierStackCount("modifier_ability_thdots_ellen01_purge",self:GetCaster())
					local mod = target:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_ellen01_purge", {duration = self:GetSpecialValueFor("miss_duration") * (1 - target:GetStatusResistance())})
					target:SetModifierStackCount("modifier_ability_thdots_ellen01_purge",self:GetCaster(),s+1)
				else
					target:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_ellen01_purge", {duration = self:GetSpecialValueFor("miss_duration") * (1 - target:GetStatusResistance())})
					target:SetModifierStackCount("modifier_ability_thdots_ellen01_purge",self:GetCaster(),1)
				end
			end
		elseif not target:IsAlive() and ExtraData.thinker_duration and ExtraData.thinker_time then
			-- IMBAfication: Reconstitution
			self:OnSpellStart(math.max(ExtraData.thinker_duration - ExtraData.thinker_time, 0), location)
		end

		return true
	end
end



function ability_thdots_ellen01_thinker:OnCreated()

	if not self:GetAbility() then self:Destroy() return end

	self.radius				= self:GetAbility():GetSpecialValueFor("radius")
	self.activation_delay	= self:GetAbility():GetSpecialValueFor("activation_delay")
	self.wraith_speed		= self:GetAbility():GetSpecialValueFor("wraith_speed")
	self.spark_damage		= self:GetAbility():GetSpecialValueFor("spark_damage")
	self.think_interval			= self:GetAbility():GetSpecialValueFor("think_interval")
	self.wraith_vision_radius	= self:GetAbility():GetSpecialValueFor("wraith_vision_radius")

	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_ArcWarden.SparkWraith.Loop")

	self.wraith_particle = ParticleManager:CreateParticle("particles/world_environmental_fx/artifact_table_underlight.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.wraith_particle, 1, Vector(self.radius, 1, 1))
	self:AddParticle(self.wraith_particle, false, false, -1, false, false)

	self:GetCaster():SetContextThink(DoUniqueString(self:GetName()), function()
		self:StartIntervalThink(self.think_interval)
		return nil
	end, self.activation_delay - self.think_interval)
end

function ability_thdots_ellen01_thinker:OnIntervalThink()
    if not IsServer() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 275, 2, true)
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)) do
		self:GetParent():EmitSound("Hero_ArcWarden.SparkWraith.Activate")

		ProjectileManager:CreateTrackingProjectile({
			EffectName			= "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
			Ability				= self:GetAbility(),
			Source				= self:GetParent(),
			vSourceLoc			= self:GetParent():GetAbsOrigin(),
			Target				= enemy,
			iMoveSpeed			= self.wraith_speed,
			flExpireTime		= nil,
			bDodgeable			= false,
			bIsAttack			= false,
			bReplaceExisting	= false,
			iSourceAttachment	= nil,
			bDrawsOnMinimap		= nil,
			bVisibleToEnemies	= true,
			bProvidesVision		= true,
			iVisionRadius		= 300,
			iVisionTeamNumber	= self:GetCaster():GetTeamNumber(),
			ExtraData			= {
				spark_damage		= self.spark_damage,
				thinker_time		= self:GetElapsedTime(),
				thinker_duration	= self:GetDuration()
			}
		})

		self:Destroy()
		break
	end
end

function ability_thdots_ellen01_thinker:OnDestroy()
	if not IsServer() then return end

	self:GetParent():StopSound("Hero_ArcWarden.SparkWraith.Loop")
end

function ability_thdots_ellen01_thinker:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_FIXED_DAY_VISION,
		MODIFIER_PROPERTY_FIXED_NIGHT_VISION
	}
end

function ability_thdots_ellen01_thinker:GetFixedDayVision()
	return self.wraith_vision_radius
end

function ability_thdots_ellen01_thinker:GetFixedNightVision()
	return self.wraith_vision_radius
end

-------------------------------------------------
-------------------------------------------------

function modifier_ability_thdots_ellen01_purge:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_ability_thdots_ellen01_purge:OnCreated()
     if not IsServer() then return end
	 if not self:GetAbility() then self:Destroy() return end
	self.miss	= self:GetAbility():GetSpecialValueFor("miss")
end

function modifier_ability_thdots_ellen01_purge:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
    }

    return decFuncs
end

function modifier_ability_thdots_ellen01_purge:GetModifierMiss_Percentage()
    return self.miss * self:GetStackCount()
end

------------------------------
------------------------------

LinkLuaModifier("modifier_ability_thdots_ellen02", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thdots_ellen02_push", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ability_thdots_ellen02_charge_coil_counter", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_ellen02_rotational", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

ability_thdots_ellen02	= {}
modifier_ability_thdots_ellen02								= class({})
modifier_thdots_ellen02_push								= class({})
modifier_ability_thdots_ellen02_charge_coil_counter			= class({})
modifier_ability_thdots_ellen02_rotational					= class({})
modifier_thdots_ellen02_pushing								= class({})
LinkLuaModifier("modifier_thdots_ellen02_pushing", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_thdots_ellen02:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET 
end


function ability_thdots_ellen02:OnSpellStart()
	if not IsServer() then return end

	local caster_pos		= self:GetCaster():GetAbsOrigin()

	local num_of_cogs		= self:GetSpecialValueFor("cogs_num")+FindTelentValue(self:GetCaster(),"special_bonus_unique_ellen_1")

	local cogs_radius		= self:GetSpecialValueFor("cogs_radius")

	local duration			= self:GetSpecialValueFor("duration")

	-- Static value cause this is kinda hot-fixing for now
	local square_dist		= 30

	local cog_vector 		= GetGroundPosition(caster_pos + Vector(0, cogs_radius, 0), nil)
	local second_cog_vector	= GetGroundPosition(caster_pos + Vector(0, cogs_radius * 2, 0), nil)

	self:GetCaster():StartGesture(ACT_DOTA_RATTLETRAP_POWERCOGS)
		for cog = 1, num_of_cogs do

			local cog = CreateUnitByName("npc_dota_rattletrap_cog", cog_vector, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
			ResolveNPCPositions(cog:GetAbsOrigin(), 128)
         	cog:EmitSound("Hero_KeeperOfTheLight.Wisp.Active")


			cog:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_ellen02",
			{
				duration 	= duration,
				x 			= (cog_vector - caster_pos).x,
				y 			= (cog_vector - caster_pos).y,


				center_x	= caster_pos.x,
				center_y	= caster_pos.y,
				center_z	= caster_pos.z
			})
			cog:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
			cog_vector		= RotatePosition(caster_pos, QAngle(0, 360/num_of_cogs, 0), cog_vector)
		end



	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("cogs_radius") + 80, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)


end

-------------------------
-------------------------

function modifier_ability_thdots_ellen02:IsHidden()		return true end
function modifier_ability_thdots_ellen02:IsPurgable()	return false end



function modifier_ability_thdots_ellen02:OnCreated(params)
	if self:GetAbility() then
		self.damage					= self:GetAbility():GetSpecialValueFor("damage")
		self.mana_burn				= self:GetAbility():GetSpecialValueFor("mana_burn")
		self.attacks_to_destroy		= self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
		self.push_length			= 200
		self.push_duration			= self:GetAbility():GetSpecialValueFor("push_duration")
		self.trigger_distance		= self:GetAbility():GetSpecialValueFor("trigger_distance")
		self.rotational_speed		= self:GetAbility():GetSpecialValueFor("rotational_speed")
		self.powered			= true
		self.health				= self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
	else
		self:Destroy()
		return
	end

	if not IsServer() then return end
	self:GetParent():SetForwardVector(Vector(params.x, params.y, 0))
	self.center_loc		= Vector(params.center_x, params.center_y, params.center_z)
	self.second_gear	= params.second_gear

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, 1, 1))
    ParticleManager:SetParticleControl(self.particle, 2, Vector(0, 0, 0))
    self:AddParticle(self.particle, false, false, -1, false, false)

    self.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling_on.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle2, 2, Vector(0, 0, 0))
    self:AddParticle(self.particle2, false, false, -1, false, false)

	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_ellen02:OnIntervalThink()
	if not IsServer() then return end


	if self:GetAbility() then
		if self:GetAbility():GetAutoCastState() and not self:GetParent():HasModifier("modifier_ability_thdots_ellen02_rotational") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ability_thdots_ellen02_rotational",
			{
				center_loc_x		= self.center_loc.x,
				center_loc_y		= self.center_loc.y,
				center_loc_z		= self.center_loc.z,
				rotational_speed	= self.rotational_speed
			})
		elseif not self:GetAbility():GetAutoCastState() and self:GetParent():HasModifier("modifier_ability_thdots_ellen02_rotational") then
			self:GetParent():RemoveModifierByName("modifier_ability_thdots_ellen02_rotational")
		end
	end

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.trigger_distance, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0, false)

	for _, enemy in pairs(enemies) do
		if self.powered and not enemy:HasModifier("modifier_thdots_ellen02_pushing") and not enemy:HasModifier("modifier_thdots_ellen02_push") and math.abs(AngleDiff(VectorToAngles(self:GetParent():GetForwardVector()).y, VectorToAngles(enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()).y)) <= 180 then
			--print("enemy:GetUnitName()")
			--print(enemy:GetUnitName())
			if enemy:GetUnitName() == "npc_coin_up_unit" 
				or enemy:GetUnitName() == "npc_power_up_unit"
				or enemy:GetUnitName() == "npc_dota_roshan"
				or enemy:HasModifier("dummy_unit")
				or IsTHDImmune(enemy) then
				break
			else
				self.health = self.health - 1
				local max_count = self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
				local set_healt = self:GetParent():GetBaseMaxHealth() * self.health / max_count
				self:GetParent():SetHealth(set_healt)
				if self.health <= 0 then
					self:StartIntervalThink(-1)
				end
				--防秒杀飞行
				enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_thdots_ellen02_pushing",{duration	= self.push_duration * (1 - enemy:GetStatusResistance())})
				enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_thdots_ellen02_push",
				{
					duration	= self.push_duration * (1 - enemy:GetStatusResistance()),
					damage		= self.damage,
					mana_burn	= self.mana_burn,
					push_length	= self.push_length
				})
				break
			end
		end
	end
end

function modifier_ability_thdots_ellen02:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("Hero_KeeperOfTheLight.Mana_Leak_Target_Fp")

	self:GetParent():EmitSound("Hero_KeeperOfTheLight.Mana_Leak_Target")


	if self:GetRemainingTime() <= 0 then
		self:GetParent():RemoveSelf()
	end
end

function modifier_ability_thdots_ellen02:CheckState()
	return  {
		[MODIFIER_STATE_SPECIALLY_DENIABLE]					= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
	}
end

function modifier_ability_thdots_ellen02:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return decFuncs
end

function modifier_ability_thdots_ellen02:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_ability_thdots_ellen02:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_ability_thdots_ellen02:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_ability_thdots_ellen02:OnAttackLanded(keys)
    if not IsServer() then return end

	if keys.target == self:GetParent() then
		if keys.attacker == self:GetCaster() then
			self:GetParent():Kill(nil, self:GetCaster())


		else
			self.health = self.health - 1
			local max_count = self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
			local set_healt = self:GetParent():GetBaseMaxHealth() * self.health / max_count
			self:GetParent():SetHealth(set_healt)
			if self.health <= 0 then
				self:GetParent():Kill(nil, keys.attacker)


			end
		end
	end
end

------------------------------
------------------------------

function modifier_thdots_ellen02_push:OnCreated(params)
	if not IsServer() then return end

	self.duration			= params.duration
	self.damage				= params.damage
	self.mana_burn			= params.mana_burn
	self.push_length		= params.push_length
	self.owner				= self:GetCaster():GetOwner() or self:GetCaster()


    self:GetCaster():EmitSound("Hero_KeeperOfTheLight.BlindingLight")
	local attack_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_phase_shift_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)



	self.knockback_speed		= self.push_length / self.duration
	self.position	= self:GetCaster():GetAbsOrigin()

	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
		return
	end
end

function modifier_thdots_ellen02_push:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end

	local distance = (me:GetOrigin() - self.position):Normalized()
    -- 三步必杀
	me:SetOrigin( me:GetOrigin() + distance * self.knockback_speed * dt )
end

function modifier_thdots_ellen02_push:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_thdots_ellen02_push:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	self:GetParent():ReduceMana(self.mana_burn)
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, true )
	local damageTable = {
		victim 			= self:GetParent(),
		damage 			= self.damage,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	}

	if not damageTable.attacker then
		damageTable.attacker = self.owner
	end

	UnitDamageTarget(damageTable)
end

function modifier_thdots_ellen02_push:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_thdots_ellen02_push:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
    return decFuncs
end

function modifier_thdots_ellen02_push:GetOverrideAnimation()
	 return ACT_DOTA_FLAIL
end


------------------------------
------------------------------
ability_thdots_ellen03 = class({})
function ability_thdots_ellen03:IsHiddenWhenStolen() 	return false end
function ability_thdots_ellen03:IsRefreshable() 		return true end
function ability_thdots_ellen03:IsStealable() 			return true end
function ability_thdots_ellen03:IsNetherWardStealable()	return true end
function ability_thdots_ellen03:GetAssociatedSecondaryAbilities() return "imba_puck_ethereal_jaunt" end
function ability_thdots_ellen03:GetCastRange() return distance end

LinkLuaModifier("modifier_ability_thdots_ellen03_orb_thinker", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_ellen03_orb_silenced", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_ellen03_orb_controller", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)

function ability_thdots_ellen03:GetAssociatedSecondaryAbilities()
	return "ability_thdots_ellen03_end"
end

function ability_thdots_ellen03:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("max_distance")
end

function ability_thdots_ellen03:OnUpgrade()
	if not IsServer() then return end

	local illuminate_end = self:GetCaster():FindAbilityByName("ability_thdots_ellen03_end")

	if illuminate_end then
		illuminate_end:SetLevel(self:GetLevel())
	end
end

function ability_thdots_ellen03:OnSpellStart()
	    local caster = self:GetCaster()
    	local pos = self:GetCursorPosition()
    	local direction = (pos - caster:GetAbsOrigin()):Normalized()
    	direction.z = 0
    	local sound = CreateModifierThinker(caster, self, "modifier_ability_thdots_ellen03_orb_thinker", {duration = 30.0}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
    	sound:EmitSound("Hero_Puck.Illusory_Orb")
    	local distance = self:GetSpecialValueFor("max_distance")
    	local speed = self:GetSpecialValueFor("orb_speed")
    	local pfx_name = "particles/econ/items/puck/puck_merry_wanderer/puck_illusory_orb_merry_wanderer.vpcf"
    	local info =
    	{
    		Ability = self,
    		EffectName = pfx_name,
    		vSpawnOrigin = caster:GetAbsOrigin(),
    		fDistance = distance,
    		fStartRadius = self:GetSpecialValueFor("radius"),
    		fEndRadius = self:GetSpecialValueFor("radius"),
    		Source = caster,
    		bHasFrontalCone = false,
    		bReplaceExisting = false,
    		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    		fExpireTime = GameRules:GetGameTime() + 10.0,
    		bDeleteOnHit = true,
    		vVelocity = direction * speed,
    		bProvidesVision = false,
    		ExtraData = {sound = sound:entindex()},
    	}
    	self.projectile = ProjectileManager:CreateLinearProjectile(info)
    	local time = (self:GetSpecialValueFor("max_distance") / self:GetSpecialValueFor("orb_speed") - 0.2)
    	caster:AddNewModifier(caster, self, "modifier_ability_thdots_ellen03_orb_controller", {duration = time}):SetStackCount(0)

end


function ability_thdots_ellen03:OnProjectileThink_ExtraData(pos, keys)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), pos, self:GetSpecialValueFor("orb_vision"), self:GetSpecialValueFor("vision_duration"), false)
	if keys.sound then
		EntIndexToHScript(keys.sound):SetOrigin(pos)
	end
end

function ability_thdots_ellen03:OnProjectileHit_ExtraData(target, pos, keys)
	if not target and keys.sound then
		EntIndexToHScript(keys.sound):StopSound("Hero_Puck.Illusory_Orb")
		EntIndexToHScript(keys.sound):ForceKill(false)
	end
	if target then
		target:EmitSound("Hero_Puck.IIllusory_Orb_Damage")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_orb_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(pfx)
		UnitDamageTarget({victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType()})
	end
end
------------------------------
------------------------------
modifier_ability_thdots_ellen03_orb_thinker = class({})

function modifier_ability_thdots_ellen03_orb_thinker:IsAura() return true end
function modifier_ability_thdots_ellen03_orb_thinker:GetAuraDuration() return 0.1 end
function modifier_ability_thdots_ellen03_orb_thinker:GetModifierAura() return "modifier_ability_thdots_ellen03_orb_silenced" end
function modifier_ability_thdots_ellen03_orb_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_ability_thdots_ellen03_orb_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_ellen03_orb_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_ellen03_orb_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_ability_thdots_ellen03_orb_silenced = class({})
function modifier_ability_thdots_ellen03_orb_silenced:IsDebuff()			return true end
function modifier_ability_thdots_ellen03_orb_silenced:IsHidden() 		return false end
function modifier_ability_thdots_ellen03_orb_silenced:IsPurgable() 		return true end
function modifier_ability_thdots_ellen03_orb_silenced:IsPurgeException() return true end
function modifier_ability_thdots_ellen03_orb_silenced:GetEffectName() return "particles/generic_gameplay/generic_silenced.vpcf" end
function modifier_ability_thdots_ellen03_orb_silenced:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_ability_thdots_ellen03_orb_silenced:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_ability_thdots_ellen03_orb_silenced:ShouldUseOverheadOffset() return true end


modifier_ability_thdots_ellen03_orb_controller = class({})

function modifier_ability_thdots_ellen03_orb_controller:IsDebuff()			return false end
function modifier_ability_thdots_ellen03_orb_controller:IsHidden() 			return false end
function modifier_ability_thdots_ellen03_orb_controller:IsPurgable() 		return false end
function modifier_ability_thdots_ellen03_orb_controller:IsPurgeException() 	return false end
function modifier_ability_thdots_ellen03_orb_controller:RemoveOnDeath() return self:GetParent():IsIllusion() end

function modifier_ability_thdots_ellen03_orb_controller:OnCreated()
	if IsServer() then
	    self:GetCaster():SwapAbilities("ability_thdots_ellen03", "ability_thdots_ellen03_end", false, true)
	end
end

function modifier_ability_thdots_ellen03_orb_controller:OnDestroy()
	if IsServer() then
		local ability = self:GetParent():FindAbilityByName("imba_puck_ethereal_jaunt")
		    self:GetCaster():SwapAbilities("ability_thdots_ellen03", "ability_thdots_ellen03_end", true,false)
	end
end
------------------------------
------------------------------
ability_thdots_ellen03_end = class({})
function ability_thdots_ellen03_end:IsHiddenWhenStolen() 		return false end
function ability_thdots_ellen03_end:IsRefreshable() 			return true end
function ability_thdots_ellen03_end:IsStealable() 			return false end
function ability_thdots_ellen03_end:IsNetherWardStealable()	return false end
function ability_thdots_ellen03_end:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("ability_thdots_ellen03")
    caster:EmitSound("Hero_Puck.Waning_Rift")

	self.miss				    = self:GetSpecialValueFor("miss")
	self.knockback_duration		= self:GetSpecialValueFor("knockback_duration")
    self.knockback_distance		= self:GetSpecialValueFor("knockback_distance")
	self.duration				= self:GetSpecialValueFor("duration")
	self.radius					= self:GetSpecialValueFor("radius")
	self.damage				    = self:GetSpecialValueFor("damage")
	local position = GetGroundPosition(ProjectileManager:GetLinearProjectileLocation(ability.projectile), nil)


	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_waning_rift.vpcf",  PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(pfx, 1, Vector(radius,radius,radius))
    ParticleManager:ReleaseParticleIndex(pfx)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 1, position)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
			if enemy:HasModifier("modifier_ability_thdots_ellen03_knockback") then
				enemy:FindModifierByName("modifier_ability_thdots_ellen03_knockback"):Destroy()
			end
			enemy:AddNewModifier(self.caster, self, "modifier_ability_thdots_ellen03_knockback", {x = position.x, y = position.y, z = position.z, duration = self.knockback_duration * (1 - enemy:GetStatusResistance())})
			local damageTable = {
    			victim 			= enemy,
    			damage 			= self.damage,
    			damage_type		= DAMAGE_TYPE_MAGICAL,
    			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
                attacker 		= self:GetCaster(),
                ability 		= self
    	}
			UnitDamageTarget(damageTable)
		end
end



LinkLuaModifier("modifier_ability_thdots_ellen03_knockback", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
modifier_ability_thdots_ellen03_knockback					= class({})
function modifier_ability_thdots_ellen03_knockback:IsHidden() return false end
function modifier_ability_thdots_ellen03_knockback:IsPurgable() return true end
function modifier_ability_thdots_ellen03_knockback:IsDebuff() return true end
function modifier_ability_thdots_ellen03_knockback:RemoveOnDeath() return true end

function modifier_ability_thdots_ellen03_knockback:OnCreated(params)
	if not IsServer() then return end

	self.ability				= self:GetAbility()
	self.parent					= self:GetParent()
	self.knockback_duration		= self.ability:GetSpecialValueFor("knockback_duration")
	self.knockback_distance		= self.ability:GetSpecialValueFor("knockback_distance")
	self.knockback_speed		= self.ability.knockback_distance / self.knockback_duration
	self.position	= Vector(params.x, params.y, params.z)
	self.parent:StartGesture(ACT_DOTA_FLAIL)
	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
		return
	end
end

function modifier_ability_thdots_ellen03_knockback:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end

	local distance = (me:GetOrigin() - self.position):Normalized()
   -- 三步必杀
    	--print("111111111111111111111")
    if not me:HasModifier("modifier_thdots_yugi04_think_interval") then
    	--print("22222222222222222222")
		me:SetOrigin( me:GetOrigin() + distance * self.knockback_speed * dt )
	end
end



function modifier_ability_thdots_ellen03_knockback:OnDestroy()
	if not IsServer() then return end
	GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), 150, true )
	self.parent:FadeGesture(ACT_DOTA_FLAIL)
		self.parent:RemoveHorizontalMotionController( self )
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
end

function modifier_ability_thdots_ellen03_knockback:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_DISABLE_TURNING
    }

    return decFuncs
end




-------------------
-------------------
LinkLuaModifier("modifier_ability_thdots_ellen04_debuff", "scripts/vscripts/abilities/abilityellen.lua", LUA_MODIFIER_MOTION_NONE)
ability_thdots_ellen04 = ability_thdots_ellen04 or class({})


function ability_thdots_ellen04:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end
function ability_thdots_ellen04:OnSpellStart()

	local caster = self:GetCaster()
	local ability = self
	local target_point = ability:GetCursorPosition()
	local cast_sound = "Hero_ShadowDemon.ShadowPoison.Cast"
    EmitSoundOn(cast_sound, caster)
	ability:FireShadowPoisonProjectile(caster:GetAbsOrigin(), target_point, false)
end

function ability_thdots_ellen04:FireShadowPoisonProjectile(origin_point, target_point, grudges)

	local caster = self:GetCaster()
	local ability = self
	local projectile_sound = "Hero_ShadowDemon.ShadowPoison"
	local particle_poison = "particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_shadow_poison_proj.vpcf"


	local radius = ability:GetSpecialValueFor("radius")
	local speed = ability:GetSpecialValueFor("speed")


	EmitSoundOnLocationWithCaster(origin_point, projectile_sound, caster)


	local direction = (target_point - origin_point):Normalized()


	local shadow_projectile = {
		Ability = ability,
		EffectName = particle_poison,
		vSpawnOrigin = origin_point,
		fDistance = ability:GetCastRange(target_point, nil),
		fStartRadius = radius,
		fEndRadius = radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam =  DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		-- iUnitTargetType = DOTA_UNIT_TARGET_HERO,--只对英雄生效
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		bDeleteOnHit = false,
		vVelocity = direction * speed * Vector(1, 1, 0),
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = true,
		iVisionRadius = radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}

	local projectileID = ProjectileManager:CreateLinearProjectile(shadow_projectile)
	if not self.shadow_poison_projectileID then
		self.shadow_poison_projectileID = {}
	end


	table.insert(self.shadow_poison_projectileID, projectileID)
	self.shadow_poison_projectileID[projectileID] = {targets = 0, isGrudge = grudges}
end


function ability_thdots_ellen04:OnProjectileHitHandle(target, location, projectileID)


	if not target then
		table.remove(self.shadow_poison_projectileID, projectileID)
		return
	end


	if target:IsInvulnerable()  then return end


	if target:IsMagicImmune() then return end

	if target:GetClassname()=="npc_dota_roshan" then return end



	if self.shadow_poison_projectileID[projectileID] then
		self.shadow_poison_projectileID[projectileID].targets = self.shadow_poison_projectileID[projectileID].targets + 1
	end

	local caster = self:GetCaster()
	local ability = self
	local particle_impact = "particles/econ/items/grimstroke/ti9_immortal/gs_ti9_artistry_dmg_steam.vpcf"
	local hit_sound = "Hero_ShadowDemon.ShadowPoison.Impact"
	local soul_catcher_ability = "imba_shadow_demon_soul_catcher"
	local modifier_shadow_poison = "modifier_ability_thdots_ellen04_debuff"
	local modifier_elated_buff = "modifier_imba_demonic_purge_elated_demon_buff"

	local hit_damage = ability:GetSpecialValueFor("hit_damage")
	local stack_duration = ability:GetSpecialValueFor("stack_duration")
	local efficient_upwards_limit = ability:GetSpecialValueFor("efficient_upwards_limit")




	EmitSoundOn(hit_sound, target)
	--给予视野
	-- AddFOWViewer(target:GetTeamNumber(), caster:GetOrigin(),128,1, false)


	local particle_impact_fx = ParticleManager:CreateParticle(particle_impact, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_impact_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_impact_fx)


	if not target:HasModifier(modifier_shadow_poison) then


		target:AddNewModifier(target, ability, modifier_shadow_poison, {duration = stack_duration * (1 - target:GetStatusResistance())})
	end


	local additional_stacks = 0
	if caster:HasModifier(modifier_elated_buff) and self.shadow_poison_projectileID[projectileID].targets == 1 then
		local modifier_elated_buff_handle = caster:FindModifierByName(modifier_elated_buff)
		if modifier_elated_buff_handle then
			additional_stacks = modifier_elated_buff_handle:GetStackCount()
		end
	end

	local total_stacks = 1 + additional_stacks
	print("total_stacks is : ")
	print(total_stacks)
	local modifier_shadow_poison_handle = target:FindModifierByName(modifier_shadow_poison)
	local modifier_stackcount = modifier_shadow_poison_handle:GetStackCount()
	if modifier_shadow_poison_handle then
		for i = 1, total_stacks do
			if modifier_stackcount < efficient_upwards_limit then 
				modifier_shadow_poison_handle:IncrementStackCount()
			end
			modifier_shadow_poison_handle:ForceRefresh()
		end
	end

	-- Apply damage
	local damageTable = {victim = target,
						attacker = caster,
						damage = hit_damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = ability}

	UnitDamageTarget(damageTable)
end


-----------------------------------
-----------------------------------

modifier_ability_thdots_ellen04_debuff = modifier_ability_thdots_ellen04_debuff or class({})

function modifier_ability_thdots_ellen04_debuff:IsHidden() return false end
function modifier_ability_thdots_ellen04_debuff:IsPurgable() return true end
function modifier_ability_thdots_ellen04_debuff:IsDebuff() return true end
function modifier_ability_thdots_ellen04_debuff:RemoveOnDeath() return true end

function modifier_ability_thdots_ellen04_debuff:OnCreated()
	-- Ability properties
	self.caster = self:GetAbility():GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.impact_sound = "Hero_ShadowDemon.ShadowPoison.Impact"
	self.particle_ui = "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_stackui.vpcf" --cp0 location, cp1 vector(second digit, first digit, 0)"
	self.particle_4stacks = "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_4stack.vpcf" --cp0 location
	self.particle_kill = "particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_shadow_poison_kill.vpcf" --cp0 location, cp2 location, cp3 Vector(1,0,0)
	self.kill_responses = {"shadow_demon_shadow_demon_ability_shadow_poison_05", "shadow_demon_shadow_demon_ability_shadow_poison_06", "shadow_demon_shadow_demon_ability_shadow_poison_08", "shadow_demon_shadow_demon_ability_shadow_poison_09", "shadow_demon_shadow_demon_ability_shadow_poison_10"} --20% chance


	self.stack_damage = self.ability:GetSpecialValueFor("stack_damage")
	self.linked_pain_dmg_spread_pct = self.ability:GetSpecialValueFor("linked_pain_dmg_spread_pct")
	self.efficient_upwards_limit = self.ability:GetSpecialValueFor("efficient_upwards_limit")

	self.particle_ui_fx = ParticleManager:CreateParticle(self.particle_ui, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle_ui_fx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle_ui_fx, 1, Vector(0, 1, 0))
	self:AddParticle(self.particle_ui_fx, true, false, -1, false, true)
end

function modifier_ability_thdots_ellen04_debuff:OnStackCountChanged()

	local stacks = self:GetStackCount()
	local first_digit = stacks % 10
	local second_digit = 0 -- default
	if stacks >= 10 then
		second_digit = 1 -- This is the highest second digit supported by this particle UI
	end


	if stacks > 19 then
		first_digit = 9
	end


	ParticleManager:SetParticleControl(self.particle_ui_fx, 1, Vector(second_digit, first_digit, 0))


	if stacks >= 4 and not self.particle_4stacks_fx then
		self.particle_4stacks_fx = ParticleManager:CreateParticle(self.particle_4stacks, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.particle_4stacks_fx, 0, self.parent:GetAbsOrigin())
		self:AddParticle(self.particle_4stacks_fx, true, false, -1, false, false)
	end
end

function modifier_ability_thdots_ellen04_debuff:CalculateShadowPoisonDamage()
	local stacks = self:GetStackCount()
	local multiplier = 2+FindTelentValue(self.caster,"special_bonus_unique_ellen_3")

    if self.highest_stack then
    	if stacks < (self.highest_stack - self.efficient_upwards_limit) then
    		stacks = stacks + self.efficient_upwards_limit
    	else
    		stacks = self.highest_stack
    	end
    end
    multiplier = multiplier ^ (stacks - 1)

	local damage = self.stack_damage * multiplier
	return damage
end

function modifier_ability_thdots_ellen04_debuff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_TOOLTIP}

	return decFuncs
end

function modifier_ability_thdots_ellen04_debuff:OnTooltip()
	return self:CalculateShadowPoisonDamage()
end

function modifier_ability_thdots_ellen04_debuff:OnDestroy()
	if not IsServer() then return end
	print(self:GetRemainingTime())
	if self:GetRemainingTime() >= 0 then return end

	self.particle_kill_fx = ParticleManager:CreateParticle(self.particle_kill, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle_kill_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle_kill_fx, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle_kill_fx, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(1,0,0), true)
	ParticleManager:ReleaseParticleIndex(self.particle_kill_fx)


	if not self.parent:HasModifier("modifier_illusion") and self.parent:IsAlive() then


		EmitSoundOn(self.impact_sound, self.caster)
		damage = self:CalculateShadowPoisonDamage()
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self.parent, damage, nil)
		local damageTable = {victim = self.parent,
							attacker = self.caster,
							damage = damage,
							damage_type = DAMAGE_TYPE_MAGICAL,
							ability = self.ability}

		UnitDamageTarget(damageTable)

		if not self.parent or self.parent:IsNull() or not self.parent:IsAlive() then
			if RollPercentage(20) then
				EmitSoundOn(self.kill_responses[RandomInt(1, #self.kill_responses)], self.caster)
			end
		end

	elseif self.parent:HasModifier("modifier_imba_disruption_soul_illusion") then
		EmitSoundOn(self.impact_sound, self.caster)


		local linked_target
		local soul_illusion_handle = self.parent:FindModifierByName("modifier_imba_disruption_soul_illusion")
		if soul_illusion_handle and soul_illusion_handle.target then
			linked_target = soul_illusion_handle.target
		end


		local particle_illusion_blast_fx = ParticleManager:CreateParticle(self.particle_illusion_blast, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particle_illusion_blast_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_illusion_blast_fx)


		local damage = self:CalculateShadowPoisonDamage()



		local enemy_killed = false
		for _, enemy in pairs(enemies) do
			local valid_enemy = true


			if not enemy:IsAlive() or enemy:IsMagicImmune() then
				valid_enemy = false
			end


			if enemy:IsCourier() then
				valid_enemy = false
			end


			if enemy:IsInvulnerable() and not enemy:HasModifier("modifier_imba_disruption_hidden") then
				valid_enemy = false
			end

			if valid_enemy then

				-- Anyone who isn't a linked target of the illusion takes lower damage, linked damage takes full damage
				local actual_damage = damage
				if enemy ~= linked_target then
					actual_damage = damage * self.linked_pain_dmg_spread_pct * 0.01
				end

				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, actual_damage, nil)

				local damageTable = {victim = enemy,
									attacker = self.parent,
									damage = actual_damage,
									damage_type = DAMAGE_TYPE_MAGICAL,
									ability = self.ability}

				UnitDamageTarget(damageTable)

				if not enemy or enemy:IsNull() or not enemy:IsAlive() then
					enemy_killed = true
				end
			end
		end

		if enemy_killed then

			if not self.parent or self.parent:IsNull() or not self.parent:IsAlive() then
				if RollPercentage(20) then
					EmitSoundOn(self.kill_responses[RandomInt(1, #self.kill_responses)], self.caster)
				end
			end
		end
	end
end



