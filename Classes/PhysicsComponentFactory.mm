/*
 *  PhysicsComponentFactory.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */
#import "Entity.h"
#import "PhysicsComponent.h"
#import "PhysicsComponentFactory.h"

using namespace Dog3D;




btRigidBody *PhysicsComponentFactory::CreateRigidBody(btVector3 &initialPosition, btCollisionShape *shape, btMotionState** motionState, float yRotation, PhysicsComponentInfo &info)
{
	// create a motion state
	btQuaternion rotation(0,0,0,1);
	if(yRotation != 0)
	{
		rotation.setEulerZYX(0, yRotation, 0);
	}
	
	
	(*motionState) = new btDefaultMotionState(btTransform(rotation,initialPosition));
	
	if( info.mIsStatic ) 
	{
		info.mMass = 0;
	}
	
	btVector3 inertia(0,0,0);
	if( (! info.mIsStatic) && info.mCanRotate)
	{
		shape->calculateLocalInertia( info.mMass,  inertia);
	}
	
	btRigidBody::btRigidBodyConstructionInfo rigidBodyCI(info.mMass, *motionState, shape, inertia);
	rigidBodyCI.m_restitution = info.mRestitution;
	
	if(!info.mCanRotate)
	{
		rigidBodyCI.m_friction = 0;
	}
	else {
		rigidBodyCI.m_friction = info.mFriction;
	}
	
	rigidBodyCI.m_linearDamping = 0.05;
	rigidBodyCI.m_angularDamping = 0.05;
	
	
	btRigidBody *body = new btRigidBody(rigidBodyCI);	
	
	body->setLinearVelocity(info.mInitialVelocity);	
	
	if(info.mDoesNotSleep)
	{
		// spheres do not deactivate
		body->setActivationState(DISABLE_DEACTIVATION);
	}
	
	return body;
}

PhysicsComponent *PhysicsComponentFactory::BuildBall(float ballRadius, btVector3 &initialPosition, PhysicsComponentInfo &info )
{	
	// build a shape
	btCollisionShape *shape = new btSphereShape(ballRadius);
	DLog(@"Build Ball w/ Radius %f", ballRadius);
	
	//btCompoundShape *shape = new btCompoundShape();
	//shape->addChildShape(btTransform(btQuaternion(0,0,0,1),btVector3(ballRadius*0.75f,0,0)), childShape);
	
	// set phys component
	btMotionState *motionState = NULL;
	
	btRigidBody *body = CreateRigidBody(initialPosition, shape, &motionState, 0, info);
	
	PhysicsComponent *physicsComponent = new PhysicsComponent(body, shape, motionState, info.mCollisionGroup, info.mCollidesWith);	
	
	body->setUserPointer(physicsComponent);
	
	return physicsComponent;	
}


PhysicsComponent *PhysicsComponentFactory::BuildFenceTriple(btVector3 &initialPosition, 
															btVector3 &halfExtents, 
															PhysicsComponentInfo &info,
															btVector3 &postExtents,
															btVector3 &topSlatExtents)
{
	
	// create box shape
	btCompoundShape *parentShape = new btCompoundShape();
	
	{
		btTransform trans;
		trans.setIdentity();
		trans.setOrigin(btVector3(0,0, -halfExtents.x()));
		
		btCollisionShape* shape = new btBoxShape(postExtents);
		shape->setMargin(info.mCollisionBound);
		
		parentShape->addChildShape(trans, shape);
	}
		
	{
		btTransform trans;
		trans.setIdentity();
		trans.setOrigin(btVector3(0,0,0));
		
		btCollisionShape* shape = new btBoxShape(topSlatExtents);
		shape->setMargin(info.mCollisionBound);
		
		parentShape->addChildShape(trans, shape);
	}
	
	{
		btTransform trans;
		trans.setIdentity();
		trans.setOrigin(btVector3(0,0, halfExtents.x()));
		
		btCollisionShape* shape = new btBoxShape(postExtents);
		shape->setMargin(info.mCollisionBound);
		
		parentShape->addChildShape(trans, shape);
	}
	
	
	btMotionState *motionState = NULL;
	btRigidBody *body = CreateRigidBody(initialPosition,parentShape, &motionState, 0, info);
		
	// set phys component
	PhysicsComponent *physicsComponent = new PhysicsComponent(body, parentShape, motionState, info.mCollisionGroup, info.mCollidesWith);	
	
	body->setUserPointer(physicsComponent);
	
	return physicsComponent;
	
}

PhysicsComponent *PhysicsComponentFactory::BuildBox(btVector3 &initialPosition, btVector3 &halfExtents, float yRotation, PhysicsComponentInfo &info)
{
	
	// create box shape
	btCollisionShape* shape = new btBoxShape(halfExtents);
	shape->setMargin(info.mCollisionBound);

	btMotionState *motionState = NULL;
	
	btRigidBody *body = CreateRigidBody(initialPosition,shape, &motionState, yRotation, info);

	// set phys component
	PhysicsComponent *physicsComponent = new PhysicsComponent(body, shape, motionState, info.mCollisionGroup, info.mCollidesWith);	
	
	body->setUserPointer(physicsComponent);
	
	return physicsComponent;
	
}

PhysicsComponent *PhysicsComponentFactory::BuildCylinder(float radius, float height, btVector3 &initialPosition, PhysicsComponentInfo &info)
{	
	// create shape
	btVector3 extents(radius, height, radius);
	btCollisionShape *shape = new btCylinderShape( extents );
	shape->setMargin(info.mCollisionBound);
	
	btMotionState *motionState = NULL;
	
	btRigidBody *body = CreateRigidBody(initialPosition,shape, &motionState,  0, info);
	
	PhysicsComponent *physicsComponent = new PhysicsComponent(body,  shape, motionState, info.mCollisionGroup, info.mCollidesWith);	

	body->setUserPointer(physicsComponent);
	
	return physicsComponent;
	
}

// create ground plane
// weird special case
PhysicsComponent *PhysicsComponentFactory::BuildPlane(btVector3 &initialPosition, float yNormalDirection, PhysicsComponentInfo &info)
{	
	
	btCollisionShape* groundShape = new btStaticPlaneShape(btVector3(0,yNormalDirection,0),1);	
	groundShape->setMargin(0.1);
	
	//create ground plane
	btQuaternion rotation(0,0,0,1);
	
	btDefaultMotionState* groundMotionState = 
	new btDefaultMotionState(btTransform(rotation, initialPosition));
	
	btRigidBody::btRigidBodyConstructionInfo groundRigidBodyCI(0,groundMotionState, groundShape,btVector3(0,0,0));
	
	btRigidBody* body = new btRigidBody(groundRigidBodyCI);
	
	PhysicsComponent *physicsComponent = new PhysicsComponent(body, groundShape, groundMotionState, info.mCollisionGroup, info.mCollidesWith);
	
	body->setUserPointer(physicsComponent);
	
	return physicsComponent;
		
}

