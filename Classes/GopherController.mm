/*
 *  GopherController.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/12/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "GopherController.h"
#import "GraphicsComponent.h"
#import "GamePlayManager.h"
#import "ExplodableComponent.h"


#import <vector>
#import <algorithm>

#import "Entity.h"
#import "GraphicsManager.h"
#import "TargetComponent.h"


namespace Dog3D
{
	
	void GopherController::Spawn( const btVector3 &spawnPosition)
	{
		mParent->SetPosition(spawnPosition);
		
		mPath.clear();
		mControllerState = SPAWN;
		
		static_cast<AnimatedGraphicsComponent *>(mParent->GetGraphicsComponent())
			->StartAnimation(AnimatedGraphicsComponent::JUMP_DOWN_HOLE, MIRROR_NONE,  false);
	}

	void GopherController::Idle()
	{
		DLog(@"Idle");

		mActiveTarget = NULL;
		mControllerState = IDLE;
		mPauseFrame = 30;
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::IDLE);
	}
	
	/*void GopherController::Freeze()
	{
		
		DLog(@"Freeze");

		mPreviousState = mControllerState;
		mControllerState = FREEZE;
		mPauseFrame = 90;
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::FREEZE);
		
	}*/
	
	void GopherController::Electro()
	{
		
		DLog(@"Electro");
		
		mPreviousState = mControllerState;
		mControllerState = ELECTRO;
		mPauseFrame = 90;
		
		dynamic_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::ELECTRO);
		
	}
	
	
	void GopherController::Fire()
	{
		DLog(@"FIRE-");
		mPreviousState = mControllerState;
		mControllerState = FIRE;
		mPauseFrame = 45;
		
		AnimationMirroring mirror = (rand() %2) ? MIRROR_HORIZONTAL : MIRROR_NONE;
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(
										AnimatedGraphicsComponent::FIRE, mirror);
	}
	
	void GopherController::Taunt()
	{
		DLog(@"Taunt");
		mPreviousState = mControllerState;
		mControllerState = TAUNT;
		mPauseFrame = 121;
		
		// note hard coded taunt time
		SetRandomTauntDelay();
		
		static_cast<AnimatedGraphicsComponent*>(
			mParent->GetGraphicsComponent())->StartAnimation(
			AnimatedGraphicsComponent::TAUNT,  (rand() %2) == 1 ? MIRROR_NONE : MIRROR_HORIZONTAL);

	}
	
	void GopherController::Attack(Entity *target, const TheMadGamer::NodeNetwork *nodeNetwork)
	{
		DLog(@"Attack");
		mActiveTarget = target;
		mControllerState = ATTACK;
	
		// pick a random time to taunt at
		SetRandomTauntDelay();
		
		// from our position 
		TheMadGamer::Vec2 currentPosition(mParent->GetPosition().getX(), mParent->GetPosition().getZ());
		
		// to the target node's position, not the target
		TargetComponent *targetComponent = static_cast<TargetComponent*> (target->FindComponentOfType(TARGET));
		if(!targetComponent)
		{
			DLog(@"Attack FAIL - no target component");
			return;
		}
		
		// get target ID
		int targetNodeID = targetComponent->mNetworkNodeID;
		//TheMadGamer::Vec2 targetPos(target->GetPosition().getX(), target->GetPosition().getZ());
		
		nodeNetwork->GetShortestPath(mPath, currentPosition, targetNodeID);
		
		DLog(@"Attack - path len %d", mPath.size());
	}
	
	void GopherController::Eat()
	{
		DLog(@"Eat");
		
		mControllerState = EAT;
		mPauseFrame = 119;
		
		// deactivate target (keep around so that at end of cycle, node can be removed from network)
		mActiveTarget->mActive = false;
		
		GamePlayManager::Instance()->RemoveCarrotLife();
		
		static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::EAT_CARROT);
		
		
	}
	
	void GopherController::JumpDown()
	{
		mControllerState = JUMP_DOWN;
		mPauseFrame = 30;
		
		// keep active target
		// do not deactivate holes
		
		// cache where we started jumping from
		mStartMotionPosition = mParent->GetPosition();
		
		// kick off jump down anim
		static_cast<AnimatedGraphicsComponent*>(
					mParent->GetGraphicsComponent())->StartAnimation(AnimatedGraphicsComponent::JUMP_DOWN_HOLE);
		
	}
	
	void GopherController::OnCollision(Entity *collidesWith)
	{
		if(!CanExplode())
		{
			return;
		}
		
		btVector3 direction = mParent->GetPosition() - collidesWith->GetPosition();
		direction.setY(0);
		direction.normalize();
		
		// explode w/ object
		ExplodableComponent *explodable = collidesWith->GetExplodable();
		
		if(explodable)
		{
			switch (explodable->GetExplosionType()) {

				case ExplodableComponent::ELECTRO:
					if(CanReact())
					{
						Electro();
					}
					break;
				case ExplodableComponent::FREEZE:
					if(CanReact())
					{
						//Freeze();
					}
					break;
				case ExplodableComponent::FIRE:
					if(CanReact())
					{
						Fire();
					}
					break;
				case ExplodableComponent::MUSHROOM:
				case ExplodableComponent::EXPLODE_SMALL:
				default:
					Explode(direction);
					break;
			}
		}
		else 
		{
			// hits another gopher
			Component *controller = collidesWith->GetController(); 
			if(controller)
			{
				GopherController *gc = dynamic_cast<GopherController*> (controller);
				ControllerState state = gc->GetControllerState();
				
				if(state == EXPLODE || CanReact())
				{
					
					switch (state) {
						case FIRE:
							if(CanReact())
							{
								Fire();
							}
							break;
						case FREEZE:
							if(CanReact())
							{
								//Freeze();
							}
							break;
						case ELECTRO:
							Electro();
							break;
						case EXPLODE:
						default:
							Explode(direction);
							break;
					}
				}
				
			}
			else
			{
			
				Explode(direction);
			}
		}
		
		
	}
	
	// triggers initial explosion
	void GopherController::Explode(btVector3 &direction)
	{
		mControllerState = EXPLODE;
		mPath.clear();
		
		btVector3 zero(0,0,0);
		
		mExplodeTime = 0;
		
		mTetheredHole = NULL;
		
		// go pinball
		// move object up
		
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();

		
		btRigidBody *body = physicsComponent->GetRigidBody();
		
		btVector3 pos = mParent->GetPosition();
		pos.setY(1.0);
		mParent->SetPosition(pos);

		
		btTransform trans;
		trans.setIdentity();
		trans.setOrigin(pos);
		
		//rotate off parent
		//trans.setBasis(mParent->GetRotation());
		
		body->getMotionState()->setWorldTransform(trans);
		body->setWorldTransform(trans);
		
		physicsComponent->SetKinematic(false);
		
		// apply a force
		//velocity.setY(1.0f);
		direction *= 100.0f;
		body->applyForce(direction, zero);
		
		AnimatedGraphicsComponent *graphicsComponent = static_cast<AnimatedGraphicsComponent *> ( mParent->GetGraphicsComponent() );					
		
		// queue blow up anims
		if(fabs(direction.getX()) < fabs(direction.getZ()))
		{					
			AnimationMirroring mirror =  (direction.getZ() > 0)? MIRROR_HORIZONTAL : MIRROR_NONE;
			graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::BLOWUP_LEFT, mirror);				
		}
		else 
		{
			AnimationMirroring mirror =  (direction.getX() > 0)? MIRROR_VERTICAL : MIRROR_NONE;
			graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::BLOWUP_FORWARD , mirror);
		}
	}
	
	void GopherController::WinDance()
	{
		if(mActiveTarget)
		{
			mActiveTarget->mActive = false;
		}
		
		mActiveTarget = NULL;
		mPauseFrame = 0;
		
		// keeps things eating
		if(mControllerState == EAT)
		{
			AnimatedGraphicsComponent *graphicsComponent = static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent());
			
			if(graphicsComponent->LastFrame())
			{
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::WIN_DANCE);
				mControllerState = WIN_DANCE;
			}
			else 
			{
				mControllerState = EAT_FINAL;
			}				
		}
		else 
		{
			DLog(@"Win Dance");	
			mControllerState = WIN_DANCE;
			PlayWinAnimation();
		}
	}

	
	void GopherController::RunAway(Entity* target, const TheMadGamer::NodeNetwork *nodeNetwork) 
	{
		DLog(@"Run Away");
		mControllerState = RUN_AWAY;
		mActiveTarget = target;
		
		// taunt on way back
		SetRandomTauntDelay();
		
		// from our position 
		TheMadGamer::Vec2 currentPosition(mParent->GetPosition().getX(), mParent->GetPosition().getZ());
		
		// to the target node's position, not the target
		TargetComponent *targetComponent = static_cast<TargetComponent*> (target->FindComponentOfType(TARGET));
		if(!targetComponent)
		{
			DLog(@"Run Away FAIL - no target component");
			return;
		}
		
		// get target ID
		int targetNodeID = targetComponent->mNetworkNodeID;
		
		nodeNetwork->GetShortestPath(mPath, currentPosition, targetNodeID);
		
		DLog(@"Run Away - path len %d", mPath.size());
	}
	
	void GopherController::Update(float dt)
	{
		if(mControllerState == EXPLODE )
		{
			UpdateExplode(dt);
		}
		else if(mControllerState == FREEZE)
		{
			if(mPauseFrame == 0)
			{
				mPauseFrame = 10;
				Idle();
			}
		}
		else if(mControllerState == ELECTRO || mControllerState == FIRE)
		{
			if(mPauseFrame == 0)
			{
				mControllerState = DEAD;
				// let game play mgr clean up
			}
		}
		else if (mControllerState == ATTACK || mControllerState == RUN_AWAY )
		{
			UpdateAttackAndRun(dt);
		}
		else if(mControllerState == IDLE) 
		{
			UpdateIdle(dt);
		}
		else if(mControllerState == JUMP_DOWN)
		{
			UpdateJumpDown(dt);
		}
		else if(mControllerState == EAT)
		{
			UpdateEat(dt);
		}
		else if(mControllerState == EAT_FINAL)
		{
			mControllerState = WIN_DANCE;
		}
		else if(mControllerState == SPAWN)
		{
			UpdateSpawn( dt);
			
		}
		else if(mControllerState == TAUNT)
		{
		
			UpdateTaunt( dt);
		}
		
		if(mControllerState == WIN_DANCE)
		{
			// pick random moon or win dance
			PlayWinAnimation();
		}

		
		if(mPauseFrame > 0 )
		{
		   if(mIntraFrameTime >= (1.0/30.0))
		   {
			   mPauseFrame--;
			   mIntraFrameTime = 0;
		   }
		   else 
		   {
			   mIntraFrameTime += dt;   
		   }
		}
	}
	
	void GopherController::UpdateTaunt(float dt)
	{
		// if done taunting
		if(mPauseFrame ==0)
		{
			if(mPreviousState == ATTACK && mActiveTarget != NULL)
			{
				// go back to attack
				mControllerState = ATTACK;
			}
			else if(GamePlayManager::Instance()->GetGamePlayMode() ==
					GamePlayManager::RICOCHET)
			{
				Idle();
			}
			else // resume run away
			{
				
				if( mTetheredHole != NULL)
				{
					RunAway( mTetheredHole, GamePlayManager::Instance()->GetNodeNetwork());
				}
				else 
				{	
					// node should be inactive, and not selectable
					// TODO- change to PickTarget();  keep as closestHole for testing
					Entity *target = GamePlayManager::Instance()->GetClosestHole(mParent->GetPosition());
					RunAway( target, GamePlayManager::Instance()->GetNodeNetwork());
				}
			}
		}
	}
	
	void GopherController::UpdateExplode(float dt)
	{
		// let physics control
		//btVector3 position = mParent->GetPosition();
		//DLog(@"Goph Expl %f %f %f", position.x(), position.y(), position.z());
		
		// character gets deactivated, respawnned, no transition out
		mExplodeTime += dt;
	
		PhysicsComponent *physics = mParent->GetPhysicsComponent();
		
		btVector3 linearVel = physics->GetRigidBody()->getLinearVelocity();

		const float kMinVel = 25.0f;
		const float kMaxVel = 40.0f;
		float vel = linearVel.length();
	
		if(vel > 0)
		{
			if(vel > kMaxVel)
			{
				linearVel.normalize();
				linearVel *= kMaxVel;
			}
			else if (vel < kMinVel)
			{
				linearVel.normalize();
				linearVel *= kMinVel;
			}
		}
	}
	
	void GopherController::UpdateSpawn(float dt)
	{
		// TODO - update the controller's spawn in 
		btVector3 position = mParent->GetPosition();
		
		// moves the gopher off the hole (up/down)
		float dX = position.getX() > 0 ? -0.006f : 0.006f; 
		position.setX(position.getX() + dX);					
		
		mParent->SetPosition(position);	
		
		// at end of animation, transition to Idle
		if(static_cast<AnimatedGraphicsComponent *>(mParent->GetGraphicsComponent())->LastFrame())
		{
			Idle();	
		}
	}
	
	void GopherController::UpdateEat(float dt)
	{
		// if not paused, and can get an active target, transition to attack
		if(mPath.size() == 0 && GamePlayManager::Instance()->GetNumActiveTargets() > 0 && mPauseFrame == 0 )
		{
			
			// keep target for removal
			TargetComponent* targetComponent = static_cast<TargetComponent*>(mActiveTarget->FindComponentOfType(TARGET));
			mActiveTarget = NULL;
			
			if( mTetheredHole != NULL)
			{
				RunAway( mTetheredHole, GamePlayManager::Instance()->GetNodeNetwork());
			}
			else 
			{					
				// node should be inactive, and not selectable
				// TODO- change to PickTarget();  keep as closestHole for testing
				Entity *target = GamePlayManager::Instance()->GetClosestHole(mParent->GetPosition());
				
				TargetComponent *newTarget =  static_cast<TargetComponent*>(target->FindComponentOfType(TARGET));
				if(newTarget != NULL && newTarget->mTargetType == TargetComponent::CARROT )
				{
					// node is targetd
					Attack(target, GamePlayManager::Instance()->GetNodeNetwork());
				}
				else if(newTarget != NULL)
				{
					RunAway( target, GamePlayManager::Instance()->GetNodeNetwork());
				}
			}
			
			// old node finally removed from network
			GamePlayManager::Instance()->RemoveTargetNode(targetComponent->mNetworkNodeID);
			
		}
		else if(GamePlayManager::Instance()->GetNumActiveTargets() == 0 && mPauseFrame == 0)
		{
			WinDance();
		}
	}
	
	void GopherController::UpdateJumpDown(float dt)
	{
		btVector3 position = mParent->GetPosition();
		
		float x = position.getX();
		
		if(x > 0)
		{
			position.setX(x+0.016f);
		}
		else {
			position.setX(x-0.020f);
		}

		
		mParent->SetPosition(position);
		
		if(mPauseFrame == 0)
		{
			// was a deactivate - let game mgr reclaim
			mControllerState = DEAD;
			mSpawnTime = kRespawnWait;
		}
		
		// TODO - move gopher towards hole
	}
	
	void GopherController::UpdateIdle(float dt)
	{
		// if not paused, and can get an active target, transition to attack
		if(mPath.size() == 0 && GamePlayManager::Instance()->GetNumActiveTargets() > 0 && mPauseFrame == 0 )
		{
			// pick a carrot from idle
			Entity *target = GamePlayManager::Instance()->GetRandomCarrot(mParent->GetPosition());
			if(target != NULL)
			{
				// then attack
				Attack(target, GamePlayManager::Instance()->GetNodeNetwork());
			}
			else {
				Taunt();
			}
		}
	}
	
	void GopherController::UpdateAttackAndRun(float dt)
	{
		// no target, nothing in path (at goal)
		if(mPath.size()== 0 && mActiveTarget != NULL )
		{
			if(mControllerState == RUN_AWAY)
			{
				SpawnComponent *spawn = static_cast<SpawnComponent*>(mActiveTarget->GetSpawnComponent());
				if(spawn)
				{
					spawn->SetOccupied();
					DLog(@"Setting spawn occupied");
				}
				
				JumpDown();
			}
			else {
				Eat();
			}
		} 
		// target becomes inactive
		else if(mActiveTarget && (!mActiveTarget->mActive))
		{
			mPath.clear();
			mActiveTarget = NULL;
			
			mPauseFrame = 15;
			Idle();
			
		}
		else if(mPath.size() > 0)
		{			
			if(mTauntTime <= 0)
			{
				Taunt();
			}
			else 
			{
				mTauntTime -= dt;
				
				// keep walking
				IntegrateMotion(dt);
			}
		}
	}
	
	void GopherController::IntegrateMotion(float dt)
	{
		btVector3 position = mParent->GetPosition();			
#if DEBUG
		GraphicsManager::Instance()->DrawDebugCircle(mParent->GetPosition(), 
													 mParent->GetGraphicsComponent()->GetScale()*0.25f);
#endif
		btVector3 direction;
		
		mParent->GetPhysicsComponent()->SynchGhostCollider();
		
		TheMadGamer::Vec2 pos;
		mPath[mPath.size()-1]->GetPosition(pos);
		direction.setValue(pos.x- position.x(), 0, pos.y - position.z());
		
		btVector3 dbgPos(pos.x, position.y(), pos.y);
#if DEBUG
		GraphicsManager::Instance()->DrawDebugLine(position, dbgPos);
#endif
		for(int i = 0; i < mPath.size()-1; i++)
		{
			TheMadGamer::Vec2 dbgPA;
			mPath[i]->GetPosition(dbgPA);
			btVector3 dbgPosA(dbgPA.x, position.y(), dbgPA.y);

			TheMadGamer::Vec2 dbgPB;
			mPath[i+1]->GetPosition(dbgPB);
			btVector3 dbgPosB(dbgPB.x, position.y(), dbgPB.y);
#if DEBUG
			GraphicsManager::Instance()->DrawDebugLine(dbgPosA, dbgPosB );	
#endif
		}
		
		
		float len = direction.length();
		if(len > dt*kWalkSpeed)
		{
			direction.normalize();
			
			btVector3 alternativePosition;
			if( mAvoidCollisions && AvoidObstacles( direction, alternativePosition) )
			{
				
				// path has changed
				TheMadGamer::PositionedNode *newNode = new TheMadGamer::PositionedNode(0);
				
				TheMadGamer::Vec2 newPos(alternativePosition.x(), alternativePosition.z());
				newNode->SetPosition(newPos);
				mPath.push_back(newNode);

				DLog(@"Avoid! Add Path Element %d", mPath.size());
				IntegrateMotion(dt);
				return;

			}
			
			
			AnimatedGraphicsComponent *graphicsComponent = 
			static_cast<AnimatedGraphicsComponent *> ( mParent->GetGraphicsComponent() );					
			
			// this updates graphics animation
			graphicsComponent->UpdateAnimatedWalkDirection(direction);
			
			direction *= dt* kWalkSpeed;
			position += direction;
			
			// step gopher
			mParent->SetPosition(position);
			
		}
		else 					
		{
			// small bit of idle anim while character moves into position
			//TODO pop beginning of path, move into position
			btVector3 position(pos.x, mParent->GetPosition().getY(), pos.y);
			mParent->SetPosition(position);
			
			mPath.pop_back();
			if(mPath.size() == 0 )
			{
				btVector3 zero(0,0,0);
				AnimatedGraphicsComponent *graphicsComponent = 
				static_cast<AnimatedGraphicsComponent *> ( mParent->GetGraphicsComponent() );
				
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::IDLE);	
			}
		}
	}
	
	bool GopherController::AvoidObstacles(btVector3 &direction, btVector3 &alternaivePosition)
	{
		
		//GraphicsManager::Instance()->DrawDebugSquare(mParent->GetPosition(), mParent->GetGraphicsComponent()->GetScale()*0.5f);
		
		const float kGopherOffset = mParent->GetGraphicsComponent()->GetScale().x() * 0.3;
		const float kScale = kGopherOffset*2.0f;
		const float kStep = mParent->GetGraphicsComponent()->GetScale().x() * 0.25;
		
		btVector3 halfTan = direction;
		
		// rotate 90
		float x = halfTan.x();
		halfTan.setX(halfTan.z());
		halfTan.setZ(-x);
		halfTan *= kGopherOffset;
		
		const btVector3 pos(mParent->GetPosition());
		
		// form a ray vector
		btVector3 rayStart0(pos);
		rayStart0 += halfTan;
				
		btVector3 rayEnd0(rayStart0);
		rayEnd0 += (direction*kScale); 
#if DEBUG
		GraphicsManager::Instance()->DrawDebugLine(rayStart0, rayEnd0);
#endif
		
		// form a ray vector
		btVector3 rayStart1(pos);
		btVector3 rayEnd1(rayStart1);
		rayEnd1 += (direction*kScale); 
#if DEBUG
		GraphicsManager::Instance()->DrawDebugLine(rayStart1, rayEnd1);
#endif
		
		// form a ray vector
		btVector3 rayStart2(pos);
		rayStart2 -= halfTan;
		
		btVector3 rayEnd2(rayStart2);
		rayEnd2 += (direction*kScale); 
#if DEBUG
		GraphicsManager::Instance()->DrawDebugLine(rayStart2, rayEnd2);
#endif
		
		btVector3 newDirection = direction;

		//DLog(@"Pos  %f %f %f", pos.x(), pos.y(), pos.z());		
		//DLog(@"direction  %f %f %f", direction.x(), direction.y(), direction.z());
		
		float incr = 1.0f; //(rand() %2 == 1) ? 1.0f : -1.0f;
		
		for(int i = 0; i < 16; i++)
		{
			//	DLog(@"Ray 0 %f %f %f", rayStart0.x(), rayStart0.y(), rayStart0.z());
			//	DLog(@"   %f %f %f", rayEnd0.x(), rayEnd0.y(), rayEnd0.z());

			//	DLog(@"Ray 1 %f %f %f", rayStart1.x(), rayStart1.y(), rayStart1.z());
			//	DLog(@"   %f %f %f", rayEnd1.x(), rayEnd1.y(), rayEnd1.z());
			
			
				
				if((!PhysicsManager::Instance()->RayIntersects(rayStart0, rayEnd0, mParent))
				   && (!PhysicsManager::Instance()->RayIntersects(rayStart1, rayEnd1, mParent))
				   && (!PhysicsManager::Instance()->RayIntersects(rayStart2, rayEnd2, mParent)))
				{
					if(i == 0)
					{
						return false;
					}
					else 
					{
						btVector3 rayEnd(mParent->GetPosition());
						rayEnd += (newDirection*kStep);
						
						alternaivePosition = rayEnd;
						
						DLog(@"alternaivePosition %d (%f %f %f)", i, alternaivePosition.x(), alternaivePosition.y(), alternaivePosition.z());
						return true;
					}
					
				}

				// allows rotation in either direction
				newDirection = newDirection.rotate(btVector3(0,1,0), incr * M_PI/4.0f);
				
				//	DLog(@"direction  %f %f %f", newDirection.x(), newDirection.y(), newDirection.z());
				
				// compute new offset
				halfTan = newDirection;			
				float x = halfTan.x();
				halfTan.setX(halfTan.z());
				halfTan.setZ(-x);
				halfTan *= kGopherOffset;
				
				// offset 0
				rayStart0 = pos;
				rayStart0 += halfTan;
				
				rayEnd0 = rayStart0;
				rayEnd0 += (newDirection*kScale);
				
				// center ray
				rayStart1 = pos;
				rayEnd1 = rayStart1;
				rayEnd1 += (newDirection*kScale);
				
				// offset 2
				rayStart2 = pos;
				rayStart2 -= halfTan;
				
				rayEnd2 = rayStart2;
				rayEnd2 += (newDirection*kScale);
			
		}
	
		// couldn't figure it out - FAIL
		DLog(@"RAY CAST FAIL");
		return false;


	}
	
	void GopherController::PlayWinAnimation()
	{
		AnimatedGraphicsComponent *graphicsComponent = static_cast<AnimatedGraphicsComponent*>(mParent->GetGraphicsComponent());		
		
		if(graphicsComponent->LastFrame())
		{
			int randomNumber = rand();
			//DLog(@"Rand %d", randomNumber);
			
			if( (randomNumber % 3) == 1)
			{
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::TAUNT);
				//DLog(@"Play taunt");
			}
			else 
			{
				graphicsComponent->PlayAnimation(AnimatedGraphicsComponent::WIN_DANCE);
				//DLog(@"Play win");
			}
		}
	}
			
			
	
}