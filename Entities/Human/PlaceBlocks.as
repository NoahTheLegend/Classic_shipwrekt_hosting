#include "IslandsCommon.as"
#include "AccurateSoundPlay.as"

const f32 rotate_speed = 30.0f;
const f32 max_build_distance = 32.0f;
u16 crewCantPlaceCounter = 0;

void onInit( CBlob@ this )
{
    CBlob@[] blocks;
    this.set("blocks", blocks);
    this.set_f32("blocks_angle", 0.0f);
    this.set_f32("target_angle", 0.0f);

    this.addCommandID("place");
}

void onTick( CBlob@ this )
{
    CBlob@[]@ blocks;
    if (this.get( "blocks", @blocks ) && blocks.size() > 0)
    {
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		Tile tile = map.getTile( pos );
		bool onLand = map.isTileBackgroundNonEmpty( tile ) || map.isTileSolid( tile );
	
        Island@ island = getIsland( this );
		if (island !is null && island.centerBlock !is null)
        {
			Vec2f islandPos = island.centerBlock.getPosition();
            f32 blocks_angle = this.get_f32("blocks_angle");//next step angle
            f32 target_angle = this.get_f32("target_angle");//final angle (after manual rotation)
            Vec2f aimPos = this.getAimPos();
			this.set_Vec2f("aim_pos", aimPos);
			this.Sync("aim_pos", false);
			
			CBlob@ refBlob = getIslandBlob( this );
					
            if (refBlob is null)
			{
				warn("PlaceBlocks: refBlob not found");
                return;
            }

			if ( getNet().isClient() )
				PositionBlocks( @blocks, pos, aimPos, blocks_angle, island.centerBlock, refBlob );

			CPlayer@ player = this.getPlayer();
            if (player !is null && player.isMyPlayer()) 
            {
				//checks for canPlace
				u32 gameTime = getGameTime();
				CRules@ rules = getRules();
				bool skipCoreCheck = gameTime > getRules().get_u16( "warmup_time" ) || ( island.isMothership && ( island.owner == "" ||  island.owner == "*" || island.owner == player.getUsername() ) );
				bool cLinked = false;
                const bool overlappingIsland = blocksOverlappingIsland( @blocks );
				for (uint i = 0; i < blocks.length; ++i)
				{
					if ( overlappingIsland )
					{
						SetDisplay( blocks[i], SColor(255, 255, 0, 0), RenderStyle::additive );
						continue;
					}
					
					if ( skipCoreCheck || blocks[i].hasTag( "coupling" ) || blocks[i].hasTag( "repulsor" ) )
						continue;
						
					if ( !cLinked )
					{
						CBlob@ core = getMothership( this.getTeamNum() );//could get the core properly based on adjacent blocks
						if ( core !is null )
							cLinked = coreLinkedDirectional( blocks[i], gameTime, core.getPosition() );
					}
					
					if ( cLinked )
						SetDisplay( blocks[i], SColor(255, 255, 0, 0), RenderStyle::additive );
				}
				
				//can'tPlace heltips
				bool crewCantPlace = !overlappingIsland && cLinked;
				if ( crewCantPlace )
					crewCantPlaceCounter++;
				else
					crewCantPlaceCounter = 0;

				this.set_bool( "blockPlacementWarn", crewCantPlace && crewCantPlaceCounter > 15 );
				
                // place
                if (this.isKeyJustPressed( key_action1 ) && !getHUD().hasMenus() && !getHUD().hasButtons() )
                {
                    if (target_angle == blocks_angle && !overlappingIsland && !cLinked )
                    {
                        CBitStream params;
                        params.write_netid( island.centerBlock.getNetworkID() );
                        params.write_netid( refBlob.getNetworkID() );
                        params.write_Vec2f( pos - islandPos );
                        params.write_Vec2f( aimPos - islandPos );
                        params.write_f32( target_angle );
                        params.write_f32( island.centerBlock.getAngleDegrees() );
                        this.SendCommand( this.getCommandID("place"), params );
                    }
                    else
                    {
                        this.getSprite().PlaySound("Denied.ogg");
                    }
                }

                // rotate
                if (this.isKeyJustPressed( key_action3 ))
                {
                    target_angle += 90.0f;
                    if (target_angle > 360.0f) {
                        target_angle -= 360.0f;
                        blocks_angle -= 360.0f;
                    }
                    this.set_f32("target_angle", target_angle);
                    this.Sync("target_angle", false);
                }
            }

            blocks_angle += rotate_speed;
            if (blocks_angle > target_angle)
                blocks_angle = target_angle;        
            this.set_f32("blocks_angle", blocks_angle);
        }
        else
        {
            // cant place in water
            for (uint i = 0; i < blocks.length; ++i)
            {
                CBlob @block = blocks[i];
                SetDisplay( block, SColor(255, 255, 0, 0), RenderStyle::light, -10.0f);
            }
        }
    }
}

