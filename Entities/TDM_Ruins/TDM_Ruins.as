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
	int prisonersq = 0;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		if (getPlayer(i).getTeamNum() == 1 && getPlayer(i).getBlob() !is null) prisonersq++;
	}
	this.set_u32("neededToEscape", prisonersq / 2);

	CRules@ rules = getRules();

	if (getPlayersCount() > 3)
	{
		rules.SetGlobalMessage("Alive players amount needed to escape: {AMOUNT}\nEscaped players: {EAMOUNT}");
		rules.AddGlobalMessageReplacement("AMOUNT", "" + this.get_u32("neededToEscape"));
		rules.AddGlobalMessageReplacement("EAMOUNT", "" + this.get_u32("escaped"));
	}

	if (this.get_u32("escaped") >= this.get_u32("neededToEscape") && getPlayersCount() > 3) 
	{
		rules.SetTeamWon(1);
		rules.SetCurrentState(GAME_OVER);
		rules.SetGlobalMessage("Prisoners win the game!");
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

		if (caller !is null && caller.isMyPlayer() && caller.getTeamNum() == 1)
		{
			this.getSprite().PlaySound("/metal_stone.ogg");
			this.set_u32("escaped", this.get_u32("escaped") + 1);
			caller.Tag("escaped");
			caller.server_Die();
			server_CreateBlob('grandpa',0,Vec2f(caller.getPosition())).server_SetPlayer(caller.getPlayer());
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
		if (isInRadius(this, caller) && caller.getTeamNum() == 1 && !caller.hasTag("escaped"))
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
