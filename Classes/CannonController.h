/*
 *  CannonController.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/17/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <vector>
#import "Component.h"
#import "NodeNetwork.h"
#import "Entity.h"
#import <btBulletDynamicsCommon.h>

#import <queue>


namespace Dog3D 
{
	
	
	//spawn is for spawn in
	// locomotion_idle is sitting there
	// attack is moving
	// defended - cannot be killed, eating
	// explode - blown up
	
	/*abstract class GopherController : public Component
	 {
	 void Update(float dt) = 0;
	 }*/

	const float kCannonForceCoef = 20.0f;

	
	// this controller maintians locomotion
	class CannonController : public Component
	{
		float mPowerScale;
	public:
		CannonController(float powerScale):mPowerScale(powerScale){}
				
		void AddBall(Entity *ball);
		
		void FireBall();
		
		int NumBallsLeft(){ return mBalls.size();}
		
	private:
		std::queue<Entity *> mBalls;

		
 	};

}