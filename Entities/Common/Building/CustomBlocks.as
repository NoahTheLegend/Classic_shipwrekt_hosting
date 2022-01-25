
namespace CMap
{
	enum CustomTiles
	{ 
		tile_goldenbrick 	= 448,
		tile_goldenbrick_d0	= 449,
		tile_goldenbrick_d1	= 450,
		tile_goldenbrick_d2	= 451,
		tile_goldenbrick_d3	= 452,
		tile_goldenbrick_d4	= 453,
		tile_goldenbrick_d5	= 454,
		tile_goldenbrick_d6	= 455,
		tile_fakedirt = 456
	};
};

void HandleCustomTile( CMap@ map, int offset, SColor pixel )
{
		//map.AddTileFlag( offset, Tile::BACKGROUND );
		//map.AddTileFlag( offset, Tile::LADDER );
		//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		//map.AddTileFlag( offset, Tile::WATER_PASSES );
		//map.AddTileFlag( offset, Tile::FLAMMABLE );
		//map.AddTileFlag( offset, Tile::PLATFORM );
		//map.AddTileFlag( offset, Tile::LIGHT_SOURCE );

}

bool isTileGolden(TileType tile)
{
	return tile >= CMap::tile_goldenbrick && tile <= CMap::tile_goldenbrick_d6;
}