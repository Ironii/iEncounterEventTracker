---------------------------
--Contact-Info-------------
---------------------------
irc:
	Ironi@Quakenet
	Ironii@Freenode
bnet:
	Ironi#2880

---------------------------
--General------------------
---------------------------

red line on the top of the main window indicates that you have filters active that doens't show up in the main window (check filtering options)

use mousewheel to scroll down/up
shift+mousewheel for fast scrolling

---------------------------
--Main-window-editbox------
---------------------------
uses the text to search from all possible table keys and values eg:
writing: 125261, will search 125261 from every table key and values

time filtering usage:

from:X/to:x

eg:
from:20 to:60, 	shows only events that happened between 20s from ENCOUNTER_START to 60s from ENCOUNTER_START
from:20			shows only events from 20s ->
to:60			shows only events from the first 60seconds of the fight

---------------------------
--Slash-cmds---------------
---------------------------

/ieet			toggle window (keybinding available)
/ieet X:
	copy 			copy current data to an editbox where you can copy it to spreadsheet (only those that you can see in the main window, so if you have filtered somethign out, it won't show)
	filters 		open filtering options window
	clear			wipe all fights
	autosave		toggle autosave
	autodiscard X	x = seconds, auto discards fights shorter than X (when autosave is on)

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
sI/spellID			number
hp					number	USCS only (doesn't support >/<, atleast not yet)


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