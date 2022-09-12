----------------------------------------------------------------------------------------------
-- Global

if AbilityReimu == nil then AbilityReimu = class({}) end

function AbilityReimu:ReimuDamageTarget(damageTable)
    if damageTable.victim:HasModifier("modifier_reimu03_flag") then
        damageTable.damage_type = DAMAGE_TYPE_PURE
    end
    UnitDamageTarget(damageTable)
end

-- Global End
----------------------------------------------------------------------------------------------
-- Reimu01

-- Ability Initialization
ability_dota2x_reimu01 = class({})

-- Ability Basic Parameter
function ability_dota2x_reimu01:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_reimu_3")
    if talent ~= nil and talent:GetLevel() ~= 0 then
        radius = radius + talent:GetSpecialValueFor("value")
    end
    return radius
end

-- Ability Script
function ability_dota2x_reimu01:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    local targetPosition = self:GetCursorPosition()
    local radius = self:GetAOERadius()
    local bounceTime = self:GetSpecialValueFor("bounce_time")
    local firstDamage = self:GetSpecialValueFor("first_damage")
    local stunDuration = self:GetSpecialValueFor("stun_duration")
    local damageFollowPct = self:GetSpecialValueFor("damage_follow_pct") * 0.01

    -- Ball parameters
    local ballParam = {
        gravity = 150,                      --重力加速度
        interval = 0.04,                    --时基
        startHeight = 680,                  --初始高度
        bounceHeight = 80,                  --弹跳平面高度
        bounceFactor = 0.8,                 --初次触底回弹速度系数
        bounceFactorFollow = 0.9,           --后续触底回弹速度系数
    }

    -- Ball object
    local ballObj = {
        position = targetPosition + Vector(0, 0, ballParam.startHeight),   -- 当前位置
        gravity = ballParam.gravity * ballParam.interval,                  -- 重力加速度
        time = 0,                                                          -- 碰撞次数
        velocity = 0,                                                      -- 垂直速度
    }
    
    -- Ball particle
    local fireIndex = ParticleManager:CreateParticle(
        "particles/heroes/reimu/reimu_01_effect_fire.vpcf",
        PATTACH_CUSTOMORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(fireIndex, 0, ballObj.position)
    local ballIndex = ParticleManager:CreateParticle(
        "particles/thd2/heroes/reimu/reimu_01_effect_b.vpcf",
        PATTACH_CUSTOMORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(ballIndex, 0, ballObj.position)
    ParticleManager:SetParticleControl(ballIndex, 1, Vector(radius * 0.035, 0, 0))
    ParticleManager:SetParticleControl(ballIndex, 3, ballObj.position)

    caster:SetContextThink(DoUniqueString("reimu_ball"),
        function()
            if GameRules:IsGamePaused() then return ballParam.interval end

            -- Fall
            ballObj.velocity = ballObj.velocity + ballObj.gravity
            ballObj.position.z = ballObj.position.z - ballObj.velocity
            ParticleManager:SetParticleControl(fireIndex, 0, ballObj.position)
            ParticleManager:SetParticleControl(ballIndex, 0, ballObj.position)
            ParticleManager:SetParticleControl(ballIndex, 3, ballObj.position)

            -- Collision detection
            if ballObj.position.z <= targetPosition.z + ballParam.bounceHeight then
                -- Collision object
                if time == 0 then
                    ballObj.velocity = - ballObj.velocity * ballParam.bounceFactor
                else
                    ballObj.velocity = - ballObj.velocity * ballParam.bounceFactorFollow
                end
                ballObj.position.z = targetPosition.z + ballParam.bounceHeight + 0.1

                -- Caculate effect
                local damage = firstDamage * (1 - damageFollowPct * ballObj.time)

                -- Find target
                local targets = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    ballObj.position,
                    nil,
                    radius,
                    self:GetAbilityTargetTeam(),
                    self:GetAbilityTargetType(),
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )

                -- Apply target effect
                for _, target in pairs(targets) do
                    -- Apply damage
                    local damageTable = {
                        ability = self,
                        victim = target,
                        attacker = caster,
                        damage = damage,
                        damage_type = self:GetAbilityDamageType(),
                    }
                    AbilityReimu:ReimuDamageTarget(damageTable)
                    -- Apply stun
                    UtilStun:UnitStunTarget(caster, target, stunDuration)
                end

                -- Collision sound
                StartSoundEventFromPosition("Visage_Familar.StoneForm.Cast", ballObj.position)

                -- Collision particle
                local effectIndex = ParticleManager:CreateParticle(
                    "particles/thd2/heroes/reimu/reimu_01_effect.vpcf",
                    PATTACH_CUSTOMORIGIN,
                    caster
                )
                ParticleManager:SetParticleControl(effectIndex, 0, ballObj.position)
                ParticleManager:SetParticleControl(effectIndex, 2, ballObj.position)
                ParticleManager:DestroyParticle(effectIndex, false)

                -- Collision time
                ballObj.time = ballObj.time + 1
                if ballObj.time >= bounceTime then
                    ParticleManager:DestroyParticle(fireIndex, true)
                    ParticleManager:DestroyParticle(ballIndex, true)
                    return
                end
            end

            return ballParam.interval
        end,
        ballParam.interval
    )
end

-- Reimu01 End
----------------------------------------------------------------------------------------------
-- Reimu02

-- Ability Initialization
ability_dota2x_reimu02 = class({})

-- Modifiers
modifier_thdots_reimu02_shot = class({})
LinkLuaModifier("modifier_thdots_reimu02_shot", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)

-- Ability Script
function ability_dota2x_reimu02:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    local casterPos = caster:GetOrigin()
    local num = self:GetLevelSpecialValueFor("number", self:GetLevel() - 1)

    -- Generate position
    local pos = Vector(
        casterPos.x + math.cos(RandomFloat(math.pi, -math.pi)) * 60,
        casterPos.y + math.sin(RandomFloat(math.pi, -math.pi)) * 60,
        casterPos.z
    )
    -- Generate position offset Angle
    local qangle = QAngle(0, 360 / num, 0)

    for i = 1, num do
        -- Generate unit
        local dummy = CreateUnitByName(
            "npc_dota2x_unit_reimu02_light",
            pos,
            false,
            caster,
            caster,
            caster:GetTeamNumber()
        )
        dummy:SetForwardVector((pos - casterPos):Normalized())
        dummy:FindAbilityByName("ability_reimu02_dummy_unit"):SetLevel(1)
        dummy:AddNewModifier(caster, self, "modifier_thdots_reimu02_shot", {
            duration = self:GetSpecialValueFor("duration"),
        })

        -- Offset position
        pos = RotatePosition(casterPos, qangle, pos)
    end
end

-- Modifier Basic Parameter
function modifier_thdots_reimu02_shot:IsHidden() return true end
function modifier_thdots_reimu02_shot:IsDebuff() return false end
function modifier_thdots_reimu02_shot:IsPurgable() return false end
function modifier_thdots_reimu02_shot:RemoveOnDeath() return true end

function modifier_thdots_reimu02_shot:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.damage = self.ability:GetLevelSpecialValueFor("damage", self.ability:GetLevel() - 1)
    self.speed = self.ability:GetSpecialValueFor("speed")
    self.followSpeed = self.ability:GetSpecialValueFor("follow_speed")
    self.damageRadius = self.ability:GetSpecialValueFor("damage_radius")
    self.followRadius = self.ability:GetSpecialValueFor("follow_radius")

    self:StartIntervalThink(FrameTime())
end

function modifier_thdots_reimu02_shot:OnIntervalThink()
    if not IsServer() then return end

    local pos = self.parent:GetOrigin()

    -- Damage target detection
    local targets = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        pos,
        nil,
        self.damageRadius,
        self.ability:GetAbilityTargetTeam(),
        self.ability:GetAbilityTargetType(),
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    -- Apply damage
    for _, target in pairs(targets) do
        local damageTable = {
            ability = self.ability,
            victim = target,
            attacker = self.caster,
            damage = self.damage,
            damage_type = self.ability:GetAbilityDamageType(),
        }
        AbilityReimu:ReimuDamageTarget(damageTable)

        target:EmitSound("Hero_Wisp.Spirits.Target")

        self:Destroy()
        return
    end

    -- Seek and mobile
    local direction = self.parent:GetForwardVector()
    local displace = direction * self.speed
    targets = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        pos,
        nil,
        self.followRadius,
        self.ability:GetAbilityTargetTeam(),
        self.ability:GetAbilityTargetType(),
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    if #targets > 0 then
        local target = targets[1]
        local targetDir = (target:GetOrigin() - self.parent:GetOrigin()):Normalized()
        direction.x = targetDir.x
        direction.y = targetDir.y
        displace = direction * self.followSpeed
    else
        displace = direction * self.speed
    end
    if pos.z <= 400 then direction.z = 1 end
    if pos.z >= 500 then direction.z = -1 end
    self.parent:SetForwardVector(direction)
    self.parent:SetOrigin(self.parent:GetOrigin() + displace)
end

function modifier_thdots_reimu02_shot:OnDestroy()
    if not IsServer() then return end

    self.parent:Destroy()
end

-- Reimu02 End
----------------------------------------------------------------------------------------------
-- Reimu03

-- Ability Initialization
ability_dota2x_reimu03 = class({})

-- Modifiers
modifier_ability_dota2x_reimu03_ally = class({})
LinkLuaModifier("modifier_ability_dota2x_reimu03_ally", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_dota2x_reimu03_enemy = class({})
LinkLuaModifier("modifier_ability_dota2x_reimu03_enemy", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)
modifier_reimu03_flag = class({})
LinkLuaModifier("modifier_reimu03_flag", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)

-- Ability Script
function ability_dota2x_reimu03:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if is_spell_blocked(target,caster) then return end

    local duration = self:GetLevelSpecialValueFor("duration", self:GetLevel() - 1)

    if caster:GetTeamNumber() == target:GetTeamNumber() then
        target:AddNewModifier(caster, self, "modifier_ability_dota2x_reimu03_ally", {duration = duration})
    else
        target:AddNewModifier(caster, self, "modifier_ability_dota2x_reimu03_enemy", {duration = duration})
    end
    target:AddNewModifier(caster, self, "modifier_reimu03_flag", {duration = duration})

    target:EmitSound("Hero_WitchDoctor.Voodoo_Restoration")
end

-- modifier 基础判定
function modifier_ability_dota2x_reimu03_ally:IsHidden() return false end
function modifier_ability_dota2x_reimu03_ally:IsDebuff() return false end
function modifier_ability_dota2x_reimu03_ally:IsPurgable() return false end
function modifier_ability_dota2x_reimu03_ally:RemoveOnDeath() return true end

function modifier_ability_dota2x_reimu03_ally:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    if self.caster:HasModifier("modifier_item_wanbaochui") then 
        self.parent:Purge(false,true,false,true,false)
    end
    
    self.effectIndex = ParticleManager:CreateParticle(
        "particles/thd2/heroes/reimu/reimu_03_effect.vpcf",
        PATTACH_CUSTOMORIGIN_FOLLOW,
        self:GetParent()
        )
    ParticleManager:SetParticleControlEnt(self.effectIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "follow_origin", Vector(0, 0, 0), true)
end

function modifier_ability_dota2x_reimu03_ally:OnDestroy()
    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.effectIndex, true)
end

-- Modifier declare functions
function modifier_ability_dota2x_reimu03_ally:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
    }
