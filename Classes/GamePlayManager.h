/*
 *  GamePlayManager.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>
#import <vector>
#import <list>
#import "PhysicsComponent.h"
#import "TriggerComponent.h"
#import "GateControllerComponent.h"
#import "NodeNetwork.h"
#import "GopherController.h"
#import "SpawnComponent.h"
#import "Entity.h"
#import "VectorMath.h"
#import "GraphicsComponent.h"
#import "PaddleController.h"
#import "FlipperController.h"
#import "CannonController.h"
#import "CannonUI.h"
#import "ExplodableComponent.h"

namespace Dog3D
{
	typedef std::list< std::pair<float, int> >  IntervalQueue;
	typedef std::list< std::pair<float, int> >::iterator  IntervalQueueIterator;
	
	class GamePlayManager
	{
	public:
		enum GameState { PLAY, PAUSE, GOPHER_WIN, GOPHER_LOST };
		enum GamePlayMode { TAP=0, 
			FLICK=1, 
			PADDLE=2, 
			FLIPPER=3, 
			TILT_ONLY=4, 
			CANNON=5, 
			POOL=6, 
			SWARM_CANNON=7, 
			RUN_CANNON=8,
			RICOCHET=9
		};
	private:
		GameState mGameState;
		
	public:
		GamePlayManager(): mGopherLives( 10 ) , mCarrotLives ( 5 ), mGopherBaseLine(mGopherLives), mCarrotBaseLine(mCarrotLives), 
		mDestroyedObjects(0),
		mGameState(PLAY),
		mGopherHUD(NULL), mCarrotHUD(NULL), mTouched(false), mFlicked(false),
		mGamePlayMode(PADDLE), mCannonController(NULL), mCannonUI(NULL), 
		mUnlimitedBalls(true), mFocalPoint(0,0,0), mCarrotSearchDistance(20.0f),
		mSpawnDelay(0.0f)
		{}
	
		
		// singleton
		static GamePlayManager *Instance()
		{
			return sGamePlayManager;
		}
		
		static void ShutDown()
		{
			delete sGamePlayManager;
			sGamePlayManager = NULL;
		}
			
		
		void Unload();
		
		// initializes singleton manager
		static void Initialize();	
		
		// steps physics
		void Update(float deltaTime);

		
#pragma mark TOUCH
		//todo multi touch
		inline void Touch(btVector3 &position)
		{
#ifdef BUILD_PADDLE_MODE
			if(mPaddles.size() == 0 && mFlippers.size() ==  0 && 
			   mCannonController == NULL)
#else
			if(mCannonController == NULL)
#endif
			{
			
				if(mBalls.size() == 0)
				{
					DLog(@"No balls");
				}
				else {
									
					Dog3D::GraphicsComponent *gfx = mBalls.front()->GetGraphicsComponent();
					if(gfx->mActive)
					{
						mTouchPosition = position;
						mTouched = true;
					}
				}
			}
			else if(mCannonUI)
			{
				// update the cannon controller
				mCannonUI->SetTouch(position);
			}
#ifdef BUILD_PADDLE_MODE
			else if( mFlippers.size() > 0)
			{
				dynamic_cast<FlipperController*>(mFlippers[0] )->SetOn();
			}
			else
			{
				if(mPaddles.size() == 1)
				{					
					dynamic_cast<PaddleController*>(mPaddles[0] )->SetTarget(position);
				}
				else 
				{
					// positive then negative
					if(position.getZ() > 0)
					{
						dynamic_cast<PaddleController*>( mPaddles[0] )->SetTarget(position);
					}
					else {
						dynamic_cast<PaddleController*>( mPaddles[1] )->SetTarget(position);
					}

				}
			}
#endif
		}
		
		// write out old swipe, start a new one
		inline void StartSwipe(btVector3 &startPosition)
		{
			mCannonUI->StartSwipe(startPosition);
		}
		
		inline void MoveSwipe(btVector3 &endPosition)
		{
			
			// update the cannon controller
			mCannonUI->MoveSwipe(endPosition);	
		}
		
		inline void EndSwipe(btVector3 &endPosition)
		{
			// update the cannon controller
			mCannonUI->EndSwipe(endPosition);	
		}
		
		inline void CancelSwipe()
		{
			mCannonUI->CancelSwipe();
		}
		
		inline void SetFlick(btVector3 &flick)
		{
			mFlicked = true;
			mFlick = flick;
		}

#ifdef BUILD_PADDLE_MODE
		//todo multi touch
		inline void EndTouch()
		{
			if(mFlippers.size() > 0)
			{
				dynamic_cast<FlipperController*>(mFlippers[0])->SetOff();
			}
		}
#endif
		
		// returns position of ball 0
		inline btVector3 GetActiveBallPosition()
		{
			
			if(mBalls.size() > 0)
			{
				return mBalls.front()->GetPosition();
			}
			else {
				return btVector3(0,0,0);
			}
			
		}
		
#pragma mark SCENE SETUP
		// play, win
		inline GameState GetGameState() { return mGameState; }
		
		inline void SetGameState(GameState gameState){ mGameState = gameState;}
		
		inline GamePlayMode GetGamePlayMode(){ return mGamePlayMode;}
		inline void SetGamePlayMode(GamePlayMode mode){mGamePlayMode = mode;}
		
		inline void AddSpawnComponent(SpawnComponent *spawn)
		{
			mSpawnComponents.push_back(spawn);
		}
		
		inline void AddTarget(Entity *target)
		{
			mTargets.push_back(target);
		}
		
		inline void AddBall( Entity *ball, int ballType = 0)
		{
			if(ballType == ExplodableComponent::CUE_BALL)
			{
				mBalls.push_front(ball);
			}
			else 
			{
				mBalls.push_back(ball);
			}
		}
		
		
		inline void SetCannon( CannonController *controller, CannonUI *ui)
		{
			mCannonController = controller;
			mCannonUI = ui;
		}
		
		inline void SetGopherHUD( HUDGraphicsComponent *hud){ mGopherHUD = hud; }
		
		inline void SetCarrotHUD( HUDGraphicsComponent *hud){ mCarrotHUD = hud; }
		
		void AddGopherController( GopherController *component);
		
#ifdef BUILD_PADDLE_MODE
		inline void AddPaddle( PaddleController *paddle )
		{
			mPaddles.push_back(  paddle );
		}
		
		inline void AddFlipper( FlipperController *flipper )
		{
			mFlippers.push_back( flipper );
		}
#endif
		
		// initializes  node network
		void InitializeNodeNetwork();
		
		// initializes debug node network
		// to be replaced later
		void InitializeDebugNetwork();
		
		void SetSpawnIntervals( IntervalQueue intervals) 
		{ 
			mSpawnIntervals = intervals;
			
			// process first spawn interval
			if(mSpawnIntervals.size() > 0)
			{
				mNumGophersToSpawn = mSpawnIntervals.front().second;
				mSpawnIntervals.pop_front();
			}
		}
		
		inline void SetWorldBounds(btVector3 &bounds)
		{
			mWorldBounds = bounds;
		}
		
		inline void GetFocalPoint(btVector3 &point)
		{
			if(mGamePlayMode == TILT_ONLY)
			{
				point = mFocalPoint;
				
					
				// then clip
				
				if(point.x() > mWorldBounds.x() - 10)
				{
					point.setX(mWorldBounds.x() - 10);
				}
				else if(point.x() < -mWorldBounds.x() +  10)
				{
					point.setX(-mWorldBounds.x() + 10);
				}
				
				if(point.z() > mWorldBounds.z() - 15)
				{
					point.setZ(mWorldBounds.z() - 15);
				}
				else if(point.z() < -mWorldBounds.z() + 15)
				{
					point.setZ(-mWorldBounds.z() +  15);
				}
				
				
			}
			else 
			{
				point.setZero();
			}

		}
			
		
#pragma mark TARGET SYSTEM
		// for target acquisition
		Entity *PickTarget(btVector3 position);
		
		// target acq
		Entity *GetRandomCarrot(btVector3 position);
		
		// target acq
		Entity *GetClosestHole(btVector3 position);
		
		
		inline int GetNumActiveTargets()
		{
			int nActiveTargets = 0;
			for(std::list<Entity *>::iterator it = mTargets.begin(); it != mTargets.end(); it++)
			{
				if((*it)->mActive)
				{
					nActiveTargets++;
				}
			}
			return nActiveTargets;
		}
		
		//TODO - this goes away
		inline TheMadGamer::NodeNetwork* GetNodeNetwork()
		{
			return &mNodeNetwork;
		}
#if DEBUG
		void DrawDebugLines();
#endif
		void RemoveTargetNode(int nodeId);
		
#pragma mark GAME LOGIC
		// reset of game win/loss logic
		// called during load up
		void InitializeLevel( int numGopherLives, int numCarrotLives)
		{
			
			SetNumGopherLives(numGopherLives);
			SetNumCarrotLives(numCarrotLives);
			mDestroyedObjects = 0;
			mScratched = false;
			mLevelTime = 0;
		}
		
		// gophers or carrots = 0
		inline bool IsGameOver() { return mGopherLives == 0 || mCarrotLives == 0 ||mScratched ; }
		
		// carrot lives = 0
		inline bool GophersWon() { return mCarrotLives == 0 || mScratched; }
		
		inline bool PlayerScratched() { return mScratched; }
		
		inline void AddExplodable(ExplodableComponent *explodable)
		{
			mExplodables.push_back(explodable);
		}
		
		inline void AddKinematicController(Component *gate)
		{
			mKinematicControllers.push_back(gate);
		}
		
		inline void SetUnlimitedBalls(bool enabled)
		{
			mUnlimitedBalls = enabled;
		}
		
#pragma mark SCORING
		
		
		//crude score test
		inline int ComputeScore()
		{
			return  (mGopherBaseLine - mGopherLives)*5;
		}
		
		// todo this really should be private
		inline void RemoveCarrotLife()
		{
			if(mCarrotLives > 0)
			{
				mCarrotLives--;
				if(mCarrotHUD)
				{
					mCarrotHUD->RemoveLife();
				}
			}
		}
		
		inline float GetLevelTime() { return mLevelTime;}
		
		inline int GetTotalGophers()
		{
			return mGopherBaseLine;
		}
		
		inline int GetDeadGophers()
		{
			return (mGopherBaseLine - mGopherLives);
		}
		
		inline void SetBallSpawn(btVector3 &bs)
		{
			mBallSpawn = bs;
		}
		
		inline int GetRemainingCarrots()
		{
			return mCarrotLives; 
		}
		
		inline int GetNumBallsLeft()
		{
			if(mCannonController != NULL)
			{
				return mCannonController->NumBallsLeft();
			}
			else {
				return -1;
			}
		}
		
		inline void SetCarrotSearchDistance(float distance)
		{
			mCarrotSearchDistance = distance;	
		}
		
		// spawns in single ball 
		void SpawnBall(Entity *ball, int position = 0);
        
	private:
		
		inline bool NoBallsLeft()
		{
			if( mCannonController == NULL)
			{
				return false;
			}
			
			if( mCannonController->NumBallsLeft() == 0 
			   && mBalls.size() == 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		  		
		inline void SetNumGopherLives( int nLives ) 
		{ 
			mGopherLives = nLives; 
			mGopherBaseLine = nLives;
		}
		
		inline void SetNumCarrotLives( int nLives ) 
		{ 
			mCarrotLives = nLives; 
			mCarrotBaseLine = nLives;
		}
		
		
		void UpdateDebugVertices();
		
		// updates the ball - physics or touch event
		void UpdateBallMotion();
		
		// update object contact/explosion mojo		
		void UpdateObjectContacts(float dt);
		
		// steps ball and gopher controllers
		void UpdateControllers(float dt);
		
		// updates gopher ai - calls controller
		void UpdateGopherAIs();
		
		// spawn in new gophers
		void SpawnNewGophers(float dt, float gameTime);
		
		// clean up gophers that have flown off screen
		void CleanUpGopherBodies();
		
		// clean up exploded balls
		void UpdateBallExplosions(float dt);
		
		// manages spawn in
		void ReclaimBalls(float dt);
		
		// either continuous spawn or to cannon
		void ReclaimBall(Entity *ball);
		
		// drop gopher one life
		inline void RemoveGopherLife() 
		{ 
			if(mGopherLives > 0)
			{
				mGopherLives--;
				if(mGopherHUD)
				{
					mGopherHUD->RemoveLife();
				}
			}
		}
		
		std::list<GopherController *> mActiveGophers;
		
		std::list<Entity *> mTargets;
		
		TheMadGamer::NodeNetwork mNodeNetwork;
		
		// managed components
		std::list<Entity *> mBalls;
		
#ifdef BUILD_PADDLE_MODE
		std::vector<  PaddleController *  > mPaddles;
		
		std::vector<  FlipperController *  > mFlippers;
#endif
		
		IntervalQueue mSpawnIntervals;
		
		HUDGraphicsComponent *mGopherHUD;
		HUDGraphicsComponent *mCarrotHUD;

		std::vector<SpawnComponent *> mSpawnComponents;
		
		std::list<ExplodableComponent *> mExplodables;
		std::list<Component *> mKinematicControllers;
		
		std::queue<GopherController *> mDeadGopherPool;
		
		
		// from UI
		btVector3 mTouchPosition;
		btVector3 mFlick;
		
		// for cannon control
		CannonController *mCannonController;
		CannonUI *mCannonUI;
		
		btVector3 mWorldBounds;
		
		btVector3 mFocalPoint;
		
		btVector3 mBallSpawn;
		
		// total play time on level
		float mLevelTime;
		
		float mCarrotSearchDistance;

		float mSpawnDelay;
		
		// singleton
		static GamePlayManager *sGamePlayManager;
		
		int mNumDebugVertices;
		
		int mNumGophersToSpawn;
		
#if DEBUG
		// debug
		Dog3D::Vec3 *mDebugVertices;
#endif
	
		// number of gopher lives (when zero, game over)
		int mGopherLives;
		
		// number of carrots lives (when zero, game over)
		int mCarrotLives;
		
		// base line number of gopher  (to begin with)
		int mGopherBaseLine;
		
		// base line number of carrots (to begin with)
		int mCarrotBaseLine;
		
		// gas cans, etc
		int mDestroyedObjects;
		
		GamePlayMode mGamePlayMode;
		
        int mSpawnInIdx;
        
		bool mUnlimitedBalls;
		
		// ui events passed in
		bool mTouched;
		bool mFlicked;
		
		// pool variant
		bool mScratched;
		
	};
}