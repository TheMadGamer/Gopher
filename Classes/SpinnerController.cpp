/*
 *  SpinnerController.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/9/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */

#include "SpinnerController.h"

using namespace Dog3D;

// simple Spinner controller
// opens for an interval, then closes
void SpinnerController::Update( float dt)
{
	
	mCurrentAngle -= (dt * mSpeed);

	btMatrix3x3 rotationMatrix;
	rotationMatrix.setEulerYPR(0, mCurrentAngle, 0);
	
	// Update entity rotation
	
	// Fuuugly hack - physics runs off a rotation matrix
	mParent->SetRotation( rotationMatrix );
	
	// Graphics has a y rotation - Epic fail...
	mParent->SetYRotation(mCurrentAngle);
}