/*
 *  PhysicsManager.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */
#import <btBulletDynamicsCommon.h>
#import <vector>
#import <algorithm>

#import "PhysicsComponent.h"
#import "PhysicsManager.h"
#import "Entity.h"
#import "GraphicsManager.h"

using namespace std;
	

namespace Dog3D
{
	typedef list<PhysicsComponent*>::iterator  PhysicsComponentIterator; 
	
	
	struct PhysRayCallback : public btCollisionWorld::RayResultCallback
	{
		int *mHitCount;
		Entity *mDoNotCollideWith;
		
		PhysRayCallback(int *nHits, Entity *doNotCollideWith)
		{
			mHitCount = nHits;
			m_collisionFilterGroup = 0;
			m_collisionFilterMask = GRP_EXPLODABLE|GRP_FIXED|GRP_BALL;
			mDoNotCollideWith = doNotCollideWith;
		}
		
		virtual bool needsCollision(btBroadphaseProxy* proxy0) const
		{
			bool collides = (proxy0->m_collisionFilterGroup & m_collisionFilterMask) != 0;
			
			PhysicsComponent* phys = (PhysicsComponent *) ((btCollisionObject *) proxy0->m_clientObject)->getUserPointer();
			collides = collides && (phys->GetParent() != mDoNotCollideWith);
			
			
			return collides;
		}
		
		virtual	btScalar addSingleResult(btCollisionWorld::LocalRayResult& rayResult,bool normalInWorldSpace)
		{
			(*mHitCount)++;
			DLog(@"Ray Hit");
			
			btCollisionObject *collider = rayResult.m_collisionObject;
			PhysicsComponent* phyComp =  (PhysicsComponent*) collider->getUserPointer();
			btVector3 pos = phyComp->GetParent()->GetPosition();
#if DEBUG
			DLog(@"Ray Hit %s", phyComp->GetParent()->mDebugName.c_str());
			
			GraphicsManager::Instance()->DrawDebugSquare(pos, btVector3(1,1,1));
#endif	
			return rayResult.m_hitFraction;
			
		}
		
	};
	
	PhysicsManager * PhysicsManager::sPhysicsManager;
	
	void PhysicsManager::Initialize()
	{
		
/// DEBUG TODO		
		sPhysicsManager = new PhysicsManager();
	}
	
	void PhysicsManager::SetGravity(btVector3 &gravity)
	{
		mDynamicsWorld->setGravity(gravity);
	}
												
	
	void PhysicsManager::CreateWorld()
	{
		
		btVector3 worldAabbMin(-100,-4,-100);
		btVector3 worldAabbMax(100,4,100);
		int maxProxies = 256;
		mBroadphase = new btAxisSweep3(worldAabbMin,worldAabbMax,maxProxies);
		
		mCollisionConfiguration = new btDefaultCollisionConfiguration();
		mDispatcher = new btCollisionDispatcher(mCollisionConfiguration);
		
		mSolver = new btSequentialImpulseConstraintSolver;
		
		
		mDynamicsWorld = new btDiscreteDynamicsWorld(mDispatcher,mBroadphase,mSolver,mCollisionConfiguration);
		
		mDynamicsWorld->setGravity(btVector3(0,-10,0));
		
		//TODO - goes in init?
		mDynamicsWorld->getBroadphase()->getOverlappingPairCache()->setInternalGhostPairCallback(new btGhostPairCallback());

		
	}
	
	void PhysicsManager::AddComponent( PhysicsComponent *component  )
	{
		
		if(find( mManagedComponents.begin(), mManagedComponents.end(), component) == mManagedComponents.end())
		{
			btRigidBody *body = component->GetRigidBody();
			body->activate(true);
			
			((btDiscreteDynamicsWorld*) mDynamicsWorld)->addRigidBody( body, (short) component->GetCollisionGroup(), (short) component->GetCollidesWith() );	
			
			mManagedComponents.push_back(component);

		}
	}
	
