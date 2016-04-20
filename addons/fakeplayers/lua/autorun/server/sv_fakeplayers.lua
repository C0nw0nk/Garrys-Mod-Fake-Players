--[[
Credits :
C0nw0nk

Github : https://github.com/C0nw0nk/Garrys-Mod-Fake-Players

Copyright : 2016 Conor Mcknight

Disclaimer :
I am not responsible for what you do with this script nor liable,
This script was released under default Copyright Law as a proof of concept.
For those who want to know what that means for your use of this script read the following : http://choosealicense.com/no-license/

Info :
This script is to give your server fake players using bots.
We also give bots legit player names to make them look like legit players.
When a legit player joins your server a bot will be kicked and bots will keep being removed until your server is full of legit players only.
If a legit player disconnects a bot will be put in their place to keep your player count looking as high as possible.
The script does the math and will not let your server be full of bots it keeps slots open for legit players.

Other methods of spoofing / faking player counts on servers use https://developer.valvesoftware.com/wiki/Server_queries
Another phrase for them could be packet spoofing.

How to use / setup :
In your "/garrysmod/cfg/server.cfg" add the following command.
bot

If you do not wish to use the bot command you may use this instead.
lua_run player.CreateNextBot("Player_Name")

Install the addon to the "/garrysmod/addons/" folder.
The path layout should look like this : "/garrysmod/addons/fakeplayers/lua/autorun/server/sv_fakeplayers.lua"

If you don't want it as a addon then install it here instead :
Install the script to the "/garrysmod/lua/autorun/server/" folder.
The path to should look like this : "/garrysmod/lua/autorun/server/sv_fakeplayers.lua"

If you have any bugs issues or problems just post a Issue request. https://github.com/C0nw0nk/Garrys-Mod-Fake-Players/issues

]]

--What team you want bots to be assigned to.
--Set as false to disable.
--If you set to false depending on your gamemode you bots will be standing around afk.
--Example :
--Team_to_Assign_Bots = false
--Team name example :
--Gmod Default : = TEAM_SPECTATOR | TEAM_UNASSIGNED | TEAM_CONNECTING
--ZombieSurvival = TEAM_SPECTATOR | TEAM_UNDEAD | TEAM_HUMAN
Team_to_Assign_Bots = TEAM_SPECTATOR --Put on the spectator team to be hidden.

--Keep this many slots free from bots so server can accept regular players.
--If you set this as 0 nobody will be able to join because server is full.
--On a 32 slot server with 10 free slots you will have 22 bots that will be created. (Simple math right ?) Slot count take away the number you set.
Number_of_Free_Slots = 10

--List of bot names to use.
--This list is just to get you started depends if you want to save / steal legit player names or not.
Bot_Names = {
"Garry :D","C0n | Ƹ̵̡Ӝ̵̨̄Ʒ","Buttercup","Fairy Liquid","Kitty",
"Rubat","Rainbow Dash","Blossom","Jaffa Cake","Sweetex",
"Meta","Fluttershy","Ace","Trigger","T-REX",
"Meow :3","Twilight Sparkle","Ted","~Katt~ <3","The G-Unit",
"Derp","Rarity","Olivia","Shade","Fee",
"Herp","Pinky Pie","Alli","d(^_^)b","Foo Foo",
"Fluffy","Derpy Hooves","Foxxi ♥","Defcon",
"Xira","Pound Cake","Xenia","Steam.exe","Broomhilda von Shaft",
"Faith","Scootalo","Prodigy","Betilla","VaL",
"Flump","Mrs. Cup Cake","Boom Headshot!","Cookie","Flesh Pound",
"Lamb","Snips","C4k3","Rabit","GirlDeaa",
"Lemon","Apple Bloom","Obama","Trina","Volition",
"><|||>","Sweetie Belle","BellaTrix","Atomic Boom!","Nuclear Reactor Party!",
"Raw.","Spike","Donald Trump","Bloo Me","DION",
"Swexy","Spyro","Super Man","Khaleesi","DYSON",
"Pixies","Rayman","Andrax","SpY","Los Lobos",
"Foxy","Big Macintosh","Lucy","Tiny Tim","BASSHUNTER",
"Scooter","Princess Luna","3===D~~~","isabella","D00p",
"puta","AppleJack","(*)(*)","Mandingo Party","C4sp3r",
"Moi Loca","Gaben","Finger Bang!","Mina | <3","Cr33p3r",
"1+3+3=7","Gabe Newell","Hot Lips","hun","Sexy Bunny",
"1+1=11","Mojo Jojo","┌∩┐(◣_◢)┌∩┐","Cerberus","Pr0",
"The Salt Bar","Bubbles","Kaya 🐻🐾🐲","Zeus","Snapshot",
"Floofy","dudette","Vixen","Coach","TANK",
"ρanda♥","dude","K9 Lady","Ellis","Woody",
"◼","Kam","Knotty","<3 FEMALE META | :3","Lisa",
} --Do not delete this.

