
class Digging
{
	string filename;

	Digging(string filename)
	{
		this.filename = filename;
	}
};

const Digging@[] digStoneGold =
{
	Digging("dig_stone1.ogg"),
	Digging("dig_stone2.ogg"),
	Digging("dig_stone3.ogg"),
	Digging("destroy_stone.ogg"),
	Digging("destroy_gold.ogg"),
};
const Digging@[] digDirt = 
{
	Digging("dig_dirt1.ogg"),
	Digging("dig_dirt2.ogg"),
	Digging("dig_dirt3.ogg"),
	Digging("destroy_dirt.ogg"),
};