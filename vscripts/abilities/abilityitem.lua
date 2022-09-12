
---------------------------------------------------------------------------------------
--[[
DEBUG FUNCTIONS
]]

--ITEM_DEBUG=true

function ItemAbility_wanbaochui02_SelfDestroy(keys)
	local caster = keys.caster
	-- print('ok')
	for i=0, 5, 1 do  --Search for Aghanim's Scepters in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			local item_name = current_item:GetName()
			
			if item_name == "item_wanbaochui2" then
				caster:RemoveItem(current_item)
			end
		end
	end

end

function ItemAbility_wanbaochui02_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local caster = keys.caster
	local target = keys.target
	print("target:IsHero()")
	print(target ~= caster)
	print(target:IsRealHero())
	-- if target ~= caster and target:IsRealHero() == false then 
	if target:IsRealHero() == false then 
		print("No")
		return 
	else
		-- 非永久万宝槌的遗留buff(如果有)应当被清除
		if keys.caster:HasModifier("modifier_item_wanbaochui") and
			keys.caster:GetModifierStackCount("modifier_item_wanbaochui",ItemAbility) ~= 99
		then
			keys.caster:RemoveModifierByName("modifier_item_wanbaochui")
		end
		-- 添加永久万宝槌的标记(with stack 99)
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_wanbaochui", {})
		caster:SetModifierStackCount("modifier_item_wanbaochui",ItemAbility,99)
		
		-- local TargetName = target:GetClassname()
	  --   if TargetName == "npc_dota_hero_chaos_knight" then
		-- 	return
		-- end
		-- if TargetName == "npc_dota_hero_clinkz" then
		-- 	return
		-- end
		
		if not caster:HasModifier("modifier_item_ultimate_scepter") then
			keys.caster:AddNewModifier(keys.caster, nil, "modifier_item_ultimate_scepter", {duration = -1})
		end
	end	
end


-- dota2 default support for aghanim scepter.
--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Aghanim's Scepter is sold or dropped.  Removes the stock Aghanim's Scepter modifier if no other 
	Aghanim's Scepters exist in the player's inventory.
================================================================================================================= ]]

function modifier_item_ultimate_scepter_datadriven_on_created(keys)
	if not keys.caster:HasModifier("modifier_item_wanbaochui") then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_wanbaochui", {})
		keys.caster:SetModifierStackCount("modifier_item_wanbaochui",ItemAbility,1)
	end
	
	if not keys.caster:HasModifier("modifier_item_ultimate_scepter") then
		keys.caster:AddNewModifier(keys.caster, nil, "modifier_item_ultimate_scepter", {duration = -1})
	end
end

function modifier_item_ultimate_scepter_datadriven_on_destroy(keys)
	if keys.caster:HasModifier("modifier_item_ultimate_scepter_datadriven") then return end

	-- 永久万宝槌不再进一步处理
	if keys.caster:HasModifier("modifier_item_wanbaochui") and
		keys.caster:GetModifierStackCount("modifier_item_wanbaochui",ItemAbility) == 99
	then
		return
	end

	if keys.caster:HasModifier("modifier_item_wanbaochui_stat") then
		keys.caster:RemoveModifierByName("modifier_item_wanbaochui_stat")
	end
	
	if keys.caster:HasModifier("modifier_item_wanbaochui") then
		keys.caster:RemoveModifierByName("modifier_item_wanbaochui")
	end
	
	--Remove the stock Aghanim's Scepter modifier if the player no longer has a scepter in their inventory.
	if keys.caster:HasModifier("modifier_item_ultimate_scepter") then
		print("Deleted modifier_item_wanbaochui")
		keys.caster:RemoveModifierByName("modifier_item_ultimate_scepter")
	end
end

function ItemAbility_UFO_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local caster = keys.caster
	local target = keys.target
	if target ~= caster and target:IsRealHero() == false then 
		print("No")
		return 
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_item_UFO_attack_speed_bonus", {})
		if (ItemAbility:IsItem()) then
			caster:RemoveItem(ItemAbility)
		end	
	end	
end

function ItemAbility_feixiangjian_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		local damage_to_deal =keys.PureDamage
		if Target:GetUnitName()=="npc_dota_roshan" then damage_to_deal=damage_to_deal*0.45 end
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PURE,
		}
		UnitDamageTarget(damage_table)
		
		--SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
		--PrintTable(damage_table)
		--DebugPrint("ItemAbility_Camera_OnAttack| Damage:"..damage_to_deal)
	end
end

function ItemAbility_specialcourier_OnSpellStart(keys)
	local Caster = keys.caster
	local unit = CreateUnitByName(
			"npc_dota_courier"
			,Caster:GetOrigin() + ( Caster:GetForwardVector() * 100 )
			,false
			,Caster
			,Caster
			,Caster:GetTeam()
		)
	unit:SetControllableByPlayer(Caster:GetPlayerOwnerID(), false)
	unit:SetOriginalModel("models/items/courier/chocobo/chocobo_flying.vmdl")	
	

	--local ability = unit:FindAbilityByName("courier_burst")
	--ability:SetLevel(1)

	local ability = unit:AddAbility("ability_system_fly")
	ability:SetLevel(1)

	--ability = unit:FindAbilityByName("courier_morph")
	--ability:SetLevel(1)
	--unit:CastAbilityNoTarget(ability,0)
	ItemAbility_Cooldown(keys)
	ItemAbility_SpendItem(keys)
end

function ForceStaff (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	if is_spell_blocked(target,caster) then return end	

	if target:HasModifier("modifier_thdots_yugi04_think_interval") and caster:GetTeamNumber() ~= target:GetTeamNumber() then
		return
	end
	ability:ApplyDataDrivenModifier(caster,target,"modifier_item_force_staff_effect",{})

	ability.forced_direction = target:GetForwardVector()
	ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)
	ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30	-- * 1/30 gives a duration of ~0.4 second push time (which is what the gamepedia-site says it should be)
	ability.forced_traveled = 0

end

function ForceHorizontal( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:HasModifier("modifier_thdots_yugi04_think_interval") and caster:GetTeamNumber() ~= target:GetTeamNumber() then
		target:RemoveModifierByName("modifier_item_force_staff_effect")
		target:InterruptMotionControllers(true)
		return
	end

	if ability.forced_traveled < ability.forced_distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.forced_direction * ability.forced_speed)
		ability.forced_traveled = ability.forced_traveled + (ability.forced_direction * ability.forced_speed):Length2D()
	else
		target:SetContextThink("clear_space",function ()
			if GameRules:IsGamePaused() then return 0.03 end
			ResolveNPCPositions(target:GetAbsOrigin(), 128)
			end,
			0.03)
		--FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		--SetTargetToTraversable(target)
		target:InterruptMotionControllers(true)
	end

end


function modifier_item_heavens_halberd_datadriven_on_attack_landed_random_on_success(keys)
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		keys.target:EmitSound("DOTA_Item.Maim")
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_heavens_halberd_datadriven_lesser_maim", {duration = keys.Duration})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when Heaven's Halberd is cast on an enemy unit.  Applies a disarm with a duration dependant on whether the
	target is melee or ranged.
	Additional parameters: keys.DisarmDurationRanged and keys.DisarmDurationMelee
================================================================================================================= ]]
function item_heavens_halberd_datadriven_on_spell_start(keys)
	if is_spell_blocked(keys.target) then return end
	keys.caster:EmitSound("DOTA_Item.HeavensHalberd.Activate")
	
	if keys.target:IsRangedAttacker() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_heavens_halberd_datadriven_disarm", {duration = keys.DisarmDurationRanged})
	else  --The target is melee.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_heavens_halberd_datadriven_disarm", {duration = keys.DisarmDurationMelee})
	end
end

function ItemAbility_tuzhushen_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	target:Purge(false,true,false,true,false)
end

function GetCurrentCoolDown(ability, Caster)
	local cd_len = ability:GetCooldown(ability:GetLevel() - 1)
	if Caster:HasModifier("modifier_cooldown_reduction_80") then
		cd_len = cd_len * 0.2;
	elseif Caster:HasModifier("modifier_item_nuclear_stick_cooldown_reduction") then
		cd_len = cd_len * 0.75;
	end
	return cd_len
end

function PrintTargetInfo(target)
	print("Target Name:"..target:GetName())
	print("Target ModelName: "..target:GetModelName())
	
	print("Target Has Abilities("..tostring(target:GetAbilityCount())..")")
	for i=0,target:GetAbilityCount()-1 do
		local indent="\t"
		local Ability=target:GetAbilityByIndex(i)
		if Ability then
			print(indent.."Target's Ability index:"..tostring(i).." name:"..Ability:GetName())
			indent=indent.."\t"
			print(indent.."GetLevel:"..tostring(Ability:GetLevel()))
		end
	end
	
	print("Target Has Modifiers("..tostring(target:GetModifierCount()).."):")
	for i=0,target:GetModifierCount()-1 do
		local indent="\t"
		local ModifierName=target:GetModifierNameByIndex(i)
		print(indent.."Target's Modifier index:"..tostring(i).." name:"..ModifierName)
		local ModifierClass=target:FindModifierByName(ModifierName)
		if ModifierClass then
			indent=indent.."\t"
			local Ability=ModifierClass:GetAbility()
			if Ability then
				print(indent.."GetAbility:"..tostring(Ability))
				print(indent.."GetAbility Name:"..Ability:GetAbilityName())
			end
			print(indent.."CDOTA_Modifier_Lua:GetAttributes:"..tostring(CDOTA_Modifier_Lua.GetAttributes(ModifierClass)))
			print(indent.."GetStackCount:"..tostring(ModifierClass:GetStackCount()))
			print(indent.."GetDuration:"..tostring(ModifierClass:GetDuration()))
			print(indent.."GetRemainingTime:"..tostring(ModifierClass:GetRemainingTime()))
			print(indent.."GetClass:"..ModifierClass:GetClass())
			print(indent.."GetCaster Name"..ModifierClass:GetCaster():GetName())
			print(indent.."GetParent Name"..ModifierClass:GetParent():GetName())
		end
	end
