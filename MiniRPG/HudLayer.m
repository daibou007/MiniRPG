//
//  HudLayer.m
//  MiniRPG
//
//  Created by 杨朋亮 on 25/12/14.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "HudLayer.h"


@implementation HudLayer

-(id)init{
    
    if( (self=[super init]) ) {
        self.chatbox = [ChatBox node];
        [self addChild:self.chatbox];
    }
    
    return self;
}

@end
