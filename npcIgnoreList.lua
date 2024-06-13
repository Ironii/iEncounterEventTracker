local _, iEET = ...
iEET.npcIgnoreList = {
--General
	[29238] = true,		--Scourge Haunt (item)
	[35642] = true,		--Jeeves
	[77789] = true,		--Blingtron 5000
	[92993] = true,		--Burning Blade Banner
	[98300] = true,		--Petrified Sand Piper (toy)
	[143985] = true,	-- Absorb-o-Tron
	[152396] = true, -- Guardian of Azeroth (essence)
	[170190] = true, -- Shadowgrasp Totem (trinket, Shadowgrasp Totem, 179356)
	[175519] = true, -- Frothing Pustule (???, trinket or smh? casts Noxious Bolt (345495))
	[176474] = true, -- Inscrutable Quantum Device trinket:179350  (Hologram)
	[180016] = true, -- Spectral Feline (trinket:186436, Resonant Silver Bell)
	[182210] = true,	-- Magically Regulated Automa Core (optional reagent)

-- Covenant/Soulbinds
	[171396] = true, -- Bron (Kyrian)
	[178601] = true, -- Kevin's Oozeling (Necrolord, Plague Deviser Marileth)

--Death Knight
	[24207] = true, 	--Army of the Dead
	[26125] = true,		--Ghoul
	[27829] = true,		--Ebon Gargoyle
	[27893] = true,		--Rune Weapon
	[82521] = true,		--Defile
	[97055] = true,		--Shambling Horror
	[99541] = true,		--Risen Skulker
	[99773] = true,		--Bloodworm
	[100876] = true,	--Val'kyr Battlemaiden
	[106848] = true,	--Transformed abomination
	[111748] = true,	--Shadowy Reflection (Blood Artifact)
	[148797] = true,	--Magus of the Dead
	[149555] = true,	--Abomination
	[163366] = true,	--Magus of the Dead
	[217228] = true,	-- Blood Beast
	[221633] = true,	-- High Inquisitor Whitemane
	[221632] = true,	-- Highlord Darion Mograine
	[221635] = true,	-- King Thoras Trollbane
	[221634] = true,	-- Nazgrim

--Demon Hunter
	[136402] = true,	--Ur'zul
	[136406] = true,	--Shivarra

--Druid
	[1964] = true,		--Treant
	[47649] = true,		--Wild Mushroom
	[54983] = true,		--Treant
	[94852] = true,		--Boomkin 4pc
	[103822] = true,	--Treant
	[198489] = true,	--Fey Missile
--Evoker
	[189161] = true,	-- Dream Sprout

--Hunter
	[62005] = true,		--Beast(?)
	[62856] = true,		--Dire Beast
	[86187] = true,		--Beast
	[90521] = true,		--Binding Shot
	[94072] = true,		--Dark Minion
	[95021] = true,		--Felboar (hunter 4pc?)
	[95582] = true,		--Beast
	[103268] = true,	--Dire Beast
	[104493] = true,	--Spitting Cobra
	[106551] = true,	--Hati
	[106548] = true,	--Hati
	[113344] = true,	--Beast
	[113346] = true,	--Beast
	[113347] = true,	--Dire Beast
	[121661] = true,	--Sneaky Snake
	[128751] = true,	--Beast
	[128752] = true,	--Beast
	[228108] = true,	-- Beast
	[228224] = true,	-- Fenryr

--Mage
	[31216] = true,		--Mirror Image
	[47243] = true,		--Mirror Image
	[47244] = true,		--Mirror Image
	[78116] = true,		--Water Elemental
	[91710] = true,		--T18 (Archmage Khadgar)
	[94879] = true,		--T18 (Tyrande Whisperwind)
	[94922] = true,		--T18 (Lady Jaina Proudmoore)
	[94925] = true,		--T18 (Lady Sylvanas Windrunner)
	[94946] = true,		--T18 (Arthas Menethil)
	[103636] = true,	--Arcane Familiar
	[223453] = true,	-- Arcane Phoenix

--Monk
	[60849] = true,		--Jade Serpent Statue
	[63508] = true,		--Xuen
	[69680] = true,		--Storm Spirit
	[69791] = true,		--Fire Spirit
	[69792] = true,		--Earth Spirit
	[73967] = true,		--Xuen
	[78065] = true,		--Jade Serpent Statue
	[99625] = true,		--Wind Spirit
	[100868] = true,	--Chi'ji
	[165374] = true, -- Yu'lon
	[166949] = true,	-- Chi-ji
	[168033] = true, -- Fallen Monk (Covenant:Venthyr)
	[168073] = true, -- Fallen Monk (Covenant:Venthyr)
	[168074] = true, -- Fallen Monk (Covenant:Venthyr)
	[180743] = true, -- Niuzao
	[180744] = true, -- Yu'lon
	[196581] = true, -- White Tiger Statue

--Paladin

--Priest
	[19668] = true,		--Shadowfiend
	[62982] = true,		--Mindbender
	[65282] = true,		--Void Tendril
	[67235] = true,		--Shadowfiend
	[67236] = true,		--Mindbender
	[98167] = true,		--Void Tendril
	[99904] = true,		--T'uure (Holy Artifact)
	[172309] = true,	--Divine Image
	[180113] = true,	--Rattling Mage (Necrolord legendary)
	[180171] = true,	--Brooding Cleric (Necrolord Legendary)
	[183955] = true,	--Your Shadow
	[189988] = true,	-- Thing from Beyond
	[192337] = true,	-- Void Tendril
	[198236] = true,	-- Divine Image
	[198757] = true,	-- Void Lasher	
	[224466] = true,	-- Voidwraith

--Rogue
	[77726] = true,		--Shadow Reflection
	[105850] = true,	--Akaari's soul (Sublety artifact)
	[144961] = true,	--Akaari's Soul (DF Talent)

--Shaman
	[2523] = true,		--Searing Totem
	[2630] = true,		--Earthbinding Totem
	[3527] = true,		--Healing Stream Totem
	[5925] = true,		--Grounding Totem
	[6112] = true,		--Windfury Totem
	[10467] = true,		--Mana Tide Totem
	[15352] = true,		--Greater Earth Elemental
	[15438] = true,		--Greater Fire Elemental
	[29264] = true,		--Spirit wolf
	[53006] = true,		--Spirit Link Totem
	[59712]	= true,		--Stone Bulwark Totem
	[59764] = true,		--Healing Tide Totem
	[60561] = true,		--Earthgrab Totem
	[61029] = true,		--Primal Fire Elemental
	[61056] = true,		--Primal Earth Elemental
	[61245] = true,		--Capacitor Totem
	[77936] = true,		--Greater Storm Elemental
	[77942] = true,		--Primal Storm Elemental
	[78001] = true,		--Cloudburst totem
	[95061] = true,		--Greater Fire Elemental
	[95072] = true,		--Greater Earth Elemental
	[95255] = true,		--Earthquake Totem
	[97022] = true,		--Greater Lightning Elemental
	[97285] = true,		--Wind Rush Totem
	[97369] = true,		--Liquid Magma Totem
	[100099] = true,	--Voodoo Totem
	[100820] = true,	--Spirit Wolf
	[100943] = true,	--Earthen Shield Totem
	[102392] = true,	--Resonance Totem
	[104818] = true,	--Ancestral Protection Totem
	[105422] = true,	--Tidal Totem
	[106317] = true,	--Storm Totem
	[106319] = true,	--Ember Totem
	[106321] = true,	--Tailwind Totem
	[184091] = true,	--Spirit Wolf
	[184092] = true,	--Spirit Wolf
	[184093] = true,	--Spirit Wolf	
	[212489] = true,	--Spirit Wolf
	[221177] = true,	-- Ancestor
	[225409] = true,	-- Surging Totem

--Warlock
	[89] = true,		--Infernal
	[416] = true,		--Imp
	[417] = true,		--Felhunter
	[1860] = true,		--Voidwalker
	[1863] = true,		--Succubus
	[4277] = true,		--Eye of Killrogg
	[11859] = true,		--Doomguard
	[17252] = true,		--Felguard
	[78158] = true,		--Doomguard
	[55659] = true,		--Wild Imp
	[58959] = true,		--Fel Imp
	[59000] = true,		--Terrorguard
	[59262] = true,		--Demonic Gateway
	[59271] = true,		--Demonic Gateway
	[78217] = true,		--Infernal
	[82927] = true,		--Inner Demon
	[94584] = true,		--Chaos Portal (Dimensional Rift, Destruction artifact)
	[95468] = true,		--T18 Demo (Illidari Satyr)
	[95469] = true,		--T18 Demo (Visicous Hellhound)
	[98035] = true,		--Dreadstalker
	[99737] = true,		--Wild Imp
	[99887] = true,		--Shadowy Tear
	[103673] = true,	--Beholder
	[108452] = true,	--Infernal
	[108493] = true,	--Chaos Tear
	[121643] = true,	--Flame Rift
	[135002] = true, 	-- Demonic Tyrant
	[135816] = true, 	-- Vilefiend
	[136398] = true,	-- Illidari Satyr
	[136399] = true,	-- Vicious Hellhound
	[136401] = true,	-- Eye of Gul'dan
	[136404] = true, 	-- Bilescourge	
	[136407] = true,	-- Wrathguard
	[136408] = true,	-- Darkhound	
	[136403] = true, 	-- Void Terror
	[143622] = true, 	-- Wild Imp
	[168932] = true,	-- Doomguard
	[169426] = true,	-- Infernal
	[184206] = true,	-- Malicious Imp (T28)
	[185584] = true,	-- Blasphemy (T28)
	[196280] = true,	-- Unstable Tear
	[198547] = true,	-- Shadowy Tear
	[198555] = true,	-- Chaos Tear
	[217429] = true,	-- Overfiend
	[226269] = true,	-- Charbound
	[228574] = true,	-- Pit Lord
	[228575] = true,	-- Overlord
	[228576] = true,	-- Mother of Chaos
--Warrior
}
