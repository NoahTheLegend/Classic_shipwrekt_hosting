#include "Knocked.as";
#include "KnightCommon.as";
#include "RunnerCommon.as";

//f32 SOUND_DISTANCE = 256.0f;
const int SLOW_FREQUENCY = 50 * 30;
const int MINING_FREQUENCY = 70 * 30;

void onInit( CBlob@ this )
{
	this.set_u32("last slow", 0 );
	this.set_bool("slow ready", true );
	this.set_u32("slow", 0);

	this.addCommandID("slow");
	
	this.set_u32("last mining", 0 );
	this.set_bool("mining ready", true );
	this.set_u32("mining", 0);

	this.addCommandID("mining");
}

void onTick( CBlob@ this ) 
{	
	CMap@ map = getMap();
	CBlob@[] healblobs;
	map.getBlobsInRadius(this.getPosition(),50,@healblobs); // regen
	for (int i = 0; i < healblobs.length; i++)
	{
		if (healblobs[i] is null || healblobs[i].isMyPlayer() || healblobs[i].getTeamNum() != this.getTeamNum() || healblobs[i].isMyPlayer()) continue;
		if (getGameTime() % (10 * 30) == 0)
		{
			if (healblobs[i].getName() == "knight"
			|| healblobs[i].getName() == "fatcat"
			|| healblobs[i].getName() == "roguecat"
			|| healblobs[i].getName() == "priestcat")
			{
				healblobs[i].server_Heal(0.5);
				ParticleAnimated( "Heal.png", healblobs[i].getPosition(), Vec2f(0,0), 0.0f, 2.0f, 1.5, -0.1f, false );
			}
		}
	}

	bool ready = this.get_bool("slow ready");
	bool readys = this.get_bool("mining ready");
	const u32 gametime = getGameTime();
	CControls@ controls = getControls();
	CRules@ rules = getRules();
	RunnerMoveVars@ moveVars;
	CSprite@ sprite = this.getSprite();

	for (int i = 0; i < getPlayersCount(); i++)
    {
    	CBlob@ blob = getPlayer(i).getBlob();

        if (blob is null || blob.getTeamNum() != 1) continue;

		if (!blob.hasTag("slowed")) blob.Tag("slowed");
		else if (this.get_u32("slow") <= 1)
		{
			blob.Untag("slowed");
		}
	}
	for (int i = 0; i < getPlayersCount(); i++)
    {
    	CBlob@ blob = getPlayer(i).getBlob();

        if (blob is null) continue;

        if (blob.getTeamNum() == 0)
        {
			if (blob !is null) 
			{
				
			} 
			else 
			{	
				if (blob.getTeamNum() == 0)
  	 			{
					{
						blob.Untag("mining");
					}
				}
			}
		}
	}
	if (ready && !rules.isWarmup()) // 
    {
		if (this !is null)
		{
			if (controls.isKeyJustPressed(KEY_KEY_R))
			{
				this.set_u32("last slow", gametime);
				this.set_bool("slow ready", false );
				this.SendCommand(this.getCommandID("slow"));
			}
		}
	}
	else 
    {		
		u32 lastSlow = this.get_u32("last slow");
		int diff = gametime - (lastSlow + SLOW_FREQUENCY);
		
		if(controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("slow ready", true );
		}
	}
	if (readys && !rules.isWarmup())
    {
		if (this !is null)
		{
			if (isClient() && this.isMyPlayer())
			{
				if (controls.isKeyJustPressed(KEY_KEY_V))
				{
					this.set_u32("last mining", gametime);
					this.set_bool("mining ready", false );
					this.SendCommand(this.getCommandID("mining"));
				}
			}
		}
	} else 
    {		
		u32 lastMining = this.get_u32("last mining");
		int diff = gametime - (lastMining + MINING_FREQUENCY);
		
		if (controls.isKeyJustPressed(KEY_KEY_V) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("mining ready", true );
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("slow"))
    {
		CMap@ map = getMap();
		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(),175,@blobs); // targets for slowness
		
		Slow(this);

		for (int i = 0; i < blobs.length; i++)
  		{
      		if (blobs[i] is null || blobs[i].getName() == "food" || blobs[i].getName() == "ladder" || blobs[i].getName() == "tdm_spawn"
			  || blobs[i].getName() == "ladder") continue;

      		if (blobs[i].getTeamNum() == 1)
      		{
				blobs[i].set_bool("isslowed", true);
				blobs[i].set_u32("sloww", 5*30);
				ParticleAnimated( "LargeSmoke.png", blobs[i].getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );
			}
		}	
	}
	if (cmd == this.getCommandID("mining"))
    {
		CMap@ map = getMap();
		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(),175,@blobs); // targets for slowness
		
		Mining(this);

		for (int i = 0; i < blobs.length; i++)
  		{
      		if (blobs[i] is null || blobs[i].getName() == "food") continue;

      		if (blobs[i].getTeamNum() == 0)
      		{
				blobs[i].set_bool("ismining", true);
				blobs[i].set_u32("miningg", 6.5*30);
				blobs[i].getSprite().PlaySound("ShieldStart.ogg", 3.0f);
				ParticleAnimated( "FireFlash.png", this.getPosition(), Vec2f(0,0), 0.0f, 2.0f, .5, -0.1f, false );
			}
		}
    }
}

void Slow(CBlob@ this)
{	
	this.set_u32("slow", 5*30);
}

void Mining(CBlob@ this) 
{	
	this.set_u32("mining", 5*30);
}