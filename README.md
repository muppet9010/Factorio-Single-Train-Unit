# Single Train Unit

A single train unit comprising of a small cargo/fluid wagon and a locomotives at both ends. Total size is of a standard  wagon. There are seperate cargo and fluid wagon versions.

Overview
============

- Intended for use as single unit trains, but they be joined togeather or joined with other locomotives or wagons (see Limitations).
- The unit's first and last 2 tiles are for feeding fuel to the locos. For Cargo wagons the middle 2 tiles are for accessing the small cargo wagon. For Fluid wagons the middle third is for connecting one pump.
- The unit runs between the performance of a single loco & wagon and a dual headed train with a wagon. It consumes fuel at twice the usual loco rate to account for its compact dual direction nature.
- The cargo/fluid wagon space is 1/2 of the standard capacity given its small size.
- The unit is unlocked with the standard Railway research.
- Place the dual headed cargo/fluid wagon in the usual manner and it will be replaced out for the 2 mini locos and a mini cargo wagon.
- The unit will be mined by the player as a whole and will be damaged/destroyed as a whole, with damage shared across all parts.
- While the graphics look as one, there are actually 2 seperate locomotives and a wagon there. So you must fuel both locomotives seperately and select the right part of the Single Train Unit for giving orders, entering to drive it, etc.
- UPS effecient as there is no continously running active code in the mod, so no ongoing CPU load added to the game.

Not Implimented Yet
================

- Modified graphics to account for the changes.
- Coloring of the train unit.

Limitations / Known Issues
================

- This is a concept mod and relies upon some emergent game behaviours. Should Factorio train placement change in the future it may not be possible to update and support it. The Factorio developers have advised against using custom train lengths in the past, but what do they know :p
- Don't build a train with multiple single train units in it out of order. Start at one end and place each one sequentially. As placing a middle single train unit between 2 other rail wagons may not place correctly.
- There is no way to detach a single train unit from a larger train, it must be deconstructed. The disconnect wagon command will be effectively undone.
- Single train units when being placed will only snap to a stations position if they are facing the right way. Theres no visual way to tell their direction at present, so just rotate them before placing if needed. Snapping on corners is very finikity.
- An event that damages multiple parts of a unit will accumilate damage too fast. i.e. a grenade hitting all 3 parts will do triple damage to the unit parts due to damage sharing vs a normal train being hit by a grenade.
- Presently the placement of single train units by other mods or scripts won't work. I can't see any need for this, but shout if you find one.

Upgrading from old POC mod verison
========================

- You can not upgrade from the Proof Of Concept version of the mod, version 18.x.x. This old version only had a handful of downloads and was a beta test. If you tried this version you'll need to start a new map to ge on the main release.