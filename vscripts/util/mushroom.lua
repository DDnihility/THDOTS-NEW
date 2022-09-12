
MUSHROOM_BANED_VEC = {
Vector(-4997.613770,-5483.517090,128.000000),
Vector(-2879.457031,-5381.724121,128.000000),
Vector(403.047760,-5450.785156,128.000000),
Vector(1833.770142,-2792.065430,128.000000),
Vector(1045.798950,-1009.788635,128.000000),
Vector(-2239.795410,2064.000000,128.000000),
Vector(-3031.070801,3913.613037,256.000000),
Vector(-1695.215820,5525.166992,256.000000),
Vector(2502.371094,5703.623047,256.000000),
Vector(5239.779785,5687.033691,256.000000),
}

function MushRoomStart()
	local mushroom_time = 0
	local start_time = 0		--刷蘑菇时间
	local interval_time = 60	--刷蘑菇间隔
	-- GameRules:SendCustomMessage("<font color='#00FFFF'>刷蘑菇启动</font>", 0, 0)
	GameRules:GetGameModeEntity():SetContextThink("mushroom_time", 
		function()
			if GameRules:IsGamePaused() then return FrameTime() end
			if math.floor(GameRules:GetDOTATime(false, false)) >= start_time then
				start_time = start_time + interval_time
				-- GameRules:SendCustomMessage("<font color='#00FFFF'>刷一波蘑菇</font>", 0, 0)
				CreateMushRoom()
			end
			mushroom_time = mushroom_time + FrameTime()
			return FrameTime()
		end
		,
		0)
end

function CreateMushRoom()
	local vec = Vector(0,0,0)
	local radius = 7500
	local destroy_time = 300 --蘑菇消除时间
	local change = 995 			--蘑菇生成几率。共1380棵树
	local trees = GridNav:GetAllTreesAroundPoint(vec, radius, false)
	for _,tree in pairs(trees) do
		if RandomInt(1,1000) > change then
			print("MUSHROOM!!")
			local item = CreateItem("item_magic_mushroom", nil, nil)
			local pos = tree:GetAbsOrigin()
			local drop = CreateItemOnPositionSync(pos, item)
			-- AddFOWViewer(DOTA_TEAM_GOODGUYS, pos,128,300,false)
			drop:SetContextThink("drop_destroy", function ()
				drop:RemoveSelf()
			end, destroy_time)
			-- item:LaunchLoot(false, 300, 0.5, pos)
		end
	end
end