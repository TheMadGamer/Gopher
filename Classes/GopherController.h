/*
 *  NavigationComponent.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/12/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <vector>
#import "Component.h"
#import "NodeNetwork.h"
#import "Entity.h"
#import <btBulletDynamicsCommon.h>

namespace Dog3D 
{

	
	const float kTauntMin = 2.0f;
	const int kTauntRange = 5.0f;
	const float kRespawnWait = 2.0;
	
	
	// this controller maintians locomotion
	class GopherController : public Component
	{
	public:
		enum ControllerState
		{
			SPAWN, 
			IDLE, 
			ATTACK, 
			EAT,
			EAT_FINAL,
			RUN_AWAY, 
			JUMP_DOWN, 
			EXPLODE, 
			WIN_DANCE, 
			FREEZE,
			ELECTRO,
			FIRE,
			DEAD,
			TAUNT
		};
		
	private:
		ControllerState mControllerState;
		ControllerState mPreviousState;
		
		TheMadGamer::Vec2 mTarget;
		std::vector<const TheMadGamer::PositionedNode *> mPath;
		
		// for a jump down hole type motion
		btVector3 mStartMotionPosition;
		
		// active attack target
		Entity *mActiveTarget;
		
		// pause in idle - how many frames until it transitions to next anim
		int mPauseFrame;
		float mIntraFrameTime;
		
		// regulates gophers' walk animation speed
		float kWalkSpeed;
		
		float mSpawnTime;
		
		float mExplodeTime;
		
		float mTauntTime;
		
	public:
		
		GopherController() : 
		mControllerState(SPAWN), 
		mActiveTarget(NULL) , 
		mPauseFrame(0), 
		mIntraFrameTime(0), 
		kWalkSpeed(2.0), 
		mSpawnTime(0.0),
		mTetheredHole(NULL),
		mAvoidCollisions(false),
		mTauntTime(0)
		{
			mTypeId = NAVIGATION;
		}
		
		inline Entity *GetActiveTarget() { return mActiveTarget; }
		inline void SetActiveTarget( Entity *target) { mActiveTarget = target;}
		
		inline ControllerState GetControllerState(){ return mControllerState;}
		
		inline void SetTetherHole(Entity *hole)
		{
			mTetheredHole = hole;
		}
		
		inline Entity* GetTetherHole()
		{
			return mTetheredHole;
		}
				
		void OnCollision(Entity *);
		
#pragma mark STATE ACTIVATION
		// spawn in a gopher
		void Spawn(const btVector3 &position);
		
		// idle the gopher
		void Idle();
		
		// attack a direction
		void Attack(Entity* target, const TheMadGamer::NodeNetwork *nodeNetwork);
		
		// eat carrot, cannot be killed
		void Eat(); 
		
		// explode - go under phys control
		void Explode(btVector3 &velocity);
		
		//void Freeze();
		
		void Electro();
		
		void Fire();
		
		void WinDance();
		
		void RunAway(Entity* target, const TheMadGamer::NodeNetwork *nodeNetwork);
		
		void JumpDown();
		
		void Taunt();
		
		void Update(float dt);
		
#pragma mark STATE UPDATE
		void UpdateTaunt(float dt);
		void UpdateSpawn(float dt);
		void UpdateEat(float dt);
		void UpdateIdle(float dt);
		void UpdateAttackAndRun(float dt);
		void UpdateJumpDown(float dt);
		void UpdateExplode(float dt);
		
#pragma mark BASIC LOGIC		
		
		inline void SetRandomTauntDelay() 
		{
			mTauntTime = 1.5f + kTauntMin + (rand()  % kTauntRange);
		}
		
		inline float GetExplodeTime() { return mExplodeTime; }
		
		inline float GetSpawnTime(){ return mSpawnTime;}
		
		inline void StepSpawnTime(float dt) { mSpawnTime -= dt;}
		
		inline bool Reactive()
		{
			return (mControllerState == EXPLODE || mControllerState == FIRE || mControllerState == ELECTRO ||
					mControllerState == FREEZE);
		}
		
		// frozen gophers can explode
		inline bool CanExplode()
		{ 
			return mParent->mActive && 
			(! (mControllerState == JUMP_DOWN && mPauseFrame < 10))
			&& mControllerState != EXPLODE && mControllerState != DEAD
			&& mControllerState != ELECTRO && mControllerState != FIRE; 
		}

		// frozen goph's cannot react
		inline bool CanReact()
		{ 
			return mParent->mActive && 
			(! (mControllerState == JUMP_DOWN && mPauseFrame < 10))
			&& mControllerState != EXPLODE && mControllerState != DEAD
			&& mControllerState != FIRE && mControllerState != FREEZE &&
			mControllerState != ELECTRO; 
		}
		
		inline void SetCollisionAvoidance(bool value)
		{
			mAvoidCollisions =value;
		}
		
	private:
		Entity *mTetheredHole;
		
		void PlayWinAnimation();
	
		void IntegrateMotion(float dt);
		
		bool AvoidObstacles(btVector3 &direction, btVector3& alternativePosition);
		
		bool mAvoidCollisions;
		
		
	};

}