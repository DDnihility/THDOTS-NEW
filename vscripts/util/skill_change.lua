--更换英雄技能天赋

function THD_Change_skill(hero,plyhd)
    if GameRules:GetDOTATime(false, false) > 0 then
        Say(plyhd, "游戏开始后无法更换技能", true)
        return 
    end
    if hero.HasSkillChange ~= true then
        Say(plyhd, "该少女没有技能卡", true)
        return
    elseif hero.HasSkillChange == false then
        Say(plyhd, "该少女已经更换技能，无法再更换", true)
        return
    end
    --删除技能天赋
    for i=0,17 do 
        if hero:GetAbilityByIndex(i) and hero:GetAbilityByIndex(i) ~= "" then
            print(hero:GetAbilityByIndex(i):GetName())
            hero:RemoveAbilityByHandle(hero:GetAbilityByIndex(i))
        end
    end
    if hero:GetName() == "npc_dota_hero_juggernaut" then
        THD_Change_skill_youmu2(hero,plyhd)
    elseif hero:GetName() == "" then

    end
end

function THD_Change_skill_youmu2(hero,plyhd)
    if GameRules:GetDOTATime(false, false) > 0 then
        Say(plyhd, "*游戏开始后无法更换技能", true)
        return 
    end
    local gold = hero:GetGold()
    local exp = hero:GetCurrentXP()
    local hero = PlayerResource:ReplaceHeroWith(plyhd:GetPlayerID(), "npc_dota_hero_enchantress", gold, exp)
    -- print("hero.HasSkillChange")
    -- print(hero.HasSkillChange)
    -- if hero.HasSkillChange == true then
    --     Say(plyhd, "*该少女已经更换技能，无法再更换", true)
    --     return
    -- end
    -- --删除技能天赋
    -- for i=0,16 do 
    --     if hero:GetAbilityByIndex(i) and hero:GetAbilityByIndex(i) ~= "" then
    --         print(hero:GetAbilityByIndex(i):GetName())
    --         hero:RemoveAbilityByHandle(hero:GetAbilityByIndex(i))
    --     end
    -- end
    -- -- 删除被动技能
    -- hero:RemoveModifierByName("passive_youmu02_attack")
    -- local ability = nil
    -- hero:AddAbility("ability_thdots_youmu2_01")
    -- hero:AddAbility("ability_thdots_youmu2_02")
    -- hero:AddAbility("ability_thdots_youmu2_03")
    -- ability = hero:AddAbility("ability_thdots_youmu2_Ex")
    local ability = hero:FindAbilityByName("ability_thdots_youmu2_Ex")
    ability:SetLevel(1)
    -- ability = hero:AddAbility("ability_thdots_youmu2_05")
    ability = hero:FindAbilityByName("ability_thdots_youmu2_05")
    ability:SetLevel(1)
    -- hero:AddAbility("ability_thdots_youmu2_04")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("special_bonus_unique_youmu2_6")
    -- hero:AddAbility("special_bonus_unique_youmu2_7")
    -- hero:AddAbility("special_bonus_unique_youmu2_2")
    -- hero:AddAbility("special_bonus_unique_youmu2_1")
    -- hero:AddAbility("special_bonus_unique_youmu2_3")
    -- hero:AddAbility("special_bonus_unique_youmu2_8")
    -- hero:AddAbility("special_bonus_unique_youmu2_4")
    -- hero:AddAbility("special_bonus_unique_youmu2_5")
    -- hero.HasSkillChange = true
    GameRules:SendCustomMessage("<font color='#00FFFF'>魂魄妖梦更换了技能卡</font>", 0, 0)
end

function THD_Change_skill_exrumia(hero,plyhd)
    if GameRules:GetDOTATime(false, false) > 0 then
        Say(plyhd, "*游戏开始后无法更换技能", true)
        return 
    end
    local gold = hero:GetGold()
    local exp = hero:GetCurrentXP()
    local hero = PlayerResource:ReplaceHeroWith(plyhd:GetPlayerID(), "npc_dota_hero_skeleton_king", gold, exp)
    -- print("hero.HasSkillChange")
    -- print(hero.HasSkillChange)
    -- if hero.HasSkillChange == true then
    --     Say(plyhd, "*该少女已经更换技能，无法再更换", true)
    --     return
    -- end
    -- --删除技能天赋
    -- for i=0,16 do 
    --     if hero:GetAbilityByIndex(i) and hero:GetAbilityByIndex(i) ~= "" then
    --         print(hero:GetAbilityByIndex(i):GetName())
    --         hero:RemoveAbilityByHandle(hero:GetAbilityByIndex(i))
    --     end
    -- end
    -- -- 删除被动技能
    -- local ability = nil
    -- hero:AddAbility("ability_thdots_exrumia01")
    -- hero:AddAbility("ability_thdots_exrumia02")
    -- hero:AddAbility("ability_thdots_exrumia03")
    -- ability = hero:AddAbility("ability_thdots_exrumiaEx")
    local ability = hero:FindAbilityByName("ability_thdots_exrumiaEx")
    ability:SetLevel(1)  
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("ability_thdots_exrumia04")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("special_bonus_unique_exrumia_01")
    -- hero:AddAbility("special_bonus_unique_exrumia_02")
    -- hero:AddAbility("special_bonus_unique_exrumia_03")
    -- hero:AddAbility("special_bonus_unique_exrumia_04")
    -- hero:AddAbility("special_bonus_unique_exrumia_05")
    -- hero:AddAbility("special_bonus_unique_exrumia_06")
    -- hero:AddAbility("special_bonus_unique_exrumia_07")
    -- hero:AddAbility("special_bonus_unique_exrumia_08")
    -- hero.HasSkillChange = true
    GameRules:SendCustomMessage("<font color='#00FFFF'>露米娅更换了技能卡</font>", 0, 0)
