--4/26/2022 Update

----------------------------------------------------------------------------------------------

-- function UnitDamageTarget(DamageTable)
--     local dDamage = vlua.clone(DamageTable)
--     local victim = dDamage.victim or dDamage.target
--     if victim == nil or victim:IsNull() then return end
--     if(victim:IsNightmared())then
--         victim:RemoveModifierByName("modifier_bane_nightmare")
--     end
--     --[[if dDamage.attacker:HasItemInInventory("item_bagua") then
--                         dDamage.damage = dDamage.damage * 1.25
--                     end]]
--     --[[if dDamage.attacker:HasModifier("modifier_thdots_patchouli_xianzhezhishi_sun") then
--                         dDamage.damage = dDamage.damage * 1.1
--                     end]]

--     -- 破魔驱散绿坝的盾
--     -- if dDamage.attacker:HasItemInInventory("item_pomojinlingli") and dDamage.damage_type == DAMAGE_TYPE_MAGICAL then
--     -- 	if victim:HasModifier("modifier_item_green_dam_barrier") then
--     -- 		victim:RemoveModifierByName("modifier_item_green_dam_barrier")
--     -- 	end
--     -- end
    
--     if dDamage.damage_type == DAMAGE_TYPE_PURE and dDamage.damage >= 100 then
--         SendOverheadEventMessage(nil,OVERHEAD_ALERT_DAMAGE,victim,dDamage.damage,nil)
--     end
--     return ApplyDamage(dDamage)
-- end

-- function FindTelentValue(caster,name)
--     local ability = caster:FindAbilityByName(name)
--     if ability~=nil then
--         return ability:GetSpecialValueFor("value")
--     else
--         return 0
--     end
-- end

function jyoon_generateParticleOnce(name,attach,target)
    local particle = ParticleManager:CreateParticle(name, attach, target)
    ParticleManager:ReleaseParticleIndex(particle)
    ParticleManager:DestroyParticle(particle,false)
    return particle
end

function jyoon_createKnockBack(caster,target,distance,height,duration,ability)
    if target:HasModifier("modifier_thdots_yugi04_think_interval") then duration = 0.1 end
    --击退信息
    local knockback_properties = {
        center_x 			= caster:GetAbsOrigin().x,
        center_y 			= caster:GetAbsOrigin().y,
        center_z 			= caster:GetAbsOrigin().z,
        duration 			= duration,
        knockback_duration = 1,
        knockback_distance = distance,
        knockback_height 	= height
    }
    target:AddNewModifier(caster,ability,"modifier_knockback",knockback_properties)
end
    ----------------------------------------------------------------------------------------------
-- 技能1

-- 初始化
ability_thdots_Jyoon_1 = class({})
-- 基础判定
function ability_thdots_Jyoon_1:IsHiddenWhenStolen()        return false end
function ability_thdots_Jyoon_1:IsRefreshable()             return true end
function ability_thdots_Jyoon_1:IsStealable()           return false end

--技能
function ability_thdots_Jyoon_1:GetIntrinsicModifierName()
    return  "modifier_ability_thdots_Jyoon_1_thinker"
end

--Modifiers
modifier_ability_thdots_Jyoon_1_thinker = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_1_thinker","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
--modifier 基础判定
function modifier_ability_thdots_Jyoon_1_thinker:IsHidden()      return true end
function modifier_ability_thdots_Jyoon_1_thinker:IsPurgable()        return false end
function modifier_ability_thdots_Jyoon_1_thinker:RemoveOnDeath()     return false end
function modifier_ability_thdots_Jyoon_1_thinker:IsDebuff()      return false end
function modifier_ability_thdots_Jyoon_1_thinker:AllowIllusionDuplicate() return false end


function modifier_ability_thdots_Jyoon_1_thinker:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_Jyoon_1_thinker:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    local caster = self:GetCaster()

    if ability:IsCooldownReady() then
        caster:AddNewModifier(caster,ability,"modifier_ability_thdots_Jyoon_1",{})
    end
end

