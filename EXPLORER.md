# Roblox Explorer layout

This describes the Instances to create in Studio. Paths use service roots (e.g., `ServerScriptService`, `Workspace`). TODO markers highlight where to swap models/positions/assets.

## Workspace
- `Terrain` / baseplate
- `Bases` (Folder)
  - `Base1` .. `Base8` (Model)
    - `SpawnLocation` (SpawnLocation) — TODO: reposition in the map.
    - `PurchaseSpot` (Part) — location to drop purchased Brainrot; TODO: reposition.
    - `DisplaySlots` (Folder) — create a few `Slot1`..`Slot6` Parts for grid placement.
    - `OwnerBillboard` (BillboardGui) — shows player name/color.
  - TODO: replace base models/walls to match art direction.
- `Conveyor` (Folder)
  - `StartPoint` (Part) — TODO: reposition and change conveyor mesh/texture.
  - `EndPoint` (Part) — TODO: reposition.
- Optional decorative props/walls for arena boundaries.

## ServerStorage
- `Templates` (Folder)
  - `BrainrotOffer` (Model)
    - `BillboardGui` (BillboardGui)
      - `ImageLabel` (ImageLabel) — TODO: replace placeholder asset id.
    - `ProximityPrompt` (ProximityPrompt) — triggered to purchase.
    - `Attachment` (Attachment) — optional for tweening.
    - `PrimaryPart` (Part) — invisible carrier that moves along conveyor.

## ReplicatedStorage
- `Remotes` (Folder)
  - `BrainrotPurchase` (RemoteEvent)
  - `MoneyShopPurchase` (RemoteEvent)
  - `RobuxShopPurchase` (RemoteEvent)
  - `CraftRequest` (RemoteEvent)
  - `EventBroadcast` (RemoteEvent)
  - `DataRequest` (RemoteFunction) — fetch replicated player state for UI.
- `SharedModules` (Folder)
  - `Config` (ModuleScript)
  - `BrainrotDefinitions` (ModuleScript)
  - `EventConfig` (ModuleScript)
  - `BaseSlots` (ModuleScript)
  - `RemotesInit` (ModuleScript) — utility for safely locating remotes on both sides.

## ServerScriptService
- `Init` (Script) — wires services.
- `BaseManager` (ModuleScript)
- `ConveyorManager` (ModuleScript)
- `EconomyService` (ModuleScript)
- `EventService` (ModuleScript)
- `DataService` (ModuleScript)
- `ShopService` (ModuleScript)

## StarterGui
- `HUD` (ScreenGui)
  - `StatsFrame` (Frame) — Money/Rebirths/BrainrotsOwned TextLabels.
  - `EventBanner` (Frame) — shows active event + timer.
  - `ShopButtons` (Frame) — buttons to open shop frames.
  - `MoneyShopFrame` (Frame) — basic upgrade buttons.
  - `RobuxShopFrame` (Frame) — placeholder buttons with TODO product ids.
  - `CraftingFrame` (Frame) — craft UI with button.
  - `Client` (LocalScript) — handles UI + remotes.

## StarterPlayer
- `StarterPlayerScripts`
  - `BaseClient` (LocalScript) — optional client helpers for base highlighting.

