function Flan01_OnSpellStart(event)
	THDReduceCooldown(event.ability,FindTelentValue(event.caster,"special_bonus_unique_flandre_5"))
end

function MirrorImage( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor( "images_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "outgoing_damage", ability:GetLevel() - 1 ) + FindTelentValue(caster,"special_bonus_unique_flandre_4")
	local incomingDamage = ability:GetLevelSpecialValueFor( "incoming_damage", ability:GetLevel() - 1 )
	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()

	-- Stop any actions of the caster otherwise its obvious which unit is real
	caster:Stop()

	-- Initialize the illusion table to keep track of the units created by the spell
	if not caster.mirror_image_illusions then
		caster.mirror_image_illusions = {}
	end

	-- Kill the old images
	for k,v in pairs(caster.mirror_image_illusions) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
			print("args")
		end
	end

	-- Start a clean illusion table
	caster.mirror_image_illusions = {}
	local flan_clothes = {
		"models/thd2/flandre/flandre_mmd.vmdl", 	
		"models/flandre_scarlet_skin4/flandre_scarlet_skin4.vmdl",
		"models/flandre_scarlet_skin5/flandre_scarlet_skin5.vmdl",
		"models/flandrev2/flandrev2.vmdl", 	
	}
	local flan_clothes_scale= {
			0.9,
			1.3,
			1.3,
			1.25,	
	}
	-- Setup a table of potential spawn positions
	local vRandomSpawnPos = {
		Vector( 72, 0, 0 ),		-- North
		Vector( 0, 72, 0 ),		-- East
		Vector( -72, 0, 0 ),	-- South
		Vector( 0, -72, 0 ),	-- West
	}

	for i=#vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
		local j = RandomInt( 1, i )
		vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
	end

	-- Insert the center position and make sure that at least one of the units will be spawned on there.
	table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )

	-- At first, move the main hero to one of the random spawn positions.
	FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )
	if caster.mirror == true then
		local arg = RandomInt(1, 4)
		caster:SetModel(flan_clothes[arg])
		caster:SetOriginalModel(flan_clothes[arg])
		caster:SetModelScale(flan_clothes_scale[arg])
	end
	-- Spawn illusions
	for i=1, images_count do

		local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, true)

		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		
		-- Level Up the unit to the casters level
		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end

		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local individual_ability = caster:GetAbilityByIndex(abilitySlot)
			if individual_ability ~= nil then 
				local illusionAbility = illusion:FindAbilityByName(individual_ability:GetAbilityName())
				if illusionAbility ~= nil then
					illusionAbility:SetLevel(individual_ability:GetLevel())
				end
			end
		end

		-- Recreate the items of the caster
		for itemSlot=0,8 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
				newItem:SetPurchaser(nil)
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Set the illusion hp to be the same as the caster
		illusion:SetHealth(caster:GetHealth())

		-- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
		table.insert(caster.mirror_image_illusions, illusion)

	end
	if caster.mirror == true then
		for k,v in pairs(caster.mirror_image_illusions) do
			if v and IsValidEntity(v) then 
				local args = RandomInt(1, 4)
				print(flan_clothes[args])
				v:SetModel(flan_clothes[args])
				v:SetOriginalModel(flan_clothes[args])
				v:SetModelScale(flan_clothes_scale[args])
			end
		end
	end
end






if AbilityFlandre == nil then
	AbilityFlandre = class({})
end

