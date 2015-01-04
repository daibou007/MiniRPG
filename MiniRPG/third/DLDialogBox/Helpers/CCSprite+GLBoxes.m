//
//  CCSprite+GLBoxes.m
//  DLDialogBox
//
//  Created by Draco on 2013-09-01.
//  Copyright (c) 2013 Draco. All rights reserved.
//

#import "CCSprite+GLBoxes.h"

@implementation CCSprite (GLBoxes)

+ (CCSprite *)rectangleOfSize:(CGSize)size
                        color:(ccColor4B)color
{
  // Create the color texture
  GLubyte *buffer = (GLubyte *) malloc(sizeof(GLubyte)*4);
  buffer[0] = color.r;
  buffer[1] = color.g;
  buffer[2] = color.b;
  buffer[3] = color.a;
  CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer
                                           pixelFormat:kCCTexture2DPixelFormat_Default
                                            pixelsWide:1
                                            pixelsHigh:1
                                           contentSize:size];
  free(buffer);
  
  // Create and return the sprite
  CCSprite *sprite = [CCSprite node];
  [sprite setTexture:tex];
  [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
  
  return sprite;
}

@end
