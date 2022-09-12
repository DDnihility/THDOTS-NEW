ability_thdots_kasen2_1 = {}


function ability_thdots_kasen2_1:GetCastAnimation()
	if self:GetCaster():GetModelName() == "models/ibaraki_kasen/ibaraki_kasen_2.vmdl" then return ACT_DOTA_CAST_ABILITY_4 end
	return ACT_DOTA_CAST_ABILITY_1
end


function ability_thdots_kasen2_1:OnSpellStart()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_kasenIllusion") then
		if self:GetCaster():FindModifierByName("modifier_kasenIllusion"):GetAbility():GetLevel() <= 2 then return end
	end
	self:GetCaster():EmitSound("kasen1")
	local cpoint = self:GetCaster():GetAbsOrigin()
	local tpoint = self:GetCursorPosition()
	self.vec = cpoint - tpoint
	local thinker = CreateModifierThinker(self:GetCaster(),self,"modifier_ability_kasen2_1thinker",{},self:GetCaster():GetAbsOrigin(),self:GetCaster():GetTeamNumber(),false)
	local vec = thinker:GetAbsOrigin()
	thinker:SetAbsOrigin(Vector(vec.x,vec.y,vec.z+150))
	self:GetCaster():AddNewModifier(thinker,self,"modifier_ability_kasen2_1c",{})
end

 
modifier_ability_kasen2_1c = {}
LinkLuaModifier("modifier_ability_kasen2_1c","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_1c:IsHidden() return true end
function modifier_ability_kasen2_1c:IsPurgable() return false end
function modifier_ability_kasen2_1c:IsDebuff() return false end
function modifier_ability_kasen2_1c:RemoveOnDeath() return true end

function modifier_ability_kasen2_1c:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_ability_kasen2_1c:OnCreated()
	if not IsServer() then return end
    self:StartIntervalThink(0.03)
    self.startPoint = self:GetParent():GetAbsOrigin()
    self.vec = self:GetAbility().vec
    self.back = false
    self.effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_lily.vpcf", PATTACH_CUSTOMORIGIN,self:GetParent())
	ParticleManager:SetParticleControlEnt(self.effectIndex , 0, self:GetParent(), 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.effectIndex , 1, self:GetCaster(), 5, "attach_hitloc", Vector(0,0,0), true)
	local heroes = FindUnitsInRadius(self:GetParent():GetTeam(),Vector(0,0,0),nil,999999,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_HERO,0,1,false)
	self.damage = 0
	for hh,sb in pairs(heroes) do
		if FindTelentValue(sb,"special_bonus_unique_kasen2_2") ~= 0 then
			self.damage = FindTelentValue(sb,"special_bonus_unique_kasen2_2")
		end
	end
end

function modifier_ability_kasen2_1c:OnIntervalThink()
	if not IsServer() then return end
	local thinkerPoint = self:GetCaster():GetAbsOrigin()
	local heroes = FindUnitsInRadius(self:GetParent():GetTeam(),thinkerPoint,nil,85,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,0,1,false)
	local length = (thinkerPoint - self.startPoint):Length2D()
	if length >= self:GetAbility():GetSpecialValueFor("cast_range") then 
		self.back = true
	end
    if #heroes == 0 and self.back == false then
    	self:GetCaster():SetOrigin(thinkerPoint-self.vec:Normalized()*50)
    elseif #heroes == 0 and self.back == true then
    	--heroes[1]:SetOrigin(thinkerPoint-self.vec:Normalized()*15)
    	self:GetCaster():SetOrigin(thinkerPoint+self.vec:Normalized()*50)
    elseif #heroes ~= 0 then 
    	self.back = true
    	heroes[1]:SetOrigin(Vector(thinkerPoint.x,thinkerPoint.y,heroes[1]:GetAbsOrigin().z)+self.vec:Normalized()*50)
		UtilStun:UnitStunTarget(self:GetCaster(),heroes[1],0.04)
    	self:GetCaster():SetOrigin(thinkerPoint+self.vec:Normalized()*50)
    end
	if self.back == true and length < 100 then
		self:GetParent():RemoveModifierByName("modifier_ability_kasen2_1c")
		if #heroes ~= 0 then
			UtilStun:UnitStunTarget(self:GetCaster(),heroes[1],self:GetAbility():GetSpecialValueFor("stuntime"))
			FindClearSpaceForUnit(heroes[1], heroes[1]:GetAbsOrigin(), true)
			local kasen2 = FindUnitsInRadius(self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,1000,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,0,0,false)
	    for hh,sb in pairs(kasen2) do
		    if sb:HasModifier("modifier_kasenIllusion") and self:GetParent():HasModifier("modifier_kasenIllusion_check") then
					FindClearSpaceForUnit(sb, heroes[1]:GetAbsOrigin(), true)
					sb:MoveToTargetToAttack(heroes[1])
					local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(effectIndex, 0, sb:GetAbsOrigin())
					ParticleManager:SetParticleControl(effectIndex, 1, sb:GetAbsOrigin())
					ParticleManager:DestroyParticleSystem(effectIndex,false)
		    end
		    if sb:HasModifier("modifier_kasenIllusion_check") and self:GetParent():HasModifier("modifier_kasenIllusion") then
					FindClearSpaceForUnit(sb, heroes[1]:GetAbsOrigin(), true)
					sb:MoveToTargetToAttack(heroes[1])
					local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(effectIndex, 0, sb:GetAbsOrigin())
					ParticleManager:SetParticleControl(effectIndex, 1, sb:GetAbsOrigin())
					ParticleManager:DestroyParticleSystem(effectIndex,false)
		    end
	    end
			self:GetParent():MoveToTargetToAttack(heroes[1])
			local damage_table = {
	        	victim = heroes[1],
		        attacker = self:GetCaster(),
	        	damage = self:GetAbility():GetAbilityDamage() + self.damage,
		        damage_type = DAMAGE_TYPE_MAGICAL,
	           }
			UnitDamageTarget(damage_table)
		end
	end
end

function modifier_ability_kasen2_1c:OnRemoved()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effectIndex,true)
end

