# BrainrotOffer template
Create a Model named `BrainrotOffer` under `ServerStorage/Templates` with:
- `PrimaryPart` (Part) named `PrimaryPart`, CanCollide=false, Transparency=1.
- `BillboardGui` attached to the PrimaryPart with:
  - `ImageLabel` sized to fill, Image set to placeholder `rbxassetid://0` (TODO replace).
  - Optional `TextLabel` for name/price.
- `ProximityPrompt` parented to PrimaryPart, ActionText left blank (script fills price).
- Set `PrimaryPart` property on the model to the Part.

This template is cloned both for conveyor offers and for base display placements.
