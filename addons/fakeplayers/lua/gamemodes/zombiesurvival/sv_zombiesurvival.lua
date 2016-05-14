--[[
Credits :
C0nw0nk

Github : https://github.com/C0nw0nk/Garrys-Mod-Fake-Players

Copyright : 2016 Conor Mcknight

This script was released under default Copyright Law.
For those who want to know what that means for your use of this script read the following : http://choosealicense.com/no-license/
]]
	--[[
	This script is incomplete it has allot of missing functions and TODO tasks.
	But i was asked for it so this is a early version.
	
	Also take not this script is realy unoptimized as it currently sits.
	
	I have not done localizing / caching of values so you will find many functions and values will run,
	Multiple un-needed number of times. When realy they should run once but i will fix that when i update this.
	]]

	--[[
	Zombie Survival Settings here.
	]]

	--Setting to prevent bots being put on the zombie volunteer list.
	--Set true to enable | false to disable.
	Prevent_Bots_Volunteer = false

	--Make starting zombies are bots only.
	--Set true to enable | false to disable.
	Bots_Volunteer_Only = false

	--Setting to prevent bots becomming the boss zombie.
	--Set true to enable | false to disable.
	Prevent_Bots_Boss_Zombie = true

	--[[
	End Custom Zombie Survival Settings.
	]]

	--If bots are all to be put on spectator team we make sure they do not be zombie volunteers automaticly.
	if Team_to_Assign_Bots == TEAM_SPECTATOR then
		Prevent_Bots_Volunteer = true
	end

	--Remove bots from being selected for starting zombies.
	function RemoveBotsFromZombieList()
		--Bot Players only.
		local BotPlayers = player.GetBots()
		--For each Zombie Volunteer.
		for i=1, #BotPlayers do
			--Remove player from volunteer table.
			table.remove(GAMEMODE.ZombieVolunteers, table.KeyFromValue(GAMEMODE.ZombieVolunteers, GAMEMODE.ZombieVolunteers[i]))
		end
	end
	--print(SortZombieSpawnDistances(player.GetBots())

	--Remove humans from being selected for starting zombies.
	function RemoveHumansFromZombieList()
		--Human Players only.
		local HumanPlayers = player.GetHumans()
		--For each Zombie Volunteer.
		for i=1, #HumanPlayers do
			--Remove player from volunteer table.
			table.remove(GAMEMODE.ZombieVolunteers, table.KeyFromValue(GAMEMODE.ZombieVolunteers, GAMEMODE.ZombieVolunteers[i]))
		end
	end
	--print(SortZombieSpawnDistances(player.GetHumans()))

	--Remove Bots from being Boss zombie.
	function RemoveBotsFromBossList()
		--For all bots.
		for _,pl in pairs(player.GetBots()) do
			--If bot is on zombie team.
			if pl:Team() == TEAM_UNDEAD then
				--For each team damaged in table.
				for k,v in pairs(pl.DamageDealt) do
					--Set the damage dealt back to 0.
					pl.DamageDealt[k] = 0
				end
			end
		end
	end

	--If Bots are not to be volunteer zombies or the user wants all fake players to be on a single team (Specificly spectator.).
	if Prevent_Bots_Volunteer == true or Team_to_Assign_Bots == TEAM_SPECTATOR then
		hook.Add("Think", "Think-ZombieSurvival-GameMode-Support", function()
			--Make sure wave is not active and it is wave 0 selection of who will be zombie.
			if GetGlobalBool("waveactive") == false and GetGlobalInt("wave") == 0 then
				--Run function to remove bots from zombie list.
				RemoveBotsFromZombieList()
			else --As soon as done disable self hook.
				hook.Remove("Think", "Think-ZombieSurvival-GameMode-Support")
			end
		end)
	elseif Bots_Volunteer_Only == true then --Else if starting zombie volunteers are to be bots only.
		hook.Add("Think", "Think-ZombieSurvival-GameMode-Support", function()
			--Make sure wave is not active and it is wave 0 selection of who will be zombie.
			if GetGlobalBool("waveactive") == false and GetGlobalInt("wave") == 0 then
				--Run function to remove humans from zombie list.
				RemoveHumansFromZombieList()
			else --As soon as done disable self hook.
				hook.Remove("Think", "Think-ZombieSurvival-GameMode-Support")
			end
		end)
	end

	--Random zombie class to change to.
	function RandomZombieClass()
		--Random Zombies Table.
		RandomZombieClassTable = {}

		--For each Zombie Class.
		for i=1, #GAMEMODE.ZombieClasses do
			--Add the name to our table
			table.insert(RandomZombieClassTable, GAMEMODE.ZombieClasses[i].Name)
			--Remove bosses, hidden zombie classes and zombie classes not active on wave number.
			if GAMEMODE.ZombieClasses[i].Boss == true or GAMEMODE.ZombieClasses[i].Hidden == true or GAMEMODE.ZombieClasses[i].Wave > GetGlobalInt("wave") then
				--Remove the Zombie from our table.
				table.remove(RandomZombieClassTable, table.KeyFromValue(RandomZombieClassTable, GAMEMODE.ZombieClasses[i].Name))
			end
			--If the class has Infliction to unlock after a certain number of humans die. and if that infliction number has been reached. (The percentage of humans turned zombie.)
			if GAMEMODE.ZombieClasses[i].Infliction and gamemode.Call("CalculateInfliction") >= GAMEMODE.ZombieClasses[i].Infliction then
				--Add the name to our table
				table.insert(RandomZombieClassTable, GAMEMODE.ZombieClasses[i].Name)
			end
		end

		--Randomize the output.
		output = table.Random(RandomZombieClassTable)

		return output
	end

	--Bone position refrence numbers and name lookups to what the actual target is. Where we will aim on the players hitbox.
	--[[timer.Simple(16, function()
		for i = 0, 128 do --An entity cannot have more than 128 bones.
			print(i.." = "..Entity(1):GetBoneName(i).."")
		end
	end)]]
	--TODO : Function for nearest bone target.

	--Aimbot for Bots random player to aim at. (Building this was so much fun!!! :)!!!)
	function RandomPlayerAim(ply)
		--Random Players Aimbot Table.
		RandomPlayerAimTable = {}

		--For all players. Don't aim for players on same team or dead.
		for k,v in pairs(player.GetAll()) do
			--Put player info into table.
			table.insert(RandomPlayerAimTable, v)
			--If player self and random player are on same team. or dead.
			if ply:Team() == TEAM_HUMAN and v:Team() == TEAM_HUMAN or ply:Health() <= 0 then
				--Remove random player from table.
				table.remove(RandomPlayerAimTable, table.KeyFromValue(RandomPlayerAimTable, v))
			end
			--If player self and random player are on same team. or dead.
			if ply:Team() == TEAM_UNDEAD and v:Team() == TEAM_UNDEAD or ply:Health() <= 0 then
				--Remove random player from table.
				table.remove(RandomPlayerAimTable, table.KeyFromValue(RandomPlayerAimTable, v))
			end
		end

		--Aimbot to target cloesest / nearest player.
		--Set distance as the largest number we can.
		local distance = math.huge
		--Set target as nil
		local target
		--For all players left in the table.
		for k,v in pairs(RandomPlayerAimTable) do
			--If player still alive.
			if v:Health() > 0 then
				--If the length of the next target is less the last length found (target is closer than previous).
				if ((ply:GetPos() - v:GetPos()):Length() < distance) then
					--Set distance to the length of the closest / nearest player.
					distance = (ply:GetPos() - v:GetPos()):Length()
					--Set new found target.
					target = v
				end
			end
		end

		--Lock aim output as nearest player.
		output = target

		--If there is no target to aim for aim at self.
		if target == nil then
			--Output self.
			output = ply
		end

		return output
	end
	--[[ Usage :
	if RandomPlayerAim(ply):GetClass() == "player" then
	end
	if RandomPlayerAim(ply):GetClass() != "player" then
	end
	]]

	--Put all door ways ladders etc into table to walk from one point to the next.
	function Tables()
		--TODO : Put all doors ladders etc anything that can be a marker for a bot to walk from one point to the next.
	end

	--Path tracker. To let bots take a route a human went to climb up somewhere/follow.
	function RecentPath()
	end

	--For when players weapon runs out of ammo switch them to a weapon that has ammo or a melee weapon.
	function SwitchToRandomWeapon(ply)
		--Random Weapons Table.
		SwitchToRandomWeaponTable = {}
		--Melee weapons.
		SwitchToRandomMeleeWeaponTable = {}

		--For all the weapons the player is carrying.
		local lol = ply:GetWeapons()
		for i=1, #lol do
			--Put all weapons into table.
			table.insert(SwitchToRandomWeaponTable, lol[i]:GetClass())
			--If weapon has no more ammo / clips left.
			if ply:GetAmmoCount(ply:GetWeapon(lol[i]:GetClass()):GetPrimaryAmmoType()) <= 0 then
				--Remove the weapon from the table. (No point switching to a weapon thats empty.)
				table.remove(SwitchToRandomWeaponTable, table.KeyFromValue(SwitchToRandomWeaponTable, lol[i]:GetClass()))
			end
			--If melee weapon.
			if ply:GetWeapon(lol[i]:GetClass()).IsMelee then
				--Put all melee weapons into table.
				table.insert(SwitchToRandomMeleeWeaponTable, lol[i]:GetClass())
			end
		end

		--If the table is empty then set the weapon as a random melee weapon.
		if table.Count(SwitchToRandomWeaponTable) <= 0 then
			--Randomize the output.
			output = table.Random(SwitchToRandomMeleeWeaponTable)
		else --Table was not empty to set the weapon output as a random firearm.
			--Randomize the output.
			output = table.Random(SwitchToRandomWeaponTable)
		end

		return output
	end
	--[[ Usage :
	--If the players current weapon is not a melee weapon and completely out of ammo.
	if !player:GetActiveWeapon().IsMelee and player:GetAmmoCount(player:GetActiveWeapon():GetPrimaryAmmoType()) <= 0 then
		--Change weapon to a weapon that has ammo.
		--If no weapon they are carrying has any ammo left they will switch to a melee weapon.
		player:SelectWeapon(SwitchToRandomWeapon(player))
	end
	]]

	--For when resupply crates / box becomes useable all human bots go grab stock.
	function ResupplyUseable()
	end

	--Bots to go spend points earned in intermission.
	function IntermissionArsenalTime()
	end

	--Bots to follow human paths.
	function BotStalker(ply)
	end

	--Intermission crow to go attack cades or peck at crates etc be an annoyance basically.
	function IntermissionAnnoyances()
	end

	--[[ Zombie Class names.
	Zombie
	Bonemesh
	Classic Zombie
	Crow
	Fast Zombie Legs
	Flesh Creeper
	Fresh Dead
	Ghoul
	Giga Gore Child
	Gore Child
	Headcrab
	Nightmare
	Puke Pus
	Shade
	Super Zombie
	The Butcher
	The Tickle Monster
	Will O' Wisp
	Zombie Legs
	Zombie Torso
	Fast Headcrab
	Wraith
	Bloated Zombie
	Fast Zombie
	Poison Headcrab
	Poison Zombie
	Burster
	Chem Zombie
	]]
	--[[
	PrintTable(GAMEMODE.ZombieClasses) --Get all zombieclass names.
	]]

	--Basis for causing bots to play.
	hook.Add("StartCommand", "StartCommand-ZombieSurvival-GameMode-Support", function(ply,cmd)
		--If map is zs_obj objective.
		--if GAMEMODE.ObjectiveMap then
			--Get bots to follow / defend random players.
			--They won't make it through the objective otherwise.
		--end
		
		--if string.sub(string.lower(game.GetMap()), 1, 3) ~= "ze_" then return end
		
		--If nav file exist.
		--[[ For some point in the future. Currently for maps without nav files bots will function like this.
		if file.Exists("maps/"..game.GetMap()..".nav", "GAME") then
			--Return to do nothing and use the NextBot behave functions.
			return
		end
		]]

		--For bot players who are zombies. and alive.
		if ply:IsBot() and ply:Team() == TEAM_UNDEAD and ply:Health() > 0 then
			--Clear movements and state.
			cmd:ClearMovement()
			cmd:ClearButtons()

			--Cache player to stop function running multiple un-needed times. (This way it only runs once.)
			local AimTarget = RandomPlayerAim(ply)

			if ply:GetZombieClassTable().Name == "Zombie" then

				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--For propkilling.
				for k,v in pairs(ents.FindInSphere(ply:GetPos(), 50)) do
					--If entity is valid and both entity and player can see eachother.
					if v:IsValid() and v:Visible(ply) then
						--If prop and is nailed.
						if string.match(v:GetClass(), "prop_physics*") and v:IsNailed() then
						end
						--If prop and is not nailed. (prop kill)
						if string.match(v:GetClass(), "prop_physics*") or string.match(v:GetClass(), "func_physbox*") and !v:IsNailed() then
							--v:SetMaxHealth(9999)
							--If the prop has no velocity
							if v:GetPhysicsObject():GetVelocity():Length() <= 40 then
								--Move to prop. (Slower)
								cmd:SetForwardMove(ply:GetMaxSpeed()/2)
								--Duck / crouch.
								cmd:SetButtons(IN_DUCK)
								--Lock Aim onto Prop.
								ply:SetEyeAngles((v:GetPos() - ply:GetShootPos()):Angle())
								--Attack prop.
								cmd:SetButtons(IN_ATTACK)
							elseif v:GetPhysicsObject():GetVelocity():Length() > 40 then
								--Lock aim onto human.
								ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
							end
						end
						if string.match(v:GetClass(), "prop_door*")
						or string.match(v:GetClass(), "func_break*")
						or string.match(v:GetClass(), "prop_arsenalcrate*")
						or string.match(v:GetClass(), "prop_resupplybox*")
						or string.match(v:GetClass(), "prop_messagebeacon*")
						or string.match(v:GetClass(), "prop_gunturret*")
						or string.match(v:GetClass(), "prop_detpack*")
						or string.match(v:GetClass(), "prop_spotlamp*")
						or string.match(v:GetClass(), "prop_weapon*")
						or string.match(v:GetClass(), "prop_ammo*")
						or ply:Visible(AimTarget) then
							--Lock Aim onto Prop.
							ply:SetEyeAngles((v:GetPos() - ply:GetShootPos()):Angle())
							--Attack prop.
							cmd:SetButtons(IN_ATTACK)
							--Move to prop.
							cmd:SetForwardMove(ply:GetMaxSpeed())
						end
					end
				end
				
				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Bonemesh" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds else throw blood bomb.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				elseif ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() > ply:GetActiveWeapon().MeleeReach) then --Else if distance greater than melee reach.
					--Throw Blood Bomb at player.
					cmd:SetButtons(IN_ATTACK2)
					if (ply:KeyDown(IN_ATTACK2)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK2)))
					end
				end
			end

			if ply:GetZombieClassTable().Name == "Classic Zombie" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Crow" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
			end

			if ply:GetZombieClassTable().Name == "Fast Zombie Legs" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Flesh Creeper" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Fresh Dead" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Ghoul" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				elseif ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() > ply:GetActiveWeapon().MeleeReach) then --Else if distance greater than melee reach.
					--Throw poison.
					cmd:SetButtons(IN_ATTACK2)
					if (ply:KeyDown(IN_ATTACK2)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK2)))
					end
				end
			end

			if ply:GetZombieClassTable().Name == "Giga Gore Child" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				elseif ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() > ply:GetActiveWeapon().MeleeReach) then --Else if distance greater than melee reach.
					--Throw babies.
					cmd:SetButtons(IN_ATTACK2)
					if (ply:KeyDown(IN_ATTACK2)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK2)))
					end
				end
			end

			if ply:GetZombieClassTable().Name == "Gore Child" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Headcrab" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
				--Attack player.
				cmd:SetButtons(IN_ATTACK)
			end

			if ply:GetZombieClassTable().Name == "Nightmare" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Puke Pus" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Shade" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Super Zombie" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "The Butcher" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "The Tickle Monster" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Will O' Wisp" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
			end

			if ply:GetZombieClassTable().Name == "Zombie Legs" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
	
				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Zombie Torso" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Fast Headcrab" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
				--Attack player.
				cmd:SetButtons(IN_ATTACK)
			end

			if ply:GetZombieClassTable().Name == "Wraith" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
				--Lock speed so in stealth.
				cmd:SetButtons(IN_SPEED)
				if (ply:KeyDown(IN_SPEED)) then
					cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_SPEED)))
				end

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Bloated Zombie" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				elseif ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() > ply:GetActiveWeapon().MeleeReach) then --Else if distance greater than melee reach.
					--Throw poison.
					cmd:SetButtons(IN_ATTACK2)
					if (ply:KeyDown(IN_ATTACK2)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK2)))
					end
				end
			end

			if ply:GetZombieClassTable().Name == "Fast Zombie" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				cmd:SetViewAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds else pounce attack.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				elseif ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() > ply:GetActiveWeapon().MeleeReach) then --Else if distance greater than melee reach.
					--Leap/Pounce Attack player.
					cmd:SetButtons(IN_ATTACK2)
					if (ply:KeyDown(IN_ATTACK2)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK2)))
					end
				end
			end

			if ply:GetZombieClassTable().Name == "Poison Headcrab" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
				--Attack player.
				cmd:SetButtons(IN_ATTACK)
				
				--TODO : If nailed props inbetween player and target spit poison.
			end

			if ply:GetZombieClassTable().Name == "Poison Zombie" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				elseif ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() > ply:GetActiveWeapon().MeleeReach) then --Else if distance greater than melee reach.
					--Throw poison.
					cmd:SetButtons(IN_ATTACK2)
					if (ply:KeyDown(IN_ATTACK2)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK2)))
					end
				end
			end

			if ply:GetZombieClassTable().Name == "Burster" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())

				--If the players enemy is within melee distance then rip them to shreds.
				if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeReach and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeReach) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if ply:GetZombieClassTable().Name == "Chem Zombie" then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
				--Chase player.
				cmd:SetForwardMove(ply:GetMaxSpeed())
			end

			--[[--For your custom zombie classes.
			--Add your custom zombie class names to make them work here.
			if ply:GetZombieClassTable().Name == "Your Zombie Class Name" then
			end
			]]

			--[[
			--The point to aim at.
			local vec1 = Vector(RandomPlayerAim(ply):GetBonePosition(1).x, RandomPlayerAim(ply):GetBonePosition(1).y, RandomPlayerAim(ply):GetBonePosition(1).z)
			--My eye position.
			local vec2 = ply:GetShootPos()
			--Lock aim onto the target.
			ply:SetEyeAngles((vec1 - vec2):Angle()) -- Sets to the angle between the two vectors
			]]
		end

		--For bot players who are humans. and alive.
		if ply:IsBot() and ply:Team() == TEAM_HUMAN and ply:Health() > 0 then
			--Clear movements and state.
			cmd:ClearMovement()
			cmd:ClearButtons()

			--If prop is nailed phase through it.
			for k,v in pairs(ents.FindInSphere(ply:GetPos(), 50)) do
				--If prop and is nailed.
				if v:IsValid() and string.match(v:GetClass(), "prop_physics*") and v:IsNailed()
				or string.match(v:GetClass(), "prop_arsenalcrate*")
				or string.match(v:GetClass(), "prop_resupplybox*")
				or string.match(v:GetClass(), "prop_messagebeacon*")
				or string.match(v:GetClass(), "prop_gunturret*")
				or string.match(v:GetClass(), "prop_spotlamp*") then
					--Jump/crouch over/under if we can.
					cmd:SetButtons(IN_JUMP)
					if (ply:KeyDown(IN_JUMP)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
					end
					if !ply:IsOnGround() then
						cmd:SetButtons(IN_DUCK)
					end
					--Suit zoom to phase / ghost through.
					cmd:SetButtons(IN_ZOOM)
					if (ply:KeyDown(IN_ZOOM)) then
						cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ZOOM)))
					end
				end
			end

			--If enemy is wraith
			if RandomPlayerAim(ply):GetZombieClassTable().Name == "Wraith" then
				--If wraith is in stalker mode.
				if RandomPlayerAim(ply):KeyDown(IN_SPEED) or RandomPlayerAim(ply):GetVelocity():Length() <= 50 then
					--Don't make eye contact. Do both of yourselves a favor and just let that handsome devil go about his business.
				end
				--If wraith is attacking.
				if RandomPlayerAim(ply):GetActiveWeapon():IsAttacking() then
				end
			end

			--If enemy is shade (Don't shoot the shade.) Kleiner logic.
			if RandomPlayerAim(ply):GetZombieClassTable().Name == "Shade" then
				--If shade is within damage distance of flashlight.
				if ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= 300) then
					--If flashlight is not on.
					if ply:FlashlightIsOn() != true then
						--Turn on flashlight.
						ply:Flashlight(true)
					end
				end
			end

			--If enemy is within melee distance of self.
			if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().MeleeRange and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().MeleeRange) then
				--Automaticly melee them.
				cmd:SetButtons(IN_ATTACK)
			end

			--If enemy is within hit distance of self. weapon_zs_fists
			if ply:GetActiveWeapon().IsMelee and ply:GetActiveWeapon().HitDistance and ((ply:GetPos() - RandomPlayerAim(ply):GetPos()):Length() <= ply:GetActiveWeapon().HitDistance) then
				--Automaticly melee them.
				cmd:SetButtons(IN_ATTACK)
			end

			--If players clip on weapon is empty.
			if ply:GetActiveWeapon():Clip1() <= 0 or ply:GetActiveWeapon():Clip2() <= 0 then
				--Reload their weapon.
				cmd:SetButtons(IN_RELOAD)
				if (ply:KeyDown(IN_RELOAD)) then
					cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_RELOAD)))
				end
			--Else clips not empty so lets shoot.
			elseif ply:GetActiveWeapon():Clip1() > 0 or ply:GetActiveWeapon():Clip2() > 0 then
				--If enemy is visible.
				if RandomPlayerAim(ply):Visible(ply) then
					--Attack player.
					cmd:SetButtons(IN_ATTACK)
				end
			end

			if !ply:GetActiveWeapon().IsMelee and ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) <= 0 then
				--Change weapon to a weapon that has ammo.
				--If no weapon they are carrying has any ammo left they will switch to a melee weapon.
				ply:SelectWeapon(SwitchToRandomWeapon(ply))
			end

			--If enemy is visible.
			if RandomPlayerAim(ply):Visible(ply) then
				--Lock aim onto player.
				ply:SetEyeAngles((RandomPlayerAim(ply):GetBonePosition(1) - ply:GetShootPos()):Angle())
			end

			cmd:SetForwardMove(-ply:GetMaxSpeed())
		end
	end)

	--If Bots are not to be on spectator team then allow them to spawn when killed.	
	if Team_to_Assign_Bots != TEAM_SPECTATOR then
		timer.Create("Timer-Loop-ZombieSurvival-GameMode-Support", 1, 0, function()
		
			--Prevent bots from becomming boss zombie.
			if GetGlobalBool("waveactive") == false and GetGlobalInt("wave") > 0 and Prevent_Bots_Boss_Zombie == true then
				RemoveBotsFromBossList()
			end
			
			--For all bots.
			for p,ply in pairs(player.GetBots()) do
				--If the bot is dead and wave is active.
				if ply:IsBot() and ply:Team() == TEAM_UNDEAD and ply:Health() <= 0 and GetGlobalBool("waveactive") == true then
					--Set the players zombie class.
					ply:SetZombieClassName(RandomZombieClass())
					--ply:SetZombieClassName("Fast Zombie")
					--Respawn the bot to go get more brains.
					--ply:Spawn()
					ply:UnSpectateAndSpawn()
				end
			end
		end)
	elseif Prevent_Bots_Boss_Zombie == true then
		timer.Create("Timer-Loop-ZombieSurvival-GameMode-Support", 1, 0, function()
			--Prevent bots from becomming boss zombie.
			if GetGlobalBool("waveactive") == false and GetGlobalInt("wave") > 0 then
				RemoveBotsFromBossList()
			end
		end)
	end
