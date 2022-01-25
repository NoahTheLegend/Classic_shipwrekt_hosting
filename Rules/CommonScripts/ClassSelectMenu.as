//stuff for building respawn menus

#include "RespawnCommandCommon.as"

//class for getting everything needed for swapping to a class at a building

shared class PlayerClass
{
	string name;
	string iconFilename;
	string iconName;
	string configFilename;
	string description;
};

const f32 CLASS_BUTTON_SIZE = 2;

//adding a class to a blobs list of classes

void addPlayerClass(CBlob@ this, string name, string iconName, string configFilename, string description)
{
	if (!this.exists("playerclasses"))
	{
		PlayerClass[] classes;
		this.set("playerclasses", classes);
	}

	PlayerClass p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	this.push("playerclasses", p);
}

//helper for building menus of classes
CRules @rules = getRules();
void addClassesToMenuMice(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	if (getGameTime() <= 50*30 || rules.isWarmup())
	{
		PlayerClass[]@ classes;

		if (this.get("playerclasses", @classes))
		{
			for (uint i = 0 ; i < classes.length / 2; i++) 
			{
				PlayerClass @pclass = classes[i];

				CBitStream params;
				write_classchange(params, callerID, pclass.configFilename);

				CGridButton@ button = menu.AddButton(pclass.iconName, getTranslatedString(pclass.name), SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
				//button.SetHoverText( pclass.description + "\n" );
			}
		}
	}
}

void addClassesToMenuCats(CBlob@ this, CGridMenu@ menu, u16 callerID)
{
	if (getGameTime() <= 50*30 || rules.isWarmup() 
	|| getGameTime() >= (50*30+60*30) && getGameTime() <= (50*30+65*30)
	|| getGameTime() >= (50*30+150*30) && getGameTime() <= (50*30+155*30))
	{
		PlayerClass[]@ classes;

		if (this.get("playerclasses", @classes))
		{
			for (uint i = classes.length - 4; i < classes.length; i++)
			{
				PlayerClass @pclass = classes[i];

				CBitStream params;
				write_classchange(params, callerID, pclass.configFilename);

				CGridButton@ button = menu.AddButton(pclass.iconName, getTranslatedString(pclass.name), SpawnCmd::changeClass, Vec2f(CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), params);
				//button.SetHoverText( pclass.description + "\n" );
			}
		}
	}
}

PlayerClass@ getDefaultClass(CBlob@ this)
{
	PlayerClass[]@ classes;

	if (this.get("playerclasses", @classes))
	{
		return classes[0];
	}
	else
	{
		return null;
	}
}
