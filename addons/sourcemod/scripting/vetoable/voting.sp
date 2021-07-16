static StringMap VetoMenus = null;

// =====[ LISTENERS ]=====

void OnPluginStart_Voting()
{
	VetoMenus = new StringMap();
}

void Vetoable_OnVetoEnded_Voting(int vetoId)
{
	char szId[16];
	IntToString(vetoId, szId, sizeof(szId));

	Menu vetoMenu = null;
	VetoMenus.GetValue(szId, vetoMenu);

	if (vetoMenu != null)
	{
		delete vetoMenu;
		VetoMenus.Remove(szId);	
	}
}

// =====[ PUBLIC ]=====

bool AskForInput(Veto veto)
{
	VetoAction action;
	veto.Actions.GetArray(veto.Cursor, action);

	if (action.VoterNum == 0)
	{
		int rndIdx = GetRandomInt(0, veto.RemainingItems.Length - 1);
		return VetoProceed(veto.Id, rndIdx);
	}

	int voter = veto.Participants.Get(action.VoterNum - 1);

	ShowVoterMenu(veto, voter, action.Type);
	return true;
}

// =====[ PRIVATE ]=====

static Menu GetOrCreateVetoMenu(Veto veto)
{
	char szId[16];
	IntToString(veto.Id, szId, sizeof(szId));

	Menu vetoMenu = null;
	VetoMenus.GetValue(szId, vetoMenu);

	if (vetoMenu == null)
	{
		vetoMenu = new Menu(MenuHandler_Voting);
		VetoMenus.SetValue(szId, vetoMenu);
	}

	return vetoMenu;
}

static void ShowVoterMenu(Veto veto, int voter, VetoActionType type)
{
	Menu vetoMenu = GetOrCreateVetoMenu(veto);

	vetoMenu.RemoveAllItems();
	vetoMenu.SetTitle("[Veto] It's your time to %s!", VetoActionPhrases[type]);

	vetoMenu.ExitButton = false;
	vetoMenu.ExitBackButton = false;
	vetoMenu.Pagination = veto.RemainingItems.Length <= 8 ? 0 : 10;

	char szId[16];
	IntToString(veto.Id, szId, sizeof(szId));

	// Store veto id in item 0 for context
	vetoMenu.AddItem(szId, "", ITEMDRAW_IGNORE);

	for (int i = 0; i < veto.RemainingItems.Length; i++)
	{
		VetoItem item;
		veto.RemainingItems.GetArray(i, item);

		vetoMenu.AddItem(item.Value, item.Name);
	}

	vetoMenu.Display(voter, gCV_VoteTimeout.IntValue);
}

public int MenuHandler_Voting(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		return;
	}

	char szId[16];
	menu.GetItem(0, szId, sizeof(szId));

	int vetoId = StringToInt(szId);

	Veto veto;
	bool exists = GetVetoById(vetoId, veto);

	if (!exists)
	{
		return;
	}

	VetoAction vetoAction;
	veto.Actions.GetArray(veto.Cursor, vetoAction);

	// Random selection if user does not interact
	int itemIndex = action == MenuAction_Select
		? param2 - 1
		: GetRandomInt(0, veto.RemainingItems.Length - 1);

	VetoProceed(vetoId, itemIndex);
}