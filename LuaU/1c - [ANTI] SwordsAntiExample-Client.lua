------------------------------------------------------
-- Services --
local ReplStorage = game:GetService('ReplicatedStorage')
local Server = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')
local StarterGui = game:GetService('StarterGui')
local TweenService = game:GetService('TweenService')
local ScriptContext = game:GetService("ScriptContext")
------------------------------------------------------
-- Variables --
local Default_Handle_Size = Vector3.new(1, 0.8, 4)
local Client = Server["LocalPlayer"]
local Mouse = Client["GetMouse"](Client)
local Exploit = nil
------------------------------------------------------
-- Arrays --
local Flags = {}
local Loaded = {}
------------------------------------------------------
-- Anti Variables --
local FirstEvent = ReplStorage:WaitForChild(tostring(Client.UserId), math.huge)
local Encryption_Key = FirstEvent:GetAttribute("f4D")
FirstEvent:SetAttribute("f4D", nil)
------------------------------------------------------
-- Functions --
local funcs = {
	Matchcrypt = function(String, ...) -- // Undecryptable hashing
		local Encryption_Key = table.pack(...)[1]
		if not Encryption_Key then
			Encryption_Key = "gasdf2" -- // Default key
		end
		local algorithm = 1
		for index, character in string.split(Encryption_Key, "") do
			local new_Byte = string.byte(character) / 2
			new_Byte = string.split(tostring(new_Byte),".")[1]
			algorithm = algorithm + tonumber(new_Byte)
			if index == #string.split(Encryption_Key, "") then
				algorithm = algorithm / (algorithm - (algorithm - 5))
				algorithm = string.split(tostring(algorithm), ".")[1]
				algorithm = algorithm + string.len(Encryption_Key) - 1
				algorithm = algorithm + math.abs(string.byte(string.split(Encryption_Key,"")[3]) - string.byte(string.split(Encryption_Key,"")[2]))
			end
		end
		algorithm = algorithm - 1
		local Initial = String
		local Hashed = ""
		for _, Character in string.split(String, "") do
			Hashed = Hashed .. utf8.char(string.byte(Character) + algorithm)
		end
		return Hashed
	end,

	New = function(Identification_Key, Function, ...)
		Loaded[Identification_Key] = tick()
		coroutine.wrap(function()
			while task.wait(1) do
				if Loaded[Identification_Key] then
					local Old = Loaded[Identification_Key]
					if Old - tick() >= 10 then
						table.insert(Flags, "Yielding Threads")
						task.delay(10,function()
							task.spawn(function()
								Client:Kick("Yield.")
							end)
							while true do end
						end)
					end
				end
			end
		end)()
		task.spawn(Function)
		return Identification_Key
	end,

	GetHandle = function(...)
		local Character = Client and Client.Character or nil
		if Character then
			local Tool = Character and Character:FindFirstChildOfClass("Tool") or nil
			if Tool then
				local Handle = Tool.Handle or nil
				return Handle
			end
		end
		return nil
	end,

	TestIndex = function(Object, Index, ...)
		local Ind = Index .. string.rep("\0", 10) .. string.rep("f", 500)
		local Success, Error = pcall(function()
			return Object[Ind]
		end)
		return Success
	end,

	SafeIndex = function(Object,Index,Bool) -- like a safe findfirstchild with the nullbyte
		if not Bool then
			Index = Index..string.rep("\0",math.random(10))
		end
		local Success, Returned = pcall(function()
			return Object[Index]
		end)
		if Success then
			return Returned
		end
	end,
}
------------------------------------------------------
-- Getting Remote --
if not FirstEvent then
	while true do end
end
task.wait(1)
FirstEvent:InvokeServer()
FirstEvent["OnClientInvoke\0"] = function(...)
	local Args = table.pack(...)[1]
	local Event = Args.EV or nil
	local String = Args.DATA or nil
	if not Event or not String then
		task.spawn(function()
			Client:Kick("Stop.")
		end)
		while true do end
	end
	Exploit = Event
	return funcs.Matchcrypt(String, Encryption_Key)
end

local Elapsed = tick()
repeat
	task.wait()
until
Exploit or tick() - Elapsed >= 30

if not Exploit then
	while true do end
