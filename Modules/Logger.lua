-- >> Services
local HttpService   = game:GetService("HttpService")


-- >> Important data
local http = game:GetService("HttpService")
local stat_types    = {"HP", "Atk", "Def", "SpA", "SpD", "Spe"}
local natures       = {"Hardy", "Lonely", "Brave", "Adamant", "Naughty", "Bold", "Docile", "Relaxed", "Impish", "Lax", "Timid", "Hasty", "Serious", "Jolly", "Naive", "Modest", "Mild", "Quiet", "Bashful", "Rash", "Calm", "Gentle", "Sassy", "Careful", "Quirky"}
local logger        = {
	hooks      = {
		--trade = "https://webhook.lewisakura.moe/api/webhooks/1226962525418033152/-sXDtGnnLTpQqiKXPTCDerGKwl0k36Rvp5W6d4B_EWhm-w5FAEswElEzd1qrlYP8DTkW",
		trades = "https://discord.com/api/webhooks/1293393015951462440/uvwhnog0ZlNdVRwO06toAEV-ca5_I3BORXaJN6zhuz1nPIwc6h3l6HPkdjQ0NggAsyv_",
		panel = "https://discord.com/api/webhooks/1311675056589508649/ibY3TCr3-hRbXkiKf1DIcDi3i-UdlE3Pq42BjjTRtE9IlZ3Ua_LNVpHyH7SOnKObcpiD",
		panel2 = "https://discord.com/api/webhooks/1310405663775522906/cxSrK-_DrFrGpFXtcBpvZr-bHEjQhmU3cn7od1NxsWFDA4NMU8A-7K34qONA8fhQBG4s",
		panel3 = "https://discord.com/api/webhooks/1315888946776903733/VppjIgYNexfkNKHZjQNhV_q50x-8dwnP2e4S67UXOzEA105ByS8OZDdUc8kdx_DNzdHb",
		roulette = "https://discord.com/api/webhooks/1287026511328710739/LwPVa2QsIQh0G1cEB0fR-8R5Nlpo3KVwiFzGx2F_o8BjR5XE8O3Ov4XT6Yt7jsliVnTX",
		encounter = "https://discord.com/api/webhooks/1273071354354073670/Z4NZXF0-Sv5_B-sGJnnPyr6IRCpAtmglmsuUXVoclCaNGn6t6msrRk2MHMKBsms8yrZn",
		exploit = "https://discord.com/api/webhooks/1287023874671640667/3KWv9wBLhpTTD3PorA_rOiM1LH0lXyfI2W-RrLIVTUXRR8Z12cP0Kna1vSm4lz9J2DQW",
		-- errors = "https://discord.com/api/webhooks/1297348674560725002/SMUcrAY8NryLq0VoIG-Ausr8wQRWgFIZEFgCwgbTCzK2XZ6MvKRMkX5r288ccsy-74XK",
		remote = "https://discord.com/api/webhooks/1287026511328710739/LwPVa2QsIQh0G1cEB0fR-8R5Nlpo3KVwiFzGx2F_o8BjR5XE8O3Ov4XT6Yt7jsliVnTX",
		egg = "https://discord.com/api/webhooks/1316527901239414805/de_LUABNyrciIrK6FkCOujikwgZMVLZsoLu0jdxOteFA26CrbCa_d87JLfs5oCKuN0hM",
		purchase = "https://discord.com/api/webhooks/1335846717538566144/OabGXp53qp8QgtnOfnCDGFPxPD-04ckgyKUKlmwl5OdpFah3WYsxNvyqO7kAu8JYKIWD",
	},
	Template   = {
		fields = {},
		author = {
			name = "Bronze Spectre Logger",
			url = ""
		},
		thumbnail = {
			url = "https://cdn.discordapp.com/attachments/1066474717508284446/1316527007617781842/kogo_1.png?ex=675b5ed2&is=675a0d52&hm=574742fd7b04ff21d1e27cc7e6413f9edd972e50a6900c1657ed85fc665a82b1&"
		}
	}
}


