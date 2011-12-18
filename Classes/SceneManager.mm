/*
 *  SceneManager.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 3/2/10.
 *  Copyright 2010 HighlandAvenue. All rights reserved.
 *
 */

#include "SceneManager.h"

#import <btBulletDynamicsCommon.h>

#import "GameEntityFactory.h"
#import "PhysicsComponentFactory.h"

#import "PhysicsManager.h"
#import "GraphicsManager.h"
#import "GamePlayManager.h"
#import "SceneManager.h"

#import "TriggerComponent.h"

#import "AudioDispatch.h"

const float kBallRadius = 0.5;

const float kWallHeight = 2.5;
const float kBoxHeight = 1.5;

const float kWallSlop = 0.5;

const float kGoalOffset = 1.1;

using namespace Dog3D;
using namespace std;

SceneManager *SceneManager::sInstance;

SceneManager::LevelControlInfo::LevelControlInfo(NSDictionary *controlDictionary)
{
	DLog(@"Init level control");
	mNumCombos = [[controlDictionary objectForKey:@"NumCombos"] intValue];
	mNumGopherLives = [[controlDictionary objectForKey:@"NumGopherLives"] intValue];	
	//mNumCarrotLives = [[controlDictionary objectForKey:@"NumCarrotLives"] intValue];
	
	mPlayMode =  (GamePlayManager::GamePlayMode) [[controlDictionary objectForKey:@"GamePlayMode"] intValue];	
	
	NSString *background = [controlDictionary objectForKey:@"Background"];
	mBackground = [background UTF8String];
	
	mScoreMode = [[controlDictionary objectForKey:@"ScoreMode"] intValue];	
	
	mBallTypes = [[controlDictionary objectForKey:@"BallTypes"] intValue];
	if(mBallTypes == 0)
	{
		mBallTypes = -1;
	}
	
	// -1 inf
	mNumBalls = [[controlDictionary objectForKey:@"NumBalls"] intValue];
	if(mNumBalls == 0)
	{
		mNumBalls = -1;
	}
	
	
	DLog(@"Control NumCombos:%d GopherLives:%d ", 
		  mNumCombos, mNumGopherLives );
	
	DLog(@"Control PlayMode:%d ScoreMode:%d BallTypes%d NumBalls:%d",
		  mPlayMode, mScoreMode, mBallTypes, mNumBalls);
	
	mCollisionAvoidance = [[controlDictionary objectForKey:@"CollisionAvoidance"] intValue];
	
	NSArray *spawnIntervalArray = [controlDictionary objectForKey:@"SpawnIntervals"];
	[spawnIntervalArray retain];
	if(spawnIntervalArray != nil)
	{
		for( NSUInteger i = 0; i < [spawnIntervalArray count]; i++)
		{
			NSDictionary *pairDict = [spawnIntervalArray objectAtIndex:i];
			std::pair<float, int> p;
			p.first = [[pairDict objectForKey:@"Time"] floatValue];
			p.second = [[pairDict objectForKey:@"Gophers"] intValue];
			DLog(@"Loading Spawn Interval %f %d", p.first, p.second);
			
			mSpawnIntervals.push_back(p);
		}
	}
	[spawnIntervalArray release];
	
	float xBound = [[controlDictionary objectForKey:@"XBounds"] floatValue];
	if(xBound > 0)
	{
		mWorldBounds.setX(xBound);
		DLog(@"XBound %f", xBound);
	}
	else {
		// default
		mWorldBounds.setX(10);
	}

	mWorldBounds.setY(4);
	
	float zBound = [[controlDictionary objectForKey:@"ZBounds"] floatValue];
	if(zBound > 0)
	{
		mWorldBounds.setZ(zBound);
		DLog(@"ZBound %f", zBound);
	}
	else {
		mWorldBounds.setZ(15);
	}
	
	float ballX = [[controlDictionary objectForKey:@"BallSpawnX"] floatValue];
	mBallSpawn.setX(ballX);
	
	mBallSpawn.setY(1.5);
	
	float ballZ = [[controlDictionary objectForKey:@"BallSpawnZ"] floatValue];
	mBallSpawn.setZ(ballZ);
	
	
	float dist = [[controlDictionary objectForKey:@"CarrotSearchDistance"] floatValue];	
	if(dist > 0)
	{
		mCarrotSearchDistance = dist;
	}
	else {
		mCarrotSearchDistance = 20.0f;
	}

    singleUseHoles = [[controlDictionary objectForKey:@"SingleUseHoles"] boolValue];
    
	
	DLog(@"Finish Init Level Control");
}