end

function ItemAbility_Debug_GetGold(keys)
	DebugPrint("ItemAbility_GetGold"..keys.bonus_gold)
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerID()
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.bonus_gold,false)
end
function ItemAbility_Debug_PrintHealth(keys)
	if (keys.caster) then
		DebugPrint(keys.debug_string.."caster health is "..keys.caster:GetHealth())
	end
	if (keys.target) then
		DebugPrint(keys.debug_string.."target health is "..keys.target:GetHealth())
	end
end

function DebugPrint(msg)
	if ITEM_DEBUG==true then print(msg) end
end

function DebugFunction(func,...)
	if ITEM_DEBUG then func(...) end
end
---------------------------------------------------------------------------------------
-- UTIL Functions

function clamp (Num, Min, Max)
	if (Num>Max) then return Max
	elseif (Num<Min) then return Min
	else return Num
	end
end

function round (num)
	return math.floor(num + 0.5)
end
 
function distance(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetAngleBetweenTwoVec(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end

function ItemAbility_SpendItem(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge>1) then
			ItemAbility:SetCurrentCharges(Charge-1)
		else
			Caster:RemoveItem(ItemAbility)
		end
	end
end

function ItemAbility_Cooldown(keys)
	local card = keys.ability
	local caster = keys.caster
	caster:SetContextNum("item_card_cooldown", 90, 0)
	caster:SetContextThink("item_card_cooldown_think",
		function (entity)
			if GameRules:IsGamePaused() then return 0.03 end
			caster:SetContextNum("item_card_cooldown", caster:GetContext("item_card_cooldown") - 0.1, 0)
			local rest = caster:GetContext("item_card_cooldown")
			for i = 0, 30 do
				local item = caster:GetItemInSlot(i)
				if item and item:GetName():find("item_card_", 1, true) then
					item:EndCooldown()
					if rest >= 0.1 then
						item:StartCooldown(rest)
					end
				end
			end
			if rest < 0.1 then return nil end
			return 0.1
		end,
	0)
end

function PrintTable(t, indent, done)
	--DebugPrint ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                DebugPrint(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                DebugPrint(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    DebugPrint(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    DebugPrint(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

function PrintKeys(keys)
	PrintTable(keys)
end

function UnitStunTarget(caster,target,stuntime)
    UtilStun:UnitStunTarget(caster,target,stuntime)
end

-- extra keys params:
-- string ModifierName
-- int Blockable
-- int ApplyToTower
function ItemAbility_ModifierTarget(keys)
	--这是所有道具的DEBUFF添加
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	local duration = ItemAbility:GetSpecialValueFor("duration")
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked(Target,Caster) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=duration})
end
--------------------------------------------------


function Item_yukkuri_stick_ModifierTarget(keys)
	local ItemAbility = keys.ability
	local duration = ItemAbility:GetSpecialValueFor("debuff_duration")
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	Target:EmitSound("Hero_Lion.Voodoo")
	Target:EmitSound("THD_ITEM.Yukkuri_Target")
	local yukkuri_stick_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW,Target)
	ParticleManager:ReleaseParticleIndex(yukkuri_stick_particle)
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration = duration})
	if Target:HasModifier("modifier_illusion") then
		ItemAbility:EndCooldown()
		local Illusion_cooldown = ItemAbility:GetSpecialValueFor("Illusion_cooldown")/100
		ItemAbility:StartCooldown(ItemAbility:GetCooldown(0) * Illusion_cooldown)
	end
end

function Item_frozen_frog_Ability_ModifierTarget(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration = keys.Duration})
	Target:AddNewModifier(Caster, ItemAbility, "modifier_item_frozen_frog_cold_debuff_reduce_regen", {duration = keys.Duration})
end

modifier_item_frozen_frog_cold_debuff_reduce_regen = {}
LinkLuaModifier("modifier_item_frozen_frog_cold_debuff_reduce_regen","scripts/vscripts/abilities/abilityItem.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_item_frozen_frog_cold_debuff_reduce_regen:IsHidden() 		return true end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:IsPurgable()		return true end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:RemoveOnDeath() 	return true end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:IsDebuff()		return true end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:OnCreated()
	self.regen_amplify = self:GetAbility():GetSpecialValueFor("regen_amplify")
end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:GetModifierHealAmplify_PercentageTarget()
	return self.regen_amplify
end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:GetModifierHPRegenAmplify_Percentage()
	return self.regen_amplify
end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:OnTooltip()
	return self.regen_amplify
end

function Item_tentacle_Ability_ModifierTarget(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	-- if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
	-- 	if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
	-- 		return
	-- 	elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
	-- 		return
	-- 	end
	-- end
	Caster:EmitSound("DOTA_Item.RodOfAtos.Cast")
	local projectile =
				{
					Target 				= Target,
					Source 				= Caster,
					Ability 			= ItemAbility,
					EffectName 			= "particles/items2_fx/rod_of_atos_attack.vpcf",
					iMoveSpeed			= 1200,
					vSourceLoc 			= Caster:GetAbsOrigin(),
					bDrawsOnMinimap 	= false,
					bDodgeable 			= true,
					bIsAttack 			= false,
					bVisibleToEnemies 	= true,
					bReplaceExisting 	= false,
					flExpireTime 		= GameRules:GetGameTime() + 20,
					bProvidesVision 	= false,
				}
				
	ProjectileManager:CreateTrackingProjectile(projectile)

	-- ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
end

function ItemAbility_tentacle_OnProjectileHitUnit(keys)
	-- print_r(three_dimension_projectile)
	local caster = keys.Caster or keys.caster
	local target = keys.Target or keys.target
	if is_spell_blocked(target,caster) then return end
	if target and not target:IsMagicImmune() then
		target:EmitSound("DOTA_Item.RodOfAtos.Target")
		keys.ability:ApplyDataDrivenModifier(caster,target,keys.ModifierName,{duration = keys.ability:GetSpecialValueFor("root_duration")})
		-- if target:GetTeam() ~= caster:GetTeam() then
		-- end
	end
end

-- extra keys params:
-- string ModifierName
-- int ModifierCount
-- table ApplyModifierParams
function ItemAbility_SetModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	
	if (keys.ModifierCount>0) then
		if (Target:HasModifier(keys.ModifierName)==false) then
			local Params = {}
			if (keys.ApplyModifierParams) then
				Params=keys.ApplyModifierParams
			end
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,Params)
		end
		Target:SetModifierStackCount(keys.ModifierName,ItemAbility,keys.ModifierCount)
	elseif(Target:HasModifier(keys.ModifierName)) then
		Target:RemoveModifierByName(keys.ModifierName)
	end
end

-- extra keys params:
-- int CountChange
-- string ModifierName
-- int ModifierCount
-- table ApplyModifierParams
function ItemAbility_ModifyModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	local ModifierStackCount = 0
	if (Target:HasModifier(keys.ModifierName)) then
		ModifierStackCount=Target:GetModifierStackCount(keys.ModifierName,Caster)
	end
	keys.ModifierCount=ModifierStackCount+keys.CountChange
	ItemAbility_SetModifierStackCount(keys)
end

function create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	local tmp = keys.caster
	if keys.caster:GetPlayerOwner():GetContext("PlayerIsBot") == 1 then
		tmp = nil
	end
	
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, true, keys.caster, tmp, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.  --seriously?
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
			illusion_duplicate_item:SetPurchaser(nil)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	return illusion
end
---------------------------------------------------------------------------------------
function ItemAbility_CardBadMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.BuffName,{})
	ItemAbility_Cooldown(keys)
	ItemAbility_SpendItem(keys)
end
function ItemAbility_CardWorseMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local AbsorbMana = min(Target:GetMana(),keys.AbsorbManaAmount)
	
--	if not is_spell_blocked_by_hakurei_amulet(Target) then
		Target:ReduceMana(AbsorbMana)
		Caster:GiveMana(AbsorbMana)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_LOSS,Target,AbsorbMana,nil)
		
		UnitDamageTarget({
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = keys.AbsorbDamage,
				damage_type = DAMAGE_TYPE_PURE,
				Blockable=0
			})
		-- SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,keys.AbsorbDamage,nil)
--	end
	ItemAbility_Cooldown(keys)
	ItemAbility_SpendItem(keys)
end
function ItemAbility_CardLoveMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Target:Heal(keys.HealAmount,Caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Target,keys.HealAmount,nil)
	ItemAbility_Cooldown(keys)
	ItemAbility_SpendItem(keys)
end
function ItemAbility_MrYang_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target

	-- Target:SetMana(Target:GetMana() + ItemAbility:GetSpecialValueFor("decline_mana")) --修改为削660蓝，而不是蓝上限

	Caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	Target:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	if is_spell_blocked_by_hakurei_amulet(Target) then
		return
	end
	Target:Purge(true,false,false,false,false)
	if Target:HasModifier("modifier_item_ghost_spoon") then
		Target:RemoveModifierByName("modifier_item_ghost_spoon")
	end
	if Target:HasModifier("modifier_item_three_dimension_debuff") then 
		Target:RemoveModifierByName("modifier_item_three_dimension_debuff")
	end
	
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.DeclineIntDebuffName,{})
	
	for i=0.0,keys.SlowdownDuration,keys.SlowdownInterval do
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.SlowdownDebuffName,{duration=i})
	end
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,"modifier_item_mr_yang_attack_not_miss",{})

end

function ItemAbility_MrYang_OnAttackStart( keys )
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if Target:HasModifier("modifier_item_mr_yang_decline_intellect") then
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,"modifier_item_mr_yang_attack_not_miss_when",{duration = 0.5})
	end
end

function ItemAbility_MrYang_OnIntervalThink(keys )
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Target:Purge(true,false,false,false,false)
	if Target:HasModifier("modifier_item_ghost_spoon") then
		Target:RemoveModifierByName("modifier_item_ghost_spoon")
	end
	if Target:HasModifier("modifier_item_three_dimension_debuff") then 
		Target:RemoveModifierByName("modifier_item_three_dimension_debuff")
	end
