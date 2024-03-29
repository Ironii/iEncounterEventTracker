local _, iEET = ...
iEET.interrupts = {
	--General

	--Death Knight
	[47476] = true, --Strangulate
	[47528] = true, --Mind Freeze

	--Demon Hunter
	[183752] = true, --Disrupt

	--Druid
	[97547] = true, --Solar Beam
	[93985] = true, --Skull Bash
	[106839] = true, --Skull Bash

	--Evoker
	[351338] = true, -- Quell
	
	--Hunter
	[147362] = true, --Counter Shot
	[187707] = true, --Muzzle

	--Mage
	[2139] = true, --Counterspell

	--Monk
	[116705] = true, --Spear Hand Strike

	--Paladin
	[31935] = true, --Avenger's Shield
	[96231] = true, --Rebuke

	--Priest
	[15487] = true, --Silence
	[220543] = true, --Silence

	--Rogue
	[1766] = true, --Kick

	--Shaman
	[57994] = true, --Wind Shear

	--Warlock
	[19647] = true, --Spell Lock (Felhunter)
	[115781] = true, --Optical Blast (Observer)
	[132409] = true, --Spell Lock (Grimoire of Sacrifice)
	[171140] = true, --Shadow Lock (Doomguard, Grimoire of Supremacy)
	[347008] = true, --Axe Toss (Felguard)

	--Warrior
	[6552] = true, --Pummel
}
