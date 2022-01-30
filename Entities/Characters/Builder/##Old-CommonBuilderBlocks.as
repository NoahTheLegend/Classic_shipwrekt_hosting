#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]&, int)
{
	InitCosts();
	CRules@ rules = getRules();

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		blocks[0].push_back(b);
	}	
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}		
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
}