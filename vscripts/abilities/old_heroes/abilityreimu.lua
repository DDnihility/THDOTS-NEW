-- Reimu01
-- init Ball parameters
REIMU01_GRAVITY = 150     			--重力加速度
REIMU01_INTERVAL = 0.03				--时基
REIMU01_START_HEIGHT = 680			--初始高度
REIMU01_BOUNCE_HEIGHT = 80			--弹跳平面高度
REIMU01_BOUNCE_FACTOR = 0.8			--初次触底回弹速度系数
REIMU01_BOUNCE_FACTOR_FOLLOW = 0.9 	--后续触底回弹速度系数

REIMU02_FOLLOW_RADIUS = 650
REIMU02_DAMAGE_RADIUS = 150
REIMU02_LIGHTSPEED = 20

if AbilityReimu == nil then AbilityReimu = class({}) end

function OnReimu01SpellStart(keys) AbilityReimu:OnReimu01Start(keys) end

function OnReimu02SpellStart(keys) AbilityReimu:OnReimu02Start(keys) end

function OnReimu02OnLightStart(keys) AbilityReimu:OnReimu02OnLight(keys) end

function OnReimu03SpellStart(keys) AbilityReimu:OnReimu03Start(keys) end

function OnReimu04SpellStart(keys) AbilityReimu:OnReimu04Start(keys) end

function OnReimu04SpellThink(keys) AbilityReimu:OnReimu04Think(keys) end