end

function ItemAbility_SmashStick_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		if Caster:GetAttackCapability()==DOTA_UNIT_CAP_RANGED_ATTACK then
			DebugPrint("ItemAbility_SmashStick_OnAttack| Ranged Stun: "..keys.StunDurationRanged.." sec")
			UnitStunTarget(Caster,Target,keys.StunDurationRanged)
		elseif Caster:GetAttackCapability()==DOTA_UNIT_CAP_MELEE_ATTACK then
			DebugPrint("ItemAbility_SmashStick_OnAttack| Melee Stun: "..keys.StunDurationMelee.." sec")
			UnitStunTarget(Caster,Target,keys.StunDurationMelee)
		end
	end
end

function ItemAbility_GhostBallon_OnAttacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker	
	if (Attacker:IsBuilding()==false) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Attacker,keys.ModifierName,{})
	end
end

--[[function ItemAbility_Xuenvdeweijin_OnAttacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker	
	if (Attacker:IsBuilding()==false) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Attacker,keys.ModifierName,{})
	end
end]]

function ItemAbility_WindGun_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal = keys.PhysicalDamage
	if (Caster:IsRealHero() and Target:IsRealHero()==false and Target:IsBuilding()==false) then
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_base_attack_explosion_charlie.vpcf", PATTACH_ABSORIGIN_FOLLOW, Target)
		ParticleManager:SetParticleControl(effectIndex, 3, Caster:GetAbsOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		UnitDamageTarget(damage_table)
	end
end

function ItemAbility_Camera_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsIllusion()==false and Target:IsBuilding()==false and not Caster:HasModifier("modifier_illusion")) then
		local damage_to_deal =Target:GetMaxHealth()*keys.DamageHealthPercent*0.01
		if Target:GetUnitName()=="npc_dota_roshan" then damage_to_deal=damage_to_deal*keys.RoshanPercent/100 end
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		UnitDamageTarget(damage_table)
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		UnitDamageTarget(damage_table)
		damage_table.damage_type = DAMAGE_TYPE_PURE
		UnitDamageTarget(damage_table)
		
		--SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
		--PrintTable(damage_table)
		--DebugPrint("ItemAbility_Camera_OnAttack| Damage:"..damage_to_deal)
	end
end

function ItemAbility_Verity_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local attackLand_damage = ItemAbility:GetSpecialValueFor("attackLand_damage")
	local reduce_mana = ItemAbility:GetSpecialValueFor("reduce_mana")
	if (Target:IsBuilding()==false and Caster:IsIllusion()==false and Caster:HasModifier("modifier_illusion")==false) then
		
		if ItemAbility:IsCooldownReady() then
			Target:ReduceMana(reduce_mana)
			--ItemAbility:StartCooldown(ItemAbility:GetCooldown(1))
			ItemAbility:StartCooldown(GetCurrentCoolDown(ItemAbility,Caster))
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = attackLand_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
			}
			UnitDamageTarget(damage_table)
		end
		Target:EmitSound("THD_ITEM.Verity_Hit")
		local RemoveMana = Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01+keys.Basicremovemana
		RemoveMana=min(RemoveMana,Target:GetMana())
		Target:ReduceMana(RemoveMana)
		local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
			}
			UnitDamageTarget(damage_table)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Verity_OnAttack| Damage:"..damage_to_deal)
		end
	else
		if (Caster:IsIllusion() or Caster:HasModifier("modifier_illusion")) and Target:IsBuilding()==false then
			Target:EmitSound("THD_ITEM.Verity_Hit")
			local RemoveMana = (Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01+keys.Basicremovemana)*0.3
			RemoveMana=min(RemoveMana,Target:GetMana())
			Target:ReduceMana(RemoveMana)
			local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor*3/7
			if (damage_to_deal>0) then
				local damage_table = {
					ability = ItemAbility,
					victim = Target,
					attacker = Caster,
					damage = damage_to_deal,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
				}
				UnitDamageTarget(damage_table)
			
				--PrintTable(damage_table)
				DebugPrint("ItemAbility_Verity_OnAttack| Damage:"..damage_to_deal)
			end
		end

        --[[if not Caster:HasModifier("modifier_illusion") then
        	if not Target:IsBuilding() then
		
		if ItemAbility:IsCooldownReady() then
			Target:ReduceMana(reduce_mana)
			--ItemAbility:StartCooldown(ItemAbility:GetCooldown(1))
			ItemAbility:StartCooldown(GetCurrentCoolDown(ItemAbility,Caster))
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = attackLand_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
			}
			UnitDamageTarget(damage_table)
		end
		Target:EmitSound("THD_ITEM.Verity_Hit")
		local RemoveMana = Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01+keys.Basicremovemana
		RemoveMana=min(RemoveMana,Target:GetMana())
		Target:ReduceMana(RemoveMana)
		local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
			}
			UnitDamageTarget(damage_table)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Verity_OnAttack| Damage:"..damage_to_deal)
		end
		end
		end]]
	end
end

function Kafziel_OnSpellStart( keys )
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Caster:EmitSound("DOTA_Item.SpiritVessel.Cast")
	Target:EmitSound("DOTA_Item.SpiritVessel.Target.Enemy")
	if is_spell_blocked(keys.target) then return end
		
			local particle = ParticleManager:CreateParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, Caster)
			ParticleManager:SetParticleControl(particle, 1, Target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)
	Target:AddNewModifier(Caster, ItemAbility, "modifier_item_kafziel_debuff_reduce_regen", {duration = ItemAbility:GetSpecialValueFor("duration")* (1 - Target:GetStatusResistance())})
	ItemAbility:ApplyDataDrivenModifier(Caster, Target, "modifier_item_kafziel_debuff", {duration = ItemAbility:GetSpecialValueFor("duration")* (1 - Target:GetStatusResistance())})
end

function ItemAbility_Kafziel_Interval_Think(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local MaxHealth = Target:GetMaxHealth()
	local Health = Target:GetHealth()
	local min_health_pct = ItemAbility:GetSpecialValueFor("min_health_pct")*0.01
	local pct = Health/MaxHealth

	if pct <= min_health_pct then
		Target:EmitSound("DOTA_Item.Dagon.Activate")
		Target:RemoveModifierByName("modifier_item_kafziel_debuff")
		Target:RemoveModifierByName("modifier_item_kafziel_debuff_reduce_regen")
		local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = ItemAbility:GetSpecialValueFor("damage"),
				damage_type = DAMAGE_TYPE_PURE,
			}

		UnitDamageTarget(damage_table)
	end
end

