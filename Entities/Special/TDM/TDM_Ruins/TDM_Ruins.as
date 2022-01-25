// TDM Ruins logic

#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "RespawnCommandCommon.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));

	//MICE
	AddIconToken("$builder_class_icon$", "Entities/Characters/Builder/Rat.png", Vec2f(25, 25), 12);
	AddIconToken("$fatrat_class_icon$", "Entities/Characters/FatRat/FatRat.png", Vec2f(25, 25), 16);
	AddIconToken("$minerrat_class_icon$", "Entities/Characters/MinerRat/MinerRat.png", Vec2f(25, 25), 20);
	AddIconToken("$necrorat_class_icon$", "Entities/Characters/NecromancerRat/NRat.png", Vec2f(25, 25), 20);
	// ADD NEW MICE CLASSES ONLY HERE (OR U GONNA MAKE CLASS SEPARATION FUNCTION WORK WRONG)

	//CATS
	AddIconToken("$knight_class_icon$", "Entities/Characters/Knight/Cat.png", Vec2f(25, 25), 16);
	AddIconToken("$fatcat_class_icon$", "Entities/Characters/FatCat/FatCat.png", Vec2f(25, 25), 16);
	AddIconToken("$roguecat_class_icon$", "Entities/Characters/RogueCat/RogueCat.png", Vec2f(25, 25), 20);
	AddIconToken("$priestcat_class_icon$", "Entities/Characters/PriestCat/PCat.png", Vec2f(25, 25), 24);
	// ADD NEW CATS CLASSES ONLY HERE (OR U GONNA MAKE CLASS SEPARATION FUNCTION WORK WRONG)
	
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	
	//MICE
	addPlayerClass(this, "Rogue rat, haves invisibility and mobility, immune to fall damage", "$builder_class_icon$", "builder", "Rat");
	addPlayerClass(this, "Fat rat, haves magic barrier and more HP, immune to knockback", "$fatrat_class_icon$", "fatrat", "Rat");
	addPlayerClass(this, "Miner rat, haves increasing mining speed ability and bigger inventory", "$minerrat_class_icon$", "minerrat", "Rat");
	addPlayerClass(this, "Necromancer, slows down cats, summon zombies and passively regens HP of rats", "$necrorat_class_icon$", "necrorat", "Rat");
	// ^^^ needs an extra line because menu is created without last class-token
	addPlayerClass(this, "extra line", "minerrat_class_icon$", "minerrat", "Rat");
	// ADD NEW MICE CLASSES ONLY HERE (OR U GONNA MAKE CLASS SEPARATION FUNCTION WORK WRONG)

	//CATS
	addPlayerClass(this, "Regular Cat, haves a double jump", "$knight_class_icon$", "knight", "Cat");
	addPlayerClass(this, "Fat Cat, haves healing ability (you and most damaged teammate)", "$fatcat_class_icon$", "fatcat", "Cat");
	addPlayerClass(this, "Rogue Cat, haves speed increasing ability, slash loading is slower, immune to fall damage", "$roguecat_class_icon$", "roguecat", "Cat");
	addPlayerClass(this, "Priest cat, increases mining speed of cats and decreases for rats, passively regens HP of cats", "$priestcat_class_icon$", "priestcat", "Cat");
	// ^^^ noneeds an extra line because menu is created without last class-token
	// ADD NEW CATS CLASSES ONLY HERE (OR U GONNA MAKE CLASS SEPARATION FUNCTION WORK WRONG)


	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("class menu");

	this.Tag("change class drop inventory");

	this.getSprite().SetZ(-50.0f);   // push to background
}

void onTick(CBlob@ this)
{
	if (enable_quickswap)
	{
		//quick switch class
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null && blob.isMyPlayer())
		{
			if (
				isInRadius(this, blob) && //blob close enough to ruins
				blob.isKeyJustReleased(key_use) && //just released e
				isTap(blob, 7) && //tapped e
				blob.getTickSinceCreated() > 1 //prevents infinite loop of swapping class
			) {
				CycleClass(this, blob);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("class menu"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null && caller.isMyPlayer())
		{
			BuildRespawnMenuFor(this, caller);
		}
	}
	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (canChangeClass(this, caller))
	{
		if (isInRadius(this, caller))
		{
			BuildRespawnMenuFor(this, caller);
		}
		else
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(0, 6), this, this.getCommandID("class menu"), getTranslatedString("Change class"), params);
		}
	}

	// warning: if we don't have this button just spawn menu here we run into that infinite menus game freeze bug
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return (this.getPosition() - caller.getPosition()).Length() < this.getRadius();
}
