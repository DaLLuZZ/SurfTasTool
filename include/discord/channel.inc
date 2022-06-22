enum
{
	GUILD_TEXT = 0,
	DM,
	GUILD_VOICE,
	GROUP_DM,
	GUILD_CATEGORY
};

methodmap DiscordChannel < StringMap
{
	public DiscordChannel()
	{
		Handle hObj = json_object();
		return view_as<DiscordChannel>(hObj);
	}

	public native void ChannelSendMessageBot(DiscordBot Bot, char[] message, char[] embed, OnMessageSent fCallback, any data);

	public void SendMessage(Handle Bot, char[] message, MessageEmbed Embed, OnMessageSent fCallback = INVALID_FUNCTION, any data = 0)
	{
		if (!Embed && !message[0])
			return;

		char stringEmbed[8192];
		stringEmbed[0] = '\0';
		if (Embed)
		{
			json_dump(Embed, stringEmbed, sizeof(stringEmbed), 0, true);
			Embed.Fields = json_null();
			delete Embed;
		}

		this.ChannelSendMessageBot(view_as<DiscordBot>(Bot), message, stringEmbed, fCallback, data);
	}

	public void GetGuildID(char[] buffer, int maxlength)
	{
		JsonObjectGetString(this, "guild_id", buffer, maxlength);
	}
	
	public void GetID(char[] buffer, int maxlength)
	{
		JsonObjectGetString(this, "id", buffer, maxlength);
	}
	
	public void GetName(char[] buffer, int maxlength)
	{
		JsonObjectGetString(this, "name", buffer, maxlength);
	}
	
	property int Position
	{
		public get() {
			return JsonObjectGetInt(this, "position");
		}
	}
	
	property bool IsPrivate
	{
		public get()
		{
			return JsonObjectGetBool(this, "is_private");
		}
	}
	
	public void GetTopic(char[] buffer, int maxlength)
	{
		JsonObjectGetString(this, "topic", buffer, maxlength);
	}
	
	public void GetLastMessageID(char[] buffer, int maxlength)
	{
		JsonObjectGetString(this, "last_message_id", buffer, maxlength);
	}
	
	public void SetLastMessageID(const char[] id)
	{
		json_object_set_new(this, "last_message_id", json_string(id));
	}
	
	property int Type
	{
		public get()
		{
			return JsonObjectGetInt(this, "type");
		}
	}
	
	property int Bitrate
	{
		public get()
		{
			return JsonObjectGetInt(this, "bitrate");
		}
	}
	
	property int UserLimit
	{
		public get()
		{
			return JsonObjectGetInt(this, "user_limit");
		}
	}
	
	property bool IsText
	{
		public get()
		{
			return this.Type == GUILD_TEXT;
		}
	}
};