	void PhysicsManager::RemoveComponent( PhysicsComponent *component)
	{
		PhysicsComponentIterator it = std::find(mManagedComponents.begin(), mManagedComponents.end(), component);
		if(it != mManagedComponents.end())
		{
#if DEBUG 
			DLog(@"Removing physics comp %s", ((*it)->GetParent()->mDebugName.c_str()));
#endif
			
			mManagedComponents.erase(it);
			mDynamicsWorld->removeRigidBody(component->GetRigidBody());
			
			btCollisionObject *collider = component->GetGhostCollider();
			if(collider)
			{
#if DEBUG 
				/*if((*it)->GetParent() != NULL)
				{
					DLog(@"Removing ghost collider %s", ((*it)->GetParent()->mDebugName.c_str()));
				}*/
#endif
				mDynamicsWorld->removeCollisionObject(collider);
			}
			
		}
		else 
		{
			DLog(@"Find to remove fail");
		}

	}	
	
	
	void PhysicsManager::Update(float deltaTime)
	{
		if(mDynamicsWorld == NULL)
		{
			return;
		}
		   
		
		// updates kinematic object position
		for(PhysicsComponentIterator it = mManagedComponents.begin(); it != mManagedComponents.end(); it++)
		{
			if((*it)->IsKinematic())
			{
				(*it)->Update(deltaTime);
			}
		}
		
		
		mDynamicsWorld->stepSimulation(deltaTime,10);
		
		// updates parent position
		for(PhysicsComponentIterator it = mManagedComponents.begin(); it != mManagedComponents.end(); it++)
		{
			if(!((*it)->IsKinematic()))
			{
				(*it)->Update(deltaTime);
			}
		}
		
		//for(PhysicsComponentIterator it = mManagedComponents.begin(); it != mManagedComponents.end(); it++)
		//{
		//	DLog(@"Debug ID %i %s", (*it)->GetRigidBody()->m_debugBodyId, (*it)->GetParent()->mDebugName.c_str());
		//}
		
	}
	

	// avoids gophers
    bool PhysicsManager::RayIntersects(btVector3 &rayStart, btVector3 &rayEnd, Entity *ignoreThis)
	{
		int hitCount = 0;
		PhysRayCallback rayCallback(&hitCount, ignoreThis);
		
		//ClosestRayResultCallback rayCallback;
		
		mDynamicsWorld->rayTest(rayStart, rayEnd, rayCallback);
		
		
		
		return (hitCount > 0);
		
	
	}
	

	
	// keep pairs in order for set comparison
	static inline void AddPair(std::set< EntityPair  > &triggeredObjects,
						EntityPair newCollision)
	{
	
		if(newCollision.first > newCollision.second)
		{
			triggeredObjects.insert(EntityPair(newCollision.second, newCollision.first));	
		}
		else 
		{
			triggeredObjects.insert(newCollision);
		}
	}
	
	
	//two pinball objects
	void PhysicsManager::GetTriggerContactList(std::set<EntityPair> &triggeredObjects)
	{
		//Assume world->stepSimulation or world->performDiscreteCollisionDetection has been called
		
		int numManifolds = mDynamicsWorld->getDispatcher()->getNumManifolds();
		for (int i=0;i<numManifolds;i++)
		{
			btPersistentManifold* contactManifold =  mDynamicsWorld->getDispatcher()->getManifoldByIndexInternal(i);
			btCollisionObject* obA = static_cast<btCollisionObject*>(contactManifold->getBody0());
			btCollisionObject* obB = static_cast<btCollisionObject*>(contactManifold->getBody1());
			
			short collisionGrpA = obA->getBroadphaseHandle()->m_collisionFilterGroup;
			short collisionGrpB = obB->getBroadphaseHandle()->m_collisionFilterGroup;
			
			if(  (collisionGrpA & (GRP_EXPLODABLE | GRP_BALL)) && (collisionGrpB & (GRP_EXPLODABLE | GRP_BALL) ) )  {
			   
				PhysicsComponent *pA = (PhysicsComponent*) obA->getUserPointer();
				PhysicsComponent *pB = (PhysicsComponent*) obB->getUserPointer();
				
				if(pA && pB && pA != pB)
				{
					Entity *entA = pA->GetParent();
					Entity *entB = pB->GetParent();
					
					AddPair(triggeredObjects, EntityPair(entA, entB));
#if DEBUG
					//	DLog(@"Exp Col %s", entA->mDebugName.c_str() );
#endif
				}
			}	
		}	
		
		
		// update for ghost objects
		for(PhysicsComponentIterator it = mManagedComponents.begin(); it != mManagedComponents.end(); it++)
		{
		
			//Entity *gopher = *it;
			PhysicsComponent *physicsComponent = (*it);
			
			// some object maintain a ghost collider
			btPairCachingGhostObject *ghostCollider = physicsComponent->GetGhostCollider();
			if(ghostCollider)
			{
				
				physicsComponent->SynchGhostCollider();
								
				int nPairs =  ghostCollider->getOverlappingPairCache()->getNumOverlappingPairs(); //pairArray.size();
				
				/*if(nPairs > 0)
				{
					DLog(@"NPairs %d", nPairs);
				}*/
				
				for(int i = 0; i < nPairs; i++)
				{
					// Dynamic cast to make sure its a rigid body
					//pairArray[i]  ); //
					btRigidBody *rigidBody = dynamic_cast<btRigidBody *>( ghostCollider->getOverlappingObject(i));         
					if(rigidBody)
					{
						PhysicsComponent *pA = (PhysicsComponent*) rigidBody->getUserPointer();
						if(pA)
						{
							Entity *entA = pA->GetParent();
							AddPair(triggeredObjects, EntityPair(entA, physicsComponent->GetParent()));
						}
					}
				}
			}
		}
	}
	
