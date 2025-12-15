local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(game:GetService("ReplicatedStorage").SharedModules.Config)
local BrainrotDefinitions = require(game:GetService("ReplicatedStorage").SharedModules.BrainrotDefinitions)

local EconomyService = {}
EconomyService.PlayerData = {}
EconomyService.OnIncomeTick = Instance.new("BindableEvent")

local idToBrainrot = {}
for _, item in ipairs(BrainrotDefinitions) do
    idToBrainrot[item.id] = item
end

function EconomyService:Init(dataService, eventService)
    self.DataService = dataService
    self.EventService = eventService

    Players.PlayerAdded:Connect(function(player)
        self:SetupPlayer(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:TeardownPlayer(player)
    end)

    task.spawn(function()
        while true do
            task.wait(Config.PassiveIncomeInterval)
            self:TickIncome()
        end
    end)
end

function EconomyService:SetupPlayer(player)
    local key = player.UserId
    local data = self.DataService:GetAsync(key)
    self.PlayerData[player] = data

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Money"
    money.Value = data.money or 0
    money.Parent = leaderstats

    local rebirths = Instance.new("IntValue")
    rebirths.Name = "Rebirths"
    rebirths.Value = data.rebirths or 0
    rebirths.Parent = leaderstats

    local owned = Instance.new("IntValue")
    owned.Name = "BrainrotsOwned"
    owned.Value = #data.ownedBrainrots
    owned.Parent = leaderstats
end

function EconomyService:TeardownPlayer(player)
    self:SavePlayer(player)
    self.PlayerData[player] = nil
end

function EconomyService:SavePlayer(player)
    local data = self.PlayerData[player]
    if not data then
        return
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        data.money = leaderstats.Money.Value
        data.rebirths = leaderstats.Rebirths.Value
    end

    self.DataService:SetAsync(player.UserId, data)
end

function EconomyService:GetData(player)
    return self.PlayerData[player]
end

function EconomyService:GetOwnedCount(player)
    local data = self.PlayerData[player]
    if not data then
        return 0
    end
    return #data.ownedBrainrots
end

function EconomyService:AddBrainrot(player, brainrotId)
    local data = self.PlayerData[player]
    if not data then
        return false
    end

    table.insert(data.ownedBrainrots, brainrotId)

    local ownedStat = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("BrainrotsOwned")
    if ownedStat then
        ownedStat.Value = #data.ownedBrainrots
    end

    return true
end

function EconomyService:HasFunds(player, cost)
    local leaderstats = player:FindFirstChild("leaderstats")
    return leaderstats and leaderstats.Money.Value >= cost
end

function EconomyService:Charge(player, cost)
    if not self:HasFunds(player, cost) then
        return false
    end
    player.leaderstats.Money.Value -= cost
    local data = self.PlayerData[player]
    if data then
        data.money = player.leaderstats.Money.Value
    end
    return true
end

function EconomyService:AddMoney(player, amount)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return
    end
    leaderstats.Money.Value += math.floor(amount)
    local data = self.PlayerData[player]
    if data then
        data.money = leaderstats.Money.Value
    end
end

function EconomyService:GetPlayerMultipliers(player)
    local data = self.PlayerData[player]
    if not data then
        return Config.DefaultIncomeMultiplier, Config.DefaultSpawnLuck, Config.BaseCapacity
    end

    local upgradeIncome = 1 + (data.upgrades.incomeMultiplier or 0) * Config.Upgrades.incomeMultiplier.multiplier
    local incomeMultiplier = upgradeIncome * (self.EventService:GetCurrentMultiplier())
    local spawnLuck = Config.DefaultSpawnLuck + (data.upgrades.spawnLuck or 0) * Config.Upgrades.spawnLuck.increment
    local capacity = Config.BaseCapacity + (data.upgrades.baseCapacity or 0) * Config.Upgrades.baseCapacity.increment
    return incomeMultiplier, spawnLuck, capacity
end

function EconomyService:TickIncome()
    for player, data in pairs(self.PlayerData) do
        local incomeMultiplier = self.EventService:GetCurrentMultiplier()
        local baseUpgradeBonus = 1 + (data.upgrades.incomeMultiplier or 0) * Config.Upgrades.incomeMultiplier.multiplier
        local multiplier = Config.DefaultIncomeMultiplier * baseUpgradeBonus * incomeMultiplier

        local total = 0
        for _, brainrotId in ipairs(data.ownedBrainrots) do
            local def = idToBrainrot[brainrotId]
            if def then
                total += def.incomePerSecond * Config.PassiveIncomeInterval
            end
        end

        total *= multiplier
        if total > 0 then
            self:AddMoney(player, total)
            self.OnIncomeTick:Fire(player, total, multiplier)
        end
    end
end

return EconomyService
