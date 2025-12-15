local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.SharedModules.Config)
local EventConfig = require(ReplicatedStorage.SharedModules.EventConfig)
local RemotesInit = require(ReplicatedStorage.SharedModules.RemotesInit)

local EventService = {}
EventService.CurrentEvent = nil
EventService.EndTime = 0

function EventService:Init()
    self.Remotes = RemotesInit.Get()

    task.spawn(function()
        while true do
            task.wait(Config.EventCheckInterval)
            self:RollEvent()
        end
    end)
end

function EventService:GetCurrentMultiplier()
    if self.CurrentEvent then
        local def = EventConfig.Events[self.CurrentEvent]
        return def and def.multiplier or Config.EventIncomeMultiplier
    end
    return 1
end

function EventService:RollEvent()
    local keys = {}
    for key in pairs(EventConfig.Events) do
        table.insert(keys, key)
    end
    if #keys == 0 then
        return
    end

    local chosen = keys[math.random(1, #keys)]
    self:StartEvent(chosen)
end

function EventService:StartEvent(eventKey)
    self.CurrentEvent = eventKey
    self.EndTime = tick() + Config.EventDuration
    self:Broadcast()

    task.delay(Config.EventDuration, function()
        if tick() >= self.EndTime then
            self.CurrentEvent = nil
            self:Broadcast()
        end
    end)
end

function EventService:Broadcast()
    if not self.Remotes then
        return
    end
    self.Remotes.EventBroadcast:FireAllClients({
        event = self.CurrentEvent,
        endsAt = self.EndTime,
        config = EventConfig.Events[self.CurrentEvent],
    })
end

return EventService
