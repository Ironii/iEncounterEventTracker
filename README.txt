---------------------------
--Contact-Info-------------
---------------------------
Bnet:
	Ironi#2880 (EU)
Discord:
	Ironi#2097
	https://discord.gg/stY2nyj

---------------------------
--General------------------
---------------------------

If you want to test the addon without doing raids, copy the strings from testData under WTF/Account/<Account>/SavedVariables/iEncounterEventTracker.lua, there are 2 tables, iEETConfig and iEET_Data, copy the strings under iEET_Data
if you want to save fights for later, you can also copy iEET_Data strings and just paste them in later when you want to look trough them
red line on the top of the main window indicates that you have filters active that doens't show up in the main window (check filtering options)

use mousewheel to scroll down/up
shift+mousewheel for fast scrolling

---------------------------
--Main-window-editbox------
---------------------------

uses the text to search from all possible table keys and values eg:
writing: 125261, will search 125261 from every table key and values

---------------------------
--Slash-cmds---------------
---------------------------

/ieet			toggle window (keybinding available)
/ieet X:
	copy 			copy current data to an editbox where you can copy it to spreadsheet (only those that you can see in the main window, so if you have filtered something out, it won't show)
	filters 		open filtering options window
	clear			wipe all fights
	autosave		toggle autosave
	autodiscard X	x = seconds, auto discards fights shorter than X (when autosave is on)
	colorreset		resets colors to default
	contact			show author's contact information
	whitelist spellid	add spell to whitelist (-spellid to remove)

---------------------------
--Colums-------------------
---------------------------

1st: time from ENCOUNTER_START
2nd: time from previus cast (with same spellID and sourceGUID) (mouseover for accurate time)
3rd: event name
4th: spell name (with hyperlink if possible), shift click to paste in to raid chat, click to show it in the details window
5th: caster name
6th: CLEU:target name, USCS: unitID
7th: cast count
8th: caster hp percent (USCS only)

---------------------------
--Using-filtering-options--
---------------------------

Key=Value

Split different argument with ';', eg.
k=v;k=v;k=v
e=2; si=205231; tn=Tichondrius; cn=Beholder	, shows every event where event is SPELL_CAST_SUCCESS, spellID = 205231, caster name (sourceName) = Beholder and the target is Tichondrius
205231		using only numbers, ieet will assume you want search with spellID and shows every event where spellID = 205231

possible key values (not case sensitive):
t/time 				number (doesn't support >/<, atleast not yet)
e/event 			number or string(long or short event names), numbers & names at the bottom of the file
sG/sourceGUID		string	UNIT_DIED:destGUID
cN/sourceName		string	UNIT_DIED:destName
tN/destName/unitID	string	USCS: source unitID
sN/spellName		string
sI/spellID		number
hp			number	USCS only (doesn't support >/<, atleast not yet)


to clear all filters use: clear
to delete just one use: del:x, eg del:1 will delete the first filter (from bottom)

REMEMBER TO CLICK 'Save' IF YOU WANT TO SAVE YOUR FILTERS, CLICKING 'Cancel' WILL ERASE YOUR EDITS

Event names/values:
1/SPELL_CAST_START/SC_START
2/SPELL_CAST_SUCCESS/SC_SUCCESS
3/SPELL_AURA_APPLIED/+SAURA
4/SPELL_AURA_REMOVED/-SAURA
5/SPELL_AURA_APPLIED_DOSE/+SA_DOSE
6/SPELL_AURA_REMOVED_DOSE/-SA_DOSE
7/SPELL_AURA_REFRESH/SAURA_R
8/SPELL_CAST_FAILED/SC_FAILED
9/SPELL_CREATE
10/SPELL_SUMMON
11/SPELL_HEAL
12/SPELL_DISPEL
13/SPELL_INTERRUPT/S_INTERRUPT
14/SPELL_PERIODIC_CAST_START/SPC_START
15/SPELL_PERIODIC_CAST_SUCCESS/SPC_SUCCESS
16/SPELL_PERIODIC_AURA_APPLIED/+SPAURA
17/SPELL_PERIODIC_AURA_REMOVED/-SPAURA
18/SPELL_PERIODIC_AURA_APPLIED_DOSE/+SPA_DOSE
19/SPELL_PERIODIC_AURA_REMOVED_DOSE/-SPA_DOSE
20/SPELL_PERIODIC_AURA_REFRESH/SPAURA_R
21/SPELL_PERIODIC_CAST_FAILED/SPC_FAILED
22/SPELL_PERIODIC_CREATE/SP_CREATE
23/SPELL_PERIODIC_SUMMON/SP_SUMMON
24/SPELL_PERIODIC_HEAL/SP_HEAL
25/UNIT_DIED
26/UNIT_SPELLCAST_SUCCEEDED/USC_SUCCEEDED
27/ENCOUNTER_START
28/ENCOUNTER_END
29/MONSTER_EMOTE
30/MONSTER_SAY
31/MONSTER_YELL
32/UNIT_TARGET
33/INSTANCE_ENCOUNTER_ENGAGE_UNIT/IEEU
34/UNIT_POWER
35/PLAYER_REGEN_DISABLED/COMBAT_START
36/PLAYER_REGEN_ENABLED/COMBAT_END
37/MANUAL_LOGGING_START/MANUAL_START
38/MANUAL_LOGGING_END/MANUAL_END
39/UNIT_SPELLCAST_START/USC_START
40/UNIT_SPELLCAST_CHANNEL_START/USC_C_START


Advanced Deleting:
iEET_Advanced_Delete(dif, encounter, fightTime)
Usage: iEET_Advanced_Delete(<difficulty, number, or false for any difficulty>, <encounterID(number) or true, <fight time (delete under), number, seconds>)
Example: iEET_Advanced_Delete(false, true, 60), would delete any fights under 60 seconds
