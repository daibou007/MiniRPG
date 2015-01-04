//
//  DSChatBox.m
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DLDialogBox.h"
#import "CCSprite+GLBoxes.h"
#import "CCScale9Sprite.h"
#import "SimpleAudioEngine.h"

// Constants for z indexes
#define kBackgroundSpriteZIndex 0
#define kPageTextZIndex 1
#define kPageIndicatorZIndex 2

@implementation DLDialogBoxCustomizer

- (id)copyWithZone:(NSZone *)zone
{
  DLDialogBoxCustomizer *another = [[self class] allocWithZone:zone];
  another.dialogSize = self.dialogSize;
  another.dialogPosition = self.dialogPosition;
  another.dialogAnchorPoint = self.dialogAnchorPoint;
  another.backgroundSpriteFile = [self.backgroundSpriteFile copyWithZone:zone];
  another.backgroundSpriteFrameName = [self.backgroundSpriteFrameName copyWithZone:zone];
  another.backgroundColor = self.backgroundColor;
  another.pageFinishedIndicatorSpriteFrameName = [self.pageFinishedIndicatorSpriteFrameName copyWithZone:zone];
  another.pageFinishedIndicatorSpriteFile = [self.pageFinishedIndicatorSpriteFile copyWithZone:zone];
  another.pageFinishedIndicatorAnimation = self.pageFinishedIndicatorAnimation;
  another.hidePageFinishedIndicatorOnLastPage = self.hidePageFinishedIndicatorOnLastPage;
  another.dialogTextInsets = self.dialogTextInsets;
  another.portraitPosition = self.portraitPosition;
  another.portraitInsets = self.portraitInsets;
  another.portraitInsideDialog = self.portraitInsideDialog;
  another.fntFile = [self.fntFile copyWithZone:zone];
  another.choiceDialogCustomizer = [self.choiceDialogCustomizer copyWithZone:zone];
  another.tapToFinishCurrentPage = self.tapToFinishCurrentPage;
  another.handleTapInputs = self.handleTapInputs;
  another.handleOnlyTapInputsInDialogBox = self.handleOnlyTapInputsInDialogBox;
  another.swallowAllTouches = self.swallowAllTouches;
  another.closeWhenDialogFinished = self.closeWhenDialogFinished;
  another.typingSpeed = self.typingSpeed;
  another.textPageStartedSoundFileName = [self.textPageStartedSoundFileName copyWithZone:zone];
  another.showAnimation = self.showAnimation;
  another.hideAnimation = self.hideAnimation;
  return another;
}

+ (DLDialogBoxCustomizer *)defaultCustomizer
{
  DLDialogBoxCustomizer *customizer = [[DLDialogBoxCustomizer alloc] init];
  
  // Load up sprite for our font and arrow sprite
  NSString *fileName = @"DLDialogBox.bundle/dldialogbox_preset_resources.plist";
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fileName];
  
  // Look
  customizer.dialogSize = CGSizeMake([[CCDirector sharedDirector] winSize].width,
                                     kDialogBoxHeightNormal);
  customizer.dialogPosition = ccp(0, 0);
  customizer.backgroundColor = ccc4(0, 0, 0, 0.8*255);
  customizer.pageFinishedIndicatorSpriteFrameName = @"arrow_cursor.png";
  customizer.pageFinishedIndicatorAnimation = ^(DLDialogBox *dialog) {
    // Animate arrow cursor blinking
    if (dialog.pageFinishedIndicator) {
      id blink = [CCBlink actionWithDuration:5.0 blinks:5.0];
      [dialog.pageFinishedIndicator runAction:[CCRepeatForever actionWithAction:blink]];
    }
  };
  customizer.hidePageFinishedIndicatorOnLastPage = YES;
  customizer.dialogTextInsets = UIEdgeInsetsMake(10, 10, 10, 10);
  customizer.portraitPosition = kDialogPortraitPositionLeft;
  customizer.portraitInsets = UIEdgeInsetsZero;
  customizer.portraitInsideDialog = NO;
  customizer.fntFile = @"DLDialogBox.bundle/dldialogbox_default_fnt.fnt";
  customizer.choiceDialogCustomizer = [DLChoiceDialogCustomizer defaultCustomizer];
  
  // Functionalities
  customizer.tapToFinishCurrentPage = YES;
  customizer.handleTapInputs = YES;
  customizer.handleOnlyTapInputsInDialogBox = YES;
  customizer.swallowAllTouches = NO;
  customizer.typingSpeed = kTypingSpeedNormal;
  customizer.closeWhenDialogFinished = YES;
  
  return customizer;
}

