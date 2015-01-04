//
//  GameLayer.m
//  MiniRPG
//
//  Created by Brandon Trebitowski on 1/25/13.
//
//

#import "GameLayer.h"


@interface GameLayer ()

@end


// HelloWorldLayer implementation
@implementation GameLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];

	// add layer as a child to scene
	[scene addChild: layer];

    
    layer.touchLayer = [TouchLayer  node];
    layer.touchLayer.del = layer;
    layer.touchLayer.position = ccp(0, 0);
    [scene addChild:layer.touchLayer];
    
    layer.hudLayer = [HudLayer node];
    layer.hudLayer.position = ccp(0,0);
    [scene addChild:layer.hudLayer];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {

        self.npcManager = [[NPCManager alloc] initWithGameLayer:self];
        // start in the room always
        NSString *filename = [NSString stringWithFormat:kStartingRoom];
        [self loadMapNamed:filename];
        
        //TODO 用脚本按关卡加载地图和对应资源
        // Load character sprite sheet frames into cache for hero
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"character.plist"];
         [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"dpad_buttons.plist"];
        self.hero = [SimpleAnimObject spriteWithSpriteFrameName:@"male_walkcycle_s_01.png"];
        self.hero.position = ccp(32*6,32*2+16);
        
        self.hero.scale = 1;
        self.hero.anchorPoint = ccp(0.5,0.5);
        self.hero.zOrder = 0;
        [self addChild:self.hero z:[[self.tileMap layerNamed:@"floor"] zOrder]];
        
//        self.envLayer = [[[EnvironmentLayer alloc] initWithWeather:2 atTime:1] autorelease];
//        [self addChild:self.envLayer z:10];
//        [self.envLayer setVisible:NO];
        
        self.canWalk = YES;

        [self schedule:@selector(update:)];
	}
	return self;
}

/**
 * Loads a tilemap from the bundle path with a given name.
 *
 */
- (void) loadMapNamed:(NSString *) name
{
    if(self.tileMap)
    {
        [self.tileMap removeAllChildrenWithCleanup:YES];
        [self removeChild:self.tileMap cleanup:YES];
        self.tileMap = nil;
    }
    name = [name stringByAppendingString:@".tmx"];
    self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:name];
    [self.tileMap setScale:kGameScale];
    [self addChild:self.tileMap z:-1];
    self.metaLayer = [self.tileMap layerNamed:@"meta"];
    self.metaLayer.visible = NO;
    self.tileSize = self.tileMap.tileSize.width;

    self.exitGroup = [self.tileMap objectGroupNamed:@"exits"];
    self.npcLayer = [self.tileMap layerNamed:@"npc"];
    [self.npcManager loadNPCsForTileMap:self.tileMap named:name];
}

/**
 * Keeps the viewpoint centered as the hero is walking
 */
- (void)update:(ccTime)dt
{
  
    //We reset the animation if the gunman changes direction
    
    self.hero.velocity = ccp(self.touchLayer.dPad.pressedVector.x*25, self.touchLayer.dPad.pressedVector.y*25);
    
    if (self.hero.velocity.x != 0 || self.hero.velocity.y != 0) {
        
        CGPoint playerPos = [self.hero getNewPosition];
        
        if (playerPos.x <= (self.tileMap.mapSize.width * self.tileMap.tileSize.width) &&
            playerPos.y <= (self.tileMap.mapSize.height * self.tileMap.tileSize.height) &&
            playerPos.y >= 0 &&
            playerPos.x >= 0 ){
            [self setPlayerPosition:playerPos];
            [self setViewpointCenter:self.hero.position];
        }
    }
}

/**
 * Centers the view on our character.  If the character is near the edge
 * of the map, the view won't change.  Only the character will move.
 *
 */
-(void)setViewpointCenter:(CGPoint) position {

    CGSize winSize = [[CCDirector sharedDirector] winSize];

    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (self.tileMap.mapSize.width * self.tileMap.tileSize.width)
            - winSize.width / 2);
    y = MIN(y, (self.tileMap.mapSize.height * self.tileMap.tileSize.height)
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);

    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;

}




/**
 * Moves the player to a given position. Also performs collision detection
 * against the meta layer for tiles with the property "Collidable" set
 * to true.
 *
 * If the player encounters an NPC or an item, they are no permitted to move
 * and the logic is handed off to the NPCManager to execut the related lua
 * script.
 */
