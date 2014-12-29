//
//  GameLayer.m
//  MiniRPG
//
//  Created by Brandon Trebitowski on 1/25/13.
//
//

#import "GameLayer.h"
#import "NPCManager.h"
#import "TouchLayer.h"

#import "SimpleAnimObject.h"
#import "Util.h"
#import "CCAnimatedTMXTiledMap.h"


// Import the interfaces
#import "config.h"

#import "CCAnimate+SequenceLoader.h"
#import "CCAnimation+SequenceLoader.h"

#import "GameSounds.h"

@interface GameLayer ()
@property (nonatomic,strong) TouchLayer        *touchLayer;
@property (nonatomic,strong) HudLayer          *hudLayer;
@property (nonatomic, strong) CCTMXTiledMap    *tileMap;
@property (nonatomic, strong) SimpleAnimObject *hero;
@property (nonatomic, strong) CCTMXLayer       *metaLayer;
@property (nonatomic        ) BOOL             canWalk;
@property (nonatomic        ) float            tileSize;
@property (nonatomic, strong) CCTMXObjectGroup *exitGroup;
@property (nonatomic, strong) CCTMXLayer       *npcLayer;
@property (nonatomic, strong) NPCManager       *npcManager;

@property (nonatomic, strong) 	CCAnimatedTMXTiledMap	*animator;
@property (nonatomic        ) int              gunmanDirection;

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
        self.hero.position = ccp(32*11,64+16);
        self.hero.scale = 1;
        self.hero.anchorPoint = ccp(0.5,0.5);
        self.hero.zOrder = 0;
        [self addChild:self.hero z:[[self.tileMap layerNamed:@"floor"] zOrder]];
        
        self.gunmanDirection = DPAD_DOWN;
        
        
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
    self.tileMap.anchorPoint = ccp(0,0);
    [self.tileMap setScale:kGameScale];
    [self addChild:self.tileMap z:-1];
    self.metaLayer = [self.tileMap layerNamed:@"meta"];
    self.metaLayer.visible = NO;
    self.tileSize = self.tileMap.tileSize.width;

    self.exitGroup = [self.tileMap objectGroupNamed:@"exits"];
    self.npcLayer = [self.tileMap layerNamed:@"npc"];
    [self.npcManager loadNPCsForTileMap:self.tileMap named:name];
    

    self.animator = [CCAnimatedTMXTiledMap fromTMXTiledMap: self.tileMap];

    
}

/**
 * Keeps the viewpoint centered as the hero is walking
 */
- (void)update:(ccTime)dt
{
    [self setViewpointCenter:self.hero.position];
    
   	bool resetAnimation = NO;
    //We reset the animation if the gunman changes direction
    if(self.touchLayer.dPad.direction != DPAD_NO_DIRECTION){
        if(self.gunmanDirection != self.touchLayer.dPad.direction){
            resetAnimation = YES;
            self.gunmanDirection = self.touchLayer.dPad.direction;
        }
    }
    if(self.hero.velocity.x != self.touchLayer.dPad.pressedVector.x*30 || self.hero.velocity.y != self.touchLayer.dPad.pressedVector.y*30){
        self.hero.velocity = ccp(self.touchLayer.dPad.pressedVector.x*30, self.touchLayer.dPad.pressedVector.y*30);
        resetAnimation = YES;
    }
    
    
    CGPoint playerPos = [self.hero getNewPosition];
    
    if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
        playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
        playerPos.y >= 0 &&
        playerPos.x >= 0 )
    {
        [self setPlayerPosition:playerPos];
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
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width)
            - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height)
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);

    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;

}

-(void) playSound:(NSString *)nameStr{
    
    [[GameSounds sharedGameSounds] playBackgroundMusic:nameStr];
    
}

- (void) npc: (NSString *)npc say:(NSString *) text{
    if (self.hudLayer && ![self.hudLayer.chatbox visible]) {
        self.hudLayer.chatbox = [ChatBox node];
        [self.hudLayer addChild:self.hudLayer.chatbox];
        [self.hudLayer.chatbox setWithNPC:(NSString *)npc text:text];
        [self.hudLayer.chatbox advanceTextOrHide];
    }
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
        
        if (self.hero.position.x > tileCoord.x * _tileMap.tileSize.width) {
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

            self.hero.position = heroPoint;
            [self loadMapNamed:name];
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
    int x = position.x / (_tileMap.tileSize.width);
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / (_tileMap.tileSize.height);
    return ccp(x, y);
}

/**
 * Given a tile coordinate, returns the position on screen
 */
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    int x = (tileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tileCoord.y * _tileMap.tileSize.height) - _tileMap.tileSize.height;
    return ccp(x, y);
}

#pragma mark - TouchLayerDelegate<NSObject>

-(void)touchEnded{
    if (self.hudLayer) {
       [self.hudLayer.chatbox advanceTextOrHide];
    }
}
-(bool)isChatBoxShow{
    if (self.hudLayer) {
        return [self.hudLayer.chatbox visible];
    }
    return NO;
}



@end
