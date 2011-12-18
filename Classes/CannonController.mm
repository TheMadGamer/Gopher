/*
 *  CannonController.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 5/17/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "CannonController.h"
#include "GraphicsComponent.h"
#include "PhysicsManager.h"
#include "ExplodableComponent.h"
#include "GamePlayManager.h"
#include "GraphicsManager.h"
#include "AudioDispatch.h"

using namespace Dog3D;

void CannonController::AddBall(Entity *ball)
{
	mBalls.push(ball);
}

void CannonController::FireBall(){

	CompoundGraphicsComponent *parentGfx = static_cast<CompoundGraphicsComponent*>(mParent->GetGraphicsComponent());
	HoldLastAnim *graphics = static_cast<HoldLastAnim*>(parentGfx->GetFirstChild());
	
	if((!mBalls.empty()) && graphics->LastFrame())
	{
		AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom1);
		
		// fire cannon FX
		//FXGraphicsComponent* fx = static_cast<FXGraphicsComponent* > ( mParent->FindComponentOfType(FX) );
		//GraphicsManager::Instance()->AddComponent(fx);

		// triggers the anim
		
		graphics->StartAnimation(AnimatedGraphicsComponent::IDLE);
		
		//
		Entity *ball = mBalls.front();
		
		// re-activate
		ball->mActive = true;
		
		mBalls.pop();
		DLog(@"Cannon Fire N Balls %d", mBalls.size());
		
		btVector3 ballPosition = ball->GetPosition();
		DLog(@"Cannon Fire ball pos %f %f %f", ballPosition.x(), ballPosition.y(),
			  ballPosition.z());
		
		ExplodableComponent *explodable =  ball->GetExplodable();
		explodable->SetTimeBomb(true);
		explodable->Prime();
		
		//btVector3 resetPosition(8,1.5,0);
		btVector3 resetPosition(mParent->GetPosition());
		
		// re activate gfx
		ball->GetGraphicsComponent()->mActive = true;
		
		// get fx component				
		std::vector<Component *> fxComponents;
		ball->FindComponentsOfType(FX, fxComponents);
		
		// enable gfx
		for(int i = 0; i < fxComponents.size(); i++)
		{
			FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
			fxComponent->mActive = true;
		}
		
		
		// form a transform to respawn at
		btTransform transform;
		transform.setIdentity();
		transform.setOrigin(resetPosition);
		
		// get the physics component
		PhysicsComponent *physicsComponent =  ball->GetPhysicsComponent();
		
		// get the rigid body
		btRigidBody *rigidBody = physicsComponent->GetRigidBody();
		
		if(rigidBody)
		{
			// update the rigid body transform
			rigidBody->setWorldTransform(transform);
			
			btVector3 zero(0,0,0);
			
			float rotation = mParent->GetYRotation();
			rotation -= (M_PI * 0.5f);
			
			DLog(@"Fire angle %f", rotation);
			
			rigidBody->setLinearVelocity(btVector3(sinf(rotation)*kCannonForceCoef*mPowerScale,0,cosf(rotation)*kCannonForceCoef *mPowerScale));
			rigidBody->setAngularVelocity(zero);
			
		}
		
		PhysicsManager::Instance()->AddComponent(physicsComponent);
		physicsComponent->SetKinematic(false);
		
		
		// place ball
		// set the parent object's position
		ball->SetPosition(resetPosition);
		
		
		//give to game mgr
		GamePlayManager::Instance()->AddBall( ball );	
	}

}