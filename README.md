# Vetoable

A flexible SourceMod plugin for organizing vetos.

## Commands

- `sm_veto <preset> [participants...]` - Starts a veto with the specified preset and participants
- `sm_veto_list` - Lists all active vetos
- `sm_veto_cancel <id>` / `sm_veto_abort <id>` - Cancels an ongoing veto
- `sm_veto_presets_reload` - Reloads presets from the file

## Convars

- `vetoable_vote_timeout` - Voting time players have until a random action is chosen

## Installation

1. Download the latest release from [the releases](https://github.com/Sikarii/vetoable/releases)
2. Extract the zip file into `/csgo/` (root game directory) of your gameserver
3. _Optionally_ adjust `/csgo/cfg/sourcemod/vetoable-presets.cfg` to your liking
   - See below for examples of configuration

## Configuration

##### By default Vetoable loads presets from a KeyValues file (`/csgo/cfg/sourcemod/vetoable-presets.cfg`)

- The preset name will be used in the `sm_veto` command
- Presets can define as many items and actions as they want
- Action type must be either `ban`, `pick`, `decider` or `random`
- Actions with voter number as `0` are considered non-interactable and will be chosen by random

Each preset in the file follows the format:

```
"Preset name"
{
    "items"
    {
        "item1"    "Item 1"
        "item2"    "Item 2"
        "item3"    "Item 3"
        "item4"    "Item 4"
    }
    "actions"
    {
        "pick"    "1"
        "ban"     "2"
        "random"  "0"
        "decider" "0"
    }
}
```

## Extending Vetoable

##### Vetoable exposes a [Plugin API](/addons/sourcemod/scripting/include/vetoable.inc) for interacting with vetos

Extending can be as simple as announcing results (see [announcer-chat](/addons/sourcemod/scripting/vetoable-announcer-chat.sp) and [announcer-winpanel](/addons/sourcemod/scripting/vetoable-announcer-chat.sp) to providing alternative ways of creating vetos.

Example plugin:

```sourcepawn
#include <vetoable>

public void OnPluginStart()
{
    RegConsoleCmd("sm_randomveto", Command_VetoRandom, "Starts a veto with random actions");
}

public Action Command_VetoRandom(int client, int args)
{
    VetoableVeto veto = VetoableVeto("Random 3");

    // Add three random picks
    // Voter 0 is non-interactable and will be random
    veto.AddAction(VetoActionType_Pick, 0);
    veto.AddAction(VetoActionType_Pick, 0);
    veto.AddAction(VetoActionType_Pick, 0);

    // Add 9 random items
    veto.AddItem("Item 1");
    veto.AddItem("Item 2");
    veto.AddItem("Item 3");
    veto.AddItem("Item 4");
    veto.AddItem("Item 5");
    veto.AddItem("Item 6");
    veto.AddItem("Item 7");
    veto.AddItem("Item 8");
    veto.AddItem("Item 9");

    veto.Start();
    return Plugin_Handled;
}
```