--Modifiers
modifier_ability_thdots_Jyoon_1 = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_1","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_1:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_1:IsPurgable()        return false end
function modifier_ability_thdots_Jyoon_1:RemoveOnDeath()     return false end
function modifier_ability_thdots_Jyoon_1:IsDebuff()      return false end

--modifier 修改列表
function modifier_ability_thdots_Jyoon_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
    }
    return funcs
end

function modifier_ability_thdots_Jyoon_1:GetModifierPreAttack_CriticalStrike(keys)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("special_bonus_unique_Jyoon_ability1_crit")
    local value = 0
    if(ability ~= nil) then
        value = ability:GetSpecialValueFor("value")
    end
    if keys.attacker == caster and keys.target:GetTeamNumber() == caster:GetTeamNumber() then 
        return 0 
    end
    return self:GetAbility():GetSpecialValueFor("crit_damage") + value
end

-- 攻击距离加成
function modifier_ability_thdots_Jyoon_1:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("range")
end
--攻击判定
function modifier_ability_thdots_Jyoon_1:OnAttackLanded(keys)
    if not IsServer() then return end
    
    local ability = self:GetAbility()
    local enemy = keys.target
    local caster = self:GetCaster()
    --冷却判定
    if keys.attacker == caster and keys.attacker:IsRealHero() and enemy:GetTeamNumber() ~= caster:GetTeamNumber() and ability:IsCooldownReady() then
        ability:StartCooldown(ability:GetEffectiveCooldown(ability:GetLevel()-1))

        --攻击特效
        local attack_particle = "particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada_embers.vpcf"
        jyoon_generateParticleOnce(attack_particle,PATTACH_ABSORIGIN_FOLLOW,enemy)

        --计算偷钱
        local steal_gold = ability:GetSpecialValueFor("steal_gold") + FindTelentValue(caster,"special_bonus_unique_Jyoon_ability1_gold")

        --print(PlayerResource:GetUnreliableGold(enemy:GetPlayerOwnerID()))
        if enemy:IsHero() and not enemy:IsIllusion() then
            --if(enemy:GetGold() - steal_gold < 0)then
            --    steal_gold = enemy:GetGold()
            --end
            --修改金币
            local unreliableGold = PlayerResource:GetUnreliableGold(enemy:GetPlayerOwnerID())
            if steal_gold > unreliableGold then steal_gold = unreliableGold end
            caster:ModifyGold(steal_gold, false, DOTA_ModifyGold_Unspecified)
            enemy:ModifyGold(- steal_gold, false, DOTA_ModifyGold_Unspecified)
            SendOverheadEventMessage(nil,OVERHEAD_ALERT_GOLD,caster,steal_gold,nil)
            --敌人丢钱特效
            local particle = "particles/econ/taunts/bounty_hunter/bh_taunt_goldpiles/bh_taunt_goldpiles_coindust.vpcf"
            local particle2 = "particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf"
            jyoon_generateParticleOnce(particle,PATTACH_ABSORIGIN_FOLLOW,enemy)
            local particle_effect = ParticleManager:CreateParticle(particle2,PATTACH_POINT,enemy)
            ParticleManager:SetParticleControlEnt(particle_effect,1,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin()+Vector(0,0,100) ,true)
            ParticleManager:ReleaseParticleIndex(particle_effect)
        end
        caster:RemoveModifierByName("modifier_ability_thdots_Jyoon_1")
    end
end
----------------------------------------------------------------------------------------------
-- 技能2

-- 初始化
ability_thdots_Jyoon_2 = class({})

--辅助function

--函数作用：计算距离
--函数输入：1. 坐标A 2.坐标B
--函数输出：距离
function ability_thdots_Jyoon_2:calDistancePoint(v1,v2)
    return math.sqrt(((v2.x-v1.x)*(v2.x-v1.x))+((v2.y-v1.y)*(v2.y-v1.y)))
end

