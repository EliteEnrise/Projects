-- This is a code that uses advanced methods to animate a admin TextBox.
-- This should demonstrate my capabilities to animate Uis at an advanced level.

local Commands = {
	-- // Main
	"kick",
	"ban",
	"tempban",
	"unban",
	"teleport",
	"shutdown",
	"unserverban",
	"serverban",
	
	-- // Misc
	"setair",
	"walkspeed",
	"jumppower",
	"health",
	"setrope",
	"disabletag",
	"enabletag",
	
	-- // Annoucements
	
	"globalserverannouncement",
	"localserverannouncement",
}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Remote = game.ReplicatedStorage.Admin

local Command = script.Parent.Command
local Suggestion = script.Parent.Suggestion
local CurrentSuggestion = nil
local MenuToggled = false

local Center = 0.2
script.Parent.Position = UDim2.new(Center, 0, 1.2, 0)

local A = tick()
local function ToggleMenu(...)
	if tick() - A <= 1 then
		return
	end
	A = tick()
	if not MenuToggled then
		local Open_Menu = TweenService:Create(Command.Parent, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Position = UDim2.new(Center, 0, 0.9, 0)})
		Open_Menu:Play()
		Open_Menu.Completed:Wait()
		MenuToggled = true
	else
		local Close_Menu = TweenService:Create(Command.Parent, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Position = UDim2.new(Center, 0, 1.2, 0)})
		Close_Menu:Play()
		Close_Menu.Completed:Wait()
		MenuToggled = false
	end
end

local gs = false
local oldsuggestion = nil
UIS.InputBegan:Connect(function(Key, Game_Input)
	local KeyCode = Key.KeyCode
	if MenuToggled and KeyCode == Enum.KeyCode.Tab then
		if CurrentSuggestion then
			Command.Text = CurrentSuggestion
			Command.CursorPosition = string.len(Command.Text) + 1
			oldsuggestion = CurrentSuggestion
			CurrentSuggestion = nil
			Suggestion.Text = ""
			gs = true
		end
	else
		if MenuToggled and KeyCode == Enum.KeyCode.Return then
			if string.len(Command.Text) >= 3 then
				Remote:FireServer(Command.Text)
				Command.Text = ""
				Suggestion.Text = ""
			end
		elseif not Game_Input then
			if KeyCode == Enum.KeyCode.Quote then
				ToggleMenu()
			end
		end
	end
end)

Command:GetPropertyChangedSignal("Text"):Connect(function(...)
	local NewText = Command.Text
	if gs then
		Command.Text = NewText:gsub("%s", "")
		Command.Text = oldsuggestion .. " "
		Command.CursorPosition = string.len(Command.Text) + 1
		NewText = Command.Text
		gs = false
	end
	local Split = string.split(NewText, " ")
	if #Split > 1 and #Split < 3 then
		local Found = false
		for i, v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Name:sub(1, string.len(Split[2])):lower() == Split[2]:lower() then
				Suggestion.Text = Split[1] .. " " .. v.Name
				CurrentSuggestion = Suggestion.Text
				Found = true
				break
			end
		end
		if not Found then
			Suggestion.Text = ""
		end
		return
	elseif #Split > 2 and #Split < 4 then
		local Found = false
		for i, v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Name:sub(1, string.len(Split[3])):lower() == Split[3]:lower() then
				Suggestion.Text = Split[1] .. " " .. Split[2].. " ".. v.Name
				
				CurrentSuggestion = Suggestion.Text
				Found = true
				break
			end
		end
		if not Found then
			Suggestion.Text = ""
		end
		return
	end
	
	if NewText == "" then
		Suggestion.Text = ""
		CurrentSuggestion = nil
		return
	end
	local Found = false
	for i, v in pairs(Commands) do
		if v:sub(1, string.len(NewText)) == NewText then
			Suggestion.Text = v
			CurrentSuggestion = Suggestion.Text
			Found = true
			break
		end
	end
	if Found then
		return
	end
	Suggestion.Text = ""
	CurrentSuggestion = nil
end)