end

function modifier_ability_dota2x_reimu03_ally:GetAbsoluteNoDamagePhysical()
    return 1
end

-- modifier Basic Parameter
function modifier_ability_dota2x_reimu03_enemy:IsHidden() return false end
function modifier_ability_dota2x_reimu03_enemy:IsDebuff() return true end
function modifier_ability_dota2x_reimu03_enemy:IsPurgable() return true end
function modifier_ability_dota2x_reimu03_enemy:RemoveOnDeath() return true end

function modifier_ability_dota2x_reimu03_enemy:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.parent = self:GetParent()

    self.effectIndex = ParticleManager:CreateParticle(
        "particles/thd2/heroes/reimu/reimu_03_effect.vpcf",
        PATTACH_CUSTOMORIGIN_FOLLOW,
        self:GetParent()
        )
    ParticleManager:SetParticleControlEnt(self.effectIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "follow_origin", Vector(0, 0, 0), true)
end

function modifier_ability_dota2x_reimu03_enemy:OnDestroy()
    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.effectIndex, true)
end

-- Modifier declare functions
function modifier_ability_dota2x_reimu03_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_ability_dota2x_reimu03_enemy:GetModifierMoveSpeedBonus_Percentage()
    if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
        return self:GetAbility():GetSpecialValueFor("scepter_slowdown")
    else
        return 0
    end
