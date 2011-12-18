/*
 *  GamePlayManager.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#include "GamePlayManager.h"

#import <btBulletDynamicsCommon.h>
#import <vector>
#import <algorithm>
#import <set>

#import "TriggerComponent.h"
#import "ExplodableComponent.h"
#import "GateControllerComponent.h"
#import "GamePlayManager.h"
#import "Entity.h"
#import "NodeNetwork.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"

#import "PhysicsManager.h"
#import "PhysicsComponentFactory.h"
#import "TargetComponent.h"
#import "SceneManager.h"

using namespace std;

const float kTapForce = 30.0;


namespace Dog3D
{
	 
	typedef list<GopherController*>::iterator NavIterator;
	typedef list<Entity *>::iterator EntityListIterator;
	
#pragma mark INIT AND CTOR	
	
	GamePlayManager * GamePlayManager::sGamePlayManager;
	
	void GamePlayManager::Initialize()
	{
		sGamePlayManager = new GamePlayManager();
		srand(2);	
	}
	
	void GamePlayManager::Unload()
	{
		mActiveGophers.clear();
		
		while(!mDeadGopherPool.empty())
		{
			mDeadGopherPool.pop();
		}
		
		mTargets.clear();
		
		mBalls.clear();
		
		mNodeNetwork = TheMadGamer::NodeNetwork();
		
		mSpawnComponents.clear();
		
#ifdef BUILD_PADDLE_MODE
		mPaddles.clear();
		mFlippers.clear();
#endif
		
		mExplodables.clear();
		
		mKinematicControllers.clear();
		
		mSpawnIntervals.clear();
		
		mGopherHUD = NULL;
		mCarrotHUD = NULL;
		
		mLevelTime = 0;
		
		mCannonController = NULL;
		mCannonUI = NULL;
		
#if DEBUG
		if(mDebugVertices)
		{
			delete [] mDebugVertices;
		}
#endif
		
	}
	
#if DEBUG
	void GamePlayManager::DrawDebugLines()
	{
		return;
		
		UpdateDebugVertices();
		
		glEnableClientState(GL_VERTEX_ARRAY);
		
		// MATERIAL
		glDisableClientState(GL_COLOR_ARRAY);
		glColor4f(1,1,1,1);
		
		for(int i = 0; i < mNumDebugVertices; i+=2)
		{			// To-Do: add support for creating and holding a display list
			glVertexPointer(3, GL_FLOAT, 0, mDebugVertices+i);
			glDrawArrays(GL_LINE_STRIP, 0, 2);
			
		}
	}
#endif
	
	void GamePlayManager::InitializeNodeNetwork()
	{
		
		int nodeId = 0;
		int nLinks = 0;
		
		const float kCarrotOffset = -1;
		const float kSpawnOffset = -1.25;
		
		for(std::list<Entity*>::iterator it = mTargets.begin(); it != mTargets.end(); it++)
		{
			
			Entity *target = (*it);
			TheMadGamer::Vec2 position(target->GetPosition().getX()+kCarrotOffset, target->GetPosition().getZ());
			mNodeNetwork.AddNode(nodeId, 
								 new TheMadGamer::PositionedNode(nodeId, position));
			
			// allows removal of carrot nodes
			TargetComponent *targetComponent = static_cast<TargetComponent*>(target->FindComponentOfType(TARGET));
			targetComponent->mNetworkNodeID = nodeId;
					
			for(int j = 0; j < nodeId; j++)
			{
				mNodeNetwork.LinkBiDirectional(j, nodeId);
				nLinks++;
			}
			
			nodeId++;
		}
		
		
		int lastTargetId = nodeId-1;
		
		for(int i = 0; i < mSpawnComponents.size(); i++)
		{
			// this causes gophs to spawn in up when below the midline and spawn downward when above
			// keeps gophs from spawning off screen
			float dX = mSpawnComponents[i]->GetParent()->GetPosition().getX() > 0 ? 
				mSpawnComponents[i]->GetParent()->GetPosition().getX()+kSpawnOffset 
			: mSpawnComponents[i]->GetParent()->GetPosition().getX()-kSpawnOffset;
			
			TheMadGamer::Vec2 position(dX, 
									   mSpawnComponents[i]->GetParent()->GetPosition().getZ());
			mNodeNetwork.AddNode(nodeId, 
								 new TheMadGamer::PositionedNode(nodeId, position));
			
			// allows removal of carrot nodes
			TargetComponent *targetComponent = static_cast<TargetComponent*>(mSpawnComponents[i]->GetParent()->FindComponentOfType(TARGET));
			targetComponent->mNetworkNodeID = nodeId;
			
			for(int targetId = 0; targetId <= lastTargetId; targetId++)
			{
				mNodeNetwork.LinkBiDirectional(targetId, nodeId);
				nLinks++;
			}
			
			nodeId++;
		}
		
		mNumDebugVertices = nLinks * 4;  //links are bi-directional
#if DEBUG
		mDebugVertices = new Dog3D::Vec3[mNumDebugVertices];
#endif
	}
	
#pragma mark DEBUG_VERTS
	void GamePlayManager::UpdateDebugVertices()
	{
		vector<int> nodeIds;
		
		mNodeNetwork.GetAllNodeIDs(nodeIds);
		
		
		int debugCnt = 0;
		
		// for each spawn component, draw links
		for(int i = 0; i < nodeIds.size();i++)
		{
			const TheMadGamer::PositionedNode *startNode = mNodeNetwork.GetNode(nodeIds[i]);
			
			const vector<int> *links = mNodeNetwork.GetLinksFrom(nodeIds[i]);
			
			for(int j = 0; j < links->size(); j++)
			{
				const TheMadGamer::PositionedNode *endNode = mNodeNetwork.GetNode((*links)[j]);
				TheMadGamer::Vec2 debugVec;
				
				startNode->GetPosition(debugVec);
#if DEBUG
				mDebugVertices[debugCnt++] = Vec3(debugVec.x, 1, debugVec.y);
#endif		
				endNode->GetPosition(debugVec);
#if DEBUG
				mDebugVertices[debugCnt++]  = Vec3(debugVec.x, 1, debugVec.y);
#endif		
			}
		}
		
		mNumDebugVertices = debugCnt-1;
	}
	
	void GamePlayManager::InitializeDebugNetwork()
	{
		
		int nodeId = 0;
		
		//TODO hard coded
		
		for(int y = -12; y <= 12; y+=3)				
		{
			for(int x = -9; x <= 9; x+= 3)
			{
				TheMadGamer::Vec2 initialPosition(x,y);
				mNodeNetwork.AddNode(nodeId, new TheMadGamer::PositionedNode(nodeId, initialPosition));
				
				nodeId++;
			}
		}
		
		nodeId = 0;
		for(int y = -12; y <= 12; y+=3)				
		{
			for(int x = -9; x <= 9; x+= 3)
			{
				
				if(x > -9)
				{
					mNodeNetwork.LinkBiDirectional(nodeId, nodeId-1);
				}
				
				if(y > -12)
				{
					mNodeNetwork.LinkBiDirectional(nodeId, nodeId-7);
				}
				
				/*if( x > -9 && y > -12)
				{
					mNodeNetwork.LinkBiDirectional(nodeId, nodeId -8);
				}
				
				if( x < 9 && y > -12)
				{
					mNodeNetwork.LinkBiDirectional(nodeId, nodeId -6);
				}*/
				
				nodeId++;
				
			}
		}
	}
	
