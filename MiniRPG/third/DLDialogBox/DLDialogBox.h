//
//  DSChatBox.h
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DLAutoTypeLabelBM.h"
#import "DLChoiceDialog.h"

#define kDialogBoxHeightSmall  55
#define kDialogBoxHeightNormal 90
#define kDialogBoxHeightLarge  130

#define kDialogBoxTouchPriority -499

/**
 * Constants to specify the position of the portrait in a <DLDialogBoxCustomizer>
 * for a <DLDialogBox>.
 *
 * @see [DLDialogBoxCustomizer portraitPosition]
 */
typedef NS_ENUM(NSInteger, DialogPortraitPosition) {
  
  /**
   * Portrait by the left of the dialog.
   */
  kDialogPortraitPositionLeft = 0,
  
  /**
   * Portrait by the right of the dialog.
   */
  kDialogPortraitPositionRight
};

/**
 * A DLDialogBoxCustomizer is used to determine the __look__, __functionalities__,
 * and the __animations__ related to a <DLDialogBox>.
 *
 * Every <DLDialogBox> must use a dialog customizer. If no customizers are given the
 * dialog box will automatically use the default customizer provided through
 * <defaultCustomizer>.
 *
 * The reason a customizer class is used to store how a dialog box should look,
 * function and animate is because this way you can reuse a single <DLDialogBoxCustomizer>
 * instance on all the DLDialogBoxes in your game to achieve a consistent look
 * and behaviour.
 */
@interface DLDialogBoxCustomizer : NSObject <NSCopying>


/// @name Customizing look/UI

/**
 * The size of dialog box (not including the portrait if its outside).
 *
 * __Default is (current device width, kDialogHeightNormal)__
 *
 * The default dialog size will make a dialog what stretches across the device
 * and can roughly accommodates 3 rows of text in landscape mode.
 *
 * Please note that DLDialogBox does not automatically scale the dialog's height
 * according to the content so you must make sure to set the <dialogSize> to a large
 * enough value so that the dialog box can accommodate all your text.
 * 
 * We provided some height constants for you to use:
 *
 * - `kDialogBoxHeightSmall` accommodates about 1-2 lines of text
 * - `kDialogBoxHeightNormal` accommodates about 3-4 lines of text and is the default height
 * - `kDialogBoxHeightLarge` accommodates about 4-5 lines of text
 */
@property (nonatomic) CGSize dialogSize;

/**
 * The position of the dialog box.
 *
 * The <DLDialogBox> will use this position when configured with a customizer.
 * However you can set the dialog box's position manually to override this position.
 *
 * __Defaults to (0, 0)__
 */
@property (nonatomic) CGPoint dialogPosition;

/**
 * The anchor point of the dialog box.
 *
 * The <DLDialogBox> will use this anchor point when configured with a customizer.
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
 * This is the sprite frame name for the sprite to be used by the dialog box
 * after a page of text is displayed.
 *
 * By default DLDialogBox will position the page finished indicator at the
 * bottom right corner of the dialog box.
 *
 * __By default `defaultCustomizer` sets this to the name of the arrow
 * cursor sprite attached with the project.__
 *
 * __Note:__ When this property is set, <pageFinishedIndicatorSpriteFile> will
 * not be used.
 *
 * @see [DLDialogBox pageFinishedIndicator]
 */
@property (nonatomic, copy) NSString *pageFinishedIndicatorSpriteFrameName;

/**
 * Name of the sprite file for the page finished indicator.
 *
 * If <pageFinishedIndicatorSpriteFrameName> is provided, then this value
 * will not be used.
 *
 * @see pageFinishedIndicatorSpriteFrameName
 */
@property (nonatomic, copy) NSString *pageFinishedIndicatorSpriteFile;

/**
 * The animation to play for the page finished indicator when its displayed.
 *
 * If not provided, the indicator will just appear instantly.
 *
 * __Defaults to a blinking animation__
 */