void SceneManager::RefreshSpawnIntervals(float gameTime)
{
	
	IntervalQueue newSpawnIntervals = mLevelControl.mSpawnIntervals;
	
	// todo copy over new intervals and offset
	
	for(IntervalQueue::iterator it = newSpawnIntervals.begin(); it!= newSpawnIntervals.end(); it++)
	{
		// offset the spawn time
		it->first += gameTime;
	}
	
	GamePlayManager::Instance()->SetSpawnIntervals(newSpawnIntervals);
	
}

void SceneManager::LoadScene( NSString *levelName)
{
	if(mSceneLoaded)
	{
		DLog(@"Unloading Scene");
		UnloadScene();
		DLog(@"Done");
	}
		
	DLog(@" **** Loading Scene **** ");
	PhysicsManager::Instance()->CreateWorld();
	
	// create a pointer to a dictionary and
	// read ".plist" from application bundle
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:levelName];
	
	NSDictionary *rootDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	NSDictionary *controlDictionary = [[rootDictionary objectForKey:@"LevelControl"] retain];
	
	mLevelControl = LevelControlInfo(controlDictionary);
	mNumCarrots = 0;
	GamePlayManager::Instance()->SetGamePlayMode(mLevelControl.mPlayMode);
	DLog(@"Game Play Mode %d", mLevelControl.mPlayMode);
	
	GamePlayManager::Instance()->SetSpawnIntervals(mLevelControl.mSpawnIntervals);
	
	GamePlayManager::Instance()->SetUnlimitedBalls((mLevelControl.mNumBalls == -1) || (mLevelControl.mNumBalls == 0));
	
	GamePlayManager::Instance()->SetBallSpawn(mLevelControl.mBallSpawn);
	
	GamePlayManager::Instance()->SetCarrotSearchDistance(mLevelControl.mCarrotSearchDistance);
	
	// setup gravity
	switch(mLevelControl.mPlayMode )
	{
		case GamePlayManager::TAP:
		case GamePlayManager::POOL:
		case GamePlayManager::FLICK:
		case GamePlayManager::PADDLE:
		case GamePlayManager::FLIPPER:
		case GamePlayManager::TILT_ONLY:
		case GamePlayManager::SWARM_CANNON:
		case GamePlayManager::RUN_CANNON:
		{
			
			btVector3 gravity(0,-10,0);
			PhysicsManager::Instance()->SetGravity(gravity);

			break;
		}
		case GamePlayManager::CANNON:
		{
			btVector3 gravity(12,-12,0);
			PhysicsManager::Instance()->SetGravity(gravity);
			break;
			
		}	
	}
	
	
	btVector3 position(0,0,0);
	
	for(int i = 0; i < 100; i++)
	{
		Entity *entity = GameEntityFactory::BuildFXElement(position, ExplodableComponent::MUSHROOM);
		mFXPool.push(entity);
	}
	
	GamePlayManager::Instance()->SetWorldBounds(mLevelControl.mWorldBounds);
	
	GraphicsManager::Instance()->SetFXPool(&mFXPool);
	
	
	// create static world walls
#ifdef BUILD_PADDLE_MODE	
	if(mLevelControl.mPlayMode != GamePlayManager::PADDLE)
#endif
	{
		int wallFlags = (mLevelControl.mPlayMode == GamePlayManager::CANNON 
						 ||mLevelControl.mPlayMode == GamePlayManager::SWARM_CANNON ||
						 mLevelControl.mPlayMode == GamePlayManager::RUN_CANNON) ? SceneManager::FLOOR | SceneManager::CEILING : -1;
		DLog(@"Wall flags %d", wallFlags);
		CreateWalls( &mLevelControl.mBackground , wallFlags , mLevelControl.mPlayMode == GamePlayManager::POOL );
	}
	
	LoadSceneObjects(rootDictionary);
		
	LoadGeneratedObjects(rootDictionary  );	
	
	// create a network for navigation
	GamePlayManager::Instance()->InitializeNodeNetwork();
	
	LoadHUDs();

#ifdef BUILD_PADDLE_MODE
	if(mLevelControl.mPlayMode == GamePlayManager::PADDLE)
	{
		{
			// on one side
			btVector3 position( 0, 1, 14);
			btVector3 extents(4,2,1);
			
			Entity *paddle = GameEntityFactory::BuildSlidePaddle(position, extents, PaddleController::Z_POS);
			
			mHuds.push_back(paddle);
		}
		
		{
			// on one side
			btVector3 position( 0, 1, 14);
			btVector3 extents(4,2,1);
			
			Entity *paddle = GameEntityFactory::BuildSlidePaddle(position, extents, PaddleController::Z_NEG);
			
			mHuds.push_back(paddle);
		}
	}
#endif
	
	// finally set number of carrot and gophers
	GamePlayManager::Instance()->InitializeLevel(mLevelControl.mNumGopherLives, mNumCarrots);
	
	// anything that would go in front would be added here.
	mSceneLoaded = true;
	mSceneName = [levelName UTF8String];
	
	[controlDictionary release];
	[rootDictionary release];
	
	
	DLog(@"**** Done loading scene ****");
	
}

