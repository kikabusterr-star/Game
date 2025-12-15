local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.SharedModules.Config)
local BrainrotDefinitions = require(ReplicatedStorage.SharedModules.BrainrotDefinitions)
local RemotesInit = require(ReplicatedStorage.SharedModules.RemotesInit)

local ShopService = {}

local idToBrainrot = {}
for _, item in ipairs(BrainrotDefinitions) do
    idToBrainrot[item.id] = item
end

function ShopService:Init(economyService, baseManager, dataService)
    self.EconomyService = economyService
    self.BaseManager = baseManager
    self.DataService = dataService
    self.Remotes = RemotesInit.Get()

    self.Remotes.MoneyShopPurchase.OnServerEvent:Connect(function(player, upgradeId)
        self:HandleUpgrade(player, upgradeId)
    end)

    self.Remotes.RobuxShopPurchase.OnServerEvent:Connect(function(player, productId)
        warn("TODO: hook Developer Product purchase for", productId)
    end)

    self.Remotes.CraftRequest.OnServerEvent:Connect(function(player, brainrotId)
        self:Craft(player, brainrotId)
    end)
end

function ShopService:HandleUpgrade(player, upgradeId)
    local upgrade = Config.Upgrades[upgradeId]
    local data = self.EconomyService:GetData(player)
    if not upgrade or not data then
        return
    end

    local ownedLevel = data.upgrades[upgradeId] or 0
    if upgrade.max and ownedLevel >= upgrade.max then
        return
    end

    if not self.EconomyService:Charge(player, upgrade.cost) then
        return
    end

    data.upgrades[upgradeId] = ownedLevel + 1
end

function ShopService:Craft(player, brainrotId)
    local data = self.EconomyService:GetData(player)
    if not data then
        return
    end

    local count = 0
    for _, id in ipairs(data.ownedBrainrots) do
        if id == brainrotId then
            count += 1
        end
    end

    if count < Config.Crafting.RequiredCopies then
        return
    end

    local removed = 0
    for i = #data.ownedBrainrots, 1, -1 do
        if data.ownedBrainrots[i] == brainrotId then
            table.remove(data.ownedBrainrots, i)
            removed += 1
            if removed >= Config.Crafting.RequiredCopies then
                break
            end
        end
    end

    self.EconomyService:AddBrainrot(player, Config.Crafting.ResultId)

    local template = game.ServerStorage.Templates:FindFirstChild("BrainrotOffer")
    if template then
        local clone = template:Clone()
        clone.Name = Config.Crafting.ResultId
        clone.Parent = workspace
        self.BaseManager:PlacePurchase(player, clone)
    end
end

return ShopService