end
------------------------------------------------------
-- Checks --
local Resize_Checks
Resize_Checks = funcs.New("ResizeChecks", function(...)
	while task.wait(5) do
		Loaded[Resize_Checks] = tick()
		local Handle = funcs.GetHandle()
		if Handle then
			if Handle.Size ~= Default_Handle_Size then
				table.insert(Flags, "Resize Check A")
				break
			end
			local Clone = Instance.new("ImageLabel").Clone(Handle)
			if Clone.Size ~= Handle.Size then
				table.insert(Flags, "Resize Check B")
				break
			end
			Clone:Destroy()
			local Tool_Clone = Instance.new("Attachment").Clone(Handle.Parent)
			if Tool_Clone then
				if Tool_Clone.Handle.Size ~= Handle.Size then
					table.insert(Flags, "Resize Check C")
					break
				end
			end
			Tool_Clone:Destroy()
			Handle.Parent.Parent.Archivable = true
			local Character_Clone = Instance.new("Frame").Clone(Handle.Parent.Parent)
			Handle.Parent.Parent.Archivable = false
			if Character_Clone:FindFirstChildOfClass("Tool").Handle.Size ~= Handle.Size then
				table.insert(Flags, "Resize Check D")
				break
			end
			Character_Clone:Destroy()
			if Handle["Size\0"] ~= Handle.Size then
				table.insert(Flags, "Resize Check E")
				break
			end
			if funcs.TestIndex(Handle, "Size") then
				table.insert(Flags, "Resize Check F")
				break
			end
		end
	end
end)

local Hitbox = game.ReplicatedFirst.HITBOX
local Yes = {}
local Weld_Checks_Resize
Weld_Checks_Resize = funcs.New("WeldChecks", function(...)
	while task.wait() do
		Loaded[Weld_Checks_Resize] = tick()
		local Handle = funcs.GetHandle()
		if Handle then
			if not Yes[Handle] then
				Yes[Handle] = true
				Handle.LocalSimulationTouched:Connect(function(Hit, ...)
					if not Hit:FindFirstChild("HITBOX") and Hit.Parent:FindFirstChildOfClass("Humanoid") then
						local Clone = Hitbox:Clone()
						Clone.Parent = Hit
						Clone.Adornee = Hit
						game:GetService("Debris"):AddItem(Clone, 0.1)
					end
				end)
			end
			local Running = true
			local Part = Instance.new("Part")
			Part.Size = Vector3.new(0.1, 0.1, 0.1)
			Part.Transparency = 1
			Part.Massless = true
			Part.CanCollide = false
			Part.Name = "Torso"
			local Weld = Instance.new("Weld")
			Weld.Parent = Part
			Part.Parent = Handle
			Weld.Part0 = Part
			Weld.Part1 = Handle
			Weld.C0 = CFrame.new(0, 0.5, 0)
			local Connection = nil
			Connection = Part.Touched:Connect(function(Part, ...)
				if Part == Handle then
					table.insert(Flags, "Resize Check G")
				end
			end)
			local F = 0
			local _Debounce = false
			local Connection2
			Connection2 = Handle.LocalSimulationTouched:Connect(function(Hit, ...)
				if _Debounce then return end
				if Hit.Parent:FindFirstChildOfClass("Humanoid") then else return end
				_Debounce = true
				local Touching = Instance.new("MeshPart").GetTouchingParts(Handle)
				if not table.find(Touching, Hit) then
					F = F + 1
				end
				task.wait(1)
				_Debounce = false
			end)
			local BaitConnection = nil
			local SomeConnection = nil
			local TouchDetected = false
			local Debounce = false
			local Debounce_ = true
			local Flags_ = 0
			task.spawn(function()
				while task.wait(0.1) do
					if not Running then
						break
					end
					for i, v in pairs(Part.GetTouchingParts(Part)) do
						if v == Handle then
							table.insert(Flags, "Resize Check H")
						end
					end
				end
			end)
			task.spawn(function()
				while task.wait(0.1) do
					if not Running then
						break
					end
				end
			end)
			task.wait(10)
			Running = false
			if F >= 3 then
				table.insert(Flags, "FTI Check F")
			end
			Connection:Disconnect()
			Connection2:Disconnect()
		end
	end
end)

local GUI_Detections
GUI_Detections = funcs.New("GUIChecks", function(...)
	while task.wait(1) do
		Loaded[GUI_Detections] = tick()
		game.GetService(game, "ContentProvider\0")["preloadAsync\0"](game.GetService(game, "ContentProvider\0"), {game.CoreGui}, function(Asset, ...)
			if Asset:find("rbxassetid://") and not Asset:find("1080455604") then
				table.insert(Flags, "GUI Check A")
			end
		end)
		if collectgarbage("count\0") ~= gcinfo() then
			table.insert(Flags, "Memory Spoof Check A")
		end
		local success, _ = pcall(function()
			return collectgarbage("collectfasfafasdgasgasgadgasdgag")
		end)
		if success then
			table.insert(Flags, "Memory Spoof Check B")
		end
	end
end)