end

-- Modifier States
function modifier_ability_dota2x_reimu03_enemy:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_ability_dota2x_reimu03_enemy:GetEffectName()
    return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced.vpcf"
end

function modifier_ability_dota2x_reimu03_enemy:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


-- Modifier Basic Parameter
function modifier_reimu03_flag:IsHidden() return true end
function modifier_reimu03_flag:IsDebuff() return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() end
function modifier_reimu03_flag:IsPurgable() return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() end
function modifier_reimu03_flag:RemoveOnDeath() return true end

-- Reimu03 End
----------------------------------------------------------------------------------------------
-- Reimu04

-- Ability Initialization
ability_dota2x_reimu04 = class({})

-- Modifiers
modifier_ability_dota2x_reimu04_immue = class({})
LinkLuaModifier("modifier_ability_dota2x_reimu04_immue", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_dota2x_reimu04_damage = class({})
LinkLuaModifier("modifier_ability_dota2x_reimu04_damage", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ability_dota2x_reimu04_root = class({})
LinkLuaModifier("modifier_ability_dota2x_reimu04_root", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)

-- Ability Script
function ability_dota2x_reimu04:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")

    local center = caster:GetOrigin()
    local creationTime = GameRules:GetGameTime()

    caster:EmitSound("Hero_Dazzle.Shallow_Grave")
    caster:EmitSound("Voice_Thdots_Reimu.AbilityReimu04")

    local effectIndex = ParticleManager:CreateParticle(
        "particles/thd2/heroes/reimu/reimu_04_effect.vpcf",
        PATTACH_CUSTOMORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(effectIndex, 0, center)

    caster:SetContextThink(DoUniqueString("reimu_circle"),
        function()
            if GameRules:IsGamePaused() then return 0.04 end

            if GameRules:GetGameTime() - creationTime >= duration then
                ParticleManager:DestroyParticle(effectIndex, false)
                return
            end

            local targets = FindUnitsInRadius(
                caster:GetTeamNumber(),
                center,
                nil,
                radius,
                self:GetAbilityTargetTeam(),
                self:GetAbilityTargetType(),
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )

            for _, target in pairs(targets) do
                local remain = duration - (GameRules:GetGameTime() - creationTime)

                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    target:AddNewModifier(caster, self, "modifier_ability_dota2x_reimu04_immue", {
                        duration = remain,
                        center_x = center.x,
                        center_y = center.y,
                        center_z = center.z,
                    })
                else
                    local talent = caster:FindAbilityByName("special_bonus_unique_reimu_1")
                    if talent ~= nil and talent:GetLevel() ~= 0 and not target:HasModifier("modifier_ability_dota2x_reimu04_root") then
                        target:AddNewModifier(caster, self, "modifier_ability_dota2x_reimu04_root", {
                            duration = remain,
                            center_x = center.x,
                            center_y = center.y,
                            center_z = center.z,
                        })
                    end

                    if not target:HasModifier("modifier_ability_dota2x_reimu04_damage") then
                        target:AddNewModifier(caster, self, "modifier_ability_dota2x_reimu04_damage", {
                            duration = remain,
                            center_x = center.x,
                            center_y = center.y,
                            center_z = center.z,
                        })
                    end
                end
            end

            return 0.04
        end,
        0
    )
end

-- modifier Basic Parameter
function modifier_ability_dota2x_reimu04_damage:IsHidden() return true end
function modifier_ability_dota2x_reimu04_damage:IsDebuff() return false end
function modifier_ability_dota2x_reimu04_damage:IsPurgable() return false end
function modifier_ability_dota2x_reimu04_damage:RemoveOnDeath() return true end

function modifier_ability_dota2x_reimu04_damage:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.center = Vector(params.center_x, params.center_y, params.center_z)
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.damageInterval = self.ability:GetSpecialValueFor("damage_interval")
    self.damageCount = self.ability:GetSpecialValueFor("damage_count")
    self.stunDuration = self.ability:GetSpecialValueFor("stun_duration")

    self.counter = 0
    self:StartIntervalThink(self.damageInterval)
end

function modifier_ability_dota2x_reimu04_damage:OnIntervalThink()
    if not IsServer() then return end

    if self.parent:IsNull() then
        self:Destroy()
        return
    end
    
    if self.counter < self.damageCount then
        local damageTable = {
            ability = self.ability,
            victim = self.parent,
            attacker = self.caster,
            damage = self.damage,
            damage_type = self.ability:GetAbilityDamageType(),
        }
        AbilityReimu:ReimuDamageTarget(damageTable)
        UtilStun:UnitStunTarget(self.caster, self.parent, self.stunDuration)

        self.counter = self.counter + 1
    end
end

-- Modifier Basic Parameter
function modifier_ability_dota2x_reimu04_immue:IsHidden() return false end
function modifier_ability_dota2x_reimu04_immue:IsDebuff() return false end
function modifier_ability_dota2x_reimu04_immue:IsPurgable() return false end
function modifier_ability_dota2x_reimu04_immue:RemoveOnDeath() return true end

function modifier_ability_dota2x_reimu04_immue:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.center = Vector(params.center_x, params.center_y, params.center_z)
    self.radius = self.ability:GetSpecialValueFor("radius")

    self:StartIntervalThink(FrameTime())
end

function modifier_ability_dota2x_reimu04_immue:OnIntervalThink()
    if not IsServer() then return end

    if self.parent:IsNull() or GetDistanceBetweenTwoVec2D(self.center, self.parent:GetOrigin()) > self.radius then
        self:Destroy()
        return
    end
end

-- Modifier states
function modifier_ability_dota2x_reimu04_immue:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_ability_dota2x_reimu04_immue:GetEffectName()
    return "particles/thd2/heroes/reimu/reimu_04_effect_buff.vpcf"
end

function modifier_ability_dota2x_reimu04_immue:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

-- Modifier Basic Parameter
function modifier_ability_dota2x_reimu04_root:IsHidden() return false end
function modifier_ability_dota2x_reimu04_root:IsDebuff() return true end
function modifier_ability_dota2x_reimu04_root:IsPurgable() return false end
function modifier_ability_dota2x_reimu04_root:IsPurgeException() return false end
function modifier_ability_dota2x_reimu04_root:RemoveOnDeath() return true end

function modifier_ability_dota2x_reimu04_root:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.center = Vector(params.center_x, params.center_y, params.center_z)
    self.radius = self.ability:GetSpecialValueFor("radius")

    self:StartIntervalThink(FrameTime())
end

function modifier_ability_dota2x_reimu04_root:OnIntervalThink()
    if not IsServer() then return end
    if self.parent:IsNull() or GetDistanceBetweenTwoVec2D(self.center, self.parent:GetOrigin()) > self.radius then
        self:Destroy()
        return
    end
end

-- Modifier states
function modifier_ability_dota2x_reimu04_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_ability_dota2x_reimu04_root:GetEffectName()
    return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

function modifier_ability_dota2x_reimu04_root:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

-- Reimu04 End
----------------------------------------------------------------------------------------------
-- ReimuEx

-- Ability Initialization
ability_dota2x_reimuEx = {}

-- Ability Basic Parameter
function ability_dota2x_reimuEx:GetIntrinsicModifierName()
    return "modifier_ability_dota2x_reimuEx_passive"
end

-- Modifiers
modifier_ability_dota2x_reimuEx_passive = {}
LinkLuaModifier("modifier_ability_dota2x_reimuEx_passive","scripts/vscripts/abilities/abilityReimu.lua",LUA_MODIFIER_MOTION_NONE)

-- Modifier Basic Parameter
function modifier_ability_dota2x_reimuEx_passive:IsHidden()        return false end
function modifier_ability_dota2x_reimuEx_passive:IsPurgable()      return false end
function modifier_ability_dota2x_reimuEx_passive:RemoveOnDeath()   return false end
function modifier_ability_dota2x_reimuEx_passive:IsDebuff()        return false end

-- Modifier Script
function modifier_ability_dota2x_reimuEx_passive:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    self.giveGoldAmount = self:GetAbility():GetSpecialValueFor("give_gold_amount")
    self.giveGoldInterval = self:GetAbility():GetSpecialValueFor("give_gold_interval")
    self.killCount = PlayerResource:GetKills(self:GetParent():GetPlayerID())
    self.assistsCount = PlayerResource:GetAssists(self:GetParent():GetPlayerID())
    self:StartIntervalThink(self.giveGoldInterval)
end

function modifier_ability_dota2x_reimuEx_passive:OnIntervalThink()
    if not IsServer() then return end
    if GameRules:GetDOTATime(false, false) == 0 then return end
    self.caster:ModifyGold(self.giveGoldAmount, false, DOTA_ModifyGold_AbilityGold)
end

-- Modifier Functions
function modifier_ability_dota2x_reimuEx_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_ability_dota2x_reimuEx_passive:OnDeath(keys)
    if not keys.unit:IsRealHero() then return end

    if self.caster == nil then self.caster = self:GetCaster() end

    if self.killCount ~= PlayerResource:GetKills(self.caster:GetPlayerID()) or self.assistsCount ~= PlayerResource:GetAssists(self.caster:GetPlayerID()) then
        local totalgoldget = self:GetAbility():GetSpecialValueFor("give_gold_kill")

        self.killCount = PlayerResource:GetKills(self.caster:GetPlayerID())
        self.assistsCount = PlayerResource:GetAssists(self.caster:GetPlayerID())

        self.caster:ModifyGold(totalgoldget, false, DOTA_ModifyGold_AbilityGold)

        local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
        ParticleManager:SetParticleControl(effectIndex, 0, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(effectIndex, 1, self.caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effectIndex)

        self.caster:EmitSound("DOTA_Item.Hand_Of_Midas")

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.caster, totalgoldget, nil)
    end
end

-- ReimuEx End
----------------------------------------------------------------------------------------------