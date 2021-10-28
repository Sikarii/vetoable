#if defined _Vetoable_included_
#endinput
#endif
#define _Vetoable_included_

// =====[ ENUMS ]=====

enum VetoActionType
{
    VetoActionType_Pick = 0,
    VetoActionType_Ban,
    VetoActionType_COUNT,
};

enum VetoEndReason
{
    VetoEndReason_Canceled = 0,
    VetoEndReason_Finished,
    VetoEndReason_Abandoned,
    VetoEndReason_COUNT,
};

// =====[ CONSTANTS ]=====

#define VETOABLE_RAW_PREFIX "[VETOABLE]"
#define VETOABLE_CHAT_PREFIX "[\x0CVETO\x0BABLE\x01]"

stock char VetoActionPhrases[VetoActionType_COUNT][] = 
{
    "pick",
    "ban",
};

stock char VetoEndReasonPhrases[VetoEndReason_COUNT][] = 
{
    "canceled",
    "finished",
    "abandoned",
};

// =====[ METHODMAP ]=====

methodmap VetoableVeto
{
    /**
     * Creates a veto.
     *
     * @param name          Name of the veto.
     * @return              The VetoableVeto instance.
     */
    public native VetoableVeto(char[] name);

    /**
     * Constructs a VetoableVeto from a veto id.
     *
     * @param id            The veto id.
     * @return              VetoableVeto instance.
     */
    public static VetoableVeto FromId(int id)
    {
        return view_as<VetoableVeto>(id);
    }

    /**
     * Gets id of the veto.
     *
     * @return              Id of the veto.
     */
    property int Id
    {
        public get()
        {
            return view_as<int>(this);
        }
    }

    /**
     * Checks the veto for validity.
     *
     * @return              Whether the veto is valid.
     */
    property bool IsValid
    {
        public native get();
    }

    /**
     * Checks if the veto has been started.
     *
     * @return              Whether the veto is started.
     */
    property bool IsStarted
    {
        public native get();
    }

    /**
     * Gets count of items in the veto.
     *
     * @return              Count of items in the veto or -1 on failure.
     */
    property int ItemCount
    {
        public native get();
    }

    /**
     * Gets count of actions in the veto.
     *
     * @return              Count of actions in the veto or -1 on failure.
     */
    property int ActionCount
    {
        public native get();
    }

    /**
     * Gets count of participants in the veto.
     *
     * @return              Count of participants in the veto or -1 on failure.
     */
    property int ParticipantCount
    {
        public native get();
    }

    /**
     * Gets the count of participants the veto needs.
     *
     * @return              Count of needed participants.
     */
    property int NeededParticipants
    {
        public native get();
    }

    /**
     * Gets count of remaining items in the veto.
     *
     * @return              Count of remaining items in the veto or -1 on failure.
     */
    property int RemainingItemCount
    {
        public native get();
    }

    /**
     * Adds an item to the veto.
     *
     * @param name          Name of the item to add.
     * @param value         Value of the item to add.
     * @return              Whether the item was successfully added.
     */
    public native bool AddItem(const char[] name, const char[] value = "");

    /**
     * Adds an action to the veto.
     *
     * @param type          Type of the action to add.
     * @param voterNum      Voter number of the action to add.
     * @return              Whether the action was successfully added.
     */
    public native bool AddAction(VetoActionType type, int voterNum);

    /**
     * Adds a participant to the veto.
     *
     * @param client        Client index of participant to add.
     * @return              Whether the participant was successfully added.
     */
    public native bool AddParticipant(int client);

    /**
     * Gets the veto's name.
     *
     * @param buffer        Output buffer.
     * @param maxlength     Maximum length of output.
     * @return              Whether the name was successfully fetched.
     */
    public native bool GetName(char[] buffer, int maxlength);

    /**
     * Gets a participant of the veto.
     *
     * @param index         The index of the participant.
     * @return              Client index of the participant or -1 on failure.
     */
    public native int GetParticipant(int index);

    /**
     * Gets the voter number of a veto action.
     *
     * @param index         The index of the action.
     * @return              Voter number of the veto action or -1 on failure.
     */
    public native int GetActionVoterNum(int index);

    /**
     * Gets the type of a veto action.
     *
     * @param index         The index of the action.
     * @return              VetoActionType of the veto action.
     */
    public native VetoActionType GetActionType(int index);

    /**
     * Gets the name of a veto item.
     *
     * @param index         The index of the item.
     * @param buffer        Output buffer.
     * @param maxlength     Maximum length of output.
     * @return              Whether an item was fetched successfully.
     */
    public native bool GetItemName(int index, char[] buffer, int maxlength);

    /**
     * Gets the value of a veto item.
     *
     * @param index         The index of the item.
     * @param buffer        Output buffer.
     * @param maxlength     Maximum length of output.
     * @return              Whether an item was fetched successfully.
     */
    public native bool GetItemValue(int index, char[] buffer, int maxlength);

    /**
     * Gets the name of a remaining veto item.
     *
     * @param index         The index of the item.
     * @param buffer        Output buffer.
     * @param maxlength     Maximum length of output.
     * @return              Whether an item was fetched successfully.
     */
    public native bool GetRemainingItemName(int index, char[] buffer, int maxlength);

    /**
     * Gets the value of a remaining veto item.
     *
     * @param index         The index of the item.
     * @param buffer        Output buffer.
     * @param maxlength     Maximum length of output.
     * @return              Whether an item was fetched successfully.
     */
    public native bool GetRemainingItemValue(int index, char[] buffer, int maxlength);

    /**
     * Starts the veto.
     *
     * @param autoDispose   Whether to remove veto on failure.
     * @return              Whether the veto was started successfully.
     */
    public native bool Start(bool autoDispose = true);

    /**
     * Cancels the veto.
     *
     * @return              Whether the veto was canceled successfully.
     */
    public native bool Cancel();
};

