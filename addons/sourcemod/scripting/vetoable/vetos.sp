enum struct Veto
{
    int Id;
    int Cursor;
    bool IsStarted;

    char Name[128];

    ArrayList Items;
    ArrayList Actions;
    ArrayList Participants;
    ArrayList RemainingItems;
}

enum struct VetoAction
{
    int VoterNum;
    VetoActionType Type;
}

enum struct VetoItem
{
    char Name[128];
    char Value[128];
}

enum struct VetoPreset
{
    char Name[128];

    ArrayList Items;
    ArrayList Actions;
}

static int UniqueId = 1;
static StringMap VetoMap = null;

// =====[ LISTENERS ]=====

void OnPluginStart_Vetos()
{
    VetoMap = new StringMap();
}

// =====[ PUBLIC ]=====

int VetoCreate(char name[sizeof(Veto::Name)])
{
    Veto veto;
    veto.Id = UniqueId++;

    veto.Name = name;

    veto.Items = new ArrayList(sizeof(VetoItem));
    veto.Actions = new ArrayList(sizeof(VetoAction));
    veto.Participants = new ArrayList();

    VetoSetById(veto.Id, veto);
    return veto.Id;
}

VetoStartResult VetoStart(int vetoId)
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists || veto.IsStarted)
    {
        return VetoStartResult_GenericError;
    }

    // A veto needs at least as many items as actions
    if (veto.Items.Length < veto.Actions.Length)
    {
        return VetoStartResult_InsufficientItems;
    }

    int neededParticipants = GetVetoNeededParticipants(vetoId);
    if (veto.Participants.Length < neededParticipants)
    {
        return VetoStartResult_InsufficientParticipants;
    }

    veto.IsStarted = true;
    veto.RemainingItems = veto.Items.Clone();

    VetoSetById(vetoId, veto);
    Call_OnVetoStarted(vetoId);

    AskForInput(veto);
    return VetoStartResult_Ok;
}

bool VetoEnd(int vetoId, VetoEndReason reason)
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists)
    {
        return false;
    }

    VetoRemove(veto);

    // Dont dispatch finished if it was never started
    if (reason == VetoEndReason_Finished && !veto.IsStarted)
    {
        return true;
    }

    Call_OnVetoEnded(vetoId, reason);
    return true;
}

bool VetoProceed(int vetoId, int chosenItemIndex)
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists)
    {
        return false;
    }

    VetoAction action;
    veto.Actions.GetArray(veto.Cursor, action);

    VetoItem item;
    veto.RemainingItems.GetArray(chosenItemIndex, item);

    veto.RemainingItems.Erase(chosenItemIndex);

    // Save this now, so plugins can retrieve up-to-date information in the global forward.
    VetoSetById(vetoId, veto);

    int voter = action.VoterNum == 0
        ? 0
        : veto.Participants.Get(action.VoterNum - 1);

    Call_OnVetoAction(vetoId, voter, action.Type, item.Name, item.Value);

    bool needMore = veto.Cursor < veto.Actions.Length - 1;
    if (!needMore)
    {
        VetoEnd(vetoId, VetoEndReason_Finished);
        return true;
    }

    veto.Cursor++;
    VetoSetById(vetoId, veto);

    return AskForInput(veto);
}

ArrayList GetVetos()
{
    StringMapSnapshot keys = VetoMap.Snapshot();
    ArrayList vetos = new ArrayList(sizeof(Veto));

    for (int i = 0; i < keys.Length; i++)
    {
        char key[16];
        keys.GetKey(i, key, sizeof(key));

        Veto veto;
        VetoMap.GetArray(key, veto, sizeof(veto));

        vetos.PushArray(veto);
    }

    delete keys;
    return vetos;
}

bool GetVetoById(int id, Veto veto)
{
    char key[16];
    IntToString(id, key, sizeof(key));
    return VetoMap.GetArray(key, veto, sizeof(veto));
}

int GetVetoNeededParticipants(int vetoId)
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists)
    {
        return -1;
    }

    int maxVoterNum = 0;

    for (int i = 0; i < veto.Actions.Length; i++)
    {
        VetoAction action;
        veto.Actions.GetArray(i, action);

        if (action.VoterNum > maxVoterNum)
        {
            maxVoterNum = action.VoterNum;
        }
    }

    return maxVoterNum;
}

int GetParticipantExistingVeto(int client)
{
    ArrayList vetos = GetVetos();

    for (int i = 0; i < vetos.Length; i++)
    {
        Veto veto;
        vetos.GetArray(i, veto);

        if (veto.Participants.FindValue(client) != -1)
        {
            delete vetos;
            return veto.Id;
        }
    }

    delete vetos;
    return -1;
}

bool VetoAddItem(int vetoId, char name[sizeof(VetoItem::Name)], char value[sizeof(VetoItem::Value)])
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists)
    {
        return false;
    }

    if (StrEqual(name, ""))
    {
        return false;
    }

    VetoItem item;
    item.Name = name;
    item.Value = value;

    // Fill value with name if not set
    if (StrEqual(item.Value, ""))
    {
        item.Value = item.Name;
    }

    veto.Items.PushArray(item);

    // Add to remaining if started already
    if (veto.IsStarted)
    {
        veto.RemainingItems.PushArray(item);
    }

    return VetoSetById(vetoId, veto);
}

bool VetoAddAction(int vetoId, VetoActionType type, int voterNum)
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists || veto.IsStarted)
    {
        return false;
    }

    if (voterNum < 0)
    {
        return false;
    }

    VetoAction action;
    action.Type = type;
    action.VoterNum = voterNum;

    veto.Actions.PushArray(action);
    return VetoSetById(vetoId, veto);
}

bool VetoAddParticipant(int vetoId, int client)
{
    Veto veto;
    bool exists = GetVetoById(vetoId, veto);

    if (!exists || veto.IsStarted)
    {
        return false;
    }

    #if !defined DEBUG
    if (client <= 0 || client > MaxClients)
    {
        return false;
    }

    if (!IsClientConnected(client))
    {
        return false;
    }

    // Already in a veto
    if (GetParticipantExistingVeto(client) != -1)
    {
        return false;
    }
    #endif

    veto.Participants.Push(client);
    return VetoSetById(vetoId, veto);
}

// =====[ PRIVATE ]=====

static bool VetoSetById(int id, Veto veto)
{
    char szId[16];
    IntToString(id, szId, sizeof(szId));
    return VetoMap.SetArray(szId, veto, sizeof(veto));
}

static bool VetoRemove(Veto veto)
{
    delete veto.Items;
    delete veto.Actions;
    delete veto.Participants;
    delete veto.RemainingItems;

    char szId[16];
    IntToString(veto.Id, szId, sizeof(szId));

    return VetoMap.Remove(szId);
}
