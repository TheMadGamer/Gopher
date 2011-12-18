//
//  GopherView.m
//  Gopher
//
//  Copyright 2010 3dDogStudios. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

#import <vector>

#import <btBulletDynamicsCommon.h>

#import "GopherView.h"

#import "GameEntityFactory.h"

#import "PhysicsManager.h"
#import "GraphicsManager.h"
#import "GamePlayManager.h"
#import "SceneManager.h"
#import "AudioDispatch.h"

#import "FakeGLU.h"

#import "TriggerComponent.h"

using namespace Dog3D;
using namespace std;

const float kBallRadius = 0.5;

float kWallHeight = 1;

@implementation GopherView

@synthesize gopherViewController;

@synthesize offsetGravityEnabled;

@synthesize tiltGravityCoef;

- (id) initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder])
	{
		
		srand(time(0));
		
		boundWidth = 20.0;
		boundHeight = 30.0; 
		boundDepth = 4.0;
		
		fpsTime = 0;
		fpsFrames = 0;
		
		physFrames = 0;
		physTime = 0;
		
		zEye = 40;
		delayFrames = 0;
		
		mViewState = LOAD;
		
		mScore = -1;
		mTotalGophers = -1;
		mDeadGophers = -1;
		mNumBallsLeft = -1;
		
		touchStartTime = 0;
		touchStart.setZero();
		
		touchMode = CANNON;
		touchStarted = false;
		graphics3D = false;

		lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];
		lastAccelInterval = [NSDate timeIntervalSinceReferenceDate];
		
		mEngineInitialized = false;
		
		offsetGravityEnabled = true;
		tiltGravityCoef = 20.0f;
		
		fX = 0;
		fY = 0;
			
		
	}
	
	return self;
}

- (void) setGraphics3D:(bool) set3D
{
	graphics3D = set3D;
	GraphicsManager::Instance()->SetGraphics3D(set3D);
}


- (void) pauseGame
{
	mViewState = PAUSE;
}

- (void) resumeGame
{
	mViewState = PLAY;
}

- (void) initEngine
{
	if(mEngineInitialized)
	{
		return;
	}
	
	PhysicsManager::Initialize();
	GraphicsManager::Initialize();
	GamePlayManager::Initialize();
	SceneManager::Initialize();
	AudioDispatch::Initialize();
	
	mEngineInitialized = true;
}

-(bool) isEngineInitialized
{
	return mEngineInitialized;
}

- (void) reloadLevel
{
	NSString *level = [[NSString alloc] initWithUTF8String:SceneManager::Instance()->GetSceneName().c_str()];
	
	SceneManager::Instance()->UnloadScene();
	[self loadLevel:level];
	
}

- (NSString*) loadedLevel
{
	return mLoadedLevel;
}

- (int) currentScore
{
	return GamePlayManager::Instance()->ComputeScore();
}

- (int) deadGophers
{	
	return GamePlayManager::Instance()->GetTotalGophers();
}

-(int) remainingCarrots
{
	return GamePlayManager::Instance()->GetRemainingCarrots();
}

- (void) loadLevel:(NSString*) levelName
{

	DLog(@"GView Load Level");
	if([levelName isEqualToString:@"Splash"])
	{
		mViewState = LOAD;
		return;
	}
	
	[levelName retain];
	
	if(mLoadedLevel != nil)
	{
		[mLoadedLevel release];
	}
	
	mLoadedLevel = levelName;
	
	SceneManager::Instance()->LoadScene(levelName);
	GamePlayManager::Instance()->SetGameState(GamePlayManager::PLAY);
	
	switch( GamePlayManager::Instance()->GetGamePlayMode() )
	{
		case GamePlayManager::TAP:
		case GamePlayManager::POOL:
		{
			// no mult touch
			touchMode = SINGLE_TOUCH;
			
			// very simple low rate accel for checking pause
			[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 /5.0];
			[[UIAccelerometer sharedAccelerometer] setDelegate:self];
			self.animationInterval = 1.0 / 60.0;
			break;
		}
#ifdef ENABLE_FLICK_MODE
		case GamePlayManager::FLICK:
		{
			// no multi touch
			touchMode = FLICK;
			break;
		}
#endif
#ifdef BUILD_PADDLE_MODE
		case GamePlayManager::PADDLE:
		case GamePlayManager::FLIPPER:
		{
			// flip on multi touch
			touchMode = PADDLES;
			break;
		}
#endif
		case GamePlayManager::TILT_ONLY:
		{
			// turn on accelerom
			[[UIAccelerometer sharedAccelerometer] setUpdateInterval: 1.0/100.0];
			[[UIAccelerometer sharedAccelerometer] setDelegate:self];
			self.animationInterval = 1.0 / 30.0;
			
			touchMode = TILT_ONLY;
			break;
		}
		case GamePlayManager::SWARM_CANNON:
		case GamePlayManager::CANNON:
		case GamePlayManager::RUN_CANNON:
		{
			touchMode = CANNON;
			self.animationInterval = 1.0 / 60.0;
			break;
		}
	}
	
	
	int score = GamePlayManager::Instance()->ComputeScore();
	int deadGophs = GamePlayManager::Instance()->GetDeadGophers(); 
	int totalGophs = GamePlayManager::Instance()->GetTotalGophers();
	int ballsLeft = GamePlayManager::Instance()->GetNumBallsLeft();
	
	if(GamePlayManager::Instance()->GetGamePlayMode() == GamePlayManager::RICOCHET)
	{
		// update score if it has changed
		[ gopherViewController updateScore: score withDead:deadGophs andTotal: totalGophs andBallsLeft:ballsLeft];
		
	}
	else
	{
		
		// update score if it has changed
		[ gopherViewController updateScore: score withDead:deadGophs andTotal: totalGophs];
		
	}
	
	
	mViewState = PLAY;
	DLog(@"GView Done Load");
}

