-- This uses MessagingService, DataStores, Webhooks, etc.
-- This is an older source that i made, i cannot promise you the most beautifully looking code here. However, it is greatly optimized and pretty good for usage.

local Remote = game.ReplicatedStorage.Admin
local Admins = {}
local Commands = {
	"kick",
	"ban",
	"tempban",
	"walkspeed",
	"jumppower",
	"setrope",
	"fly",
	"health",
	"unban",
	"teleport",
	"shutdown",
	"setair",
	"globalserverannouncement",
	"localserverannouncement",
	"globalpoll",
	"unserverban",
	"disabletag",
	"enabletag",
	"serverban",
}



local Fliter = game:GetService("Chat")
local Perm_Banned = game:GetService("DataStoreService"):GetDataStore("BANNED_DS_1")
local Temp_Banned = game:GetService("DataStoreService"):GetDataStore("TEMPBANNED_DS_1")
local Moderators = game:GetService("DataStoreService"):GetDataStore("ADMIN_LIST")
local Ban = nil
local TempBan = nil
local Data_store = game:GetService("DataStoreService")
Poll_Data_Store = Data_store:GetDataStore("Poll")

local Server_Message =  game.ServerScriptService.General_Scripts.Send_Server_Messages.Message
local MS = game:GetService("MessagingService")

local proxy = require(script.WebhookService)
local votekickUrl = ""
local banUrl = ""
local http = game:GetService("HttpService")

