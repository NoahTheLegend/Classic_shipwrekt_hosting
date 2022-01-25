//knight HUD

#include "Slowing.as"
#include "/Entities/Common/GUI/ActorHUDStartPos.as";

const string iconsFilename = "Entities/Characters/Knight/KnightIcons.png";
const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors(CBlob@ this)
{
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-32, -32));
		}
		else
		{
			getHUD().SetCursorImage("Entities/Characters/Knight/KnightCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-22, -22));
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	ManageCursors(blob);

    const u32 gametime = getGameTime();

	if (g_videorecording)
		return;

	CPlayer@ player = blob.getPlayer();

	// draw inventory

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, tl);

	u8 type = blob.get_u8("bomb type");
	u8 frame = 1;
	if (type == 0)
	{
		frame = 0;
	}
	else
	{
		frame = 1 + type;
	}

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw class icon

	GUI::DrawIcon(iconsFilename, frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f);

	u32 lastSlow = blob.get_u32("last slow");
	int diff = gametime - (lastSlow + SLOW_FREQUENCY);
	double cooldownSlowSecs = (diff / 30) * (-1);
	int cooldownSlowFullSecs = diff % 30;
	double cooldownSlowSecsHUD;
	if (cooldownSlowFullSecs == 0 && cooldownSlowSecs >= 0) cooldownSlowSecsHUD = cooldownSlowSecs;
	
	u32 lastMining = blob.get_u32("last mining");
	int difff = gametime - (lastMining + MINING_FREQUENCY);
	double cooldownMiningSecs = (difff / 30) * (-1);
	int cooldownMiningFullSecs = difff % 30;
	double cooldownMiningSecsHUD;
	if (cooldownMiningFullSecs == 0 && cooldownMiningSecs >= 0) cooldownMiningSecsHUD = cooldownMiningSecs;
	
	if (diff > 0)
	{
		GUI::DrawIcon( "Slowing.png", 0, Vec2f(16,16), Vec2f(11,158));
		GUI::SetFont("menu"); GUI::DrawText("  R button", Vec2f(25,175), SColor(255, 255, 216, 0));
	}
	else
	{
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), Vec2f(10,158), 0.5f);
		GUI::SetFont("menu"); GUI::DrawText("" + cooldownSlowSecs + "  R button", Vec2f(25,175), SColor(255, 255, 216, 0));
	}
	if (difff > 0)
	{
		GUI::DrawIcon( "Mining.png", 0, Vec2f(16,16), Vec2f(11,198));
		GUI::SetFont("menu"); GUI::DrawText("  V button", Vec2f(25,215), SColor(255, 255, 216, 0));
	}
	else
	{
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), Vec2f(10,198), 0.5f);
		GUI::SetFont("menu"); GUI::DrawText("" + cooldownMiningSecs + "  V button", Vec2f(25,215), SColor(255, 255, 216, 0));
	}
}
