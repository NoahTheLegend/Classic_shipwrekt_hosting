#define CLIENT_ONLY

bool canShow = true;
u32 timer = 400;

string rules = "JailBreak rules:\n\n"
+ "This message will disappear automatically after 10 seconds. Type !rules to show it again.\n"
+ "Guards:\n"
+ "1. Don't kill prisoners inside cells\n"
+ "2. Don't kill prisoners without reason\n"
+ "3. Before killing warn jabbing him\n"
+ "4. Give commands to the prisoners\n\n\n" 
+ "Possible reasons to attack/kill the prisoner:\n"
+ "1. The prisoner has killed a guard ***\n"
+ "2. The prisoner's attacking you or other guard ***\n"
+ "3. The prisoner's destroying the prison\n"
+ "4. The prisoner's trying to escape the prison ***\n"
+ "5. The prisoner's not executing your commands ***\n"
+ "6. The prisoner's last one alive ***\n"
+ "7. The prisoner is AFK ***\n"
+ "Prisoners:\n"
+ "Escape the jail to the restricted area!\n\n\n"
+ " - Modification Created By PLDragON - Hosted & Fixed By Terracraft\n";

void renderRules()
{
	s32 scrw = getScreenWidth();
	s32 scrh = getScreenHeight();

	s32 w = 800;
	s32 h = 296;

	Vec2f tl(scrw / 2 - w / 2, 120);
	Vec2f br(scrw / 2 + w / 2, 120 + h);
	
	GUI::DrawButton(tl, br);
	GUI::DrawText(rules, tl + Vec2f(10, 10), br - Vec2f(10, 10), color_white, true, true, false);
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(text_in == "!rules" && !getNet().isServer() && getLocalPlayer().getUsername() == player.getUsername())
	{
		canShow = true;
		timer = 400;
	}
	
	if(text_in == "!accept" && !getNet().isServer() && getLocalPlayer().getUsername() == player.getUsername())
	{
		canShow = false;
		timer = 0;
	}

	return true;
}

void onTick(CRules@ this)
{
	if(timer > 0)
	{
		timer--;
	}
	
	canShow = (timer > 0);
}

void onRender(CRules@ this)
{
	if(canShow)
	{
		renderRules();
	}
}