--If we should save names bots use or not.
--If this is disabled we will no longer steal players names but use the names specified in the Bot_Names table.
--Set true to enable | false to disable.
--The list of names saved can be found on your server written here : "/garrysmod/data/BotNames.txt"
Save_Player_Names = true

--The max number of names to be saved.
--Set a number to enable | false to disable.
--Only allow max of 1000 names to be saved / stolen.
--Max_Names_to_Save = 1000
--Currently false so unlimited names will be saved.
Max_Names_to_Save = false

--This feature only works if the Save_Player_Names feature is set to be true / enabled.
--Filter out player names we steal for bad words phrases advertising etc.
--This prevents the bots that get randomly named on the server from advertising others.
--Admin names will never be stolen but if a player who is not an admin changes their name to match with the name of an admin then the name will end up being in the database.
Bot_Name_Filter = {
"^%b()", --Regex strings can be used for pattern matching This matches those that start start with brackets and the brackets contain something example : (1)Playername will become Playername.
".com",
".net",
".org",
".info",
".co.uk",
"http",
"www",
} --Do not delete this.

--Bot Identifier to show to players who is bot and who is not.
--Example : Bot Identifier = "BOT | "
--Default : empty to not show who is a bot.
Bot_Identifier = ""

--This timer is not needed but i put it here incase of conflicting scripts addons etc that somehow stop bots from spawning in.
--I recommend leaving this as it is.
Bot_Timer_Check = 1

--[[

DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING.

^^^^^ YOU WILL MOST LIKELY BREAK THE SCRIPT SO TO CONFIGURE THE FEATURES YOU WANT JUST USE WHAT I GAVE YOU ABOVE. ^^^^^

THIS BLOCK IS ENTIRELY WRITTEN IN CAPS LOCK TO SHOW YOU HOW SERIOUS I AM.

]]

--This area is for Game Mode support. (If you are a developer you can use this to add support for GameModes.)
--For example hook's, calls etc to disable / prevent or fix the game mode doing things that causes problems with fake bots, players, displays, team switching you get the idea.

--[[ TODO :
Everything NextBot related is server sided.
https://wiki.garrysmod.com/page/Category:NextBot
So add support for each gamemode and nextbots here.
]]

--Timer to delay grabbing GAMEMODE.Name to let the gamemode load first.
timer.Simple(2, function()

--Sand Box support.
if GAMEMODE_NAME == "sandbox" then
end

--TTT | Trouble in Terrorist Town support.
if GAMEMODE_NAME == "terrortown" then
end

--Cinema support.
if GAMEMODE_NAME == "cinema" then
end

--Dark RP support.
if GAMEMODE_NAME == "darkrp" then
end

--Star Wars RP support.
if GAMEMODE_NAME == "starwarsrp" then
end

--Death Run support.
if GAMEMODE_NAME == "deathrun" then
end

--Gun Gaym support.
if GAMEMODE_NAME == "gungaym" then
end

--Flood support.
if GAMEMODE_NAME == "flood" then
end

--Jail Break support.
if GAMEMODE_NAME == "jailbreak" then
end

--Mini Games support.
if GAMEMODE_NAME == "minigames" then
end

--Pirate Ship Wars support.
if GAMEMODE_NAME == "pirateshipwars" then
end

--Stop it Slender support.
if GAMEMODE_NAME == "stopitslender" then
end

--ZE | Zombie Escape support.
if GAMEMODE_NAME == "zombieescape" then
end

--ZS | Zombie Survival support.
if GAMEMODE_NAME == "zombiesurvival" then
	--Include our gamemode support file.
	include("gamemodes/sv_zombiesurvival.lua")
end

--Awesome Strike: Source support.
if GAMEMODE_NAME == "awesomestrike" then
end

--Extreme Football Throwdown support.
if GAMEMODE_NAME == "extremefootballthrowdown" then
end

--End Game Mode support.

--This area is for Admin addons support.

--So far the only admin addon i have seen encounter issues is ULX becuase it trys to Authenticate NextBots as legit players!?.
--If you spawn bots in with the "Bot" console command this error never happens.
--ULX support.
if (ULib and ULib.bans) then
--ULX has some strange bug / issue with NextBot's and Player Authentication.
--[[
[ERROR] Unauthed player
  1. query - [C]:-1
   2. fn - addons/ulx-v3_70/lua/ulx/modules/slots.lua:44
    3. unknown - addons/ulib-v2_60/lua/ulib/shared/hook.lua:110
]]
	--Fix above error by adding acception for bots to the ulxSlotsDisconnect hook.
	hook.Add("PlayerDisconnected", "ulxSlotsDisconnect", function(ply)
		--If player is bot.
		if ply:IsBot() then
			--Do nothing.
			return
		end
	end)
end

--End Admin addons support.

end) --End timer delay.

