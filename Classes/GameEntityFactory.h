/*
 *  ball.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/19/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>
#import "Entity.h"
#import "PaddleController.h"
#import "SceneManager.h"
#import "ExplodableComponent.h"
#import "GraphicsManager.h"

#include <vector>
#import <string>

class GameEntityFactory
{
	
	
	public: 	
    enum CharacterType
	{
        Gopher, Bunny, Squ
    };
    
	static Dog3D::Entity *BuildBall( float radius,  btVector3 &initialPosition, 
									bool canRotate , float restitution, 
									float mass, Dog3D::ExplodableComponent::ExplosionType explosionType,
									bool antiGopher, float friction);

	static Dog3D::Entity *BuildCharacter( float radius,  btVector3 &initialPosition, CharacterType charType );
	
	static void BuildCannon( float radius, btVector3 &initialPosition , 
							std::vector<Dog3D::Entity *> &newEntities,
							float rotationOffset, float rotationScale,
							float powerScale);
	
	static Dog3D::Entity *BuildGround( btVector3 &initialPosition , 
									  float height, float width,
									  const std::string *backgroundTexture,
									  bool poolTable);
	static Dog3D::Entity *BuildTopPlate( btVector3 &initialPosition );
	
	// gopher hole
	static Dog3D::Entity *BuildHole( btVector3 &initialPosition, float radius);
	
	// carrot
	static Dog3D::Entity *BuildCarrot( btVector3 &initialPosition, float radius);
	
	// generic box
	static Dog3D::Entity *BuildBox( btVector3 &initialPosition, btVector3 &halfExtents, 
								   bool isStatic, float restitution, 
								   float mass, bool isExplodable  );

	// explodable 3d crate (same as gas can basically, but moves)
	static Dog3D::Entity *BuildCrate( btVector3 &initialPosition, btVector3 &halfExtents, 
								   float restitution, 
								   float mass, bool isExplodable  );
	
	// sprite + explodable collider
	static Dog3D::Entity *BuildTexturedExploder( btVector3 &initialPosition, btVector3 &halfExtents, NSString *textureName);
	
	// 3d fence
	static Dog3D::Entity *BuildFence( btVector3 &initialPosition, btVector3 &halfExtents, float restitution, float mass, 
										  bool isExplodable );

	// rock like collider
	static Dog3D::Entity *BuildTexturedCollider( btVector3 &initialPosition, btVector3 &halfExtents, 
												float yRotation, float restitution, 
												NSString *textureName, float graphicsScale);
	
	static Dog3D::Entity *BuildGate( btVector3 &initialPosition, btVector3 &halfExtents, 
										 float yRotation, float restitution, NSString *textureName,
										 float graphicsScale, float triggerX, float triggerZ);
	
	static Dog3D::Entity *BuildSpinner( btVector3 &initialPosition, btVector3 &halfExtents, 
											float yRotation, float restitution, NSString *textureName,
											float graphicsScale);
	
	// rock collider
	static Dog3D::Entity *BuildCircularCollider( btVector3 &initialPosition, btVector3 &halfExtents, 
												float restitution, NSString *textureName, 
												float graphicsScale);
	
	// flower exploder
	static Dog3D::Entity *BuildCircularExploder( btVector3 &initialPosition, btVector3 &halfExtents, NSString *textureName, 
												float respawnTime, float graphicsScale, Dog3D::ExplodableComponent::ExplosionType explosionType);
	
	//3d gas can
	static Dog3D::Entity *BuildGasCan( btVector3 &initialPosition, btVector3 &halfExtents, float restitution);
	
	// boundary wall
	static Dog3D::Entity *BuildWall( btVector3 &initialPosition, btVector3 &halfExtents, float restitution );
	
	// build a static physics circle collider, no graphics component
	static Dog3D::Entity *BuildHedgeCircle( btVector3 &initialPosition, float radius );
	static Dog3D::Entity *BuildFenceBox( btVector3 &initialPosition, btVector3 &halfExtents );

	// HUDS removed
	//static Dog3D::Entity *BuildGopherHUD( btVector3 &initialPosition, btVector3 &extents, float widthSpacing, int nGopherLives, bool alignLeft);
	//static Dog3D::Entity *BuildCarrotHUD( btVector3 &initialPosition, btVector3 &extents, float widthSpacing, int nGopherLives, bool alignLeft);
	//static Dog3D::Entity *BuildHUDBackground( btVector3 &initialPosition, float width, float height);
	//static Dog3D::Entity *BuildWin();
	//static Dog3D::Entity *BuildLost();

#ifdef BUILD_PADDLE_MODE
	static Dog3D::Entity *BuildFlipper( btVector3& initialPosition, btVector3& halfExtents, float yRotation );
	static Dog3D::Entity *BuildSlidePaddle( btVector3& initialPosition, btVector3& halfExtents , Dog3D::PaddleController::ConstraintAxis axis );
#endif
	
	static Dog3D::Entity *BuildFXElement(  btVector3 &initialPosition, Dog3D::ExplodableComponent::ExplosionType elementType );
	
	static Dog3D::Entity *BuildFXElement(  btVector3 &initialPosition, btVector3 &extents, 
										 NSString *spriteSheet, int nTilesHigh, int nTilesWide, 
										 int nTiles,bool renderInPreQueue = false);

	static Dog3D::Entity *BuildFXCircularCollider(  btVector3 &initialPosition, btVector3 &extents, 
										 NSString *spriteSheet, int nTilesHigh, int nTilesWide, 
										 int nTiles);
	
	static Dog3D::Entity *BuildSprite( btVector3 &initialPosition, float w, float h, NSString *spriteName,  Dog3D::GraphicsManager::RenderQueueOrder order=Dog3D::GraphicsManager::MID);

	static Dog3D::Entity *BuildScreenSpaceSprite( btVector3 &initialPosition, float w, float h, NSString *spriteName, float duration);
	
};
