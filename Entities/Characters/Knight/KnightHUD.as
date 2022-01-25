//knight HUD

#include "Dash.as"
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
	else if (type < 255)
	{
		frame = 1 + type;
	}

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw class icon

	GUI::DrawIcon(iconsFilename, frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f);

     //Dash icon
	u32 lastDash = blob.get_u32("last dash");
	int diff = gametime - (lastDash + DASH_FREQUENCY);
	double cooldownDashSecs = (diff / 30) * (-1);
	int cooldownDashFullSecs = diff % 30;
	double cooldownDashSecsHUD;
	if (cooldownDashFullSecs == 0 && cooldownDashSecs >= 0) cooldownDashSecsHUD = cooldownDashSecs;
	
	if (diff > 0)
	{
		GUI::DrawIcon( "Dash.png", 0, Vec2f(16,16), Vec2f(11,158));
		GUI::SetFont("menu"); GUI::DrawText("  R button", Vec2f(25,175), SColor(255, 255, 216, 0));
	}
	else
	{
		GUI::DrawIcon( "MenuItems.png", 13, Vec2f(32,32), Vec2f(10,158), 0.5f);
		GUI::SetFont("menu"); GUI::DrawText("" + cooldownDashSecs + "  R button", Vec2f(25,175), SColor(255, 255, 216, 0));
	}
}
