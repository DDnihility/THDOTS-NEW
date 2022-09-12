
G_IsAIMode = false
G_IsFastCDMode = false
G_IsFastRespawnMode = false
G_IsCloneMode = false
-- G_IsFCloneMode = false
local team_hero = {}
Bot_Mode = false
-- look at precache, if map == "dota" then enable for default

player_per_team = 5 --default
cur_bot_dif = 1 -- easy
cur_jff = 1 -- ordinary
fast_respawn_val = 20 -- fast respawn mode's respawn time
G_Bot_Push_All_Time = {40,30,20,10}

G_Bot_List = {}
G_Bot_Buff_List = {}
G_Bot_Diff_Text = {"easy","normal","hard","lunatic"}
G_JFF_Text = {"ordinary","allsame","ayayayaya","gaishi"}

G_Bot_Level = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Activelist = LoadKeyValues('scripts/npc/activelist.txt')
function GetValidConnectedCount()
	local ret = 0
	for i=0,233 do
		if PlayerResource:GetConnectionState(i) == 2 then
			ret = ret + 1
		end
	end
	return ret
end

function THD2_SetTeamHero(team_id,val) team_hero[team_id] = val end
function THD2_SetBotMode(val) Bot_Mode = val end
function THD2_SetFCDMode(val) G_IsFastCDMode = val end
function THD2_SetFRSMode(val) G_IsFastRespawnMode = val end
function THD2_SetFRSTime(val) fast_respawn_val = val end
function THD2_SetPlayerPerTeam(val)
	if GetMapName()=="dota" and 
		cur_bot_heros_size + GetValidConnectedCount() < val * 2 and
		not G_IsCloneMode
		then
		val = math.floor((cur_bot_heros_size + GetValidConnectedCount())/2.0)
	end
	--if val > 20 then val=20 end
	player_per_team = val
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, val )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, val )
	return val
end
function THD2_SetBotThinking(val)
	G_IsAIMode = val
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(val)
end
function THD2_SetCloneMode(val)
	G_IsCloneMode = val
	--if val == false then G_IsFCloneMode = false end
	if val == false and cur_jff ~= 1 then 
		cur_jff = 1 
		Say(player, "JustForFun Mode set to ordinary", false)
	end
	GameRules:SetSameHeroSelectionEnabled(val)
end
--[[
function THD2_SetFCloneMode(val)
	G_IsFCloneMode = val
	if val == true then THD2_SetCloneMode(true) end
end
--]]


function THD2_GetBotMode() return Bot_Mode end
function THD2_GetFCDMode() return G_IsFastCDMode end
function THD2_GetFRSMode() return G_IsFastRespawnMode end
function THD2_GetFRSTime() return fast_respawn_val end
function THD2_GetBotDiff() return cur_bot_dif end
function THD2_GetBotDiffName() return G_Bot_Diff_Text[cur_bot_dif] end
function THD2_GetBotThinking(val) G_IsAIMode = val end
function THD2_GetPlayerPerTeam(val) return player_per_team end
function THD2_GetCloneMode() return G_IsCloneMode end
--function THD2_GetFCloneMode() return G_IsFCloneMode end
function THD2_GetFCloneMode() return cur_jff==2 end
function THD2_GetJFFModeName() return G_JFF_Text[cur_jff] end
function THD2_GetJFFMode() return cur_jff end


--to ban some girls(which is not work done XD)
cur_bot_heros_size = 45
tot_bot_heros_size = 63
G_BOT_USED = 
{
	false ,
	false ,
	false ,
	false ,
	false ,
	
	true ,			--黑白
	false ,
	false ,
	false ,
	false ,
	
	true ,			--西瓜
	false ,
	false ,
	true ,			--二妹
	false ,
	
	false ,			--衣玖
	false ,
	true ,			--辉夜
	true ,			--船长
	false ,
	
	true ,			--uuz
	true ,			--蓝
	true ,			--空
	false ,
	true ,			--花妈
	
	true ,			--神妈
	true ,			--大妹
	true ,			--狗花
	true ,			--永琳
	true ,			--紫
	
	true ,			--16
	true ,			--小爱
	false ,
	true ,			--正邪
	false ,
	
	false ,
	false ,
	false ,
	false ,
	false ,			--斯塔
	
	false ,
	false ,
	false ,
	false ,
	false ,
	
	true ,			--秦心
	false ,
	false ,
	false ,
	false ,
	
	false ,
	false ,
	false ,
	false ,
	false ,
	
	false ,			--芙兰v2
	false ,
	false ,
	false ,
	false ,
	
	false ,
	false ,
	false ,
}

