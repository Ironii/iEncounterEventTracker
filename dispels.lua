local _, iEET = ...
-- 1 = Defensive
-- 2 = Offensive
-- 3 = Both
iEET.dispels = {
	--General
	[50613] = 2, -- Arcane Torrent (DK?)
	[202719] = 2, -- Arcane Torrent (DH)
	[339189] = 1, -- Purify Soul (Kyrian phial)
	[323436] = 1, -- Purify Soul (Kyrian phial)

	--Demon Hunter
	[278326] = 2, -- Consume Magic

	--Druid
	[2782] = 1,		--Remove Corruption
	[2908] = 2,		--Soothe
	[88423] = 1,	--Nature's Cure
	[5487] = 1,		-- Bear Form
	[24858] = 1,	-- Moonkin Form

	--Evoker
	[374251] = 1, -- Cauterizing Flame
	[372048] = 2, -- Oppressing Roar
	[360823] = 1, -- Naturalize
	[357210] = 1,	-- Deep Breath

	--Hunter
	[19801] = 2,	--Tranquilizing Shot
	[781] = 1,		-- Disengage

	--Mage
	[30449] = 2,	--Spellsteal
	[475] = 1,		--Remove Curse

	--Monk
	[115310] = 1,	--Revival
	[115450] = 1,	--Detox
	[218164] = 1, --Detox (Brewmaster)
	[122783] = 1,	--Diffuse Magic
	[116841] = 1, -- Tiger's Lust

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
