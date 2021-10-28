enum struct VetoItem
{
    char Name[128];
    char Value[128];

    bool Validate()
    {
        if (StrEqual(this.Name, ""))
        {
            return false;
        }

        return true;
    }
}
