ability_thdots_ellen01	= {}

LinkLuaModifier("ability_thdots_ellen01_thinker", "abilities/ability_thdots_ellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_ellen01_purge", "abilities/ability_thdots_ellen.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_ellen01_purge	= modifier_ability_thdots_ellen01_purge or class({})
ability_thdots_ellen01_thinker	= ability_thdots_ellen01_thinker or class({})

function ability_thdots_ellen01:OnSpellStart(recastDuration, recastLocation)
	self:GetCaster():EmitSound("Hero_ArcWarden.SparkWraith.Cast")
    	EmitSoundOnLocationWithCaster(recastLocation or self:GetCursorPosition(), "Hero_ArcWarden.SparkWraith.Appear", self:GetCaster())

    	if not self:GetAutoCastState() then
    		CreateModifierThinker(self:GetCaster(), self, "ability_thdots_ellen01_thinker", {
    			duration = recastDuration or self:GetSpecialValueFor("duration")
    		}, recastLocation or self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
    	else
    		-- Preventing projectiles getting stuck in one spot due to potential 0 length vector
    		if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
    			self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    		end

    		ProjectileManager:CreateLinearProjectile({
    			EffectName	= "particles/hero/arc_warden/spark_wraith_linear.vpcf",
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
    			iVisionRadius		= self:GetSpecialValueFor("wraith_vision_radius"),
    			iVisionTeamNumber	= self:GetCaster():GetTeamNumber(),
    			ExtraData			= {
    				spark_damage		= self:GetSpecialValueFor("spark_damage"),
    				auto_cast			= 1
    			}
    		})
    	end
    end

function ability_thdots_ellen01:OnProjectileHit_ExtraData(target, location, ExtraData)
	if target then
		AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("wraith_vision_radius"), self:GetSpecialValueFor("wraith_vision_duration"), true)

		if not target:IsMagicImmune() then
			target:EmitSound("Hero_ArcWarden.SparkWraith.Damage")

			if ExtraData.auto_cast == 1 then
				local burst_particle = ParticleManager:CreateParticle("particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_prj_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:ReleaseParticleIndex(burst_particle)
			end

			-- "Deals damage based on the level upon cast of the ability. Leveling up Spark Wraith does not update the damage of already placed Spark Wraiths."
			-- "The wraith first applies the damage, then the debuff."
			-- "Choosing the damage upgrading talent immediately upgrades all already placed wraiths, including ones which already seek a target."
			ApplyDamage({
				victim 			= target,
				damage 			= ExtraData.spark_damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self
			})

			target:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_ellen01_purge", {duration = self:GetSpecialValueFor("ministun_duration") * (1 - target:GetStatusResistance())})
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

	self.wraith_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_wraith.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.wraith_particle, 1, Vector(self.radius, 1, 1))
	self:AddParticle(self.wraith_particle, false, false, -1, false, false)

	self:GetCaster():SetContextThink(DoUniqueString(self:GetName()), function()
		self:StartIntervalThink(self.think_interval)
		return nil
	end, self.activation_delay - self.think_interval)
end

function ability_thdots_ellen01_thinker:OnIntervalThink()
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
			iVisionRadius		= self.wraith_vision_radius,
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
-- MODIFIER_ability_thdots_ellen01_PURGE --
-------------------------------------------------

function modifier_ability_thdots_ellen01_purge:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.move_speed_slow_pct	= self:GetAbility():GetSpecialValueFor("move_speed_slow_pct") * (-1)
end

function modifier_ability_thdots_ellen01_purge:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_ability_thdots_ellen01_purge:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_slow_pct
end



------------------------------

------------------------------

LinkLuaModifier("modifier_ability_thdots_ellen02", "abilities/ability_thdots_ellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thdots_ellen02_push", "abilities/ability_thdots_ellen.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_ability_thdots_ellen02_charge_coil_counter", "abilities/ability_thdots_ellen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_ellen02_rotational", "abilities/ability_thdots_ellen.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

ability_thdots_ellen02	= {}
modifier_ability_thdots_ellen02								= class({})
modifier_thdots_ellen02_push								= class({})
modifier_ability_thdots_ellen02_charge_coil_counter			= class({})
modifier_ability_thdots_ellen02_rotational					= class({})

function ability_thdots_ellen02:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
end

function ability_thdots_ellen02:OnSpellStart()
	if not IsServer() then return end

	local caster_pos		= self:GetCaster():GetAbsOrigin()

	local num_of_cogs		= self:GetSpecialValueFor("cogs_num")
	print(num_of_cogs)
	local cogs_radius		= self:GetSpecialValueFor("cogs_radius")

	-- Static value cause this is kinda hot-fixing for now
	local square_dist		= 30

	local cog_vector 		= GetGroundPosition(caster_pos + Vector(0, cogs_radius, 0), nil)
	local second_cog_vector	= GetGroundPosition(caster_pos + Vector(0, cogs_radius * 2, 0), nil)

	self:GetCaster():StartGesture(ACT_DOTA_RATTLETRAP_POWERCOGS)

	-- if not self:GetAutoCastState() then
		for cog = 1, num_of_cogs do

			local cog = CreateUnitByName("npc_dota_rattletrap_cog", cog_vector, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

			cog:EmitSound("Hero_Rattletrap.Power_Cogs")

			cog:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_ellen02",
			{
				duration 	= self:GetSpecialValueFor("duration"),
				x 			= (cog_vector - caster_pos).x,
				y 			= (cog_vector - caster_pos).y,

				-- Also need to store these for the Rotational IMBAfication
				center_x	= caster_pos.x,
				center_y	= caster_pos.y,
				center_z	= caster_pos.z
			})

			-- Talent: Second Gear (might be too laggy with Rotational...)
			cog_vector		= RotatePosition(caster_pos, QAngle(0, 360/num_of_cogs, 0), cog_vector)
		end


	local deploy_particle	= ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(deploy_particle)



	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("cogs_radius") + 80, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)


end

-------------------------
-- POWER COGS MODIFIER --
-------------------------

function modifier_ability_thdots_ellen02:IsHidden()		return true end
function modifier_ability_thdots_ellen02:IsPurgable()	return false end

function modifier_ability_thdots_ellen02:GetEffectName()
	-- No idea if this is actually a thing but w/e using assets as I see them
	return "particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient_blur.vpcf"
end

function modifier_ability_thdots_ellen02:OnCreated(params)
	if self:GetAbility() then
		self.damage					= self:GetAbility():GetSpecialValueFor("damage")
		self.mana_burn				= self:GetAbility():GetSpecialValueFor("mana_burn")
		self.attacks_to_destroy		= self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
		self.push_length			= 200
		self.push_duration			= self:GetAbility():GetSpecialValueFor("push_duration")
		self.trigger_distance		= self:GetAbility():GetSpecialValueFor("trigger_distance")
		self.rotational_speed		= self:GetAbility():GetSpecialValueFor("rotational_speed")


		-- Use this variable to track if the cog is currently charged
		self.powered			= true
		-- Use this variable to track how much "health" the cog has (the health doesn't actually change in vanilla)
		self.health				= self:GetAbility():GetSpecialValueFor("attacks_to_destroy")
	else
		self:Destroy()
		return
	end

	if not IsServer() then return end

	-- Make the cog face a certain way to determine when it should shock people using its "face"
	self:GetParent():SetForwardVector(Vector(params.x, params.y, 0))

	-- Get the center of all the cogs (basically where the caster cast this spell)
	self.center_loc		= Vector(params.center_x, params.center_y, params.center_z)

	-- Check if the cog is from the Second Gear talent (it will be rotating the other way under Rotational)
	self.second_gear	= params.second_gear

	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 62, Vector(0, 0, 0))
	self:AddParticle(self.particle, false, false, -1, false, false)

	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_ellen02:OnIntervalThink()
	if not IsServer() then return end

	-- Lag...
	-- if self:GetAbility() and self:GetAbility():GetAutoCastState() then

		-- if not self.second_gear then
			-- self:GetParent():SetAbsOrigin(GetGroundPosition(RotatePosition(self.center_loc, QAngle(0, self.rotational_speed * FrameTime(), 0), self:GetParent():GetAbsOrigin()), nil))
		-- else
			-- self:GetParent():SetAbsOrigin(GetGroundPosition(RotatePosition(self.center_loc, QAngle(0, self.rotational_speed * FrameTime() * (-1), 0), self:GetParent():GetAbsOrigin()), nil))
		-- end

		-- -- Update forward vector to face away from the center
		-- self:GetParent():SetForwardVector(self:GetParent():GetAbsOrigin() - self.center_loc)
		-- -- Try to make sure people don't get stuck in-between the cogs if they slip in a gap
		-- ResolveNPCPositions(self:GetParent():GetAbsOrigin(), self:GetParent():GetHullRadius())
	-- end

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

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.trigger_distance, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_CLOSEST, false)

	for _, enemy in pairs(enemies) do
		-- QANGLES, HOW DO THEY WORK
		-- Basically this if statement checks if the cog is powered (i.e. hasn't pushed someone yet), if the target themselves isn't already being pushed by another cog, and if the difference between the cog's "face" vector and the directional vector between the enemy and the cog is less than 90 degrees both ways (so 180 degrees of the cog face is valid for shocking)
		if self.powered and not enemy:HasModifier("modifier_thdots_ellen02_push") and math.abs(AngleDiff(VectorToAngles(self:GetParent():GetForwardVector()).y, VectorToAngles(enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()).y)) <= 180 then

			-- The cog is the caster here, as its position will be passed into the modifier
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_thdots_ellen02_push",
			{
				duration	= self.push_duration * (1 - enemy:GetStatusResistance()),

				damage		= self.damage,
				mana_burn	= self.mana_burn,
				push_length	= self.push_length
			})

			ParticleManager:DestroyParticle(self.particle, false)
			ParticleManager:ReleaseParticleIndex(self.particle)

			-- Can't break interval think anymore if I want to have the Rotational IMBAfication handled here too
			--self:StartIntervalThink(-1)
			break
		end
	end
