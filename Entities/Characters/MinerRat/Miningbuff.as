#include "Knocked.as";

//f32 SOUND_DISTANCE = 256.0f;
const int MINING_FREQUENCY = 65 * 30; // 60 secs

void onInit( CBlob@ this )
{
	this.set_u32("last mining", 0 );
	this.set_bool("mining ready", true );
	this.set_u32("mining", 0);
	this.set_bool("mining enable", false);

	this.addCommandID("mining");
}

void onTick( CBlob@ this ) 
{	
	if (this.get_u32("mining") > 5*30)
	{
		this.set_u32("mining", 5*30 - 5);
	}
	bool ready = this.get_bool("mining ready");
	const u32 gametime = getGameTime();
	CControls@ controls = getControls();
	
	if (this.get_bool("mining enable") == true)
	{
		this.set_bool("isslowed", false);
		CSprite@ sprite = this.getSprite();
		Animation@ animation_strike = sprite.getAnimation("strike");
		Animation@ animation_chop = sprite.getAnimation("chop");
		animation_strike.time = 1;
		animation_chop.time = 1;	
	}
	
	if (this.get_bool("mining enable") == false)
	{
		CSprite@ sprite = this.getSprite();
		Animation@ animation_strike = sprite.getAnimation("strike");
		Animation@ animation_chop = sprite.getAnimation("chop");
		animation_strike.time = 2;
		animation_chop.time = 2;
	}
	CRules@ rules = getRules();
	if (ready && !rules.isWarmup()) 
    {
		if (this !is null)
		{
			if (isClient() && this.isMyPlayer())
			{
				if (controls.isKeyJustPressed(KEY_KEY_R))
				{
					this.set_u32("last mining", gametime);
					this.set_bool("mining ready", false);
					this.SendCommand(this.getCommandID("mining"));
				}
			}
		}
	} else 
    {		
		u32 lastMining = this.get_u32("last mining");
		int diff = gametime - (lastMining + MINING_FREQUENCY);
		
		if(controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("mining ready", true );
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("mining"))
    {
        Mining(this);
    }
}

void Mining(CBlob@ this) //check the anim and logic files too	
{		
	this.set_u32("mining", 5*30);
	this.set_bool("mining enable", true);
	ParticleAnimated( "SmallSteam.png", this.getPosition(), Vec2f(0.5,-0.25), 0.0f, 1.0f, 0.5, -0.1f, false );
	ParticleAnimated( "SmallSteam.png", this.getPosition(), Vec2f(-0.5,-0.5), 0.0f, 1.5f, 1.0, -0.1f, false );
	ParticleAnimated( "SmallSteam.png", this.getPosition(), Vec2f(1,-0.75), 0.0f, 2.0f, 1.5, -0.1f, false );
	ParticleAnimated( "SmallSteam.png", this.getPosition(), Vec2f(-1,-1), 0.0f, 2.5f, 2.0, -0.1f, false );
	ParticleAnimated( "SmallSteam.png", this.getPosition(), Vec2f(1,-1.25), 0.0f, 3.0f, 2.5, -0.1f, false );
	ParticleAnimated( "SmallSteam.png", this.getPosition(), Vec2f(-1,-1.25), 0.0f, 3.0f, 2.5, -0.1f, false );
	
    //sound
	//CBlob@[] nearBlobs;
	//this.getMap().getBlobsInRadius( this.getPosition(), SOUND_DISTANCE, @nearBlobs );
	//this.getSprite().PlaySound("", 3.0f);
	
}