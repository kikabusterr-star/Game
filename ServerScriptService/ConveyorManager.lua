local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.SharedModules.Config)
local BrainrotDefinitions = require(ReplicatedStorage.SharedModules.BrainrotDefinitions)
local RemotesInit = require(ReplicatedStorage.SharedModules.RemotesInit)

local ConveyorManager = {}

function ConveyorManager:Init(economyService, baseManager)
    self.EconomyService = economyService
    self.BaseManager = baseManager
    self.Remotes = RemotesInit.Get()
    self.Template = ServerStorage:WaitForChild("Templates"):WaitForChild("BrainrotOffer")
    self.StartPoint = Workspace.Conveyor:WaitForChild("StartPoint")
    self.EndPoint = Workspace.Conveyor:WaitForChild("EndPoint")

    self:StartLoop()
end

function ConveyorManager:StartLoop()
    task.spawn(function()
        while true do
            self:SpawnOffer()
            task.wait(Config.OfferSpawnInterval)
        end
    end)
end

function ConveyorManager:SpawnOffer()
    local offer = self.Template:Clone()
    offer.PrimaryPart.CFrame = self.StartPoint.CFrame
    offer.Parent = Workspace

    local brainrot = self:PickRandomBrainrot()
    offer:SetAttribute("BrainrotId", brainrot.id)
    offer:SetAttribute("Price", brainrot.price)

    local billboard = offer:FindFirstChildOfClass("BillboardGui")
    if billboard then
        local image = billboard:FindFirstChildOfClass("ImageLabel")
        if image then
            image.Image = brainrot.assetId
        end
        local text = billboard:FindFirstChildOfClass("TextLabel")
        if text then
            text.Text = brainrot.name .. " - $" .. brainrot.price
        end
    end

    local prompt = offer:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.ActionText = "Buy ($" .. brainrot.price .. ")"
        prompt.Triggered:Connect(function(player)
            self:TryPurchase(player, offer)
        end)
    end

    local tween = TweenService:Create(offer.PrimaryPart, TweenInfo.new(Config.OfferLifetime), {CFrame = self.EndPoint.CFrame})
    tween:Play()
    tween.Completed:Connect(function()
        if offer.Parent then
            offer:Destroy()
        end
    end)
end

function ConveyorManager:PickRandomBrainrot()
    return BrainrotDefinitions[math.random(1, #BrainrotDefinitions)]
end

function ConveyorManager:TryPurchase(player, offer)
    if not offer.Parent then
        return
    end

    local brainrotId = offer:GetAttribute("BrainrotId")
    local price = offer:GetAttribute("Price")
    if not brainrotId or not price then
        return
    end

    if not self.EconomyService:Charge(player, price) then
        return
    end

    self.EconomyService:AddBrainrot(player, brainrotId)
    offer:Destroy()

    local template = self.Template:Clone()
    template.Name = brainrotId
    template.Parent = Workspace
    self.BaseManager:PlacePurchase(player, template)
end

return ConveyorManager
