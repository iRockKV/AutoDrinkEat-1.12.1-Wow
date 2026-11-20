# AutoDrinkEat

a small Auto_Eat&amp;Drink Addon for Kronos V 1.12.1

================================================================================
AutoDrinkEat (WoW 1.12.1 / Vanilla)
================================================================================

A lightweight, event-driven addon for automated eating and drinking with 
zone-aware item prioritization (Mage consumables -> Battleground rations -> 
Standard vendor supplies) and dynamic icon/count syncing for SuperMacro.


--------------------------------------------------------------------------------
1. INSTALLATION
--------------------------------------------------------------------------------
1. Copy the "AutoDrinkEat" folder into your WoW AddOns directory:
   World of Warcraft\Interface\AddOns\AutoDrinkEat
2. Make sure both "AutoDrinkEat.toc" and "AutoDrinkEat.lua" are inside 
   the folder.
3. Restart WoW or type "/reload" in-game.


--------------------------------------------------------------------------------
2. MACRO SETUP (IMPORTANT!)
--------------------------------------------------------------------------------
To enable dynamic icon and item count updates via SuperMacro:

1. Open the STANDARD Blizzard macro window by typing:
   /macro
   (Important: Do not use the extended SuperMacro tab!)
2. Click "New".
3. Enter the exact macro name (all lowercase):
   autorest
4. Select the red question mark (?) as the macro icon.
5. Enter only the following command into the macro text box:
   /autorest
6. Drag the macro onto your action bar.

Note: Whenever your bags update or you change zones, the addon automatically 
updates the macro text in the background so SuperMacro displays the matching 
icon and remaining item count.


--------------------------------------------------------------------------------
3. SLASH COMMANDS
--------------------------------------------------------------------------------
/autorest   - Drinks and eats simultaneously (if Mana and/or HP are below 100%)
/autodrink  - Drinks only (if Mana is below 100%)
/autoeat    - Eats only (if HP is below 100%)


--------------------------------------------------------------------------------
4. PRIORITY LOGIC
--------------------------------------------------------------------------------
The addon automatically checks your current zone when triggered:

- Always first: Mage water / Mage food
- In Alterac Valley: AV biscuits (Alterac Manna Biscuit) / AV water
- In Warsong Gulch: WSG rations (Warsong Gulch Rations)
- In Arathi Basin: AB rations (Arathi Basin Rations)
- Everywhere else: Standard vendor water / food

Built-in buff detection and combo-item protection prevent wasting supplies or 
interrupting active regeneration when spamming the button.