-- 基础判定
function ability_thdots_Jyoon_2:IsHiddenWhenStolen()        return false end
function ability_thdots_Jyoon_2:IsRefreshable()             return true end
function ability_thdots_Jyoon_2:IsStealable()           return true end
function ability_thdots_Jyoon_2:GetAOERadius() 
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("special_bonus_unique_Jyoon_ability2_radius")
    local value = 0
    if(ability ~= nil) then
        value = ability:GetSpecialValueFor("value")
    end
    return self:GetSpecialValueFor("radius") + value
end
function ability_thdots_Jyoon_2:GetIntrinsicModifierName() return "modifier_ability_thdots_Jyoon_2_wanbaochui" end
-- 技能施法事件
function ability_thdots_Jyoon_2:OnSpellStart()
    if not IsServer() then return end
    
    --基础信息
    local caster = self:GetCaster()
    local ability = self

    --投射物信息
    local target_location = self:GetCursorPosition()
    local current_location = caster:GetAbsOrigin()
    local direction = caster:GetForwardVector()
    local speed = ability:GetSpecialValueFor("projectile_speed")

    --传送信息
    self.target_loc = target_location

    local projectile_table = {
        Source = caster,
        Ability = ability,
        EffectName = "particles/neutral_fx/satyr_hellcaller.vpcf",
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = caster:GetTeamNumber(),
        vSpawnOrigin = current_location,
        vVelocity = direction * speed,
        fDistance = self:calDistancePoint(target_location,current_location),
        fStartRadius = self:GetSpecialValueFor("collision_radius"),
        fEndRadius = self:GetSpecialValueFor("collision_radius"),
        -- iUnitTargetTeam	 	= ability:GetAbilityTargetTeam(),
	   	-- iUnitTargetType 	= ability:GetAbilityTargetType(),
        -- iUnitTargetFlags = ability:GetAbilityTargetFlags(),
        bIgnoreSource = true,
        bHasFrontalCone = false,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
    }
    ProjectileManager:CreateLinearProjectile(projectile_table)
end

function ability_thdots_Jyoon_2:OnProjectileHitHandle(hTarget,vLocation,iProjectileHandle)
    if not IsServer() then return end

    --基本信息
    local caster = self:GetCaster()
    local ability = self
    local radius = self:GetSpecialValueFor("radius") + FindTelentValue(caster,"special_bonus_unique_Jyoon_ability2_radius")

    --寻找附近单位
    local enemy = FindUnitsInRadius(
        caster:GetTeam(),
        vLocation,
        nil,
        radius,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    --处理目标
    for _,unit in pairs(enemy) do
        unit:AddNewModifier(caster,self,"modifier_ability_thdots_Jyoon_2_debuff",{duration = ability:GetSpecialValueFor("duration")})

        local damage_table=
        {
            victim = unit,
            attacker = caster,
            damage          = ability:GetSpecialValueFor("damage"),
            damage_type     = ability:GetAbilityDamageType(),
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }
        UnitDamageTarget(damage_table)
    end

    --特效
    local particle = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_marker.vpcf"
    local particle_effect = ParticleManager:CreateParticle(particle,PATTACH_POINT,caster)
    ParticleManager:SetParticleControl(particle_effect,0,vLocation)
    ParticleManager:SetParticleControl(particle_effect,1,Vector(radius,radius,radius))
    ParticleManager:ReleaseParticleIndex(particle_effect)
    --return true 会移除投射物
    return true
end

--Modifiers
modifier_ability_thdots_Jyoon_2_debuff = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_debuff","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_2_debuff:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_2_debuff:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_2_debuff:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_2_debuff:IsDebuff()      return true end

--modifier 修改列表
function modifier_ability_thdots_Jyoon_2_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_ability_thdots_Jyoon_2_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -(self:GetAbility():GetSpecialValueFor("slow_amount_percent"))* (1 - self:GetParent():GetStatusResistance())
end

function modifier_ability_thdots_Jyoon_2_debuff:OnCreated()
    if not IsServer() then return end
    debuff_list = {
        "modifier_ability_thdots_Jyoon_2_stunned","modifier_ability_thdots_Jyoon_2_silence","modifier_ability_thdots_Jyoon_2_rooted","modifier_fear","modifier_ability_thdots_Jyoon_2_disarm"
        --modifier_ability_thdots_Jyoon_2_fear
    }
    self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),debuff_list[RandomInt(1,#debuff_list)],{duration = self:GetAbility():GetSpecialValueFor("duration")* (1 - self:GetParent():GetStatusResistance())})
    self:GetParent():EmitSound("Hero_DarkWillow.Fear.Location")
end


--自定义的modifier
modifier_ability_thdots_Jyoon_2_stunned = class({})
modifier_ability_thdots_Jyoon_2_silence = class({})
modifier_ability_thdots_Jyoon_2_rooted = class({})
modifier_ability_thdots_Jyoon_2_fear = class({})
modifier_ability_thdots_Jyoon_2_disarm = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_stunned","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_silence","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_rooted","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_fear","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_disarm","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
--眩晕
function modifier_ability_thdots_Jyoon_2_stunned:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_2_stunned:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_2_stunned:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_2_stunned:IsDebuff()      return true end
function modifier_ability_thdots_Jyoon_2_stunned:GetEffectName()
    return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned_symbol.vpcf"
end
function modifier_ability_thdots_Jyoon_2_stunned:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_ability_thdots_Jyoon_2_stunned:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }
    return state
end
--沉默
function modifier_ability_thdots_Jyoon_2_silence:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_2_silence:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_2_silence:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_2_silence:IsDebuff()      return true end
function modifier_ability_thdots_Jyoon_2_silence:GetEffectName()
    return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced.vpcf"
end
function modifier_ability_thdots_Jyoon_2_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_ability_thdots_Jyoon_2_silence:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }
    return state
