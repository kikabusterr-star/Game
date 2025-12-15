local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.SharedModules.RemotesInit).Get()
local Config = require(ReplicatedStorage.SharedModules.Config)

local player = Players.LocalPlayer
local gui = script.Parent
local statsFrame = gui:WaitForChild("StatsFrame")
local eventBanner = gui:WaitForChild("EventBanner")
local shopButtons = gui:WaitForChild("ShopButtons")
local moneyShop = gui:WaitForChild("MoneyShopFrame")
local robuxShop = gui:WaitForChild("RobuxShopFrame")
local craftFrame = gui:WaitForChild("CraftingFrame")

local function setVisibleOnly(frame)
    moneyShop.Visible = frame == moneyShop
    robuxShop.Visible = frame == robuxShop
    craftFrame.Visible = frame == craftFrame
end

local function updateStats()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return
    end
    statsFrame.MoneyLabel.Text = "Money: " .. leaderstats.Money.Value
    statsFrame.RebirthLabel.Text = "Rebirths: " .. leaderstats.Rebirths.Value
    statsFrame.OwnedLabel.Text = "Brainrots: " .. leaderstats.BrainrotsOwned.Value
end

player:WaitForChild("leaderstats").ChildAdded:Connect(updateStats)
player.leaderstats.ChildRemoved:Connect(updateStats)
player.leaderstats.ChildAdded:Connect(function(child)
    child.Changed:Connect(updateStats)
end)
for _, child in ipairs(player.leaderstats:GetChildren()) do
    child.Changed:Connect(updateStats)
end
updateStats()

local function handleEventBroadcast(payload)
    if payload.event then
        eventBanner.Visible = true
        eventBanner.EventName.Text = payload.config and payload.config.name or payload.event
        local endsAt = payload.endsAt or 0
        task.spawn(function()
            while tick() < endsAt do
                eventBanner.EventTimer.Text = string.format("Ends in %ds", math.floor(endsAt - tick()))
                task.wait(1)
            end
            eventBanner.Visible = false
        end)
    else
        eventBanner.Visible = false
    end
end

Remotes.EventBroadcast.OnClientEvent:Connect(handleEventBroadcast)

shopButtons.MoneyShopButton.MouseButton1Click:Connect(function()
    setVisibleOnly(moneyShop)
end)
shopButtons.RobuxShopButton.MouseButton1Click:Connect(function()
    setVisibleOnly(robuxShop)
end)
shopButtons.CraftButton.MouseButton1Click:Connect(function()
    setVisibleOnly(craftFrame)
end)

moneyShop.IncomeUpgrade.MouseButton1Click:Connect(function()
    Remotes.MoneyShopPurchase:FireServer("incomeMultiplier")
end)
moneyShop.SpawnLuckUpgrade.MouseButton1Click:Connect(function()
    Remotes.MoneyShopPurchase:FireServer("spawnLuck")
end)
moneyShop.BaseCapacityUpgrade.MouseButton1Click:Connect(function()
    Remotes.MoneyShopPurchase:FireServer("baseCapacity")
end)

robuxShop.DoubleMoney.MouseButton1Click:Connect(function()
    Remotes.RobuxShopPurchase:FireServer("TODO_PRODUCT_ID_DOUBLE")
end)
robuxShop.VIP.MouseButton1Click:Connect(function()
    Remotes.RobuxShopPurchase:FireServer("TODO_PRODUCT_ID_VIP")
end)

craftFrame.CraftButton.MouseButton1Click:Connect(function()
    local targetId = craftFrame.BrainrotIdBox.Text
    Remotes.CraftRequest:FireServer(targetId)
end)

-- initial pull for event state
local ok, payload = pcall(function()
    return Remotes.DataRequest:InvokeServer()
end)
if ok and payload then
    if payload.activeEvent then
        handleEventBroadcast({
            event = payload.activeEvent,
            endsAt = payload.eventEndsAt,
            config = payload.definitions and payload.definitions[payload.activeEvent],
        })
    end
end