G_Bot_Random_Hero = 
{	
	"npc_dota_hero_lina",					--红白
	"npc_dota_hero_juggernaut",				--妖梦
	"npc_dota_hero_slark",					--文文
	"npc_dota_hero_earthshaker",			--天子
	"npc_dota_hero_life_stealer",			--⑩
	
	"npc_dota_hero_crystal_maiden",			--黑白
	"npc_dota_hero_drow_ranger",			--恋
	"npc_dota_hero_mirana",					--兔子
	"npc_dota_hero_chaos_knight",			--妹红
	"npc_dota_hero_centaur",				--红三
	
	"npc_dota_hero_tidehunter",				--西瓜
	"npc_dota_hero_clinkz",					--虫子
	"npc_dota_hero_axe",					--⑨
	"npc_dota_hero_naga_siren",				--二妹
	"npc_dota_hero_storm_spirit",			--四季
	
	"npc_dota_hero_razor",					--衣玖
	"npc_dota_hero_dark_seer",				--白莲
	"npc_dota_hero_furion",					--辉夜
	"npc_dota_hero_kunkka",					--船长
	"npc_dota_hero_lion",					--早苗
	
	"npc_dota_hero_necrolyte",				--uuz
	"npc_dota_hero_puck",					--蓝
	"npc_dota_hero_sniper",					--空
	"npc_dota_hero_tinker",					--教授
	"npc_dota_hero_venomancer" ,			--花妈
	
	"npc_dota_hero_zuus",					--神妈
	"npc_dota_hero_warlock",				--大妹
	"npc_dota_hero_bounty_hunter",			--狗花
	"npc_dota_hero_silencer",				--永琳
	"npc_dota_hero_obsidian_destroyer",		--紫
	
	"npc_dota_hero_templar_assassin",		--16
	"npc_dota_hero_visage",					--小爱
	"npc_dota_hero_viper",					--毒人偶
	"npc_dota_hero_batrider",				--正邪
	"npc_dota_hero_witch_doctor",			--转转
	
	"npc_dota_hero_mars",					--星
	"npc_dota_hero_doom_bringer",			--皮丝
	"npc_dota_hero_rattletrap",				--桑尼
	"npc_dota_hero_luna",					--露娜
	"npc_dota_hero_keeper_of_the_light",	--斯塔
	
	"npc_dota_hero_night_stalker",			--夜雀
	"npc_dota_hero_nyx_assassin",			--大妖精
	"npc_dota_hero_dazzle",					--露娜萨
	"npc_dota_hero_earth_spirit",			--梅露兰
	"npc_dota_hero_weaver",					--莉莉卡
	
	"npc_dota_hero_legion_commander",		--秦心
	"npc_dota_hero_disruptor",				--屠自古
	"npc_dota_hero_elder_titan",			--小町
	"npc_dota_hero_dragon_knight",			--红师傅
	"npc_dota_hero_lich",					--小恶魔
	
	"npc_dota_hero_arc_warden",				--爱莲
	"npc_dota_hero_vengefulspirit",			--果/极/羽立
	"npc_dota_hero_dawnbreaker",			--神子
	"npc_dota_hero_undying",				--宫古
	"npc_dota_hero_grimstroke",				--青娥
	
	"npc_dota_hero_pangolier",				--芙兰v2
	"npc_dota_hero_queenofpain",			--探女
	"npc_dota_hero_omniknight",				--琪斯美
	"npc_dota_hero_ursa",					--娜兹玲
	"npc_dota_hero_ogre_magi",				--诹访子
	
	"npc_dota_hero_phantom_lancer",			--铃仙02
	"npc_dota_hero_dark_willow",			--拉尔瓦
	"npc_dota_hero_huskar",					--秋穰子
}

