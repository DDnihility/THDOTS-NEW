--------------------------------------------------------
--仙术「Wall Runner」
--------------------------------------------------------
ability_thdots_seigaEx = {}

function ability_thdots_seigaEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_seigaEx_passive"
end

function ability_thdots_seigaEx:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_seigaEx:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT
end

function ability_thdots_seigaEx:OnSpellStart()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target_point = self:GetCursorPosition()
	self.exclude_distance = self:GetSpecialValueFor("exclude_distance")
	self.duration = self:GetSpecialValueFor("duration")
	local fail_flag = (self.target_point - self.caster:GetAbsOrigin()):Length2D()<=self.exclude_distance
	local portals_near_1 = FindUnitsInRadius(self.caster:GetTeamNumber(), self.target_point, nil, self.exclude_distance, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	if fail_flag then
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, self.caster)
		ParticleManager:SetParticleControlEnt(effectIndex, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_origin", self.caster:GetAbsOrigin(), true)
		ParticleManager:DestroyParticle(effectIndex, false)
		self.caster:EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx.Explode")
		return
	end
	for _, portal in pairs(portals_near_1) do
		if portal:FindModifierByName("modifier_ability_thdots_seigaEx_portal") then
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, portal)
			ParticleManager:SetParticleControlEnt(effectIndex, 0, portal, PATTACH_POINT_FOLLOW, "attach_origin", portal:GetAbsOrigin(), true)
			ParticleManager:DestroyParticle(effectIndex, false)
			portal:EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx.Explode")
			return
		end
	end

	local portals_near_2 = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, self.exclude_distance, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

	for _, portal in pairs(portals_near_2) do
		if portal:FindModifierByName("modifier_ability_thdots_seigaEx_portal") then
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, portal)
			ParticleManager:SetParticleControlEnt(effectIndex, 0, portal, PATTACH_POINT_FOLLOW, "attach_origin", portal:GetAbsOrigin(), true)
			ParticleManager:DestroyParticle(effectIndex, false)
			portal:EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx.Explode")
			return
		end
	end

	local portal_1 = CreateUnitByName(
		"npc_ability_seiga_ex_portal"
		,self.target_point
		,false
		,self.caster
		,self.caster
		,self.caster:GetTeam()
	)
	FindClearSpaceForUnit(portal_1, self.target_point, false)
	local ability_dummy_unit_1 = portal_1:FindAbilityByName("ability_dummy_unit")
	portal_1:AddNewModifier(self.caster, self, "modifier_ability_thdots_seigaEx_portal", {duration = self.duration})
	ability_dummy_unit_1:SetLevel(1)
	portal_1.effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti10/portal/portal_open_good.vpcf", PATTACH_POINT, portal_1)

	local time_1 = 0
	portal_1:SetContextThink(DoUniqueString("OnSeigaExDestroy"),
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			time_1 = time_1 + 0.2
			if time_1 >= self.duration then
				ParticleManager:DestroyParticle(portal_1.effectIndex, false)
				local effectIndex = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, portal_1)
				ParticleManager:SetParticleControlEnt(effectIndex, 0, portal_1, PATTACH_POINT_FOLLOW, "attach_origin", portal_1:GetAbsOrigin(), true)
				ParticleManager:DestroyParticle(effectIndex, false)
				portal_1:EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx.Explode")
				portal_1:Destroy()
				return nil
			end
			return 0.2
		end,
		0
	)

	local portal_2 = CreateUnitByName(
		"npc_ability_seiga_ex_portal"
		,self.caster:GetAbsOrigin()
		,false
		,self.caster
		,self.caster
		,self.caster:GetTeam()
	)
	FindClearSpaceForUnit(portal_2, self.caster:GetAbsOrigin(), false)
	local ability_dummy_unit_2 = portal_2:FindAbilityByName("ability_dummy_unit")
	portal_2:AddNewModifier(self.caster, self, "modifier_ability_thdots_seigaEx_portal", {duration = self.duration})
	ability_dummy_unit_2:SetLevel(1)
	portal_2.effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti10/portal/portal_open_good.vpcf", PATTACH_POINT, portal_2)

	local time_2 = 0
	portal_2:SetContextThink(DoUniqueString("OnSeigaExDestroy"),
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			time_2 = time_2 + 0.2
			if time_2 >= self.duration then
				ParticleManager:DestroyParticle(portal_2.effectIndex, false)
				local effectIndex = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, portal_2)
				ParticleManager:SetParticleControlEnt(effectIndex, 0, portal_2, PATTACH_POINT_FOLLOW, "attach_origin", portal_2:GetAbsOrigin(), true)
				ParticleManager:DestroyParticle(effectIndex, false)
				portal_2:EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx.Explode")
				portal_2:Destroy()
				return nil
			end
			return 0.2
		end,
		0
	)

	portal_1.dual = portal_2
	portal_2.dual = portal_1
end

