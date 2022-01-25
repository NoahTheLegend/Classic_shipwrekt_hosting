#include "Knocked.as";

const int DASH_FREQUENCY = 30 * 30; //60 secs

void onInit( CBlob@ this )
{
	this.set_u32("last dash", 0);
	this.set_bool("dash ready", true);
	this.set_u32("dash", 0);
}
void onTick( CBlob@ this ) 
{	
	CRules @rules = getRules();	
	bool ready = this.get_bool("dash ready");
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
					this.set_u32("last dash", gametime);
					this.set_bool("dash ready", false);
					Dash(this);
				}
			}
		}
	} else 
    {		
		u32 lastDash = this.get_u32("last dash");
		int diff = gametime - (lastDash + DASH_FREQUENCY);
		
		if(controls.isKeyJustPressed(KEY_KEY_R) && this.isMyPlayer())
		{
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("dash ready", true);
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
}

void Dash(CBlob@ this) //check the anim and logic files too	
{	
    Vec2f vel = this.getVelocity();
	this.AddForce(Vec2f(vel.x * 5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
			
	Vec2f velocity = this.getAimPos() - this.getPosition();
	velocity.Normalize();
	// velocity.y *= 0.5f;
				
	this.setVelocity(velocity * 5);
	this.set_string("sweep", "sweep.ogg");
	this.getSprite().PlaySound(this.get_string("sweep"));
}