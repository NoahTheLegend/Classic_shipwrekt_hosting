// TDM Ruins logic

#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "RespawnCommandCommon.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	//TDM classes
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("class menu");

	this.Tag("change class drop inventory");

	this.getSprite().SetZ(-50.0f);   // push to background

	this.add_u32("neededToEscape", 0);
	this.add_u32("escaped", 0);
}

void onTick(CBlob@ this)
{
	if (getGameTime() == 1)
	{
		int prisonersq = 0;
		for (int i = 0; i < getPlayersCount(); i++)
		{
			if (getPlayer(i).getTeamNum() == 1 && getPlayer(i).getBlob() !is null) prisonersq++;
		}
		this.set_u32("neededToEscape", prisonersq / 3);
	}
	CRules@ rules = getRules();

	int prisonersleft = 0;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		if (getPlayer(i).getTeamNum() == 1 && getPlayer(i).getBlob() !is null) prisonersleft++;
	}

	if (getPlayersCount() > 3 && getGameTime() < 300*30+10*30 && prisonersleft != 0 && this.get_u32("escaped") != this.get_u32("neededToEscape") )
	{
		rules.SetGlobalMessage("Alive players amount needed to escape: {AMOUNT}\nEscaped players: {EAMOUNT}");
		rules.AddGlobalMessageReplacement("AMOUNT", "" + this.get_u32("neededToEscape"));
		rules.AddGlobalMessageReplacement("EAMOUNT", "" + this.get_u32("escaped"));
	}
	if (getGameTime() == 300*30+10*30 && this.get_u32("escaped") == 0) // game duration + warmuptime
	{
		rules.SetTeamWon(1);
		rules.SetCurrentState(GAME_OVER);
		rules.SetGlobalMessage("There are no escaped prisoners, guardians win the game fairly!");
	} 
	else if (this.get_u32("escaped") == this.get_u32("neededToEscape") && this.get_u32("neededToEscape") != 0 && getPlayersCount() > 3)
	{
		rules.SetTeamWon(1);
		rules.SetCurrentState(GAME_OVER);
		rules.SetGlobalMessage("There are enough prisoners escaped, they win the game!");
	}
	else if (this.get_u32("escaped") > 0 && this.get_u32("neededToEscape") != 0 && getPlayersCount() > 3 && getGameTime() == 300*30+10*30) 
	{
		rules.SetTeamWon(1);
		rules.SetCurrentState(GAME_OVER);
		rules.SetGlobalMessage("There are escaped prisoners left, its a tie!");
	}

	if (enable_quickswap)
	{
		//quick switch class
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null && blob.isMyPlayer())
		{
			if (
				isInRadius(this, blob) && //blob close enough to ruins
				blob.isKeyJustReleased(key_use) && //just released e
				isTap(blob, 7) && //tapped e
				blob.getTickSinceCreated() > 1 //prevents infinite loop of swapping class
			) {
				CycleClass(this, blob);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("class menu"))
    {
        u16 callerID = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerID);
        string classconfig = params.read_string();

        if (caller !is null && caller.getTeamNum() == 1)
        {
            this.getSprite().PlaySound("/metal_stone.ogg");
            this.set_u32("escaped", this.get_u32("escaped") + 1);
            caller.Tag("escaped");
            
            caller.server_Die();
        }
    }
    else
    {
        onRespawnCommand(this, cmd, params);
    }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (canChangeClass(this, caller))
	{
		if (isInRadius(this, caller) && caller.getTeamNum() == 1 && !caller.hasTag("escaped") && getGameTime() > 10*30)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(0, 6), this, this.getCommandID("class menu"), getTranslatedString("Escape!"), params);
		}
	}

	// warning: if we don't have this button just spawn menu here we run into that infinite menus game freeze bug
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return (this.getPosition() - caller.getPosition()).Length() < this.getRadius();
}
