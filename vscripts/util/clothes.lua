
Hero_Cloth = 
{
	["npc_dota_hero_visage"] =	--小爱
		{	
			"models/alice/alice.vmdl",
			"models/alice_cloth01/alice_cloth01.vmdl"
		},

	["npc_dota_hero_visage_size"] =	--对应尺寸
		{	
			1.2,
			1.2
		},

	["npc_dota_hero_obsidian_destroyer"] =	--紫
		{	
			"models/new_touhou_model/yukari/yukari.vmdl",
			"models/thd2/yukari/yukari_mmd.vmdl"
		},

	["npc_dota_hero_obsidian_destroyer_size"] =
		{	
			0.95,
			1.0
		},

	["npc_dota_hero_lina"] = --红白
		{	
			"models/new_touhou_model/reimu/reimu.vmdl",
			"models/heroes/troll_warlord/troll_warlord.vmdl"
		},

	["npc_dota_hero_lina_size"] =
		{	
			1.2,
			1.0
		},

	["npc_dota_hero_crystal_maiden"] = --黑白
		{	
			"models/new_touhou_model/marisa/marisa.vmdl",
			"models/thd2/marisa/marisa_mmd.vmdl"
		},

	["npc_dota_hero_crystal_maiden_size"] =
		{	
			1.15,
			0.95
		},

	["npc_dota_hero_juggernaut"] = --妖梦
		{	
			"models/new_touhou_model/youmu/youmu.vmdl",
			"models/thd2/youmu/youmu_mmd.vmdl"
		},

	["npc_dota_hero_juggernaut_size"] =
		{	
			1.2,
			1.0
		},

	["npc_dota_hero_slark"] = --文
		{	
			"models/new_touhou_model/aya/aya.vmdl",
		},

	["npc_dota_hero_slark_size"] =
		{	
			1.15,
		},

	["npc_dota_hero_earthshaker"] = --天子
		{	
			"models/new_touhou_model/tenshi/tenshi.vmdl",
			"models/thd2/tenshi/tenshi_mmd.vmdl"
		},

	["npc_dota_hero_earthshaker_size"] =
		{	
			1.2,
			1.0
		},

	["npc_dota_hero_templar_assassin"] = --16
		{	
			"models/new_touhou_model/sakuya/sakuya.vmdl",
			"models/thd2/sakuya/sakuya_mmd.vmdl"
		},

	["npc_dota_hero_templar_assassin_size"] =
		{	
			1.15,
			1.0
		},
	["npc_dota_hero_naga_siren"] = --二妹
		{	
			"models/thd2/flandre/flandre_mmd.vmdl",
			"models/flandre_scarlet_skin4/flandre_scarlet_skin4.vmdl",
			"models/flandre_scarlet_skin5/flandre_scarlet_skin5.vmdl",
			"models/flandrev2/flandrev2.vmdl",
			-- "models/flandre_scarlet_skin3/flandre_scarlet_skin3.vmdl",
			-- "models/flandre_scarlet/flandre_scarlet.vmdl",
		},

	["npc_dota_hero_naga_siren_size"] =
		{	
			0.9,
			1.3,
			1.3,
			1.25,
			-- 1.3,
			-- 1.0,
		},
	["npc_dota_hero_warlock"] = --大妹
		{	
			"models/remilia/remilia.vmdl",
			"models/thd2/remilia/remilia_mmd.vmdl"
		},

	["npc_dota_hero_warlock_size"] =
		{	
			1.2,
			1.0
		},
	["npc_dota_hero_life_stealer"] =
	     {
	     	"models/thd2/rumia/rumia_mmd.vmdl",
	     	"models/exrumia/exrumia.vmdl",
	     },
    ["npc_dota_hero_life_stealer_size"] =
        {
           1.0,
           1.3,
        },
	["npc_dota_hero_axe"] =
	     {
	     	"models/thd2/chiruno/chiruno_mmd.vmdl",
	     	"models/cirno2/cirno2.vmdl",
	     },
    ["npc_dota_hero_axe_size"] =
        {
           1.0,
           0.9,
        },
	["npc_dota_hero_centaur"] =
	     {
	     	"models/thd2/yuugi/yuugi_mmd.vmdl",
	     	"models/hoshiguma/hoshiguma.vmdl",
	     },
    ["npc_dota_hero_centaur_size"] =
        {
           0.8,
           1.25,
        },
}

function add_cloth( heroname, cloth_path, scale, cloth_id )
	if cloth_id == nil then
		if Hero_Cloth[heroname] == nil then
			Hero_Cloth[heroname] = {}
			cloth_id = 1
		else 
			for i=1,99 do
				if Hero_Cloth[heroname][i] == nil then
					cloth_id = i
					break
				end
			end
		end
	end
	
	if scale == nil then scale = 1.0 end
	Hero_Cloth[heroname][cloth_id] = cloth_path
	Hero_Cloth[heroname..'_size'][cloth_id] = scale
	
end

function update_cloth( G_Player_Cloth, plyid, cloth_id )
	local hero = PlayerResource:GetPlayer(plyid):GetAssignedHero()
	if Hero_Cloth[hero:GetClassname()] == nil then return end
	if Hero_Cloth[hero:GetClassname()][cloth_id] ~= nil then
		hero:SetModel(Hero_Cloth[hero:GetClassname()][cloth_id])
		hero:SetModelScale(Hero_Cloth[hero:GetClassname()..'_size'][cloth_id])
		hero:SetOriginalModel(Hero_Cloth[hero:GetClassname()][cloth_id])
		G_Player_Cloth[plyid + 1] = cloth_id
		return
	end
end

function ChangeModelExRumia( G_Player_Cloth, plyid )
	local hero = PlayerResource:GetPlayer(plyid):GetAssignedHero()
	if Hero_Cloth[hero:GetClassname()] == nil then return end
		hero:SetModel(Hero_Cloth[hero:GetClassname()][2])
		hero:SetModelScale(Hero_Cloth[hero:GetClassname()..'_size'][2])
		hero:SetOriginalModel(Hero_Cloth[hero:GetClassname()][2])
		G_Player_Cloth[plyid + 1] = 2
		return
	end

function ChangeModelFlandre( G_Player_Cloth, plyid )
	local hero = PlayerResource:GetPlayer(plyid):GetAssignedHero()
	if Hero_Cloth[hero:GetClassname()] == nil then return end
		hero:SetModel(Hero_Cloth[hero:GetClassname()][4])
		hero:SetOriginalModel(Hero_Cloth[hero:GetClassname()][4])
		hero:SetModelScale(Hero_Cloth[hero:GetClassname()..'_size'][4])
		G_Player_Cloth[plyid + 1] = 4
		return
end