--减卡数量函数
function ItemAbility_SpendItem(keys)
	local ItemAbility = keys
	local Caster = keys:GetCaster()
	
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge>1) then
			ItemAbility:SetCurrentCharges(Charge-1)
		else
			Caster:RemoveItem(ItemAbility)
		end
	end
end

function ItemAbility_Cooldown(card)
	local caster = card:GetCaster()
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

item_card_good_man = {}

function item_card_good_man:OnSpellStart()
	if not IsServer() then return end
	local Caster = self:GetCaster()
	local Target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("slowdown_duration")
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if Target:IsBuilding() then
			return
		end
	end
	Target.good_man_slowdown_movespeed_percent = self:GetSpecialValueFor("slowdown_movespeed_percent") * (1 - Target:GetStatusResistance())
	Target.good_man_slowdown_attackspeed_percent = self:GetSpecialValueFor("slowdown_attackspeed_percent") * (1 - Target:GetStatusResistance())
	Target:AddNewModifier(Caster, self, "modifier_item_card_good_man_slowdown", {duration = duration})
	Caster.good_man_target = Target
	ItemAbility_Cooldown(self)
	ItemAbility_SpendItem(self)
end

modifier_item_card_good_man_slowdown = {}
LinkLuaModifier("modifier_item_card_good_man_slowdown", "scripts/vscripts/items/item_card.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_card_good_man_slowdown:IsHidden() return false end
function modifier_item_card_good_man_slowdown:IsDebuff() return true end
function modifier_item_card_good_man_slowdown:IsPurgable() return true end
function modifier_item_card_good_man_slowdown:RemoveOnDeath() return false end

function modifier_item_card_good_man_slowdown:GetEffectName()
	return "particles/thd2/items/item_good_man_card.vpcf"
end

function modifier_item_card_good_man_slowdown:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_card_good_man_slowdown:OnCreated()
	if not IsServer() then return end
	local ItemAbility = self:GetAbility()
	local Caster = self:GetCaster()
	local Target = self:GetParent()
	Caster:AddNewModifier(Caster, ItemAbility, "modifier_item_card_good_man_kill", {duration = ItemAbility:GetSpecialValueFor("slowdown_duration")})
end

function modifier_item_card_good_man_slowdown:OnDestroy()
	if not IsServer() then return end
	local Caster = self:GetCaster()
	Caster:RemoveModifierByName("modifier_item_card_good_man_kill")
end

function modifier_item_card_good_man_slowdown:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_card_good_man_slowdown:GetModifierMoveSpeedBonus_Percentage()
	return self:GetParent().good_man_slowdown_movespeed_percent
end

function modifier_item_card_good_man_slowdown:GetModifierAttackSpeedBonus_Constant()
	return self:GetParent().good_man_slowdown_attackspeed_percent
end

--好人卡击杀加钱机制
modifier_item_card_good_man_kill = {}
LinkLuaModifier("modifier_item_card_good_man_kill","scripts/vscripts/items/item_card.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_card_good_man_kill:IsHidden() 		return false end
function modifier_item_card_good_man_kill:IsPurgable()		return false end
function modifier_item_card_good_man_kill:RemoveOnDeath() 	return false end
function modifier_item_card_good_man_kill:IsDebuff()		return false end

function modifier_item_card_good_man_kill:DeclareFunctions()	
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_item_card_good_man_kill:OnDeath(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if keys.unit == self:GetCaster().good_man_target and keys.unit:IsRealHero() then
		keys.unit:SetContextThink("HasAegis",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if keys.unit:GetTimeUntilRespawn() > 5 then
				local PlayerID = caster:GetPlayerOwnerID()
				local min_time = math.floor(GameRules:GetDOTATime(false, false) /60)
				local totalgoldget = GetItemCost("item_card_good_man") + min_time * ability:GetSpecialValueFor("min_gold")
				print(totalgoldget)
				PlayerResource:SetGold(PlayerID,PlayerResource:GetUnreliableGold(PlayerID) + totalgoldget,false)
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(effectIndex)
				caster:EmitSound("DOTA_Item.Hand_Of_Midas")
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD,caster, totalgoldget, nil)
			end
		end
		,
		FrameTime())
	end
end

item_card_eat_man = {}
--[[
function item_card_eat_man:GetAOERadius()
	if self:GetCaster():GetLevel() >= self:GetSpecialValueFor("level_limit") then
		return self:GetSpecialValueFor("radius")
	else
		return
	end
end]]

function item_card_eat_man:CastFilterResultTarget(target)
	if target:GetUnitName() == "npc_dota_dark_troll_warlord_skeleton_warrior" then return end
	local game_minute = math.floor(GameRules:GetDOTATime(false, false) /60)

	if not target:IsNeutralUnitType() or target:GetTeamNumber() ~= 4 then
		return UF_FAIL_CUSTOM
	--吃远古判定
	elseif target:IsAncient() and game_minute < 10 --[[and self:GetCaster():GetLevel() < self:GetSpecialValueFor("level_limit")]] then
		return UF_FAIL_CUSTOM
	end
end

function item_card_eat_man:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local radius = self:GetSpecialValueFor("radius")
	local per_min = self:GetSpecialValueFor("per_min")

	local game_time = math.floor(GameRules:GetDOTATime(false, false) /60)
	local eat_num = math.floor(game_time/per_min)
	
	--特效音效
	local particle_pact = "particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf"
	local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_pact_fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_pact_fx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_pact_fx, 5, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_pact_fx)
	
	target:Kill(self,caster)

	caster:AddNewModifier(caster,self,"modifier_item_card_eat_man",{duration = self:GetSpecialValueFor("duration")})
	local targets = FindUnitsInRadius(caster:GetTeam(),target:GetOrigin(), nil,radius,self:GetAbilityTargetTeam(),
							 DOTA_UNIT_TARGET_CREEP,0,0,false)
	DeleteCreep(targets)
	-- if caster:GetLevel() < self:GetSpecialValueFor("level_limit") then
	-- 	DeleteAncient(targets)
	-- end
	table.sort(targets, function(a, b) if a:GetLevel()>b:GetLevel() then return true end end ) --根据等级排序，优先吃最高级的

	caster:EmitSound("Hero_Clinkz.DeathPact.Cast")

	ItemAbility_Cooldown(self)
	ItemAbility_SpendItem(self)

	for _,v in pairs (targets) do
		if eat_num <= 0 then
			break
		else

			--特效音效
			local particle_pact = "particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf"
			local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle_pact_fx, 0, v:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_pact_fx, 1, v:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_pact_fx, 5, v:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_pact_fx)

			v:Kill(self,caster)
			eat_num = eat_num - 1
		end
	end
