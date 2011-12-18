/*
 *  GateControllerComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

#include "GateControllerComponent.h"


using namespace Dog3D;

// simple gate controller
// opens for an interval, then closes
void GateController::Update( float dt)
{

	if(mState)
	{
		if(mCurrentAngle == mOpenAngle)
		{
			mTimer += dt; 
			if(mTimer >= mInterval)
			{
				mState = false;
			}
		}
		else 
		{
			mTimer += dt;
			mCurrentAngle += (dt * mSpeed);
		
			if(mCurrentAngle > mOpenAngle)
			{
				mCurrentAngle = mOpenAngle;
			}
			
			// update entity rotation
			mParent->SetYRotation( mCurrentAngle );
		}
	}
	else 
	{
		if(mCurrentAngle != mClosedAngle)
		{
			mCurrentAngle -= (dt * mSpeed);
			
			if(mCurrentAngle < mClosedAngle)
			{
				mCurrentAngle = mClosedAngle;
			}
			
			// Update entity rotation
			mParent->SetYRotation( mCurrentAngle );
		}
	}
}