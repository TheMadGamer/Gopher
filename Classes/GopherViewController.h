//
//  GopherViewController.h
//  Gopher
//
//  Created by Anthony Lobay on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GopherView.h"

@protocol GopherViewControllerDelegate;

@interface GopherViewController : UIViewController <GopherViewDelegate, AVAudioPlayerDelegate> {
	
	IBOutlet GopherView *gopherView;	
	UIView *scoreView;
	UILabel *scoreLabel;
	
	UIView *mPauseView;
	
	UIView *mEndOfGameView;
	
	UIButton *audioButton;

	UIImageView *mInstructionsView;
	UIButton *mInstructionsButton;
	
	int mFrameIndex;
	
	id <GopherViewControllerDelegate> delegate;
	NSString *levelName;
	
	IBOutlet float tiltGravityCoef;
	IBOutlet bool offsetGravityEnabled;
	
	// looping audio
	AVAudioPlayer* mMusicPlayer;
	
}

@property (nonatomic, assign) IBOutlet GopherView *gopherView;
@property (nonatomic, assign) id <GopherViewControllerDelegate> delegate;
@property (nonatomic, assign) NSString *levelName;

@property (nonatomic, assign) float tiltGravityCoef;

@property (nonatomic, assign) bool offsetGravityEnabled;


- (IBAction) resumePushed:(id)sender;
- (IBAction) endOfGamePushed:(id)sender;
- (IBAction) restartPushed:(id)sender;
- (IBAction) audioButtonPushed:(id)sender;
- (IBAction) helpButtonPushed:(id)sender;
- (IBAction) nextInstructionFramePressed:(id)sender;
- (IBAction) nextLevelPushed:(id) sender;


// animates in a view
- (void) animateIn:(UIView*) animView;

-(void) exitLevel;
-(void) restartLevel;

// pause level decl'd in GopherViewDelegate protocol
-(void) resumeLevel;

- (void)pausePlayback;
- (void)resumePlayback;
- (void)startPlayback;
- (void) restartPlayback;

-(UILabel *) makeScoreLabel;

- (void)initStuff;
- (void)shutdownStuff;


@end


///////// Protocol for delegate ////////////
@protocol GopherViewControllerDelegate

- (void)gopherViewControllerDidFinish:(GopherViewController *)controller withResult:(NSString *)levelName;

// writes out the score for a win
- (void) writeScore:(int) score forLevel:(NSString*) levelName;

// gets the high score
- (int) getScore:(NSString*)levelName;

- (NSString*) getNextLevelName: (NSString*) currentLevelName;
- (void) setLevelPlayed:(NSString*) levelName played:(BOOL)played;

- (bool) isLastLevel: (NSString*) levelName;
- (bool) isBonusLevel: (NSString*) currentLevelName;

- (bool) isAudioOn;
- (void) setAudioOn:(bool) isOn;

@end