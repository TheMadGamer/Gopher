/*
 *  CannonUI.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/27/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */


#import "Component.h"
#import "Entity.h"

namespace Dog3D 
{
	
	
	//spawn is for spawn in
	// locomotion_idle is sitting there
	// attack is moving
	// defended - cannot be killed, eating
	// explode - blown up
	
	/*abstract class GopherController : public Component
	 {
	 void Update(float dt) = 0;
	 }*/
	
	const float kFireRadius = 3.0f;
	const float kWheelInnerRadius = 1.0f;
	const float kWheelOuterRadius = 6.0f;
	
	// this controller maintians locomotion
	class CannonUI : public Component
	{
		Entity *mCannon;
		
		Entity *mWheel;
		Entity *mButton;
		
		float mRotationOffset;
		
		btVector3 mStartSwipe;
		
		float mSwipeRotation;
		
		float mRotationScale;
		
		bool mSwipeStarted;
		
		
	public:
		CannonUI(Entity *cannon, Entity *wheel, Entity *button, float rotationScale)
		: mCannon(cannon), 
		mWheel(wheel), 
		mButton(button),
		mSwipeStarted(false),
		mRotationOffset(0),
		mRotationScale(rotationScale)
		{ }
		
		void SetTouch(btVector3 touch);
		
		bool StartSwipe(btVector3 &swipe);
		
		void MoveSwipe(btVector3 &swipe);
		
		void EndSwipe(btVector3 swipe);
		
		inline void SetRotationOffset(float offset) { mRotationOffset = offset;}
		
		void CancelSwipe();	
		
		inline float AngleToX(float angle)
		{
			return (angle) * 10.0f/mRotationScale;
		}
		
		inline float XToAngle(float x)
		{
			return x * mRotationScale/10.0f;
		}
	};
	
}