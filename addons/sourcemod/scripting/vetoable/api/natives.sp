// =====[ PUBLIC ]=====

void OnAskPluginLoad2_Natives()
{
	// Methodmap
	CreateNative("VetoableVeto.VetoableVeto", Native_CreateVeto);
	CreateNative("VetoableVeto.Start", Native_StartVeto);
	CreateNative("VetoableVeto.Cancel", Native_CancelVeto);
	CreateNative("VetoableVeto.GetName", Native_GetVetoName);
	CreateNative("VetoableVeto.IsValid.get", Native_IsVetoValid);
	CreateNative("VetoableVeto.IsStarted.get", Native_IsVetoStarted);
	CreateNative("VetoableVeto.AddItem", Native_AddItemToVeto);
	CreateNative("VetoableVeto.AddAction", Native_AddActionToVeto);
	CreateNative("VetoableVeto.AddParticipant", Native_AddParticipantToVeto);
	CreateNative("VetoableVeto.ItemCount.get", Native_GetVetoItemCount);
	CreateNative("VetoableVeto.ActionCount.get", Native_GetVetoActionCount);
	CreateNative("VetoableVeto.ParticipantCount.get", Native_GetVetoParticipantCount);
	CreateNative("VetoableVeto.RemainingItemCount.get", Native_GetVetoRemainingItemCount);
	CreateNative("VetoableVeto.NeededParticipants.get", Native_GetVetoNeededParticipants);
	CreateNative("VetoableVeto.GetItemName", Native_GetVetoItemName);
	CreateNative("VetoableVeto.GetItemValue", Native_GetVetoItemValue);
	CreateNative("VetoableVeto.GetActionType", Native_GetVetoActionType);
	CreateNative("VetoableVeto.GetActionVoterNum", Native_GetVetoActionVoterNum);
	CreateNative("VetoableVeto.GetParticipant", Native_GetVetoParticipant);
	CreateNative("VetoableVeto.GetRemainingItemName", Native_GetVetoRemainingItemName);
	CreateNative("VetoableVeto.GetRemainingItemValue", Native_GetVetoRemainingItemValue);
	// End methodmap

	CreateNative("Vetoable_PrintToChat", Native_PrintToChat);
	CreateNative("Vetoable_PrintToChatAll", Native_PrintToChatAll);
	CreateNative("Vetoable_ReplyToCommand", Native_ReplyToCommand);
	CreateNative("Vetoable_IsClientInVeto", Native_IsClientInVeto);
}

public int Native_CreateVeto(Handle plugin, int numParams)
{
	char name[sizeof(Veto::Name)];
	GetNativeString(1, name, sizeof(name));

	int createdVetoId = VetoCreate(name);
	return createdVetoId;
}

public int Native_StartVeto(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	bool disposeOnFailure = GetNativeCell(2);

	bool success = VetoStart(vetoId);
	if (!success && disposeOnFailure)
	{
		// Global end forward is not called
		VetoEnd(vetoId, VetoEndReason_Finished);
	}

	return success;
}

public int Native_CancelVeto(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	return VetoEnd(vetoId, VetoEndReason_Canceled);
}

public int Native_GetVetoName(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return false;
	}

	int maxlength = GetNativeCell(3);
	SetNativeString(2, veto.Name, maxlength);

	return true;
}

public int Native_IsVetoValid(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;
	return GetVetoById(vetoId, veto);
}

public int Native_IsVetoStarted(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return false;
	}

	return veto.IsStarted;
}

public int Native_AddItemToVeto(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	char name[sizeof(VetoItem::Name)];
	GetNativeString(2, name, sizeof(name));

	char value[sizeof(VetoItem::Value)];
	GetNativeString(3, value, sizeof(value));

	return VetoAddItem(vetoId, name, value);
}

public int Native_AddActionToVeto(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	VetoActionType type = GetNativeCell(2);
	int voterNum = GetNativeCell(3);

	return VetoAddAction(vetoId, type, voterNum);
}

public int Native_AddParticipantToVeto(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int client = GetNativeCell(2);

	return VetoAddParticipant(vetoId, client);
}

public int Native_GetVetoItemCount(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	return veto.Items.Length;
}

public int Native_GetVetoActionCount(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	return veto.Actions.Length;
}

