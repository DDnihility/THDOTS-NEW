item_harvest_cradle = {}

function item_harvest_cradle:GetIntrinsicModifierName()
	return "modifier_item_harvest_cradle_passive"
end

modifier_item_harvest_cradle_passive = {}
LinkLuaModifier("modifier_item_harvest_cradle_passive","items/item_harvest_cradle.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_harvest_cradle_passive:IsHidden() return false end
function modifier_item_harvest_cradle_passive:IsPurgable() return false end
function modifier_item_harvest_cradle_passive:IsPurgeException() return false end
function modifier_item_harvest_cradle_passive:RemoveOnDeath() return false end
function modifier_item_harvest_cradle_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_harvest_cradle_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_item_harvest_cradle_passive:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")	
end

function modifier_item_harvest_cradle_passive:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_harvest_cradle_passive:OnCreated()
	if not IsServer() then return end
	self.level 							= self:GetCaster():GetLevel()
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.regen_health					= self.ability:GetSpecialValueFor("regen_health")
	self.regen_mana						= self.ability:GetSpecialValueFor("regen_mana")
	self.regen_health_perlevel			= self.ability:GetSpecialValueFor("regen_health_perlevel")
	self.regen_mana_perlevel			= self.ability:GetSpecialValueFor("regen_mana_perlevel")
	self.duration						= self.ability:GetSpecialValueFor("duration")
	self:StartIntervalThink(FrameTime())
end

function modifier_item_harvest_cradle_passive:OnIntervalThink()
	if not IsServer() then return end
	if self.level ~= self:GetCaster():GetLevel() then

		--固定回血回蓝
		-- local health_regen = self.regen_health + self:GetCaster():GetLevel() * self.regen_health_perlevel
		-- local mana_regen = self.regen_mana + self:GetCaster():GetLevel() * self.regen_mana_perlevel

		--根据游戏时间和等级回蓝，具体为 （分钟数 + 英雄等级）%
		-- local game_time = math.floor(GameRules:GetDOTATime(false, false) /60)
		-- local health_regen = self.regen_health + (self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetBaseMaxHealth()
		-- local mana_regen = self.regen_mana + (self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetMaxMana()
		-- self.health_regen = health_regen / self.duration
		-- self.mana_regen = mana_regen / self.duration
		-- self.caster:Heal(health_regen, self.caster)
		-- self.caster:SetMana(self.caster:GetMana() + mana_regen)
		-- print((self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetBaseMaxHealth())
		-- print((self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetMaxMana())
		-- SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self.caster,health_regen,nil)
		-- SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,self.caster,mana_regen,nil)
		self.caster:AddNewModifier(self.caster, self.ability,"modifier_item_harvest_cradle_levelup", {duration = self.duration})
		self.level = self:GetCaster():GetLevel()
	end
end


--新增一个回血BUFF，被攻击打断
modifier_item_harvest_cradle_levelup = {}
LinkLuaModifier("modifier_item_harvest_cradle_levelup","items/item_harvest_cradle.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_harvest_cradle_levelup:IsHidden() 		return false end
function modifier_item_harvest_cradle_levelup:IsPurgable()		return true end
function modifier_item_harvest_cradle_levelup:RemoveOnDeath() 	return true end
function modifier_item_harvest_cradle_levelup:IsDebuff()		return false end

function modifier_item_harvest_cradle_levelup:OnCreated()
	if not IsServer() then return end
	self.level 							= self:GetCaster():GetLevel()
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.regen_health					= self.ability:GetSpecialValueFor("regen_health")
	self.regen_mana						= self.ability:GetSpecialValueFor("regen_mana")
	self.regen_health_perlevel			= self.ability:GetSpecialValueFor("regen_health_perlevel")
	self.regen_mana_perlevel			= self.ability:GetSpecialValueFor("regen_mana_perlevel")
	self.duration						= self.ability:GetSpecialValueFor("duration")

	local pfx_name = "particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_lvl3.vpcf"
	self.particle = ParticleManager:CreateParticle(pfx_name,PATTACH_ROOTBONE_FOLLOW,self.caster)

	local game_time = math.floor(GameRules:GetDOTATime(false, false) /60)
	local health_regen = self.regen_health + (self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetBaseMaxHealth()
	local mana_regen = self.regen_mana + (self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetMaxMana()
	-- print((self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetBaseMaxHealth())
	-- print((self:GetCaster():GetLevel() + game_time)/100 * self.caster:GetMaxMana())
	self.health_regen = health_regen / self.duration
	self.mana_regen = mana_regen / self.duration
end

function modifier_item_harvest_cradle_levelup:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.particle,true)
end

function modifier_item_harvest_cradle_levelup:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_item_harvest_cradle_levelup:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_item_harvest_cradle_levelup:GetModifierConstantManaRegen()
	return self.mana_regen
end

function modifier_item_harvest_cradle_levelup:OnTakeDamage(keys)
	if not IsServer() then return end
	-- print(keys.damage_category)
	if keys.unit ~= self:GetParent() then return end
	if keys.attacker:GetTeam() ~= keys.unit:GetTeam() and keys.attacker:IsHero() then
		self:GetParent():RemoveModifierByName("modifier_item_harvest_cradle_levelup")
	end
end