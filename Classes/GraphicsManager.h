/*
 *  GraphicsManager.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */


#import <btBulletDynamicsCommon.h>

#import <string>
#import <queue>
#import <list>

#import "Entity.h"
#import "GraphicsComponent.h"
#import "ExplodableComponent.h"
#import "PhysicsManager.h"

namespace Dog3D
{
	
	enum CameraMode
	{
		TOP_DOWN, TOP_ZOOMED, TRACKING
	};
	
	
	const int kMaxSceneTextures = 1;
	
	
	// for graphics shapes - caches various coords for reuse	
	class GraphicsManager
	{
		GraphicsManager();
	
	public:
		
		// render order
		enum RenderQueueOrder { PRE, MID, POST};
		
		~GraphicsManager()
		{
			delete mBoxCoordinateSet;
			delete mSphereCoordinateSet;
			delete mLineCoordinateSet;
			
			// release textures
			for( std::map<std::string, Texture2D *>::iterator tex = mTextures.begin(); tex != mTextures.end(); tex++)
			{
				[(tex->second) release];
			}
			mTextures.clear();
		
			
		}
	
		static void ShutDown()
		{
			delete sGraphicsManager;
			sGraphicsManager = NULL;
		}
		
		// initializes singleton manager
		static void Initialize();	
		
		void Unload();
		
		// adds a Graphics component 
		inline void AddComponent( GraphicsComponent *component)
		{
			mMidRenderQueue.push_back(component);
		}
		
		inline void AddComponent( GraphicsComponent *component, RenderQueueOrder order)
		{
			switch (order) {
				case PRE:
					mPreRenderQueue.push_back(component);
					break;
				case MID:
					mMidRenderQueue.push_back(component);
					break;
				case POST:
					mPostRenderQueue.push_back(component);
					break;
			}
		}
		
		inline void AddComponent (AnimatedGraphicsComponent *component)
		{
			mMidRenderQueue.push_back(component);
		}
		
		inline void AddComponent( FXGraphicsComponent *component, bool renderInPreQueue)
		{
			component->StartAnimation(AnimatedGraphicsComponent::IDLE);
			if(renderInPreQueue)
			{
				mPreFXComponents.push_back(component);
			}
			else 
			{
				mPostFXComponents.push_back(component);
			}

		}
		
		inline void AddComponent( HoldLastAnim *component)
		{
			mMidRenderQueue.push_back(component);
		}
		
		inline void AddComponent( ScreenSpaceComponent *component)
		{
			mSSComponents.push_back(component);
		}
		
		// removes a Graphics component
		void RemoveComponent( GraphicsComponent *component);
		
		// draw
		void Update(float deltaTime);
		
		// singleton
		static GraphicsManager *Instance()
		{
			return sGraphicsManager;
		}
		
		// set up lighting
		void SetupLights();
		
		// set up camera view
		void SetupView(float boundWidth, float boundHeight, float zEye);
		
		/*void DebugTransition();*/
		
		void OrthoViewSetup(int backingWidth, int backingHeight, float zEye);
		void OrthoViewCleanUp();
		
				
		// returns a texture map (for gophers)
		inline Texture2D *GetTexture(const std::string *textureName) 
		{
			
			std::map<std::string, Texture2D*>::iterator it = mTextures.find(*textureName);
			
			if( it == mTextures.end())
			{
				return LoadTexture(textureName);
			}
			else
			{
				return it->second;
			}
		}
		
		// returns a texture map (for gophers)
		inline Texture2D *GetTexture(NSString *name) 
		{
			
			std::string textureName([name  UTF8String]);
			
			return GetTexture(&textureName);
		}
		
		
		// show 3d projection mode
		inline void SetGraphics3D(bool show3d)
		{
			mGraphics3D = show3d;
		}
				
		inline void SetFXPool( std::queue<Entity *> *fxPool)
		{
			mFXPool = fxPool;
		}
		