modifier_ability_thdots_seigaEx_portal = {}
LinkLuaModifier("modifier_ability_thdots_seigaEx_portal", "abilities/abilityseiga.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_seigaEx_portal:IsHidden() return false end
function modifier_ability_thdots_seigaEx_portal:IsPurgable() return false end
function modifier_ability_thdots_seigaEx_portal:IsDebuff() return false end

function modifier_ability_thdots_seigaEx_portal:OnCreated()
	if not self:GetAbility() then
		self:Destroy()
		return
	end

	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.portal = self:GetParent()
	self.trigger_distance = self.ability:GetSpecialValueFor("trigger_distance")
	self.transport_cooldown = self.ability:GetSpecialValueFor("transport_cooldown")

	if not IsServer() then return end

	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_seigaEx_portal:OnIntervalThink()
	if not IsServer() then return end
	local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.trigger_distance, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for _, hero in pairs(heroes) do
		if not hero:FindModifierByName("modifier_ability_thdots_seigaEx_transport_cooldown") and hero:GetTeam() == self:GetCaster():GetTeam() then
			local effectIndex_1 = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, self.portal)
			ParticleManager:SetParticleControlEnt(effectIndex_1, 0, self.portal, PATTACH_POINT_FOLLOW, "attach_origin", self.portal:GetAbsOrigin(), true)
			ParticleManager:DestroyParticle(effectIndex_1, false)

			local effectIndex_2 = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_POINT, self.portal.dual)
			ParticleManager:SetParticleControlEnt(effectIndex_2, 0, self.portal.dual, PATTACH_POINT_FOLLOW, "attach_origin", self.portal.dual:GetAbsOrigin(), true)
			ParticleManager:DestroyParticle(effectIndex_2, false)

			hero:EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx.Transport")
			hero:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_seigaEx_transport_cooldown", {duration = self.transport_cooldown})
			FindClearSpaceForUnit(hero, self.portal.dual:GetAbsOrigin(), false)
		end
	end
end

