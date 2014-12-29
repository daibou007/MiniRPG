//
//  TouchableSprite.m
//  MiniRPG
//
//  Created by 杨朋亮 on 23/12/14.
//
//

#import "TouchableSprite.h"


@implementation TouchableSprite


-(id)init {
    self = [super init];
    if (self != nil) {
        self.pressed = NO;
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}

- (bool)checkTouchWithPoint:(CGPoint)point {
    if(pointIsInRect(point, [self rect])){
        return YES;
    }else{
        return NO;
    }
}

- (CGRect) rect {
    //We set our scale mod to make sprite easier to press.
    //This also lets us press 2 sprites with 1 touch if they are sufficiently close.
    float scaleMod = 1.5f;
    float w = [self contentSize].width * [self scale] * scaleMod;
    float h = [self contentSize].height * [self scale] * scaleMod;
    CGPoint point = CGPointMake([self position].x - (w/2), [self position].y - (h/2));
    
    return CGRectMake(point.x, point.y, w, h);
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    
    //We use circle collision for our buttons
    if(pointIsInCircle(point, self.position, self.rect.size.width/2)){
        self.touchHash = [touch hash];
        [self processTouch:point];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    
    if(pointIsInCircle(point, self.position, self.rect.size.width/2)){
        if(self.touchHash == [touch hash]){		//If we moved on this sprite
            [self processTouch:point];
        }else if(!self.pressed){					//If a new touch moves onto this sprite
            self.touchHash = [touch hash];
            [self processTouch:point];
        }
    }else if(self.touchHash == [touch hash]){	//If we moved off of this sprite
        [self processRelease];
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: [touch view]];
    point = [[CCDirector sharedDirector] convertToGL: point];
    
    if(self.touchHash == [touch hash]){	//If the touch which self.pressed this sprite ended we release
        [self processRelease];
    }
}

- (void)processTouch:(CGPoint)point {
    self.pressed = YES;
}

- (void)processRelease {
    self.pressed = NO;
}

@end
