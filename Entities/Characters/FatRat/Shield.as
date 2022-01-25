#include "Knocked.as";
#include "RunnerCommon.as"; //

const int SHIELD_FREQUENCY = 60 * 30; // 75 secs

void onInit( CBlob@ this )
{
	this.set_u32("last shield", 0);
	this.set_bool("shield ready", true);
	this.set_u32("shield", 0);

	this.addCommandID("shield");
	this.addCommandID("addMaterializing");
	this.addCommandID("removeMaterializing");
}

void onTick(CBlob@ this) 
{	
	if (this.get_u32("shield") > 15030)
	{
		this.set_u32("shield", 10*30 - 5); // checks if this gone endless and sets it back to last ticks
	}
	bool ready = this.get_bool("shield ready");
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
					this.set_u32("last shield", gametime);
					this.set_bool("shield ready", false);
					this.SendCommand(this.getCommandID("addMaterializing"));
					this.SendCommand(this.getCommandID("shield"));
				}
			}
		}
	} else 
    {		
		u32 lastShield = this.get_u32("last shield");
		int diff = gametime - (lastShield + SHIELD_FREQUENCY);
		
		if (controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("shield ready", true);
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
	RunnerMoveVars@ moveVars;
    if (this.get("moveVars", @moveVars))
    {
       moveVars.walkSpeed = 2.1f;
	   moveVars.walkSpeedInAir = 2.1f;
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
		if(!isServer())
	{
		return;
	}

	if (cmd == this.getCommandID("addMaterializing"))
	{
		this.Tag("materializing");
	}

	if (cmd == this.getCommandID("removeMaterializing"))
	{
		this.Untag("materializing");
	}

	if (cmd == this.getCommandID("shield"))
	{
		Shield(this);
	}
}

void Shield(CBlob@ this)	
{	
	this.set_u32("shield", 15*30);
	this.Sync("shield", true);

	Vec2f targetPos = this.getAimPos() + Vec2f(0.0f,-2.0f);
	Vec2f userPos = this.getPosition() + Vec2f(0.0f,-2.0f);
	Vec2f castDir = (targetPos- userPos);
	castDir.Normalize();
	castDir *= 20; //all of this to get deviation 2.5 blocks in front of caster
	Vec2f castPos = userPos + castDir; //exact position of effect

	CBlob@ barrier = server_CreateBlob( "battering_ram" ); //creates "supershield"
	this.getSprite().PlaySound("ShieldStart.ogg", 3.0f);

	if (barrier !is null)
	{
		barrier.SetDamageOwnerPlayer( this.getPlayer() ); //<<important
		barrier.server_setTeamNum( this.getTeamNum() );
		barrier.setPosition( castPos );
		barrier.setAngleDegrees(-castDir.Angle()+90.0f);
	}
}