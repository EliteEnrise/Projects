-- This targets a specific version of dex - SecureDex, but also works on normal dex and has no false positives.
-- This code may look ugly in your eyes, but that is for the sole purpose of solidifying the security of the script.

local stat = game.GetService(game, 'Stats')
local uis = game.GetService(game, 'UserInputService')
task.spawn(function()
	while task.wait(1) do
		local t= false
		game.ContentProvider.preloadAsync(game.ContentProvider,{game.CoreGui},function(asset)
			if asset:find('rbxassetid://') then
				if not t then
					print('[CAUGHT] Failed Injection Check [2]')
				end
				t = true
			end
		end)
		local textbox = uis.GetFocusedTextBox(uis)
		local textbox2 = uis:GetFocusedTextBox()
		if textbox and not textbox2 then
			print('[CAUGHT] Failed Spoof Check [7]')
		end
		if textbox then
			local s,e = pcall(function()
				return textbox.Archivable
			end)
			if not s then
				print('[CAUGHT] Failed Injection Check [4]')
			end
		end
	end
end)
local Init = 0
task.spawn(function()
	while task.wait() do
		if stat.getTotalMemoryUsageMb(stat) ~= stat.GetTotalMemoryUsageMb(stat) or stat:GetTotalMemoryUsageMb(stat) ~= stat.getTotalMemoryUsageMb(stat) then
			Init = Init + 1
		end
	end
end)
task.spawn(function()
	while task.wait(10) do
		if Init > 0 then
			Init = 0
		else
			print('[CAUGHT] Failed Spoof Check [1]')
		end
	end
end)
local Attempts = 0
local Time = 1
local Elapsed = tick()
local KickAttempts = 10
task.spawn(function()
	while task.wait(Time) do
		if tick() - Elapsed >= KickAttempts * Time + 1 then
			Attempts = 0
			warn('[CHECK] Reset Spoof Attempts')
			Elapsed = tick()
		end
		local GC = gcinfo()
		if GC >= 10000 then
			Attempts = Attempts + 1
			if Attempts >= KickAttempts then
				print('[CAUGHT] Failed Spoof Check [5]')
			end
		end
	end
end)
task.spawn(function()
	while task.wait(1) do

		if collectgarbage('count') ~= gcinfo() then
			print('[CAUGHT] Failed Spoof Check [6]')
		end
	end
end)
