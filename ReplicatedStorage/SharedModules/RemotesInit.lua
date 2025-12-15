local Remotes = {}

local function waitForChildOfClass(parent, name, className)
    local child = parent:FindFirstChild(name)
    while not child or not child:IsA(className) do
        child = parent:WaitForChild(name)
        if child and child:IsA(className) then
            break
        end
    end
    return child
end

function Remotes.Get()
    local storage = game:GetService("ReplicatedStorage")
    local folder = storage:WaitForChild("Remotes")
    return {
        BrainrotPurchase = waitForChildOfClass(folder, "BrainrotPurchase", "RemoteEvent"),
        MoneyShopPurchase = waitForChildOfClass(folder, "MoneyShopPurchase", "RemoteEvent"),
        RobuxShopPurchase = waitForChildOfClass(folder, "RobuxShopPurchase", "RemoteEvent"),
        CraftRequest = waitForChildOfClass(folder, "CraftRequest", "RemoteEvent"),
        EventBroadcast = waitForChildOfClass(folder, "EventBroadcast", "RemoteEvent"),
        DataRequest = waitForChildOfClass(folder, "DataRequest", "RemoteFunction"),
    }
end

return Remotes