- (void)drawView 
{	
	if(mViewState == PAUSE)
	{
		return; 
	}
	
	[EAGLContext setCurrentContext:context];
	
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		
	
	if(!mEngineInitialized)
	{
		[self initEngine];
	}
	
	if(mViewState == LOAD ) 
	{
		// final draw
		GraphicsManager::Instance()->OrthoViewSetup(backingWidth, backingHeight, zEye);		
		
		
		GraphicsManager::Instance()->OrthoViewCleanUp();
		
		mViewState = PAUSE;

		// record these
		startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
		lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];
		
		[gopherViewController finishedLoadUp];
		
	}
	
	
	if(mViewState == PLAY)	
	{
		// transition out of Play
		if(GamePlayManager::Instance()->GetGameState() == GamePlayManager::GOPHER_WIN ||
		   GamePlayManager::Instance()->GetGameState() == GamePlayManager::GOPHER_LOST)
		{
			mViewState = (GamePlayManager::Instance()->GetGameState() == GamePlayManager::GOPHER_LOST)? GOPHER_LOST : GOPHER_WIN;
			
			// message delegate
			[gopherViewController finishedLevel:(mViewState == GOPHER_LOST)]; 
		}
		
	}
	
		
	if(mViewState == PLAY || mViewState == GOPHER_WIN || mViewState == GOPHER_LOST)
	{
		// strangely, there must be no GL context or something in the init 
		GraphicsManager::Instance()->SetupLights();
		GraphicsManager::Instance()->SetupView(
											   backingWidth,  
											   backingHeight,  
											   zEye
											   );
		
		
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		double dt = ([NSDate timeIntervalSinceReferenceDate] - lastTimeInterval);
		
		
		lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];	
#if DEBUG
		if(fpsTime > 1.0f)
		{
			float fps = fpsFrames / fpsTime;
			
			NSLog(@"FPS : %f", fps);
				
			fpsTime = 0;
			fpsFrames = 0;
		}
		else {
			fpsFrames++;
			fpsTime += dt;
		}
#endif
		// clamp dt
		dt = MIN(0.2, dt);
		
#if DEBUG
		PhysicsManager::Instance()->Update(dt);
#else
		// in tilt mode, update phys in acclerometer thread
		if(GamePlayManager::Instance()->GetGamePlayMode() 
		   != GamePlayManager::TILT_ONLY ||
		   mViewState != PLAY)
		{
			PhysicsManager::Instance()->Update(dt);
		}
#endif
			
		GamePlayManager::Instance()->Update(dt);	
		GraphicsManager::Instance()->Update(dt);

		if(mViewState == PLAY)
		{
			SceneManager::Instance()->Update(dt);
		}
		
		int score = GamePlayManager::Instance()->ComputeScore();
		int deadGophs = GamePlayManager::Instance()->GetDeadGophers(); 
		int totalGophs = GamePlayManager::Instance()->GetTotalGophers();
		int ballsLeft = GamePlayManager::Instance()->GetNumBallsLeft();
		
		if(GamePlayManager::Instance()->GetGamePlayMode() == GamePlayManager::RICOCHET)
		{
			if(score != mScore || deadGophs != deadGophs || totalGophs != totalGophs || ballsLeft != mNumBallsLeft)
			{
				// update score if it has changed
				[ gopherViewController updateScore: score withDead:deadGophs andTotal: totalGophs andBallsLeft:ballsLeft];
			}
			
		}
		else
		{
			if(score != mScore || deadGophs != deadGophs || totalGophs != totalGophs)
			{
				// update score if it has changed
				[ gopherViewController updateScore: score withDead:deadGophs andTotal: totalGophs];
			}
		}
		mScore = score;
		mDeadGophers = deadGophs;
		mTotalGophers = totalGophs;
		mNumBallsLeft = ballsLeft;
	}

	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	
	int error = glGetError();
	if(error )
	{ 
		DLog(@"Gl error. Still effed up %d?", error);
	}

}

