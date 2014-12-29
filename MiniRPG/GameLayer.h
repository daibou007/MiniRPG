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


@interface GameLayer : CCLayer <TouchLayerDelegate>



+(CCScene *) scene;

@end
