/*
 *  PhysicsComponent.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#ifndef PHYSICS_COMPONENT_H
#define PHYSICS_COMPONENT_H

#import "Entity.h"
#import "Component.h"

#import <btBulletDynamicsCommon.h>
#import <btBulletCollisionCommon.h>
#import <BulletCollision/CollisionDispatch/btGhostObject.h>


namespace Dog3D
{
	enum PhysicsObjectShape
	{
		SPHERE, BOX, CYLINDER
	};
	
	
#define BIT(x) (1<<(x)) 
	
	enum GopherCollisionTypes {
		GRP_EXPLODABLE = BIT(1), //< various moving scene objects 
		GRP_FIXED = BIT(2), //< rocks
		GRP_WALL = BIT(3), //<fixed walls
		GRP_FLOOR_CEIL = BIT(4), // < floor or ceil
		GRP_GOPHER = BIT(5), //< gophers
		GRP_BALL = BIT(6) //<the ball
	};
	
	
	// TODO: use this instead of args to factory
	class PhysicsComponentInfo
	{
	public:
		

		PhysicsComponentInfo() 
		: 
		mInitialVelocity(0,0,0),
		mRestitution(1.0f),
		mMass(1.0f),
		mCollisionBound(0.1f), 
		mFriction(0.5f), 
		mCollisionGroup(GRP_EXPLODABLE),
		mCollidesWith(GRP_EXPLODABLE|GRP_WALL|GRP_FLOOR_CEIL|GRP_FIXED|GRP_GOPHER|GRP_BALL),
		mIsStatic(false), mCanRotate(false), mDoesNotSleep(false)
		{}
		
		btVector3 mInitialVelocity;
		float mRestitution;
		float mMass;
		float mCollisionBound;
		float mFriction;
		short int mCollisionGroup;
		short int mCollidesWith;
		bool mIsStatic;
		bool mCanRotate;
		bool mHasGhostCollider;
		bool mDoesNotSleep;
	};
	
	
	// Collidable component
	class PhysicsComponent : public Component
	{

	protected:	
		btRigidBody* mRigidBody;
		btPairCachingGhostObject *mGhostCollider;
		btCollisionShape *mCollisionShape;
		btMotionState *mMotionState;
		
		int mCollisionGroup;
		int mCollidesWith;
		bool mKinematic;
		
	public:
		PhysicsComponent(btRigidBody *rigidBody, btCollisionShape *collisionShape, 
						 btMotionState *motionState,
						 short int collisionGroup, short int collidesWith)
		{
			mTypeId = PHYSICS;
			mRigidBody = rigidBody;
			mCollisionShape = collisionShape;
			mMotionState = motionState;
			mGhostCollider = NULL;
			
			mCollisionGroup = collisionGroup;
			mCollidesWith = collidesWith;
			mKinematic = false;
		}
		
		~PhysicsComponent()
		{  
			delete mRigidBody;
			delete mCollisionShape;
			
			delete mMotionState;
			
			if(mGhostCollider)
			{
				delete mGhostCollider;
			}
			
		}
		
		void AddGhostCollider( );
		inline void RemoveGhostCollider() 
		{
			mGhostCollider = NULL;
		}
		void SetGhostColliderShape( btCollisionShape *shape );
		
		// synchs ghost to rigid body
		inline void SynchGhostCollider()
		{
			if(mGhostCollider && mRigidBody)
			{
				btTransform trans = mGhostCollider->getWorldTransform();
				trans.setOrigin(btVector3(mParent->GetPosition().x(),1,mParent->GetPosition().getZ()));
				
				mGhostCollider->setWorldTransform(trans);
				
			}
			
		}
		
		inline btPairCachingGhostObject* GetGhostCollider()
		{
			return mGhostCollider;
		}
		
		inline int GetCollisionGroup(){ return mCollisionGroup; } 
		inline int GetCollidesWith() { return mCollidesWith;}
		
		void SetKinematic(bool kinematic);
		
		inline bool IsKinematic(){ return mKinematic;}
		
		inline btRigidBody *GetRigidBody(){ return mRigidBody; }
				
		inline btCollisionShape *GetCollisionShape() { return mRigidBody->getCollisionShape();}
		
		virtual void Update(float deltaTime);
		
		
	};
}

#endif