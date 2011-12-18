//
//  SoundEffect.h
//  Gopher
//
//  Created by Anthony Lobay on 7/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundEffect : NSObject {
    SystemSoundID _soundID;
}

+ (id)soundEffectWithContentsOfFile:(NSString *)aPath;
- (id)initWithContentsOfFile:(NSString *)path;
- (void)play;

@end