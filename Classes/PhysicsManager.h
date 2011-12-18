/*
 *  PhysicsManager.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>
#import <btCollisionWorld.h>

#import <vector>
#import <list>
#import <map>
#import <set>
#import "PhysicsComponent.h"


namespace Dog3D
{
	
	

	typedef std::pair<Entity *, Entity*> EntityPair;
	
	
	class PhysicsManager
	{		
	public:
		
		
		static const float kMushroomBlastRadius = 7.5f;
		static const float kSmallBlastRadius = 2.0f;

		// initializes singleton manager
		static void Initialize();	
		static void ShutDown() { delete sPhysicsManager; sPhysicsManager = NULL;}
		void Unload();
		
		// adds a physics component (adds to world)
		// warning, does not add back ghost component
		void AddComponent( PhysicsComponent *component );	
		
		// removes a physics component
		void RemoveComponent( PhysicsComponent *component);
				
		// steps physics
		void Update(float deltaTime);
		
		// singleton
		static PhysicsManager *Instance()
		{
			return sPhysicsManager;
		}
		
		// sets grav in physics world
		void SetGravity(btVector3 &gravity);
				
		void GetTriggerContactList(std::set<EntityPair> &triggeredObjects);
		
		
		//adds a ghost collider to world
	    void AddGhostCollider(btPairCachingGhostObject *ghostCollider, int collidesWith=GRP_BALL|GRP_EXPLODABLE);
		
		// removes from world
		inline void RemoveGhostCollider(btPairCachingGhostObject *ghostCollider)
		{
			mDynamicsWorld->removeCollisionObject(ghostCollider);
		}
		
		inline btCollisionShape* GetBlastGhost(){ return mBlastGhostShape;}
		inline btCollisionShape* GetSmallBlastGhost(){ return mSmallBlastGhostShape;}
		
		bool RayIntersects(btVector3 &rayStart, btVector3 &rayEnd, Entity *ignoreThis);

		// creates dynamic world
		void CreateWorld();
		
	protected:
		
		PhysicsManager() 
		{
			mBlastGhostShape = new btSphereShape(kMushroomBlastRadius);
			mSmallBlastGhostShape = new btSphereShape(kSmallBlastRadius);
		}
		
		virtual ~PhysicsManager()
		{
			delete mBlastGhostShape;
			delete mSmallBlastGhostShape;
			
		}

		
		// managed components
		std::list<PhysicsComponent *> mManagedComponents;
		
		// bullet dynamic world
		btDynamicsWorld *mDynamicsWorld;
		
		// singleton
		static PhysicsManager *sPhysicsManager;
		
		btCollisionShape *mBlastGhostShape;
		
		btCollisionShape *mSmallBlastGhostShape;
		
		btAxisSweep3* mBroadphase;
		btDefaultCollisionConfiguration* mCollisionConfiguration;
		btCollisionDispatcher* mDispatcher;
		btSequentialImpulseConstraintSolver* mSolver;
	};
	
#if 0
	class FakePhysicsManager : public PhysicsManager
	{
	public:
		
		FakePhysicsManager();
		virtual ~FakePhysicsManager();
		
		virtual void Update(float deltaTime);
		
		void CreateWorld();
		bool RayIntersects(btVector3 &rayStart, btVector3 &rayEnd, Entity *ignoreThis);
		
		void RemoveGhostCollider(btPairCachingGhostObject *ghostCollider);
	
		//adds a ghost collider to world
		void AddGhostCollider(btPairCachingGhostObject *ghostCollider, int collidesWith=GRP_BALL|GRP_EXPLODABLE);
	
		// initializes singleton manager
		void Unload();
		
		// adds a physics component (adds to world)
		// warning, does not add back ghost component
		void AddComponent( PhysicsComponent *component );		
		// removes a physics component
		void RemoveComponent( PhysicsComponent *component);
		
		// sets grav in physics world
		void SetGravity(btVector3 &gravity);
		
		void GetTriggerContactList(std::set<EntityPair> &triggeredObjects);
		
		
	};
#endif	
	
}