end
--缠绕
function modifier_ability_thdots_Jyoon_2_rooted:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_2_rooted:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_2_rooted:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_2_rooted:IsDebuff()      return true end
function modifier_ability_thdots_Jyoon_2_rooted:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
end
function modifier_ability_thdots_Jyoon_2_rooted:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_ability_thdots_Jyoon_2_rooted:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end
--恐惧
-- function modifier_ability_thdots_Jyoon_2_fear:IsHidden()      return false end
-- function modifier_ability_thdots_Jyoon_2_fear:IsPurgable()        return true end
-- function modifier_ability_thdots_Jyoon_2_fear:RemoveOnDeath()     return true end
-- function modifier_ability_thdots_Jyoon_2_fear:IsDebuff()      return true end
-- function modifier_ability_thdots_Jyoon_2_fear:GetEffectName()
--     return "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf"
-- end
-- function modifier_ability_thdots_Jyoon_2_fear:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end
-- function modifier_ability_thdots_Jyoon_2_fear:CheckState()
--     local state = {
--         [MODIFIER_STATE_FEARED] = true,
--     }
--     return state
-- end
--缴械
function modifier_ability_thdots_Jyoon_2_disarm:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_2_disarm:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_2_disarm:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_2_disarm:IsDebuff()      return true end
function modifier_ability_thdots_Jyoon_2_disarm:GetEffectName()
    return "particles/units/heroes/hero_sniper/concussive_grenade_disarm.vpcf"
end
function modifier_ability_thdots_Jyoon_2_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_ability_thdots_Jyoon_2_disarm:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end
--自定义modifier end

--万宝槌
modifier_ability_thdots_Jyoon_2_wanbaochui = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_2_wanbaochui","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_Jyoon_2_wanbaochui:IsHidden()
    if(self:GetParent():HasModifier("modifier_item_wanbaochui")) then
        return false
    else
        return true
    end
end
function modifier_ability_thdots_Jyoon_2_wanbaochui:IsPurgable()        return false end
function modifier_ability_thdots_Jyoon_2_wanbaochui:RemoveOnDeath()     return false end
function modifier_ability_thdots_Jyoon_2_wanbaochui:IsDebuff()      return false end
function modifier_ability_thdots_Jyoon_2_wanbaochui:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self:SetStackCount(0)
end
function modifier_ability_thdots_Jyoon_2_wanbaochui:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    if(caster:HasModifier("modifier_item_wanbaochui") and self:GetStackCount() < ability:GetSpecialValueFor("wanbaochui_charge_time")) then
        self:SetStackCount(self:GetStackCount()+1)
    end
