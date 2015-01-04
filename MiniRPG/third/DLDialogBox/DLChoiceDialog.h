//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSelectableLabel.h"
#import "cocos2d.h"

// A block type that will be used for custom animations
typedef void(^DLAnimationBlock)(id);

// This must be small enough so we can swallow most of other touch handlers
#define kChoiceDialogTouchPriority -500

/**
 * A DLChoiceDialogCustomizer is used to determine the __look__, __functionalities__,
 * and the __animations__ related to a <DLChoiceDialog>.
 *
 * Every <DLChoiceDialog> must use a dialog customizer. If no customizers are given the
 * dialog box will automatically use the default customizer provided through
 * <defaultCustomizer>.
 *
 * The reason a customizer class is used to store how a dialog box should look,
 * function and animate is because this way you can reuse a single customizer
 * instance on all the DLChoiceDialogs in your game to achieve a consistent look
 * and behaviour.
 */
@interface DLChoiceDialogCustomizer : NSObject <NSCopying>


/// @name Customizing look/UI

/**
 * The position of the choice dialog.
 *
 * The <DLChoiceDialog> will use this position when configured with a customizer.
 * However you can set the choice dialog's position manually to override this position.
 *
 * __Defaults to (0, 0)__
 */
@property (nonatomic) CGPoint dialogPosition;

/**
 * The anchor point of the choice dialog.
 *
 * The <DLChoiceDialog> will use this anchor point when configured with a customizer.
 *
 * __Defaults to (0, 0)__
 */
@property (nonatomic) CGPoint dialogAnchorPoint;

/**
 * The file name of a stretchable sprite image that will be used as
 * the background image for the dialog box.
 *
 * If the `backgroundSpriteFrameName` is also provided, then this value will be ignored.
 *
 * Please refer to the usage documentation on how the sprite image should be made.
 */
@property (nonatomic, copy) NSString *backgroundSpriteFile;

/**
 * The sprite frame name of a stretchable sprite image that will be used as
 * the background image for the dialog box.
 *
 * If a `backgroundSpriteFile` is also provided, then only this value will be used.
 *
 * Please refer to usage documentation on how the sprite image should be made.
 */
@property (nonatomic, copy) NSString *backgroundSpriteFrameName;

/**
 * If a sprite is not provided as the dialog's background, this property will be
 * used as the background color of the dialog box.
 *
 * You can create a `ccColor4B` via `ccc4(red, blue, green, alpha)`.
 * Note that all color values are from 0-255.
 *
 * __Defaults to a semi-transparent black color (`ccc4(0,0,0,0.8*255)`).__
 */
@property (nonatomic) ccColor4B backgroundColor;

/**
 * The font file used by the dialog for displaying text.
 *
 * __Defaults to the demo fnt file (`demo_fnt.fnt`) attached with the project__
 */
@property (nonatomic, copy) NSString *fntFile;

/**
 * This sets the insets of the choice dialog's choice content.
 *
 * The size of the choice dialog will adjust accordingly to accommodate both the
 * choice content and its insets.
 *
 * __Defaults to (5, 5, 5, 5)__
 */
@property (nonatomic) UIEdgeInsets contentInsets;

/**
 * The vertical margin between the choice labels.
 *
 * Setting this to a positive value will result in more spacing
 * between choice labels.
 *
 * __Defaults to 5.0__
 */
@property (nonatomic) CGFloat spacingBetweenChoices;

/**
 * The <DLSelectableLabelCustomizer> for customizing the labels inside the choice dialog.
 *
 * __Defaults to the default DLSelectableLabelCustomizer__
 *
 * @see [DLSelectableLabelCustomizer defaultCustomizer]
 */
@property (nonatomic, strong) DLSelectableLabelCustomizer *labelCustomizer;


/// @name Customizing functionalities

