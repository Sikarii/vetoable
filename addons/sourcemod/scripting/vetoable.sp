#include <vetoable>

#include "vetoable/types/VetoItem.sp"
#include "vetoable/types/VetoAction.sp"
#include "vetoable/types/VetoPreset.sp"
#include "vetoable/types/Veto.sp"

#include "vetoable/convars.sp"
#include "vetoable/commands.sp"

#include "vetoable/vetos.sp"
#include "vetoable/voting.sp"
#include "vetoable/presets.sp"

#include "vetoable/api/natives.sp"
#include "vetoable/api/forwards.sp"

public Plugin myinfo =
{
    name = "Vetoable",
    author = "Sikari",
    description = "",
    version = VETOABLE_VERSION,
    url = "https://github.com/Sikarii/vetoable"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("Vetoable");

    OnAskPluginLoad2_Natives();
    OnAskPluginLoad2_Forwards();
}

public void OnPluginStart()
{
    OnPluginStart_Vetos();
    OnPluginStart_Presets();
    OnPluginStart_Convars();
    OnPluginStart_Commands();

    AutoExecConfig(true, "vetoable");
    LoadTranslations("common.phrases");

    TryLoadPresetsFromKeyValues("cfg/sourcemod/vetoable-presets.cfg");
}

public void OnClientDisconnect(int client)
{
    int existingVetoId = GetParticipantExistingVeto(client);
    if (existingVetoId != -1)
    {
        VetoEnd(existingVetoId, VetoEndReason_Abandoned);
    }
}