modifier_item_kafziel_debuff_reduce_regen = {}
LinkLuaModifier("modifier_item_kafziel_debuff_reduce_regen","scripts/vscripts/abilities/abilityItem.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_item_kafziel_debuff_reduce_regen:IsHidden() 		return true end
function modifier_item_kafziel_debuff_reduce_regen:IsPurgable()		return false end
function modifier_item_kafziel_debuff_reduce_regen:RemoveOnDeath() 	return true end
function modifier_item_kafziel_debuff_reduce_regen:IsDebuff()		return true end

function modifier_item_kafziel_debuff_reduce_regen:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_item_kafziel_debuff_reduce_regen:OnCreated()
	self.regen_amplify = self:GetAbility():GetSpecialValueFor("regen_amplify")
end
function modifier_item_kafziel_debuff_reduce_regen:GetModifierHealAmplify_PercentageTarget()
	return self.regen_amplify
end
function modifier_item_kafziel_debuff_reduce_regen:GetModifierHPRegenAmplify_Percentage()
	return self.regen_amplify
end
function modifier_item_kafziel_debuff_reduce_regen:OnTooltip()
	return self.regen_amplify
end

function ItemAbility_Kafziel_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		local damage_to_deal = (Caster:GetHealth()-Target:GetHealth())*keys.HarvestDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			UnitDamageTarget(damage_table)
			-- SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Kafziel_OnAttack| Damage:"..damage_to_deal)
			print("ItemAbility_Kafziel_OnAttack| Damage:"..damage_to_deal)
		end
	end
end

function ItemAbility_Frock_Poison(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	if ItemAbility:IsCooldownReady() == false then return end
	if (Attacker:IsBuilding()==false) then
		local damage_to_deal = 0
		if (Attacker:IsHero()) then
			local MaxAttribute = max(max(Attacker:GetStrength(),Attacker:GetAgility()),Attacker:GetIntellect())
			damage_to_deal = keys.PoisonDamageBase + MaxAttribute*keys.PoisonDamageFactor
		end
		damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
		if (damage_to_deal>0) then
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
			local damage_table = {
				ability = ItemAbility,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			UnitDamageTarget(damage_table)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Frock_Poison| Damage:"..damage_to_deal)
		end
	end
end

function ItemAbility_Frock_Poison_Destory(keys)
	keys.caster.Poison = false
end

function ItemAbility_Frock_Poison_TakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	local damage_to_deal = keys.TakenDamage * keys.BackFactor
	if Caster:GetContext("ability_yuyuko_Ex_deadflag")~=nil and keys.TakenDamage == Caster:GetMaxHealth() then
		damage_to_deal = 0
	end
	keys.caster.Poison = true
	if (Attacker:IsBuilding()==false) and Attacker ~= Caster and not IsTHDReflect(Attacker) then
		if (damage_to_deal>0 and damage_to_deal<=Caster:GetMaxHealth()) then
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
			local damage_table = {
				ability = ItemAbility,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}			
			UnitDamageTarget(damage_table)			
		end
	end
end

function ItemAbility_LoneLiness_RegenHealth(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Health = Caster:GetHealth()
	local MaxHealth = Caster:GetMaxHealth()
	local HealthRegen = Caster:GetHealthRegen()
	local HealAmount = ((MaxHealth-Health)*0.5)*keys.PercentHealthRegenBonus*0.01 + HealthRegen*keys.HealthRegenMultiplier*0.01*0.5
	Caster:Heal(HealAmount,Caster)
end

function ItemAbility_Bagua_RegenMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Mana =  Caster:GetMana()
	local MaxMana = Caster:GetMaxMana()
	local ManaRegenAmount = MaxMana*keys.PercentManaRegenBonus*0.01
	Caster:SetMana(Mana + ManaRegenAmount)
end

function ItemAbility_HakureiTicket_FeastHeal(keys)
	local Caster = keys.caster
	local HealAmount = keys.HealAmount
	local Targets = keys.target_entities
	Caster:EmitSound("DOTA_Item.Mekansm.Activate")
	for i,v in pairs(Targets) do
		if not v:HasModifier("modifier_item_hakurei_ticket_feast_buff") then
			v:Heal(HealAmount + v:GetMaxHealth()*0.1,Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,v,HealAmount + v:GetMaxHealth()*0.1,nil)
		end
		v:EmitSound("DOTA_Item.Mekansm.Target")
		local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_CUSTOMORIGIN, v)
		ParticleManager:SetParticleControlEnt(effectIndex , 0, v, 5, "follow_origin", Vector(0,0,0), true)
	end
end

function ItemAbility_DoctorDoll_DeclineHealth(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Health = Caster:GetHealth()
	
	local damage_to_deal = min(keys.DeclineHealthPerSec,Health-1)
	if (damage_to_deal>0) then
		Caster:SetHealth(Health - damage_to_deal)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Caster,damage_to_deal,nil)
		
		--PrintTable(damage_table)
	end
end

function ItemAbility_DummyDoll_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	
	ProjectileManager:ProjectileDodge(Caster)
	--create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	illusion=create_illusion(keys,Caster:GetAbsOrigin(),keys.illusion_damage_percent_incoming_melee,-65,keys.illusions_duration)
	if (illusion ~= nil) then
		local CasterAngles = Caster:GetAnglesAsVector()
		illusion:SetAngles(CasterAngles.x,CasterAngles.y,CasterAngles.z)
		
		illusion:SetHealth(illusion:GetMaxHealth()*Caster:GetHealthPercent()*0.01)
		illusion:SetMana(illusion:GetMaxMana()*Caster:GetManaPercent()*0.01)
		--ItemAbility:ApplyDataDrivenModifier(illusion,illusion,keys.illusion_modifier,{})
	end
end


function ItemAbility_Good_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	if Caster:HasModifier("modifier_item_better_lunchbox") or Caster:HasModifier("modifier_item_best_lunchbox") or Caster:HasModifier("modifier_item_god_lunchbox") then return end
	if Caster:GetTeam()~=Target:GetTeam() and Caster:CanEntityBeSeenByMyTeam(Target) then
		local CurrentActiveAbility=keys.event_ability
		if IsNotLunchbox_ability(CurrentActiveAbility) then return end
		if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
			local Charge = ItemAbility:GetCurrentCharges()
			if (Charge<keys.MaxCharges) then
				ItemAbility:SetCurrentCharges(Charge+1)
			end
		end
	end
end

function ItemAbility_Better_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	--print("debug_better_Caster is :" .. Caster:GetUnitName() .. "and Target is" .. Target:GetUnitName())
	if Caster:HasModifier("modifier_item_best_lunchbox") or Caster:HasModifier("modifier_item_god_lunchbox") then return end
	local Casters=FindUnitsInRadius(Target:GetTeamNumber(),
									Target:GetAbsOrigin(),
									nil,
									1400,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)	
	for i,v in pairs(Casters) do
	--print("Casters is :" .. v:GetName())	
		if v:GetTeam()~=Target:GetTeam() and v:CanEntityBeSeenByMyTeam(Target) and v:HasItemInInventory("item_better_lunchbox") then
			local CurrentActiveAbility=keys.event_ability
			if IsNotLunchbox_ability(CurrentActiveAbility) then return end
			if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
				for k = 0,5,1 do
					if v:GetItemInSlot(k) ~= nil and v:GetItemInSlot(k):GetAbilityName() == "item_better_lunchbox" then
						local Charge = v:GetItemInSlot(k):GetCurrentCharges()
						if (Charge<keys.MaxCharges) then
							v:GetItemInSlot(k):SetCurrentCharges(Charge+1)
							break
						end
					end
				end
			end
		end	
	end
end

function ItemAbility_Best_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	--print("debug_best_Caster is :" .. Caster:GetUnitName() .. "and Target is" .. Target:GetUnitName())
	if Caster:HasModifier("modifier_item_god_lunchbox") then return end
	local Casters=FindUnitsInRadius(Target:GetTeamNumber(),
									Target:GetAbsOrigin(),
									nil,
									1400,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)	
	for i,v in pairs(Casters) do	
		if v:GetTeam()~=Target:GetTeam() and v:CanEntityBeSeenByMyTeam(Target) and v:HasItemInInventory("item_best_lunchbox") then
			local CurrentActiveAbility=keys.event_ability
			if IsNotLunchbox_ability(CurrentActiveAbility) then return end
			if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
				for k = 0,5,1 do
					if v:GetItemInSlot(k) ~= nil and v:GetItemInSlot(k):GetAbilityName() == "item_best_lunchbox" then
						local Charge = v:GetItemInSlot(k):GetCurrentCharges()
						if (Charge<keys.MaxCharges) then
							v:GetItemInSlot(k):SetCurrentCharges(Charge+1)
							break
						end
					end
				end
			end
		end	
	end
end

function ItemAbility_God_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit --Target是施法的人 . Caster是接受能量点的人
--print("Target is :" .. Target:GetName())
--print("Caster is :" .. Caster:GetName())
--CanEntityBeSeenByMyTeam 视野方法
--DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE 视野方法
--GetAbilityName() 获取道具名
-- print("TargetName is:" .. tostring(Target:GetName()))
-- print(keys.event_ability:GetName())
-- print_r(keys)
	local Casters=FindUnitsInRadius(Target:GetTeamNumber(),
									Target:GetAbsOrigin(),
									nil,
									1400,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)		
	for i,v in pairs(Casters) do
	--print("Casters is kejian:" .. v:GetUnitName())
		if v:GetTeam()~=Target:GetTeam() and v:CanEntityBeSeenByMyTeam(Target) and v:HasItemInInventory("item_god_lunchbox") then
			local CurrentActiveAbility=keys.event_ability
			if IsNotLunchbox_ability(CurrentActiveAbility) then return end
			if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
				--local Charge = ItemAbility:GetCurrentCharges()
				for k = 0,5,1 do
					--print(v:GetItemInSlot(k))
					--print(k)
					if v:GetItemInSlot(k) ~= nil and v:GetItemInSlot(k):GetAbilityName() == "item_god_lunchbox" then
						--print(tostring(v:GetItemInSlot(k)) .. "is god_lunchbox")
						local Charge = v:GetItemInSlot(k):GetCurrentCharges()
							if (Charge<keys.MaxCharges) then
							v:GetItemInSlot(k):SetCurrentCharges(Charge+1)
							-- print("debug_god_v is :" .. v:GetUnitName() .. "and Target is" .. Target:GetUnitName())
								break
							end
					end
				end
			end
		end
	end
end

function Lunchbox_particle(caster)
	local stick_pfx = ParticleManager:CreateParticle("particles/items2_fx/magic_stick.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(stick_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(stick_pfx, 1, Vector(10,0,0))
	ParticleManager:ReleaseParticleIndex(stick_pfx)
	caster:EmitSound("DOTA_Item.MagicStick.Activate")
end

function ItemAbility_Lunchbox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Lunchbox_particle(Caster)
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		local HealAmount = Charge*keys.RestorePerCharge
		if (Charge>0) then
			Caster:Heal(HealAmount,Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Caster,HealAmount,nil)
			Caster:GiveMana(HealAmount)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,Caster,HealAmount,nil)
			
			ItemAbility:SetCurrentCharges(0)
		end
	end
end

function ItemAbility_God_Lunchbox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Lunchbox_particle(Caster)
	if (ItemAbility:GetCurrentCharges()>=7) then
		--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
		Caster:Purge(false,true,false,true,false)
	end
	ItemAbility_Lunchbox_OnSpellStart(keys) --Spend Charges
end

function ItemAbility_DragonStar_Stack_Permanent(keys) --永久增加龙星冷却时间
	if not keys.caster:HasModifier("modifier_item_dragon_star_stacks") then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_item_dragon_star_stacks",{})
	end
	THDReduceCooldown(keys.ability,10*keys.caster:GetModifierStackCount("modifier_item_dragon_star_stacks",nil))
	if keys.caster:GetModifierStackCount("modifier_item_dragon_star_stacks",nil)>=5 then return end
	--keys.caster:SetModifierStackCount("modifier_item_dragon_star_stacks",keys.caster,keys.caster:GetModifierStackCount("modifier_item_dragon_star_stacks",nil)+1)
end

function ItemAbility_DragonStar_Purge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	--DebugPrint("ItemAbility_Dragon_Star_Purge")
	--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
	Caster:Purge(false,true,false,true,false)
	
end


function ItemAbility_mushroom_kebab_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if GameRules:GetDOTATime(false,false)<300 then return end
	Caster:SetBaseStrength(Caster:GetBaseStrength() + keys.IncreaseStrength)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_mushroom_pie_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if GameRules:GetDOTATime(false,false)<300 then return end
	Caster:SetBaseAgility(Caster:GetBaseAgility() + keys.IncreaseAgility)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_mushroom_soup_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if GameRules:GetDOTATime(false,false)<300 then return end
	Caster:SetBaseIntellect(Caster:GetBaseIntellect() + keys.IncreaseIntellect)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_HorseKing_OnOpen_SpendMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	--if (Caster:GetMaxMana()>keys.NeedSpendMana) then
	do
		if (Caster:GetManaPercent()<keys.SpendManaPercent and ItemAbility:GetToggleState()) then
			ItemAbility:ToggleAbility()
		else
			local SpendMana = Caster:GetMaxMana()*keys.SpendManaPercent*0.01
			Caster:SpendMana(SpendMana,ItemAbility)
			--Caster:ReduceMana(SpendMana)
		end
	end
end

function ItemAbility_HorseKing_ToggleOff(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:GetToggleState()) then
		ItemAbility:ToggleAbility()
	end
end

function ItemAbility_DonationBox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local GoldBounty = Target:GetGoldBounty()
	if Target:GetUnitName() == "ability_minamitsu_04_ship" 
		or Target:GetUnitName() == "ability_margatroid03_doll"
		or Target:GetUnitName() == "npc_ability_parsee04_dummy"
		then return
	end
	if Target:HasModifier("modifier_ability_thdots_super_siege") then --40分钟超级兵
		return
	end
	Target:SetMaximumGoldBounty(GoldBounty+keys.BonusGold)
	Target:SetMinimumGoldBounty(GoldBounty+keys.BonusGold)
	Target:Kill(ItemAbility,Caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_GOLD,Caster,keys.BonusGold,nil)
	Caster:AddExperience(180,DOTA_ModifyXP_CreepKill,false,false)
	
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, Target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)
	
	local Duration=0.0
	Caster:SetThink(function ()
		if (Duration>1.0) then 
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			return nil 
		end
		
		Duration = Duration+0.02
		ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
		return 0.02
	end)
end

function ItemAbility_DonationGem_BounsGold(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	local GoldBountyAmount=keys.GoldBountyAmount
	
	if Target:GetTeam()~=Caster:GetTeam() then
		if (ItemAbility and ItemAbility:IsCooldownReady()) then
			--ItemAbility:StartCooldown(ItemAbility:GetCooldown(ItemAbility:GetLevel()))
			ItemAbility:StartCooldown(GetCurrentCoolDown(ItemAbility,Caster))
			Caster.ItemAbility_DonationGem_TriggerTime=GameRules:GetGameTime()
			PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + GoldBountyAmount,false)
			
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, Caster)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			
			SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,GoldBountyAmount,nil)
			DebugPrint("ItemAbility_DonationGem_BounsGold| Bounty Gold: "..tostring(GoldBountyAmount))
		end
	end