Remote.OnServerEvent:Connect(function(Player, Command, ...)
	if table.find(Admins, Player.UserId) then
		local Split = string.split(tostring(Command), " ")
		if table.find(Commands, Split[1]) then
			local Cmd = Split[1]
			local Str = Split[2]
			local Split_3 = Split[3]
			table.remove(Split, 1)
			table.remove(Split, 1)
			if Cmd == "tempban" then
				table.remove(Split, 1)
			end
			local Reason = table.concat(Split, " ")
			local isName = true
			if string.len(tostring(tonumber(Str))) > 3 then
				isName = false
			end
			if Cmd == "kick" then
				if isName then
		    	    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
						if v.Name == Str then
							v:Kick(Reason)
							game.ReplicatedStorage.Send_Server_Messages:FireAllClients(v.Name.." has been kicked by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
							proxy:createEmbed(banUrl, "Kick Issued","\nUser kicked: **"..v.Name.."**\nUser ID: "..v.UserId.."\nReason: "..Reason.."\n\nModerator: "..Player.Name)
						end
					end
				else
					if not isName then
						-- // Attempt One
						local Found = false
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v.UserId == tonumber(Str) then
								v:Kick(Reason)
								game.ReplicatedStorage.Send_Server_Messages:FireAllClients(v.Name.." has been kicked by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
								proxy:createEmbed(banUrl, "Kick Issued","\nUser kicked: **"..v.Name.."**\nUser ID: "..v.UserId.."\nReason: "..Reason.."\n\nModerator: "..Player.Name)
								Found = true
								break
							end
						end
						if not Found then
						    -- // Attempt Two
							game:GetService("MessagingService"):PublishAsync("Admin_Event", {Command = "kick", UserID = tonumber(Str), Rsn = Reason})
						end
					end
				end
			elseif Cmd == "ban" then
				if isName then
					for i, v in pairs(game:GetService("Players"):GetPlayers()) do
						if v.Name == Str then
							local Success = Ban(v)
							if Success then
								v:Kick(Reason)
								game.ReplicatedStorage.Send_Server_Messages:FireAllClients(v.Name.." has been permanently BANNED by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
								proxy:createEmbed(banUrl, "Perma Ban Issued","\nUser banned: **"..v.Name.."**\nUser ID: "..v.UserId.."\nReason: "..Reason.."\n\nModerator: "..Player.Name)
							end
						end
					end
				else
					if not isName then
						-- // Attempt One
						local Found = false
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v.UserId == tonumber(Str) then
								local Success = Ban(v)
								if Success then
									v:Kick(Reason)
									game.ReplicatedStorage.Send_Server_Messages:FireAllClients(v.Name.." has been permanently BANNED by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
									proxy:createEmbed(banUrl, "Perma Ban Issued","\nUser banned: **"..v.Name.."**\nUser ID: "..v.UserId.."\nReason: "..Reason.."\n\nModerator: "..Player.Name)
								end
								Found = true
								break
							end
						end
						if not Found then
							-- // Attempt Two
							game:GetService("MessagingService"):PublishAsync("Admin_Event", {Command = "kick", UserID = tonumber(Str), Rsn = Reason})
							
							-- // Attempt Three (in case none of the above worked, offline ban the user)
							local Success, Result = pcall(function()
								game.ReplicatedStorage.Send_Server_Messages:FireAllClients(Str.." has been permanently BANNED by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
								proxy:createEmbed(banUrl, "*Offline* Perma Ban Issued","\nUser banned: **"..Str.."**\n\nModerator: "..Player.Name)
								return Perm_Banned:SetAsync(tonumber(Str), true)
							end)
						end
					end
				end
			elseif Cmd == "unban" then
				if not isName then
					local Success, Result = pcall(function()
						local user = game.Players:GetNameFromUserIdAsync(Str)
						if user then
							proxy:createEmbed(banUrl, "User unbanned","\nUserId unbanned: **"..Str.."**\nUsername: "..user.."\n\nModerator: "..Player.Name)
						else
							proxy:createEmbed(banUrl, "User unbanned","\nUser unbanned: **"..Str.."**\n\nModerator: "..Player.Name)
						end
						return Perm_Banned:SetAsync(tonumber(Str), false)
					end)
					local Success, Result = pcall(function()
						return Temp_Banned:SetAsync(tonumber(Str), false)
					end)
				end
			elseif Cmd == "tempban" then
				if isName then
					for i, v in pairs(game:GetService("Players"):GetPlayers()) do
						if v.Name == Str then
							local Success = TempBan(v, tonumber(Split_3) or 60)
							if Success then
								v:Kick("You have been temporarily banned for "..Split_3..' seconds for the reason: "'..Reason..'".'.."\nIf you think this ban is unjustified, please appeal in our community server.")
								game.ReplicatedStorage.Send_Server_Messages:FireAllClients(v.Name.." has been temporarily banned by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
								proxy:createEmbed(banUrl, "Temp-Ban Issued","\nUser banned: **"..v.Name.."**\nUser Id: "..v.UserId.."\nReason: "..Reason.."\nLength: "..Split_3.." seconds\n\nModerator: "..Player.Name)
							end
						end
					end
				else
					if not isName then
						-- // Attempt One
						local Found = false
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v.UserId == tonumber(Str) then
								local Success = TempBan(v, tonumber(Split_3) or 60)
								if Success then
									v:Kick(Reason)
									game.ReplicatedStorage.Send_Server_Messages:FireAllClients(v.Name.." has been temporarily banned by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
									proxy:createEmbed(banUrl, "Temp-Ban Issued","\nUser banned: **"..v.Name.."**\nUser Id: "..v.UserId.."\nReason: "..Reason.."\nLength: "..Split_3.." seconds\n\nModerator: "..Player.Name)
								end
								Found = true
								break
							end
						end
						if not Found then
							-- // Attempt Two
							game:GetService("MessagingService"):PublishAsync("Admin_Event", {Command = "tempban", UserID = tonumber(Str), Rsn = Reason, Time = tostring(Split_3)})

							-- // Attempt Three (in case none of the above worked, offline ban the user)
							local Success, Result = pcall(function()
								proxy:createEmbed(banUrl, "*Offline* Temp-Ban Issued","\nUser banned: **"..Str.."**\nReason: "..Reason.."\nLength: "..Split_3.." seconds\n\nModerator: "..Player.Name)
								game.ReplicatedStorage.Send_Server_Messages:FireAllClients(Str.." has been temporarily banned by The Divine Hammer holder "..Player.Name.." for "..Reason..".",Color3.fromRGB(184, 0, 3))
								return Temp_Banned:SetAsync(tonumber(Str), {Time = tostring(Split_3), Banned = tostring(tick())})
							end)
						end
					end
				end
			elseif Cmd == "walkspeed" then
				if Str == "me" then
					pcall(function()
						Player.Character.Humanoid.WalkSpeed = tonumber(Split_3)
						Player.Character.Original_Speed.Value =  tonumber(Split_3)
					end)
				else
					if Str == "others" then
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v ~= Player then
								pcall(function()
									v.Character.Humanoid.WalkSpeed = tonumber(Split_3)
									v.Character.Original_Speed.Value =  tonumber(Split_3)
								end)
							end
						end
					else
						if Str == "all" then
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								pcall(function()
									v.Character.Humanoid.WalkSpeed = tonumber(Split_3)
									v.Character.Original_Speed.Value =  tonumber(Split_3)
								end)
							end
						else
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								if v.Name == Str then
									pcall(function()
										v.Character.Humanoid.WalkSpeed = tonumber(Split_3)
										v.Character.Original_Speed.Value =  tonumber(Split_3)
									end)
								end
							end
						end
					end
				end
			elseif Cmd == "jumppower" then
				if Str == "me" then
					local s, e = pcall(function()
						Player.Character.Humanoid.JumpPower = tonumber(Split_3)
						Player.Character.Original_Jump.Value = tonumber(Split_3)
					end)
				else
					if Str == "others" then
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v ~= Player then
								pcall(function()
									v.Character.Humanoid.JumpPower = tonumber(Split_3)
									v.Character.Original_Jump.Value = tonumber(Split_3)
								end)
							end
						end
					else
						if Str == "all" then
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								pcall(function()
									v.Character.Humanoid.JumpPower = tonumber(Split_3)
									v.Character.Original_Jump.Value = tonumber(Split_3)
								end)
							end
						else
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								if v.Name == Str then
								    pcall(function()
										v.Character.Humanoid.JumpPower = tonumber(Split_3)
										v.Character.Original_Jump.Value = tonumber(Split_3)
									end)
								end
							end
						end
					end
				end
			elseif Cmd == "setrope" then
				if Str == "me" then
					pcall(function()
						game.ReplicatedStorage.Rope_Amounts[Player.Name].Value = tonumber(Split_3)
					end)
				else
					if Str == "others" then
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v ~= Player then
								pcall(function()
									game.ReplicatedStorage.Rope_Amounts[v.Name].Value = tonumber(Split_3)
								end)
							end
						end
					else
						if Str == "all" then
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								pcall(function()
									game.ReplicatedStorage.Rope_Amounts[v.Name].Value = tonumber(Split_3)
								end)
							end
						else
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								if v.Name == Str then
									pcall(function()
										game.ReplicatedStorage.Rope_Amounts[v.Name].Value = tonumber(Split_3)
									end)
								end
							end
						end
					end
				end
			elseif Cmd == "health" then
				if Str == "me" then
					pcall(function()
						Player.Character.Humanoid.MaxHealth = tonumber(Split_3)
						Player.Character.Humanoid.Health = tonumber(Split_3)
					end)
				else
					if Str == "others" then
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v ~= Player then
								pcall(function()
									v.Character.Humanoid.MaxHealth = tonumber(Split_3)
									v.Character.Humanoid.Health = tonumber(Split_3)
								end)
							end
						end
					else
						if Str == "all" then
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								pcall(function()
									v.Character.Humanoid.MaxHealth = tonumber(Split_3)
									v.Character.Humanoid.Health = tonumber(Split_3)
								end)
							end
						else
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								if v.Name == Str then
									pcall(function()
										v.Character.Humanoid.MaxHealth = tonumber(Split_3)
										v.Character.Humanoid.Health = tonumber(Split_3)
									end)
								end
							end
						end
					end
				end
			elseif Cmd == "teleport" then
				
	
				print("Str is "..Str)
				print("Split_3 is "..Split_3)
				--[[if Str and (Split_3 ~= " " or Split_3) then -- teleport other player to other player
					print("p2p")
					local teleporter1 = game.Players:FindFirstChild(Str)
					pcall(function()
						teleporter1.Character:MoveTo(game.Workspace.Players[Split_3].PrimaryPart.Position)
					end)
				else -- normal teleport -- tp (player)
					print("normal teleport")
					pcall(function()
						Player.Character:MoveTo( game.Workspace.Players[Str].PrimaryPart.Position  )
					end)
				end--]]
				if Str and not game.Players:FindFirstChild(Split_3) --[[(not Split_3 or Split_3 == " " or Split_3 == "" or Split_3 == "  ")--]] then
					print("normal teleport")
					Player.Character:MoveTo(game.Workspace.Players[Str].PrimaryPart.Position)
				else
					print("p2p")
					local teleporter1 = game.Players:FindFirstChild(Str)
					pcall(function()
						teleporter1.Character:MoveTo(game.Workspace.Players[Split_3].PrimaryPart.Position)
					end)
				end
			
		
				
			elseif Cmd == "shutdown" then
				
				pcall(function()
					for number, Kick_Player in pairs(game.Players:GetChildren()) do
						if Kick_Player ~= Player then
							Kick_Player:Kick("Admin has shutdown server ¯\_(ツ)_/¯ ")
						end
						
						
					end
				end)
				
				
				
			elseif Cmd == "setair" then
				if Str == "me" then
					pcall(function()
						game.ReplicatedStorage.player_air[Player.Name].Value = tonumber(Split_3)
						game.ReplicatedStorage.Player_Values[Player.Name].Max_Air.Value = tonumber(Split_3)
					end)
				else
					if Str == "others" then
						for i, v in pairs(game:GetService("Players"):GetPlayers()) do
							if v ~= Player then
								pcall(function()
									game.ReplicatedStorage.player_air[v.Name].Value = tonumber(Split_3)
									game.ReplicatedStorage.Player_Values[v.Name].Max_Air.Value = tonumber(Split_3)
								
								end)
							end
						end
					else
						if Str == "all" then
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								pcall(function()
									game.ReplicatedStorage.player_air[v.Name].Value = tonumber(Split_3)
									game.ReplicatedStorage.Player_Values[v.Name].Max_Air.Value = tonumber(Split_3)
								end)
							end
						else
							for i, v in pairs(game:GetService("Players"):GetPlayers()) do
								if v.Name == Str then
									pcall(function()
										game.ReplicatedStorage.player_air[v.Name].Value = tonumber(Split_3)
										game.ReplicatedStorage.Player_Values[v.Name].Max_Air.Value = tonumber(Split_3)
									end)
								end
							end
						end
					end
				end
			elseif Cmd == "globalserverannouncement" then
				local Published_String = Str
				for number = 1,100 do
					print(Split[number])
					if Split[number] ~= nil then
						Published_String = Published_String .. " " ..   Split[number]
					end
				end
				MS:PublishAsync('Announcement', {PlrName = Player.Name, Message =  Fliter:FilterStringForBroadcast(Published_String,Player)} )
			elseif Cmd == "localserverannouncement" then
				local Published_String = Str
				for number = 1,100 do
					print(Split[number])
					if Split[number] ~= nil then
						Published_String = Published_String .. " " ..   Split[number]
					end
				end
				Server_Message:Fire(Fliter:FilterStringForBroadcast(Published_String,Player), Color3.fromRGB(255, 255, 0), true)
			elseif Cmd == "globalpoll" then
				local Number_Of_Options = Str
				local Options = {}
				table.insert(Split,(0),Split_3)
				print(Number_Of_Options)
				print(Split)
				for number = 1,Number_Of_Options do
					print(Split[number])
					table.insert(Options,Split[number])
				end
				local Published_String = ""
				for number = Number_Of_Options + 1,100 do
					print(Split[number])
					if Split[number] ~= nil then
						Published_String = Published_String .. " " ..   Split[number]
					end
				end
				
				for Position, Number in pairs(Options) do
					-- position is the key
					-- number is the number of votes we increase it by
					Poll_Data_Store:SetAsync(Position,0)

				end
				
				print(Options,Published_String)
				MS:PublishAsync('Global_Poll', {Options = Options, Poll_Message =  Published_String})
			elseif Cmd == "unserverban" then
				game.ServerScriptService.Player_Scripts["Player_left/joined"].player_joins.unServerBan:Fire(Str, false)
				print(Str.." has been unserverbanned! (alledgedly)")
				game.ReplicatedStorage.Send_Server_Messages:FireClient(Player, "[LOCAL] "..Str.." has been unserverbanned!",Color3.fromRGB(39, 118, 0))
			elseif Cmd == "disabletag" then
				game.ServerScriptService.Un_Needed_For_Normal_Play.Chat_Tags.Change:Fire(Player.Name, "disable")
			elseif Cmd == "enabletag" then
				game.ServerScriptService.Un_Needed_For_Normal_Play.Chat_Tags.Change:Fire(Player.Name, "enable")
			elseif Cmd == "serverban" then
				--print("HIHIHIHI")
				game.ServerScriptService.Player_Scripts["Player_left/joined"].player_joins.unServerBan:Fire(Str, true)
				print(Str.." has been serverbanned")
				game.ReplicatedStorage.Send_Server_Messages:FireAllClients(Str.." has been serverbanned by The Divine Hammer holder "..Player.Name..".",Color3.fromRGB(184, 0, 3))
				proxy:createEmbed(banUrl, "Serverban Issued","\nUser serverbanned: **"..Str.."**\n\nModerator: "..Player.Name)
			end
		end
	end
end)

local function addModerator(Player)
	coroutine.wrap(function() -- // dont yield current thread, create another one
		local PlayerGui = Player:WaitForChild("PlayerGui", math.huge)
		local Menu = script.Admin_Bar:Clone()
		Menu.ResetOnSpawn = false
		Menu.Parent = PlayerGui
		table.insert(Admins, Player.UserId)
	end)()
end

local function onPlayerAdded(Player)
	local Success, Result = pcall(function()
		return Perm_Banned:GetAsync(Player.UserId)
	end)
	if Success and Result then
		Player:Kick([[You appear to have been permanently banned from Flooded Area. If you wish to appeal, please join the community server and open a ban appeal ticket.]])
	end
	local Success1, Result1 = pcall(function()
		return Temp_Banned:GetAsync(Player.UserId)
	end)
	if Success1 and typeof(Result1) == "table" then
		local Time = Result1.Time
		local Banned = Result1.Banned
		local Remaining = tonumber(Time) - (tick() - tonumber(Banned))
		if tonumber(Remaining) > 0 then
			Player:Kick([[You appear to have been temporarily banned from Flooded Area. If you wish to appeal, please join the community server and open a ban appeal ticket.
			Time remaining: ]] .. tostring(math.floor(Remaining)) .. " seconds")
		else
			local _, _ = pcall(function()
				return Temp_Banned:SetAsync(Player.UserId, false)
			end)
		end
	end
	local s, r = pcall(function()
		return Moderators:GetAsync(Player.UserId)
	end)
	if s and r then
	    addModerator(Player)
	end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)

Ban = function(Player)
	local Success, Result = pcall(function()
		return Perm_Banned:SetAsync(Player.UserId, true)
	end)
	if Success then
		return true
	else
		warn(Result)
	end
	return false
end

TempBan = function(Player, Time)
	local Success, Result = pcall(function()
		return Temp_Banned:SetAsync(Player.UserId, {Time = tostring(Time), Banned = tostring(tick())})
	end)
	if Success then
		return true
	else
		warn(Result)
	end
	return false
end

local Success, Result = pcall(function()
	return game:GetService("MessagingService"):SubscribeAsync("Admin_Event", function(Message)
		local Data = Message.Data

		local Cmd = Data.Command
		local ID = Data.UserID
		local Reason = Data.Rsn
		
		if Cmd == "kick" then
		    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
			    if v.UserId == ID then
				    v:Kick(Reason)
				    break
				end
			end
		elseif Cmd == "ban" then
			for i, v in pairs(game:GetService("Players"):GetPlayers()) do
				if v.UserId == ID then
					local Success = Ban(v)
					if Success then
						v:Kick(Reason)
					end
					break
				end
			end
		elseif Cmd == "tempban" then
			for i, v in pairs(game:GetService("Players"):GetPlayers()) do
				if v.UserId == ID then
					v:Kick(Reason)
					break
				end
			end
		end
	end)
end)


MS:SubscribeAsync('Announcement', function(Args)
	Server_Message:Fire("[GLOBAL ADMIN ANNOUNCEMENT] " .. Args.Data.PlrName .. ": " .. Args.Data.Message, Color3.fromRGB(255, 255, 0), true)
end)

MS:SubscribeAsync('Global_Poll', function(Args)
	game.ServerScriptService.Un_Needed_For_Normal_Play.Poll.Start_Poll:Invoke(Args.Data.Poll_Message,  Args.Data.Options)
end)