void PositionBlocks( CBlob@[]@ blocks, Vec2f pos, Vec2f aimPos, const f32 blocks_angle, CBlob@ centerBlock, CBlob@ refBlock )
{
    if ( centerBlock is null )
	{
        warn("PositionBlocks: centerblock not found");
        return;
    }
	
	Vec2f island_pos = centerBlock.getPosition();
    f32 angle = centerBlock.getAngleDegrees();
	f32 refBAngle = refBlock.getAngleDegrees();//reference block angle
	//current island angle as point of reference
	while(refBAngle > angle + 45)	refBAngle -= 90.0f;
	while(refBAngle < angle - 45)	refBAngle += 90.0f;
	
	//get offset (based on the centerblock) of block we're standing on
	Vec2f refBOffset = refBlock.getPosition() - island_pos;
	refBOffset.RotateBy( -refBAngle );
	refBOffset.x = refBOffset.x % 8.0f;
	refBOffset.y = refBOffset.y % 8.0f;
	//not really necessary
	if ( refBOffset.x > 4.0f )	refBOffset.x -= 8.0f;	else if ( refBOffset.x < -4.0f )	refBOffset.x += 8.0f;
	if ( refBOffset.y > 4.0f )	refBOffset.y -= 8.0f;	else if ( refBOffset.y < -4.0f )	refBOffset.y += 8.0f;
	refBOffset.RotateBy( refBAngle );
		
	island_pos += refBOffset;
	Vec2f mouseAim = aimPos - pos;
	f32 mouseDist = Maths::Min( mouseAim.Normalize(), max_build_distance );
	aimPos = pos + mouseAim * mouseDist;//position of the 'buildblock' pointer
	Vec2f islandAim = aimPos - island_pos;//island to 'buildblock' pointer
	islandAim.RotateBy( -refBAngle );		
	islandAim = RelSnapToGrid( islandAim );		
	islandAim.RotateBy( refBAngle );
	Vec2f cursor_pos = island_pos + islandAim;//position of snapped buildblock
	
	//rotate and position blocks
	for (uint i = 0; i < blocks.length; ++i)
	{
		CBlob @block = blocks[i];
		Vec2f offset = block.get_Vec2f( "offset" );
		offset.RotateBy( blocks_angle );                        
		offset.RotateBy( refBAngle );                
  
		block.setPosition( cursor_pos + offset );//align to island grid
		block.setAngleDegrees( ( refBAngle + blocks_angle ) % 360.0f );//set angle: reference angle + rotation angle

		SetDisplay( block, color_white, RenderStyle::additive, 560.0f );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("place"))
    {
        CBlob@ centerBlock = getBlobByNetworkID( params.read_netid() );
        CBlob@ refBlock = getBlobByNetworkID( params.read_netid() );
        if (centerBlock is null || refBlock is null)
        {
            warn("place cmd: centerBlock not found");
            return;
        }

        Vec2f pos_offset = params.read_Vec2f();
        Vec2f aimPos_offset = params.read_Vec2f();
        const f32 target_angle = params.read_f32();
        const f32 island_angle = params.read_f32();

        Island@ island = getIsland( centerBlock.getShape().getVars().customData );
        if (island is null)
        {
            warn("place cmd: island not found");
            return;
        }
		
		Vec2f islandPos = centerBlock.getPosition();
		f32 islandAngle = centerBlock.getAngleDegrees();
		f32 angleDelta = islandAngle - island_angle;//to account for island angle lag
		
		bool blocksPlaced = false;
        CBlob@[]@ blocks;
        if (this.get( "blocks", @blocks ) && blocks.size() > 0)                 
        {	
			PositionBlocks( @blocks, islandPos + pos_offset.RotateBy( angleDelta ), islandPos + aimPos_offset.RotateBy( angleDelta ), target_angle, centerBlock, refBlock );

			if ( true )
			{
				int iColor = centerBlock.getShape().getVars().customData;
				for (uint i = 0; i < blocks.length; ++i)
				{
					CBlob@ b = blocks[i];
					if (b !is null)
					{
						b.set_u16("ownerID", 0);//so it wont add to owner blocks
						f32 z = 510.0f;
						if ( b.getSprite().getFrame() == 0 )	z = 509.0f;//platforms
						else if ( b.hasTag( "weapon" ) )	z = 511.0f;//weaps
						SetDisplay( b, color_white, RenderStyle::normal, z );
						if ( !getNet().isServer() )//add it locally till a sync
						{
							IslandBlock isle_block;
							isle_block.blobID = b.getNetworkID();
							isle_block.offset = b.getPosition() - islandPos;
							isle_block.offset.RotateBy( -islandAngle );
							isle_block.angle_offset = b.getAngleDegrees() - islandAngle;
							b.getShape().getVars().customData = iColor;
							island.blocks.push_back(isle_block);	
						} else
							b.getShape().getVars().customData = 0; // push on island  
						
						b.set_u32( "placedTime", getGameTime() ); 
					}
					else{
						warn("place cmd: blob not found");
					}
				}
				this.set_u32( "placedTime", getGameTime() );
				blocksPlaced = true;
			}
			else
			{
				warn("place cmd: blocks overlapping, cannot place");
				this.getSprite().PlaySound("Denied.ogg");
				return;	
			}
        }
        else
        {
            warn("place cmd: no blocks");
            return;
        }
		
		blocks.clear();//releases the blocks (they are placed)
		getRules().set_bool("dirty islands", true);
		directionalSoundPlay( "build_ladder.ogg", this.getPosition() );
		
		//rebuy last placed blocks, currently disabled
		if ( false )
		{
			CBlob@ core = getMothership( this.getTeamNum() );
			if ( core !is null && !core.hasTag( "critical" ) )
			{
				CBitStream params;
				params.write_u16( this.getNetworkID() );
				params.write_string( this.get_string( "last buy" ) );
				
				core.SendCommand( core.getCommandID("buyBlock"), params );
			}
		}
    }
}

void SetDisplay( CBlob@ blob, SColor color, RenderStyle::Style style, f32 Z=-10000)
{
    CSprite@ sprite = blob.getSprite();
    sprite.asLayer().SetColor( color );
    sprite.asLayer().setRenderStyle( style );
    if (Z>-10000){
        sprite.SetZ(Z);
    }
}