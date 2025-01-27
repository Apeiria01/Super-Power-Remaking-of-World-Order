
-- GTAS_TableSerialization - Part of Really Advanced Setup Mod

-- Contains code for converting a table to a string of data and vise versa.

-- Data Tokens ------------------------------------------------------------------------------------------------
-- Token Values - These are used to indentify each item within a data string. 
-- They are used when saving and loading a table.
NO_TOKEN = "0";
TABLE_START = "1";
TABLE_END = "2";
NUMBER_VALUE = "3";
BOOLEAN_VALUE = "4";
STRING_VALUE = "5";

-- Warning - LoadTable can NOT handle empty strings or strings that contain DATA_CHAR so they are not saved!
-- The DATA_SEPARATOR should only contain these characters.
DATA_CHAR = "*";

-- This value is used to seperate each item and token within a data string. 
-- It is used when saving and loading a table.
DATA_SEPARATOR = DATA_CHAR .. DATA_CHAR .. DATA_CHAR;


---------------------------------------------------------------------------------------
-- This function saves a table to a data string.
-- The "source" variable should be the table that will be saved.
-- The "output" variable does not need to be passed unless you want to append data to an existing string.
-- The "tableKey" variable should be nil (or no value supplied) when calling this function (this variable is used when the function is called recursively from within).
-- This function will return a single string containing the data passed in output (if any) plus the converted source table.
-- This function currently only works with values that are either tables, numbers, booleans, or strings.
-- It will pass over other items and just print an error message.
-- Warning - LoadTable can NOT handle empty strings or strings that contain DATA_CHAR so they are not saved!
function SaveTable(source, output, tableKey)
	local keyType, valueType = NO_TOKEN, NO_TOKEN;

	if output == nil then
		output = "";
	end

	if tableKey ~= nil then
		if type(tableKey) == "number" then
			output = output .. TABLE_START .. DATA_SEPARATOR .. NUMBER_VALUE .. DATA_SEPARATOR .. tableKey .. DATA_SEPARATOR;
		else
			output = output .. TABLE_START .. DATA_SEPARATOR .. STRING_VALUE .. DATA_SEPARATOR .. tableKey .. DATA_SEPARATOR;
		end
	end

	for key, value in pairs(source) do
		if type(value) == "table" then
			output = SaveTable(value, output, key);

		else
			doSaveData = true;

			if type(key) == "number" then
				keyType = NUMBER_VALUE;

			else
				keyType = STRING_VALUE;
			end

			if type(value) == "number" then
				valueType = NUMBER_VALUE;

			elseif type(value) == "boolean" then
				valueType = BOOLEAN_VALUE;

			elseif type(value) == "string" then
				valueType = STRING_VALUE;

				-- LoadTable can't handle empty strings or strings that contain DATA_CHAR so they are not saved.
				if value == "" or string.find(value, DATA_CHAR) ~= nil then
					doSaveData = false;
				end

			else
				if type(value) == "function" then
					print("Function found in SaveTable - will be ignored.");

				else
					print("Value Error in SaveTable. Value not saved.");
				end

				doSaveData = false;
			end

			if doSaveData then
				output = output .. keyType .. DATA_SEPARATOR .. tostring(key) .. DATA_SEPARATOR .. valueType .. DATA_SEPARATOR .. tostring(value) .. DATA_SEPARATOR;
			end
		end
	end

	output = output .. TABLE_END .. DATA_SEPARATOR;
	return output;
end

---------------------------------------------------------------------------------------
-- This function loads a table from a data string that was created using the SaveTable function.
-- The "input" variable should be a string containing data that was created using SaveTable.
-- The "dest" variable should be the table where the data will be created.
-- Warning - LoadTable can NOT handle empty strings or strings that contain DATA_CHAR so they are not saved by SaveTable!
function LoadTable(input, dest)
	if type(input) == "string" then
		input = input:gmatch("[^" .. DATA_CHAR .. "]+")
	end

	for token in input do
		if token == TABLE_START then
			local keyType = input();
			local key = input();

			if keyType == NUMBER_VALUE then
				key = tonumber(key);
			end

			dest[key] = {};

			if not LoadTable(input, dest[key]) then
				print("Table Error in LoadTable. Load stopped prematurely.");
				return false
			end

		elseif token == TABLE_END then
			return true;

		else
			local key = input();

			if token == NUMBER_VALUE then
				key = tonumber(key);

			elseif token == STRING_VALUE then
				key = tostring(key);

			else
				print(string.format("Key Type Error in LoadTable. Load stopped prematurely. (token = %s, key = %s)", token, key));
				return false
			end

			local valueType = input();
			local value = input();

			if valueType == NUMBER_VALUE then
				dest[key] = tonumber(value);

			elseif valueType == BOOLEAN_VALUE then
				if value == "true" then
					dest[key] = true;
				else
					dest[key] = false;
				end

			elseif valueType == STRING_VALUE then
				dest[key] = tostring(value);

			else
				print(string.format("Value Type Error in LoadTable. Load stopped prematurely. (valueType = %s, value = %s)", valueType, value));
				return false
			end

		end
	end
end