end

function ItemAbility_Rocket_OnHit(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if is_spell_blocked_by_hakurei_amulet(Target) then
		return
	end
	Caster:EmitSound("THD_ITEM.Rocket_Hit")
	UnitStunTarget(Caster,Target,keys.StunDuration)
	UnitDamageTarget({
		ability = ItemAbility,
		victim = Target,
		attacker = Caster,
		damage = keys.RocketDamage,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end

function ItemAbility_9ball_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local vecCaster = Caster:GetOrigin()
	local radian = RandomFloat(0,6.28)
	local range = RandomFloat(keys.BlinkRangeMin,keys.BlinkRangeMax)
	vecCaster.x = vecCaster.x+math.cos(radian)*range
	vecCaster.y = vecCaster.y+math.sin(radian)*range
	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_end_ti7.vpcf", PATTACH_POINT, Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex, false)
	Caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	FindClearSpaceForUnit(Caster, vecCaster, true)
	ProjectileManager:ProjectileDodge(Caster)
	--SetTargetToTraversable(Caster)
end

function ItemAbility_PresentBox_RestoreGold(keys)
	local ItemAbility = keys.ability
	if (ItemAbility:IsItem())then
		local Caster = keys.caster
		local CasterPlayerID = Caster:GetPlayerOwnerID()
		local RestoreGold = ItemAbility:GetCost()*keys.RestoreGoldPercent*0.01
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + RestoreGold,false)
		Caster:RemoveItem(ItemAbility)
		SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,RestoreGold,nil)
	end
end

function ItemAbility_PresentBox_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function ItemAbility_Lifu_RestoreGold(keys)
	local ItemAbility = keys.ability
	if (ItemAbility:IsItem())then
		local Caster = keys.caster
		local CasterPlayerID = Caster:GetPlayerOwnerID()
		local RestoreGold = ItemAbility:GetCost()*keys.RestoreGoldPercent*0.01
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + RestoreGold,false)
		Caster:RemoveItem(ItemAbility)
		SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,RestoreGold,nil)
	end
end

function ItemAbility_Lifu_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function ItemAbility_PresentBox_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function ItemAbility_Peach_OnTakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local DamageTaken = keys.DamageTaken
	local TakeDamageCount = Caster.ItemAbility_Peach_TakeDamageCount
	local SpeedupDuration = keys.SpeedupDuration
	local SpeedupModifierName = keys.SpeedupModifierName
	local SpeedupMaxModifierStack = keys.SpeedupMaxModifierStack
	local TimeNow = GameRules:GetGameTime()
	if (TakeDamageCount==nil) then
		TakeDamageCount=0
	end
	
	if (Caster.ItemAbility_Peach_LastTriggerTime==nil or TimeNow-Caster.ItemAbility_Peach_LastTriggerTime>=SpeedupDuration) then
		TakeDamageCount=0
		Caster.ItemAbility_Peach_LastTriggerTime = GameRules:GetGameTime()
	end
	
	TakeDamageCount = TakeDamageCount + DamageTaken
	Caster.ItemAbility_Peach_TakeDamageCount=TakeDamageCount
	DebugPrint("Item_Peach TakenDamageCount.."..TakeDamageCount)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+1
		local TriggerBuff = nil
		ModifierCount = min(ModifierCount,SpeedupMaxModifierStack)
		
		if (Caster:HasModifier(SpeedupModifierName)) then
			if (Caster:GetModifierStackCount(SpeedupModifierName,Caster)~=ModifierCount or (ModifierCount==SpeedupMaxModifierStack and TimeNow>Caster.ItemAbility_Peach_LastTriggerTime)) then
				Caster:RemoveModifierByName(SpeedupModifierName)
				ItemAbility:ApplyDataDrivenModifier(Caster,Caster,SpeedupModifierName,{duration = SpeedupDuration})
				Caster:SetModifierStackCount(SpeedupModifierName,ItemAbility,ModifierCount)
				TriggerBuff = true
			end
		else
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,SpeedupModifierName,{duration = SpeedupDuration})
			Caster:SetModifierStackCount(SpeedupModifierName,ItemAbility,ModifierCount)
			TriggerBuff = true
		end
		
		if (TriggerBuff) then
			Caster.ItemAbility_Peach_LastTriggerTime = TimeNow
		end
	end
end

function ItemAbility_Anchor_OnTakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local DamageTaken = keys.DamageTaken
	local TakeDamageCount = Caster.ItemAbility_Anchor_TakeDamageCount
	local BuffDuration = keys.BuffDuration
	local IconModifierName = keys.IconModifierName
	local BuffMaxStack = keys.BuffMaxStack
	local TimeNow = GameRules:GetGameTime()
	if (TakeDamageCount==nil) then
		TakeDamageCount=0
	end
	
	if (Caster.ItemAbility_Anchor_LastTriggerTime==nil or TimeNow-Caster.ItemAbility_Anchor_LastTriggerTime>=BuffDuration) then
		TakeDamageCount=0
		Caster.ItemAbility_Anchor_LastTriggerTime = TimeNow
	end
	
	TakeDamageCount = TakeDamageCount + DamageTaken
	Caster.ItemAbility_Anchor_TakeDamageCount=TakeDamageCount
	DebugPrint("Item_Anchor TakenDamageCount.."..TakeDamageCount)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+1
		local TriggerBuff = nil
		ModifierCount = keys.CritChanceConst+min(ModifierCount,BuffMaxStack)*keys.BuffCritChance
		
		if (Caster:HasModifier(IconModifierName)) then
			if (Caster:GetModifierStackCount(IconModifierName,Caster)~=ModifierCount or (ModifierCount==keys.CritChanceConst+BuffMaxStack*keys.BuffCritChance and TimeNow>Caster.ItemAbility_Anchor_LastTriggerTime)) then
				Caster:RemoveModifierByName(IconModifierName)
				ItemAbility:ApplyDataDrivenModifier(Caster,Caster,IconModifierName,{duration = BuffDuration})
				Caster:SetModifierStackCount(IconModifierName,ItemAbility,ModifierCount)
				TriggerBuff = true
			end
		else
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,IconModifierName,{duration = BuffDuration})
			Caster:SetModifierStackCount(keys.IconModifierName,ItemAbility,ModifierCount)
			TriggerBuff = true
		end
		
		if (TriggerBuff) then
			Caster.ItemAbility_Anchor_LastTriggerTime = TimeNow
		end
	end
end

function ItemAbility_Anchor_OnAttackStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CritChance = keys.CritChanceConst
	
	if (Caster:HasModifier(keys.IconModifierName)) then
		CritChance = Caster:GetModifierStackCount(keys.IconModifierName,Caster)
	end
	
	if (CritChance>=RandomInt(1,100)) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.CritModifierName,{})
	end
end

function ItemAbility_NuclearStick_OnAbility(keys)
	local Caster=keys.caster
	local Ability=Caster:GetCurrentActiveAbility()
	local ReductionCooldown=keys.ReductionCooldown
	local AbilityCooldown=Ability:GetCooldown(Ability:GetLevel() - 1)*(100-ReductionCooldown)*0.01
	if not Ability or Ability:IsItem() then return end
	Caster:SetThink(function()
		DebugPrint("StartCooldown: "..tostring(AbilityCooldown).." sec")
		Ability:EndCooldown()
		Ability:StartCooldown(AbilityCooldown)
		return nil
	end)
end