function OnFlandreExDealDamage(keys)
	--PrintTable(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if not caster:HasModifier("modifier_ability_thdots_flandre_Ex") then
		caster:AddNewModifier(caster, keys.ability, "modifier_ability_thdots_flandre_Ex", {})
	end
	if(caster.flandrelock == nil)then
		caster.flandrelock = false
	end

	if(caster.flandrelock == true)then
		return
	end
	local upgrade = 0.0
	if caster:GetModifierStackCount("modifier_flandre02_ruin_upgrade",caster) ~= nil then
		upgrade = caster:GetModifierStackCount("modifier_flandre02_ruin_upgrade",caster)/100
	end
	caster.flandrelock = true
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster,
		damage = keys.DealDamage * (keys.IncreaseDamage+upgrade),
		damage_type = keys.ability:GetAbilityDamageType(), 
		damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	--caster:RemoveModifierByName("passive_flandreEx_damaged")
	UnitDamageTarget(damage_table)
	caster.flandrelock = false
	--keys.ability:ApplyDataDrivenModifier(caster, caster, "passive_flandreEx_damaged", nil)

	--调整调换模型后的攻击前摇动画点
	-- if caster:GetModelName() == "models/flandre_scarlet/flandre_scarlet.vmdl" then
	-- 	caster:SetBaseAttackTime(0.35)
	-- elseif caster:GetModelName() == "models/thd2/flandre/flandre_mmd.vmdl" then
	-- 	caster:SetBaseAttackTime(0.444)
	-- end
end

function OnFlandre02SpellStartUnit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if target:IsBuilding() then return end	
	local MaxDecreaseNum = keys.DecreaseMaxSpeed
	--[[if caster:HasModifier("modifier_item_wanbaochui") then
		if(target:GetContext("ability_flandre02_Speed_Decrease")==nil)then
			target:SetContextNum("ability_flandre02_Speed_Decrease",0,0)
		end
		local decreaseSpeedCount = target:GetContext("ability_flandre02_Speed_Decrease")
		decreaseSpeedCount = decreaseSpeedCount + 1
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_slow_wanbaochui",{})
		if(decreaseSpeedCount>MaxDecreaseNum)then
			target:RemoveModifierByName("modifier_flandre02_slow_wanbaochui")
		else
			target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedCount,0)
			target:SetThink(
				function()
					target:RemoveModifierByName("modifier_flandre02_slow_wanbaochui")
					local decreaseSpeedNow = target:GetContext("ability_flandre02_Speed_Decrease") - 1
					target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedNow,0)	
				end, 
				DoUniqueString("ability_flandre02_Speed_Decrease_Duration"), 
				keys.Duration
			)	
		end
	
	else]]
		if(target:GetContext("ability_flandre02_Speed_Decrease")==nil)then
			target:SetContextNum("ability_flandre02_Speed_Decrease",0,0)
		end
		local decreaseSpeedCount = target:GetContext("ability_flandre02_Speed_Decrease")
		decreaseSpeedCount = decreaseSpeedCount + 1
		if(decreaseSpeedCount>MaxDecreaseNum)then
			for i=0,decreaseSpeedCount do
				target:RemoveModifierByName("modifier_flandre02_slow")
				target:RemoveModifierByName("modifier_flandre02_slow_nopurge")
			end
			ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_ribbon_b.vpcf", PATTACH_ABSORIGIN_FOLLOW , target) 
			if target:IsHero() then 
				if FindTelentValue(caster,"special_bonus_unique_flandre_3") >0 then 
					target:RemoveModifierByName("modifier_flandre02_ruin")
					keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_ruin_nopurge",{})
				else
					keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_ruin",{duration = keys.ruin_duration})
				end
			end
			decreaseSpeedCount = 1
			local damageTable = {
				victim=target,
				attacker=caster,
				ability = keys.ability,
				damage_type=keys.ability:GetAbilityDamageType(),
				damage=keys.ability:GetSpecialValueFor("bonus_damage")
				}
			UnitDamageTarget(damageTable)
		end
			--[[target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedCount,0)
			target:SetThink(
				function()
					target:RemoveModifierByName("modifier_flandre02_slow")
					local decreaseSpeedNow = target:GetContext("ability_flandre02_Speed_Decrease") - 1
					target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedNow,0)	
				end, 
				DoUniqueString("ability_flandre02_Speed_Decrease_Duration"), 
				keys.Duration
			)	
		end]]
		target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedCount,0)
		if FindTelentValue(caster,"special_bonus_unique_flandre_3") >0 then 
			keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_slow_nopurge",{})
		else
			keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_slow",{duration = keys.Duration})
		end
	--end
end




function OnFlandre02RuinAttacked(keys)
	local damageTable = {
				victim=keys.target,
				attacker=keys.attacker,
				damage_type=DAMAGE_TYPE_PURE,
				damage=keys.DamageTaken*keys.DamageBonus/100
				}
	UnitDamageTarget(damageTable)
end


function  OnFlandre02SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.ExDamage,
					damage_type = DAMAGE_TYPE_PHYSICAL, 
					damage_flags = 0
				}
	UnitDamageTarget(damage_table)	
end


function OnFlandre04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	keys.ability:SetContextNum("ability_flandre04_multi_count",0,0)
	caster:AddNewModifier(caster,keys.ability,"modifier_thdots_flandre04_speed",{duration = 99})
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_flandre"))
	local count = 1 + FindTelentValue(caster,"special_bonus_unique_flandre_2")
	local illusions = FindUnitsInRadius(
		   caster:GetTeam(),		
		   caster:GetOrigin(),		
		   nil,					
		   3000,		
		   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		   DOTA_UNIT_TARGET_ALL,
		   DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 
		   FIND_CLOSEST,
		   false
	)

	for _,v in pairs(illusions) do
		if v:IsIllusion() and
			-- ( v:GetModelName() == "models/flandre_scarlet/flandre_scarlet.vmdl" 
			-- or v:GetModelName() == "models/thd2/flandre/flandre_mmd.vmdl"
			-- or v:GetModelName() == "models/flandre_scarlet_skin3/flandre_scarlet_skin3.vmdl"
			-- or v:GetModelName() == "models/flandre_scarlet_skin4/flandre_scarlet_skin4.vmdl"
			-- or v:GetModelName() == "models/flandre_scarlet_skin5/flandre_scarlet_skin5.vmdl"
			-- )
			v:GetPlayerOwnerID() == caster:GetPlayerOwnerID()
		then
			count = count + 1
			v:MoveToPosition(caster:GetOrigin())
			v:SetThink(
				function()
					OnFlandre04illusionsRemove(v,caster)
					return 0.02
				end, 
				DoUniqueString("ability_collection_power"),
			0.02)
		end
	end

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_ambient.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	-- ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_sk1_fx", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)

	keys.ability:SetContextNum("ability_flandre04_multi_count",count,0)
	keys.ability:SetContextNum("ability_flandre04_effectIndex",effectIndex,0)
	
	caster:StopSound("Voice_Thdots_Flandre.AbilityFlandre01")
	if RollPercentage(98) then
		caster:EmitSound("Voice_Thdots_Flandre.AbilityFlandre04")
	else
		caster:EmitSound("Voice_Thdots_Flandre.AbilityFlandre04_old")
	end
