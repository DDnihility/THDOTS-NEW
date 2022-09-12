Crit_chance = {}

function THDPerformAttack(attacker,target,miss)
	for item_id = 0, 5 do
		    local item = attacker:GetItemInSlot(item_id)
		    if item~=nil then
	        if item:GetName() == "item_sampan" then
		        if item:GetSpecialValueFor("crit_chance") >= RandomInt(1,100) then
		        	if not attacker:HasModifier("modifier_THD2_crit") then
		    	        attacker:AddNewModifier(attacker,self,"modifier_THD2_crit",{})
		            end
                    if attacker:GetModifierStackCount("modifier_THD2_crit",nil) > item:GetSpecialValueFor("crit_mult") then return end
 		        	attacker:SetModifierStackCount("modifier_THD2_crit",nil,item:GetSpecialValueFor("crit_mult"))
 	        	end
	        elseif item:GetName() == "item_quant" then
		        if item:GetSpecialValueFor("crit_chance") >= RandomInt(1,100) then
		        	if not attacker:HasModifier("modifier_THD2_crit") then
		        	    attacker:AddNewModifier(attacker,self,"modifier_THD2_crit",{})
		            end
                    if attacker:GetModifierStackCount("modifier_THD2_crit",nil) > item:GetSpecialValueFor("crit_mult") then return end
 		        	attacker:SetModifierStackCount("modifier_THD2_crit",nil,item:GetSpecialValueFor("crit_mult"))
 	        	end
 	        elseif item:GetName() == "item_anchor" then
 		        if attacker:HasModifier("modifier_item_anchor_crit_chance_icon") then
 		        	Crit_chance.chance = attacker:GetModifierStackCount("modifier_item_anchor_crit_chance_icon",nil)
 		        else
 		        	Crit_chance.chance = item:GetSpecialValueFor("crit_chance_const")
 		        end
		        if Crit_chance.chance >= RandomInt(1,100) then
		        	if not attacker:HasModifier("modifier_THD2_crit") then
		    	        attacker:AddNewModifier(attacker,self,"modifier_THD2_crit",{})
		            end
                    if attacker:GetModifierStackCount("modifier_THD2_crit",nil) > item:GetSpecialValueFor("buff_take_damage_trigger") then return end
 		    	    attacker:SetModifierStackCount("modifier_THD2_crit",nil,item:GetSpecialValueFor("buff_take_damage_trigger"))
 		        end
 	        end
	    end
	end
	attacker:PerformAttack(target, true, true, true, true, false, false, miss)
	attacker:RemoveModifierByName("modifier_THD2_crit")
end

modifier_THD2_crit = {}
LinkLuaModifier("modifier_THD2_crit","scripts/vscripts/util/performattack.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_THD2_crit:IsHidden() return true end
function modifier_THD2_crit:IsPurgable() return false end
function modifier_THD2_crit:IsDebuff() return false end
function modifier_THD2_crit:RemoveOnDeath() return true end

function modifier_THD2_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end

function modifier_THD2_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetStackCount()
end