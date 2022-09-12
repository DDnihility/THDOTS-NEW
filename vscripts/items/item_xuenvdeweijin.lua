item_xuenvdeweijin={}
function item_xuenvdeweijin:GetIntrinsicModifierName()
	return "modifier_item_xuenvdeweijin"
end

modifier_item_xuenvdeweijin={}
LinkLuaModifier("modifier_item_xuenvdeweijin","items/item_xuenvdeweijin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_xuenvdeweijin:IsHidden() return true end
function modifier_item_xuenvdeweijin:IsPurgable() return false end
function modifier_item_xuenvdeweijin:IsPurgeException() return false end
function modifier_item_xuenvdeweijin:RemoveOnDeath() return false end
function modifier_item_xuenvdeweijin:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_xuenvdeweijin:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
    }
end

function modifier_item_xuenvdeweijin:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_item_xuenvdeweijin:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_item_xuenvdeweijin:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

function modifier_item_xuenvdeweijin:GetModifierPhysical_ConstantBlock(events)--被攻击时触发,不必检测伤害来源
    if IsClient() then return end
	if RollPercentage(self.block_chance) then
        if events.damage * self.block_percent <= self.block_damage_melee then return events.damage * self.block_percent end
		if not self:GetParent():IsRangedAttacker() then
			return self.block_damage_melee
		else
			return self.block_damage_ranged
		end
	end
end

function modifier_item_xuenvdeweijin:OnCreated()
    if not IsServer() then return end
    self.block_chance = self:GetAbility():GetSpecialValueFor("chance")
    self.block_damage_melee = self:GetAbility():GetSpecialValueFor("block")
    self.block_damage_ranged = self:GetAbility():GetSpecialValueFor("block")
    self.block_percent = self:GetAbility():GetSpecialValueFor("percent")/100
    self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
    self.caster = self:GetCaster()
    self:StartIntervalThink(1) 
end

function modifier_item_xuenvdeweijin:OnIntervalThink()
    if not IsServer() then return end
    if self.caster:IsAlive() then
    local Targets = FindUnitsInRadius(				   
                self.caster:GetTeam(),		
                self.caster:GetOrigin(),		
                nil,					
                self.radius,		
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING,
                0,
                FIND_CLOSEST,
                false)
    for _,v in pairs(Targets) do
        v:AddNewModifier(self.caster, self:GetAbility(), "modifier_item_xuenvdeweijin_enemy_aura", {duration = 1})
    end
    end
end

modifier_item_xuenvdeweijin_enemy_aura={}
LinkLuaModifier("modifier_item_xuenvdeweijin_enemy_aura","items/item_xuenvdeweijin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_xuenvdeweijin_enemy_aura:IsHidden() return false end
function modifier_item_xuenvdeweijin_enemy_aura:IsPurgable() return true end
function modifier_item_xuenvdeweijin_enemy_aura:IsPurgeException() return false end
function modifier_item_xuenvdeweijin_enemy_aura:RemoveOnDeath() return true end

function modifier_item_xuenvdeweijin_enemy_aura:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_item_xuenvdeweijin_enemy_aura:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("aura_attack_speed") end



function item_xuenvdeweijin:OnSpellStart()
    local caster = self:GetCaster()
    self.BlastFinalRadius = self:GetSpecialValueFor("blast_final_radius")
    self.BlastSpeedPerSecond = self:GetSpecialValueFor("blast_speed_per_second")
	local shivas_guard_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(shivas_guard_particle, 1, Vector(self.BlastFinalRadius, self.BlastFinalRadius / self.BlastSpeedPerSecond, self.BlastSpeedPerSecond))
	caster:AddNewModifier(caster, self, "modifier_item_xuenvdeweijin_shield", {duration = self:GetSpecialValueFor("shield_duration")})	
	caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	caster.xuenvdeweijin_blast_radius=0.0
	caster:SetThink(function ()
		if (caster.xuenvdeweijin_blast_radius>=self.BlastFinalRadius) then 
			return nil 
		end
		self:CreateVisibilityNode(caster:GetAbsOrigin(), self:GetSpecialValueFor("blast_vision_radius"), self:GetSpecialValueFor("blast_vision_duration"))
		caster.xuenvdeweijin_blast_radius = caster.xuenvdeweijin_blast_radius + (self.BlastSpeedPerSecond *0.03)
		local nearby_enemy_units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, caster.xuenvdeweijin_blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for _, individual_unit in ipairs(nearby_enemy_units) do
				if not individual_unit:HasModifier("modifier_item_xuenvdeweijin_blast_debuff") then
					--This impact particle effect should radiate away from the caster of Shiva's Guard.
					local shivas_guard_impact_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
					local target_point = individual_unit:GetAbsOrigin()
					local caster_point = individual_unit:GetAbsOrigin()
					ParticleManager:SetParticleControl(shivas_guard_impact_particle, 1, target_point + (target_point - caster_point) * 30)
                    individual_unit:AddNewModifier(caster, self, "modifier_item_xuenvdeweijin_blast_debuff", {duration = self:GetSpecialValueFor("blast_debuff_duration") * (1 - individual_unit:GetStatusResistance())})
					local damage_table = {
						ability = self,
						victim = individual_unit,
						attacker = caster,
						damage = self:GetSpecialValueFor("blast_damage"),
						damage_type = DAMAGE_TYPE_MAGICAL,
					}
					UnitDamageTarget(damage_table)					
				end
			end
		return 0.03
	end)
end

modifier_item_xuenvdeweijin_shield={}
LinkLuaModifier("modifier_item_xuenvdeweijin_shield","items/item_xuenvdeweijin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_xuenvdeweijin_shield:IsHidden() return false end
function modifier_item_xuenvdeweijin_shield:IsPurgable() return true end
function modifier_item_xuenvdeweijin_shield:IsPurgeException() return false end
function modifier_item_xuenvdeweijin_shield:RemoveOnDeath() return true end

function modifier_item_xuenvdeweijin_shield:GetEffectName() return "particles/thd2/items/item_ballon.vpcf" end
function modifier_item_xuenvdeweijin_shield:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_xuenvdeweijin_shield:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
    }
end
function modifier_item_xuenvdeweijin_shield:GetModifierIncomingPhysicalDamage_Percentage() return self:GetAbility():GetSpecialValueFor("incoming_damage_reduce") end

modifier_item_xuenvdeweijin_blast_debuff={}
LinkLuaModifier("modifier_item_xuenvdeweijin_blast_debuff","items/item_xuenvdeweijin.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_xuenvdeweijin_blast_debuff:IsHidden() return false end
function modifier_item_xuenvdeweijin_blast_debuff:IsPurgable() return false end
function modifier_item_xuenvdeweijin_blast_debuff:IsPurgeException() return false end
function modifier_item_xuenvdeweijin_blast_debuff:RemoveOnDeath() return true end
function modifier_item_xuenvdeweijin_blast_debuff:IsDebuff() return true end

function modifier_item_xuenvdeweijin_blast_debuff:StatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_item_xuenvdeweijin_blast_debuff:StatusEffectPriority() return 10 end

function modifier_item_xuenvdeweijin_blast_debuff:DeclareFunctions() return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_item_xuenvdeweijin_blast_debuff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("blast_movement_speed_debuff") end