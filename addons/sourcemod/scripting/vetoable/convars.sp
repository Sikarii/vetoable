ConVar gCV_VoteTimeout = null;

void OnPluginStart_Convars()
{
	gCV_VoteTimeout = CreateConVar("vetoable_vote_timeout", "60", "Voting time in seconds", _, true, 0.0);
}
