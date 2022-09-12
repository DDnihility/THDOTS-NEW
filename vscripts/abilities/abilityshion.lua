----------------------------------------------------------------------------------------------
-- 对象

if AbilityShion == nil then AbilityShion = class({}) end

-----------------------
--------- Oil ---------
-----------------------

function AbilityShion:CreateOil(caster, oilTable)
    if caster:HasModifier("modifier_ability_thdots_shion_oilManager") then
        caster:FindModifierByName("modifier_ability_thdots_shion_oilManager"):CreateOil(oilTable)
    -- else
    --     local ability = caster:FindAbilityByName("ability_thdots_shion_01")
    --     if ability == nil or ability:GetLevel() == 0 then return end
    --     caster:AddNewModifier(caster, ability, "modifier_ability_thdots_shion_oilManager", {}):CreateOil(oilTable)
    end
end

function AbilityShion:IsOnOil(caster, target)
    if not caster:IsNull() and caster:HasModifier("modifier_ability_thdots_shion_oilManager") then
        return caster:FindModifierByName("modifier_ability_thdots_shion_oilManager"):IsOnOil(target)
    else
        return false
    end
end

function AbilityShion:IsImmuneHealthBouns(target)
    return target:HasModifier("modifier_thdots_yuyukoEx") or target:HasModifier("modifier_ability_thdots_lyrica04")
end

-----------------------
------- Danmaku -------
-----------------------