void SceneManager::LoadSceneObjects(NSDictionary *rootDictionary)
{
	NSDictionary *layoutDictionary = [rootDictionary objectForKey:@"LayoutObjects"];
    
	// load up things like spawn points, targets, hedges
	for (id key in layoutDictionary) 
	{
		NSDictionary *object = [layoutDictionary objectForKey:key];
		
		NSString *type = [object objectForKey:@"type"];
		
		float x = [[object objectForKey:@"x"] floatValue];
		float y = [[object objectForKey:@"y"] floatValue];
		float z = [[object objectForKey:@"z"] floatValue];
		btVector3 pos( x,y,z);
		
		
		float sx = [[object objectForKey:@"sx"] floatValue];
		float sy = [[object objectForKey:@"sy"] floatValue];
		float sz = [[object objectForKey:@"sz"] floatValue];
		
		btVector3 extents(sx, sy, sz);
		
		float radius = [[object objectForKey:@"radius"] floatValue];
		
		float rotationY = [[object objectForKey:@"ry"] floatValue];
		
		float spawnTime = [[object objectForKey:@"spawnTime"] floatValue];
		
		NSRange flowerSubRange = [type rangeOfString:@"flower"];
		
		if( [type isEqualToString:@"spawn"] ||
		   [type isEqualToString:@"hole"]  ) 
		{	
			pos.setY(0.05);
			
			mSpawnPoints.push_back( GameEntityFactory::BuildHole(pos, radius) );	
			
		}		
		else if ([type isEqualToString:@"target"] || [type isEqualToString:@"carrot"]  )
		{
			pos.setY(0.05);
			
			mTargets.push_back(GameEntityFactory::BuildCarrot(pos, radius));
			mNumCarrots++;
		}
		// test box
		else if ([type isEqualToString:@"hedgeCollider"]  )
		{
			
			mHedges.push_back( GameEntityFactory::BuildHedgeCircle(pos, radius) );
		}	
		// test box
		else if ([type isEqualToString:@"fenceCollider"] )
		{		
			btVector3 extents(sx, 10, sz);
			
			//hedges, fences are deallocated the same way
			mHedges.push_back( GameEntityFactory::BuildFenceBox(pos, extents) );
		}
		else if([type isEqualToString:@"crate"] )
		{
			btVector3 extents(sx, sx, sx);
			
			Entity * crate = GameEntityFactory::BuildCrate(pos, extents,
														   mFixedRest, 0.3f, true);
			mSceneElements.insert(crate);
			crate->GetExplodable()->Prime();
		}
		else if([type isEqualToString:@"fenceLt"] || [type isEqualToString:@"fenceC"] || [type isEqualToString:@"hedge1"])
		{
			DLog(@"Loading collider %@ with YRotation %f", type, rotationY);
			
			Entity * item = GameEntityFactory::BuildTexturedCollider(pos, extents, rotationY, mFixedRest, type, 1.33f);
			mSceneElements.insert(item);
			
			item->SetYRotation(rotationY);
		}
		else if([type isEqualToString:@"gate1"])
		{
			DLog(@"Loading collider %@ with YRotation %f", type, rotationY);
			
			float triggerX = [[object objectForKey:@"triggerX"] floatValue];
			float triggerZ = [[object objectForKey:@"triggerZ"] floatValue];
			
			Entity * item = GameEntityFactory::BuildGate(pos, extents, rotationY, mFixedRest, @"fenceC", 1.33f, triggerX, triggerZ);
			mSceneElements.insert(item);
			
			item->SetYRotation(rotationY);
		}
		else if([type isEqualToString:@"spinner1"])
		{
			DLog(@"Loading collider %@ with YRotation %f", type, rotationY);
			
			Entity * item = GameEntityFactory::BuildSpinner(pos, extents, rotationY, 1.0f, @"fenceC", 1.33f);
			mSceneElements.insert(item);
			
			item->SetYRotation(rotationY);
		}
		else if( [type isEqualToString:@"tombStone"])
		{
			DLog(@"Loading collider %@ with YRotation %f", type, rotationY);
			extents.setY(kWallHeight);
			
			Entity * item = GameEntityFactory::BuildTexturedCollider(pos, extents, rotationY, mFixedRest, type, 1.1f);
			mSceneElements.insert(item);
			
			item->SetYRotation(rotationY);
		}
		else if([type isEqualToString:@"rock"] )
		{
			// no delayed rock spawning
			/*if(spawnTime > 0)
			{
				mDelayedSpawns.push_back(new SpawnInfo([type UTF8String], pos, extents, 0, spawnTime));
			}
			else*/
			{
				// rocks have a 25% padding
				Entity * item = GameEntityFactory::BuildCircularCollider(pos, extents, mFixedRest , type, 1.33f);
				mSceneElements.insert(item);
			}
		}
		else if([type isEqualToString:@"bounceRock"]  )
		{
				// rocks have a 25% padding
				Entity * item = GameEntityFactory::BuildCircularCollider(pos, extents, mBounceRest, @"rock", 1.33f);
				mSceneElements.insert(item);
		
		}
		else if([type isEqualToString:@"pot1"] || [type isEqualToString:@"pot2"] || [type isEqualToString:@"wagon"] )
		{
			
			extents.setY(10);
			if(spawnTime > 0)
			{
				mDelayedSpawns.push_back(new SpawnInfo([type UTF8String], pos, extents, 0, spawnTime));
			}
			else 
			{
				Entity *item = GameEntityFactory::BuildTexturedExploder(pos, extents, type);
				mSceneElements.insert(item);
				item->GetExplodable()->Prime();
			}
			
			//item->SetYRotation(rotationY);
		}
		else if([type isEqualToString:@"flower"])
		{
			Entity *item = GameEntityFactory::BuildCircularExploder(pos, extents, @"flower", spawnTime,1, ExplodableComponent::EXPLODE_SMALL);
			mSceneElements.insert(item);
			item->GetExplodable()->Prime();
		}
		else if( flowerSubRange.location != NSNotFound)
		{
			NSString *subType = [[NSString alloc] initWithString:[type substringFromIndex:6]];
			DLog(@"Type Name %@", subType);
			
			Entity *item = NULL;
			
			if([type isEqualToString:@"flowerPurple"])
			{			
				item = GameEntityFactory::BuildCircularExploder(pos, extents, type, spawnTime,1,
														ExplodableComponent::BUMPER );
			}
			else {
				item = GameEntityFactory::BuildCircularExploder(pos, extents, type, spawnTime,1,
														 ExplodableComponent::POP );				
			}

			
			mSceneElements.insert(item);
			item->GetExplodable()->Prime();
			
			[subType release];
		}		
		else if([type isEqualToString:@"gasCan"] )
		{
			Entity * crate = GameEntityFactory::BuildGasCan(pos, extents,0.45);
			mSceneElements.insert(crate);
			crate->GetExplodable()->Prime();
		}
		else if([type isEqualToString:@"fence"] )
		{
			
			Entity * fence = GameEntityFactory::BuildFence(pos, extents,
														   mFixedRest, 0.3f, true);
			fence->SetYRotation(rotationY);
			
			mSceneElements.insert(fence);
			fence->GetExplodable()->Prime();
		}
		else if([type isEqualToString:@"firePit"] )
		{
			// fx renders in pre queue
			Entity * firePit = GameEntityFactory::BuildFXElement(pos, extents,
														   @"tiki.sheet", 2,2,4, true);
			
			mSceneElements.insert(firePit);
			
		}
		else if([type isEqualToString:@"uFO"] )
		{
			
			Entity * element = GameEntityFactory::BuildFXElement(pos, extents,
																 @"UFO.sheet", 2,2,4);
			
			mSceneElements.insert(element);
			
		}
		else if([type isEqualToString:@"fountain"] )
		{
			Entity * element = GameEntityFactory::BuildFXCircularCollider(pos, extents,
																 @"fountain.sheet", 2,2,4);
			
			mSceneElements.insert(element);
			
		}
		else {
			DLog(@"--->>> Error loading object of type %@", type);
		}

	}

}