function AbilityReimu:OnReimu01Start(keys)
    local targetPoint = keys.target_points[1]
    local caster = EntIndexToHScript(keys.caster_entindex)
    local LightIndex = ParticleManager:CreateParticle(
                           "particles/thd2/heroes/reimu/reimu_01_effect_b.vpcf",
                           PATTACH_CUSTOMORIGIN, nil)
    local FireIndex = ParticleManager:CreateParticle(
                          "particles/heroes/reimu/reimu_01_effect_fire.vpcf",
                          PATTACH_CUSTOMORIGIN, nil)
    local radius = keys.Radius
    local gravity = REIMU01_GRAVITY * REIMU01_INTERVAL
    local bounceTimeLimit = keys.BounceTime
    local ballunit = CreateUnitByName("npc_dota2x_unit_reimu01_ball",
                                      caster:GetOrigin(), false, caster, caster,
                                      caster:GetTeam())
    ballunit.tReimu01Elements = {
        Ball = {paIndex = nil, t = 0, g = gravity, v = 0},
        Target = nil,
        OriginZ = 0
    }
    keys.ability:ApplyDataDrivenModifier(caster, ballunit, "modifier_thdots_reimu01_ball", {Duration = 2.4}) --增加modifier去掉阴阳玉的残留特效
    if FindTelentValue( caster, "special_bonus_unique_reimu_3") == 1 then
		radius =  radius + 150
	end
    ParticleManager:SetParticleControl(LightIndex, 1, Vector(radius*0.04,0,0))
    ParticleManager:SetParticleControlEnt(FireIndex, 0, ballunit, 0,
                                          follow_origin, ballunit:GetOrigin(),
                                          false)
    ballunit.LightIndex = LightIndex
    ballunit.forward = 0
    ballunit.tReimu01Elements.OriginZ = GetGroundPosition(targetPoint, nil).z
    if ballunit then
        local diffVec = targetPoint - caster:GetOrigin()
        local vec3 = Vector(targetPoint.x, targetPoint.y,
                            ballunit.tReimu01Elements.OriginZ +
                                REIMU01_START_HEIGHT)
        ballunit.tReimu01Elements.ballVector = vec3
        ballunit:SetOrigin(vec3)
    end
    ballunit.tReimu01Elements.Decrease = 0
    ballunit:SetContextThink("OnReimu01Release", function()
        if GameRules:IsGamePaused() then return 0.03 end
        if (ballunit == nil) then return end
        local headOrigin = ballunit.tReimu01Elements.ballVector

        local ug = ballunit.tReimu01Elements.Ball.g
        ballunit.tReimu01Elements.Ball.v = ballunit.tReimu01Elements.Ball.v + ug
        local uv = ballunit.tReimu01Elements.Ball.v
        local uz = headOrigin.z - uv
        local vec = Vector(headOrigin.x, headOrigin.y, uz)
        local locability = keys.ability
        local abilitylevel = locability:GetLevel()
        ParticleManager:SetParticleControl(ballunit.LightIndex, 0, vec)
        ParticleManager:SetParticleControl(ballunit.LightIndex, 3, vec)
        ballunit.tReimu01Elements.ballVector = vec
        -- print(uz,"and",ballunit.tReimu01Elements.OriginZ + REIMU01_BOUNCE_HEIGHT)
        if uz <= ballunit.tReimu01Elements.OriginZ + REIMU01_BOUNCE_HEIGHT then
            local effectIndex = ParticleManager:CreateParticle(
                                    "particles/thd2/heroes/reimu/reimu_01_effect.vpcf",
                                    PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControl(effectIndex, 0, vec)
            ParticleManager:SetParticleControl(effectIndex, 2, vec)
            ParticleManager:DestroyParticleSystem(effectIndex, false)

            local damageFactor = keys.DamageFollowPercentage / 100
            local stunDurationReal = keys.StunDuration
            local speedFactor = REIMU01_BOUNCE_FACTOR
            if ballunit.tReimu01Elements.Ball.t > 0 then
                -- damageFactor = keys.DamageFollowPercentage / 100 -- 0.33
                stunDurationReal = keys.StunDurationFollow
                speedFactor = REIMU01_BOUNCE_FACTOR_FOLLOW
            end

            ballunit.tReimu01Elements.Ball.v = ballunit.tReimu01Elements.Ball.v * -speedFactor
            vec = Vector(headOrigin.x, headOrigin.y, ballunit.tReimu01Elements.OriginZ + REIMU01_BOUNCE_HEIGHT + 0.1)
            ballunit.tReimu01Elements.ballVector = vec
            ballunit.tReimu01Elements.Ball.t = ballunit.tReimu01Elements.Ball.t + 1

            local DamageTargets =
                FindUnitsInRadius(caster:GetTeam(), -- caster team
                ballunit:GetOrigin(), -- find position
                nil, -- find entity
                radius, -- find radius
                DOTA_UNIT_TARGET_TEAM_ENEMY,
	            keys.ability:GetAbilityTargetType(), 0,
	            FIND_CLOSEST, false)
            local decrease = ballunit.tReimu01Elements.Decrease
            local damageFinal = keys.FirstDamage * (1-decrease)
            -- local damageFinal = keys.FirstDamage * damageFactor
            for _, v in pairs(DamageTargets) do
                local DamageTable = {
                    ability = keys.ability,
                    victim = v,
                    attacker = caster,
                    damage = damageFinal,
                    damage_type = keys.ability:GetAbilityDamageType(),
                }
            	if v:HasModifier("modifier_reimu03_flag") then
            		DamageTable.damage_type = DAMAGE_TYPE_PURE
            	end
                UtilStun:UnitStunTarget(caster, v, stunDurationReal)
                UnitDamageTarget(DamageTable)
            end
            ballunit.tReimu01Elements.Decrease = ballunit.tReimu01Elements.Decrease + damageFactor
            ballunit:EmitSound("Visage_Familar.StoneForm.Cast")
        end

        if ballunit.tReimu01Elements.Ball.t >= bounceTimeLimit then
            ParticleManager:DestroyParticleSystem(ballunit.LightIndex, true)
            ballunit.tReimu01Elements.Decrease = 0
            ballunit:RemoveSelf()
            ballunit.tReimu01Elements.Ball.unit = nil
            return nil
        end
        return REIMU01_INTERVAL
    end, 0.1)
end


function OnReimu01Destory( keys )
    --print(keys.target.LightIndex)
    if keys.target.LightIndex == nil then return end
    ParticleManager:DestroyParticleSystem(keys.target.LightIndex,true)
    keys.target:RemoveSelf()
end
-- Reimu02
function AbilityReimu:initLightData(level)
    self.tReimu02Light = self.tReimu02Light or {}
    zincrease = REIMU02_LIGHTSPEED
    for i = 0, level + 1 do
        self.tReimu02Light[i] = {Ball = {unit = nil, t = 0}, Target = nil}
    end
end

function AbilityReimu:OnReimu02Start(keys)
    local caster = EntIndexToHScript(keys.caster_entindex)
    local vec0 = caster:GetOrigin()
    local ability = keys.ability
    local abilitylevel = ability:GetLevel()

    AbilityReimu:initLightData(abilitylevel)

    for i = 0, abilitylevel + 1 do
        local veccre = Vector(vec0.x + math.cos(0.628 * i) * 60,
                              vec0.y + math.sin(0.628 * i) * 60, 500)
        self.tReimu02Light[i].Ball.unit =
            CreateUnitByName("npc_dota2x_unit_reimu02_light", vec0, false,
                             caster, caster, caster:GetTeam())
        local removeUnit = self.tReimu02Light[i].Ball.unit
        removeUnit:SetContextThink("ability_reimu02_unit_remove", function()
            if GameRules:IsGamePaused() then return 0.03 end
            removeUnit:RemoveSelf()
            return nil
        end, 5)

        if self.tReimu02Light[i].Ball.unit then
            self.tReimu02Light[i].Ball.unit:SetOrigin(veccre)
            self.tReimu02Light[i].Ball.unit:SetForwardVector(
                Vector(math.cos(RandomFloat(math.pi, -math.pi)),
                       math.sin(RandomFloat(math.pi, -math.pi)), 0))
        else
            self.tReimu02Light[i].Ball.unit = nil
        end
    end
end

function AbilityReimu:OnReimu02OnLight(keys)
    local i = 0
    local caster = EntIndexToHScript(keys.caster_entindex)
    local level = keys.ability:GetLevel()
    self.tReimu02Light[i].Ball.t = self.tReimu02Light[i].Ball.t + 0.03

    if (self.tReimu02Light[i].Ball.t >= 1.47) then
        for i = 0, level + 1 do
            if (self.tReimu02Light[i].Ball.unit ~= nil) then
                self.tReimu02Light[i].Ball.unit:RemoveSelf()
                self.tReimu02Light[i].Ball.unit = nil
            end
        end
        return
    end
    --
    for i = 0, level + 1 do
        if (self.tReimu02Light[i].Ball.unit ~= nil) then

            local vec = self.tReimu02Light[i].Ball.unit:GetOrigin()
            local DamageTargets =
                FindUnitsInRadius(caster:GetTeam(), -- caster team
                vec, -- find position
                nil, -- find entity
                REIMU02_DAMAGE_RADIUS, -- find radius
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  keys.ability:GetAbilityTargetType(), 0, 0,
                                  false)
            for k, v in pairs(DamageTargets) do
                if (v ~= nil) then
                    local DamageTable = {
                        ability = keys.ability,
                        victim = v,
                        attacker = caster,
                        damage = keys.ability:GetAbilityDamage(),
                        damage_type = keys.ability:GetAbilityDamageType(),
                    }
                	if v:HasModifier("modifier_reimu03_flag") then
            			DamageTable.damage_type = DAMAGE_TYPE_PURE
            		end
                    v:EmitSound("Hero_Wisp.Spirits.Target")
                    UnitDamageTarget(DamageTable)
                    self.tReimu02Light[i].Ball.unit:RemoveSelf()
                    self.tReimu02Light[i].Ball.unit = nil
                    break
                end
            end

            if (self.tReimu02Light[i].Ball.unit ~= nil) then

                local FollowTargets =
                    FindUnitsInRadius(caster:GetTeam(), -- caster team
                    vec, -- find position
                    nil, -- find entity
                    REIMU02_FOLLOW_RADIUS, -- find radius
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                      keys.ability:GetAbilityTargetType(), 0, 0,
                                      false)

                local FollowTarget = nil

                for k, v in pairs(FollowTargets) do
                    if (v == nil) then
                        self.tReimu02Light[i].Ball.unit:RemoveSelf()
                        self.tReimu02Light[i].Ball.unit = nil
                        break
                    else
                        FollowTarget = v
                        break
                    end
                end

                if (FollowTarget ~= nil) then

                    local vecenemy = FollowTarget:GetOrigin()

                    local radian = GetRadBetweenTwoVec2D(vec, vecenemy)

                    vec.x = math.cos(radian) * REIMU02_LIGHTSPEED + vec.x
                    vec.y = math.sin(radian) * REIMU02_LIGHTSPEED + vec.y

                end
            end
            if vec.z >= 500 then
                local ranInt = -10
                self.zincrease = ranInt
            end

            if vec.z <= 400 then
                local ranInt = 10
                self.zincrease = ranInt
            end

            vec = Vector(vec.x + self.zincrease, vec.y + self.zincrease,
                         vec.z + self.zincrease)
            if (self.tReimu02Light[i].Ball.unit ~= nil) then
                self.tReimu02Light[i].Ball.unit:SetOrigin(
                    vec + self.tReimu02Light[i].Ball.unit:GetForwardVector() * 9)
            end
        end
    end
end
-- Reimu02End

function AbilityReimu:OnReimu03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
    if is_spell_blocked(keys.target,caster) then return end
    keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_ability_dota2x_reimu03_effect", {Duration = keys.Duration})
	if(caster:GetTeam() == keys.target:GetTeam())then
		 keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_ability_dota2x_reimu03_armor", {Duration = keys.Duration})
         keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_ability_dota2x_reimu03_armor_lua", {Duration = keys.Duration})
		 if caster:HasModifier("modifier_item_wanbaochui") then 
			keys.target:Purge(false,true,false,true,false)
		 end
		

	else
		if caster:HasModifier("modifier_item_wanbaochui") then
			keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_ability_dota2x_reimu03_slow", {Duration = keys.Duration})
		end
	    UtilSilence:UnitSilenceTarget(caster,keys.target,keys.Duration)
	    keys.ability:ApplyDataDrivenModifier(caster, keys.target,"modifier_reimu03_flag",{Duration = keys.Duration})
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('Release Effect'),
    	function ()
    		if GameRules:IsGamePaused() then return 0.03 end
			keys.target:RemoveModifierByName("modifier_ability_dota2x_reimu03_effect")
	    	return nil
    	end,keys.Duration)
	end
