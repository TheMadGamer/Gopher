//
//  GopherGameController.h
//  Gopher
//
//  Created by Anthony Lobay on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"
#import "InstructionsViewController.h"
#import "GopherViewController.h"
#import "ScoresViewController.h"
#import "LevelPackPurchaseVC.h"

#if USE_OF
#import "OpenFeint.h"
#endif

@interface GopherGameController : UIViewController <PreferencesViewControllerDelegate, 
	InstructionsViewControllerDelegate, GopherViewControllerDelegate, 
	AVAudioPlayerDelegate,
	ScoresViewDelegate,
#if USE_OF
 OpenFeintDelegate,
#endif
	UIAlertViewDelegate,
	SKProductsRequestDelegate,
	LevelUnlockDelegate>
{

	// play, sound, scores
	IBOutlet UIView *mLandingView;
		
	// what's this?
	IBOutlet UIImageView *mSplashView;
	
	// what's this?
	IBOutlet UIView *mBackgroundView;
	
	IBOutlet UIButton *mMuteButton;
		
	IBOutlet UIButton *mScoresButton;
		
	// gopher game view	
	IBOutlet GopherViewController *mGopherViewController;

	int mSplashFrame;

	bool mAudioIsOn;
		
	bool mFinishedGLInit;
		
	pthread_mutex_t mutex;	
	
	AVAudioPlayer* mPlayer;

	bool mFirstAppearance;
		
	NSArray *levels;
	
	NSString *lastLevelName;
		
}

+ (NSString *) levelPlist;

@property (readonly) NSString *playedLevelsFileName;
@property (readonly) NSString *highScoresFileName;
@property (nonatomic, retain) LevelPackPurchaseVC *levelPackVC;

- (IBAction)mutePressed;

- (IBAction)play;

- (IBAction) scoresPressed;

- (IBAction) instructionsPressed;

- (IBAction) buyMoreLevelsPressed;

- (void) animateIn;

- (void) showGopherView:(NSString*) levelName;

- (void) showInstructionsView:(NSString *) levelName;

- (void) showScoresView;

- (void) setLevelPlayed:(NSString *)levelName played:(BOOL)played;

- (BOOL) isLevelPlayed:(NSString *)levelName;

- (bool) isLevelUnlockedFromName:(NSString *)currentLevelName;

// for anything returning that doesn't need special handling
- (void) genericViewControllerDidFinish;

/////// AUDIO ///////////

- (bool) isAudioOn;

- (void) setAudioOn:(bool) isOn;

- (void) pausePlayback;
- (void) resumePlayback;
- (void) startPlayback;
- (void) restartPlayback;


- (void) appPaused;
- (void) appResumed;

@end