#pragma mark UPDATE
	void GamePlayManager::Update(float deltaTime)
	{
		if(mActiveGophers.size() == 0 && mDeadGopherPool.empty())
		{
			return;
		}
#ifdef BUILD_PADDLE_MODE
		for(int i = 0; i < mPaddles.size(); i++)
		{
			mPaddles[i]->Update(deltaTime);
		
		}
		
		for(int i = 0; i < mFlippers.size(); i++)
		{
			mFlippers[i]->Update(deltaTime);
		}
#endif
				
		if(mGameState == GOPHER_WIN || mGameState == GOPHER_LOST)
		{

			for(EntityListIterator it = mBalls.begin(); it!= mBalls.end(); it++)
			{
				(*it)->mActive = false;
			}
			
			// compute positions
			// eat veggies - todo move this up to update carrot eating
			if(mGameState == GOPHER_LOST)
			{
				for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
				{
					// throw in an explode here
					if((*it)->GetControllerState() != GopherController::EXPLODE)
					{
						btVector3 position = (*it)->GetParent()->GetPosition();
						position.normalize();
					
						(*it)->Explode( position );
					}
				}

				// update exploding gophers
				CleanUpGopherBodies();
			}
			else 
			{
				for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
				{
					if((*it)->GetControllerState() != GopherController::WIN_DANCE)
					{
						(*it)->WinDance( );
					}
				}
				
				// compute positions
				// eat veggies - todo move this up to update carrot eating
				UpdateControllers(deltaTime);
				
								
				// update exploding gophers
				CleanUpGopherBodies();

				// spawn in new gophers
				SpawnNewGophers(deltaTime, mLevelTime);
			}
		}
		else
		{
			
			if( mTouched || mFlicked)
			{
				// todo - should rely on an input object/controller
				// steps ball or changes velocity given a tap
				UpdateBallMotion();
			}
			
			// if ball impacts a gopher, explode gopher
			UpdateObjectContacts(deltaTime);
			
			// compute positions
			// eat veggies - todo move this up to update carrot eating
			UpdateControllers(deltaTime);
			
			// update exploding gophers
			CleanUpGopherBodies();
			
			// spawn in new gophers
			SpawnNewGophers(deltaTime, mLevelTime);
			
			// spawn or spawn new balls
			ReclaimBalls(deltaTime);
			
			if(mGamePlayMode == TILT_ONLY && 
			   mBalls.size() > 0)
			{
				btVector3 point= mBalls.front()->GetPosition();
				
				mFocalPoint *= 0.9;
				mFocalPoint += point * 0.1f;
			}
			
		}
			
		if(mCarrotLives <= 0 || 
		   mScratched || NoBallsLeft() )
		{
			mGameState = GOPHER_WIN;
		}
		else if(mGopherLives <= 0 )
		{
			mGameState = GOPHER_LOST;
		}
		else 
		{
			mGameState = PLAY;
		}
		
		mLevelTime+= deltaTime;
	}	

	
	// spawns in ball at a new location
	void GamePlayManager::ReclaimBalls(float dt)
	{
		for(list<Entity *>::iterator it = mBalls.begin(); it != mBalls.end(); it++ )
		{
			Entity *entity = (*it);
			if( entity->mActive)
			{
				btVector3 position = entity->GetPosition();	
				ExplodableComponent *explodable =  entity->GetExplodable();	
				
				
				// if ball is in a RECLAIM state
				// or its out of bounds, reclaim
				if ( (explodable && explodable->CanReclaim()) ||
					(fabs(position.getX()) > (mWorldBounds.x() + 5) || 
					 position.getY() < -5 || 
					 fabs(position.getZ()) > (mWorldBounds.z() + 5) ||
					 position.getY() > 20))
				{
					PhysicsManager::Instance()->RemoveComponent(entity->GetPhysicsComponent());
					
					ReclaimBall(entity);
					//toRemove.push_back(entity);
					if(mCannonController)
					{
#if DEBUG
						DLog(@"Removing Ball %s", (*it)->mDebugName.c_str());
#endif
						it = mBalls.erase(it);
					}
				}
			}
		}
	}
	
	// either respawns ball or adds to cannon
	void GamePlayManager::ReclaimBall(Entity *ball)
	{
		
		ExplodableComponent *explodable = ball->GetExplodable();
		
		// reset the explodable into idle state
		explodable->Reset();
		
		if(mCannonController )
		{
			// get the physics component
			PhysicsComponent *physicsComponent =  ball->GetPhysicsComponent();
			physicsComponent->SetKinematic(true);
			ball->mActive = false;
			if(mUnlimitedBalls)
			{
				// adds to physics world
				mCannonController->AddBall(ball);
			}
		}
		else
		{
			// adds back to physics world
			// continuous spawn
			SpawnBall(ball);
		}
	}
	
	// for touch/flick/tilt mode only
	// adds ball back to physics world
	void GamePlayManager::SpawnBall(Entity *ball, int position)
	{
		DLog(@"Spawining ball");
		
		ExplodableComponent *explodable = ball->GetExplodable();
		
		// only in flick mode do we defer activation
		if(mGamePlayMode != FLICK)
		{
			explodable->Prime();
		}
		
		// pick a random start point (see rands below)
		btVector3 resetPosition(mBallSpawn);
		mBallSpawn.setY(1.5);
		
		if(mGamePlayMode == POOL)
		{
			
			if(explodable->GetExplosionType() == ExplodableComponent::CUE_BALL)
			{
				resetPosition.setValue(0, 1.5, 5);
			}
			else 
			{
				if(position == 0)
				{
					resetPosition.setValue(0, 1.5, -5);
				}
				else 
				{
					resetPosition.setValue(0.75, 1.5, -6.25);
					
					
					if(position == 2)
					{
						resetPosition.setX(-0.75);			
					}
					
				}
			}
		}

		// re activate gfx
		ball->GetGraphicsComponent()->mActive = true;
		
		// get fx component				
		vector<Component *> fxComponents;
		ball->FindComponentsOfType(FX, fxComponents);
		
		// disable
		for(int i = 0; i < fxComponents.size(); i++)
		{
			FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
			fxComponent->mActive = true;
		}
		
		
		// form a transform to respawn at
		btTransform transform;
		transform.setIdentity();
		transform.setOrigin(resetPosition);
		
		// get the physics component
		PhysicsComponent *physicsComponent = ball->GetPhysicsComponent();
		
		if(physicsComponent)
		{
			// get the rigid body
			btRigidBody *rigidBody = physicsComponent->GetRigidBody();
			
			if(rigidBody)
			{
				// update the rigid body transform
				rigidBody->setWorldTransform(transform);
				
				btVector3 zero(0,0,0);
				rigidBody->setLinearVelocity(zero);
				rigidBody->setAngularVelocity(zero);
				
			}
			
			PhysicsManager::Instance()->AddComponent(physicsComponent);
			
			if(mGamePlayMode == FLICK )
			{
				physicsComponent->SetKinematic(true);
			}
			else {
				physicsComponent->SetKinematic(false);
			}
		}
		// set the parent object's position
		ball->SetPosition(resetPosition);
		
		if(mGamePlayMode == PADDLE)
		{
			ball->GetPhysicsComponent()->GetRigidBody()->setLinearVelocity(btVector3(0,0,25));
		}
		
	}
	
	
	// updates ball motion if there's a touch motion
	// for touch control 
	void GamePlayManager::UpdateBallMotion()
	{
		
		for(EntityListIterator it = mBalls.begin(); it != mBalls.end(); it++)
		{
			Entity *ball = (*it);
			
			ExplodableComponent *explodable = ball->GetExplodable();
			if(explodable->IsExploding())
			{
				// let physics drive
				return;
			}
			
			PhysicsComponent *physicsComponent = ball->GetPhysicsComponent();
			if(!physicsComponent)
			{
				return;
			}
			
			// tap control mode
			if(mTouched)
			{
				btVector3 direction = mTouchPosition;
				
				btVector3 ballPosition = ball->GetPosition();
				direction -= ballPosition;
				
				direction.normalize();
				direction *= kTapForce;
				
				btRigidBody *rigidBody = physicsComponent->GetRigidBody();
				
				btVector3 velocity = rigidBody->getLinearVelocity();
				
				velocity += direction;
				
				rigidBody->setLinearVelocity(velocity);
				
				mTouched = false;
				
			}
#ifdef ENABLE_FLICK_MODE			
			// flick control mode
			if( mFlicked )
			{
				btRigidBody *rigidBody = physicsComponent->GetRigidBody();
				
				//mFlick *= 5.0;
				float velocity = mFlick.length();
				if(velocity > 100)
				{
					mFlick.normalize();
					mFlick *= 100;
				}
				
				rigidBody->setLinearVelocity(mFlick);
				
				// let ball move under physics control
				physicsComponent->SetKinematic(false);
				explodable->Prime();
				
				mFlicked = false;
			}
#endif
		}
		
	}
	
	// check ball/gopher collisions for explode
	void GamePlayManager::UpdateObjectContacts(float dt)
	{

		set<EntityPair> triggeredObjects;
		
		PhysicsManager::Instance()->GetTriggerContactList(triggeredObjects);
		
		for(set<EntityPair>::iterator sIt = triggeredObjects.begin(); sIt != triggeredObjects.end(); sIt++)
		{
			// check gopher gopher
			if(sIt->first->GetExplodable() == NULL
			   && sIt->second->GetExplodable() == NULL)
			{
#if DEBUG
				// happens all over - sprays log
				//DLog(@"Gopher Gopher Collision ");
#endif		
				Component *controllerA = sIt->first->GetController();
				Component *controllerB = sIt->second->GetController();
				if(controllerA && controllerB )
				{
					GopherController *gA = static_cast<GopherController*>(controllerA);
					GopherController *gB = static_cast<GopherController*>(controllerB);
					
					if( gA->Reactive()  &&
					   (gB->CanExplode()))	
					{
#if DEBUG
						DLog(@"Gopher/Gopher");
#endif	
						gB->OnCollision(sIt->first);
					}
					else if(gB->Reactive() &&
							(gA->CanExplode()))
					{
#if DEBUG
						DLog(@"Gopher/Gopher");
#endif	
						gA->OnCollision(sIt->second);
					}
				}
				else {
#if DEBUG
					DLog(@"No explodables, no controllers?");
					DLog(@" - %s %s ", sIt->first->mDebugName.c_str(), sIt->second->mDebugName.c_str());
#endif	
				}

			
			}
			else
			{
#if DEBUG
				if((sIt->first	) && (sIt->second))
				{
					DLog(@"Collision %s %s ", sIt->first->mDebugName.c_str(), sIt->second->mDebugName.c_str());
				}
#endif		
				
				// check ball ball explodable
				// removes scratch rule
				/*if(mGamePlayMode == POOL)
				{
					ExplodableComponent *explodableA = sIt->first->GetExplodable();
					ExplodableComponent *explodableB = sIt->second->GetExplodable();
					
					if(( (!explodableB) && explodableA->GetExplosionType() == ExplodableComponent::CUE_BALL) ||
					  ( (!explodableA) && explodableB->GetExplosionType() == ExplodableComponent::CUE_BALL))
					{
						mScratched = true;
					}
					
				}*/
				
			   
				{
					ExplodableComponent *explodable = sIt->first->GetExplodable();
					ExplodableComponent *secondExplodable = sIt->second->GetExplodable();
					
					if(explodable && (!secondExplodable || (secondExplodable &&
					   secondExplodable->DetonatesOtherCollider())) && explodable->IsPrimed())
					{
						explodable->OnCollision(sIt->second);
						
					}
					else 
					{
						// gopher
						Component *controller = sIt->first->GetController();
						if(controller)
						{
							// prevents double explosion
							GopherController *gController = dynamic_cast<GopherController*> (controller);
							if(gController->CanExplode())
							{
								
								gController->OnCollision(sIt->second);
								RemoveGopherLife();
							}
						}
						else
						{
#if DEBUG
							//Entity *entA = sIt->first;
							//Entity *entB = sIt->second;
							DLog(@"Collision FAIL");
#endif						
						}
					}
				}
				
				{
					ExplodableComponent *explodable = sIt->second->GetExplodable();
					ExplodableComponent* firstExplodable = sIt->first->GetExplodable();
					if(explodable && (!firstExplodable 
								|| (firstExplodable && firstExplodable->DetonatesOtherCollider()))
					   && explodable->IsPrimed())
					{
						explodable->OnCollision(sIt->first);
					}
					else 
					{
						// gopher
						Component *controller = sIt->second->GetController();
						if(controller )
						{
							// prevents double explosion
							GopherController *gController = dynamic_cast<GopherController*> (controller);
							if(gController->CanExplode())
							{
								gController->OnCollision(sIt->first);
								RemoveGopherLife();
							}
							
						}
						else
						{
#if DEBUG
							//Entity *entA = sIt->first;
							//Entity *entB = sIt->second;
							DLog(@"Collision FAIL");
#endif
						}
					}
				}
			}
		}
	}
	
	// updates ball (explode) and gopher controllers
	void GamePlayManager::UpdateControllers(float dt)
	{
		for(EntityListIterator it = mBalls.begin(); it != mBalls.end(); it++)
		{
			ExplodableComponent *explodable = (*it)->GetExplodable();
			explodable->Update(dt);
		}
		
		for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
		{
			if((*it)->GetParent()->mActive)
			{
				(*it)->Update(dt);
			}
		}
	
		for( list<ExplodableComponent *>::iterator it = mExplodables.begin(); it != mExplodables.end(); it++)
		{
			ExplodableComponent *explodable = (*it);
			if(explodable->CanReclaim())
			{
#if DEBUG
				DLog(@"Removing Explodable %s",explodable->GetParent()->mDebugName.c_str());
#endif
				it = mExplodables.erase(it);
				
			}
			else {
				explodable->Update(dt);
			}
		}
		
		// and update gates
		for( list<Component *>::iterator it = mKinematicControllers.begin(); it != mKinematicControllers.end(); it++)
		{
			(*it)->Update(dt);
		}
		
	}
	
	// gopher out of bounds or timed out
	void GamePlayManager::CleanUpGopherBodies()
	{
		
		for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
		{
			
			Entity *gopher = (*it)->GetParent();
			btVector3 position = gopher->GetPosition();	
			
			if(abs(position.getX()) > (mWorldBounds.x() + 2) || 
			   abs(position.getZ()) > (mWorldBounds.z()+2))
			{
				DLog(@"Bounds");
			}
			

			if(abs(position.getX()) > (mWorldBounds.x() + 2) || 
			   abs(position.getZ()) > (mWorldBounds.z() + 2) ||
			   ( (*it)->GetControllerState() == GopherController::EXPLODE && (*it)->GetExplodeTime() > 3)  ||
			   (*it)->GetControllerState() == GopherController::DEAD)				
			{
				// this puts the gopher into a spawn state
				// away from everythign
				(*it)->Spawn(btVector3(0,-100.1,0));
				
				static_cast<AnimatedGraphicsComponent*>(gopher->GetGraphicsComponent())->PlayAnimation(AnimatedGraphicsComponent::IDLE);
				gopher->mActive = false;
				
				mDeadGopherPool.push(*it);
				
				it = mActiveGophers.erase(it);
				
				PhysicsManager::Instance()->RemoveComponent(gopher->GetPhysicsComponent());
				DLog(@"Removing gopher from world");
			}
		}
	}
	
	///Spaws gopehrs at random holes
	void GamePlayManager::SpawnNewGophers(float dt, float gameTime)
	{
		
		if(mSpawnDelay > 0)
		{
			mSpawnDelay -= dt;
			return;
		}
		
		// look at first item in queue
		pair<float, int> front = mSpawnIntervals.front();
		
		if(mSpawnIntervals.size() > 0 && (gameTime > front.first))
		{
			
			//front = mSpawnIntervals.front();
			mNumGophersToSpawn = front.second;
			//DLog(@"Next Spawn Interval: %d time: %f", front.first, front.second);
		
			mSpawnIntervals.pop_front();
		}
		
		if(mGamePlayMode == RICOCHET)
		{
			mNumGophersToSpawn = min(mNumGophersToSpawn, mGopherLives);
		}

		int numToSpawn =  mNumGophersToSpawn - mActiveGophers.size() ;
		
		if(numToSpawn > 0)
		{
			DLog(@"Active %d Gophs to Spawn %d", mActiveGophers.size(), mNumGophersToSpawn);
			DLog(@"Spawining in %d gophers", numToSpawn);
		}
		
		for(int i = 0; i < numToSpawn; i++)
		{
			if(mDeadGopherPool.empty())
			{
				// nothing to spawn
				break;
			}
			
			GopherController *controller = mDeadGopherPool.front();
			Entity *gopher = (controller)->GetParent();
			mDeadGopherPool.pop();
			
			btVector3 spawnPosition;
			
			for(int i = 0; i < 20; i++)
			{
                
                if(SceneManager::Instance()->GetSingleUseHoles())
                {
                    mSpawnInIdx = this->mGopherLives-1;
                }
                else
                {
                    // try to find a random, unoccupied spawn point
                    mSpawnInIdx = rand() % (mSpawnComponents.size());
				}
                
				if(! (mSpawnComponents[mSpawnInIdx]->GetOccupied()))
				{
					DLog(@"Adding gopher to world at spawn %i", mSpawnInIdx);
					
					Entity *spawn =  mSpawnComponents[ mSpawnInIdx ]->GetParent();
					
					btVector3 spawnPosition = spawn->GetPosition();
					spawnPosition.setY(0.1);
					
					controller->Spawn(spawnPosition);
					mSpawnComponents[mSpawnInIdx]->SetOccupied();
					
					gopher->mActive = true;
										
					// set back under kinematic control
					PhysicsComponent* physicsComponent = gopher->GetPhysicsComponent();
					
					btVector3 zero(0,0,0);
					physicsComponent->SetKinematic(true);
					physicsComponent->GetRigidBody()->setLinearVelocity(zero);		
					physicsComponent->GetRigidBody()->setAngularVelocity(zero);
					
					physicsComponent->AddGhostCollider();
					PhysicsManager::Instance()->AddComponent(physicsComponent);
					PhysicsManager::Instance()->AddGhostCollider(physicsComponent->GetGhostCollider());
					
					mActiveGophers.push_back(controller);
					
					// warning arrow system
					if(mGamePlayMode == TILT_ONLY && 
					   (mWorldBounds.z() > 15 || mWorldBounds.x() > 10))
					{
						GraphicsManager::Instance()->PointWarningArrowAt(spawnPosition);
					}
					
					mSpawnDelay = ((float) (rand() % 5)) * 0.2f;
					
					break;
				}
			}
			
			// can't find any spawn points, wait till next iteration
			if(!gopher->mActive)
			{
				mDeadGopherPool.push( static_cast<GopherController*> (gopher->GetController()));
				break;
			}
			
		}
		
		for(int i = 0; i < mSpawnComponents.size(); i++)
		{
			mSpawnComponents[i]->Update(dt);
		}
		
		
		if( mSpawnIntervals.size() == 0)
		{
			SceneManager::Instance()->RefreshSpawnIntervals(gameTime);
			//DLog(@"Refreshing spawn intervals");
		}
		
		
	}
	
