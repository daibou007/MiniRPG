//
//  CCAnimatedTMXTiledMap.m
//
//  Created by Adam Griffiths on 6/03/12.
//  Copyright (c) 2012 Twisted Pair Development. All rights reserved.
//
//  twistedpairdevelopment.wordpress.com
//  @twistedpairdev
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCAnimatedTMXTiledMap.h"

// ---------------------------------------------

@interface CCAnimatedTMXTiledMap (PrivateMethods)
-(BOOL) animationEnabledForGID: (unsigned int)gid;
-(unsigned int) nextAnimationForGID: (unsigned int)gid;

-(void) animateTiles: (ccTime)dt;
-(void) animateTilesForLayer: (NSString*)layer delta:(ccTime)dt;

-(ccTime) getAnimationDelay;
-(NSDictionary*) getAnimatedMapTiles;
-(NSArray*) getAnimatedTilesForLayer: (CCTMXLayer*)layer;
@end

// ---------------------------------------------

@implementation CCAnimatedTMXTiledMap


+(id) fromTMXTiledMap: (CCTMXTiledMap*)map
{
	return [ [self alloc] initWithMap: map];
}

// ---------------------------------------------

-(id) initWithMap: (CCTMXTiledMap*) map
{
	self = [super init];
	if ( self != nil )
	{
		self.map = map;
		
		// process our tile set meta data
		// and find any animated tiles.
		// we will store this info efficient processing
		// at runtime.
		self.animated_tiles = [self getAnimatedMapTiles];
		
		ccTime interval = [self getAnimationDelay];

		// add a callback to handle animating the sprites
        
		[ [CCScheduler sharedScheduler]
		 	scheduleSelector: @selector(animateTiles:)
		 	forTarget: self
		 	interval: interval
		 	paused: NO
		 	];
	}
	return self;
}

// ---------------------------------------------

-(BOOL) animationEnabledForGID: (unsigned int)gid
{
	// get the property set for the GID if one exists
	// if there is one, check if the 'animate_enable' value
	// is set to 'YES'
	NSDictionary *properties = [self.map propertiesForGID: gid ];
	if ( properties != nil )
	{
		// get the 'animate_enable' value
		if ( [ [properties objectForKey: @"animate_enable"] isEqualToString: @"YES" ] )
		{
			return YES;
		}
	}
	return NO;
}

// ---------------------------------------------

-(unsigned int) nextAnimationForGID: (unsigned int)gid
{
	// get the property set for the GID if one exists
	// if there is one, check if the 'animate_enable' value
	// is set to 'YES'
	NSDictionary *properties = [self.map propertiesForGID: gid ];
	if ( properties != nil )
	{
		// get the 'animate_next_tile' value
		
        NSString *str = [properties objectForKey: @"animate_next_tile"];
        if ( str != nil )
        {
            NSNumber *next_tile = [NSNumber numberWithFloat:[str intValue]];
		
			return [next_tile intValue];
		}
	}
	
	// no properties
	// so return the current value
	return gid;
}

// ---------------------------------------------

-(ccTime) getAnimationDelay
{
    NSString *str = [self.map.properties objectForKey: @"animate_delay"];
	if ( str != nil )
	{
        NSNumber *animation_delay = [NSNumber numberWithFloat:[str floatValue]];
		return [animation_delay floatValue];
	}
	
	NSLog( @"No 'animate_delay' property set on map" );
	
	// return 30fps
	return 0.032f;
}

// ---------------------------------------------

-(NSDictionary*) getAnimatedMapTiles
{
	// store our layers with animations in a dictionary
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// iterate through our layers in order to find
	// any tiles that have animations
	for ( CCTMXLayer* layer in [self.map children] )
	{
		if ( [layer isKindOfClass:[CCTMXLayer class]] )
		{
			// find any animated tiles for this layer
			// if there are no animations, the return value
			// will be nil
			// otherwise it will be an NSArray of NSValues
			// which were originally CGPoint
			NSArray *coords = [self getAnimatedTilesForLayer: layer];
		
			// don't continue if there are no animations
			if ( coords == nil )
			{
				continue;
			}

			// add the array to our dictionary
			// the layer name shall be the key
			[dict setObject: coords forKey: layer.layerName];
		}
	}
	
	// convert to a non-mutable dictionary
	return [NSDictionary dictionaryWithDictionary: dict];
}

// ---------------------------------------------

-(NSArray*) getAnimatedTilesForLayer: (CCTMXLayer*)layer
{
	// we will store x,y coordinates for each animated
	// tile in this array
	NSMutableArray *coords = [NSMutableArray array];
	
	// iterate through the tiles of our layer
	CGSize size = [layer layerSize];
	for( int x = 0; x < size.width; ++x)
	{
		for( int y = 0; y < size.height; ++y )
		{
			// see if the tile has a GID of a tile with
			// animations enabled
			CGPoint point = ccp( x, y );
			unsigned int gid = [layer tileGIDAt: point];
			if ( [self animationEnabledForGID: gid] == YES )
			{
				// animation is enabled
				NSLog( @"[%@]:%d,%d is animated", layer.layerName, x, y );
				
				// convert the CGPoint to an NSValue
				// and add to our array
				[coords addObject: [NSValue valueWithCGPoint: point]];
			}
		}
	}
	
	// check if we found any coordinates
	if ( [coords count] == 0 )
	{
		// no coordinates
		NSLog( @"[%@]: No animations", layer.layerName );
		return nil;
	}
	
	// we have some animations
	// convert from NSMutableArray to NSArray
	return [NSArray arrayWithArray: coords];
}

// ---------------------------------------------

-(void) animateTiles: (ccTime)dt
{
	// iterate through the layers in our animation dictionary
	for ( NSString *layer in [self.animated_tiles allKeys] )
	{
		// animate the tiles for this layer
		[self animateTilesForLayer: layer delta: dt];
	}
}

// ---------------------------------------------

-(void) animateTilesForLayer: (NSString*)layerName delta:(ccTime)dt
{
	// get the array of animated values for our layer
	NSArray* coords = [self.animated_tiles objectForKey: layerName];
	
	// get the layer object
	CCTMXLayer *layer = [self.map layerNamed: layerName];

	// iterate through each tile for the layer	
	for ( NSValue *val in coords )
	{
		// convert from NSValue back to CGPoint
		CGPoint point = [val CGPointValue];
		
		// get the current GID for the tile
		uint32_t gid = [layer tileGIDAt: point];
		
		// get the next GID
		gid = [self nextAnimationForGID: gid];
		
		// set the tile to the next GID
		[layer setTileGID: gid at: point];
	}
}

// ---------------------------------------------

@end

// ---------------------------------------------