--Grab and select random name to name the bots we create with.
function RandomName()
	--BotNames table.
	BotNames = {}

	--If save player names is true then allow us to create data file.
	if Save_Player_Names == true then
		if file.Exists("BotNames.txt", "DATA") then
			--Read our file.
			local lol = file.Read("BotNames.txt", "DATA")
			--Put our file data into a table.
			data = string.Explode("\n", lol)
			--For each name in our table.
			for i=1, #data do
				--Add name to the table of names.
				table.insert(BotNames, data[i])
			end
		else
			--file did not exist so create it and add player names.
			for i=1, #Bot_Names do
				--For the first instance we create the file.
				if i == 1 then
					--Create file and add name from table.
					file.Write("BotNames.txt", ""..Bot_Names[i].."")
				else
					--Add the new name to the file.
					file.Append("BotNames.txt", "\n"..Bot_Names[i].."")
				end
				--Add name to the table of names.
				table.insert(BotNames, Bot_Names[i])
			end
		end
	else --Save names is not true so Don't create any files.
		--For each bot name in our table.
		for i=1, #Bot_Names do
			--Add name to the table of names.
			table.insert(BotNames, Bot_Names[i])
		end
	end

	--Prevent bots getting the same name as existing bots/players.
	local Players = player.GetAll()
	--For each player.
	for i=1, #Players do
		--If player name is found within table.
		if table.HasValue(BotNames, Players[i]:GetName()) then
			--Remove the name from the table.
			table.remove(BotNames, table.KeyFromValue(BotNames, Players[i]:GetName()))
		end
	end

	--Randomize the output.
	output = table.Random(BotNames)

    return output
end

--Add names of legit players to our database of names for future usage.
function AddNametoDatabase(name)

	--TODO : Improve this pattern matching / filtering technique.
	for i=1, #Bot_Name_Filter do
		--[[ Nulled out this code to use regex for upper / lower case matching.
		--lower case matches.
		if name:lower():find(Bot_Name_Filter[i]) then
			--Filter out string and replace with nothing.
			name = name:gsub(Bot_Name_Filter[i], "")
		end
		--upper case matches.
		if name:upper():find(Bot_Name_Filter[i]) then
			--Filter out string and replace with nothing.
			name = name:gsub(Bot_Name_Filter[i], "")
		end]]
		--For exact matches
		if name:find(Bot_Name_Filter[i]) then
			--Filter out string and replace with nothing.
			name = name:gsub(Bot_Name_Filter[i], "")
		end
	end

	if file.Exists("BotNames.txt", "DATA") then
		--Read our file.
		local lol = file.Read("BotNames.txt", "DATA")
		--Put our file data into a table.
		data = string.Explode("\n", lol)
		--Prevent the file becomming larger than we say.
		if table.Count(data) <= Max_Names_to_Save or Max_Names_to_Save == false then
			--Only add names to database that do not exist.
			if !table.HasValue(data, name) then
				--Add the new name to the file.
				file.Append("BotNames.txt", "\n"..name.."")
			end
		end
	else
		--file did not exist so create it and add player name.
		file.Write("BotNames.txt", ""..name.."")
	end
end