#pragma mark NETWORK PRIVATE
	void GamePlayManager::RemoveTargetNode(int nodeId)
	{
		// deactivate associated node
		mNodeNetwork.RemoveNode(nodeId);
	}
	
	
	Entity *GamePlayManager::PickTarget(btVector3 position)
	{
		if(rand() %2 == 1)
		{
			DLog(@"Get Closest Hole");
			return GetClosestHole(position);
		}
		else 
		{
			DLog(@"Get Random Carrot");
			return GetRandomCarrot(position);
		}
		
	}
	
	Entity *GamePlayManager::GetClosestHole(btVector3 position)
	{
		float distToClosest = HUGE_VAL;
		
		// assumes there is one spawn hole
		// also assumes that not all holes will be occupied (ie holes outnumber gophers)
		
		Entity *closestSpawn = NULL;
		
		for(int i = 0; i < mSpawnComponents.size(); i++)
		{
			btVector3 dist = position - mSpawnComponents[i]->GetParent()->GetPosition();
			
			float currentDist = dist.length();
			if(currentDist < distToClosest && (!mSpawnComponents[i]->GetOccupied()))
			{
				closestSpawn = mSpawnComponents[i]->GetParent();
				distToClosest = currentDist;
			}
		}
		
		if(closestSpawn == NULL)
		{
			// return a random if the search fails
			return mSpawnComponents[rand() % mSpawnComponents.size()]->GetParent();
		}
		
		return closestSpawn;
		
	}
	
	
	Entity *GamePlayManager::GetRandomCarrot(btVector3 position)
	{
		// try for a proximal target

		float closestDist = HUGE_VAL;
		Entity *closestTarget = NULL;
		
		for(list<Entity*>::iterator it = mTargets.begin(); it!= mTargets.end(); it++)
		{
			if((*it)->mActive)
			{
				btVector3 dist = position - (*it)->GetPosition();
				float distance = dist.length();
				if(distance < mCarrotSearchDistance && distance < closestDist)
				{
					closestTarget = (*it);
					closestDist = distance;
				}
			}
		}
		
		return closestTarget;
		

		/*
		// if no proximal target then
		// pick a random carrot as target
		while(true)
		{
			int randomTarget = rand() % mTargets.size();
			if( mTargets[randomTarget]->mActive)
			{
				return mTargets[randomTarget];
			}
		}*/
	}
	
	
	void GamePlayManager::AddGopherController( GopherController *gopher)
	{
		//mActiveGophers.push_back(gopher);
		mDeadGopherPool.push(gopher);
	}
}