+ (DLAnimationBlock)customShowAnimationWithSlideDistance:(CGFloat)distance
                                                  fadeIn:(BOOL)fadeIn
                                                duration:(ccTime)duration
{
  return ^(DLDialogBox *dialog)
  {
    // Animate any outside portrait independently
    [dialog animateOutsidePortraitInWithFadeIn:NO
                                      distance:dialog.portrait.contentSize.width / 4
                                      duration:duration];
    
    // Animate dialog content slides in
    if (distance != 0) {
      CGPoint startPos = CGPointZero;
      CGPoint finalPos = dialog.dialogContent.position;
      CGPoint travelDiff = CGPointMake(0, distance);
      startPos = ccpSub(dialog.dialogContent.position, travelDiff);
      dialog.dialogContent.position = startPos;
      id move = [CCMoveTo actionWithDuration:duration position:finalPos];
      [dialog.dialogContent runAction:move];
    }
    
    // Animate dialog content fade in
    if (fadeIn) {
      [dialog fadeInWithDuration:duration];
    }
  };
}

+ (DLAnimationBlock)customHideAnimationWithSlideDistance:(CGFloat)distance
                                                 fadeOut:(BOOL)fadeOut
                                                duration:(ccTime)duration
{
  return ^(DLDialogBox *dialog)
  {
    // Animate any outside portrait independently
    [dialog animateOutsidePortraitOutWithFadeOut:fadeOut
                                        distance:dialog.portrait.contentSize.width / 4
                                        duration:duration];
    
    // Animate dialog content slide out
    if (distance != 0) {
      CGPoint finalPos = CGPointZero;
      CGPoint travelDiff = CGPointMake(0, distance);
      finalPos = ccpSub(dialog.dialogContent.position, travelDiff);
      id move = [CCMoveTo actionWithDuration:duration position:finalPos];
      [dialog.dialogContent runAction:move];
    }
    
    // Animate dialog content fade in
    if (fadeOut) {
      [dialog fadeOutWithDuration:duration];
    }
    
    // Done callback to remove the dialog
    [dialog removeFromParentAndCleanupAfterDelay:duration];
  };
}

@end

static DLDialogBoxCustomizer *defaultCustomizer = nil;

@interface DLDialogBox ()
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, readwrite) BOOL currentPageTyped;

- (void)initializeDialogBoxWithCurrentCustomizer;
@end

@implementation DLDialogBox

- (void)dealloc
{
  self.delegate = nil;
  self.dialogLabel.delegate = nil;
  if (self.choiceDialog) {
    self.choiceDialog.delegate = nil;
  }
  [self.customizer removeObserver:self forKeyPath:@"typingSpeed"];
}


+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
{
  DLDialogBoxCustomizer *customizer = [[DLDialogBox defaultCustomizer] copy];
  if (!customizer) {
    customizer = [DLDialogBoxCustomizer defaultCustomizer];
  }
  return [[self alloc] initWithTextArray:texts
                                 choices:nil
                         defaultPortrait:portrait
                              customizer:customizer];
}

+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
               customizer:(DLDialogBoxCustomizer *)customizer
{
  return [[self alloc] initWithTextArray:texts
                                 choices:nil
                         defaultPortrait:portrait
                              customizer:customizer];
}

+ (id)dialogWithTextArray:(NSArray *)texts
                  choices:(NSArray *)choices
          defaultPortrait:(CCSprite *)portrait
{
  DLDialogBoxCustomizer *customizer = [[DLDialogBox defaultCustomizer] copy];
  if (!customizer) {
    customizer = [DLDialogBoxCustomizer defaultCustomizer];
  }
  return [[self alloc] initWithTextArray:texts
                                 choices:choices
                         defaultPortrait:portrait
                              customizer:customizer];
}

+ (id)dialogWithTextArray:(NSArray *)texts
                  choices:(NSArray *)choices
          defaultPortrait:(CCSprite *)portrait
               customizer:(DLDialogBoxCustomizer *)customizer
{
  return [[self alloc] initWithTextArray:texts
                                 choices:choices
                         defaultPortrait:portrait
                              customizer:customizer];
}