end
modifier_item_card_eat_man = {}
LinkLuaModifier("modifier_item_card_eat_man", "scripts/vscripts/items/item_card.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_card_eat_man:IsHidden() return false end
function modifier_item_card_eat_man:IsDebuff() return false end
function modifier_item_card_eat_man:IsPurgable() return true end
function modifier_item_card_eat_man:RemoveOnDeath() return true end

function modifier_item_card_eat_man:GetEffectName()
	return "particles/items_fx/healing_tango.vpcf"
end

function modifier_item_card_eat_man:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_card_eat_man:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_item_card_eat_man:GetModifierConstantHealthRegen()
	return 4
end
function DeleteCreep(targets)--删除小兵单位
    for i=1,#targets do
    	if targets[i]:GetUnitName() == "npc_dota_dark_troll_warlord_skeleton_warrior" 
    		or targets[i]:GetUnitName() == "npc_dota_roshan"
    	then break end
        if not targets[i]:IsNeutralUnitType() or targets[i]:GetTeamNumber() ~= 4 then
            table.remove(targets, i)
            DeleteDummy(targets)
        end
    end
end

-- function DeleteAncient(targets)--删除远古单位
--     for i=1,#targets do
--     	if targets[i]:GetUnitName() == "npc_dota_dark_troll_warlord_skeleton_warrior" 
--     		or targets[i]:GetUnitName() == "npc_dota_roshan"
--     	then break end
--         if targets[i]:IsAncient() then
--             table.remove(targets, i)
--             DeleteDummy(targets)
--         end
--     end
-- end

item_card_kid_man = {}

function item_card_kid_man:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local d = self:GetSpecialValueFor("push_duration")
	local speed = self:GetSpecialValueFor("push_speed")
	local delay = self:GetSpecialValueFor("delay")
	local ability = self
	caster:SetContextThink(
					"kid_man",
					function ()
						if GameRules:IsGamePaused() then return 0.03 end
						caster:EmitSound("DOTA_Item.ForceStaff.Activate")
						local mod = caster:AddNewModifier(caster, ability, "modifier_item_card_kid_man", {duration = d,push_speed=speed})
						return nil
					end,
					delay)
	ItemAbility_Cooldown(self)
	ItemAbility_SpendItem(self)
end

modifier_item_card_kid_man = {}
LinkLuaModifier("modifier_item_card_kid_man","scripts/vscripts/items/item_card",LUA_MODIFIER_MOTION_NONE)

function modifier_item_card_kid_man:IsDebuff() return false end
function modifier_item_card_kid_man:IsHidden() return true end
function modifier_item_card_kid_man:IsPurgable() return false end
function modifier_item_card_kid_man:IsStunDebuff() return false end
function modifier_item_card_kid_man:IsMotionController()  return true end
function modifier_item_card_kid_man:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_item_card_kid_man:IgnoreTenacity()	return true end

function modifier_item_card_kid_man:OnCreated(keys)
	if not IsServer() then return end
	self.push_speed = keys.push_speed
	local particle_name = "particles/items_fx/force_staff.vpcf"
	--self.push_speed = self:GetAbility():GetSpecialValueFor("push_speed")
	self.pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self.angle = self:GetParent():GetForwardVector()
	self:StartIntervalThink(0.02)
end

function modifier_item_card_kid_man:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	-- FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetOrigin(),true)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_item_card_kid_man:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	--不摧毁树木
	-- GridNav:DestroyTreesAroundPoint(caster:GetOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), true)
	caster:SetOrigin(caster:GetOrigin() + self.angle * self.push_speed)