// =====[ NATIVES ]=====

/**
 * Prints to the client's chat using Vetoable's prefix.
 *
 * @param client            Client index to print to.
 * @param format            Formatting rules.
 * @param ...               Variable number of format parameters.
 * @noreturn
 */
native void Vetoable_PrintToChat(int client, const char[] format, any...);

/**
 * Prints to all clients chat using Vetoable's prefix.
 *
 * @param format            Formatting rules.
 * @param ...               Variable number of format parameters.
 * @noreturn
 */
native void Vetoable_PrintToChatAll(const char[] format, any...);

/**
 * Prints to the client's chat or console using Vetoable's prefix.
 *
 * @param client            Client index to print to.
 * @param format            Formatting rules.
 * @param ...               Variable number of format parameters.
 * @noreturn
 */
native void Vetoable_ReplyToCommand(int client, const char[] format, any...);

/**
 * Returns whether the specified client is in a veto.
 * Optionally also returns the veto id via a by-ref param.
 *
 * @param client            Client index.
 * @param inVetoId          Id of the veto the client is in.
 * @return                  Whether the client is currently in a veto.
 */
native bool Vetoable_IsClientInVeto(int client, int &inVetoId = -1);

// =====[ STOCKS ]=====

/**
 * Adds actions to a veto from a string.
 * Example input: P1,P2,B1,B2,P1,P2,P0
 *
 * @param veto              Veto to add to.
 * @param input             Input string, see above example.
 * @param delimiter         Delimiter to use for the input string.
 * @return                  Number of added actions from the input string.
 */
stock int Vetoable_AddActionsFromString(VetoableVeto veto, char[] input, char[] delimiter = ",")
{
    char actions[64][4];
    int actionCount = ExplodeString(input, delimiter, actions, sizeof(actions), sizeof(actions[]));

    int addedCount = 0;

    for (int i = 0; i < actionCount; i++)
    {
        char typeChar = actions[i][0];
        int voterNum = StringToInt(actions[i][1]);

        VetoActionType type = typeChar == 'B' ? VetoActionType_Ban : VetoActionType_Pick;

        bool added = veto.AddAction(type, voterNum);
        if (added)
        {
            addedCount++;
        }
    }

    return addedCount;
}

