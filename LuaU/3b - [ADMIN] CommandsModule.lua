-- declare a few variables (arrays)
local Commands = {};
local Internal = {};
local Variables = {};
local Constants = {};
local LoadedCommands = {};
local PlayerRanking = {};
local RegisteredPrefixes = {};
local Ranks = {};

-- first argument is the initial table, and second is the table's metatable
local Services = setmetatable({}, {
	-- __index metamethod, whenever this metamethod is called by indexing the table with X, Services.Players - Service argument will be Players, making it easier to access game services

	__index = function(_, Service)
		return game:GetService(Service);
	end
});

-- PUBLIC
-- declare a table inside the commands array
--[[

    Commands = {
        OnPromotion = {}
    }

]]
Commands.OnPromotion = {};
-- create an empty function
local PromotionCallback = function(...) end;
-- create a folder localized inside ReplicatedStorage (Service)
local Folder = Instance.new("Folder", Services.ReplicatedStorage);
-- name the folder Commands
Folder.Name = "Commands";
-- repeat the block of code 4 times, creating 4 stringvalues and naming it based on the corresponding integer value of the current position in the range of the loop
for i = 1, 4 do
	local StrValue = Instance.new("StringValue", Folder);
	StrValue.Name = i == 1 and "AutoCompletion" or i == 2 and "BarPrefix" or i == 3 and "TriggerKey" or "BarHandler";
end

-- declare a few simple functions called by __namecall
function Commands:SetBarHandler(ScreenGui)
	Folder.BarHandler.Value = "True";
end

function Commands:SetAutoCompletion(Boolean)
	Folder.AutoCompletion.Value = Boolean and "True" or "False";
end

function Commands:SetBarPrefix(Boolean)
	Folder.BarPrefix.Value = Boolean and "True" or "False";
end

function Commands:SetBarTriggerKey(KeyCode)
	local Key = string.split(tostring(KeyCode), ".")[3];
	Folder.TriggerKey.Value = Key;
end

-- recreate :Connect for the Commands.OnPromotion callback and return the function that was parsed as argument nr1
function Commands.OnPromotion:Connect(Func)
	PromotionCallback = Func;
	return Func;
end

-- some other simple functions called through __namecall
function Commands:Command(Expression, Configuration, Callback, RequirementMatch)
	-- parse the arguments ^^^ by re-using them as arguments for the ParseExpression function (i have no idea why i did this, i modified something and was lazy to re-modify it back)
	local Parsed = Internal:ParseExpression(Expression, Configuration, Callback, RequirementMatch);
end

function Commands:DynamicVariable(Variable, Value)
	Variables[Variable] = Value;
	return Variable;
end

function Commands:ConstantVariable(Variable, Value)
	Constants[Variable] = Value;
	return Variable;
end

function Commands:GetVariable(Variable)
	if (Constants[Variable]) then
		return Constants[Variable], "Constant";
	end;
	return Variables[Variable], "Dynamic";
end

function Commands:UpdateVariable(Variable, Value)
	if (Constants[Variable]) then
		return error(string.format("expected dynamic variable as 1st argument got %s"), "Constant");
	end;
	-- basically pcall (protected call) but has an error handler function
	-- if first argument (function 1) errors, then the second function will be ran
	xpcall(function(...)
		Variables[Variable] = Value;
	end, function(Err)
		if string.find(Err, "table index") then
			-- sends an error if the first function has a runtime error
			-- string.format would return a formatted string that uses the arguments given from 2nd and up
			-- in this case %s is replaced with Nil
			return error(string.format("expected existent dynamic variable got %s", "Nil"));
		end;
		return error("Unexpected behaviour: Line 40, Commands");
	end)
	return Variables[Variable];
end

function Commands:GetPlayerRank(Player)
	return Ranks[Player] or 0;
end

function Commands:Promote(Player, Rank)
	Ranks[Player] = Rank;
	PromotionCallback(Player, Rank);
	return Ranks[Player];
end

function Commands:Resolve(Caller, Arg, Func)
	if (not Arg) then
		return;
	end;

	-- basically pcall (protected call) but has an error handler function
	-- if first argument (function 1) errors, then the second function will be ran
	xpcall(function(...)
		assert(Caller:IsA("Player"), string.format("expected player for #1 argument <Caller> got %s", typeof(Caller)));
		assert(typeof(Func) == "function", string.format("expected function for #3 argument <Callback> got %s", typeof(Func)));
	end, function(Err)
		error("function Resolve - argument was different than expected")
	end)

	-- self explanatory
	local Parse = string.lower(tostring(Arg));
	if (Parse == "me") then
		return Func(Caller);
	elseif (Parse == "others") then
		-- getplayers returns the player instances (The players lol)
		for _, Plr in Services.Players:GetPlayers() do
			if (Plr ~= Caller) then
				Func(Plr);
			end;
		end;
	elseif (Parse == "all") then
		for _, Plr in Services.Players:GetPlayers() do
			Func(Plr);
		end;
	else
		-- if Arg is of class Player then run the function Func with argument 1 being the Player
		if (Arg:IsA("Player")) then
			Func(Arg);
		end;
	end;

	return true;