end

function modifier_item_card_kid_man:CheckState()
	return {
		[MODIFIER_STATE_ROOTED]		= true,
	}
end

item_card_moon_man = {}

function item_card_moon_man:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local movement_bonus = self:GetSpecialValueFor("movement_bonus")
	print(self:GetName())
	caster:EmitSound("DOTA_Item.SmokeOfDeceit.Activate")
	caster:AddNewModifier(caster, self, "modifier_item_card_moon_man", {duration = self:GetSpecialValueFor("duration")}):SetStackCount(movement_bonus)
	caster:AddNewModifier(caster, self, "modifier_smoke_of_deceit", {duration = self:GetSpecialValueFor("duration")})
	ItemAbility_Cooldown(self)
	ItemAbility_SpendItem(self)
end

modifier_item_card_moon_man = {}
LinkLuaModifier("modifier_item_card_moon_man","scripts/vscripts/items/item_card",LUA_MODIFIER_MOTION_NONE)

function modifier_item_card_moon_man:IsDebuff() return false end
function modifier_item_card_moon_man:IsHidden() return true end
function modifier_item_card_moon_man:IsPurgable() return false end
function modifier_item_card_moon_man:RemoveOnDeath() return true end
function modifier_item_card_moon_man:OnCreated()
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.visibility_radius = self.ability:GetSpecialValueFor("visibility_radius")
	self:StartIntervalThink(FrameTime())
end

function modifier_item_card_moon_man:OnIntervalThink()
	if not IsServer() then return end
	local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
                                      self.parent:GetAbsOrigin(),
                                      nil,
                                      self.visibility_radius,
                                      DOTA_UNIT_TARGET_TEAM_ENEMY,
                                      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING,
                                      DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                                      FIND_ANY_ORDER,
                                      false)
    for _,enemy in pairs(enemies) do
        if enemy:IsRealHero() or enemy:IsClone() or enemy:IsTower() then
            -- Found valid enemy in range - surprise attack! 
            self.parent:RemoveModifierByName("modifier_smoke_of_deceit")
            self:Destroy()
            return
        end
    end
end

function modifier_item_card_moon_man:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_item_card_moon_man:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

item_card_super_man = {}


function item_card_super_man:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	print(self:GetName())
	caster:EmitSound("THD_ITEM.SuperMan_Cast")
	caster:AddNewModifier(caster, self, "modifier_item_card_super_man", {duration = self:GetSpecialValueFor("duration"),value = self:GetSpecialValueFor("bonus_damage_percentage")})
	ItemAbility_Cooldown(self)
	ItemAbility_SpendItem(self)
end

