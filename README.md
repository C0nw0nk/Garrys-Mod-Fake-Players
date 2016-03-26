# Garrys-Mod-Fake-Players
Spoof / fake player counts on servers in Garrys Mod using bots lots of useful features to customize slots to be kept free / open and make the bots look like real players

The main concept of this addon is to be used as a base to add support for NextBot's in each game mode, Would allow servers players to no longer play alone but to have bot's to compete against that will slowly be removed as regular players join them. The result will be your server will be full of legit players only as bots get removed when legit players join, When a legit player disconnects the script checks the player count and slots available and if player count is less than your free number of slots it will spawn a bot to keep the player count looking high.

# Features :

Assign all bots to a single team only. (Default : TEAM_SPECTATOR)

Specify number of slots that bots may never fill. (Default : 10)

Specify your own bot names.

Steal legit player names and use them for bot names. (Default : TRUE)

Set Max number on names to steal / save. (Default : FALSE)

Filter out words phrases etc from names we steal and name our bots with to prevent advertising etc.

# How to install :

Inside your `/garrysmod/cfg/server.cfg` file make sure you have the following : (This makes sure when the server starts a bot is spawned to kick start our script.)

`bot`

If you do not wish to use the bot command you may use this instead.

`lua_run player.CreateNextBot("Player_Name")`

Install the addon to the `"/garrysmod/addons/"` folder.

The path layout should look like this : `"/garrysmod/addons/fakeplayers/lua/autorun/server/sv_fakeplayers.lua"`

If you don't want it as a addon then install it here instead :

Install the script to the `"/garrysmod/lua/autorun/server/"` folder.

The path to should look like this : `"/garrysmod/lua/autorun/server/sv_fakeplayers.lua"`

Configure the script with any settings you want : (I recommend default)

https://github.com/C0nw0nk/Garrys-Mod-Fake-Players/blob/master/addons/fakeplayers/lua/autorun/server/sv_fakeplayers.lua#L1

If you have any bugs issues or problems just post a Issue request. https://github.com/C0nw0nk/Garrys-Mod-Fake-Players/issues

# TODO Tasks :

This script does everything a bot script should do the only thing currently missing is support for NextBots in each game mode.

When support is added for each game mode NextBots will be responsive and attack be friendly fight back etc you get the idea. Think of them like fighting against the AI bots in Killing Floor.

https://github.com/C0nw0nk/Garrys-Mod-Fake-Players/blob/master/addons/fakeplayers/lua/autorun/server/sv_fakeplayers.lua#L133
