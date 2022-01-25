// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"
#include "TeamIconToken.as"
#include "CustomBlocks.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, int team_num = 0, const string&in gamemode_override = "")
{
	AddIconToken("$dirt$", "Sprites/world.png", Vec2f(8, 8), 456);
	AddIconToken("$goldblock$", "Sprites/world.png", Vec2f(8, 8), 448);
	AddIconToken("$barbedwire$", "BarbedWire.png", Vec2f(16, 16), 0);

	InitCosts();
	CRules@ rules = getRules();
	string gamemode = rules.gamemode_name;
	
	if (gamemode_override != "")
	{
		gamemode = gamemode_override;
	}
	
	const bool CTF = rules.gamemode_name == "CTF";
	const bool TTH = rules.gamemode_name == "TTH";
	const bool SBX = rules.gamemode_name == "Sandbox";
	
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_fakedirt, "tile_fakedirt", "$dirt$", "Fake dirt\nHide!");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_goldenbrick, "tile_goldenbrick", "$goldblock$", "Cheese block\nCan be mined by cats");
		AddRequirement(b.reqs, "blob", "mat_gold", "Cheese", 25);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "bridge", getTeamIcon("bridge", "Bridge.png", team_num), "Trap Bridge\nOnly your team can stand on it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 45);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "lever", "$lever$", "Fake stone or gold digging\n(toggle to enable!)");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Cheese", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Fake dirt digging\n(toggle to enable!)");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_gold", "Cheese", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Abuse a cat!\n(dont abuse IRL!)");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		AddRequirement(b.reqs, "blob", "mat_gold", "Cheese", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "barbedwire", "$barbedwire$", "Barbed Wire\nHurts anyone who passes through it");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		blocks[0].push_back(b);
	}
	if (CTF)
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", CTFCosts::workshop_wood);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].insertAt(9, b);
	}
	else if (TTH)
	{
		{
			BuildBlock b(0, "factory", "$building$", "Factory\nAn item-producing factory\nRequires migrant");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::factory_wood);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[0].insertAt(9, b);
		}
		{
			BuildBlock b(0, "workbench", "$workbench$", "Workbench\nCreate trampolines, saws, and more");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::workbench_wood);
			b.buildOnGround = true;
			b.size.Set(32, 16);
			blocks[0].push_back(b);
		}
	}
	else if (SBX)
	{
		{
			BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[0].insertAt(9, b);
		}

		BuildBlock[] page_1;
		blocks.push_back(page_1);
		{
			BuildBlock b(0, "wire", "$wire$", "Wire");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "elbow", "$elbow$", "Elbow");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "tee", "$tee$", "Tee");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "junction", "$junction$", "Junction");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "diode", "$diode$", "Diode");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "resistor", "$resistor$", "Resistor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "inverter", "$inverter$", "Inverter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "transistor", "$transistor$", "Transistor");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "toggle", "$toggle$", "Toggle");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
			blocks[1].push_back(b);
		}

		BuildBlock[] page_2;
		blocks.push_back(page_2);
		{
			BuildBlock b(0, "lever", "$lever$", "Lever");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "push_button", "$pushbutton$", "Button");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[2].push_back(b);
		}

		BuildBlock[] page_3;
		blocks.push_back(page_3);
		{
			BuildBlock b(0, "lamp", "$lamp$", "Lamp");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "emitter", "$emitter$", "Emitter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "receiver", "$receiver$", "Receiver");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "magazine", "$magazine$", "Magazine");
			AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 20);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "bolter", "$bolter$", "Bolter");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "spiker", "$spiker$", "Spiker");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
			blocks[3].push_back(b);
		}
	}
}

ConfigFile@ openBlockBindingsConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/BlockBindings.cfg"))
	{
		// write EmoteBinding.cfg to Cache
		cfg.saveFile("BlockBindings.cfg");

	}

	return cfg;
}

u8 read_block(ConfigFile@ cfg, string name, u8 default_value)
{
	u8 read_val = cfg.read_u8(name, default_value);
	return read_val;
}

