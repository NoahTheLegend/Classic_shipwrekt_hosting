#include "Knocked.as";

//f32 SOUND_DISTANCE = 256.0f;
const int SUMMON_FREQUENCY = 10 * 30; //60 secs

void onInit( CBlob@ this )
{
	this.set_u32("last summon", 0 );
	this.set_bool("summon ready", true );
	this.Sync("summon", true);

	this.addCommandID("summon");
}

void onTick( CBlob@ this ) 
{	
	bool ready = this.get_bool("summon ready");
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
		
		if(controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
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
    if (cmd == this.getCommandID("summon"))
    {
        Summon(this);
    }
}

void Summon(CBlob@ this) 
{	
	return;
}