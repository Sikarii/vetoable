enum struct VetoAction
{
	int VoterNum;
	VetoActionType Type;

	bool Validate()
	{
		if (this.VoterNum < 0)
		{
			return false;
		}

		return true;
	}
}