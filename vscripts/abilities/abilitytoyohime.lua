ability_thdots_toyohimeEx ={}

function ability_thdots_toyohimeEx:OnSpellStart()
    local caster = self:GetCaster()
    --创建属于施法者的坐标表
    if caster.Thinkers == nil then
        caster.Thinkers = {}
    end
    --播放音效(未定)
    local thinker1 = CreateModifierThinker(caster, self, "modifier_ability_thdots_toyohimeEx_thinker", {duration = self:GetSpecialValueFor("duration")},self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
    --创建坐标
    --table.insert(caster.Thinkers,1,thinker1)
    --存储坐标
    local thinker2 = CreateModifierThinker(caster, self, "modifier_ability_thdots_toyohimeEx_thinker", {duration = self:GetSpecialValueFor("duration")},self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
    --table.insert(caster.Thinkers,1,thinker2)
    --创建并存储脚下坐标
    print("success")
end

modifier_ability_thdots_toyohimeEx_thinker = {}--坐标
LinkLuaModifier("modifier_ability_thdots_toyohimeEx_thinker", "scripts/vscripts/abilities/abilitytoyohime.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_toyohimeEx_thinker:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
    self.ability            = self:GetAbility()
	self.radius				= self.ability:GetSpecialValueFor("radius")
    self.interval           = self.ability:GetSpecialValueFor("interval")
    self.caster             = self:GetCaster()
    print("success")
	if not IsServer() then return end
    print("success")
    local vortex_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_anti_abrasion.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(vortex_particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(vortex_particle, 5, Vector(self.radius, 0, 0))
	self:AddParticle(vortex_particle, false, false, -1, false, false)
    self:StartIntervalThink(self.interval)
end

function modifier_ability_thdots_toyohimeEx_thinker:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius(self.caster:GetTeam(),self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)--循环查找范围内单位
    for _,unit in ipairs(units) do
        unit:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_toyohimeEx_mark", {duration = self.interval})--添加标记
    end
end

function modifier_ability_thdots_toyohimeEx_thinker:OnRemoved()
    --table.remove(self.caster.Thinkers)--先填入的坐标必然最先消失，移除首位即可
    --移除特效
end

modifier_ability_thdots_toyohimeEx_mark = {}--标记
LinkLuaModifier("modifier_ability_thdots_toyohimeEx_mark", "scripts/vscripts/abilities/abilitytoyohime.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_toyohimeEx_mark:IsHidden() return true end
function modifier_ability_thdots_toyohimeEx_mark:IsPurgable() return false end
function modifier_ability_thdots_toyohimeEx_mark:IsPurgeException() return false end
function modifier_ability_thdots_toyohimeEx_mark:RemoveOnDeath() return true end

function modifier_ability_thdots_toyohimeEx_mark:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
    --判断标记所有者的团队，然后上buff
    if parent:HasModifier("modifier_ability_thdots_toyohimeEx_debuff") or parent:HasModifier("modifier_ability_thdots_toyohimeEx_buff") then return end
    if parent:IsOpposingTeam(self:GetCaster():GetTeam()) then
        parent:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_toyohimeEx_debuff", {})
    else
        parent:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_toyohimeEx_buff", {})
    end
end

modifier_ability_thdots_toyohimeEx_buff= {}
LinkLuaModifier("modifier_ability_thdots_toyohimeEx_buff", "scripts/vscripts/abilities/abilitytoyohime.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_toyohimeEx_buff:IsHidden() return false end
function modifier_ability_thdots_toyohimeEx_buff:IsPurgable() return false end
function modifier_ability_thdots_toyohimeEx_buff:IsPurgeException() return false end
function modifier_ability_thdots_toyohimeEx_buff:RemoveOnDeath() return true end

function modifier_ability_thdots_toyohimeEx_buff:OnCreated()
    if not IsServer() then return end
    self.damage_reduce_pct = self:GetAbility():GetSpecialValueFor("damage_reduce_pct")
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_ability_thdots_toyohimeEx_buff:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_ability_thdots_toyohimeEx_mark") then
        if self:GetStackCount()< 19 then self:IncrementStackCount() end
    else
        self:Destroy()
    end
end

function modifier_ability_thdots_toyohimeEx_buff:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end

function modifier_ability_thdots_toyohimeEx_buff:CheckState()   return {[MODIFIER_STATE_FLYING]	= true} end

function modifier_ability_thdots_toyohimeEx_buff:GetModifierIncomingDamage_Percentage()
	return self:GetStackCount() * self.damage_reduce_pct
end

function modifier_ability_thdots_toyohimeEx_buff:GetEffectName()
	return "particles/units/heroes/hero_silencer/silencer_last_word_status.vpcf"
end

modifier_ability_thdots_toyohimeEx_debuff= {}
LinkLuaModifier("modifier_ability_thdots_toyohimeEx_debuff", "scripts/vscripts/abilities/abilitytoyohime.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_toyohimeEx_debuff:IsHidden() return false end
function modifier_ability_thdots_toyohimeEx_debuff:IsPurgable() return false end
function modifier_ability_thdots_toyohimeEx_debuff:IsPurgeException() return false end
function modifier_ability_thdots_toyohimeEx_debuff:RemoveOnDeath() return true end

function modifier_ability_thdots_toyohimeEx_debuff:OnCreated()
    if not IsServer() then return end
    self.damage_amplify_pct = self:GetAbility():GetSpecialValueFor("damage_amplify_pct")
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_ability_thdots_toyohimeEx_debuff:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_ability_thdots_toyohimeEx_mark") then
        if self:GetStackCount()< 19 then self:IncrementStackCount() end
    else
        self:Destroy()
    end
end

function modifier_ability_thdots_toyohimeEx_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end

function modifier_ability_thdots_toyohimeEx_debuff:GetModifierIncomingDamage_Percentage()
	return self:GetStackCount() * self.damage_amplify_pct
end

function modifier_ability_thdots_toyohimeEx_debuff:GetEffectName()
	return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end


ability_thdots_toyohime01 = {}

function ability_thdots_toyohime01:OnSpellStart()
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local particle_gust = "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf"
    local gust_projectile = {	
    Ability = self,
    EffectName = particle_gust,
    vSpawnOrigin = caster:GetAbsOrigin(),
    fDistance = 1500,
    fStartRadius = 1000,
    fEndRadius = 2,
    Source = caster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    bDeleteOnHit = false,
    vVelocity = (((target_point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * 1000,
    bProvidesVision = false,
    ExtraData = {
        x = caster:GetOrigin().x,
        y = caster:GetOrigin().y,
    }
}

    ProjectileManager:CreateLinearProjectile(gust_projectile)
end

--------------------------------------------------------------------------------
-- Projectile
function ability_thdots_toyohime01:OnProjectileHit_ExtraData( target, location, data )
	if not target then return end

	-- get value
	local silence = self:GetSpecialValueFor( "silence_duration" )
	local duration = self:GetSpecialValueFor( "knockback_duration" )
	local max_dist = self:GetSpecialValueFor( "knockback_distance_max" )

	-- calculate distance & direction
	local vec = target:GetOrigin()-Vector(data.x,data.y,0)
	vec.z = 0
	local distance = vec:Length2D()
	distance = (1-distance/self:GetCastRange( Vector(0,0,0), nil ))*max_dist
	if max_dist<0 then distance = 0 end
	vec = vec:Normalized()

	-- apply knockback
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			duration = duration,
			distance = distance,
			direction_x = vec.x,
			direction_y = vec.y,
		} -- kv
	)

	-- apply silence
	UtilSilence:UnitSilenceTarget(self:GetCaster(),target,duration)
	-- play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function ability_thdots_toyohime01:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_drow/drow_hero_silence.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

ability_thdots_toyohime02 = {}