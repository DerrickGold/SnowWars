#SnowWars

![ScreenShot](https://github.com/DerrickGold/SnowWars/blob/master/ScreenShot/snowwars.png?raw=true)

##WELCOME TO SNOW WARS!

Created by: Curtis Murray, Jaymeson Wickins, Derrick Gold, Shaun Yonkers
Terrains and maps for level 1 and 2 created by Jaymeson and Shaun.

###PRIMARY FEATURES

Attacking snowmen is the primary feature of Snow Wars. When throwing a snowball the snow that is used to hold the snowman together is also your ammunition. Because of this, throwing a snowball will decrement a small portion of health from the character. Due to this mechanic, walking through the snow will pick up more snow and as a result the snowman will regain a small amount of health. 

There are two game modes: Team Deathmatch and Free For All
In Team Deathmatch two teams are pitted against each other to score the most amount of points. Make sure not to kill your own teammates in team deathmatch or your score will decrease, and potentially go into the negatives! Note: your team is always team blue (color of team text in bottom right corner).
In FFA, all snowmen are fighting for individual domination! No teams, everyone for themselves. Scores keep track of the player and the AI with the most amount of kills.
Default winning scores for Deathmatch and Free For All are 10 kills and 5 kills respectively, and can be edited in the scripts.
FFAScript.cs is the script that handles the Free For All mode and DeathMatchScript.cs handles the team deathmatch mode.

###Controls

Use WASD to move.
Space bar to jump. 
Hold shift to sprint. Note: if stamina runs out, snowman becomes burned out and must wait for stamina to fully recharge before sprinting becomes possible again.
First person view, using the mouse to look around.


###BUFFS

Buffs exist in the form of bouncing presents. Run over a present to obtain one of seven buffs:
  - Infinite health: player has infinite health and as a result, infinite ammo
  - Infinite ammo: weaker version of infinite health, as this only gives infinite ammo, not infinite health
  - Infinite stamina: running does not lower stamina. After buff, stamina completely drains
  - Super snowball: a much stronger snowball that requires more health from the snowman to use but deals massive damage to other snowmen and explodes into many smaller snowballs (careful not to kill yourself!!)
  - Health boost: running through the snow heals more health than usual 
  - Speed boost: increase the run and walk speed of the snowman

Notes: you are allowed to pick up multiple buffs, but only the first buff you picked up will be displayed on the HUD.

###ENVIRONMENTAL FEATURES

  - Snowmen are made of snow and as a result will begin to melt and break apart if they stand in water. Standing in water will rapidly decrease your health. 
  - In the team deathmatch level, there are trap spikes under one archway that will drop and take away a large 
    portion of health from player or AI if they walk near or under the archway.

###EXTRA FEATURES

  - Running back to a spawn point will regain all of the player or AI's health
  - AI will retreat to the home base after HP has dropped below 30. 
  - Upon start AI search for the nearest buff. After the beginning of the game, AI will only search for new buffs after they die or their current target dies. Otherwise they will go after an enemy if they have picked up a buff, or if someone else has picked up the buff they were going after.
  - "Ragdoll" effects on death: when a snowman dies they break into their respective pieces and roll around for a few seconds before respawning.

###SIDE EFFECTS

When buffs work together they can produce interesting side effects. For example, speed boost allows the player to "pick up more snow" and as a result they will gain more health with the speed boost. This coupled with Health Boost will regain health very quickly.
In the FFA mode, AI spawn locations are randomized throughout the level. If they run back to their spawn locations they will regain all of their health back again.