// spawn in objects
void SceneManager::LoadGeneratedObjects(NSDictionary *rootDictionary)
{
	int poolBallCount = 0;
	
	NSDictionary *levelDictionary = [rootDictionary objectForKey:@"GeneratedObjects"];
	// load up generated gophers and balls
	
	for (id key in levelDictionary) 
	{
		NSDictionary *object = [levelDictionary objectForKey:key];
		
		NSString *type = [object objectForKey:@"type"];
		
		if( [type isEqualToString:@"gopher"] || 
		   [type isEqualToString:@"bunny"] || 
		   [type isEqualToString:@"squ"] |
		   [type isEqualToString:@"furry"]) 
		{
			
			float x = [[object objectForKey:@"x"] floatValue];
			float z = [[object objectForKey:@"z"] floatValue];
			
			// for now gophs have a fixed size
			//float scale = [[object objectForKey:@"scale"] floatValue];
			float scale = 1.5f;
			
			btVector3 pos( x , 0.05, z);
			
			DLog(@"Add gopher %f %f", x, z);
			
			GameEntityFactory::CharacterType charType;
			if([type isEqualToString:@"gopher"])
			{
				charType = 	GameEntityFactory::Gopher;
			}
			else if([type isEqualToString:@"bunny"])
			{
				charType = 	GameEntityFactory::Bunny;
			}
			else if( [type isEqualToString:@"squ"])
			{
				charType = 	GameEntityFactory::Squ;
			}
			else 
			{
				int rnd = rand() %3;
				if(rnd == 0)
				{
					charType = GameEntityFactory::Gopher;
				}
				else if(rnd == 1)
				{
					charType = GameEntityFactory::Bunny;
				}
				else 
				{
					charType = GameEntityFactory::Squ;	
				}

			}

			
			Entity *gopher =  GameEntityFactory::BuildCharacter(scale, pos, charType);
			mGophers.push_back( gopher );

			GraphicsManager::Instance()->AddComponent(gopher->GetGraphicsComponent(), GraphicsManager::POST);

			
			static_cast<GopherController*>(gopher->GetController())->
				SetCollisionAvoidance(mLevelControl.mCollisionAvoidance > 0);
			
		}
		// balls are spawned out of a pool
		else if ([type isEqualToString:@"ball"] )
		{
			
			float radius = [[object objectForKey:@"scale"] floatValue];
			
			int ballType = [[object objectForKey:@"ballType"] intValue];
			
			btVector3 pos( 8, 1.5, 10);
			
			if(mLevelControl.mPlayMode == GamePlayManager::POOL)
			{
				if(poolBallCount == 0)
				{
					ballType = ExplodableComponent::CUE_BALL;
 				}
				else
				{
					ballType = ExplodableComponent::BALL_8;
				}
			}
				
				
			bool poolBall = ballType == ExplodableComponent::BALL_8 || ballType == ExplodableComponent::CUE_BALL;
			
			// can roll if not in paddle mode
			
			
			Entity *ball = NULL;
			
			if(mLevelControl.mPlayMode == GamePlayManager::TILT_ONLY)
			{
			
				ball = GameEntityFactory::BuildBall(radius, 
														pos, 
														mLevelControl.mPlayMode != GamePlayManager::PADDLE, 
														poolBall ? 1.0f : 0.3f, 
														0.1f, 
														(ExplodableComponent::ExplosionType) ballType , 
														true,
														0.1f);
			}
			else
			{	
				ball = GameEntityFactory::BuildBall(radius, 
													pos, 
													mLevelControl.mPlayMode != GamePlayManager::PADDLE, 
													poolBall ? 1.0f : 0.3f, 
													1.0f, 
													(ExplodableComponent::ExplosionType) ballType , 
													false,
													0.5f);
				
			}
						
			PhysicsComponent *physics = dynamic_cast<PhysicsComponent*>(ball->GetPhysicsComponent());
			
			// add to phyz mgr
			PhysicsManager::Instance()->AddComponent( physics );

			// add to game mgr
			GamePlayManager::Instance()->AddBall( ball, ballType );			
			
				
			if(ballType == ExplodableComponent::BALL_8)
			{
				// explicitly spawn in 
				GamePlayManager::Instance()->SpawnBall(ball, poolBallCount-1);		
			}
			else {
				// explicitly spawn in 
				GamePlayManager::Instance()->SpawnBall(ball);						
			}
			
			poolBallCount++;

			// disable kinematic
			if(mLevelControl.mPlayMode == GamePlayManager::TAP || mLevelControl.mPlayMode == GamePlayManager::TILT_ONLY)
			{
				physics->SetKinematic(false);
			}
			
			GraphicsManager::Instance()->AddComponent(ball->GetGraphicsComponent(), GraphicsManager::POST);
			
			mBalls.push_back(ball);
			
		}
		else if([type compare:@"cannon"] == NSOrderedSame )
		{
			
			float scale = [[object objectForKey:@"scale"] floatValue];
			
			//btVector3 pos( 8, 1.5, 0);
			float x = [[object objectForKey:@"x"] floatValue];
			//float y = [[object objectForKey:@"y"] floatValue];
			float z = [[object objectForKey:@"z"] floatValue];
			btVector3 pos( x,1.5,z);
			
			float rotationOffset = [[object objectForKey:@"rotationOffset"] floatValue];
			
			float cannonPowerScale = [[object objectForKey:@"powerScale"] floatValue];
			if(cannonPowerScale == 0)
			{
				cannonPowerScale = 1;
			}
			
			float rotationScale = (mLevelControl.mPlayMode == GamePlayManager::CANNON) ? M_PI/1.8f : M_PI*1.1f;
			
			scale *= 4.0f;
			
			// can roll if not in paddle mode
			vector<Entity*> newObjects;
			GameEntityFactory::BuildCannon(scale, pos, newObjects, rotationOffset, rotationScale, cannonPowerScale);
			
			mCannon = newObjects[0];
			mHuds.push_back(newObjects[1]);
			mHuds.push_back(newObjects[2]);
			mHuds.push_back(newObjects[3]);
			
			GraphicsManager::Instance()->AddComponent( mCannon->GetGraphicsComponent(), GraphicsManager::POST ); 
			
			CannonController *controller = dynamic_cast<CannonController*>( mCannon->GetController());
			
			// create 50 balls, add to cannon
			int numBalls = ( mLevelControl.mNumBalls == -1) ? 20 :  mLevelControl.mNumBalls;
			
			for(int i = 0; i <numBalls ; i++)
			{
				
				float radius = scale * 0.125f * 0.75f;
				
				int randType = 1; //EXPLODE_SMALL
				
				if(mLevelControl.mBallTypes == 1 || 
				   mLevelControl.mBallTypes == 2 || 
				   mLevelControl.mBallTypes == 4 ||
				   mLevelControl.mBallTypes == 8 ||
				   mLevelControl.mBallTypes == 16)
				{
					randType = mLevelControl.mBallTypes;
				}
				else {
					
					// pick a random ball type
					while(true)
					{
						randType = 1 << (rand() % 5);
						if(randType & mLevelControl.mBallTypes)
						{
							break;
						}
					}
				}
				
				//ExplodableComponent::ExplosionType randType = ExplodableComponent::EXPLODE_SMALL;
				// can roll if not in paddle mode
				// in the case of ricochet, anti-gopher ball that doesn't detonate itself, only the goph
				Entity *ball = GameEntityFactory::BuildBall(radius, pos, true ,
															mLevelControl.mPlayMode == GamePlayManager::RICOCHET ? 1.0f : 0.8f,
															mLevelControl.mPlayMode == GamePlayManager::RICOCHET ? 0.5f : 1.0f,  
															(ExplodableComponent::ExplosionType) randType, 
															mLevelControl.mPlayMode == GamePlayManager::RICOCHET,
															mLevelControl.mPlayMode == GamePlayManager::RICOCHET? 0.01f:0.5f);
				mBalls.push_back(ball);
				
				ball->mActive = false;
				
				PhysicsComponent *physicsComponent = dynamic_cast<PhysicsComponent*>(ball->GetPhysicsComponent());
				physicsComponent->SetKinematic(true);
				controller->AddBall(ball);

				GraphicsManager::Instance()->AddComponent(ball->GetGraphicsComponent(), GraphicsManager::POST);

				
			}
		}
	}
	
	if( mBalls.size() == 0)
	{
		DLog(@"No balls loaded - fail");
	}
	
}

