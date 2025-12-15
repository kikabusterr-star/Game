# Brainrot Conveyor Tycoon (Roblox draft)

This repo contains script sources and layout notes for a Roblox experience featuring a conveyor of Brainrot PNG offers, eight claimable bases, passive income, random events, and three shop types (money, Robux placeholder, and crafting).

Highlights:
- Bases auto-assign on join; attempt to restore previous base if free.
- Conveyor spawns Brainrot offers that can be bought with a ProximityPrompt.
- Purchases are cloned into the player's base and add to passive income.
- Economy stored server-side with DataStore fallback to in-memory table.
- Radioactive and Snow events apply a temporary income buff and broadcast to UI.
- Shop upgrades, Robux purchase stubs, and crafting (3 commons -> upgraded common).
- HUD shows money, rebirths, owned count, shop buttons, and event banner.

See `EXPLORER.md` for the exact Roblox Explorer hierarchy to create, and the files under `Workspace/` and `ServerStorage/Templates/` for placement/model TODOs.
