//
//  TouchLayer.h
//  MiniRPG
//
//  Created by 杨朋亮 on 23/12/14.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DPad.h"

@protocol TouchLayerDelegate<NSObject>

-(void)touchEnded;
-(bool)isChatBoxShow;

@end


@interface TouchLayer : CCLayer {
    
}

@property (nonatomic,retain) DPad             *dPad;
@property (nonatomic,assign) id<TouchLayerDelegate>   del;

-(id)init;

@end
