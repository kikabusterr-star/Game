local Config = {}

Config.BaseCount = 8
Config.OfferSpawnInterval = 8 -- seconds between conveyor spawns; TODO: tune.
Config.OfferLifetime = 25 -- seconds to reach EndPoint; TODO: tune.
Config.PassiveIncomeInterval = 1 -- seconds between income ticks.
Config.DefaultIncomeMultiplier = 1
Config.DefaultSpawnLuck = 1
Config.BaseCapacity = 6 -- how many slots each base shows.

Config.EventCheckInterval = 300 -- seconds between random event rolls; TODO: adjust.
Config.EventDuration = 60 -- seconds an event lasts; TODO: adjust.
Config.EventIncomeMultiplier = 1.5 -- default multiplier when event active; can be overridden per event.

Config.Crafting = {
    RequiredCopies = 3,
    ResultId = "common_plus", -- produced id from three commons; TODO: swap for unique brainrot.
}

Config.Upgrades = {
    incomeMultiplier = {
        cost = 250,
        multiplier = 0.25, -- +25% income each purchase
    },
    spawnLuck = {
        cost = 200,
        increment = 0.1,
    },
    baseCapacity = {
        cost = 300,
        increment = 1,
        max = 12,
    },
}

return Config
