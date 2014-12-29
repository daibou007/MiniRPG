//
//  HudLayer.h
//  MiniRPG
//
//  Created by 杨朋亮 on 25/12/14.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ChatBox.h"


@protocol HudLayerDelegate<NSObject>

-(void)showChatBox:(NSString*)npc text:(NSString*)str;
-(bool)isChatBoxShow;

@end

@interface HudLayer : CCLayer

@property (nonatomic, strong) ChatBox          *chatbox;
    


@end
