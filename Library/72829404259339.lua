repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.CreatorId == 15009415
repeat task.wait(20) until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild('HUD')

print('-- Anime Rangers X')

local request = http_request or request or HttpPost or (syn and syn.request)
local httpservices = game:GetService("HttpService")
local player = game:GetService("Players").LocalPlayer
local replicate = game:GetService("ReplicatedStorage"):WaitForChild("Player_Data"):WaitForChild(player.Name)

-- variables
_G.Config = {
   Collections = {"Ace"}
}

task.spawn(function()
    while true do task.wait()
        local gui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild('AFKChamber')
        if gui and not gui.Enabled then
            x, p = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("AFKWorldTeleport"):FireServer()
                task.wait(5)
            end)
        end
    end
end)

local function getValue() 

    local Result = {gem = 0, gold = 0, level = 0, reroll = 0}

    if replicate and replicate:FindFirstChild("Data") then
        local gem = replicate.Data.Gem.Value
        local gold = replicate.Data.Gold.Value
        local level = replicate.Data.Level.Value

        Result.gem = gem
        Result.gold = gold
        Result.level = level

    end
    if replicate and replicate:FindFirstChild("Items") then
        local trait = replicate.Items:FindFirstChild('Trait Reroll')
        if trait then
            local reroll = trait.Amount.Value
            Result.reroll = reroll
        end
    end
    return Result
end

local function getCollection()
    local collection = {}
    local lookup = {}
    for _, v in ipairs(replicate.Collection:GetChildren()) do 
        if table.find(_G.Config.Collections, v.Name) and not lookup[v.Name] then
            table.insert(collection, v.Name)
            lookup[v.Name] = v.Name
        end
    end
    return collection
end

local function discord_notify(collection, rewards)
    local embedData = {
        color = tonumber(_G.colorEmbed),
        author = {
            name = "# Arise Crossover"
        },
        fields = {
            {
                name = "📋 Account - Information",
                value = "➟ Roblox Username:  " .. player.Name .. " ",
                inline = false
            },
            {
            name = "✨ Collection - ของสะสม",
            value = #collection > 0 and ("✅ **" .. table.concat(collection, ", ") .. "**") or "No Collection",
            inline = false
        },
        {
            name = "🎁 Rewards - ของที่ได้รับ",
            value = rewards ~= '' and rewards or "No rewards",
            inline = false
        }
        },
        image = {
            url = tostring(_G.banerUrl)
        }
    }

    local payload = {
        username = tostring(_G.avatarName),
        avatar_url = tostring(_G.avatarUrl),
        embeds = {embedData}
    }

    local jsonPayload = httpservices:JSONEncode(payload)

    local response = request({
        Url = tostring(_G.webhookUrl),
        Body = jsonPayload,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })
end

task.spawn(function()
    while true do task.wait(300) 
        local success, err = pcall(function()
            local rewards = getValue() or 'None'
            local collection = getCollection() or {}
            discord_notify(collection, '💎 Gems: `'..rewards.gem..'x`'..'  💰 Gold: `'..rewards.gold..'x`'..'  🎲 Reroll: `'..rewards.reroll..'x`')
            print("Sended to Discord")
        end)
        if not success then
            warn(`error: {tostring(err)}`)
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Anime Rangers X", -- Required
    Text = "", -- Required
})