end

modifier_ability_dota2x_reimu03_armor_lua = {}
LinkLuaModifier("modifier_ability_dota2x_reimu03_armor_lua","scripts/vscripts/abilities/abilityReimu.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_dota2x_reimu03_armor_lua:IsHidden()         return false end
function modifier_ability_dota2x_reimu03_armor_lua:IsPurgable()       return false end
function modifier_ability_dota2x_reimu03_armor_lua:RemoveOnDeath()    return false end
function modifier_ability_dota2x_reimu03_armor_lua:IsDebuff()     return false end
function modifier_ability_dota2x_reimu03_armor_lua:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
end

function modifier_ability_dota2x_reimu03_armor_lua:GetModifierTotal_ConstantBlock(kv)
    if not IsServer() then return end
    if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
    print_r(kv)
    if kv.damage_type == 1 then
        return kv.damage
    end
end

function AbilityReimu:OnReimu04Start(keys)
    local caster = EntIndexToHScript(keys.caster_entindex)
    Caster = keys.caster
    local unit = CreateUnitByName("npc_reimu_04_dummy_unit", caster:GetOrigin(),
                                  false, caster, caster, caster:GetTeam())
    local nEffectIndex = ParticleManager:CreateParticle(
                             "particles/thd2/heroes/reimu/reimu_04_effect.vpcf",
                             PATTACH_CUSTOMORIGIN, unit)
    local vecCorlor = Vector(255, 255, 0)
    ParticleManager:SetParticleControl(nEffectIndex, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(nEffectIndex, 1, caster:GetOrigin())
    ParticleManager:SetParticleControl(nEffectIndex, 2, vecCorlor)
    ParticleManager:SetParticleControl(nEffectIndex, 3,
                                       caster:GetForwardVector())
    ParticleManager:SetParticleControl(nEffectIndex, 4, caster:GetOrigin())
    ParticleManager:SetParticleControl(nEffectIndex, 5, caster:GetOrigin())

    unit:SetOwner(caster)
    -- unit:AddAbility("ability_dota2x_reimu04_unit")
    local ability_dummy_unit = unit:FindAbilityByName("ability_reimu04_dummy_unit")
    ability_dummy_unit:SetLevel(1)
    local unitAbility = unit:FindAbilityByName("ability_dota2x_reimu04_unit")
    unitAbility:SetLevel(keys.ability:GetLevel())
    unit:CastAbilityImmediately(unitAbility, 0)

    keys.ability:SetContextNum("Reimu04_Effect_Unit", unit:GetEntityIndex(), 0)
    unit:SetContextThink(DoUniqueString('ability_reimu04_damage'), function()
        if GameRules:IsGamePaused() then return 0.03 end
        unit:RemoveSelf()
        return nil
    end, keys.Ability_Duration + 0.1)
end

function AbilityReimu:OnReimu04Think(keys)
    local caster = EntIndexToHScript(keys.caster_entindex)
    local Targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for k, v in pairs(Targets) do
        if (v:GetTeam() == caster:GetTeam()) then
            if not v:HasModifier("modifier_dota2x_reimu04_magic_immune") then
                v:AddNewModifier(caster, keys.ability, "modifier_dota2x_reimu04_magic_immune", {duration = keys.Ability_Duration})
            end
        else
            if FindTelentValue(caster:GetOwner(), "special_bonus_unique_reimu_1") == 1 and not v:HasModifier("modifier_thdots_reimu04_root") then
                v:AddNewModifier(caster, keys.ability, "modifier_thdots_reimu04_root", {duration = keys.Ability_Duration * (1 - v:GetStatusResistance())})
            end
            if v:GetContext("Reimu04_Effect_Damage_Count") == nil then
                v:SetContextNum("Reimu04_Effect_Damage_Count", 0, 0)
            end
            if v:GetContext("Reimu04_Effect_Damage_Count") == 0 then
                Timer.Wait(DoUniqueString('ability_reimu04_damage')) (keys.Ability_Duration,
                    function()
                        if GameRules:IsGamePaused() then
                            return 0.03
                        end
                        if v and not v:IsNull() then
                            v:SetContextNum("Reimu04_Effect_Damage_Count", 0, 0)
                        end
                    end
                )
            end
            if v:GetContext("Reimu04_Effect_Damage_Count") < keys.Damage_Count then
                local DamageTable = {
                    ability = keys.ability,
                    victim = v,
                    attacker = caster,
                    damage = keys.ability:GetAbilityDamage() / keys.Damage_Count,
                    damage_type = keys.ability:GetAbilityDamageType(),
                }
                if v:HasModifier("modifier_reimu03_flag") then
                    DamageTable.damage_type = DAMAGE_TYPE_PURE
                end
                UtilStun:UnitStunTarget(caster, v, keys.Stun_Duration)
                UnitDamageTarget(DamageTable)
                v:SetContextNum("Reimu04_Effect_Damage_Count", v:GetContext("Reimu04_Effect_Damage_Count") + 1, 0)
            end
        end
    end
end

modifier_dota2x_reimu04_magic_immune = {}
LinkLuaModifier("modifier_dota2x_reimu04_magic_immune", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_dota2x_reimu04_magic_immune:IsHidden() return false end
function modifier_dota2x_reimu04_magic_immune:IsDebuff() return false end
function modifier_dota2x_reimu04_magic_immune:RemoveOnDeath() return true end

function modifier_dota2x_reimu04_magic_immune:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_dota2x_reimu04_magic_immune:GetEffectName()
    return "particles/thd2/heroes/reimu/reimu_04_effect_buff.vpcf"
end

function modifier_dota2x_reimu04_magic_immune:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function modifier_dota2x_reimu04_magic_immune:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.4)
end

function modifier_dota2x_reimu04_magic_immune:OnIntervalThink()
    if not IsServer() then return end
    local dummy = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not dummy or not parent or not ability or dummy:IsNull() or parent:IsNull() or ability:IsNull() or GetDistanceBetweenTwoVec2D(dummy:GetAbsOrigin(), parent:GetAbsOrigin()) > ability:GetSpecialValueFor("radius") then
        self:Destroy()
    end
end

modifier_thdots_reimu04_root = {}
LinkLuaModifier("modifier_thdots_reimu04_root", "scripts/vscripts/abilities/abilityreimu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_reimu04_root:IsHidden() return false end
function modifier_thdots_reimu04_root:IsDebuff() return true end
function modifier_thdots_reimu04_root:RemoveOnDeath() return true end
function modifier_thdots_reimu04_root:IsPurgable() return false end
function modifier_thdots_reimu04_root:IsPurgeException() return false end

function modifier_thdots_reimu04_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_thdots_reimu04_root:GetEffectName()
    return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

function modifier_thdots_reimu04_root:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_thdots_reimu04_root:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.4)
end

function modifier_thdots_reimu04_root:OnIntervalThink()
    if not IsServer() then return end
    local dummy = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not dummy or not parent or not ability or dummy:IsNull() or parent:IsNull() or ability:IsNull() or GetDistanceBetweenTwoVec2D(dummy:GetAbsOrigin(), parent:GetAbsOrigin()) > ability:GetSpecialValueFor("radius") then
        self:Destroy()
    end
end

ability_dota2x_reimuEx = {}

function ability_dota2x_reimuEx:GetIntrinsicModifierName()
    return "ability_dota2x_reimuEx_passive"
end

ability_dota2x_reimuEx_passive = {}
LinkLuaModifier("ability_dota2x_reimuEx_passive","scripts/vscripts/abilities/abilityReimu.lua",LUA_MODIFIER_MOTION_NONE)
function ability_dota2x_reimuEx_passive:IsHidden()        return false end
function ability_dota2x_reimuEx_passive:IsPurgable()      return false end
function ability_dota2x_reimuEx_passive:RemoveOnDeath()   return false end
function ability_dota2x_reimuEx_passive:IsDebuff()        return false end

function ability_dota2x_reimuEx_passive:OnCreated()
    if not IsServer() then return end
    self.give_gold_amount           = self:GetAbility():GetSpecialValueFor("give_gold_amount")
    self.give_gold_interval         = self:GetAbility():GetSpecialValueFor("give_gold_interval")
    self.Kill_count =   PlayerResource:GetKills(self:GetParent():GetPlayerID())
    self.Assists_count =   PlayerResource:GetAssists(self:GetParent():GetPlayerID())
    self:StartIntervalThink(self.give_gold_interval)
end

function ability_dota2x_reimuEx_passive:OnIntervalThink()
    if not IsServer() then return end
    local Caster = self:GetParent()
    local CasterPlayerID = Caster:GetPlayerOwnerID()
    if GameRules:GetDOTATime(false, false) == 0 then return end
    PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + self.give_gold_amount,false)
end


function ability_dota2x_reimuEx_passive:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function ability_dota2x_reimuEx_passive:OnDeath(keys)
    if not keys.unit:IsRealHero() then return end
    local caster = self:GetParent()
    if self.Kill_count ~= PlayerResource:GetKills(caster:GetPlayerID()) or self.Assists_count ~= PlayerResource:GetAssists(caster:GetPlayerID()) then
        local totalgoldget = self:GetAbility():GetSpecialValueFor("give_gold_kill")
        print("------------------------")
        self.Kill_count = PlayerResource:GetKills(caster:GetPlayerID())
        self.Assists_count = PlayerResource:GetAssists(caster:GetPlayerID())

        local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effectIndex)
        caster:EmitSound("DOTA_Item.Hand_Of_Midas")
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD,caster, totalgoldget, nil)

        local PlayerID = caster:GetPlayerOwnerID()
        PlayerResource:SetGold(PlayerID,PlayerResource:GetUnreliableGold(PlayerID) + totalgoldget,false)
        print(PlayerResource:GetNetWorth(caster:GetPlayerOwnerID()))
    end
end