void SceneManager::LoadHUDs()
{

	// pause button (only on pool)
	if(mLevelControl.mPlayMode != GamePlayManager::POOL)
	{
		btVector3 position( -9, 1, -14);
		
		Entity *hud = GameEntityFactory::BuildScreenSpaceSprite(position, 2.0f, 2.0f, 
														 @"PauseButton", HUGE_VAL);
		
		// pause btn does not rotate
		static_cast<ScreenSpaceComponent*>(hud->GetGraphicsComponent())->mRotateTowardsTarget = false;
		static_cast<ScreenSpaceComponent*>(hud->GetGraphicsComponent())->mConstrainToCircle = false;
		
		// do not add to huds - Graphics Manager will clean this up
	}
	
	
	/*
	{
		btVector3 position( 0,1,0);
		btVector3 extent(3, 1, 1);
		
		Entity *hud = GameEntityFactory::BuildText(position, extent.x(), extent.z(), @"ABCDcore: 123");
		mHuds.push_back(hud);
		

	}*/
	
}

void SceneManager::ConvertToSingleBodies(Entity *compoundEntity, vector<Entity*> &newBodies)
{
	CompoundGraphicsComponent *graphicsParent = dynamic_cast<CompoundGraphicsComponent*>(compoundEntity->GetGraphicsComponent());		
	PhysicsComponent *physicsParent =  compoundEntity->GetPhysicsComponent();
	
	if(physicsParent && graphicsParent)
	{
		// toss the physics object
		btRigidBody *body = physicsParent->GetRigidBody();
		PhysicsManager::Instance()->RemoveComponent(physicsParent);
		GraphicsManager::Instance()->RemoveComponent(graphicsParent);
		
		while(!graphicsParent->IsEmtpy())
		{
			GraphicsComponent *gfxChild = graphicsParent->RemoveFirstChild();
			
			
			btVector3 initialPosition = compoundEntity->GetPosition();
			initialPosition += gfxChild->GetOffset();
			
			btVector3 halfExtents = gfxChild->GetScale();
			halfExtents *= 0.5;		
			
			PhysicsComponentInfo info;
			info.mIsStatic = false;
			info.mCanRotate = true;
			info.mRestitution = body->getRestitution();
			info.mMass =  1.0f/body->getInvMass();
			info.mDoesNotSleep = true;
			
			PhysicsComponent *physics = 
				PhysicsComponentFactory::BuildBox(
							initialPosition, halfExtents, 0, info);
			
			Entity *newEntity = new Entity();
#if DEBUG
			newEntity->mDebugName = "Destruction Child";
#endif
			
			newEntity->SetPosition(initialPosition);
			newEntity->SetGraphicsComponent(gfxChild);
			GraphicsManager::Instance()->AddComponent(gfxChild);
			
			PhysicsManager::Instance()->AddComponent(physics);
			newEntity->SetPhysicsComponent(physics);
			
			ExplodableComponent *finalExplodable = new ExplodableComponent(ExplodableComponent::EXPLODE_SMALL);
			finalExplodable->PrimeAfterDelay(1.0);
			newEntity->SetExplodable(finalExplodable);
			
			// and add to stuff to be removed later
			mSceneElements.insert(newEntity);
			
			newBodies.push_back(newEntity);
		}
		
		compoundEntity->mActive = false;
		
	}
	else 
	{
		DLog(@"Massive failure with Compound Explodable");
		GraphicsManager::Instance()->RemoveComponent(compoundEntity->GetGraphicsComponent());
		
		if(physicsParent)
		{
			PhysicsManager::Instance()->RemoveComponent(physicsParent);
		}	
			
		// wait for later for Sceme Mgr to delete
		compoundEntity->mActive = false;
		
	}
}


