
#import "SimpleAnimObject.h"

@implementation SimpleAnimObject
@synthesize animationType,velocity;
-(void) update: (ccTime) t {	
	self.position = ccp(self.position.x + velocity.x, self.position.y + velocity.y);
}

-(CGPoint)getNewPosition{
    return ccp(self.position.x + velocity.x, self.position.y + velocity.y);
}

- (CGRect) rect {
	float scaleMod = 0.5f;
	float w = [self contentSize].width * [self scale] * scaleMod;
	float h = [self contentSize].height * [self scale] * scaleMod;
	CGPoint point = CGPointMake([self position].x - (w/2), [self position].y - (h/2));
	return CGRectMake(point.x, point.y, w, h); 
}
@end