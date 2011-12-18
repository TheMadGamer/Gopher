/*
 *  Explodable.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/24/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */


#import <vector>
#import <string>
#import "Component.h"
#import "NodeNetwork.h"
#import "GraphicsComponent.h"

namespace Dog3D 
{
	
	const float kBallRespawnTime = 1.1;
	const float kMaxFuseTime = 5.0;
	
	
	/// Ball exploder component
	class ExplodableComponent : public Component
	{	
	public:
		
		enum ExplodeState 
		{
			//IDLE, do nothing
			//PRIMED, begin count down
			IDLE, PRIME_DELAY, PRIMED, EXPLODE, TIMED_EXPLODE, RECLAIM
		};
		
		enum ExplosionType
		{
			EXPLODE_SMALL = 1, 
			ELECTRO = 2, 
			FREEZE = 4,
			FIRE = 8,
			MUSHROOM = 16,
			CUE_BALL = 32,
			BALL_8 = 64,
			POP = 128,
			BUMPER = 256
		};
		
	private:
		float mRespawnTime;
		
	protected:
		ExplodeState mExplodeState;
		
		
		float mFuseTime;
		
		ExplosionType mExplosionType;
		float mPrimeDelay;
		bool mIsTrigger;
		bool mTimeBomb;
		
		void Explode()
		{
			mExplodeState = EXPLODE;
			mRespawnTime = kBallRespawnTime;
		}
		
	public:
		
		ExplodableComponent( ExplosionType explosionType ) : 
		mExplodeState(IDLE), 
		mRespawnTime(0), 
		mPrimeDelay(-1),
		mIsTrigger(false),
		mTimeBomb(false), 
		mExplosionType(explosionType)
		{
			mTypeId = LOGIC_EXPLODE;
		};
		
		inline bool GetIsTrigger(){  return mIsTrigger;}
		inline void SetIsTrigger(bool isTrigger)
		{
			mIsTrigger = true;
		}
		
		void PrimeAfterDelay(float nSeconds)
		{
			mPrimeDelay = nSeconds;
			mExplodeState = PRIME_DELAY;
		}
		
		virtual bool DetonatesOtherCollider(){ return true;}
		
		//inline void SetExplostionType(FXGraphicsComponent::FXElementType explosionType) { mExplosionType = explosionType; }
		
		inline ExplosionType GetExplosionType(){ return mExplosionType;}
		
		//inline ExplodeState GetExplodeState() { return mExplodeState;}
		inline bool IsExploding() { return mExplodeState == EXPLODE || mExplodeState == TIMED_EXPLODE;}
		inline bool IsPrimed() { return mExplodeState == PRIMED;}
		inline bool CanReclaim() { return mExplodeState == RECLAIM;}
		
		// kick off explode
		//void Explode();
		void OnCollision( Entity *collidesWith);
		
		// update explode timer
		void Update(float dt);
		
		inline void SetTimeBomb(bool timeBomb)
		{
			mTimeBomb = timeBomb;
		}
		
		// this allows defered activation in flick mode
		// the ball can idle unit touched
		inline void Prime()
		{
			mFuseTime = 0;
			mExplodeState = PRIMED;
		}
		
		// this allows ball to be spawned in, but not timer count down
		inline void Reset()
		{
			mExplodeState = IDLE;
			mRespawnTime = 0;
			mFuseTime = 0;
		}
		
	};

	// object releases from kinematic state on explode 
	class FireballExplodable : public ExplodableComponent
	{
	public:
		FireballExplodable( ExplosionType explosionType) : 
		ExplodableComponent(explosionType){}
		
		void OnCollision(Entity *collidesWith);
	};
	
	// object releases from kinematic state on explode 
	class KinematicReleaseExplodable : public ExplodableComponent
	{
	public:
		KinematicReleaseExplodable( ExplosionType explosionType) : 
			ExplodableComponent(explosionType){}
		
		void OnCollision(Entity *collidesWith);
	};
	
	// breaks into sub components  on explode 
	class CompoundExplodable : public ExplodableComponent
	{
	public:
		CompoundExplodable( ExplosionType explosionType) : 
		ExplodableComponent(explosionType){}
		
		void OnCollision(Entity *collidesWith);
	};

	// keeps on exploding 
	class AntiGopherExplodable : public ExplodableComponent
	{
	public:
		AntiGopherExplodable( ExplosionType explosionType) : 
		ExplodableComponent(explosionType){}
		
		void OnCollision(Entity *collidesWith);
	};
	
	// keeps on exploding 
	class InfiniteExplodable : public ExplodableComponent
	{
	public:
		InfiniteExplodable( ExplosionType explosionType) : 
		ExplodableComponent(explosionType){}
		
		void OnCollision(Entity *collidesWith);
	};
	
	// keeps on exploding 
	class RespawnExplodable : public ExplodableComponent
	{
		float mRegenerateTime;
		std::string mRespawnType;
	public:
		RespawnExplodable( ExplosionType explosionType, float respawnTime, std::string respawnType) : 
		ExplodableComponent(explosionType), mRegenerateTime(respawnTime), mRespawnType(respawnType)
		{		
		}
		
		void OnCollision(Entity *collidesWith);
		
	};
	
	// keeps on exploding 
	class BumperExplodable : public ExplodableComponent
	{
		float mRegenerateTime;
		std::string mRespawnType;
	public:
		BumperExplodable( ExplosionType explosionType, float respawnTime, std::string respawnType) : 
		ExplodableComponent(explosionType), mRegenerateTime(respawnTime), mRespawnType(respawnType)
		{		
		}
		
		virtual bool DetonatesOtherCollider(){ return false;}
		
		void OnCollision(Entity *collidesWith);
	};
	
	// pop, regenerate,  
	class PopExplodable : public ExplodableComponent
	{
		float mRegenerateTime;
		std::string mRespawnType;
	public:
		PopExplodable( ExplosionType explosionType, float respawnTime, std::string respawnType) : 
		ExplodableComponent(explosionType), mRegenerateTime(respawnTime), mRespawnType(respawnType)
		{		
		}
		
		virtual bool DetonatesOtherCollider(){ return false;}
		
		void OnCollision(Entity *collidesWith);
	};
}