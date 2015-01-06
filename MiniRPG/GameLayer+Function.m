//
//  GameLayer+Function.m
//  MiniRPG
//
//  Created by 杨朋亮 on 4/1/15.
//
//

#import "GameLayer+Function.h"
#import "CCShake.h"
#import "CCNode+FlashingEffect.h"


@implementation GameLayer(Function)




-(void) stopSound{
    [[GameSounds sharedGameSounds] stopBackgroundMusic];
}

-(void) playSound:(NSString *)nameStr{
    [[GameSounds sharedGameSounds] playBackgroundMusic:nameStr];
}

- (void) npc: (NSString *)npc say:(NSString *) text{
    if(self.hudLayer.chatbox)
    {
        [self.hudLayer.chatbox removeAllChildrenWithCleanup:YES];
        [self.hudLayer removeChild:self.hudLayer.chatbox cleanup:YES];
        self.hudLayer.chatbox = nil;
    }
    self.hudLayer.chatbox = [ChatBox node];
    [self.hudLayer addChild:self.hudLayer.chatbox];
    [self.hudLayer.chatbox setWithNPC:(NSString *)npc text:text];
}

-(void)showRaining:(bool)show{
    
    if(self.envLayer){
        [self.envLayer setVisible:YES];
    }
}

-(void)setViewPositionWithX:(NSNumber*)x WithY:(NSNumber*)y{
    NSLog(@"%f",[x doubleValue]);
    self.controlViewCamera = YES;
    [self setViewpointCenter:ccp([x floatValue], [y floatValue])];
}

///
/**
 *  震动
 */
-(void)shake{
    CCShake *shake =[CCShake createWithDuration:10.0 strength:10.0];
    [self runAction:shake];
}

-(void)flash{
    [self flashEffectWithSpeed:10.0f];
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

@end