-- 弹幕生成
function AbilityShion:CreateDanmaku(caster, danmakuTable)
    if danmakuTable.direction == nil then return end
    if danmakuTable.position == nil then return end

    danmakuTable.ability = caster:FindAbilityByName("ability_thdots_shion_02")
    if danmakuTable.ability == nil or danmakuTable.ability:GetLevel() == 0 then return end

    danmakuTable.creationTime = GameRules:GetDOTATime(false, true)
    danmakuTable.startPosition = danmakuTable.position
    danmakuTable.interval = 0.04

    danmakuTable.danmakuMaxTime = danmakuTable.ability:GetSpecialValueFor("danmakuMaxTime")
    danmakuTable.danmakuStartTime = danmakuTable.ability:GetSpecialValueFor("danmakuStartTime")
    danmakuTable.danmakuSpeed = danmakuTable.ability:GetSpecialValueFor("danmakuSpeed")
    danmakuTable.danmakuDamageBonusPercent = danmakuTable.ability:GetSpecialValueFor("danmakuDamageBonusPercent")
    danmakuTable.danmakuMaxDamageBonusPercent = danmakuTable.ability:GetSpecialValueFor("danmakuMaxDamageBonusPercent")
    danmakuTable.danmakuMaxDamageBonusDuration = danmakuTable.ability:GetSpecialValueFor("danmakuMaxDamageBonusDuration")
    danmakuTable.lockDistance = danmakuTable.ability:GetSpecialValueFor("lockDistance")
    danmakuTable.unlockDistance = danmakuTable.ability:GetSpecialValueFor("unlockDistance")
    danmakuTable.danmakuHigh = danmakuTable.ability:GetSpecialValueFor("danmakuHigh")
    danmakuTable.danmakuMaxDistance = danmakuTable.ability:GetSpecialValueFor("danmakuMaxDistance")

    local effectIndex = ParticleManager:CreateParticle("models/shion/shion_fx/shion_cast2.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(effectIndex, 0, danmakuTable.position)

    caster:SetContextThink(DoUniqueString("shion_danmaku_particle"),
        function()
            if GameRules:IsGamePaused() then return danmakuTable.interval end

            if caster:IsNull() then
                ParticleManager:DestroyParticle(effectIndex, false)
                return
            end

            local existTime = GameRules:GetDOTATime(false, true) - danmakuTable.creationTime

            -- 超时销毁
            if existTime >= danmakuTable.danmakuMaxTime then
                ParticleManager:DestroyParticle(effectIndex, false)
                return
            end

            -- 伤害
            -- 大于一段时间时，弹幕碰撞检测
            if existTime >= danmakuTable.danmakuStartTime then
                -- 碰撞检测与效果施加
                local targets = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    danmakuTable.position,
                    nil,
                    36,
                    danmakuTable.ability:GetAbilityTargetTeam(),
                    danmakuTable.ability:GetAbilityTargetType(),
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                DeleteDummy(targets)
                for _, target in pairs(targets) do
                    -- 「厄貧負損」 天赋触发
                    local telent = caster:FindAbilityByName("special_bonus_unique_shion_08")
                    if telent ~= nil and telent:GetLevel() ~= 0 then
                        shion_telent_08_SpellStart(caster, danmakuTable.ability, target)
                    end

                    -- 每个减速修饰器的持续时间单独计算
                    local modifier = target:AddNewModifier(caster, danmakuTable.ability, "modifier_ability_thdots_shion_02_target", {
                        duration = danmakuTable.ability:GetSpecialValueFor("moveSpeedBonusTime")
                    })

                    -- 伤害施加
                    local damage = danmakuTable.ability:GetLevelSpecialValueFor("danmakuDamage", danmakuTable.ability:GetLevel() - 1)

                    -- 伤害衰减
                    if target:IsHero() then
                        if target:HasModifier("modifier_ability_thdots_shion_02_damageBouns") then
                            local modifier = target:FindModifierByName("modifier_ability_thdots_shion_02_damageBouns")
                            damage = damage * (100 - modifier:GetStackCount()) * 0.01
                            local newDamageBonusPercent = modifier:GetStackCount() + danmakuTable.danmakuDamageBonusPercent
                            if newDamageBonusPercent <= danmakuTable.danmakuMaxDamageBonusPercent then
                                modifier:SetStackCount(newDamageBonusPercent)
                            else
                                modifier:SetStackCount(danmakuTable.danmakuMaxDamageBonusPercent)
                            end
                            modifier:SetDuration(danmakuTable.danmakuMaxDamageBonusDuration, true)
                        else
                            target:AddNewModifier(caster, danmakuTable.ability, "modifier_ability_thdots_shion_02_damageBouns", {
                                duration = danmakuTable.danmakuMaxDamageBonusDuration
                            }):SetStackCount(danmakuTable.danmakuDamageBonusPercent)
                        end
                    end

                    local damageTable = {
                        victim = target,
                        damage = damage,
                        damage_type = danmakuTable.ability:GetAbilityDamageType(),
                        damage_flags = DOTA_DAMAGE_FLAG_NONE,
                        attacker = caster,
                        ability = danmakuTable.ability
                    }

                    UnitDamageTarget(damageTable)
                    end

                if #targets > 0 then 
                    -- 「贫乏神式污染」 天赋触发
                    local telent = caster:FindAbilityByName("special_bonus_unique_shion_07")
                    if telent ~= nil and telent:GetLevel() ~= 0 then
                        -- 冷却判定
                        local telentOn = false
                        local createOilCooldown = 1 -- 冷却时间
                        for _, target in pairs(targets) do
                            if not target:HasModifier("modifier_ability_thdots_shion_telent_07_danmakuCooldown") then
                                telentOn = true
                                break
                            end
                        end
                        if telentOn then
                            for _, target in pairs(targets) do
                                if target:HasModifier("modifier_ability_thdots_shion_telent_07_danmakuCooldown") then
                                    target:FindModifierByName("modifier_ability_thdots_shion_telent_07_danmakuCooldown"):SetDuration(createOilCooldown, true)
                                else
                                    target:AddNewModifier(caster, danmakuTable.ability, "modifier_ability_thdots_shion_telent_07_danmakuCooldown", {duration = createOilCooldown})
                                end
                            end
                            local oilTable = {
                                position = danmakuTable.position,
                                oilDuringDichotomy = true,
                            }
                            AbilityShion:CreateOil(caster, oilTable)
                        end
                    end

                    StartSoundEventFromPosition("Voice_Thdots_Shion.AbilityShion02_4", danmakuTable.position)
                    ParticleManager:DestroyParticle(effectIndex, false)
                    return
                end
            end

            -- 移动
            local existTime = GameRules:GetDOTATime(false, true) - danmakuTable.creationTime
            -- 大于一段时间时，弹幕索敌移动
            if existTime >= danmakuTable.danmakuStartTime then
                -- 若目标距离在 150 内，则锁定该目标；若被锁定的目标距离在 300 以外，则解锁目标
                if danmakuTable.lockedTarget ~= nil 
                    and not danmakuTable.lockedTarget:IsNull() and danmakuTable.lockedTarget:IsAlive() and not danmakuTable.lockedTarget:IsInvisible()
                    and not danmakuTable.lockedTarget:IsMagicImmune() and danmakuTable.lockedTarget:GetTeamNumber() ~= caster:GetTeamNumber()
                    and GetDistanceBetweenTwoVec2D(danmakuTable.position, danmakuTable.lockedTarget:GetOrigin()) <= danmakuTable.unlockDistance then
                    danmakuTable.direction = (danmakuTable.lockedTarget:GetOrigin() - danmakuTable.position):Normalized()
                else
                    local radius = danmakuTable.lockDistance
                    if caster:HasModifier("modifier_item_wanbaochui") then
                        radius = danmakuTable.danmakuMaxDistance + GetDistanceBetweenTwoVec2D(danmakuTable.startPosition, danmakuTable.position)
                    end
                    local targets = FindUnitsInRadius(
                        caster:GetTeamNumber(),
                        danmakuTable.position,
                        nil,
                        radius,
                        danmakuTable.ability:GetAbilityTargetTeam(),
                        danmakuTable.ability:GetAbilityTargetType(),
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false
                    )
                    local target = nil
                    for _, val in ipairs(targets) do
                        if not val:IsInvisible() 
                            and GetDistanceBetweenTwoVec2D(danmakuTable.startPosition, val:GetOrigin()) <= danmakuTable.danmakuMaxDistance then

                            target = val
                            break
                        end
                    end
                    if target ~= nil then
                        danmakuTable.direction = (target:GetOrigin() - danmakuTable.position):Normalized()
                        if GetDistanceBetweenTwoVec2D(target:GetOrigin(), danmakuTable.position) < danmakuTable.lockDistance then
                            danmakuTable.lockedTarget = target
                        else
                            danmakuTable.lockedTarget = nil
                        end
                    else
                        danmakuTable.lockedTarget = nil
                    end
                end
            end

            danmakuTable.position = danmakuTable.position + danmakuTable.direction * danmakuTable.danmakuSpeed * danmakuTable.interval

            -- 特效同步
            ParticleManager:SetParticleControl(effectIndex, 0,
                Vector(danmakuTable.position.x, danmakuTable.position.y, danmakuTable.startPosition.z + danmakuTable.danmakuHigh))

            -- 超出最大范围则销毁
            local danmakuDistance = GetDistanceBetweenTwoVec2D(danmakuTable.startPosition, danmakuTable.position)
            if danmakuDistance > danmakuTable.danmakuMaxDistance then
                ParticleManager:DestroyParticle(effectIndex, false)
                return
            end

            return danmakuTable.interval
        end,
        0
    )
end

-- 对象 End
----------------------------------------------------------------------------------------------
-- 天生技能

-- 初始化
ability_thdots_shion_ex = class({})

-- Modifiers
-- 技能施加于自身的 modifier
modifier_ability_thdots_shion_ex_caster = class({})
LinkLuaModifier("modifier_ability_thdots_shion_ex_caster", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
-- 施加于目标的 modifier
modifier_ability_thdots_shion_ex_target = class({})
LinkLuaModifier("modifier_ability_thdots_shion_ex_target", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 基础设定
function ability_thdots_shion_ex:IsStealable() return false end
function ability_thdots_shion_ex:GetAOERadius() return self:GetSpecialValueFor("auraRangeRadius") end

-- 天生技能触发
function ability_thdots_shion_ex:GetIntrinsicModifierName()
    return "modifier_ability_thdots_shion_ex_caster"
end

-- 自身 modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_ex_caster:IsHidden() return not self:GetCaster():IsRealHero() end
function modifier_ability_thdots_shion_ex_caster:IsDebuff() return false end
function modifier_ability_thdots_shion_ex_caster:IsPurgable() return false end
function modifier_ability_thdots_shion_ex_caster:RemoveOnDeath() return true end

-- modifier 光环判定
function modifier_ability_thdots_shion_ex_caster:IsAura() return self:GetCaster():IsRealHero() end
function modifier_ability_thdots_shion_ex_caster:GetAuraEntityReject(target) return false end
function modifier_ability_thdots_shion_ex_caster:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("auraRangeRadius") end
function modifier_ability_thdots_shion_ex_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_shion_ex_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_thdots_shion_ex_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_shion_ex_caster:GetModifierAura() return "modifier_ability_thdots_shion_ex_target" end

-- 天赋技能实现
function modifier_ability_thdots_shion_ex_caster:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    local particleName = "models/shion/shion_fx/shion_ambient.vpcf"
    self.effectIndex = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControlEnt(self.effectIndex, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
end

function modifier_ability_thdots_shion_ex_caster:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.effectIndex, false)
end

-- modifier 修改列表
function modifier_ability_thdots_shion_ex_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DAMAGE_CALCULATED,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_ability_thdots_shion_ex_caster:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetCaster() or not keys.target:IsCreep() and not keys.target:IsHero() then return end

    -- 「厄貧負損」 天赋触发
    if self.caster == nil then self.caster = self:GetCaster() end
    local telent = self.caster:FindAbilityByName("special_bonus_unique_shion_08")
    if telent ~= nil and telent:GetLevel() ~= 0 then
        shion_telent_08_SpellStart(self.caster, self.ability, keys.target)
    end

    -- 「贫乏神式污染」 天赋触发
    telent = self.caster:FindAbilityByName("special_bonus_unique_shion_07")
    if telent ~= nil and telent:GetLevel() ~= 0 then
        -- 冷却判定
        if not self.caster:HasModifier("modifier_ability_thdots_shion_telent_07_attackCooldown") then
            local oilTable = {
                position = keys.target:GetOrigin(),
                oilDuringDichotomy = true,
            }
            AbilityShion:CreateOil(self.caster, oilTable)
            -- 冷却重置
            self.caster:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_shion_telent_07_attackCooldown", {duration = 2})
        end
    end
end

function modifier_ability_thdots_shion_ex_caster:OnDamageCalculated(keys)
    if not IsServer() then return end
    if keys.target ~= self:GetParent() then return end

    local caster = self:GetCaster()

    -- 「必然凭依」 天赋触发
    local telent = self.caster:FindAbilityByName("special_bonus_unique_shion_05")
    if telent ~= nil and telent:GetLevel() ~= 0 then
        if keys.damage >= caster:GetHealth() * telent:GetSpecialValueFor("probability") * 0.01 and not caster:HasModifier("modifier_ability_thdots_shion_telent_05_cooldown") then
            local abilities = {
                caster:FindAbilityByName("ability_thdots_shion_01"),
                caster:FindAbilityByName("ability_thdots_shion_02"),
                caster:FindAbilityByName("ability_thdots_shion_03"),
                caster:FindAbilityByName("ability_thdots_shion_04"),
            }
            for _, val in pairs(abilities) do
                local newCooldown = val:GetCooldownTimeRemaining() - telent:GetSpecialValueFor("cooldownBonus") -- CD减少
                val:EndCooldown()
                if newCooldown > 0 then
                    val:StartCooldown(newCooldown)
                end
            end
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_shion_telent_05_cooldown", {duration = telent:GetSpecialValueFor("triggerInterval")})
        end
    end
end

-- 天生目标 modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_ex_target:IsHidden() return false end
function modifier_ability_thdots_shion_ex_target:IsDebuff() return true end
function modifier_ability_thdots_shion_ex_target:IsPurgable() return false end
function modifier_ability_thdots_shion_ex_target:IsPurgeException() return false end
function modifier_ability_thdots_shion_ex_target:RemoveOnDeath() return true end

-- modifier 修改列表
function modifier_ability_thdots_shion_ex_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }
    return funcs
end

function modifier_ability_thdots_shion_ex_target:GetHPRegenAmplify()
    if self.subBasicRatio == nil then self.subBasicRatio = self:GetAbility():GetSpecialValueFor("subBasicRatio") end
    if self.subExtraRatio == nil then self.subExtraRatio = self:GetAbility():GetSpecialValueFor("subExtraRatio") end
    local subRatio = - (self.subBasicRatio + self.subExtraRatio * GameRules:GetDOTATime(false, false) / 60)
    if subRatio >= -70 then
        return subRatio
    else
        return -70
    end
end

function modifier_ability_thdots_shion_ex_target:GetModifierHPRegenAmplify_Percentage()
    return self:GetHPRegenAmplify()
end

function modifier_ability_thdots_shion_ex_target:GetModifierHealAmplify_PercentageTarget()
    return self:GetHPRegenAmplify()
end

function modifier_ability_thdots_shion_ex_target:OnTooltip()
    return self:GetHPRegenAmplify()
end

-- 天生技能 End
----------------------------------------------------------------------------------------------
-- 一技能

-- 初始化
ability_thdots_shion_01 = class({})

-- Modifiers
modifier_ability_thdots_shion_01_caster = class({})
LinkLuaModifier("modifier_ability_thdots_shion_01_caster", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_01_caster_debuff = class({})
LinkLuaModifier("modifier_ability_thdots_shion_01_caster_debuff", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_oilManager = class({})
LinkLuaModifier("modifier_ability_thdots_shion_oilManager", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_casterOnOil = class({})
LinkLuaModifier("modifier_ability_thdots_shion_casterOnOil", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_targetOnOil = class({})
LinkLuaModifier("modifier_ability_thdots_shion_targetOnOil", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_targetOnOil_healthBonus = class({})
LinkLuaModifier("modifier_ability_thdots_shion_targetOnOil_healthBonus", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 基础设定
function ability_thdots_shion_01:IsStealable() return true end

-- 被动石油管理
function ability_thdots_shion_01:GetIntrinsicModifierName()
    return "modifier_ability_thdots_shion_oilManager"
end

-- 一技能触发
function ability_thdots_shion_01:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    if caster:HasModifier("modifier_ability_thdots_shion_01_caster") then caster:FindModifierByName("modifier_ability_thdots_shion_01_caster"):Destroy() end
    if caster:HasModifier("modifier_ability_thdots_shion_01_caster_debuff") then caster:FindModifierByName("modifier_ability_thdots_shion_01_caster_debuff"):Destroy() end
    caster:AddNewModifier(caster, self, "modifier_ability_thdots_shion_01_caster", { duration = self:GetSpecialValueFor("abilityDuring") })
    caster:AddNewModifier(caster, self, "modifier_ability_thdots_shion_01_caster_debuff", { duration = self:GetSpecialValueFor("abilityDuring") })
end

-- 对自身的modifier 
-- modifier 基础判定
function modifier_ability_thdots_shion_01_caster:IsHidden() return false end
function modifier_ability_thdots_shion_01_caster:IsDebuff() return false end
function modifier_ability_thdots_shion_01_caster:IsPurgable() return false end
function modifier_ability_thdots_shion_01_caster:RemoveOnDeath() return true end

function modifier_ability_thdots_shion_01_caster:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    self.oilRadiusDistance = self.ability:GetSpecialValueFor("oilRadiusDistance")
    self.healMoveDistance = self.ability:GetSpecialValueFor("healMoveDistance")

    self.healMoveDistanceCount = 0.0 -- 生命恢复的移动距离计数值
    self.preOilPosition = nil
    self.preCasterPosition = self.caster:GetOrigin()

    -- 音效相关
    self.soundIntervalTime = 0
    self.caster:EmitSound("Voice_Thdots_Shion.AbilityShion01_2")
    self.soundIndex = 1

    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_shion_01_caster:OnIntervalThink()
    if not IsServer() then return end
    local position = self.caster:GetOrigin()
    local moveDistance = GetDistanceBetweenTwoVec2D(self.preCasterPosition, position)

    -- 厄土生成
    if self.preOilPosition == nil or GetDistanceBetweenTwoVec2D(self.caster:GetOrigin(), self.preOilPosition) >= self.oilRadiusDistance then
        local oilTable = {
            position = position,
        }
        self.preOilPosition = position
        AbilityShion:CreateOil(self.caster, oilTable)
        -- 音效生成
        if self.soundIntervalTime > 1 then
            self.caster:EmitSound("Voice_Thdots_Shion.AbilityShion01_" .. self.soundIndex)
            if self.soundIndex == 1 then
                self.soundIndex = 2
            else 
                self.soundIndex = 1
            end
            self.soundIntervalTime = - FrameTime()
        end
    end

    -- 生命恢复
    self.healMoveDistanceCount = self.healMoveDistanceCount + moveDistance
    if self.healMoveDistanceCount >= self.healMoveDistance then
        self.caster:Heal(self.ability:GetLevelSpecialValueFor("heal", self.ability:GetLevel() - 1), self.caster)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.caster, self.ability:GetLevelSpecialValueFor("heal", self.ability:GetLevel() - 1), nil)
        self.healMoveDistanceCount = self.healMoveDistanceCount % self.healMoveDistance
    end

    self.preCasterPosition = position
    self.soundIntervalTime = self.soundIntervalTime + FrameTime()
end

-- 对自身的modifier(debuff部分)
-- modifier 基础判定
function modifier_ability_thdots_shion_01_caster_debuff:IsHidden() return false end
function modifier_ability_thdots_shion_01_caster_debuff:IsDebuff() return true end
function modifier_ability_thdots_shion_01_caster_debuff:IsPurgable() return true end
function modifier_ability_thdots_shion_01_caster_debuff:RemoveOnDeath() return true end

-- modifier 修改列表
function modifier_ability_thdots_shion_01_caster_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_ability_thdots_shion_01_caster_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetLevelSpecialValueFor("ownResistanceBonus", self:GetAbility():GetLevel() - 1)
end

function modifier_ability_thdots_shion_01_caster_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetLevelSpecialValueFor("ownResistanceBonus", self:GetAbility():GetLevel() - 1)
end

-- 厄土实体的modifier，用于维护该实体
-- modifier 基础判定
function modifier_ability_thdots_shion_oilManager:IsHidden() return true end
function modifier_ability_thdots_shion_oilManager:IsDebuff() return false end
function modifier_ability_thdots_shion_oilManager:IsPurgable() return false end
function modifier_ability_thdots_shion_oilManager:RemoveOnDeath() return false end

function modifier_ability_thdots_shion_oilManager:OnCreated()
    if not IsServer() then return end

    if not self:GetCaster():IsRealHero() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    -- 石油池
    self.oilQue = Queue:New()

    -- 石油矩阵
    self.oilMatrix = {}
    -- 石油矩阵缓存
    self.oilMatrixMemory = {}
    
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_shion_oilManager:OnIntervalThink()
    if not IsServer() then return end

    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end

    self:RemoveOilFromBackByDuration()

    -- 判定施法者
    if not self.caster:HasModifier("modifier_ability_thdots_shion_casterOnOil") and self:IsOnOil(self.caster) then
        self.caster:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_shion_casterOnOil", {})
    elseif self.caster:HasModifier("modifier_ability_thdots_shion_casterOnOil") and not self:IsOnOil(self.caster) then
        self.caster:RemoveModifierByName("modifier_ability_thdots_shion_casterOnOil")
    end

    -- 判定目标单位
    local targets = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        Vector(0, 0, 256),
        nil,
        9999,
        self.ability:GetAbilityTargetTeam(),
        self.ability:GetAbilityTargetType(),
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    DeleteDummy(targets)
    for _, target in pairs(targets) do
        if not target:HasModifier("modifier_ability_thdots_shion_targetOnOil") and self:IsOnOil(target) then
            target:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_shion_targetOnOil", {})
        end
    end
end

function modifier_ability_thdots_shion_oilManager:OnDestroy()
    if not IsServer() then return end

    if self.oilQue ~= nil then
        while not self.oilQue:IsEmpty() do

            if self.oilQue:Back().effectIndex ~= nil then
                ParticleManager:DestroyParticle(self.oilQue:Back().effectIndex, false)
            end

            self.oilQue:PopBack()
        end
    end
end

-- 模块函数及接口
-- 石油生成
function modifier_ability_thdots_shion_oilManager:CreateOil(oilTable)
    -- 生成判定
    if not self.caster:IsRealHero() then return nil end
    if not self.caster:HasAbility("ability_thdots_shion_01") or self.caster:FindAbilityByName("ability_thdots_shion_01"):GetLevel() == 0 then return nil end

    -- 石油数据检测
    if oilTable.position == nil then return end -- 必要数据
    if oilTable.oilRange == nil then oilTable.oilRange = self.ability:GetSpecialValueFor("oilRangeRadius") end -- 选要数据
    if oilTable.oilDuring == nil then oilTable.oilDuring = self.ability:GetSpecialValueFor("oilDuring") end -- 选要数据
    if oilTable.oilDuringDichotomy == true then -- 选要数据
        oilTable.oilDuring = oilTable.oilDuring / 2
        oilTable.oilDuringDichotomy = nil
    end

    -- 石油数据填充
    oilTable.creationTime = GameRules:GetDOTATime(false, true)

    -- 石油特效
    oilTable.effectIndex = ParticleManager:CreateParticle("models/shion/shion_fx/shion_cast5.vpcf", PATTACH_WORLDORIGIN, self.caster)
    ParticleManager:SetParticleControl(oilTable.effectIndex, 0, oilTable.position)
    ParticleManager:SetParticleControl(oilTable.effectIndex, 1, Vector(oilTable.oilRange, 0, 0))

    -- 石油光环地图填充
    self:AddOilToAuraMatrix(oilTable)

    self.oilQue:PushFront(oilTable)
end

function modifier_ability_thdots_shion_oilManager:RecreateFrontOil()
    self.oilQue:Front().creationTime = GameRules:GetDOTATime(false, true)
end

-- 队尾石油删除
function modifier_ability_thdots_shion_oilManager:RemoveOilFromBackByDuration()
    while not self.oilQue:IsEmpty() and GameRules:GetDOTATime(false, true) - self.oilQue:Back().creationTime >= self.oilQue:Back().oilDuring do
        -- 石油矩阵移除
        self:RemoveOilFromAuraMatrix(self.oilQue:Back())

        ParticleManager:DestroyParticle(self.oilQue:Back().effectIndex, false)

        self.oilQue:PopBack()
    end
end

-- 克隆
function modifier_ability_thdots_shion_oilManager:CloneMatrix(oilMatrix)
    -- local cloneMatrix = {}
    -- for index, matrix in ipairs(oilMatrix) do
    --     cloneMatrix[index] = { x = matrix.x, y = matrix.y }
    -- end
    -- return cloneMatrix
    return DepthCloneTable(oilMatrix)
end

-- 写入矩阵缓存
function modifier_ability_thdots_shion_oilManager:WriteMatrixMemory(oilRange, oilMatrix)
    self.oilMatrixMemory[oilRange] = self:CloneMatrix(oilMatrix)
end

-- 读取矩阵缓存
function modifier_ability_thdots_shion_oilManager:ReadMatrixMemory(oilRange)
    if self.oilMatrixMemory[oilRange] == nil then 
        return nil
    else
        return self:CloneMatrix(self.oilMatrixMemory[oilRange])
    end
end

-- 计算石油范围矩阵
function modifier_ability_thdots_shion_oilManager:CalculateOilRangeMatrix(oilRange)
    -- 试读矩阵缓存
    local oilMatrix = self:ReadMatrixMemory(ability, oilRange)
    if oilMatrix ~= nil then return oilMatrix end

    -- 计算矩阵
    oilMatrix = {} -- 存放x和y坐标哈希表的数组
    local oilRadius = self:Round(self:CalibrateDimension(oilRange))
    for x = - oilRadius, oilRadius do
        local yRange = self:Round(math.sqrt(oilRadius * oilRadius - x * x))
        for y = - yRange, yRange do
            table.insert(oilMatrix, { x = x, y = y })
        end
    end
    self:WriteMatrixMemory(oilRange, oilMatrix)
    return oilMatrix
end

-- 装载石油范围矩阵
function modifier_ability_thdots_shion_oilManager:LoadOilRangeMatrix(oilTable)
    local oilMatrix = self:CalculateOilRangeMatrix(oilTable.oilRange) -- 存放x和y坐标哈希表的数组
    local positionInt2D = { x = self:Round(self:CalibrateDimension(oilTable.position.x)), y = self:Round(self:CalibrateDimension(oilTable.position.y)) }
    for _, matrix in ipairs(oilMatrix) do
        matrix.x = positionInt2D.x + matrix.x
        matrix.y = positionInt2D.y + matrix.y
    end
    return oilMatrix
end

-- 在光环表中添加石油
function modifier_ability_thdots_shion_oilManager:AddOilToAuraMatrix(oilTable)
    local oilMatrix = self:LoadOilRangeMatrix(oilTable)
    if self.oilAuraMatrix == nil then self.oilAuraMatrix = {} end
    for _, matrix in ipairs(oilMatrix) do
        local x = matrix.x
        local y = matrix.y
        if self.oilAuraMatrix[x] == nil then self.oilAuraMatrix[x] = {} end
        if self.oilAuraMatrix[x][y] == nil then
            self.oilAuraMatrix[x][y] = 1
        else
            self.oilAuraMatrix[x][y] = self.oilAuraMatrix[x][y] + 1
        end
    end
end

-- 从光环表中删除石油
function modifier_ability_thdots_shion_oilManager:RemoveOilFromAuraMatrix(oilTable)
    local oilMatrix = self:LoadOilRangeMatrix(oilTable)
    if self.oilAuraMatrix == nil then self.oilAuraMatrix = {} end
    for _, matrix in ipairs(oilMatrix) do
        local x = matrix.x
        local y = matrix.y
        if self.oilAuraMatrix[x] ~= nil and self.oilAuraMatrix[x][y] ~= nil then
            self.oilAuraMatrix[x][y] = self.oilAuraMatrix[x][y] - 1
        end
    end
end

-- 判断该位置是否在石油上
function modifier_ability_thdots_shion_oilManager:IsOnOil(target)
    if self.caster ~= target and self.caster:GetTeamNumber() == target:GetTeamNumber() then return false end
    local position = target:GetOrigin()
    local x = self:Round(self:CalibrateDimension(position.x))
    local y = self:Round(self:CalibrateDimension(position.y))
    return self.oilAuraMatrix ~= nil and self.oilAuraMatrix[x] ~= nil and self.oilAuraMatrix[x][y] ~= nil and self.oilAuraMatrix[x][y] > 0
end

-- 清空光环表
function modifier_ability_thdots_shion_oilManager:ClearAuraMatrix()
    for x, yTable in pairs(self.oilAuraMatrix) do
        for y, _ in pairs(yTable) do
            self.oilAuraMatrix[x][y] = 0
        end
    end
end

-- 量纲换算
function modifier_ability_thdots_shion_oilManager:CalibrateDimension(number)
    return number / 10
end

-- 取整
function modifier_ability_thdots_shion_oilManager:Round(number)
    return math.floor(number + 0.5)
end

-- 紫苑位于厄土上的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_casterOnOil:IsHidden() return false end
function modifier_ability_thdots_shion_casterOnOil:IsDebuff() return false end
function modifier_ability_thdots_shion_casterOnOil:IsPurgable() return false end
function modifier_ability_thdots_shion_casterOnOil:IsPurgeException() return false end
function modifier_ability_thdots_shion_casterOnOil:RemoveOnDeath() return true end

-- 目标位于厄土上的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_targetOnOil:IsHidden() return false end
function modifier_ability_thdots_shion_targetOnOil:IsDebuff() return true end
function modifier_ability_thdots_shion_targetOnOil:IsPurgable() return true end
function modifier_ability_thdots_shion_targetOnOil:IsPurgeException() return true end
function modifier_ability_thdots_shion_targetOnOil:RemoveOnDeath() return true end

-- modifier 修改列表
function modifier_ability_thdots_shion_targetOnOil:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_ability_thdots_shion_targetOnOil:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetLevelSpecialValueFor("targetResistanceBonus", self:GetAbility():GetLevel() - 1)
end

function modifier_ability_thdots_shion_targetOnOil:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetLevelSpecialValueFor("targetResistanceBonus", self:GetAbility():GetLevel() - 1)
end

function modifier_ability_thdots_shion_targetOnOil:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.timer = 0 -- 计时器
    if GetMapName() == "dota" then
        self.intervalTime = 0.5
    else
        self.intervalTime = 0.1
    end
    self:StartIntervalThink(self.intervalTime)
end

function modifier_ability_thdots_shion_targetOnOil:OnIntervalThink()
    if not IsServer() then return end

    -- 空目标、魔免检测
    if self.parent:IsNull() or not self.parent:IsAlive() or self.parent:IsMagicImmune() or IsTHDImmune(self.parent) then
        self:Destroy()
        return 
    end

    -- 石油作用判断
    if not AbilityShion:IsOnOil(self.caster, self.parent) then
        self:Destroy()
        return
    end

    -- 生命削减
    if not self.parent:HasModifier("modifier_ability_thdots_shion_targetOnOil_healthBonus")
        and self.parent:GetName() ~= "npc_dota_roshan" and not AbilityShion:IsImmuneHealthBouns(self.parent) then
        self.parent:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_shion_targetOnOil_healthBonus", {})
    end

    if self.timer >= 1 then
        -- 伤害施加
        local damage = self.ability:GetLevelSpecialValueFor("oilDamage", self.ability:GetLevel() - 1)
        local telent = self.caster:FindAbilityByName("special_bonus_unique_shion_03")
        if telent ~= nil and telent:GetLevel() ~= 0 then
            damage = damage + telent:GetSpecialValueFor("damageBonus")
        end
        local damageTable = {
            victim = self.parent,
            attacker = self.caster,
            damage =  damage,
            damage_type = self.ability:GetAbilityDamageType(),
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self.ability
        }
        UnitDamageTarget(damageTable)

        self.timer = 0
    else
        self.timer = self.timer + self.intervalTime
    end
end

-- 敌方目标位于厄土上的modifier（生命值部分）
-- modifier 基础判定
function modifier_ability_thdots_shion_targetOnOil_healthBonus:IsHidden() return false end
function modifier_ability_thdots_shion_targetOnOil_healthBonus:IsDebuff() return true end
function modifier_ability_thdots_shion_targetOnOil_healthBonus:IsPurgable() return true end
function modifier_ability_thdots_shion_targetOnOil_healthBonus:RemoveOnDeath() return true end

function modifier_ability_thdots_shion_targetOnOil_healthBonus:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.oilLeftDuring = self.ability:GetSpecialValueFor("oilLeftDuring")
    self.healthBonusPct = self.ability:GetLevelSpecialValueFor("healthBonusPct", self.ability:GetLevel() - 1) * 0.01 -- 血量上限削减比例

    self.maxHealthDecrease = 0 -- 血量上限削减
    self.coverHealth = 0 -- 上限削减覆盖的血量
    self:SetStackCount(0)

    local particleName = "models/shion/shion_fx/shion_cast5_debuff.vpcf"
    self.effectIndex = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.effectIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)

    self.timer = 0 -- 计时器
    if GetMapName() == "dota" then
        self.intervalTime = 0.5
    else
        self.intervalTime = 0.1
    end
    self:StartIntervalThink(self.intervalTime)
end

function modifier_ability_thdots_shion_targetOnOil_healthBonus:OnIntervalThink()
    if not IsServer() then return end

    -- 空目标、魔免、特殊机体检测
    if self.parent:IsNull() or not self.parent:IsAlive() 
        or self.parent:IsMagicImmune() or IsTHDImmune(self.parent) 
        or AbilityShion:IsImmuneHealthBouns(self.parent)
        or self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
        
        self:Destroy()
        return
    end

    -- 石油目标检测
    if self.parent:HasModifier("modifier_ability_thdots_shion_targetOnOil") then
        if self:GetDuration() > 0 then self:SetDuration(-1, true) end
    else
        if self:GetDuration() < 0 then self:SetDuration(self.oilLeftDuring, true) end
    end

    if self.timer >= 1 then
        local curHealth = self.parent:GetHealth() -- 当前血量
        local actMaxHealth = self.parent:GetMaxHealth() -- 实际最大血量
        local curVirMaxHealth = actMaxHealth - self.maxHealthDecrease -- 当前虚拟最大血量

        local nextMaxHealthDecrease = self.maxHealthDecrease
        local nextVirMaxHealth = curVirMaxHealth

        -- 在石油上时计算后继削减的血量上限和覆盖的血量
        if self:GetDuration() < 0 then
            nextMaxHealthDecrease = self.maxHealthDecrease + curVirMaxHealth * self.healthBonusPct -- 后继削减的最大血量
            nextVirMaxHealth = actMaxHealth - nextMaxHealthDecrease -- 后继虚拟最大血量
            if curHealth > nextVirMaxHealth then
                self.coverHealth = self.coverHealth + math.min(curHealth, curVirMaxHealth) - nextVirMaxHealth
            end
            self.maxHealthDecrease = nextMaxHealthDecrease
        end

        -- 上限监控
        if curHealth > nextVirMaxHealth then
            -- 伤害计算
            local damage = curHealth - nextVirMaxHealth
            local killFlag = false
            if curHealth - damage < 1 then
                damage = curHealth - 1
                killFlag = true
            end

            -- 伤害标志
            local damageFlag = 
                DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR +
                DOTA_DAMAGE_FLAG_HPLOSS + 
                DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION

            -- 伤害施加
            local damageTable = {
                victim = self.parent,
                attacker = self.caster,
                damage = damage,
                damage_type = self.ability:GetAbilityDamageType(),
                damage_flags = damageFlag,
                ability = self.ability
            }
            UnitDamageTarget(damageTable)

            -- 击杀判断
            if killFlag == true then
                if self.caster == nil or self.caster:IsNull() then
                    self.parent:Kill(self.ability, nil)
                else
                    self.parent:Kill(self.ability, self.caster)
                end
            end
        end

        self.timer = 0
    else
        self.timer = self.timer + self.intervalTime
    end

    -- 削减指示
    self:SetStackCount(self.maxHealthDecrease)
end

function modifier_ability_thdots_shion_targetOnOil_healthBonus:OnDestroy()
    if not IsServer() then return end
    -- 特效销毁
    ParticleManager:DestroyParticle(self.effectIndex, false)
    -- 返还血量
    if not self.parent:IsNull() and self.parent:IsAlive() then
        -- self.parent:Heal(self.coverHealth, self:GetAbility())
        self.parent:SetHealth(self.parent:GetHealth() + self.coverHealth)
    end
end

-- modifier 修改列表
function modifier_ability_thdots_shion_targetOnOil_healthBonus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING,
    }
    return funcs
end

-- 达到上限减疗
function modifier_ability_thdots_shion_targetOnOil_healthBonus:GetDisableHealing()
    if self.maxHealthDecrease == nil then return 0 end

    if self:GetParent():GetHealth() >= self:GetParent():GetMaxHealth() - self.maxHealthDecrease then
        return 1
    else
        return 0
    end
end

-- 一技能 End
----------------------------------------------------------------------------------------------
-- 二技能

-- 初始化
ability_thdots_shion_02 = class({})

function ability_thdots_shion_02:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

-- Modifiers
modifier_ability_thdots_shion_02_caster = class({})
LinkLuaModifier("modifier_ability_thdots_shion_02_caster", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_02_caster_debuff = class({})
LinkLuaModifier("modifier_ability_thdots_shion_02_caster_debuff", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_02_caster_passive = class({})
LinkLuaModifier("modifier_ability_thdots_shion_02_caster_passive", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_danmakuManager = class({})
LinkLuaModifier("modifier_ability_thdots_shion_danmakuManager", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_02_target = class({})
LinkLuaModifier("modifier_ability_thdots_shion_02_target", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_02_damageBouns = class({})
LinkLuaModifier("modifier_ability_thdots_shion_02_damageBouns", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 基础设定
function ability_thdots_shion_02:IsStealable() return true end

-- 技能触发
function ability_thdots_shion_02:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    if caster:HasModifier("modifier_ability_thdots_shion_02_caster") then caster:FindModifierByName("modifier_ability_thdots_shion_02_caster"):Destroy() end
    if caster:HasModifier("modifier_ability_thdots_shion_02_caster_debuff") then caster:FindModifierByName("modifier_ability_thdots_shion_02_caster_debuff"):Destroy() end
    caster:AddNewModifier(caster, self, "modifier_ability_thdots_shion_02_caster", { duration = self:GetSpecialValueFor("duration") })
    caster:AddNewModifier(caster, self, "modifier_ability_thdots_shion_02_caster_debuff", { duration = self:GetSpecialValueFor("duration") })
end

-- 对自身的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_02_caster:IsHidden() return false end
function modifier_ability_thdots_shion_02_caster:IsDebuff() return false end
function modifier_ability_thdots_shion_02_caster:IsPurgable() return false end
function modifier_ability_thdots_shion_02_caster:RemoveOnDeath() return true end

-- modifier 状态列表
function modifier_ability_thdots_shion_02_caster:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
    }
end

-- modifier 修改列表
function modifier_ability_thdots_shion_02_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
    }
    return funcs
end

function modifier_ability_thdots_shion_02_caster:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_2 
end

function modifier_ability_thdots_shion_02_caster:GetOverrideAnimationRate()
    return 40 / 30
end

function modifier_ability_thdots_shion_02_caster:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.num = self.ability:GetLevelSpecialValueFor("danmakuNumber", self.ability:GetLevel() - 1)
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.startDirection = self.caster:GetForwardVector()
    self.angle = 360 / self.num
    self.qangle = QAngle(0, self.angle, 0) -- 弹幕旋转量

    self.thinkTotalTime = 0
    self.preShootTime = self.thinkTotalTime - 1
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_shion_02_caster:OnIntervalThink()
    if not IsServer() then return end
    -- 技能打断（眩晕、沉默）
    if self.caster:IsNull() or self.caster:IsStunned() or self.caster:IsSilenced() then
        self:Destroy()
        return
    end

    -- 保证弹幕间隔1秒，且弹幕发出的时间界限为[0, n - 1]（n为持续时间）
    if self.thinkTotalTime - self.preShootTime >= 1 and self.thinkTotalTime < self.duration - 0.5 then
        local position = self.caster:GetOrigin()
        local direction = RotatePosition(Vector(0, 0, 0), QAngle(0, RandomInt(- self.angle / 4, self.angle / 4), 0), self.startDirection) -- 弹幕初始运行方向
        StartSoundEventFromPosition("Voice_Thdots_Shion.AbilityShion02_3", position)
        for i = 1, self.num do
            local danmakuTable = {
                direction = direction,
                position = position,
            }
            AbilityShion:CreateDanmaku(self.caster, danmakuTable)

            direction = RotatePosition(Vector(0, 0, 0), self.qangle, direction)
        end
        -- 万宝槌效果：额外向随机方向发射一个弹幕
        if self.caster:HasModifier("modifier_item_wanbaochui") then
            local danmakuTable = {
                direction = RotatePosition(Vector(0, 0, 0), QAngle(0, RandomInt(0, 360), 0) , self.caster:GetForwardVector() * Vector(1, 1, 0)),
                position = position,
            }
            AbilityShion:CreateDanmaku(self.caster, danmakuTable)
        end
        -- 维护变量：上一次发射的时间
        self.preShootTime = self.preShootTime + 1
    end

    self.thinkTotalTime = self.thinkTotalTime + FrameTime()
end

-- 二技能被动部分
-- 技能触发
function ability_thdots_shion_02:GetIntrinsicModifierName()
    return "modifier_ability_thdots_shion_02_caster_passive"
end

-- modifier 基础判定
function modifier_ability_thdots_shion_02_caster_passive:IsHidden()
    if not self:GetCaster():IsRealHero() or self:GetCaster():HasModifier("modifier_item_wanbaochui") then 
        return false
    else
        return true
    end
end
function modifier_ability_thdots_shion_02_caster_passive:IsDebuff() return false end
function modifier_ability_thdots_shion_02_caster_passive:IsPurgable() return false end
function modifier_ability_thdots_shion_02_caster_passive:RemoveOnDeath() return true end

function modifier_ability_thdots_shion_02_caster_passive:OnCreated()
    if not IsServer() then return end
    if not self:GetCaster():IsRealHero() then return end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("passiveInterval"))
end

function modifier_ability_thdots_shion_02_caster_passive:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetCaster():IsRealHero() then return end
    -- 万宝槌效果：额外向随机方向发射一个弹幕
    local position = self.caster:GetOrigin()
    if self.caster:IsAlive() and self.caster:HasModifier("modifier_item_wanbaochui") then
        local danmakuTable = {
            direction = RotatePosition(Vector(0, 0, 0), QAngle(0, RandomInt(0, 360), 0) , self.caster:GetForwardVector() * Vector(1, 1, 0)),
            position = position,
        }
        AbilityShion:CreateDanmaku(self.caster, danmakuTable)
    end
end

-- 对目标的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_02_target:IsHidden() return false end
function modifier_ability_thdots_shion_02_target:IsDebuff() return true end
function modifier_ability_thdots_shion_02_target:IsPurgable() return true end
function modifier_ability_thdots_shion_02_target:RemoveOnDeath() return true end

-- 对自身的modifier(debuff部分)
-- modifier 基础判定
function modifier_ability_thdots_shion_02_caster_debuff:IsHidden() return false end
function modifier_ability_thdots_shion_02_caster_debuff:IsDebuff() return true end
function modifier_ability_thdots_shion_02_caster_debuff:IsPurgable() return true end
function modifier_ability_thdots_shion_02_caster_debuff:RemoveOnDeath() return true end

-- modifier 修改列表
function modifier_ability_thdots_shion_02_caster_debuff:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_ability_thdots_shion_02_caster_debuff:GetModifierAttackSpeedBonus_Constant() 
    return self:GetAbility():GetLevelSpecialValueFor("attackSpeedBonus", self:GetAbility():GetLevel() - 1) 
end

-- modifier 修改列表
function modifier_ability_thdots_shion_02_target:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_ability_thdots_shion_02_target:GetAttributes()
    return {
        MODIFIER_ATTRIBUTE_MULTIPLE
    }
end

function modifier_ability_thdots_shion_02_target:GetModifierMoveSpeedBonus_Percentage()
    if not IsServer() then return end
    return self:GetAbility():GetSpecialValueFor("moveSpeedBonus") 
end

-- 弹幕伤害衰减
-- modifier 基础判定
function modifier_ability_thdots_shion_02_damageBouns:IsHidden() return false end
function modifier_ability_thdots_shion_02_damageBouns:IsDebuff() return true end
function modifier_ability_thdots_shion_02_damageBouns:IsPurgable() return false end
function modifier_ability_thdots_shion_02_damageBouns:IsPurgeException() return false end
function modifier_ability_thdots_shion_02_damageBouns:RemoveOnDeath() return true end

-- 二技能 End
----------------------------------------------------------------------------------------------
-- 三技能

-- 初始化
ability_thdots_shion_03 = class({})

-- 基础设定
function ability_thdots_shion_03:IsStealable() return false end
function ability_thdots_shion_03:GetAOERadius() return self:GetLevelSpecialValueFor("auraRangeRadius", self:GetLevel() - 1) end

-- Modifiers
modifier_ability_thdots_shion_03_caster = class({})
LinkLuaModifier("modifier_ability_thdots_shion_03_caster", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_03_caster_debuff = class({})
LinkLuaModifier("modifier_ability_thdots_shion_03_caster_debuff", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_03_target = class({})
LinkLuaModifier("modifier_ability_thdots_shion_03_target", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 技能触发
function ability_thdots_shion_03:GetIntrinsicModifierName()
    return "modifier_ability_thdots_shion_03_caster"
end

-- 天赋护甲计算
function ability_thdots_shion_03:CalculateArmorBonusWhenTelent(Dichotomy)
    local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_shion_06")
    if telent ~= nil then
        local bonus = telent:GetSpecialValueFor("armorBonus")
        if Dichotomy then bonus = bonus / 2 end
        return bonus
    else
        return 0
    end
end

-- 对自身的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_03_caster:IsHidden() return not self:GetCaster():IsRealHero() end
function modifier_ability_thdots_shion_03_caster:IsDebuff() return false end
function modifier_ability_thdots_shion_03_caster:IsPurgable() return false end
function modifier_ability_thdots_shion_03_caster:RemoveOnDeath() return true end

-- modifier 光环判定
function modifier_ability_thdots_shion_03_caster:IsAura() return self:GetCaster():IsRealHero() end
function modifier_ability_thdots_shion_03_caster:GetAuraEntityReject(target) return target:HasModifier("dummy_unit") end
function modifier_ability_thdots_shion_03_caster:GetAuraRadius() return self:GetAbility():GetLevelSpecialValueFor("auraRangeRadius", self:GetAbility():GetLevel() - 1) end
function modifier_ability_thdots_shion_03_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_shion_03_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_thdots_shion_03_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_shion_03_caster:GetModifierAura() return "modifier_ability_thdots_shion_03_target" end

function modifier_ability_thdots_shion_03_caster:OnCreated()
    if not IsServer() then return end
    if not self:GetCaster():IsRealHero() then return end
    self.caster = self:GetCaster()
    self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ability_thdots_shion_03_caster_debuff", {})
    self:StartIntervalThink(1)
end

function modifier_ability_thdots_shion_03_caster:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetCaster():IsRealHero() then return end
    if not self.caster:IsNull() and not self.caster:HasModifier("modifier_ability_thdots_shion_03_caster_debuff") then
        self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ability_thdots_shion_03_caster_debuff", {})
    end
end

function modifier_ability_thdots_shion_03_caster:OnDestroy()
    if not IsServer() then return end
    if not self:GetCaster():IsRealHero() then return end
    if not self.caster:IsNull() and self.caster:HasModifier("modifier_ability_thdots_shion_03_caster_debuff") then
        self.caster:RemoveModifierByName("modifier_ability_thdots_shion_03_caster_debuff")
    end
end

-- 对自身的modifier(debuff部分)
-- modifier 基础判定
function modifier_ability_thdots_shion_03_caster_debuff:IsHidden() return false end
function modifier_ability_thdots_shion_03_caster_debuff:IsDebuff() return true end
function modifier_ability_thdots_shion_03_caster_debuff:IsPurgable() return true end
function modifier_ability_thdots_shion_03_caster_debuff:RemoveOnDeath() return true end

-- modifier 修改列表
function modifier_ability_thdots_shion_03_caster_debuff:DeclareFunctions()
    local funcs
    if self:GetParent():HasModifier("modifier_ability_thdots_shion_03_target") then 
        funcs = {} 
    else
        funcs = {
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BASE_PERCENTAGE,
        }
    end
    return funcs
end

function modifier_ability_thdots_shion_03_caster_debuff:GetModifierMagicalResistanceBonus()
    return self:GetCaster():GetBaseMagicalResistanceValue() * self:GetAbility():GetLevelSpecialValueFor("ownMagicResistanceBonus", self:GetAbility():GetLevel() - 1) * 0.01
end

function modifier_ability_thdots_shion_03_caster_debuff:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    return ability:GetLevelSpecialValueFor("ownArmorBonus", ability:GetLevel() - 1) + ability:CalculateArmorBonusWhenTelent(true)
end

-- function modifier_ability_thdots_shion_03_caster_debuff:GetModifierPhysicalArmorBase_Percentage()
--     return 100 + self:GetAbility():GetLevelSpecialValueFor("ownArmorBonus", self:GetAbility():GetLevel() - 1)
-- end

-- 对目标的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_03_target:IsHidden() return false end
function modifier_ability_thdots_shion_03_target:IsDebuff() return true end
function modifier_ability_thdots_shion_03_target:IsPurgable() return false end
function modifier_ability_thdots_shion_03_target:IsPurgeException() return false end
function modifier_ability_thdots_shion_03_target:RemoveOnDeath() return true end

function modifier_ability_thdots_shion_03_target:OnCreated()
    if not IsServer() then return end
    local particleName = "models/shion/shion_fx/shion_cast3_debuff.vpcf"
    self.effectIndex = ParticleManager:CreateParticle(particleName, PATTACH_RENDERORIGIN_FOLLOW, self:GetParent())
    -- ParticleManager:SetParticleControlEnt(self.effectIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
end

function modifier_ability_thdots_shion_03_target:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.effectIndex, false)
end

-- modifier 修改列表
function modifier_ability_thdots_shion_03_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BASE_PERCENTAGE,
    }
    return funcs
end

function modifier_ability_thdots_shion_03_target:GetModifierMagicalResistanceBonus()
    local ability = self:GetAbility()
    local bouns = ability:GetLevelSpecialValueFor("targetMagicResistanceBonus", ability:GetLevel() - 1)
    if self:GetParent():HasModifier("modifier_ability_thdots_shion_03_caster_debuff") then 
        bouns = bouns + ability:GetLevelSpecialValueFor("ownBonus", ability:GetLevel() - 1) 
    end
    return self:GetParent():GetBaseMagicalResistanceValue() * bouns * 0.01
end

function modifier_ability_thdots_shion_03_target:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    local bouns = ability:GetLevelSpecialValueFor("targetArmorBonus", ability:GetLevel() - 1) + ability:CalculateArmorBonusWhenTelent(false)
    if self:GetParent():HasModifier("modifier_ability_thdots_shion_03_caster_debuff") then 
        bouns = bouns + ability:GetLevelSpecialValueFor("ownBonus", ability:GetLevel() - 1) + ability:CalculateArmorBonusWhenTelent(true) 
    end
    return bouns
end

-- 三技能 End
----------------------------------------------------------------------------------------------
-- 四技能

-- 初始化
-- 技能一形态
ability_thdots_shion_04 = class({})
-- 技能二形态
ability_thdots_shion_05 = class({})

-- Modifiers
modifier_ability_thdots_shion_04_caster = class({})
LinkLuaModifier("modifier_ability_thdots_shion_04_caster", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_04_target = class({})
LinkLuaModifier("modifier_ability_thdots_shion_04_target", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_04_passive = class({})
LinkLuaModifier("modifier_ability_thdots_shion_04_passive", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 技能一形态
-- 基础设定
function ability_thdots_shion_04:IsStealable() return true end

-- 目标过滤
function ability_thdots_shion_04:CastFilterResultTarget(target)
    if target:IsHero() then
        if target == self:GetCaster() then
            return UF_FAIL_CONSIDERED_HERO
        else
            return UF_SUCCESS
        end
    elseif target:IsCreep() then
        return UF_FAIL_CREEP
    elseif target:IsBuilding() then
        return UF_FAIL_BUILDING
    elseif target:IsCourier() then
        return UF_FAIL_COURIER
    else
        return UF_FAIL_CUSTOM
    end
end

-- 同步技能等级
function ability_thdots_shion_04:OnUpgrade()
    if not IsServer() then return end
    local synchronousLevelAbility = {
        self:GetCaster():FindAbilityByName("ability_thdots_shion_05"),
    }
    for _, val in pairs(synchronousLevelAbility) do
        if val:GetLevel() ~= self:GetLevel() then
            val:SetLevel(self:GetLevel())
        end
    end
end

-- 「必然凭依」 施法范围加成
function ability_thdots_shion_04:GetCastRange()
    local telent = self:GetCaster():FindAbilityByName("special_bonus_unique_shion_05")
    if telent ~= nil and telent:GetLevel() ~= 0 then
        return self:GetSpecialValueFor("castRange") + telent:GetSpecialValueFor("castRangeBonus")
    else
        return self:GetSpecialValueFor("castRange")
    end
end

-- 技能触发
function ability_thdots_shion_04:OnSpellStart()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    -- 如果是幻象则杀死幻象
    if self.target:HasModifier("modifier_illusion") then
        if self.caster == nil or self.caster:IsNull() then
            self.target:Kill(self, nil)
        else
            self.target:Kill(self, self.caster)
        end
        return 
    end
    local hyouiDuring = self:GetLevelSpecialValueFor("hyouiDuring", self:GetLevel() - 1)
    if self.caster:GetTeam() ~= self.target:GetTeam() then
        hyouiDuring = hyouiDuring / 3
    end
    self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_shion_04_caster", { duration = hyouiDuring })
    self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_shion_04_target", { duration = hyouiDuring })
    self.caster:EmitSound("Voice_Thdots_Shion.AbilityShion04_1")
end

-- 对自身的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_04_caster:IsHidden() return false end
function modifier_ability_thdots_shion_04_caster:IsDebuff() return false end
function modifier_ability_thdots_shion_04_caster:IsPurgable() return false end
function modifier_ability_thdots_shion_04_caster:RemoveOnDeath() return true end
function modifier_ability_thdots_shion_04_caster:IsPurgeException() return false end

-- modifier 修改列表
function modifier_ability_thdots_shion_04_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
    }
    return funcs
end

function modifier_ability_thdots_shion_04_caster:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_2 
end

function modifier_ability_thdots_shion_04_caster:GetOverrideAnimationRate()
    return 40 / 30
end

-- modifier 状态列表
function modifier_ability_thdots_shion_04_caster:CheckState()
    local states = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
    }
    if self:GetCaster():HasModifier("modifier_item_wanbaochui") and not self:GetAbility().target:IsNull() and self:GetCaster():GetTeamNumber() == self:GetAbility().target:GetTeamNumber() then
        states[MODIFIER_STATE_FLYING] = true
    end
    return states
end

function modifier_ability_thdots_shion_04_caster:OnCreated()
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.caster = self.ability.caster
    self.target = self.ability.target
    self.abilityCooldown = self.ability:GetCooldownTime()
    self.caster:SwapAbilities("ability_thdots_shion_04", "ability_thdots_shion_05", false, true)
    self.caster:FindAbilityByName("ability_thdots_shion_05"):StartCooldown(1)
    -- DEBUFF列表
    self.shionDebuffNames = {
        "modifier_ability_thdots_shion_01_caster_debuff",
        "modifier_ability_thdots_shion_02_caster_debuff",
        "modifier_ability_thdots_shion_03_caster_debuff",
    }
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_shion_04_caster:OnIntervalThink()
    if not IsServer() then return end
    if self.target:IsNull() or not self.target:IsAlive() then
        self:Destroy()
        return
    end

    -- 跟随目标
    local casterPosition = self.caster:GetOrigin()
    local targetPosition = self.target:GetOrigin()
    local maxDistance = 75 -- 最大距离
    local distance = GetDistanceBetweenTwoVec2D(casterPosition, targetPosition)
    local direction = (targetPosition - casterPosition):Normalized()
    self.caster:SetForwardVector(direction * Vector(1, 1, 0))
    if distance > maxDistance then
        local moveDistance = distance - maxDistance
        if moveDistance > 1.0 then
            self.caster:SetOrigin(casterPosition + direction * moveDistance)
        end
    end

    -- 复制负面buff施加于目标
    for _, modifierName in pairs(self.shionDebuffNames) do
        if self.caster:HasModifier(modifierName) then
            local modifier = self.caster:FindModifierByName(modifierName)
            if not self.target:HasModifier(modifierName) then
                local modifierRemainingTime = modifier:GetRemainingTime()
                if self:GetRemainingTime() <= modifierRemainingTime or modifierRemainingTime < 0 then
                    self.target:AddNewModifier(self.caster, modifier:GetAbility(), modifierName, { duration = self:GetRemainingTime() })
                else
                    self.target:AddNewModifier(self.caster, modifier:GetAbility(), modifierName, { duration = modifierRemainingTime })
                end
            end
        end
    end

    -- 与目标隐身同步
    if self.target:IsInvisible() and not self.caster:HasModifier("modifier_invisible") then
        self.caster:AddNewModifier(self.caster, self.ability, "modifier_invisible", nil)
    elseif not self.target:IsInvisible() and self.caster:HasModifier("modifier_invisible") and self.caster:FindModifierByName("modifier_invisible"):GetAbility() == self.ability then
        self.caster:RemoveModifierByName("modifier_invisible")
    end
end

function modifier_ability_thdots_shion_04_caster:OnDestroy()
    if not IsServer() then return end
    -- 销毁凭依的modifier
    if not self.target:IsNull() then
        local targetModifiers = self.target:FindAllModifiers()
        for _, val in pairs(targetModifiers) do
            if val:GetAbility() == self:GetAbility() and val ~= self then
                val:Destroy()
            end
        end
    end

    -- 技能交换
    self.caster:SwapAbilities("ability_thdots_shion_04", "ability_thdots_shion_05", true, false)
    self.ability:StartCooldown(self.abilityCooldown)

    -- 销毁凭依期间产生的隐身效果
    if self.caster:HasModifier("modifier_invisible") and self.caster:FindModifierByName("modifier_invisible"):GetAbility() == self.ability then
        self.caster:RemoveModifierByName("modifier_invisible")
    end

    -- 安全着陆
    FindClearSpaceForUnit(self.caster, self.caster:GetOrigin(), true)

    -- 创建厄土
    local oilTable = {
        position = self.caster:GetOrigin(),
        oilRange = self.ability:GetSpecialValueFor("oilRangeRadius"),
    }
    AbilityShion:CreateOil(self.caster, oilTable)

    -- 音效
    self.caster:EmitSound("Voice_Thdots_Shion.AbilityShion05")
end

-- 对目标的modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_04_target:IsHidden() return false end
function modifier_ability_thdots_shion_04_target:IsDebuff() return true end
function modifier_ability_thdots_shion_04_target:IsPurgable() return false end
function modifier_ability_thdots_shion_04_target:RemoveOnDeath() return true end
function modifier_ability_thdots_shion_04_target:IsPurgeException() return false end

function modifier_ability_thdots_shion_04_target:OnCreated()
    if not IsServer() then return end
    local particleName = "models/shion/shion_fx/shion_cast4.vpcf"
    self.effectIndex = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetOwner())
end

function modifier_ability_thdots_shion_04_target:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.effectIndex, false)
end

-- 凭依时施加飞行效果的modifier（万宝槌效果）
function modifier_ability_thdots_shion_04_target:CheckState()
    local funcs = {}
    if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
            funcs[MODIFIER_STATE_FLYING] = true
        end
    else
        funcs[MODIFIER_STATE_INVISIBLE] = false
    end
    return funcs
end

-- modifier 修改列表
function modifier_ability_thdots_shion_04_target:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
    }
end

function modifier_ability_thdots_shion_04_target:GetModifierProvidesFOWVision()
    if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        return 0
    else
        return 1
    end
end

-- 技能二形态
-- 基础设定
function ability_thdots_shion_05:IsStealable() return true end

-- 同步技能等级
function ability_thdots_shion_05:OnUpgrade()
    if not IsServer() then return end
    local synchronousLevelAbility = {
        self:GetCaster():FindAbilityByName("ability_thdots_shion_04"),
    }
    for _, val in pairs(synchronousLevelAbility) do
        if val:GetLevel() ~= self:GetLevel() then
            val:SetLevel(self:GetLevel())
        end
    end
end

-- 技能触发
function ability_thdots_shion_05:OnSpellStart()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.target = self.caster:FindAbilityByName("ability_thdots_shion_04").target
    if self.caster:HasModifier("modifier_ability_thdots_shion_04_caster") then self.caster:FindModifierByName("modifier_ability_thdots_shion_04_caster"):Destroy() end
    if self.target:HasModifier("modifier_ability_thdots_shion_04_target") then self.target:FindModifierByName("modifier_ability_thdots_shion_04_target"):Destroy() end
end

-- 四技能被动部分
-- 技能触发
function ability_thdots_shion_04:GetIntrinsicModifierName()
    return "modifier_ability_thdots_shion_04_passive"
end

-- 四技能被动modifier
-- modifier 基础判定
function modifier_ability_thdots_shion_04_passive:IsHidden() return false end
function modifier_ability_thdots_shion_04_passive:IsDebuff() return false end
function modifier_ability_thdots_shion_04_passive:IsPurgable() return false end
function modifier_ability_thdots_shion_04_passive:RemoveOnDeath() return true end

function modifier_ability_thdots_shion_04_passive:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.invisibleTime = 0
    self.invisibleDelayTime = self:GetAbility():GetSpecialValueFor("invisibleDelayTime")
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_shion_04_passive:OnIntervalThink()
    if not IsServer() then return end
    if not self.caster:HasModifier("modifier_ability_thdots_shion_04_caster") then
        if self.caster:HasModifier("modifier_ability_thdots_shion_casterOnOil") then
            if self.invisibleTime < self.invisibleDelayTime then
                self.invisibleTime = self.invisibleTime + FrameTime()
            elseif not self.caster:HasModifier("modifier_invisible") then
                self.caster:AddNewModifier(self.caster, self.ability, "modifier_invisible", {})
            end
        else
            self.invisibleTime = 0
            if self.caster:HasModifier("modifier_invisible") then
                local invisibleModifier = self.caster:FindModifierByName("modifier_invisible")
                if invisibleModifier:GetAbility() == self.ability then
                    invisibleModifier:Destroy()
                end
            end
        end
    end
end

-- modifier 修改列表
function modifier_ability_thdots_shion_04_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_ability_thdots_shion_04_passive:OnAbilityFullyCast(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetCaster() then return end
    self.invisibleTime = 0
    if self:GetCaster():HasModifier("modifier_invisible") then
        local invisibleModifier = self:GetCaster():FindModifierByName("modifier_invisible")
        if invisibleModifier:GetAbility() == self:GetAbility() then
            invisibleModifier:Destroy()
        end
    end
end

function modifier_ability_thdots_shion_04_passive:OnAttack(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetCaster() then return end
    self.invisibleTime = 0
    if self:GetCaster():HasModifier("modifier_invisible") then
        local invisibleModifier = self:GetCaster():FindModifierByName("modifier_invisible")
        if invisibleModifier:GetAbility() == self:GetAbility() then
            invisibleModifier:Destroy()
        end
    end
end

function modifier_ability_thdots_shion_04_passive:OnTakeDamage(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetCaster() or not self:GetCaster():IsRealHero() then return end
    local caster = self:GetCaster()
    if caster:GetHealth() == 0 then
        local oilTable = {
            position = self.caster:GetOrigin(),
            oilRange = self.ability:GetSpecialValueFor("oilRangeRadius"),
        }
        AbilityShion:CreateOil(self.caster, oilTable)
    end
end

-- 四技能 End
----------------------------------------------------------------------------------------------
-- 天赋 「必然凭依」

-- Modifiers
modifier_ability_thdots_shion_telent_05_cooldown = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_05_cooldown", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 冷却
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_05_cooldown:IsHidden() return true end
function modifier_ability_thdots_shion_telent_05_cooldown:IsDebuff() return false end
function modifier_ability_thdots_shion_telent_05_cooldown:IsPurgable() return false end
function modifier_ability_thdots_shion_telent_05_cooldown:IsPurgeException() return false end
function modifier_ability_thdots_shion_telent_05_cooldown:RemoveOnDeath() return true end

-- 天赋 「必然凭依」 End
----------------------------------------------------------------------------------------------
-- 天赋 「贫乏神式污染」

-- Modifiers
modifier_ability_thdots_shion_telent_07_danmakuCooldown = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_07_danmakuCooldown", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_telent_07_attackCooldown = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_07_attackCooldown", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 冷却
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_07_danmakuCooldown:IsHidden() return true end
function modifier_ability_thdots_shion_telent_07_danmakuCooldown:IsDebuff() return false end
function modifier_ability_thdots_shion_telent_07_danmakuCooldown:IsPurgable() return false end
function modifier_ability_thdots_shion_telent_07_danmakuCooldown:IsPurgeException() return false end
function modifier_ability_thdots_shion_telent_07_danmakuCooldown:RemoveOnDeath() return true end

-- modifier 基础判定
function modifier_ability_thdots_shion_telent_07_attackCooldown:IsHidden() return true end
function modifier_ability_thdots_shion_telent_07_attackCooldown:IsDebuff() return false end
function modifier_ability_thdots_shion_telent_07_attackCooldown:IsPurgable() return false end
function modifier_ability_thdots_shion_telent_07_attackCooldown:IsPurgeException() return false end
function modifier_ability_thdots_shion_telent_07_attackCooldown:RemoveOnDeath() return true end

-- 天赋 「贫乏神式污染」 End
----------------------------------------------------------------------------------------------
-- 天赋 「厄貧負損」

-- 「厄貧負損」 天赋触发效果
function shion_telent_08_SpellStart(caster, ability, target)
    local telent = caster:FindAbilityByName("special_bonus_unique_shion_08")
    if telent == nil or telent:GetLevel() == 0 then return end

    -- 冷却判定
    if target:HasModifier("modifier_ability_thdots_shion_telent_08_cooldown") then return end

    -- 概率判定
    local probability = telent:GetSpecialValueFor("probability") -- 概率百分比
    if RandomInt(0, 100) > probability then return end

    -- 「厄貧負損」 状态modifier列表
    local SHION_TELENT05_MODIFIERS = {
        "modifier_ability_thdots_shion_telent_08_silenced",
        "modifier_ability_thdots_shion_telent_08_disarmed",
        "modifier_ability_thdots_shion_telent_08_muted",
        "modifier_ability_thdots_shion_telent_08_rooted",
    }

    -- 状态施加
    local stateDuration = telent:GetSpecialValueFor("duration") -- 状态持续时间
    local modifier = target:AddNewModifier(
        caster,
        ability,
        SHION_TELENT05_MODIFIERS[RandomInt(1, #SHION_TELENT05_MODIFIERS)],
        { duration = stateDuration }
    )
    target:AddNewModifier(caster, ability, "modifier_ability_thdots_shion_telent_08_cooldown", {duration = telent:GetSpecialValueFor("cooldown")})
end

-- Modifiers
modifier_ability_thdots_shion_telent_08_cooldown = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_08_cooldown", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_telent_08_silenced = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_08_silenced", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_telent_08_disarmed = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_08_disarmed", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_telent_08_muted = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_08_muted", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_shion_telent_08_rooted = class({})
LinkLuaModifier("modifier_ability_thdots_shion_telent_08_rooted", "scripts/vscripts/abilities/abilityshion.lua", LUA_MODIFIER_MOTION_NONE)

-- 冷却
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_08_cooldown:IsHidden() return true end
function modifier_ability_thdots_shion_telent_08_cooldown:IsDebuff() return true end
function modifier_ability_thdots_shion_telent_08_cooldown:IsPurgable() return false end
function modifier_ability_thdots_shion_telent_08_cooldown:IsPurgeException() return false end
function modifier_ability_thdots_shion_telent_08_cooldown:RemoveOnDeath() return true end

-- 沉默效果
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_08_silenced:IsHidden() return true end
function modifier_ability_thdots_shion_telent_08_silenced:IsDebuff() return true end
function modifier_ability_thdots_shion_telent_08_silenced:IsPurgable() return true end
function modifier_ability_thdots_shion_telent_08_silenced:RemoveOnDeath() return true end

-- modifier 状态列表
function modifier_ability_thdots_shion_telent_08_silenced:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true
    }
end

function modifier_ability_thdots_shion_telent_08_silenced:GetEffectName()
    return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced.vpcf"
end

function modifier_ability_thdots_shion_telent_08_silenced:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

-- 缴械效果
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_08_disarmed:IsHidden() return true end
function modifier_ability_thdots_shion_telent_08_disarmed:IsDebuff() return true end
function modifier_ability_thdots_shion_telent_08_disarmed:IsPurgable() return true end
function modifier_ability_thdots_shion_telent_08_disarmed:RemoveOnDeath() return true end

-- modifier 状态列表
function modifier_ability_thdots_shion_telent_08_disarmed:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_ability_thdots_shion_telent_08_disarmed:GetEffectName()
    return "particles/units/heroes/hero_sniper/concussive_grenade_disarm.vpcf"
end

function modifier_ability_thdots_shion_telent_08_disarmed:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

-- 锁闭效果
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_08_muted:IsHidden() return true end
function modifier_ability_thdots_shion_telent_08_muted:IsDebuff() return true end
function modifier_ability_thdots_shion_telent_08_muted:IsPurgable() return true end
function modifier_ability_thdots_shion_telent_08_muted:RemoveOnDeath() return true end

-- modifier 状态列表
function modifier_ability_thdots_shion_telent_08_muted:CheckState()
    return {
        [MODIFIER_STATE_MUTED] = true
    }
end

function modifier_ability_thdots_shion_telent_08_muted:GetEffectName()
    return "particles/generic_gameplay/generic_muted.vpcf"
end

function modifier_ability_thdots_shion_telent_08_muted:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

-- 禁锢效果
-- modifier 基础判定
function modifier_ability_thdots_shion_telent_08_rooted:IsHidden() return true end
function modifier_ability_thdots_shion_telent_08_rooted:IsDebuff() return true end
function modifier_ability_thdots_shion_telent_08_rooted:IsPurgable() return true end
function modifier_ability_thdots_shion_telent_08_rooted:RemoveOnDeath() return true end

-- modifier 状态列表
function modifier_ability_thdots_shion_telent_08_rooted:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_ability_thdots_shion_telent_08_rooted:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
end

function modifier_ability_thdots_shion_telent_08_rooted:GetEffectAttachType()
    return PATTACH_CUSTOMORIGIN_FOLLOW
end

-- 天赋 「厄貧負損」 End
----------------------------------------------------------------------------------------------