end

function THD_Change_skill_flandre(hero,plyhd)
    if GameRules:GetDOTATime(false, false) > 0 then
        Say(plyhd, "*游戏开始后无法更换技能", true)
        return 
    end
    -- print("hero.HasSkillChange")
    -- print(hero:GetContext("flandre_changed_skill"))
    -- if hero.HasSkillChange == true then
    --     Say(plyhd, "*该少女已经更换技能，无法再更换", true)
    --     return
    -- end
    local gold = hero:GetGold()
    local exp = hero:GetCurrentXP()
    local hero = PlayerResource:ReplaceHeroWith(plyhd:GetPlayerID(), "npc_dota_hero_pangolier", gold, exp)
    --删除技能天赋
    -- for i=0,16 do 
    --     if hero:GetAbilityByIndex(i) and hero:GetAbilityByIndex(i) ~= "" then
    --         print(hero:GetAbilityByIndex(i):GetName())
    --         hero:RemoveAbilityByHandle(hero:GetAbilityByIndex(i))
    --     end
    -- end
    -- -- 删除被动技能
    -- local ability = nil
    -- hero:RemoveModifierByName("passive_flandreEx_damaged")
    -- hero:RemoveModifierByName("modifier_ability_thdots_flandre_Ex")
    -- hero:AddAbility("ability_thdots_flandrev2_01")
    -- hero:AddAbility("ability_thdots_flandrev2_02")
    -- ability = hero:AddAbility("ability_thdots_flandrev2_wanbaochui")
    local ability = hero:FindAbilityByName("ability_thdots_flandrev2_wanbaochui")
    ability:SetLevel(1)  
    ability:SetHidden(true)
    -- hero:AddAbility("ability_thdots_flandrev2_04")
    -- hero:AddAbility("ability_thdots_flandrev2_05")
    -- hero:AddAbility("ability_thdots_flandrev2_06")
    -- ability = hero:AddAbility("ability_thdots_flandrev2_03")
    ability = hero:FindAbilityByName("ability_thdots_flandrev2_03")
    ability:SetLevel(1)  
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("special_bonus_unique_flandrev2_01")
    -- hero:AddAbility("special_bonus_unique_flandrev2_02")
    -- hero:AddAbility("special_bonus_unique_flandrev2_03")
    -- hero:AddAbility("special_bonus_unique_flandrev2_04")
    -- hero:AddAbility("special_bonus_unique_flandrev2_05")
    -- hero:AddAbility("special_bonus_unique_flandrev2_06")
    -- hero:AddAbility("special_bonus_unique_flandrev2_07")
    -- hero:AddAbility("special_bonus_unique_flandrev2_08")
    -- hero.HasSkillChange = true
    GameRules:SendCustomMessage("<font color='#00FFFF'>芙兰朵露更换了技能卡</font>", 0, 0)
end

function THD_Change_skill_miko(hero,plyhd)
    if GameRules:GetDOTATime(false, false) > 0 then
        Say(plyhd, "*游戏开始后无法更换技能", true)
        return 
    end
    local gold = hero:GetGold()
    local exp = hero:GetCurrentXP()
    local hero = PlayerResource:ReplaceHeroWith(plyhd:GetPlayerID(), "npc_dota_hero_marci", gold, exp)
    -- print("hero.HasSkillChange")
    -- print(hero.HasSkillChange)
    -- if hero.HasSkillChange == true then
    --     Say(plyhd, "*该少女已经更换技能，无法再更换", true)
    --     return
    -- end
    -- --删除技能天赋
    -- for i=0,16 do 
    --     if hero:GetAbilityByIndex(i) and hero:GetAbilityByIndex(i) ~= "" then
    --         print(hero:GetAbilityByIndex(i):GetName())
    --         hero:RemoveAbilityByHandle(hero:GetAbilityByIndex(i))
    --     end
    -- end
    -- -- 删除被动技能
    -- local ability = nil
    -- hero:RemoveModifierByName("modifier_ability_mikoEx_vision")
    -- hero:RemoveModifierByName("modifier_ability_miko03_passiv")
    -- hero:RemoveModifierByName("modifier_miko_telent")
    -- hero:AddAbility("ability_thdots_miko2_1")
    -- hero:AddAbility("ability_thdots_miko2_2")
    -- hero:AddAbility("ability_thdots_miko2_3")
    -- ability = hero:AddAbility("ability_thdots_miko2_Ex")
    local ability = hero:FindAbilityByName("ability_thdots_miko2_Ex")
    ability:SetLevel(1)  
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("ability_thdots_miko2_4")
    -- hero:AddAbility("generic_hidden")
    -- hero:AddAbility("special_bonus_unique_miko2_1")
    -- hero:AddAbility("special_bonus_unique_miko2_2")
    -- hero:AddAbility("special_bonus_unique_miko2_3")
    -- hero:AddAbility("special_bonus_unique_miko2_4")
    -- hero:AddAbility("special_bonus_unique_miko2_5")
    -- hero:AddAbility("special_bonus_unique_miko2_6")
    -- hero:AddAbility("special_bonus_unique_miko2_7")
    -- hero:AddAbility("special_bonus_unique_miko2_8")
    -- hero:SetBaseHealthRegen(0)
    -- hero:SetBaseMoveSpeed(315)
    -- hero.HasSkillChange = true
    GameRules:SendCustomMessage("<font color='#00FFFF'>丰聪耳神子更换了技能卡</font>", 0, 0)
end