- (id)initWithTextArray:(NSArray *)texts
                choices:(NSArray *)choices
        defaultPortrait:(CCSprite *)portrait
             customizer:(DLDialogBoxCustomizer *)customizer
{
  if (self = [super init])
  {
    _currentPageTyped = NO;
    _textArray = [texts mutableCopy];
    _initialTextArray = texts;
    
    // Create our dialog content node
    _dialogContent = [CCNode node];
    _dialogContent.anchorPoint = ccp(0, 0);
    _dialogContent.position = ccp(0, 0);
    _dialogContent.contentSize = customizer.dialogSize;
    [self addChild:_dialogContent z:kBackgroundSpriteZIndex];
    
    // Add in general portrait
    _defaultPortraitSprite = portrait;
    _portrait = [CCSprite node];
    _portrait.anchorPoint = ccp(0, 0);
    _portrait.visible = YES;
    [self updatePortraitTextureWithSprite:_defaultPortraitSprite];
    
    // Add portrait to dialog content node if its inside the dialog
    if (customizer.portraitInsideDialog) {
      [_dialogContent addChild:_portrait z:kBackgroundSpriteZIndex + 1];
    }else {
      [self addChild:_portrait z:kBackgroundSpriteZIndex - 1];
    }
   //TODO
    // Add in our dialog label
      _dialogLabel = [DLAutoTypeLabelBM labelWithString:@"" fontName:@"HiraMinProN-W6" fontSize:20.0f];
    _dialogLabel.delegate = self;
    _dialogLabel.anchorPoint = ccp(0, 1);
    _dialogLabel.visible = NO;
    [self.dialogContent addChild:_dialogLabel z:kPageTextZIndex];
    
    // Set our customizer and layout the UI for our dialog box
    _customizer = customizer;
    [self initializeDialogBoxWithCurrentCustomizer];
    
    // Create choices and our choice dialog
    // Adding choices after customizer allows us to create a choice dialog
    // with the current customizer
    self.choices = choices;
    
    // Observe for typing speed changes on the customizer
    [self.customizer addObserver:self
                      forKeyPath:@"typingSpeed"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
  }
  
  return self;
}


#pragma mark - Custom property setters/getters

- (void)setChoices:(NSArray *)choices
{
  if (_choices != choices) {
    _choices = choices;
    
    // Remove existing choice dialogs
    if (self.choiceDialog) {
      [self.choiceDialog removeFromParentAndCleanup:YES];
      self.choiceDialog.delegate = nil;
    }
    
    // Make new choice dialog with our customizer
    if (choices && choices.count > 0)
    {
      // If no specified fntFile for the choice dialog, we will use the dialog's font file
      if (!self.customizer.choiceDialogCustomizer.fntFile) {
        self.customizer.choiceDialogCustomizer.fntFile = self.customizer.fntFile;
      }
      self.choiceDialog = [DLChoiceDialog dialogWithChoices:choices
                                           dialogCustomizer:self.customizer.choiceDialogCustomizer];
      self.choiceDialog.customizer.closeWhenChoiceSelected = NO; // This dialog box takes full control over what happens
      self.choiceDialog.delegate = self;
    }
  }
}

- (NSUInteger)currentTextPage
{
  int currentCount = self.textArray.count;
  int oriCount = self.initialTextArray.count;
  return oriCount - currentCount;
}


#pragma mark - Public methods

- (void)finishCurrentPageOrAdvance
{
  // If current page is still being animated, then finish it
  if (self.dialogLabel.currentlyTyping) {
    [self finishCurrentPage];
  }else if (self.currentPageTyped) {
    // If current page is already displayed go to next page
    [self advanceToNextPage];
  }
}

- (void)finishCurrentPage
{
  // Finish typing current page if typing has not finished.
  // If typing has already finished then this method would do nothing and the
  // typing finished delegate wont be called.
  [self.dialogLabel finishTypingAnimation];
}

- (void)advanceToNextPage
{
  // If choice dialog is on, dialog will not be able to advance
  if (self.choiceDialog && self.choiceDialog.parent && self.choiceDialog.visible) {
    return;
  }
  
  // Alert delegate if no more text and has no choice dialog.
  // If does have choice dialog, we alert all text finished whithout this additional call
  if(self.textArray.count == 0 && !self.choiceDialog) {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogBoxAllTextFinished:)]) {
      [self.delegate dialogBoxAllTextFinished:self];
    }
    
    // Close dialog box if enabled when no more content to display
    if (self.customizer.closeWhenDialogFinished) {
      [self playHideAnimationOrRemoveFromParent];
    }
    
    return;
  }
  
  // Stop any existing blinking cursor
  if (self.pageFinishedIndicator) {
    [self.pageFinishedIndicator stopAllActions];
    self.pageFinishedIndicator.visible = NO;
  }
  
  // Remove the text to be displayed from our text array
  NSString *text = self.textArray[0];
  [self.textArray removeObjectAtIndex:0];
  
  // Type the text
  self.currentPageTyped = NO;
  NSString *stringToType = text;
  if (self.prependText) {
    stringToType = [NSString stringWithFormat:@"%@%@", self.prependText, stringToType];
  }
  [self.dialogLabel typeText:stringToType typingSpeed:self.customizer.typingSpeed];
  self.dialogLabel.visible = YES;
  
  // Update for any custom portrait for this page
  if (self.customPortraitForPages) {
    NSString *pageString = [NSString stringWithFormat:@"%d", self.currentTextPage];
    id value = [self.customPortraitForPages valueForKey:pageString];
    if (value && [value isKindOfClass:[CCSprite class]])
    {
      [self updatePortraitTextureWithSprite:(CCSprite *)value];
    }
    else if (value && [value isKindOfClass:[NSString class]])
    {
      CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:(NSString *)value];
      [self updatePortraitTextureWithSprite:sprite];
    }else {
      [self updatePortraitTextureWithSprite:self.defaultPortraitSprite];
    }
  }else {
    // Make sure we are displaying the default sprite.
    [self updatePortraitTextureWithSprite:self.defaultPortraitSprite];
  }
  
  // Play sound fx
  if (self.customizer.textPageStartedSoundFileName) {
    [[SimpleAudioEngine sharedEngine] playEffect:self.customizer.textPageStartedSoundFileName];
  }
  
  // Inform delegate of new page animation
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(dialogBoxCurrentTextPageStarted:currentPage:)])
  {
    [self.delegate dialogBoxCurrentTextPageStarted:self currentPage:self.currentTextPage];
  }
}

