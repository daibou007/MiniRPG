//SimpleAnimObject
#import "cocos2d.h"

@interface SimpleAnimObject : CCSprite {
	int animationType;
	CGPoint velocity;
}
@property (readwrite, assign) int animationType;
@property (readwrite, assign) CGPoint velocity;
-(void) update: (ccTime) t;
-(CGRect) rect;
-(CGPoint)getNewPosition;
@end

