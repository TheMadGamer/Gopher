/*
 *  Entity.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/19/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import "Entity.h"
#import "PhysicsComponent.h"
#import "GraphicsComponent.h"
#import "ExplodableComponent.h"

using namespace Dog3D;
using namespace std;

Entity::Entity() :
mPosition(btVector3(0,0,0)),
mGraphicsComponent(NULL),
mPhysicsComponent(NULL),
mController(NULL),
mSpawnComponent(NULL),
mExplodableComponent(NULL),
mActive(true),
// do not set rotation in graphics component 
// unless someone actually assings the matrix
mRotationSet(false),
mYRotation(0)
{
	mRotation.setIdentity();
}

void Entity::SetGraphicsComponent( GraphicsComponent *graphicsComponent)
{
	mGraphicsComponent = graphicsComponent;
	graphicsComponent->SetParent(this);
}

void Entity::SetPhysicsComponent( PhysicsComponent *physicsComponent)
{
	mPhysicsComponent = physicsComponent;
	if(mPhysicsComponent)
	{
		physicsComponent->SetParent(this);
	}
}

void Entity::SetExplodable( ExplodableComponent *explodableComponent)
{
	mExplodableComponent = explodableComponent;
	mExplodableComponent->SetParent(this);
}

Entity::~Entity()
{	
	if(mGraphicsComponent)
	{
		delete mGraphicsComponent;
		mGraphicsComponent = NULL;
	}
	
	if(mPhysicsComponent)
	{
		delete mPhysicsComponent;
		mPhysicsComponent = NULL;
	}
	
	if(mController)
	{
		
		delete mController;
		mController = NULL;
	}
	
	if(mSpawnComponent)
	{
		delete mSpawnComponent;
		mSpawnComponent = NULL;
	}

	if(mExplodableComponent)
	{
		delete mExplodableComponent;
		mExplodableComponent = NULL;
	}
	
	for(int i = 0; i < mGenericComponents.size(); i++)
	{
		delete mGenericComponents[i];
	}
	
	mGenericComponents.clear();
	
	
}