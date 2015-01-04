//
//  CCNode+FlashingEffect.m
//  CCInvaders
//
//  Created by Stephen Ceresia on 12-06-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNode+FlashingEffect.h"

@implementation CCNode (FlashingEffect)

- (void) flashEffectWithSpeed:(float) s
{
    id tint = [CCTintBy actionWithDuration:s red:255 green:255 blue:0];
    id tint2 = [CCTintBy actionWithDuration:s red:255 green:0 blue:255];
    id tint3 = [CCTintBy actionWithDuration:s red:0 green:255 blue:255];
    
    id seq = [CCSequence actions:
              tint,[tint reverse],
              tint2,[tint2 reverse],
              tint3,[tint3 reverse],
              nil];
    
    id actionPow = [CCRepeatForever actionWithAction:seq];
    [self runAction:actionPow];
}

@end