G_Bots_Ability_Add = {
	--0X
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  },
	{2,1,2,1,2,  6,2,1,1,10,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,11,13,14,16  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,10,13,14,16  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  },
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  }, --marisa wait for fix
	{2,1,3,3,3,  2,3,2,2,10,  6,6,1,1,13, 1,0,6,0,14,  0,0,0,0,16,  0,11,12,15,17  },
	{2,1,1,3,1,  6,1,3,3,10,  3,6,2,2,12, 2,0,6,0,14,  0,0,0,0,17,  0,11,13,15,16  },
	{2,1,2,3,2,  6,2,3,3,10,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,11,12,14,17  },
	{1,3,1,3,1,  6,1,3,3,10,  2,6,2,2,13, 2,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  },
	
	--1X
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  }, -- suika wait for fix
	{2,1,2,3,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17,  0,10,12,15,16  },
	{3,2,1,3,1,  6,3,1,2,11,  3,6,1,2,13, 2,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  }, --cirno
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  },
	{3,2,1,2,2,  6,2,3,3,10,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  }, --shikieiki
	
	{3,1,2,3,1,  6,3,1,3,10,  1,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16,  0,11,13,14,17  }, --iku(x)
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,10,12,15,16  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,10,13,14,16  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  },
	{1,2,3,1,1,  6,1,3,3,11,  3,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16,  0,10,13,14,17  }, --sanae
	
	--2X(预留)
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  },
	{2,1,2,3,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17,  0,10,12,15,16  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,10,13,14,16  },
	{1,3,2,1,3,  6,1,3,1,10,  3,6,2,2,13, 2,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  }, --yumemi
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,10,12,15,16  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,10,15,14,16  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  },
	{1,2,3,1,1,  6,1,3,3,11,  3,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16,  0,10,15,14,17  },
	
	--3X
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,10,12,15,17  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,10,12,15,16  },
	{1,2,3,2,2,  6,2,1,1,10,  1,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --medicine
	{2,3,1,2,2,  6,2,1,1,11,  1,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --seija
	{3,2,1,3,3,  6,3,2,2,11,  2,6,1,1,13, 1,0,6,0,15,  0,0,0,0,17,  0,10,12,14,16  }, --hina
	
	{2,1,3,2,3,  6,2,3,2,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17,  0,10,12,15,16  }, --shou
	{3,2,1,3,2,  6,3,2,3,11,  2,6,1,1,12, 1,0,6,0,15,  0,0,0,0,16,  0,10,13,14,17  }, --clown
	{2,3,1,2,2,  6,2,3,3,10,  3,6,1,1,12, 1,0,6,0,15,  0,0,0,0,17,  0,11,13,14,16  }, --sunny
	{3,1,2,3,3,  6,3,1,1,10,  1,6,2,2,12, 2,0,6,0,15,  0,0,0,0,17,  0,11,13,14,16  }, --luna
	{2,1,2,1,2,  6,1,2,1,11,  3,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --star(x)
	
	--4X
	{1,2,3,1,2,  6,3,1,2,11,  3,6,1,2,12, 3,0,6,0,14,  0,0,0,0,16,  0,10,13,15,17  }, --mystia
	{2,1,3,2,1,  6,2,1,2,10,  1,6,3,3,12, 3,0,6,0,14,  0,0,0,0,17,  0,11,13,15,16  }, --daiyousei
	{1,2,3,1,2,  6,1,2,1,11,  2,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --lunasa
	{3,1,2,3,3,  6,3,1,1,11,  1,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16,  0,10,13,14,17  }, --merlin
	{1,2,1,2,1,  6,2,1,2,10,  3,6,3,3,12, 3,0,6,0,14,  0,0,0,0,17,  0,11,13,15,16  }, --lyrica
	
	{2,1,3,2,1,  6,2,1,2,11,  1,6,3,3,13, 3,0,6,0,15,  0,0,0,0,17,  0,10,12,14,16  }, --kokoro
	{2,1,3,2,1,  6,2,1,2,10,  1,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,11,13,14,16  }, --tojiko
	{2,3,1,3,1,  6,3,1,3,10,  1,6,2,2,12, 2,0,6,0,15,  0,0,0,0,17,  0,11,13,14,16  }, --komachi
	{3,2,1,3,2,  6,1,3,2,10,  1,6,3,2,12, 1,0,6,0,14,  0,0,0,0,16,  0,11,13,15,17  }, --meirin
	{1,3,2,1,3,  6,1,3,1,10,  3,6,2,2,12, 2,0,6,0,14,  0,0,0,0,16,  0,11,13,15,17  }, --koakuma
	
	--5X
	{1,3,2,1,3,  6,1,3,1,10,  3,6,2,2,12, 2,0,6,0,14,  0,0,0,0,16,  0,11,13,15,17  }, --ellen
	{1,3,2,1,3,  6,1,3,1,10,  3,6,2,2,12, 2,0,6,0,14,  0,0,0,0,16,  0,11,13,15,17  }, --hatate
	{1,3,2,1,3,  6,1,3,1,11,  3,6,2,2,13, 2,0,6,0,15,  0,0,0,0,17,  0,10,12,14,16  }, --miko
	{3,1,2,3,3,  6,3,1,1,10,  1,6,2,2,13, 2,0,6,0,15,  0,0,0,0,17,  0,11,12,14,16  }, --miyako
	{2,1,3,2,1,  6,2,1,2,11,  1,6,3,3,13, 3,0,6,0,15,  0,0,0,0,17,  0,10,12,14,16  }, --seiga
	
	{4,1,2,1,2,  6,1,2,1,10,  2,6,4,4,13, 4,0,6,0,15,  0,0,0,0,16,  0,11,12,14,17  }, --flandrev2
	{2,1,3,2,1,  6,2,1,2,10,  1,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,11,12,15,16  }, --sagume
	{1,2,3,2,3,  6,2,3,2,11,  3,6,1,1,12, 1,0,6,0,14,  0,0,0,0,17,  0,10,13,15,16  }, --kisume
	{1,2,3,1,2,  6,1,2,1,10,  2,6,3,3,12, 3,0,6,0,14,  0,0,0,0,17,  0,11,13,15,16  }, --nazrin
	{1,2,3,1,2,  6,1,2,1,11,  2,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --suwako
	
	--6X
	{3,1,2,3,1,  6,3,1,3,11,  1,6,2,2,13, 2,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --reisen02
	{3,2,1,3,2,  6,3,2,3,11,  2,6,1,1,13, 1,0,6,0,15,  0,0,0,0,17,  0,10,12,14,16  }, --larva
	{1,2,3,1,2,  6,1,2,1,11,  2,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,10,12,14,17  }, --minoriko
	
}

function check_H_name(H_name)
	for i=1,tot_bot_heros_size do
		if G_Bot_Random_Hero[i] == H_name then
			return not G_BOT_USED[i]
		end
	end
	return false
end

function THD2_BotUpGradeAbility(hero)
	print("THDOTSGameMode:BotUpGradeAbility")
	
	local hName = hero:GetClassname()
	local hIndex = -1
	for i=0,233 do
		if G_Bot_Random_Hero[i] == hName then
			hIndex = i
			break
		end
	end
	
	if hIndex < 0 then
		print('THDOTSGameMode:BotUpGradeAbility: Error: invalid hero name: ' .. hName )
	else
		local v = hero:GetPlayerOwnerID()
		local lvl = hero:GetLevel()
		--print(lvl)
		if lvl == nil then
			lvl = 1
		end
		if G_Bot_Level[v] == nil then
			G_Bot_Level[v] = 0
		end
		--print(lvl)
		for i=G_Bot_Level[v]+1,lvl do
			if i > 25 then break end 
			local j = G_Bots_Ability_Add[hIndex][i] - 1 --abilitys is 0~n-1, but vals set as 1~n
			local ability = hero:GetAbilityByIndex(j)
			if ability~=nil then
				local level = math.min((ability:GetLevel() + 1),ability:GetMaxLevel())
				ability:SetLevel(level)
			end
		end
		
		G_Bot_Level[v] = lvl
		hero:SetAbilityPoints(0)
		
	end
	
	
end

function THD2_ChangeBotDifficulty( player, dif )
	
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_STRATEGY_TIME then -- can't change difficulty in game
		Say(player, "Can't change bot's difficulty after bot spawned!",false)
		print("THDOTSGameMode:ChangeBotDifficulty: Error: Can't Change difficulty after bot spawned")
		return
	end
	if dif <=0 or dif > 4 then --invalid difficulty
		Say(player, "invalid difficulty!",false)
		print("THDOTSGameMode:ChangeBotDifficulty: Error: invalid difficulty")
		return
	end
	cur_bot_dif = dif
	
	local text = G_Bot_Diff_Text[dif]
	Say(player, "Bot Difficulty set to " .. text, false)
	print("Bot Difficulty set to " .. text)
	
	-- not modify at here now, see state changes
	--[[
	for k,v in pairs(G_Bot_List) do
		local tHero = PlayerResource:GetPlayer(v):GetAssignedHero()
		tHero:SetBotDifficulty(dif)
	end
	
	for k,v in pairs(G_Bot_Buff_List) do
		v:SetLevel(dif)
	end
	]]--
end

function THD2_SetJustForFunMode( player, jff )
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_STRATEGY_TIME then -- can't change difficulty in game
		Say(player, "Can't set bot's Mode after bot spawned!",false)
		print("THDOTSGameMode:JustForFunMode: Error: Can't set Mode after bot spawned")
		return
	end
	if jff <= 0 or jff > 4 then --invalid jff mode
		Say(player, "invalid jff mode!",false)
		print("THDOTSGameMode:SetJustForFunMode: Error: invalid jff mode")
		return
	end
	cur_jff = jff
	
	local text = G_JFF_Text[jff]
	Say(player, "JustForFun Mode set to " .. text, false)
	print("JustForFun Mode set to " .. text)
	
	if jff ~= 1 and not G_IsCloneMode then 
	THD2_SetCloneMode(true)
	Say(player, "Allowsame Mode ON...",false)
	elseif jff == 1 and G_IsCloneMode then
	THD2_SetCloneMode(false)
	Say(player, "Allowsame Mode OFF...",false)
	end
	
end

function THD2_BanBotHero(player, hero_name)
	local index = 0
	for i, name in pairs(G_Bot_Random_Hero) do
		if name == hero_name or name == "npc_dota_hero_" .. hero_name then
			index = i
			if name == hero_name then
				hero_name = string.sub(hero_name, 15)
			end
			break
		end
	end
	if index > 0 then
		G_BOT_USED[index] = true
		Say(player, "Banned bot hero: " .. hero_name, false)
	else
		Say(player, "Cannot ban bot hero " .. hero_name .. ": Hero not found", false)
	end
end

function THD2_BanHero(player, hero_name)
	local index = 0
	for name, i in pairs(Activelist) do
		if name == hero_name or name == "npc_dota_hero_" .. hero_name then
			index = i
			if name == hero_name then
				hero_name = string.sub(hero_name, 15)
			end
			break
		end
	end
	if index > 0 then
		GameRules:AddHeroToBlacklist(hero_name)
		Say(player, "Banned hero: " .. hero_name, false)
	else
		Say(player, "Cannot ban hero " .. hero_name .. ": Hero not found", false)
	end
end
function get_usable_bot_hero()
	
	local int = RandomInt(1, tot_bot_heros_size)
	while(G_BOT_USED[int])
	do
		int = RandomInt(1, tot_bot_heros_size)
	end
	return int
end
			
function THD2_AddBot()

			print("changing to bot mod...")
			print(GameRules:IsCheatMode()) --debug
			
			--DOTA2 的bot加载机制十分弱智
			--如果你进游戏的时候是作弊模式, 那么你就可以控制机器人了
			--但如果不是作弊模式会创建不了机器人
			--所以唯一的办法就是先开作弊创建机器人, 然后进游戏前关掉作弊, 进游戏以后再打开作弊并开启机器人脚本
			--十分弱智不是嘛qwq ? 
			--    来自zdw1999
			
			--[[
			
			local ply = nil
			for i=0,9 do --检测机器人将要使用的位置
				ply = PlayerResource:GetPlayer(i)
				if ply==nil then
					table.insert(G_Bot_List,i)
				end
			end
			--用bot填充空位
			SendToServerConsole('dota_bot_populate')
			SendToServerConsole('dota_bot_set_difficulty 3') --难度为hard
			--设置AI活动
			--local GameMode = GameRules:GetGameModeEntity()
			--GameMode:SetBotThinkingEnabled(true) --不要在这里开启脚本
			--设置AI推塔的最高级别
			--GameMode:SetBotsMaxPushTier(5)
			
			--在这里先关闭cheats, 等进游戏后执行 -startbot
			SendToServerConsole('sv_cheats 0')
			
			--]]
			
			--old bot load style
			--SendToServerConsole('sv_cheats 1')
			--print(GameRules:IsCheatMode()) --debug
			--G_IsAIMode = true
			
			--为了能够方便控制机器人的技能点和属性, 这里使用旧方式加载bot
			
			local GameMode = GameRules:GetGameModeEntity()
			local ply = nil
			local goodcnt = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
			local badcnt = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
			
			-- will check inside
			THD2_ForceClone()
			
			local player_hero_table = {}
			--清除玩家选择的英雄
			if not G_IsCloneMode then
				for i=0,233 do
					ply = PlayerResource:GetPlayer(i)
					if ply ~= nil then
						local tHeroName = PlayerResource:GetSelectedHeroName(i)
						print( 'Player ' .. string.format("%d",i) .. ' picked ' .. tHeroName )
						--针对v2的处理
						--玩家选择芙兰时，bot禁选芙兰v2
						if tHeroName == "npc_dota_hero_naga_siren" then
							for j=0,233 do
								if G_Bot_Random_Hero[j] == "npc_dota_hero_pangolier" then
									G_BOT_USED[j] = true
									break
								end
							end
						end
						--通用情况
						if tHeroName ~= nil then
							for j=0,233 do
								if G_Bot_Random_Hero[j] == tHeroName then
									G_BOT_USED[j] = true
									break
								end
							end
						end
					end
				end
			else
				-- record player hero and make null
				for i=0,233 do
					ply = PlayerResource:GetPlayer(i)
					if ply ~= nil then
						local tHeroName = PlayerResource:GetSelectedHeroName(i)
						player_hero_table[i] = tHeroName
						THD2_ForcePlayerRepick(i,'npc_dota_hero_monkey_king')
					end
				end
			end
			-- 创建bot
			if cur_jff == 4 then
				for i=1,tot_bot_heros_size do
					if i==2 or i==3 or i==7 or i==8 or i==9 or i==10 or i==17 or i==39 or i==42 
					or i==48 or i==49 or i==52 or i==53 or i==56 or i==58
					then
					G_BOT_USED[i] = false
					else
					G_BOT_USED[i] = true
					end
				end
			end
			for i=0,233 do
				ply = PlayerResource:GetPlayer(i)
				if ply ~= nil then
					print(string.format("player %d is not nil",i))
				end
				
				if goodcnt >= player_per_team and badcnt >= player_per_team then
					break
				end
				
				if ply == nil then
					bot_team = true
					local H_name=team_hero[2]
					if goodcnt >= player_per_team then
						bot_team = false
						H_name=team_hero[3]
					end
					local H_id = nil
					--[[
					if (not G_IsFCloneMode) or (not check_H_name(H_name)) then
						H_id = get_usable_bot_hero()
						H_name = G_Bot_Random_Hero[H_id]
						if G_IsFCloneMode then
							if bot_team then
								team_hero[2] = H_name
							else
								team_hero[3] = H_name
							end
						end
					end
					--]]
					-- if not G_BOT_USED[8] then
					-- 	H_id = 8
					-- 	H_name = "npc_dota_hero_mirana"
					-- elseif not G_BOT_USED[40] then
					-- 	H_id = 40
					-- 	H_name = "npc_dota_hero_keeper_of_the_light"
					-- elseif cur_jff == 1 then
					if cur_jff == 1 then
						--ordinary
						H_id = get_usable_bot_hero()
						H_name = G_Bot_Random_Hero[H_id]	
					elseif cur_jff == 2 then
						--allsame
						if (not check_H_name(H_name)) then
							H_id = get_usable_bot_hero()
							H_name = G_Bot_Random_Hero[H_id]
						end
						if bot_team then
							team_hero[2] = H_name
						else
							team_hero[3] = H_name
						end
					elseif cur_jff == 3 then
						--ayayayaya
						H_name = "npc_dota_hero_slark"
					elseif cur_jff == 4 then
						--gaishi(该模式在循环前修改了Used表)
						H_id = get_usable_bot_hero()
						H_name = G_Bot_Random_Hero[H_id]							
					end

					if bot_team == true then
						goodcnt = goodcnt + 1
					else 
						badcnt = badcnt + 1
					end
					--table.insert(G_Bot_List,i)
					print(H_name)
					-- hero name, line('top','mid','bottom'), diff, team 
					Tutorial:AddBot(H_name,'','',bot_team)
					-- clear it temporary
					for i=0,233 do
						if PlayerResource:GetPlayer(i) ~= nil and
							PlayerResource:GetConnectionState(i) == 1 and
							not player_hero_table[i]
							then
							player_hero_table[i] = PlayerResource:GetSelectedHeroName(i)
							THD2_ForcePlayerRepick(i,'npc_dota_hero_monkey_king')
						end
					end
					if not G_IsCloneMode then G_BOT_USED[H_id]=true end
					
				end
			end
			
			print('bbbbb')
			
			for i=0,233 do
				ply = PlayerResource:GetPlayer(i)
				if ply ~= nil and PlayerResource:GetConnectionState(i) == 1 then
					table.insert(G_Bot_List,i)
					ply:SetContextNum("PlayerIsBot", 1, 0)
					print(i)
				end
			end
			--如果存在机器人则启动AI
			
			if #G_Bot_List > 0 then
				THD2_SetBotMode(true)
				--设置AI活动
				GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
				--设置AI推塔的最高级别
				GameRules:GetGameModeEntity():SetBotsMaxPushTier(cur_bot_dif + 2)
				--for i=0,9 do
				--	if PlayerResource:GetConnectionState(i)==1 then
				--		plyhd = PlayerResource:GetPlayer(keys.userid-1)
				--		plyhd:
				--	end
				--end
			end
			
			--在这里先关闭cheats, 等进游戏后执行 -startbot
			--G_IsAIMode = false
			--SendToServerConsole('sv_cheats 0')
			--print(GameRules:IsCheatMode()) --debug
			
			--Say(nil, "Bot Spawned...",false)
			print("Bot Spawned...") --debug
			
			-- formated remake,restore player hero
			for i=0,233 do
				if player_hero_table[i] then
					THD2_ForcePlayerRepick(i,player_hero_table[i])
				end
			end
			
end

function THD2_FirstAddBuff( hero )

			-- set bot's default ability level
		    if THD2_GetBotMode() == true then
			    local plyID = hero:GetPlayerOwnerID()
			    for k,v in pairs(G_Bot_List) do
			    	if v == plyID then
						local bot_buff_ability = hero:AddAbility("ability_common_bot_buff") --bot mana buff
						if bot_buff_ability ~= nil then
							table.insert(G_Bot_Buff_List,bot_buff_ability)
							bot_buff_ability:SetLevel(cur_bot_dif) -- bot's default difficulty
						end
						hero:SetBotDifficulty(cur_bot_dif)
						G_Bot_Level[hero:GetPlayerOwnerID()] = nil
						THD2_BotUpGradeAbility(hero) -- init abilities
						local hName = hero:GetClassname()
						if hName == "npc_dota_hero_pangolier" then
							THD2_BotSpecialInit(hero)
						end
						--[[
						for i=0,16 do
						 	local ability = hero:GetAbilityByIndex(i)
							if ability~=nil then
								local level = 1 or ability:GetMaxLevel()
								ability:SetLevel(level)
							end
						end
						]]--
				 	end
				end
			end
			
			if G_IsFastCDMode then --Fast CoolDown
				local fastCDability = hero:AddAbility("ability_fast_cd_buff")
				if fastCDability ~= nil then
					fastCDability:SetLevel(1)
				end
			end
			
end

function THD2_BotPushAllWithDelay()

		GameRules:GetGameModeEntity():SetContextThink(
			"Bot Push All",
			function()
				GameRules:GetGameModeEntity():SetBotsMaxPushTier(6)
				return nil
			end,
			G_Bot_Push_All_Time[cur_bot_dif] * 60.0
		)
end

function THD2_Special_OnLevelUp()
	
	if THD2_GetBotMode() == true then
	    for k,v in pairs(G_Bot_List) do
	    	--if v == keys.player then
			-- just updata every bot is ok
    			local ply = PlayerResource:GetPlayer(v)
	    		local hero = ply:GetAssignedHero()
				THD2_BotUpGradeAbility(hero)
		 	--end
		end
	end
	
end

function THD2_MakePlayerRepick( plyid , heroname, penalty )
	if penalty == nil then penalty = true end
    --if GameRules:State_Get() == 4 and G_IsFCloneMode then return end --强制克隆时不能在4阶段repick
    if GameRules:State_Get() == 4 and cur_jff ~= 1 then return end
	if GameRules:State_Get() >= 5 then return end --显然游戏开始后不能repick
	local plyhd = PlayerResource:GetPlayer(plyid)
	if PlayerResource:HasSelectedHero(plyid) == false then return end
	if penalty then
		if PlayerResource:HasRandomed(plyid) then 
			PlayerResource:ModifyGold(plyid,-200,true,0); -- -200 gold
		end
		PlayerResource:ModifyGold(plyid,-100,true,0); -- -100 gold
	end
	local tmp = plyhd:GetAssignedHero();
	CreateHeroForPlayer(heroname, plyhd):RemoveSelf();
	if tmp~=nil then tmp:RemoveSelf() end
end

function THD2_ForcePlayerRepick( plyid , heroname )
	local plyhd = PlayerResource:GetPlayer(plyid)
	if PlayerResource:HasSelectedHero(plyid) == false then return end
	local tmp = plyhd:GetAssignedHero();
	if tmp~=nil then tmp:RemoveSelf() end
	if GameRules:State_Get() <= 5 then
		local tmp2=CreateHeroForPlayer(heroname, plyhd);
		plyhd:SetAssignedHeroEntity(tmp2);
		tmp2:RemoveSelf();
	else
		plyhd:SetAssignedHeroEntity(CreateHeroForPlayer(heroname, plyhd));
	end
	plyhd:SetSelectedHero(heroname)
end

function THD2_ForceClone()

	print('!!!')
	--if not G_IsFCloneMode then return end
	if (cur_jff ~= 2) then return end
	print('???')
	
	local H_table = {}
	
	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
			print(playerId)
			local team = PlayerResource:GetTeam(playerId)
			local hero = PlayerResource:GetSelectedHeroName(playerId)
			
			local val = 1
			if PlayerResource:IsFakeClient(playerId) then val = 99 end
			print(val)
			
			if H_table[team] == nil then H_table[team] = {} end
			if H_table[team][hero] == nil then H_table[team][hero] = 0 end
			H_table[team][hero] = H_table[team][hero] + val
			
		end
	end
	
	local H_result = {}

	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
			local team = PlayerResource:GetTeam(playerId)
			local hero = PlayerResource:GetSelectedHeroName(playerId)
			
			if H_result[team] == nil then
				H_result[team] = hero
			elseif H_table[team][H_result[team]] < H_table[team][hero] then
				H_result[team] = hero
			end
			
		end
	end
	
	for i=2, 3 do
		if team_hero[i] then
			H_result[i] = team_hero[i]
		else
			team_hero[i] = H_result[i]
		end
		if team_hero[i] == nil then
			local H_id = get_usable_bot_hero()
			team_hero[i] = G_Bot_Random_Hero[H_id]
			H_result[i] = team_hero[i]
			--G_BOT_USED[team_hero[H_id]] = true
		end
	end
	
	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
			local team = PlayerResource:GetTeam(playerId)
			local hero = PlayerResource:GetSelectedHeroName(playerId)
			
			if hero ~= H_result[team] then
				THD2_ForcePlayerRepick(playerId , H_result[team])
			end
			
		end
	end

end

function THD2_BotThinker()
	
	if THD2_GetBotMode() == true then
	    for k,v in pairs(G_Bot_List) do
	    	--if v == keys.player then
			-- just updata every bot is ok
    			local ply = PlayerResource:GetPlayer(v)
	    		local hero = ply:GetAssignedHero()
				THD2_BotUpGradeAbility(hero)
		 	--end
		end
	end
	
end

function THD2_BotSpecialInit(hero)
	--为部分技能和buff设定初始值
	local hName = hero:GetClassname()
	 --abilitys is 0~n-1, but vals set as 1~n
	if hName == "npc_dota_hero_pangolier" then
		local ability = hero:GetAbilityByIndex(6)
		if ability~=nil then
			print("SpecialAbilityInit:" .. ability:GetAbilityName())
			ability:SetLevel(1)
		else
			print("SpecialAbilityInit Error: flandrev2")
		end
		local mName = "modifier_ability_thdots_flandrev2_03_bloodfire"
		local modifier = hero:FindModifierByName(mName)
		if modifier ~= nil then
			print("SpecialModifierInit:" .. mName)
			local init_value = 0
			if cur_bot_dif > 2 then
				init_value = (cur_bot_dif-2) * 50 + 10
			end
			hero:SetModifierStackCount(mName, modifier, init_value)
		else
			print("SpecialModifierInit Error: flandrev2")
		end	
	end
end