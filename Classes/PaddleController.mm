/*
 *  PaddleController.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/2/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "PaddleController.h"

using namespace Dog3D;

void PaddleController::Update( float dt)
{
	// dampen motion to target?
	
	mTarget.setY(mParent->GetPosition().getY());
	
	mParent->SetPosition(mTarget);
	
}