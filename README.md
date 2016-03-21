# Garrys-Mod-Fake-Players
Spoof / fake player counts on servers in Garrys Mod using bots lots of useful features to customize slots to be kept free / open and make the bots look like real players

# Features :

Assign all bots to a single team only. (Default : TEAM_SPECTATOR)

Specify number of slots that bots may never fill. (Default : 10)

Specify your own bot names.

Steal legit player names and use them for bot names.

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

If you have any bugs issues or problems just post a Issue request. https://github.com/C0nw0nk/Garrys-Mod-Fake-Players/issues
