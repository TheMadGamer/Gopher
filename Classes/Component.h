/*
 *  Component.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <vector>

namespace Dog3D
{

	class Entity;
	
	enum ComponentType
	{
		GRAPHICS, PHYSICS, NAVIGATION, 
		TRIGGER, SPAWN_COMPONENT, 
		TARGET, FX, LOGIC_EXPLODE,
		PADDLE, FLIPPER
	};
	
	class Component 
	{
	protected:
		// back pointer to parent
		Entity *mParent;
		ComponentType mTypeId;
		
	public:
		
		virtual ~Component(){}
		
		inline ComponentType GetTypeId(){return mTypeId;}
		
		// draw, step, run script, etc
		virtual void Update(float deltaTime) {}		
		
		inline void SetParent( Entity *parent)
		{
			mParent = parent;
		}
		
		virtual void OnCollision( Entity *collidesWith){}
		
		Entity* GetParent();
		
		virtual void Activate(){}
		
	};
	
	typedef std::vector<Component*>::iterator ComponentIterator; 

}