/**
 * If enabled, selecting a choice in a choice dialog will first preselect
 * the choice. The choice will only be selected if selected after being preselected.
 *
 * Enabling this will result in less errors when the player is selecting a choice.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL preselectEnabled;

/**
 * If enabled, the choice dialog will swallow all touches. This can essentially
 * disable all touch inputs aside from this dialog.
 *
 * Enabling this is an easy way to disable all other user inputs when selecting a choice.
 * However it is likely that you still want your player to tap on things like the
 * menu button etc, thus `swallowAllTouches` is set to NO by default so that you
 * can disable user inputs manually.
 *
 * Please note that once a DLChoiceDialog has been created, changing this value
 * will not change the behaviour of the DLChoiceDialog since this property, unlike
 * the other fuctionality related properties, is evaluated only when the
 * DLChoiceDialog is first displayed.
 *
 * __Note:__ If something has a higher touch priority than 
 * kChoiceDialogTouchPriority, then that receiver will receive touch
 * events even with `swallowAllTouches` set to YES. However 
 * kChoiceDialogTouchPriority is currently set to a such low value that
 * this choice dialog should have the highest touch priority (even higher than
 * a DLDialogBox).
 *
 * __Defaults to NO__
 */
@property (nonatomic) BOOL swallowAllTouches;

/**
 * Close the choice dialog when a choice is selected
 *
 * If enabled, the choice dialog will be removed when a choice is selected.
 * However if a <hideAnimation> is specified, the hideAnimation will be called
 * instead. The hideAnmation block should then be responsible for removing the
 * choice dialog.
 *
 * __Defaults to YES__
 *
 * @see [DLChoiceDialog playHideAnimationOrRemoveFromParent]
 */
@property (nonatomic) BOOL closeWhenChoiceSelected;

/**
 * The sound file to play when the label is preselected.
 */
@property (nonatomic, copy) NSString *preselectSoundFileName;

/**
 * The sound file to play when the label is selected.
 */
@property (nonatomic, copy) NSString *selectedSoundFileName;


/// @name Custom Animations

/**
 * A block that is run during the onEnter method to display the dialog.
 *
 * You should use this to make custom show animations.
 *
 * This animation block will be run automatically after the dialog box is
 * added to a parent.
 */
@property (nonatomic, copy) DLAnimationBlock showAnimation;

/**
 * A block that is run when closing the dialog.
 *
 * You should use this to make custom hide animations.
 *
 * This animation block is automatically run when a choice is selected if 
 * <closeWhenChoiceSelected> is set to YES.
 *
 * Or you can run this animation block manually by calling
 * `playHideAnimationOrRemoveFromParent` on the dialog box.
 *
 * __Note:__ You should remove the choice dialog in your hideAnimation block after
 * all animations are played. When a hideAnimation is specified, the dialog
 * does not know when to remove itself so please make sure to do it in your
 * block.
 *
 * @see [DLChoiceDialog removeFromParentAndCleanupAfterDelay:]
 */
@property (nonatomic, copy) DLAnimationBlock hideAnimation;

/**
 * Returns the default customizer used by the DLChoiceDialog
 */
+ (DLChoiceDialogCustomizer *)defaultCustomizer;

/**
 * Returns a common show animation for the dialog so you don't have to write them!
 *
 * __Note:__ If you do not want to animate the position of the dialog, then
 * just make the startPosition the same as the finalPosition.
 *
 * @param startPos          Start position of the dialog before the move animation.
 * @param finalPos          The position where the dialog should move to.
 * @param fadeIn            Fades the dialog box in.
 * @param duration          Duration of the whole animation sequence.
 */
+ (DLAnimationBlock)customShowAnimationWithStartPosition:(CGPoint)startPos
                                           finalPosition:(CGPoint)finalPos
                                                  fadeIn:(BOOL)fadeIn
                                                duration:(ccTime)duration;

/**
 * Returns a common hide animation for the dialog so you don't have to write them!
 *
 * __Note:__ If you do not want to animate the position of the dialog, then
 * just make the finalPosition the same as the position where the dialog is
 * being displayed.
 *
 * @param finalPos          The position where the dialog should move to.
 * @param fadeOut           Fades the dialog box out.
 * @param duration          Duration of the whole animation sequence.
 */
+ (DLAnimationBlock)customHideAnimationWithFinalPosition:(CGPoint)finalPos
                                                 fadeOut:(BOOL)fadeOut
                                                duration:(ccTime)duration;

@end


