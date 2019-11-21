Config                          = {}

Config.DrawDistance             = 100.0
Config.MarkerType               = 1
Config.MarkerSize               = { x = 1.5, y = 1.5, z = 0.5 }
Config.MarkerColor              = { r = 50, g = 50, b = 204 }

Config.EnablePlayerManagement   = true
Config.EnableArmoryManagement   = true

Config.EnableJobBlip            = true -- enable blips for colleagues, requires esx_society
Config.UseCarPack		= false -- Use car pack suggested on download

Config.LowPayout		= 100
Config.MidPayout		= 150
Config.HighPayout		= 250

Config.SecurityStations = {

	PillboxHill = {

		Blip = {
			Coords  = vector3(-197.01, -831.18, 30.76),
			Sprite  = 67,
			Display = 4,
			Scale   = 1.2,
			Colour  = 2
		},
		
		FrontDoor = {
			vector3(-197.01, -831.18, 30.76)
		},
		
		Elevator = {
			vector3(-75.57, -826.99, 243.36)
		},
		
		Listing = {
			vector3(-72.503, -814.230, 242.843)
		},

		Cloakrooms = {
			vector3(-79.45, -810.97, 243.39)
		},

		Armories = {
			vector3(-74.54, -809.70, 243.39),
		},
		
		Vehicles = {
			{
				Spawner = vector3(-182.90, -837.23, 30.33),
				SpawnPoints = {
					{ coords = vector3(-176.72, -827.64, 30.60), heading = 160.0, radius = 3.0 },
					{ coords = vector3(-178.93, -833.87, 30.34), heading = 160.0, radius = 3.0 },
					{ coords = vector3(-181.43, -840.67, 30.02), heading = 160.0, radius = 3.0 },
					{ coords = vector3(-183.64, -846.46, 29.67), heading = 160.0, radius = 3.0 }
				}
			},

		},

		BossActions = {
			vector3(-81.01, -802.43, 243.40)
		}

	},

}

Config.PatrolZones = {
	
	vector3(-183.92, -763.01, 30.45), -- Front of Building
	vector3(1714.53, -1661.01, 112.48), -- Murietta Fields
	vector3(-1130.58, -1987.48, 13.17), -- Airport LS Customs
	vector3(-1174.08, 63.18, 55.45), -- Golf Course
	vector3(2559.46, -377.44, 93.11), -- NOOSE Lot
	vector3(184.20, -934.27, 30.93),  -- Legion Square
	vector3(1079.96, -690.30, 57.63)  -- Mirror Park
	
}

Config.Peds = {	

	'u_m_y_militarybum', 'a_f_m_skidrow_01', 'a_f_m_trampbeac_01', 'a_f_y_hippie_01',
	'a_f_y_rurmeth_01', 'a_m_m_hillbilly_01', 'a_m_m_hillbilly_02', 'a_m_m_salton_03', 'a_m_m_rurmeth_01',
	'a_m_o_tramp_01', 'a_m_y_hippy_01', 'a_m_y_methhead_01', 'cs_old_man2', 'csb_ramp_hic', 'ig_cletus',
	'u_m_m_blane', 'u_m_y_croupthief_01'
	
}

Config.Scenarios = {
	
	'WORLD_HUMAN_DRINKING', 'WORLD_HUMAN_DRUG_DEALER', 'WORLD_HUMAN_LEANING', 'WORLD_HUMAN_PARTYING',
	'WORLD_HUMAN_SMOKING_POT', 'WORLD_HUMAN_STUPOR'
	
}

Config.AuthorizedWeapons = {
	recruit = {
		{ weapon = 'WEAPON_NIGHTSTICK'},
		{ weapon = 'WEAPON_FLASHLIGHT'}
	},

	guard = {
		{ weapon = 'WEAPON_NIGHTSTICK'},
		{ weapon = 'WEAPON_STUNGUN'},
		{ weapon = 'WEAPON_FLASHLIGHT'}
	},

	nightwatch = {
		{ weapon = 'WEAPON_COMBATPISTOL'},
		{ weapon = 'WEAPON_NIGHTSTICK'},
		{ weapon = 'WEAPON_STUNGUN'},
		{ weapon = 'WEAPON_FLASHLIGHT'}
	},

	manager = {
		{ weapon = 'WEAPON_COMBATPISTOL'},
		{ weapon = 'WEAPON_NIGHTSTICK'},
		{ weapon = 'WEAPON_STUNGUN'},
		{ weapon = 'WEAPON_FLASHLIGHT'}
	},

	boss = {
		{ weapon = 'WEAPON_COMBATPISTOL'},
		{ weapon = 'WEAPON_PUMPSHOTGUN'},
		{ weapon = 'WEAPON_NIGHTSTICK'},
		{ weapon = 'WEAPON_STUNGUN'},
		{ weapon = 'WEAPON_FLASHLIGHT'}
	},

}

-- CHECK SKINCHANGER CLIENT MAIN.LUA for matching elements

Config.Uniforms = {
	patrol_wear = {
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 50,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 11,
			['pants_1'] = 34,   ['pants_2'] = 0,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 65,  ['helmet_2'] = 0,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = 2,     ['ears_2'] = 0
		},
		female = {
			['tshirt_1'] = 36,  ['tshirt_2'] = 1,
			['torso_1'] = 48,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 44,
			['pants_1'] = 34,   ['pants_2'] = 0,
			['shoes_1'] = 27,   ['shoes_2'] = 0,
			['helmet_1'] = 45,  ['helmet_2'] = 0,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = 2,     ['ears_2'] = 0
		}
	},
	boss_wear = { 
		male = {
			['tshirt_1'] = 7,  ['tshirt_2'] = 2,
			['torso_1'] = 11,   ['torso_2'] = 0,
			['decals_1'] = 8,   ['decals_2'] = 3,
			['arms'] = 11,
			['pants_1'] = 25,   ['pants_2'] = 0,
			['shoes_1'] = 21,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = 2,     ['ears_2'] = 0
		},
		female = {
			['tshirt_1'] = 35,  ['tshirt_2'] = 0,
			['torso_1'] = 48,   ['torso_2'] = 0,
			['decals_1'] = 7,   ['decals_2'] = 3,
			['arms'] = 44,
			['pants_1'] = 34,   ['pants_2'] = 0,
			['shoes_1'] = 27,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = 2,     ['ears_2'] = 0
		}
	},
	bullet_wear = {
		male = {
			['bproof_1'] = 11,  ['bproof_2'] = 1
		},
		female = {
			['bproof_1'] = 13,  ['bproof_2'] = 1
		}
	},
	gilet_wear = {
		male = {
			['tshirt_1'] = 59,  ['tshirt_2'] = 1,
			['torso_1'] = 50, 	['torso_2'] = 0
		},
		female = {
			['tshirt_1'] = 36,  ['tshirt_2'] = 1
		}
	},
	heavy_wear = {
		male = {
			['tshirt_1'] = 56,  ['tshirt_2'] = 1,
			['torso_1']  = 49, 	['torso_2'] = 0,
			['arms']     = 1,
			['pants_1']  = 98,	['pants_2']  = 1,
			['shoes_1']	 = 71,	['shoes_2']  = 1,
			['helmet_1'] = 115, ['helmet_2'] = 0
		},
		female = {
			['bproof_1'] = 13,  ['bproof_2'] = 1
		}
	}	
}