void SceneManager::UnloadScene()
{
	DLog(@" **** Unloading Scene **** ");
	
	PhysicsManager::Instance()->Unload();
	GamePlayManager::Instance()->Unload();
	GraphicsManager::Instance()->Unload();
	
	// try to evict the level control background texture
	//GraphicsManager::Instance()->EvictTexture(mLevelControl.mBackground);
	
	for(EntityIterator it = mSpawnPoints.begin(); it!= mSpawnPoints.end(); it++)
	{
		delete *it;
	}
	mSpawnPoints.clear();	
	
	for(EntityIterator it = mTargets.begin(); it!= mTargets.end(); it++)
	{
		delete *it;
	}
	mTargets.clear();
	
	for(EntityIterator it = mGophers.begin(); it!= mGophers.end(); it++)
	{
		delete *it;
	}
	mGophers.clear();
	
	
	for(EntityIterator it = mHedges.begin(); it!= mHedges.end(); it++)
	{
		delete *it;
	}
	mHedges.clear();
	
	
	for(EntityIterator it = mWalls.begin(); it!= mWalls.end(); it++)
	{
		delete *it;
	}
	mWalls.clear();
	
	
	for(EntityIterator it = mBalls.begin(); it!= mBalls.end(); it++)
	{
		delete *it;
	}
	mBalls.clear();
	
	
	for(EntityIterator it = mHuds.begin(); it!= mHuds.end(); it++)
	{
		delete *it;
	}
	mHuds.clear();
	
	// this is a set
	for(set<Entity*>::iterator it = mSceneElements.begin(); it != mSceneElements.end(); it++)
	{
		delete *it;
	}
	mSceneElements.clear();
	
	while (!mDelayedSpawns.empty()) 
	{
		delete mDelayedSpawns.front();
		mDelayedSpawns.pop_front();
	}
	mDelayedSpawns.clear();
	
	// TODO - pool these
	while(!mFXPool.empty())
	{
		Entity *ent = mFXPool.front();
		delete (ent);
		mFXPool.pop();
	}
	
	delete mCannon;
	mCannon = NULL;
	
	mSceneLoaded = false;

}

	
void SceneManager::CreateWalls( const string *backgroundTexture, int wallFlags, bool poolTable)
{	
	
	float kEpsilon = 0.5;
	
	const float wallRestitution = (mLevelControl.mPlayMode == GamePlayManager::RICOCHET) ? 1.0f : 0.9f;
	
	// create ground 
	if(wallFlags & FLOOR) {
		btVector3 pos(0,0,0);
		
		mWalls.push_back(GameEntityFactory::BuildGround(pos, mLevelControl.mWorldBounds.x() *2.0f, 
														mLevelControl.mWorldBounds.z() *2.0f, 
														backgroundTexture, poolTable));
		
	}
	
	// create top plate
	if(wallFlags & CEILING) {
		btVector3 pos(0,kWallHeight+2.0,0);
		
		mWalls.push_back(GameEntityFactory::BuildTopPlate(pos));
	}
	
	// catching objects off screen, then re-spawning
	//left wall
	if(wallFlags & LEFT) {
		btVector3 pos( -mLevelControl.mWorldBounds.x() - kEpsilon, kWallHeight, 0);
		btVector3 extents(kEpsilon,kWallHeight, mLevelControl.mWorldBounds.z() + kEpsilon );
		mWalls.push_back( GameEntityFactory::BuildWall(pos, extents, wallRestitution ) );
	}
	
	//right wall
	if(wallFlags & RIGHT) {
		btVector3 pos(mLevelControl.mWorldBounds.x() + kEpsilon, kWallHeight, 0);
		btVector3 extents(kEpsilon,kWallHeight, mLevelControl.mWorldBounds.z()  + kEpsilon );
		mWalls.push_back( GameEntityFactory::BuildWall(pos, extents, wallRestitution ) );
	}
	
	
	//top wall
	if(wallFlags & TOP) {
		btVector3 pos( 0, kWallHeight, mLevelControl.mWorldBounds.z() + kEpsilon );
		btVector3 extents(mLevelControl.mWorldBounds.x()+ kEpsilon , kWallHeight, kEpsilon);
		mWalls.push_back( GameEntityFactory::BuildWall(pos, extents, wallRestitution ) );
	}
	
	//bottom wall
	if(wallFlags & BOTTOM) {
		btVector3 pos( 0, kWallHeight, -mLevelControl.mWorldBounds.z() - kEpsilon  );
		btVector3 extents(mLevelControl.mWorldBounds.x()+ kEpsilon , kWallHeight, kEpsilon);
		mWalls.push_back( GameEntityFactory::BuildWall(pos, extents, wallRestitution ) );
	}
	
}

