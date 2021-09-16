#include <vetoable>

static int activeVetoId;
static char panelHtml[8192];

public void Vetoable_OnVetoStarted(VetoableVeto veto)
{
	if (activeVetoId != 0)
	{
		return;
	}

	char name[128];
	veto.GetName(name, sizeof(name));

	int player1 = veto.GetParticipant(0);
	int player2 = veto.GetParticipant(1);

	Format(panelHtml, sizeof(panelHtml), "\
		<span class='fontSize-xl' color='#4B6DF5'>VETO</span>\
		<span class='fontSize-xl' color='#5E99D5'>ABLE</span>");

	Format(panelHtml, sizeof(panelHtml), "%s\
		<br>\
		<span class='fontSize-m'>Veto #%d (%s)</span>\
		<br><br>\
		<span class='fontSize-l'>%N</span>\
		<span class='fontSize-xl' color='#FFA500'> vs </span>\
		<span class='fontSize-l'>%N</span>\
		<br><br>",
		panelHtml,
		veto.Id,
		name,
		player1 != -1 ? player1 : 0,
		player2 != -1 ? player2 : 0);

	activeVetoId = veto.Id;
	ShowWinPanel(panelHtml);
}

public void Vetoable_OnVetoAction(VetoableVeto veto, int voter, VetoActionType type, const char[] name, const char[] value)
{
	if (veto.Id == activeVetoId)
	{
		PushNewResultItem(veto, voter, type, name);
		StrCat(panelHtml, sizeof(panelHtml), "<br>");

		ShowWinPanel(panelHtml);
	}
}

public void Vetoable_OnVetoEnded(VetoableVeto veto, VetoEndReason reason)
{
	activeVetoId = 0;
	CreateTimer(15.0, Timer_HidePanel);
}

public Action Timer_HidePanel(Handle timer)
{
	if (activeVetoId == 0)
	{
		ShowWinPanel("");	
	}
}

void ShowWinPanel(const char[] message)
{
	Event event = CreateEvent("cs_win_panel_round");
	if (event == null)
	{
		return;
	}

	event.SetString("funfact_token", message);
	event.Fire();
}

static int PushNewResultItem(VetoableVeto veto, int voter, VetoActionType type, const char[] name)
{
	if (type == VetoActionType_Ban)
	{
		return Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontSize-m'>%N</span>\
				<span color='#C80000'> banned </span>\
				<span class='fontSize-m'>%s</span>",
				panelHtml,
				voter,
				name);
	}

	if (type == VetoActionType_Pick)
	{
		if (voter == 0 && veto.RemainingItemCount == 0)
		{
			return Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontSize-m'>%s</span> is \
				the <span color='#C8C800'>decider</span>",
				panelHtml,
				name);
		}

		return Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontSize-m'>%N</span>\
				<span color='#00C800'> picked </span>\
				<span class='fontSize-m'>%s</span>",
				panelHtml,
				voter,
				name);
	}

	return -1;
}