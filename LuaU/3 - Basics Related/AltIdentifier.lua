--[[


░█▀▀▀ ░█▄─░█ ░█▀▀█ ▀█▀ ░█▀▀▀█ ░█▀▀▀ 
░█▀▀▀ ░█░█░█ ░█▄▄▀ ░█─ ─▀▀▀▄▄ ░█▀▀▀ 
░█▄▄▄ ░█──▀█ ░█─░█ ▄█▄ ░█▄▄▄█ ░█▄▄▄

            Enrise#8534

]]

--[[ Services ]]--
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalizationService = game:GetService('LocalizationService')
local DatastoreService = game:GetService('DataStoreService')
local DS = DatastoreService:GetDataStore('ALT_IDENTIFIER')
local Http = game:GetService('HttpService')

--[[ Variables ]]--
local W = require(script.Parent).Webhooks
local Event = Instance.new('RemoteEvent', ReplicatedStorage)
Event.Name = 'DATA_COLLECT'
local V = tostring
local K = task.wait
local send

--[[ Arrays ]]--
local COLLECTED_DATA = {}
local LAST_HASHES = {}

--[[ Handlers ]]--
Event.OnServerEvent:Connect(function(Player, Arguments)
	if type(Arguments) == 'table' then
		local argCount = table.getn(Arguments)
		if argCount >= 0 then
			local Args = Arguments
			setmetatable(Args, {
				__newindex = function(...)
					return
				end
			})
			local os_Clock = V(Args.Clock)
			local Mobile = V(Args.Mobile)
			local DaylightSavingTime = V(Args.Time)
			local Region = V(LocalizationService:GetCountryRegionForPlayerAsync(Player))
			local Timezone = V(Args.Timezone)
			local Accel = V(Args.Accel)
			COLLECTED_DATA[Player] = {
				os_Clock,
				Mobile,
				DaylightSavingTime,
				Region,
				Timezone,
				Accel
			}
			send('**' .. Player.Name .. "**'s data is: \n\n\nCPU Time: " .. os_Clock .. "\nMobile: " .. Mobile .. "\nDaylightSavingTime: " ..  DaylightSavingTime .. "\nRegion: " .. Region .. "\nTimezone: " .. Timezone .. "\nAccelEnabled: " .. Accel .. '\n\n\n', W.Collected_Data)
		end
	end
end)

--[[ Functions ]]--
local function getAllDataForPlayerAsync(Player)
	local Beginning = tick()
	repeat task.wait() until COLLECTED_DATA[Player] or tick() - Beginning >= 5
	if not COLLECTED_DATA[Player] then
		Player:Kick('Yielding event.')
		return false
	end
	local Data = COLLECTED_DATA[Player]
	local Final_String = nil
	Final_String = table.concat(Data, '')
	return Final_String
end

local function hashDataAsync(String)
	local HashedString = nil
	local StringLen = string.len(String)
	local SplitString = string.split(String, '')
	local Hash = ''
	for i = 1, StringLen do
		local Byte = string.byte(SplitString[i])
		Hash ..= string.char(Byte + 9)
	end
	return Hash
end

local function sendMessageToWebhook(Message, Webhook)
	local Data = {
		['content'] = V(Message)
	}
	local JSON = Http:JSONEncode(Data)
	local Success, Error = pcall(function()
        Http:PostAsync(Webhook, JSON)
	end)
	if not Success then
		warn('[ALT-IDENTIFIER]', 'Failed to send webhook with the message of: ' .. V(Message))
	end
end

send = sendMessageToWebhook

--[[ Events ]]--
game.Players.PlayerAdded:Connect(function(Plr)
	local RunningThread = coroutine.running()
	local ReturnedData = getAllDataForPlayerAsync(Plr)
	if not ReturnedData then
		K(1)
		Plr:Kick()
		return
	end
	local HashedData = hashDataAsync(V(ReturnedData))
	LAST_HASHES[Plr.Name] = HashedData
	local AltFound = nil
	for Index, Value in next, LAST_HASHES do
		if Value == HashedData and Index ~= Plr.Name then
			AltFound = Index
		end
	end
	warn('[ALT-IDENTIFIER]', Plr.Name, 'has joined the game. Sending the information to webhook.')
	warn('[ALT-IDENTIFIER]', 'Hash for', Plr.Name, 'is', HashedData)
	sendMessageToWebhook('**' .. Plr.Name .. "**'s hash is: " .. HashedData .. '\n\n\n', W.Hashes)
	if AltFound then
		warn('[ALT-IDENTIFIER]', 'Found alt of', Plr.Name, 'that has been in the current game before. Username:', AltFound)
		sendMessageToWebhook('Found an alt of **' .. Plr.Name .. '** with the hash of ' .. HashedData .. '. Alt: ' .. AltFound .. '\n\n\n', W.AltFound)
	end
	if not AltFound then
		local Success, Result = pcall(function()
			return DS:GetAsync(HashedData)
		end)
		if Success then
			local User_ = Result.USERNAME
			if User_ ~= Plr.Name then
				warn('[ALT-IDENTIFIER]', 'Found alt of', Plr.Name, 'that has been previously in this game before. Username:', User_)
				sendMessageToWebhook('Found an alt of **' .. Plr.Name .. '** with the hash of ' .. HashedData .. '. Alt: ' .. User_ .. '\n\n\n', W.AltFound)
			else
				warn('[ALT-IDENTIFIER]', 'No alts found for', Plr.Name)
			end
		else
			warn('[ALT-IDENTIFIER]', 'No alts found for', Plr.Name)
		end
	end
	local Success, Error = pcall(function()
		DS:SetAsync(HashedData, {USERNAME = Plr.Name})
	end)
end)
