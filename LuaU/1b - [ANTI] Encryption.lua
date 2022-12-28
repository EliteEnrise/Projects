function Encryption.Encode(Key: string, JunkSize: number, ByteOffset: number, String: string)
	local nextString = String;
	local keyDivision = string.split(Key, "")
	local integerStock = 0;
	local previousStock = "";
	local skipping = false;
	local algorithmSelections = {
		ShiftingKey = tonumber(keyDivision[1]),
		ShuffleKey = tonumber(keyDivision[2])
	}
	local decodeTable = {}
	
	local function illiterate(String: string, Callback: any)
		local cachedLetters = string.split(String, "");
		nextString = "";
		
		local nextCall = 1;
		while Callback[nextCall] do
		    for _, v in cachedLetters do
			    Callback[nextCall](v, _)
			end
			nextCall += 1;
			print(nextString)
			if Callback[nextCall] then
			    cachedLetters = string.split(nextString, "")
				nextString = ""
			end
			task.wait()
		end
	end
	
	illiterate(nextString, {
		
		(function(Letter, Index)
			decodeTable[Index] = {}
			local randomOffset = math.random(-10, 30)
		    if string.upper(Letter) == Letter then
				nextString ..= string.char((string.byte(Letter) + algorithmSelections.ShiftingKey - 65) % 26 + 65 + randomOffset)
				table.insert(decodeTable[Index], ((string.byte(Letter) + algorithmSelections.ShiftingKey - 65) / 26))
				table.insert(decodeTable[Index], (string.byte(Letter) + algorithmSelections.ShiftingKey - 65) % 26)
				table.insert(decodeTable[Index], randomOffset)
		    else
				nextString ..= string.char((string.byte(Letter) + algorithmSelections.ShiftingKey - 97) % 26 + 97 + randomOffset)
				table.insert(decodeTable[Index], ((string.byte(Letter) + algorithmSelections.ShiftingKey - 97) / 26))
				table.insert(decodeTable[Index], (string.byte(Letter) + algorithmSelections.ShiftingKey - 97) % 26)
				table.insert(decodeTable[Index], randomOffset)
	    	end
	    end),
	
		(function(Letter)
			local offsettedLetter = string.char(math.floor((string.byte(Letter) + ByteOffset) * 0.5));
			nextString ..= offsettedLetter;
			local newDump = string.split(nextString, "");
			if integerStock == algorithmSelections.ShuffleKey then
				table.remove(newDump, table.getn(newDump) - 1)
				nextString ..= previousStock;
			end
			previousStock = newDump[#newDump]
		end),
		
		(function(Letter)
			local byteSum = 0;
			local keyLen = string.len(Key);
			local upperCaseCount = 0;
			local lowerCaseCount = 0;
			local numbersCount = 0;
			local lettersCount = 0;
			
			table.foreach(keyDivision, function(Letter) 
				byteSum += string.byte(Letter) 
				if string.upper(Letter) == Letter then
					if string.len(tostring(tonumber(Letter))) <= 0 then
						upperCaseCount += 1;
						lettersCount += 1;
					else
						numbersCount += 1;
					end
				else
					lowerCaseCount += 1;
					lettersCount += 1;
				end
			end)

			if upperCaseCount >= lowerCaseCount then
				nextString ..= utf8.char(math.floor(string.byte(Letter) + byteSum + math.abs(numbersCount - lettersCount) + (keyLen + 3)))
			else
				nextString ..= utf8.char(math.floor(string.byte(Letter) + byteSum + math.abs(numbersCount - lettersCount) + (keyLen - 3)))
			end

		end)
		
	})
	
	return nextString, decodeTable
end

function Encryption.Decode(Key: string, JunkSize: number, ByteOffset: number, String: string, DecodeTable: table)
	-- not included due to the fact that i do not wish to make this public for use
end