@property (nonatomic, copy) DLAnimationBlock pageFinishedIndicatorAnimation;

/**
 * Hides the page finished indicator for the last page of the dialog box.
 *
 * By default, JRPGs hide the indicator on the last page of the text so that the
 * player knows that there are no more text to display next. However sometimes
 * you may want to follow up one dialog box immediately with another one from
 * another npc, thus it might look better to set this value to NO for these
 * cases to show that they are more dialogs to follow.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL hidePageFinishedIndicatorOnLastPage;

/**
 * In CSS terms, this is essentially the margin of the dialog text.
 *
 * If the dialog box has an inner portrait on the left side of the dialog,
 * then the insets correspond to the spacing between the dialog box and the
 * inner portrait.
 *
 * Please note that this value is also used as the default insets between the
 * <pageFinishedIndicator> and the bottom right of the dialog box. If you don't
 * like that, you can always set the position of the indicator manually through
 * <pageFinishedIndicator>.
 *
 * __Defaults to (10, 10, 10, 10)__
 */
@property (nonatomic) UIEdgeInsets dialogTextInsets;

/**
 * Position of the portrait in the dialog box.
 *
 * This value can be `kDialogPortraitPositionLeft` or `kDialogPortraitPositionRight`
 *
 * __Defaults to `kDialogPortraitPositionLeft`__
 */
@property (nonatomic) DialogPortraitPosition portraitPosition;

/**
 * This is essentially the margin of the portrait sprite.
 *
 * By default the portrait sprite is placed at the bottom left corner of the dialog
 * box if <portraitInsideDialog> is set to NO.
 *
 * If <portraitInsideDialog> is YES, then the portrait is positioned in the top
 * left corner of the dialog box.
 *
 * __Defaults to (0, 0, 0, 0)__
 */
@property (nonatomic) UIEdgeInsets portraitInsets;

/**
 * If set to YES, the dialog's portrait will appear inside the dialog box.
 *
 * By default the portrait will be placed outside of the dialog box so you
 * can use a big beautiful portrait that is just super fabulous. 
 *
 * However if `portraitInsideDialog` is set to YES, then the portrait will instead
 * be placed inside the dialog.
 *
 * __Defaults to NO__
 *
 * @see portraitInsets
 */
@property (nonatomic) BOOL portraitInsideDialog;

/**
 * The font file used by the dialog for displaying text.
 *
 * This font file is also used by the choice dialog if the font file for
 * <choiceDialogCustomizer> is not set.
 *
 * __Defaults to the demo fnt file (`demo_fnt.fnt`) attached with the project__
 */
@property (nonatomic, copy) NSString *fntFile;

/**
 * The `DLChoiceDialogCustomizer` for the dialog box's choice dialog.
 *
 * __Defaults to the default DLChoiceDialogCustomizer__
 *
 * @see [DLChoiceDialogCustomizer defaultCustomizer]
 */
@property (nonatomic, strong) DLChoiceDialogCustomizer *choiceDialogCustomizer;


/// @name Customizing functionalities

/**
 * If enabled, tap inputs during dialog typing animation will immediately
 * finish the current page, bypassing anymore typing animations.
 *
 * If the page is already finished then tapping will go to the next page.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL tapToFinishCurrentPage;

/**
 * When enabled, the dialog box will process all tap inputs on the screen.
 *
 * By default when the dialog's typing animation has finished, tap inputs
 * will result in the dialog displaying the following page.
 *
 * Also depending on what other functionalities are enabled, tap inputs will
 * also do other things.
 *
 * __Defaults to YES__
 *
 * @see tapToFinishCurrentPage
 * @see handleOnlyTapInputsInDialogBox
 * @see swallowAllTouches
 * @see closeWhenDialogFinished
 */
@property (nonatomic) BOOL handleTapInputs;