-(void)setPlayerPosition:(CGPoint)position {

    if(!self.canWalk) return;

	CGPoint tileCoord = [self tileCoordForPosition:position];

    // Check walls
    int tileGid = [self.metaLayer tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [self.tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"collidable"];
            if (collision && [collision compare:@"true"] == NSOrderedSame) {
                //TODO 原地转向
//                position = self.hero.position;
                return;
            }
        }
    }

    // Check npc
    tileGid = [self.npcLayer tileGIDAt:tileCoord];
    if(tileGid){
        
        
        //NPC转向
        
        CCSprite  *cc =  [self.npcLayer tileAt:tileCoord];
        NSString *dir = [self.npcLayer propertyNamed:@"face"];
        
        if (self.hero.position.x > tileCoord.x * self.tileMap.tileSize.width) {
            //R
            if ([dir isEqualToString:@"LEFT"]) {
                cc.flipX = YES;
                [self.npcLayer.properties setValue:@"RIGHT" forKey:@"face"];
            }
        }else{
            //L
            if ([dir isEqualToString:@"RIGHT"]) {
                cc.flipX = NO;
                 [self.npcLayer.properties setValue:@"LEFT" forKey:@"face"];
            }
        }
       
        
        NSDictionary *properties = [self.tileMap propertiesForGID:tileGid];
        NSString *name = [properties objectForKey:@"name"];
        [self.npcManager interactWithNPCNamed:name];
        return;
    }

    self.canWalk = NO;

    // Animate the player
    id moveAction = [CCMoveTo actionWithDuration:0.4 position:position];
	// Play actions
    
    [self playHeroMoveAnimationFromPosition:self.hero.position toPosition:position];
    [self.hero runAction:[CCSequence actions:moveAction, nil]];
    
}

/**
 * Animates the player from one position to the next
 */
- (void) playHeroMoveAnimationFromPosition:(CGPoint) fromPosition toPosition:(CGPoint) toPosition
{
    if (fromPosition.x != toPosition.x || fromPosition.y != toPosition.y) {
        NSString *direction = @"n";
        if(toPosition.x > fromPosition.x)
            direction = @"e";
        else if(toPosition.x < fromPosition.x)
            direction = @"w";
        else if(toPosition.y < fromPosition.y)
            direction = @"s";

        NSString *walkCycle = [NSString stringWithFormat:@"male_walkcycle_%@_%%02d.png",direction];
        CCActionInterval *action = [CCAnimate actionWithSpriteSequence:walkCycle numFrames:9 delay:.05 restoreOriginalFrame:YES];
        CCAction *doneAction = [CCCallFuncN actionWithTarget:self selector:@selector(heroIsDoneWalking)];
        [self.hero runAction:[CCSequence actions:action,doneAction, nil]];
    }else{
        self.canWalk = YES;
    }
}

/**
 * Called after the hero is done with his walk sequence
 */
- (void) heroIsDoneWalking
{
    self.canWalk = YES;
    // 1
    NSArray *exits = self.exitGroup.objects;
    for(NSDictionary *exit in exits)
    {
        // 2
        CGRect exitRect = CGRectMake([exit[@"x"] floatValue], [exit[@"y"] floatValue],
                                     [exit[@"width"] floatValue], [exit[@"height"] floatValue]);
        // 3
        if(CGRectContainsPoint(exitRect, self.hero.position))
        {
            // 4
            NSString *name = exit[@"destination"];
            CGPoint heroPoint = CGPointMake([exit[@"startx"] floatValue] * self.tileSize + (self.tileSize/2), [exit[@"starty"] floatValue] * self.tileSize + (self.tileSize/2));

            [self resetEffertLayers];
            
            self.hero.position = heroPoint;
            [self loadMapNamed:name];
            [self setViewpointCenter:self.hero.position];

            return;
        }
    }
}

- (void) setMeta:(NSString *)value forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

- (NSString *) getMetaValueForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

/**
 * Given a point on the map, returns the tile coordinate for that point.
 */
- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / (self.tileMap.tileSize.width);
    int y = ((self.tileMap.mapSize.height * self.tileMap.tileSize.height) - position.y) / (self.tileMap.tileSize.height);
    return ccp(x, y);
}

/**
 * Given a tile coordinate, returns the position on screen
 */
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    int x = (tileCoord.x * self.tileMap.tileSize.width) + self.tileMap.tileSize.width;
    int y = (self.tileMap.mapSize.height * self.tileMap.tileSize.height) - (tileCoord.y * self.tileMap.tileSize.height) - self.tileMap.tileSize.height;
    return ccp(x, y);
}



#pragma mark - TouchLayerDelegate<NSObject>

-(void)touchEnded{
    if (self.hudLayer) {
    }
}
-(bool)isChatBoxShow{
    if (self.hudLayer) {
        return [self.hudLayer.chatbox visible];
    }
    return NO;
}



@end