- (void)updatePortraitTextureWithSprite:(CCSprite *)sprite
{
  // Update dialog portrait displayed image if texture is different
  if (self.portrait.texture != sprite.texture) {
    [self.portrait setTextureAtlas:sprite.textureAtlas];
    [self.portrait setTexture:sprite.texture];
    [self.portrait setTextureRect:sprite.textureRect];
    [self.portrait setDisplayFrame:sprite.displayFrame];
  }
}

- (void)showChoiceDialog
{
  // We add the choice dialog to the parent instead of the dialog box
  if (self.choiceDialog && !self.choiceDialog.parent) {
    self.choiceDialog.visible = YES;
    [self.parent addChild:self.choiceDialog z:self.zOrder + 1];
  }
}

- (void)removeDialogBoxAndChoiceDialogFromParentAndCleanup
{
  if (self.choiceDialog) {
    [self.choiceDialog removeFromParentAndCleanup:YES];
  }
  [self removeFromParentAndCleanup:YES];
}

- (void)removeFromParentAndCleanupAfterDelay:(ccTime)delay
{
  // If delay is 0, remove from parent immediately
  if (delay <= 0) {
    [self removeFromParentAndCleanup:YES];
    return;
  }
  
  // Remove after delay
  __weak DLDialogBox *weakSelf = self;
  id removeBlock = [CCCallBlock actionWithBlock:^() {
    [weakSelf removeFromParentAndCleanup:YES];
  }];
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:delay],
                   removeBlock, nil]];
}

- (void)playHideAnimationOrRemoveFromParent
{
  // Remove the dialog box
  if (self.customizer.hideAnimation) {
    self.customizer.hideAnimation(self);
  }else {
    [self removeFromParentAndCleanup:YES];
  }
  
  // Remove the choice dialog if its exists and is shown
  if (self.choiceDialog && self.choiceDialog.parent) {
    if (self.choiceDialog.customizer.hideAnimation) {
      [self.choiceDialog playHideAnimationOrRemoveFromParent];
    }else {
      [self.choiceDialog removeFromParentAndCleanup:YES];
      self.choiceDialog.delegate = nil;
    }
  }
}