// this handles spawn and respawn
void SceneManager::Update(float dt)
{

	
	for(list<SpawnInfo *>::iterator it = mDelayedSpawns.begin(); it != mDelayedSpawns.end(); it++  ) 
	{
		SpawnInfo *info = *it;
		if( info->mSpawnTime <= GamePlayManager::Instance()->GetLevelTime())
		{
			Entity * item = NULL;
			//spawn
			
			
			
			if(info->mTypeName == "rock")
			{
				
				DLog(@"Spawn Rock");
				item = GameEntityFactory::BuildCircularCollider(
												info->mPosition, 
												info->mScale, 
												0.45f,  
												@"rock", 
												1.33f);
				
				mSceneElements.insert(item);
				
				//GraphicsManager::Instance()->ShowFXElement(info->mPosition, ExplodableComponent::FREEZE);
				
				delete info;
				
				it = mDelayedSpawns.erase(it);
			}
			else if(info->mTypeName == "flower")
			{
				
				DLog(@"Spawn Flower");
				
				RespawnInfo *respawnInfo = (RespawnInfo*)(info);
				DLog(@" Scn: Respawn Info %f", respawnInfo->mRespawnInterval);
				
				item = GameEntityFactory::BuildCircularExploder(info->mPosition, 
																info->mScale, 
																@"flower", 
																respawnInfo->mRespawnInterval, 1, ExplodableComponent::EXPLODE_SMALL) ;
			
			
				GraphicsComponent *graphics= item->GetGraphicsComponent();
				graphics->mActive = false;
				
				mSceneElements.insert(item);
				
				GraphicsManager::Instance()->ShowFXElement(info->mPosition, @"flower.sheet", graphics, info->mScale.x());
				
				delete info;
				
				it = mDelayedSpawns.erase(it);
				
			}
			else if( info->mTypeName.find("flower") != string::npos)
			{
				//NSString *subType = [[NSString alloc] initWithString:[type substringFromIndex:6]];
				//DLog(@"Type Name %@", subType);
				
				RespawnInfo *respawnInfo = (RespawnInfo*)(info);
				DLog(@" Scn: Respawn Info %f", respawnInfo->mRespawnInterval);
				
				Entity *item = GameEntityFactory::BuildCircularExploder(info->mPosition, 
																		info->mScale, 
																		[[NSString alloc] initWithUTF8String:info->mTypeName.c_str()], 
																		respawnInfo->mRespawnInterval, 1,
																		ExplodableComponent::POP);
				
				
				GraphicsComponent *graphics= item->GetGraphicsComponent();
				graphics->mActive = false;
				
				mSceneElements.insert(item);
				
				//NSString *baseName =  [[NSString alloc] initWithUTF8String:info->mTypeName.c_str()];
				//NSString *sheetName = [baseName stringByAppendingString:@".sheet"];
				
				GraphicsManager::Instance()->ShowFXElement(info->mPosition, @"flowerPurple.sheet", graphics, info->mScale.x());
				
				//[baseName release];
 				//[sheetName autorelease];
				
				
				delete info;
				
				it = mDelayedSpawns.erase(it);				
				
			}
			
			else {
				DLog(@"Don't know how to spawn %@", [[NSString alloc] initWithUTF8String:info->mTypeName.c_str()]);
			}

			
		}
		
	}
	
	
}

