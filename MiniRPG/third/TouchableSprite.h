#import "cocos2d.h"


@interface TouchableSprite : CCSprite
{
	@public
		bool pressed;			//Is this sprite pressed
		NSUInteger touchHash;	//Used to identify individual touches
}

@property (readwrite, assign) bool pressed;
@property (readwrite, assign) NSUInteger touchHash;

- (id)init;
- (bool)checkTouchWithPoint:(CGPoint)point;
- (CGRect)rect;
- (void)processTouch:(CGPoint)point;
- (void)processRelease;
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