/**
 * When enabled, this dialog box will only process tap inputs that are inside
 * the dialog box.
 *
 * This property is only relavent if <handleTapInputs> is enabled.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL handleOnlyTapInputsInDialogBox;

/**
 * If enabled, the dialog box will swallow all touches inputs. This can essentially
 * disable all touch inputs aside from this dialog box and its choice dialog.
 *
 * Enabling this is an easy way to disable all other user inputs when
 * the dialog box is displayed.
 *
 * However it is likely that you still want your player to tap on things like the
 * menu button etc, thus `swallowAllTouches` is set to NO by default so that you
 * can disable user inputs manually.
 *
 * Please note that once a DLDialogBox has been displayed, changing this value
 * will not change the behaviour of the DLDialogBox since this property, unlike
 * the other fuctionality related properties, is evaluated only when
 * DLDialogBox is first displayed.
 *
 * __Note:__ If something has a higher touch priority than `kDialogBoxTouchPriority`,
 * then that receiver will receive touch events even with `swallowAllTouches`
 * set to YES. However `kDialogBoxTouchPriority` is currently set to a such
 * low value that this dialog box should have the highest touch priority.
 *
 * __Defaults to NO__
 */
@property (nonatomic) BOOL swallowAllTouches;

/**
 * When enabled, this dialog box will automatically close when the dialog
 * has finished all its tasks.
 *
 * When there are no choices to be shown, this will allow the player to close
 * this dialog box on tap after all text pages are displayed.
 *
 * When there are choices to be displayed at the end, this dialog will close
 * automatically after a choice is selected (animated if the choice dialog has
 * a hideAnimation).
 *
 * __Defaults to YES__
 *
 * @see [DLDialogBox playHideAnimationOrRemoveFromParent]
 */
@property (nonatomic) BOOL closeWhenDialogFinished;

/**
 * The number of characters to be typed per second.
 *
 * __Defaults to kTypingSpeedNormal__
 */
@property (nonatomic) CGFloat typingSpeed;


/// @name Sound related

/**
 * The sound file to play whenever a new page of text has started.
 */
@property (nonatomic, copy) NSString *textPageStartedSoundFileName;


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
 * This animation block is automatically run if <closeWhenDialogFinished> is
 * set to YES and the dialog has finished.
 *
 * Or you can run this animation block manually by calling
 * <[DLDialogBox playHideAnimationOrRemoveFromParent]> on the dialog box.
 *
 * __Note:__ You should call <[DLDialogBox removeFromParentAndCleanupAfterDelay:]>
 * in your animation block to remove the dialog box after the duration of your
 * hide animation. This is required because DLDialogBox will not remove itself
 * after the hide animation has played.
 *
 * @see [DLDialogBox removeFromParentAndCleanupAfterDelay:]
 */
@property (nonatomic, copy) DLAnimationBlock hideAnimation;


/**
 * Returns a default customizer for the dialog box
 */
+ (DLDialogBoxCustomizer *)defaultCustomizer;

/**
 * Returns a common show animation for the dialog so you don't have to write them!
 *
 * __Note:__ The default slide direction is up. However if you want the dialog
 * content box to slide down instead of sliding up when showing then just specify
 * a negative distance. Furthermore, the move animation will not be performed
 * if the distance is 0.
 *
 * @param distance          The distance the dialog should travel for the slide up.
 * @param fadeIn            Fades the dialog in.
 * @param duration          Duration of the whole animation sequence.
 */
+ (DLAnimationBlock)customShowAnimationWithSlideDistance:(CGFloat)distance
                                                  fadeIn:(BOOL)fadeIn
                                                duration:(ccTime)duration;

/**
 * Returns a common hide animation for the dialog so you don't have to write them!
 *
 * __Note:__ The default slide direction is down. However if you want the dialog
 * content box to slide up instead of sliding down when hiding then just specify
 * a negative distance. Furthermore, the move animation will not be performed
 * if the distance is 0.
 *
 * @param distance          The distance the dialog should travel for the slide down.
 * @param fadeOut           Fades the dialog out.
 * @param duration          Duration of the whole animation sequence.
 */
