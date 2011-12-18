/*
 *  SpawnComponent.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/25/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Component.h"
namespace Dog3D
{
	class SpawnComponent : public Component
	{
	public:
		// gopher already spawing in/out
		float mSpawnTime;
		SpawnComponent() : mSpawnTime(0) { mTypeId = SPAWN_COMPONENT;}
		
		inline void Update(float dt) 
		{ 
			if(mSpawnTime > 0)
			{
				mSpawnTime -= dt; 
				if(mSpawnTime < 0)
				{
					mSpawnTime = 0;
				}
			}
		}
		
		inline void SetOccupied() { mSpawnTime  = 3.0f + (float)(rand() % 4);}
		
		inline bool GetOccupied() { return mSpawnTime > 0;}
			
	};
}