/*
 *  GenericsFactory.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/9/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */


#import <btBulletDynamicsCommon.h>

#import "GameEntityFactory.h"

#import "GraphicsComponent.h"
#import "GraphicsComponentFactory.h"
#import "GraphicsManager.h"

#import "PhysicsComponent.h"
#import "PhysicsComponentFactory.h"
#import "PhysicsManager.h"

#import "GamePlayManager.h"
#import "GopherController.h"
#import "SpawnComponent.h"
#import "TargetComponent.h"
#import "ExplodableComponent.h"
#import "PaddleController.h"
#import "SceneManager.h"
#import "CannonController.h"
#import "GateControllerComponent.h"
#import "SpinnerController.h"

#import <vector>


const float kFixedHeight = 10;
using namespace Dog3D;
using namespace std;


Entity *GameEntityFactory::BuildGate( btVector3 &initialPosition, btVector3 &halfExtents, 
												 float yRotation, float restitution, NSString *textureName,
												 float graphicsScale, float triggerX, float triggerZ)
{
	
	Entity *newEntity = new Entity();
	newEntity->SetPosition(initialPosition);
	
	btMatrix3x3 rotation;
	rotation.setEulerZYX(0, 0, yRotation);
	newEntity->SetRotation(rotation);
	
#if DEBUG
	newEntity->mDebugName = [textureName UTF8String];
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f * graphicsScale, 
																				 halfExtents.z()*2.0f * graphicsScale, 
																				 textureName);
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newEntity->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = false;
	info.mRestitution = restitution;
	info.mDoesNotSleep = false;
	info.mCanRotate = true;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith = GRP_BALL | GRP_GOPHER;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, yRotation, info );
	
	physicsBox->SetKinematic(true);
	
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newEntity->SetPhysicsComponent( physicsBox );
	
	GateController *gate = new GateController(PI/2.0f, 10.0f, 0.0f, -PI/2.0f );
	newEntity->AddComponent(gate);
	
	TriggerComponent *trigger = new TriggerComponent(gate);
	newEntity->AddComponent(trigger);
	
	GamePlayManager::Instance()->AddKinematicController(gate);
	
	return newEntity;
	
}



Entity *GameEntityFactory::BuildSpinner( btVector3 &initialPosition, btVector3 &halfExtents, 
									 float yRotation, float restitution, NSString *textureName,
									 float graphicsScale)
{
	
	Entity *newEntity = new Entity();
	newEntity->SetPosition(initialPosition);
	
	btMatrix3x3 rotation;
	rotation.setEulerZYX(0, 0, yRotation);
	newEntity->SetRotation(rotation);
	
#if DEBUG
	newEntity->mDebugName = [textureName UTF8String];
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f * graphicsScale, 
																				 halfExtents.z()*2.0f * graphicsScale, 
																				 textureName);
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newEntity->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = false;
	info.mRestitution = restitution;
	info.mDoesNotSleep = false;
	info.mCanRotate = true;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith = GRP_BALL | GRP_GOPHER;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, yRotation, info );
	
	physicsBox->SetKinematic(true);
	
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newEntity->SetPhysicsComponent( physicsBox );
	
	SpinnerController *spinner = new SpinnerController(PI/2.0f);
	newEntity->AddComponent(spinner);

	
	GamePlayManager::Instance()->AddKinematicController(spinner);
	
	return newEntity;
	
}

