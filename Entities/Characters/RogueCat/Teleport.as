// MUST BE TELEPORT SKILL BUT getPosition() AND setPosition DO NOT WORK OR IM A BAD PROGRAMMER
// - NOAH

#include "Knocked.as";
#include "RunnerCommon.as";

//f32 SOUND_DISTANCE = 256.0f;
const int TELEPORT_FREQUENCY = 30 * 45;


void onInit( CBlob@ this )
{
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
	this.set_u32("teleport", 0);

	this.addCommandID("teleport");
}

void onTick( CBlob@ this ) 
{	
	bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	RunnerMoveVars@ moveVars;
	CControls@ controls = getControls();

	if (this.get_u32("teleport") > 0)
	{
		if (this.get("moveVars", @moveVars) && this.getName() == "roguecat")
    	{
      		moveVars.walkSpeed = 2.7f;
			moveVars.walkSpeedInAir = 2.7f;
	   		moveVars.walkFactor = 1.4f;
    	}
	} else
	{
		if (this.get_u32("teleport") < 1)
		{
  		 	if (this.get("moveVars", @moveVars) && this.getName() == "roguecat")
  	 		{
    	 	 	moveVars.walkSpeed = 2.5f;
		  		moveVars.walkSpeedInAir = 2.5f;
		   		moveVars.walkFactor = 1.1f;
    		}
		}
	}

	if (ready) 
    {
		if (this !is null)
		{
			if (isClient() && this.isMyPlayer())
			{
				if (controls.isKeyJustPressed(KEY_KEY_R))
				{		
					this.set_u32("last teleport", gametime);
					this.set_bool("teleport ready", false);
					this.SendCommand(this.getCommandID("teleport"));
				}
			}
		}
	} else 
    {	 
		u32 lastTeleport = this.get_u32("last teleport");
		int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
		
		if(controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}
		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("teleport"))
    {
        Teleport(this);
    }
}

void Teleport(CBlob@ this)
{
	ParticleAnimated( "SmallSmoke2.png", this.getPosition(), Vec2f(0,0), 10.0f, 3.0f, 2.5, -0.1f, false );
	ParticleAnimated( "SmallSmoke2.png", this.getPosition(), Vec2f(0,0), 10.0f, 4.0f, 2.5, -0.1f, false );
	this.set_u32("teleport", 2.5*30);
	this.getSprite().PlaySound("tadumhuh.ogg", 3.5);
}