+ (DLAnimationBlock)customHideAnimationWithSlideDistance:(CGFloat)distance
                                                 fadeOut:(BOOL)fadeOut
                                                duration:(ccTime)duration;

@end

@class DLDialogBox;

/**
 * Delegate for DLDialogBox
 */
@protocol DLDialogBoxDelegate <NSObject>
@optional

/**
 * Called after a <DLDialogBox> has displayed all its text pages.
 *
 * __Note:__ If the dialog box needs to open a choice dialog after the last text then
 * this is called after the choice dialog is displayed, not after a choice
 * has been selected.
 *
 * @param sender  The dialog box
 */
- (void)dialogBoxAllTextFinished:(DLDialogBox *)sender;

/**
 * Called when a <DLDialogBox> has started animating a text page.
 *
 * @param sender        The dialog box
 * @param currentPage   The page currently being displayed
 */
- (void)dialogBoxCurrentTextPageStarted:(DLDialogBox *)sender
                            currentPage:(NSUInteger)currentPage;

/**
 * Called when a <DLDialogBox> has finished animating a text page.
 *
 * Since the dialog box can display an array of text, this method is called
 * whenever a single page of text has finished animating and is fully displayed.
 *
 * @param sender        The targeted dialog box
 * @param currentPage   The page currently being displayed
 */
- (void)dialogBoxCurrentTextPageFinished:(DLDialogBox *)sender
                             currentPage:(NSUInteger)currentPage;

/**
 * Called when a choice is selected for a <DLDialogBox>
 *
 * @param sender        The targeted dialog box
 * @param text          The text that is selected
 * @param index         The index of the choice
 */
- (void)dialogBoxChoiceSelected:(DLDialogBox *)sender
                     choiceText:(NSString *)text
                    choiceIndex:(NSUInteger)index;
@end

@class DSCharater;

/**
 * DLDialogBox is the single interface to create super customizable dialog boxes.
 *
 * DLDialogBox provides simple methods to display dialog text and also provide
 * an easy way to receive player input through the use of an integrated <DLChoiceDialog>.
 *
 * A <DLDialogBoxCustomizer> is used to customize the dialog box.
 *
 * ---
 * ### Shared Default Customizer
 *
 * You can also use this class to set a single shared <DLDialogBoxCustomizer>
 * that you can use on all your dialogs to make sure that they all
 * follow a consistent theme.
 *
 * Usage example:
 *
 * ```
 *     // Create a basic customizer
 *     DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
 *
 *     // Customize the customizer however you want (you can use DLDialogPresets).
 *     // ...
 *
 *     // Set it as the default customizer
 *     [DLDialogBox setDefaultCustomizer:customizer];
 *
 *     // Create a dialog box like usual
 *     DLDialogBox *dialog = [DLDialogBox dialogWithTextArray:texts defaultPortrait:portrait];
 *
 *     // Fetch the default customizer when needed
 *    [DLDialogBox defaultCustomizer];
 * ```
 *
 * @see DLDialogBoxCustomizer
 * @see setDefaultCustomizer:
 */
@interface DLDialogBox : CCNode
<DLAutoTypeLabelBMDelegate, DLChoiceDialogDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLDialogBoxDelegate> delegate;


/// @name Dialog Box Information

/**
 * Current dialog page. Starts at 1. 0 when nothing has been typed.
 *
 * __Defaults to 0__
 */
@property (nonatomic, readonly) NSUInteger currentTextPage;


/// @name Functionalities

/**
 * The text to be displayed before every dialog content.
 *
 * A good use of this will be adding a character name before all dialog content.
 *
 * For example setting `prependText` to "Draco: " will result in all text displayed
 * by the dialog box to start with "Draco: [content]" as if it's me saying it :)
 */
@property (nonatomic, copy) NSString *prependText;

/**
 * This value will be YES when the current page displayed by the dialog box
 * has been fully typed/displayed.
 *
 * __By default this is NO__
 */
