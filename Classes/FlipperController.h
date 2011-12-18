/*
 *  FlipperController.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/13/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <vector>
#import "Component.h"
#import "Entity.h"
#import <btBulletDynamicsCommon.h>

namespace Dog3D 
{
	
	
	// this controller maintians locomotion
	class FlipperController : public Component
	{
		// goes from min to max
		float mMinAngle;
		float mMaxAngle;
		
		float mDTheta;
		
		bool mOn;
		
	public:
		FlipperController( float minAngle, float maxAngle, float dTheta) 
		:
		mMinAngle(minAngle),
		mMaxAngle(maxAngle),
		mDTheta(dTheta),
		mOn(false)
		{}
		
		inline void SetOn() { mOn = true;}
		inline void SetOff() { mOn = false;}
		
		void Update( float dt);
		
	};
}
