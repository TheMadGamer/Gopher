/*
 *  HUDController.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/22/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "Component.h"
#import "GraphicsComponent.h"

namespace Dog3D
{
	
	class HUDController
	{
	public:
		HUDController(int nLives) : mNumLives(nLives){}
		
		void Update(float dt);
		
		void SetNumLives(int nLives)
		{
			
		}
		
	private:
		int mNumLives;
	};
}