/*
 *  SpinnerController.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/9/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

/*
 *  SpinnerControllerComponent.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

#import "Component.h"
#import "PhysicsManager.h"

#import <vector>

namespace Dog3D
{
	
	// Spinner controller component
	class SpinnerController : public Component
	{				
		
	public:
		
		SpinnerController(float speed) :
		mSpeed(speed),
		mCurrentAngle(0)
		{}
		
		virtual void Update(float dt);
		
		
	protected:
		
		float mSpeed;
		float mCurrentAngle;
	};
	
}