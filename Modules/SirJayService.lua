local defaultDatabase = "https://rorian-des-default-rtdb.firebaseio.com/"; --// Database URL
local authenticationToken = "bc21Qn88fpbHdnfMI5HLExC6qM3tQMoD1z3bbkm8"; --// Authentication Token

--== Variables;
local HttpService = game:GetService("HttpService");
local DataStoreService = game:GetService("DataStoreService");

local SirJayService = {};
local UseSirJay = true;

function SirJayService:SetUseSirJay(value)
	UseSirJay = value and true or false;
end

function SirJayService:GetSirJay(name, database)
	database = database or defaultDatabase;
	local datastore = DataStoreService:GetDataStore(name);

	local databaseName = database..HttpService:UrlEncode(name);
	local authentication = ".json?auth="..authenticationToken;

	local SirJay = {};

	function SirJay.GetDatastore()
		return datastore;
	end

	--// Entries Start
	function SirJay:GetAsync(directory)
		local data = nil;

		--== SirJay Get;
		local getTick = tick();
		local tries = 0; repeat until pcall(function() tries = tries +1;
			data = HttpService:GetAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, true);
		end) or tries > 2;
		if type(data) == "string" then
			if data:sub(1,1) == '"' then
				return data:sub(2, data:len()-1);
			elseif data:len() <= 0 then
				return nil;
			end
		end
		return tonumber(data) or data ~= "null" and data or nil;
	end

	function SirJay:SetAsync(directory, value, header)
		if not UseSirJay then return end
		if value == "[]" then self:RemoveAsync(directory); return end;

		header = header or {["X-HTTP-Method-Override"]="PUT"};
		local replyJson = "";
		if type(value) == "string" and value:len() >= 1 and value:sub(1,1) ~= "{" and value:sub(1,1) ~= "[" then
			value = '"'..value..'"';
		end
		local success, errorMessage = pcall(function()
			replyJson = HttpService:PostAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, value,
				Enum.HttpContentType.ApplicationUrlEncoded, false, header);
		end);
		if not success then
			warn("SirJayService>> [ERROR] "..errorMessage);
			pcall(function()
				replyJson = HttpService:JSONDecode(replyJson or "[]");
			end)
		end
	end
	
	function SirJayService:GetOrderedBase(name, database)
		local OrderedStore = self:GetSirJay(name, database)

		function OrderedStore:GetSortedAsync(ascending, pageSize)
			local data = HttpService:JSONDecode(self:GetAsync())
			local pages = {}

			local sortedData = {}
			local sortedPages = {}

			local maxFullPages
			local currentPage = 1    
			for id, score in pairs(data) do 
				sortedData[#sortedData+1] = {key = id, value = score}
			end

			table.sort(sortedData, function(plr, plr2)
				if ascending then return plr.value < plr2.value end
				return plr.value > plr2.value
			end)

			maxFullPages = #sortedData//pageSize

			--sort into pages

			for i = 1, maxFullPages do
				sortedPages[i] = {}

				local maxReach = i * pageSize -- minIndex required for currentPage
				local minReach = maxReach - pageSize -- maxIndex required for currentPage

				for index, data in pairs(sortedData) do
					if index >= minReach and index <= maxReach then
						table.insert(sortedPages[i], data)
						sortedData[index] = nil
					end                
				end
			end

			if next(sortedData) ~= nil then
				sortedPages[#sortedPages+1] = {}
				local latestPage = sortedPages[#sortedPages]

				for _, data in pairs(sortedData) do
					table.insert(latestPage, data)
				end
			end                    

			function pages:GetCurrentPage()
				return sortedPages[currentPage] or {}
			end

			function pages:AdvanceToNextPageAsync()
				currentPage += 1
			end

			return pages
		end

		return OrderedStore
	end

	function SirJay:RemoveAsync(directory)
		if not UseSirJay then return end
		self:SetAsync(directory, "", {["X-HTTP-Method-Override"]="DELETE"});
	end

	function SirJay:IncrementAsync(directory, delta)
		delta = delta or 1;
		if type(delta) ~= "number" then warn("SirJayService>> increment delta is not a number for key ("..directory.."), delta(",delta,")"); return end;
		local data = self:GetAsync(directory) or 0;
		if data and type(data) == "number" then
			data = data+delta;
			self:SetAsync(directory, data);
		else
			warn("SirJayService>> Invalid data type to increment for key ("..directory..")");
		end
		return data;
	end

	function SirJay:UpdateAsync(directory, callback)
		local data = self:GetAsync(directory);
		local callbackData = callback(data);
		if callbackData then
			self:SetAsync(directory, callbackData);
		end
	end

	return SirJay;
end

return SirJayService;
