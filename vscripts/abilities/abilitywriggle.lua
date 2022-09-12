--function OnWriggle01Start(keys)
--	local caster = keys.caster
--	local unit = CreateUnitByName(
--		"npc_vision_dummy_unit"
--		,caster:GetOrigin()
--		,false
--		,caster
--		,caster
--		,caster:GetTeam()
--	)

--	unit:SetDayTimeVisionRange(keys.Vision)
--	unit:SetNightTimeVisionRange(keys.Vision)
--	if FindTelentValue(caster,"special_bonus_unique_wriggle_3") ~= 0 then
--		local abilityGEM = unit:FindAbilityByName("ability_thdots_wriggle_talent_unit")
--		if abilityGEM ~= nil then
--			abilityGEM:SetLevel(1)
--			unit:CastAbilityImmediately(abilityGEM, 0)
--		end
--	end
	
--	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_prison_top_orb.vpcf", PATTACH_CUSTOMORIGIN, caster) 
--	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)

--	Timer.Loop 'ability_wriggle_01_vision' (0.1, keys.Duration * 10,
--			function(i)
--				unit:SetOrigin(caster:GetOrigin())
--				if i == keys.Duration * 10 then
--					unit:RemoveSelf()
--					if caster:HasItemInInventory("item_gem") == false then
--						caster:RemoveModifierByName("modifier_item_gem_of_true_sight")
--					end
--					ParticleManager:DestroyParticleSystem(effectIndex,true)
--					return true
--				end
--			end
--	)
--end

function OnWriggle03AttackLanded(keys)
	local caster = keys.caster
	
	if keys.ability:IsCooldownReady() then

		local caster = EntIndexToHScript(keys.caster_entindex)
		local target = keys.target
		if target == nil then
			return
		end

		caster:PerformAttack(target, false, true, true, true, true, false, false)
		local projectileTable = {
			Target = target,
			Source = caster,
			Ability = keys.ability,	
			EffectName = "particles/units/heroes/hero_weaver/weaver_base_attack.vpcf",
			iMoveSpeed = 1500,
			vSourceLoc= caster:GetAbsOrigin(),
			bDrawsOnMinimap = false, 
		    bDodgeable = true,
		    bIsAttack = false, 
		    bVisibleToEnemies = true,
		    bReplaceExisting = false,
		    flExpireTime = GameRules:GetGameTime() + 10,
			bProvidesVision = true,
			iVisionRadius = 100,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = 1
		} 
		ProjectileManager:CreateTrackingProjectile(projectileTable)
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1))
		local cd_len = keys.ability:GetCooldown(keys.ability:GetLevel() - 1)
		if caster:HasModifier("modifier_cooldown_reduction_15") then
			cd_len = cd_len * 0.85;
		elseif caster:HasModifier("modifier_item_nuclear_stick_cooldown_reduction") then
			cd_len = cd_len * 0.75;
		end
		keys.ability:StartCooldown(cd_len)
		THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_wriggle_1"))
	end
end

function OnWriggle03ProjectileHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local DamageTable = {
			ability = keys.ability,
			victim = target, 
			attacker = caster, 
			damage = keys.BaseDamage,
			damage_type = keys.ability:GetAbilityDamageType(),
			damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UtilSilence:UnitSilenceTarget( caster,target,keys.SilenceDuration)
	UnitDamageTarget(DamageTable)
end

function OnWriggle04AttackStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local effectIndex = ParticleManager:CreateParticle("particles/econ/courier/courier_master_chocobo/courier_master_chocobo_ambient_death_b.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_wriggle04_noinvisible", {} )
	caster:RemoveModifierByName("modifier_wriggle04_invisible")
end

function OnWriggle04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local effectIndex = ParticleManager:CreateParticle("particles/econ/courier/courier_master_chocobo/courier_master_chocobo_ambient_death_b.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_wriggle04_noinvisible", {} )
	caster:RemoveModifierByName("modifier_wriggle04_invisible")
end

function OnWriggle04Order(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if caster:HasModifier("modifier_wriggle04_noinvisible") == false then
		keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_wriggle04_invisible", {} )
	end
	if caster:FindAbilityByName("special_bonus_unique_wriggle_2"):GetLevel() ~= 0 
		and not caster:HasModifier("wriggle_talent_modifier_spell_amplify_40") then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "wriggle_talent_modifier_spell_amplify_40", {})
	end
end


function wriggle_wanbaochui(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = FindUnitsInRadius(
				caster:GetTeam(),		
				caster:GetOrigin(),		
				nil,					
				keys.Radius,		
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO,
				0, FIND_CLOSEST,
				false
	)
	local count = 0
	for k,v in pairs(targets) do
		if v:HasModifier("modifier_illusion")==false then
			count = count + 1
		end
	end
	if caster:HasModifier("modifier_item_wanbaochui") then
		if count == 0 then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "wriggle_wanbaochui_buff", {} )
			caster:RemoveModifierByName("wriggle_wanbaochui_buff_2")
		else
			keys.ability:ApplyDataDrivenModifier(caster, caster, "wriggle_wanbaochui_buff_2", {} )
			caster:RemoveModifierByName("wriggle_wanbaochui_buff")
        end
	else
		caster:RemoveModifierByName("wriggle_wanbaochui_buff")
		caster:RemoveModifierByName("wriggle_wanbaochui_buff_2")
	end
end

ability_thdots_wriggle01 = {}

function ability_thdots_wriggle01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	if FindTelentValue(caster,"special_bonus_unique_wriggle_3") ~= 0 then
		local ability = caster:AddAbility("ability_thdots_wriggle01_special")
		ability:SetLevel(self:GetLevel())
		caster:CastAbilityImmediately(ability,caster:GetPlayerID())
		ability:SetHidden(true)
		return
    end
	caster:AddNewModifier(caster,self,"modifier_item_gem_of_true_sight",{duration = duration})
	caster:AddNewModifier(caster,self,"modifier_wriggle_check",{duration = duration})
end

ability_thdots_wriggle01_special = {}

function ability_thdots_wriggle01_special:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	caster:AddNewModifier(caster,self,"modifier_item_gem_of_true_sight",{duration = duration})
	caster:AddNewModifier(caster,self,"modifier_wriggle_check",{duration = duration})
end

modifier_wriggle_check = {}
LinkLuaModifier("modifier_wriggle_check","scripts/vscripts/abilities/abilitywriggle.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_wriggle_check:IsHidden() return false end
function modifier_wriggle_check:IsPurgable() return false end
function modifier_wriggle_check:IsDebuff() return false end
function modifier_wriggle_check:RemoveOnDeath() return true end

function modifier_wriggle_check:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.03)
    local caster = self:GetCaster()
	self.effectIndex = ParticleManager:CreateParticle("particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_prison_top_orb.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControlEnt(self.effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	self.vision = self:GetAbility():GetSpecialValueFor("vision")
end
 
function modifier_wriggle_check:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	AddFOWViewer(caster:GetTeam(),caster:GetAbsOrigin(),self.vision,0.03,false)
end

function modifier_wriggle_check:OnRemoved()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:HasItemInInventory("item_gem") == false then
		caster:RemoveModifierByName("modifier_item_gem_of_true_sight")
	end
	ParticleManager:DestroyParticleSystem(self.effectIndex,true)
	if self:GetAbility():GetAbilityName() ~= "ability_thdots_wriggle01_special" then return end
	self:GetCaster():RemoveAbility("ability_thdots_wriggle01_special")
end