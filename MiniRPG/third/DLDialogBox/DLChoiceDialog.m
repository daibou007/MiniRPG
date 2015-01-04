//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import "DLChoiceDialog.h"
#import "CCSprite+GLBoxes.h"
#import "DLSelectableLabel.h"
#import "CCScale9Sprite.h"

@implementation DLChoiceDialogCustomizer

- (id)copyWithZone:(NSZone *)zone
{
  DLChoiceDialogCustomizer *another = [[self class] allocWithZone:zone];
  another.dialogPosition = self.dialogPosition;
  another.dialogAnchorPoint = self.dialogAnchorPoint;
  another.backgroundSpriteFile = [self.backgroundSpriteFile copyWithZone:zone];
  another.backgroundSpriteFrameName = [self.backgroundSpriteFrameName copyWithZone:zone];
  another.backgroundColor = self.backgroundColor;
  another.fntFile = [self.fntFile copyWithZone:zone];
  another.contentInsets = self.contentInsets;
  another.spacingBetweenChoices = self.spacingBetweenChoices;
  another.labelCustomizer = [self.labelCustomizer copyWithZone:zone];
  another.preselectEnabled = self.preselectEnabled;
  another.swallowAllTouches = self.swallowAllTouches;
  another.closeWhenChoiceSelected = self.closeWhenChoiceSelected;
  another.preselectSoundFileName = [self.preselectSoundFileName copyWithZone:zone];
  another.selectedSoundFileName = [self.selectedSoundFileName copyWithZone:zone];
  another.showAnimation = self.showAnimation;
  another.hideAnimation = self.hideAnimation;
  return another;
}

+ (DLChoiceDialogCustomizer *)defaultCustomizer
{
  DLChoiceDialogCustomizer *customizer = [[DLChoiceDialogCustomizer alloc] init];
  
  // Look
  customizer.dialogPosition = ccp(0, 0);
  customizer.dialogAnchorPoint = ccp(0, 0);
  customizer.backgroundColor = ccc4(0, 0, 0, 0.8*255);
  customizer.fntFile = @"DLDialogBox.bundle/dldialogbox_default_fnt.fnt";
  customizer.contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
  customizer.spacingBetweenChoices = 5.0;
  customizer.labelCustomizer = [DLSelectableLabelCustomizer defaultCustomizer];
  
  // Functionalities
  customizer.preselectEnabled = YES;
  customizer.swallowAllTouches = NO;
  customizer.closeWhenChoiceSelected = YES;
  
  return customizer;
}

+ (DLAnimationBlock)customShowAnimationWithStartPosition:(CGPoint)startPos
                                           finalPosition:(CGPoint)finalPos
                                                  fadeIn:(BOOL)fadeIn
                                                duration:(ccTime)duration
{
  return ^(DLChoiceDialog *dialog)
  {
    // Run fade
    if (fadeIn) {
      [dialog fadeInWithDuration:duration];
    }
    
    // Run move
    if (!CGPointEqualToPoint(startPos, finalPos)) {
      dialog.position = startPos;
      id move = [CCMoveTo actionWithDuration:duration position:finalPos];
      [dialog runAction:move];
    }
  };
}

+ (DLAnimationBlock)customHideAnimationWithFinalPosition:(CGPoint)finalPos
                                                 fadeOut:(BOOL)fadeOut
                                                duration:(ccTime)duration
{
  return ^(DLChoiceDialog *dialog)
  {
    // Run fade
    if (fadeOut) {
      [dialog fadeOutWithDuration:duration];
    }
    
    // Run move
    if (!CGPointEqualToPoint(dialog.position, finalPos)) {
      id move = [CCMoveTo actionWithDuration:duration position:finalPos];
      [dialog runAction:move];
    }
    
    // Remove the choice dialog after done
    [dialog removeFromParentAndCleanupAfterDelay:duration];
  };
}

@end

@interface DLChoiceDialog ()
@property (nonatomic, strong) CCNode *bgSprite;
@property (nonatomic, copy) NSArray *labels;

- (void)updateChoiceDialogUI;
@end

@implementation DLChoiceDialog

- (void)dealloc
{
  for (DLSelectableLabel *label in self.labels) {
    label.delegate = nil;
  }
  self.delegate = nil;
  [self.customizer removeObserver:self forKeyPath:@"preselectEnabled"];
  [self.customizer removeObserver:self forKeyPath:@"preselectSoundFileName"];
  [self.customizer removeObserver:self forKeyPath:@"selectedSoundFileName"];
}

+ (id)dialogWithChoices:(NSArray *)choices
{
  return [[self alloc] initWithChoices:choices
                      dialogCustomizer:[DLChoiceDialogCustomizer defaultCustomizer]];
}