function ItemAbility_Yuri_OnSpell(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local ContractOverRange = keys.ContractOverRange
	local MaxRange = ContractOverRange*3
	local MaxSpeed=keys.MaxSpeed
	local BuffModifierName = keys.BuffModifierName
	local ModifierName = keys.ModifierName
	local FirstDistance = 400
	DebugFunction(PrintTargetInfo,Target)
	
	if Caster:GetTeam()~=Target:GetTeam() and is_spell_blocked_by_hakurei_amulet(Target) then
		return
	end
	--敌对
	if Caster:GetTeam()~=Target:GetTeam() then 
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.BuffModifierName,{})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=7})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=5})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=2})
	--友方
	else 
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.BuffModifierName,{})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.FriendlyModifierName,{})
	end
	
	local effectIndex = ItemAbility_Yuri_create_line(Caster,Target)

	Caster:SetThink(function ()
		local CasterPos = Caster:GetAbsOrigin()
		local TargetPos = Target:GetAbsOrigin()
		local Distance = distance(CasterPos,TargetPos)
		if (Caster:HasModifier(BuffModifierName)==false or Target:IsAlive()==false or Distance>MaxRange) then
			Caster:RemoveModifierByNameAndCaster(BuffModifierName,Caster)
			ParticleManager:DestroyParticleSystem(effectIndex,true)
			return nil
		end
		
		if (Distance>FirstDistance) then
			local vec = TargetPos - CasterPos
			local MoveDistance = (Distance-FirstDistance)
			MoveDistance=(MoveDistance*MoveDistance)/(200*200)*MaxSpeed*0.02
			if MoveDistance>1.0 then
				Caster:SetAbsOrigin(CasterPos + vec:Normalized()*MoveDistance)
			end
		end
		return 0.02
	end)
end

function ItemAbility_Yuri_create_line(caster,target)
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_lily.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	return effectIndex
end




function ItemAbility_Bra_Physical_Block(keys)
	local Caster = keys.caster
	local damageblock=keys.DamageBlock
	--[[
	local AttackCapability=Caster:GetAttackCapability()
	local IsMelee=false
	if AttackCapability==DOTA_UNIT_CAP_MELEE_ATTACK then 
		IsMelee=true
	else 
		IsMelee=false
	end
	if  IsMelee==true then
		damageblock = keys.DamageBlock
	else
		damageblock = keys.DamageBlock/2
	end]]
	local DamageBlock = min(damageblock,keys.DamageTaken*keys.BlockPercent/100)
	
	--DebugPrint("ItemAbility_Bra Physical Block: "..DamageBlock)
	if (Caster:GetHealth() + DamageBlock <= keys.DamageTaken) then return end
	Caster:SetHealth(Caster:GetHealth()+DamageBlock)
	
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BLOCK,Caster,DamageBlock,nil)
end

function ItemAbility_MoonBow_OnHit(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal = keys.arrow_damage_const + Caster:GetIntellect()*keys.arrow_damage_int_mult
	--if (Target:IsHero()) then
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Moon_Bow_OnHit| Damage:"..damage_to_deal)
			UnitDamageTarget(damage_table)
			
			
			-- SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
		end
	--end
end

function ItemAbility_InabaIllusionWeapon_OnEquip(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local AttackCapability=Caster:GetAttackCapability()
	local IsMelee=false
	local IsRanged=false
	local IsCannon=false
	if AttackCapability==DOTA_UNIT_CAP_MELEE_ATTACK then IsMelee=true
	elseif AttackCapability==DOTA_UNIT_CAP_RANGED_ATTACK then IsRanged=true
	else IsCannon=true end 
	
	if IsMelee then
		if not Caster:HasModifier(keys.ModifierBuffMelee) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.ModifierBuffMelee,{})
		end
	elseif IsRanged then
		if not Caster:HasModifier(keys.ModifierBuffRanged) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.ModifierBuffRanged,{})
		end
	elseif IsCannon then
		if not Caster:HasModifier(keys.ModifierBuffCannon) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.ModifierBuffCannon,{})
		end
	end
end

