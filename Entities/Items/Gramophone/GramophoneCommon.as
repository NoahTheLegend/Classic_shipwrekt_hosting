
class GramophoneRecord
{
	string name;
	string filename;

	GramophoneRecord(string name, string filename)
	{
		this.name = name;
		this.filename = filename;
	}
};

const GramophoneRecord@[] records =
{
	GramophoneRecord("Mountain King", "Disc_MountainKing.ogg"),
	GramophoneRecord("Drunken Sailor", "Disc_DrunkenSailor.ogg"),
	GramophoneRecord("Odd Couple", "Disc_OddCouple.ogg"),
	GramophoneRecord("Bandit Radio", "Disc_Bandit.ogg"),
	GramophoneRecord("Keep on Running", "Disc_KeepOnRunning.ogg"),
	GramophoneRecord("Fortunate Son", "Disc_FortunateSon.ogg"),
	GramophoneRecord("Divide", "HM2Divide.ogg"),
	GramophoneRecord("Bloodline", "HM2Bloodline.ogg"),
	GramophoneRecord("Future Club", "HM2FutureClub.ogg"),
	GramophoneRecord("NARC", "HM2NARC.ogg"),
	GramophoneRecord("Acid Spit", "HM2AcidSpit.ogg"),
	GramophoneRecord("Roller Mobster", "HM2RollerMobster.ogg"),
	GramophoneRecord("Blizzard", "HM2Blizzard.ogg"),
	GramophoneRecord("Score Screen", "HM2ScoreScreen.ogg"),
};