modifier_ability_thdots_seigaEx_transport_cooldown = {}
LinkLuaModifier("modifier_ability_thdots_seigaEx_transport_cooldown", "abilities/abilityseiga.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_seigaEx_transport_cooldown:IsHidden() return false end
function modifier_ability_thdots_seigaEx_transport_cooldown:IsPurgable() return false end
function modifier_ability_thdots_seigaEx_transport_cooldown:RemoveOnDeath() return false end
function modifier_ability_thdots_seigaEx_transport_cooldown:IsDebuff() return true end

-- function ability_thdots_seigaEx:OnSpellStart()
-- 	if not IsServer() then return end
-- 	local duration = self:GetSpecialValueFor("duration")
-- 	THDReduceCooldown(self,FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_7"))
-- 	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_seigaEx_active", {duration = duration})
-- 	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bloodseeker_thirst", {duration = duration})
-- 	self:GetCaster():EmitSound("Voice_Thdots_Seiga.AbilitySeigaEx")
-- end

-- modifier_ability_thdots_seigaEx_active = {}
-- LinkLuaModifier("modifier_ability_thdots_seigaEx_active","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_seigaEx_active:IsHidden() 		return true end

-- function modifier_ability_thdots_seigaEx_active:CheckState()
-- 	return {
-- 		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
-- 	}
-- end

-- function modifier_ability_thdots_seigaEx_active:DeclareFunctions()
-- 	return {
-- 		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
-- 	}
-- end
-- function modifier_ability_thdots_seigaEx_active:GetModifierMoveSpeedBonus_Constant()
-- 	return self.speed
-- end

-- function modifier_ability_thdots_seigaEx_active:OnCreated()
-- 	self.speed = 1000
-- 	if not IsServer() then return end
-- 	self.parent = self:GetParent()
-- 	local particle	=	"particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_force_staff.vpcf"
-- 	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
-- 	-- ParticleManager:SetParticleControl(self.particle_fx, 0, self.parent:GetAbsOrigin())
-- 	-- ParticleManager:SetParticleControl(self.particle_fx, 3, self.parent:GetAbsOrigin())
-- 	ParticleManager:SetParticleControlEnt(self.particle_fx,0,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
-- 	ParticleManager:SetParticleControlEnt(self.particle_fx,20,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
-- 	self:StartIntervalThink(FrameTime())
-- end

-- function modifier_ability_thdots_seigaEx_active:OnDestroy()
-- 	if not IsServer() then return end
-- 	-- Remove the particle
-- 	ParticleManager:DestroyParticle(self.particle_fx, false)
-- 	ParticleManager:ReleaseParticleIndex(self.particle_fx)
-- end

-- function modifier_ability_thdots_seigaEx_active:OnIntervalThink()
-- 	self.speed = self.speed - 30
-- 	if not IsServer() then return end
-- end

modifier_ability_thdots_seigaEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_seigaEx_passive","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seigaEx_passive:IsHidden() 		return true end
function modifier_ability_thdots_seigaEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_seigaEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seigaEx_passive:IsDebuff()		return false end

function modifier_ability_thdots_seigaEx_passive:DeclareFunctions()
	return
	{
		-- MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_thdots_seigaEx_passive:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.link_particle = false
    local seiga_weapon = ParticleManager:CreateParticle("models/kaku_seiga/kaku_seiga_ambient.vpcf", PATTACH_POINT_FOLLOW,self:GetCaster())
    ParticleManager:SetParticleControlEnt(seiga_weapon,0,self:GetCaster(),PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	self:StartIntervalThink(FrameTime())
end

-- 本来设置买活打折的，后来太麻烦了懒得做了。
-- function modifier_ability_thdots_seigaEx_passive:OnDeath(keys)
-- 	if not IsServer() then return end
-- 	local caster = self:GetParent()
-- 	if keys.unit == self:GetParent() then
-- 		local ability = self:GetAbility()
-- 		local buy_back_reduce = ability:GetSpecialValueFor("buy_back_reduce")
-- 		local cost = PlayerResource:GetGoldSpentOnBuybacks(caster:GetPlayerID())
-- 		local buyback_cost = cost * (1 - buy_back_reduce * 0.01 )
-- 	   	PlayerResource:SetCustomBuybackCost(caster:GetPlayerID(),100)
-- 	end
-- end

function modifier_ability_thdots_seigaEx_passive:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self.link_particle == false and false then
		self.link_particle = true
		-- 与华扇的羁绊特效
		-- local seiga_link = ParticleManager:CreateParticle("models/kaku_seiga/kaku_seiga_and_ibaraki_kasen_ambient.vpcf", PATTACH_POINT_FOLLOW,self:GetCaster())
	    -- ParticleManager:SetParticleControlEnt(seiga_link,0,self:GetCaster(),PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_2") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_2") then
		caster:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_seigaEx_telent_2",{})
		local modifier = caster:FindModifierByName("modifier_ability_thdots_seigaEx_telent_2")
		modifier:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_2"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_3") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_3") then
		caster:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_seigaEx_telent_3",{})
		local modifier = caster:FindModifierByName("modifier_ability_thdots_seigaEx_telent_3")
		modifier:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_3"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_6") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_6") then
		caster:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_seigaEx_telent_6",{})
		local modifier = caster:FindModifierByName("modifier_ability_thdots_seigaEx_telent_6")
		modifier:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_6"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_7") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_7") then
		caster:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_seigaEx_telent_7",{})
		local modifier = caster:FindModifierByName("modifier_ability_thdots_seigaEx_telent_7")
		modifier:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_7"))
	end
end

modifier_ability_thdots_seigaEx_telent_2 = modifier_ability_thdots_seigaEx_telent_2 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_seigaEx_telent_2","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seigaEx_telent_2:IsHidden() 		return true end
function modifier_ability_thdots_seigaEx_telent_2:IsPurgable()		return false end
function modifier_ability_thdots_seigaEx_telent_2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seigaEx_telent_2:IsDebuff()		return false end

modifier_ability_thdots_seigaEx_telent_3 = modifier_ability_thdots_seigaEx_telent_3 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_seigaEx_telent_3","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seigaEx_telent_3:IsHidden() 		return true end
function modifier_ability_thdots_seigaEx_telent_3:IsPurgable()		return false end
function modifier_ability_thdots_seigaEx_telent_3:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seigaEx_telent_3:IsDebuff()		return false end

modifier_ability_thdots_seigaEx_telent_6 = modifier_ability_thdots_seigaEx_telent_6 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_seigaEx_telent_6","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seigaEx_telent_6:IsHidden() 		return true end
function modifier_ability_thdots_seigaEx_telent_6:IsPurgable()		return false end
function modifier_ability_thdots_seigaEx_telent_6:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seigaEx_telent_6:IsDebuff()		return false end

modifier_ability_thdots_seigaEx_telent_7 = modifier_ability_thdots_seigaEx_telent_7 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_seigaEx_telent_7","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seigaEx_telent_7:IsHidden() 		return true end
function modifier_ability_thdots_seigaEx_telent_7:IsPurgable()		return false end
function modifier_ability_thdots_seigaEx_telent_7:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seigaEx_telent_7:IsDebuff()		return false end



--------------------------------------------------------
--邪符「养小鬼」
--------------------------------------------------------
ability_thdots_seiga01 = {}

function ability_thdots_seiga01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_seiga01:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_6") then
		return self.BaseClass.GetBehavior(self)
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
end

function ability_thdots_seiga01:GetAOERadius()
	if not self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_6") then
		return 0
	else
		return self:GetSpecialValueFor("talent_radius")
	end
end

function ability_thdots_seiga01:CastFilterResultTarget(hTarget)
	if hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber()
	 or ( hTarget:IsTower() and hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() )then
		return
	else
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_seiga01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local talent_radius = self:GetSpecialValueFor("talent_radius")
	self.target_damage_bonus = self:GetSpecialValueFor("target_damage_bonus")
	self.caster_damage_bonus = self:GetSpecialValueFor("caster_damage_bonus")

	if not caster:HasModifier("modifier_ability_thdots_seigaEx_telent_6") then
		self.target = self:GetCursorTarget()

		if self.caster ~= self.target then
			self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_seiga01_target", {duration = duration})
		end
	else
		--天赋，对范围内所有单位释放
		local point = self:GetCursorPosition()
		local targets = FindUnitsInRadius(caster:GetTeam(), point, nil, talent_radius,
					self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),0,0,false)
		for _,ally in pairs(targets) do
			if ally ~= caster and ally:GetUnitName() ~= "npc_ability_parsee03_dummy" then
				ally:AddNewModifier(self.caster, self, "modifier_ability_thdots_seiga01_target", {duration = duration})
			end
		end
	end
	local modifier = self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_seiga01_caster", {duration = duration})
	self.telent_bonus = FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_1")
	self.caster:EmitSound("Voice_Thdots_Seiga.AbilitySeiga01_Cast")
	--特效音效
end

modifier_ability_thdots_seiga01_caster = {}
LinkLuaModifier("modifier_ability_thdots_seiga01_caster","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga01_caster:IsHidden() 		return false end
function modifier_ability_thdots_seiga01_caster:IsPurgable()		return true end
function modifier_ability_thdots_seiga01_caster:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seiga01_caster:IsDebuff()		return false end

function modifier_ability_thdots_seiga01_caster:OnCreated()
	if not IsServer() then return end
	self.parent = self:GetParent()

	local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_ambient.vpcf"
	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetAbsOrigin(), true)
end

function modifier_ability_thdots_seiga01_caster:OnDestroy()
	if not IsServer() then return end
	-- Remove the particle
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

function modifier_ability_thdots_seiga01_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_seiga01_caster:OnAttackLanded(keys)
	if not IsServer() then return end
	if not (keys.attacker == self:GetParent()) or keys.target:IsBuilding() then return end
	local target = keys.target
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.caster_damage_bonus = self.ability:GetSpecialValueFor("caster_damage_bonus") + self.ability.telent_bonus
	--self.attack_bonus = self.ability:GetSpecialValueFor("attack_bonus")
	local damage = self.caster_damage_bonus

	--if not self.caster:HasModifier("modifier_ability_thdots_seigaEx_telent_6") then
	--	local ally = self.ability.target
	--	damage = damage + ally:GetAverageTrueAttackDamage(ally) * self.attack_bonus
	--end

	target:EmitSound("Voice_Thdots_Seiga.AbilitySeiga01_AttackLanded")
	-- local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge.vpcf"
	-- local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_sprit_ti8_overload_discharge.vpcf"
	local particle	=	"particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_dmg_stroke_tgt.vpcf"
	local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, keys.target)
	ParticleManager:SetParticleControl(particle_fx, 0, keys.target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_fx, 3, keys.target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_fx)

	local damage_table = {
				ability = self.ability,
			    victim = target,
			    attacker = self.caster,
			    damage = damage,
			    damage_type = self.ability:GetAbilityDamageType(),
			}
	UnitDamageTarget(damage_table)
end


modifier_ability_thdots_seiga01_target = {}
LinkLuaModifier("modifier_ability_thdots_seiga01_target","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga01_target:IsHidden() 		return false end
function modifier_ability_thdots_seiga01_target:IsPurgable()		return true end
function modifier_ability_thdots_seiga01_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seiga01_target:IsDebuff()		return false end
function modifier_ability_thdots_seiga01_target:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.target_damage_bonus = self.ability:GetSpecialValueFor("target_damage_bonus")

	-- local particle	=	"particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf"
	-- local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_ambient.vpcf"
	local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_gold_ambient.vpcf"
	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetAbsOrigin(), true)
end

function modifier_ability_thdots_seiga01_target:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_seiga01_target:OnAttackLanded(keys)
	if not IsServer() then return end
	if not (keys.attacker == self:GetParent()) or keys.target:IsBuilding() then return end
	local target = keys.target

	target:EmitSound("Voice_Thdots_Seiga.AbilitySeiga01_AttackLanded")
	-- local particle	=	"particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf"
	-- local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge.vpcf"
	-- local particle	=	"particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_sprit_ti8_overload_discharge.vpcf"
	local particle	=	"particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_dmg_stroke_tgt.vpcf"
	local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, keys.target)
	ParticleManager:SetParticleControl(particle_fx, 0, keys.target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_fx, 3, keys.target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_fx)

	local damage_table = {
				ability = self.ability,
			    victim = target,
			    attacker = self.caster,
			    damage = self.target_damage_bonus + self.ability.telent_bonus,
			    damage_type = self.ability:GetAbilityDamageType(),
			}
	UnitDamageTarget(damage_table)
	if target and not target:IsNull() and FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_5") ~= 0 then
		local info = {
			Source = self:GetCaster(),
			Target = target,
			Ability = self.ability,
			bDodgeable = true,
			EffectName = "particles/units/heroes/hero_grimstroke/grimstroke_base_attack.vpcf",
			-- EffectName = "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net_projectile.vpcf",
			-- EffectName = "particles/units/heroes/hero_siren/siren_net_projectile.vpcf",
			iMoveSpeed = 1200--self:GetSpecialValueFor("projectile_speed"),
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end

function modifier_ability_thdots_seiga01_target:OnDestroy()
	if not IsServer() then return end
	-- Remove the particle
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

--天赋增加霍青娥攻击
function ability_thdots_seiga01:OnProjectileHit(hTarget, vLocation)
	if not hTarget then return end
	local caster = self:GetCaster()
	hTarget:EmitSound("Hero_Puck.ProjectileImpact")
	caster:PerformAttack(hTarget, true, true, true, true, false, false, false)
end


--------------------------------------------------------
--降灵「死人童乩」
--------------------------------------------------------
ability_thdots_seiga02 = {}

function ability_thdots_seiga02:CastFilterResultTarget(hTarget)
	if hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() and not hTarget:IsBuilding() then
		return
	else
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_seiga02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_seiga02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	--特效音效
	self.caster:EmitSound("Voice_Thdots_Seiga.AbilitySeiga02_Cast")
	self.target:EmitSound("Voice_Thdots_Seiga.AbilitySeiga02_Target")
	--火圈特效
	-- local cast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
	-- ParticleManager:SetParticleControl(cast_pfx, 0, target_loc)
	-- ParticleManager:SetParticleControl(cast_pfx, 1, Vector(effect_radius, 1, 1))
	-- ParticleManager:ReleaseParticleIndex(cast_pfx)

	
	self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_seiga02", {duration = duration})
	local modifier = self.target:FindModifierByName("modifier_ability_thdots_seiga02")
	modifier:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_1"))
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_4") ~= 0 then
		modifier.seiga02_telent = true
	end
end

modifier_ability_thdots_seiga02 = {}
LinkLuaModifier("modifier_ability_thdots_seiga02","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga02:IsHidden() 		return false end
function modifier_ability_thdots_seiga02:IsPurgable()		return true end
function modifier_ability_thdots_seiga02:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seiga02:IsDebuff()		return false end

function modifier_ability_thdots_seiga02:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.attack_speed_bonus = self.ability:GetSpecialValueFor("attack_speed_bonus")
	self.blink_range = self.ability:GetSpecialValueFor("blink_range")
	self.melee_percent = self.ability:GetSpecialValueFor("melee_percent")
	if not IsServer() then return end
	self.attack_intval = self.ability:GetSpecialValueFor("attack_intval")
	-- local particle	=	"particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
	local particle	=	"particles/units/heroes/hero_grimstroke/grimstroke_soulchain_marker.vpcf"
	-- self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
	-- ParticleManager:SetParticleControl(self.particle_fx, 0, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(self.particle_fx, 3, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(self.particle_fx, 4, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(self.particle_fx, 5, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,0,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,3,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,4,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,5,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)

end

function modifier_ability_thdots_seiga02:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

function modifier_ability_thdots_seiga02:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER,
		-- MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end


function modifier_ability_thdots_seiga02:OnAttackStart(keys)
	if not IsServer() then return end
	--近战加攻击距离，攻击开始直接瞬移过去。
	if keys.attacker ~= self:GetParent() or keys.attacker:IsRangedAttacker() or keys.attacker:IsRooted() then return end
	local target = keys.target
	local attacker = keys.attacker
	local vecMove = target:GetOrigin() + (attacker:GetOrigin() - target:GetOrigin()):Normalized() * 150

	-- local particle_name = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_slash_trail_ground_rope.vpcf"
	local particle_name = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail_bladekeeper.vpcf"
	-- local particle_name = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf"
	local trail_pfx1 = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN,self.parent)
	ParticleManager:SetParticleControl(trail_pfx1, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(trail_pfx1, 1, target:GetOrigin())
	-- ParticleManager:SetParticleControl(trail_pfx1, 2, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(trail_pfx1)
	local distance = (target:GetOrigin() - attacker:GetOrigin()):Length2D()
	-- if distance <= self.blink_range and not attacker:HasModifier("modifier_ability_thdots_seiga02_intval") then
	if not attacker:HasModifier("modifier_ability_thdots_seiga02_intval") then
		attacker:SetOrigin(vecMove)
		FindClearSpaceForUnit(attacker, vecMove, true)
		attacker:AddNewModifier(attacker, self.ability, "modifier_ability_thdots_seiga02_intval",{duration = self.attack_intval})
	end
end

function modifier_ability_thdots_seiga02:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker == self.parent and self.seiga02_telent == true then
		self.seiga02_telent = false
		--天赋眩晕
		local telent_stun_time = FindTelentValue(self:GetCaster(),"special_bonus_unique_seiga_4")
		UtilStun:UnitStunTarget(self.caster,keys.target,telent_stun_time)
	end
end

-- function modifier_ability_thdots_seiga02:OnOrder(kv)
-- 	if not IsServer() then return end
-- 	if kv.unit == self:GetParent() and not kv.unit:IsRangedAttacker() then
-- 	end
-- end

function modifier_ability_thdots_seiga02:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() or self:GetParent():HasModifier("modifier_ability_thdots_seiga02_intval") 
		or self:GetParent():IsRooted() then
		return 0
	else
		return self.blink_range - self:GetParent():GetBaseAttackRange()
	end
end
--[[function modifier_ability_thdots_seiga02:OnAttackStart(keys)
	if not IsServer() then return end
	if(keys.attacker:HasModifier("modifier_ability_thdots_seiga02_buff")) then
		keys.attacker:RemoveModifierByName("modifier_ability_thdots_seiga02_buff")
	end

end
function modifier_ability_thdots_seiga02:OnOrder(keys)
 	if not IsServer() then return end
	local caster = self:GetParent()
	if(keys.unit:IsRangedAttacker() or keys.unit ~= self:GetParent() or keys.unit:IsDisarmed()) then return end
 	if(keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET) then
		if keys.target:GetTeam()== caster:GetTeam() then return end
		local distance = (keys.target:GetOrigin() - keys.unit:GetOrigin()):Length2D()
		--print(distance)
		if(not keys.unit:HasModifier("modifier_ability_thdots_seiga02_buff") 
		and not keys.unit:HasModifier("modifier_ability_thdots_seiga02_intval") 
		and distance <= self.blink_range) then
			
			-- local particle_name = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_slash_trail_ground_rope.vpcf"
			-- local particle_name = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail_bladekeeper.vpcf"
			-- local particle_name = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf"
			-- self.trail_pfx1 = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN,self.parent)
			--ParticleManager:SetParticleControl(trail_pfx1, 0, self.parent:GetOrigin())
			--ParticleManager:SetParticleControl(trail_pfx1, 1, target:GetOrigin())
			-- ParticleManager:SetParticleControl(trail_pfx1, 2, target:GetOrigin())
			--ParticleManager:ReleaseParticleIndex(trail_pfx1)
			keys.unit:AddNewModifier(keys.unit,self.ability,"modifier_ability_thdots_seiga02_buff",{duration=6})
			keys.unit:AddNewModifier(keys.unit, self.ability, "modifier_ability_thdots_seiga02_intval",{duration = self.attack_intval})
		end
 	end
end
function modifier_ability_thdots_seiga02:OnUnitMoved(keys)
	if not IsServer() then return end
	if (keys.unit == self.parent and keys.unit:HasModifier("modifier_ability_thdots_seiga02_buff")) then
		local particle_name = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail_bladekeeper.vpcf"
		local trail_pfx1 = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN,self.parent)
		ParticleManager:SetParticleControl(trail_pfx1, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControl(trail_pfx1, 1, keys.new_pos)
		ParticleManager:SetParticleControl(trail_pfx1, 2, keys.new_pos)
		ParticleManager:ReleaseParticleIndex(trail_pfx1)
	end
end]]--

function modifier_ability_thdots_seiga02:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():IsRangedAttacker() then
		return self.attack_speed_bonus 
	else
		return self.attack_speed_bonus * self.melee_percent/100
	end
end
--modifier 名字: 英雄buff 加速
modifier_ability_thdots_seiga02_buff=class({})
LinkLuaModifier("modifier_ability_thdots_seiga02_buff","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_seiga02_buff:IsHidden()         return false end
function modifier_ability_thdots_seiga02_buff:IsPurgable()       return false end
function modifier_ability_thdots_seiga02_buff:RemoveOnDeath()    return true end
function modifier_ability_thdots_seiga02_buff:IsDebuff()     return false end

--modifier 修改列表
function modifier_ability_thdots_seiga02_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_EVENT_ON_ORDER,
    }
    return funcs
end

--提供相位
function modifier_ability_thdots_seiga02_buff:CheckState()
    local state = {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    -- if self:GetCaster():HasModifier("modifier_item_wanbaochui") then 
    --     state = {
    --         [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    --         [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    --         }
    -- end

    return state
end

--modifier 修改函数
function modifier_ability_thdots_seiga02_buff:GetModifierMoveSpeed_Absolute()
    --if not IsServer() then return end
    return self:GetAbility():GetSpecialValueFor("speed")
end

--modifier 触发事件：任何命令
function modifier_ability_thdots_seiga02_buff:OnOrder(keys)
    if not IsServer() then return end

    local caster=self:GetParent()
    local ability=self:GetAbility()
	if(keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET) then
		if keys.target:GetTeam()== caster:GetTeam() then return end
		local distance = (keys.target:GetOrigin() - keys.unit:GetOrigin()):Length2D()

		if( distance <= ability.blink_range) then return end
	end
    if keys.unit==caster then 
        --消除加速buff
        if caster:HasModifier("modifier_ability_thdots_seiga02_buff") then
            --caster:RemoveModifierByName("modifier_bloodseeker_thirst")
            caster:RemoveModifierByName("modifier_ability_thdots_seiga02_buff")
        end
    end
end

--modifier 消失事件
function modifier_ability_thdots_seiga02_buff:OnDestroy()
    if not IsServer() then return end
    local ability=self:GetAbility()
    --删除特效，停止音效
    --ParticleManager:DestroyParticle(ability.particle,true) 
    --StopSoundOn("Ability.Windrun",ability.owner)
end

modifier_ability_thdots_seiga02_intval = {}
LinkLuaModifier("modifier_ability_thdots_seiga02_intval","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga02_intval:IsHidden() 		return true end

--------------------------------------------------------
--入魔「走火入魔」
--------------------------------------------------------
ability_thdots_seiga03 = {}

-- 天赋减冷却
-- function ability_thdots_seiga03:GetCooldown(level)
-- 	if self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_2") then
-- 		return self.BaseClass.GetCooldown(self, level) - 6
-- 	else
-- 		return self.BaseClass.GetCooldown(self, level)
-- 	end
-- end


function ability_thdots_seiga03:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_seiga03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_seiga03_debuff", {duration = duration * (1 - self.target:GetStatusResistance())})

	--特效音效
	self.caster:EmitSound("Voice_Thdots_Seiga.AbilitySeiga03_Cast")
	self.target:EmitSound("Voice_Thdots_Seiga.AbilitySeiga03_Target")
end

modifier_ability_thdots_seiga03_debuff = {}
LinkLuaModifier("modifier_ability_thdots_seiga03_debuff","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga03_debuff:IsHidden() 		return false end
function modifier_ability_thdots_seiga03_debuff:IsPurgable()		return true end
function modifier_ability_thdots_seiga03_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seiga03_debuff:IsDebuff()		return true end
function modifier_ability_thdots_seiga03_debuff:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.damage_decrease = self.ability:GetSpecialValueFor("damage_decrease")
	if not IsServer() then return end
	--特效音效
	self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	self.parent = self:GetParent()
	-- local particle = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf"
	-- self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
	-- -- ParticleManager:SetParticleControl(self.particle_fx, 0, self.parent:GetAbsOrigin())
	-- -- ParticleManager:SetParticleControl(self.particle_fx, 1, self.parent:GetAbsOrigin())
	-- -- ParticleManager:SetParticleControl(self.particle_fx, 2, self.parent:GetAbsOrigin())
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,0,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,1,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,2,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)

end

function modifier_ability_thdots_seiga03_debuff:GetEffectName() return "particles/units/heroes/hero_bane/bane_enfeeble.vpcf" end
function modifier_ability_thdots_seiga03_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end


function modifier_ability_thdots_seiga03_debuff:OnDestroy()
	if not IsServer() then return end
	-- ParticleManager:DestroyParticle(self.particle_fx, false)
	-- ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

function modifier_ability_thdots_seiga03_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_ability_thdots_seiga03_debuff:GetModifierDamageOutgoing_Percentage()
	return -self.damage_decrease
end

function modifier_ability_thdots_seiga03_debuff:OnAbilityExecuted(keys)
	if not IsServer() then return end
	local target = self:GetParent()

	if keys.unit ~= target or keys.ability:IsItem() then return end
	--特效音效
	local particle = "particles/units/heroes/hero_grimstroke/grimstroke_sfm_ink_swell_reveal.vpcf"
	local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
	ParticleManager:SetParticleControl(particle_fx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_fx, 1, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_fx)
	self.parent:EmitSound("Voice_Thdots_Seiga.AbilitySeiga03_Target_Stun")
	-- ParticleManager:SetParticleControl(self.particle_fx, 2, self.parent:GetAbsOrigin())
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,0,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,1,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(self.particle_fx,2,self.parent,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)

	local damage_table = {
				ability = self.ability,
			    victim = target,
			    attacker = self.caster,
			    damage = self.damage,
			    damage_type = self.ability:GetAbilityDamageType(), 
			}
	UtilStun:UnitStunTarget(self.caster,target,self.stun_duration)
	UnitDamageTarget(damage_table)
end

--------------------------------------------------------
--通灵「通灵芳香」
--------------------------------------------------------
ability_thdots_seiga04 = {}

function ability_thdots_seiga04:CastFilterResultTarget(hTarget)
	if hTarget:IsHero() and hTarget ~= self:GetCaster() and hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() 
		and not hTarget:HasModifier("modifier_koishi04_bonus")
		and not hTarget:HasModifier("modifier_thdots_medicine04_debuff") then
		return
	else
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_seiga04:GetIntrinsicModifierName()
    return "modifier_ability_thdots_seiga04_charge"
end

function ability_thdots_seiga04:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

-- function ability_thdots_seiga04:GetAOERadius()
-- 	if self:GetCaster():HasModifier("modifier_ability_thdots_lettyEx_talent_1") then
-- 		return self:GetSpecialValueFor("radius") + 200
-- 	else
-- 		return self:GetSpecialValueFor("radius")
-- 	end
-- end

function ability_thdots_seiga04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.caster = caster
	self.target = self:GetCursorTarget()
	self.frametime = 0
	self.duration = self:GetSpecialValueFor("duration")
	local charge = caster:FindModifierByName("modifier_ability_thdots_seiga04_charge")
	
	-- local particle = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall.vpcf"
	local particle = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_cyclone.vpcf"
	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.target)
	-- ParticleManager:SetParticleControl(self.particle_fx, 0, self.target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle_fx,0,self.target,PATTACH_ROOTBONE_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	self.caster:EmitSound("Voice_Thdots_Seiga.AbilitySeiga04_Target")
	self.target:EmitSound("Voice_Thdots_Seiga.AbilitySeiga04_Target")

	-- self.freezing_field_aura = CreateModifierThinker(caster, self, "modifier_ability_thdots_seiga04", {duration = duration}, self.point, caster:GetTeamNumber(), false)
	-- self.freezing_field_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_CUSTOMORIGIN, self.freezing_field_aura)

	-- ParticleManager:SetParticleControl(self.freezing_field_particle, 0, self.point)
	-- ParticleManager:SetParticleControl(self.freezing_field_particle, 1, Vector (self.radius, 0, 0))
	-- ParticleManager:SetParticleControl(self.freezing_field_particle, 5, Vector (self.radius, 0, 0))
	-- caster:EmitSound("hero_Crystal.freezingField.wind")

	--万宝槌 充能：刷新技能
    if charge:GetStackCount() > 0 then 
        charge:SetStackCount(charge:GetStackCount()-1)
        self:EndCooldown()
    end
end

function ability_thdots_seiga04:OnChannelThink()
	if not IsServer() then return end
	self.frametime = self.frametime + FrameTime()
	if self.frametime >= self.duration then
		self:EndChannel(false)
	end
end

function ability_thdots_seiga04:OnChannelFinish()
	if not IsServer() then return end
	--删除特效
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)

	if self.frametime >= self.duration then
		local vecMove = self.caster:GetOrigin() + (self.target:GetOrigin() - self.caster:GetOrigin()):Normalized() * 150
		StartSoundEventFromPosition("Voice_Thdots_Seiga.AbilitySeiga04_Target_Swap",self.target:GetOrigin())
		FindClearSpaceForUnit(self.target, vecMove, true)
		--特效音效
		--这是带轨迹的VS换特效
		-- local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, self.target)
		-- ParticleManager:SetParticleControlEnt(caster_pfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		--这是小精灵开大传送的特效
		local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_ABSORIGIN, self.target)
		ParticleManager:SetParticleControl(self.particle_fx, 0, self.target:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle_fx, 1, self.target:GetAbsOrigin())

	end
	self.caster:StopSound("Voice_Thdots_Seiga.AbilitySeiga04_Target")
	self.target:StopSound("Voice_Thdots_Seiga.AbilitySeiga04_Target")
	-- ParticleManager:DestroyParticle(self.freezing_field_particle, false)
	-- ParticleManager:ReleaseParticleIndex(self.freezing_field_particle)
end

--modifier 名字：充能

modifier_ability_thdots_seiga04_charge=class({})
LinkLuaModifier("modifier_ability_thdots_seiga04_charge","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_seiga04_charge:IsHidden()
    if self:GetCaster():HasModifier("modifier_ability_thdots_seigaEx_telent_3") then
        return false
    end

    return true;
end

function modifier_ability_thdots_seiga04_charge:IsPurgable()       return false end
function modifier_ability_thdots_seiga04_charge:RemoveOnDeath()    return false end
function modifier_ability_thdots_seiga04_charge:IsDebuff()     return false end

function modifier_ability_thdots_seiga04_charge:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_seiga04_charge:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
end

function modifier_ability_thdots_seiga04_charge:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local charge = ability:GetSpecialValueFor("telent_charge")

    if self:IsHidden() == false then 
        if not caster:HasModifier("modifier_ability_thdots_seiga04_charge_think") and self:GetStackCount() < charge then 
            caster:AddNewModifier(caster, ability, "modifier_ability_thdots_seiga04_charge_think", {duration = ability:GetCooldown(ability:GetLevel()-1)})
            local duration = ability:GetCooldown(ability:GetLevel()-1)
        end

        if self:GetStackCount() > 0 and ability:GetCooldownTimeRemaining() > 0 then
            self:SetStackCount(self:GetStackCount()-1)
            ability:EndCooldown()
        end

    elseif self:IsHidden() and caster:HasModifier("modifier_ability_thdots_seiga04_charge_think") then 
        caster:RemoveModifierByName("modifier_ability_thdots_seiga04_charge_think")
        self:SetStackCount(0)
    end

end

--modifier 名字：充能计时
modifier_ability_thdots_seiga04_charge_think=class({})
LinkLuaModifier("modifier_ability_thdots_seiga04_charge_think","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_seiga04_charge_think:IsHidden() return false end
function modifier_ability_thdots_seiga04_charge_think:IsPurgable()       return false end
function modifier_ability_thdots_seiga04_charge_think:RemoveOnDeath()    return false end
function modifier_ability_thdots_seiga04_charge_think:IsDebuff()     return false end

function modifier_ability_thdots_seiga04_charge_think:OnDestroy()
    if not IsServer() then return end

    local parentModifier = self:GetCaster():FindModifierByName("modifier_ability_thdots_seiga04_charge")
    local stack = parentModifier:GetStackCount()
    parentModifier:SetStackCount(stack + 1)
end


--------------------------------------------------------
--仙术「Wall Runner」
--------------------------------------------------------
ability_thdots_seiga05 = {}

function ability_thdots_seiga05:GetIntrinsicModifierName()
	return "modifier_ability_thdots_seiga05_caster"
end

function ability_thdots_seiga05:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			local illusion = FindUnitsInRadius(self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,99999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_BASIC+ DOTA_UNIT_TARGET_HERO,0,0,false)
			for _,v in pairs(illusion) do
				if v:HasModifier("modifier_ability_thdots_seiga05_target") then
					v:ForceKill(true)
				end
			end
			self:SetHidden(true)
		end
	end
end

function ability_thdots_seiga05:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_seiga05:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

-- function ability_thdots_seiga05:OnSpellStart()
-- 	if not IsServer() then return end
-- 	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_seiga05_caster", {duration = 10})
-- end

modifier_ability_thdots_seiga05_caster = {}
LinkLuaModifier("modifier_ability_thdots_seiga05_caster","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga05_caster:IsHidden()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
        return false
    end

    return true;
end
function modifier_ability_thdots_seiga05_caster:IsPurgable()		return false end
function modifier_ability_thdots_seiga05_caster:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seiga05_caster:IsDebuff()		return false end
function modifier_ability_thdots_seiga05_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_ability_thdots_seiga05_caster:OnDeath(keys)
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.ability.caster = self.caster
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local illusion_outgoing_damage = self:GetAbility():GetSpecialValueFor("illusion_outgoing_damage")
	local distance = (self.caster:GetOrigin() - keys.unit:GetOrigin()):Length2D()
	if self.caster:IsAlive() and self.caster:IsRealHero() and keys.unit:IsRealHero() and self.caster:HasModifier("modifier_item_wanbaochui") and distance <= radius then
		--范围内英雄死亡制造幻象
		keys.unit:SetContextThink("HasAegis",
			function()
				if GameRules:IsGamePaused() then return 0.03 end
				if keys.unit:GetTimeUntilRespawn() > 5 then
					self.ability.target = keys.unit
					self.illusion = create_illusion(self.ability,self.ability.target:GetAbsOrigin(),0,illusion_outgoing_damage,duration)
					self.illusion:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_seiga05_target", {duration = duration})	
					FindClearSpaceForUnit(self.illusion,self.illusion:GetOrigin(),true)
					-- local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
					-- ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
					-- ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
					-- ParticleManager:ReleaseParticleIndex(effectIndex)
					-- caster:EmitSound("DOTA_Item.Hand_Of_Midas")
				end
			end
		,FrameTime())
	end
end

modifier_ability_thdots_seiga05_target = {}
LinkLuaModifier("modifier_ability_thdots_seiga05_target","scripts/vscripts/abilities/abilityseiga.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seiga05_target:IsHidden() 		return false end
function modifier_ability_thdots_seiga05_target:IsPurgable()		return false end
function modifier_ability_thdots_seiga05_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seiga05_target:IsDebuff()		return false end

function modifier_ability_thdots_seiga05_target:CheckState()
	return{
		[MODIFIER_STATE_MAGIC_IMMUNE] = false,
	}
end

function modifier_ability_thdots_seiga05_target:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_thdots_seiga05_target:OnCreated()
	self.illusion_speed_bonus = self:GetAbility():GetSpecialValueFor("illusion_speed_bonus")
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.attacked_limit = self:GetAbility():GetSpecialValueFor("attacked_limit")
	self:SetStackCount(self.attacked_limit)
	local particle	=	"particles/units/heroes/hero_grimstroke/grimstroke_ink_over_debuff.vpcf"
	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.parent)
	self.parent:EmitSound("Voice_Thdots_Seiga.AbilitySeiga05_Target")
	-- self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)

	-- ParticleManager:SetParticleControl(self.particle_fx, 0, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(self.particle_fx, 1, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(self.particle_fx, 3, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(self.particle_fx, 4, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(self.particle_fx,0,self.parent,PATTACH_OVERHEAD_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(self.particle_fx,1,self.parent,PATTACH_OVERHEAD_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(self.particle_fx,3,self.parent,PATTACH_OVERHEAD_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(self.particle_fx,4,self.parent,PATTACH_OVERHEAD_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	
end


function modifier_ability_thdots_seiga05_target:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

function modifier_ability_thdots_seiga05_target:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.target == self.parent and keys.attacker:GetTeamNumber() ~= keys.target:GetTeamNumber() and 
		(keys.attacker:IsHero() or keys.attacker:IsBuilding()) then
		print(keys.attacker:GetUnitName())
		self:DecrementStackCount()
		local health = self.parent:GetBaseMaxHealth() * self:GetStackCount() / self.attacked_limit
		if self:GetStackCount() <= 0 then
			self.parent:Kill(keys.ability, keys.attacker)
		else
			self.parent:SetHealth(health)
		end
	end
end

function modifier_ability_thdots_seiga05_target:GetModifierMoveSpeedBonus_Constant()
	return self.illusion_speed_bonus
end
function modifier_ability_thdots_seiga05_target:GetModifierIncomingDamage_Percentage()
	return -999
end


function create_illusion(self, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = self.caster:GetPlayerID()
	local caster_team = self.caster:GetTeam()
	local tmp = self.caster

	local illusion = CreateUnitByName(self.target:GetUnitName(), illusion_origin, true, self.caster, tmp, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	local caster_level = self.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = self.target:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = self.target:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
			illusion_duplicate_item:SetPurchaser(nil)
		end
	end
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
		illusion:AddNewModifier(self.caster, self, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
		illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.
		return illusion
end
