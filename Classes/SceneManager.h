/*
 *  SceneManager.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 3/2/10.
 *  Copyright 2010 HighlandAvenue. All rights reserved.
 *
 */

#import "Entity.h"
#import "Component.h"
#import "GamePlayManager.h"
#import "ExplodableComponent.h"
#import <vector>
#import <string>

namespace Dog3D
{
	
	class SceneManager
	{
	public:
		
		enum WallCreationFlags
		{
			TOP = 0x1,
			BOTTOM = 0x2,
			LEFT = 0x4,
			RIGHT = 0x8,
			FLOOR = 0x10,
			CEILING = 0x20,
			ALL = -1
		};
		
		class SpawnInfo {
		public:
			
			SpawnInfo(std::string typeName,
					  btVector3 pos,
					  btVector3 scale,
					  float yRot,
					  float spawnTime): 
			mPosition(pos),
			mScale(scale), 
			mYRotation(yRot),
			mSpawnTime(spawnTime)
			{
				mTypeName = typeName;
			}
			
			~SpawnInfo(){ }
			
			std::string mTypeName;
			
			btVector3 mPosition;
			btVector3 mScale;
			float mYRotation;
			float mSpawnTime;
			
		};
		
		class RespawnInfo : public SpawnInfo 		
		{
			
		public:
			
			RespawnInfo(std::string typeName,
					  btVector3 pos,
					  btVector3 scale,
					  float yRot,
					  float spawnTime,
					  float respawnInterval) :
			SpawnInfo(typeName, pos, scale, yRot, spawnTime),
			mRespawnInterval(respawnInterval)
			{
				DLog(@"Respawn Info Interval %f", respawnInterval);
			}
			
			float mRespawnInterval;
			
		};
		
		class LevelControlInfo
		{
		public:
			
			std::string mBackground;
			IntervalQueue mSpawnIntervals;
			
			btVector3 mBallSpawn;
			btVector3 mWorldBounds;
			
			float mCarrotSearchDistance;
			
			int mNumCombos;
			int mNumGopherLives;
			int mScoreMode;
			int mBallTypes;
			int mNumBalls;
			int mCollisionAvoidance;
			GamePlayManager::GamePlayMode mPlayMode;
            bool singleUseHoles;
			
			
			
			LevelControlInfo(): 
			mBallSpawn(8.5,1.5,0),
			mWorldBounds(10,10,15),
			mNumCombos(0), 
			mNumGopherLives(0), 
			mScoreMode(0), 
			mBallTypes(-1), 
			mNumBalls(-1),
			mCollisionAvoidance(0),
			mCarrotSearchDistance(20.0f),
			mPlayMode(GamePlayManager::CANNON ),
            singleUseHoles(false)
			{
			}
			
			LevelControlInfo(NSDictionary *controlDictionary);	
			
			~LevelControlInfo()
			{
			}
		};
		
		
	private:
		static SceneManager *sInstance;
		
		std::vector<Entity *> mSpawnPoints;
		
		std::vector<Entity *> mTargets;
		
		std::vector<Entity *> mGophers;
		
		std::vector<Entity *> mHedges;
		
		std::vector<Entity *> mWalls;
		
		std::set<Entity *> mSceneElements;
		
		std::vector<Entity *> mBalls;
		
		std::vector<Entity*> mHuds;
		
		std::queue<Entity *> mFXPool;
		
		std::list<SpawnInfo*> mDelayedSpawns;
		
		LevelControlInfo mLevelControl;
		
		Entity *mCannon;
		
		std::string mSceneName;
		
		float mFixedRest;
		float mBounceRest;
		
		int mNumCarrots;
		
		bool mSceneLoaded;
		
		SceneManager(): mSceneLoaded(false), mCannon(NULL), mNumCarrots(0), mFixedRest(1.0f), mBounceRest(1.1f){}
	public:
		
		static void Initialize() { sInstance = new SceneManager();}
		static SceneManager *Instance(){ return sInstance;}	
		static void ShutDown() { delete sInstance;  sInstance = NULL;}
		
		Entity *GetBall(int idx){ return mBalls[idx]; }
		
		void LoadScene( NSString* levelName );	
		void UnloadScene();
		
		//void AddWin();
		//void AddLost();

		void ConvertToSingleBodies(Entity *compoundEntity,
								   std::vector<Entity*> &newBodies);
		
		void Update(float dt);
		
		// for adding a respawn
		void AddDelayedSpawn(SpawnInfo *info)
		{
			mDelayedSpawns.push_back(info);
		}
		
		inline std::string GetSceneName()
		{
			return mSceneName;
		}
		
		void RefreshSpawnIntervals(float gameTime);
		
        bool GetSingleUseHoles(){ return mLevelControl.singleUseHoles;}
        
	private:
		// see wall creation flags
		void CreateWalls(const std::string  *background,  int wallFlags, bool poolTable);
		
		void LoadGeneratedObjects(NSDictionary *rootDictionary);
		
		void LoadSceneObjects(NSDictionary *rootDictionary);
		
		// screen space faux widgets
		void LoadHUDs();
	};
}	