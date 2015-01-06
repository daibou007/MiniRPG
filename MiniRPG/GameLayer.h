//
//  GameLayer.h
//  MiniRPG
//
//  Created by Brandon Trebitowski on 1/25/13.
//
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "TouchLayer.h"
#import "HudLayer.h"
#import "EnvironmentLayer.h"
#import "GameSounds.h"
#import "NPCManager.h"
#import "TouchLayer.h"
#import "SimpleAnimObject.h"
#import "Util.h"
#import "config.h"
#import "CCAnimate+SequenceLoader.h"
#import "CCAnimation+SequenceLoader.h"

@interface GameLayer : CCLayerRGBA <TouchLayerDelegate>

@property (nonatomic, strong) CCLayer                   *gameLayer;
@property (nonatomic, strong) TouchLayer                 *touchLayer;
@property (nonatomic, strong) EnvironmentLayer           *envLayer;
@property (nonatomic, strong) HudLayer                   *hudLayer;
@property (nonatomic, strong) CCTMXTiledMap             *tileMap;
@property (nonatomic, strong) SimpleAnimObject          *hero;
@property (nonatomic, strong) CCTMXLayer                *metaLayer;
@property (nonatomic        ) BOOL                      canWalk;
@property (nonatomic        ) float                     tileSize;
@property (nonatomic, strong) CCTMXObjectGroup          *exitGroup;
@property (nonatomic, strong) CCTMXLayer                *npcLayer;
@property (nonatomic, strong) NPCManager                *npcManager;
@property (nonatomic) BOOL controlViewCamera;


+(CCScene *) scene;
-(void)setViewpointCenter:(CGPoint) position;

- (void) setMeta:(NSString *)value forKey:(NSString *)key;
- (NSString *) getMetaValueForKey:(NSString *)key;

@end