end

function modifier_ability_thdots_Jyoon_2_wanbaochui:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_ability_thdots_Jyoon_2_wanbaochui:GetModifierIncomingDamage_Percentage(keys)
    if not IsServer() then return end
    --基本信息
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius") + FindTelentValue(caster,"special_bonus_unique_Jyoon_ability2_radius")

    if(keys.attacker:IsHero() and keys.target == caster) then
        if(caster:HasModifier("modifier_item_wanbaochui") and self:GetStackCount() >= ability:GetSpecialValueFor("wanbaochui_charge_time")) then

            --寻找附近单位
            local enemy = FindUnitsInRadius(
                caster:GetTeam(),
                caster:GetAbsOrigin(),
                nil,
                radius,
                ability:GetAbilityTargetTeam(),
                ability:GetAbilityTargetType(),
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )
    
            --处理目标
            for _,unit in pairs(enemy) do
                unit:AddNewModifier(caster,ability,"modifier_ability_thdots_Jyoon_2_debuff",{duration = ability:GetSpecialValueFor("duration")})
    
                local damage_table=
                {
                    victim = unit,
                    attacker = caster,
                    damage          = ability:GetSpecialValueFor("damage"),
                    damage_type     = ability:GetAbilityDamageType(),
                    damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                    ability = self
                }
                UnitDamageTarget(damage_table)
            end
            --特效
            local particle = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_marker.vpcf"
            local particle_effect = ParticleManager:CreateParticle(particle,PATTACH_POINT,caster)
            ParticleManager:SetParticleControl(particle_effect,0,caster:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_effect,1,Vector(radius,radius,radius))
            ParticleManager:ReleaseParticleIndex(particle_effect)
            self:SetStackCount(0)
        end
    end
    return 0
end

----------------------------------------------------------------------------------------------
-- 技能3

-- 初始化
ability_thdots_Jyoon_3 = class({})

-- 基础判定
function ability_thdots_Jyoon_3:IsHiddenWhenStolen()        return false end
function ability_thdots_Jyoon_3:IsRefreshable()             return true end
function ability_thdots_Jyoon_3:IsStealable()           return true end
function ability_thdots_Jyoon_3:GetAOERadius()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("special_bonus_unique_Jyoon_ability3_mark_range")
    local value = 0
    if(ability ~= nil) then
        value = ability:GetSpecialValueFor("value")
    end
    return self:GetSpecialValueFor("radius") + value
end