local HBE_Checks
HBE_Checks = funcs.New("HBEChecks",function()
	local Limbs = {
		"HumanoidRootPart","Torso",
		"Right Arm","Right Leg",
		"Left Arm","Left Leg",
		"Head"
	}
	local vector3 = Vector3.new
	local NormalLimbSizes = {
		['Left Leg'] = vector3(1, 2, 1),
		['Right Leg'] = vector3(1, 2, 1),
		['Head'] = vector3(2, 1, 1),
		['Torso'] = vector3(2, 2, 1),
		['HumanoidRootPart'] = vector3(2, 2, 1),
		['Right Arm'] = vector3(1, 2, 1),
		['Left Arm'] = vector3(1, 2, 1)
	}
	local CachedTweens = setmetatable({}, {
		__mode = "v"
	})
	while true do
		for _,v in pairs(Server:GetPlayers()) do
			local char = funcs.SafeIndex(v,"Character",true)
			local Humanoid = char and funcs.SafeIndex(char,"Humanoid")
			if not Humanoid then continue end
			for _,v in pairs(Limbs) do
				local Limb = funcs.SafeIndex(char,v)
				
				if Limb and Humanoid:GetLimb(Limb) ~= Enum.Limb.Unknown then
					local OldSize = NormalLimbSizes[v]
					if funcs.SafeIndex(Limb,"Size",true) ~= OldSize then -- Normal Limb.Size ~= Actual Size
						table.insert(Flags,"HBE Check A [1]")
						Limb["Size\0"] = OldSize
						return
					end
					if funcs.SafeIndex(Limb,"Size") ~= OldSize then -- Null byte
						table.insert(Flags,"HBE Check A [2]")
						Limb["Size\0"] = OldSize
						return
					end
					if funcs.TestIndex(Limb,"Size") then -- yk what this is fatrise.
						table.insert(Flags,"Spoof Check F [4]")
						Limb["Size\0"] = OldSize
						return
					end
					if not CachedTweens[Limb] then
						CachedTweens[Limb] = TweenService:Create(Limb,TweenInfo.new(.01),{Size = OldSize+Vector3.new(.03,0,0)})
					end
					CachedTweens[Limb]:Play()
					CachedTweens[Limb].Completed:Wait() -- for some reason this doesnt play when ur tabbed out so i yield until u tab back in
					if Limb.Size == OldSize then
						table.insert(Flags,"Spoof Check F [5]")
					end
					Limb["Size\0"] = OldSize
				end
			end
		end
		Loaded["HBEChecks"] = tick()
		task.wait(3)
	end
end)

local CBring_Detections
CBring_Detections = funcs.New("CbringDetections",function()
	local Secure = {}
	local Limbs = {
		"HumanoidRootPart","Torso",
		"Right Arm","Right Leg",
		"Left Arm","Left Leg",
		"Head"
	}
	local Breakable = {
		"Left Shoulder","Right Shoulder","Left Hip","Right Hip"
	}
	while true do
		task.wait(3)
		for _,v in pairs(Server:GetPlayers()) do
			local char = funcs.SafeIndex(v,"Character",true)
			local Humanoid = char and funcs.SafeIndex(char,"Humanoid")
			if Humanoid then
				local Torso = funcs.SafeIndex(char,"Torso")
				if Torso then
					local Count = 0
					for _,v in pairs(Breakable) do
						if not funcs.SafeIndex(Torso,v) then
							Count += 1
						end
					end
					if Count > 0 and Count < 3 then
						if funcs.SafeIndex(Torso,"Neck") then
							table.insert(Flags,"CBring Check B")
						end
					end
				end
				for _,v in pairs(Limbs) do					
					local Limb = funcs.SafeIndex(char,v)
					if Limb and Humanoid:GetLimb(Limb) then
						local OriginalSize = Limb.Size
						if Secure[Limb] then
							Secure[Limb]:Disconnect()
							Secure[Limb] = nil
						end
						Secure[Limb] = Limb['GetPropertyChangedSignal\0'](Limb,"CFrame")["Connect\0"](Limb['GetPropertyChangedSignal\0'](Limb,"CFrame"),function()
						    table.insert(Flags,"CBring Check A")
						end)
					end
				end
			end
		end
		Loaded["CbringDetections"] = tick()
	end
end)