+ (id)dialogWithChoices:(NSArray *)choices
       dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer
{
  return [[self alloc] initWithChoices:choices
                      dialogCustomizer:dialogCustomizer];
}


- (id)initWithChoices:(NSArray *)choices
     dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer
{
  if (self = [super init])
  {
    _customizer = dialogCustomizer;
    
    // Observe for customizer changes
    [self.customizer addObserver:self
                      forKeyPath:@"preselectEnabled"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    [self.customizer addObserver:self
                      forKeyPath:@"preselectSoundFileName"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    [self.customizer addObserver:self
                      forKeyPath:@"selectedSoundFileName"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    // This generates our labels and then update UI according to them
    self.choices = choices;
  }
  
  return self;
}


#pragma mark - Property setter overrides

- (void)setCustomizer:(DLChoiceDialogCustomizer *)customizer
{
  if (_customizer != customizer) {
    _customizer = customizer;
    
    // Update UI of content only if have content generated after setting choices
    if (self.labels && self.labels.count > 0) {
      [self updateChoiceDialogUI];
    }
  }
}

- (void)setChoices:(NSArray *)choices
{
  if (_choices != choices) {
    _choices = choices;
    
    // Remove all existing choice labels
    for (DLSelectableLabel *label in self.labels) {
      [label removeFromParentAndCleanup:YES];
      label.delegate = nil;
    }
    
    // Make choice labels
    _customizer.labelCustomizer.preselectEnabled = _customizer.preselectEnabled;
    _customizer.labelCustomizer.preselectSoundFileName = _customizer.preselectSoundFileName;
    _customizer.labelCustomizer.selectedSoundFileName = _customizer.selectedSoundFileName;
    NSMutableArray *allLabels = [NSMutableArray arrayWithCapacity:_choices.count];
    for (int i = 0; i < _choices.count; i++) {
      NSString *choice = [_choices objectAtIndex:i];
      
      DLSelectableLabel *label = [[DLSelectableLabel alloc]
                                  initWithText:choice
                                  fntFile:_customizer.fntFile
                                  cutomizer:_customizer.labelCustomizer];
      label.anchorPoint = ccp(0, 1); // top left corner is anchor
      label.delegate = self;
      label.tag = i;
      [self addChild:label z:1];
      [allLabels addObject:label];
    }
    self.labels = [allLabels copy];

    // Update all choice labels on screen according to current customizer
    [self updateChoiceDialogUI];
  }
}

#pragma mark - Public methods

- (void)selectChoiceAtIndex:(NSUInteger)index skipPreselect:(BOOL)skipPreselect
{
  DLSelectableLabel *targetLabel = [self.labels objectAtIndex:index];
  if (targetLabel.customizer.preselectEnabled && skipPreselect) {
    [targetLabel selectWithoutPreselect];
  }else {
    [targetLabel select];
  }
}

- (void)removeFromParentAndCleanupAfterDelay:(ccTime)delay
{
  // If delay is 0, remove from parent immediately
  if (delay <= 0) {
    [self removeFromParentAndCleanup:YES];
    return;
  }
  
  // Remove after delay
  __weak DLChoiceDialog *weakSelf = self;
  id removeBlock = [CCCallBlock actionWithBlock:^() {
    [weakSelf removeFromParentAndCleanup:YES];
  }];
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:delay],
                   removeBlock, nil]];
}

- (void)playHideAnimationOrRemoveFromParent;
{
  if (self.customizer.hideAnimation) {
    self.customizer.hideAnimation(self);
  }else {
    [self removeFromParentAndCleanup:YES];
  }
}

- (void)fadeInWithDuration:(ccTime)duration
{
  id fade = [CCFadeIn actionWithDuration:duration];
  [self.bgSprite runAction:fade];
  for (DLSelectableLabel *label in self.labels) {
    [label fadeInWithDuration:duration];
  }
}

- (void)fadeOutWithDuration:(ccTime)duration
{
  id fade = [CCFadeOut actionWithDuration:duration];
  [self.bgSprite runAction:fade];
  for (DLSelectableLabel *label in self.labels) {
    [label fadeOutWithDuration:duration];
  }
}


#pragma mark - Private methods

