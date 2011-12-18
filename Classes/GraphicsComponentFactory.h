/*
 *  DrawableFactory.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */
#import "GraphicsComponent.h"

namespace Dog3D
{

	class GraphicsComponentFactory
	{
	public:
		
		static GraphicsComponent* BuildReticule(float scale);
		
		static GraphicsComponent* BuildSphere(float radius, NSString *ballTexture);
		
		static AnimatedGraphicsComponent* BuildGopher(float width, float height);
        
		static AnimatedGraphicsComponent* BuildBunny(float width, float height);
		
		static AnimatedGraphicsComponent* BuildSqu(float width,  float height);
		
		
		static GraphicsComponent* BuildGroundPlane(float width, float height, const std::string *backgroundTexture);
		static GraphicsComponent* BuildBox(btVector3 &halfExtents, Texture2D *texture=NULL);
		
		static FXGraphicsComponent* BuildFXExplosion(float width,  float height);
		static FXGraphicsComponent* BuildFXElement(float width,  float height, NSString *effect, 
												   int nTilesWide, int nTilesHigh, int nTiles, bool loopAnim = false, float frameDuration=1.0/15.0);

		static BillBoard* BuildBillBoardElement(float width,  float height, NSString *effect, 
												int nTilesWide, int nTilesHigh, int nTiles,
												float offsetLength);
		
		static GraphicsComponent* BuildSprite(float width, float height, NSString *textureName);
		
		static GraphicsComponent* BuildScreenSpaceSprite(float width, 
														 float height, 
														 NSString *textureName, 
														 btVector3 screenOffset, 
														 float duration);		
		
		static HUDGraphicsComponent* BuildHUD(btVector3& extents, float widthSpacing, int nGopherLives, 
											  bool alignLeft, NSString *textureName);
	
		static HoldLastAnim* BuildHoldLastAnim(float width, float height, NSString *effect, int nTiles);

	};
	
}