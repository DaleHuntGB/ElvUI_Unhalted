# ElvUI: Unhalted

[![Ko-fi](https://img.shields.io/badge/Ko--fi-FF5E5B?style=for-the-badge&logo=kofi&logoColor=white)](https://ko-fi.com/unhalted)
[![Patreon](https://img.shields.io/badge/Patreon-FF424D?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/c/Unhalted)

Plugin for ElvUI, built specifically for my UI. It adds quality of life features, custom displays, and enhancements to the ElvUI suite.

Requires ElvUI. Configure the plugin under **UnhaltedUI** in ElvUI's options. Supported addons must be installed separately to use their skins and profile imports.

## Features

- **AddOn Skins:** Custom styling for LS: Toasts and the BugSack minimap icon.
- **Damage Meter:** Two independently configurable windows using Blizzard's damage meter data.
- **Combat Alert:** Customisable entering and leaving combat text, with position, font, colour, and display duration settings.
- **Combat Timer:** Combat and encounter duration anchored to the player frame, with customisable text, positioning, and opacity outside combat.
- **Buff Alerts:** Displays with selectable sounds for Bloodlust, Power Infusion, and Time Spiral.
- **Missing Buffs:** Reminders for food, flasks, and weapon enchants in dungeons and raids, plus missing raid buffs based on the classes in your group.
- **Mouse Cursor:** Additional cursor textures, with optional combat-only visibility and size, position, and colour controls for supported textures.
- **Quick Actions:** A radial menu arranged in a central circle, with square icons and 1px black borders. Assign a keybind and click to add mounts, active spells, toys, or bag consumables from a searchable catalogue.
- **ElvUI Enhancements:** Consistent loot roll backdrop opacity, action status text styling and positioning, and UI error visibility, positioning, and filtering.
- **Vendor Helper:** Automatically sells eligible items at or below your selected quality and item level limits, with built-in item and category exclusions.
- **CVars:** Control Blizzard CVars & sync them with the other characters.
- **Profile Manager:** Import my profiles for a wide-range of addons.
- **Shared Media:** Bundled sounds and a custom status bar texture.

## Quick Actions

Enable **UnhaltedUI → Quick Actions** in ElvUI's options and assign a keybind above the item row. Quick Actions uses one group, stored in `QuickAction.Groups[1]`, with a category tree for mounts, spells, toys, and consumables.

- Click a catalogue row to add the action. Each row shows its icon and title. Added actions disappear from the catalogue. Right-click an item in the item row to remove it and return it to the catalogue.
- Categories load when opened and cache their names and icons. Each page displays up to 40 actions; use the arrows or search to find an action.
- Hold the group's keybind, point towards an icon, and release to activate it. Release in the centre or press Escape to cancel.
- Icons show available consumable uses and spell charges. Cooldowns, including spell recharge timers, follow ElvUI's global cooldown settings in the menu and catalogue.
- Use **Refresh Catalogue** after changing your spells, inventory, or Toy Box filters. The toy catalogue respects those filters. Consumables are collected from equipped bags and duplicate stacks appear once.

The group and its keybind are shared across characters. The binding takes priority while the module is enabled and the group contains items; clearing the keybind or disabling the module releases it without changing saved WoW bindings. Mouse-wheel bindings are unavailable because the menu requires a held key or mouse button. Editing is disabled in combat. Spells, toys, and consumables use secure actions; mounts use the Mount Journal summon API outside combat. The game's usual action restrictions still apply.

## Quality of Life Toggles

- Automatically fill the `DELETE` confirmation text.
- Automatically sell grey items at merchants.
- Automatically confirm group applications and role checks; hold Shift to bypass.
- Reposition raid warnings.
- Hide the boss loot banner, loss of control display, and talking head dialogue.
- Automatically skip cinematics.