- (void)updateChoiceDialogUI
{
  if (!self.labels || self.labels.count == 0) {
    return;
  }
  
  // Update choice dialog position and anchor
  self.position = _customizer.dialogPosition;
  self.anchorPoint = _customizer.dialogAnchorPoint;
  
  // First update all label styling and find out largest label width
  CGFloat largestLabelWidth = .0f;
  for (DLSelectableLabel *label in self.labels)
  {
    // Update label styling (does nothing if customizer is same)
    label.customizer = self.customizer.labelCustomizer;
    
    // Find the largest label width
    CGFloat labelWidth = label.contentSize.width;
    if (labelWidth > largestLabelWidth) {
      largestLabelWidth = labelWidth;
    }
  }
  
  // Update choice dialog contentSize
  NSUInteger totalChoices = _choices.count;
  DLSelectableLabel *oneLabel = [self.labels objectAtIndex:0];
  UIEdgeInsets contentInsets = _customizer.contentInsets;
  CGFloat totalHeight = contentInsets.top + contentInsets.bottom + \
                        totalChoices * oneLabel.contentSize.height +
                        _customizer.spacingBetweenChoices * (totalChoices - 1);
  CGFloat totalWidth = largestLabelWidth + contentInsets.left + contentInsets.right;
  self.contentSize = CGSizeMake(totalWidth, totalHeight);
  
  // Position all labels and adjust to common largest width
  CGFloat heightOffset = totalHeight - contentInsets.top;
  for (int i = 0; i < _choices.count; i++)
  {
    DLSelectableLabel *label = [self.labels objectAtIndex:i];
    
    // Normalize width of all choice labels
    // Change all label width to match the largest label width
    [label setWidth:largestLabelWidth];
    
    // Reposition all labels
    label.position = ccp(contentInsets.left, heightOffset);
    
    // Set the y position of the next label
    heightOffset = heightOffset - label.contentSize.height - _customizer.spacingBetweenChoices;
  }
  
  // Remove any existing background sprite
  if (_bgSprite) {
    [_bgSprite removeFromParentAndCleanup:YES];
  }
  
  // Update dialog background
  if (_customizer.backgroundSpriteFrameName)
  {
    _bgSprite = [CCScale9Sprite spriteWithSpriteFrameName:_customizer.backgroundSpriteFrameName];
    [_bgSprite setContentSize:self.contentSize];
  }
  else if (_customizer.backgroundSpriteFile)
  {
    _bgSprite = [CCScale9Sprite spriteWithFile:_customizer.backgroundSpriteFile];
    [_bgSprite setContentSize:self.contentSize];
  }
  else {
    // If no border just create choice dialog background
    _bgSprite = [CCSprite rectangleOfSize:self.contentSize
                                    color:_customizer.backgroundColor];
  }
  _bgSprite.anchorPoint = ccp(0, 0);
  _bgSprite.position = ccp(0, 0);
  [self addChild:_bgSprite z:0];
}


#pragma mark - DSSelectableLabel Delegate

- (void)selectableLabelPreselected:(DLSelectableLabel *)sender
{
  // When a label is preselected in a dialog, we deselect all other labels
  for (DLSelectableLabel *label in self.labels) {
    if (![label isEqual:sender]) {
      [label deselect];
    }
  }
  
  // Inform delegate
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(choiceDialogLabelPreselected:choiceText:choiceIndex:)]) {
    [self.delegate choiceDialogLabelPreselected:self
                                     choiceText:sender.text.string
                                    choiceIndex:sender.tag];
  }
}

- (void)selectableLabelSelected:(DLSelectableLabel *)sender
{
  // Inform delegate
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(choiceDialogLabelSelected:choiceText:choiceIndex:)])
  {
    [self.delegate choiceDialogLabelSelected:self
                                  choiceText:sender.text.string
                                 choiceIndex:sender.tag];
  }
  
  // Close choice dialog if specified
  if (self.customizer.closeWhenChoiceSelected) {
    [self playHideAnimationOrRemoveFromParent];
  }
}


#pragma mark - Transitions

- (void)onEnter
{
  [super onEnter];
  
  // Play any show animations
  if (self.customizer.showAnimation) {
    self.customizer.showAnimation(self);
  }
  
  // Listen for touch events
  [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                            priority:kChoiceDialogTouchPriority
                                                     swallowsTouches:YES];
}

- (void)onExit
{
  [super onExit];
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}


#pragma mark - CCTouchOneByOneDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  if (self.customizer.swallowAllTouches) {
    return YES;
  }
  
  // Swallow all touches inside dialog
  CGPoint touchPoint = [self convertTouchToNodeSpace:touch];
  CGRect relativeRect = self.bgSprite.boundingBox;
  if (CGRectContainsPoint(relativeRect, touchPoint)) {
    return YES;
  }
  
  return NO;
}


#pragma mark - Property Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  // Update label's customizer when this customizer changes
  if (self.customizer == object && self.labels)
  {
    for (DLSelectableLabel *label in self.labels) {
      id newValue = [self.customizer valueForKey:keyPath];
      [label.customizer setValue:newValue forKey:keyPath];
    }
  }
}

@end