function ItemAbility_InabaIllusionWeapon_OnUnequip(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local ItemCount = 0
	for i=0,5 do
		local curr_item=Caster:GetItemInSlot(i)
		if curr_item and curr_item:GetName()==ItemAbility:GetName() then
			ItemCount=ItemCount+1
		end
	end
	if ItemCount<=0 then
		if Caster:HasModifier(keys.ModifierBuffMelee) then
			Caster:RemoveModifierByName(keys.ModifierBuffMelee)
		end
		if Caster:HasModifier(keys.ModifierBuffRanged) then
			Caster:RemoveModifierByName(keys.ModifierBuffRanged)
		end
		if Caster:HasModifier(keys.ModifierBuffCannon) then
			Caster:RemoveModifierByName(keys.ModifierBuffCannon)
		end
	end
end

function ItemAbility_InabaIllusionWeapon_Melee_OnAttackLanded(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local CleavePercent=keys.CleavePercent
	local CleaveRadius=keys.CleaveRadius
	local ItemCount=0
	if Caster:IsRealHero() and Caster:GetTeam()~=Target:GetTeam() then
		for i=0,5 do
			local curr_item=Caster:GetItemInSlot(i)
			if curr_item and curr_item:GetName()==ItemAbility:GetName() then
				ItemCount=ItemCount+1
			end
		end
		
		if (ItemCount>0) then
			local Damage=keys.AttackDamage*ItemCount*CleavePercent*0.01
			DoCleaveAttack(Caster,Target,ItemAbility,Damage,CleaveRadius,CleaveRadius,CleaveRadius,"particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
		end
	end
end

function ItemAbility_InabaIllusionWeapon_Ranged_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if Caster:HasModifier("modifier_ability_thdots_tei03") then return end --黑兔子开启枪斗术禁用兔炮效果
	local RangedSplitNum=keys.RangedSplitNum
	local RangedSplitRadius=keys.RangedSplitRadius
	local ItemCount=0
	if Caster:GetTeam()~=Target:GetTeam() then
		for i=0,5 do
			local curr_item=Caster:GetItemInSlot(i)
			if curr_item and curr_item:GetName()==ItemAbility:GetName() then
				ItemCount=ItemCount+1
			end
		end
		local MaxTargets=ItemCount*RangedSplitNum
		local Targets=FindUnitsInRadius(Caster:GetTeamNumber(),
										Caster:GetAbsOrigin(),
										nil,
										RangedSplitRadius,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
										false)
		for _,unit in pairs(Targets) do
			if MaxTargets>0 then
				if unit and unit:IsAlive() and unit~=Target and Caster:CanEntityBeSeenByMyTeam(unit) then
					Caster:PerformAttack(unit,
						true,
						false,
						true,
						false,
						true,
						false,
						true
						)
					MaxTargets=MaxTargets-1
				end
			else break end
		end
	end
end

function ItemAbility_InabaIllusionWeapon_Cannon_OnAttackLanded(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local CannonDamageMin=keys.CannonDamageMin
	local CannonDamageMax=keys.CannonDamageMax
	local CannonDamageRadius=keys.CannonDamageRadius
	local ItemCount=0
	if Caster:IsRealHero() and Caster:GetTeam()~=Target:GetTeam() then
		for i=0,5 do
			local curr_item=Caster:GetItemInSlot(i)
			if curr_item and curr_item:GetName()==ItemAbility:GetName() then
				ItemCount=ItemCount+1
			end
		end
		
		if (ItemCount>0) then
			local Damage=RandomFloat(CannonDamageMin,CannonDamageMax)*ItemCount
			local Targets=FindUnitsInRadius(Caster:GetTeamNumber(),
											Target:GetAbsOrigin(),
											nil,
											CannonDamageRadius,
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_ALL,
											DOTA_UNIT_TARGET_FLAG_NONE,
											FIND_ANY_ORDER,
											false)
			for _,unit in pairs(Targets) do
				if unit and unit:IsAlive() then
					UnitDamageTarget{
						ability = ItemAbility,
						victim = unit,
						attacker = Caster,
						damage = Damage,
						damage_type = DAMAGE_TYPE_PURE
					}
				end
			end	
			DebugPrint("ItemAbility_InabaIllusionWeapon_Cannon_OnAttackLanded| Damage:"..Damage)
		end
	end
end
--------------------------------------------------------------------------------------------------------
--[[
	item_hakurei_amulet
]]
function is_spell_blocked_by_hakurei_amulet(target)
	if target:HasModifier("modifier_item_sphere_target") then
		target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
		target:EmitSound("DOTA_Item.LinkensSphere.Activate")
		return true
	end
	return false
end

function ItemAbility_HakureiAmulet_OnCreated(keys)
	if keys.ability ~= nil and keys.ability:IsCooldownReady() then
		if keys.caster:HasModifier("modifier_item_sphere_target") then  --Remove any potentially temporary version of the modifier and replace it with an indefinite one.
			keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		end
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_hakurei_amulet_icon", {duration = -1})
	end
end

function ItemAbility_HakureiAmulet_OnDestroy(keys)
	if not keys.caster:HasModifier("modifier_item_hakurei_amulet") then
		keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		keys.caster:RemoveModifierByName("modifier_item_hakurei_amulet_icon")
	end
end

function ItemAbility_HakureiAmulet_OnIntervalThink(keys)
	if not keys.caster:HasModifier("modifier_item_sphere_target") then
		if keys.caster:HasModifier("modifier_item_hakurei_amulet_icon") then -- blocked spell
			for i=0, 5, 1 do
				local current_item = keys.caster:GetItemInSlot(i)
				if current_item ~= nil and current_item:GetName()=="item_hakurei_amulet" then
					--current_item:StartCooldown(current_item:GetCooldown(current_item:GetLevel()))
					current_item:StartCooldown(GetCurrentCoolDown(current_item,keys.caster))
				end
			end
			keys.caster:RemoveModifierByName("modifier_item_hakurei_amulet_icon")
		else -- reset modifier
			local num_off_cooldown_linkens_spheres_in_inventory = 0
			for i=0, 5, 1 do
				local current_item = keys.caster:GetItemInSlot(i)
				if current_item ~= nil then
					if current_item:GetName() == "item_hakurei_amulet" and current_item:IsCooldownReady() then
						num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
					end
				end
			end
			if num_off_cooldown_linkens_spheres_in_inventory>0 then
				keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
				keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_hakurei_amulet_icon", {duration = -1})
			end
		end
	end
end

function ItemAbility_Qijizhixing_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target

	target:Heal(keys.HealAmount + caster:GetMaxMana() * 0.25,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,keys.HealAmount + caster:GetMaxMana() * 0.25,nil)
	target:Purge(false,true,false,true,false)
end

function ItemAbility_tsundere_OnSpellStart(keys)
	local caster = keys.caster
	caster:Purge(false,true,false,true,false)
end



function ItemAbility_Ganggenier_OnDealDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	--print("do it1111")
	if(caster.ganggenierlock == nil)then
		caster.ganggenierlock = false
	end

	if(caster.ganggenierlock == true)then
		return
	end

	caster.ganggenierlock = true
	
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster,
		damage = keys.DamageDeal * keys.IncreaseDamage/100,
		damage_type = DAMAGE_TYPE_PURE, 
	}
	UnitDamageTarget(damage_table)
	caster.ganggenierlock = false

	--增加法术吸血
end

-- function ItemAbility_Morenjingjuan_Antiblink_OnSpellStart(keys)
-- 	local caster = keys.caster
-- 	local target = keys.target
-- 	local ability = keys.ability
-- 	local vecTarget = target:GetOrigin()
-- 	local attackspeed = keys.AttackSpeedIncrese * (caster:GetMaxMana() - target:GetMaxMana())

-- 	target.isAntiBlink = true

-- 	attackspeedint =  math.floor(attackspeed/100)

-- 	ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_morenjingjuan_buff",{duration = keys.Duration})
-- 	caster:SetModifierStackCount("modifier_item_morenjingjuan_buff",ability,attackspeedint)

-- 	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_ambient_body.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
-- 	ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)

-- 	local effectIndex2 = ParticleManager:CreateParticle("particles/thd2/items/item_morenjingjuan.vpcf", PATTACH_CUSTOMORIGIN, caster)
-- 	ParticleManager:SetParticleControlEnt(effectIndex2 , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
-- 	ParticleManager:SetParticleControl(effectIndex2, 1, Vector(0,0,0))
-- 	ParticleManager:SetParticleControl(effectIndex2, 6, Vector(1,1,1))
-- 	ParticleManager:DestroyParticleSystemTime(effectIndex2,keys.Duration)

-- 	local count = 0

-- 	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('item_ability_morenjingjuan'),
--     	function ()
--     		if GameRules:IsGamePaused() then return 0.03 end
--     		count = count + 0.03

--     		if target:HasModifier("modifier_item_morenjingjuan_antiblink") == false then
-- 				ParticleManager:DestroyParticleSystem(effectIndex,true)
--     			return nil
--     		end

--     		if target.is_Iku_02_knock == true then
--     			return 0.03
--     		end

-- 		    target:SetOrigin(vecTarget)

-- 		    if count > keys.Duration then
-- 		    	ParticleManager:DestroyParticleSystem(effectIndex,true)
-- 		    	return nil
-- 		    else
-- 		    	return 0.03
-- 		    end
-- 	    end,
-- 	    0.03
-- 	)

-- end

-- function ItemAbility_Morenjingjuan_Antiblink_OnDestroy(keys)
-- 	local target = keys.target
-- 	FindClearSpaceForUnit(target,target:GetOrigin(),true)
-- end

function ItemAbility_ModifierTarget_Morenjingjuan(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	local duration = ItemAbility:GetSpecialValueFor("bonus_duration")
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked(Target,Caster) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_start.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, Target, 5, "follow_origin", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(effectIndex, 5, Target)
	-- ParticleManager:SetParticleControl(effectIndex, 6, Vector(1,1,1))
	ParticleManager:DestroyParticleSystemTime(effectIndex,4)
	Target:EmitSound("THD_ITEM.Morenjingjuan_Cast")
	Target:AddNewModifier(Caster, ItemAbility, "modifier_item_morenjingjuan_antiblink", {duration = duration* (1 - Target:GetStatusResistance())})
end

modifier_item_morenjingjuan_antiblink = {}
LinkLuaModifier("modifier_item_morenjingjuan_antiblink","scripts/vscripts/abilities/abilityItem.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_item_morenjingjuan_antiblink:IsPurgable() 		 return true end
function modifier_item_morenjingjuan_antiblink:RemoveOnDeath()		 return true end
function modifier_item_morenjingjuan_antiblink:IsHidden()			 return false end
function modifier_item_morenjingjuan_antiblink:IsDebuff()			 return true end
function modifier_item_morenjingjuan_antiblink:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	self.vecTarget = target:GetOrigin()
	local bonus_duration = ability:GetSpecialValueFor("bonus_duration")
	local bonus_attackspeed_increase = ability:GetSpecialValueFor("bonus_attackspeed_increase")
	local attackspeed = bonus_attackspeed_increase * (caster:GetMaxMana() - target:GetMaxMana())


	target.isAntiBlink = true

	attackspeedint =  math.floor(attackspeed/100)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_morenjingjuan_buff",{duration = bonus_duration})
	caster:SetModifierStackCount("modifier_item_morenjingjuan_buff",ability,attackspeedint)

	self.effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_ambient_body.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(self.effectIndex, 0, self.vecTarget)

	self.effectIndex2 = ParticleManager:CreateParticle("particles/thd2/items/item_morenjingjuan.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(self.effectIndex2 , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effectIndex2, 1, Vector(0,0,0))
	ParticleManager:SetParticleControl(self.effectIndex2, 6, Vector(1,1,1))
	ParticleManager:DestroyParticleSystemTime(self.effectIndex2,bonus_duration)

	self:StartIntervalThink(FrameTime())
	print("1231231231231")
end

function modifier_item_morenjingjuan_antiblink:OnIntervalThink()
	if not IsServer() then return end
	local target = self:GetParent()
	print("intintintin")
	if not target.is_Iku_02_knock == true then
		target:SetOrigin(self.vecTarget)
	end
end

function modifier_item_morenjingjuan_antiblink:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.effectIndex,true)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function ItemAbility_yuemianzhinu_range(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_yuemianzhinu_range",{})
	end
end

function ItemAbility_phoenix_wing_burn(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dealdamage = keys.damage + caster:GetMaxHealth() * keys.damage_percent/100
	--local distance = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),target:GetOrigin())
	--[[if distance>=0 and distance<200 then
		dealdamage = dealdamage
	elseif distance>=200 and distance<400 then
		dealdamage = dealdamage*0.6
	elseif distance>=400 then
		dealdamage = dealdamage*0.3
	end]]
	--ParticleManager:SetParticleControl(target.phoenix_wing_particle, 1, caster:GetAbsOrigin())
	UnitDamageTarget({
		ability = ability,
		victim = target,
		attacker = caster,
		damage = dealdamage,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end


function ItemAbility_phoenix_wing_burn_created(keys)
	local caster = keys.caster
	local target = keys.target
	local particle_name = "particles/econ/events/ti10/radiance_ti10.vpcf"
	target.phoenix_wing_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(target.phoenix_wing_particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(target.phoenix_wing_particle, 1, caster:GetAbsOrigin())
end

function ItemAbility_phoenix_wing_burn_destory(keys)
	local target = keys.target
	if not target or target:IsNull() or not target.phoenix_wing_particle then return end
	ParticleManager:DestroyParticle(target.phoenix_wing_particle, false)
	-- ParticleManager:ReleaseParticleIndex(target.phoenix_wing_particle)
end

function OnZunGlasses_Take_Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local VecCaster = caster:GetOrigin()

	if keys.ability:IsCooldownReady() and caster:IsRealHero() then 
		if caster:GetHealth() == 0 and caster:GetClassname()~="npc_dota_hero_necrolyte" and caster:HasModifier("modifier_thdots_komachi_04")==false then 
			if caster:GetClassname()=="npc_dota_hero_chaos_knight" then
				caster:SetRespawnPosition(VecCaster)
				caster:RespawnUnit()
			end
			caster:SetHealth(caster:GetMaxHealth()*0.15)
			--keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
			keys.ability:StartCooldown(GetCurrentCoolDown(keys.ability,keys.caster))
		end
	end
		--原代码
	--if(caster:GetHealth()<=keys.DamageTaken and caster:GetClassname()~="npc_dota_hero_necrolyte")then
	--	local randomInt = RandomInt(0,100)
	--	if randomInt <= 50 and keys.ability:IsCooldownReady() then
	--		caster:SetHealth(caster:GetHealth()+keys.DamageTaken)
	--		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	--	end
	--end
end

function ItemAbility_item_brother_sharp_created(keys)
	print("dot is")
	local caster = keys.caster
	-- local particle_name = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_cyclone.vpcf"
	local particle_name = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient.vpcf"
	-- local particle_name = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_debut_ambient_v2.vpcf"
	caster.brother_sharp_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
	-- caster.brother_sharp_particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	-- caster.brother_sharp_particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.brother_sharp_particle , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(caster.brother_sharp_particle , 1, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(caster.brother_sharp_particle , 2, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(caster.brother_sharp_particle , 11, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(caster.brother_sharp_particle , 12, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(caster.brother_sharp_particle, 1, caster:GetAbsOrigin())
end

function ItemAbility_item_brother_sharp_destory(keys)
	print("22222222222")
	local caster = keys.caster
	ParticleManager:DestroyParticle(caster.brother_sharp_particle, false)
	-- ParticleManager:ReleaseParticleIndex(target.brother_sharp_particle)
end

--[[function OnFly_BirdKillSpawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local caster = keys.caster
	if caster.ability_fly_bird~=nil and caster.ability_fly_bird:IsNull() == false then
		caster.ability_fly_bird:ForceKill(true)
	end
end]]

function OnTentacle_Effect(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	if ( Caster:IsRealHero() == false ) then return end
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end	
		local randomInt = RandomInt(0,100)
		if randomInt <= 16  then
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration = keys.ability:GetSpecialValueFor("root_duration")})
		end	
	end
end
-------------------------------------------------------------------------------------------------------------------
--[[Author: Pizzalol
	Date: 18.01.2015.
	Checks if the target is an illusion, if true then it kills it
	otherwise the target model gets swapped into a frog]]
function voodoo_start( keys )
	local target = keys.target
	local model = keys.model

	if target:HasModifier("modifier_illusion") then
		target:ForceKill(true)
	else
		if target.target_model == nil then
			target.target_model = target:GetModelName()
		end

		target:SetOriginalModel(model)
	end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Reverts the target model back to what it was]]
function voodoo_end( keys )
	local target = keys.target

	-- Checking for errors
	if target.target_model ~= nil then
		target:SetModel(target.target_model)
		target:SetOriginalModel(target.target_model)
	end
end

--[[Author: Noya
	Date: 10.01.2015.
	Hides all dem hats
]]
function HideWearables( event )
	--[[
	local hero = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	print("Hiding Wearables")
	--hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable

	hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
	hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil then
            	-- Add the original model name to revert later
            	table.insert(hero.wearableNames,modelName)
            	print("Hidden "..modelName.."")

            	-- Set model invisible
            	model:SetModel("models/development/invisiblebox.vmdl")
            	table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
        	print("Next Peer:" .. model:GetModelName())
        end
    end]]
end

--[[Author: Noya
	Date: 10.01.2015.
	Shows the hidden hero wearables
]]
function ShowWearables( event )
	--[[
	local hero = event.target
	print("Showing Wearables on ".. hero:GetModelName())

	-- Iterate on both tables to set each item back to their original modelName
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				print("Changed "..v:GetModelName().. " back to "..modelName)
				v:SetModel(modelName)
			end
		end
	end]]
end

three_dimension_projectile = nil

function ItemAbility_three_dimension_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local caster = keys.Caster or keys.caster
	local target = keys.Target or keys.target
	
	-- Play the cast sound
	caster:EmitSound("DOTA_Item.EtherealBlade.Activate")

	-- Fire the projectile
	local projectile =
			{
				Target 				= target,
				Source 				= caster,
				Ability 			= ItemAbility,
				EffectName 			= "particles/items_fx/ethereal_blade.vpcf",
				iMoveSpeed			= 1275,
				vSourceLoc 			= caster:GetOrigin(),
				bDrawsOnMinimap 	= false,
				bDodgeable 			= true,
				bIsAttack 			= false,
				bVisibleToEnemies 	= true,
				bReplaceExisting 	= false,
				flExpireTime 		= GameRules:GetGameTime() + 20,
				bProvidesVision 	= false,
			}
	three_dimension_projectile = projectile
		ProjectileManager:CreateTrackingProjectile(projectile)
end

function ItemAbility_three_dimension_OnProjectileHitUnit(keys)
	-- print_r(three_dimension_projectile)
	local caster = keys.Caster or keys.caster
	local target = keys.Target or keys.target
	if is_spell_blocked(target,caster) then return end
	if target and not target:IsMagicImmune() then
		target:EmitSound("DOTA_Item.EtherealBlade.Target")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_item_three_dimension_debuff", {})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_item_three_dimension_debuff_movement_slow", {})
		-- if target:GetTeam() ~= caster:GetTeam() then
		-- end
	end
end

function ItemAbility_jiao_shou(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local cast_range = keys.AbilityCastRange
	local radius = keys.radius
	local effectradius = radius + 125
	caster:EmitSound("DOTA_Item.VeilofDiscord.Activate")
	local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf",PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target_point)
	ParticleManager:SetParticleControl(effectIndex, 1, Vector(effectradius, 1, 1))
	ParticleManager:ReleaseParticleIndex(effectIndex)
	local targets = FindUnitsInRadius(caster:GetTeam(),target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	for _,v in pairs(targets) do
		ability:ApplyDataDrivenModifier(caster, v, "modifier_item_jiao_shou_play_debuff", {duration = keys.Duration})
	end
end

function ItemAbility_zaiezhizhurenxing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.effect_radius
	local effect_radius = radius + 250
	local target_point = keys.target_points[1]
	caster:EmitSound("DOTA_Item.VeilofDiscord.Activate")
	local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf",PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target_point)
	ParticleManager:SetParticleControl(effectIndex, 1, Vector(effect_radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(effectIndex)
	local targets = FindUnitsInRadius(caster:GetTeam(),target_point, nil,radius, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	for _,v in pairs(targets) do
		ability:ApplyDataDrivenModifier(caster, v, "modifier_item_zaiezhizhurenxing_play_debuff", {duration = keys.Duration})
	end
end

function item_horse_red_active( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	if attacker:IsHero() then
		caster:RemoveModifierByName("modifier_item_horse_red_active")
	end
end

function item_horse_blue_active( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	if attacker:IsHero() then
		caster:RemoveModifierByName("modifier_item_horse_blue_active")
	end
end

--恨弓

LinkLuaModifier("modifier_grudge_bow_debuff_lua","scripts/vscripts/abilities/abilityItem.lua",LUA_MODIFIER_MOTION_NONE)
modifier_grudge_bow_debuff_lua = {}

function modifier_grudge_bow_debuff_lua:IsPurgable() 		 return true end
function modifier_grudge_bow_debuff_lua:IsPurgeException()	 return false end
function modifier_grudge_bow_debuff_lua:RemoveOnDeath()		 return false end
function modifier_grudge_bow_debuff_lua:IsHidden()			 return false end
function modifier_grudge_bow_debuff_lua:IsDebuff()			 return true end
function modifier_grudge_bow_debuff_lua:GetAttributes() 	 return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_grudge_bow_debuff_lua:GetEffectName()
	return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end

function modifier_grudge_bow_debuff_lua:GetEffectAttachType()
	return "follow_origin"
end

function modifier_grudge_bow_debuff_lua:OnCreated(keys)
	self.decrease_per_stack = self:GetAbility():GetSpecialValueFor("decrease_per_stack")
end

function modifier_grudge_bow_debuff_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_grudge_bow_debuff_lua:GetModifierMagicalResistanceBonus()
	return self.decrease_per_stack * self:GetStackCount()
end


function OnGrudgeBowAttackLanded(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local base_damage = ItemAbility:GetSpecialValueFor("damage")
	if Target:IsBuilding() or not Caster:IsRealHero() or not Target:IsAlive() then
		return
	end

	local spell_duration = ItemAbility:GetSpecialValueFor("duration")
	local max_stack = ItemAbility:GetSpecialValueFor("max_stack_amount")
	
	local grudgebow_debuff_name = "modifier_grudge_bow_debuff_lua"
	if Target:HasModifier(grudgebow_debuff_name) ~= true then
		Target:AddNewModifier(Caster, ItemAbility,grudgebow_debuff_name,  {Duration = spell_duration* (1 - Target:GetStatusResistance())} )
		Target:FindModifierByName(grudgebow_debuff_name):SetStackCount(1)
	else
	print("333")
		local stackcount = Target:FindModifierByName(grudgebow_debuff_name):GetStackCount()
		if stackcount < max_stack then
			Target:FindModifierByName(grudgebow_debuff_name):IncrementStackCount()
		end
		Target:FindModifierByName(grudgebow_debuff_name):SetDuration(spell_duration,true)
	end
	
	local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = base_damage,
			damage_type = DAMAGE_TYPE_MAGICAL, 
	}
	UnitDamageTarget(damage_table)
	
end


function ItemAbility_pomojinlingli_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	local duration = ItemAbility:GetSpecialValueFor("duration")
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	Target:AddNewModifier(Caster, ItemAbility, "modifier_item_pomojinlingli_silence", {duration = duration* (1 - Target:GetStatusResistance())})
end
modifier_item_pomojinlingli_silence = {}
LinkLuaModifier("modifier_item_pomojinlingli_silence","scripts/vscripts/abilities/abilityItem.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_item_pomojinlingli_silence:IsPurgable() 		 return true end
function modifier_item_pomojinlingli_silence:RemoveOnDeath()		 return true end
function modifier_item_pomojinlingli_silence:IsHidden()			 return false end
function modifier_item_pomojinlingli_silence:IsDebuff()			 return true end
function modifier_item_pomojinlingli_silence:GetEffectName()
	return "particles/econ/items/silencer/silencer_ti6/silencer_last_word_status_ti6_ring_mist.vpcf"
end

function modifier_item_pomojinlingli_silence:GetEffectAttachType()
	return "follow_origin"
end

function modifier_item_pomojinlingli_silence:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end
function modifier_item_pomojinlingli_silence:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.particle = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/storm_spirit_orchid_hat/storm_spirit_orchid.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
end
function modifier_item_pomojinlingli_silence:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle,true)
end

function yueyaomishi_AbilityExecuted(keys)
	local ItemAbility = keys.ability
	local caster = keys.caster
	local CurrentActiveAbility=keys.event_ability
	local duration = keys.ability:GetSpecialValueFor("duration")
	local max_level = keys.ability:GetSpecialValueFor("max_level")
	if IsNotLunchbox_ability(CurrentActiveAbility) then return end
	if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
		if not caster:HasModifier("modifier_item_yueyaomishi_spell_amplify_buff") then
			keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_yueyaomishi_spell_amplify_buff",{duration = duration})
			caster:SetModifierStackCount("modifier_item_yueyaomishi_spell_amplify_buff",keys.ability, 1)
		else
			local stack_count = keys.caster:GetModifierStackCount("modifier_item_yueyaomishi_spell_amplify_buff",keys.ability)
			if stack_count < max_level then 
				caster:SetModifierStackCount("modifier_item_yueyaomishi_spell_amplify_buff",keys.ability, stack_count + 1)
			end
			keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_yueyaomishi_spell_amplify_buff",{duration = duration})
		end
	end
end
------------------------------------------------------------------------------------------------
function zuzhoumujian_disable(keys)
	local target = keys.target
	local caster = keys.caster
	local duration = keys.ability:GetSpecialValueFor("duration")
	if caster:IsRealHero() then
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_item_zuzhoumujian_disable",{duration = duration})
	end
end