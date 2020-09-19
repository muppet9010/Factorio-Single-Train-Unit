# Single Train Unit

Adds a single train unit comprising of a small cargo/fluid wagon and a locomotives at both ends. Total size is of a standard wagon. There are seperate cargo and fluid wagon versions.

![Single Train Unit Examples](https://thumbs.gfycat.com/DependableMixedBarasinga-size_restricted.gif)


Overview
============

- Intended for use as single unit trains, but they be joined togeather or joined with other locomotives or wagons (see Limitations).
- The unit's first and last 2 tiles are for feeding fuel to the locos. For Cargo wagons the middle 2 tiles are for accessing the small cargo wagon. For Fluid wagons the middle third is for connecting one pump. See the images.
- The units run between the performance of a single loco & wagon (1-1) and a dual headed train with a wagon (1-1-1). It consumes fuel at twice the usual loco rate to account for its compact dual direction nature.
- The cargo/fluid wagon space is 1/2 of the standard capacity given its small size.
- The unit is unlocked with the standard Railway research.
- Place the dual headed cargo/fluid wagon in the usual manner and it will be replaced out for the 2 mini locos and a mini cargo wagon.
- The unit will be mined by the player as a whole and will be damaged/destroyed as a whole, with damage shared across all parts.
- While the graphics look as one, there are actually 2 separate locomotives and a wagon there. So you must fuel both locomotive ends separately and select the right part of the Single Train Unit for giving train orders, entering to drive it, viewing the cargo, etc.
- UPS efficient as there is no continuously running active code in the mod, so no ongoing CPU load added to the game.
- The original trains and wagons are unaffected by this mod.


Not Implemented Yet / TODO
================

- Graphics are a WIP: cargo unit, fluid unit, train wheels.
- Method for players to colour the train unit.
- Add direction indicator to placement graphics to help with snapping to stations.
- Support for other mods to place the single train units, i.e. Train Construction Site.


Graphics Work In Progress
=================

The graphics are a work in progress and there is a mod setting to turn them on. By default the vanilla game's cargo wagon and fluid tanker graphics are used.
At present the cargo wagon has WIP graphics when stopped at a station and for some of the rotations, at other items its graphics will change to a vanilla locomotive. The fluid wagon has no custom graphics yet. The train wheels may show as doubled up.


Limitations / Known Issues
================

- Don't build a longer train with multiple single train units joined together out of order. Start at one end and place each one sequentially. As placing a middle single train unit between 2 other rail wagons may not place correctly.
- You can not detach a single train unit from other carriages as the parts all face outwards. There is protection in the mod to prevent a single train unit being broken up. However, you can detach regular carriages (cargo, loco, fluid) from a single train unit. If you need to detach a single train unit from another, its often easiest to just mine one of them.
- Single train units when being placed will only snap to a stations position if they are facing the right way. Theres no visual way to tell their direction at present, so just rotate them before placing if needed. Snapping on corners can be finikity.
- When single train units are blueprinted with fuel in them the highest fuel value type and count across them all is noted and this is used in the ghosted request. As blueprints lose the relationship between the single train unit parts its not possible to keep the fuel to train parts exactly the same.
- A single action that does multiple damages at a time (i.e. explosive rocket) will only do the single max damage and not the total cumulative damage. In the case of explosive rockets this means it will lose the lower impact damage, but get the correct higher blast damage. This is the fairest balance solution I can find so far to damage across the multiple parts of the train unit.
- Other mods that try to manipulate the train unit may have issues. Please report anything so I can review it if not listed below already.


Compatible Mods
=============

*Battery Pack*
Battery pack vesions of the trains are included when the mod is enabled.

*Factorio Extended & Factorio Extended Plus*
Additional tiers of single train units added to match the additional locomotive and wagon tiers.
Please provide any feedback on recipe or balance of these trains as I am not familiar with these mods and had to make approximations.

*Fill4Me*
The Fill4Me mod's auto insertion of fuel is applied to both locomotive ends of the single train unit. If you don't have enough fuel then as much as is available will be spread between the 2 locomotives.

*Signalized Couplers*
As the single train unit is made up of 3 train parts internally you need to account for this in the signals used. i.e. to decouple a single train unit at the end of a train use -3 as the decouple signal, not the standard -1 for a vanilla cargo wagon or locomotive.


Incompatible Mods
============

I have not blocked any other mods unless they hard break this mod. As while they won't work with the single train units added by this mod, they will still work with other types of trains and wagons. All train related mods with known issues or no effect are listed below with details.

*Bulk Rail Loader*
At present the Bulk Rail Loader can't work with the single train units as the Bulk Rail Loader only tries to take cargo items from one end of the wagon, which is a locomotive in the single train units case. This has been raised with the mod author to see if there's a solution. https://mods.factorio.com/mod/railloader/discussion/5f59068dab70d5cb80c7e723

*Electric Train*
At present no integration is present and so there isn't an electric version available.

*Multiple Unit Train Control*
The Multiple Unit Train Control mod doesn't appear to get applied to Single Train Units by default. Probably due to single train units being placed via script. This is desired behaviour as Single Train Units are already balanced for their dual direction nature.

*Noxys Multidirectional Trains*
The Noxys Multidirectional Trains mod doesn't appear to get applied to Single Train Units by default. Probably due to single train units being placed via script. This is desired behaviour as Single Train Units are already balanced for their dual direction nature.

*Train Construction Site*
Mod isn't compatible with single train units due to how it creates the boxed train prototypes at present. Not raised to mod author so far due to lack of interest.


Upgrading from old POC mod version
========================

- You can not upgrade from the Proof Of Concept version of the mod, version 18.x.x. This old version only had a handful of downloads and was a beta test. If you tried this version you'll need to start a new map to get on the main release.