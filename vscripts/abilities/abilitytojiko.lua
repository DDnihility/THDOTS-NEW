--------------------------------------------------------
--雷矢「元兴寺的电磁炮」
--------------------------------------------------------
ability_thdots_tojikoEx = {}

function ability_thdots_tojikoEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_tojikoEx"
end

-- function ability_thdots_tojikoEx:OnSpellStart()
-- 	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_tojikoEx", {duration = 20})
-- end

modifier_ability_thdots_tojikoEx = {}
LinkLuaModifier("modifier_ability_thdots_tojikoEx","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojikoEx:IsHidden() 		return false end
function modifier_ability_thdots_tojikoEx:IsPurgable()		return false end
function modifier_ability_thdots_tojikoEx:RemoveOnDeath() 	return false end
function modifier_ability_thdots_tojikoEx:IsDebuff()		return false end


function modifier_ability_thdots_tojikoEx:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_thdots_tojikoEx:OnCreated()
	if not IsServer() then return end
	self.ability_1 = false
	self.ability_2 = false
	self.ability_3 = false
	self.ability_4 = false
	print("do it")
	print(self:GetParent():GetModelName())
	if self:GetParent():GetModelName() == "models/tojiko/tojiko.vmdl" then
		local tojikoEx_particle = ParticleManager:CreateParticle("models/tojiko/tojiko/lightning.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(tojikoEx_particle , 0, self:GetParent(), 5, "attach_wq_fx", Vector(0,0,0), true)
		ParticleManager:CreateParticle("models/tojiko/tojiko/cloud.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_ability_thdots_tojikoEx:OnAbilityFullyCast(keys)
	if not IsServer() then return end
	if keys.unit == self:GetParent() then
		local caster = self:GetParent()
		local cast_ability = keys.ability
		local cast_ability_point = cast_ability:GetCursorPosition()
		local ability_1 = "ability_thdots_tojiko01"
		local ability_2 = "ability_thdots_tojiko02"
		local ability_3 = "ability_thdots_tojiko03"
		local ability_4 = "ability_thdots_tojiko04"
		if cast_ability:GetName() == ability_1 then
			caster.tojiko01_dummy_create_position = caster.tojiko01_dummy_create_position or cast_ability_point
			caster.tojiko01_dummy_cast_direct = caster.tojiko01_dummy_cast_direct or cast_ability_point
			caster.tojiko01_dummy = CreateUnitByName("npc_vision_dummy_unit",
			-- caster.tojiko01_dummy = CreateUnitByName("npc_ability_hina01_doll",
									caster.tojiko01_dummy_create_position, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
			caster.tojiko01_dummy:FindAbilityByName("ability_invisible_dummy_unit"):SetLevel(1)
			caster.tojiko01_dummy.tojiko01_caster = caster
			caster.tojiko01_dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
				caster.tojiko01_dummy:AddAbility(ability_1)
			local tojiko01_ability = caster.tojiko01_dummy:FindAbilityByName(ability_1)
			tojiko01_ability:SetLevel(cast_ability:GetLevel())

			caster.tojiko01_dummy_cast_position = caster.tojiko01_dummy:GetOrigin() + caster.tojiko01_dummy_cast_direct
			--延迟释放
			caster.tojiko01_dummy:SetContextThink("tojiko01_dummy_cast", function ()
				if self.ability_1 then
					caster.tojiko01_dummy:CastAbilityOnPosition(caster.tojiko01_dummy_cast_position , tojiko01_ability , caster:GetPlayerOwnerID())
				else
					self.ability_1 = true
				end
				caster.tojiko01_dummy_create_position = caster:GetOrigin()
				end,FrameTime())

			caster.tojiko01_dummy_cast_direct = caster:GetForwardVector()

			--延时删除dummy
			local tojiko01_dummy_kill = caster.tojiko01_dummy
			tojiko01_dummy_kill:SetContextThink("tojiko01_dummy_kill", function ()
				tojiko01_dummy_kill:RemoveSelf()
			end,1)

		elseif cast_ability:GetName() == ability_2 then
			caster.tojiko02_dummy_cast_position = caster.tojiko02_dummy_cast_position or cast_ability_point
			caster.tojiko02_dummy = CreateUnitByName("npc_vision_dummy_unit",
			-- caster.tojiko02_dummy = CreateUnitByName("npc_ability_hina01_doll",
									caster.tojiko02_dummy_cast_position, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
			caster.tojiko02_dummy:FindAbilityByName("ability_invisible_dummy_unit"):SetLevel(1)
			caster.tojiko02_dummy.tojiko02_caster = caster
			caster.tojiko02_dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			caster.tojiko02_dummy:AddAbility(ability_2) 
			local tojiko02_ability = caster.tojiko02_dummy:FindAbilityByName(ability_2)
			tojiko02_ability:SetLevel(cast_ability:GetLevel())
			

			caster.tojiko02_dummy:SetContextThink("tojiko02_dummy_cast", function ()
				if self.ability_2 then
					caster.tojiko02_dummy:CastAbilityOnPosition(caster.tojiko02_dummy_cast_position , tojiko02_ability , caster:GetPlayerOwnerID())
				else
					self.ability_2 = true
				end
				caster.tojiko02_dummy_cast_position = cast_ability_point
			end,FrameTime())

			--延时删除dummy
			local tojiko02_dummy_kill = caster.tojiko02_dummy
			tojiko02_dummy_kill:SetContextThink("tojiko02_dummy_kill", function ()
				tojiko02_dummy_kill:RemoveSelf()
			end,2)
		elseif cast_ability:GetName() == ability_3 then
			caster.tojiko03_dummy_cast_position = caster.tojiko03_dummy_cast_position or cast_ability_point
			caster.tojiko03_dummy = CreateUnitByName("npc_vision_dummy_unit",
			-- caster.tojiko03_dummy = CreateUnitByName("npc_ability_hina01_doll",
									caster.tojiko03_dummy_cast_position, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
			caster.tojiko03_dummy:FindAbilityByName("ability_invisible_dummy_unit"):SetLevel(1)
			caster.tojiko03_dummy.tojiko03_caster = caster
			caster.tojiko03_dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			caster.tojiko03_dummy:AddAbility(ability_3) 
			local tojiko03_ability = caster.tojiko03_dummy:FindAbilityByName(ability_3)
			tojiko03_ability:SetLevel(cast_ability:GetLevel())
			

			caster.tojiko03_dummy:SetContextThink("tojiko03_dummy_cast", function ()
				if self.ability_3 then
					caster.tojiko03_dummy:CastAbilityOnPosition(caster.tojiko03_dummy_cast_position , tojiko03_ability , caster:GetPlayerOwnerID())
				else
					self.ability_3 = true
				end
				caster.tojiko03_dummy_cast_position = cast_ability_point
			end,FrameTime())

			--延时删除dummy
			local tojiko03_dummy_kill = caster.tojiko03_dummy
			tojiko03_dummy_kill:SetContextThink("tojiko03_dummy_kill", function ()
				tojiko03_dummy_kill:RemoveSelf()
			end,1)

		elseif cast_ability:GetName() == ability_4 then
			caster.tojiko04_dummy_cast_position = caster.tojiko04_dummy_cast_position or cast_ability_point
			caster.tojiko04_dummy = CreateUnitByName("npc_vision_dummy_unit",
			-- caster.tojiko04_dummy = CreateUnitByName("npc_ability_hina01_doll",
									caster.tojiko04_dummy_cast_position, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
			caster.tojiko04_dummy:FindAbilityByName("ability_invisible_dummy_unit"):SetLevel(1)
			caster.tojiko04_dummy.tojiko04_caster = caster
			caster.tojiko04_dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			caster.tojiko04_dummy:AddAbility(ability_4) 
			local tojiko04_ability = caster.tojiko04_dummy:FindAbilityByName(ability_4)
			tojiko04_ability:SetLevel(cast_ability:GetLevel())
			

			caster.tojiko04_dummy:SetContextThink("tojiko04_dummy_cast", function ()
				if self.ability_4 then
					caster.tojiko04_dummy:CastAbilityOnPosition(caster.tojiko04_dummy_cast_position , tojiko04_ability , caster:GetPlayerOwnerID())
				else
					self.ability_4 = true
				end
				caster.tojiko04_dummy_cast_position = cast_ability_point
			end,FrameTime())

			--延时删除dummy
			local tojiko04_dummy_kill = caster.tojiko04_dummy
			tojiko04_dummy_kill:SetContextThink("tojiko04_dummy_kill", function ()
				tojiko04_dummy_kill:RemoveSelf()
			end,3)

		end
	end
end

function modifier_ability_thdots_tojikoEx:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	-- self.abi_table = {}
	self.ability_thdots_tojiko01 = nil
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_tojikoEx:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker:GetTeam() == keys.unit:GetTeam() then return end
	if keys.inflictor == nil then return end
	local caster = keys.attacker
	local target = keys.unit
	if caster:IsHero() then
	end
	if keys.attacker == self:GetParent() and keys.damage_type == 2 and not keys.inflictor:IsItem() then
		--天赋易伤
		if FindTelentValue(self:GetParent(),"special_bonus_unique_tojiko_2") ~= 0 and target:IsAlive() then
			local duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
			if target:FindModifierByName("modifier_ability_thdots_tojikoEx_debuff") == nil then
				target:AddNewModifier(self:GetCaster(), self:GetAbility(),"modifier_ability_thdots_tojikoEx_debuff", {duration = duration * (1 - target:GetStatusResistance())}):SetStackCount(1)
			else
				local modifier = target:FindModifierByName("modifier_ability_thdots_tojikoEx_debuff")
				modifier:IncrementStackCount()
				modifier:SetDuration(duration, true)
			end
		end
		--天赋刷新大招冷却
		if FindTelentValue(self:GetParent(),"special_bonus_unique_tojiko_3") ~= 0 and target:IsHero() then
			local reduce_time = self:GetAbility():GetSpecialValueFor("reduce_time")
			local tojiko04 = caster:FindAbilityByName("ability_thdots_tojiko04")
			local cooldown = tojiko04:GetCooldownTimeRemaining() - reduce_time
			print(reduce_time)
			tojiko04:EndCooldown()
			tojiko04:StartCooldown(cooldown)
		end
	end
end


--天赋监听
function modifier_ability_thdots_tojikoEx:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_tojiko_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_tojikoEx_telent_1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_tojikoEx_telent_1",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_tojikog_1"))
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_tojiko_4") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_tojikoEx_telent_4") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_tojikoEx_telent_4",{}):SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_tojikog_4"))
	end
end

modifier_ability_thdots_tojikoEx_telent_1 = modifier_ability_thdots_tojikoEx_telent_1 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_tojikoEx_telent_1","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojikoEx_telent_1:IsHidden() 		return true end
function modifier_ability_thdots_tojikoEx_telent_1:IsPurgable()		return false end
function modifier_ability_thdots_tojikoEx_telent_1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_tojikoEx_telent_1:IsDebuff()		return false end

modifier_ability_thdots_tojikoEx_telent_4 = modifier_ability_thdots_tojikoEx_telent_4 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_tojikoEx_telent_4","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojikoEx_telent_4:IsHidden() 		return true end
function modifier_ability_thdots_tojikoEx_telent_4:IsPurgable()		return false end
function modifier_ability_thdots_tojikoEx_telent_4:RemoveOnDeath() 	return false end
function modifier_ability_thdots_tojikoEx_telent_4:IsDebuff()		return false end
function modifier_ability_thdots_tojikoEx_telent_4:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_ability_thdots_tojikoEx_telent_4:GetModifierConstantManaRegen()
	return 8
end


--天赋易伤debuff
modifier_ability_thdots_tojikoEx_debuff = {}
LinkLuaModifier("modifier_ability_thdots_tojikoEx_debuff","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojikoEx_debuff:IsHidden() 		return false end
function modifier_ability_thdots_tojikoEx_debuff:IsPurgable()		return true end
function modifier_ability_thdots_tojikoEx_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_tojikoEx_debuff:IsDebuff()		return true end

function modifier_ability_thdots_tojikoEx_debuff:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_ability_thdots_tojikoEx_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_tojikoEx_debuff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_thdots_tojikoEx_debuff:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("debuff_bonus_damage") * self:GetStackCount()
end

--特效modifier
modifier_ability_thdots_tojikoEx_passive_dummy = {}
LinkLuaModifier("modifier_ability_thdots_tojikoEx_passive_dummy","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojikoEx_passive_dummy:IsHidden() 		return false end
function modifier_ability_thdots_tojikoEx_passive_dummy:IsPurgable()		return false end
function modifier_ability_thdots_tojikoEx_passive_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_tojikoEx_passive_dummy:IsDebuff()		return false end

function modifier_ability_thdots_tojikoEx_passive_dummy:OnCreated()
	if not IsServer() then return end
	-- print("11111111111111111111111")
	-- print(self)
	local point = self:GetParent():GetOrigin()
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	-- ParticleManager:SetParticleControl(self.particle, 0, Vector(point.x,point.y,point.z+500))
	-- print(self.particle)
	-- self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_tojikoEx_passive_dummy:OnIntervalThink()
	if not IsServer() then return end
	local point = self:GetParent():GetOrigin()
	-- self:GetParent():SetOrigin(Vector(point.x,point.y,point.z+500))
end

function modifier_ability_thdots_tojikoEx_passive_dummy:OnDestroy()
	if not IsServer() then return end
	-- print("22222222222222222222222")
	-- ParticleManager:DestroyParticleSystem(self.particle,true)
end
--------------------------------------------------------
--神明「稻目之怨」
--------------------------------------------------------

ability_thdots_tojiko01 = {}

function ability_thdots_tojiko01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_tojiko01:GetCastPoint()
	if self:GetCaster():IsRealHero() then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0
	end
end


function ability_thdots_tojiko01:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local point 				= self:GetCursorPosition()
	local cast_range  			= self:GetSpecialValueFor("cast_range") + caster:GetCastRangeBonus()
	local width  				= self:GetSpecialValueFor("width")
	local length  				= self:GetSpecialValueFor("length")
	local damage  				= self:GetSpecialValueFor("damage")
	local armor_damage_bonus  	= self:GetSpecialValueFor("armor_damage_bonus")
	local stun_duration  		= self:GetSpecialValueFor("stun_duration") + FindTelentValue(caster,"special_bonus_unique_tojiko_1")
	local HitHero = false



	local distance = (point - caster:GetOrigin()):Length2D() + length
	if distance > cast_range then
		point = caster:GetOrigin() + (point - caster:GetOrigin()):Normalized() * ( cast_range - length )
	end
	local end_position = point + ( point - caster:GetOrigin()):Normalized() * length
	caster.tojiko01_end_position = end_position
	local radius = 300
	
	--设置8个点
	local num = 8
	local qangle = QAngle(0, 90, 0)
	local cp = caster:GetOrigin()
	local ap1 = point
	local ap2 = ap1 + (ap1 - cp):Normalized() * length / 3
	local ap3 = ap1 + (ap1 - cp):Normalized() * length / 3 * 2
	local ap4 = ap1 + (ap1 - cp):Normalized() * length
	local position_1 = ap1 + (ap1 - cp):Normalized() * width
	local position_2 = ap2 + (ap2 - cp):Normalized() * width
	local position_3 = ap3 + (ap3 - cp):Normalized() * width
	local position_4 = ap4 + (ap4 - cp):Normalized() * width
	local pt = {}
	pt[1] = RotatePosition(ap1, QAngle(0, 90, 0), position_1)
	pt[2] = RotatePosition(ap1, QAngle(0, -90, 0), position_1)
	pt[3] = RotatePosition(ap2, QAngle(0, 90, 0), position_2)
	pt[4] = RotatePosition(ap2, QAngle(0, -90, 0), position_2)
	pt[5] = RotatePosition(ap3, QAngle(0, 90, 0), position_3)
	pt[6] = RotatePosition(ap3, QAngle(0, -90, 0), position_3)
	pt[7] = RotatePosition(ap4, QAngle(0, 90, 0), position_4)
	pt[8] = RotatePosition(ap4, QAngle(0, -90, 0), position_4)
	--特效音效
	if caster:IsHero() then
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko01",point)
	else
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko01_dummy",point)
	end
	local tojiko01_particle_name = "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf"
	local tojiko01_particle_name_2 = "particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_cast.vpcf"
	for i=1,num do
		local particle_point = pt[i]
		local tojiko01_particle_1 = ParticleManager:CreateParticle(tojiko01_particle_name, PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(tojiko01_particle_1, 0, particle_point)
		ParticleManager:SetParticleControl(tojiko01_particle_1, 1, Vector(particle_point.x,particle_point.y,particle_point.z+1500))
		ParticleManager:DestroyParticleSystem(tojiko01_particle_1,false)

		local tojiko01_particle_2 = ParticleManager:CreateParticle(tojiko01_particle_name_2, PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(tojiko01_particle_2, 0, particle_point)
		ParticleManager:SetParticleControl(tojiko01_particle_2, 1, particle_point)
		ParticleManager:DestroyParticleSystem(tojiko01_particle_2,false)
	end


	--只有英雄触发table操作，马甲不触发
	-- if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then

	-- 	self.tojiko01_table = self.tojiko01_table or {}
	-- 	print(#self.tojiko01_table)
	-- 	for i=1,num do
	-- 		if self.tojiko01_table[i] ~= nil then
	-- 			self.tojiko01_table[i].think_modifier:RemoveSelf()
	-- 		end
	-- 		self.tojiko01_table[i] = {
	-- 			point = nil,
	-- 			think_modifier = nil,
	-- 		}
	-- 		local point = pt[i]
	-- 		self.tojiko01_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
	-- 	end
	-- end

	if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then
		self.tojiko01_table = self.tojiko01_table or {}
		for i=1,num do
			local point = pt[i]
			if self.tojiko01_table[i] == nil then
					self.tojiko01_table[i] = {
					think_modifier = nil,
				}
				self.tojiko01_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
			else
				self.tojiko01_table[i].think_modifier:SetAbsOrigin(point)
			end
		end
	end

	--判断是否击中英雄单位并造成伤害
	local targets = FindUnitsInLine(caster:GetTeam(), point, end_position, nil,width,self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),0)
	for _,vic in ipairs(targets) do
		if vic:IsHero() then
			HitHero = true
			print("tojiko01_hero")
			break
		end
	end
	local ability = self
	if not caster:IsHero() then
		caster = caster.tojiko01_caster
		ability = caster:FindAbilityByName("ability_thdots_tojiko01")
	end
	for _,vic in pairs (targets) do
		local vic_damage = damage + vic:GetPhysicalArmorValue(false) * armor_damage_bonus
		local damage_tabel = {
				victim 			= vic,
				damage 			= vic_damage,
				damage_type		= ability:GetAbilityDamageType(),
				attacker 		= caster,
				ability 		= ability
			}
		if HitHero then
			UtilStun:UnitStunTarget(caster,vic,stun_duration)
		end
		UnitDamageTarget(damage_tabel)
	end
end

--------------------------------------------------------
--雷击「镰足之死」
--------------------------------------------------------

ability_thdots_tojiko02 = {}

function ability_thdots_tojiko02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_tojiko02:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_tojiko02:GetCastPoint()
	if self:GetCaster():IsRealHero() then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0
	end
end

function ability_thdots_tojiko02:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local point 				= self:GetCursorPosition()
	local radius  				= self:GetSpecialValueFor("radius")
	local damage  				= self:GetSpecialValueFor("damage")
	local armor_damage_bonus  	= self:GetSpecialValueFor("armor_damage_bonus")
	local delay  				= self:GetSpecialValueFor("delay")
	local damage_bonus  		= self:GetSpecialValueFor("damage_bonus") / 100
	AddFOWViewer(caster:GetTeamNumber(), point,radius,delay+0.5, false)
	if caster:IsHero() then
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko02_1",point)
	else
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko02_1_dummy",point)
	end
	local tojiko_explosion_particle = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lb_cfx_il.vpcf", PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(tojiko_explosion_particle, 0, point)
	ParticleManager:SetParticleControl(tojiko_explosion_particle, 1, Vector(radius,0,0))
	ParticleManager:DestroyParticleSystem(tojiko_explosion_particle,false)

	local tojiko_explosion_particle_2 = ParticleManager:CreateParticle("particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_spawn_portal.vpcf", PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(tojiko_explosion_particle_2, 0, point)
	ParticleManager:DestroyParticleSystem(tojiko_explosion_particle_2,false)

	local strike_particle = "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf"
	local strike_particle_fx = ParticleManager:CreateParticle(strike_particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(strike_particle_fx, 0, point)
	ParticleManager:SetParticleControl(strike_particle_fx, 1, point)
	ParticleManager:SetParticleControl(strike_particle_fx, 2, point)
	ParticleManager:SetParticleControl(strike_particle_fx, 7, Vector(radius,0,0))
	ParticleManager:DestroyParticleSystem(strike_particle_fx,false)


	caster:SetContextThink("tojiko02_delay", function ()	
		if GameRules:IsGamePaused() then return FrameTime() end
		--设置8个点
		local num = 8
		local qangle = QAngle(0, 44, 0)
		local cp = caster:GetOrigin()
		cp.x = cp.x + 0.01 --设置技能点偏移，不然特效会出BUG
		local position = point + (point - cp):Normalized() * radius
		local pt = {}
		for i=1,num do
			pt[i] = position
			position = RotatePosition(point, qangle, position)
		end

		--特效音效
		if caster:IsHero() then
			StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko02_2",point)
		else
			StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko02_2_dummy",point)
		end
		local tojiko02_particle_name = "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf"
		local tojiko02_particle_name_2 = "particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_cast.vpcf"
		for i=1,num do
			local particle_point = pt[i]
			-- print(particle_point)
			local tojiko02_particle_1 = ParticleManager:CreateParticle(tojiko02_particle_name, PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(tojiko02_particle_1, 0, Vector(particle_point.x,particle_point.y,particle_point.z+1500))
			ParticleManager:SetParticleControl(tojiko02_particle_1, 1, particle_point)
			ParticleManager:SetParticleControl(tojiko02_particle_1, 2, particle_point)
			ParticleManager:SetParticleControl(tojiko02_particle_1, 3, particle_point)
			ParticleManager:SetParticleControl(tojiko02_particle_1, 9, particle_point)
			ParticleManager:DestroyParticleSystem(tojiko02_particle_1,false)

			local tojiko02_particle_2 = ParticleManager:CreateParticle(tojiko02_particle_name_2, PATTACH_CUSTOMORIGIN,nil)
			ParticleManager:SetParticleControl(tojiko02_particle_2, 0, particle_point)
			ParticleManager:SetParticleControl(tojiko02_particle_2, 1, particle_point)
			ParticleManager:DestroyParticleSystem(tojiko02_particle_2,false)
		end
		--只有英雄触发table操作，马甲不触发
		-- if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then

		-- 	self.tojiko02_table = self.tojiko02_table or {}
		-- 	for i=1,num do
		-- 		if self.tojiko02_table[i] ~= nil then
		-- 			self.tojiko02_table[i].think_modifier:RemoveSelf()
		-- 		end
		-- 		self.tojiko02_table[i] = {
		-- 			point = nil,
		-- 			think_modifier = nil,
		-- 		}
		-- 		local point = pt[i]
		-- 		self.tojiko02_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
		-- 	end
		-- end

		if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then
			self.tojiko02_table = self.tojiko02_table or {}
			for i=1,num do
				local point = pt[i]
				if self.tojiko02_table[i] == nil then
						self.tojiko02_table[i] = {
						think_modifier = nil,
					}
					self.tojiko02_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
				else
					self.tojiko02_table[i].think_modifier:SetAbsOrigin(point)
				end
			end
		end
		
		
		local targets = FindUnitsInRadius(caster:GetTeam(), point,nil,radius,self:GetAbilityTargetTeam()
			,self:GetAbilityTargetType(),0,0,false)

		for _,vic in ipairs(targets) do
			if vic:IsHero() then
				damage = damage * (1 + damage_bonus)
				break
			end
		end
		local ability = self
		if not caster:IsHero() then
			caster = caster.tojiko02_caster
			ability = caster:FindAbilityByName("ability_thdots_tojiko02")
		end

		for _,vic in pairs (targets) do
			local vic_damage = damage + vic:GetPhysicalArmorValue(false) * armor_damage_bonus
			local damage_tabel = {
					victim 			= vic,
					damage 			= vic_damage,
					damage_type		= ability:GetAbilityDamageType(),
					attacker 		= caster,
					ability 		= ability
				}
			UnitDamageTarget(damage_tabel)
		end
	end, delay)
end

--------------------------------------------------------
--雷矢「元兴寺的雷矢」
--------------------------------------------------------

ability_thdots_tojiko03 = {}

function ability_thdots_tojiko03:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_tojiko03:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_tojiko03:GetCastPoint()
	if self:GetCaster():IsRealHero() then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0
	end
end

function ability_thdots_tojiko03:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local point 				= self:GetCursorPosition()
	local radius  				= self:GetSpecialValueFor("radius")
	local damage  				= self:GetSpecialValueFor("damage")
	local armor_damage_bonus  	= self:GetSpecialValueFor("armor_damage_bonus")
	local duration  			= self:GetSpecialValueFor("duration")
	local vision_time  			= self:GetSpecialValueFor("vision_time") --视野持续时间
	local vision_radius  		= self:GetSpecialValueFor("vision_radius")

	AddFOWViewer(caster:GetTeamNumber(), point,vision_radius,vision_time, false)
	local unit = CreateUnitByName(
		"npc_vision_momiji_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)

	unit:SetOrigin(point)

	unit:SetDayTimeVisionRange(vision_radius)
	unit:SetNightTimeVisionRange(vision_radius)
	local abilityGEM = unit:FindAbilityByName("ability_thdots_momiji02_unit")
	if abilityGEM ~= nil then
		abilityGEM:SetLevel(4)
		unit:CastAbilityImmediately(abilityGEM, 0)
	end

	local ability_invisible_dummy_unit = unit:FindAbilityByName("ability_invisible_dummy_unit")
	ability_invisible_dummy_unit:SetLevel(1)

	unit:SetContextThink("ability_momiji_02_vision", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:ForceKill(true)
		end, 
	vision_time)
	--设置1个点
	local num = 1
	local qangle = QAngle(0, 44, 0)
	local cp = caster:GetOrigin()

	local pt = {}
	for i=1,num do
		pt[i] = point
	end

	--特效音效
	if caster:IsHero() then
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko03",point)
	else
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko03_dummy",point)
	end
	local tojiko03_particle_name = "particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf"
	-- local tojiko03_particle_name = "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf"
	local tojiko03_particle_name_2 = "particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_cast.vpcf"
	for i=1,num do
		local particle_point = pt[i]
		local tojiko03_particle_1 = ParticleManager:CreateParticle(tojiko03_particle_name, PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(tojiko03_particle_1, 0, Vector(particle_point.x,particle_point.y,particle_point.z+5000))
		ParticleManager:SetParticleControl(tojiko03_particle_1, 1, particle_point)
		ParticleManager:DestroyParticleSystem(tojiko03_particle_1,false)

		-- local tojiko01_particle_2 = ParticleManager:CreateParticle(tojiko03_particle_name_2, PATTACH_CUSTOMORIGIN, nil)
		-- ParticleManager:SetParticleControl(tojiko01_particle_2, 0, particle_point)
		-- ParticleManager:SetParticleControl(tojiko01_particle_2, 1, particle_point)
		-- ParticleManager:ReleaseParticleIndex(tojiko01_particle_2)

		local strike_particle = "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf"
		local strike_particle_fx = ParticleManager:CreateParticle(strike_particle, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(strike_particle_fx, 0, particle_point)
		ParticleManager:SetParticleControl(strike_particle_fx, 1, particle_point)
		ParticleManager:SetParticleControl(strike_particle_fx, 2, particle_point)
		ParticleManager:SetParticleControl(strike_particle_fx, 7, Vector(radius,0,0))
		ParticleManager:DestroyParticleSystem(strike_particle_fx,false)
	end

	
	--只有英雄触发table操作，马甲不触发
	if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then
		self.tojiko03_table = self.tojiko03_table or {}
		for i=1,num do
			local point = pt[i]
			if self.tojiko03_table[i] == nil then
					self.tojiko03_table[i] = {
					think_modifier = nil,
				}
				self.tojiko03_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
			else
				self.tojiko03_table[i].think_modifier:SetAbsOrigin(point)
			end
		end
	end


	local targets = FindUnitsInRadius(caster:GetTeam(), point,nil,radius,self:GetAbilityTargetTeam()
		,self:GetAbilityTargetType(),0,0,false)

	for _,vic in ipairs(targets) do
		if vic:IsHero() then
			caster:AddNewModifier(caster, self, "modifier_ability_thdots_tojiko03", {duration = duration})
			print("add_modifier")
			if caster.tojiko03_caster ~= nil then
				local caster_ability_tojiko03 = caster.tojiko03_caster:FindAbilityByName("ability_thdots_tojiko03")
				caster.tojiko03_caster:AddNewModifier(caster.tojiko03_caster, caster_ability_tojiko03, "modifier_ability_thdots_tojiko03", {duration = duration})
				print(caster.tojiko03_caster:GetName())
			end
			break
		end
	end
	local ability = self
	if not caster:IsHero() then
		caster = caster.tojiko03_caster
		ability = caster:FindAbilityByName("ability_thdots_tojiko03")
	end
	for _,vic in pairs (targets) do
		local vic_damage = damage + vic:GetPhysicalArmorValue(false) * armor_damage_bonus
		local damage_tabel = {
				victim 			= vic,
				damage 			= vic_damage,
				damage_type		= ability:GetAbilityDamageType(),
				attacker 		= caster,
				ability 		= ability
			}
		UnitDamageTarget(damage_tabel)
	end

end


modifier_ability_thdots_tojiko03 = {}
LinkLuaModifier("modifier_ability_thdots_tojiko03","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojiko03:IsHidden() 		return false end
function modifier_ability_thdots_tojiko03:IsPurgable()		return true end
function modifier_ability_thdots_tojiko03:RemoveOnDeath() 	return true end
function modifier_ability_thdots_tojiko03:IsDebuff()		return false end


function modifier_ability_thdots_tojiko03:OnCreated()
	if not IsServer() then return end
	if self:GetParent():IsHero() then
		self.effect = ParticleManager:CreateParticle("particles/econ/events/ti8/mjollnir_shield_ti8.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_ability_thdots_tojiko03:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():IsHero() then
		ParticleManager:DestroyParticle(self.effect,true)
	end
end

function modifier_ability_thdots_tojiko03:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_tojiko03:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage_percentage")
end

function modifier_ability_thdots_tojiko03:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return 0 end
	if kv.target == self:GetParent() and kv.damage_type == 1 then
		print(self:GetAbility():GetSpecialValueFor("physical_reduce"))
		return kv.damage * self:GetAbility():GetSpecialValueFor("physical_reduce") / 100
	else
		return 0
	end
end

--------------------------------------------------------
--怨灵「入鹿之雷」
--------------------------------------------------------

ability_thdots_tojiko04 = {}

function ability_thdots_tojiko04:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_tojiko04:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_tojiko04:GetCastPoint()
	if self:GetCaster():IsRealHero() then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0
	end
end

function ability_thdots_tojiko04:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local point 				= self:GetCursorPosition()
	local radius  				= self:GetSpecialValueFor("radius")
	local damage  				= self:GetSpecialValueFor("damage")
	local delay  				= self:GetSpecialValueFor("delay")
	local armor_damage_bonus  	= self:GetSpecialValueFor("armor_damage_bonus")
	local regen_mana  			= self:GetSpecialValueFor("regen_mana")


	if caster:IsHero() then
		caster:EmitSound("Voice_Thdots_Tojiko.AbilityTojiko04_1")
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko04_3",point)
	else
		StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko04_3_dummy",point)
	end
	AddFOWViewer(caster:GetTeamNumber(), point,radius,delay+1, false)
	local tojiko04_cast_particle = ParticleManager:CreateParticle("particles/econ/items/razor/razor_ti6/razor_plasmafield_ti6.vpcf", PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(tojiko04_cast_particle, 0, point)
	ParticleManager:SetParticleControl(tojiko04_cast_particle, 1, Vector(radius,radius,1))
	ParticleManager:DestroyParticleSystemTime(tojiko04_cast_particle,delay)

	if caster:IsHero() then
		local tojiko04_cast_particle_2 = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(tojiko04_cast_particle_2, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(tojiko04_cast_particle_2, 1, caster:GetOrigin())
		ParticleManager:SetParticleControl(tojiko04_cast_particle_2, 2, Vector(0,0,0))
		ParticleManager:SetParticleControl(tojiko04_cast_particle_2, 3, caster:GetOrigin())
		ParticleManager:SetParticleControl(tojiko04_cast_particle_2, 6, caster:GetOrigin())
		ParticleManager:DestroyParticleSystemTime(tojiko04_cast_particle_2,delay)
	end


	caster:SetContextThink("tojiko04_delay", function ()	
		if GameRules:IsGamePaused() then return FrameTime() end

		--设置20个点,10个大圈，10个小圈
		local num = 10
		local num_2 = 10
		local qangle = QAngle(0, 360/num, 0)
		num = num + num_2
		local cp = caster:GetOrigin()
		cp.x = cp.x + 0.01 --设置技能点偏移，不然特效会出BUG
		local position = point + (point - cp):Normalized() * radius
		local position_2 = point + (point - cp):Normalized() * ( radius - 150 )
		local pt = {}
		for i=1,num do
			pt[i] = position
			if i ~= num_2 then
				position = RotatePosition(point, qangle, position)
			else
				position = position_2
			end
		end

		--特效音效
		if caster:IsHero() then
			StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko04_2",point)
		else
			StartSoundEventFromPosition("Voice_Thdots_Tojiko.AbilityTojiko04_2_dummy",point)
		end

		local tojiko04_particle_name = "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf"
		local tojiko04_particle_name_2 = "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath.vpcf"
		for i=1,num do
			local particle_point = pt[i]
			-- print(particle_point)
			local tojiko04_particle_1 = ParticleManager:CreateParticle(tojiko04_particle_name, PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(tojiko04_particle_1, 0, Vector(particle_point.x,particle_point.y,particle_point.z+1500))
			ParticleManager:SetParticleControl(tojiko04_particle_1, 1, particle_point)
			ParticleManager:SetParticleControl(tojiko04_particle_1, 2, particle_point)
			ParticleManager:DestroyParticleSystem(tojiko04_particle_1,false)

			local tojiko04_particle_2 = ParticleManager:CreateParticle(tojiko04_particle_name_2, PATTACH_CUSTOMORIGIN,nil)
			ParticleManager:SetParticleControl(tojiko04_particle_2, 0, Vector(particle_point.x,particle_point.y,particle_point.z+1500))
			ParticleManager:SetParticleControl(tojiko04_particle_2, 1, particle_point)
			ParticleManager:SetParticleControl(tojiko04_particle_2, 2, particle_point)
			ParticleManager:DestroyParticleSystem(tojiko04_particle_2,false)
		end
		local tojiko04_cast_particle_end = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(tojiko04_cast_particle_end, 0, point)
		ParticleManager:SetParticleControl(tojiko04_cast_particle_end, 1, Vector(radius,radius,radius))
		ParticleManager:DestroyParticleSystem(tojiko04_cast_particle_end,false)
		--只有英雄触发table操作，马甲不触发
		-- if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then

		-- 		print("do it")
		-- 	self.tojiko04_table = self.tojiko04_table or {}
		-- 	for i=1,num do
		-- 		if self.tojiko04_table[i] ~= nil then
		-- 			self.tojiko04_table[i].think_modifier:RemoveSelf()
		-- 		end
		-- 		self.tojiko04_table[i] = {
		-- 			point = nil,
		-- 			think_modifier = nil,
		-- 		}
		-- 		local point = pt[i]
		-- 		self.tojiko04_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
		-- 	end
		-- end

		if caster:IsHero() and caster:HasModifier("modifier_ability_thdots_tojikoEx") then
			self.tojiko04_table = self.tojiko04_table or {}
			for i=1,num do
				local point = pt[i]
				if self.tojiko04_table[i] == nil then
						self.tojiko04_table[i] = {
						think_modifier = nil,
					}
					self.tojiko04_table[i].think_modifier = CreateModifierThinker(caster, self, "modifier_ability_thdots_tojikoEx_passive_dummy", {}, point, caster:GetTeamNumber(), false)
				else
					-- self.tojiko04_table[i].think_modifier:SetAbsOrigin(point)
					self.tojiko04_table[i].think_modifier:SetOrigin(point)
				end
			end
		end


		local targets = FindUnitsInRadius(caster:GetTeam(), point,nil,radius,self:GetAbilityTargetTeam()
			,self:GetAbilityTargetType(),0,0,false)

		for _,vic in ipairs(targets) do
			if vic:IsHero() then
				print("mana")
				if caster.tojiko04_caster ~= nil then
					print("caster.tojiko04_caster")
					print(caster.tojiko04_caster:GetName())
					caster.tojiko04_caster:SetMana(caster.tojiko04_caster:GetMana() + regen_mana)
					SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,caster.tojiko04_caster,regen_mana,nil)
				else
					print("caster")
					print(caster:GetName())
					caster:SetMana(caster:GetMana() + regen_mana)
					SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,caster,regen_mana,nil)
				end
				break
			end
		end
		local ability = self
		if not caster:IsHero() then
			caster = caster.tojiko04_caster
			ability = caster:FindAbilityByName("ability_thdots_tojiko04")
		end
		for _,vic in pairs (targets) do
			print(vic:GetPhysicalArmorValue(false))
			print(vic:GetPhysicalArmorValue(false) * armor_damage_bonus)
			local vic_damage = damage + vic:GetPhysicalArmorValue(false) * armor_damage_bonus
			local damage_tabel = {
					victim 			= vic,
					damage 			= vic_damage,
					damage_type		= ability:GetAbilityDamageType(),
					attacker 		= caster,
					ability 		= ability
				}
			if not vic:HasModifier("modifier_fountain_aura_buff") then
				-- local tojiko04_cast_particle_damage = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_tgw_screen_damage.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, vic)
				-- ParticleManager:ReleaseParticleIndex(tojiko04_cast_particle_damage)
				UnitDamageTarget(damage_tabel)
			end
		end
	end, delay)
end



--------------------------------------------------------
--「元兴寺的龙卷」：万宝槌技能
--------------------------------------------------------

ability_thdots_tojiko05 = {}

function ability_thdots_tojiko05:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_tojiko05:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			if self:GetCaster():HasModifier("modifier_ability_thdots_tojiko05") then
				self:GetCaster():RemoveModifierByName("modifier_ability_thdots_tojiko05")
			end
			self:SetHidden(true)
		end
	end
end

function ability_thdots_tojiko05:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_tojiko05:GetCastPoint()
	if self:GetCaster():IsRealHero() then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0
	end
end

function ability_thdots_tojiko05:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local radius  				= self:GetSpecialValueFor("radius")
	local duration  			= self:GetSpecialValueFor("duration")
	caster:EmitSound("Voice_Thdots_Tojiko.AbilityTojiko05_Cast")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_tojiko05",{duration = duration})
end

modifier_ability_thdots_tojiko05 = {}
LinkLuaModifier("modifier_ability_thdots_tojiko05","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojiko05:IsHidden() 		return false end
function modifier_ability_thdots_tojiko05:IsPurgable()		return false end
function modifier_ability_thdots_tojiko05:RemoveOnDeath() 	return true end
function modifier_ability_thdots_tojiko05:IsDebuff()		return false end
function modifier_ability_thdots_tojiko05:IsAura() 			return true end

function modifier_ability_thdots_tojiko05:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_ability_thdots_tojiko05:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_tojiko05:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_tojiko05:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_ability_thdots_tojiko05:GetModifierAura() return "modifier_ability_thdots_tojiko05_debuff" end

function modifier_ability_thdots_tojiko05:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_ability_thdots_tojiko05:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_ability_thdots_tojiko05:CheckState() --无法攻击被攻击
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
end


function modifier_ability_thdots_tojiko05:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_ability_thdots_tojiko05:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("reduce_mgical_resistance")
end


function modifier_ability_thdots_tojiko05:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local tojiko05_particle_name = "particles/units/heroes/hero_razor/razor_plasmafield.vpcf"
	self.tojiko05_particle = ParticleManager:CreateParticle(tojiko05_particle_name, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(self.tojiko05_particle, 1, Vector(radius,radius,1))

	local tojiko05_particle_name_2 = "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf"
	self.tojiko05_particle_2 = ParticleManager:CreateParticle(tojiko05_particle_name_2, PATTACH_ABSORIGIN, caster)

	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_tojiko05:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	local caster_origin = caster:GetOrigin()
	ParticleManager:SetParticleControl(self.tojiko05_particle, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(self.tojiko05_particle_2, 0, caster:GetOrigin())
end

function modifier_ability_thdots_tojiko05:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.tojiko05_particle,true)
	ParticleManager:DestroyParticleSystem(self.tojiko05_particle_2,true)
end


modifier_ability_thdots_tojiko05_debuff = {}
LinkLuaModifier("modifier_ability_thdots_tojiko05_debuff","scripts/vscripts/abilities/abilitytojiko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_tojiko05_debuff:IsHidden() 		return false end
function modifier_ability_thdots_tojiko05_debuff:IsPurgable()		return false end
function modifier_ability_thdots_tojiko05_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_tojiko05_debuff:IsDebuff()		return true end

function modifier_ability_thdots_tojiko05_debuff:CheckState()
	if not IsServer() then return end
	if IsTHDImmune(self:GetParent()) then
		return {[MODIFIER_STATE_SILENCED] = false}
	else
		return {[MODIFIER_STATE_SILENCED] = true}
	end
end
function modifier_ability_thdots_tojiko05_debuff:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target = self:GetParent()
	self.target:EmitSound("Voice_Thdots_Tojiko.AbilityTojiko05_Target_1")
	self.target:EmitSound("Voice_Thdots_Tojiko.AbilityTojiko05_Target_2")
	local tojiko05_particle_debuff_name = "particles/units/heroes/hero_razor_reduced_flash/razor_static_link_beam_reduced_flash.vpcf"
	self.tojiko05_particle_debuff = ParticleManager:CreateParticle(tojiko05_particle_debuff_name, PATTACH_ABSORIGIN_FOLLOW,self.target)
	ParticleManager:SetParticleControlEnt(self.tojiko05_particle_debuff , 0, self.target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.tojiko05_particle_debuff , 1, self.caster, 5, "attach_hitloc", Vector(0,0,0), true)
end

function modifier_ability_thdots_tojiko05_debuff:OnIntervalThink()
	if not IsServer() then return end
end

function modifier_ability_thdots_tojiko05_debuff:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.tojiko05_particle_debuff,true)
	self.target:StopSound("Voice_Thdots_Tojiko.AbilityTojiko05_Target_2")
	self.target:EmitSound("Voice_Thdots_Tojiko.AbilityTojiko05_Target_3")
end