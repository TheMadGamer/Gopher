/*
 *  TargetComponent.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/25/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Component.h"

namespace Dog3D
{
	class TargetComponent : public Component
	{
	public:

		enum TargetType 
		{
			CARROT, HOLE
		};
		
		int mNetworkNodeID;
		
		TargetType mTargetType;
		
		TargetComponent(TargetType targetType) : mTargetType(targetType)
		{ 
			mTypeId = TARGET; 
			mNetworkNodeID = 0;
		}
		
	};
}