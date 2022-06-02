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
**If you're going to tell me you're in trouble, write at least the following:**  

* [ ] What happened to you? Write the detail.
* [ ] How to get the same problem? The "step to reproduce" section.
* [ ] Any errors?  If so, the message in the console.
* [ ] Your environment (OS, Graphics card, and so on).
* [ ] Addons in your game - Some of them may conflict. Please specify the one.  
**Something like "I have 300+ addons" isn't helpful, either.**
* [ ] Try removing cache files! Some updates conflict with your old cache files.  
They're located in *garrysmod/data/splatoonsweps/mapname.txt* for singleplayer and listen server host,  
and *garrysmod/download/data/splatoonsweps/mapname.txt* for multiplayer.

## Known issues

* Loading some large maps with this SWEPs causes GMOD to crash in 32-bit build.
    You can still load them in 64-bit build so I recommend to switch to it.
* You may experience major frame drops if your VRAM amount is not enough.
    Make sure to set the ink resolution option (found in where you change playermodel for the SWEPs) correctly.

***

## Done

* A new ink system
* Inkling base system.
    You can become inkling as well.
* Basic GUI to change playermodel, ink color, and other settings.
    GUI menu is in the weapon tab and Utility -> Splatoon SWEPs.
* All main weapons in Splatoon (Wii U).

## Currently working on

* Sub weapons!
  * [x] Explosive effect for bombs
  * [x] Guide marker
  * [x] Explosive sub weapons
    * [x] Burst Bomb
    * [x] Ink Mine
    * [x] Seeker
    * [x] Splat Bomb
    * [x] Suction Bomb
  * [ ] Non-explosive sub weapons
    * [x] Disruptor
    * [x] Point Sensor
    * [x] Sprinkler
    * [x] Splash Wall
    * [ ] Squid Beakon

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

Using an external addon for third person view is also recommended.

* ~~[View Extension [ Thirdperson & Firstperson ]][9]~~  
  (Update on June 3rd)  
  **Remove this immediately!!**  
  it was hacked and now it's just a troll.
* [Enhanced ThirdPerson [Reupload]][10]  
  I think this is a good alternative for now.

[1]:https://steamcommunity.com/sharedfiles/filedetails/?id=746789974
[2]:https://steamcommunity.com/workshop/filedetails/?id=688236142
[3]:https://steamcommunity.com/sharedfiles/filedetails/?id=688236142
[4]:https://steamcommunity.com/workshop/filedetails/?id=572513533
[5]:https://steamcommunity.com/sharedfiles/filedetails/?id=479265317
[6]:https://steamcommunity.com/sharedfiles/filedetails/?id=478059724
[7]:https://steamcommunity.com/sharedfiles/filedetails/?id=476149543
[8]:https://steamcommunity.com/sharedfiles/filedetails/?id=1544841933
[9]:https://steamcommunity.com/sharedfiles/filedetails/?id=2589006389
[10]:https://steamcommunity.com/sharedfiles/filedetails/?id=2593095865
