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
- Support for other mods making their own versions of the single train units, i.e. electric train mods, battery mods, Factorio extended.
- Support for other mods to place the single trian units, i.e. Train Constrcution Site.


Limitations / Known Issues
================

- This is a concept mod and relies upon some emergent game behaviours. Should Factorio train placement change in the future it may not be possible to update and support it. The Factorio developers have advised against using custom train lengths in the past, but what do they know :p
- Don't build a train with multiple single train units in it out of order. Start at one end and place each one sequentially. As placing a middle single train unit between 2 other rail wagons may not place correctly.
- You can not detach a single train unit from other carriages as the parts all face inwards and there is protection in the mod to prevent a single train unit being broken up. However, you can detach regular carriages (cargo, loco, fluid) from a single train unit. If you need to detach a single train unit from another, its often easiest to just mine one of them.
- Single train units when being placed will only snap to a stations position if they are facing the right way. Theres no visual way to tell their direction at present, so just rotate them before placing if needed. Snapping on corners can be finikity.
- A single event that does multiple damages at a time (i.e. explosive rocket) will only do the single max damage and not the total cumilative damage. In the case of explosive rockets this means it will lose the lower impact damage, but get the correct higher blast damage. This is the least balance impacting solution I can find so far.
- Not able to blueprint the single train units with fuel in them. This may be added in future, but isn't simple.
- Other other mods that try to manipulate the train unit may have issues. Please report anything so I can review it.


Other Mods
============

I have not blocked any other mods unless they hard break this mod, however some won't work with the single train units added by this mod. All train related mods for known support, issues or just tested are listed below.
This decision to not block mods that don't work with single train units is to allow their use with other (regular) type trains in the game.

Factorio Extended & Factorio Extended Plus
--------------

Additional tiers of single train units added to match the additional locomotive and wagon tiers.

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

Electric Train
-----------------

At present no integration is present and so there isn't an electric version available.

Battery Pack
------------------

At present this isn't compatible. Investigation ongoing.

Upgrading from old POC mod verison
========================

- You can not upgrade from the Proof Of Concept version of the mod, version 18.x.x. This old version only had a handful of downloads and was a beta test. If you tried this version you'll need to start a new map to ge on the main release.