function ability_thdots_Jyoon_3:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    local range = self:GetSpecialValueFor("radius") + FindTelentValue(self:GetCaster(), "special_bonus_unique_Jyoon_ability3_mark_range")

    local enemy = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _,unit in pairs(enemy) do
        unit:AddNewModifier(caster,self,"modifier_ability_thdots_Jyoon_3_mark",{duration = self:GetSpecialValueFor("sight_duration")})
        
    end
    caster:AddNewModifier(caster,self,"modifier_ability_thdots_Jyoon_3_buff",{duration = self:GetSpecialValueFor("duration") + (#enemy * ability:GetSpecialValueFor("extra_duration_multiplier"))})
    caster:EmitSound("Hero_Spirit_Breaker.Bulldoze.Cast")
end

--modifier: 加速和状态抗性
modifier_ability_thdots_Jyoon_3_buff = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_3_buff","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_3_buff:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_3_buff:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_3_buff:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_3_buff:IsDebuff()      return false end
function modifier_ability_thdots_Jyoon_3_buff:GetEffectName() 
    return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf"
end


--modifier 创建
function modifier_ability_thdots_Jyoon_3_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE
    }
    return funcs
end

function modifier_ability_thdots_Jyoon_3_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("move_speed_bonus_percentage")
end

function modifier_ability_thdots_Jyoon_3_buff:GetModifierStatusResistance()
    return self:GetAbility():GetSpecialValueFor("status_resist")
end

--modifier: 标记
modifier_ability_thdots_Jyoon_3_mark = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_3_mark","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_3_mark:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_3_mark:IsPurgable()        return true end
function modifier_ability_thdots_Jyoon_3_mark:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_3_mark:IsDebuff()      return true end
function modifier_ability_thdots_Jyoon_3_mark:GetEffectName() 
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_scroll.vpcf"
end
function modifier_ability_thdots_Jyoon_3_mark:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_thdots_Jyoon_3_mark:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
    }
    return funcs
end

function modifier_ability_thdots_Jyoon_3_mark:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
    return state
end

function modifier_ability_thdots_Jyoon_3_mark:GetModifierProvidesFOWVision()
    return 1
end

function modifier_ability_thdots_Jyoon_3_mark:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end
----------------------------------------------------------------------------------------------
-- 技能4

-- 初始化
ability_thdots_Jyoon_4 = class({})

-- 基础判定
function ability_thdots_Jyoon_4:IsHiddenWhenStolen()        return false end
function ability_thdots_Jyoon_4:IsRefreshable()             return true end
function ability_thdots_Jyoon_4:IsStealable()           return true end

function ability_thdots_Jyoon_4:OnSpellStart()
    if not IsServer() then return end

    --基础信息
    local caster = self:GetCaster()
    
    caster:AddNewModifier(caster,self,"modifier_ability_thdots_Jyoon_4_buff",{duration = self:GetSpecialValueFor("duration")})
    caster:EmitSound("Hero_Marci.Unleash.Cast")
end 

--主要buff
modifier_ability_thdots_Jyoon_4_buff = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_4_buff","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_4_buff:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_4_buff:IsPurgable()        return false end
function modifier_ability_thdots_Jyoon_4_buff:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_4_buff:IsDebuff()      return false end
function modifier_ability_thdots_Jyoon_4_buff:GetEffectName() 
    return "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf"
end
function modifier_ability_thdots_Jyoon_4_buff:GetEffectAttachType() 
    return PATTACH_POINT_FOLLOW
end

function modifier_ability_thdots_Jyoon_4_buff:OnCreated()
    if not IsServer() then return end
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ability_thdots_Jyoon_4_attackInterval", {duration = self:GetAbility():GetSpecialValueFor("duration")})
        local particle = "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW , self:GetCaster())
    return
end


--攻击时间buff
modifier_ability_thdots_Jyoon_4_attackInterval = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_4_attackInterval","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_4_attackInterval:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_4_attackInterval:IsPurgable()        return false end
function modifier_ability_thdots_Jyoon_4_attackInterval:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_4_attackInterval:IsDebuff()      return false end

function modifier_ability_thdots_Jyoon_4_attackInterval:OnCreated()
    if not IsServer() then return end
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("attackCount"))
        self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_marci/marci_unleash_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,self:GetCaster())
        ParticleManager:SetParticleControl(self.effect,1,Vector(0,self:GetStackCount(),0))
        self:GetParent():EmitSound("Hero_Marci.Unleash.Charged")
    return
end


function modifier_ability_thdots_Jyoon_4_attackInterval:OnDestroy()
    if not IsServer() then return end

    if(self:GetCaster():HasModifier("modifier_ability_thdots_Jyoon_4_buff") and self:GetCaster():FindModifierByName("modifier_ability_thdots_Jyoon_4_buff"):GetRemainingTime()>0.1) then
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ability_thdots_Jyoon_4_disarm", {duration = self:GetAbility():GetSpecialValueFor("disarmInterval")})
    end
    ParticleManager:DestroyParticle(self.effect,false)
    ParticleManager:ReleaseParticleIndex(self.effect)
    
end

function modifier_ability_thdots_Jyoon_4_attackInterval:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_ability_thdots_Jyoon_4_attackInterval:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("attck_increase")
end

function modifier_ability_thdots_Jyoon_4_attackInterval:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_increase")
end

