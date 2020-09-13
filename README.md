# Single Train Unit

Adds a single train unit comprising of a small cargo/fluid wagon and a locomotives at both ends. Total size is of a standard  wagon. There are seperate cargo and fluid wagon versions.

![Single Train Unit Examples](https://thumbs.gfycat.com/DependableMixedBarasinga-size_restricted.gif)


Overview
============

- Intended for use as single unit trains, but they be joined togeather or joined with other locomotives or wagons (see Limitations).
- The unit's first and last 2 tiles are for feeding fuel to the locos. For Cargo wagons the middle 2 tiles are for accessing the small cargo wagon. For Fluid wagons the middle third is for connecting one pump. See the images.
- The unit runs between the performance of a single loco & wagon and a dual headed train with a wagon. It consumes fuel at twice the usual loco rate to account for its compact dual direction nature.
- The cargo/fluid wagon space is 1/2 of the standard capacity given its small size.
- The unit is unlocked with the standard Railway research.
- Place the dual headed cargo/fluid wagon in the usual manner and it will be replaced out for the 2 mini locos and a mini cargo wagon.
- The unit will be mined by the player as a whole and will be damaged/destroyed as a whole, with damage shared across all parts.
- While the graphics look as one, there are actually 2 seperate locomotives and a wagon there. So you must fuel both locomotives seperately and select the right part of the Single Train Unit for giving orders, entering to drive it, etc.
- UPS effecient as there is no continously running active code in the mod, so no ongoing CPU load added to the game.
- The origional trains and wagons are unaffected by this mod.


Graphics Work In Progress
=================

The graphics are a work in progress and there is a mod setting to turn them on. By default the vanilla game's cargo wagon and fluid tanker graphics are used.
At present the cargo wagon has WIP graphics when stopped at a station and for some of the rotations, at other items its graphics will change to a vanilla locomotive. The fluid wagon has no custom graphics yet. The train wheels may show as doubled up.


If you can help with the graphics please see: https://forums.factorio.com/viewtopic.php?f=15&t=89145
===========


Not Implimented Yet
================

- Graphics are a WIP: cargo unit, fluid unit, train wheels.
- Coloring of the train unit.


Limitations / Known Issues
================

- This is a concept mod and relies upon some emergent game behaviours. Should Factorio train placement change in the future it may not be possible to update and support it. The Factorio developers have advised against using custom train lengths in the past, but what do they know :p
- Don't build a train with multiple single train units in it out of order. Start at one end and place each one sequentially. As placing a middle single train unit between 2 other rail wagons may not place correctly.
- You can not detach a single train unit from other carriages as the parts all face inwards and there is protection i the mod to prevent a single train unit beign broken up. However, you can detach regular carriages (cargo, loco, fluid) from a single train unit. If you need to detach a single train unit from another its often easiest to just mine one of them. There is a risk this logic isn't perfect in some edge cases.
- Single train units when being placed will only snap to a stations position if they are facing the right way. Theres no visual way to tell their direction at present, so just rotate them before placing if needed. Snapping on corners is very finikity.
- An event that damages multiple parts of a unit will accumilate damage too fast. i.e. a grenade hitting all 3 parts will do triple damage to the unit parts due to damage sharing vs a normal train being hit by a grenade.
- Presently the placement of single train units by other mods or scripts won't work. I can't see any need for this, but shout if you find one.
- Other other mods that try to manipulate the train unit may have issues. Please report anything so I can review it.


Other Mods
============

I have not blocked any other mods unless they hard break this mod, however some won't work with this mod. This decision is to allow their use with other (regular) type trains in games. These mods are listed below as well as any specific other mod integrations.

Fill4Me
-------------

The Fill4Me mod's auto insertion of fuel is applied to both locomotive ends of the single train unit. If you don't have enough fuel then as much as is available will be spread between the 2 locomotives.

Signalized Couplers
-------------

As the single train unit is made up of 3 train parts internally you need to account for this in the signals used. i.e. to decouple a single train unit at the end of a train use -3 as the decouple signal, not the standard -1 for a vanilla cargo wagon or locomotive.

Bulk Rail Loader
-------------

At present the Bulk Rail Loader can't work with the single train units as the Bulk Rail Loader only tries to take cargo items from one end of the wagon, which is a locomotive in the single train units case. This has been raised with the mod author to see if there's a solution. https://mods.factorio.com/mod/railloader/discussion/5f59068dab70d5cb80c7e723

Multiple Unit Train Control
----------------------

The Multiple Unit Train Control mod doesn't appear to get applied to Single Train Units by default. Probably due to single train units being placed via script. This is desired behavior as Single Train Units are already balanced for their dual direction nature.

Noxys Multidirectional Trains
----------------------

The Noxys Multidirectional Trains mod doesn't appear to get applied to Single Train Units by default. Probably due to single train units being placed via script. This is desired behavior as Single Train Units are already balanced for their dual direction nature.


Upgrading from old POC mod verison
========================

- You can not upgrade from the Proof Of Concept version of the mod, version 18.x.x. This old version only had a handful of downloads and was a beta test. If you tried this version you'll need to start a new map to ge on the main release.