end



function OnFlandre04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local count = keys.ability:GetContext("ability_flandre04_multi_count")
	count = count - 1
	keys.ability:SetContextNum("ability_flandre04_multi_count",count,0)
	if(count<=0)then
		caster:RemoveModifierByName("modifier_thdots_flandre_04_multi")
		caster:RemoveModifierByName("modifier_thdots_flandre04_speed")
	end
end

function OnFlandre04EffectRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:RemoveModifierByName("modifier_thdots_flandre04_speed")
	local effectIndex = keys.ability:GetContext("ability_flandre04_effectIndex")
	ParticleManager:DestroyParticle(effectIndex,true)
end


function OnFlandre04illusionsRemove(target,caster,keys)
	local vecTarget = target:GetOrigin()
	local vecCaster = caster:GetOrigin()
	local speed = 30
	local radForward = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
	local vecForward = Vector(math.cos(radForward) * speed,math.sin(radForward) * speed,1)
	vecTarget = vecTarget + vecForward
	
	target:SetForwardVector(vecForward)
	target:SetOrigin(vecTarget)
	if(GetDistanceBetweenTwoVec2D(vecTarget,vecCaster)<50)then
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/flandre/ability_flandre_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecCaster)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		
		target:RemoveSelf()
		target = nil
	end
end

function Onflandre04Success(keys)
	local Target = keys.target
	local caster = keys.caster
	local ability = nil
	if not caster:HasModifier("modifier_item_wanbaochui") then return end
	ability = caster:FindAbilityByName("ability_thdots_flandre04")
	if Target:IsRealHero() == true then
		if ability~=nil then
			ability:EndCooldown()		

			local effectIndex = ParticleManager:CreateParticle(
					"particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf", 
					PATTACH_CUSTOMORIGIN, 
					keys.caster)
			ParticleManager:SetParticleControlEnt(effectIndex , 0, keys.caster, 5, "follow_origin", Vector(0,0,0), true)
			ParticleManager:SetParticleControl(effectIndex, 1, keys.caster:GetOrigin())
			ParticleManager:DestroyParticleSystemTime(effectIndex,2)

			EmitSoundOn("Hero_Bane.BrainSap.Target",keys.caster)
		end
	end
end

 function Onflandre04Kill(keys)
 	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:HasModifier("modifier_item_wanbaochui") then
 		caster:AddNewModifier(caster, keys.ability, "modifier_invisible", {duration=keys.Duration})
	end
 end


modifier_ability_thdots_flandre_Ex = {}
LinkLuaModifier("modifier_ability_thdots_flandre_Ex","scripts/vscripts/abilities/abilityFlandre.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_flandre_Ex:IsHidden() 		return true end
function modifier_ability_thdots_flandre_Ex:IsPurgable()		return false end
function modifier_ability_thdots_flandre_Ex:RemoveOnDeath() 	return false end
function modifier_ability_thdots_flandre_Ex:IsDebuff()		return false end
function modifier_ability_thdots_flandre_Ex:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

modifier_thdots_flandre04_speed = {}
LinkLuaModifier("modifier_thdots_flandre04_speed","scripts/vscripts/abilities/abilityFlandre.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_flandre04_speed:IsHidden() 		return true end
function modifier_thdots_flandre04_speed:IsPurgable()		return false end
function modifier_thdots_flandre04_speed:RemoveOnDeath() 	return true end
function modifier_thdots_flandre04_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_thdots_flandre04_speed:OnCreated( ... )
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_thdots_flandre04_speed:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent();
	self:SetStackCount(100*(1-caster:GetHealth()/caster:GetMaxHealth()))
end



function modifier_thdots_flandre04_speed:GetModifierMoveSpeedBonus_Percentage()
	local percent = self:GetStackCount()
	return self:GetAbility():GetSpecialValueFor("speed_bonus")+self:GetAbility():GetSpecialValueFor("ex_speed_bonus")*percent
end


function modifier_ability_thdots_flandre_Ex:OnAbilityExecuted(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	if caster ~= keys.unit then return end
	local ability = keys.ability
	if ability:GetName() == "ability_thdots_flandre01" then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil,1500,DOTA_UNIT_TARGET_TEAM_ENEMY,
								DOTA_UNIT_TARGET_HERO,0,0,false)
		if #targets ~= 0 and RollPercentage(60) then
			caster:EmitSound("Voice_Thdots_Flandre.AbilityFlandre01")
		end
	end
end

