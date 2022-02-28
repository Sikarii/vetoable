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
    if (veto.RemainingItems.Length == 1)
    {
        return VetoProceed(veto.Id, 0);
    }

    ShowVoterMenu(veto, voter, action.Type);
    return true;
}

// =====[ PRIVATE ]=====

static void ShowVoterMenu(Veto veto, int voter, VetoActionType type)
{
    Menu vetoMenu = new Menu(MenuHandler_Voting);

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
    if (action == MenuAction_Select || action == MenuAction_Cancel)
    {
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
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}
