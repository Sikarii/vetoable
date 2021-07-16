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
		<span class='fontsize-m'>Veto #%d (%s)</span>\
		<br><br>\
		<span class='fontSize-l'>%N</span>\
		<span class='fontSize-xl' color='#FFA500'> vs </span>\
		<span class='fontSize-l'>%N</span>\
		<br><br><br>",
	panelHtml,
	veto.Id,
	name,
	player1,
	player2);

	activeVetoId = veto.Id;
	ShowWinPanel(panelHtml);
}

public void Vetoable_OnVetoAction(VetoableVeto veto, int voter, VetoActionType type, const char[] name, const char[] value)
{
	if (veto.Id == activeVetoId)
	{
		PushNewResultItem(voter, type, name);
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

static void PushNewResultItem(int voter, VetoActionType type, const char[] name)
{
	switch (type)
	{
		case VetoActionType_Ban:
		{
			Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontsize-l'>%N</span>\
				<span color='#C80000'> banned </span>\
				<span class='fontsize-m'>%s</span>",
			panelHtml,
			voter,
			name);
		}
		case VetoActionType_Pick:
		{
			Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontsize-l'>%N</span>\
				<span color='#00C800'> picked </span>\
				<span class='fontsize-m'>%s</span>",
			panelHtml,
			voter,
			name);
		}
		case VetoActionType_Random:
		{
			Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontsize-m'>%s</span> was \
				<span color='#C8C800'>randomly selected</span>",
			panelHtml,
			name);
		}
		case VetoActionType_Decider:
		{
			Format(panelHtml, sizeof(panelHtml), "%s\
				<span class='fontsize-m'>%s</span> is \
				the <span color='#C8C800'>decider</span>",
			panelHtml,
			name);
		}
	}

	StrCat(panelHtml, sizeof(panelHtml), "<br>");
}