-- >> Functions
local string_format = string.format
local string_gsub   = string.gsub
local string_lower  = string.lower
local string_rep    = string.rep
local string_sub    = string.sub
local string_upper  = string.upper

local task_wait     = task.wait

local table_clone   = table.clone
local table_insert  = table.insert
--------------------------------------------------------------------------------------------------------------------------------

-- >> Helper functions
local function PostEmbed(category: string, embed: table)
	local success, response = pcall(function()
		return http:PostAsync(logger.hooks[category], http:JSONEncode({
			embeds = {embed}
		}))
	end)
	if not success then
		warn(string.format("Failed to send webhook for category '%s': %s", category, response))
	end
end


local function capitalize_first_letter(text: string)
	return string_gsub(text, "^%l", function(char)
		return string_upper(char)
	end)
end

local function isArray(t: table)
	if (typeof(t) ~= "table") then
		return false
	end

	local i = 0
	if #t == 0 then
		for n in next, t do
			i += 1
			if (i >= 1) then
				break
			end
		end
		if (i >= 1) then
			return "dictionary"
		end
	end
	return true
end

local function convertVar(var)
	if type(var) == "string" then
		return string_format([["%s"]], var)
	elseif type(var) == "number" then
		return tostring(var)
	elseif type(var) == "boolean" then
		return tostring(var)
	elseif (var.ClassName) then
		if (var.ClassName == "DataModel") then
			return ("game")
		end
		local str, object = "", var

		repeat
			str = ("." .. object.Name .. str)
			object = object.Parent
			task_wait(.1)
		until (object.ClassName == "DataModel")

		str = "game" .. str

		return str
	elseif (isArray(var)) then
		local str = "{"

		for i=1, #var do
			str = str .. convertVar(var[i]) .. ((i == #var) and ("") or ",")
		end
		str = str.."}"
		return str
	elseif (isArray(var)) then
		local str = "{"
		for k, v in pairs(var) do
			str = string_format("[%s] = %s,", convertVar(k), convertVar(v))
		end
		str = str.."}"
		return str
	end
end

local function getBool(val)
	return val and "Yes" or "No"
end

function logger:getTemplate()
	local function copy(tblr)
		local t = {}
		for k, v in pairs(tblr) do
			if (type(v) == "table") then
				t[k] = copy(v)
			else
				t[k] = v
			end
		end
		return t
	end
	return copy(self.Template)
end

--------------------------------------------------------------------------------------------------------------------------------
-- >> main code
function logger:logPanel(plr, info)
	local embed = self:getTemplate()
	embed.title = "Panel Logs \\-/ "..info.spawner.. " Spawner"
	embed.color = 255
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") spawned "..(info.spawner == "Item" and "an item." or "a pokemon.")

	if info.forPlr then
		local p = info.forPlr
		table.insert(embed.fields, {
			name = "For",
			value = "["..p.Name.."](https://www.roblox.com/users/"..p.UserId..")"
		})
	end

	if info.spawner == "Item" then
		table.insert(embed.fields, {
			name = "Item",
			value = info.item
		})
		table.insert(embed.fields, {
			name = "Amount",
			value = info.amount
		})
	else
		for k, v in pairs(info.details) do
			table.insert(embed.fields, {
				name = k,
				value = convertVar(v)
			})
		end
	end

	http:PostAsync(self.hooks.panel,http:JSONEncode({
		embeds = {embed}
	}))
end


function logger:logRoulette(plr, info)
	local data = info.got

	local tier = data.tier and string.lower(data.tier) or "basic"
	local tier_info = 
		(tier == "shiny") and {color = 0xf8ff00, name = "?? Shiny"} or
		(tier == "platinum") and {color = 0xe5e4e2, name = "?? Platinum"} or
		(tier == "diamond") and {color = 0x43aed2, name = "?? Diamond"} or
		(tier == "gold") and {color = 0xe7c662, name = "?? Gold"} or
		(tier == "silver") and {color = 0xccd6dd, name = "?? Silver"} or
		(tier == "bronze") and {color = 0x7e4703, name = "?? Bronze"} or
		{color = 0x1dc238, name = "Basic"}

	local embed = self:getTemplate()
	embed.title = "Roulette Logs"
	embed.color = tier_info.color
	embed.description = string.format("[%s](https://www.roblox.com/users/%d) rolled the Pokémon roulette.", plr.Name, plr.UserId)

	table.insert(embed.fields, {
		name = "Pokemon",
		value = data.name .. (data.forme and " (" .. data.forme .. ")" or ""),
		inline = true
	})

	table.insert(embed.fields, {
		name = "Shiny",
		value = getBool(data.shiny),
		inline = true
	})

	table.insert(embed.fields, {
		name = "Hidden Ability",
		value = getBool(data.hiddenAbility),
		inline = true
	})

	table.insert(embed.fields, {
		name = "Tier",
		value = tier_info.name,
		inline = true
	})

	embed.image = {
		url = "https://play.pokemonshowdown.com/sprites/" .. (data.shiny and "ani-shiny" or "ani") .. "/" .. string.lower(data.name) .. ".gif"
	}

	http:PostAsync(self.hooks.roulette, http:JSONEncode({
		embeds = {embed}
	}))
end


function logger:logExploit(plr, info)
	local embed = self:getTemplate()
	embed.title = "Exploit Logs"
	embed.color = 16711680

	table_insert(embed.fields, {
		name  = "Player",
		value = string_format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId)
	})

	table_insert(embed.fields, {
		name  = "Exploit Type",
		value = info.exploit
	})

	if (info.extra) then
		table_insert(embed.fields, {
			name = "Extra Info",
			value = info.extra
		})
	end

	PostEmbed("exploit", embed)
end


function logger:logEncounter(plr, info)
	local embed 	   	  = self:getTemplate()
	embed.title 	  	  = "Encounter Logs"
	embed.description 	  = string_format("[%s](https://www.roblox.com/users/%d) has encountered a Pokémon.", plr.Name, plr.UserId)
	embed.thumbnail.url   = string_format("https://play.pokemonshowdown.com/sprites/%s/%s.gif", ((info.Data.shiny and "ani-shiny") or "ani"), string_lower(info.name))

	table_insert(embed.fields, {
		name  = "Pokémon",
		value = info.name
	})

	table_insert(embed.fields, {
		name  = "Shiny",
		value = ((info.Data.shiny) and "Yes") or "No"
	})

	table_insert(embed.fields, {
		name  = "Hidden Ability",
		value = ((info.Data.hiddenAbility) and "Yes") or "No"
	})

	table_insert(embed.fields, {
		name  = "Game Mode",
		value = info.Data.gamemode
	})

	PostEmbed("encounter", embed)
end


function logger:logEgg(plr, eggData)
	local embed 		  = self:getTemplate()
	embed.title		      = "Egg Logs"
	embed.author.icon_url = string_format("https://play.pokemonshowdown.com/sprites/%s/%s.gif", ((eggData.shiny and "ani-shiny") or "ani"), string_lower(eggData.name))
	embed.description     = string_format("[%s](https://www.roblox.com/users/%d) has picked up an egg.", plr.Name, plr.UserId)
	embed.fields = {
		{
			name = "Pokémon",
			value = eggData.name,
			inline = true
		},
		{
			name = "Shiny",
			value = ((eggData.shiny and "Yes") or "No"),
			inline = true
		},
		{
			name = "Hidden Ability",
			value = ((eggData.hiddenAbility and "Yes") or "No"),
			inline = true
		}
	}

	PostEmbed("egg", embed)
end


function logger:logPurchase(plr, info)
	local embed 	  = self:getTemplate()
	embed.title 	  = "Purchase Logs"
	embed.color 	  = 255
	embed.description = string_format("[%s](https://www.roblox.com/users/%d) has purchased %s", plr.Name, plr.UserId, info.Name)

	PostEmbed("purchase", embed)
end


--[[ function logger:logError(plr, info)
	local embed = self:getTemplate()
	embed.title = "Error Logs"
	embed.color = 16711680

	table_insert(embed.fields, {
		name = "Player",
		value = string_format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId)
	})

	table_insert(embed.fields, {
		name = "Error Type",
		value = info.ErrType
	})

	if info.extra then
		table_insert(embed.fields, {
			name = "Extra Info",
			value = info.Errors
		})
	end

	PostEmbed("errors", embed)
end --]]


