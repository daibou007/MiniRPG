//
//  TouchLayer.m
//  MiniRPG
//
//  Created by 杨朋亮 on 23/12/14.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "TouchLayer.h"
#import "cocos2d.h"

@implementation TouchLayer


-(id)init{
    self = [super init];
    if (self) {
        self.isTouchEnabled = YES;
        
        self.dPad = [[DPad alloc] init];
        
        self.dPad.position = ccp(50,50);
        
        [self addChild:self.dPad];
    }
    return self;
}


/* Process touches */
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    
    [self.dPad ccTouchesBegan:touches withEvent:event];
}
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    
    [self.dPad ccTouchesMoved:touches withEvent:event];
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.del){
        if ([self.del isChatBoxShow]) {
            [self.del touchEnded];
            return;
        }
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    
    [self.dPad ccTouchesEnded:touches withEvent:event];
}

-(void)dealloc{
    [super dealloc];
}

@end
