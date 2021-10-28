#include <vetoable>

public void Vetoable_OnVetoStarted(VetoableVeto veto)
{
	char name[128];
	veto.GetName(name, sizeof(name));

	Vetoable_PrintToChatAll("\x03#%d\x01 | Started (%s)", veto.Id, name);
}

public void Vetoable_OnVetoAction(VetoableVeto veto, int voter, VetoActionType type, const char[] name, const char[] value)
{
	char buf[128];
	FormatAction(veto, voter, type, name, buf, sizeof(buf));

	Vetoable_PrintToChatAll("\x03#%d\x01 | %s", veto.Id, buf);
}

public void Vetoable_OnVetoEnded(VetoableVeto veto, VetoEndReason reason)
{
	Vetoable_PrintToChatAll("\x03#%d\x01 | Ended with reason '%s'", veto.Id, VetoEndReasonPhrases[reason]);
}

static int FormatAction(VetoableVeto veto, int voter, VetoActionType type, const char[] name, char[] buffer, int maxlength)
{
	if (type == VetoActionType_Ban)
	{
        return Format(buffer, maxlength, "%N \x07banned\x01 %s", voter, name);
	}

	if (type == VetoActionType_Pick)
	{
		if (voter == 0 && veto.RemainingItemCount == 0)
		{
			return Format(buffer, maxlength, "%s is the \x09decider\x01", name);
		}
		else
		{
            return Format(buffer, maxlength, "%N \x04picked\x01 %s", voter, name);   
		}
	}

	return -1;
}
