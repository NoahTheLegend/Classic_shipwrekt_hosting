#include "Knocked.as";
#include "RunnerCommon.as"; //

const int HEAL_FREQUENCY = 90 * 30; // 90 secs
const float HEALRADIUS = 8*10;
void onInit( CBlob@ this )
{
	this.set_u32("last heal", 0);
	this.set_bool("heal ready", true);
	this.set_u32("heal", 0);

	this.addCommandID("heal");
}

void onTick(CBlob@ this) 
{	
	bool ready = this.get_bool("heal ready");
	const u32 gametime = getGameTime();
	CControls@ controls = getControls();
	
	if (ready) 
    {
		if (this !is null)
		{
			if (isClient() && this.isMyPlayer())
			{
				if (controls.isKeyJustPressed(KEY_KEY_R))
				{
					this.set_u32("last heal", gametime);
					this.set_bool("heal ready", false);
					this.SendCommand(this.getCommandID("heal"));
				}
			}
		}
	} else 
    {		
		u32 lastHeal = this.get_u32("last heal");
		int diff = gametime - (lastHeal + HEAL_FREQUENCY);
		
		if (controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("heal ready", true);
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
	RunnerMoveVars@ moveVars;
    if (this.get("moveVars", @moveVars) && !this.hasTag("vslowed"))
    {
       moveVars.walkSpeed = 2.1f;
	   moveVars.walkSpeedInAir = 2.1f;
    }
	else if (this.hasTag("vslowed"))
	{
		moveVars.walkSpeed = 1.8f;
		moveVars.walkSpeedInAir = 1.8f;
		moveVars.walkFactor = 0.8f;
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("heal"))
	{
		Heal(this);
	}
}

void Heal(CBlob@ this)	
{	
	CMap@ map = getMap();
	CBlob@[] blobs;
	map.getBlobsInRadius(this.getPosition(),HEALRADIUS,@blobs);
	f32 minHealthInRadius = 100;

	this.server_SetHealth(this.getInitialHealth()); //heals MyPlayer before finding most hurted teammate in radius
	this.set_string("eat sound", "HealSkill.ogg");
	this.getSprite().PlaySound("HealSkill.ogg", 3.0f);
	ParticleAnimated( "Heal.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );

	for (int i = 0; i < blobs.length; i++) // finds most hurted
	{
		CBlob@ b = blobs[i];

		f32 health = b.getHealth();
		if (health < minHealthInRadius)
		{
			minHealthInRadius = health;
		}
	}

	for (int i = 0; i < blobs.length; i++) 
	{
		CBlob@ b = blobs[i];

		if(b.getPlayer() !is null && b.getTeamNum() == this.getTeamNum()) // heals most hurted
		{
			f32 initHealth = b.getInitialHealth();
			if (b.getHealth() == minHealthInRadius)
			{
				ParticleAnimated( "Heal.png", b.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );
				b.server_SetHealth(initHealth);
				b.getSprite().PlaySound("HealSkill.ogg", 3.0f);
			}
		}
	}
}