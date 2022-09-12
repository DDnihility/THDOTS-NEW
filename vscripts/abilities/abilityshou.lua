abilityshou = class({})
SHOU01INTERVAL = 0
count01 = 0
ZDCS = 1
ZDCS_FLAG = true
SHOUEX_COUNT = 0

function Shou01AddParticle( keys )
	-- body
	local caster = keys.caster
	local effectIndex = ParticleManager:CreateParticle(
		"particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave_playerglow.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		caster)
	SHOU01_EFFECT_INDEX = effectIndex
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack2", Vector(0,0,0), true)
end

function OnShou01SpellStart( keys )
	-- body
	local caster = keys.caster
	SHOU01INTERVAL = SHOU01INTERVAL + 0.1
end

function OnShou01AttackLanded( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(target) then return end
	local duration = keys.duration
	local damage = keys.damage
	local stun_bonus = keys.stun_bonus
	if not target:IsBuilding() then
		local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = damage + caster:GetIntellect()*1.5,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
		}
		UtilStun:UnitStunTarget(caster,target,(duration - SHOU01INTERVAL) * stun_bonus)
		SHOU01INTERVAL = 0
		ParticleManager:DestroyParticleSystem(SHOU01_EFFECT_INDEX, true)
		UnitDamageTarget(damage_table)
	--特效
	--音效
	end
end

function OnShou01OnDestroy( keys )
	-- body
	SHOU01INTERVAL = 0
	ParticleManager:DestroyParticleSystem(SHOU01_EFFECT_INDEX, true)
end

function OnShou02SpellStart( keys )
	-- body
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local targetPoint =keys.ability:GetCursorPosition()
	local distance = targetPoint - caster:GetAbsOrigin()
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) --自制的charge系统，现已经被Dota2的AbilityCharge取代。
	local count = caster:GetModifierStackCount("modifier_ability_thdots_shou02", caster)
	if count > 1 then
		--充能大于1，CD好，层数减一
		keys.ability:EndCooldown()
		caster:SetModifierStackCount("modifier_ability_thdots_shou02", caster, count - 1)
	elseif count == 1 then --充能等于1，CD好，层数减1， 计数器归零
		keys.ability:EndCooldown()
		caster:SetModifierStackCount("modifier_ability_thdots_shou02", caster, count - 1)
		ability:SetContextNum("ability_Shou02_Count",0,0)
		count01 = math.abs(ability:GetContext("ability_Shou02_Count"))
	end
	-- local effectIndex = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_arcana/rbck_arc_skywrath_mage_mystic_flare_beam.vpcf", PATTACH_POINT, caster)
	-- ParticleManager:SetParticleControl(effectIndex, 0, targetPoint)
	-- ParticleManager:DestroyParticleSystem(effectIndex,false)
	-- effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff_f.vpcf", PATTACH_POINT, caster)
	-- ParticleManager:SetParticleControl(effectIndex, 0, targetPoint)
	-- ParticleManager:DestroyParticleSystem(effectIndex,false)
	-- local view = AddFOWViewer(caster:GetTeam(), targetPoint, 8, 5, false)
	local light = CreateUnitByName(
			"npc_ability_shou_02_light"
			,targetPoint
			,false
			,caster
			,caster
			,caster:GetTeam()
	)
	local ability_dummy_unit = light:FindAbilityByName("ability_dummy_unit")
	ability:ApplyDataDrivenModifier(caster, light, "modifier_ability_thdots_shou02_light", {})
	ability_dummy_unit:SetLevel(1)
end

