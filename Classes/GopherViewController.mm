//
//  GopherViewController.m
//  Gopher
//
//  Created by Anthony Lobay on 5/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GopherViewController.h"
#import "InstructionsViewController.h"

#import "PhysicsManager.h"
#import "GraphicsManager.h"
#import "GamePlayManager.h"
#import "SceneManager.h"
#import "AudioDispatch.h"

@implementation GopherViewController

@synthesize gopherView;
@synthesize delegate;
@synthesize levelName;


using namespace Dog3D;

@synthesize offsetGravityEnabled;
@synthesize tiltGravityCoef;

// pauses level
// puts up a bunch of buttons
- (void)pauseLevel
{
	[gopherView pauseGame];
	
	// attach subview
	// pause
	if(mPauseView == nil)
	{
		
		mPauseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[gopherView addSubview:mPauseView];
		
		// Rotates button views
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
		mPauseView.transform = transform;
		
		
		/*UIView *pauseGrayBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[pauseGrayBack setBackgroundColor:[UIColor grayColor]];
		[pauseGrayBack setAlpha:0.50];
		pauseGrayBack.transform = transform;
		[mPauseView addSubview:pauseGrayBack];*/

		/*CGRectMake(-80+60, 80+40, 360, 240)*/
		UIImageView *pauseBack = [[UIImageView alloc] initWithFrame:CGRectMake(-80, 80, 480, 320)];
		[pauseBack setImage:[UIImage imageNamed:@"PauseScreenHalf.png"]];
		//pauseBack.transform = transform;
		
		[mPauseView addSubview:pauseBack];
		
		// resume
		{
			UIButton *resumeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			[resumeButton setBackgroundImage:[UIImage imageNamed:@"Resume.png"] forState:UIControlStateNormal];
			[resumeButton addTarget:self action:@selector(resumePushed:) 
				   forControlEvents:UIControlEventTouchUpInside];
			
			
			CGRect rect = CGRectMake(246-80,146+80,161,52);
			[resumeButton setFrame:rect];
			
			[mPauseView addSubview:resumeButton];
		}
		
		// restart button
		{
			UIButton *restartButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[restartButton setBackgroundImage:[UIImage imageNamed:@"Restart.png"] forState:UIControlStateNormal];
			
			[restartButton addTarget:self action:@selector(restartPushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(150-80,80+80,174,53);
			[restartButton setFrame:rect];
			
			[mPauseView addSubview:restartButton];
			
		}
		
		
		{
			UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[exitButton setBackgroundImage:[UIImage imageNamed:@"ExitText2.png"] forState:UIControlStateNormal];
			
			[exitButton addTarget:self action:@selector(endOfGamePushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(72-80,146+80,112,52);
			[exitButton setFrame:rect];
			
			[mPauseView addSubview:exitButton];
			
		}
		
		
		{
			audioButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			if([delegate isAudioOn])
			{
				[audioButton setBackgroundImage:[UIImage imageNamed:@"SoundOn.png"] forState:UIControlStateNormal];
			}
			else
			{
				[audioButton setBackgroundImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
			}
			
			[audioButton addTarget:self action:@selector(audioButtonPushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
				
			CGRect rect = CGRectMake(60-16,276,32,32);
			[audioButton setFrame:rect];
			
			[mPauseView addSubview:audioButton];
			
		}
		
		{
			UIButton *helpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[helpButton setBackgroundImage:[UIImage imageNamed:@"InstructionsText.png"] forState:UIControlStateNormal];
			
			[helpButton addTarget:self action:@selector(helpButtonPushed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(150-80,207+80,160,64);
			[helpButton setFrame:rect];
			
			[mPauseView addSubview:helpButton];
			
		}
		
		[self animateIn:mPauseView];
	}
	

}

// resumes gameplay
- (void)resumeLevel
{
	[gopherView resumeGame];
	
	[mPauseView removeFromSuperview];
	[mPauseView release];
	mPauseView = nil;
	
	
}


- (void) exitLevel
{
	[gopherView endLevel];
	[gopherView stopAnimation];
		
	[delegate gopherViewControllerDidFinish:self withResult:@"Foo"];
}



- (void) restartLevel
{
	if(mEndOfGameView != nil)
	{
		[mEndOfGameView removeFromSuperview];
		[mEndOfGameView release];
		mEndOfGameView = nil;
	
	}
	if(mPauseView != nil)
	{
		[mPauseView removeFromSuperview];
		[mPauseView release];
		mPauseView = nil;
	}
	
	
	[gopherView reloadLevel];
	
}

- (UILabel *) makeScoreLabel
{
	int numGophers = [gopherView deadGophers];
	int numCarrots = [gopherView remainingCarrots];
	int currentScore = numCarrots * 20 + numGophers * 10;
	int currentHigh = [delegate getScore:[gopherView loadedLevel]];
	
	
	UILabel *highScoreLabel;
	UIImageView *carrot = [[UIImageView alloc] initWithFrame:CGRectMake(282, 32, 32, 32.0)];

	// TODO - pull orange, silver, gold carrots
	carrot.image = [UIImage imageNamed:@"Carrot32.png"];
	
	
	if(currentHigh < currentScore)
	{
		DLog(@"New High Score");
		[delegate writeScore:currentScore forLevel:[gopherView loadedLevel]];
		
		highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-240/2- 32,240-160/2 + 80,314,96)];
		NSString *formatString = @"Gophers: %i x 10 = %i\nCarrots: %i x 20 = %i\nNew High Score: %i";
		NSString *scoreString = [NSString stringWithFormat:formatString, numGophers, numGophers *10, numCarrots, numCarrots*20, currentScore];
		highScoreLabel.text = scoreString;
	}
	else 
	{	
		highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-240/2 - 32,240-160/2 + 80,314,96)];
		NSString *formatString = @"Gophers: %i x 10 = %i\nCarrots: %i x 20 = %i\nScore: %i";
		NSString *scoreString = [NSString stringWithFormat:formatString, numGophers, numGophers *10, numCarrots, numCarrots*20, currentScore];
		highScoreLabel.text = scoreString;
	}
	
	highScoreLabel.textAlignment = UITextAlignmentCenter;
	highScoreLabel.numberOfLines = 3;
	highScoreLabel.backgroundColor = [UIColor clearColor];
	highScoreLabel.font = [UIFont fontWithName:@"Marker Felt" size:24.0f];
	highScoreLabel.textColor = [UIColor orangeColor];
	highScoreLabel.shadowColor = [UIColor blackColor];
	highScoreLabel.shadowOffset = CGSizeMake(2,2);	
	
	[highScoreLabel addSubview:carrot];
	
	return highScoreLabel;
	
}

- (void) finishedLevel: (bool) playerWon
{

	// add subview try gain or whatever
	if(mEndOfGameView == nil)
	{
	
		mEndOfGameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
						  
		[gopherView addSubview:mEndOfGameView];
		
		// Rotates the score view
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
		mEndOfGameView.transform = transform;
		
		// win/try again
		UIImageView *mainLabel;
		if(playerWon)
		{
			mainLabel  = [[UIImageView alloc] initWithFrame:CGRectMake(160-240/2,240-160/2 - 48 ,240,160)]; 
			[mainLabel setImage:[UIImage imageNamed:@"LevelCleared.png"]];
			[mEndOfGameView addSubview:mainLabel];
			[mainLabel release];
			
			UILabel *highScoreLabel = [self makeScoreLabel];			
			[mEndOfGameView addSubview:highScoreLabel];
			[highScoreLabel release];
			
			
			// replay option
			{
				// exit button
				UIButton *restartButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[restartButton setBackgroundImage:[UIImage imageNamed:@"Restart.png"] forState:UIControlStateNormal];
				
				[restartButton addTarget:self action:@selector(restartPushed:) 
						forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(240,332,128,64);
				[restartButton setFrame:rect];
				
				[mEndOfGameView addSubview:restartButton];
				
			}
			
			// exit option
			// TODO - get isLastLevel from delegate
			if((![delegate isLastLevel:levelName])&& (! [delegate isBonusLevel:levelName]) )
			{
				// exit button
				UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[exitButton setBackgroundImage:[UIImage imageNamed:@"NextLevel.png"] forState:UIControlStateNormal];
				
				[exitButton addTarget:self action:@selector(nextLevelPushed:) 
					 forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(100,332,128,64);
				[exitButton setFrame:rect];
				
				[mEndOfGameView addSubview:exitButton];
				
			}
			
			// exit option
			{
				// exit button
				UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[exitButton setBackgroundImage:[UIImage imageNamed:@"ExitText2.png"] forState:UIControlStateNormal];
				
				[exitButton addTarget:self action:@selector(endOfGamePushed:) 
					 forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(-20,332,128,64);
				[exitButton setFrame:rect];
				
				[mEndOfGameView addSubview:exitButton];
				
			}
			
			
		}
		else 
		{
			// replay option
			{
				// exit button
				UIButton *restartButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[restartButton setBackgroundImage:[UIImage imageNamed:@"TryAgain.png"] forState:UIControlStateNormal];
				
				[restartButton addTarget:self action:@selector(restartPushed:) 
						forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake (252-80,280,160,64);
				[restartButton setFrame:rect];
				
				[mEndOfGameView addSubview:restartButton];
				
			}
			
			// exit option
			{
				// exit button
				UIButton *exitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
				
				[exitButton setBackgroundImage:[UIImage imageNamed:@"ExitText2.png"] forState:UIControlStateNormal];
				
				[exitButton addTarget:self action:@selector(endOfGamePushed:) 
					 forControlEvents:UIControlEventTouchUpInside];
				
				CGRect rect = CGRectMake(72-80,280,128,64);
				[exitButton setFrame:rect];
				
				[mEndOfGameView addSubview:exitButton];
				
			}

			
		}

		
		[self animateIn:mEndOfGameView];
	}
}


// animate in landing view
- (void) animateIn:(UIView*) animView
{
	int x = animView.frame.origin.x;
	
	animView.frame = CGRectMake(-animView.frame.size.width, 
								animView.frame.origin.y, 
								animView.frame.size.width, 
								animView.frame.size.height);
	
	[UIView beginAnimations:@"GameViewAnimation" context:nil];
	animView.frame = CGRectMake(x, 
								   animView.frame.origin.y, 
								   animView.frame.size.width, 
								   animView.frame.size.height);
	[UIView commitAnimations];
}

#pragma mark ACTIONS


- (IBAction) resumePushed:(id)sender
{
	[self resumeLevel];
}

- (IBAction) endOfGamePushed:(id)sender
{
	[self exitLevel];
}

- (IBAction) nextLevelPushed:(id) sender
{
	
	if([delegate isLastLevel:levelName])
	{
		DLog(@"MASSIVE FAIL!");
	}
	else {
		[mEndOfGameView removeFromSuperview];
		[mEndOfGameView release];
		mEndOfGameView = nil;
		
		levelName = [delegate getNextLevelName:levelName];
		
		// load next level		
		[gopherView startAnimation];
		[gopherView loadLevel:levelName];
		
	}

	
}

- (IBAction) restartPushed:(id)sender
{
	[self restartLevel];
}

-(IBAction) audioButtonPushed:(id)sender
{
	[delegate setAudioOn: ![delegate isAudioOn]];
	
	if([delegate isAudioOn])
	{
		[audioButton setImage:[UIImage imageNamed:@"SoundOn.png"] forState:UIControlStateNormal];
		[self resumePlayback];
		AudioDispatch::Instance()->SetAudioOn(true);
	}
	else
	{
		[audioButton setImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
		[self pausePlayback];
		AudioDispatch::Instance()->SetAudioOn(false);
	}
}

-(IBAction) helpButtonPushed:(id)sender
{
	if(mInstructionsView == nil)
	{
		mInstructionsView = [[UIImageView alloc] initWithFrame:CGRectMake(-80, 80, 480, 320)];
		
		[gopherView addSubview:mInstructionsView];
		
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2.0);
		mInstructionsView.transform = transform;
		
		mInstructionsView.image = [UIImage imageNamed:@"Instructions_Intro.png"];
		
		{
			mInstructionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
			
			[mInstructionsButton setImage:[UIImage imageNamed:@"ArrowButtonGold32.png"] forState:UIControlStateNormal];
			
			[mInstructionsButton addTarget:self action:@selector(nextInstructionFramePressed:) 
				 forControlEvents:UIControlEventTouchUpInside];
			
			CGRect rect = CGRectMake(60,400,32,32);
			[mInstructionsButton setFrame:rect];
			
			mInstructionsButton.transform = transform;
			
			[gopherView addSubview:mInstructionsButton];
			mFrameIndex = 1;
			
		}
		
	}
}

#pragma mark SCORE

- (void) updateScore: (int) score withDead:(int) nDead andTotal:(int) total
{
	if(scoreLabel != nil)
	{
        if(total > 1)
        {
            scoreLabel.text = [NSString stringWithFormat: @"Gophers: %d/%d", nDead, total];
        }
        else
        {
            scoreLabel.text = @"";
        }
    }
}

- (void) updateScore: (int) score withDead:(int) nDead andTotal:(int) total andBallsLeft:(int) ballsLeft
{
	if(scoreLabel != nil)
	{
		scoreLabel.text = [NSString stringWithFormat: @"Gophers: %d/%d Balls: %d", nDead, total, ballsLeft];
	}
}


#pragma mark LOADUP
// for initializing during splash load up
// message the delegate that we're done
- (void)finishedLoadUp
{
	
	[gopherView pauseGame];
	[gopherView stopAnimation];
	[delegate gopherViewControllerDidFinish:self withResult:@"Splash"];
}

 
#pragma mark LOAD AND APPEAR

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// called 1x in lifetime
- (void)viewDidLoad {
	[super viewDidLoad];
	 
	DLog(@"--> Gopher View Did Load");
	
	//gopherView.animationInterval = 1.0 / 60.0;
	
	if(![gopherView isEngineInitialized])
	{
		DLog(@"Init Engine");
		[gopherView initEngine];
	}
	[gopherView setGopherViewController:self];
	
}

- (void)initStuff 
{
	DLog(@"--> GViewC will appear");
	
	if( (![levelName isEqualToString:@"Splash"]) && [delegate isAudioOn])
	{
		[self startPlayback];
	}
	
	if(![levelName isEqualToString:@"Splash"])
	{
		AudioDispatch::Instance()->SetAudioOn([delegate isAudioOn]);
	}
	
	gopherView.animationInterval = 1.0 / 60.0;
	
	[gopherView startAnimation];
	[gopherView loadLevel:levelName];
	
	DLog(@"--> GViewC did appear");
	
	[[self view] setFrame:CGRectMake(0,0,320, 480)];
	
	if(mEndOfGameView != nil)
	{
		[mEndOfGameView removeFromSuperview];
		[mEndOfGameView release];
		mEndOfGameView = nil;
	}
	
	if(mInstructionsView != nil)
	{
		[mInstructionsView removeFromSuperview];
		[mInstructionsView release];
		mInstructionsView = nil;
		
	}
	
	[[UIApplication sharedApplication ] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	
	
	// add score overlay
	scoreView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
	[gopherView addSubview:scoreView];

	// Rotates the score view
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	scoreView.transform = transform;
	
	// add score label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0,256, 32)];
	label.text = @"";
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithName:@"Marker Felt" size:17.0f];
	label.textColor = [UIColor orangeColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(2,2);	
	
	{
		/// TODO - extract into fcn
		int score = GamePlayManager::Instance()->ComputeScore();
		int deadGophs = GamePlayManager::Instance()->GetDeadGophers(); 
		int totalGophs = GamePlayManager::Instance()->GetTotalGophers();
		int ballsLeft = GamePlayManager::Instance()->GetNumBallsLeft();
		
		if(GamePlayManager::Instance()->GetGamePlayMode() == GamePlayManager::RICOCHET)
		{
			// update score if it has changed
			[ self updateScore: score withDead:deadGophs andTotal: totalGophs andBallsLeft:ballsLeft];
			
		}
		else
		{
			
			// update score if it has changed
			[ self updateScore: score withDead:deadGophs andTotal: totalGophs];
			
		}
	}
	
	scoreLabel = label;	
	
	[scoreView addSubview:label];
	
	
	// TODO- this was removed - show an image in the GopherView and respond to the touch event there
	// add exit button
	/*UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain]; 	

	[button setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];
	
	[button addTarget:self action:@selector(pausePushed:) 
	 forControlEvents:UIControlEventTouchUpInside];

	CGRect frame = scoreView.frame;
	frame.size.height = 480;
	scoreView.frame = frame;

	// this is a bit absurd
	// the frame stuff is done in world space
	CGRect rect = CGRectMake( scoreView.frame.size.height - 32, 12,32,32);
	[button setFrame:rect];
	 */
	
	// this is needed to keep the overlay from making this single touch
	[scoreView setMultipleTouchEnabled:YES];
	
	//[scoreView addSubview:button];
	
}

-(void)shutdownStuff 
{
	DLog(@"--> Gopher View Ctlr will disappear");
	
	if(mMusicPlayer != nil)
	{
		[mMusicPlayer pause];
		[mMusicPlayer release];
		mMusicPlayer = nil;
		
	}
	
	[scoreLabel release];
	scoreLabel = nil;
	
	[scoreView removeFromSuperview];
	[scoreView release];
	scoreView = nil;
	
	if(mPauseView != nil)
	{
		[mPauseView removeFromSuperview];
		[mPauseView release];
		mPauseView = nil;
	}
	
	if(mInstructionsView != nil)
	{
		
		[mInstructionsView removeFromSuperview];
		[mInstructionsView release];
		mInstructionsView = nil;
		
	}
	if(mInstructionsButton != nil)
	{
		
		[mInstructionsButton removeFromSuperview];
		mInstructionsButton = nil;
		
	}
	
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
}



#pragma mark MUSIC

- (void)startPlayback {
	
    if(!mMusicPlayer){
        /*
         * Here we grab our path to our resource
         */
        NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
        resourcePath = [resourcePath stringByAppendingString:@"/FeelinGood4.caf"];
        DLog(@"Path to play: %@", resourcePath);
        NSError* err;
		
        //Initialize our player pointing to the path to our resource
        mMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
				   [NSURL fileURLWithPath:resourcePath] error:&err];
		
        if( err ){
            //bail!
            DLog(@"Failed with reason: %@", [err localizedDescription]);
        }
        else{
            //set our delegate and begin playback
            mMusicPlayer.delegate = self;
            [mMusicPlayer play];
        }
    }
	else {
		[mMusicPlayer play];
	}
	
}

- (void)pausePlayback {
	
    DLog(@"Player paused at time: %f", mMusicPlayer.currentTime);
	if( mMusicPlayer)
	{
		[mMusicPlayer pause];
	}
}

- (void)resumePlayback
{	
	if( mMusicPlayer)
	{
		[mMusicPlayer play];
	}
	else {
		[self startPlayback];
	}
	
}

- (void) restartPlayback
{
	
	if(mMusicPlayer)
	{
		mMusicPlayer.currentTime = 0;
		[mMusicPlayer play];
	}
	else {
		[self startPlayback];
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	
	[self restartPlayback];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
	
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (IBAction) nextInstructionFramePressed:(id)sender
{
	if(mInstructionsView == nil)
	{
		return;
	}
	
	if(mFrameIndex == 3)
	{
		[mInstructionsView removeFromSuperview];
		[mInstructionsView release];
		mInstructionsView = nil;				
		
		[mInstructionsButton removeFromSuperview];
		mInstructionsButton = nil;
		
		[self resumeLevel];
		mFrameIndex = 1;
	}
	else {
		
		NSString *path = [[NSBundle mainBundle] bundlePath];
		
		NSString *finalPath = [path stringByAppendingPathComponent:[gopherView loadedLevel] ];
		NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		
		NSDictionary *controlDictionary = [[rootDictionary objectForKey:@"LevelControl"] retain];
		
		SceneManager::LevelControlInfo levelControl(controlDictionary);
		
		
		mFrameIndex++;
		
		NSString* imageName;
		if(mFrameIndex == 2)
		{
			imageName = @"Instructions_Goal.png";
		}
		else {
			
			if(levelControl.mPlayMode == GamePlayManager::CANNON ||
			   levelControl.mPlayMode == GamePlayManager::SWARM_CANNON ||
			   levelControl.mPlayMode == GamePlayManager::RUN_CANNON ||
			   levelControl.mPlayMode == GamePlayManager::RICOCHET)
			{
				imageName = @"Instructions_Cannon.png";
			}
			else if(levelControl.mPlayMode == GamePlayManager::POOL)
			{
				imageName = @"Instructions_Tap.png";
			}
			else {
				imageName = @"Instructions_Tilt.png";
			}
			
		}
		
		
		mInstructionsView.image = [UIImage imageNamed:imageName];
		[controlDictionary release];
	}
}

@end
