/*
 *  PhysicsComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Entity.h"
#import "PhysicsComponent.h"
#import "PhysicsManager.h"

namespace Dog3D
{
	
	void PhysicsComponent::Update(float deltaTime)
	{
		if(mKinematic)
		{
			btTransform trans;
			trans.setIdentity();
			trans.setOrigin(mParent->GetPosition());
			
			//rotate off parent
			trans.setBasis(mParent->GetRotation());
						
			mRigidBody->getMotionState()->setWorldTransform(trans);
			
			mRigidBody->setWorldTransform(trans);
			
		}
		else 
		{
			
			
			btTransform trans;
			trans.setIdentity();
			mRigidBody->getMotionState()->getWorldTransform(trans);
			
			btVector3 position = trans.getOrigin();
			mParent->SetPosition(position);
			
			btMatrix3x3 basis = trans.getBasis();
			mParent->SetRotation(basis);
		}
		
	}
	
	void PhysicsComponent::AddGhostCollider( )
	{
		if(mRigidBody)
		{
			if(!mGhostCollider)
			{
				mGhostCollider = new btPairCachingGhostObject();
			}
			mGhostCollider->setCollisionShape( /* 2 new btSphereShape(4)*/  mRigidBody->getCollisionShape() );
			
			
			btTransform trans; //  = mRigidBody->getWorldTransform();  // 3 trans;
			trans.setIdentity();
			trans.setOrigin(btVector3(mParent->GetPosition().getX(), 1,mParent->GetPosition().getZ() )); //mParent->GetPosition().getX(),1,mParent->GetPosition().getZ()));
			mGhostCollider->setCollisionFlags(mGhostCollider->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);
		
			mGhostCollider->setWorldTransform(trans);
			mGhostCollider->setUserPointer(this);
		}
		else {
			DLog(@"Ghost collider WTF");
		}

	}
	
	void PhysicsComponent::SetGhostColliderShape( btCollisionShape *shape )
	{
		
#if DEBUG
		DLog(@"Change Ghost Collider %s ", mParent->mDebugName.c_str());
#endif
		
		if(!mGhostCollider)
		{
			mGhostCollider = new btPairCachingGhostObject();
		}
		
		mGhostCollider->setCollisionShape( shape );
		btTransform trans; 
		trans.setIdentity();
		trans.setOrigin(btVector3(mParent->GetPosition().getX(), 1, mParent->GetPosition().getZ()));
		mGhostCollider->setCollisionFlags(mGhostCollider->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);
		
		mGhostCollider->setWorldTransform(trans);
		mGhostCollider->setUserPointer(this);
		
	}
	
	void PhysicsComponent::SetKinematic(bool kinematic)
	{ 
		if(mKinematic == kinematic)
		{
			return;
		}

		mKinematic = kinematic;	
		
		bool removeAndAdd = (mRigidBody->isInWorld());
		
		if(removeAndAdd)
		{
			PhysicsManager::Instance()->RemoveComponent(this);
		}
	
		if(kinematic)
		{
			mRigidBody->setCollisionFlags( mRigidBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
			mRigidBody->setActivationState( DISABLE_DEACTIVATION );
		}
		else 
		{
			// flip off kinematic flags
			mRigidBody->setCollisionFlags(  mRigidBody->getCollisionFlags() & ~btCollisionObject::CF_KINEMATIC_OBJECT);
			mRigidBody->setActivationState( WANTS_DEACTIVATION );
		}

		if(removeAndAdd)
		{
			PhysicsManager::Instance()->AddComponent(this);
		}
		
	}
}