--Fill server with bots @ startup / mapchange.
--hook.Add("InitPostEntityMap", "InitPostEntityMap-Spoof-Player-Count", function()
hook.Add("InitPostEntity", "InitPostEntity-Spoof-Player-Count", function()

	--Need to run a check on player count. (Only create bots on player count avaliable.)
	if #player.GetHumans() + #player.GetBots() <= game.MaxPlayers() - Number_of_Free_Slots then

		--Timer is mandatory did not want to spawn in bots / work without this.
		timer.Simple(1, function()
			--Current number of players on the server. (Both Human and Bots.)
			CurrentPlayerCount = #player.GetHumans() + #player.GetBots()
			--Make the number of bots to create the MaxPlayer count take away free slots.
			FillSlots = game.MaxPlayers() - Number_of_Free_Slots

			--For each number.
			for i=1, FillSlots - CurrentPlayerCount do
				--Spawn / create a bot.
				player.CreateNextBot(""..Bot_Identifier..""..RandomName().."")
				--RunConsoleCommand("bot")
			end

			--Assign all bots to a single team rather than let your game mode balance them.
			if Team_to_Assign_Bots != false then
				--Get all bots.
				for k,v in pairs(player.GetBots()) do
					--If the bot is not on the team specified.
					if v:Team() != Team_to_Assign_Bots then
						--Some game modes are stupid so we need to kill the bot before switching team.
						--v:Kill()
						v:KillSilent()
						--Team to put the bots on.
						v:SetTeam(Team_to_Assign_Bots)
					end
				end
			end
		end)
	end
end)

--Assign all bots to a single team rather than let your game mode balance them.
if Team_to_Assign_Bots != false then
	--When a bot spawns for the first time set their team.
	function BotInitialSpawnTeamSwitch(ply)
		--If player is bot and not on the team specified.
		if ply:IsBot() and ply:Team() != Team_to_Assign_Bots then
			--Some game modes are stupid so we need to kill the bot before switching team.
			--ply:Kill()
			ply:KillSilent()
			--Team to put the bots on.
			ply:SetTeam(Team_to_Assign_Bots)
		end
	end
	hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn-BotInitialTeamSwitch", BotInitialSpawnTeamSwitch)

	--When a bot spawns set their team.
	function BotTeamSwitch(ply)
		--If player is bot and not on the team specified.
		if ply:IsBot() and ply:Team() != Team_to_Assign_Bots then
			--Some game modes are stupid so we need to kill the bot before switching team.
			--ply:Kill()
			ply:KillSilent()
			--Team to put the bots on.
			ply:SetTeam(Team_to_Assign_Bots)
		end
	end
	hook.Add("PlayerSpawn", "PlayerSpawn-BotTeamSwitch", BotTeamSwitch)
end

--When player connects remove a bot and give them the bots slot.
function ConnectKillBot(ply)
	--[[
	--Select a random bot.
	RandomBot = player.GetBots()[math.random(1,#player.GetBots())]
	--If player is not a bot.
	if !ply:IsBot() then
		--Goodbye bot.
		RandomBot:Kick()
	end
	]]

	--If player connecting is not a bot.
	if !ply:IsBot() then

		--Set distance.
		local distance = 0
		--Set target as nil.
		local target

		--For all bots.
		for k,v in pairs(player.GetBots()) do
			--If player is dead.
			if v:Health() <= 0 then
				--Kick the dead bot.
				v:Kick()
				--Prevent the script from executing any further.
				return
			else --Else no bots are dead.
				--For all human players.
				for p,ply in pairs(player.GetHumans()) do
					--If not self. (No point in checking our own position.)
					if ply:GetPos() != v:GetPos() then
						--If the length of the next target is more than the last length found (target is further away than previous).
						if ((v:GetPos() - ply:GetPos()):Length() > distance) then
							--Set distance to the length furthest player.
							distance = (v:GetPos() - ply:GetPos()):Length()
							--Set new found target.
							target = v
						end
					end
				end
			end
		end

		--If a target is set.
		if target != nil then
			--Kick the bot furthest away.
			target:Kick()
		end
	end
end
hook.Add("PlayerAuthed", "PlayerAuthed-KillBot", ConnectKillBot)

--For when a player leaves add a bot to fill their slot.
hook.Add("PlayerDisconnected", "PlayerDisconnected-SpawnBot", function(ply)

	--Need to run a check on player count. (Only create bots on player count avaliable.)
	if #player.GetHumans() + #player.GetBots() <= game.MaxPlayers() - Number_of_Free_Slots and ply:IsBot() then
		--Spawn / create a bot.
		player.CreateNextBot(""..Bot_Identifier..""..RandomName().."")
		--RunConsoleCommand("bot")

		--Assign all bots to a single team rather than let your game mode balance them.
		if Team_to_Assign_Bots != false then
			--Get all bots.
			for k,v in pairs(player.GetBots()) do
				--If the bot is not on the team specified.
				if v:Team() != Team_to_Assign_Bots then
					--Some game modes are stupid so we need to kill the bot before switching team.
					--v:Kill()
					v:KillSilent()
					--Team to put the bots on.
					v:SetTeam(Team_to_Assign_Bots)
				end
			end
		end
	end

	--Check the player leaving is not a bot.	
	if !ply:IsBot() then
		--Prevent admin's names being used by bots.
		if !ply:IsAdmin() then

			--Need to run a check on player count. (Only create bots on player count avaliable.)
			if #player.GetHumans() + #player.GetBots() <= game.MaxPlayers() - Number_of_Free_Slots then

				--If player names are to be saved then.
				if Save_Player_Names != false then
					--Spawn bot in the place of the player that just left and steal the players name :)
					player.CreateNextBot(""..Bot_Identifier..""..ply:Nick().."")
					--RunConsoleCommand("bot")
				else --Not to be saved so give random.
					--Create a bot and give a random name.
					player.CreateNextBot(""..Bot_Identifier..""..RandomName().."")
					--RunConsoleCommand("bot")
				end

				--Assign all bots to a single team rather than let your game mode balance them.
				if Team_to_Assign_Bots != false then
					--Get all bots.
					for k,v in pairs(player.GetBots()) do
						--If the bot is not on the team specified.
						if v:Team() != Team_to_Assign_Bots then
							--Some game modes are stupid so we need to kill the bot before switching team.
							--v:Kill()
							v:KillSilent()
							--Team to put the bots on.
							v:SetTeam(Team_to_Assign_Bots)
						end
					end
				end
			end

			--If player names are to be saved then.
			if Save_Player_Names != false then
				--Add the player name to our database for future use.
				AddNametoDatabase(""..ply:Nick().."")
			end

		else --Else player was admin

			--Need to run a check on player count. (Only create bots on player count avaliable.)
			if #player.GetHumans() + #player.GetBots() <= game.MaxPlayers() - Number_of_Free_Slots then

				--Create a bot and give a random name.
				player.CreateNextBot(""..Bot_Identifier..""..RandomName().."")
				--RunConsoleCommand("bot")

				--Assign all bots to a single team rather than let your game mode balance them.
				if Team_to_Assign_Bots != false then
					--Get all bots.
					for k,v in pairs(player.GetBots()) do
						--If the bot is not on the team specified.
						if v:Team() != Team_to_Assign_Bots then
							--Some game modes are stupid so we need to kill the bot before switching team.
							--v:Kill()
							v:KillSilent()
							--Team to put the bots on.
							v:SetTeam(Team_to_Assign_Bots)
						end
					end
				end
			end
		end
	end
end)

--Timer on loop to fix any random problems / errors given of by external addons and to ensure player count stays as high as possible.
--This timer is not necessary but i put it here as a safety precaution.
timer.Create("Timer-Loop-Spoof-Player-Count", Bot_Timer_Check, 0, function()
	--Need to run a check on player count. (Only create bots on player count avaliable.)
	if #player.GetHumans() + #player.GetBots() <= game.MaxPlayers() - Number_of_Free_Slots then
		--Current number of players on the server. (Both Human and Bots.)
		CurrentPlayerCount = #player.GetHumans() + #player.GetBots()
		--Make the number of bots to create the MaxPlayer count take away free slots.
		FillSlots = game.MaxPlayers() - Number_of_Free_Slots

		--For each number.
		for i=1, FillSlots - CurrentPlayerCount do
			--Spawn / create a bot.
			player.CreateNextBot(""..Bot_Identifier..""..RandomName().."")
			--RunConsoleCommand("bot")
		end

		--Assign all bots to a single team rather than let your game mode balance them.
		if Team_to_Assign_Bots != false then
			--Get all bots.
			for k,v in pairs(player.GetBots()) do
				--If the bot is not on the team specified.
				if v:Team() != Team_to_Assign_Bots then
					--Some game modes are stupid so we need to kill the bot before switching team.
					--v:Kill()
					v:KillSilent()
					--Team to put the bots on.
					v:SetTeam(Team_to_Assign_Bots)
				end
			end
		end
	end
end)
