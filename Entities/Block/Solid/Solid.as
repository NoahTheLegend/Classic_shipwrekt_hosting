
void onInit(CBlob@ this)
{
	this.Tag("hull");
    this.Tag("solid");
	
	this.set_u16("cost", 20);
	this.set_f32("weight", 0.5f);
}
