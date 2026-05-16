$dir = "Z:\Source Code\FF14Hint\data\duties"

function Write-Duty {
    param([hashtable]$Data)
    $json = $Data | ConvertTo-Json -Depth 12
    $path = Join-Path $dir "$($Data.id).json"
    if (Test-Path $path) { Remove-Item -LiteralPath $path -Force }
    [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
}

# navel (Titan Normal)
Write-Duty @{
    id='navel'; name='大地之臍'; nameEn='The Navel'; expansion='2.x 重生之境 (A Realm Reborn)';
    type='trial'; playerCount=8; iLvlSync=$null; jobLevelSync=36; highEnd=$false; quality='excellent';
    mnemonic=@('1）Titan 泰坦：Geocrush 場地外緣崩塌，每次都會縮小。','2）Landslide 山崩前方直線擊退要靠中央站。','3）Heart 心臟召喚 → DPS 速殺，否則 Tumult 大傷害。');
    notes='ARR 2.0 MSQ trial (Lv 36)。Titan (泰坦) Normal。場地會逐漸縮小。';
    bosses=@(
        @{name='Titan 泰坦'; nameEn='Titan'; mnemonic=@('Geocrush 場地縮小','Landslide 直線擊退','Heart 心臟必殺');
          phases=@(@{name='主戰'; mechanics=@(
            @{name='Landslide 山崩'; type='knockback'; description='Titan 前方直線擊退攻擊。'; tips=@(@{text='MT 把 boss 朝向場邊';role='tank'},'站近中央避免被擊飛出去')},
            @{name='Weight of the Land 大地之重'; type='aoe'; description='場上多個圓形 AoE。'; tips=@('散開避免重疊')},
            @{name='Geocrush 大地崩裂'; type='other'; description='Titan 跳起，落地時場地外緣崩塌變紅環，多次後場地會大幅縮小。'; tips=@('注意縮小的場地邊緣')},
            @{name='Granite Gaol 花崗岩牢'; type='other'; description='隨機玩家被花崗岩囚禁，需打掉。'; tips=@(@{text='DPS 立刻打掉囚牢';role='dps'})},
            @{name='Heart of the Mountain 心臟'; type='other'; description='召喚心臟，未殺光會放 Tumult 全屏大傷害。'; tips=@(@{text='DPS 全力集火心臟';role='dps'})},
            @{name='Earthen Fury 大地之怒'; type='raidwide'; description='全屏 AoE，狂暴技。'; tips=@(@{text='減傷 + 補滿';role='healer'})}
          )})
        )
    )
}

# pharos_sirius_hard
Write-Duty @{
    id='pharos_sirius_hard'; name='天狼星燈塔（零式）'; nameEn='Pharos Sirius (Hard)'; expansion='3.x 蒼穹的禁城 (Heavensward)';
    type='dungeon'; playerCount=4; iLvlSync=$null; jobLevelSync=60; highEnd=$false; quality='excellent';
    mnemonic=@('1）B1 Hoary Boulder + Coultenet：雙坦各拉一隻。','2）B2 Olgoi-Khorkhoi 死亡蟲：場上電圓 + 中央電擊。','3）B3 Inferno 火主：直線火 + 站火環中。');
    notes='HW 3.1 dungeon Hard (Lv 60, ilvl 175)。Pharos Sirius 重製版。';
    bosses=@(
        @{name='Hoary Boulder + Coultenet 雙人組'; nameEn='Hoary Boulder + Coultenet'; mnemonic=@('雙坦 boss');
          phases=@(@{name='B1'; mechanics=@(
            @{name='Mighty Smash 重擊 + Strike 'em Down'; type='tankbuster'; description='Boulder 對 MT 物理 tankbuster；Coultenet 法系。'; tips=@(@{text='MT/OT 各坦一隻';role='tank'})},
            @{name='Magic Burst 法術爆破'; type='aoe'; description='Coultenet 場上多重圓 AoE。'; tips=@('閃預警')}
          )})},
        @{name='Olgoi-Khorkhoi 死亡蟲'; nameEn='Olgoi-Khorkhoi'; mnemonic=@('蒙古死亡蟲');
          phases=@(@{name='B2'; mechanics=@(
            @{name='Lightning Bolt 電擊'; type='aoe'; description='場上多重電擊 AoE。'; tips=@('閃預警')},
            @{name='Hydrothermal Vent 熱液孔'; type='aoe'; description='場上直線高熱 AoE。'; tips=@('閃直線')},
            @{name='Massive Burst 巨大爆發'; type='raidwide'; description='全屏 AoE。'; tips=@(@{text='減傷';role='healer'})}
          )})},
        @{name='Inferno 火主'; nameEn='Inferno'; mnemonic=@('火球 + 火環');
          phases=@(@{name='B3'; mechanics=@(
            @{name='Hellfire 地獄火'; type='aoe'; description='場上多重圓火 AoE。'; tips=@('跟預兆')},
            @{name='Searing Wind 灼風'; type='other'; description='玩家獲得 DoT debuff 需站到場邊「火環」中緩解。'; tips=@('被點名跑進火環內')},
            @{name='Cremate 焚化'; type='tankbuster'; description='Tankbuster。'; tips=@(@{text='MT 開減傷';role='tank'})},
            @{name='Crimson Cyclone 緋紅旋風'; type='raidwide'; description='全屏 AoE。'; tips=@(@{text='減傷';role='healer'})}
          )})}
    )
}

# saint_mociannes_arboretum (3.55)
Write-Duty @{
    id='saint_mociannes_arboretum'; name='聖莫西安植物園'; nameEn='Saint Mocianne''s Arboretum'; expansion='3.x 蒼穹的禁城 (Heavensward)';
    type='dungeon'; playerCount=4; iLvlSync=$null; jobLevelSync=60; highEnd=$false; quality='excellent';
    mnemonic=@('1）B1 Putrid Apsaras 腐敗女像：Sticky Mist 黏液區要閃。','2）B2 Tlatpetli 樹妖：Garden Stomp 場上圓 + 種子。','3）B3 Tlaloc 雨神：Geyser 水柱 + Stoneskin 需破護盾。');
    notes='HW 3.55 dungeon (Lv 60, ilvl 230)。聖莫西安植物園，3 個 boss。';
    bosses=@(
        @{name='Putrid Apsaras 腐敗女像'; nameEn='Putrid Apsaras'; mnemonic=@('黏液區');
          phases=@(@{name='B1'; mechanics=@(
            @{name='Sticky Mist 黏液霧'; type='aoe'; description='場上多重黏液 AoE 區，會給 Heavy debuff。'; tips=@('閃預警')},
            @{name='Bewildering Stench 迷亂惡臭'; type='raidwide'; description='全屏 AoE。'; tips=@(@{text='減傷';role='healer'})},
            @{name='Putrid Stench tankbuster'; type='tankbuster'; description='Tankbuster。'; tips=@(@{text='MT 開減傷';role='tank'})}
          )})},
        @{name='Tlatpetli 樹妖'; nameEn='Tlatpetli'; mnemonic=@('種子');
          phases=@(@{name='B2'; mechanics=@(
            @{name='Garden Stomp 庭園踩擊'; type='aoe'; description='場上多重圓 AoE。'; tips=@('閃預警')},
            @{name='Seedling Spore 種子'; type='other'; description='場上召喚種子小怪，未殺光會分裂。'; tips=@(@{text='DPS 速殺種子';role='dps'})},
            @{name='Rotten Stench 腐臭'; type='raidwide'; description='全屏。'; tips=@(@{text='減傷';role='healer'})}
          )})},
        @{name='Tlaloc 雨神'; nameEn='Tlaloc'; mnemonic=@('水柱 + 護盾');
          phases=@(@{name='B3'; mechanics=@(
            @{name='Geyser 噴泉'; type='aoe'; description='場上多重水柱 AoE。'; tips=@('閃預兆')},
            @{name='Stoneskin 石膚'; type='other'; description='boss 上盾，必須打破否則接著放大招。'; tips=@(@{text='DPS 全力打破護盾';role='dps'})},
            @{name='Aqua Burst 水爆'; type='raidwide'; description='全屏。'; tips=@(@{text='減傷';role='healer'})}
          )})}
    )
}
Write-Host 'Wrote navel, pharos_sirius_hard, saint_mociannes_arboretum'
