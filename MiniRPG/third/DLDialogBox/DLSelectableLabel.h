//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kSelectableLabelTouchPriority -501

/**
 * A DLSelectableLabelCustomizer is used to determine the __look__, __functionalities__,
 * and the __animations__ related to a <DLSelectableLabel>.
 *
 * Every <DLSelectableLabel> must use a dialog customizer. If no customizers are given the
 * dialog box will automatically use the default customizer provided through
 * <defaultCustomizer>.
 */
@interface DLSelectableLabelCustomizer : NSObject <NSCopying>


/// @name Customizing look/UI

/**
 * The alignment of the text in the label.
 *
 * __Defaults to kCCTextAlignmentLeft__
 *
 * @bug kCCTextAlignmentCenter currently does not work
 */
@property (nonatomic) CCTextAlignment textAlignment;

/**
 * Specifies the background color of the label in normal state.
 *
 * __Defaults to transparent__
 */
@property (nonatomic) ccColor4B backgroundColor;

/**
 * Specifies the background color of the label in its preselected state.
 *
 * __Defaults to ccc4(200, 0, 0, 0.70*255)__
 */
@property (nonatomic) ccColor4B preSelectedBackgroundColor;

/**
 * Specifies the background color of the label in its selected state.
 *
 * __Defaults to transparent__
 */
@property (nonatomic) ccColor4B selectedBackgroundColor;

/**
 * Insets of the label's text.
 *
 * The larger the insets the more spacing there are between the label's string
 * and the label itself.
 *
 * __Defaults to (5, 10, 5, 10)__
 */
@property (nonatomic) UIEdgeInsets textInsets;


/// @name Customizing functionalities

/**
 * If enabled this label will automatically be deselected if tapped outside.
 *
 * __Defaults to NO__
 */
@property (nonatomic) BOOL deselectOnOutsideTap;

/**
 * When set to YES, tapping the label the first time will result in the label
 * being preselected.
 *
 * When preselect the delegate will be notified and the label's background
 * will change to the preselected background.
 *
 * Enable preselect may result in a better user experience since it's easy
 * for the user to accidentally tap on an unwanted label.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL preselectEnabled;

/**
 * The sound file to play when the label is preselected.
 */
@property (nonatomic, copy) NSString *preselectSoundFileName;

/**
 * The sound file to play when the label is selected.
 */
@property (nonatomic, copy) NSString *selectedSoundFileName;

/**
 * Returns the default customizer used by the DLSelectableLabel.
 */
+ (DLSelectableLabelCustomizer *)defaultCustomizer;

@end

@class DLSelectableLabel;

/**
 * Delegate for the DLSelectableLabel.
 */
@protocol DLSelectableLabelDelegate <NSObject>
@optional

/**
 * Called when the label is preselected
 *
 * @param sender    The DLSelectableLabel that is preselected
 */
- (void)selectableLabelPreselected:(DLSelectableLabel *)sender;

/**
 * Called when the label is selected
 *
 * @param sender    The DLSelectableLabel that is selected
 */
- (void)selectableLabelSelected:(DLSelectableLabel *)sender;
@end

/**
 * DLSelectableLabel is essentialy a button with support for being preselected.
 *
 * A <DLSelectableLabelCustomizer> is used to customize the label.
 *
 * @see DLSelectableLabelCustomizer
 */
@interface DLSelectableLabel : CCNode <CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLSelectableLabelDelegate> delegate;

/**
 * This is used to display the text through the use of a font file
 */
@property (nonatomic, strong) CCLabelBMFont *text;

/**
 * Background sprite for the label.
 */
@property (nonatomic, strong) CCSprite *bgSprite;

/**
 * Returns YES if the label is currently preselected.
 */
@property (nonatomic) BOOL preselected;

/**
 * Returns YES if the label is currently selected.
 */
@property (nonatomic) BOOL selected;

/**
 * This customizer is used to customize the UI and functionalities of the label.
 */
@property (nonatomic, strong) DLSelectableLabelCustomizer *customizer;

/**
 * @param text        Text for the label
 * @param fntFile     Font file to use for the label
 * @param customizer  A DLSelectableLabelCustomizer to custom the label
 */
- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile
         cutomizer:(DLSelectableLabelCustomizer *)customizer;

+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile;
+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile
          cutomizer:(DLSelectableLabelCustomizer *)customizer;

/**
 * Selects the current label. If preselect is enabled, this preselects the label
 * if not already preselected.
 *
 * __Note:__ Calling `select` when already selected will not inform the delegate.
 */
- (void)select;

/**
 * Selects the label. If preselect is enabled, this bypasses the preselect and just
 * selects the label directly.
 */
- (void)selectWithoutPreselect;

/**
 * Deselect reverts the label to the default state. Not selected or preselected.
 */
- (void)deselect;

/**
 * Set the width of the label manually.
 *
 * When not set manually, the width of the label equals to the width of the 
 * label text plus `2*[self.customizer.stringOffset.x]`
 *
 * @param width     New width of the label.
 */
- (void)setWidth:(CGFloat)width;

/**
 * Fade this label in with duration.
 *
 * @param duration    Duration of the fade
 */
- (void)fadeInWithDuration:(ccTime)duration;

/**
 * Fade this label out with duration.
 *
 * @param duration    Duration of the fade
 */
- (void)fadeOutWithDuration:(ccTime)duration;

@end