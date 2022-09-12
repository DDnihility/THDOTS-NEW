
local player_repicked = {}
local player_randomed = {}

local enable_random = true;
local enable_repick = false;

--global usable
function THD_Set_Repick_Usable( v )
	enable_repick = v
	CustomGameEventManager:Send_ServerToAllClients("set_repick_button_visible", {val = v} )
end
function THD_Set_Random_Usable( v )
	print(11)
	enable_random = v
	CustomGameEventManager:Send_ServerToAllClients("set_random_button_visible", {val = v} )
end

local THD_Player_Repick = function (keys)
	print("THD_Player_Repick")
	print(keys.val)
	local val = keys.val
	local plyid = keys.PlayerID
	
	if not enable_repick then return end
	
	if GetMapName() == "dota" and GameRules:State_Get() >= DOTA_GAMERULES_STATE_STRATEGY_TIME then return end
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_STRATEGY_TIME then return end
	
	if player_repicked[plyid] then return end
	
	local tmp_table = {}
	
	if PlayerResource:HasSelectedHero(plyid) then
		
		for i=0,128 do
			if PlayerResource:GetPlayer(i) ~= nil then
				tmp_table[i] = PlayerResource:GetSelectedHeroName(i);
			end
		end
		
		GameRules:SetHeroSelectionTime( 10 );
		GameRules:SetHeroSelectPenaltyTime( 0 );
		GameRules:ResetToHeroSelection();
		
		for i=0,128 do
			if i~=plyid and tmp_table[i] ~= nil then
			--if tmp_table[i] ~= nil then
				tmp_table[i] = PlayerResource:GetPlayer(i):SetSelectedHeroName(i);
			end
		end
	
		if player_randomed[plyid] then
			PlayerResource:ModifyGold(plyid,-300,true,0);
		else
			PlayerResource:ModifyGold(plyid,-100,true,0);
		end
		
		player_repicked[plyid] = true
		
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyid), "set_repick_button_visible", {val = false} )
		
	end
	
end

local THD_Player_RandomPick = function (keys)
	print("THD_Player_RandomPick")
	print(keys.val)
	local val = keys.val
	local plyid = keys.PlayerID
	
	if not enable_random then return end
	if player_randomed[plyid] or player_repicked[plyid] then return end
	
	if not PlayerResource:HasSelectedHero(plyid) then
		
		PlayerResource:GetPlayer(plyid):MakeRandomHeroSelection();
		PlayerResource:SetHasRandomed(plyid);
		PlayerResource:ModifyGold(plyid,200,true,0);
		
		player_randomed[plyid] = true;
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyid), "set_random_button_visible", {val = false} )
	
	end
	
end


RegisterCustomEventListener("THD_Player_Repick", THD_Player_Repick);
RegisterCustomEventListener("THD_Player_RandomPick", THD_Player_RandomPick);