		// assumes 16 frames
		// for activating something after a spawn in anim
		inline void ShowFXElement(btVector3 &position, NSString *sheetName, GraphicsComponent *triggeredComponent,
								  float scale, bool renderInPreQueue=false)
		{
			if(mFXPool)
			{
				Entity *entity = mFXPool->front();
				entity->SetPosition(position);
				
				FXGraphicsComponent *graphicsComponent= static_cast<FXGraphicsComponent*>(entity->GetGraphicsComponent());
				
				
				graphicsComponent->SetFXTexture( GraphicsManager::Instance()->GetTexture(sheetName));
				
				if(scale == 1.0f)
				{
					graphicsComponent->PlayBigVertices(false, 1.0f);
				}
				else {
					graphicsComponent->PlayBigVertices(true, scale);
				}

					
					
				graphicsComponent->StartAnimation(AnimatedGraphicsComponent::IDLE);
				
				graphicsComponent->mTriggeredComponent = triggeredComponent;
				
				if(renderInPreQueue)
				{
					mPreFXComponents.push_back(graphicsComponent);
				}
				else 
				{
					mPostFXComponents.push_back(graphicsComponent);
				}

				
				mFXPool->pop();
				mFXPool->push(entity);
				
			}
		}
		
		// only queue in post queue
		inline void ShowFXElement(btVector3 &position, 
								  ExplodableComponent::ExplosionType effect)
		{
			if(mFXPool)
			{
				Entity *entity = mFXPool->front();
				entity->SetPosition(position);
				
				FXGraphicsComponent *graphicsComponent= static_cast<FXGraphicsComponent*>(entity->GetGraphicsComponent());
				btVector3 pos(position);
				
				switch (effect) {
					case ExplodableComponent::EXPLODE_SMALL:
						//gfx
						graphicsComponent->SetFXTexture( GraphicsManager::GetTexture( @"ball.smokeExplode.sheet" ));
						graphicsComponent->PlayBigVertices(false,1);
						break;
					case ExplodableComponent::MUSHROOM:
						//gfx
						
						// offset hack
						
						pos.setX(pos.x() - 1.5f);
						entity->SetPosition(pos);
						
						graphicsComponent->SetFXTexture( GraphicsManager::GetTexture(@"mushroom.sheet"));
						graphicsComponent->PlayBigVertices(true,PhysicsManager::kMushroomBlastRadius*0.75f);
						break;
					case ExplodableComponent::ELECTRO:
						//gfx
						graphicsComponent->SetFXTexture( GraphicsManager::GetTexture(@"ball.electric.sheet"));
						graphicsComponent->PlayBigVertices(false,1);
						break;
					case ExplodableComponent::FREEZE:
						//gfx
						//graphicsComponent->SetFXTexture(GraphicsManager::GetTexture( @"ball.ice.sheet"));
						//graphicsComponent->PlayBigVertices(false,1);
						break;
					default:
						//DLog(@"WTF - unknown effect");
						graphicsComponent->SetFXTexture( GraphicsManager::GetTexture( @"ball.smokeExplode.sheet" ));
						graphicsComponent->PlayBigVertices(false,1);
						
						break;
				}
				
				graphicsComponent->StartAnimation(AnimatedGraphicsComponent::IDLE);
				
				mPostFXComponents.push_back(graphicsComponent);
				
				mFXPool->pop();
				mFXPool->push(entity);
			
			}
		}
		
		// throw up a spawn arrow at
		void PointWarningArrowAt(btVector3 spawnPosition);

		// throw up a spawn arrow at
		void PointCriticalArrowAt(btVector3 spawnPosition);
	
			
		void EvictTexture(std::string textureName)
		{
			
			std::map<std::string, Texture2D*>::iterator it = mTextures.find(textureName);
			
			if( it != mTextures.end())
			{
				Texture2D* texture = it->second;
				[texture release];
				
				mTextures.erase(it);
			}
		}
		