@property (nonatomic, readonly) BOOL currentPageTyped;


/// @name Dialog Box Data

/**
 * An array of choices for the dialog box's choice dialog.
 *
 * Once a choice array has been provided, a <DLChoiceDialog> will automatically be created.
 * You can then access the <DLChoiceDialog> through the property <choiceDialog>.
 *
 * You can change this choices array anytime before the choice dialog is displayed.
 * Changing this choices array will automatically recreate the choice dialog to
 * reflect the new choices.
 *
 * @see DLChoiceDialog
 */
@property (nonatomic, copy) NSArray *choices;

/**
 * This is used provide unique portrait sprites for the different dialog pages in a <DLDialogBox>.
 *
 * ### Usage
 *
 * - The key of the dictionary must be the page number greater than 0.
 * - The value of the dictionary can be two class types:
 *
 * __Type 1:__
 *
 * If the value belongs to a CCSprite then this sprite will be used
 * as the portrait image for the dialog page indicated by the key.
 *
 * Example: `{"4": [a cool sprite]}`
 *
 * __Type 2:__
 *
 * If the value belonds to a NSString, then this string will be used by
 * `[CCSprite spriteWithSpriteFrameName:]` to create the sprite to be used
 * as the portrait image for the dialog page indicated by the key.
 *
 * Example: `{"2": "draco_smiling.png"}`
 */
@property (nonatomic, copy) NSDictionary *customPortraitForPages;

/**
 * An array of text that this dialog will be typing.
 *
 * Each element of this array will be display as a single page.
 * <currentTextPage> should corresponds to the current page that is being typed.
 */
@property (nonatomic, copy) NSArray *initialTextArray;


/// @name Dialog Box Node Content

/**
 * This customizer is used to customize the UI and functionalities of the dialog box.
 *
 * Please note that once a DLDialogBox is created with a customizer, you cannot
 * update UI related properties in the customizer anymore as the dialog box will only
 * process the UI properties once during creation to draw the dialog box.
 *
 * Attempting to update any UI related properties in the customizer
 * will not do anything and may break some functionalities.
 *
 * You can however update functionality related properties on the customizer
 * as those are processed whenever they are required.
 *
 * @see DLDialogBoxCustomizer
 */
@property (nonatomic, strong) DLDialogBoxCustomizer *customizer;

/**
 * The `DLChoiceDialog` to be displayed at the last text page if <choices> are provided.
 *
 * You can customize this choice dialog through the <customizer>.
 *
 * The choice dialog is only created when the <choices> array is set.
 *
 * Since this choice dialog is added to the same parent as the dialog box, as
 * opposed to as a child of the dialog box, removing the dialog box will not
 * remove the choice dialog if its displayed. You will need to remove this choice
 * dialog individually or by calling <playHideAnimationOrRemoveFromParent>.
 */
@property (nonatomic, strong) DLChoiceDialog *choiceDialog;

/**
 * The portrait sprite to display by default.
 *
 * If nil, no portrait will be displayed for the dialog box.
 *
 * You can customize the portrait position through the <customizer>.
 */
@property (nonatomic, strong) CCSprite *defaultPortraitSprite;

/**
 * A page finished indicator sprite to be shown after each page have been finished.
 *
 * The sprite is determined by the <customizer>.
 *
 * By default DLDialogBox will position the page finished indicator at the
 * bottom right corner of the dialog box.
 */
@property (nonatomic, strong) CCSprite *pageFinishedIndicator;

/**
 * The portrait that is being displayed by the dialog box.
 *
 * This sprite is the only sprite that is used by the dialog box to display the portrait.
 *
 * <defaultPortraitSprite> or any other sprites in <customPortraitForPages> is
 * only used to replace this sprite's texture.
 *
 * This sprite is exposed publicly so that you can customize it however you like.
 * Just don't do anything weird.
 *
 * __Please note that this sprite will be `nil` if `defaultPortraitSprite` is not provided.__
 *
 */
