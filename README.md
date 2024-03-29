# SplatoonSWEPs

[![Discord Banner 2](https://discordapp.com/api/guilds/933039683259224135/widget.png?style=banner2)](https://discord.gg/XyRXGxSYwY)

This is a huge rework of my existing addon, [SplatoonSWEPs][1].  
If you are interested in this project, watch this the following video for a brief introduction.  
[![Youtube](https://img.youtube.com/vi/2ca3UeLlCZs/0.jpg)](https://www.youtube.com/watch?v=2ca3UeLlCZs)

The aim of this rework is the following:

* Working fine on multiplayer game (especially on dedicated servers)
* More flesh than before! (not just throwing props)
* Various options with better UI
  * Drawing crosshair
  * Left hand mode
  * Realistic scope for scoped chargers
  * DOOM-style viewmodel
  * Aim down sight
  * And so on...

## Important thing - read before testing

***
**I don't intend to let you enjoy the new SWEPs.  Actually I want you to test it to help me fix bugs.**  
**So, I think something like "The addon isn't working for me" isn't worth reading.**  
**If you're going to tell me you're in trouble, go to Issues page and follow the template.**  

* [ ] What happened to you? Write the detail.
* [ ] How to get the same problem? The "step to reproduce" section.
* [ ] Any errors?  If so, the message in the console.
* [ ] Your environment (OS, Graphics card, and so on).
* [ ] Addons in your game - Some of them may conflict. Please specify the one.  
      **Something like "I have 300+ addons" isn't helpful.**

## Known issues

* Loading some large maps with this SWEPs causes GMOD to crash in 32-bit build.
    You can still load them in 64-bit build so I recommend to switch to it.
* You may experience major frame drops if your VRAM amount is not enough.
    Make sure to set the ink resolution option (found in where you change playermodel for the SWEPs) correctly.
* If you see errors on map load and can't paint at all, try removing cache files.
    * They are located in `garrysmod/data/splatoonsweps/<mapname>.txt` for singleplayer and listen server host.
    * They are located in `garrysmod/download/data/splatoonsweps/<mapname>.txt` for multiplayer games.
    * There are also `garrysmod/data/splatoonsweps/<mapname>_lightmap.png`.  
      If you see strange shading for the ink, try removing them.
* The ink surface doesn't support multiple light styles on a map.

***

## Done

* A new ink system
* Inkling base system.
    You can become inkling as well.
* Basic GUI to change playermodel, ink color, and other settings.
    GUI menu is in the weapon tab and Utility -> Splatoon SWEPs.
* All main weapons in Splatoon (Wii U).
* All sub weapons in Splatoon (Wii U).

## Currently working on

* Special weapons!
  * [x] Bomb Rush
  * [x] Echolocator
  * [x] Bubbler
  * [ ] Inkzooka
  * [ ] Inkstrike
  * [ ] Killer Wail
  * [ ] Kraken

## I want to make the following, too

* Special weapons in Splatoon and Splatoon 2
* Dualies, Brellas and some Splatoon 2 features.
* Gears and gear abilities

## How to install this project

Though this is still work in progress, you can download and test it.
If you test it in multiplayer game, all players must have the assets.

* Click **Clone or download** on the top-right, then **Download ZIP**.
* Extract the zip into garrysmod/addons/.  
  * Go to Steam -> LIBRARY -> Garry's Mod
  * Right click the game in the list or click the gear icon -> then Properties
  * Open **LOCAL FILES** tab and click **BROWSE LOCAL FILES...** button.
  * An explorer pops up. Go to **garrysmod/addons/**.
  * Put the extracted folder named **splatoonsweps-master** there.

You need the following to work it correctly.

* Team Fortress 2
* [Enhanced Inklings][4]
* ~~[Splatoon Full Weapons Pack][3]~~ Now you don't need this!  

Playermodels are optional, but I recommend to install them, too.

* [Inkling Playermodels][5]
* [Octoling Playermodels][6]
* [Callie & Marie Playermodels][7]
* [Splatoon 2 - Octolings [PM/RAG/VOX]][8]
* [[PMs] Off the Hook (Splatoon 2)][9]

Using an external addon for third person view is also recommended.

* [Enhanced ThirdPerson [Reupload]][10]  

[1]:https://steamcommunity.com/sharedfiles/filedetails/?id=746789974
[2]:https://steamcommunity.com/workshop/filedetails/?id=688236142
[3]:https://steamcommunity.com/sharedfiles/filedetails/?id=688236142
[4]:https://steamcommunity.com/workshop/filedetails/?id=572513533
[5]:https://steamcommunity.com/sharedfiles/filedetails/?id=479265317
[6]:https://steamcommunity.com/sharedfiles/filedetails/?id=478059724
[7]:https://steamcommunity.com/sharedfiles/filedetails/?id=476149543
[8]:https://steamcommunity.com/sharedfiles/filedetails/?id=1544841933
[9]:https://steamcommunity.com/sharedfiles/filedetails/?id=2626656553
[10]:https://steamcommunity.com/sharedfiles/filedetails/?id=2593095865
