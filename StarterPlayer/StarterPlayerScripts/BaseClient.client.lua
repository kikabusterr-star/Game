local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Optional cosmetic: highlight owned base billboard color.
local function onCharacterAdded(character)
    local player = Players.LocalPlayer
    task.wait(1)
    local base = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild("Base" .. (player:GetAttribute("BaseId") or ""))
    if not base then
        return
    end
    local billboard = base:FindFirstChild("OwnerBillboard", true)
    if billboard then
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then
            label.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
end

Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