@property (nonatomic, strong) CCSprite *portrait;

/**
 * The node that is the parent of all nodes in the dialog box.
 *
 * When the dialog box's portrait is inside, this node should contain everything
 * including the dialog portrait.
 * However when the portrait is outside of the portrait then the portrait will
 * be excluded from the dialogContent.
 *
 * This property is exposed so that you can animate just the dialog content in 
 * isolation of anything that might be outside of it.
 */
@property (nonatomic, strong) CCNode *dialogContent;

/**
 * The label that is used to type texts in the dialog box.
 * 
 * This property is exposed so that you can provide custom animations
 * for just the dialog label during dialog onEnter or onExit.
 */
@property (nonatomic, strong) DLAutoTypeLabelBM *dialogLabel;

/**
 * Sprite of the dialog box background.
 *
 * Exposed here so you can animate the dialog's background during onEnter or onExit.
 *
 * This sprite is created after the DLDialogBox is initialized with a customizer.
 */
@property (nonatomic, strong) CCSprite *bgSprite;


/// @name Initializers

/**
 * @param texts       An array of texts to display
 * @param portrait    The portrait sprite to show
 * @param choices     An array of choice strings for the choice dialog
 * @param customizer  A <DLDialogBoxCustomizer> to customize the dialog box
 */
- (id)initWithTextArray:(NSArray *)texts
                choices:(NSArray *)choices
        defaultPortrait:(CCSprite *)portrait
             customizer:(DLDialogBoxCustomizer *)customizer;

/**
 * @param texts       An array of texts to display
 * @param portrait    The portrait sprite to show
 */
+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait;

/**
 * @param texts       An array of texts to display
 * @param portrait    The portrait sprite to show
 * @param customizer  A <DLDialogBoxCustomizer> to customize the dialog box
 */
+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
               customizer:(DLDialogBoxCustomizer *)customizer;

/**
 * @param texts       An array of texts to display
 * @param choices     An array of choice strings for the choice dialog
 * @param portrait    The portrait sprite to show
 */
+ (id)dialogWithTextArray:(NSArray *)texts
                  choices:(NSArray *)choices
          defaultPortrait:(CCSprite *)portrait;

/**
 * @param texts       An array of texts to display
 * @param choices     An array of choice strings for the choice dialog
 * @param portrait    The portrait sprite to show
 * @param customizer  A <DLDialogBoxCustomizer> to customize the dialog box
 */
+ (id)dialogWithTextArray:(NSArray *)texts
                  choices:(NSArray *)choices
          defaultPortrait:(CCSprite *)portrait
               customizer:(DLDialogBoxCustomizer *)customizer;


/// @name Controlling DialogBox Interactions

/**
 * Finish animating the current page if the dialog content is still being typed,
 * else go to the next page.
 *
 * This method essentially calls <finishCurrentPage> if current page is still
 * being animated. Else if <currentPageTyped> is YES, then <advanceToNextPage>
 * will be called.
 *
 * __Example usage:__ Make a custom "Next" button that the player can use to skip
 * the typing animation or go to the next page if the page has already finished displaying.
 *
 * When <tapToFinishCurrentPage> is set to YES, tap inputs are all handled by this
 * method internally.
 */
- (void)finishCurrentPageOrAdvance;

/**
 * Finish the current page immediately, skipping any typing animations.
 *
 * If the current page has already finished animating, then nothing happens.
 */
- (void)finishCurrentPage;

/**
 * Finish the current page immediately and display the next page's content.
 *
 * If called before the dialog has finished its typing animation, then the
 * typing animation will not finish and would instead immeditely start animating
 * the next page's content.
 *
 * If there are no more content left to display this method would do nothing
 * unless <closeWhenDialogFinished> is set to YES and there are no choice dialogs.
 * In this case this method would remove the dialog box since everything is done.
 */
- (void)advanceToNextPage;

/**
 * Update this dialog's portrait with the texture of the passed in sprite.
 *
 * @param sprite The sprite to use for the dialog portrait
 */
