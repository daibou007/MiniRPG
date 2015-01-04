//
//  CCSprite+GLBoxes.h
//  DLDialogBox
//
//  Created by Draco on 2013-09-01.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "CCSprite.h"

@interface CCSprite (GLBoxes)

/**
 * Create a sprite with a solid color.
 */
+ (CCSprite *)rectangleOfSize:(CGSize)size
                        color:(ccColor4B)color;

@end