public int Native_GetVetoParticipantCount(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	return veto.Participants.Length;
}

public int Native_GetVetoRemainingItemCount(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	// Remaining items are not cloned until started
	if (!veto.IsStarted)
	{
		return veto.Items.Length;
	}

	return veto.RemainingItems.Length;
}

public int Native_GetVetoNeededParticipants(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	return veto.NeededParticipants();
}

public int Native_GetVetoItemName(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int itemIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return false;
	}

	if (itemIndex < 0 || itemIndex >= veto.Items.Length)
	{
		return false;
	}

	VetoItem item;
	veto.Items.GetArray(itemIndex, item);

	int maxlength = GetNativeCell(4);
	SetNativeString(3, item.Name, maxlength);

	return true;
}

public int Native_GetVetoItemValue(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int itemIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return false;
	}

	if (itemIndex < 0 || itemIndex >= veto.Items.Length)
	{
		return false;
	}

	VetoItem item;
	veto.Items.GetArray(itemIndex, item);

	int maxlength = GetNativeCell(4);
	SetNativeString(3, item.Value, maxlength);

	return true;
}

public any Native_GetVetoActionType(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int actionIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	if (actionIndex < 0 || actionIndex >= veto.Actions.Length)
	{
		return -1;
	}

	VetoAction action;
	veto.Actions.GetArray(actionIndex, action);

	return action.Type;
}

public int Native_GetVetoActionVoterNum(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int actionIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	if (actionIndex < 0 || actionIndex >= veto.Actions.Length)
	{
		return -1;
	}

	VetoAction action;
	veto.Actions.GetArray(actionIndex, action);

	return action.VoterNum;
}

public int Native_GetVetoParticipant(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int participantIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return -1;
	}

	if (participantIndex < 0 || participantIndex >= veto.Participants.Length)
	{
		return -1;
	}

	int participant = veto.Participants.Get(participantIndex);
	return participant;
}

public int Native_GetVetoRemainingItemName(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int itemIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return false;
	}

	// Remaining items only exists if the veto is started
	ArrayList items = veto.IsStarted ? veto.RemainingItems : veto.Items;

	if (itemIndex < 0 || itemIndex >= items.Length)
	{
		return false;
	}

	VetoItem item;
	items.GetArray(itemIndex, item);

	int maxlength = GetNativeCell(4);
	SetNativeString(3, item.Name, maxlength);

	return true;
}

public int Native_GetVetoRemainingItemValue(Handle plugin, int numParams)
{
	int vetoId = GetNativeCell(1);
	int itemIndex = GetNativeCell(2);

	Veto veto;

	bool exists = GetVetoById(vetoId, veto);
	if (!exists)
	{
		return false;
	}

	// Remaining items only exists if the veto is started
	ArrayList items = veto.IsStarted ? veto.RemainingItems : veto.Items;

	if (itemIndex < 0 || itemIndex >= items.Length)
	{
		return false;
	}

	VetoItem item;
	items.GetArray(itemIndex, item);

	int maxlength = GetNativeCell(4);
	SetNativeString(3, item.Value, maxlength);

	return true;
}

public int Native_PrintToChat(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	SetGlobalTransTarget(client);

	char buffer[1024];
	FormatNativeString(0, 2, 3, sizeof(buffer), _, buffer);

	PrintToChat(client, "%s %s", VETOABLE_CHAT_PREFIX, buffer);
}

public int Native_PrintToChatAll(Handle plugin, int numParams)
{
	char buffer[1024];
	FormatNativeString(0, 1, 2, sizeof(buffer), _, buffer);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			Vetoable_PrintToChat(i, "%s", buffer);
		}
	}
}

public int Native_ReplyToCommand(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	ReplySource source = GetCmdReplySource();

	SetGlobalTransTarget(client);

	char buffer[1024];
	FormatNativeString(0, 2, 3, sizeof(buffer), _, buffer);

	if (source == SM_REPLY_TO_CHAT)
	{
		Vetoable_PrintToChat(client, "%s", buffer);
	}
	else
	{
		ReplyToCommand(client, "%s %s", VETOABLE_RAW_PREFIX, buffer);
	}
}

public int Native_IsClientInVeto(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int vetoId = GetParticipantExistingVeto(client);

	SetNativeCellRef(2, vetoId);
	return vetoId != -1;
}
