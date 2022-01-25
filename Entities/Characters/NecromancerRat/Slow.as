#include "Knocked.as";
#include "RunnerCommon.as";

//f32 SOUND_DISTANCE = 256.0f;
const int SLOW_FREQUENCY = 30 * 30;
const int SUMMON_FREQUENCY = 50 * 30;

void onInit( CBlob@ this )
{
	this.set_u32("last slow", 0 );
	this.set_bool("slow ready", true );
	this.set_u32("slow", 0);
	this.Sync("slow", true);

	this.addCommandID("slow");
	
	this.set_u32("last summon", 0 );
	this.set_bool("summon ready", true );
	this.Sync("summon", true);

	this.addCommandID("summon");
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
			if (healblobs[i].getName() == "builder"
			|| healblobs[i].getName() == "fatrat"
			|| healblobs[i].getName() == "minerrat"
			|| healblobs[i].getName() == "necrorat")
			{
				healblobs[i].server_Heal(0.5);
				ParticleAnimated( "Heal.png", healblobs[i].getPosition(), Vec2f(0,0), 0.0f, 2.0f, 1.5, -0.1f, false );
			}
		}
	}

	RunnerMoveVars@ moveVars;

	if (this.get_u32("slow") > 5*30)
	{
		this.set_u32("slow", 5*30 - 5);
	}
	for (int i = 0; i < getPlayersCount(); i++)
    {
    	CBlob@ blob = getPlayer(i).getBlob();

        if (blob is null) continue;

        if (blob.getTeamNum() == 0 && blob.getName() != "roguecat")
        {
			if (this.get_u32("slow") > 1 && blob !is null) 
			{
  				if (blob.get("moveVars", @moveVars) && blob.hasTag("vslowed") && blob.getName() != "roguecat") // setting slowness
  	 			{
    	 			moveVars.walkSpeed = 1.8f;
		  			moveVars.walkSpeedInAir = 1.8f;
		  			moveVars.walkFactor = 0.8f;
    			}
			} 
			else 
			{	
				if (blob.get("moveVars", @moveVars) && blob.getTeamNum() == 0 && blob.getName() != "roguecat" || this.get_u32("slow") <= 1)
  	 			{
					if (blob.getName() == "fatcat")
					{
						moveVars.walkSpeed = 2.1f;
	  					moveVars.walkSpeedInAir = 2.1f;
						moveVars.walkFactor = 1.0f;
					} else
					{
						moveVars.walkSpeed = 2.6f;
						moveVars.walkSpeedInAir = 2.5f;
						moveVars.walkFactor = 1.0f;
					}
					if (blob.hasTag("vslowed"))
					{
						blob.Untag("vslowed");
					}
				}
			}
		}
	}
	bool ready = this.get_bool("slow ready");
	bool readys = this.get_bool("summon ready");
	const u32 gametime = getGameTime();
	CControls@ controls = getControls();
	CRules@ rules = getRules();
	
	if (ready && !rules.isWarmup()) 
    {
		if (this !is null)
		{
			if (isClient() && this.isMyPlayer())
			{
				if (controls.isKeyJustPressed(KEY_KEY_R))
				{
					this.set_u32("last slow", gametime);
					this.set_bool("slow ready", false );
					this.SendCommand(this.getCommandID("slow"));
				}
			}
		}
	} else 
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
					this.set_u32("last summon", gametime);
					this.set_bool("summon ready", false );
					this.SendCommand(this.getCommandID("summon"));
				}
			}
		}
	} else 
    {		
		u32 lastSummon = this.get_u32("last summon");
		int diff = gametime - (lastSummon + SUMMON_FREQUENCY);
		
		if (controls.isKeyJustPressed(KEY_KEY_V) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("summon ready", true );
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
      		if (blobs[i] is null || blobs[i].getName() == "food") continue;

      		if (blobs[i].getTeamNum() == 0)
      		{
				for (int i = 0; i < blobs.length; i++)
				{
					if (blobs[i].getTeamNum() == 0)
					{
						blobs[i].Tag("vslowed");
					}
				}
				blobs[i].getSprite().PlaySound("ShieldStart.ogg", 3.0f);
				ParticleZombieLightning(blobs[i].getPosition());
			}
		}
	}
	 if (cmd == this.getCommandID("summon"))
    {
        Summon(this);
    }
}

void Slow(CBlob@ this)
{	
	this.set_u32("slow", 7.5*30);
}

void Summon(CBlob@ this) 
{	
	int players = 0;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		if (getPlayer(i).getBlob() !is null) players++;
	}
	if (players <= 5)
	{
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
	}
	else if (players > 5 && players <= 10)
	{
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
	}
	else if (players > 10 && players <= 16)
	{
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
	}
	if (players > 16)
	{
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Zombie", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
		server_CreateBlob("Skeleton", this.getTeamNum(), this.getPosition());
	}
}