-(void) endLevel
{
	SceneManager::Instance()->UnloadScene();
	if(mLoadedLevel != nil)
	{
		[mLoadedLevel release];
		mLoadedLevel = nil;
	}
}

- (btVector3) getTouchPoint:( CGPoint ) touchPoint
{
	// map touch into local coordinates
	float x = touchPoint.x/320.0;
	float y = touchPoint.y/480.0;
	
	x -= 0.5;
	x *= -20.0;
	
	y -= 0.5;
	y *= -30.0;
	
	return btVector3(x, 0, y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	
	if(mViewState != PLAY)
	{
		return;
	}
	
	// check for pause touch
	
	if( GamePlayManager::Instance()->GetGamePlayMode() != GamePlayManager::POOL)
	{
		btVector3 touchPt = [self getTouchPoint:touchPoint];
		touchPt -= btVector3(-9,0,-14);
		
		if(touchPt.length() < 1.5f)
		{
			[gopherViewController pauseLevel];
		}
		
	}
	
	
	if(touchMode == TILT_ONLY )
	{
#if DEBUG // for debug with emulator
		UITouch *touch = [touches anyObject];
		
		CGPoint touchPoint = [touch locationInView:self];
		
		btVector3 touchPt = [self getTouchPoint:touchPoint];

		float ptLen = touchPt.length();
		
		// clamp
		if(ptLen > 10.0f)
		{
			ptLen = 10.0f;
		}
		 
		touchPt.normalize();
		touchPt *= (10.0f * ptLen/10.0f);
		
		touchPt.setY(-10.0);
		
		
		PhysicsManager::Instance()->SetGravity(touchPt);
#endif
		
		return;
	}
	if( touchMode == SINGLE_TOUCH)
	{
		return;
	}
	   
#ifdef FLICK_MODE_ENABLED
	if(touchMode == FLICK)
	{
		UITouch *touch = [touches anyObject];
		
		CGPoint touchPoint = [touch locationInView:self];
		
		touchStart = [self getTouchPoint:touchPoint];
		
		//grab touchStartTime
		btVector3 dist = touchStart - GamePlayManager::Instance()->GetActiveBallPosition();
		dist.setY(0);
		
		// some ball radius and then some
		if(dist.length() < 4.0) 
		{
			touchStarted = true;
			touchStartTime = CFAbsoluteTimeGetCurrent();
		}
		else 
		{
			touchStarted= false;
		}
	}
	else
#endif
	{

		for (UITouch *touch in touches) 
		{
			//UITouch *touch = [touches anyObject];
			
			CGPoint touchPoint = [touch locationInView:self];
			touchStart = [self getTouchPoint:touchPoint];
			
			//changed this to allow run cannon
			if(touchStart.z() > -10)
			{
				GamePlayManager::Instance()->StartSwipe(touchStart);
				//mDidMove = false;
			}
			else {
				GamePlayManager::Instance()->Touch(touchStart);			
			}
		}
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

	if(mViewState != PLAY)
	{
		return;
	}
	
	if(touchMode == CANNON )
	{
		
		for (UITouch *touch in touches) 
		{

			// TODO : send in a relative motion	
			//UITouch *touch = [touches anyObject];
			
			CGPoint touchPoint = [touch locationInView:self];
			
			btVector3 touchPosition = [self getTouchPoint:touchPoint];
			if(touchPosition.z() > 0)
			{
				GamePlayManager::Instance()->MoveSwipe(touchPosition);
				mDidMove = true;
			}
		}
	}
	else if(touchMode != FLICK && touchMode != TILT_ONLY && touchMode != SINGLE_TOUCH)
	{
		// multi touch mode		
		for (UITouch *touch in touches) {
			
			CGPoint point = [touch locationInView:self];
			
			CGPoint touchPoint = [touch locationInView:self];
			
			btVector3 touchPosition = [self getTouchPoint:touchPoint];
			
			GamePlayManager::Instance()->Touch(touchPosition);
		}
	} 
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchStarted = false;
	
	//GamePlayManager::Instance()->CancelSwipe();
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

	UITouch *touch = [touches anyObject];
	
	if(mViewState == LOAD || mViewState == GOPHER_WIN || mViewState == GOPHER_LOST
	 || touchMode == TILT_ONLY )  
	{
		return;
	}
	
	if (touchMode == CANNON ) {
		
		return; /////////////////////////////////// RETURN ///////////////
		
	}
#ifdef FLICK_MODE_ENABLED
	else if(touchMode == FLICK)
	{
		if(touchStarted)
		{
			
			CFTimeInterval thisFrameStartTime = CFAbsoluteTimeGetCurrent();    
			double dt = thisFrameStartTime - touchStartTime;
			
			if(dt < 2.0)
			{
			
				CGPoint touchPoint = [touch locationInView:self];
				
				btVector3 touchEnd = [self getTouchPoint:touchPoint];
				
				
				DLog(@"Flick: Start %0.1f %0.1f, End: %0.1f %0.1f, Dt %0.2f ",
					  touchStart.x(), touchStart.z(), touchEnd.x(), touchEnd.z(), dt);
				
				touchEnd -= touchStart;
				
				touchEnd /= dt;
				
				GamePlayManager::Instance()->SetFlick(touchEnd);
				
			}
			touchStarted = false;
		}
	}
#endif
	else
	{
			
		//for (UITouch *touch in touches) {

			CGPoint point = [touch locationInView:self];
			
			CGPoint touchPoint = [touch locationInView:self];
			
			btVector3 touchPosition = [self getTouchPoint:touchPoint];
			
			GamePlayManager::Instance()->Touch(touchPosition);
		//}
	}
}

inline float clamp(float a, float mn, float mx)
{
	if(a > mx)
	{
		return mx;
	}
	if(a < mn)
	{
		return mn;
	}
	return a;
	
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	
	if(mViewState != PLAY )
	{
		return;
	}
	
	if(GamePlayManager::Instance()->GetGamePlayMode() == GamePlayManager::POOL)
	{
		if(acceleration.x > 2.0f)
		{
			DLog(@"Accel %f %f %f", acceleration.x, acceleration.y, acceleration.z);
			[gopherViewController pauseLevel];
		}
		return;
	}
	
	if(touchMode != TILT_ONLY )
	{
		return;
	}
	
		// should use a better filter
	float kFilteringFactor = 0.1;
	
	float aX = acceleration.x;
	float aY = acceleration.y;
	
#ifndef SIMPLE_FILTER
	
    // Use a basic low-pass filter to keep only the gravity component of each axis.
    const float bX = (aX * kFilteringFactor) + (fX * (1.0 - kFilteringFactor));
    const float bY = (aY * kFilteringFactor) + (fY * (1.0 - kFilteringFactor));
	

	const float filterFactor = 0.1f;
	const float attenuation = 3.0f;
	const float minStep = 0.02f;
	
	float fNorm = sqrtf( fX*fX + fY*fY);
	float aNorm = sqrtf( aX*aX + aY*aY);
	
	
	const float d = clamp(fabs(fNorm - aNorm)/minStep - 1.0f, 0.0f, 1.0f);
	
	const float alph = (1.0f - d) * (filterFactor / attenuation) + d * filterFactor;
	
	fX = aX * alph + bX * (1.0f - alph);
	fY = aY * alph + bY * (1.0f - alph);
	
	// this is set for device upright
	btVector3 gravity(-fX*75.0f, -75*(1.0f - fabs(fY) -fabs(fX)), fY*75.0f);
	
#else
	
	
    // Use a basic low-pass filter to keep only the gravity component of each axis.
    gX = (aX * kFilteringFactor) + (gX * (1.0 - kFilteringFactor));
    gY = (aY * kFilteringFactor) + (gY * (1.0 - kFilteringFactor));
	
	
	// this is set for device upright
	btVector3 gravity(-gX*75.0f, -75*(1.0f - fabs(gY) -fabs(gX)), gY*75.0f);
#endif
	
	
	PhysicsManager::Instance()->SetGravity(gravity);
	
	// get time interval
	double dt = ([NSDate timeIntervalSinceReferenceDate] - lastAccelInterval);	
	lastAccelInterval = [NSDate timeIntervalSinceReferenceDate];	
	
	
	// in tilt mode, update phys in acclerometer thread
	PhysicsManager::Instance()->Update(dt);
	
#if DEBUG
	if(physTime > 1.0f)
	{
		float fps = physFrames/physTime;
		NSLog(@"Phys FPS %f", fps);
		
		physFrames = 0;
		physTime = 0;
		
	}
	else
	{
		physTime += dt;
		physFrames++;
	}
#endif	
	
	
}

-(void) dealloc
{	
	GamePlayManager::ShutDown();
	GraphicsManager::ShutDown();
	PhysicsManager::ShutDown();
	SceneManager::ShutDown();
	AudioDispatch::ShutDown();
	
	[super dealloc];	
}
 
@end

