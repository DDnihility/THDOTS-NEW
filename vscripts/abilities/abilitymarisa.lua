if AbilityMarisa == nil then
	AbilityMarisa = class({})
end

function OnMarisa01SpellStart(keys)
	AbilityMarisa:OnMarisa01Start(keys)
end

function OnMarisa01SpellMove(keys)
	AbilityMarisa:OnMarisa01Move(keys)
end

ability_thdots_marisa02 = {}

function ability_thdots_marisa02:OnSpellStart(keys)
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	self.duration = self:GetSpecialValueFor("damage_duration")
	self.radius = self:GetSpecialValueFor("damage_radius")
	self.damage = self:GetAbilityDamage() + FindTelentValue(self.caster, "special_bonus_unique_marisa_3")

	self.caster:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target")

	self:SetContextNum("ability_marisa02_point_x", self.point.x, 0)
	self:SetContextNum("ability_marisa02_point_y", self.point.y, 0)
	self:SetContextNum("ability_marisa02_point_z", self.point.z, 0)
	local unit = CreateUnitByName(
		"npc_dummy_unit"
		,self.caster:GetOrigin()
		,false
		,self.caster
		,self.caster
		,self.caster:GetTeam()
	)
	self:SetContextNum("ability_marisa02_effectUnit", unit:GetEntityIndex(), 0)

	unit:SetContextThink("ability_marisa02_effect_remove", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
			return nil
		end, 
	1) 

	self.caster:AddNewModifier(self.caster, self, "modifier_thdots_marisa02_think_interval", {duration = self.duration})
end

function ability_thdots_marisa02:OnChannelFinish(interrupted)
	self.caster:RemoveModifierByName("modifier_thdots_marisa02_think_interval")
end

modifier_thdots_marisa02_think_interval = {}
LinkLuaModifier("modifier_thdots_marisa02_think_interval", "scripts/vscripts/abilities/abilitymarisa.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_marisa02_think_interval:IsHidden() 		return true end
function modifier_thdots_marisa02_think_interval:IsPurgable()		return false end
function modifier_thdots_marisa02_think_interval:RemoveOnDeath() 	return true end
function modifier_thdots_marisa02_think_interval:IsDebuff()		return false end

function modifier_thdots_marisa02_think_interval:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.078)
end

