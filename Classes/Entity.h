/*
 *  Entity.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/19/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <vector>
#import <string>
#import <btBulletDynamicsCommon.h>

#import "Component.h"

namespace Dog3D
{
#if DEBUG
#define DLog  NSLog
#else
#define DLog  if(false) NSLog 
#endif

	class ExplodableComponent;
	class PhysicsComponent;
	class GraphicsComponent;
	
	// basic entity class
	class Entity
	{
	protected:
		// positioned object 
		btVector3 mPosition;		
		btMatrix3x3 mRotation;
		btScalar mYRotation;

		
	public:
		GraphicsComponent *mGraphicsComponent;
		PhysicsComponent *mPhysicsComponent;
		Component *mController;
		Component *mSpawnComponent;
		ExplodableComponent *mExplodableComponent;
		
		std::vector<Component*> mGenericComponents;
		
#if DEBUG
		std::string mDebugName;
#endif
		
		bool mActive;
		
	protected:
		bool mRotationSet;
		
	public:
		
		Entity();
		
		// Destroys components
		virtual ~Entity();
		
		
		inline const btVector3 &GetPosition() const 
		{
			return mPosition; 
		}

		inline btVector3 GetPosition()
		{
			return mPosition; 
		}
				
		
		inline void SetPosition( const btVector3 &position) 
		{
			mPosition = position;
		}
		
		inline bool IsRotationSet() const
		{
			return mRotationSet;
		}
		
		inline const btMatrix3x3 &GetRotation() const
		{ 
			return mRotation; 
		}
		
		
		inline void SetYRotation( btScalar yRotation)
		{
			mRotationSet = true;
			//mRotation.setEulerYPR(0, yRotation, 0);
			mYRotation = yRotation;
		}
		
		// this is kind of a hacky system, 
		// you either use yRotation (for in plane rotation)
		// or rotation (for balls), but do not mix
		inline float GetYRotation( )
		{
			return mYRotation;
			
		}
		
		inline void SetRotation( btMatrix3x3 &rotation )
		{
			mRotationSet = true;
			mRotation = rotation;
		}
		
		////////// Physics Component ///////
		
		
		void SetPhysicsComponent( PhysicsComponent *physicsComponent);
		
		
		inline PhysicsComponent *GetPhysicsComponent()
		{
			return mPhysicsComponent;
		}	
		
		
		
		////////// Drawable ///////////
		
		void SetGraphicsComponent( GraphicsComponent *graphicsComponent);

		
		inline GraphicsComponent *GetGraphicsComponent()
		{
			return mGraphicsComponent;
		}
		
		//////// Controller Component ////////
		
		inline void SetController(Dog3D::Component *controller)
		{
			mController = controller;
			mController->SetParent(this);
		}
		
		inline Dog3D::Component *GetController()
		{
			return mController;
		}
		
		inline void SetSpawnComponent( Dog3D::Component *spawnComponent)
		{
			mSpawnComponent = spawnComponent;
			mSpawnComponent->SetParent(this);
		}
		
		inline Dog3D::Component *GetSpawnComponent()
		{
			return mSpawnComponent;
		}
		
		////////////// EXPLODABLE COMPONENT /////////////////
		
		inline ExplodableComponent *GetExplodable()
		{
			return mExplodableComponent;
		}
		
		void SetExplodable( ExplodableComponent *explodableComponent);		

		/////// Generic Componenets /////
		
		inline void AddComponent( Component *component)
		{
			mGenericComponents.push_back(component);
			component->SetParent(this);
		}
		
		inline void FindComponentsOfType( ComponentType typeId, std::vector<Component*> &components )
		{
			
			for(int i = 0; i < mGenericComponents.size(); i++)
			{
				if(mGenericComponents[i]->GetTypeId() == typeId)
				{
					components.push_back(mGenericComponents[i]);
				}
			}
		}
		
		// returns first component instance
		inline Component *FindComponentOfType( ComponentType typeId)
		{
			for(int i = 0; i < mGenericComponents.size(); i++)
			{
				if(mGenericComponents[i]->GetTypeId() == typeId)
				{
					return mGenericComponents[i];
				}
			}
			return NULL;
		}
		
	};
	
	typedef  std::vector<Dog3D::Entity*>::iterator EntityIterator;
	
}