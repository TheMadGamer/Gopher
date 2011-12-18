/*
 *  FlipperController.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/13/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "FlipperController.h"

using namespace Dog3D;

void FlipperController::Update( float dt)
{
	float yRotation = mParent->GetYRotation();
	
	if(mOn)
	{
		// drive up
		if(yRotation < mMaxAngle)
		{
			yRotation += (mDTheta*dt);
			
			yRotation = std::min(mMaxAngle, yRotation);
			mParent->SetYRotation(yRotation);
		}
		
	}
	else
	{
		// drive down
		if(yRotation > mMinAngle)
		{
			yRotation -= (mDTheta*dt);
			
			yRotation = std::max(mMinAngle, yRotation);
			mParent->SetYRotation(yRotation);	
		}
		
	}
}