function modifier_thdots_marisa02_think_interval:OnIntervalThink()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(ability:GetContext("ability_marisa02_point_x"), ability:GetContext("ability_marisa02_point_y"), ability:GetContext("ability_marisa02_point_z"))
	local targets = FindUnitsInRadius(
		caster:GetTeam(),		--caster team
		vecCaster,		            --find position
		nil,					    --find entity
		ability.radius,		        --find radius
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		ability:GetAbilityTargetType(),
		0, FIND_CLOSEST,
		false
	)
	
	local unit = EntIndexToHScript(ability:GetContext("ability_marisa02_effectUnit"))
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_02_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
	local vecForward = Vector(500 * caster:GetForwardVector().x, 500 * caster:GetForwardVector().y, caster:GetForwardVector().z)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin() + caster:GetForwardVector() * 100)
	ParticleManager:SetParticleControl(effectIndex, 3, vecForward)
	ParticleManager:DestroyParticleSystem(effectIndex, false)
	
	for _,v in pairs(targets) do
		local vVec = v:GetOrigin()
		local vecRad = GetRadBetweenTwoVec2D(targetPoint, vecCaster)
		local vDistance = GetDistanceBetweenTwoVec2D(vVec, vecCaster)

		if IsPointInCircularSector(vVec.x, vVec.y, math.cos(vecRad), math.sin(vecRad), ability.radius, math.pi / 3, vecCaster.x, vecCaster.y) then
			local deal_damage = ability.damage / 5
			if vDistance < 400 then
				deal_damage = deal_damage *2
			end
			local damage_table = {
				ability = ability,
				victim = v,
				attacker = caster,
				damage = deal_damage,
				damage_type = ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
		end
	end
end

function OnMarisa02SpellDamage(keys)
	AbilityMarisa:OnMarisa02Damage(keys)
end
function OnMarisa02SpellRemove(keys)
	--[[local caster = EntIndexToHScript(keys.caster_entindex)
	local unitIndex = keys.ability:GetContext("ability_marisa02_effectUnit")
	local unit = EntIndexToHScript(unitIndex)
	if(unit~=nil)then
		Timer.Wait 'ability_marisa02_effectUnit_release' (0.5,
			function()
				if(unit~=nil)then
					unit:RemoveSelf()
				end
			end
	    )
	end]]--
end

function OnMarisa03SpellStart(keys)
	AbilityMarisa:OnMarisa03Start(keys)
end

function OnMarisa03SpellThink(keys)
	AbilityMarisa:OnMarisa03Think(keys)
end

function OnMarisa03DealDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local dealdamage
	if keys.unit:IsBuilding() then
		dealdamage = keys.DealDamage * keys.ability:GetSpecialValueFor("building_percent")/100
		if caster:HasModifier("modifier_ability_marisa03_special_bonus") then 
			dealdamage = dealdamage /2;
		end
	else
		dealdamage = keys.DealDamage
	end
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster.hero,
		damage = dealdamage, --* (1+FindTelentValue(caster.hero,"special_bonus_unique_marisa_1")),
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(damage_table) 
end

ability_thdots_marisa04 = {}

function ability_thdots_marisa04:GetIntrinsicModifierName()
	return "modifier_ability_thdots_marisa04_passive"
end

function ability_thdots_marisa04:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self, level)
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_marisa_2")
	if telent ~= nil then
		cd = cd + telent:GetSpecialValueFor("value")
	end
	return cd
end

function ability_thdots_marisa04:OnSpellStart()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	self.duration = self:GetSpecialValueFor("duration")
	self.damage_width = self:GetSpecialValueFor("damage_width")
	self.damage_length = self:GetSpecialValueFor("damage_lenth")-100

	self.caster:EmitSound("Voice_Thdots_Marisa.AbilityMarisa04")

	local marisaEx_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_windrun_beam.vpcf", PATTACH_OVERHEAD_FOLLOW, self.caster)
	ParticleManager:ReleaseParticleIndex(marisaEx_particle)
	
	local unit = CreateUnitByName(
		"npc_dota2x_unit_marisa04_spark"
		,self.caster:GetOrigin()
		,false
		,self.caster
		,self.caster
		,self.caster:GetTeam()
	)
	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	
	self.effectcircle = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_04_spark_circle.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:DestroyParticleSystem(self.effectcircle,false)
	self.effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:DestroyParticleSystem(self.effectIndex,false)
	self.effectIndex_b = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark_wind_b.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:DestroyParticleSystem(self.effectIndex_b,false)
	self:SetContextNum("ability_marisa_04_spark_unit",unit:GetEntityIndex(),0)

	MarisaSparkParticleControl(self.caster, self.point, self)
	-- self:SetContextNum("ability_marisa_04_spark_lock",FALSE,0)
	self.caster:AddNewModifier(self.caster, self, "modifier_thdots_marisa04_think_interval", {duration = self.duration})
end

function ability_thdots_marisa04:OnChannelFinish(interrupted)
	self.caster:RemoveModifierByName("modifier_thdots_marisa04_think_interval")
	local unitIndex = self:GetContext("ability_marisa_04_spark_unit")
	local unit = EntIndexToHScript(unitIndex)
	if unit ~= nil then
		unit:RemoveSelf()
		self.effectcircle = -1
		self.effectIndex = -1
	end
	-- self:SetContextNum("ability_marisa_04_spark_lock", TRUE, 0)
end