- (void)fadeInWithDuration:(ccTime)duration
{
  id fade = [CCFadeIn actionWithDuration:duration];
  [self.bgSprite runAction:fade];
  [self.dialogLabel runAction:[fade copy]];
  if (self.pageFinishedIndicator && self.pageFinishedIndicator.parent) {
    [self.pageFinishedIndicator runAction:[fade copy]];
  }
  if (self.defaultPortraitSprite) {
    [self.portrait runAction:[fade copy]];
  }
}

- (void)fadeOutWithDuration:(ccTime)duration
{
  id fade = [CCFadeOut actionWithDuration:duration];
  [self.bgSprite runAction:fade];
  [self.dialogLabel runAction:[fade copy]];
  if (self.pageFinishedIndicator && self.pageFinishedIndicator.parent) {
    [self.pageFinishedIndicator runAction:[fade copy]];
  }
  if (self.defaultPortraitSprite) {
    [self.portrait runAction:[fade copy]];
  }
}

- (void)animateOutsidePortraitInWithFadeIn:(BOOL)fadeIn
                                  distance:(CGFloat)distance
                                  duration:(ccTime)duration
{
  // Animate in outside portrait independently
  if (self.defaultPortraitSprite && !self.customizer.portraitInsideDialog)
  {
    CGPoint finalPos = self.portrait.position;
    
    // Calculate initial position
    CGPoint startingPos = CGPointZero;
    if (self.customizer.portraitPosition == kDialogPortraitPositionLeft) {
      startingPos = ccpSub(finalPos, CGPointMake(distance, 0));
    }else {
      startingPos = ccpAdd(finalPos, CGPointMake(distance, 0));
    }
    
    // Animate move and fade in
    self.portrait.position = startingPos;
    id move = [CCMoveTo actionWithDuration:duration
                                  position:finalPos];
    //    id moveEaseOut = [CCEaseOut actionWithAction:move
    //                                            rate:kPortraitMoveAnimationEaseRate];D
    id fadeIn = [CCFadeIn actionWithDuration:duration];
    id action = nil;
    if (fadeIn && distance != 0) {
      action = [CCSpawn actions:move, fadeIn, nil];
    }else if (fadeIn) {
      action = fadeIn;
    }else if (distance != 0) {
      action = move;
    }
    [self.portrait runAction:action];
  }
}

- (void)animateOutsidePortraitOutWithFadeOut:(BOOL)fadeOut
                                    distance:(CGFloat)distance
                                    duration:(ccTime)duration
{
  // Animate out outside portrait independently
  if (self.defaultPortraitSprite && !self.customizer.portraitInsideDialog)
  {
    // Calculate final position
    CGPoint finalPos = CGPointZero;
    CGPoint startPos = self.portrait.position;
    if (self.customizer.portraitPosition == kDialogPortraitPositionLeft) {
      finalPos = ccpSub(startPos, CGPointMake(distance, 0));
    }else {
      finalPos = ccpAdd(startPos, CGPointMake(distance, 0));
    }
    
    // Animate move and fade in
    id move = [CCMoveTo actionWithDuration:duration position:finalPos];
    id fadeOut = [CCFadeOut actionWithDuration:duration];
    id action = nil;
    if (fadeOut && distance != 0) {
      action = [CCSpawn actions:move, fadeOut, nil];
    }else if (fadeOut) {
      action = fadeOut;
    }else if (distance != 0) {
      action = move;
    }
    [self.portrait runAction:action];
  }
}


#pragma mark - Class methods

+ (void)setDefaultCustomizer:(DLDialogBoxCustomizer *)customizer
{
  defaultCustomizer = customizer;
}

+ (DLDialogBoxCustomizer *)defaultCustomizer
{
  return defaultCustomizer;
}


#pragma mark - Private methods

