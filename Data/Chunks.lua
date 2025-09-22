local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))

local kmanVolume = 1
local routeMusicVolume = kmanVolume

local uid = require(game:GetService('ServerStorage').Utilities).uid

local encounterLists = {}
local function EncounterList(list)
	local isMetadata = false
	-- check a random key, if it is not a number then this is metadata
	for i in pairs(list) do if type(i) ~= 'number' then isMetadata = true end break end
	if isMetadata then
		return function(actualList)
			local eld = EncounterList(actualList)
			local t = encounterLists[eld.id]
			for k, v in pairs(list) do
				t[k] = v
			end
			return eld
		end
	end
	-- modify lists here (e.g. for a new version of October2k16's Haunter event)
	local function modList(list)
		local totalWeightD = 0
		local totalWeightN = 0
		local minLevel = 100
		local maxLevel = 1
		for _, encounter in pairs(list) do
			local w = encounter[4] * 20
			encounter[4] = w
			if encounter[5] ~= 'night' then totalWeightD = totalWeightD + w end
			if encounter[5] ~= 'day'   then totalWeightN = totalWeightN + w end
			minLevel = math.min(minLevel, encounter[2])
			maxLevel = math.max(maxLevel, encounter[3])
		end
		local totalWeight = (totalWeightD+totalWeightN)/2
		if totalWeight == 0 then return end
	end
	modList(list)  --Halloween 2022 ]]--

	local id = uid()--#encounterLists + 1 -- prefer uid, because it prevents guessing and makes every server unique
	while encounterLists[id] do id = uid() end
	encounterLists[id] = {id = id, list = list}
	local levelDistributionDay   = {}
	local levelDistributionNight = {}
	for _, entry in pairs(list) do
		-- day
		if entry[5] ~= 'night' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionDay  [level] = (levelDistributionDay  [level] or 0) + chancePerLevel
			end
		end
		-- night
		if entry[5] ~= 'day' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionNight[level] = (levelDistributionNight[level] or 0) + chancePerLevel
			end
		end
	end
	local function convert(t)
		local new = {}
		for level, chance in pairs(t) do
			new[#new+1] = {level, chance}
		end
		return new
	end
	return {
		id = id,
		ld = {convert(levelDistributionDay),
			convert(levelDistributionNight)}
	}
end

local function ConstantLevelList(list, level)
	for _, entry in pairs(list) do
		entry[5] = entry[3] -- [5] day / night
		entry[4] = entry[2] -- [4] chance
		entry[2] = level    -- [2] min level
		entry[3] = level    -- [3] max level
	end
	return EncounterList(list)
end

local function OldRodList(list)
	local ed = ConstantLevelList(list, 10)
	encounterLists[ed.id].rod = 'old'
	return ed
end

local function GoodRodList(list)
	local ed = ConstantLevelList(list, 20)
	encounterLists[ed.id].rod = 'good'
	return ed
end

local ruinsEncounter = EncounterList {
	{'Baltoy',   29, 32, 25, nil, nil, nil, 'lightclay', 20},
	{'Natu',     29, 32, 20},
	{'Elgyem',   29, 32, 20},
	{'Sigilyph', 29, 32, 10},
	{'Ekans',    29, 32,  8},
	{'Darumaka', 29, 32,  4},
	{'Zorua',    29, 32,  2},
}

local chunks = {
	["chunk0"] = {
		canFly = false,
		noHover = true,
		blackOutTo = 'chunk1',
		buildings = {},
		regions = {
			['Intro'] = {
				NoSign = true,
			}    
		}
	},
	['chunk1'] = {
		buildings = {
			'Gate1',
		},
		regions = {
			['Mitis Town'] = {
				SignColor = BrickColor.new('Bronze').Color,
				Music = {17802917042, 17802920528},
				MusicVolume = kmanVolume,
				OldRod = OldRodList {
					{'Magikarp', 100},
				},
				GoodRod = GoodRodList {
					{'Magikarp', 80},
					{'Gyarados', 5},
				}
			},
			['Route 1'] = {
				Music = 17685037986,
				MusicVolume = kmanVolume,
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
					{'Sentret',    2, 4,  5, 'day'},
				},
			},
		},
	},
	['chunk2'] = {
		buildings = {
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Camper',
						cframe = CFrame.new(10, 0, 0),
						interact = { 'See that girl over there behind the counter?', 'She heals your pokemon.' }
					},
				},
			},
			'Gate1',
			'Gate2',
			['SawsbuckCoffee'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Cheshma Town'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = 123055564980400,
				MusicVolume = kmanVolume,
			},
			['Gale Forest'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = {99934707185055, 92070774093587},
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Weedle',     3, 5, 20},
					{'Caterpie',   3, 5, 20},
					{'Metapod',    5, 6, 10},
					{'Kakuna',     5, 6, 10},
					{'Nidoran[F]', 3, 5, 10},
					{'Nidoran[M]', 3, 5, 10},
					{'Blipbug',    5, 6, 10},
					{'Ledyba',     3, 5, 15, 'day'},
					{'Spinarak',   3, 5, 15, 'night'},
					{'Hoothoot',   4, 6, 10, 'night'},
					{'Nickit',     4, 6,  5, 'night'},
					{'Pikachu',    4, 6,  3, 'day', nil, nil, 'lightball', 20},
					--{'Mimikyu',    4, 6,  3, 'night', nil, nil, 'chestoberry', 20}, -- Halloween 2022
				},
			},
			['Route 2'] = {
				RTDDisabled = true,
				Music = 17685044396,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Pidgey',     23, 25, 10},
					{'Fletchling', 23, 25, 10},
					{'Greedent', 23, 25, 10},
					{'Dubwool', 23, 25, 10},
					{'Zigzagoon',   23, 25,  8, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Plusle',     23, 25,  2, nil, nil, nil, 'cellbattery', 20},
					{'Minun',      23, 25,  2, nil, nil, nil, 'cellbattery', 20},
				},
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Barboach', 50},
				},
				GoodRod = GoodRodList {
					{'Barboach',20},
					{'Magikarp',15},
					{'Gyarados',10},
					{'Whiscash',5},
				},
				Surf = EncounterList {
					{'Goldeen', 13,18,10, nil, nil, nil, 'mysticwater', 20},
					{'Magikarp',13,18,7},
					{'Barboach',13,18,7},
					{'Lotad',13,18,3, nil, nil, nil, 'mentalherb', 20},
				}
			},
		},
	},
	['chunk3'] = {
		buildings = {
			['Gym1'] = {
				Music = {83292387109762, 126706677495787},
				noPCBox = true,
				BattleSceneType = 'Gym1',
			},
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Rich Boy',
						cframe = CFrame.new(-23, 0, 8) * CFrame.Angles(0, -math.pi/3, 0),
						interact = { 'This PC has been acting awfully strange lately.', 'I think it needs an upgrade...' }
					},
				},
			},
			'Gate2',
			'Gate3',
		},
		regions = {
			['Route 3'] = {
				BlackOutTo = 'chunk2',
				Music = 17685044396,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Poochyena', 5, 7, 20},
					{'Shinx',     5, 7, 20},
					{'Electrike', 5, 7, 20},
					{'Mareep',    5, 7, 20},
					{'Nincada',   5, 7, 10, nil, nil, nil, 'softsand', 20},
					{'Abra',      5, 7, 10, nil, nil, nil, 'twistedspoon', 20},
					{'Yamper', 5, 7,  5},
					{'Pachirisu', 6, 8,  4},
				}
			},
			['Silvent City'] = {
				Music = {102566656494471, 100802762559068},
				SignColor = BrickColor.new('Bright yellow').Color,
				PCEncounter = EncounterList {PDEvent = 'PCPorygonEncountered'} {{'Porygon', 5, 5, 1}}
			},
			['Route 4'] = {
				RTDDisabled = true,
				Music = 17685044396,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Pidgey', 7,  9, 25},
					{'Shinx',  7,  9, 20},
					{'Mareep', 7,  9, 20},
					{'Stunky', 7,  9, 15},
					{'Yamper', 7, 9,  10},
					{'Skiddo', 7, 10, 10},
					{'Marill', 7, 10, 10},
				}
			},
		},
	},
	['chunk4'] = {
		blackOutTo = 'chunk3',
		buildings = {
			'Gate3',
			'Gate4',
		},
		regions = {
			['Route 5'] = {
				RTDDisabled = true,
				Music = 17685082102,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Rellor',     8, 10, 25},
					{'Patrat',     8, 10, 25},
					{'Phanpy',     8, 10, 20},
					{'Blitzle',    8, 10, 20},
					{'Lechonk',     8, 10, 20},
					{'Litleo',     8, 10, 20},
					{'Rolycoly',   8, 10, 20},
					{'Hippopotas', 8, 10, 15},
					{'Girafarig',  9, 11,  5},

				}
			},
			['Old Graveyard'] = {
				Music = 18963395570,
				RTDDisabled = true,
				SignColor = Color3.new(.5, .5, .5),
				BattleScene = 'Graveyard',
				GrassEncounterChance = 9,
				Grass = EncounterList {
					{'Cubone',  8, 10, 40, nil, nil, nil, 'thickclub', 20},
					{'Gothita', 8, 10, 15},
					{'Impidimp', 8, 10, 15},
					{'Gastly',  8, 10, 30, 'night'},
					{'Murkrow', 8, 10, 20, 'night'},
					{'Yamask',  8, 10,  5, 'night', nil, nil, 'spelltag', 20},
				}
			},
		},
	},
	['chunk5'] = {
		buildings = {
			'Gate4', 'Gate5', 'Gate6',
			'PokeCenter',
			['Gym2'] = {
				Music = 95337149605028,
				noPCBox = true,
				BattleSceneType = 'Gym2',
			},
		},
		regions = {
			['Brimber City'] = {
				Music = 112839496460501,
				SignColor = BrickColor.new('Crimson').Color,
				BattleScene = 'Safari', -- for Santa, if nothing else
			}
		},
	},
	['chunk6'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate5',
		},
		regions = {
			['Route 6'] = {
				Music = 17685082102,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Litleo',     11, 13, 20},
					{'Blitzle',    11, 13, 20},
					{'Sizzlipede', 11, 13, 20, 'day'},
					{'Ponyta',     11, 13, 15},
					{'Rolycoly',   11, 13, 15},
					{'Rhyhorn',    11, 13, 10},
					{'Zubat',      11, 13, 30, 'night'},
				},
				Anthill = EncounterList {Locked = true} {{'Durant', 5, 8, 1}}
			}
		}
	},
	['chunk7'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Mt. Igneus'] = {
				Music = 103393691324351,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   12, 15, 20},
					{'Sizzlipede', 12, 15, 20},
					{'Slugma',  12, 15, 20},
					{'Torkoal', 12, 15, 17, nil, false, nil, 'charcoal', 20},
					{'Magby',   12, 15,  8, nil, false, nil, 'magmarizer', 20},
					{'Heatmor', 12, 15,  5},
					{'Zubat',   12, 15, 30, 'day'},
				},
				LavaBeast = EncounterList
				{PDEvent = 'Groudon'}
				{{'Groudon', 40, 40, 1}}
			}
		}
	},
	['chunk8'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate6',
			'Gate7',
			['SawMill'] = {
				BattleSceneType = 'SawMill',
			},
		},
		regions = {
			['Route 7'] = {
				Music = 96613691475712,
				MusicVolume = .575,
				RTDDisabled = true,
				Grass = EncounterList {
					{'Bidoof',  15, 17, 20},
					{'Poliwag', 15, 17, 15},
					{'Marill',  15, 17, 15},
					{'Wooper',  15, 17, 15},
					{'Sunkern', 15, 17, 12},
					{'Gossifleur', 15, 17, 10},
					{'Surskit', 15, 17, 10, nil, false, nil, 'honey', 2},
					{'Skitty',  15, 17, 8},
					{'Yanma',   15, 17, 8, nil, false, nil, 'widelens', 20},
					{'Hatenna', 16, 18, 7},
					{'Ralts',   16, 18, 5},
				},
				OldRod = OldRodList {
					{'Magikarp', 40},
					{'Tympole',  20},
					{'Corphish', 5},
				},
				GoodRod = GoodRodList {
					{'Tympole',20},
					{'Corphish', 14},
					{'Magikarp',6},
					{'Wishiwashi',2},
				},
				Surf = EncounterList {
					{'Bidoof',26,29,10},
					{'Tympole',26,29,7},
					{'Corphish',26,29,5},
					{'Mareanie',28,31,1}
				}
			}
		}
	},
	['chunk9'] = {
		buildings = {
			'Gate7',
			'Gate8',
			'PokeCenter',
		},
		regions = {
			['Lagoona Lake'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = {99177295636102, 72627677539436},
				-- Regular rod fishing (unchanged)
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Goldeen', 10, nil,nil,nil, nil, nil, 'mysticwater', 20},
				},
				GoodRod = GoodRodList {
					{'Goldeen',20, nil,nil,nil, nil, nil, 'mysticwater', 20},
				},
				-- Fishing spot encounters (uses OldRod encounters)
				FishingSpots = OldRodList {
					{'Charizard', 50},
					{'Charizard', 10, nil,nil,nil, nil, nil, 'mysticwater', 20},
				},
				Surf = EncounterList
				{Weather = 'primordialsea'}
				{
					{'Goldeen', 26,30,10, nil, false, nil, 'mysticwater', 20},
					{'Gyarados', 26,30,3},
					{'Veluza', 26,30,3},
					{'Finizen', 26,30,3, 'night'},
					{'Ducklett', 26,30,1},
					{'Lumineon', 28,32,5, 'night'}
				}
			},
		},
	},
	['chunk10'] = {
		blackOutTo = 'chunk9',
		buildings = {
			'Gate8',
			'Gate9',
		},
		regions = {
			['Route 8'] = {
				RTDDisabled = true,
				Music = 11967711829,
				Grass = EncounterList {
					{'Oddish',     13, 16, 40, nil, false, nil, 'absorbbulb', 20},
					{'Bellsprout', 13, 16, 40},
					{'Falinks',    13, 16, 35},
					{'Starly',     13, 16, 35},
					{'Lillipup',   13, 16, 35},
					{'Espurr',     13, 16, 25},
					{'Swablu',     13, 16, 20},
					{'Staravia',   14, 16, 15},
					{'Herdier',    14, 16, 15},
					{'Clobbopus',  14, 16, 12},
					{'Buneary',      15, 18,  4},
					{'Riolu',      15, 18,  4},
				},
				Well = EncounterList
				{Verify = function(PlayerData) return PlayerData:incrementBagItem('oddkeystone', -1) end}
				{{'Spiritomb', 15, 15, 1}}
			},
		},
	},
	['chunk11'] = {
		buildings = {
			'Gate9',
			'Gate10',
			'PokeCenter',
			['Gym3'] = {
				Music = 110721268146576,
				noPCBox = true,
				BattleSceneType = 'Gym3',
			},
		},
		regions = {
			['Rosecove City'] = {
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 79272827435027,
				BattleScene = 'Beach', -- for Santa, if nothing else
			},
			['Rosecove Beach'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 118146866855304,
				MusicVolume = 0.4,
				BattleScene = 'Beach',
				RodScene = 'Beach',
				RTDDisabled = true,
				Grass = EncounterList {
					{'Shellos',  15, 17, 20},
					{'Chewtle',  15, 17, 20},
					{'Slowpoke', 15, 17, 15, nil, false, nil, 'laggingtail', 20},
					{'Wingull',  15, 17, 10, nil, false, nil, 'prettywing', 2},
					{'Psyduck',  15, 17, 10},
					{'Abra',     15, 17,  2, 'night', false, nil, 'psychicgem', 1},
				},
				OldRod = OldRodList {
					{'Tentacool', 4, nil, nil, nil, false, nil, 'poisonbarb', 20},
					{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacool', 5, nil, nil, nil, false, nil, 'poisonbarb', 20},
					{'Finneon',   4},
					{'Tentacruel',1, nil, nil, nil, false, nil, 'poisonbarb', 20},
				},
				PalmTree = EncounterList {Locked = true} {
					{'Exeggcute', 15, 17, 4, nil, false, nil, 'psychicseed', 2},
					{'Aipom',     15, 17, 1},
				},
				MiscEncounter = EncounterList {Locked = true} {
					{'Krabby', 15, 17, 3},
					{'Staryu', 15, 17, 2, nil, false, nil, 'starpiece', 20, 'stardust', 2},
					{'Crabrawler', 15, 17, 1, 'day', false, nil, 'luckypunch'},
				},
				Surf = EncounterList { 
					{'Tentacool', 27, 32, 5, nil, false, nil, 'poisonbarb', 20},
					{'Finneon', 27, 32, 4},
					{'Lumineon', 27, 32, 2},
					{'Alomomola', 27, 32, 1}
				}
			}
		}
	},
	['chunk12'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate10',
			['Gate11'] = {
				Music = 112833503941075,
			},
			'Gate12',
			'Gate13',
		},
		regions = {
			['Route 9'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 83609335529564,
				MusicVolume = 0.7,
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Sewaddle',  22, 25, 30, nil, false, nil, 'mentalherb', 20},
					{'Venipede',  22, 25, 25, nil, false, nil, 'poisonbarb', 20},
					{'Shroomish', 22, 25,  2, nil, false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Paras',     22, 25, 35, 'day', false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Roselia',   22, 25,  5, 'day'},
					{'Flapple',   21, 24,  1, 'day'},
					{'Kricketot', 22, 25, 35, 'night'},
					{'Venonat',   22, 25,  5, 'night'},
				},
				PineTree = EncounterList {Locked = true} {
					{'Pineco',    22, 25, 30},
					{'Spewpa',    22, 25, 20},
					{'Kakuna',    22, 25, 10},
					{'Metapod',   22, 25, 10},
					{'Heracross', 23, 26,  2, 'night'},
					{'Pinsir',    23, 26,  2, 'day'},
				}
			}
		}
	},
	['chunk13'] = {
		blackOutTo = 'chunk11',
		lighting = {
			FogColor = Color3.fromHSV(5/6, .2, .5),
			FogStart = 45,
			FogEnd = 200,
		},
		buildings = {
			['Gate11'] = {
				Music = 112833503941075,
			},
			['HMFoyer'] = {
				BattleSceneType = 'HauntedMansion',
				Music = 10840805329,
			},
			['HMStub1'] = { DoorViewAngle = 10 },
			['HMStub2'] = { DoorViewAngle = 10 },
			['HMAttic'] = {
				BattleSceneType = 'HauntedMansion',
				Music = 10840805329,
			},
			['HMBabyRoom'] = {BattleSceneType = 'HauntedMansion'},
			['HMBadBedroom'] = {BattleSceneType = 'HauntedMansion'},
			['HMBathroom'] = {BattleSceneType = 'HauntedMansion'},
			['HMBedroom'] = {BattleSceneType = 'HauntedMansion'},
			['HMDiningRoom'] = {BattleSceneType = 'HauntedMansion'},
			['HMLibrary'] = {BattleSceneType = 'HauntedMansion'},
			['HMMotherLounge'] = {BattleSceneType = 'HauntedMansion'},
			['HMMusicRoom'] = {BattleSceneType = 'HauntedMansion'},
			['HMUpperHall'] = {BattleSceneType = 'HauntedMansion'},
		},
		regions = {
			['Fortulose Manor'] = {
				SignColor = BrickColor.new('Mulberry').Color,
				Music = {112808358853895, 114159602061925},
				Grass = EncounterList {
					{'Phantump',  20, 22, 30},
					{'Pumpkaboo', 20, 22, 30, nil, nil, nil, 'miracleseed', 1},
					{'Golett',    21, 23,  4, nil, nil, nil, 'lightclay', 20},
					{'Sableye',   24, 27,  1},
					{'Dreepy',    21, 22,  1},
				},
				OldRod = OldRodList {
					{'Magikarp', 18},
					{'Feebas',    1},
				},
				GoodRod = GoodRodList {
					{'Magikarp',35},
					{'Feebas',15},
					{'Corsola',3, nil, nil, 'Galar'},
				},
				InsideEnc = EncounterList {
					{'Rattata',    20, 22, 30, nil, nil, nil, 'chilanberry', 20},
					{'Shuppet',    20, 22, 20, nil, nil, nil, 'spelltag', 20},
					{'Duskull',    20, 22, 20, nil, nil, nil, 'spelltag', 20},
					{'Misdreavus', 20, 22,  8},
					{'Greavard', 20, 22,  8},
					{'Sinistea',    21, 22, 3, nil, false, nil, 'spelltag', 20},
					{'Honedge',    20, 22,  2},
					{'Dreepy',   23, 27,  1},
				},
				Candle = EncounterList {Locked = true} {{'Litwick', 20, 20, 1}},
				Gameboy = EncounterList {PDEvent = 'Rotom7'} {{'Rotom', 25, 25, 1}}
			}
		}
	},
	['chunk14'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate12',
		},
		regions = {
			['Grove of Dreams'] = {
				Music = 94706775362977,
				Grass = EncounterList {
					{'Venipede',  20, 22, 25, nil, false, nil, 'poisonbarb', 20},
					{'Mankey',    20, 22, 15},
					{'Snubbull',  20, 22, 10},
					{'Meowth',    20, 22,  9, nil, nil, 'Galar'},
					{'Chatot',    20, 22,  5, nil, false, nil, 'metronome', 20},
					{'Pancham',   21, 23,  2, nil, false, nil, 'mentalherb', 20},
					{'Minccino',  20, 22, 10, 'day'},
					{'Vivillon',  20, 22, 5, 'night'},
					{'Kricketot', 20, 22, 35, 'night', false, nil, 'metronome', 20},
					
				},
				OldRod = OldRodList {
					{'Magikarp', 49},
				},
				GoodRod = GoodRodList {
					{'Magikarp',98},
					{'Dratini',2, nil, nil, nil, nil, nil, 'dragonscale', 20},
				},
				Wish = EncounterList {PDEvent = 'Jirachi'} {{'Jirachi', 25, 25, 1, nil, nil, nil, 'starpiece', 1}},
				Sage = EncounterList {Locked = true} {{'Pansage', 25, 25, 1}},
				Sear = EncounterList {Locked = true} {{'Pansear', 25, 25, 1}},
				Pour = EncounterList {Locked = true} {{'Panpour', 25, 25, 1}}
			}
		}
	},
	['chunk15'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate13',
			['CableCars'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Route 10'] = {
				SignColor = BrickColor.new('Linen').Color,
				Music = 11968117770,
				MusicVolume = routeMusicVolume,
				BattleScene = 'Flowers',
				Grass = EncounterList {
					{'Hoppip',     20, 22, 30},
					{'Spoink',     20, 22, 25},
					{'Growlithe',  20, 22, 15},
					{'Chimecho',   20, 22, 10, nil, false, nil, 'cleansetag', 20},
					{'Pawniard',   20, 22,  8},
					{'Grubbin',    20, 22,  6},
					{'Helioptile', 20, 22,  4},
					{'Scyther',    21, 23,  2},
				},
				MiscEncounter = EncounterList {
					{'Floette',    20, 23, 30},
					{'Hoppip',     20, 23, 30},
					{'Spoink',     20, 23, 25},
					{'Petilil',    20, 23, 15, nil, nil, nil, 'absorbbulb', 20},
					{'Comfey',     20, 23, 10, nil, nil, nil, 'mistyseed', 20},
				},
				HoneyTree = EncounterList
				{GetPokemon = function(PlayerData)
					local foe = PlayerData.honey.foe
					PlayerData.honey = nil
					return foe
				end}
				{{'Teddiursa', 19, 23, 10}, {'Combee', 19, 23, 90, nil, nil, nil, 'honey', 20}},
				Windmill = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.DinWM then return false end
					PlayerData.flags.DinWM = nil
					PlayerData.lastDrifloonEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Drifloon', 22, 25, 1}}
			}
		}
	},
	['chunk16'] = {
		blackOutTo = 'chunk11',
		canFly = false,
		regions = {
			['Cragonos Mines'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 108267422641258,
				BattleScene = 'CragonosMines',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Nymble',     21, 24, 35, 'day'},
					{'Woobat',     21, 24, 35, 'day'},
					{'Geodude',    21, 24, 30, nil, false, nil, 'everstone', 20},
					{'Roggenrola', 21, 24, 30, nil, false, nil, 'hardstone', 20, 'everstone', 2},
					{'Meditite',   21, 24, 15},
					{'Diglett',    21, 24, 10, nil, false, nil, 'softsand', 20},
					{'Onix',       21, 24,  7},
					{'Drilbur',    22, 25,  3},
					{'Cufant',     22, 25,  3},
					{'Larvitar',   22, 25,  2},
				},
				RodScene = 'CragonosMines',
				OldRod = OldRodList {
					{'Magikarp', 20},
					{'Goldeen',  10,nil,nil, nil, false, nil, 'mysticwater', 20},
					{'Chinchou',  2,nil,nil, nil, false, nil, 'deepseascale', 20},
				},
				GoodRod = GoodRodList {
					{'Magikarp',20},
					{'Goldeen', 10,nil,nil, nil, false, nil, 'mysticwater', 20},
					{'Chinchou', 6,nil,nil, nil, false, nil, 'deepseascale', 20},
				},
				Surf = EncounterList {
					{'Goldeen',   22, 24,  5, nil, false, nil, 'mysticwater', 20},
					{'Magikarp',   22, 24,  3},
					{'Cramorant',   22, 24,  3},
					{'Tentacool',   22, 24,  2, nil, false, nil, 'poisonbarb', 20},
					{'Clauncher',   22, 24,  1},
				}
			}
		}
	},
	['chunk17'] = {
		buildings = {
			'PokeCenter',
		},
		regions = {
			['Cragonos Cliffs'] = {
				SignColor = BrickColor.new('Sand green').Color,
				Music = 11968127516,
				MusicVolume = routeMusicVolume,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					{'Woobat',    21, 24, 30, 'night'},
					{'Spearow',   21, 24, 30, nil, nil, nil, 'sharpbeak', 20},
					{'Pidgeotto', 21, 24, 20},
					{'Skiddo',    21, 24, 20},
					{'Vullaby',   21, 24, 10},
					{'Oricorio',   21, 24,  8},
					{'Gligar',    21, 24,  5},
					{'Bagon',     21, 24,  1, nil, false, nil, 'dragonfang', 20},
				},
				Grace = EncounterList
				{Verify = function(PlayerData)
					return PlayerData:getBagDataById('gracidea', 5) and true or false
				end, PDEvent = 'Shaymin'}
				{{'Shaymin', 30, 30, 1, 'lumberry', 1}}
			}
		}
	},
	['chunk18'] = {
		blackOutTo = 'chunk17',
		regions = {
			['Cragonos Peak'] = {
				SignColor = Color3.new(1, 1, 1),
				Music = 86463398824110,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					{'Skiddo',   22, 25, 30},
					{'Dubwool',  22, 25, 30, 'day'},
					{'Doduo',    22, 25, 30, nil, false, nil, 'sharpbeak', 20},
					{'Spearow',  22, 25, 30, nil, false, nil, 'sharpbeak', 20},
					{'Inkay',    22, 25, 10},
					{'Stantler', 23, 26,  6},
					{'Rufflet',  22, 26,  2},
				}
			}
		}
	},
	['chunk19'] = {
		blackOutTo = 'chunk21',
		regions = {
			['Anthian City - Housing District'] = {
				SignColor = BrickColor.new('Steel blue').Color,
				Music = 18955893698,
				Dumpster = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.TinD then return false end
					PlayerData.flags.TinD = nil
					PlayerData.lastTrubbishEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Trubbish', 22, 25, 1, nil, nil, nil, 'silkscarf', 20}}
			}
		}
	},
	['Arcade'] = {
		canFly = false,
		blackOutTo = 'chunk17',
		lighting = {
			Ambient = Color3.fromRGB(255, 12, 190),
			OutdoorAmbient = Color3.fromRGB(255, 12, 190),
		},
		regions = {
			['Golden Pokeball - Arcade'] = {
				NoSign = true,
				Music = 18955962784,
			}
		}
	},
	['chunk20'] = {
		blackOutTo = 'chunk21',
		buildings = {
			['PokeBallShop'] = {
				DoorViewAngle = 25
			},
			['LudiLoco'] = {
				Music = 18955947881,
				DoorViewAngle = 20
			},
			['LottoShop'] = {
				DoorViewAngle = 25
			},
			['C_chunk23'] = {
				DoorViewAngle = 60,
				DoorViewZoom = 15
			}
		},
		regions = {
			['Anthian City - Shopping District'] = {
				SignColor = BrickColor.new('Fossil').Color,
				Music = {18955858634, 18955875280},
				MusicVolume = .7,

			}
		}
	},
	['chunk21'] = {
		buildings = {
			['Gym4'] = {
				Music = 17802716367,
				noPCBox = true,
				BattleSceneType = 'Gym4',
				DoorViewZoom = 35,
			},
			'PokeCenter'
		},
		regions = {
			['Anthian City - Battle District'] = {
				SignColor = BrickColor.new('Crimson').Color,
				Music = 18955887370,

			}
		}
	},
	['chunk22'] = {
		blackOutTo = 'chunk21',
		buildings = {
			['PowerPlant'] = {DoorViewAngle = 20},
			
		},
		regions = {
			['Anthian City - Park District'] = {
				SignColor = BrickColor.new('Bright green').Color,
				Music = 18955843950,
				BattleScene = 'Sewer',
				
			}
			
		}
	},
	['chunk23'] = {
		blackOutTo = 'chunk21',
		canFly = false,
		noHover = true,
		buildings = {
			['C_chunk20'] = {
				DoorViewZoom = 14,
			},
			['C_chunk22'] = {
				DoorViewAngle = 30,
				DoorViewZoom = 14,
			},
			['C_chunk23'] = {
				DoorViewAngle = 30,
				DoorViewZoom = 14,
			},
			['EnergyCore'] = {
				DoorViewAngle = 20,
				DoorViewZoom = 12,
				BattleSceneType = 'CoreRoom',
			}
		},
		lighting = {
			Ambient = Color3.fromRGB(145, 145, 145),
			OutdoorAmbient = Color3.fromRGB(108, 108, 108),
		},
		regions = {
			['Anthian Sewer'] = {
				SignColor = BrickColor.new('Slime green').Color,
				Music = 11977716258,
				BattleScene = 'Sewer',
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Voltorb',      27, 30, 25},
					{'Magnemite',    27, 30, 25},
					{'Klink',        27, 30, 20},
					{'Koffing',      27, 30, 10, nil, false, nil, 'smokeball', 20},
					{'Grimer',       27, 30, 10, nil, false, nil, 'blacksludge', 20},
					{'Elekid',       28, 29,  2, nil, false, nil, 'electirizer', 20},
				},
				Metal = EncounterList
				{PDEvent = 'Meltan'}
				{{'Meltan', 20, 20, 1}}
			}
		}
	},
	['chunk24'] = {
		blackOutTo = 'chunk21',
		buildings = {
			['CableCars'] = {DoorViewAngle = 15},
			'Gate14',
		},
		lighting = {
			FogColor = Color3.fromRGB(216, 194, 114),
			FogEnd = 200,
			FogStart = 40,
		},
		regions = {
			['Route 11'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 17802824938,
				BattleScene = 'Desert',
				Grass = EncounterList
				{Weather = 'sandstorm'}
				{
					{'Cacnea',    28, 31, 20, nil, false, nil, 'stickybarb', 20},
					{'Stonjourner', 28, 31, 20, 'night'},
					{'Trapinch',  28, 31, 20, nil, false, nil, 'softsand', 20},
					{'Hippowdon', 28, 31, 15},
					{'Silicobra', 28, 31, 12},
					{'Sandslash', 28, 31, 10, nil, false, nil, 'gripclaw', 20},
					{'Krokorok',  28, 31,  8, nil, false, nil, 'blackglasses', 20},
					{'Maractus',  28, 31,  3, nil, false, nil, 'miracleseed', 20},
				}
			}
		}
	},
	['chunk25'] = {
		buildings = {
			'Gate14',
			'Gate15',
			'Gate16',
			['PokeCenter'] = {DoorViewAngle = 25},
			['House4'] = {DoorViewAngle = 25},
			['Palace'] = {Music = {11977724609, 11977731995}, noPCBox = true} 
		},
		regions = {
			['Aredia City'] = {
				SignColor = BrickColor.new('Flint').Color,
				Music = {17802888868, 109178126213566},
				BattleScene = 'Aredia',
				Snore = EncounterList
				{Verify = function(PlayerData)
					return PlayerData:hasFlute()
				end, PDEvent = 'Snorlax'}
				{{'Snorlax', 30, 30, 1, nil, nil, nil, 'leftovers', 1}}
			}
		}
	},
	['chunk26'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Glistening Grotto'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 136557554771773,
				MusicVolume = .45,
				BattleScene = 'CrystalCave',
				RodScene = 'CrystalCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Zubat',   25, 30, 25, 'day'},
					{'Bronzor', 25, 30, 25},
					{'Boldore', 25, 30, 20, nil, nil, nil, 'hardstone', 20, 'everstone', 2},
					{'Carbink', 25, 30, 15},
					{'Elgyem',  25, 30, 10},
					{'Toxel',  25, 30,   6, nil, nil, nil, 'blacksludge', 50},
					{'Mawile',  25, 30,  5, nil, nil, nil, 'ironball', 20},
					{'Sableye', 25, 30,  5, nil, nil, nil, 'widelens', 20},
					{'Aron',    25, 30,  3, nil, nil, nil, 'hardstone', 20},
				},
				OldRod = OldRodList {
					{'Goldeen',  30,nil,nil, nil, nil, nil, 'mysticwater', 20},
					{'Shellder', 15,nil,nil, nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
				},
				GoodRod = GoodRodList {
					{'Goldeen',20, nil, nil, nil, nil, nil, 'mysticwater', 20},
					{'Shellder',13, nil, nil, nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
					{'Relicanth', 1, nil, nil, nil, nil, nil, 'deepseascale', 20},
				}
			}
		}
	},
	['chunk27'] = {
		blackOutTo = 'chunk25',
		buildings = {
			'Gate15'
		},
		regions = {
			['Old Aredia'] = {
				SignColor = BrickColor.new('Cashmere').Color,
				Music = 11979752860,
				BattleScene = 'Desert',
				Grass = EncounterList {
					{'Hippowdon', 29, 32, 25},
					{'Cacnea',    29, 32, 20, nil, false, nil, 'stickybarb', 20},
					{'Trapinch',  29, 32, 20, nil, false, nil, 'softsand', 20},
					{'Sandslash', 29, 32, 15, nil, false, nil, 'gripclaw', 20},
					{'Dunsparce', 29, 32, 10},
					{'Centiskorch', 29, 32, 5},
					{'Gible',     29, 32,  1},
				}
			}
		}
	},
	['chunk28'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk29'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk30'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk31'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk32'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk33'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk34'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 11979752860, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter,
		Victory = EncounterList
		{Verify = function(PlayerData)
			if not PlayerData.badges[5] then return false end
			return PlayerData.completedEvents.BJP and true or false
		end, PDEvent = 'Victini'}
		{{'Victini', 35, 35, 1}}}}},
	['gym5'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk25',
		regions = {
			['Aredia City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				noPCBox = true,
				Music = {111780413789940, 97260317319084},
				BattleScene = 'Gym5'
			}
		}
	},
	['chunk35'] = {
		blackOutTo = 'chunk25',
		regions = {
			['Desert Catacombs'] = {
				SignColor = BrickColor.new('Black').Color,
				Music = 17802899021,
				MusicVolume = .8,
				BattleScene = 'UnownRuins',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Unown', 25, 30, 1}
				}
			}
		}
	},
	['chunk36'] = {
		buildings = {
			'Gate16'
		},
		blackOutTo = 'chunk25',
		regions = {
			['Route 12'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 11979829274,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Tranquill',  31, 34, 20},
					{'Houndour',   31, 34, 20},
					{'Vulpix',     31, 34, 15, nil, false, nil, 'charcoal', 20},
					{'Sawk',       31, 35, 15, nil, false, nil, 'blackbelt', 20},
					{'Throh',      31, 35, 15, nil, false, nil, 'blackbelt', 20},
					{'Scraggy',    31, 34, 10, nil, false, nil, 'shedshell', 20},
					{'Miltank',    31, 34,  5, nil, false, nil, 'moomoomilk', 1},
					{'Tauros',     31, 34,  5},
					{'Bouffalant', 31, 34,  3},
				},
				OldRod = OldRodList {
					{'Magikarp', 10},
					{'Goldeen',   5, nil,nil,nil, false, nil, 'mysticwater', 20},
					{'Qwilfish',  1, nil,nil,nil, false, nil, 'poisonbarb', 20},
				},
				GoodRod = GoodRodList {
					{'Goldeen',20, nil,nil,nil, false, nil, 'mysticwater', 20},
					{'Magikarp',13},
					{'Qwilfish',5, nil,nil,nil, false, nil, 'poisonbarb', 20},
				},
			}
		}
	},
	['chunk37'] = {
		blackOutTo = 'chunk25',
		canFly = false,
		regions = {
			['Nature\'s Den'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 123756208314722,
				BattleScene = 'NatureDen',
				Landforce = EncounterList
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.RNatureForces then return false end
					return PlayerData.flags.landorusEnabled and true or false
				end, PDEvent = 'Landorus'}
				{{'Landorus', 40, 40, 1}}
			}
		}
	},
	['chunk38'] = {
		buildings = {'Gate17'},
		canFly = false,
		blackOutTo = 'chunk25',
		regions = {
			['Route 13'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 131986201642552,
				BattleScene = 'BioCave',
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20,nil, false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Dottler',  32, 36, 12, nil, false, nil, 'leftovers', 80},
					{'Volbeat',  32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Illumise', 32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Joltik',   32, 36, 10},
					{'Eldegoss',  32, 36,  5},
					{'Tynamo',   32, 36,  3},
					{'Applin',32, 36, 20}
				}
			}
		}
	},
	['chunk39'] = {
		buildings = {'Gate17', 'Gate18', 'PokeCenter'},
		regions = {
			['Fluoruma City'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 80932597080286
			}
		}
	},
	['gym6'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Fluoruma City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				noPCBox = true,
				Music = 11990168187,
				BattleScene = 'Gym6'
			}
		}
	},
	['chunk40'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Igneus Depths'] = {
				Music = 95337149605028,
				MusicVolume = .8,
				SignColor = BrickColor.new('Burgundy').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   25, 27, 20},
					{'Slugma',  25, 27, 20},
					{'Centiskorch',  25, 27, 20},
					{'Torkoal', 25, 27, 17,nil, false, nil, 'charcoal', 20},
					{'Magmar',  25, 27,  8,nil, false, nil, 'magmarizer', 20},
					{'Heatmor', 25, 27,  5},
				},
				Heat = EncounterList
				{PDEvent = 'Heatran'}
				{{'Heatran', 40, 40, 1}}
			}
		}
	},
	['chunk41'] = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Chamber of the Jewel'] = {
				SignColor = BrickColor.new('Pink').Color,
				BattleScene = 'BioCave',
				Music = 11990171543,
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20,nil, false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Dottler',  32, 36, 12, nil, false, nil, 'leftovers', 80},
					{'Volbeat',  32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Illumise', 32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Joltik',   32, 36, 10},
					{'Eldegoss',  32, 36,  5},
					{'Tynamo',   32, 36,  3}
				},
				Jewel = EncounterList
				{Verify = function(PlayerData) return PlayerData.completedEvents.OpenJDoor and true or false end,
				PDEvent = 'Diancie'}
				{{'Diancie', 40, 40, 1}}
			}
		}
	},
	['chunk42'] = {
		buildings = {'Gate18'},
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Flint').Color,
				BattleScene = 'Rt14Ruins',
				Music = 17802795009,
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 300},
					{'Makuhita', 32, 36, 300,nil, false, nil, 'blackbelt', 20},
					{'Nosepass', 32, 36, 250,nil, false, nil, 'magnet', 20},
					{'Mr. Mime', 32, 36, 150},
					{'Mr. Rime', 32, 36, 130},
					{'Arctozolt', 32, 36, 130},
					{'Clefairy', 32, 36, 125,nil, false, nil, 'moonstone', 20},
					{'Noibat',   32, 36,  75},
					{'Morpeko',  32, 36,  50},
					{'Beldum',   32, 36,  40},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},
	['chunk43'] = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Teal').Color,
				BattleScene = 'Rt14Ice',
				Music = 11990173262,
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 300},
					{'Makuhita', 32, 36, 300,nil, false, nil, 'blackbelt', 20},
					{'Nosepass', 32, 36, 250,nil, false, nil, 'magnet', 20},
					{'Mr. Mime', 32, 36, 150},
					{'Mr. Rime', 32, 36, 130},
					{'Clefairy', 32, 36, 125,nil, false, nil, 'moonstone', 20},
					{'Noibat',   32, 36,  75},
					{'Morpeko',  32, 36,  50},
					{'Beldum',   32, 36,  40},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},
	['chunk44'] = {
		canFly = false,
		blackOutTo = 'chunk17',
		regions = {
			['Cragonos Sanctuary'] = {
				SignColor = BrickColor.new('Hurricane grey').Color,
				Music = 11990177621,
			}
		}
	},
	['chunk45'] = {
		blackOutTo = 'chunk39',
		buildings = {
			'Gate19',
			'house1',
			'house2'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Route 15'] = {
				RTDDisabled = true,
				BattleScene = 'Snow',
				RodScene = 'Snow',
				SignColor = BrickColor.new('Medium blue').Color,
				Music = 108752772560278,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Snover',  34, 38, 400, nil, false, nil, 'nevermeltice', 20},
					{'Swinub', 34, 38, 400},
					{'Vanillite', 34, 38, 350, nil, false, nil, 'nevermeltice', 20},
					{'Snorunt', 34, 38, 200, nil, false, nil, 'snowball', 20},
					{'Snom', 34, 38, 200, nil, false, nil, 'snowball', 20},
					{'Darumaka', 34, 38, 200, nil, nil, 'Galar'},
					{'Sneasel', 34, 38, 100, 'night', false, nil, 'quickclaw', 20},
					{'Sceptile', 34, 38, 5, nil, nil, 'christmas'}, -- 2021 X-Mass Event
					{'Sceptile', 34, 38, 1.7, nil, nil, 'whitechristmas'}, -- 2021 X-Mass Event
				},
				OldRod = OldRodList {
					{'Magikarp', 600},
					{'Spheal', 500},
					{'Seel',   400},
					{'Bergmite',  70}
				},
				GoodRod = GoodRodList {
					{'Spheal',   5},
					{'Clobbopus',   5},
					{'Seel',     3},
					{'Bergmite', 1},
				},
			}
		}
	},
	['chunk46'] = {
		blackOutTo = 'chunk39',
		buildings = {
			'Gate19',
			'PokeCenter',
			'house1',
			'house2',
			'house3',
			'house4',
			'house5',
			'house6',
			'house7',
			'Gate20',
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Frostveil City'] = {
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 126817385866669,
				MusicVolume = .7,
			}
		}
	},
	['gym7'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk46',
		lighting = {
			FogColor = Color3.fromRGB(0, 0, 0),
			FogStart = 0,
			FogEnd = 0,
		},
		regions = {
			['Frostveil City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 109356687310965,
				noPCBox = true,
				MusicVolume = 0.81,
				BattleScene = 'Gym7'
			}
		}
	},

	['chunk47'] = {
		canFly = false,
		regions = {
			['Frostveil Catacombs'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 11990183868,
				IsDark = true,
			}
		}
	},

	['chunk48'] = {
		canFly = false,
		blackOutTo = 'chunk5',
		regions = {
			['Calcite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Yellow flip/flop').Color,
				Music = 11990199131,
				IsDark = true,
				BattleScene = 'RegirockCave',
				Regirock = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Regirock or not PlayerData.completedEvents.CompletedCatacombs then return false end
					return true
				end}
				{{'Regirock', 40, 40, 1}}
			},
		},
	},

	['chunk49'] = {
		canFly = false,
		blackOutTo = 'chunk11',
		regions = {
			['Martensite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Grey').Color,
				Music = 11990199131,
				IsDark = true,
				BattleScene = 'RegisteelCave',
				Registeel = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Registeel or not PlayerData.completedEvents.CompletedCatacombs then return false end
					return true
				end}
				{{'Registeel', 40, 40, 1}}
			},
		},
	},

	['chunk50'] = {
		canFly = false,
		blackOutTo = 'chunk46',
		regions = {
			['Dendrite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Medium blue').Color,
				Music = 11990199131,
				BattleScene = 'RegiceCave',
				IsDark = true,
				Regice = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Regice or not PlayerData.completedEvents.CompletedCatacombs then return false end
					return true
				end}
				{{'Regice', 40, 40, 1}}
			},
		},
	},

	['chunk51'] = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Titans Throng'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Gold').Color,
				IsDark = true,
				Music = 11990199131,
			},
		},
	},

	['chunk52'] = {
		blackOutTo = 'chunk46',
		buildings = {
			'Gate20',
			'Gate21',
			'SkittyLodge'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Route 16'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 101629191659673,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Jigglypuff',  35, 39, 400,nil, false, nil, 'moonstone', 20},
					{'Swellow', 35, 39, 400},
					{'Thievul', 35, 39, 400},
					{'Furfrou', 35, 39, 350},
					{'Nuzleaf', 35, 39, 200,nil, false, nil, 'powerherb', 20},
					{'Dedenne', 35, 39, 150},
					{'Appletun', 35, 39, 150},
					{'Dracovish', 35, 39, 150},
					{'Emolga', 35, 39, 150},
				}
			}
		}
	},

	['chunk53'] = {
		blackOutTo = 'chunk46',
		canFly = false,
		lighting = {
			FogColor = Color3.fromRGB(94, 94, 94),
			FogStart = 1,
			FogEnd = 800,
		},
		regions = {
			['Freezing Fissure'] = {
				SignColor = BrickColor.new('Cyan').Color,
				Music = 99429640873577,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'Fissure',
				RodScene = 'Fissure',
				MusicVolume = .8,
				IsDark = true,
				Grass = EncounterList {
					{'Munna',  36, 40, 40},
					{'Cubchoo',   36, 40, 40},
					{'Snorunt', 36, 40, 29, nil, nil, nil, 'snowball', 20},
					{'Cryogonal',  36, 40, 25, nil, nil, nil, 'nevermeltice', 20},
					{'Jynx',  36, 40, 5},
					{'Delibird',  36, 40, 1},

				},
			},
		}
	},

	['chunk54'] = {
		blackOutTo = 'chunk46',
		buildings = {
			['PondEntrance'] = {
				BattleSceneType = 'PondEntrance',
			},
			'Gate21',
			'Gate22',
			'Gate23',
		},
		regions = {
			['Cosmeos Valley'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 134683810722902,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Tarountula',  36, 40, 400},
					{'Munna',  36, 40, 400},
					{'Cottonee', 36, 40, 400,nil, false, nil, 'absorbbulb', 20},
					{'Vigoroth', 36, 40, 350},
					{'Minior', 36, 40, 200,nil, false, nil, 'starpiece', 20},
					{'Skarmory', 36, 40, 100},
					{'Mr. Rime', 36, 40, 65},
					{'Hawlucha', 36, 40, 25,nil, false, nil, 'kingsrock', 20},
					{'Shelmet', 36, 40, 10},
					{'Karrablast', 36, 40, 10},
				},
				OldRod = OldRodList {
					{'Magikarp', 100},
					{'Goldeen', 50,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Basculin', 30,nil,nil,nil, nil, nil, 'deepseatooth', 20},
				},
				GoodRod = GoodRodList {
					{'Goldeen',   10,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Magikarp', 5},
					{'Basculin',  3,nil,nil,nil, nil, nil, 'deepseatooth', 20},
					{'Luvdisc',  1,nil,nil,nil, nil, nil, 'heartscale', 2},
					
				},
				Deoxys  = EncounterList {PDEvent = 'DeoxysBattle'} {{'Deoxys', 50, 50, 1}}
			},
			   
		}
	},
	['chunk55'] = {
		canFly = false,
		noHover = true,
		regions = {
			['Cosmeos Observatory'] = {
				Music = 11990206687,
				MusicVolume = routeMusicVolume,
			},
		},
	},

	['chunk56'] = {
		noHover = true,
		blackOutTo = 'chunk46',
		buildings = {
			'Gate22'
		},
		regions = {
			['Tinbell Construction Site'] = {
				SignColor = BrickColor.new('Light orange brown').Color,
				Music = 11990210123,
				MusicVolume = 2,
			},
			['Tinbell Tower'] = {
				SignColor = BrickColor.new('Flame yellowish orange').Color,
				GrassNotRequired = true,
				Music = 11990210123,
				MusicVolume = 2,
				BattleScene = 'TinbellTower',
				Grass = EncounterList {
					{'Machop', 30, 40, 20, nil, nil, nil, 'focusband', 20},
					{'Timburr', 30, 40, 17},
					{'Clobbopus', 30, 40, 14},
					{'Machoke', 30, 40, 10, nil, nil, nil, 'focusband', 20},
					{'Gurdurr', 30, 40, 10},
					{'Falinks', 30, 40, 5},
				},
				HoOh = EncounterList
				{PDEvent = 'HoOhBattle'}
				{{'Ho-Oh', 40, 40, 1}}
			},
		}
	},


	['chunk57'] = {
		blackOutTo = 'chunk46',
		regions = {
			['Magik Pond'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RodScene = 'MagikCave',
				Music = 11990212167,
				OldRod = OldRodList {
					{'Magikarp', 100, nil, nil, nil, false, 'OrangeDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'PinkDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'CalicoOrangeWhite'},
					{'Magikarp', 100, nil, nil, nil, false, 'Monochrome'},
					{'Magikarp', 100, nil, nil, nil, false, 'Wasp'},
					{'Magikarp', 100, nil, nil, nil, false, 'YinYang'},
					{'Magikarp', 100, nil, nil, nil, false, 'Seaking'},
					{'Magikarp', 100, nil, nil, nil, false, 'Gyarados'},
					{'Magikarp', 100, nil, nil, nil, false, 'Relicanth'},
					{'Magikarp', 1.5, nil, nil, nil, nil, 'Rayquaza'},
					
				},
				GoodRod = GoodRodList {
					{'Magikarp', 100, nil, nil, nil, false, 'OrangeDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'PinkDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'CalicoOrangeWhite'},
					{'Magikarp', 100, nil, nil, nil, false, 'Monochrome'},
					{'Magikarp', 100, nil, nil, nil, false, 'Wasp'},
					{'Magikarp', 100, nil, nil, nil, false, 'YinYang'},
					{'Magikarp', 100, nil, nil, nil, false, 'Seaking'},
					{'Magikarp', 100, nil, nil, nil, false, 'Gyarados'},
					{'Magikarp', 100, nil, nil, nil, false, 'Relicanth'},
					{'Magikarp', 1.5, nil, nil, nil, nil, 'Rayquaza'},
				}
			}
		}
	},

	['chunk58'] = {
		buildings = {
			'Gate23',
			'Gate24',
			'HerosHoverboardsDecca',
			'PokeCenter',
			'PBStampShop',
			'AifesShelter',
			'ShipHouse',
			'DeccaTravelAgency',
			'CookesKitchen'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Port Decca'] = {
				SignColor = BrickColor.new('Teal').Color,
				Music = 116289585965006,
				MusicVolume = .7,
			}
		}
	},

	['chunk59'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk58',
		regions = {
			['Secret Lab'] = {
				SignColor = BrickColor.new('Pink').Color,
				RTDDisabled = true,
				Music = 11990292836,
				BattleScene = 'SecretLab',
			}
		}
	},

	['chunk60'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Path of Truth'] = {
				isDark = true,
				BattleScene = 'PathOfTruth',
				SignColor = BrickColor.new('Earth blue').Color,
				Music = 17802961536,
				RTDDisabled = true,
				MusicVolume = routeMusicVolume,
				GrassNotRequired = true,
				Grass = EncounterList {
					{'Axew',     36, 41, 35},
					{'Noibat',    36, 41, 30},
					{'Deino',    36, 41,  3},
					{'Duraludon',    36, 41,  3},
					{'Druddigon',   36, 41,  2, nil, false, nil, 'dragonfang', 20},
					{'Milcery',   36, 41,  1, nil, false, nil, 'whippeddream', 20},
				},
			},
		}
	},

	['chunk61'] = {
		blackOutTo = 'chunk58',
		buildings = {
			'Gate24'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Decca Beach'] = {
				SignColor = BrickColor.new('Cashmere').Color,
				Music = 81092464145938,
				BattleScene = 'DeccaBeach',
				OldRod = OldRodList {
					{'Tentacool', 100,nil,nil,nil, false, nil, 'poisonbarb', 20},
					{'Finneon', 50},
					{'Grapploct', 25},
				},
				GoodRod = GoodRodList {
					{'Tentacool',20,nil,nil,nil, false, nil, 'poisonbarb', 20},
					{'Finneon',14},
					{'Grapploct', 10},
					{'Gyarados',8},
					{'Remoraid',1},
				},
				Surf = EncounterList { 
					{'Tentacruel', 30, 40, 5,nil, false, nil, 'poisonbarb', 20},
					{'Carvanha', 30, 40, 5,nil, false, nil, 'deepseatooth', 20},
					{'Lumineon', 30, 40, 3},
					{'Cramorant', 30, 40, 3},
					{'Mantine', 30, 40, 1}
				}
			}
		}
	},

	['chunk62'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Steam Chamber'] = {
				Music = 11990218357,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Camerupt',   36, 40, 20},
					{'Torkoal', 36, 40, 17, nil, nil, nil, 'charcoal', 20},
					{'Heatmor',  36, 40, 17},
					{'Magcargo',  36, 40, 10},
					{'Magmar',   36, 40,  10, nil, nil, nil, 'magmarizer', 20},
					{'Larvesta', 36, 40,  5},
				},
				Volcanion = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.RevealSteamChamber then return false end
					return true
				end}
				{{'Volcanion', 60, 60, 1}}
			}
		}
	},

	['chunk63'] = {
		blackOutTo = 'chunk9',
		regions = {
			['Secret Grove'] = {
				Music = 11990264255,
				RTDDisabled = true,
				BattleScene = 'Grove',
				Keldeo = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.hasSwordsOJ then return false end
					return true
				end}
				{{'Keldeo', 40, 40, 1}}
			}
		}
	},

	['chunk64'] = {
		blackOutTo = 'chunk11',
		canFly = false,
		lighting = {
			FogColor = Color3.fromRGB(0, 170, 255),
			FogStart = 200,
			FogEnd = 1200,
		},
		regions = {
			['Cragonos Spring'] = {
				isDark = true,
				BattleScene = 'CragonosMines',
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 11990265816,
				GrassNotRequired = true,
				RTDDisabled = true,
				Grass = EncounterList {
					{'Woobat',     21, 24, 35, 'day'},
					{'Geodude',    21, 24, 30, nil, nil, nil, 'everstone', 20},
					{'Roggenrola', 21, 24, 30, nil, nil, nil, 'hardstone', 20, 'everstone', 2},
					{'Meditite',   21, 24, 15},
					{'Diglett',    21, 24, 10, nil, nil, nil, 'softsand', 20},
					{'Onix',       21, 24,  7},
					{'Drilbur',    22, 25,  3},
					{'Larvitar',   22, 24,  2},
				},
				RodScene = 'Springs',
				SurfScene = 'Springs',
				OldRod = OldRodList {
					{'Magikarp', 20},
					{'Goldeen',  10,nil,nil, nil, nil, nil, 'mysticwater', 20},
					{'Chinchou',  2,nil,nil, nil, nil, nil, 'deepseascale', 20},
				},
				GoodRod = GoodRodList {
					{'Magikarp',20},
					{'Goldeen', 10,nil,nil, nil, nil, nil, 'mysticwater', 20},
					{'Chinchou', 6,nil,nil, nil, nil, nil, 'deepseascale', 20},
				},
				Surf = EncounterList {
					{'Goldeen',   22, 24,  5, nil, nil, nil, 'mysticwater', 20},
					{'Magikarp',   22, 24,  3},
					{'Tentacool',   22, 24,  2, nil, nil, nil, 'poisonbarb', 20},
					{'Clauncher',   22, 24,  1},
				},
				Lapras = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.badges[7] then return false end
					if not PlayerData.flags.LapD then return false end
					PlayerData.flags.Lapras = nil
					PlayerData.lastLaprasEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Lapras', 40, 40, 1, nil, nil, nil, 'mysticwater', 1}}
			},
		}
	},

	['chunk65'] = {
		blackOutTo = 'chunk58',
		regions = {
			['Lost Islands'] = {
				SignColor = BrickColor.new('Gold').Color,
				Music = 87992055727614,
				RTDDisabled = true,
				BattleScene = 'Islands',
				Grass = EncounterList {
					{'Yungoos', 20, 30, 500,nil, nil, nil, 'pechaberry', 20},
					{'Pikipek', 20, 30, 350,nil, nil, nil, 'oranberry', 20},

					{'Rattata', 20, 30, 350, nil, nil, 'Alola', 'chilanberry', 20, 'pechaberry', 2},
					{'Grubbin', 20, 30, 150},
					{'Rockruff', 20, 30, 10},
				},
				OldRod = OldRodList {
					{'Tentacool', 100,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Finneon', 50},
				},
				GoodRod = GoodRodList {
					{'Tentacruel', 100,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 50},
					{'Tentacool', 25,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Mareanie', 2,nil,nil,nil, nil, nil, 'poisonbarb', 20},
				},
				Surf = EncounterList {
					{'Tentacruel', 20, 30, 5,nil, nil, nil, 'poisonbarb', 20},
					{'Tentacool', 20, 30, 2,nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 20, 30, 2},
					{'Corsola', 20, 30, 1,nil, nil, nil, 'luminousmoss', 20},
				}
			},
		}
	},

	['chunk66'] = {
		blackOutTo = 'chunk58',
		regions = {
			['Lost Islands - Deep Jungle'] = {
				BattleScene = 'Islands',
				SignColor = BrickColor.new('Dark green').Color,
				Music = 11990272797,
				RTDDisabled = true,
				Grass = EncounterList {
					{'Cutiefly',  22, 35, 20, nil, nil, nil, 'honey', 20},
					{'Bounsweet',  22, 35, 15, nil, nil, nil, 'grassyseed', 20},
					{'Dewpider',  22, 35, 10, nil, nil, nil, 'mysticwater', 20},
					{'Fomantis',  22, 35, 6.3, nil, nil, nil, 'miracleseed', 20},
					{'Meowth', 22, 35, 5, nil, nil, 'Alola', 'quickclaw', 20},
					{'Crabrawler', 22, 35, 1.3, nil, nil, nil, 'aspearberry', 20},
				},
				OldRod = OldRodList {
					{'Tentacool', 4, nil, nil, nil, nil, nil, 'poisonbarb', 20},
					{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacool', 20, nil, nil, nil, nil, nil, 'poisonbarb', 20},
					{'Tentacruel',15, nil, nil, nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon',  15},
					{'Gyarados', 10},
					{'Wishiwashi', 1.8, nil, nil, 'School'},
				},
				Surf = EncounterList { 
					{'Tentacruel', 20, 30, 20, nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 20, 30, 20},
					{'Tentacool', 20, 30, 15, nil, nil, nil, 'poisonbarb', 20},
					{'Corsola', 20, 30, 10, nil, nil, nil, 'luminousmoss', 20},
				}
			}
		}
	},

	['chunk90'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		regions = {
			['Solgaleo\'s Island'] = {
				Music = 11990218357,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'Islands',
				IsDark = true,
				GrassNotRequired = false,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Camerupt',   36, 40, 20},
					{'Torkoal', 36, 40, 17, nil, nil, nil, 'charcoal', 20},
					{'Heatmor',  36, 40, 17},
					{'Magcargo',  36, 40, 10},
					{'Magmar',   36, 40,  10, nil, nil, nil, 'magmarizer', 20},
					{'Larvesta', 36, 40,  5},
				},
				Solgaleo  = EncounterList {PDEvent = 'SolgaleoBattle'} {{'Solgaleo', 50, 50, 1}}
			}
		}
	},
				
	['chunk67'] = {
		blackOutTo = 'chunk58',
		buildings = {

		},
		regions = {
			['Frigidia Island'] = {
				SignColor = BrickColor.new('Bright blue').Color,
				Music = 11990275286,
				RTDDisabled = true,
			},
		}
	},

	['chunk68'] = {
		blackOutTo = 'chunk58',
		buildings = {

		},
		regions = {
			['Voltridia Island'] = {
				SignColor = BrickColor.new('Bright yellow').Color,
				Music = 11990275286,
				RTDDisabled = true,
			},
		}
	},

	['chunk69'] = {
		blackOutTo = 'chunk58',
		buildings = {

		},
		regions = {
			['Obsidia Island'] = {
				SignColor = BrickColor.new('Bright red').Color,
				Music = 11990275286,
				RTDDisabled = true,
			},
		}
	},

	['chunk70'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		buildings = {

		},
		regions = {
			['Frigidia Cavern'] = {
				SignColor = BrickColor.new('Bright blue').Color,
				Music = 11990276663,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'Frigidia',
				IsDark = true,
				Grass = EncounterList {
					{'Swinub',   29, 37, 20},
					{'Snorunt', 29, 37, 17, nil, nil, nil, 'snowball', 20},
					{'Piloswine',  29, 37, 17},
					{'Sandshrew',  29, 37, 10, nil, nil, 'Alola', 'gripclaw', 20},
					{'Vulpix',  29, 37, 10, nil, nil, 'Alola', 'snowball', 20},
				},
				Articuno = EncounterList 
				{Verify = function(PlayerData)
					local item = PlayerData:birdsitem()
					if not item.ft then return false end
					return true
				end}
				{{'Articuno', 50, 50, 1}}
			},
		}
	},

	['chunk71'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		buildings = {

		},
		regions = {
			['Voltridia Cavern'] = {
				SignColor = BrickColor.new('Bright yellow').Color,
				Music = 11990276663,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'Voltridia',
				IsDark = true,
				Grass = EncounterList {
					{'Joltik',   29, 37, 20},
					{'Nosepass', 29, 37, 17, nil, nil, nil, 'magnet', 20},
					{'Graveler',  29, 37, 17, nil, nil, 'Alola', 'cellbattery', 20},
					{'Stunfisk',  29, 37, 10, nil, nil, nil, 'softsand', 20},
				},
				Zapdos = EncounterList 
				{Verify = function(PlayerData)
					local item = PlayerData:birdsitem()
					if not item.vt then return false end
					return true
				end}
				{{'Zapdos', 50, 50, 1}}
			},
		}
	},	
	['chunk100'] = {
		blackOutTo = 'chunk100',
		buildings = { 
			'PokeCenter',
		},-- go to port decca
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Roria League  - Entrance'] = {
				Music = 13555352251,
				RTDDisabled = false,
				canFly = false,
			}
		}
	},
	['chunk99'] = {
		blackOutTo = 'chunk58', -- go to port decca
		regions = {
			['Roria League  - Encounter Place'] = {
				Music = 13555331910,
				NoSign = true,
				RTDDisabled = false,
				canFly = false,
				BattleScene = 'Islands',
				Grass = EncounterList {
					{'Hawlucha', 29, 30, 500,nil, nil, nil, 'pechaberry', 20},
					{'Toxicroak', 29, 30, 500,nil, nil, nil, 'oranberry', 20},
					{'Barraskewda', 29, 30, 500},
					{'Lycanroc', 29, 30, 500, nil, nil, nil, 'chilanberry', 20, 'pechaberry', 2},
					{'Goodra', 29, 30, 500},
					{'Hitmonchan', 29, 30, 500},
					{'Type: Null', 29, 30, 300},
					{'Cresselia', 29, 30, 250},
					{'Poipole', 29, 30, 250 },
					{'Gliscor', 29, 30, 500 },
					{'Samurott', 29, 30, 500 },	
					{'Sirfetch\'d', 29, 30, 500 },	
				},
			}
		}
	},
	
	['chunk102'] = {
		blackOutTo = 'chunk58', -- go to port decca
		regions = {
			['Elite - Ice '] = {
				Music = 13522350800,
				NoSign = true,
				RTDDisabled = false,
				canFly = false,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Pelipper',   38, 37, 20},
					{'Sharpedo',   38, 37, 20},
					{'Turtonator',   38, 37, 18},
					{'Duraludon', 38, 37, 17},
					{'Togedemaru',  38, 37, 17},
					{'Vikavolt', 38, 37, 12},
					{'Seaking',  38, 37, 10, nil, nil, nil, 'charcoal', 20},
				},
			}
		}
	},
	['chunk103'] = {
		blackOutTo = 'chunk100', 
		regions = {
			['Elite - Fighting '] = {
				Music = 13522452624,
				NoSign = true,
				RTDDisabled = false,
				canFly = false,
				BattleScene = 'CragonosMines',
			}
		}
	},
	['chunk104'] = {
		blackOutTo = 'chunk100', 
		regions = {
			['Elite - Fairy '] = {
				Music = 13522412460,
				NoSign = true,
				RTDDisabled = false,
				canFly = false,
				BattleScene = 'Safari',
			}
		}
	},
	['chunk105'] = {
		blackOutTo = 'chunk100', 
		regions = {
			['Elite - Dragon '] = {
				Music = 13522464699,
				NoSign = true,
				RTDDisabled = false,
				IsDark = true,
				canFly = false,
				BattleScene = 'Safari',
			}
		}
	},
	['chunk106'] = {
		blackOutTo = 'chunk100', 
		regions = {
			['Champions Hall '] = {
				Music = 13522478016,
				NoSign = true,
				RTDDisabled = false,
				canFly = false,
				IsDark = true,
				BattleScene = 'Safari',
			}
		}
	},
	['chunk72'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		buildings = {

		},
		regions = {
			['Obsidia Cavern'] = {
				SignColor = BrickColor.new('Bright red').Color,
				Music = 11990276663,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'Obsidia',
				IsDark = true,
				Grass = EncounterList {
					{'Slugma',   29, 37, 20},
					{'Sizzlipede',   29, 37, 18},
					{'Numel', 29, 37, 17},
					{'Camerupt',  29, 37, 17},
					{'Carbink', 29, 37, 12},
					{'Turtonator',  29, 37, 10, nil, nil, nil, 'charcoal', 20},
				},
				Moltres = EncounterList 
				{Verify = function(PlayerData)
					local item = PlayerData:birdsitem()
					if not item.ot then return false end
					return true
				end}
				{{'Moltres', 50, 50, 1}}
			},
		}
	},

	['chunk73'] = {
		blackOutTo = 'chunk11',
		canFly = false,
		regions = {
			['Silver Cove'] = {
				Music = 95433530412705,
				BattleScene = 'SilverCove',
				RTDDisabled = true,
				IsDark = true,
				Lugia = EncounterList 
				{PDEvent = 'Lugia'}
				{{'Lugia', 50, 50, 1}}
			}
		}
	},

	['chunk74'] = {
		SignColor = BrickColor.new('Royal purple').Color,
		canFly = false,
		noHover = true,
		noSaving = true,
		blackOutTo = 'chunk9',
		regions = {
			['Shadow Void'] = {
				Music = 11158727072,
				BattleScene = 'ShadowVoid',
				NoSign = true,
				RTDDisabled = true,
				MusicVolume = 0.81,
				Marshadow = EncounterList 
				{PDEvent = 'MarshadowBattle'} {{'Marshadow', 40, 40, 1}},
			},
		},
	},

	['chunk75'] = {
		noHover = true,
		blackOutTo = 'chunk58',
		lighting = {
			FogColor = Color3.fromRGB(0, 110, 255),
			FogEnd = 7000,
			FogStart = 0,
		},
		regions = {
			['Route 17'] = {
				SignColor = BrickColor.new('Navy blue').Color,
				Music = 17802813021,
				MusicVolume = routeMusicVolume,
				RTDDisabled = true,
				BattleScene = 'Surf',
				RodScene = 'Surf',
				OldRod = OldRodList {
					{'Tentacool', 50,nil,nil,nil, false, nil, 'poisonbarb', 20},
					{'Goldeen',  10,nil,nil,nil, false, nil, 'mysticwater', 20},
					{'Finneon',   5},
					{'Buizel',   1},
				},
				GoodRod = GoodRodList {
					{'Wailmer', 50},
					{'Tentacool',  45,nil,nil,nil, false, nil, 'poisonbarb', 20},
					{'Goldeen',   40,nil,nil,nil, false, nil, 'mysticwater', 20},
					{'Skrelp',   35},
					{'Finneon', 30},
					{'Horsea',  25,nil,nil,nil, false, nil, 'dragonscale', 20},
					{'Pyukumuku',   10},
					{'Buizel',   5},
					{'Bruxish',   2,nil,nil,nil, false, nil, 'razorfang', 20},
				},
				Surf = EncounterList { 
					{'Palafin', 31, 39, 5},
					{'Wailmer', 31, 39, 5},
					{'Tentacruel', 31, 39, 5,nil, false, nil, 'poisonbarb', 20},
					{'Lumineon', 31, 39, 3},
					{'Seaking', 31, 39, 3,nil, false, nil, 'mysticwater', 20},
					{'Skrelp', 31, 39, 3},
					{'Horsea', 31, 39, 3,nil, false, nil, 'dragonscale', 20},
					{'Eiscue', 31, 39, 2},
					{'Pyukumuku', 31, 39, 1},
					{'Floatzel', 31, 39, 1},
				},
				Sand = EncounterList {
					{'Sandygast', 31, 39, 5,nil, nil, nil, 'spelltag', 20},
				}
			}
		}
	},

	['chunk76'] = {
		buildings = {
			'PokeCenter',
			'Tavern',
			'Gate25',
			'House1',
			'House2',
			'House3',
			'House4'
		},
		regions = {
			['Crescent Town'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Pastel green').Color,
				Music = 102768889340872,
				RodScene = 'Creeks',
				SurfScene = 'Creeks',
				lighting = {
					FogColor = Color3.fromRGB(184, 212, 227),
					FogStart = 0,
					FogEnd = 10000000,
				},
				MusicVolume = .7,
				OldRod = OldRodList {
					{'Finneon', 100},
					{'Goldeen', 50,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Tentacool', 45,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Clamperl', 10,nil,nil,nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
				},
				GoodRod = GoodRodList {
					{'Binacle',10},
					{'Tentacool',10,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Frillish',10},
					{'Goldeen',6,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Finneon',6},
					{'Clamperl',2,nil,nil,nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
					{'Dhelmise',2,nil,nil,nil, nil, nil, 'persimberry', 20},
				},
				Surf = EncounterList { 
					{'Frillish', 31, 39, 5},
					{'Tentacruel', 31, 39, 5,nil, nil, nil, 'poisonbarb', 20},
					{'Binacle', 31, 39, 5},
					{'Seaking', 31, 39, 2,nil, nil, nil, 'mysticwater', 20},
					{'Lumineon', 31, 39, 2},
					{'Clamperl', 31, 39, 1,nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
				}
			}
		}
	},

	['chunk77'] = {
		buildings = {
			['C_chunk82'] = {
				DoorViewAngle = 20
			},
			['C_chunk83'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Entrance Hall'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
				BattleScene = 'EclipseHalls'
			}
		}
	},

	['chunk78'] = {
		buildings = {
			['C_chunk77|b'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Cafeteria'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
				BattleScene = 'EclipseCafeteria'
			}
		}
	},

	['chunk79'] = {
		buildings = {
			['C_chunk77|a'] = {
				DoorViewAngle = 20
			},
			['C_chunk77|b'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Power Station'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
				BattleScene = 'EclipsePower'
			}
		}
	},

	['chunk80'] = {
		buildings = {
			['C_chunk77'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Living Quarters'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
				BattleScene = 'LivingQuarters'
			}
		}
	},

	['chunk81'] = {
		buildings = {
			['C_chunk77'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Surveillance Room'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
			}
		}
	},

	['chunk82'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			["Eclipse Base - Cypress' Office"] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
			}
		}
	},

	['chunk83'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Prison Cells'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
			}
		}
	},

	['chunk84'] = {
		buildings = {
			['C_chunk83'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Eclipse Base - Aircraft Hangar'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 89660624071574,
			}
		}
	},

	['chunk85'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Gene Lab'] = {
				SignColor = BrickColor.new('Bright violet').Color,
				RTDDisabled = true,
				Music = 89660624071574,
				BattleScene = 'GeneLab',
				MetalBug = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.UnlockGenDoor then return false end
					return true
				end}
				{{'Genesect', 50, 50, 1}}
			}
		}
	},

	['chunk86'] = {
		blackOutTo = 'chunk76',
		buildings = {
			'Gate25'
		},
		lighting = {
			FogColor = Color3.fromRGB(104, 131, 107),
			FogStart = 0,
			FogEnd = 200,
		},
		regions = {
			['Route 18'] = {
				RTDDisabled = true,
				BattleScene = 'Swamp',
				SignColor = BrickColor.new('Grime').Color,
				Music = 17802816861,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Tarountula',  34, 42, 400,nil, false, nil, 'sitrusberry', 20, 'oranberry', 2},
					{'Swalot',  34, 42, 400,nil, false, nil, 'sitrusberry', 20, 'oranberry', 2},
					{'Croagunk', 34, 42, 400,nil, false, nil, 'blacksludge', 20},
					{'Toxicroak', 34, 42, 350,nil, false, nil, 'blacksludge', 20},
					{'Ribombee', 36, 40, 200,nil, false, nil, 'honey', 20},
					{'Skorupi', 34, 42, 100,nil, false, nil, 'poisonbarb', 20},
					{'Drapion', 34, 42, 25,nil, false, nil, 'poisonbarb', 20},
					{'Carnivine', 34, 42, 25},
					{'Grimer', 34, 42, 10, nil, false, 'Alola', 'blacksludge', 20},
					{'Goomy', 34, 42, 10,nil, false, nil, 'shedshell', 20},
					{'Sirfetch\'d', 34, 42, 4},
					{'Drakloak', 42, 49, 1},
					{'Dudunsparce', 42, 49, 1},
					
				},
			}
		}
	},

	['chunk87'] = {
		blackOutTo = 'chunk76',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 100000,
		},
		canFly = false,
		regions = {
			["Demon's Tomb"] = {
				RTDDisabled = true,
				isDark = true,
				SignColor = BrickColor.new('Reddish lilac').Color,
				Music = 11990298664,
				BattleScene = 'Tomb',
				MusicVolume = 0.81,
				Hoopa = EncounterList 
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.DefeatHoopa then return false end
					if not PlayerData.completedEvents.DefeatEclipseBase then return false end
					return true
				end}
				{{'Hoopa', 65, 65, 1, nil, nil, 'Unbound'}}
			},
			['Aborille Outpost'] = {
				RTDDisabled = true,
				isDark = true,
				SignColor = BrickColor.new('Dirt brown').Color,
				Music = 88155708370807,
				BattleScene = 'Aborille',
				MusicVolume = 0.81,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Mienfoo',   36, 40,  7},
					{'Wobbuffet', 36, 40,  6},
					{'Ponyta',    36, 40,  6, nil, nil, 'Galar'},
					{'Solrock',   36, 40,  4,nil, nil, nil, 'sunstone', 20, 'stardust', 2},
					{'Weezing',   36, 40,  3, nil, nil, 'Galar', 'roseliberry', 20},
					{'Lunatone',  36, 40,  2,nil, nil, nil, 'moonstone', 20, 'stardust', 2},
					{'Drampa',    36, 40,  1,nil, nil, nil, 'persimberry', 20},
				}
			},
		},
	},

	['chunk88'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		lighting = {
			FogColor = Color3.fromRGB(0, 127, 186),
			FogEnd = 700,
			FogStart = 200,
		},
		regions = {
			['Ocean\'s Origin'] = {
				SignColor = BrickColor.new('Navy blue').Color,
				Music = 11990450831,
				isDark = true,
				MusicVolume = 2,
				RTDDisabled = true,
				BattleScene = 'Springs',
				RodScene = 'Springs',
				GrassNotRequired = true,
				Grass = EncounterList {
					{'Dewgong',  31, 39, 25},
					{'Spheal',  31, 39, 25},
					{'Bergmite',  31, 39, 20},
					{'Frillish',  31, 39, 15},
					{'Skrelp',  31, 39, 15},
					{'Wimpod',  31, 39, 12},
					{'Tirtouga',  31, 39, 12},
					{'Wishiwashi',  31, 39, 12},
					{'Chewtle',  31, 39, 10},
					{'Swanna',  31, 39, 7},
					{'Arrokuda',  31, 39, 5},
					{'Mr. Mime', 31, 39, 2, nil, nil, 'Galar'},
				},
				Kyogre = EncounterList
				{PDEvent = 'Kyogre'}
				{{'Kyogre', 40, 40, 1}}
			},
		}
	},
	['gym8'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk76',
		regions = {
			['Crescent Town Gym'] = {
				RTDDisabled = true,
				SignColor = Color3.new(0.223529, 0.14902, 0.317647),
				Music = 11990453993,
				MusicVolume = 0.81,
				BattleScene = 'Gym8'
			}
		}
	},
	
	
	['chunk120'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		regions = {
			['Sky Pillar Shore'] = {
				Music = 18963392959,
				MusicVolume = .8,
				SignColor = BrickColor.new('Sea green').Color,
			},
		},
	},
	
	['chunk121'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		regions = {
			['Sky Pillar Cave'] = {
				Music = 17685037986,
				MusicVolume = kmanVolume,
				GrassNotRequired = true,
				BattleScene = 'Springs',
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Altaria',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Druddigon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Turtonator',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Goodra', 2, 4, 11},
				},
			},
		},
	},
	
	['chunk122'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		regions = {
			['Sky Pillar Island'] = {
				Music = 18963392959,
				MusicVolume = .8,
				BattleScene = 'PillarTower',
				SignColor = BrickColor.new('Tr. Brown').Color,
				Rayquaza = EncounterList 
				{PDEvent = 'RayquazaBattle'}
				{{'Rayquaza', 50, 50, 1}}
			},
		},
	},
	
	['chunk123'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Tr. Brown').Color,
		canFly = false,
		regions = {
			['Sky Pillar - Floor 1'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = true,
				BattleScene = 'SkyPillar',
				Grass = EncounterList {
					{'Duraludon',     31, 39, 15},
					{'Goodra',    31, 39, 15},
					{'Hydreigon',    31, 39, 15},
					{'Flygon',  31, 39, 15, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Druddigon',   31, 39, 15},
					{'Dracovish',    31, 39, 15},
					{'Turtonator',    31, 39, 15, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Altaria', 31, 39, 15},
                }, 
			},
		},
	},
	
	['chunk124'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Tr. Brown').Color,
		canFly = false,
		regions = {
			['Sky Pillar - Floor 2'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = true,
				BattleScene = 'SkyPillar',
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
				}, 
			},
		},
	},
	
	['chunk125'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Tr. Brown').Color,
		canFly = false,
		regions = {
			['Sky Pillar - Floor 3'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = true,
				BattleScene = 'SkyPillar',
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
				}, 
			},
		},
	},
	
	['chunk126'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Tr. Brown').Color,
		canFly = false,
		regions = {
			['Sky Pillar - Floor 4'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = true,
				BattleScene = 'SkyPillar',
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
				}, 
			},
		},
	},
	
	['chunk127'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Sea green').Color,
		canFly = false,
		regions = {
			['Sky Pillar - Floor 5'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = true,
				BattleScene = 'SkyPillar',
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
				}, 
			},
		},
	},
	
	['chunk128'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Sea green').Color,
		canFly = false,
		regions = {
			['Sky Pillar - Floor 6'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = true,
				BattleScene = 'SkyPillar',
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Wooloo',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
				}, 
			},
		},
	},
	
	['chunk129'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		regions = {
			['Sky Pillar - Top Floor'] = {
				Music = 18963392959,
				MusicVolume = .8,
				SignColor = BrickColor.new('Sea green').Color,
			},
		},
	},
	
	['chunk200'] = {
		buildings = {'C_Chunk3', 'C_Chunk201'},
		regions = {
			['Lab Hall'] = {
				SignColor = BrickColor.new('Light purple').Color,
				Music = 11990167033,
				BattleScene = 'GeneLab',
			}
		}
	},
	
	['chunk201'] = {
		buildings = {'C_Chunk200'},
		regions = {
			['Mewtwo Lab'] = {
				SignColor = BrickColor.new('Light purple').Color,
				Music = 11990167033,
				BattleScene = 'GeneLab',
				Mewtwo = EncounterList
				{PDEvent = 'Mewtwo'}
				{{'Mewtwo', 40, 40, 1}}
			}
		}
	},
	
	['chunk91'] = {
		noHover = true,
		canFly = false,
		buildings = {
			['C_chunk61|a'] = {
				DoorViewAngle = 10
			},
			['C_chunk61|b'] = {
				DoorViewAngle = 10
			},
			['C_chunk92|a'] = {
				DoorViewAngle = 10
			},
			['C_chunk92|b'] = {
				DoorViewAngle = 10
			}
		},
		regions = {
			['Safari Zone Entrance'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 13176715576,
			}
		}
	},

	['chunk92'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		isSafari = true,
		buildings = {
			['C_chunk91|a'] = {
				DoorViewAngle = 10
			},
			['C_chunk91|b'] = {
				DoorViewAngle = 10
			}
		},
		regions = {
			['Roria Safari Zone'] = {
				SignColor = BrickColor.new('Dark green').Color,
				RTDDisabled = true,
				Music = 11354349175,
				BattleScene = 'SafariZone',
				Grass = EncounterList                 
				{isSafari = true}
				{
					{'Deerling', 29, 37, 10},
					{'Drowzee', 29, 37, 10},
					{'Farfetch\'d', 29, 37, 10, nil, nil, nil, 'stick', 20},
					{'Lickitung', 29, 37, 10, nil, nil, nil, 'laggingtail', 20},
					{'Morelull', 29, 37, 10, nil, nil, nil, 'bigmushroom', 20},
					{'Mudbray', 29, 37, 10, nil, nil, nil, 'lightclay', 20},
					{'Rhyhorn', 29, 37, 10},
					{'Shellos', 29, 37, 10, nil, nil, 'East'},
					{'Spinda', 29, 37, 10},
					{'Ferroseed', 29, 37, 5, nil, nil, nil, 'stickybarb', 20},
					{'Kecleon', 29, 37, 5},
					{'Stufful', 29, 37, 5},
					{'Tropius', 29, 37, 5},
					{'Kangaskhan', 29, 37, 5},
					{'Kecleon', 29, 37, 0.5, nil, nil, 'Purple'},
					{'Rhyhorn', 29, 37, 0.3, nil, nil, 'Purple'}, 
				},
				MiscEncounter = EncounterList 
				{isSafari = true}
				{
					{'Drowzee', 29, 37, 10},
					{'Farfetch\'d', 29, 37, 10, nil, nil, nil, 'stick', 20},
					{'Kecleon', 29, 37, 10},
					{'Morelull', 29, 37, 10, nil, nil, nil, 'bigmushroom', 20},
					{'Oddish', 29, 37, 10, nil, nil, nil, 'absorbbulb', 20},
					{'Spinda', 29, 37, 10},
					{'Spritzee', 29, 37, 10},
					{'Swirlix', 29, 37, 10},
					{'Tropius', 29, 37, 5},
					{'Kangaskhan', 29, 37, 5},
					{'Stufful', 29, 37, 5},
					{'Kecleon', 29, 37, 0.5, nil, nil, 'Purple'},
					{'Oddish', 29, 37, 0.5, nil, nil, 'Aku', 'absorbbulb', 20},
				},
				Zelda = EncounterList {Locked = true} {{'Honedge', 30, 30, 1, nil, nil, 'Zelda'}}
			}
		}
	},
	
	['chunkYveltal'] = {
		buildings = {'C_Chunk23'},
		noHover = true,
		canFly = false,
		regions = {
			['Yveltal Lab'] = {
				SignColor = BrickColor.new('Really red').Color,
				Music = 11990167033,
				Yveltal = EncounterList 
				{PDEvent = 'Yveltal'}
				{{'Yveltal', 50, 50, 1}}
			}
		}
	},
	
	['chunkXerneas'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Yggdrasil Tree'] = {
				SignColor = BrickColor.new('Pink').Color,
				Music = 11990167033,
				Xerneas = EncounterList 
				{PDEvent = 'Xerneas'}
				{{'Xerneas', 50, 50, 1}}
			}
		}
	},
	
	['chunkZygarde'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Zygarde Grotto'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 11990167033,
				Zygarde = EncounterList 
				{PDEvent = 'Zygarde'}
				{{'Zygarde', 50, 50, 1, nil, nil, 'ten'}},
			}
		}
	},
	
	['chunkHisuian'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Sea green').Color,
		canFly = false,
		regions = {
			['Runeforge Island - Greenland'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = false,
				BattleScene = 'Islands',
				Grass = EncounterList {
					{'Salandit', 24, 31, 75},
					{'Dewpider', 24, 31, 65, nil, nil, nil, 'mysticwater', 20},
					{'Growlithe', 24, 31, 45, nil, nil, 'Hisuian'},
					{'Voltorb', 24, 31, 45, nil, nil, 'Hisuian'},
					{'Cutiefly', 24, 31, 45},
				}, 
			},
			['Runeforge Island - Icy Gales'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Pastel light blue').Color,
				Music = 1,
				BattleScene = 'Hisui',
				MusicVolume = 0.65,
				GrassNotRequired = false,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Snom', 24, 31, 75, nil, false, nil, 'snowball', 20},
					{'Darumaka', 24, 31, 65, nil, nil, 'Galar'},
					{'Sneasel', 24, 31, 45, 'night', false, nil, 'quickclaw', 20},
					{'Avalugg', 24, 31, 45, nil, nil, 'Hisuian'},
					{'Sneasel', 24, 31, 45, nil, nil, 'Hisuian'},
					{'Zorua', 24, 31, 5, nil, nil, 'Hisuian', 'razorclaw', 15},
					{'Typhlosion', 24, 31, 5, nil, nil, 'Hisuian', 15},
				}
			},
		}
	},	
	
	['chunkCave'] = {
		blackOutTo = 'chunk58',
		SignColor = BrickColor.new('Sea green').Color,
		canFly = false,
		regions = {
			['Balance Entrance'] = {
				Music = 18963392959,
				MusicVolume = .8,
				GrassNotRequired = false,
				BattleScene = 'CrystalCave',
				Grass = EncounterList {
					{'Rolem', 24, 31, 75},
					{'Dewpider', 24, 31, 65, nil, nil, nil, 'mysticwater', 20},
					{'Rolem', 24, 31, 45, nil, nil},
					{'Rolem', 24, 31, 45, nil, nil},
					{'Rolem', 24, 31, 45},
					{'Charcadet', 24, 31, 45},
				}, 
			},
		}
	},	
	
	['chunkZR'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Cavern of Balance'] = {
				BattleScene = 'ReshiZekrom',
				SignColor = BrickColor.new('Gold').Color,
				NoSign = false,
				RTDDisabled = true,
				Music = 17856675736,
				DialgaZ = EncounterList {
					{'Reshiram', 65, 65, 1, nil, nil}
				},
				PalkiaZ = EncounterList {
					{'Zekrom',     65, 65, 2, nil, nil},
				}
			},
		}
	},
	
	['chunkSolgaleo'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Altar of the Sunne'] = {
				BattleScene = 'Solgaleo',
				SignColor = BrickColor.new('Gold').Color,
				NoSign = false,
				RTDDisabled = true,
				Music = 17856675736,
				Altar = EncounterList {
					{'Solgaleo',     65, 65, 2, nil, nil},
				}
			},
		}
	},
	
	['cresselia'] = {
		CanFly = false,
		blackOutTo = 'chunk11',
		regions = {
			['Lunar Veil'] = {
				Music = 1,
				RTDDisabled = true,
				noSaving = false,
				CanFly = false,
				battleSceneType = 'scenecresselia',
				Dream = EncounterList {PDEvent = 'CresseliaEvent'} {{'Cresselia', 25, 25, 1, nil, nil, nil, 'starpiece', 1}},
			}
		}
	},
	
	['darkrai'] = {
		noHover = true,
		RTDDisabled = true,
		noSaving = true,
		CanFly = false,
		lighting = {
			Brightness = 0,
			FogEnd = 550,
			FogStart = 0,
			FogColor = Color3.fromRGB(32,29,33)
		},
		regions = {
			['Nightmare Abyss'] = {
				SignColor = BrickColor.new('Gold').Color,
				battleSceneType = 'scenedarkrai',
				Music = 1845108839,
				RTDDisabled = true,
				IsDark = true,
				MusicVolume = 0.81,
				Shadow =  EncounterList {PDEvent = 'DarkraiEvent'}  {{'Darkrai', 40, 40, 1}}
			}
		}
	},
	
	['enamorus'] = {
		blackOutTo = 'chunk11',
		regions = {
			['Elysian Grove'] = {
				Music = 94706775362977,
				battleSceneType = 'Enamorus',
				Grass = EncounterList {
					{'Cleffa', 50, 55, 10},   
					{'Igglybuff', 50, 55, 10},
					{'Togepi', 50, 55, 7},    
					{'Snubbull', 50, 55, 7},  
					{'Ralts', 40, 55, 5},   
					{'Flabébé', 40, 55, 5},
					{'Spritzee', 25, 55, 3}, 
					{'Swirlix', 25, 55, 3},  
					{'Cutiefly', 15, 55, 2}, 
				},
				Love = EncounterList {PDEvent = 'EnamorusEvent'} {{'Enamorus', 25, 25, 1, nil, nil, nil, 'starpiece', 1}},
			}
		}
	},
	
	['chunkRegi'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Split-Decision Ruins'] = {
				RTDDisabled = true,
				SignColor = Color3.new(78/400, 133/400, 191/400),
				Music = 136801252829048,
				Regidrago = EncounterList {PDEvent = 'RegidragoEvent'} {{'Regidrago', 25, 25, 1, nil, nil, nil, 'starpiece', 1}},
				Regieleki  = EncounterList {PDEvent = 'RegielekiEvent'} {{'Regieleki', 25, 25, 1, nil, nil, nil, 'starpiece', 1}},
			},
		},
	},

	['chunkHoOh'] = {
		regions = {
			['rc test'] = {
				SignColor = Color3.new(0.729412, 0.729412, 0),
				Music = 1841970811,--301381959,
				MusicVolume = .8,
				noWeather = true,
				battleSceneType = 'PalkiaScene',
				Bird = EncounterList 
				{PDEvent = 'DialgaEvent'}
				{{'Ho-Oh', 20, 20, 1}}
			},
		}
	},

	['mining'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Lagoona Trenches'] = {
				RTDDisabled = true,
				SignColor = Color3.new(78/400, 133/400, 191/400),
				Music = 136801252829048,
			},
		},
	},

	--// Sub-Contexts
	['colosseum'] = {
		canFly = false,
		regions = {
			['Battle Colosseum'] = {
				SignColor = BrickColor.new('Light orange').Color,
				Music = 81658773920922,
			}
		}
	},
	['resort'] = {
		canFly = false,
		regions = {
			['Trade Resort'] = {
				SignColor = BrickColor.new('Pastel blue-green').Color,
				Music = {112150539593397, 127093969765612}, --11322838239, -- 2021 X-Mass Event
				--MusicVolume = 5, -- 2021 X-Mass Event
			}
		}
	},
	rockSmashEncounter = EncounterList {Locked = true} {
		{'Dwebble', 15, 20, 7,nil, nil, nil, 'hardstone', 20},
		{'Shuckle', 15, 20, 1,nil, nil, nil, 'berryjuice', 1},
	},
	nonMaxEnconter = EncounterList {Locked = false} {
		{'Magikarp', 1, 1, 1},
	},
	roamingEncounter = { -- all @ lv 40
		Jirachi = {{'Jirachi', 4}},
		Shaymin = {{'Shaymin', 4}},
		Victini = {{'Victini', 4}},
		RNatureForces = {{'Thundurus', 3}, {'Tornadus',  3}},
		Landorus = {{'Landorus', 2}},
		Heatran = {{'Heatran', 4}},
		Diancie = {{'Diancie', 4}},
		RBeastTrio = {{'Raikou',  3}, {'Entei',   3}, {'Suicune', 3}},
		EonDuo = {{'Latios',  3}, {'Latias ', 3}},
		Regice = {{'Regice', 4}},
		Regirock = {{'Regirock', 4}},
		Registeel = {{'Registeel', 4}},
		Regigigas = {{'Regigigas', 3}},
		SwordsOJ = {{'Cobalion', 3}, {'Terrakion', 3}, {'Virizion', 3}},
		Keldeo = {{'Keldeo', 4}},
		Volcanion = {{'Volcanion', 4}},
		Mew = {{'Mew',  4}},
		Articuno = {{'Articuno', 4}},
		Zapdos = {{'Zapdos', 4}},
		Moltres = {{'Moltres', 4}},
		Lugia = {{'Lugia', 4}},
		Genesect = {{'Genesect', 4}},
		DefeatHoopa = {{'Hoopa',  4}},
		DeoxysBattle = {{"Deoxys",4}},
		SolgaleoBattle = {{"Solgaleo",4}},
		Groudon = {{'Groudon', 2}},
		Kyogre= {{'Kyogre', 2}},
		Celebi = {{'Celebi',  4}},
		RayquazaBattle = {{'Rayquaza',  4}},
		HoOhBattle = {{'Ho-Oh',  4}},
		Yveltal = {{'Yveltal', 2}},
		Xerneas = {{'Xerneas', 2}},
		EnamorusEvent = {{'Enamorus', 3}},
		CresseliaEvent = {{'Cresselia', 3}},
		DarkraiEvent = {{'Darkrai', 3}},
		RegidragoEvent = {{'Regieleki', 3}},
		RegielekiEvent = {{'Regidrago', 3}},
	}
}

chunks.encounterLists = encounterLists
return chunks