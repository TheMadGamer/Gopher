/*
 *  ExplodabelComponent.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/13/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "Entity.h"
#import "ExplodableComponent.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"
#import "PhysicsManager.h"
#import "PhysicsComponent.h"
#import "SceneManager.h"
#import "AudioDispatch.h"

#import <vector>

using namespace std;

namespace Dog3D
{

	void ExplodableComponent::Update(float dt)
	{
		if(mExplodeState == PRIMED)
		{
			if(mTimeBomb)
			{
				if(mFuseTime >= kMaxFuseTime)
				{
					OnCollision(NULL);
					mFuseTime = 0;
				}
			
				mFuseTime += dt;
			}
		}
		
		// if detonated
		else if(mExplodeState == EXPLODE)
		{
			//btVector3 pos = mParent->GetPosition();
			//DLog(@"Explode posn %f %f %f", pos.x(), pos.y(), pos.z());
			
			mRespawnTime -= dt;
			
			if(mRespawnTime <=0)
			{
				mExplodeState = RECLAIM;
			}
			
		}
		else if(mExplodeState == PRIME_DELAY)
		{
			if(mPrimeDelay <= 0)
			{ 
				Prime();
			}
			else
			{
				mPrimeDelay -= dt;
			}
		}
		else if(mExplodeState == TIMED_EXPLODE)
		{
			
			mFuseTime -= dt;
			
			if(mFuseTime <=0)
			{
				mExplodeState = RECLAIM;
				if(mParent->GetPhysicsComponent())
				{
					PhysicsManager::Instance()->RemoveComponent(mParent->GetPhysicsComponent());
				}
			}
		}
		
	}

	// generic ball
	void ExplodableComponent::OnCollision( Entity *collidesWith )
	{ 
		Explode();
		
		// get fx component				
		vector<Component *> fxComponents;
		mParent->FindComponentsOfType(FX, fxComponents);
		
		// disable
		for(int i = 0; i < fxComponents.size(); i++)
		{
			FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
			fxComponent->mActive = false;
			
		}
		
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		// remove the physics component
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
		if(physicsComponent)
		{
			// remove ball from world
			physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
			physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
			PhysicsManager::Instance()->RemoveComponent(physicsComponent);
		}
		
		mParent->GetGraphicsComponent()->mActive = false;
		
	}
	
	// roller and ricochet ball
	void AntiGopherExplodable::OnCollision( Entity *collidesWith )
	{ 
		// not a goph, explode
		
		GopherController *controller = collidesWith != NULL ?  dynamic_cast<GopherController*>(collidesWith->GetController()) : NULL;
		if(controller == NULL)
		{
			Explode();
			
			// get fx component				
			vector<Component *> fxComponents;
			mParent->FindComponentsOfType(FX, fxComponents);
			
			// disable
			for(int i = 0; i < fxComponents.size(); i++)
			{
				FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
				fxComponent->mActive = false;
				
			}
			
			AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
			
			btVector3 position = mParent->GetPosition();
			
			if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
			{
				GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
			}
			
			// remove the physics component
			PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
			if(physicsComponent)
			{
				// remove ball from world
				physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
				physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
				PhysicsManager::Instance()->RemoveComponent(physicsComponent);
			}
			
			mParent->GetGraphicsComponent()->mActive = false;
			
			
		}
		else 
		{
			
			btVector3 position = mParent->GetPosition();
			
			if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
			{
				GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
			}
			
			AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		}
		
	}
	
	// cue ball 
	void InfiniteExplodable::OnCollision( Entity *collidesWith )
	{ 
		
		if(collidesWith->GetController() == NULL)
		{
			return;
		}
		
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		// remove the physics component
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
		if(physicsComponent)
		{
			// remove ball from world
			
			physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
		
			btVector3 direction = position;
			direction -= collidesWith->GetPosition();
			
			if(direction.length() > 0.00001)
			{
				direction.normalize();
			}
			else {
				direction.setX(1);
				direction.setY(0);
				direction.setZ(1);
			}
			physicsComponent->GetRigidBody()->setLinearVelocity(direction*20.0f);
			
		}
		
	}
	
	void FireballExplodable::OnCollision( Entity *collidesWith )
	{ 
		if(mExplodeState == TIMED_EXPLODE)
		{
			DLog(@"Already exploding");
		}
		
		mExplodeState = TIMED_EXPLODE;
		
		// get fx component				
		vector<Component *> fxComponents;
		mParent->FindComponentsOfType(FX, fxComponents);
		
		// disable
		for(int i = 0; i < fxComponents.size(); i++)
		{
			FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
			fxComponent->mActive = false;
			
		}
		
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		// remove the physics component
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
		
		// remove ball from world
		physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
		physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
		physicsComponent->SetKinematic(true);
		
		// add in ghost collider
		physicsComponent->SetGhostColliderShape(PhysicsManager::Instance()->GetSmallBlastGhost());
		
		PhysicsManager::Instance()->AddGhostCollider(physicsComponent->GetGhostCollider(), GRP_EXPLODABLE | GRP_BALL );
		
		GamePlayManager::Instance()->AddExplodable(this);
		
		// time out mechanism
		mFuseTime = 0.5f;
		
		//PhysicsManager::Instance()->RemoveComponent(physicsComponent);
		
		mParent->GetGraphicsComponent()->mActive = false;
		
	}
	
	void CompoundExplodable::OnCollision( Entity *collidesWith )
	{ 
		mExplodeState = EXPLODE;
		
		// by design, Compound objects have no playing effect component - they can, just not adding for now
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		vector<Entity *> newBodies;
		// let scene mgr handle, so stuff gets properly unloaded
		SceneManager::Instance()->ConvertToSingleBodies(mParent, newBodies);
		
		for(EntityIterator it = newBodies.begin(); it!= newBodies.end(); it++)
		{
			btVector3 direction = (*it)->GetPosition();
			direction -= collidesWith->GetPosition();
			
			if(direction.length() > 0.00001)
			{
				direction.normalize();
			}
			else {
				direction.setX(1);
				direction.setY(0);
				direction.setZ(1);
			}
			
			direction *= 20;
			
			PhysicsComponent *physicsComponent = (*it)->GetPhysicsComponent();
			btVector3 offset(0.1,0.1,0);
			physicsComponent->GetRigidBody()->applyForce(direction, offset);
		}
	}
	
	void KinematicReleaseExplodable::OnCollision( Entity *collidesWith )
	{ 
		Explode();
		
		// get fx component				
		vector<Component *> fxComponents;
		mParent->FindComponentsOfType(FX, fxComponents);
		
		// disable running effect (if any)
		for(int i = 0; i < fxComponents.size(); i++)
		{
			FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
			fxComponent->mActive = false;
			
		}
		
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		// set physics component to be non-kinematic
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
		if(physicsComponent)
		{
			btVector3 direction = mParent->GetPosition();
			direction -= collidesWith->GetPosition();
			
			if(direction.length() > 0.00001)
			{
				direction.normalize();
			}
			else {
				direction.setX(1);
				direction.setY(0);
				direction.setZ(1);
			}

			direction *= 20;
			btVector3 offset(0.1,0.1,0);
			physicsComponent->GetRigidBody()->applyForce(direction, offset);
			
			physicsComponent->SetKinematic(false);
			
			// possibly apply some force?
		}
	}
	
	void RespawnExplodable::OnCollision( Entity *collidesWith )
	{ 
		//hacky, don't detonate if not visible
		if(!mParent->GetGraphicsComponent()->mActive)
		{
			return;
		}
		
		
		Explode();
		
		// get fx component				
		vector<Component *> fxComponents;
		mParent->FindComponentsOfType(FX, fxComponents);
		
		// disable
		for(int i = 0; i < fxComponents.size(); i++)
		{
			FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
			fxComponent->mActive = false;
		}
		
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		// remove the physics component
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
		if(physicsComponent)
		{
			// remove ball from world
			physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
			physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
			PhysicsManager::Instance()->RemoveComponent(physicsComponent);
			
			btVector3 extents =  mParent->GetGraphicsComponent()->GetScale();
			extents *= 0.5f;
			
			SceneManager::RespawnInfo *respawnInfo = new SceneManager::RespawnInfo(mRespawnType, 
												   position, 
												   extents, 
												   0, 
												   GamePlayManager::Instance()->GetLevelTime() + mRegenerateTime,
												   mRegenerateTime);
			
			SceneManager::Instance()->AddDelayedSpawn(respawnInfo);
			
		}
		
		mParent->GetGraphicsComponent()->mActive = false;
		
	}
	
	void BumperExplodable::OnCollision( Entity *collidesWith )
	{ 
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		PhysicsComponent *otherPhysics = collidesWith->GetPhysicsComponent();
		
		if(otherPhysics != NULL)
		{
			btVector3 direction = collidesWith->GetPosition();
			direction -= mParent->GetPosition();
			direction.normalize();
			direction *= 40.0f;
			
			btVector3 offset(0.1,0.1,0);
			otherPhysics->GetRigidBody()->applyForce(direction, offset);
		}
		
	}
	
	void PopExplodable::OnCollision( Entity *collidesWith )
	{ 
		Explode();
		
		btVector3 position = mParent->GetPosition();
		
		if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
		{
			GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
		}
		
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
		
		PhysicsComponent *otherPhysics = collidesWith->GetPhysicsComponent();
		
		if(otherPhysics != NULL)
		{
			btVector3 direction = collidesWith->GetPosition();
			direction -= mParent->GetPosition();
			direction.normalize();
			direction *= 40.0f;
			
			btVector3 offset(0.1,0.1,0);
			otherPhysics->GetRigidBody()->applyForce(direction, offset);
		}
		
		
		// remove the physics component
		PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
		if(physicsComponent)
		{
			// remove ball from world
			physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
			physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
			PhysicsManager::Instance()->RemoveComponent(physicsComponent);
			
			btVector3 extents =  mParent->GetGraphicsComponent()->GetScale();
			extents *= 0.5f;
			
			
			/*SceneManager::RespawnInfo *respawnInfo = new SceneManager::RespawnInfo(mRespawnType, 
																				   position, 
																				   extents, 
																				   0, 
																				   GamePlayManager::Instance()->GetLevelTime() + mRegenerateTime,
																				   mRegenerateTime);
			
			SceneManager::Instance()->AddDelayedSpawn(respawnInfo);*/
			 
			
			
		}
		
		mParent->GetGraphicsComponent()->mActive = false;
	}
	
	
}