local Spoof_Checks
Spoof_Checks = funcs.New("SpoofChecks",function()
	while task.wait(1) do
		Loaded["SpoofChecks"] = tick()
		local Handle = funcs.GetHandle()
		if Handle then
			local R = Instance.new('RemoteEvent')
			R['Name\0\0\0'] = 'Handle'
			local R2 =  Instance.new('RemoteEvent')
			R2['Name\0\0\0'] = 'Humanoid'
			local R3 =  Instance.new('RemoteEvent')
			R3['Name\0\0\0'] = 'Character'
			local Spoof_Table = {
				S1 = pcall(function()
					return Handle.SizeAA
				end),
				S2 = pcall(function()
					return Handle.CloneA(Handle)
				end),
				S3 = pcall(function()
					return Handle.MassAAA
				end),
				S4 = pcall(function()
					return R.Size
				end),
				S5 = pcall(function()
					return Handle.MaSs
				end),
				S6 = pcall(function()
					return Handle.SiZe
				end),
				S7 = pcall(function()
					return workspace:GetConnectedParts()
				end),
				S8 = pcall(function()
					return workspace:GetTouchingParts()
				end),
				S9 = pcall(function()
					return R:GetPartsInPart()
				end),
				S10 = pcall(function()
					return R.Humanoid
				end),
				S11 = pcall(function()
					return R.Character
				end),
				S12 = pcall(function()
					return R2.Health
				end),
				S13 = pcall(function()
					return R2:GetState()
				end),
				S14 = pcall(function()
					return R2.MoveDirection
				end),
				S15 = pcall(function()
					return R.Velocity
				end)
			}	
			for i, v in pairs(Spoof_Table) do
				if v then
					table.insert(Flags,("Spoof Check E [%s]"):format(i))
				end
			end
			for i, v in pairs(Server:GetPlayers()) do
				pcall(function(...)
					if v.Character.Humanoid["Health"] ~= v.Character.Humanoid["Health\0\0a"] then
						table.insert(Flags, "Spoof Check F")
					end
				end)
			end
		end
	end
end)

local LastAdded = tick()
game.descendantAdded:connect(function(Child, ...)
	LastAdded = tick()
	local Success, Error = pcall(function()
		return Child.Parent, Child.Parent.Parent
	end)
	if not Success then
		table.insert(Flags, "FTI Check G [1]")
	end
	if Child.Parent.Parent and not Child.Parent.Parent:FindFirstChild(tostring(Child), true) then
		table.insert(Flags, "FTI Check G [2]")
	end
	if Child.Parent and not Child.Parent:FindFirstChild(tostring(Child)) then
		table.insert(Flags, "FTI Check G [3]")
	end
	if Child.Parent and Child.Parent.Parent and Child.Parent.Parent:IsA("Tool") then
		return
	end
	if Child.Parent.Parent.Parent and Child.Parent.Parent.Parent:IsA("Tool") then
		return
	end	
	local Success, Error = pcall(function()
		return Child.Parent.Parent.Parent.Parent
	end)
	if Success and Child.Parent.Parent.Parent.Parent and Child.Parent.Parent.Parent.Parent:IsA("Tool") then
		return
	end
	if Child.Parent.Parent:IsA("Model") then
		return
	end
end)

task.spawn(function(...)
	local Folder = workspace:FindFirstChild("rise_objects-" .. tostring(game.PlaceId))
	if not Folder then
		workspace.childAdded:Connect(function(Obj, ...)
			if Obj.Name == "rise_objects-" .. tostring(game.PlaceId) then
				Obj.descendantAdded:Connect(function(Descendant, ...)
					if Descendant:IsA("TouchTransmitter") then
						table.insert(Flags, "FTI Check K - Security Check")
					end
				end)
			end
		end)
	else
		Folder.descendantAdded:Connect(function(Descendant, ...)
			if Descendant:IsA("TouchTransmitter") then
				table.insert(Flags, "FTI Check K - Security Check")
			end
		end)
	end
end)


------------------------------------------------------
-- Main Event --
local Last_Check = nil
local Running_Check = false
Exploit["OnClientInvoke\0"] = function(...)
	if Running_Check then
		while true do end
		task.spawn(function()
			Client:Kick("Stop. [0]")
		end)
		wait(9e9)
	end
	Running_Check = true
	if Last_Check and tick() - Last_Check < 3 then
		while true do end
		task.spawn(function()
			Client:Kick("Stop. [1]")
		end)
		wait(9e9)
	end
	local c = false
	Last_Check = tick()
	local Args = {...}
	Args = Args[1]
	local String = Args.STRING
	local Response = {String = nil, Detections = nil}
	Response.Detections = Flags
	if #Flags ~= #Response.Detections then
		c = true
		while true do end
		task.spawn(function()
			Client:Kick("Stop. [4]")
		end)
		wait(9e9)
	end
	Flags = {}
	table.insert(Flags, "FTI Check H")
	if not table.find(Flags, "FTI Check H") then
		c = true
		while true do end
		task.spawn(function()
			Client:Kick("Stop. [2]")
		end)
		wait(9e9)
	end
	local i = 0
	local f = false
	while true do
		i = i + 1
		if not Flags[i] then break end
		if Flags[i] == "FTI Check H" then
			f = true
			Flags[i] = nil
			break
		end
		task.wait()
	end
	if not f then
		c = true
		while true do end
		task.spawn(function()
			Client:Kick("Stop. [3]")
		end)
		wait(9e9)
	end
	if c then
		return
	end
	Response.String = funcs.Matchcrypt(Args.STRING, Encryption_Key)
	Running_Check = false
	return Response
end
