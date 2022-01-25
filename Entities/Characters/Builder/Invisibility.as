#include "Knocked.as";

//f32 SOUND_DISTANCE = 256.0f;
const int INVISIBILITY_FREQUENCY = 60 * 30; //60 secs

void onInit( CBlob@ this )
{
	this.set_u32("last invisibility", 0 );
	this.set_bool("invisibility ready", true );
	this.set_u32("invisible", 0);
	this.Sync("invisible", true);

	this.addCommandID("invisibility");
}

void onTick( CBlob@ this ) 
{	
	if (this.get_u32("invisible") > 15*30)
	{
		this.set_u32("invisible", 15*30 - 5); // checks if invisibility gone endless and sets it back to last ticks
	}
	bool ready = this.get_bool("invisibility ready");
	const u32 gametime = getGameTime();
	CControls@ controls = getControls();
	
	if(ready) 
    {
		if (this !is null)
		{
			if (isClient() && this.isMyPlayer())
			{
				if (controls.isKeyJustPressed(KEY_KEY_R))
				{
					this.set_u32("last invisibility", gametime);
					this.set_bool("invisibility ready", false );
					this.SendCommand(this.getCommandID("invisibility"));
				}
			}
		}
	} else 
    {		
		u32 lastInvisibility = this.get_u32("last invisibility");
		int diff = gametime - (lastInvisibility + INVISIBILITY_FREQUENCY);
		
		if(controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("invisibility ready", true );
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("invisibility"))
    {
        Invisibility(this);
    }
}

void Invisibility(CBlob@ this) //check the anim and logic files too	
{	
	//turn ourselves invisible
	ParticleAnimated( "LargeSmoke.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );
	this.set_u32("invisible", 15*30);
	this.Sync("invisible", true);
	
    //sound
	//CBlob@[] nearBlobs;
	//this.getMap().getBlobsInRadius( this.getPosition(), SOUND_DISTANCE, @nearBlobs );
	//this.getSprite().PlaySound("", 3.0f);
	
}