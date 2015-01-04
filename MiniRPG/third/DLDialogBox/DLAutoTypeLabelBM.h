//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kTypingSpeedSuperMegaFast 550
#define kTypingSpeedSuperFast     220
#define kTypingSpeedFast          120
#define kTypingSpeedNormal        60
#define kTypingSpeedSlow          35

@class DLAutoTypeLabelBM;

/**
 * Delegate for a DLAutoTypeLabelBM.
 */
@protocol DLAutoTypeLabelBMDelegate
@optional

/**
 * Called when typing animation for the string is finished.
 *
 * @param sender  The typeLabel that just finished.
 */
- (void)autoTypeLabelBMTypingFinished:(DLAutoTypeLabelBM *)sender;

/**
 * Called whenever a single or block of characters are typed.
 *
 * When the typing speed is slow, this method will be called for every character
 * typed. However they the typing speed is really fast, we actually type
 * multiple characters per typing interval. Thus in this case this method
 * is called for every character block typed.
 *
 * @param sender  The `DLAutoTypeLabelBM`.
 */
- (void)autoTypeLabelBMCharacterBlockTyped:(DLAutoTypeLabelBM *)sender;

@end

/**
 * Strings displayed with this class will be animated as if its being typed.
 */
@interface DLAutoTypeLabelBM : CCLabelTTF
@property (nonatomic, weak) NSObject<DLAutoTypeLabelBMDelegate> *delegate;


/**
 * Typing speed in terms of characters to be typed per second.
 *
 * Since typingSpeed is evaluated after every typed character, changing this
 * while the label is being typed will speed up or slow down the current typing speed.
 *
 * You can use our provided speed constants for differents speeds:
 * - `kTypingSpeedSuperMegaFast`
 * - `kTypingSpeedSuperFast`
 * - `kTypingSpeedFast`
 * - `kTypingSpeedNormal`
 * - `kTypingSpeedSlow`
 */
@property (nonatomic) CGFloat typingSpeed;

/**
 * The string this label is about to type.
 */
@property (nonatomic, copy) NSString *autoTypeString;

/**
 * Returns YES if text is currently being typed.
 */
@property (nonatomic, readonly) BOOL currentlyTyping;

/**
 * When called the current typing animation will stop and the label will display
 * whatever has been typed so far. This will not trigger typing finished delegate method.
 */
- (void)stopTypingAnimation;

/**
 * When called, the current typing animation will stop and the label will display
 * the full text that is meant to be typed immediately.
 *
 * If <currentlyTyping> is set to NO then this method would not inform the
 * delegate that the typing is finished but will make sure that the displayed text
 * is the final text to display.
 */
- (void)finishTypingAnimation;

/**
 * Type in some text with the specified typing speed.
 *
 * @see typingSpeed
 * @param txt   The text to type.
 * @param speed The typing speed to type the text
 */
- (void)typeText:(NSString*)txt typingSpeed:(CGFloat)speed;

@end
