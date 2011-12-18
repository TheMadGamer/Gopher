/*
 *  TriggerComponent.h
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Component.h"
#import "PhysicsManager.h"
#import <vector>

namespace Dog3D
{
	
	// Collidable component
	class TriggerComponent : public Component
	{				
		
	public:
		
		TriggerComponent( Component *gate ) : mGate(gate){}

		// trips a sensor
		virtual void OnCollision( Entity *collidesWith);
		
	protected:	

		Component *mGate;
	};
	
	typedef std::vector<TriggerComponent*>::iterator  TriggerComponentIterator;
	
}