- (void)initializeDialogBoxWithCurrentCustomizer
{
  DLDialogBoxCustomizer *customizer = _customizer;
  
  // Update dialog position and anchor
  self.position = _customizer.dialogPosition;
  self.anchorPoint = _customizer.dialogAnchorPoint;
  
  // Create the dialog background image
  CGSize dialogSize = customizer.dialogSize;
  if (customizer.backgroundSpriteFrameName)
  {
    _bgSprite = [CCScale9Sprite spriteWithSpriteFrameName:customizer.backgroundSpriteFrameName];
    [_bgSprite setContentSize:dialogSize];
  }
  else if (customizer.backgroundSpriteFile)
  {
    _bgSprite = [CCScale9Sprite spriteWithFile:customizer.backgroundSpriteFile];
    [_bgSprite setContentSize:dialogSize];
  }
  else {
    // If no border just create choice dialog background
    _bgSprite = [CCSprite rectangleOfSize:dialogSize
                                    color:customizer.backgroundColor];
  }
  _bgSprite.anchorPoint = ccp(0, 0);
  _bgSprite.position = ccp(0, 0);
  [self.dialogContent addChild:_bgSprite z:kBackgroundSpriteZIndex];
  
  // Adjust label text position
  CGFloat labelY = dialogSize.height - customizer.dialogTextInsets.top;
  self.dialogLabel.position = ccp(customizer.dialogTextInsets.left, labelY);
  
  // If portrait is on the left and inside, we must adjust label position to make room
  if (self.defaultPortraitSprite && customizer.portraitInsideDialog &&
      customizer.portraitPosition == kDialogPortraitPositionLeft)
  {
    CGFloat x = customizer.portraitInsets.left + _defaultPortraitSprite.contentSize.width + \
    customizer.portraitInsets.right + customizer.dialogTextInsets.left;
    self.dialogLabel.position = ccp(x, labelY);
  }
  
  // Adjust label width to fit inside dialog
  CGFloat width = dialogSize.width - customizer.dialogTextInsets.left - \
  customizer.dialogTextInsets.right;
  if (self.defaultPortraitSprite && customizer.portraitInsideDialog) {
    width = width - _defaultPortraitSprite.contentSize.width - \
    customizer.portraitInsets.left - customizer.portraitInsets.right;
  }
//  [self.dialogLabel setWidth:width];
  
  // Adjust portrait image position
  CGSize portraitSize = _defaultPortraitSprite.contentSize;
  UIEdgeInsets portraitInsets = customizer.portraitInsets;
  if (customizer.portraitPosition == kDialogPortraitPositionLeft)
  {
    CGFloat x = portraitInsets.left;
    CGFloat y = portraitInsets.bottom;
    if (customizer.portraitInsideDialog) {
      y = dialogSize.height - portraitInsets.top - portraitSize.height;
    }
    self.portrait.position = ccp(x, y);
  }
  else
  {
    CGFloat x = dialogSize.width - portraitInsets.right - portraitSize.width;
    CGFloat y = portraitInsets.bottom;
    if (customizer.portraitInsideDialog) {
      y = dialogSize.height - portraitInsets.top - portraitSize.height;
    }
    self.portrait.position = ccp(x, y);
  }
  
  // Create our new page indicator
  self.pageFinishedIndicator = nil;
  if (customizer.pageFinishedIndicatorSpriteFrameName) {
    self.pageFinishedIndicator = [CCSprite spriteWithSpriteFrameName:customizer.pageFinishedIndicatorSpriteFrameName];
  }else if (customizer.pageFinishedIndicatorSpriteFile) {
    self.pageFinishedIndicator = [CCSprite spriteWithFile:customizer.pageFinishedIndicatorSpriteFile];
  }
  
  // Position and add our page finished indicator
  if (self.pageFinishedIndicator) {
    CCSprite *indicator = self.pageFinishedIndicator;
    indicator.anchorPoint = ccp(1, 0);
    
    // By default the indicator's insets uses the same one as the dialogTextInsets
    indicator.position = ccp(dialogSize.width - customizer.dialogTextInsets.right,
                             customizer.dialogTextInsets.bottom);
    
    // Handle when portrait is inside and on the right side
    if (customizer.portraitInsideDialog &&
        customizer.portraitPosition == kDialogPortraitPositionRight)
    {
      CGFloat x = dialogSize.width - self.defaultPortraitSprite.contentSize.width - \
      self.pageFinishedIndicator.contentSize.width - \
      customizer.portraitInsets.left - customizer.dialogTextInsets.right;
      indicator.position = ccp(x, customizer.dialogTextInsets.bottom);
    }
    
    indicator.visible = NO;
    [self.dialogContent addChild:indicator z:kPageIndicatorZIndex];
  }
}


