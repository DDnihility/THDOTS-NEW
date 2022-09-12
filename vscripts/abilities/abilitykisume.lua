--------------------------------------------------------
--吊瓶「Well Destructor」
--------------------------------------------------------
ability_thdots_kisumeEx = {}

function ability_thdots_kisumeEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_kisumeEx_passive"
end

modifier_ability_thdots_kisumeEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_kisumeEx_passive","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisumeEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_kisumeEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_kisumeEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisumeEx_passive:IsDebuff()		return false end
function modifier_ability_thdots_kisumeEx_passive:OnCreated()
	self:SetStackCount(1)
end


function modifier_ability_thdots_kisumeEx_passive:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_ability_thdots_kisumeEx_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_ability_thdots_kisumeEx_passive:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_kisume_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_kisumeEx_telent_1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_kisumeEx_telent_1",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_kisume_1"))
	end
end

modifier_ability_thdots_kisumeEx_telent_1 = modifier_ability_thdots_kisumeEx_telent_1 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_kisumeEx_telent_1","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisumeEx_telent_1:IsHidden() 		return true end
function modifier_ability_thdots_kisumeEx_telent_1:IsPurgable()		return false end
function modifier_ability_thdots_kisumeEx_telent_1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisumeEx_telent_1:IsDebuff()		return false end
--------------------------------------------------------
--怪奇「钓瓶落之怪」
--------------------------------------------------------
ability_thdots_kisume01 = {}

function ability_thdots_kisume01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end
function ability_thdots_kisume01:GetAOERadius()
	return self:GetSpecialValueFor("stun_radius")
end

