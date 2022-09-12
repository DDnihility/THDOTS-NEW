ability_thdots_rinEx = class({})
function ability_thdots_rinEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_rinEx_buff"
end
function ability_thdots_rinEx:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function ability_thdots_rinEx:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.pos = self:GetCursorPosition()
	self.direction = (self.pos - caster:GetAbsOrigin()):Normalized()
	self.direction.z = 0
	--sound:EmitSound("Hero_Puck.Illusory_Orb")
	self.speed = self:GetSpecialValueFor("projectile_speed")
	local count = caster:FindModifierByName("modifier_ability_thdots_rinEx_buff"):GetStackCount()
	if count > 0 then
		local unit = ability_thdots_rinEx_create_spectre(caster:GetAbsOrigin(),caster)
		self.modifier = unit:AddNewModifier(caster,self,"modifier_ability_thdots_rinEx_move",{duration = 2})
		caster:FindModifierByName("modifier_ability_thdots_rinEx_buff"):DecrementStackCount()
	else
		self:RefundManaCost()
		self:EndCooldown()
	end
end

function ability_thdots_rinEx_create_spectre(pos,caster)
	if not IsServer() then return end
	local unit = CreateUnitByName(
		"npc_rinEx_unit"
		,pos
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	ParticleManager:CreateParticle("particles/heroes/rin/rin_spectre.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	local ability_dummy_unit = unit:FindAbilityByName("ability_rinEx_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	local ability = caster:FindAbilityByName("ability_thdots_rinEx")
	local duration = ability:GetSpecialValueFor("duration")
	unit:AddNewModifier(caster,ability,"modifier_ability_thdots_rinEx",{duration = duration})
	--print(duration)
	return unit
end

modifier_ability_thdots_rinEx_move=class({})
LinkLuaModifier("modifier_ability_thdots_rinEx_move","scripts/vscripts/abilities/abilityrin.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_rinEx_move:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.unit = self:GetParent()
	self.pos = self:GetAbility().pos
	self.velocity = self:GetAbility().speed*FrameTime()
	self.vec = self:GetAbility().direction
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_rinEx_move:OnIntervalThink()
	if not IsServer() then return end
	if (self.unit:GetOrigin() - self.pos):Length2D() <= self.velocity then
		self:Destroy()
	else
		self.unit:SetAbsOrigin(self.unit:GetOrigin() + self.vec * self.velocity)
	end
end

function modifier_ability_thdots_rinEx_move:OnDestroy()
	if not IsServer() then return end
	FindClearSpaceForUnit(self.unit, self.pos, true)
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local damage = ability:GetSpecialValueFor("damage") + (FindTelentValue(caster,"special_bonus_unique_rin_7") + 1 ) * caster:GetStrength()
	--print("damage "..damage)
	local targets = FindUnitsInRadius(
		self:GetCaster():GetTeam(),
		self:GetParent():GetAbsOrigin(),
		nil,
		ability:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		ability:GetAbilityTargetType(),
		0,
		0,
		false)
	for _,v in pairs(targets) do
		local damage_table = {
			ability = ability,
			victim = v,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = ability:GetAbilityDamageType(), 
			damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	self:GetParent():EmitSound("Hero_Rattletrap.Rocket_Flare.Explode")
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/rin/rin_spectre_explode.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, self.pos)
end

modifier_ability_thdots_rinEx_buff=class({})
LinkLuaModifier("modifier_ability_thdots_rinEx_buff","scripts/vscripts/abilities/abilityrin.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rinEx_buff:IsHidden() return false end
function modifier_ability_thdots_rinEx_buff:IsPurgable() return false end
function modifier_ability_thdots_rinEx_buff:IsDebuff() return false end
function modifier_ability_thdots_rinEx_buff:RemoveOnDeath() return false end

function modifier_ability_thdots_rinEx_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_thdots_rinEx_buff:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("hp_regen")*self:GetStackCount()
end
function modifier_ability_thdots_rinEx_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("speed_bonus")*self:GetStackCount()
end
function modifier_ability_thdots_rinEx_buff:GetModifierBonusStats_Strength()
	return FindTelentValue(self:GetCaster(),"special_bonus_unique_rin_3")*self:GetStackCount()
end

function modifier_ability_thdots_rinEx_buff:OnDeath(event)
	if not IsServer() then return end
	--DeepPrintTable(event)
	local caster =self:GetCaster()
	if caster:IsAlive()==false then return end
	if event.unit == caster then return end
	local ability = self.caster:FindAbilityByName("ability_thdots_rin04")
	local point = event.unit:GetAbsOrigin()
	local distance = (self:GetCaster():GetOrigin() - point):Length2D()
	local radius = ability:GetSpecialValueFor("radius")
	local aura_radius = ability:GetLevelSpecialValueFor("aura_radius",0)
	local damage_pct = (ability:GetSpecialValueFor("damage_pct")+FindTelentValue(caster,"special_bonus_unique_rin_2"))*0.01
	local ex_damage_pct = (ability:GetSpecialValueFor("ex_damage_pct")+FindTelentValue(caster,"special_bonus_unique_rin_2"))*0.01
	local ex_ability = self:GetAbility()
	if distance <= aura_radius then
		--print(event.unit:GetUnitName())
		--print("damage_pct "..damage_pct)
		--print("ex_damage_pct "..ex_damage_pct)
		local modifier = self
		if event.unit:IsRealHero() then
			self:GetCaster().limit = self:GetCaster().limit + 1
			
		end
		if modifier:GetStackCount() < self:GetCaster().limit + FindTelentValue(caster,"special_bonus_unique_rin_1") and event.unit:HasModifier("dummy_unit")==false and event.unit:HasModifier("modifier_illusion")==false then
			modifier:IncrementStackCount()
		end
		if event.unit:GetTeam() ~= caster:GetTeam() then return end
		if caster:HasModifier("modifier_ability_thdots_rin04_passive")==false or event.unit:HasModifier("modifier_illusion") then return end
		local effectIndex = ParticleManager:CreateParticle("particles/econ/events/diretide_2020/death_effect/death_dt20_pre.vpcf", PATTACH_CUSTOMORIGIN, event.unit)
		ParticleManager:SetParticleControl(effectIndex, 0, point)
		local targets = FindUnitsInRadius(
			caster:GetTeam(), 
			point,
			nil,
			radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			0,
			0,
			false)
		local damage = event.unit:GetMaxHealth() * damage_pct
		if event.unit:GetUnitName() ~= "npc_rinEx_unit" then 
			ex_damage_pct = 0
		else
			damage = 0
		end
		--print("death")
		for _,v in pairs(targets) do
			local damage_table = {
					ability = ability,
					victim = v,
					attacker = caster,
					damage = damage + (v:GetMaxHealth()-v:GetHealth())*ex_damage_pct,
					damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
			UnitDamageTarget(damage_table)
		end
	end
end
function modifier_ability_thdots_rinEx_buff:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self:StartIntervalThink(0.2)
end
function modifier_ability_thdots_rinEx_buff:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_rin_4") ~= 0 then
		self.caster:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_rinEx_buff_2",{})
	end
end

modifier_ability_thdots_rinEx_buff_2=class({})
LinkLuaModifier("modifier_ability_thdots_rinEx_buff_2","scripts/vscripts/abilities/abilityrin.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rinEx_buff_2:IsHidden() return false end
function modifier_ability_thdots_rinEx_buff_2:IsPurgable() return false end
function modifier_ability_thdots_rinEx_buff_2:IsDebuff() return false end
function modifier_ability_thdots_rinEx_buff_2:RemoveOnDeath() return true end

function modifier_ability_thdots_rinEx_buff_2:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	ParticleManager:CreateParticle("particles/heroes/rin/rin_talent_flame.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	self:StartIntervalThink(1)
end
function modifier_ability_thdots_rinEx_buff_2:OnIntervalThink()
	if not IsServer() then return end
	local count = self.caster:FindModifierByName("modifier_ability_thdots_rinEx_buff"):GetStackCount()
	local targets = FindUnitsInRadius(
		self.caster:GetTeam(),
		self.caster:GetAbsOrigin(),
		nil,
		450,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		self.ability:GetAbilityTargetType(),
		0,
		0,
		false)
	for _,v in pairs(targets) do
		local damage_table = {
					ability = self.ability,
					victim = v,
					attacker = self.caster,
					damage = count * FindTelentValue(self:GetCaster(),"special_bonus_unique_rin_4"),
					damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
	end

end

modifier_ability_thdots_rinEx=class({})
LinkLuaModifier("modifier_ability_thdots_rinEx","scripts/vscripts/abilities/abilityrin.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rinEx:IsHidden() return false end

function modifier_ability_thdots_rinEx:OnDestroy()
	if not IsServer() then return end
	self:GetParent():Destroy()
end

modifier_ability_thdots_rinEx_explode=class({})
LinkLuaModifier("modifier_ability_thdots_rinEx_explode","scripts/vscripts/abilities/abilityrin.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rinEx_explode:IsHidden() return false end

function modifier_ability_thdots_rinEx_explode:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:GetClassname() ~= "npc_dota_hero_abyssal_underlord" then return end
	local ability = caster:FindAbilityByName("ability_thdots_rinEx")
	ability:EndCooldown()
	local damage = ability:GetSpecialValueFor("damage") + (FindTelentValue(caster,"special_bonus_unique_rin_7") + 1 ) * caster:GetStrength()
	local stun_duration = ability:GetSpecialValueFor("stun_duration") + FindTelentValue(caster,"special_bonus_unique_rin_6")
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/rin/rin_spectre_explode.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, self:GetParent():GetAbsOrigin()+Vector(0,0,128))
	self:GetParent():EmitSound("Hero_Rattletrap.Rocket_Flare.Explode")
	local targets = FindUnitsInRadius(
		caster:GetTeam(),
		self:GetParent():GetAbsOrigin(),
		nil,
		ability:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		ability:GetAbilityTargetType(),
		0,
		0,
		false)
	for _,v in pairs(targets) do
		local damage_table = {
					ability = ability,
					victim = v,
					attacker = self:GetCaster(),
					damage = damage,
					damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UtilStun:UnitStunTarget(caster,v,stun_duration)
		UnitDamageTarget(damage_table)
	end
	self:GetParent():ForceKill(false)
	self:GetParent():Destroy()
	--print("explode")
end

ability_thdots_rin01 = class({})
function ability_thdots_rin01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0
	caster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
	local distance = self:GetSpecialValueFor("max_distance")
	local speed = self:GetSpecialValueFor("projectile_speed")
	local pfx_name = "particles/heroes/rin/rin_01_wheel.vpcf"
	local info =
	{
		Ability = self,
		EffectName = pfx_name,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = 100,
		fEndRadius = 100,
		Source = caster,
		iUnitTargetTeam	= DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * speed,
		bProvidesVision = false,
	}
	self.projectile = ProjectileManager:CreateLinearProjectile(info)
end

function ability_thdots_rin01:OnProjectileHit(target, pos)
	if not IsServer() then return end
	--print("OnProjectileHit")
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local ability = self:GetCaster():FindAbilityByName("ability_thdots_rinEx")
	
	if target then
		--print("name "..target:GetUnitName())
		if target:GetTeam() ~= caster:GetTeam() then
			local damage_table = {
					ability = self,
					victim = target,
					attacker = caster,
					damage = damage,
					damage_type = self:GetAbilityDamageType(), 
					damage_flags = 0
				}
			UnitDamageTarget(damage_table)
		end
		if target and not target:IsNull() and target:GetUnitName() == "npc_rinEx_unit" and caster:GetClassname() =="npc_dota_hero_abyssal_underlord" then 
			target:AddNewModifier(caster,ability,"modifier_ability_thdots_rinEx_explode",{})
		end
	else
		--print("01 last hit")
		StartSoundEventFromPosition("Hero_Clinkz.Death", pos)
		
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, pos)
	end
end

ability_thdots_rin02 = class({})

function ability_thdots_rin02:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_rin02:OnSpellStart()
	if not IsServer() then return end
	self.point = self:GetCursorPosition()
	self:GetCaster():EmitSound("Hero_ElderTitan.AncestralSpirit.Return")
	CreateModifierThinker(self:GetCaster(), self, "modifier_ability_thdots_rin02_thinker", {duration = 6},  self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
	--self:EmitSound("Hero_ArcWarden.SparkWraith.Loop")
end

modifier_ability_thdots_rin02_thinker = modifier_ability_thdots_rin02_thinker or class({})
LinkLuaModifier("modifier_ability_thdots_rin02_thinker", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)


function modifier_ability_thdots_rin02_thinker:OnCreated()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	self.point 		= self:GetAbility().point
	self.radius		= self:GetAbility():GetSpecialValueFor("radius")
	self.width		= self:GetAbility():GetSpecialValueFor("width")
	self.min_radius	= self:GetAbility():GetSpecialValueFor("min_radius")
	self.damage		= self:GetAbility():GetSpecialValueFor("damage") * FrameTime()
	self.shrink_speed	= self:GetAbility():GetSpecialValueFor("shrink_speed") * FrameTime()
	self.reduce_speed	= self:GetAbility():GetSpecialValueFor("reduce_speed")
	self:StartIntervalThink(FrameTime())
	self.effectIndex={}
	local pos = self.point + Vector(0,self.radius-self.width * 0.5,0)
	for i = 1, 12 do
		self.effectIndex[i] = ParticleManager:CreateParticle("particles/heroes/rin/rin_02.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(self.effectIndex[i], 0, pos)
		pos = RotatePosition(self.point, QAngle(0, 30, 0), pos)
	end
end

function modifier_ability_thdots_rin02_thinker:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()
   -- AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 275, 2, true)
   --挑选环形区域内单位
    local FinalTarget={}
	local AllTarget = FindUnitsInRadius(
						caster:GetTeam(),
						self.point,
						nil,
						self.radius,
						DOTA_UNIT_TARGET_TEAM_BOTH,
						19,
						ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
	--print("AllTarget",unpack(AllTarget))
	local RemoveTarget = FindUnitsInRadius(
						caster:GetTeam(),
						self.point,
						nil,
						self.radius-self.width,
						DOTA_UNIT_TARGET_TEAM_BOTH,
						19,
						ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
	--print("RemoveTarget",unpack(RemoveTarget))
	for i = 1, #AllTarget do
		if AllTarget[i] ~= RemoveTarget[i] then
			for j = i, #AllTarget do
				if AllTarget[j]:GetTeam()~=caster:GetTeam() and AllTarget[j]:IsHero() then
					table.insert(FinalTarget,AllTarget[j])
				elseif AllTarget[j]:GetUnitName() == "npc_rinEx_unit" then 
					table.insert(FinalTarget,AllTarget[j])
				end
			end
			for _,v in pairs(FinalTarget) do
				if v:GetTeam()~=caster:GetTeam() then
					local damage_table = {
						ability = ability,
						victim = v,
						attacker = caster,
						damage = self.damage,
						damage_type = ability:GetAbilityDamageType(), 
						damage_flags = 0
					}
					UnitDamageTarget(damage_table)
				end
				--牵引
				if v and not v:IsNull() then
					local vector_distance = v:GetAbsOrigin()-self.point
					local Direction = vector_distance:Normalized()
					Direction.z = 0
					local distance = (vector_distance):Length2D()
					v:AddNewModifier(caster,ability,"modifier_ability_thdots_rin02",{duration = 2 * FrameTime()})
					FindClearSpaceForUnit(v, v:GetAbsOrigin() - Direction * self.shrink_speed, false)
				end
			end
			break
		end
	end
	--大于最小范围时收缩范围和特效
	if self.radius > self.min_radius then
		self.radius = self.radius - self.shrink_speed
		local pos = self.point + Vector(0,self.radius-self.width * 0.5,0)
		for i = 1, 12 do
			ParticleManager:SetParticleControl(self.effectIndex[i], 0, pos)
			pos = RotatePosition(self.point, QAngle(0, 30, 0), pos)
		end
	end
	--print("radius "..self.radius)
end

function modifier_ability_thdots_rin02_thinker:OnDestroy()
	if not IsServer() then return end
	for i = 1, 12 do
		ParticleManager:DestroyParticleSystem(self.effectIndex[i],true)
	end
end

modifier_ability_thdots_rin02 = class({})
LinkLuaModifier("modifier_ability_thdots_rin02", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_rin02:CheckState() 
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_rin_5") ~= 0 and IsTHDImmune(self:GetParent()) ~= true then
		return {
			[MODIFIER_STATE_MUTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		} 
	else
		return {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		}
	end
end

function modifier_ability_thdots_rin02:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_thdots_rin02:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("reduce_speed")
end

ability_thdots_rin03 = class({})

function ability_thdots_rin03:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_rin03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local range = self:GetSpecialValueFor("range")
	local distance = (caster:GetOrigin() - point):Length2D()
	if distance > range then
		distance = range
	end
	local duration = distance/self:GetSpecialValueFor("speed")
	caster:EmitSound("Hero_MonkeyKing.TreeJump.Cast")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_rin03_move",{duration = duration})
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_rin03_buff",{duration = self:GetSpecialValueFor("duration")})
end

modifier_ability_thdots_rin03_move = class({})
LinkLuaModifier("modifier_ability_thdots_rin03_move", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin03_move:IsHidden() return true end
function modifier_ability_thdots_rin03_move:IsPurgable() return false end
function modifier_ability_thdots_rin03_move:IsDebuff() return false end
function modifier_ability_thdots_rin03_move:RemoveOnDeath() return true end

function modifier_ability_thdots_rin03_move:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.point = self.ability:GetCursorPosition()
	self.velocity = self.ability:GetSpecialValueFor("speed")*FrameTime()
	local distance = (self.caster:GetOrigin() - self.point):Length2D()
	self.vec = (self.point - self.caster:GetAbsOrigin()):Normalized()
	--self.vec.z = 0
	local range = self.ability:GetSpecialValueFor("range")
	if distance > range then
		self.point = self.caster:GetOrigin() + self.vec * range
	end
	if self.caster:GetClassname() == "npc_dota_hero_abyssal_underlord" then
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3_END,1)
	end
	self.caster:SetForwardVector(self.vec)
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_rin03_move:OnIntervalThink()
	if not IsServer() then return end
	if (self.caster:GetOrigin() - self.point):Length2D() <= self.velocity then
		self:Destroy()
	else
		--local height = GetGroundHeight(self.caster:GetAbsOrigin(), nil)
		local pos = self.caster:GetAbsOrigin() + self.vec * self.velocity
		--pos.z = height
		self.caster:SetAbsOrigin(pos)
	end
end

function modifier_ability_thdots_rin03_move:OnDestroy()
	if not IsServer() then return end
	if self.caster:GetClassname() =="npc_dota_hero_abyssal_underlord" then
		local targets = FindUnitsInRadius(
			self.caster:GetTeam(),
			self.point,
			nil,
			self.ability:GetSpecialValueFor("radius"),
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			self.ability:GetAbilityTargetType(),
			self.ability:GetAbilityTargetFlags(),
			FIND_CLOSEST,
			false)
		for _,v in pairs(targets) do
			if v:GetUnitName() == "npc_rinEx_unit" then 
				v:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_rinEx_explode",{})
			end
		end
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1.2)
	end
	FindClearSpaceForUnit(self.caster, self.caster:GetAbsOrigin(), true)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	local ForwardVector = self.caster:GetForwardVector()
	ForwardVector.z = 0
	self.caster:SetForwardVector(ForwardVector)
	self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3_END)
end

modifier_ability_thdots_rin03_buff = class({})
LinkLuaModifier("modifier_ability_thdots_rin03_buff", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin03_buff:IsHidden() return false end
function modifier_ability_thdots_rin03_buff:IsPurgable() return false end
function modifier_ability_thdots_rin03_buff:IsDebuff() return false end
function modifier_ability_thdots_rin03_buff:RemoveOnDeath() return true end

function modifier_ability_thdots_rin03_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
end
function modifier_ability_thdots_rin03_buff:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("evasion")
end

ability_thdots_rin04 = class({})
function ability_thdots_rin04:GetIntrinsicModifierName()
	return "modifier_ability_thdots_rin04_passive"
end

modifier_ability_thdots_rin04_passive = class({})
LinkLuaModifier("modifier_ability_thdots_rin04_passive", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin04_passive:IsHidden() return false end
function modifier_ability_thdots_rin04_passive:IsPurgable() return false end
function modifier_ability_thdots_rin04_passive:IsDebuff() return false end
function modifier_ability_thdots_rin04_passive:RemoveOnDeath() return false end
--[[
function modifier_ability_thdots_rin04_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_ability_thdots_rin04_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_rin04_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_ability_thdots_rin04_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_ability_thdots_rin04_passive:GetModifierAura() return "modifier_ability_thdots_rin04_dead" end
function modifier_ability_thdots_rin04_passive:IsAura() return true end
]]
--[[
function modifier_ability_thdots_rin04_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_ability_thdots_rin04_passive:OnDeath(event)
	if not IsServer() then return end
	--DeepPrintTable(event)
	local caster =self:GetCaster()
	if event.unit == caster then return end
	local ability = self:GetAbility()
	local point = event.unit:GetAbsOrigin()
	local distance = (self:GetCaster():GetOrigin() - point):Length2D()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
	local damage_pct = (self:GetAbility():GetSpecialValueFor("damage_pct")+FindTelentValue(caster,"special_bonus_unique_rin_2"))*0.01
	local ex_damage_pct = (self:GetAbility():GetSpecialValueFor("ex_damage_pct")+FindTelentValue(caster,"special_bonus_unique_rin_2"))*0.01
	--print("damage_pct "..damage_pct)
	--print("ex_damage_pct "..ex_damage_pct)
	local ex_ability = self:GetParent():FindAbilityByName("ability_thdots_rinEx")
	if distance <= aura_radius then
		--print(event.unit:GetUnitName())
		local modifier = caster:FindModifierByName("modifier_ability_thdots_rinEx_buff")
		if event.unit:IsRealHero() then
			self:GetCaster().limit = self:GetCaster().limit + 1
			
		end
		if modifier:GetStackCount() < self:GetCaster().limit and event.unit:GetUnitName() == "npc_rinEx_unit" then
			modifier:IncrementStackCount()
		end
		print(ability:GetLevel())
		print("max limit "..self:GetCaster().limit)
		print("count "..modifier:GetStackCount())
		local effectIndex = ParticleManager:CreateParticle("particles/econ/events/diretide_2020/death_effect/death_dt20_pre.vpcf", PATTACH_CUSTOMORIGIN, event.unit)
		ParticleManager:SetParticleControl(effectIndex, 0, point)
		local targets = FindUnitsInRadius(
			caster:GetTeam(), 
			point,
			nil,
			radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			0,
			0,
			false)
		local damage = event.unit:GetMaxHealth() * damage_pct
		if event.unit:GetUnitName() ~= "npc_rinEx_unit" then 
			ex_damage_pct = 0
		else
			damage = 0
		end
		for _,v in pairs(targets) do
			local damage_table = {
					ability = ability,
					victim = v,
					attacker = caster,
					damage = damage + (v:GetMaxHealth()-v:GetHealth())*ex_damage_pct,
					damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
			UnitDamageTarget(damage_table)
		end
	end
end
]]
function ability_thdots_rin04:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local num = self:GetSpecialValueFor("num")
	local pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 200
	local duration = self:GetSpecialValueFor("duration")
	local hp = self:GetSpecialValueFor("health")
	local move_speed = self:GetSpecialValueFor("move_speed")
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Spectre.HauntCast")
	for i=1, num do
		local unit = CreateUnitByName(
			"npc_rin04_unit"
			,pos
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
		ResolveNPCPositions(unit:GetAbsOrigin(), 128)
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true) 
     	unit:EmitSound("Hero_KeeperOfTheLight.Wisp.Active")
		unit:AddNewModifier(self:GetCaster(),self,"modifier_ability_thdots_rin04",{duration = duration})
		unit:SetBaseMaxHealth(hp)
		unit:SetBaseMoveSpeed(move_speed)
		pos = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, 360/num, 0), pos)
	end
end

modifier_ability_thdots_rin04 = class({})
LinkLuaModifier("modifier_ability_thdots_rin04", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin04:IsHidden() return false end
function modifier_ability_thdots_rin04:IsPurgable() return false end
function modifier_ability_thdots_rin04:IsDebuff() return false end
function modifier_ability_thdots_rin04:RemoveOnDeath() return true end

function modifier_ability_thdots_rin04:OnDestroy()
	if not IsServer() then return end
	local pos = self:GetParent():GetAbsOrigin()
	local caster = self:GetCaster()
	local unit = ability_thdots_rinEx_create_spectre(pos,caster)
	self:GetParent():Kill(self:GetAbility(),caster)
end

function modifier_ability_thdots_rin04:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}
end
function modifier_ability_thdots_rin04:GetModifierMoveSpeedOverride()
	return self:GetAbility():GetSpecialValueFor("move_speed")
end

ability_thdots_rin_wbc = class({})
function ability_thdots_rin_wbc:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_rin_wbc:GetBehavior()
	if self:GetCaster():HasModifier("modifier_ability_thdots_rin_wbc_throw") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET+DOTA_ABILITY_BEHAVIOR_POINT+DOTA_ABILITY_BEHAVIOR_AOE		
	end
end

function ability_thdots_rin_wbc:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_rin_wbc_throw") then
	 	return 0
	else
	 	return self.BaseClass.GetManaCost(self, level)
	end
end

function ability_thdots_rin_wbc:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			self:SetHidden(true)
		end
	end
end

function ability_thdots_rin_wbc:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_ability_thdots_rin_wbc_throw") then
		caster:RemoveModifierByName("modifier_ability_thdots_rin_wbc_throw")
	else
		--记录cd和变身时刻
		self.remain_time = self:GetCooldownTimeRemaining()
		self.time = GameRules:GetGameTime()
		self:EndCooldown()
		if self:GetCursorTarget() ~= nil then
			self.target = self:GetCursorTarget()
			self.point = self.target:GetAbsOrigin()
			--print("target")
		else
			self.point = self:GetCursorPosition()
			--print("point")
		end
		caster:AddNewModifier(caster,self,"modifier_ability_thdots_rin_wbc_throw",{duration = 3})
		self.modifier = caster:AddNewModifier(caster,self,"modifier_ability_thdots_rin_wbc",{duration = 3})
		caster:EmitSound("Hero_Pangolier.Gyroshell.Loop")
		
	end	
end

modifier_ability_thdots_rin_wbc_throw = class({})
LinkLuaModifier("modifier_ability_thdots_rin_wbc_throw", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin_wbc_throw:IsHidden() return true end
function modifier_ability_thdots_rin_wbc_throw:IsPurgable() return false end
function modifier_ability_thdots_rin_wbc_throw:IsDebuff() return false end
function modifier_ability_thdots_rin_wbc_throw:RemoveOnDeath() return true end

modifier_ability_thdots_rin_wbc = class({})
LinkLuaModifier("modifier_ability_thdots_rin_wbc", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin_wbc:IsHidden() return true end
function modifier_ability_thdots_rin_wbc:IsPurgable() return false end
function modifier_ability_thdots_rin_wbc:IsDebuff() return false end
function modifier_ability_thdots_rin_wbc:RemoveOnDeath() return true end

function modifier_ability_thdots_rin_wbc:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.max_num = self.ability:GetSpecialValueFor("max_num")
	self.velocity = self.ability:GetSpecialValueFor("speed")*FrameTime()
	self.search_radius = self.ability:GetSpecialValueFor("search_radius")
	self.target = self.ability.target
	self.point = self.ability.point
	self.distance = (self.caster:GetOrigin() - self.point):Length2D()
	self:StartIntervalThink(FrameTime())
	self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_6,1.5)
end

function modifier_ability_thdots_rin_wbc:OnIntervalThink()
	if not IsServer() then return end
	if self.target ~= nil then
		self.point = self.target:GetAbsOrigin()
	end
	self.vec = (self.point - self.caster:GetAbsOrigin()):Normalized()
	self.vec.z = 0
	self.caster:SetForwardVector(self.vec)
	local targets = FindUnitsInRadius(
		self.caster:GetTeam(), 
		self.caster:GetAbsOrigin() + 100 * self.caster:GetForwardVector(),
		nil,
		self.search_radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		self.ability:GetAbilityTargetType(),
		0,
		FIND_CLOSEST,
		false)

	--记录单位位置
	local relative_position = {}
	local units = {}
	for k,v in pairs(targets) do
		if self.max_num > 0 and v:GetClassname() ~= "npc_dota_hero_abyssal_underlord" and v ~= self.target and IsTHDImmune(v)==false then
			--print("num "..self.max_num)
			if v:GetUnitName() == "npc_rinEx_unit" or v:IsHero() or v:GetUnitName() == "npc_rin04_unit" then
				table.insert(units,targets[k])
				table.insert(relative_position,self.caster:GetAbsOrigin() - v:GetAbsOrigin())
				--self.max_num = self.max_num - 1
			end
		end
	end

	--扔车
	if self.caster:HasModifier("modifier_ability_thdots_rin_wbc_throw")~=true then
		--扔车动作
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,3)
		--车投射物特效与伤害
		ability_thdots_rin_wbc_create_projectile(self.caster,self.point,self.ability,self.search_radius)
		--你们都去吧
		local duration = (self.caster:GetOrigin() - self.point):Length2D()/self.ability:GetSpecialValueFor("speed")
		for k,v in pairs(units) do
			v:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_rin_wbc_move",{duration = duration})
			v:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_rin_wbc_root",{duration = duration})
		end
		--自身停止移动
		self.caster:EmitSound("Hero_Pangolier.Gyroshell.Cast")
		self.caster:StopSound("Hero_Pangolier.Gyroshell.Loop")
		self:Destroy()
	else
		--移动
		if (self.caster:GetOrigin() - self.point):Length2D() > self.velocity then
			--移动自己
			local height = GetGroundHeight(self.caster:GetAbsOrigin(), nil)
			local pos = self.caster:GetAbsOrigin() + self.vec * self.velocity
			pos.z = height
			self.caster:SetAbsOrigin(pos)
			--移动全体单位
			for k,v in pairs(units) do
				local height = GetGroundHeight(v:GetAbsOrigin(), nil)
				local pos = self.caster:GetAbsOrigin() - relative_position[k]
				pos.z = height
				v:SetAbsOrigin(pos)
				v:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_rin_wbc_root",{duration = FrameTime()})
			end
		--非常靠近，停止
		else
			for k,v in pairs(units) do
				v:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_rin_wbc_move",{duration = FrameTime()})
			end
			self.caster:RemoveModifierByName("modifier_ability_thdots_rin_wbc_throw")
			self.caster:StopSound("Hero_Pangolier.Gyroshell.Loop")
			self:Destroy()
		end
	end
end

function modifier_ability_thdots_rin_wbc:OnDestroy()
	if not IsServer() then return end
	self:GetAbility().point = nil
	self:GetAbility().target = nil
	--ResolveNPCPositions(self.caster:GetAbsOrigin() + self.caster:GetForwardVector() * 100, 128)
	FindClearSpaceForUnit(self.caster, self.caster:GetAbsOrigin(), true)

	--计算冷却时间=技能释放时CD-(目前时刻-变身时刻)
	local cool_down = self:GetAbility().remain_time + self:GetAbility().time - GameRules:GetGameTime()
	--与0相比的最大值
	cool_down = (cool_down>0) and cool_down or 0
	--先冷却结束，再开始冷却
	self:GetAbility():EndCooldown()
	self:GetAbility():StartCooldown(cool_down)
	self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
end

function modifier_ability_thdots_rin_wbc:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]= true,
	}
end

modifier_ability_thdots_rin_wbc_root = class({})
LinkLuaModifier("modifier_ability_thdots_rin_wbc_root", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin_wbc_root:CheckState()
	return {
		[MODIFIER_STATE_ROOTED]= true,
	}
end

modifier_ability_thdots_rin_wbc_move = class({})
LinkLuaModifier("modifier_ability_thdots_rin_wbc_move", "scripts/vscripts/abilities/abilityrin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_rin_wbc_move:IsHidden() return true end
function modifier_ability_thdots_rin_wbc_move:IsPurgable() return false end
function modifier_ability_thdots_rin_wbc_move:IsDebuff() return false end
function modifier_ability_thdots_rin_wbc_move:RemoveOnDeath() return true end

function modifier_ability_thdots_rin_wbc_move:CheckState()
	if self:GetParent():HasModifier("modifier_ability_thdots_rin_wbc_root") then
		return {
			[MODIFIER_STATE_STUNNED]= true,
		}
	end
end

function modifier_ability_thdots_rin_wbc_move:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.unit = self:GetParent()
	self.velocity = self.ability:GetSpecialValueFor("speed")*FrameTime()*2
	self.point = self.caster:FindModifierByName("modifier_ability_thdots_rin_wbc").point
	self.vec = (self.point - self.caster:GetAbsOrigin()):Normalized()
	self.path = self.point - self.caster:GetAbsOrigin()
	self.point = self.unit:GetAbsOrigin() + self.path
	local height = GetGroundHeight(self.point, nil)
	self.point.z = height
	self.vec.z = 0
	self.present_point = self.unit:GetAbsOrigin()
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_rin_wbc_move:OnIntervalThink()
	if not IsServer() then return end
	local dis = (self.present_point-self.unit:GetAbsOrigin()):Length2D()
	if dis > 20 then self:Destroy() end
	local present_point =  self.unit:GetAbsOrigin()
	if (present_point - self.point):Length2D() <= 2 * self.velocity then
		--移动最后，消除卡死
		local modifier = self.unit:FindModifierByName("modifier_ability_thdots_rin_wbc_root")
		if modifier ~= nil then
			modifier:Destroy()
		end
		self:Destroy()
	else
		local height = GetGroundHeight(present_point, nil)
		local pos = present_point + self.vec * self.velocity
		pos.z = height
		self.unit:SetAbsOrigin(pos)
		self.present_point = self.unit:GetAbsOrigin()
	end
	
end

function modifier_ability_thdots_rin_wbc_move:OnDestroy()
	if not IsServer() then return end
	FindClearSpaceForUnit(self.unit, self.unit:GetAbsOrigin(), true)
end

function ability_thdots_rin_wbc:OnProjectileHit(target, pos)
	if not IsServer() then return end
	--print("OnProjectileHit")
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("path_damage")
	local ability = self
	local radius = self:GetSpecialValueFor("radius")
	local explosion_damage = self:GetSpecialValueFor("explosion_damage")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	--StartSoundEventFromPosition("Hero_Jakiro.LiquidFire", target:GetOrigin())
	if target then
		--print("name "..target:GetUnitName())
		if target:GetTeam() ~= caster:GetTeam() then
			local damage_table = {
					ability = ability,
					victim = target,
					attacker = caster,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
			UtilStun:UnitStunTarget(caster,target,stun_duration)
			UnitDamageTarget(damage_table)
		end
	else
		--print("last hit")
		StartSoundEventFromPosition("Hero_Techies.Suicide",pos)
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, pos)
		local targets = FindUnitsInRadius(
			caster:GetTeam(), 
			pos,
			nil,
			self:GetSpecialValueFor("radius"),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			self:GetAbilityTargetType(),
			0,
			FIND_CLOSEST,
			false)
		for _,v in pairs(targets) do
			local damage_table = {
				ability = self,
				victim = v,
				attacker = caster,
				damage = explosion_damage,
				damage_type = ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UtilStun:UnitStunTarget(caster,v,stun_duration)
			UnitDamageTarget(damage_table)
		end
	end
end

function ability_thdots_rin_wbc_create_projectile(caster,pos,ability,radius)
	if not IsServer() then return end
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0
	--sound:EmitSound("Hero_Puck.Illusory_Orb")
	local distance = (caster:GetOrigin() - pos):Length2D() - 70
	local speed = ability:GetSpecialValueFor("speed")*2
	local pfx_name = "particles/heroes/rin/rin_wbc.vpcf"
	local info =
	{
		Ability = ability,
		EffectName = pfx_name,
		vSpawnOrigin = caster:GetAbsOrigin() + caster:GetForwardVector() * 70,
		fDistance = distance,
		fStartRadius = radius,
		fEndRadius = radius,
		Source = caster,
		iUnitTargetTeam	= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * speed,
		bProvidesVision		= true,
		iVisionRadius		= 400,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	ProjectileManager:CreateLinearProjectile(info)
end