	void PhysicsManager::AddGhostCollider(btPairCachingGhostObject *ghostCollider, int collidesWith)
	{
		mDynamicsWorld->addCollisionObject(ghostCollider,
										   GRP_EXPLODABLE, 
										   collidesWith/* 1 removed this |GRP_GHOST|GRP_WALL|GRP_FLOOR_CEIL|GRP_FIXED*/);
		
	}
	
	void PhysicsManager::Unload()
	{
		for(PhysicsComponentIterator it = mManagedComponents.begin(); it!= mManagedComponents.end(); it++)
		{
			mDynamicsWorld->removeRigidBody((*it)->GetRigidBody());
			
			btCollisionObject *ghostCollider = (*it)->GetGhostCollider();
			if(ghostCollider!= NULL)
			{
				mDynamicsWorld->removeCollisionObject(ghostCollider);
				(*it)->RemoveGhostCollider();
			}
		}
	
#if DEBUG
		if(mDynamicsWorld->getNumCollisionObjects())
		{
			DLog(@"WARNING: Num Objects still in world %i", mDynamicsWorld->getNumCollisionObjects());
		}
#endif
		
		mManagedComponents.clear();
	
		delete mDynamicsWorld;
		delete mSolver;
		delete mDispatcher;
		delete mCollisionConfiguration;
		
		delete mBroadphase;
		
	
	
	}
#if 0
	void FakePhysicsManager::Update(float deltaTime)
	{
		DLog(@"Ican has update");
		
	}
	
	FakePhysicsManager::FakePhysicsManager(){}
	FakePhysicsManager::~FakePhysicsManager(){}
	
	void FakePhysicsManager::CreateWorld(){}
	bool FakePhysicsManager::RayIntersects(btVector3 &rayStart, btVector3 &rayEnd, Entity *ignoreThis){return false;}
	
	void FakePhysicsManager::RemoveGhostCollider(btPairCachingGhostObject *ghostCollider){}
	
	//adds a ghost collider to world
	void FakePhysicsManager::AddGhostCollider(btPairCachingGhostObject *ghostCollider, int collidesWith){}
	
	
	// initializes singleton manager
	void FakePhysicsManager::Unload(){}
	
	// adds a physics component (adds to world)
	// warning, does not add back ghost component
	void FakePhysicsManager::AddComponent( PhysicsComponent *component ){}
	
	// removes a physics component
	void FakePhysicsManager::RemoveComponent( PhysicsComponent *component){}
	
	
	// sets grav in physics world
	void FakePhysicsManager::SetGravity(btVector3 &gravity){}
	
	void FakePhysicsManager::GetTriggerContactList(std::set<EntityPair> &triggeredObjects){}
#endif	
}
