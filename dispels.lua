local _, iEET = ...
-- 1 = Defensive
-- 2 = Offensive
-- 3 = Both
iEET.dispels = {
	--Druid
	[2782] = 1,		--Remove Corruption
	[2908] = 2,		--Soothe
	[88423] = 1,	--Nature's Cure

	--Hunter
	[19801] = 2,	--Tranquilizing Shot

	--Mage
	[30449] = 2,	--Spellsteal
	[475] = 1,		--Remove Curse

	--Monk
	[115310] = 1,	--Revival
	[115450] = 1,	--Detox

	--Paladin
	[4987] = 1,		--Cleanse
	[213644] = 1,	--Cleanse Toxins

	--Priest
	[527] = 1,		--Purify
	[528] = 2,		--Dispel Magic
	[32375] = 3,	--Mass Dispel

	--Rogue
	[5938] = 2,		--Shiv

	--Shaman
	[370] = 2,		--Purge
	[51886] = 1,	--Cleanse Spirit
	[77130] = 1,	--Purify Spirit

	--Warlock
	[89808] = 1,	--Singe Magic (Imp)
	[115276] = 1,	--Sear Magic (Fel Imp)
	
	-- Warrior
	[107574] = 1,	--Avatar
}