/**
 * Adds participants to a veto from command args.
 *
 * @param veto              Veto to add to.
 * @param issuer            The command issuer.
 * @param count             Number of participants to look for.
 * @param offset            Number of command arguments to skip (offset).
 * @return                  Number of added participants from command args.
 */
stock int Vetoable_AddParticipantsFromArgs(VetoableVeto veto, int issuer, int count, int offset = 1)
{
    int args = GetCmdArgs();
    int addedCount = 0;

    for (int i = offset; i < (offset + count); i++)
    {
        if (i > args)
        {
            return addedCount;
        }

        char targetStr[MAX_NAME_LENGTH];
        GetCmdArg(i, targetStr, sizeof(targetStr));

        int target = FindTarget(issuer, targetStr, true, false);
        if (target == -1)
        {
            Vetoable_ReplyToCommand(issuer, "Cannot find participant by '%s'", targetStr);
            continue;
        }

        bool added = veto.AddParticipant(target);
        if (added)
        {
            addedCount++;
        }
    }

    return addedCount;
}

// =====[ FORWARDS ]=====

/**
 * Called when a veto is started.
 *
 * @param veto              VetoableVeto instance of the started veto.
 */
forward void Vetoable_OnVetoStarted(VetoableVeto veto);

/**
 * Called when a veto is actioned on.
 *
 * @param veto              VetoableVeto instance of the actioned veto.
 * @param voter             Client index of the player who actioned on the veto.
 * @param type              Type of the action (VetoableVetoType).
 * @param name              Name of the actioned item.
 * @param value             Value of the actioned item.
 */
forward void Vetoable_OnVetoAction(VetoableVeto veto, int voter, VetoActionType type, const char[] name, const char[] value);

/**
 * Called when a veto is ended.
 *
 * @param veto              VetoableVeto instance of the ended veto.
 * @param reason            Reason of why the veto ended (VetoEndReason).
 */
forward void Vetoable_OnVetoEnded(VetoableVeto veto, VetoEndReason reason);

// =====[ DEPENDENCY ]=====

public SharedPlugin __pl_Vetoable = 
{
    name = "Vetoable", 
    file = "vetoable.smx", 
    #if defined REQUIRE_PLUGIN
    required = 1, 
    #else
    required = 0, 
    #endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_Vetoable_SetNTVOptional()
{
    // Methodmap
    MarkNativeAsOptional("VetoableVeto.VetoableVeto");
    MarkNativeAsOptional("VetoableVeto.Start");
    MarkNativeAsOptional("VetoableVeto.Cancel");
    MarkNativeAsOptional("VetoableVeto.GetName");
    MarkNativeAsOptional("VetoableVeto.IsValid.get");
    MarkNativeAsOptional("VetoableVeto.IsStarted.get");
    MarkNativeAsOptional("VetoableVeto.AddItem");
    MarkNativeAsOptional("VetoableVeto.AddAction");
    MarkNativeAsOptional("VetoableVeto.AddParticipant");
    MarkNativeAsOptional("VetoableVeto.ItemCount.get");
    MarkNativeAsOptional("VetoableVeto.ActionCount.get");
    MarkNativeAsOptional("VetoableVeto.ParticipantCount.get");
    MarkNativeAsOptional("VetoableVeto.RemainingItemCount.get");
    MarkNativeAsOptional("VetoableVeto.NeededParticipants.get");
    MarkNativeAsOptional("VetoableVeto.GetItemName");
    MarkNativeAsOptional("VetoableVeto.GetItemValue");
    MarkNativeAsOptional("VetoableVeto.GetActionType");
    MarkNativeAsOptional("VetoableVeto.GetActionVoterNum");
    MarkNativeAsOptional("VetoableVeto.GetParticipant");
    MarkNativeAsOptional("VetoableVeto.GetRemainingItemName");
    MarkNativeAsOptional("VetoableVeto.GetRemainingItemValue");
    // End methodmap

    MarkNativeAsOptional("Vetoable_PrintToChat");
    MarkNativeAsOptional("Vetoable_PrintToChatAll");
    MarkNativeAsOptional("Vetoable_ReplyToCommand");
    MarkNativeAsOptional("Vetoable_IsClientInVeto");
}
#endif
