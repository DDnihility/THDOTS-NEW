refresh_mod = {}
LinkLuaModifier("refresh_mod","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function refresh_mod:IsHidden() 		return false end     --是否隐藏
function refresh_mod:IsPurgable()     return false end     --是否可净化
function refresh_mod:RemoveOnDeath() 	return false end     --死亡移除
function refresh_mod:IsDebuff()	   	return false end     --是否是DEBUFF

ability_thdots_kasenEx = {}

function ability_thdots_kasenEx:OnAbilityPhaseStart()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_thdots_kasen_ex") then return true end
	self:GetCaster():EmitSound("kasenEx_11")
	return true
end

function ability_thdots_kasenEx:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_thdots_kasen_ex") then
		return "custom/kasen/ability_thdots_kasenex"
	else
		return "custom/kasen/ability_thdots_kasenex_shadow"
	end
end
--function ability_thdots_kasenEx:GetIntrinsicModifierName()
--	return "modifier_thdots_kasen_ex_WBC_check"
--end
function ability_thdots_kasenEx:OnHeroLevelUp()
	local ability_lvl=math.floor(self:GetCaster():GetLevel()/6) + 1
	if ability_lvl ~= self:GetLevel() and ability_lvl < 5 then
		self:SetLevel(ability_lvl)
	end
end

function ability_thdots_kasenEx:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration =self:GetSpecialValueFor("duration")
	if  not caster:HasModifier("modifier_thdots_kasen_ex") then
		caster:AddNewModifier(caster,self,"modifier_thdots_kasen_ex",{duration = duration})
		self:EndCooldown()
	else
		local Cooldown = caster:FindModifierByName("modifier_thdots_kasen_ex"):GetRemainingTime()
		caster:RemoveModifierByName("modifier_thdots_kasen_ex")
		self:EndCooldown()
		self:StartCooldown(Cooldown)
	end
	caster:AddNewModifier(self:GetCaster(),self,"refresh_mod",{duration = 0.03})
end
function ability_thdots_kasenEx:OnInventoryContentsChanged()
	if not IsServer() then return end
	local ability = self:GetCaster():FindAbilityByName("ability_thdots_kasen04_ex_WBC")
    if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		ability:SetHidden(false)
	else
		ability:SetHidden(true)
	end	
end
modifier_thdots_kasen_ex = {}
LinkLuaModifier("modifier_thdots_kasen_ex","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen_ex:IsHidden() 		return false end     --是否隐藏
function modifier_thdots_kasen_ex:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen_ex:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen_ex:IsDebuff()	   	return false end     --是否是DEBUFF

function modifier_thdots_kasen_ex:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_thdots_kasen_ex:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("strength_bonus_ex")
end
function modifier_thdots_kasen_ex:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability =self:GetAbility()
	self:StartIntervalThink(2)
	self.lock=0
	self.particle = ParticleManager:CreateParticle("models/ibaraki_kasen/ibaraki_kasen2_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW,caster)
		caster:SetOriginalModel("models/ibaraki_kasen/ibaraki_kasen_2.vmdl")
		caster:SwapAbilities("ability_thdots_kasen04","ability_thdots_kasen04_ex",false,true)
		local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		--禁用1技能
		ability = caster:FindAbilityByName("ability_thdots_kasen01")	
		ability:SetActivated(false)
		--启用2技能
		ability = caster:FindAbilityByName("ability_thdots_kasen02")
		ability:SetActivated(true)
		--禁用3技能
		ability = caster:FindAbilityByName("ability_thdots_kasen03")	
		ability:SetActivated(false)
end

function modifier_thdots_kasen_ex:OnIntervalThink()
	if not IsServer() then return end
	local caster=self:GetCaster()
	if self.lock==1 then return end
	if RandomInt(1,2)==1 then
	print("1")
	    caster:EmitSound("kasenEx_12")
	else
	print("2")
		caster:EmitSound("kasenEx_22")
	end
	self.lock=1
end

function modifier_thdots_kasen_ex:OnRemoved()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability =self:GetAbility()
	caster:SetOriginalModel("models/ibaraki_kasen/ibaraki_kasen_1.vmdl")	
	caster:SwapAbilities("ability_thdots_kasen04_ex","ability_thdots_kasen04",false,true)

	ParticleManager:DestroyParticleSystem(self.particle,true)
	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	--启用1技能
	ability = caster:FindAbilityByName("ability_thdots_kasen01")	
	ability:SetActivated(true)
	--禁用2技能
	ability = caster:FindAbilityByName("ability_thdots_kasen02")
	ability:SetActivated(false)
	--启用3技能
	ability = caster:FindAbilityByName("ability_thdots_kasen03")	
	ability:SetActivated(true)
	caster:AddNewModifier(caster,self,"refresh_mod",{duration = 0.03})
end

ability_thdots_kasenEx_WBC = {}

function ability_thdots_kasenEx_WBC:GetIntrinsicModifierName()
	return "modifier_thdots_kasen_ex_WBC_check"
end
modifier_thdots_kasen_ex_WBC_check ={}
LinkLuaModifier("modifier_thdots_kasen_ex_WBC_check","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen_ex_WBC_check:IsHidden() 			return true end
function modifier_thdots_kasen_ex_WBC_check:IsPurgable()			return false end
function modifier_thdots_kasen_ex_WBC_check:RemoveOnDeath() 		return false end
function modifier_thdots_kasen_ex_WBC_check:IsDebuff()				return false end

function modifier_thdots_kasen_ex_WBC_check:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_thdots_kasen_ex_WBC_check:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	if FindTelentValue(caster,"special_bonus_unique_kasen_6") ~= 0 and not caster:HasModifier("modifier_thdots_kasen_ex_WBC")then
		caster:FindAbilityByName("ability_thdots_kasenEx_WBC"):SetHidden(false)
		--caster:FindAbilityByName("ability_thdots_kasenEx"):SetHidden(true)
		caster:AddNewModifier(caster,self:GetAbility(),"modifier_thdots_kasen_ex_WBC",{duration = -1})
	end
end

modifier_thdots_kasen_ex_WBC = {}
LinkLuaModifier("modifier_thdots_kasen_ex_WBC","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen_ex_WBC:IsHidden() 		return false end     --是否隐藏
function modifier_thdots_kasen_ex_WBC:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen_ex_WBC:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen_ex_WBC:IsDebuff()	   	return false end     --是否是DEBUFF

function modifier_thdots_kasen_ex_WBC:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability
	if caster:HasModifier("modifier_thdots_kasen_ex") then 
		caster:RemoveModifierByName("modifier_thdots_kasen_ex")
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5,1)
		self.particle = ParticleManager:CreateParticle("models/ibaraki_kasen/ibaraki_kasen3_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:CreateParticle("models/ibaraki_kasen/ibaraki_kasen3_die.vpcf", PATTACH_ABSORIGIN_FOLLOW,self.caster)
		caster:SetOriginalModel("models/ibaraki_kasen/ibaraki_kasen_3.vmdl")
		--启用1技能
		ability = caster:FindAbilityByName("ability_thdots_kasen01")	
		ability:SetActivated(true)
		--启用2技能
		ability = caster:FindAbilityByName("ability_thdots_kasen02")
		ability:SetActivated(true)
		--启用3技能
		ability = caster:FindAbilityByName("ability_thdots_kasen03")	
		ability:SetActivated(true)

		ability = caster:FindAbilityByName("ability_thdots_kasenEx"):SetHidden(true)
	caster:SwapAbilities("ability_thdots_kasenEx","ability_thdots_kasen04_ex",false,true)
	self:StartIntervalThink(1)
end
function modifier_thdots_kasen_ex_WBC:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_thdots_kasen_ex_WBC:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("strength_bonus")
end
function modifier_thdots_kasen_ex_WBC:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_reduction")
end
function modifier_thdots_kasen_ex_WBC:OnAbilityStart(keys)
	if not IsServer() then return end
	local Parent = self:GetParent()
	if Parent ~= keys.unit or keys.ability:IsItem() then return end
	--print(Parent:GetHealth() )
	local pct = self:GetAbility():GetSpecialValueFor("lose_health") * 0.01
	local damage = Parent:GetHealth() * pct
	local damage_table = {
		ability = self:GetAbility(),
		victim = Parent,
		attacker = Parent,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE, 
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}
	--print(damage)
	UnitDamageTarget(damage_table)
end

function modifier_thdots_kasen_ex_WBC:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local Strength = caster:GetStrength()
	local Health_pct = 1 - caster:GetHealth()/caster:GetMaxHealth()
	local Heal_pct = ability:GetSpecialValueFor("max_heal_pct")*0.01
	if Health_pct < 0.7 then
		 Heal_pct = (Health_pct)*ability:GetSpecialValueFor("max_heal_pct")*0.01
	end
	local HealAmount = Strength * Heal_pct
	print(HealAmount)
	caster:Heal(HealAmount,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,HealAmount,nil)
end

function Kasen04_OnUpgrade(keys)
	local caster = keys.caster
	local ability01 = caster:FindAbilityByName("ability_thdots_kasen04")
	local ability02 = caster:FindAbilityByName("ability_thdots_kasen04_ex")
	if caster:GetClassname()~="npc_dota_hero_bristleback" then return end
	if caster.upgrading == nil then caster.upgrading = false end
	local ability=keys.ability
	if ability==ability01 and caster.upgrading~=true then
		caster.upgrading = true
		ability02:SetLevel(ability01:GetLevel())
		caster.upgrading = false 
	elseif ability==ability02 and caster.upgrading~=true then
		caster.upgrading = true
		ability01:SetLevel(ability02:GetLevel())
		caster.upgrading = false
	end
end

function Kasen02_OnUpgrade(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_thdots_kasen_ex") == false and caster:HasModifier("modifier_thdots_kasen_ex_WBC") == false then
		keys.ability:SetActivated(false)
	end
end
--///////////////////////////////////
--//*猿之手啊！捏碎敌人*
--///////////////////////////////////
ability_thdots_kasen01 = {}
function ability_thdots_kasen01:GetAOERadius() 
	local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("special_bonus_unique_kasen_2")
    local value = 0
    if(ability ~= nil) then
        value = ability:GetSpecialValueFor("value")
    end
    return self:GetSpecialValueFor("radius") + value
end
function ability_thdots_kasen01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("duration_damage") * self:GetSpecialValueFor("think_interval")
	local PointPosition = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius") + FindTelentValue(caster,"special_bonus_unique_kasen_2")
	local speed = self:GetSpecialValueFor("speed")/20
	local buff_duration = self:GetSpecialValueFor("buff_duration")+ FindTelentValue(caster,"special_bonus_unique_kasen_1")
	local time = 0
	EmitSoundOn("Hero_Enigma.Black_Hole", caster)
	self.pfx = ParticleManager:CreateParticle("particles/heroes/kasen/kasen01.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.pfx, 0, PointPosition)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(radius, radius, radius))
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("kasen01"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time >= duration or caster:IsChanneling()==false then 					
				return nil 
			end								
			local targets = FindUnitsInRadius(
				caster:GetTeam(),						--team
				PointPosition, 							--location
				nil, 									--cacheUnit
				radius,									--radius
				self:GetAbilityTargetTeam(),	--teamFilter
				self:GetAbilityTargetType(),	--type
				0,										--flag
				0,										--order
				false 									--canGrowCache
				)
			for _,v in pairs(targets) do
				if v:IsRealHero() then
					--增加力量
					caster:AddNewModifier(caster, self, "modifier_thdots_kasen01_buff_strength", {duration = buff_duration})	
					--减少力量
					v:AddNewModifier(caster, self, "modifier_thdots_kasen01_debuff_strength", {duration = buff_duration})
				end
				local damage_table = {
								ability = self,
								victim = v,
								attacker = caster,
								damage = damage,
								damage_type = self:GetAbilityDamageType(), 
								damage_flags = self:GetAbilityTargetFlags()
							}
				UnitDamageTarget(damage_table)
			end
			time = time + 0.5	
			return 0.5
		end,
	0)

	local time02 = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("kasen01move"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time02 >= duration-0.23 or caster:IsChanneling()==false then 
				return nil 
			end
				time02 = time02 + 0.06
				local targets = FindUnitsInRadius(
					caster:GetTeam(),						--team
					PointPosition, 							--location
					nil, 									--cacheUnit
					radius,									--radius
					self:GetAbilityTargetTeam(),	--teamFilter
					self:GetAbilityTargetType(),	--type
					0,										--flag
					0,										--order
					false 									--canGrowCache
					)
				for _,v in pairs(targets) do
					if IsTHDImmune(v)==false then
						local unit_location = v:GetAbsOrigin()
						local vector_distance = PointPosition - unit_location
						local distance = (vector_distance):Length2D()
						local direction = (vector_distance):Normalized()
						--128内吸引	
						FindClearSpaceForUnit(v, unit_location + direction * speed, true)
						ResolveNPCPositions(PointPosition, radius)
						UtilStun:UnitStunTarget(caster, v, 0.06)
					end					
				end			
			return 0.06			
		end,
	0)
end
function  ability_thdots_kasen01:OnChannelThink(fInterval)
	if not IsServer() then return end
end
function ability_thdots_kasen01:OnChannelFinish()
	if not IsServer() then return end
	local caster = self:GetCaster()
	ParticleManager:DestroyParticleSystem(self.pfx,true)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	EmitSoundOn("Hero_Enigma.Black_Hole.Stop", caster)
	StopSoundOn("Hero_Enigma.Black_Hole", caster)
end
function ability_thdots_kasen01:GetIntrinsicModifierName()
	return "modifier_thdots_kasen01_Passive"
end
modifier_thdots_kasen01_Passive = {}
LinkLuaModifier("modifier_thdots_kasen01_Passive","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen01_Passive:IsHidden() 		return true end     --是否隐藏
function modifier_thdots_kasen01_Passive:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen01_Passive:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen01_Passive:IsDebuff()	   	return false end     --是否是DEBUFF
function modifier_thdots_kasen01_Passive:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_thdots_kasen01_Passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = keys.attacker
	if caster ~=self:GetCaster() then return end
	local ability =self:GetAbility()
	local target = keys.target
	local buff_duration = ability:GetSpecialValueFor("buff_duration")+ FindTelentValue(caster,"special_bonus_unique_kasen_1")
	local chance = self:GetAbility():GetSpecialValueFor("chance") + FindTelentValue(caster,"special_bonus_unique_kasen_3")
	if target:IsRealHero() and  RandomInt(0,100) < chance then
		--有天生状态时继续
		if caster:HasModifier("modifier_thdots_kasen_ex")==false and caster:HasModifier("modifier_thdots_kasen_ex_WBC")==false then return end
		caster:EmitSound("Hero_Centaur.DoubleEdge.TI9")
		caster:AddNewModifier(caster,ability, "modifier_thdots_kasen01_buff_strength_Passive", {duration = buff_duration})	
		target:AddNewModifier(caster,ability, "modifier_thdots_kasen01_debuff_strength_Passive", {duration = buff_duration})
	end
end
modifier_thdots_kasen01_buff_strength = {}
LinkLuaModifier("modifier_thdots_kasen01_buff_strength","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen01_buff_strength:IsHidden() 		return true end     --是否隐藏
function modifier_thdots_kasen01_buff_strength:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen01_buff_strength:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen01_buff_strength:IsDebuff()	   	return false end     --是否是DEBUFF
function modifier_thdots_kasen01_buff_strength:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_thdots_kasen01_buff_strength:DeclareFunctions() return  {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_thdots_kasen01_buff_strength:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("strength_bonus")
end
modifier_thdots_kasen01_debuff_strength = {}
LinkLuaModifier("modifier_thdots_kasen01_debuff_strength","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen01_debuff_strength:IsHidden() 		return true end     --是否隐藏
function modifier_thdots_kasen01_debuff_strength:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen01_debuff_strength:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen01_debuff_strength:IsDebuff()	   	return true end     --是否是DEBUFF
function modifier_thdots_kasen01_debuff_strength:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_thdots_kasen01_debuff_strength:DeclareFunctions() return  {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_thdots_kasen01_debuff_strength:GetModifierBonusStats_Strength()
	return -self:GetAbility():GetSpecialValueFor("strength_bonus")
end
modifier_thdots_kasen01_buff_strength_Passive= {}
LinkLuaModifier("modifier_thdots_kasen01_buff_strength_Passive","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen01_buff_strength_Passive:IsHidden() 		return true end     --是否隐藏
function modifier_thdots_kasen01_buff_strength_Passive:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen01_buff_strength_Passive:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen01_buff_strength_Passive:IsDebuff()	   	return false end     --是否是DEBUFF
function modifier_thdots_kasen01_buff_strength_Passive:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_thdots_kasen01_buff_strength_Passive:DeclareFunctions() return  {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_thdots_kasen01_buff_strength_Passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("strength_parameter")
end
modifier_thdots_kasen01_debuff_strength_Passive= {}
LinkLuaModifier("modifier_thdots_kasen01_debuff_strength_Passive","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen01_debuff_strength_Passive:IsHidden() 		return true end     --是否隐藏
function modifier_thdots_kasen01_debuff_strength_Passive:IsPurgable()     return false end     --是否可净化
function modifier_thdots_kasen01_debuff_strength_Passive:RemoveOnDeath() 	return false end     --死亡移除
function modifier_thdots_kasen01_debuff_strength_Passive:IsDebuff()	   	return true end     --是否是DEBUFF
function modifier_thdots_kasen01_debuff_strength_Passive:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_thdots_kasen01_debuff_strength_Passive:DeclareFunctions() return  {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_thdots_kasen01_debuff_strength_Passive:GetModifierBonusStats_Strength()
	return -self:GetAbility():GetSpecialValueFor("strength_parameter")
end
--///////////////////////////////////
--//鬼王「怪力掷击」
--///////////////////////////////////
function Kasen02PassiveKnock(keys)
	local caster = keys.caster
	local target = keys.target
	if target:IsBuilding() then return end
	local ability=keys.ability
	if caster:HasModifier("modifier_thdots_kasen_ex")==true and caster:HasModifier("modifier_thdots_kasen_ex_WBC")==false then return end

	caster:EmitSound("Hero_Spirit_Breaker.GreaterBash")

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)

	local damage = keys.KnockDamage  + FindTelentValue( caster,"special_bonus_unique_kasen_5") * caster:GetStrength()
	local knockback_duration = keys.KnockbackDuration
	local knockback_distance = keys.KnockbackDistance
	local knockback_height = keys.KnockbackHight
	local knockback_properties = {
			 center_x 			= caster:GetOrigin().x,
			 center_y 			= caster:GetOrigin().y,
			 center_z 			= caster:GetOrigin().z,
			 duration 			= knockback_duration,
			 knockback_duration = knockback_duration,
			 knockback_distance = knockback_distance,
			 knockback_height 	= knockback_height,
		}
	target:AddNewModifier(caster, ability, "modifier_knockback", knockback_properties) --击飞
	local damage_tabel = {
					victim 			= target,					
					damage 			= damage,
					damage_type		= ability:GetAbilityDamageType(),
					damage_flags 	= ability:GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= ability
				}
		UnitDamageTarget(damage_tabel)
end

function OnKasen02SpellStart(keys)
	-- body
	local caster = keys.caster
	local target = keys.target
	local ability= keys.ability
	local info = {
		EffectName = "particles/heroes/kasen/kasen02.vpcf",
		Ability = keys.ability,
		iMoveSpeed = 1200,
		Source = caster,
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		--ExtraData = {x = 10, y = 2, name = "abc"}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function OnKasen02ProjectileHitUnit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if is_spell_blocked(keys.target) then return end
	local damage = keys.StoneDamage 
	local stun_duration = keys.StunDuration
	local slow_duration = keys.SlowDuration
	local radius = keys.Radius	
	local PointPosition = target:GetAbsOrigin()
	local targets = FindUnitsInRadius(
			caster:GetTeam(),						--team
			PointPosition, 							--location
			nil, 									--cacheUnit
			radius,									--radius
			ability:GetAbilityTargetTeam(),			--teamFilter
			ability:GetAbilityTargetType(),			--type
			0,										--flag
			0,										--order
			false 									--canGrowCache
			)
	for _,v in pairs(targets) do
		if v==target or FindTelentValue( caster,"special_bonus_unique_kasen_4") == 2 then
			UtilStun:UnitStunTarget(caster, v, stun_duration)
		end
		local damage_tabel = {
			victim 			= v,				
			damage 			= damage,
			damage_type		= ability:GetAbilityDamageType(),
			damage_flags 	= ability:GetAbilityTargetFlags(),
			attacker 		= caster,
			ability 		= ability
		}
		UnitDamageTarget(damage_tabel)
		ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kasen02_slow", {duration = slow_duration})
	end--对范围内目标造成伤害与减速，若有天赋，额外造成眩晕
	if FindTelentValue( caster,"special_bonus_unique_kasen_4") == 2 then
		local damage_tabel = {
				victim 			= target,					
				damage 			= damage,
				damage_type		= ability:GetAbilityDamageType(),
				damage_flags 	= ability:GetAbilityTargetFlags(),
				attacker 		= caster,
				ability 		= ability
			}
		UnitDamageTarget(damage_tabel)
	end--对主目标造成额外伤害
end


function OnKasen03SpellStart( keys )
	local ability = keys.ability
	local caster =keys.caster
	local ability= keys.ability
	--if caster:HasModifier("modifier_thdots_kasen_ex_WBC") then
	--	caster:SetHealth(caster:GetHealth()*( 1 - 0.01 * ability:GetSpecialValueFor("health_cost") ) )
	--end
	local range = ability:GetSpecialValueFor("range")
	local radius = ability:GetSpecialValueFor("radius")
	local speed = ability:GetSpecialValueFor("speed")
	local interval_damage = ability:GetSpecialValueFor("interval_damage") + caster:GetStrength() * ability:GetSpecialValueFor("strength_multiply")
	local interval_distance = ability:GetSpecialValueFor("interval_distance")
	local casterPoint = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local forwardVec = (targetPoint - casterPoint):Normalized()
	local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
	--[[local projectileTable = {
					Ability				= ability,
					EffectName			= "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
					vSpawnOrigin		= caster:GetOrigin() + Vector(0,0,128),
					fDistance			= range,
					fStartRadius		= radius,
					fEndRadius			= radius,
					Source				= caster,
					bHasFrontalCone		= false,
					bReplaceExisting	= false,
					iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType		= DOTA_UNIT_TARGET_FLAG_NONE,
					fExpireTime			= GameRules:GetGameTime() + 5.0,
					bDeleteOnHit		= false,
					vVelocity			= velocityVec*speed,
					bProvidesVision		= true,
					iVisionRadius		= 400,
					iVisionTeamNumber	= caster:GetTeamNumber(),
					iSourceAttachment 	= PATTACH_CUSTOMORIGIN
				} 
			local LinearProject = ProjectileManager:CreateLinearProjectile( projectileTable )]]

	--间隔闪电球	
	local interval_time = interval_distance/speed --间隔时间
	local time = interval_time
	local fTime = range/speed --最终时间
	local SpawnPosition = caster:GetOrigin() --出生位置
	local velocity = velocityVec * speed --速度矢量
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("interval_flash_ball"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time <= fTime then 
				local Pos = velocity * time + SpawnPosition --当前位置

				local effectIndex = ParticleManager:CreateParticle("particles/heroes/kasen/kasen03_land.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(effectIndex, 0, Pos + Vector(0, 0, 1800))
				ParticleManager:SetParticleControl(effectIndex, 1, Pos)
				ParticleManager:DestroyParticleSystem(effectIndex,false)
				
				local targets = FindUnitsInRadius(
					caster:GetTeam(),						--team
					Pos, 							--location
					nil, 									--cacheUnit
					interval_distance/2,									--radius
					ability:GetAbilityTargetTeam(),	--teamFilter
					ability:GetAbilityTargetType(),	--type
					0,										--flag
					0,										--order
					false 									--canGrowCache
					)
				for _,v in pairs(targets) do
					local damage_tabel = {
								victim 			= v,					
								damage 			= interval_damage,
								damage_type		= ability:GetAbilityDamageType(),
								damage_flags 	= ability:GetAbilityTargetFlags(),
								attacker 		= caster,
								ability 		= ability
							}
					UnitDamageTarget(damage_tabel)					
				end

				time = time + interval_time
				StartSoundEventFromPosition("Hero_Zuus.LightningBolt",  Pos)
				--EmitGlobalSound("Hero_ShadowShaman.EtherShock.Target")
			else
				return nil
			end			
			return interval_time
		end,
	time)
end

function OnKasen03ProjectileHitUnit(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	local wave_damage = ability:GetSpecialValueFor("wave_damage")
	local damage = wave_damage + caster:GetStrength() * ability:GetSpecialValueFor("strength_multiply")
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_kasen03_slow", {duration = duration})	
	local damage_tabel = {
				victim 			= target,					
				damage 			= damage,
				damage_type		= ability:GetAbilityDamageType(),
				damage_flags 	= ability:GetAbilityTargetFlags(),
				attacker 		= caster,
				ability 		= ability
			}
	UnitDamageTarget(damage_tabel)
end

function Kasen03Passive(keys)
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local passive_cd = {
		duration = ability:GetSpecialValueFor("passive_cd") * 0.1
	}
	if caster:HasModifier("modifier_thdots_kasen03_cd") then return end
    caster:AddNewModifier(caster,caster,"modifier_thdots_kasen03_cd",passive_cd)

	local max_targets = ability:GetSpecialValueFor("max_targets")
	local passive_damage = ability:GetSpecialValueFor("passive_damage") + caster:GetStrength() * ability:GetSpecialValueFor("strength_multiply")
	local aura_radius = ability:GetSpecialValueFor("aura_radius")
	local banned_duration = ability:GetSpecialValueFor("banned_duration")
	--有天生状态时继续
	if caster:HasModifier("modifier_thdots_kasen_ex")==false and caster:HasModifier("modifier_thdots_kasen_ex_WBC")==false then return end
	--最短间隔
	if caster:HasModifier("passive_kasen03_banned") then return end
	local banned_duration = ability:GetSpecialValueFor("banned_duration")
	ability:ApplyDataDrivenModifier(caster, caster, "passive_kasen03_banned", {duration = banned_duration})
	local particleName = "particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf"
	local targets_shocked = 0
	-- Make sure the main target is damaged
	if target:HasModifier("passive_kasen03_check") then
		local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
		local damage_tabel = {
					victim 			= target,					
					damage 			= passive_damage,
					damage_type		= ability:GetAbilityDamageType(),
					damage_flags 	= ability:GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= ability
				}
		UnitDamageTarget(damage_tabel)
		
		targets_shocked = 1
	end

	local targets = FindUnitsInRadius(
					caster:GetTeam(),						--team
					caster:GetAbsOrigin(), 					--location
					nil, 									--cacheUnit
					aura_radius,							--radius
					ability:GetAbilityTargetTeam(),			--teamFilter
					ability:GetAbilityTargetType(),			--type
					0,										--flag
					0,										--order
					false 									--canGrowCache
					)
	
	for _,v in pairs(targets) do
		if targets_shocked < max_targets then
			if v ~= target and v:HasModifier("passive_kasen03_check") then
				-- Particle
				local origin = v:GetAbsOrigin()
				local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
				ParticleManager:SetParticleControl(lightningBolt,1,Vector(origin.x,origin.y,origin.z + v:GetBoundingMaxs().z ))

				local damage_tabel = {
					victim 			= v,					
					damage 			= passive_damage,
					damage_type		= ability:GetAbilityDamageType(),
					damage_flags 	= ability:GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= ability
				}
				UnitDamageTarget(damage_tabel)

				targets_shocked = targets_shocked + 1
			end
		else
			break
		end
	end
	if targets_shocked ~= 0 then
		caster:EmitSound("Hero_ShadowShaman.EtherShock.Target")
	end
end

function Kasen03PassiveOnAbility(keys)
	local caster = keys.caster 
	local target = keys.unit --mod目标
	local event_target = keys.target --mod目标用的技能的目标

	local ability = keys.ability --施加mod所属技能
	local target_ability = keys.event_ability --mod目标用的技能
	--有天生状态时继续
	if caster:HasModifier("modifier_thdots_kasen_ex")==false and caster:HasModifier("modifier_thdots_kasen_ex_WBC")==false then return end

	--敌对技能目标是我时继续
	if event_target ~= caster then return end
	--最短间隔
	if caster:HasModifier("passive_kasen03_banned") then return end
	local banned_duration = ability:GetSpecialValueFor("banned_duration")
	ability:ApplyDataDrivenModifier(caster, caster, "passive_kasen03_banned", {duration = banned_duration})
	local max_targets = ability:GetSpecialValueFor("max_targets")
	local passive_damage = ability:GetSpecialValueFor("passive_damage") + caster:GetStrength() * ability:GetSpecialValueFor("strength_multiply")
	local aura_radius = ability:GetSpecialValueFor("aura_radius")
	local chance = ability:GetSpecialValueFor("chance")
	local ability_type_Int = target_ability:GetBehaviorInt() --GetBehavior()对lua_base技能有问题，GetBehaviorInt()可以

	--随机
	--[[
	local i = RandomInt(0,99)
	if i > chance then return end
	]]

	--输出所有behaviortype
	local BehaviorTable = {}
	local rem = 0
	local NumInt = ability_type_Int
	local IsFinish = false
	local TypeTarget = false
	while not IsFinish do
		rem = NumInt % 2
		NumInt = math.floor( NumInt / 2 )
		table.insert( BehaviorTable, rem )
		if NumInt == 0 then IsFinish = true end
	end
	local AllBehavior={}
	for i,v in ipairs(BehaviorTable) do
		if v==1 then
			local BehaviorNum = math.pow(2,i-1)
			table.insert(AllBehavior,BehaviorNum)
		end		
	end
	--判断behavior
	for k, v in ipairs(AllBehavior) do
    	if v == 8 then --是指向型
    		TypeTarget = true
    		--print("true")
    	end
	end

	if target:GetTeam() ~= caster:GetTeam() and TypeTarget == true then

		local particleName = "particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf"
		local targets_shocked = 0
		--优先主目标
		if target:HasModifier("passive_kasen03_check") then
			local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
			ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
			target:EmitSound("Hero_ShadowShaman.EtherShock.Target")
			local damage_tabel = {
						victim 			= target,					
						damage 			= passive_damage,
						damage_type		= ability:GetAbilityDamageType(),
						damage_flags 	= ability:GetAbilityTargetFlags(),
						attacker 		= caster,
						ability 		= ability
					}
			UnitDamageTarget(damage_tabel)
			targets_shocked = 1
		end
		--次目标
		local targets = FindUnitsInRadius(
						caster:GetTeam(),						--team
						caster:GetAbsOrigin(), 					--location
						nil, 									--cacheUnit
						aura_radius,							--radius
						ability:GetAbilityTargetTeam(),			--teamFilter
						ability:GetAbilityTargetType(),			--type
						0,										--flag
						0,										--order
						false 									--canGrowCache
						)
		
		for _,v in pairs(targets) do
			if targets_shocked < max_targets then
				if v ~= target and v:HasModifier("passive_kasen03_check") then
					-- Particle
					local origin = v:GetAbsOrigin()
					local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
					ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
					ParticleManager:SetParticleControl(lightningBolt,1,Vector(origin.x,origin.y,origin.z + v:GetBoundingMaxs().z ))

					local damage_tabel = {
						victim 			= v,					
						damage 			= passive_damage,
						damage_type		= ability:GetAbilityDamageType(),
						damage_flags 	= ability:GetAbilityTargetFlags(),
						attacker 		= caster,
						ability 		= ability
					}
					UnitDamageTarget(damage_tabel)

					targets_shocked = targets_shocked + 1
				end
			else
				break
			end
		end
		if targets_shocked ~= 0 then
			caster:EmitSound("Hero_ShadowShaman.EtherShock.Target")
		end
	end
end

function OnKasen04Normal( event )
	local caster		= event.caster
	local ability		= event.ability

	local pathLength	= event.cast_range
	local pathRadius	= event.path_radius
	local duration		= event.duration
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * pathLength

	ability.startPos	= startPos
	ability.endPos	= endPos
	ability.expireTime = GameRules:GetGameTime() + duration

	-- Create particle effect
	local particleName = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 3, startPos )

	particleName = "particles/econ/items/jakiro/jakiro_ti7_immortal_head/jakiro_ti7_immortal_head_ice_path_b.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( stun_duration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 9, startPos )

	-- Generate projectiles
	pathRadius = math.max( pathRadius, 64 )
	local numProjectiles = math.floor( pathLength / (pathRadius) )
	local stepLength = pathRadius
	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * i * pathRadius			
		ability:ApplyDataDrivenThinker(caster, projectilePos, "modifier_thdots_kasen04normal_debuff_aura", {duration = duration})
		local targets = FindUnitsInRadius(
						caster:GetTeam(),						--team
						projectilePos, 					--location
						nil, 									--cacheUnit
						pathRadius,							--radius
						ability:GetAbilityTargetTeam(),			--teamFilter
						ability:GetAbilityTargetType(),			--type
						0,										--flag
						0,										--order
						false 									--canGrowCache
						)
		for _,v in pairs(targets) do
			ability:ApplyDataDrivenModifier(caster, v, "modifier_kasen04normal_stun", { duration = stun_duration })
			UtilStun:UnitStunTarget(caster, v, stun_duration)
		end
	end
end

function Kasen04NormalDamage( event )
	local caster		= event.caster
	local target		= event.target
	local ability		= event.ability
	local damage		= ability:GetSpecialValueFor("damage") * ability:GetSpecialValueFor("burn_interval")
	local damagetype    = ability:GetAbilityDamageType()
	if FindTelentValue( caster,"special_bonus_unique_kasen_7") == 1 then
		damagetype = DAMAGE_TYPE_PURE 
		damage = damage * 2
	end
	local damage_tabel = {
			victim 			= target,			
			damage 			= damage,
			damage_type		= damagetype,
			damage_flags 	= ability:GetAbilityTargetFlags(),
			attacker 		= caster,
			ability 		= ability
		}
	UnitDamageTarget(damage_tabel)
end

function OnKasen04ExStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")

	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1)

	local time = 3.0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("kasen04ex_count_down"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time >= 0 then 
				local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
				local preSymbol = 0 
				local digits = 2 --显示2位数
				local number = time

				-- Get the integer. Add a bit because the think interval isn't a perfect 0.5 timer
				local integer = math.floor(math.abs(number)) + 10 --如果整数位小于1则各位不显示数字，所以+10

				-- Round the decimal number to .0 or .5
				local decimal = math.abs(number) % 1

				if decimal ~= 0.5 then 
					decimal = 1 -- ".0"
				else 
					decimal = 8 -- ".5"
				end

				local particle = ParticleManager:CreateParticle( particleName, PATTACH_OVERHEAD_FOLLOW, caster )
				ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
				ParticleManager:SetParticleControl( particle, 1, Vector( preSymbol, integer, decimal) )
				ParticleManager:SetParticleControl( particle, 2, Vector( digits, 0, 0) )
				time = time - 0.5
				return 0.5
			else
				return nil
			end
		end,
	0)
end

function OnKasen04ExTakeDamage(keys)

	local caster = keys.caster
	local attacker = keys.attacker
	local damage_taken = keys.DamageTaken
	local Health = caster:GetHealth()
	local ability= keys.ability
	if IsKilledByYugi04(caster,damage_taken) then return end
	if caster:HasModifier("modifier_thdots_medicine04_damage") and (not caster:HasModifier("modifier_thdots_medicine04_debuff")) and caster:HasModifier("modifier_thdots_yugi04_think_interval") then return end
	local attack_speed_bonus = ability:GetSpecialValueFor("attack_speed_bonus")
	local strength_bonus = ability:GetSpecialValueFor("strength_bonus")*0.01
	local buff_duration = ability:GetSpecialValueFor("buff_duration")
	local absorb_pct = ability:GetSpecialValueFor("absorb_pct")
	local attack_speed
	local strength
	if ability.kasen04ex_absorbed == nil then ability.kasen04ex_absorbed = 0 end
	--回血
	caster:SetHealth(caster:GetHealth() + damage_taken)	
	caster:Heal(damage_taken,ability)
	SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, caster, damage_taken, nil)
	
	ability.kasen04ex_absorbed = ability.kasen04ex_absorbed + damage_taken * 0.01 * absorb_pct
	attack_speed_count = math.floor(ability.kasen04ex_absorbed / 100) * attack_speed_bonus
	strength_count = math.floor(ability.kasen04ex_absorbed / 100) * strength_bonus

	local true_strength
	if caster:FindModifierByName("modifier_thdots_kasen04ex_strength") ~=nil then
		true_strength = caster:GetStrength()-(caster:FindModifierByName("modifier_thdots_kasen04ex_strength")):GetStackCount()
	else
		true_strength = caster:GetStrength()
	end

	local attack_speed_modifier = ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kasen04ex_attack_speed", {duration = buff_duration})	
	caster:SetModifierStackCount("modifier_thdots_kasen04ex_attack_speed", ability, attack_speed_count)

	local strength_modifier = ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kasen04ex_strength", {duration = buff_duration})	
	caster:SetModifierStackCount("modifier_thdots_kasen04ex_strength", ability, true_strength * strength_count)

	local ability01 =caster:FindAbilityByName("ability_thdots_kasen01")
end

function OnKasen04ExEnd(keys)
	local ability =keys.ability
	local caster = keys.caster
	local damagetype= ability:GetAbilityDamageType()
	local damage = keys.caster:GetStrength() * 2
	if FindTelentValue( caster,"special_bonus_unique_kasen_7") == 1 then 
		damagetype = DAMAGE_TYPE_PURE 
		damage = damage * 2
	end 
	ability.kasen04ex_absorbed=0
	local radius = ability:GetSpecialValueFor("radius")
	local particle = ParticleManager:CreateParticle( "particles/heroes/kasen/kasen04end.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 2, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 3, caster:GetAbsOrigin() )
	local targets = FindUnitsInRadius(
						caster:GetTeam(),						--team
						caster:GetAbsOrigin(), 					--location
						nil, 									--cacheUnit
						radius,									--radius
						ability:GetAbilityTargetTeam(),			--teamFilter
						ability:GetAbilityTargetType(),			--type
						0,										--flag
						0,										--order
						false 									--canGrowCache
					)
	for _,v in pairs(targets) do
		UtilStun:UnitStunTarget(caster, v, keys.ability:GetSpecialValueFor("stun_duration"))
		local damage_tabel = {
			victim 			= v,					
			damage 			= damage,
			damage_type		= damagetype,
			damage_flags 	= ability:GetAbilityTargetFlags(),
			attacker 		= caster,
			ability 		= keys.ability
		}
		UnitDamageTarget(damage_tabel)
	end
end

function ability_thdots_kasenEx_WBC:OnInventoryContentsChanged()
	if IsServer() then
		local ability =self:GetCaster():FindAbilityByName("ability_thdots_kasen04_ex_WBC")
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			ability:SetHidden(false)
		else
			ability:SetHidden(true)
		end
	end
end
--[[Author: Pizzalol
	Date: 07.03.2015.
	Initialize the Stone Gaze unit table]]
function StoneGazeStart( keys )
	local caster = keys.caster
	--local ability= keys.ability
	--if caster:HasModifier("modifier_thdots_kasen_ex_WBC") then
	--	caster:SetHealth(caster:GetHealth()*( 1 - 0.01 * ability:GetSpecialValueFor("health_cost") ) )
	--end
	caster.stone_gaze_table = {}
end

--[[Author: Pizzalol
	Date: 07.03.2015.
	Checks if the caster has the Stone Gaze modifier
	If the caster doesnt have the modifier then remove the debuff modifier from the target]]
function StoneGazeSlow( keys )
	local caster = keys.caster
	local target = keys.target
	
	local modifier_caster = keys.modifier_caster
	local modifier_target = keys.modifier_target

	if not caster:HasModifier(modifier_caster) then
		target:RemoveModifierByNameAndCaster(modifier_target, caster)
	end
end

--[[Author: Pizzalol, math by BMD
	Date: 07.03.2015.
	Checks if the target is currently facing the caster
	then it checks if the target faced the caster before
	if the target did face the caster before then apply the counter modifier
	otherwise add the target as a new target]]
function StoneGaze( keys )
	local caster = keys.caster
	local target = keys.target
	local targetname = target:GetClassname()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_slow = keys.modifier_slow
	local modifier_facing = keys.modifier_facing

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local vision_cone = ability:GetLevelSpecialValueFor("vision_cone", ability_level)

	-- Locations
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()	

	-- Angle calculation
	local direction = (caster_location - target_location):Normalized()
	local forward_vector = target:GetForwardVector()
	local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)
	--print("Angle: " .. angle)

	-- Facing check
	if angle <= vision_cone/2 then
		local check = false
		-- Check if its a target from before
		for k,v in ipairs(caster.stone_gaze_table) do
			if v == target then
				check = true
			end
		end

		-- If its a target from before then apply the counter modifier for 2 frames
		if check then
			ability:ApplyDataDrivenModifier(caster, target, modifier_facing, {Duration = 0.06})
		else
			-- If its a new target then add it to the table
			table.insert(caster.stone_gaze_table, target)
			-- Set the facing time to 0
			target.stone_gaze_look = 0
			-- Set the petrification variable to false
			target.stone_gaze_stoned = false

			-- Apply the slow and counter modifiers
			ability:ApplyDataDrivenModifier(caster, target, modifier_slow, {Duration = duration})
			ability:ApplyDataDrivenModifier(caster, target, modifier_facing, {Duration = 0.06})
		end
	end
end

--[[Author: Pizzalol
	Date: 07.03.2015.
	Checks for how long the target faced the caster
	If it was for longer than the minimum required facing time then
	apply the petrification debuff if the target was not petrified before]]
function StoneGazeFacing( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local face_duration = ability:GetLevelSpecialValueFor("face_duration", ability_level)
	local stone_duration = ability:GetLevelSpecialValueFor("stone_duration", ability_level)
	local modifier_stone = keys.modifier_stone
	if target.stone_gaze_look == nil then target.stone_gaze_look = 0 end
	target.stone_gaze_look = target.stone_gaze_look + 0.03

	-- If the target was facing the caster for more than the required time and wasnt petrified before
	-- then petrify it
	if target.stone_gaze_look >= face_duration and not target.stone_gaze_stoned then
		ability:ApplyDataDrivenModifier(caster, target, modifier_stone, {Duration = stone_duration})
		target.stone_gaze_stoned = true
		target.stone_gaze_look = 0
		caster:Purge(false,true,false,true,false)
		local particle = ParticleManager:CreateParticle( "particles/heroes/kasen/kasen04ex_wbc.vpcf", PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )				
		ParticleManager:SetParticleControl( particle, 4, caster:GetAbsOrigin() )
		ParticleManager:DestroyParticleSystem(particle,false)
	end
end

modifier_thdots_kasen03_cd = {}
LinkLuaModifier("modifier_thdots_kasen03_cd","scripts/vscripts/abilities/abilitykasen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_kasen03_cd:IsHidden() return true end
function modifier_thdots_kasen03_cd:IsDebuff() return false end
function modifier_thdots_kasen03_cd:IsPurgable() return false end