modifier_item_card_super_man = {}
LinkLuaModifier("modifier_item_card_super_man","scripts/vscripts/items/item_card",LUA_MODIFIER_MOTION_NONE)

function modifier_item_card_super_man:IsDebuff() return false end
function modifier_item_card_super_man:IsHidden() return false end
function modifier_item_card_super_man:IsPurgable() return true end
function modifier_item_card_super_man:RemoveOnDeath() return true end
function modifier_item_card_super_man:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end
function modifier_item_card_super_man:GetModifierBonusStats_Strength()
	return self.value
end
function modifier_item_card_super_man:GetModifierBonusStats_Agility()
	return self.value
end
function modifier_item_card_super_man:GetModifierBonusStats_Intellect()
	return self.value
end
function modifier_item_card_super_man:OnCreated(keys)
	if not IsServer() then return end
	self.value = keys.value
	self.bonus_damage_percentage = self:GetAbility():GetSpecialValueFor("bonus_damage_percentage")
	local particle_name = "particles/econ/items/phantom_assassin/phantom_assassin_weapon_hells_usher/phantom_assassin_hells_usher_ambient.vpcf"
	self.superman_weapon = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW,self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.superman_weapon,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_attack1",Vector(0,0,0),true)
end
function modifier_item_card_super_man:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.superman_weapon,true)
end
--[[
function modifier_item_card_super_man:OnTakeDamage(keys)
	if not IsServer() then return end
	local caster = keys.attacker
	local target = keys.unit
	if keys.attacker:GetTeam() == keys.unit:GetTeam() then return end
	if keys.attacker == self:GetParent() then
		local particle_name = "particles/units/heroes/hero_void_spirit/void_spirit_void_bubble_explosion_electricity_expand.vpcf"
		self.superman_particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW,target)
		ParticleManager:SetParticleControlEnt(self.superman_particle,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
		ParticleManager:SetParticleControlEnt(self.superman_particle,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
		caster:SetContextThink("superman_damage",function ()
			self:Destroy()
		end, FrameTime())
	end
end
function modifier_item_card_super_man:GetModifierTotalDamageOutgoing_Percentage()
	return self.bonus_damage_percentage
end]]

--商店卡片购买程序，由于中立的装备栏无法设置商店个数，所以设置买到物品栏卡自动变成中立掉落卡

item_card_kid_man_shop = {}
function item_card_kid_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_good_man_shop = {}
function item_card_good_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_bad_man_shop = {}
function item_card_bad_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_worse_man_shop = {}
function item_card_worse_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_love_man_shop = {}
function item_card_love_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_eat_man_shop = {}
function item_card_eat_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_moon_man_shop = {}
function item_card_moon_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end
item_card_super_man_shop = {}
function item_card_super_man_shop:GetIntrinsicModifierName()
	return "modifier_item_card_shop"
end


modifier_item_card_shop = {}
LinkLuaModifier("modifier_item_card_shop","scripts/vscripts/items/item_card",LUA_MODIFIER_MOTION_NONE)

function modifier_item_card_shop:OnCreated()
	if not IsServer() then return end
	print("card-------------------------")
	print(self:GetAbility():GetName())
	print(self:GetAbility():GetCurrentCharges())
	self:StartIntervalThink(FrameTime())
end

function modifier_item_card_shop:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	for i=1,self:GetAbility():GetCurrentCharges() do
		if ability:GetName() == "item_card_kid_man_shop" then
			caster:AddItemByName("item_card_kid_man")
		elseif ability:GetName() == "item_card_eat_man_shop" then
			caster:AddItemByName("item_card_eat_man")
		elseif ability:GetName() == "item_card_good_man_shop" then
			caster:AddItemByName("item_card_good_man")
		elseif ability:GetName() == "item_card_worse_man_shop" then
			caster:AddItemByName("item_card_worse_man")
		elseif ability:GetName() == "item_card_bad_man_shop" then
			caster:AddItemByName("item_card_bad_man")
		elseif ability:GetName() == "item_card_love_man_shop" then
			caster:AddItemByName("item_card_love_man")
		elseif ability:GetName() == "item_card_moon_man_shop" then
			caster:AddItemByName("item_card_moon_man")
		elseif ability:GetName() == "item_card_super_man_shop" then
			caster:AddItemByName("item_card_super_man")
		end
	end
	self:GetAbility():RemoveSelf()
	self:Destroy()
end