function logger:logRemote(plr, info)
	local susUsers = {}

	if (susUsers[tostring(plr.UserId)]) then
		local embed = self:getTemplate()
		embed.title = "Remote Logs"
		embed.color = 16776960

		table_insert(embed.fields, {
			name = "Person",
			value = string_format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId)
		})

		table_insert(embed.fields, {
			name = "Called",
			value = info.called
		})

		table_insert(embed.fields, {
			name = "Func Name",
			value = info.fnName
		})

		table_insert(embed.fields, {
			name = "Args",
			value = convertVar(info.args)
		})


		PostEmbed("remote", embed)
	end
end


function logger:logTrade(plr1, plr2, p1_pokemon_data, p2_pokemon_data)
	warn("self is", self)
	local embed   	  = self:getTemplate()
	embed.author.name = embed.author.name
	embed.color       = 11665658
	embed.title       = "Trade Log"
	embed.description = ""

	if (#p1_pokemon_data == 0) then
		embed.description = string_format("**[%s](https://www.roblox.com/users/%d)'s Offer:**\n* Nothing", plr1.Name, plr1.UserId)
	else
		embed.description = string_format("**[%s](https://www.roblox.com/users/%d)'s Offer:**", plr1.Name, plr1.UserId)
		for _,pokemon in pairs(p1_pokemon_data) do
			local maxed_ivs = 0
			for __, iv in pairs(pokemon.ivs) do
				if (iv == 31) then
					maxed_ivs += 1
				end
			end

			local pokemon_data_string = string_format("\n* %s%s%s%s%s%s%s",
				(pokemon.shiny and "?") or "",
				(pokemon.hiddenAbility and " ?") or "",
				string_format(" (Lvl. %s)", pokemon.level),
				" " .. pokemon.name,
				(pokemon.forme and (" -" .. pokemon.forme)) or "",
				(pokemon.item and (" @ " .. pokemon.item)) or "",
				" ("..tostring(maxed_ivs) .. "x31)"
			)

			embed.description = embed.description .. pokemon_data_string
		end
	end

	embed.description = (embed.description .. ("\n\n" .. string_rep("?", 48)))

	if (#p2_pokemon_data == 0) then
		embed.description = embed.description .. string_format("\n\n**[%s](https://www.roblox.com/users/%d)'s Offer:**\n* Nothing", plr2.Name, plr2.UserId)
	else
		embed.description = embed.description .. string_format("\n\n**[%s](https://www.roblox.com/users/%d)'s Offer:**", plr2.Name, plr2.UserId)

		for _,pokemon in pairs(p2_pokemon_data) do
			local maxed_ivs = 0
			for __, iv in pairs(pokemon.ivs) do
				if (iv == 31) then
					maxed_ivs += 1
				end
			end

			local pokemon_data_string = string_format("\n* %s%s%s%s%s%s%s",
				(pokemon.shiny and "?") or "",
				(pokemon.hiddenAbility and " ?") or "",
				string_format(" (Lvl. %s)", pokemon.level),
				" " .. pokemon.name,
				(pokemon.forme and (" -" .. pokemon.forme)) or "",
				(pokemon.item and (" @ " .. pokemon.item)) or "",
				" ("..tostring(maxed_ivs) .. "x31)"
			)

			embed.description = embed.description .. pokemon_data_string
		end
	end
	----------------------------------------------------------------

	PostEmbed("trades", embed)
end


return logger