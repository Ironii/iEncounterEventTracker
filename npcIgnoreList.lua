local _, iEET = ...
iEET.npcIgnoreList = {
--General
	[29238] = true,		--Scourge Haunt (item)
	[35642] = true,		--Jeeves
	[77789] = true,		--Blingtron 5000
	[92993] = true,		--Burning Blade Banner

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

--Demon Hunter

--Druid
	[1964] = true,		--Treant
	[47649] = true,		--Wild Mushroom
	[54983] = true,		--Treant
	[94852] = true,		--Boomkin 4pc
	[103822] = true,	--Treant

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

--Paladin

--Priest
	[19668] = true,		--Shadowfiend
	[62982] = true,		--Mindbender
	[65282] = true,		--Void Tendril
	[67235] = true,		--Shadowfiend
	[67236] = true,		--Mindbender
	[98167] = true,		--Void Tendril
	[99904] = true,		--T'uure (Holy Artifact)

--Rogue
	[77726] = true,		--Shadow Reflection
	[105850] = true,	--Akaari's soul (Sublety artifact)

--Shaman
	[2523] = true,		--Searing Totem
	[2630] = true,		--Earthbinding Totem
	[3527] = true,		--Healing Stream Totem
	[5925] = true,		--Grounding Totem
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


--Warrior
}