end

function modifier_ability_thdots_ellen02:OnDestroy()
	if not IsServer() then return end

	self:GetParent():StopSound("Hero_Rattletrap.Power_Cogs")
	self:GetParent():EmitSound("Hero_Rattletrap.Power_Cog.Destroy")

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

			if self.health <= 0 then
				self:GetParent():Kill(nil, keys.attacker)


			end
		end
	end
end

------------------------------
-- POWER COGS PUSH MODIFIER --
------------------------------

function modifier_thdots_ellen02_push:OnCreated(params)
	if not IsServer() then return end

	self.duration			= params.duration
	self.damage				= params.damage
	self.mana_burn			= params.mana_burn
	self.push_length		= params.push_length

	-- This is purely for if a cog is destroyed while it is applying a push, so the attacker can be rerouted to the cog owner to properly deal damage
	self.owner				= self:GetCaster():GetOwner() or self:GetCaster()

	-- Normally I put the sounds and particles in the spell cast, but due to having two sources that can potentially call this modifier, I'm putting them in here
	self:GetCaster():EmitSound("Hero_Rattletrap.Power_Cogs_Impact")

	-- Create cog zap particle
	local attack_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	if self:GetCaster():GetName() == "npc_dota_rattletrap_cog" then
		ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	else
		-- Charge Coil particle attachment
		ParticleManager:SetParticleControlEnt(attack_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	end

	-- Calculate speed at which modifier owner will be knocked back
	self.knockback_speed		= self.push_length / self.duration

	-- Get the center of the cog to know which direction to get knocked back
	self.position	= self:GetCaster():GetAbsOrigin()

	-- If horizontal motion cannot be applied, remove the modifier
	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
		return
	end
end

function modifier_thdots_ellen02_push:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end

	local distance = (me:GetOrigin() - self.position):Normalized()

	me:SetOrigin( me:GetOrigin() + distance * self.knockback_speed * dt )
end

-- This typically gets called if the caster uses a position breaking tool (ex. Blink Dagger) while in mid-motion
function modifier_thdots_ellen02_push:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_thdots_ellen02_push:OnDestroy()
	if not IsServer() then return end

	self:GetParent():RemoveHorizontalMotionController( self )

	-- "Applies the damage first, and then the mana loss."
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

	ApplyDamage(damageTable)

	self:GetParent():ReduceMana(self.mana_burn)

	-- "At the end of the knock back, trees within a 100 radius of the unit are destroyed."
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, true )
end

function modifier_thdots_ellen02_push:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function modifier_thdots_ellen02_push:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return decFuncs
end

function modifier_thdots_ellen02_push:GetOverrideAnimation()
	 return ACT_DOTA_FLAIL
end

