
void onInit(CBlob@ this)
{
	this.Tag("ram");
    this.Tag("solid");
	
	this.set_u16("cost", 35);
	this.set_f32("weight", 2.0f);
}
