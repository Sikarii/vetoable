static GlobalForward OnVetoStarted;
static GlobalForward OnVetoAction;
static GlobalForward OnVetoEnded;

// =====[ PUBLIC ]=====

void OnAskPluginLoad2_Forwards()
{
    OnVetoStarted = new GlobalForward("Vetoable_OnVetoStarted", 
        ET_Ignore, 
        Param_Cell);

    OnVetoAction = new GlobalForward("Vetoable_OnVetoAction", 
        ET_Ignore, 
        Param_Cell, 
        Param_Cell, 
        Param_Cell, 
        Param_String, 
        Param_String);

    OnVetoEnded = new GlobalForward("Vetoable_OnVetoEnded", 
        ET_Ignore, 
        Param_Cell, 
        Param_Cell);
}

void Call_OnVetoStarted(int vetoId)
{
    Call_StartForward(OnVetoStarted);
    Call_PushCell(vetoId);
    Call_Finish();
}

void Call_OnVetoAction(int vetoId, int voter, VetoActionType type, char[] name, char[] value)
{
    Call_StartForward(OnVetoAction);
    Call_PushCell(vetoId);
    Call_PushCell(voter);
    Call_PushCell(type);
    Call_PushString(name);
    Call_PushString(value);
    Call_Finish();
}

void Call_OnVetoEnded(int vetoId, VetoEndReason reason)
{
    Call_StartForward(OnVetoEnded);
    Call_PushCell(vetoId);
    Call_PushCell(reason);
    Call_Finish();
}