@class DLChoiceDialog, DLSelectableLabelCustomizer;

/**
 * Delegate for a <DLChoiceDialog>.
 */
@protocol DLChoiceDialogDelegate <NSObject>
@optional

/**
 * Called when a choice is selected in the choice dialog. Preselects does not
 * trigger this callback.
 *
 * @param sender    The choice dialog.
 * @param text      The text of the selected choice.
 * @param index     The index of the choice selection.
 */
- (void)choiceDialogLabelSelected:(DLChoiceDialog *)sender
                       choiceText:(NSString *)text
                      choiceIndex:(NSUInteger)index;

/**
 * Called only when a choice is preselected in the choice dialog.
 *
 * @param sender    The choice dialog.
 * @param text      The text of the preselected text.
 * @param index     The index of the choice selection.
 */
- (void)choiceDialogLabelPreselected:(DLChoiceDialog *)sender
                          choiceText:(NSString *)text
                         choiceIndex:(NSUInteger)index;
@end

/**
 * DLChoiceDialog is a dialog that asks for user input from a list of choices.
 *
 * DLChoiceDialog provides a simple way for you to gain user input without
 * writing up much code.
 *
 * A <DLChoiceDialogCustomizer> is used to customize the choice dialog.
 *
 * @see DLDialogBoxCustomizer
 */
@interface DLChoiceDialog : CCNode <DLSelectableLabelDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLChoiceDialogDelegate> delegate;

/**
 * An array of strings that contains the choices for this choice dialog.
 *
 * Setting this array will actually redraw/reposition the choice dialog's content
 * according to the current customizer.
 *
 * However it is still recommended to not change this array once your choice dialog
 * is created.
 */
@property (nonatomic, copy) NSArray *choices;

/**
 * This customizer is used to customize the UI and functionalities of the choice dialog.
 *
 * Attempting to update any UI related properties in the customizer
 * will not do anything and may break some functionalities.
 *
 * You can however update functionality related properties on the customizer
 * as those are processed whenever they are required.
 *
 * @see DLChoiceDialogCustomizer
 */
@property (nonatomic, strong) DLChoiceDialogCustomizer *customizer;

/**
 * @param choices           An array of choice strings to be displayed.
 * @param dialogCustomizer  A <DLChoiceDialogCustomizer> to customize the choice dialog.
 */
- (id)initWithChoices:(NSArray *)choices
     dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer;

+ (id)dialogWithChoices:(NSArray *)choices;
+ (id)dialogWithChoices:(NSArray *)choices
       dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer;

/**
 * Programatically selects a choice by passing the index of the choice in the <choices> array.
 *
 * If skipPreselect is set to NO, this method will preselect the label first if
 * <preselectEnabled> is enabled and the targeted choice has not
 * already been preselected.
 *
 * __Note:__ The delegate will be notified of this selection (maybe be a preselect or select).
 *
 * __Note:__ index starts at 0.
 *
 * @param index           Index of the choice. Starts at 0.
 * @param skipPreselect   If set to YES, this method will bypass any preselects.
 */
- (void)selectChoiceAtIndex:(NSUInteger)index skipPreselect:(BOOL)skipPreselect;

/**
 * Removes this dialog from its parent after a delay.
 *
 * Useful for removing the choice dialog from the parent after all hide animations
 * are finished. In this case, set the delay to the duration of the hide
 * animation so the dialog will be removed after animation is finished.
 *
 * @param delay   Delay before the dialog is removed
 */
- (void)removeFromParentAndCleanupAfterDelay:(ccTime)delay;

/**
 * Play the hide animation block associated with the dialog's customizer if it
 * exists. Else just remove the dialog from the parent.
 *
 * __Note:__ The hide animation block should be responsible for removing the
 * choice dialog from the parent.
 */
- (void)playHideAnimationOrRemoveFromParent;

/**
 * Fade in the dialog with a specified duration.
 *
 * @param duration    Duration of the fade
 */
- (void)fadeInWithDuration:(ccTime)duration;

/**
 * Fade out the dialog with a specified duration.
 *
 * @param duration    Duration of the fade
 */
- (void)fadeOutWithDuration:(ccTime)duration;

@end
