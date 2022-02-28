static StringMap PresetMap = null;

void OnPluginStart_Presets()
{
    PresetMap = new StringMap();
}

bool GetPresetByName(char[] name, VetoPreset foundPreset)
{
    return PresetMap.GetArray(name, foundPreset, sizeof(foundPreset));
}

bool TryLoadPresetsFromKeyValues(char filePath[PLATFORM_MAX_PATH])
{
    PresetMap.Clear();

    KeyValues kv = new KeyValues("Vetoable-Presets");
    if (kv == null || !kv.ImportFromFile(filePath))
    {
        delete kv;
        return false;
    }

    while (kv.GotoNextKey(false) || (kv.GotoFirstSubKey(false) && kv.NodesInStack() <= 1))
    {
        VetoPreset preset;
        kv.GetSectionName(preset.Name, sizeof(preset.Name));

        preset.Items = ParseItems(kv);

        kv.Rewind();
        kv.JumpToKey(preset.Name);

        preset.Actions = ParseActions(kv);

        kv.Rewind();
        kv.JumpToKey(preset.Name);

        PresetMap.SetArray(preset.Name, preset, sizeof(preset));
    }

    delete kv;
    return true;
}

static ArrayList ParseItems(KeyValues kv)
{
    ArrayList items = new ArrayList(sizeof(VetoItem));

    if (!kv.JumpToKey("items"))
    {
        return items;
    }

    while (kv.GotoFirstSubKey(false) || kv.GotoNextKey(false))
    {
        VetoItem item;
        kv.GetSectionName(item.Value, sizeof(item.Value));
        kv.GetString(NULL_STRING, item.Name, sizeof(item.Name));

        items.PushArray(item);
    }

    return items;
}

static ArrayList ParseActions(KeyValues kv)
{
    ArrayList actions = new ArrayList(sizeof(VetoAction));

    if (!kv.JumpToKey("actions"))
    {
        return actions;
    }

    while (kv.GotoFirstSubKey(false) || kv.GotoNextKey(false))
    {
        VetoAction action;

        char typeStr[32];
        kv.GetSectionName(typeStr, sizeof(typeStr));

        char voterStr[32];
        kv.GetString(NULL_STRING, voterStr, sizeof(voterStr));

        action.Type = StringToVetoType(typeStr);
        action.VoterNum = StringToInt(voterStr);

        actions.PushArray(action);
    }

    return actions;
}

static VetoActionType StringToVetoType(char[] input)
{
    for (VetoActionType type; type < VetoActionType_COUNT; type++)
    {
        if (StrEqual(VetoActionPhrases[type], input))
        {
            return type;
        }
    }

    return VetoActionType_Pick;
}