modifier_thdots_marisa04_think_interval = {}
LinkLuaModifier("modifier_thdots_marisa04_think_interval", "scripts/vscripts/abilities/abilitymarisa.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_marisa04_think_interval:IsHidden() 		return true end
function modifier_thdots_marisa04_think_interval:IsPurgable()		return false end
function modifier_thdots_marisa04_think_interval:RemoveOnDeath() 	return true end
function modifier_thdots_marisa04_think_interval:IsDebuff()		return false end

function modifier_thdots_marisa04_think_interval:OnCreated()
	if not IsServer() then return end
	EmitSoundOnLocationWithCaster(self:GetAbility().point, "Voice_Thdots_Marisa.AbilityMarisa04_Cast", self:GetCaster())
	self:StartIntervalThink(0.1)
end

function modifier_thdots_marisa04_think_interval:OnIntervalThink()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	-- if ability:GetContext("ability_marisa_04_spark_lock") == FALSE then
		local vecCaster = caster:GetAbsOrigin()
		local targetPoint =  vecCaster + caster:GetForwardVector()
		local sparkRad = GetRadBetweenTwoVec2D(vecCaster, targetPoint)
		local findVec = Vector(vecCaster.x + math.cos(sparkRad) * ability.damage_length/2, vecCaster.y + math.sin(sparkRad) * ability.damage_length / 2, vecCaster.z)
		local findRadius = math.sqrt(((ability.damage_length / 2) * (ability.damage_length / 2) + (ability.damage_width / 2) * (ability.damage_width / 2)))
		local DamageTargets = FindUnitsInRadius(
			caster:GetTeam(),		--caster team
			findVec,		            --find position
			nil,					    --find entity
			findRadius,		        --find radius
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			ability:GetAbilityTargetType(),
			0, FIND_CLOSEST,
			false
		)
		--DebugDrawCircle(findVec+Vector(0,0,50),Vector(1,1,1),1,findRadius,false,5)
		for _,v in pairs(DamageTargets) do
			local vecV = v:GetOrigin()
			--print(vecV, vecCaster, ability.damage_width, ability.damage_length, sparkRad)
			if IsRadInRect(vecV, vecCaster, ability.damage_width, ability.damage_length, sparkRad) then
				local deal_damage = ability:GetAbilityDamage() / 20
				if IsRadInRect(vecV, vecCaster, 200, ability.damage_length, sparkRad) then
					deal_damage = deal_damage * 2
				end
				local damage_table = {
					ability = ability,
					victim = v,
					attacker = caster,
					damage = deal_damage,
					damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UtilStun:UnitStunTarget(caster, v, 0.2)
				UnitDamageTarget(damage_table)
			end
		end
		MarisaSparkParticleControl(caster, targetPoint, ability)
	-- end
end

modifier_ability_thdots_marisa04_passive = {}
LinkLuaModifier("modifier_ability_thdots_marisa04_passive", "scripts/vscripts/abilities/abilitymarisa.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_marisa04_passive:IsHidden() 		return true end
function modifier_ability_thdots_marisa04_passive:IsPurgable()		return false end
function modifier_ability_thdots_marisa04_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_marisa04_passive:IsDebuff()		return false end

function modifier_ability_thdots_marisa04_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_ability_thdots_marisa04_passive:GetModifierSpellAmplify_Percentage()
	local caster = self:GetCaster()
	if caster:IsNull() or not caster:HasScepter() or caster:GetMaxMana() == 0 then return 0 end
	local ability = self:GetAbility()
	return caster:GetMana() / caster:GetMaxMana() * 100 * ability:GetSpecialValueFor("wanbaochui_amplify")
end

function MarisaSparkParticleControl(caster,targetPoint,ability)
	local unitIndex = ability:GetContext("ability_marisa_04_spark_unit")
	local unit = EntIndexToHScript(unitIndex)

	if(ability.point ~= targetPoint)then
		ability.point = targetPoint
	end

	if(ability.effectIndex_b ~= -1)then
		ParticleManager:DestroyParticleSystem(ability.effectIndex_b,true)
	end

	if(unit == nil or ability.effectIndex == -1 or ability.effectcircle == -1)then
		return
	end

	forwardRad = GetRadBetweenTwoVec2D(targetPoint,caster:GetOrigin()) 
	vecForward = Vector(math.cos(math.pi/2 + forwardRad),math.sin(math.pi/2 + forwardRad),0)
	unit:SetForwardVector(vecForward)
	vecUnit = caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,160)
	vecColor = Vector(255,255,255)
	unit:SetOrigin(vecUnit)

	ability.effectIndex_b = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark_wind_b.vpcf", PATTACH_CUSTOMORIGIN, unit)

	ParticleManager:SetParticleControl(ability.effectcircle, 0, caster:GetOrigin())
	
	local effect2ForwardRad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint) 
	local effect2VecForward = Vector(math.cos(effect2ForwardRad)*850,math.sin(effect2ForwardRad)*850,0) + caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,108)
	
	ParticleManager:SetParticleControl(ability.effectIndex, 0, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 92,caster:GetForwardVector().y * 92,150))
	ParticleManager:SetParticleControl(ability.effectIndex, 1, effect2VecForward)
	ParticleManager:SetParticleControl(ability.effectIndex, 2, vecColor)
	local forwardRadwind = forwardRad + math.pi
	ParticleManager:SetParticleControl(ability.effectIndex, 8, Vector(math.cos(forwardRadwind),math.sin(forwardRadwind),0))
	ParticleManager:SetParticleControl(ability.effectIndex, 9, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,108))

	ParticleManager:SetParticleControl(ability.effectIndex_b, 0, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 92,caster:GetForwardVector().y * 92,150))
	ParticleManager:SetParticleControl(ability.effectIndex_b, 8, Vector(math.cos(forwardRadwind),math.sin(forwardRadwind),0))
	ParticleManager:DestroyParticleSystem(ability.effectIndex_b,false)