function modifier_ability_thdots_Jyoon_4_attackInterval:OnAttackLanded(keys)
    if not IsServer() then return end

    local ability = self:GetAbility()
    local enemy = keys.target
    local caster = self:GetCaster()
    local stackCount = self:GetStackCount()
    local caster_loc = caster:GetAbsOrigin()
    local knockback = self:GetAbility():GetSpecialValueFor("knockback_distance")

    --天赋吸血
    if keys.attacker == caster and not enemy:IsTower() and not enemy:IsBuilding()then
        local damage = keys.damage
        local heal = damage * FindTelentValue(self:GetCaster(),"special_bonus_unique_Jyoon_ability4_lifesteal")/100
        caster:Heal(heal, caster)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, nil)
    end 

    --攻击判定
    if keys.attacker == caster then
        self:SetStackCount(self:GetStackCount()-1)
        ParticleManager:SetParticleControl(self.effect,1,Vector(0,self:GetStackCount(),0))
        --特效
        local particle = "particles/units/heroes/hero_marci/marci_unleash_attack_model.vpcf"
        local particle2 = "particles/units/heroes/hero_marci/marci_dispose_land.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, caster)
        local effect2 = ParticleManager:CreateParticle(particle2, PATTACH_POINT_FOLLOW, enemy)
        --effect
        ParticleManager:SetParticleControl(effect, 0, Vector(0,0,0))
        --effect2
        ParticleManager:SetParticleControlEnt(effect2, 1, enemy, PATTACH_POINT_FOLLOW, nil, enemy:GetAbsOrigin(), true)

        --Free Index
        ParticleManager:ReleaseParticleIndex(effect)
        ParticleManager:ReleaseParticleIndex(effect2)

        if(not enemy:IsTower() and not enemy:IsBuilding()) then
            enemy:AddNewModifier(caster, nil, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
        end
        if(self:GetStackCount()<1) then
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5,4)
            if(not enemy:IsTower() and not enemy:IsBuilding()) then
                jyoon_createKnockBack(self:GetCaster(),enemy,knockback,100,1,self:GetAbility())
            end
            self:Destroy()
        end
        caster:EmitSound("Hero_Marci.Unleash.Pulse")
    end
end

