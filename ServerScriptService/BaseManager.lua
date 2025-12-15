local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.SharedModules.Config)
local BaseSlots = require(ReplicatedStorage.SharedModules.BaseSlots)

local BaseManager = {}
BaseManager.Bases = {}
BaseManager.Assignments = {}

function BaseManager:Init(economyService)
    self.EconomyService = economyService

    local basesFolder = Workspace:WaitForChild("Bases")
    for i = 1, Config.BaseCount do
        local baseModel = basesFolder:FindFirstChild("Base" .. i)
        if baseModel then
            table.insert(self.Bases, baseModel)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        self:AssignBase(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:ReleaseBase(player)
    end)
end

function BaseManager:GetBaseForPlayer(player)
    return self.Assignments[player]
end

function BaseManager:AssignBase(player)
    local desiredBaseId
    local data = self.EconomyService:GetData(player)
    if data then
        desiredBaseId = data.lastBaseId
    end

    local assigned
    if desiredBaseId then
        local base = Workspace.Bases:FindFirstChild("Base" .. desiredBaseId)
        if base and not base:GetAttribute("Taken") then
            assigned = base
        end
    end

    if not assigned then
        for _, base in ipairs(self.Bases) do
            if not base:GetAttribute("Taken") then
                assigned = base
                break
            end
        end
    end

    if not assigned then
        warn("No free bases!")
        return nil
    end

    assigned:SetAttribute("Taken", true)
    assigned:SetAttribute("OwnerUserId", player.UserId)
    self.Assignments[player] = assigned

    local data = self.EconomyService:GetData(player)
    if data then
        data.lastBaseId = tonumber(assigned.Name:match("Base(%d+)") or 0)
    end
    player:SetAttribute("BaseId", data and data.lastBaseId or tonumber(assigned.Name:match("Base(%d+)") or 0))

    local spawn = assigned:FindFirstChild("SpawnLocation")
    if spawn then
        player.RespawnLocation = spawn
    end

    local billboard = assigned:FindFirstChild("OwnerBillboard", true)
    if billboard and billboard:IsA("BillboardGui") then
        billboard.Enabled = true
        billboard:FindFirstChildOfClass("TextLabel").Text = player.Name
    end

    return assigned
end

function BaseManager:ReleaseBase(player)
    local base = self.Assignments[player]
    if base then
        base:SetAttribute("Taken", false)
        base:SetAttribute("OwnerUserId", nil)
        self.Assignments[player] = nil
    end
    player:SetAttribute("BaseId", nil)
end

function BaseManager:PlacePurchase(player, itemModel)
    local base = self.Assignments[player]
    if not base then
        return
    end

    local data = self.EconomyService:GetData(player)
    local _, _, capacity = self.EconomyService:GetPlayerMultipliers(player)
    local slotIndex = math.min((data and #data.ownedBrainrots) or 1, capacity)
    local cframe = BaseSlots.GetSlotWorldCFrame(base, slotIndex)
    itemModel:SetPrimaryPartCFrame(cframe)
    itemModel.Parent = base:FindFirstChild("Purchases") or base
end

return BaseManager