end

function AbilityMarisa:OnMarisa01Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_marisa_4"))
	-- local targetPoint  = CastRang_Calculate(caster,keys.target_points[1],keys.ability:GetSpecialValueFor("cast_range"))
	local targetPoint = keys.target_points[1]
	local range = keys.ability:GetSpecialValueFor("cast_range")
	local distance = ( targetPoint - caster:GetOrigin() ):Length2D()
	if distance >= range then
		targetPoint = caster:GetOrigin() + ( targetPoint - caster:GetOrigin() ):Normalized() * range 
	end
	local marisa01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local marisa01dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability:SetContextNum("ability_marisa01_Rad",marisa01rad,0)
	keys.ability:SetContextNum("ability_marisa01_Dis",marisa01dis,0)
	--local marisa01time = marisa01dis/1250
	--UnitPauseTarget(caster,caster,marisa01time)
end

function AbilityMarisa:OnMarisa01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		if(v:GetContext("ability_marisa01_damage")==nil)then
			v:SetContextNum("ability_marisa01_damage",TRUE,0)
		end
		if(v:GetContext("ability_marisa01_damage")==TRUE)then
			local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		    }
			UnitDamageTarget(damage_table)
			if v and not v:IsNull() then
				v:SetContextNum("ability_marisa01_damage",FALSE,0)
				Timer.Wait 'ability_marisa01_damage_timer' (0.7,
				function()
					v:SetContextNum("ability_marisa01_damage",TRUE,0)
				end
					)
			end
		end
	end
	local marisa01rad = keys.ability:GetContext("ability_marisa01_Rad")
	local vec = Vector(vecCaster.x+math.cos(marisa01rad)*keys.MoveSpeed/50,vecCaster.y+math.sin(marisa01rad)*keys.MoveSpeed/50,vecCaster.z)
	caster:SetOrigin(vec)
	local marisa01dis = keys.ability:GetContext("ability_marisa01_Dis")
	if(marisa01dis<0)then
		SetTargetToTraversable(caster)
		keys.ability:SetContextNum("ability_marisa01_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_marisa01_think_interval")
	else
	    marisa01dis = marisa01dis - keys.MoveSpeed/50
	    keys.ability:SetContextNum("ability_marisa01_Dis",marisa01dis,0)
	end
