void OnPluginStart_Commands()
{
    RegAdminCmd("sm_veto", Command_Veto, ADMFLAG_RCON, "Starts a veto", "vetoable");

    RegAdminCmd("sm_veto_list", Command_VetoList, ADMFLAG_RCON, "Lists all active vetos", "vetoable");
    RegAdminCmd("sm_veto_abort", Command_VetoCancel, ADMFLAG_RCON, "Cancels a veto by id", "vetoable");
    RegAdminCmd("sm_veto_cancel", Command_VetoCancel, ADMFLAG_RCON, "Cancels a veto by id", "vetoable");

    RegAdminCmd("sm_veto_presets_reload", Command_VetoPresetsReload, ADMFLAG_RCON, "Reloads veto presets", "vetoable");
}

public Action Command_Veto(int client, int args)
{
    char presetName[128];
    GetCmdArg(1, presetName, sizeof(presetName));

    VetoPreset preset;
    bool exists = GetPresetByName(presetName, preset);

    if (!exists)
    {
        Vetoable_ReplyToCommand(client, "No preset with name '%s' exists", presetName);
        return Plugin_Handled;
    }

    VetoableVeto veto = VetoableVeto(preset.Name);

    for (int i = 0; i < preset.Items.Length; i++)
    {
        VetoItem item;
        preset.Items.GetArray(i, item);

        veto.AddItem(item.Name, item.Value);
    }

    for (int i = 0; i < preset.Actions.Length; i++)
    {
        VetoAction action;
        preset.Actions.GetArray(i, action);

        veto.AddAction(action.Type, action.VoterNum);
    }

    int needed = veto.NeededParticipants;

    int added = Vetoable_AddParticipantsFromArgs(veto, client, needed, 2);
    if (added < needed)
    {
        Vetoable_ReplyToCommand(client, "%d participants are needed", needed);
    }

    bool started = veto.Start();
    if (!started)
    {
        Vetoable_ReplyToCommand(client, "Failed to start veto");
        return Plugin_Handled;
    }

    Vetoable_ReplyToCommand(client, "Started veto %d", veto.Id);
    return Plugin_Handled;
}

public Action Command_VetoList(int client, int args)
{
    ArrayList vetos = GetVetos();

    Vetoable_ReplyToCommand(client, "Available vetos (%d):", vetos.Length);

    for (int i = 0; i < vetos.Length; i++)
    {
        Veto veto;
        vetos.GetArray(i, veto);

        Vetoable_ReplyToCommand(client, "[#%d] %s - [Started: %s]", 
            veto.Id, 
            veto.Name, 
            veto.IsStarted ? "Yes" : "No");
    }

    delete vetos;
    return Plugin_Handled;
}

public Action Command_VetoCancel(int client, int args)
{
    char cmdName[64];
    GetCmdArg(0, cmdName, sizeof(cmdName));

    if (args <= 0)
    {
        Vetoable_ReplyToCommand(client, "Usage: %s <id>", cmdName);
        Vetoable_ReplyToCommand(client, "Example: %s 420", cmdName);
        return Plugin_Handled;
    }

    char szId[32];
    GetCmdArg(1, szId, sizeof(szId));

    int id = StringToInt(szId);

    Veto veto;
    bool exists = GetVetoById(id, veto);

    if (!exists)
    {
        Vetoable_ReplyToCommand(client, "No veto with id %s exists", szId);
        return Plugin_Handled;
    }

    VetoEnd(veto.Id, VetoEndReason_Canceled);

    Vetoable_ReplyToCommand(client, "Veto canceled");
    return Plugin_Handled;
}

public Action Command_VetoPresetsReload(int client, int args)
{
    bool result = TryLoadPresetsFromKeyValues("cfg/sourcemod/vetoable-presets.cfg");

    Vetoable_ReplyToCommand(client, "%s loading presets", result ? "Success" : "Failure");
    return Plugin_Handled;
}