function ability_thdots_kisume01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	self.cast_range = self:GetSpecialValueFor("cast_range")
	self.point = self.caster:GetOrigin() + (self:GetCursorPosition() - self.caster:GetOrigin()):Normalized() * self.cast_range
	self.duration = self:GetSpecialValueFor("duration")
	self.damage = self:GetSpecialValueFor("damage")
	self.damage_radius = self:GetSpecialValueFor("damage_radius")
	self.think_damage = self:GetSpecialValueFor("think_damage")
	self.stun_radius = self:GetSpecialValueFor("stun_radius")
	self.cast_range = self:GetSpecialValueFor("cast_range")
	self.kisumeEx_stun_time = 0
	print(self.point)
	print(self.cast_range)
	print((self:GetCursorPosition() - self.caster:GetOrigin()):Normalized())
	print(self:GetCursorPosition())

	caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume01")

	kisumeEx_count(self.caster,self)

	local latch_radius = 80
	local projectile_speed = 1200

	local particle_name = "particles/units/heroes/hero_invoker_kid/invoker_kid_base_attack_exort.vpcf"
	self.kisume01_particle_start = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN,nil)

	ParticleManager:SetParticleControl(self.kisume01_particle_start, 0, Vector(self.caster:GetOrigin().x,self.caster:GetOrigin().y,self.caster:GetOrigin().z + 100))
	ParticleManager:SetParticleControl(self.kisume01_particle_start, 1, Vector(self.point.x,self.point.y,self.point.z + 100))
	ParticleManager:SetParticleControl(self.kisume01_particle_start, 2, Vector(projectile_speed+50,0,0))

	local projectile = {
		Ability				= self,
		-- EffectName			= "particles/econ/items/invoker/invoker_ti6/invoker_ti6_exort_orb.vpcf", -- Doesn't do anything
		vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
		fDistance			= self.cast_range + self:GetCaster():GetCastRangeBonus(),
		fStartRadius		= latch_radius,
		fEndRadius			= latch_radius,
		Source				= self:GetCaster(),
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= self:GetAbilityTargetFlags(),
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		fExpireTime 		= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= true,
		vVelocity			= (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * projectile_speed * Vector(1, 1, 0),
		bProvidesVision		= true,
		ExtraData			= {kisume01_start_particle = self.kisume01_particle_start}
	}
	self.projectile = ProjectileManager:CreateLinearProjectile(projectile)
end


function ability_thdots_kisume01:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if not IsServer() then return end
	self.caster = self:GetCaster()
	StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume01_2",vLocation)
	CreateModifierThinker(self.caster, self, "modifier_ability_thdots_kisume01_dummy", {duration = self.duration},vLocation, self.caster:GetTeamNumber(), false)
	ProjectileManager:DestroyLinearProjectile(self.projectile)
	if ExtraData.kisume01_start_particle then
		ParticleManager:DestroyParticle(ExtraData.kisume01_start_particle, true)
		ParticleManager:ReleaseParticleIndex(ExtraData.kisume01_start_particle)
		ProjectileManager:DestroyLinearProjectile(self.projectile)
	end
end

modifier_ability_thdots_kisume01_dummy = {}
LinkLuaModifier("modifier_ability_thdots_kisume01_dummy","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume01_dummy:IsHidden() 		return true end
function modifier_ability_thdots_kisume01_dummy:IsPurgable()		return false end
function modifier_ability_thdots_kisume01_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisume01_dummy:IsDebuff()		return false end

function modifier_ability_thdots_kisume01_dummy:GetEffectName() return "particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_ambient_esl.vpcf" end
function modifier_ability_thdots_kisume01_dummy:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_kisume01_dummy:OnCreated()
	if not IsServer() then return end
	local interval = 0.5
	self.caster = self:GetCaster()
	self.dummy = self:GetParent()
	self.ability = self:GetAbility()
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.damage_radius = self.ability:GetSpecialValueFor("damage_radius")
	self.think_damage = self.ability:GetSpecialValueFor("think_damage") * interval
	self.stun_radius = self.ability:GetSpecialValueFor("stun_radius")
	self.stun_duration = self.ability:GetSpecialValueFor("stun_duration") + self.ability.kisumeEx_stun_time
	print("self.stun_duration")
	print(self.stun_duration)
	print(self.ability.kisumeEx_stun_time)
	self.dummy:EmitSound("Voice_Thdots_Kisume.AbilityKisume01_3")
	self.dummy:EmitSound("Voice_Thdots_Kisume.AbilityKisume01_4")
	
	self.kisume01_particle = ParticleManager:CreateParticle("particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_ambient_esl.vpcf", PATTACH_WORLDORIGIN,nil)

	ParticleManager:SetParticleControl(self.kisume01_particle, 0, self.dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.kisume01_particle, 1, self.dummy:GetOrigin())

	local targets = FindUnitsInRadius(self.caster:GetTeam(), self:GetParent():GetOrigin(),nil,self.stun_radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
	for _,victim in pairs(targets) do
		local damage_table = {
					ability = self.ability,
				    victim = victim,
				    attacker = self.caster,
				    damage = self.damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UtilStun:UnitStunTarget(self.caster,victim,self.stun_duration)
		UnitDamageTarget(damage_table)
	end
	self:StartIntervalThink(interval)
end

function modifier_ability_thdots_kisume01_dummy:OnIntervalThink()
	if not IsServer() then return end
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self:GetParent():GetOrigin(),nil,self.damage_radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
	local particle_name_1 = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_death_fire.vpcf"
	local particle_name_2 = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_death_ember_suck.vpcf"
	local particle_name_3 = "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground_hit_glow.vpcf"
	local kisume01_think_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(kisume01_think_particle, 0, self.dummy:GetOrigin())
	ParticleManager:SetParticleControl(kisume01_think_particle, 1, self.dummy:GetOrigin())
	ParticleManager:DestroyParticleSystem(kisume01_think_particle,false)

	local kisume01_think_particle_2 = ParticleManager:CreateParticle(particle_name_2, PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(kisume01_think_particle_2, 0, self.dummy:GetOrigin())
	ParticleManager:SetParticleControl(kisume01_think_particle_2, 1, self.dummy:GetOrigin())
	ParticleManager:DestroyParticleSystem(kisume01_think_particle_2,false)

	local kisume01_think_particle_3 = ParticleManager:CreateParticle(particle_name_2, PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(kisume01_think_particle_3, 0, self.dummy:GetOrigin())
	ParticleManager:SetParticleControl(kisume01_think_particle_3, 3, self.dummy:GetOrigin())
	ParticleManager:DestroyParticleSystem(kisume01_think_particle_3,false)

	for _,victim in pairs(targets) do
		local damage_table = {
					ability = self.ability,
				    victim = victim,
				    attacker = self.caster,
				    damage = self.think_damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
	end
end

function modifier_ability_thdots_kisume01_dummy:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.kisume01_particle,true)
	self.dummy:StopSound("Voice_Thdots_Kisume.AbilityKisume01_4")
end
--------------------------------------------------------
--吊瓶「飞入井中」
--------------------------------------------------------
ability_thdots_kisume02 = {}

function ability_thdots_kisume02:GetCastRange()
	if self:GetCaster():HasModifier("modifier_ability_thdots_kisumeEx_telent_1") then
		return self:GetSpecialValueFor("cast_range") + 500
	else
		return self:GetSpecialValueFor("cast_range")
	end
end
function ability_thdots_kisume02:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_kisume02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	local cast_range = self:GetSpecialValueFor("cast_range") + caster:GetCastRangeBonus() + FindTelentValue(self:GetCaster(),"special_bonus_unique_kisume_1")
	local damage = self:GetSpecialValueFor("damage")
	local damage_bonus = self:GetSpecialValueFor("damage_bonus")
	local invin_time = self:GetSpecialValueFor("invin_time")
	local distance = (self:GetCursorPosition() - caster:GetOrigin()):Length2D()
	if distance >= cast_range then
		distance = cast_range
	end
	self.point = caster:GetOrigin() + (self:GetCursorPosition() - caster:GetOrigin()):Normalized() * distance
	self.damage_bonus = self:GetSpecialValueFor("damage_bonus")
	self.damage = self:GetSpecialValueFor("damage")
	local kisume02_invic = caster:AddNewModifier(caster, self, "modifier_ability_thdots_kisume02_invin", {duration = invin_time})
	
	ProjectileManager:ProjectileDodge(caster)
	caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume02_1")
	self.kisumeEx_stun_time = 0
	kisumeEx_count(self.caster,self)
end

modifier_ability_thdots_kisume02_invin = {}
LinkLuaModifier("modifier_ability_thdots_kisume02_invin","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume02_invin:IsHidden() 		return true end
function modifier_ability_thdots_kisume02_invin:IsPurgable()		return false end
function modifier_ability_thdots_kisume02_invin:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisume02_invin:IsDebuff()		return false end

function modifier_ability_thdots_kisume02_invin:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] 	= true,
		[MODIFIER_STATE_OUT_OF_GAME]	= true,
		[MODIFIER_STATE_UNSELECTABLE]	= true,
		[MODIFIER_STATE_DISARMED]		= true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end
function modifier_ability_thdots_kisume02_invin:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:GetName() == "npc_dota_hero_ember_spirit" then
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,0.1)
	end
	caster:SetContextThink("kisume02_delay", function ()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_kisume02_delay", {duration = 0.4})
	end,0.2)
end
function modifier_ability_thdots_kisume02_invin:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local point = ability.point
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_bonus = ability:GetSpecialValueFor("damage_bonus")
	damage = damage + caster:GetAverageTrueAttackDamage(caster) * damage_bonus
	self.ability = self:GetAbility()
	self.caster = caster
	print("self.ability.kisumeEx_stun_time")
	print(damage)
	print(caster:GetAverageTrueAttackDamage(caster))

	
	--特效音效
	caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume02_2")
	local particle_name_1 = "particles/units/heroes/hero_leshrac/leshrac_split_projected.vpcf"
	if self.ability.kisumeEx_stun_time ~= 0 then
		caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume02_3")
		-- particle_name_1 = "particles/econ/items/leshrac/leshrac_tormented_staff_retro/leshrac_split_retro_tormented.vpcf"
		particle_name_1 = "particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf"
	end
	local particle_name_2 = "particles/heroes/seija/seija04.vpcf"
	local particle_name_3 = "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground_hit_glow.vpcf"
	local kisume02_explosion_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(kisume02_explosion_particle, 0, self.caster:GetOrigin())
	ParticleManager:SetParticleControl(kisume02_explosion_particle, 1, Vector(radius,radius,radius))
	ParticleManager:DestroyParticleSystem(kisume02_explosion_particle,false)

	-- local kisume02_explosion_particle_2 = ParticleManager:CreateParticle(particle_name_2, PATTACH_WORLDORIGIN,nil)
	-- ParticleManager:SetParticleControl(kisume02_explosion_particle_2, 0, point)
	-- ParticleManager:SetParticleControl(kisume02_explosion_particle_2, 1, point)
	-- ParticleManager:SetParticleControl(kisume02_explosion_particle_2, 0, Vector(radius,radius,radius))
	-- -- ParticleManager:SetParticleControl(kisume02_explosion_particle_2, 1, self.caster:GetOrigin())
	-- ParticleManager:DestroyParticleSystem(kisume02_explosion_particle_2,false)

	-- local kisume02_explosion_particle_3 = ParticleManager:CreateParticle(particle_name_2, PATTACH_WORLDORIGIN,nil)
	-- ParticleManager:SetParticleControl(kisume02_explosion_particle_3, 0, self.caster:GetOrigin())
	-- ParticleManager:SetParticleControl(kisume02_explosion_particle_3, 3, self.caster:GetOrigin())
	-- ParticleManager:DestroyParticleSystem(kisume02_explosion_particle_3,false)

	local targets = FindUnitsInRadius(self.caster:GetTeam(), point,nil,radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)

	for _,victim in pairs(targets) do
		local damage_decrease = (victim:GetOrigin() - point):Length2D() / radius
		local victim_damage = damage * (1 - damage_decrease)
		print("1111111111")
		print(damage_decrease)
		print(damage)
		print(victim_damage)
		local damage_table = {
					ability = self.ability,
				    victim = victim,
				    attacker = self.caster,
				    damage = victim_damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		if self.ability.kisumeEx_stun_time ~= 0 then
			UtilStun:UnitStunTarget(self.caster,victim,self.ability.kisumeEx_stun_time)
		end
		UnitDamageTarget(damage_table)
	end
end

modifier_ability_thdots_kisume02_delay = {}
LinkLuaModifier("modifier_ability_thdots_kisume02_delay","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume02_delay:IsHidden() 		return true end
function modifier_ability_thdots_kisume02_delay:IsPurgable()		return false end
function modifier_ability_thdots_kisume02_delay:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisume02_delay:IsDebuff()		return false end

function modifier_ability_thdots_kisume02_delay:OnCreated()
	if not IsServer() then return end
	self:GetParent():AddNoDraw()
end

function modifier_ability_thdots_kisume02_delay:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local point = ability.point
	self:GetParent():RemoveNoDraw()
	FindClearSpaceForUnit(self:GetParent(), point, true)
	if caster:GetName() == "npc_dota_hero_ember_spirit" then
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_END,0.1)
	end
end

--------------------------------------------------------
--桶符「强力防护之桶」
--------------------------------------------------------
ability_thdots_kisume03 = {}

function ability_thdots_kisume03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_kisume03_passive"
end

modifier_ability_thdots_kisume03_passive = {}
LinkLuaModifier("modifier_ability_thdots_kisume03_passive","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume03_passive:IsHidden() 		return false end
function modifier_ability_thdots_kisume03_passive:IsPurgable()		return false end
function modifier_ability_thdots_kisume03_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisume03_passive:IsDebuff()		return false end
function modifier_ability_thdots_kisume03_passive:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end
function modifier_ability_thdots_kisume03_passive:GetModifierIncomingDamage_Percentage()
	return -self:GetAbility():GetSpecialValueFor("decrease_damage")
end


function ability_thdots_kisume03:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_kisume03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	self.point = caster:GetOrigin()
	self.duration = self:GetSpecialValueFor("duration")
	self.radius = self:GetSpecialValueFor("radius")
	self.damage = self:GetSpecialValueFor("damage")
	print(self.duration)
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_kisume03_active", {duration = self.duration})

	self.kisumeEx_stun_time = 0
	kisumeEx_count(self.caster,self)

	caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume03_1")
	local particle_name = "particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf"
	local kisume03_damage_particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW,self.caster)
	ParticleManager:DestroyParticleSystem(kisume03_damage_particle,false)


	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.point,nil,self.radius,self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),0,0,false)

	for _,victim in pairs(targets) do
		local damage_table = {
					ability = self,
				    victim = victim,
				    attacker = self.caster,
				    damage = self.damage,
				    damage_type = self:GetAbilityDamageType(), 
					damage_flags = 0
				}
		if self.kisumeEx_stun_time ~= 0 then
			UtilStun:UnitStunTarget(self.caster,victim,self.kisumeEx_stun_time)
		end
		UnitDamageTarget(damage_table)
	end
end

modifier_ability_thdots_kisume03_active = {}
LinkLuaModifier("modifier_ability_thdots_kisume03_active","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume03_active:IsHidden() 		return false end
function modifier_ability_thdots_kisume03_active:IsPurgable()		return false end
function modifier_ability_thdots_kisume03_active:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisume03_active:IsDebuff()		return false end
function modifier_ability_thdots_kisume03_active:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.defence = self.ability:GetSpecialValueFor("defence")
	self.armor_bonus = self.ability:GetSpecialValueFor("armor_bonus")
	print("active_number")
	print(self.armor_bonus)
	self.defence = self.defence + self.caster:GetPhysicalArmorValue(false) * self.armor_bonus
	print(self.defence)

	local particle_name_1 = "particles/econ/items/ember_spirit/ember_ti9/ember_ti9_flameguard_shield_core.vpcf"
	local particle_name_2 = "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard_shield.vpcf"
	
	self.kisume03_guard_particle = ParticleManager:CreateParticle(particle_name_2, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.kisume03_guard_particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControl(self.kisume03_guard_particle, 2, Vector(128,128,128))
	-- ParticleManager:SetParticleControl(self.kisume03_guard_particle, 3, Vector(128,128,128))
	

	self.kisume03_guard_particle_1 = ParticleManager:CreateParticle(particle_name_2, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(self.kisume03_guard_particle_1, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	-- local kisume03_guard_particle_2 = ParticleManager:CreateParticle(particle_name_1, PATTACH_ABSORIGIN_FOLLOW,self.caster)
	-- ParticleManager:SetParticleControl(kisume03_guard_particle_2, 0, self.dummy:GetOrigin())
	-- ParticleManager:SetParticleControl(kisume03_guard_particle_2, 1, self.dummy:GetOrigin())
	-- ParticleManager:DestroyParticleSystem(kisume03_guard_particle_2,false)

end

function modifier_ability_thdots_kisume03_active:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.kisume03_guard_particle,true)
	ParticleManager:DestroyParticleSystem(self.kisume03_guard_particle_1,true)
	if self.defence > 0 then
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_kisume_2") ~= 0 then
			self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(self.end_particle)
			self:GetParent():EmitSound("Voice_Thdots_Kisume.AbilityKisume03_Heal")
			self:GetParent():Heal(self.defence, self:GetParent())
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetParent(),self.defence,nil)
		end
	else
		self:GetParent():EmitSound("Voice_Thdots_Kisume.AbilityKisume03_Explosion")
		local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetOrigin())
		ParticleManager:ReleaseParticleIndex(particle)
	end
end

function modifier_ability_thdots_kisume03_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
	}
end

function modifier_ability_thdots_kisume03_active:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	local caster 				= self:GetCaster()
	local original_shield_amount	= self.defence
	if kv.attacker == kv.target then return end
	self.defence = self.defence - kv.damage
	if kv.damage < original_shield_amount then
		--Emit damage blocking effect
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, caster, kv.damage, nil)
		return kv.damage
			--Else, reduce what you can and blow up the shield
	else
		--Emit damage block effect
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, caster, original_shield_amount, nil)
		-- ParticleManager:DestroyParticleSystem(self.particle, true)
		-- caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
		-- local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, caster)
		-- ParticleManager:SetParticleControl(particle, 0, target_vector)
		-- ParticleManager:ReleaseParticleIndex(particle)
		self:Destroy()
		return original_shield_amount
	end
end

--------------------------------------------------------
--鬼火「皿数燃尽」
--------------------------------------------------------
ability_thdots_kisume04 = {}

function ability_thdots_kisume04:GetAbilityTextureName()
	return "custom/kisume/ability_thdots_kisume_4"
end

function ability_thdots_kisume04:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_kisume04:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")
	local max_health = self:GetSpecialValueFor("max_health") / 100
	local point = caster:GetOrigin()

	local health = caster:GetMaxHealth() * max_health
	local caster_damage = caster:GetHealth() - health
	local damage_table = {
				ability = nil,
			    victim = caster,
			    attacker = nil,
			    damage = caster_damage / 3,
			    damage_type = DAMAGE_TYPE_PURE, 
				damage_flags = 0
			}
	-- ApplyDamage(damage_table)
	caster:SetHealth(health)
	local d = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster,self,"modifier_ability_thdots_kisume04",{duration = d})
	--万宝槌加伤害
	local target_damage = 0
	if caster:HasModifier("modifier_ability_thdots_kisume05_caster") then
		local caster_modifier = caster:FindModifierByName("modifier_ability_thdots_kisume05_caster")
		local target = caster_modifier.target
		local target_health = target:GetMaxHealth() * max_health
		target_damage = target:GetHealth() - target_health
		local damage_table = {
				ability = nil,
			    victim = target,
			    attacker = nil,
			    damage = target_damage / 2,
			    damage_type = DAMAGE_TYPE_PURE, 
				damage_flags = 0
			}
		-- ApplyDamage(damage_table)
		target:AddNewModifier(caster,self,"modifier_ability_thdots_kisume04",{duration = d})
		target:SetHealth(target_health)
		damage = damage * 2
	end

	--天赋加伤害
	damage = damage + caster_damage * FindTelentValue(self:GetCaster(),"special_bonus_unique_kisume_3") + target_damage * FindTelentValue(self:GetCaster(),"special_bonus_unique_kisume_3")

	self.kisumeEx_stun_time = 0
	kisumeEx_count(self.caster,self)

	--特效音效
	caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume04_1")
	StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume04_1", caster:GetOrigin())
	StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume04_1", caster:GetOrigin())
	StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume04_1", caster:GetOrigin())
	local particle_name_1 = "particles/units/heroes/hero_invoker_kid/invoker_kid_loadout.vpcf"
	local particle_name_2 = "particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf"
	local particle_name_3 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf"
	
	local kisume04_particle = ParticleManager:CreateParticle(particle_name_1, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
	ParticleManager:SetParticleControlEnt(kisume04_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
	ParticleManager:ReleaseParticleIndex(kisume04_particle)


	local kisume04_particle_2 = ParticleManager:CreateParticle(particle_name_2, PATTACH_WORLDORIGIN, nil)
	-- ParticleManager:SetParticleControl(kisume04_particle_2, 0, Vector(particle_point.x,particle_point.y,particle_point.z+1500))
	ParticleManager:SetParticleControl(kisume04_particle_2, 0, point)
	ParticleManager:SetParticleControl(kisume04_particle_2, 3, point)
	ParticleManager:SetParticleControl(kisume04_particle_2, 5, point)
	ParticleManager:ReleaseParticleIndex(kisume04_particle_2)

	if self.kisumeEx_stun_time ~= 0 then
		local kisume04_particle_Ex = ParticleManager:CreateParticle(particle_name_3, PATTACH_CUSTOMORIGIN_FOLLOW,self.caster)
		ParticleManager:SetParticleControl(kisume04_particle_2, 0, point)
		ParticleManager:SetParticleControl(kisume04_particle_2, 0, Vector(radius,radius,radius))
		-- ParticleManager:SetParticleControlEnt(kisume04_particle_Ex, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", point, true)
		ParticleManager:ReleaseParticleIndex(kisume04_particle_Ex)
		StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume04_3",caster:GetOrigin())
		StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume04_3",caster:GetOrigin())
		StartSoundEventFromPosition("Voice_Thdots_Kisume.AbilityKisume04_3",caster:GetOrigin())
	end

	--设置20个点,10个大圈，10个小圈
	local per_num = 30
	local num_1 = per_num
	local num_2 = per_num
	local num_3 = per_num
	local qangle = QAngle(0, 360/per_num, 0)
	local num = num_1 + num_2 + num_3
	local cp = caster:GetOrigin()
	cp.x = cp.x + 0.01 --设置技能点偏移，不然特效会出BUG
	local position = point + (point - cp):Normalized() * radius
	local position_2 = point + (point - cp):Normalized() * ( radius - 150 )
	local position_3 = point + (point - cp):Normalized() * ( radius - 300 )
	local pt = {}
	for i=1,num do
		pt[i] = position
		if i == num_1 then
			position = position_2
		elseif i == num_1+num_2 then
			position = position_3
		end
		position = RotatePosition(point, qangle, position)
	end
	local particle_name_3 = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf"
	for i=1,num do
			local particle_point = pt[i]

			local kisume04_particle_2 = ParticleManager:CreateParticle(particle_name_3, PATTACH_WORLDORIGIN, nil)
			-- ParticleManager:SetParticleControl(kisume04_particle_2, 0, Vector(particle_point.x,particle_point.y,particle_point.z+1500))
			ParticleManager:SetParticleControl(kisume04_particle_2, 0, particle_point)
			ParticleManager:ReleaseParticleIndex(kisume04_particle_2)
		end
	---------------------
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,radius,self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),0,0,false)

	for _,victim in pairs(targets) do
		local damage_table = {
					ability = self,
				    victim = victim,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self:GetAbilityDamageType(), 
					damage_flags = 0
				}
				print(self.kisumeEx_stun_time)
		if self.kisumeEx_stun_time ~= 0 then
			UtilStun:UnitStunTarget(self.caster,victim,self.kisumeEx_stun_time)
		end
		UnitDamageTarget(damage_table)
	end
end

modifier_ability_thdots_kisume04 = {}
LinkLuaModifier("modifier_ability_thdots_kisume04","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume04:IsHidden() 		return false end
function modifier_ability_thdots_kisume04:IsPurgable()		return false end
function modifier_ability_thdots_kisume04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_kisume04:IsDebuff()		return true end
function modifier_ability_thdots_kisume04:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_ability_thdots_kisume04:GetModifierHealAmplify_PercentageTarget()
	return self:GetAbility():GetSpecialValueFor("regen_amplify")
end

function modifier_ability_thdots_kisume04:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("regen_amplify")
end

--------------------------------------------------------
--「飞入桶中」
--------------------------------------------------------
ability_thdots_kisume05 = {}

function ability_thdots_kisume05:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			if self:GetCaster():HasModifier("modifier_ability_thdots_kisume05_caster") then
				self:GetCaster():RemoveModifierByName("modifier_ability_thdots_kisume05_caster")
			end
			self:SetHidden(true)
		end
	end
end

function ability_thdots_kisume05:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_kisume05:GetCastRange()
	if self:GetCaster():HasModifier("modifier_ability_thdots_kisume05_caster") then
		return self:GetSpecialValueFor("cast_range") + 600
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function ability_thdots_kisume05:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ability_thdots_kisume05_caster") then
		return "custom/kisume/ability_thdots_kisume_05_2"
	else
		return "custom/kisume/ability_thdots_kisume_05_1"
	end
end

function ability_thdots_kisume05:GetBehavior()
	if self:GetCaster():HasModifier("modifier_ability_thdots_kisume05_caster") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function ability_thdots_kisume05:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_kisume05_caster") then
		return 0
	else
		return self.BaseClass.GetManaCost(self, level)
	end
end

function ability_thdots_kisume05:CastFilterResultTarget(hTarget)
	if hTarget:IsRealHero() and hTarget ~= self:GetCaster() and hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return
	else
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_kisume05:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	local target = self:GetCursorTarget()
	local point  = self:GetCursorPosition()
	local ability = self
	local duration = self:GetSpecialValueFor("duration")
	local distance = (point - caster:GetOrigin()):Length2D()
	if not caster:HasModifier("modifier_ability_thdots_kisume05_caster") then
		local kisume05_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(kisume05_particle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(kisume05_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(kisume05_particle)
		caster:EmitSound("Voice_Thdots_Kisume.AbilityKisume05")
		local caster_modifier = caster:AddNewModifier(caster, self, "modifier_ability_thdots_kisume05_caster", {duration = duration})
		caster_modifier.modifier = target:AddNewModifier(caster, self, "modifier_ability_thdots_kisume05_target", {duration = duration})
		caster_modifier.target = target
	else
		local caster_modifier = caster:FindModifierByName("modifier_ability_thdots_kisume05_caster")
		local target = caster_modifier.target
		caster:RemoveModifierByName("modifier_ability_thdots_kisume05_caster")
		FindClearSpaceForUnit(target, caster:GetOrigin() + caster:GetForwardVector()*150, true)
		local knockback_properties = {
			 center_x 			= caster:GetOrigin().x,
			 center_y 			= caster:GetOrigin().y,
			 center_z 			= caster:GetOrigin().z,
			 duration 			= 0.5 ,
			 knockback_duration = 0.5,
			 knockback_distance = distance,
			 knockback_height 	= 600,
		}
		target:AddNewModifier(caster, self, "modifier_knockback", knockback_properties)
		target:EmitSound("Voice_Thdots_Kisume.AbilityKisume05_throw")
	end

end


modifier_ability_thdots_kisume05_caster = {}
LinkLuaModifier("modifier_ability_thdots_kisume05_caster","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume05_caster:IsHidden() 		return false end
function modifier_ability_thdots_kisume05_caster:IsPurgable()		return false end
function modifier_ability_thdots_kisume05_caster:RemoveOnDeath() 	return true end
function modifier_ability_thdots_kisume05_caster:IsDebuff()		return false end
function modifier_ability_thdots_kisume05_caster:OnDestroy()
	if not IsServer() then return end
	if self.target:HasModifier("modifier_ability_thdots_kisume05_target") then
		self.target:RemoveModifierByName("modifier_ability_thdots_kisume05_target")
	end
	self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("cooldown"))
end

modifier_ability_thdots_kisume05_target = {}
LinkLuaModifier("modifier_ability_thdots_kisume05_target","scripts/vscripts/abilities/abilitykisume.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_kisume05_target:IsHidden() 		return false end
function modifier_ability_thdots_kisume05_target:IsPurgable()		return false end
function modifier_ability_thdots_kisume05_target:RemoveOnDeath() 	return false end
function modifier_ability_thdots_kisume05_target:IsDebuff()		return false end
function modifier_ability_thdots_kisume05_target:OnCreated()
	if not IsServer() then return end
	self:GetParent():AddNoDraw()
	self.interval = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_kisume05_target:OnIntervalThink()
	if not IsServer() then return end
	if self.interval <= 1 then
		self.interval = self.interval + FrameTime()
	else
		self:SetStackCount(1)
	end
	local caster = self:GetCaster()
	local target = self:GetParent()
	target:SetOrigin(caster:GetOrigin())
end


function modifier_ability_thdots_kisume05_target:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER,
	}
end

function modifier_ability_thdots_kisume05_target:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetParent()
	if self.drop_point ~= nil then
		local point = caster:GetOrigin() + (self.drop_point - caster:GetOrigin()):Normalized()
		target:SetOrigin(point)
		target:SetForwardVector((self.drop_point - caster:GetOrigin()):Normalized())
		local knockback_properties = {
			 center_x 			= caster:GetOrigin().x,
			 center_y 			= caster:GetOrigin().y,
			 center_z 			= caster:GetOrigin().z,
			 duration 			= 0.5 ,
			 knockback_duration = 0.5,
			 knockback_distance = 200,
			 knockback_height 	= 200,
		}
		target:AddNewModifier(caster, self, "modifier_knockback", knockback_properties)
		target:EmitSound("Voice_Thdots_Kisume.AbilityKisume05_throw")
	end
	self:GetParent():RemoveNoDraw()
end

function modifier_ability_thdots_kisume05_target:OnOrder(kv)
	if not IsServer() then return end
	if kv.unit == self:GetParent() and self:GetStackCount() == 1 then
		self.drop_point = kv.new_pos
		self:GetCaster():RemoveModifierByName("modifier_ability_thdots_kisume05_caster")
	end
end


function modifier_ability_thdots_kisume05_target:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] 	= true,
		[MODIFIER_STATE_OUT_OF_GAME]	= true,
		[MODIFIER_STATE_UNSELECTABLE]	= true,
		[MODIFIER_STATE_DISARMED]		= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
		-- [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end


function kisumeEx_count(caster,ability)
	if ability.caster:HasModifier("modifier_ability_thdots_kisumeEx_passive") and ability.caster:HasAbility("ability_thdots_kisumeEx") then
		local kisumeEx_modifier = ability.caster:FindModifierByName("modifier_ability_thdots_kisumeEx_passive")
		local kisumeEx = ability.caster:FindAbilityByName("ability_thdots_kisumeEx")
		local kisumeEx_count = kisumeEx:GetSpecialValueFor("count") + FindTelentValue(caster,"special_bonus_unique_kisume_4")
		if kisumeEx_modifier:GetStackCount() >= kisumeEx_count then
			ability.kisumeEx_stun_time = kisumeEx:GetSpecialValueFor("duration")
			kisumeEx_modifier:SetStackCount(0)
		else
			kisumeEx_modifier:IncrementStackCount()
		end
	end
end