--缴械时间buff
modifier_ability_thdots_Jyoon_4_disarm = class({})
LinkLuaModifier("modifier_ability_thdots_Jyoon_4_disarm","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_Jyoon_4_disarm:IsHidden()      return false end
function modifier_ability_thdots_Jyoon_4_disarm:IsPurgable()        return false end
function modifier_ability_thdots_Jyoon_4_disarm:RemoveOnDeath()     return true end
function modifier_ability_thdots_Jyoon_4_disarm:IsDebuff()      return false end

function modifier_ability_thdots_Jyoon_4_disarm:OnDestroy()
    if not IsServer() then return end
        if(self:GetCaster():HasModifier("modifier_ability_thdots_Jyoon_4_buff")) then
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ability_thdots_Jyoon_4_attackInterval", {duration = self:GetCaster():FindModifierByName("modifier_ability_thdots_Jyoon_4_buff"):GetRemainingTime()})
        end
    return
end

function modifier_ability_thdots_Jyoon_4_disarm:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

function modifier_ability_thdots_Jyoon_4_disarm:GetEffectName()
	return "particles/units/heroes/hero_sniper/concussive_grenade_disarm.vpcf"
end

function modifier_ability_thdots_Jyoon_4_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

----------------------------------------------------------------------------------------------

-- 天生

-- 初始化
ability_thdots_Jyoon_passive = class({})

-- 基础判定
function ability_thdots_Jyoon_passive:IsHiddenWhenStolen()        return false end
function ability_thdots_Jyoon_passive:IsRefreshable()             return true end
function ability_thdots_Jyoon_passive:IsStealable()           return false end
function ability_thdots_Jyoon_passive:GetAOERadius()      return self:GetSpecialValueFor("radius") end

function ability_thdots_Jyoon_passive:GetIntrinsicModifierName()
    return "modifier_thdots_Jyoon_passive_applier"
end

--万宝槌测试
-- modifier_item_wanbaochui = class({})
-- LinkLuaModifier("modifier_item_wanbaochui","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_item_wanbaochui:IsHidden() return false end
-- function modifier_item_wanbaochui:IsPurgable() return false end
-- function modifier_item_wanbaochui:IsDebuff() return false end
-- function modifier_item_wanbaochui:RemoveOnDeath() return false end

-- function ability_thdots_Jyoon_passive:OnSpellStart()
--     if not IsServer() then return end
--     local caster = self:GetCaster()
--     if(caster:HasModifier("modifier_item_wanbaochui")) then
--         caster:RemoveModifierByName("modifier_item_wanbaochui")
--     else
--         caster:AddNewModifier(caster, self, "modifier_item_wanbaochui", {})
--     end
    
-- end

--Modifier
modifier_thdots_Jyoon_passive_applier = class({})
LinkLuaModifier("modifier_thdots_Jyoon_passive_applier","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_thdots_Jyoon_passive_applier:IsHidden() return true end
function modifier_thdots_Jyoon_passive_applier:IsPurgable() return false end
function modifier_thdots_Jyoon_passive_applier:IsDebuff() return false end
function modifier_thdots_Jyoon_passive_applier:RemoveOnDeath() return false end
function modifier_thdots_Jyoon_passive_applier:AllowIllusionDuplicate() return false end

function modifier_thdots_Jyoon_passive_applier:IsAura() return self:GetCaster():IsRealHero() end
function modifier_thdots_Jyoon_passive_applier:GetAuraEntityReject(target) return false end
function modifier_thdots_Jyoon_passive_applier:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_thdots_Jyoon_passive_applier:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function modifier_thdots_Jyoon_passive_applier:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function modifier_thdots_Jyoon_passive_applier:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_thdots_Jyoon_passive_applier:GetModifierAura() return "modifier_thdots_Jyoon_passive_dropGold" end

function modifier_thdots_Jyoon_passive_applier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
    return funcs
end

function modifier_thdots_Jyoon_passive_applier:GetModifierHealthBonus()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("special_bonus_unique_Jyoon_passive_maxhealth")
    local value = 0
    if(ability ~= nil) then
        value = ability:GetSpecialValueFor("value")
    end
    return value
end

--Modifier
modifier_thdots_Jyoon_passive_dropGold = class({})
LinkLuaModifier("modifier_thdots_Jyoon_passive_dropGold","scripts/vscripts/abilities/abilityJyoon.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_thdots_Jyoon_passive_dropGold:IsHidden() return false end
function modifier_thdots_Jyoon_passive_dropGold:IsPurgable() return false end
function modifier_thdots_Jyoon_passive_dropGold:IsDebuff() return true end
function modifier_thdots_Jyoon_passive_dropGold:RemoveOnDeath() return true end
function modifier_thdots_Jyoon_passive_dropGold:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_HERO_KILLED
    }
    return funcs
end

function modifier_thdots_Jyoon_passive_dropGold:OnHeroKilled(keys)
    if not IsServer() then return end

    local enemy = keys.target
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    if enemy == self:GetParent() then
        local playerID = enemy:GetPlayerOwnerID()
        --天赋
        -- if(FindTelentValue(caster, "special_bonus_unique_Jyoon_passive_take_gold")~= 0) then
        --     caster:SetGold(caster:GetGold() + (PlayerResource:GetUnreliableGold(playerID)), false)
        --     enemy:SetGold(enemy:GetGold()-(PlayerResource:GetUnreliableGold(playerID)), false)
        --     SendOverheadEventMessage(nil,OVERHEAD_ALERT_GOLD,caster,(PlayerResource:GetUnreliableGold(playerID)),nil)
        -- end
        local dropGold = PlayerResource:GetTotalEarnedGold(playerID) / ability:GetSpecialValueFor("networth_divided_by")
        local unreliableGold = PlayerResource:GetUnreliableGold(playerID)
        if dropGold > unreliableGold then dropGold = unreliableGold end
        enemy:ModifyGold(- dropGold, false, DOTA_ModifyGold_Death)

        local particle = "particles/units/heroes/hero_furion/furion_tnt_rain.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, enemy)
        ParticleManager:SetParticleControl(effect, 0, enemy:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect)

    end

    return 
end