function Shou02Light(keys)
	-- body
	local caster = keys.caster
	local unit = keys.target
	local radius = keys.radius
	local damage = keys.damage
	local ability = keys.ability
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_arcana/rbck_arc_skywrath_mage_mystic_flare_beam.vpcf", PATTACH_POINT, unit)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff_f.vpcf", PATTACH_POINT, unit)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	targets = FindUnitsInRadius(caster:GetTeam(), unit:GetOrigin(), nil, keys.radius, ability:GetAbilityTargetTeam(),	ability:GetAbilityTargetType(), 0,0,false)
	if targets then 
		for _,v in pairs (targets) do
			local damage_table = {
				ability = keys.ability,
				victim = v,
				attacker = caster,
				damage = damage + caster:GetIntellect() * 1.4,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
			unit:EmitSound("Hero_StormSpirit.StaticRemnantExplode")
			unit:EmitSound("Hero_Earthshaker.Enchant")
			unit:RemoveModifierByName("modifier_ability_thdots_shou02_light")
			unit:ForceKill(true)
			effectIndex = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge.vpcf", PATTACH_POINT, unit)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
		end
	end
end

function OnShou02IntervalThink( keys )
	--每0.1秒增加层数1层。当有层数的时候，让CD转好
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local count = caster:GetModifierStackCount("modifier_ability_thdots_shou02", caster)
	if ZDCS_FLAG == true and FindTelentValue(caster,"special_bonus_unique_shou_1") == 2 then 	--天赋加最大层数
		ZDCS = ZDCS + FindTelentValue(caster,"special_bonus_unique_shou_1")
		ZDCS_FLAG = false
	end
	if(keys.ability:GetContext("ability_Shou02_Count") == nil)then
		--设置内置计数器
	    ability:SetContextNum("ability_Shou02_Count",0,0)
		count01 = math.abs(ability:GetContext("ability_Shou02_Count"))
	end
	if count01 >= cooldown then  --若计时器转满
			caster:SetModifierStackCount("modifier_ability_thdots_shou02", caster, count + 1) --层数+1
			if count >= ZDCS then --若达到最大层数
				caster:SetModifierStackCount("modifier_ability_thdots_shou02", caster, ZDCS) 
				count01 = 0 --设置计时器为冷却CD时间
			else
				ability:SetContextNum("ability_Shou02_Count",cooldown - count01,0) --计数器归零
				count01 = math.abs(ability:GetContext("ability_Shou02_Count"))
			end
	else   --若计时器小于当前技能CD时间，则继续计时
		if count ~= ZDCS then
			ability:SetContextNum("ability_Shou02_Count",count01 + 0.1,0)
			count01 = math.abs(ability:GetContext("ability_Shou02_Count"))
		end
		if ability:GetCooldownTime() > 0 and count > 0 then --若技能还在转CD时
			if count >= 1 then 				--有层数，则CD好，层数-1，计数器不变
				keys.ability:EndCooldown()
				caster:SetModifierStackCount("modifier_ability_thdots_shou02", caster, count - 1)
			else  --若无层数，则CD好，计数器清零
				ability:SetContextNum("ability_Shou02_Count",cooldown - count01,0)
				count01 = math.abs(ability:GetContext("ability_Shou02_Count"))
			end
		end
	end
end

function Shou02Destory( keys )
	-- body
	local unit = keys.target
	unit:ForceKill(true)
end

function Shou03OnKill( keys )
	-- body
	local caster = keys.caster
	local target = keys.unit
	local damage = keys.damage
	local radius = keys.radius
	local count = caster:GetModifierStackCount("modifier_ability_thdots_shouEx", caster)
	local casterPlayerID = caster:GetPlayerOwnerID()
	local GoldBountyAmount=keys.gold_bonus + FindTelentValue(caster,"special_bonus_unique_shou_2")
	target:EmitSound("Hero_Sandking.CausticBodyexplode")
	caster.ItemAbility_DonationGem_TriggerTime=GameRules:GetGameTime()	--加钱
	PlayerResource:SetGold(casterPlayerID,PlayerResource:GetUnreliableGold(casterPlayerID) + GoldBountyAmount,false)
	SendOverheadEventMessage(caster:GetOwner(),OVERHEAD_ALERT_GOLD,caster,GoldBountyAmount,nil)
	if count < 6 then
		caster:SetModifierStackCount("modifier_ability_thdots_shouEx", caster, count + 1)
	end
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effectIndex , 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	effectIndex = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(),nil,radius,keys.ability:GetAbilityTargetTeam(),keys.ability:GetAbilityTargetType(),0,0,false)
	for _,v in pairs (targets) do
		local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = damage,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		effectIndex = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion_streak.vpcf", PATTACH_POINT, v)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		UtilStun:UnitStunTarget(caster,v,keys.stun_duration)
		UnitDamageTarget(damage_table)
		--特效待测
	end
end

