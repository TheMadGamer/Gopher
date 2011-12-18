/*
 *  PhysicsComponentFactory.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Component.h"
#import "PhysicsComponent.h"

namespace Dog3D
{
	class PhysicsComponentFactory
	{
	public:
		
		static PhysicsComponent *BuildPlane(btVector3 &initialPosition, float yNormalDirection, PhysicsComponentInfo &info);
		
		static PhysicsComponent *BuildBall(float radius,btVector3 &initialPosition,
									PhysicsComponentInfo &info);
		
		static PhysicsComponent *BuildBox(btVector3 &initialPosition, btVector3 &halfExtents, float yRotation, PhysicsComponentInfo &info );
		
		static PhysicsComponent *BuildCylinder(float radius, float height, btVector3 &initialPosition, PhysicsComponentInfo &info);
		
		static PhysicsComponent *BuildFenceTriple(btVector3 &initialPosition, 
												  btVector3 &halfExtents, 
												  PhysicsComponentInfo &info,
												  btVector3 &postExtents,
												  btVector3 &topSlatExtents);

		
	private:
		static btRigidBody *CreateRigidBody(btVector3 &initialPosition, btCollisionShape *shape, 
											btMotionState** motionState,
											float yRotation, PhysicsComponentInfo &info);
	};
}