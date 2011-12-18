/*
 *  TriggerComponent.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/8/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */
#import "TriggerComponent.h"

using namespace Dog3D;

void TriggerComponent::OnCollision( Entity *collidesWith)
{
	if(mGate != NULL)
	{
		mGate->Activate();
	}
}