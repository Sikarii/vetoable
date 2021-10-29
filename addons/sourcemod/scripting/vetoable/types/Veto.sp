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

    int NeededParticipants()
    {
        int maxVoterNum = 0;

        for (int i = 0; i < this.Actions.Length; i++)
        {
            VetoAction action;
            this.Actions.GetArray(i, action);

            if (action.VoterNum > maxVoterNum)
            {
                maxVoterNum = action.VoterNum;
            }
        }

        return maxVoterNum;
    }
}