end

function AbilityMarisa:OnMarisa02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	keys.ability:SetContextNum("ability_marisa02_point_x",targetPoint.x,0)
	keys.ability:SetContextNum("ability_marisa02_point_y",targetPoint.y,0)
	keys.ability:SetContextNum("ability_marisa02_point_z",targetPoint.z,0)
	local unit = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	keys.ability:SetContextNum("ability_marisa02_effectUnit",unit:GetEntityIndex(),0)

	unit:SetContextThink("ability_marisa02_effect_remove", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
			return nil
		end, 
	1) 
end

function AbilityMarisa:OnMarisa02Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(keys.ability:GetContext("ability_marisa02_point_x"),keys.ability:GetContext("ability_marisa02_point_y"),keys.ability:GetContext("ability_marisa02_point_z"))
	local targets = keys.target_entities
	
	local unitIndex = keys.ability:GetContext("ability_marisa02_effectUnit")
	local unit = EntIndexToHScript(unitIndex)
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_02_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
	local vecForward = Vector(500 * caster:GetForwardVector().x,500 * caster:GetForwardVector().y,caster:GetForwardVector().z)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 3, vecForward)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	
	-- Ñ­»µ¸÷¸öÄ¿±êµ¥Î»
	for _,v in pairs(targets) do
		local vVec = v:GetOrigin()
		local vecRad = GetRadBetweenTwoVec2D(targetPoint,vecCaster)
		local vDistance = GetDistanceBetweenTwoVec2D(vVec,vecCaster)

		if(IsPointInCircularSector(vVec.x,vVec.y,math.cos(vecRad),math.sin(vecRad),keys.DamageRadius,math.pi/3,vecCaster.x,vecCaster.y))then
			local deal_damage = (keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_marisa_3"))/5
			if(vDistance<400)then
				deal_damage = deal_damage *2
			end
			local damage_table = {
				ability = keys.ability,
				victim = v,
				attacker = caster,
				damage = deal_damage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
		end
	end
end

function AbilityMarisa:OnMarisa03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local duration = keys.AbilityDuration -- FindTelentValue(caster,"special_bonus_unique_marisa_1")
	self.Marisa03Stars = {}
	for i = 0,3 do
		local vec = Vector(caster:GetOrigin().x + math.cos(i*math. pi/2) * 150,caster:GetOrigin().y + math.sin(i*math.pi/2) * 150,caster:GetOrigin().z + 300)
		local unit = CreateUnitByName(
		"npc_thdots_unit_marisa03_star"
		,vec
		,false
		,caster
		,caster
		,caster:GetTeam()
		)
		unit:SetContextNum("ability_marisa03_unit_rad",GetRadBetweenTwoVec2D(caster:GetOrigin(),vec),0)
		unit:AddNewModifier(caster, keys.ability, "modifier_ability_marisa03_unit_auto_attack", {})
		if FindTelentValue(caster,"special_bonus_unique_marisa_1") >0 then
			unit:AddNewModifier(caster, keys.ability, "modifier_ability_marisa03_special_bonus", {})
		end
		unit.hero = caster
		unitAbility = unit:FindAbilityByName("ability_thdots_marisa03_dealdamage")
		unitAbility:SetLevel(keys.ability:GetLevel())
		local ability_dummy_unit = unit:FindAbilityByName("ability_marisa03_dummy_unit")
		ability_dummy_unit:SetLevel(1)
		--unit:SetBaseDamageMax(keys.ability:GetAbilityDamage())
		--unit:SetBaseDamageMin(keys.ability:GetAbilityDamage())
		local effectIndex
		if(i==0)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==1)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_b.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==2)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_c.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==3)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_d.vpcf", PATTACH_CUSTOMORIGIN, unit)
		end
		ParticleManager:SetParticleControlEnt(effectIndex , 0, unit, 5, "follow_origin", Vector(0,0,0), true)

		-- Timer.Wait 'ability_marisa03_star_release' (duration,
		-- 	function()
		-- 		unit:ForceKill(true)
		-- 		unit:AddNoDraw()
		-- 		caster:RemoveModifierByName("modifier_thdots_marisa03_think_interval")
		-- 	end
		--    )
		unit:AddNewModifier(caster,keys.ability,"modifier_thdots_marisa03_unit_death",{duration = duration})
		table.insert(self.Marisa03Stars,unit)
	end
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_marisa03_think_interval", {Duration = duration})
end