function Shou03Think(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_item_wanbaochui") then
		caster:AddNewModifier(caster, ability, "modifier_ability_thdots_shou_wanbaochui",{})
	elseif caster:HasModifier("modifier_ability_thdots_shou_wanbaochui") then
		caster:RemoveModifierByName("modifier_ability_thdots_shou_wanbaochui")
	end
end

modifier_ability_thdots_shou_wanbaochui=class({})
LinkLuaModifier("modifier_ability_thdots_shou_wanbaochui","scripts/vscripts/abilities/abilityshou.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_shou_wanbaochui:IsHidden()      return true end
function modifier_ability_thdots_shou_wanbaochui:IsPurgable()        return false end
function modifier_ability_thdots_shou_wanbaochui:RemoveOnDeath()     return false end
function modifier_ability_thdots_shou_wanbaochui:IsDebuff()      return false end

function modifier_ability_thdots_shou_wanbaochui:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_ability_thdots_shou_wanbaochui:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.amplify_gold = self:GetAbility():GetSpecialValueFor("amplify_gold")
	self.amplify = 0
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_shou_wanbaochui:OnIntervalThink()
	if not IsServer() then return end
	self.amplify = math.floor(self.caster:GetGold()/self.amplify_gold)
	self:SetStackCount(self.amplify)
end

function modifier_ability_thdots_shou_wanbaochui:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end

function modifier_ability_thdots_shou_wanbaochui:OnDeath(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() and keys.unit:IsRealHero() then
		print(keys.unit:GetTimeUntilRespawn())
		keys.unit:SetContextThink("HasAegis",
		function()
			if keys.unit:GetTimeUntilRespawn() > 5 then
				print("no aeigs")
				local caster = self:GetParent()
				local casterPlayerID = caster:GetPlayerOwnerID()
				local GoldBountyAmount= self:GetAbility():GetSpecialValueFor("reduce_gold") * caster:GetGold() / 100
				print(GoldBountyAmount)
				PlayerResource:SetGold(casterPlayerID,PlayerResource:GetUnreliableGold(casterPlayerID) + GoldBountyAmount ,false)
				-- SendOverheadEventMessage(caster:GetOwner(),OVERHEAD_ALERT_GOLD,caster,GoldBountyAmount,nil)
			end
		end
		,
		0.03)
	end
end

function ShouExThink( keys )
	-- body
	local caster = keys.caster
	local ability = keys.ability
	local count = caster:GetModifierStackCount("modifier_ability_thdots_shouEx", caster)
	SHOUEX_COUNT = SHOUEX_COUNT + 1
	if SHOUEX_COUNT >= keys.persecond and count < keys.max then
		caster:SetModifierStackCount("modifier_ability_thdots_shouEx", caster, count + 1)
		SHOUEX_COUNT = 0
	end
	if count >= keys.max then
		SHOUEX_COUNT = 0
	end
	--天赋监听
	-- if FindTelentValue(caster,"special_bonus_unique_shou_1") ~= 0 and not caster:HasModifier("modifier_ability_thdots_shouEx_talent1") then
	-- 	print("shou02")
	-- 	caster:AddNewModifier(caster,ability,"modifier_ability_thdots_shouEx_talent1",{})
	-- 	-- caster:FindAbilityByName("ability_thdots_shou02"):SetCurrentAbilityCharges(FindTelentValue(caster,"special_bonus_unique_shou_1"))
	-- 	caster:FindAbilityByName("ability_thdots_shou02"):SetCurrentAbilityCharges(4)
	-- end
end

-- modifier_ability_thdots_shouEx_talent1 = {}  --天赋监听
-- LinkLuaModifier("modifier_ability_thdots_shouEx_talent1","scripts/vscripts/abilities/abilityshou.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_shouEx_talent1:IsHidden() 		return true end
-- function modifier_ability_thdots_shouEx_talent1:IsPurgable()		return false end
-- function modifier_ability_thdots_shouEx_talent1:RemoveOnDeath() 	return false end
-- function modifier_ability_thdots_shouEx_talent1:IsDebuff()		return false end

function ShouExOnSpellStart( keys )
	-- body
	local caster = keys.caster
	local ability = keys.ability
	local regen = keys.regen
	local count = caster:GetModifierStackCount("modifier_ability_thdots_shouEx", caster)
	if count >= 1 and not keys.event_ability:IsItem() and caster:GetHealth() ~= caster:GetMaxHealth() and caster:GetMana() ~= caster:GetMaxMana() then
		-- caster:SetHealth(caster:GetHealth() + (caster:GetMaxHealth()*regen))
		caster:Heal((caster:GetMaxHealth()*regen),caster)
		caster:SetMana(caster:GetMana() + (caster:GetMaxMana()*regen))
		caster:SetModifierStackCount("modifier_ability_thdots_shouEx", caster, count - 1 )
	end
end

ability_thdots_shou04 = {}

function ability_thdots_shou04:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self, level)
	local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_shou_3")
	if telent ~= nil then
		cd = cd + telent:GetSpecialValueFor("value")
	end
	return cd
end

function ability_thdots_shou04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	local length = self:GetSpecialValueFor("length")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local stun = self:GetSpecialValueFor("stun")
	Shou04OnSpellStart({
		caster = caster,
		ability = self
	})
	caster:EmitSound("Hero_ElderTitan.EchoStomp.Channel")
	caster:EmitSound("Hero_ElderTitan.EchoStomp.Channel")
	caster:EmitSound("Hero_ElderTitan.EchoStomp.Channel")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_shou04_stun", {duration = 1.2})
	Timer.Wait "Shou04DelayedAction" (1.2,
		function ()
			Shou04DelayedAction({
				caster = caster,
				ability = ability,
				length = length,
				radius = radius,
				damage = damage,
				stun = stun
			})
		end
	)
end

function Shou04OnSpellStart( keys )
	-- body
	local caster = keys.caster
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_6,0.17)
	caster.point = keys.ability:GetCursorPosition()
end

function Shou04DelayedAction( keys )
	-- body
	local caster = keys.caster
	if not caster:IsAlive() then return end 
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
	-- THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_shou_3"))
	local targetPoint = caster.point
	FindClearSpaceForUnit(caster, targetPoint, false)
	StartSoundEventFromPosition("Hero_EarthShaker.EchoSlam", caster:GetOrigin())
	caster:AddNewModifier(caster, keys.ability, "modifier_ability_thdots_shou04", {Duration = 2})
	SHOU04_POINT = caster:GetAbsOrigin()
	SHOU04_VEC = caster:GetForwardVector()
	shou04_x = SHOU04_VEC.x
	ABS_VEC = math.acos(shou04_x) --相对地图的面向角度
	for k=0,4 do
		local rad = Vector(math.cos(ABS_VEC+math.pi/2.5*k),math.sin(ABS_VEC+math.pi/2.5*k),0) --五个方向
		local targets = FindUnitsInLine(caster:GetTeam(), SHOU04_POINT, SHOU04_POINT + rad * keys.length, nil, keys.radius, keys.ability:GetAbilityTargetTeam(), keys.ability:GetAbilityTargetType(), 0)
		for _,v in pairs (targets) do
			v:AddNewModifier(caster, keys.ability, "modifier_ability_thdots_shou04_damage", {duration = 1})
			UtilStun:UnitStunTarget(caster,v,keys.stun)
		end
	end
end

modifier_ability_thdots_shou04_stun = {}
LinkLuaModifier("modifier_ability_thdots_shou04_stun", "scripts/vscripts/abilities/abilityshou.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_shou04_stun:IsHidden() return true end
function modifier_ability_thdots_shou04_stun:IsPurgable() return false end
function modifier_ability_thdots_shou04_stun:RemoveOnDeath() return true end
function modifier_ability_thdots_shou04_stun:IsDebuff() return false end
function modifier_ability_thdots_shou04_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

modifier_ability_thdots_shou04 = {}
LinkLuaModifier("modifier_ability_thdots_shou04", "scripts/vscripts/abilities/abilityshou.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_shou04:IsHidden() return true end
function modifier_ability_thdots_shou04:IsPurgable() return false end
function modifier_ability_thdots_shou04:RemoveOnDeath() return false end
function modifier_ability_thdots_shou04:IsDebuff() return false end

function modifier_ability_thdots_shou04:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ability_thdots_shou04:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	for k=0,4 do
		local rad = Vector(math.cos(ABS_VEC+math.pi/2.5*k),math.sin(ABS_VEC+math.pi/2.5*k),0)
		for i=1,10 do
			effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff_f.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(effectIndex,0, SHOU04_POINT + rad *i* 100)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
		end
	end
end

modifier_ability_thdots_shou04_damage = {}
LinkLuaModifier("modifier_ability_thdots_shou04_damage", "scripts/vscripts/abilities/abilityshou.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_shou04_damage:IsHidden() return true end
function modifier_ability_thdots_shou04_damage:IsPurgable() return false end
function modifier_ability_thdots_shou04_damage:RemoveOnDeath() return true end
function modifier_ability_thdots_shou04_damage:IsDebuff() return true end

function modifier_ability_thdots_shou04_damage:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local damage_table = {
		ability = ability,
		victim = parent,
		attacker = caster,
		damage = ability:GetSpecialValueFor("damage") + caster:GetIntellect() * 1.8,
		damage_type = ability:GetAbilityDamageType(), 
		damage_flags = 0
	}
	UnitDamageTarget(damage_table)
end
