//
//  GameSounds.mm


#import "GameSounds.h"
#import "SimpleAudioEngine.h"



@implementation GameSounds


static GameSounds *sharedGameSounds = nil;

//场景初始化

-(id) init
{
  
  if ((self = [super init] ))
  {
    
  }
  return self;
  
}

//单例类方法

+(GameSounds*) sharedGameSounds {
  
  if (sharedGameSounds == nil) {
    sharedGameSounds = [[GameSounds alloc] init];
    
  }
  
  return sharedGameSounds;
}

//预加载游戏中所需的音效

-(void) preloadSounds {
  
//  [[SimpleAudioEngine sharedEngine] preloadEffect:@"bird.mp3"];

  
}



//禁用音效
-(void) disableSoundEffect {
  

  
}
//启用音效
-(void) enableSoundEffect {
  

}




//播放音效
-(void) playSoundEffect:(NSString*)fileName {
  
//  if ( [GameData sharedData].soundEffectMuted  == NO ) {
    
    [[SimpleAudioEngine sharedEngine] playEffect:fileName];
    
//  }
  
}


//
////在一定的延迟时间后播放音效
//
//-(void) playSoundEffect:(NSString*)fileName WithDelay:(float)delayTime {
//  
//  if ( [GameData sharedData].soundEffectMuted  == NO ) {
//    
//    delayedSoundEffectName = fileName;
//    [self performSelector:@selector(playThisAfterDelay) withObject:nil afterDelay:delayTime];
//    
//    
//  }
//  
//}





//介绍标签音效

-(void) playIntroSound {
  
//  if ( [GameData sharedData].soundEffectMuted  == NO ) {
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"gong.mp3"];
    
//  }
  
  
}



//播放背景音乐

-(void) playBackgroundMusic{
  
  
  [[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
  
//  if ( [GameData sharedData].backgroundMusicMuted  == NO ) {
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"soft.mp3" loop:YES];
    [CDAudioManager sharedManager].backgroundMusic.volume = 0.15f;
//  }
  
  
  
}

-(void) playBackgroundMusic:(NSString*)str{
    
    [[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:str loop:YES];
    [CDAudioManager sharedManager].backgroundMusic.volume = 0.15f;
    
}

//停止背景音乐

-(void) stopBackgroundMusic {
  
  [[CDAudioManager sharedManager] setMode:kAMM_FxOnly];
  
  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic ];
  
  
  
  
}

//重启背景音乐

-(void) restartBackgroundMusic {
  
  [self playBackgroundMusic];
}








@end
