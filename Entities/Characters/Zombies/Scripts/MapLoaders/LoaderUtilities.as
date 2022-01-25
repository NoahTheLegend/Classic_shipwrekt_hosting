// LoaderUtilities.as

#include "CustomBlocks.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{
			//GOLDEN BRICK
			case CMap::tile_goldenbrick:   {OnGoldTileHit(map, index); return CMap::tile_goldenbrick_d0;}		
			case CMap::tile_goldenbrick_d0:
			case CMap::tile_goldenbrick_d1:
			case CMap::tile_goldenbrick_d2:
			case CMap::tile_goldenbrick_d3:
			case CMap::tile_goldenbrick_d4: {OnGoldTileHit(map, index); return oldTileType + 1;}	
			case CMap::tile_goldenbrick_d5: {OnGoldTileDestroyed(map, index); return CMap::tile_empty;}
			case CMap::tile_fakedirt: {OnFakeTileDestroyed(map, index); return CMap::tile_empty;}
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if (map.getTile(index).type > 255) //custom solids
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			// golden brick
			case CMap::tile_goldenbrick:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 0.6f);
				break;
			}
			case CMap::tile_goldenbrick_d0:
			case CMap::tile_goldenbrick_d1:
			case CMap::tile_goldenbrick_d2:
			case CMap::tile_goldenbrick_d3:
			case CMap::tile_goldenbrick_d4:
			case CMap::tile_goldenbrick_d5:
			case CMap::tile_goldenbrick_d6:
			{
				OnGoldTileHit(map, index);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			}

			case CMap::tile_fakedirt:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES);
				break;
			}
		}
	}
}

void OnGoldTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND );
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("goldsack_take.ogg", pos, 0.5f, 0.5f+(XORRandom(10)*0.002));
	}
}

void OnGoldTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("goldsack_take.ogg", pos, 0.5f, 0.5f+(XORRandom(10)*0.002));
	}
}

void OnFakeTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("dig_dirt1.ogg", pos, 0.5f, 0.5f+(XORRandom(10)*0.002));
	}
}