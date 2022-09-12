
    if UtilStun == nil then
	    UtilStun = class({})
    end

	function UtilStun:UnitStunTarget( caster,target,stuntime)
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration=stuntime * (1 - target:GetStatusResistance())})
    end

    function UnitPauseTargetSakuya( caster,target,pausetime,ability)
    	ability:ApplyDataDrivenModifier( caster, target, "modifier_sakuya_pause_unit", {Duration=pausetime} )
    end