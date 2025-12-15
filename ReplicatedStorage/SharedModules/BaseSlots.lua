local BaseSlots = {}

function BaseSlots.GetSlotWorldCFrame(baseModel, index)
    local displayFolder = baseModel:FindFirstChild("DisplaySlots")
    if displayFolder then
        local part = displayFolder:FindFirstChild("Slot" .. index)
        if part and part:IsA("BasePart") then
            return part.CFrame
        end
    end

    -- fallback: grid near PurchaseSpot
    local spot = baseModel:FindFirstChild("PurchaseSpot")
    local origin = spot and spot.CFrame or baseModel.PrimaryPart and baseModel.PrimaryPart.CFrame
    if not origin then
        return CFrame.new()
    end

    local size = 4
    local row = math.floor((index - 1) / 3)
    local col = (index - 1) % 3
    return origin * CFrame.new(col * size, 0, row * size)
end

return BaseSlots