#pragma mark - Method overrides

- (void)onEnter
{
  [super onEnter];
  
  // Start first page automatically on page enter.
  [self advanceToNextPage];
  
  // Custom on enter animations
  if (self.customizer.showAnimation) {
    self.customizer.showAnimation(self);
  }
  
  // Add touch dispatcher
  [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                            priority:kDialogBoxTouchPriority
                                                     swallowsTouches:YES];
}

- (void)onExit
{
  [super onExit];
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}


#pragma mark - DLAutoTypeLabelBMDelegate

- (void)autoTypeLabelBMTypingFinished:(DLAutoTypeLabelBM *)sender
{
  self.currentPageTyped = YES;
  
  // Show the choice dialog after all words are displayed and we have a choice dialog
  if (self.textArray.count == 0 && self.choiceDialog)
  {
    [self showChoiceDialog];
    
    // Inform delegate we finished all text
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogBoxAllTextFinished:)]) {
      [self.delegate dialogBoxAllTextFinished:self];
    }
  }
  
  // Inform delegate one page finished
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(dialogBoxCurrentTextPageFinished:currentPage:)]) {
    [self.delegate dialogBoxCurrentTextPageFinished:self currentPage:self.currentTextPage];
  }
  
  // Show page finished indicator after every page except last
  if (self.pageFinishedIndicator &&
      (self.textArray.count != 0 || !self.customizer.hidePageFinishedIndicatorOnLastPage))
  {
    self.pageFinishedIndicator.visible = YES;
    if (self.customizer.pageFinishedIndicatorAnimation) {
      self.customizer.pageFinishedIndicatorAnimation(self);
    }
  }
}


#pragma mark - DLChoiceDialogDelegate

- (void)choiceDialogLabelSelected:(DLChoiceDialog *)sender
                       choiceText:(NSString *)text
                      choiceIndex:(NSUInteger)index
{
  // Inform delegate
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(dialogBoxChoiceSelected:choiceText:choiceIndex:)])
  {
    [self.delegate dialogBoxChoiceSelected:self
                                choiceText:text
                               choiceIndex:index];
  }
  
  // Close dialog box when choice is selected
  if (self.customizer.closeWhenDialogFinished) {
    [self playHideAnimationOrRemoveFromParent];
  }
}


#pragma mark - CCTouchOneByOneDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  // If the dialog box shouldn't handle any input, we claim none and do nothing.
  if (!self.customizer.handleTapInputs) {
    return NO;
  }
  
  CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
  CGRect relativeRect = self.dialogContent.boundingBox;
  BOOL tapInDialogBox = CGRectContainsPoint(relativeRect, touchPoint);
  
  BOOL handleTap = YES;
  
  // Check if we should only respond to touch in dialog box
  if (self.customizer.handleOnlyTapInputsInDialogBox) {
    handleTap = tapInDialogBox;
  }
  
  // Dialog box should not handle any touches when choice dialogs is showing
  if (handleTap &&
      self.choiceDialog &&
      self.choiceDialog.parent &&
      self.choiceDialog.visible) {
    handleTap = NO;
  }
  
  if (handleTap) {
    // If tap to finish current page is enabled, we finish current page or advance
    // on touch input. If not, we only advance if current typing is finished.
    if (self.customizer.tapToFinishCurrentPage) {
      [self finishCurrentPageOrAdvance];
    }else if (self.currentPageTyped) {
      [self advanceToNextPage];
    }
  }
  
  BOOL shouldClaim = NO;
  
  if (self.customizer.swallowAllTouches) {
    shouldClaim = YES;
  }else {
    // Swallow all touches in dialog content by default
    if (tapInDialogBox) {
      shouldClaim = YES;
    }
  }

  return shouldClaim;
}


#pragma mark - Property Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  // Allows preselectEnabled to be changed even after the dialog is initialized
  if (self.customizer == object &&
      [keyPath isEqualToString:@"typingSpeed"] && self.dialogLabel)
  {
    // Update dialog label current typing delay
    self.dialogLabel.typingSpeed = self.customizer.typingSpeed;
  }
}

@end
