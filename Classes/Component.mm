/*
 *  Component.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */
#import "Component.h"
#import "Entity.h"

namespace Dog3D
{

	Entity* Component::GetParent()
	{
		return mParent;
	}
}