- (void)updatePortraitTextureWithSprite:(CCSprite *)sprite;

/**
 * Add this dialog's choice dialog to DLDialogBox's parent if a <choiceDialog> exists.
 *
 * Note that the choice dialog is actually added to the same parent that this
 * dialog box is added to. Thus you should set the <choiceDialog>'s position
 * manually right after creating a DLDialogBox with choices.
 *
 * The z index of the choice dialog is automatically set to the dialog box's zOrder + 1
 * so it is always above the dialog box.
 * 
 * <showChoiceDialog> is automatically called after a <DLDialogBox> has finished
 * typing all its text array. However you can show the choice dialog earlier
 * manually by calling this method.
 *
 * The <choiceDialog> is only created when <choices> are set.
 */
- (void)showChoiceDialog;


/// @name Removing the DialogBox

/**
 * A convenience method to remove this dialog and also its choice dialog (since
 * its not a child of this dialog box) from the parent and clean up.
 *
 * Call this method directly if you want to make sure to remove the dialog box
 * and its choice dialog immediately.
 */
- (void)removeDialogBoxAndChoiceDialogFromParentAndCleanup;

/**
 * Removes the dialog box from its parent after a delay. Does not remove the 
 * dialog's choice dialog.
 *
 * Useful for removing the dialog box from the parent after all hide animations
 * are finished. In this case, set the delay to the duration of the hide
 * animation so the dialog box will be removed after animation is finished.
 *
 * @see [DLDialogBoxCustomizer hideAnimation]
 *
 * @param delay   The delay before the dialog is removed
 */
- (void)removeFromParentAndCleanupAfterDelay:(ccTime)delay;


/// @name Animations

/**
 * Play the hide animation block associated with this dialog's customizer and 
 * the choice dialog's cutomizer if they exist. 
 *
 * If no hide Animation exists, then this method will just remove the dialog
 * box and its choice dialog from the parent.
 *
 * This method is automatically called when the dialog is finished if
 * <[DLDialogBoxCustomizer closeWhenDialogFinished]> is set to `YES` in the customizer.
 *
 * __Note:__ The hide animation blocks should be responsible for removing the
 * dialog from the parent.
 *
 * @see [DLDialogBoxCustomizer hideAnimation]
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

/**
 * Animates the outside portrait in if it exists.
 *
 * If the portrait is positioned on the left side, then the animation will slide
 * in from the left and vice versa if positioned on the right side.
 *
 * __Note:__ If you do not want a move animation then just set the distance to 0.
 *
 * @param fadeIn    Should the portrait be faded in?
 * @param distance  The distance the portrait should travel to get to the final position.
 * @param duration  Duration of the animation sequence.
 */
- (void)animateOutsidePortraitInWithFadeIn:(BOOL)fadeIn
                                  distance:(CGFloat)distance
                                  duration:(ccTime)duration;

/**
 * Animates the outside portrait out if it exists.
 *
 * If the portrait is positioned on the left side, then the animation will slide
 * to the left and vice versa if positioned on the right side.
 *
 * __Note:__ If you do not want a move animation then just set the distance to 0.
 *
 * @param fadeOut   Should the portrait be faded out?
 * @param distance  The distance the portrait should travel in its slide direction.
 * @param duration  Duration of the animation sequence.
 */
- (void)animateOutsidePortraitOutWithFadeOut:(BOOL)fadeOut
                                    distance:(CGFloat)distance
                                    duration:(ccTime)duration;


/// @name Default Shared Customizer

/**
 * Set the default customizer used by all DLDialogBox instances when a customizer
 * is not specified.
 *
 * @param customizer  The customizer to use by default
 */
+ (void)setDefaultCustomizer:(DLDialogBoxCustomizer *)customizer;

/**
 * Get the default customizer used by all DLDialogBox instances.
 */
+ (DLDialogBoxCustomizer *)defaultCustomizer;

@end
