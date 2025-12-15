local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local DataService = {}
DataService.Store = DataStoreService:GetDataStore("BrainrotTycoonV1")
DataService.MockMemory = {}

local function deepCopy(tbl)
    return HttpService:JSONDecode(HttpService:JSONEncode(tbl))
end

local defaultData = {
    money = 100,
    rebirths = 0,
    ownedBrainrots = {},
    upgrades = {
        incomeMultiplier = 0,
        spawnLuck = 0,
        baseCapacity = 0,
    },
    lastBaseId = nil,
}

function DataService:GetAsync(key)
    local success, result = pcall(function()
        return self.Store:GetAsync(key)
    end)
    if success and result ~= nil then
        return result
    end

    return deepCopy(self.MockMemory[key]) or deepCopy(defaultData)
end

function DataService:SetAsync(key, data)
    self.MockMemory[key] = deepCopy(data)
    pcall(function()
        self.Store:SetAsync(key, data)
    end)
end

function DataService:UpdateAsync(key, cb)
    local current = self:GetAsync(key)
    local newValue = cb(current)
    self:SetAsync(key, newValue)
    return newValue
end

function DataService:GetDefault()
    return deepCopy(defaultData)
end

return DataService
