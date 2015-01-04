#import "ChatBox.h"
#import "DLDialogBox.h"
#import "DLDialogPresets.h"


@implementation ChatBox

- (void) setWithNPC:(NSString *)npc text:(NSString *)text{
    
    DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
    
    // Others
    customizer.portraitInsideDialog = YES;
    customizer.typingSpeed = kTypingSpeedNormal;
    customizer.dialogSize = CGSizeMake(customizer.dialogSize.width, 100);
    customizer.dialogTextInsets = UIEdgeInsetsMake(7, 10, 7, 10);
    
    // Go through our customizer presets
    customizer = [DLDialogPresets dialogBoxCustomizerWithPresets:
                  @[@(kCustomizerWithDialogOnTop),
                    @(kCustomizerWithDialogLeftAligned),
                    @(kCustomizerWithFadeAndSlideAnimationFromTop),
                    @(kCustomizerWithFancyUI),
                    @(kCustomizerWithRetroSounds)] baseCustomizer:customizer];
    
    DLDialogBox *third = [DLDialogBox dialogWithTextArray:@[text]
                                                  choices:nil
                                          defaultPortrait:nil
                                               customizer:customizer];
    third.prependText = npc;

    [self addChild:third z:1];
}


@end