modifier_ability_marisa03_unit_auto_attack = {}
LinkLuaModifier("modifier_ability_marisa03_unit_auto_attack", "scripts/vscripts/abilities/abilityMarisa.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_marisa03_unit_auto_attack:IsHidden() return false end
function modifier_ability_marisa03_unit_auto_attack:IsPurgable() return false end
function modifier_ability_marisa03_unit_auto_attack:RemoveOnDeath() return true end
function modifier_ability_marisa03_unit_auto_attack:IsDebuff() return false end

function modifier_ability_marisa03_unit_auto_attack:OnCreated()
	if not IsServer() then return end
	local star = self:GetParent()
	self:StartIntervalThink(0.2)
end

function modifier_ability_marisa03_unit_auto_attack:OnIntervalThink()
	if not IsServer() then return end

	local star = self:GetParent()
	if star.attackingTarget ~= nil and not star.attackingTarget:IsNull() and star.attackingTarget:IsAlive() and not star.attackingTarget:IsAttackImmune() then
		if GetDistanceBetweenTwoVec2D(star:GetAbsOrigin(), star.attackingTarget:GetAbsOrigin()) <= star:Script_GetAttackRange() then
			star:PerformAttack(star.attackingTarget, true, true, false, false, true, false, false)
			return
		end
	end

	local caster = self:GetCaster()
	local targets = FindUnitsInRadius(
		caster:GetTeam(),
		star:GetAbsOrigin(),
		nil,
		star:Script_GetAttackRange(),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
		FIND_CLOSEST,
		false
	)
	if #targets > 0 then
		star.attackingTarget = targets[1]
		star:PerformAttack(targets[1], true, true, false, false, true, false, false)
	else
		star.attackingTarget = nil
	end
end

modifier_thdots_marisa03_unit_death = {}
LinkLuaModifier("modifier_thdots_marisa03_unit_death","scripts/vscripts/abilities/abilityMarisa.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_marisa03_unit_death:IsHidden() 		return false end
function modifier_thdots_marisa03_unit_death:IsPurgable()		return false end
function modifier_thdots_marisa03_unit_death:RemoveOnDeath() 	return true end
function modifier_thdots_marisa03_unit_death:IsDebuff()		return false end
function modifier_thdots_marisa03_unit_death:OnDestroy()
	if not IsServer() then return end
	self:GetParent():ForceKill(true)
	self:GetParent():AddNoDraw()
end

function AbilityMarisa:OnMarisa03Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vCaster = caster:GetOrigin()
	local stars = self.Marisa03Stars
	for _,v in pairs(stars) do
		local vVec = v:GetOrigin()
		local turnRad = v:GetContext("ability_marisa03_unit_rad") + math.pi/120
		v:SetContextNum("ability_marisa03_unit_rad",turnRad,0)
		local turnVec = Vector(vCaster.x + math.cos(turnRad) * 150,vCaster.y + math.sin(turnRad) * 150,vCaster.z + 300)
		v:SetOrigin(turnVec)
	end
end
modifier_ability_marisa03_special_bonus = {}
LinkLuaModifier("modifier_ability_marisa03_special_bonus","scripts/vscripts/abilities/abilityMarisa.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_marisa03_special_bonus:IsHidden() 		return false end
function modifier_ability_marisa03_special_bonus:IsPurgable()		return false end
function modifier_ability_marisa03_special_bonus:RemoveOnDeath() 	return true end
function modifier_ability_marisa03_special_bonus:IsDebuff()		return false end
function modifier_ability_marisa03_special_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_ability_marisa03_special_bonus:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
    }
    return funcs
end

function modifier_ability_marisa03_special_bonus:GetModifierAttackRangeOverride()
	return 800
end

function modifier_ability_marisa03_special_bonus:GetModifierAttackSpeedBonus_Constant()
	return 150
end

function modifier_ability_marisa03_special_bonus:GetModifierProjectileSpeedBonus()
	return 400
end

ability_thdots_marisaEx = {}

function ability_thdots_marisaEx:GetIntrinsicModifierName()
    return "ability_thdots_marisaEx_passive"
end

ability_thdots_marisaEx_passive = {}
LinkLuaModifier("ability_thdots_marisaEx_passive","scripts/vscripts/abilities/abilityMarisa.lua",LUA_MODIFIER_MOTION_NONE)
function ability_thdots_marisaEx_passive:IsHidden()
	if self:GetStackCount() ~= 1 then
		return false 
	else
		return true
	end
end
function ability_thdots_marisaEx_passive:IsPurgable()      return false end
function ability_thdots_marisaEx_passive:RemoveOnDeath()   return false end
function ability_thdots_marisaEx_passive:IsDebuff()        return false end

function ability_thdots_marisaEx_passive:OnCreated()
    if not IsServer() then return end
    self.caster 				= self:GetCaster()
    self.ability 				= self:GetAbility()
    self.refresh_interval		= self.ability:GetSpecialValueFor("refresh_interval")
    self.refresh_time 			= self.ability:GetSpecialValueFor("refresh_time")
    self.refresh_time_ult 		= self.ability:GetSpecialValueFor("refresh_time_ult")
    self.react_time	= 0

    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
end

function ability_thdots_marisaEx_passive:OnIntervalThink()
    if not IsServer() then return end
    if self.react_time <= self.refresh_interval and self:GetStackCount() ~= 0 then
    	self.react_time = self.react_time + FrameTime()
    elseif self.react_time > self.refresh_interval and self:GetStackCount() ~= 0 then
    	self.caster:EmitSound("Voice_Thdots_Marisa.AbilityMarisaEx")
    	local particle_name = "particles/units/heroes/hero_windrunner/windrunner_windrun_beam.vpcf"
		local marisaEx_particle = ParticleManager:CreateParticle(particle_name, PATTACH_OVERHEAD_FOLLOW, self.caster)
		ParticleManager:ReleaseParticleIndex(marisaEx_particle)
    	self:SetStackCount(0)
    end
end

function ability_thdots_marisaEx_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

function ability_thdots_marisaEx_passive:OnAbilityExecuted(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local ability = keys.ability
	if keys.unit ~= caster or ability:IsItem() then return end
	
	self.react_time = 0
	if self:GetStackCount() ~= 1 then
		--print("do is")
		if ability:GetAbilityType() == 1 then
			caster:SetContextThink("marisaEx", function ()
				THDReduceCooldown(ability,-(self.refresh_time_ult))
				--print(ability:GetCooldownTimeRemaining())
			end, FrameTime())
		else
			caster:SetContextThink("marisaEx", function ()
				THDReduceCooldown(ability,-(self.refresh_time+caster:GetLevel()*0.1))
				--print(ability:GetCooldownTimeRemaining())
			end, FrameTime())
		end
		self:SetStackCount(1)
	end
end