modifier_ability_kasen2_1thinker = {}
LinkLuaModifier("modifier_ability_kasen2_1thinker","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)

ability_thdots_kasen2_2 = {}

function ability_thdots_kasen2_2:CastFilterResult()
	if not IsServer() then return end
    if not self:GetCaster():HasModifier("modifier_item_wanbaochui") then return UF_FAIL_CUSTOM end
    if not self:GetCaster():IsAlive() then return UF_FAIL_CUSTOM end
	if self:GetCaster():FindModifierByName("modifier_kasenIllusion_check") == nil then return UF_FAIL_CUSTOM end

	local kasen = self:GetCaster():GetAbsOrigin()
	local kasen2 = self:GetCaster():FindModifierByName("modifier_kasenIllusion_check"):GetCaster():GetAbsOrigin()
	local length = (kasen - kasen2):Length2D()
	local limit = self:GetCaster():FindAbilityByName("ability_thdots_kasen2_4"):GetSpecialValueFor("cast_radius")
	if length <= limit then return UF_SUCCESS end
	return UF_FAIL_CUSTOM
end

function ability_thdots_kasen2_2:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_5
end

function ability_thdots_kasen2_2:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local kasen2 = caster:FindModifierByName("modifier_kasenIllusion_check"):GetCaster()
	kasenTransfiguration(caster,kasen2)
end

function ability_thdots_kasen2_2:GetIntrinsicModifierName()
	return "modifier_ability_kasen2_2passive"
end

modifier_kasen_bkb = {}
LinkLuaModifier("modifier_kasen_bkb","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_bkb:IsHidden() return false end
function modifier_kasen_bkb:IsPurgable() return false end
function modifier_kasen_bkb:IsDebuff() return false end
function modifier_kasen_bkb:RemoveOnDeath() return true end

function modifier_kasen_bkb:OnCreated()
	if not IsServer() then return end
	self.eff = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
end

function modifier_kasen_bkb:OnDestroy()
	if not IsServer() then return end
    ParticleManager:DestroyParticle(self.eff,true)
end

function modifier_kasen_bkb:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_kasen_bkb:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_kasen_bkb:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then return end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	--print_r(keys)
    if keys.damage_type == 1 then
    	return
    else
    	return keys.damage
    end
end

modifier_kasen_transfiguration = {}
LinkLuaModifier("modifier_kasen_transfiguration","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_transfiguration:IsHidden() return false end
function modifier_kasen_transfiguration:IsPurgable() return false end
function modifier_kasen_transfiguration:IsDebuff() return false end
function modifier_kasen_transfiguration:RemoveOnDeath() return false end

function modifier_kasen_transfiguration:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        --MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_kasen_transfiguration:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attackRange")
end

function modifier_kasen_transfiguration:GetModifierTotal_ConstantBlock(keys)
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
    local healthpct = self:GetCaster():GetHealth() / self:GetCaster():GetMaxHealth()
    if healthpct > 0.1 then
        return keys.damage * 0.01 * (-self:GetAbility():GetSpecialValueFor("block_damage_max")/0.9*healthpct+self:GetAbility():GetSpecialValueFor("block_damage_max")/0.9)
    else
    	return self:GetAbility():GetSpecialValueFor("block_damage_max") * keys.damage * 0.01
    end
end

function modifier_kasen_transfiguration:GetModifierConstantHealthRegen()
	return (self:GetCaster():GetMaxHealth() - self:GetCaster():GetHealth()) * self:GetAbility():GetSpecialValueFor("health_regen") * 0.01
end

function modifier_kasen_transfiguration:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus_max") * (1 - self:GetCaster():GetHealth() / self:GetCaster():GetMaxHealth())
end

function modifier_kasen_transfiguration:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.caster:SetOriginalModel("models/ibaraki_kasen/ibaraki_kasen_3.vmdl")
	self.caster:SetModelScale(1.25)
end

function modifier_kasen_transfiguration:OnRemoved()
	if not IsServer() then return end
	self.caster:SetOriginalModel("models/ibaraki_kasen/ibaraki_kasen_1.vmdl")
	self.caster:SetModelScale(1)
	self.caster:RemoveAbility("ability_thdots_kasen01")
	self.caster:RemoveAbility("ability_thdots_kasen03")
end

modifier_ability_kasen2_2passive = {}
LinkLuaModifier("modifier_ability_kasen2_2passive","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_2passive:IsHidden() return true end
function modifier_ability_kasen2_2passive:IsPurgable() return false end
function modifier_ability_kasen2_2passive:IsDebuff() return false end
function modifier_ability_kasen2_2passive:RemoveOnDeath() return false end

function modifier_ability_kasen2_2passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_kasen2_2passive:GetModifierAttackSpeedBonus_Constant()
	local attackspeed = self:GetAbility():GetSpecialValueFor("attackspeed")
	if self:GetCaster():HasModifier("modifier_kasen_transfiguration") then attackspeed = attackspeed*2 end
	return attackspeed
end

ability_thdots_kasen2_3 = {}

function ability_thdots_kasen2_3:GetIntrinsicModifierName()
	return "modifier_ability_kasen2_3strengthBonus"
end

function ability_thdots_kasen2_3:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_kasen2_telent4") then
	      return self.BaseClass.GetCooldown(self, level) - 20
     else
	      return self.BaseClass.GetCooldown(self, level)
     end
end

function ability_thdots_kasen2_3:CastFilterResultTarget(target)
	if not IsServer() then return end
	if target:GetName() == "npc_thd_goodguys_super_siege" then return UF_FAIL_CUSTOM end
	if target:GetName() == "npc_thd_badguys_super_siege" then return UF_FAIL_CUSTOM end
	if not target:IsCreep() or (target:GetTeam() == self:GetCaster():GetTeam()) then
		return UF_FAIL_CUSTOM
	elseif target:IsAncient() and FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_3")==0 --[[and self:GetCaster():GetLevel() < self:GetSpecialValueFor("level_limit")]] then
		return UF_FAIL_ANCIENT
	end
end

function ability_thdots_kasen2_3:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local monster = self:GetCursorTarget()
	local gold = self:GetSpecialValueFor("gold") + FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_1")
	local exp = self:GetSpecialValueFor("exp")
	if  monster:GetClassname() == "npc_dota_roshan" then return end
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf", PATTACH_ABSORIGIN,monster)
	caster:FindModifierByName("modifier_ability_kasen2_3strengthBonus"):SetStackCount(caster:FindModifierByName("modifier_ability_kasen2_3strengthBonus"):GetStackCount()+1)
    local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)
	caster:EmitSound("DOTA_Item.Hand_Of_Midas")
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD,caster,gold, nil)
	local PlayerID = caster:GetPlayerOwnerID()
	PlayerResource:SetGold(PlayerID,PlayerResource:GetUnreliableGold(PlayerID) + gold,false)
	caster:AddExperience(exp,DOTA_ModifyXP_CreepKill,false,false)
	print(monster:GetClassname())
	print(self:GetAutoCastState())
	if self:GetAutoCastState() == false then
		monster:Kill(self, caster)
		return
	end
	for i=0,1 do
		if monster:GetAbilityByIndex(i) and monster:GetAbilityByIndex(i) ~= nil then
			print(i)
			print(monster:GetAbilityByIndex(i):GetName())
			if i == 0 then 
				caster:RemoveAbilityByHandle(caster:GetAbilityByIndex(3))
				local ability = monster:GetAbilityByIndex(i)
				if ability:GetName() == "ghost_frost_attack" then
					ability = caster:AddAbility("kasen_weird_attack")
				elseif ability:GetName() == "alpha_wolf_critical_strike" then
					ability = caster:AddAbility("kasen2_toulangcrit")
				elseif ability:GetName() == "mudgolem_cloak_aura" then
					ability = caster:AddAbility("kasen_magicalResistance_aura")
				elseif ability:GetName() == "kobold_taskmaster_speed_aura" then
					ability = caster:AddAbility("kasen_movespeed_aura")
				elseif ability:GetName() == "granite_golem_hp_aura" then
					ability = caster:AddAbility("kasen_HP_bonus_aura")
				elseif ability:GetName() == "enraged_wildkin_hurricane" then
					ability = caster:AddAbility("rubick_empty1")
				elseif ability:GetName() == "neutral_upgrade" then
					ability = caster:AddAbility("rubick_empty1")
				elseif ability:GetName() == "creep_irresolute" then
					ability = caster:AddAbility("rubick_empty1")
				elseif ability:GetName() == "creep_siege" then
					ability = caster:AddAbility("rubick_empty1")
				elseif ability:GetName() == "creep_piercing" then
					ability = caster:AddAbility("rubick_empty1")
				else
					ability = caster:AddAbility(ability:GetName())
				end
				ability:SetLevel(monster:GetAbilityByIndex(i):GetLevel())
				ability:SetHidden(false)
			else
				caster:RemoveAbilityByHandle(caster:GetAbilityByIndex(4))
				local ability = monster:GetAbilityByIndex(i)
				if ability:GetName() == "black_dragon_splash_attack" then
					ability = caster:AddAbility("kasen_dragon_splash_attack")
				elseif ability:GetName() == "forest_troll_high_priest_mana_aura" then
					ability = caster:AddAbility("kasen2_huilanaura")
				elseif ability:GetName() == "alpha_wolf_command_aura" then
					ability = caster:AddAbility("kasen2_toulangaura")
				elseif ability:GetName() == "enraged_wildkin_toughness_aura" then
					ability = caster:AddAbility("kasen_armor_aura")
				elseif ability:GetName() == "satyr_hellcaller_unholy_aura" then
					ability = caster:AddAbility("kasen_HPregen_aura")
				elseif ability:GetName() == "centaur_khan_endurance_aura" then
					ability = caster:AddAbility("kasen_attackspeed_aura")
				elseif ability:GetName() == "neutral_upgrade" then
					ability = caster:AddAbility("rubick_empty2")
				elseif ability:GetName() == "creep_irresolute" then
					ability = caster:AddAbility("rubick_empty2")
				elseif ability:GetName() == "creep_siege" then
					ability = caster:AddAbility("rubick_empty2")
				elseif ability:GetName() == "creep_piercing" then
					ability = caster:AddAbility("rubick_empty2")
				else
					ability = caster:AddAbility(ability:GetName())
				end
				ability:SetLevel(monster:GetAbilityByIndex(i):GetLevel())
				ability:SetHidden(false)
			end
		else
			if i == 0 then 
				caster:RemoveAbilityByHandle(caster:GetAbilityByIndex(3))
				local ability = caster:AddAbility("rubick_empty1")
				ability:SetHidden(false)
			else 
				caster:RemoveAbilityByHandle(caster:GetAbilityByIndex(4))
				local ability = caster:AddAbility("rubick_empty2")
				ability:SetHidden(false)
			end
		end
	end
	monster:Kill(self, caster)
end

modifier_ability_kasen2_3strengthBonus = {}
LinkLuaModifier("modifier_ability_kasen2_3strengthBonus","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_3strengthBonus:IsHidden() return false end
function modifier_ability_kasen2_3strengthBonus:IsPurgable() return false end
function modifier_ability_kasen2_3strengthBonus:IsDebuff() return false end
function modifier_ability_kasen2_3strengthBonus:RemoveOnDeath() return false end

function modifier_ability_kasen2_3strengthBonus:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
	self.telent = 0
end

function modifier_ability_kasen2_3strengthBonus:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_6") ~= 0 then
		self.telent = FindTelentValue(self:GetParent(),"special_bonus_unique_kasen2_6")
	end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_kasen2_4") ~= 0 and not self:GetParent():HasModifier("modifier_ability_kasen2_telent4") then 
    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_kasen2_telent4",{}) end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_kasen2_8") ~= 0 and not self:GetParent():HasModifier("modifier_ability_kasen2_telent8") then 
    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_kasen2_telent8",{}) end
end

function modifier_ability_kasen2_3strengthBonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_ability_kasen2_3strengthBonus:GetModifierBonusStats_Strength()
	return self:GetStackCount() * (self.telent + 1)
end

modifier_ability_kasen2_telent4 = {}
LinkLuaModifier("modifier_ability_kasen2_telent4","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_telent4:IsHidden() return true end
function modifier_ability_kasen2_telent4:IsPurgable() return false end
function modifier_ability_kasen2_telent4:IsDebuff() return false end
function modifier_ability_kasen2_telent4:RemoveOnDeath() return false end

modifier_ability_kasen2_telent8 = {}
LinkLuaModifier("modifier_ability_kasen2_telent8","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_telent8:IsHidden() return true end
function modifier_ability_kasen2_telent8:IsPurgable() return false end
function modifier_ability_kasen2_telent8:IsDebuff() return false end
function modifier_ability_kasen2_telent8:RemoveOnDeath() return false end

modifier_kasen2_spellcheck = {}
LinkLuaModifier("modifier_kasen2_spellcheck","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)

ability_thdots_kasen2_4 = {}

function ability_thdots_kasen2_4:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_kasen_transfiguration") then caster:RemoveModifierByName("modifier_kasen_transfiguration") end
	caster:AddNewModifier(caster,self,"modifier_kasen2_spellcheck",{})
	killKasenIllusion(caster)
	local illusionOrigin = self:GetCaster():GetAbsOrigin()
	local illusionModel = "models/ibaraki_kasen/ibaraki_kasen_2.vmdl"
	local kasenIllusion = CreateKasenIllusion(self,caster,illusionOrigin,illusionModel)
end

function CreateKasenIllusion(self,caster,origin,model)
	if not IsServer() then return end
	local kasen2 = CreateUnitByName( caster:GetUnitName(), origin, true, caster, caster:GetOwner(), caster:GetTeam())
	kasen2:SetControllableByPlayer(caster:GetPlayerID(), false)
	kasen2:SetOriginalModel(model)
	caster:EmitSound("kasen2")
	local caster_level = caster:GetLevel()
	for i = 2, caster_level do
		kasen2:HeroLevelUp(false)
	end

    
	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)

	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, kasen2:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, kasen2:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)

    for i=0,16 do 
        if kasen2:GetAbilityByIndex(i) and kasen2:GetAbilityByIndex(i) ~= "" then
            print(kasen2:GetAbilityByIndex(i):GetName())
            kasen2:RemoveAbilityByHandle(kasen2:GetAbilityByIndex(i))
        end
    end

    --kasen2:AddAbility
 
    for item_id = 0, 5 do
		local item_in_caster = caster:GetItemInSlot(item_id)	
		if item_in_caster ~= nil then
			local item_name = item_in_caster:GetName()
			if IsKasenItem(item_name) then
		        local item_created = CreateItem( item_in_caster:GetName(), kasen2, kasen2)
		        kasen2:AddItem(item_created)
			    item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
			    print(item_in_caster:GetName())
		    end
		end
	end 
    

	kasen2:GetItemInSlot(15):EndCooldown()
    
	kasen2:SetMaximumGoldBounty(0)
	kasen2:SetMinimumGoldBounty(0)
	kasen2:SetDeathXP(0)
	kasen2:SetAbilityPoints(0)
	kasen2:SetHasInventory(false)
	kasen2:SetCanSellItems(false) 

    kasen2:AddNewModifier(caster,self,"modifier_kasenIllusion",{})

    kasen2:AddNewModifier(caster,self,"modifier_ability_kasen2_3strengthBonus",{})
    local count = 0
    if caster:FindModifierByName("modifier_ability_kasen2_3strengthBonus") ~= nil then count = caster:FindModifierByName("modifier_ability_kasen2_3strengthBonus"):GetStackCount() end
    if FindTelentValue(caster,"special_bonus_unique_kasen2_6") ~= 0 then count = count + count end
    kasen2:FindModifierByName("modifier_ability_kasen2_3strengthBonus"):SetStackCount(count)

    healthPercent = caster:GetHealth()/caster:GetMaxHealth()
    kasen2:SetHealth(kasen2:GetMaxHealth())

    ability = kasen2:AddAbility("ability_thdots_kasen01")
    ability:SetLevel(self:GetLevel())
    
    if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
        ability = kasen2:AddAbility("ability_thdots_kasen2_s3")
        ability:SetLevel(1)
    else
        ability = kasen2:AddAbility("ability_thdots_kasen2_s3")
        ability:SetLevel(0)
    end

    ability = kasen2:AddAbility("ability_thdots_kasen2_sEx")
    ability:SetLevel(self:GetLevel())
    
    if self:GetLevel() >= 2 then
    ability = kasen2:AddAbility(caster:GetAbilityByIndex(3):GetName())
    ability:SetLevel(caster:GetAbilityByIndex(3):GetLevel())

    ability = kasen2:AddAbility(caster:GetAbilityByIndex(4):GetName())
    ability:SetLevel(caster:GetAbilityByIndex(4):GetLevel())
    else
    kasen2:AddAbility("generic_hidden")
    kasen2:AddAbility("generic_hidden")
    end

    ability = kasen2:AddAbility("ability_thdots_kasen04_ex")
    ability:SetLevel(self:GetLevel())

    ability = kasen2:AddAbility("ability_thdots_kasen03")
    ability:SetLevel(self:GetLevel())	
	ability:SetActivated(false)

    return kasen2
end

KasenBanItem = {
	"item_lifu",
	"item_present_box",
	"item_UFO",
	"item_mushroom_pie",
	"item_mushroom_soup",
	"item_mushroom_kebab",
	"item_gem",
	"item_rapier",
	"item_ward_dispenser",
	"item_ward_observer",
	"item_ward_sentry",
	"item_smoke_of_deceit",
	"item_dust",
	"item_jiduzhixinyan",
	"item_donation_gem",
}

function IsKasenItem(name)
	for hh,sb in pairs(KasenBanItem) do
		if name == sb then return false end
	end
	return true
end

modifier_kasenIllusion = {}
LinkLuaModifier("modifier_kasenIllusion","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasenIllusion:IsHidden() return true end
function modifier_kasenIllusion:IsPurgable() return false end
function modifier_kasenIllusion:IsDebuff() return false end
function modifier_kasenIllusion:RemoveOnDeath() return true end

function modifier_kasenIllusion:OnCreated()
	if not IsServer() then return end
	self:GetCaster():AddNewModifier(self:GetParent(),self,"modifier_kasenIllusion_check",{})
	self.strength = self:GetCaster():FindModifierByName("modifier_kasenIllusion_check").strength
	self.agility = self:GetCaster():FindModifierByName("modifier_kasenIllusion_check").agility
	self.intellect = self:GetCaster():FindModifierByName("modifier_kasenIllusion_check").intellect
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_7") ~= 0 then
		self.mute = false
	else
		self.mute = true
	end
	self:StartIntervalThink(0.1)
end

function modifier_kasenIllusion:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_kasenIllusion_check")
end

function modifier_kasenIllusion:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():FindAbilityByName("ability_thdots_kasen2_2"):GetSpecialValueFor("attackspeed"))
end

function modifier_kasenIllusion:CheckState()
	return {
		[MODIFIER_STATE_MUTED] = self.mute,
	}
end

function modifier_kasenIllusion:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SUPER_ILLUSION,
		MODIFIER_PROPERTY_ILLUSION_LABEL,
		MODIFIER_PROPERTY_IS_ILLUSION,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_kasenIllusion:OnTakeDamage( event )
	if not IsServer() then return end
	if event.unit == self:GetParent() then 
	    if event.unit:IsAlive() == false then
		    event.unit:MakeIllusion()
    	end
    end
    --if (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("cast_radius") then return end
	if event.attacker == self:GetParent() then
		local percent = self:GetCaster():FindAbilityByName("ability_thdots_kasen2_2"):GetSpecialValueFor("percent")*0.01
		self:GetCaster():Heal(event.damage*percent,event.attacker)
	    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetCaster(),event.damage*percent,nil)
	end
	if event.attacker == self:GetCaster() --[[and FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_6") ~= 0]] then
		local percent = self:GetCaster():FindAbilityByName("ability_thdots_kasen2_2"):GetSpecialValueFor("percent")*0.01
		self:GetParent():Heal(event.damage*percent,event.attacker)
	    SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self:GetParent(),event.damage*percent,nil)
	end	
end

function modifier_kasenIllusion:OnDeath(keys)
	if not IsServer() then return end
	if keys.unit == self:GetCaster() then
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_8") == 0 then
	        killKasenIllusion(self:GetCaster())
	        return 
	    end
    end
    if keys.unit == self:GetParent() then
    	if self:GetCaster():HasModifier("modifier_kasen_transfiguration") then return end
    	if self:GetCaster():HasModifier("modifier_kasen2_spellcheck") then return end
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_8") ~= 0 then return end
    	self:GetCaster():Kill(self:GetAbility(),keys.attacker)
    end
	if keys.unit ~= self:GetParent() then return end
	local damage_table = {
	        	victim = self:GetCaster(),
		        attacker = keys.attacker,
	        	damage = self:GetCaster():GetMaxHealth()*self:GetAbility():GetSpecialValueFor("damage_percent")*0.01,
		        damage_type = DAMAGE_TYPE_MAGICAL,
	           }
    UnitDamageTarget(damage_table)
	if not keys.attacker:IsRealHero() then return end
	if keys.attacker:GetTeam() == self:GetCaster():GetTeam() then return end
	local gold = self:GetAbility():GetSpecialValueFor("gold")
    local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, keys.attacker)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.attacker:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, keys.attacker:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)
	keys.attacker:EmitSound("DOTA_Item.Hand_Of_Midas")
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD,keys.attacker,gold, nil)
end

function modifier_kasenIllusion:GetIsIllusion()
	return false
end

function modifier_kasenIllusion:GetModifierSuperIllusion()
	return true
end

function modifier_kasenIllusion:GetModifierIllusionLabel()
	return true
end

function modifier_kasenIllusion:GetModifierBonusStats_Strength()
   return -self:GetCaster():GetStrength()*(100-self:GetAbility():GetSpecialValueFor("percent")-FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_5"))*0.01
end

function modifier_kasenIllusion:GetModifierBonusStats_Agility()
   return -self:GetCaster():GetAgility()*(100-self:GetAbility():GetSpecialValueFor("percent")-FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_5"))*0.01
end

function modifier_kasenIllusion:GetModifierBonusStats_Intellect()
   return -self:GetCaster():GetIntellect()*(100-self:GetAbility():GetSpecialValueFor("percent")-FindTelentValue(self:GetCaster(),"special_bonus_unique_kasen2_5"))*0.01
end

function modifier_kasenIllusion:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end

function killKasenIllusion(caster)
	local kasen2 = FindUnitsInRadius(caster:GetTeam(),Vector(0,0,0),nil,999999,DOTA_UNIT_TARGET_TEAM_BOTH
		,DOTA_UNIT_TARGET_ALL,0,0,false)
	for hh,sb in pairs(kasen2) do
		if sb:HasModifier("modifier_kasenIllusion") then
			sb:RemoveModifierByName("modifier_kasenIllusion")
			sb:MakeIllusion()
			sb:ForceKill(false)
			sb:RemoveAllModifiers(0,true,true,true)
			sb:RemoveSelf() 
		end
	end
	if caster:HasModifier("modifier_kasen2_spellcheck") then caster:RemoveModifierByName("modifier_kasen2_spellcheck") end
	return nil
end

function kasenAbility2Cast(caster)
	if not caster:HasModifier("modifier_item_wanbaochui") then return DOTA_ABILITY_BEHAVIOR_PASSIVE end
	if not caster:HasModifier("modifier_kasenIllusion_check") then return DOTA_ABILITY_BEHAVIOR_PASSIVE end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

modifier_kasenIllusion_check = {}
LinkLuaModifier("modifier_kasenIllusion_check","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasenIllusion_check:IsHidden() return true end
function modifier_kasenIllusion_check:IsPurgable() return false end
function modifier_kasenIllusion_check:IsDebuff() return false end
function modifier_kasenIllusion_check:RemoveOnDeath() return false end

function modifier_kasenIllusion_check:OnCreated()
	if not IsServer() then return end
	self.exp = self:GetCaster():GetCurrentXP()
	print(self.exp)
end

function modifier_kasenIllusion_check:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_kasenIllusion_check:OnDeath(keys)
	if not IsServer() then return end
	local exp = self:GetCaster():GetCurrentXP() - self.exp
    if exp > 0 then
        self:GetParent():AddExperience(exp,0,false,true)
        self.exp = self:GetCaster():GetCurrentXP()
    end
end

function kasenTransfiguration(caster,kasen2)
	if not caster:IsAlive() then return end
	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	caster:EmitSound("kasenhenshin")
	local duration = caster:FindAbilityByName("ability_thdots_kasen2_2"):GetSpecialValueFor("duration")
	local bkbDuration = caster:FindAbilityByName("ability_thdots_kasen2_2"):GetSpecialValueFor("bkbDuration")
	caster:AddNewModifier(caster,caster:FindAbilityByName("ability_thdots_kasen2_2"),"modifier_kasen_transfiguration",{})
	ability = caster:AddAbility("ability_thdots_kasen01")
	ability:SetLevel(caster:FindAbilityByName("ability_thdots_kasen2_4"):GetLevel())
	ability:SetActivated(false)
	ability = caster:AddAbility("ability_thdots_kasen03")
	ability:SetLevel(caster:FindAbilityByName("ability_thdots_kasen2_4"):GetLevel())
	ability:SetActivated(false)

	killKasenIllusion(caster)
end

ability_thdots_kasen2_sEx = {}

function ability_thdots_kasen2_sEx:GetIntrinsicModifierName()
	return "modifier_ability_kasen2_sEx_basic"
end

modifier_ability_kasen2_sEx_basic = {}
LinkLuaModifier("modifier_ability_kasen2_sEx_basic","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_sEx_basic:IsHidden() return true end
function modifier_ability_kasen2_sEx_basic:IsPurgable() return false end
function modifier_ability_kasen2_sEx_basic:IsDebuff() return false end
function modifier_ability_kasen2_sEx_basic:RemoveOnDeath() return false end

function modifier_ability_kasen2_sEx_basic:OnCreated()
	if not IsServer() then return end
    self.caster = self:GetParent():FindModifierByName("modifier_kasenIllusion"):GetCaster()
    self.caster:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_ability_kasen2_sEx_passive",{})
end

function modifier_ability_kasen2_sEx_basic:OnDestroy()
	if not IsServer() then return end
	self.caster:RemoveModifierByName("modifier_ability_kasen2_sEx_passive")
end

modifier_ability_kasen2_sEx_passive = {}
LinkLuaModifier("modifier_ability_kasen2_sEx_passive","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_sEx_passive:IsHidden() return true end
function modifier_ability_kasen2_sEx_passive:IsPurgable() return false end
function modifier_ability_kasen2_sEx_passive:IsDebuff() return false end
function modifier_ability_kasen2_sEx_passive:RemoveOnDeath() return false end

function modifier_ability_kasen2_sEx_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_kasen2_sEx_passive:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then return end
	--if not self:GetParent():IsAlive() then return end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	if self:GetCaster():GetHealth() > keys.damage*self:GetAbility():GetSpecialValueFor("percent")*0.01 then
		local damage_table = {
	        	victim = self:GetCaster(),
		        attacker = keys.attacker,
	        	damage = keys.damage*self:GetAbility():GetSpecialValueFor("percent")*0.01,
		        damage_type = DAMAGE_TYPE_PURE,
	           }
        UnitDamageTarget(damage_table)
        return keys.damage*self:GetAbility():GetSpecialValueFor("percent")*0.01
    else
    	local damage_table = {
	        	victim = self:GetCaster(),
		        attacker = keys.attacker,
	        	damage = self:GetCaster():GetHealth(),
		        damage_type = DAMAGE_TYPE_PURE,
	           }
        UnitDamageTarget(damage_table)
        return self:GetCaster():GetHealth()
    end
end

ability_thdots_kasen2_s1 = {}

function ability_thdots_kasen2_s1:GetIntrinsicModifierName()
	return "modifier_ability_kasen2_s1_basic"
end

modifier_ability_kasen2_s1_basic = {}
LinkLuaModifier("modifier_ability_kasen2_s1_basic","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_s1_basic:IsHidden() return true end
function modifier_ability_kasen2_s1_basic:IsPurgable() return false end
function modifier_ability_kasen2_s1_basic:IsDebuff() return false end
function modifier_ability_kasen2_s1_basic:RemoveOnDeath() return false end

function modifier_ability_kasen2_s1_basic:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_kasen2_s1_basic:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	if keys.target:IsBuilding() then return end
	local num = RandomInt(1,100)
	if not (num <= 25) then return end
	UtilStun:UnitStunTarget(keys.attacker,keys.target,self:GetAbility():GetSpecialValueFor("stuntime"))
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_gold.vpcf", PATTACH_ABSORIGIN,keys.target)
	ParticleManager:SetParticleControlEnt(effectIndex, 1, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effectIndex, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effectIndex, 2, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effectIndex, 3, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	keys.attacker:EmitSound("kasen2s1")
	local damage_table = {
	        victim = keys.target,
		    attacker = keys.attacker,
	        damage = self:GetAbility():GetSpecialValueFor("damage"),
		    damage_type = DAMAGE_TYPE_MAGICAL,
	       }
	UnitDamageTarget(damage_table)
	--ParticleManager:DestroyParticleSystem(effectIndex,false)
end

ability_thdots_kasen2_s2 = {}

function ability_thdots_kasen2_s2:GetIntrinsicModifierName()
	return "modifier_ability_kasen2_s2_basic"
end

modifier_ability_kasen2_s2_basic = {}
LinkLuaModifier("modifier_ability_kasen2_s2_basic","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen2_s2_basic:IsHidden() return true end
function modifier_ability_kasen2_s2_basic:IsPurgable() return false end
function modifier_ability_kasen2_s2_basic:IsDebuff() return false end
function modifier_ability_kasen2_s2_basic:RemoveOnDeath() return false end

function modifier_ability_kasen2_s2_basic:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_kasen2_s2_basic:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	if keys.target:IsBuilding() then return end
	if keys.attacker:HasModifier("modifier_kasenIllusion") then
		if keys.attacker:FindModifierByName("modifier_kasenIllusion"):GetAbility():GetLevel() == 1 then return end
	end
	local num = RandomInt(1,100)
	if not (num <= 25) then return end
	DoCleaveAttack(keys.attacker,keys.target,self:GetAbility(),keys.damage,150,450,self:GetAbility():GetSpecialValueFor("distance"),"")
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_attack_normal_punch.vpcf", PATTACH_ABSORIGIN,keys.attacker)
	ParticleManager:SetParticleControlEnt(effectIndex, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effectIndex, 2, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
end

kasen_dragon_splash_attack = {}

function kasen_dragon_splash_attack:GetIntrinsicModifierName()
	return "modifier_ability_kasen_dragon_splash_attack_basic"
end

modifier_ability_kasen_dragon_splash_attack_basic = {}
LinkLuaModifier("modifier_ability_kasen_dragon_splash_attack_basic","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_kasen_dragon_splash_attack_basic:IsHidden() return true end
function modifier_ability_kasen_dragon_splash_attack_basic:IsPurgable() return false end
function modifier_ability_kasen_dragon_splash_attack_basic:IsDebuff() return false end
function modifier_ability_kasen_dragon_splash_attack_basic:RemoveOnDeath() return false end

function modifier_ability_kasen_dragon_splash_attack_basic:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_kasen_dragon_splash_attack_basic:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return end
	if keys.target:IsBuilding() then return end
	DoCleaveAttack(keys.attacker,keys.target,self:GetAbility(),keys.damage*1.5,150,450,self:GetAbility():GetSpecialValueFor("distance"),"")
	local projectile = {Target = keys.target,
				Source = keys.target,
				Ability = self:GetAbility(),
				EffectName = "particles/neutral_fx/black_dragon_attack.vpcf",
				iMoveSpeed = 1000,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = true,
			}
	ProjectileManager:CreateTrackingProjectile(projectile)
end

ability_thdots_kasen2_s3 = {}

function ability_thdots_kasen2_s3:CastFilterResult()
	if not IsServer() then return end
	local kasen = self:GetCaster():FindModifierByName("modifier_kasenIllusion"):GetCaster():GetAbsOrigin()
	local kasen2 = self:GetCaster():GetAbsOrigin()
	local length = (kasen - kasen2):Length2D()
	local limit = self:GetCaster():FindModifierByName("modifier_kasenIllusion"):GetCaster():FindAbilityByName("ability_thdots_kasen2_4"):GetSpecialValueFor("cast_radius")
	if length <= limit then return UF_SUCCESS end
	return UF_FAIL_CUSTOM
end


function ability_thdots_kasen2_s3:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster():FindModifierByName("modifier_kasenIllusion"):GetCaster()
	local kasen2 = self:GetCaster()
	if not caster:HasModifier("modifier_item_wanbaochui") then return end
	FindClearSpaceForUnit(caster, kasen2:GetAbsOrigin(), true)
	kasenTransfiguration(caster,kasen2)
end

kasen_weird_attack = {}

function kasen_weird_attack:GetIntrinsicModifierName()
	return "modifier_kasen_weird_attack"
end

modifier_kasen_weird_attack = {}
LinkLuaModifier("modifier_kasen_weird_attack","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_weird_attack:IsHidden() return true end
function modifier_kasen_weird_attack:IsPurgable() return false end
function modifier_kasen_weird_attack:IsDebuff() return false end
function modifier_kasen_weird_attack:RemoveOnDeath() return false end

function modifier_kasen_weird_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_kasen_weird_attack:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsBuilding() then return end
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	if keys.target:HasModifier("modifier_kasen_weird_attack_slow") then keys.target:FindModifierByName("modifier_kasen_weird_attack_slow"):SetDuration(duration,true) return end
	keys.target:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_kasen_weird_attack_slow",{duration = duration})
end

modifier_kasen_weird_attack_slow = {}
LinkLuaModifier("modifier_kasen_weird_attack_slow","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_weird_attack_slow:IsHidden() return false end
function modifier_kasen_weird_attack_slow:IsPurgable() return true end
function modifier_kasen_weird_attack_slow:IsDebuff() return true end
function modifier_kasen_weird_attack_slow:RemoveOnDeath() return true end

function modifier_kasen_weird_attack_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_kasen_weird_attack_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_kasen_weird_attack_slow:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

kasen2_toulangaura = {}

function kasen2_toulangaura:GetIntrinsicModifierName()
	return "modifier_kasen_toulang_aura"
end

modifier_kasen_toulang_aura = {}
LinkLuaModifier("modifier_kasen_toulang_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_toulang_aura:IsHidden() return true end
function modifier_kasen_toulang_aura:IsPurgable() return false end
function modifier_kasen_toulang_aura:IsDebuff() return false end
function modifier_kasen_toulang_aura:RemoveOnDeath() return true end

function modifier_kasen_toulang_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_toulang_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_toulang_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_toulang_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_toulang_aura:GetModifierAura() return "modifier_kasen_toulang" end
function modifier_kasen_toulang_aura:IsAura() return true end

modifier_kasen_toulang = {}
LinkLuaModifier("modifier_kasen_toulang","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_toulang:IsHidden() return false end
function modifier_kasen_toulang:IsPurgable() return false end
function modifier_kasen_toulang:IsDebuff() return false end
function modifier_kasen_toulang:RemoveOnDeath() return true end

function modifier_kasen_toulang:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_kasen_toulang:GetModifierDamageOutgoing_Percentage()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("percent")
end

kasen2_huilanaura = {}

function kasen2_huilanaura:GetIntrinsicModifierName()
	return "modifier_kasen_huilan_aura"
end

modifier_kasen_huilan_aura = {}
LinkLuaModifier("modifier_kasen_huilan_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_huilan_aura:IsHidden() return true end
function modifier_kasen_huilan_aura:IsPurgable() return false end
function modifier_kasen_huilan_aura:IsDebuff() return false end
function modifier_kasen_huilan_aura:RemoveOnDeath() return true end

function modifier_kasen_huilan_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_huilan_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_huilan_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_huilan_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_huilan_aura:GetModifierAura() return "modifier_kasen_huilan" end
function modifier_kasen_huilan_aura:IsAura() return true end

modifier_kasen_huilan = {}
LinkLuaModifier("modifier_kasen_huilan","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_huilan:IsHidden() return false end
function modifier_kasen_huilan:IsPurgable() return false end
function modifier_kasen_huilan:IsDebuff() return false end
function modifier_kasen_huilan:RemoveOnDeath() return true end

function modifier_kasen_huilan:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end

function modifier_kasen_huilan:GetModifierConstantManaRegen()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end

kasen2_toulangcrit = {}

function kasen2_toulangcrit:GetIntrinsicModifierName()
	return "modifier_kasen2_toulangcrit_basic"
end

modifier_kasen2_toulangcrit_basic = {}
LinkLuaModifier("modifier_kasen2_toulangcrit_basic","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen2_toulangcrit_basic:IsHidden() return true end
function modifier_kasen2_toulangcrit_basic:IsPurgable() return false end
function modifier_kasen2_toulangcrit_basic:IsDebuff() return false end
function modifier_kasen2_toulangcrit_basic:RemoveOnDeath() return true end

function modifier_kasen2_toulangcrit_basic:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_kasen2_toulangcrit_basic:OnAttackStart(keys)
	if not IsServer() then return end
	if self:GetAbility() == nil then return end
	if keys.attacker ~= self:GetParent() then return end
	if keys.attacker:HasModifier("modifier_kasen2_toulangcrit") then
		keys.attacker:RemoveModifierByName("modifier_kasen2_toulangcrit")
	end
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	self.i = RandomInt(0,99)
	if self. i >= chance then return end
	keys.attacker:AddNewModifier(keys.attacker,self:GetAbility(),"modifier_kasen2_toulangcrit",{})
end

modifier_kasen2_toulangcrit = {}
LinkLuaModifier("modifier_kasen2_toulangcrit","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen2_toulangcrit:IsHidden() return true end
function modifier_kasen2_toulangcrit:IsPurgable() return false end
function modifier_kasen2_toulangcrit:IsDebuff() return false end
function modifier_kasen2_toulangcrit:RemoveOnDeath() return true end

function modifier_kasen2_toulangcrit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end

function modifier_kasen2_toulangcrit:GetModifierPreAttack_CriticalStrike()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("crit_percent")
end

kasen_magicalResistance_aura = {}

function kasen_magicalResistance_aura:GetIntrinsicModifierName()
	return "modifier_kasen_magicalResistance_aura"
end

modifier_kasen_magicalResistance_aura = {}
LinkLuaModifier("modifier_kasen_magicalResistance_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_magicalResistance_aura:IsHidden() return true end
function modifier_kasen_magicalResistance_aura:IsPurgable() return false end
function modifier_kasen_magicalResistance_aura:IsDebuff() return false end
function modifier_kasen_magicalResistance_aura:RemoveOnDeath() return true end

function modifier_kasen_magicalResistance_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_magicalResistance_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_magicalResistance_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_magicalResistance_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_magicalResistance_aura:GetModifierAura() return "modifier_kasen_magicalResistance" end
function modifier_kasen_magicalResistance_aura:IsAura() return true end

modifier_kasen_magicalResistance = {}
LinkLuaModifier("modifier_kasen_magicalResistance","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_magicalResistance:IsHidden() return true end
function modifier_kasen_magicalResistance:IsPurgable() return false end
function modifier_kasen_magicalResistance:IsDebuff() return false end
function modifier_kasen_magicalResistance:RemoveOnDeath() return true end

function modifier_kasen_magicalResistance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_kasen_magicalResistance:GetModifierMagicalResistanceBonus()
	if self:GetAbility() == nil then return 0 end
	if self:GetParent():IsRealHero() then
		return self:GetAbility():GetSpecialValueFor("magicResistance_percent")
	else
		return self:GetAbility():GetSpecialValueFor("magicResistance_percent") * 2
	end
end

kasen_armor_aura = {}

function kasen_armor_aura:GetIntrinsicModifierName()
	return "modifier_kasen_armor_aura"
end

modifier_kasen_armor_aura = {}
LinkLuaModifier("modifier_kasen_armor_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_armor_aura:IsHidden() return true end
function modifier_kasen_armor_aura:IsPurgable() return false end
function modifier_kasen_armor_aura:IsDebuff() return false end
function modifier_kasen_armor_aura:RemoveOnDeath() return true end

function modifier_kasen_armor_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_armor_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_armor_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_armor_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_armor_aura:GetModifierAura() return "modifier_kasen_armor" end
function modifier_kasen_armor_aura:IsAura() return true end

modifier_kasen_armor = {}
LinkLuaModifier("modifier_kasen_armor","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_armor:IsHidden() return true end
function modifier_kasen_armor:IsPurgable() return false end
function modifier_kasen_armor:IsDebuff() return false end
function modifier_kasen_armor:RemoveOnDeath() return true end

function modifier_kasen_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_kasen_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("armor_bonus")
end

kasen_HPregen_aura = {}

function kasen_HPregen_aura:GetIntrinsicModifierName()
	return "modifier_kasen_HPregen_aura"
end

modifier_kasen_HPregen_aura = {}
LinkLuaModifier("modifier_kasen_HPregen_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_HPregen_aura:IsHidden() return true end
function modifier_kasen_HPregen_aura:IsPurgable() return false end
function modifier_kasen_HPregen_aura:IsDebuff() return false end
function modifier_kasen_HPregen_aura:RemoveOnDeath() return true end

function modifier_kasen_HPregen_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_HPregen_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_HPregen_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_HPregen_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_HPregen_aura:GetModifierAura() return "modifier_kasen_HPregen" end
function modifier_kasen_HPregen_aura:IsAura() return true end

modifier_kasen_HPregen = {}
LinkLuaModifier("modifier_kasen_HPregen","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_HPregen:IsHidden() return true end
function modifier_kasen_HPregen:IsPurgable() return false end
function modifier_kasen_HPregen:IsDebuff() return false end
function modifier_kasen_HPregen:RemoveOnDeath() return true end

function modifier_kasen_HPregen:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_kasen_HPregen:GetModifierConstantHealthRegen()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("HP_regen")
end

kasen_attackspeed_aura = {}

function kasen_attackspeed_aura:GetIntrinsicModifierName()
	return "modifier_kasen_attackspeed_aura"
end

modifier_kasen_attackspeed_aura = {}
LinkLuaModifier("modifier_kasen_attackspeed_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_attackspeed_aura:IsHidden() return true end
function modifier_kasen_attackspeed_aura:IsPurgable() return false end
function modifier_kasen_attackspeed_aura:IsDebuff() return false end
function modifier_kasen_attackspeed_aura:RemoveOnDeath() return true end

function modifier_kasen_attackspeed_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_attackspeed_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_attackspeed_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_attackspeed_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_attackspeed_aura:GetModifierAura() return "modifier_kasen_attackspeed" end
function modifier_kasen_attackspeed_aura:IsAura() return true end

modifier_kasen_movespeed = {}
LinkLuaModifier("modifier_kasen_movespeed","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_movespeed:IsHidden() return true end
function modifier_kasen_movespeed:IsPurgable() return false end
function modifier_kasen_movespeed:IsDebuff() return false end
function modifier_kasen_movespeed:RemoveOnDeath() return true end

function modifier_kasen_movespeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_kasen_movespeed:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

kasen_movespeed_aura = {}

function kasen_movespeed_aura:GetIntrinsicModifierName()
	return "modifier_kasen_movespeed_aura"
end

modifier_kasen_movespeed_aura = {}
LinkLuaModifier("modifier_kasen_movespeed_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_movespeed_aura:IsHidden() return true end
function modifier_kasen_movespeed_aura:IsPurgable() return false end
function modifier_kasen_movespeed_aura:IsDebuff() return false end
function modifier_kasen_movespeed_aura:RemoveOnDeath() return true end

function modifier_kasen_movespeed_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_movespeed_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_movespeed_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_movespeed_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_movespeed_aura:GetModifierAura() return "modifier_kasen_movespeed" end
function modifier_kasen_movespeed_aura:IsAura() return true end

modifier_kasen_movespeed = {}
LinkLuaModifier("modifier_kasen_movespeed","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_movespeed:IsHidden() return true end
function modifier_kasen_movespeed:IsPurgable() return false end
function modifier_kasen_movespeed:IsDebuff() return false end
function modifier_kasen_movespeed:RemoveOnDeath() return true end

function modifier_kasen_movespeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_kasen_movespeed:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

kasen_HP_bonus_aura = {}

function kasen_HP_bonus_aura:GetIntrinsicModifierName()
	return "modifier_kasen_HP_bonus_aura"
end

modifier_kasen_HP_bonus_aura = {}
LinkLuaModifier("modifier_kasen_HP_bonus_aura","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_HP_bonus_aura:IsHidden() return true end
function modifier_kasen_HP_bonus_aura:IsPurgable() return false end
function modifier_kasen_HP_bonus_aura:IsDebuff() return false end
function modifier_kasen_HP_bonus_aura:RemoveOnDeath() return true end

function modifier_kasen_HP_bonus_aura:GetAuraRadius()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_kasen_HP_bonus_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_kasen_HP_bonus_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_kasen_HP_bonus_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_kasen_HP_bonus_aura:GetModifierAura() return "modifier_kasen_HP_bonus" end
function modifier_kasen_HP_bonus_aura:IsAura() return true end

modifier_kasen_HP_bonus = {}
LinkLuaModifier("modifier_kasen_HP_bonus","scripts/vscripts/abilities/abilitykasen2.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_kasen_HP_bonus:IsHidden() return true end
function modifier_kasen_HP_bonus:IsPurgable() return false end
function modifier_kasen_HP_bonus:IsDebuff() return false end
function modifier_kasen_HP_bonus:RemoveOnDeath() return true end

function modifier_kasen_HP_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
end

function modifier_kasen_HP_bonus:GetModifierExtraHealthPercentage()
	if self:GetAbility() == nil then return 0 end
	return self:GetAbility():GetSpecialValueFor("HP_bonus")
end

-- kasen_hurricane = {}

-- function kasen_hurricane:OnSpellStart()

-- end
