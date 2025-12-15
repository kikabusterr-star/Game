local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Ensure remote objects exist
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local function ensureRemote(name, className)
    local existing = remotesFolder:FindFirstChild(name)
    if existing and existing:IsA(className) then
        return existing
    end
    local newRemote = Instance.new(className)
    newRemote.Name = name
    newRemote.Parent = remotesFolder
    return newRemote
end

ensureRemote("BrainrotPurchase", "RemoteEvent")
ensureRemote("MoneyShopPurchase", "RemoteEvent")
ensureRemote("RobuxShopPurchase", "RemoteEvent")
ensureRemote("CraftRequest", "RemoteEvent")
ensureRemote("EventBroadcast", "RemoteEvent")
ensureRemote("DataRequest", "RemoteFunction")

local DataService = require(script.Parent.DataService)
local EventService = require(script.Parent.EventService)
local EconomyService = require(script.Parent.EconomyService)
local BaseManager = require(script.Parent.BaseManager)
local ConveyorManager = require(script.Parent.ConveyorManager)
local ShopService = require(script.Parent.ShopService)

EventService:Init()
EconomyService:Init(DataService, EventService)
BaseManager:Init(EconomyService)
ConveyorManager:Init(EconomyService, BaseManager)
ShopService:Init(EconomyService, BaseManager, DataService)

local brainrotMap = {}
for _, def in ipairs(require(ReplicatedStorage.SharedModules.BrainrotDefinitions)) do
    brainrotMap[def.id] = def
end

remotesFolder.DataRequest.OnServerInvoke = function(player)
    local data = EconomyService:GetData(player) or DataService:GetDefault()
    return {
        money = data.money,
        rebirths = data.rebirths,
        ownedBrainrots = data.ownedBrainrots,
        upgrades = data.upgrades,
        activeEvent = EventService.CurrentEvent,
        eventEndsAt = EventService.EndTime,
        definitions = brainrotMap,
    }
end

Players.PlayerRemoving:Connect(function(player)
    EconomyService:SavePlayer(player)
end)
