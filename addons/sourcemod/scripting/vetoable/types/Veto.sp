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

	bool Validate()
	{
		if (this.Participants.Length < this.NeededParticipants())
		{
			return false;
		}

		// A veto needs at least as many items as actions
		if (this.Items.Length < this.Actions.Length)
		{
			return false;
		}

		return true;
	}
}
