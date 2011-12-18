/*
 *  PaddleController.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/2/10.
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
	class PaddleController : public Component
	{
	public:
		enum ConstraintAxis 
		{
			X_POS, X_NEG, Z_POS, Z_NEG
		};
		
	private:
		btVector3 mTarget;
		
		ConstraintAxis mConstraintAxis;
		
	public:
		PaddleController( ConstraintAxis constraintAxis) 
		: mTarget(0,0,0), mConstraintAxis(constraintAxis)
		{
			if(mConstraintAxis == X_POS || mConstraintAxis == X_NEG)
			{
				mTarget.setX( mConstraintAxis == X_POS ? 8 : -8);
			}
			else 
			{
				mTarget.setZ( mConstraintAxis == Z_POS ? 14 : -14);
			}
			mTypeId = PADDLE;
		}
		
		inline void SetTarget(btVector3 &target)
		{ 
			if(mConstraintAxis == X_POS || mConstraintAxis == X_NEG)
			{
				mTarget.setZ(target.getZ());
				mTarget.setX( mConstraintAxis == X_POS ? 8 : -8);
				
			}
			else {
				mTarget.setX(target.getX());
				mTarget.setZ( mConstraintAxis == Z_POS ? 14 : -14);
			}
		}
		
		void Update( float dt);
		
	};
}