		// cached textures eventually blown away after scene is unloaded
		void MarkAsSceneTexture( const std::string *textureName);

		
		void DisableLineDrawing();
		void SetupLineDrawing();

		// draws debug stuff in red
		void DrawLine(btVector3 pointA, btVector3 pointB);

#pragma mark DEBUG DRAWING
#if DEBUG

		
		void DrawSquare(btVector3 center, btVector3 extents);
		
		void DrawCircle(btVector3 center, btVector3 extents);

	public: 
		inline void DrawDebugLine(btVector3 pointA, btVector3 pointB)
		{
			mDebugLinePairs.push(pointA);
			mDebugLinePairs.push(pointB);
		}

		inline void DrawDebugSquare(btVector3 pointA, btVector3 pointB)
		{
			mDebugSquares.push(pointA);
			mDebugSquares.push(pointB);
		}
		
		inline void DrawDebugCircle(btVector3 pointA, btVector3 pointB)
		{
			mDebugCircles.push(pointA);
			mDebugCircles.push(pointB);
		}
		
		
		

		bool mShowDebug;
#endif
		const MaterialSet *GetDefaultMaterialSet() const { return & mDefaultMaterialSet;}
		const CoordinateSet *GetBoxCoordinateSet() const { return mBoxCoordinateSet;}
		const CoordinateSet *GetSphereCoordinateSet() const { return mSphereCoordinateSet;}
		const CoordinateSet *GetLineCoordinateSet() const { return mLineCoordinateSet;}
		
	private:
		
#if DEBUG
		std::queue<btVector3> mDebugLinePairs;
		std::queue<btVector3> mDebugSquares;
		std::queue<btVector3> mDebugCircles;
#endif
		
		// for caching textures
		inline bool TextureLoaded(NSString *name)
		{
			std::string textureName([name  UTF8String]);
			
			return mTextures.find(textureName) != mTextures.end();
		}
		
		

		
		Texture2D* LoadTexture(const std::string *name)
		{
			NSString *textureName = [[NSString alloc] initWithUTF8String:name->c_str()];
			
			Texture2D *texture = LoadTexture(textureName);
			[textureName release];
			return texture;
			
		}
		
		Texture2D* LoadTexture(NSString *name)
		{	
			
			Texture2D *texture = [[Texture2D alloc] initWithImagePath:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]];
			
			// convert to std::string
			std::string textureName([name UTF8String]);
			
			mTextures[textureName] = texture;
			return texture;
			
		}
		
		// loads animation texture maps
		void InitializeTextures();
		
		void InitializeCoordinateSets();
		
		void InitializeBoxCoordinateSet( CoordinateSet *coordSet);
		
		void InitializeSphereCoordinateSet( CoordinateSet *coordSet);
		
		void InitializeLineCoordinateSet( CoordinateSet *coordSet);
		
		MaterialSet mDefaultMaterialSet;
		
		std::map<std::string, Texture2D *> mTextures;
		
		// list of n scene textures, unloaded in order
		// 
		std::list<std::string> mSceneTextures;

		btVector3 mTrackVelocity;
		
		// managed components
		std::list<GraphicsComponent *> mPreRenderQueue;	
		std::list<GraphicsComponent *> mMidRenderQueue;
		std::list<GraphicsComponent *> mPostRenderQueue;
		
		std::list<FXGraphicsComponent *> mPreFXComponents;		
		std::list<FXGraphicsComponent *> mPostFXComponents;
		
		std::list<ScreenSpaceComponent *> mSSComponents;
		
		
		std::queue<Entity *> *mFXPool;
		
		std::map<std::string , GraphicsComponent *> mCachedGraphicsObjects;
		CoordinateSet *mBoxCoordinateSet;
		CoordinateSet *mSphereCoordinateSet;
		CoordinateSet *mLineCoordinateSet;
		
		
		// singleton
		static GraphicsManager *sGraphicsManager;
		
		
		bool mIdle;
		bool mGraphics3D;
		
	};
}