end

-- PRIVATE

function Internal:ParseExpression(Expression, Configuration, Callback, ErrorCallback)
	-- if expression isnt string, or configuration isnt a table, or callback isnt a function, then it will trigger an error corresponding to the second argument of assert
	-- in simple terms just an error handler
	assert(typeof(Expression) == "string", string.format("expected string for argument: Expression, got %s", typeof(Expression)));
	assert(typeof(Configuration) == "table", string.format("expected table for argument: Configuration, got %s", typeof(Configuration)));
	assert(typeof(Callback) == "function", string.format("expected function for argument: Callback, got %s", typeof(Callback)));

	-- divides the expression string parsed into multiple substrings based on a separator parsed (in this case, " ")
	-- Hi A B -> {"Hi", "A", "B"}
	local splExpression = string.split(Expression, " ");
	-- descrease the splExpression table length by 1 and declare the variable argCount
	local argCount = #splExpression - 1;
	-- booleans
	local varType, varName = nil, nil;
	local commandFromExpression = nil;
	-- declare a boolean for later
	local canBeLowerBool = false;
	-- same thing
	local splExpressionFromSplit = string.split(splExpression[1], "");

	-- if there is "%%" in the first argument of splExpression then it will run the corresponding block of code to the if statement
	if (string.find(splExpression[1], "%%")) then
		-- extract the string located between index 3 (3rd letter) and the last index (being string's length)
		Expression = Expression:sub(3, string.len(Expression));
		varName = string.split(splExpression[1], "")[2];
		varType = Variables[varName] and "DYNAMIC" or "CONSTANT";
	end;

	-- same ting lol
	if (string.find(splExpression[1], "]")) then
		-- It was initially RegEx
		--local Regex = string.match(splExpression[1], "%[*%w+%]");
		--Regex = Regex:gsub("%[", "");
		--Regex = Regex:gsub("%]", "");
		local FinalStr = "";
		local StT = false;
		-- illiterate through splExpressionFromSplit and run the corresponding block of code for every element from the table
		for _, Char in splExpressionFromSplit do
			-- stop the illiteration if the character is ]
			if Char == "]" then break end;
			-- if the boolean is TRUE then concatenate FinalStr with the character
			if (StT) then
				FinalStr ..= Char;
			end;
			-- if character is [ then set the boolean StT to true
			if (Char == "[") then
				StT = true;
			end;
		end;
		-- more basic stuff
		canBeLowerBool = true;
		commandFromExpression = FinalStr;
	else
		-- same thing as before
		for Index, Character in splExpressionFromSplit do -- Had to do a for loop due to many reasons i am lazy to explain
			if (Character == "%") then
				if (splExpressionFromSplit[Index + 2] ~= "%") then
					for i = 1, Index + 1 do
						-- remove the first element from the table splExpressionFromSplit
						table.remove(splExpressionFromSplit, 1);
					end;
					-- concatenate the elements from the table to a string with the separator "" (nothing)
					commandFromExpression = table.concat(splExpressionFromSplit, "");
				end;
			end;
		end;
	end;

	-- basic if statement
	if (Configuration["Reserved"]) then
		-- same thing as before
		assert(typeof(Configuration["Reserved"]) == "table", string.format("expected table of player userids for Reserved in Configuration, got %s", typeof(Configuration["Reserved"])));
	end;

	table.remove(splExpression, 1);

	if (string.find(commandFromExpression, "/")) then
		-- illiterate through the table that is returned
		for _, Com in pairs(string.split(commandFromExpression, "/")) do
			-- set the string as an element of the table LoadedCommands, to which is corresponding a table with a set of elements describing the command
			LoadedCommands[Com] = {
				commandPrefix = varType and varName and varType .. "_" .. varName or "",
				anyCase = canBeLowerBool,
				reqRank = Configuration["Rank"] or 0,
				funcCallback = Callback,
				errorCallback = ErrorCallback,
				reservedPlayers = Configuration["Reserved"] or nil,
				argsCount = argCount,
				commandExpression = Expression
			};
		end;

		-- blablabla
		return LoadedCommands[commandFromExpression];
	end;

	-- same ting
	LoadedCommands[commandFromExpression] = {
		commandPrefix = varType and varName and varType .. "_" .. varName or "",
		anyCase = canBeLowerBool,
		reqRank = Configuration["Rank"] or 0,
		funcCallback = Callback,
		errorCallback = ErrorCallback,
		reservedPlayers = Configuration["Reserved"] or nil,
		argsCount = argCount,
		commandExpression = Expression
	};

	-- same ting
	return LoadedCommands[commandFromExpression];
end;

function Internal:StartsWith(Message, String)
	-- recreated python startswith lol
	-- basically if message starts with string then return true else false
	if (Message:sub(1, string.len(String)) == String) then
		return true;
	end;
	return false;
end;

function Internal:Process(Message)
	local Split = string.split(Message, " ");
	local CommandAssumed = nil;
	local Prefix = nil;

	-- if first arg of split exists
	if (Split[1]) then
		if (LoadedCommands[Split[1]]) then
			-- blablabla, first arg of split
			CommandAssumed = Split[1];
		else
			-- sub deprecated string.sub, commented before
			if (LoadedCommands[Split[1]:sub(2, string.len(Split[1]))]) then
				CommandAssumed = Split[1]:sub(2, string.len(Split[1]));
				Prefix = Split[1]:sub(1, 1);
			end;
		end;
	end;

	return CommandAssumed, Prefix;
end;

function Internal:ProcessNextExpression(CommandUsed, Expressions)
	-- if expressions isnt a table then return an empty table
	if (typeof(Expressions) ~= "table") then
		return {};
	end;

	-- self explanatory, commented before
	local Split = Expressions;
	local exprFormat = string.split(LoadedCommands[CommandUsed]["commandExpression"], " ");
	table.remove(exprFormat, 1);
	local Args = {};
	local N = 0;
	local LoopBreak = false;

	-- illiterate through the Split table
	for Index, Word in Split do
		local Sub = Word:gsub("%<", "");
		Sub = Word:gsub("%>", "");
		for Index, expr in exprFormat do
			-- :find is deprecated string.find, commented before
			if (string.lower(exprFormat[Index]):find("player")) then
				-- boolean
				local ffN_d = false;
				-- some EQ checks
				if (string.lower(Word) == "me" or string.lower(Word) == "others" or string.lower(Word) == "all") then
					table.insert(Args, Word);
					-- set boolean to trrue lol
					ffN_d = true;
				end
				-- increment by 1
				N += 1;
				if not ffN_d then
					for Index, Player in Services.Players:GetPlayers() do
						-- lower is deprecated string.lower, sub is deprecated string.sub, string.len returns the length of a string
						if Player.Name:lower():sub(1, string.len(Sub)) == Sub then
							ffN_d = true;
							-- add player as an element in the table Args
							table.insert(Args, Player);
							-- stop the illiteration
							break;
						end;
					end;
				end;
				-- basic stuff tbh, commented before
			elseif (string.lower(exprFormat[Index]):find("string")) then
				N += 1;
				table.insert(Args, Sub);
			elseif (string.lower(exprFormat[Index]):find("integer")) then
				N += 1;
				table.insert(Args, tonumber(Sub));
			elseif (string.lower(exprFormat[Index]):find("boolean")) then
				N += 1;
				table.insert(Args, Sub:lower() == "true" and true or Sub:lower() == "false" and false or nil);
			elseif (string.lower(exprFormat[Index]):find("reason")) then
				if (N ~= 0) then
					for i = 1, N do
						table.remove(Expressions, 1);
					end;
				end;
				local Concat = table.concat(Expressions, " ");
				table.insert(Args, Concat)
				LoopBreak = true;
				break;
			end;
		end;
		if (LoopBreak) then
			break;
		end;
	end;

	return Args;
end;

function Internal:ChatEvent()
	Services.Players.PlayerAdded:Connect(function(Player) -- whenever a player joins the game the event fires, having as 1st argument the player that joined
		Player.Chatted:Connect(function(Message) -- whenever a player joins this event is connected to the player, whenever a player sends a message the message is parsed thorugh this function as teh first argument
			-- returns a tuple so two variables are declared to keep the things returned
			local CommandUsed, cmdPrefix = Internal:Process(Message);
			if CommandUsed then
				local Prefix = LoadedCommands[CommandUsed]["commandPrefix"];
				local typePrefix, varNamePrefix = "", "";
				Prefix = string.split(Prefix, "_");
				typePrefix = Prefix[1];
				varNamePrefix = Prefix[2];
				Prefix = varNamePrefix;
				-- self explanatory everything above and below, commented before this
				if (typePrefix == "DYNAMIC") then
					Prefix = Variables[varNamePrefix];
				else
					Prefix = Constants[varNamePrefix];
				end;
				if (Prefix == cmdPrefix) or (not Prefix and not cmdPrefix) then
					local splitTable = string.split(Message, " ");
					-- remove first argument of splittable
					table.remove(splitTable, 1);
					-- head over to processnextexpression for comments
					local args = Internal:ProcessNextExpression(CommandUsed, splitTable);
					if (not Commands:GetPlayerRank(Player) or Commands:GetPlayerRank(Player) < LoadedCommands[CommandUsed]["reqRank"]) then
						return typeof(LoadedCommands[CommandUsed]["errorCallback"]) == "function" and LoadedCommands[CommandUsed]["errorCallback"](Player, unpack(args));
					end;
					-- and finally return the callback of the command that was identified to be used and parse player and the rest of the args as arguments
					return LoadedCommands[CommandUsed]["funcCallback"](Player, unpack(args));
				end;
			end;
		end);
	end);
end;

Internal:ChatEvent();

return Commands
