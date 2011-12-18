/*
 *  DrawableFactory.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <cmath>
#import <string>

#import "VectorMath.h"

#import "GraphicsComponent.h"
#import "GraphicsComponentFactory.h"
#import "GraphicsManager.h"


using namespace Dog3D;
using namespace std;

GraphicsComponent* GraphicsComponentFactory::BuildReticule(float scale)
{
	
	GraphicsComponent *graphicsComponent = new LineComponent();
	const CoordinateSet *coordSet = GraphicsManager::Instance()->GetLineCoordinateSet();
	
	graphicsComponent->SetScale(scale);
	
	graphicsComponent->SetVertices(coordSet->mVertices, coordSet->mVertexCount);
	graphicsComponent->SetNormals(coordSet->mNormals);
	graphicsComponent->SetColors(coordSet->mColors);
	
	return graphicsComponent;
	
}


GraphicsComponent* GraphicsComponentFactory::BuildSphere(float radius, NSString *texture)
{
	
	GraphicsComponent *graphicsComponent = new GraphicsComponent();
	const CoordinateSet *sphereSet = GraphicsManager::Instance()->GetSphereCoordinateSet();
	
	graphicsComponent->SetScale(radius);
	
	graphicsComponent->SetVertices(sphereSet->mVertices, sphereSet->mVertexCount);
	graphicsComponent->SetNormals(sphereSet->mNormals);
	graphicsComponent->SetColors(sphereSet->mColors);
	
	if(texture)
	{
		graphicsComponent->SetTexCoords(sphereSet->mTexCoords);	
		graphicsComponent->SetTexture(GraphicsManager::Instance()->GetTexture(texture));
	}
	
	return graphicsComponent;

}

AnimatedGraphicsComponent* GraphicsComponentFactory::BuildGopher(float width,  float height)
{
	AnimatedGraphicsComponent *graphicsComponent = new AnimatedGraphicsComponent(width, height);
    
	int count= 4;
	Vec3 *vertices = new Vec3[ count ];
	Vec3 *bigVertices = new Vec3[ count];
	Vec3 *normals =  new Vec3[ count ];
	Color *colors =  new Color[ count ];
    
	vertices[0].setValue( -width/2.0, 0, height/2.0 );
	vertices[1].setValue(width/2.0, 0, height/2.0);
	vertices[2].setValue(-width/2.0, 0, -height/2.0);
	vertices[3].setValue(width/2.0, 0, -height/2.0);
    
	bigVertices[0].setValue( -width*0.75, 0, height*0.75);
	bigVertices[1].setValue(width*0.75, 0, height*0.75);
	bigVertices[2].setValue(-width*0.75, 0, -height*0.75);
	bigVertices[3].setValue(width*0.75, 0, -height*0.75);
	
	normals[0].setValue(0,1,0);
	normals[1].setValue(0,1,0);
	normals[2].setValue(0,1,0);
	normals[3].setValue(0,1,0);
	
	colors[0] = Color(1.0, 1.0, 1.0, 1.0);
	colors[1] = Color(1.0, 1.0, 1.0, 1.0);
	colors[2] = Color(1.0, 1.0, 1.0, 1.0);
	colors[3] = Color(1.0, 1.0, 1.0, 1.0);	
    
	graphicsComponent->SetVertices(vertices, count);
	graphicsComponent->SetNormals(normals);
	graphicsComponent->SetColors(colors);
	graphicsComponent->SetBigVertices(bigVertices);
	
	const float kWalkFPS = 1.0/60.0;
	
	{
		Texture2D *idleTexture = GraphicsManager::Instance()->GetTexture(@"idle.sheet");
		SpriteAnimation *idleAnimation = new SpriteAnimation();
		idleAnimation->mTileWidth = 8;
		idleAnimation->mTileHeight = 16;
		idleAnimation->mTileCount = 90;
		idleAnimation->mTileIndex = 0;
		idleAnimation->mSpriteSheet = idleTexture;
		graphicsComponent->AddAnimation(idleAnimation, (int) AnimatedGraphicsComponent::IDLE);
	}
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"walk_forward.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_FORWARD);
	}
	
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"walk_forward_left.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_FORWARD_LEFT);
	}
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"walk_left.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_LEFT);
	}
	
	
	{
		Texture2D *spriteTexture =  GraphicsManager::Instance()->GetTexture(@"walk_back_left.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_BACK_LEFT);
	}
	
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"walk_back.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_BACK);
	}
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"blowup.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::BLOWUP_FORWARD);
	}
    
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"blowup.left.sheet");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::BLOWUP_LEFT);
	}
    /*
     {
     Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"jump.in.sheet");
     SpriteAnimation *spriteAnimation = new SpriteAnimation(false, false);
     spriteAnimation->mTileWidth = 8;
     spriteAnimation->mTileHeight = 8;
     spriteAnimation->mTileCount = 61;
     spriteAnimation->mTileIndex = 0;
     spriteAnimation->mSpriteSheet = spriteTexture;
     graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::SPAWN_IN);
     }*/
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"jump_down.sheet" );
		SpriteAnimation *spriteAnimation = new SpriteAnimation(false, false);
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 28;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::JUMP_DOWN_HOLE);
	}
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"EatCarrot.sheet");
		SpriteAnimation *anim = new SpriteAnimation(false, false);
		anim->mTileWidth = 8;
		anim->mTileHeight = 16;
		anim->mTileCount = 121;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::EAT_CARROT);
	}
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"Dance.sheet");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 8;
		anim->mTileHeight = 8;
		anim->mTileCount = 8*5;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::WIN_DANCE);
	}
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"taunt.sheet");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 8;
		anim->mTileHeight = 16;
		anim->mTileCount = 91;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::TAUNT);
	}
	
	/*{
     Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"freeze.sheet");
     SpriteAnimation *anim = new SpriteAnimation();
     anim->mTileWidth = 8;
     anim->mTileHeight = 4;
     anim->mTileCount = 30;
     anim->mTileIndex = 0;
     anim->mSpriteSheet = texture;
     anim->mLoopAnimation = true;
     anim->mPlayBigVertices = true;
     
     graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::FREEZE);
     }*/
	
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"fire.sheet");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 8;
		anim->mTileHeight = 8;
		anim->mTileCount = 45;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		anim->mLoopAnimation = true;
		anim->mPlayBigVertices = true;
		
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::FIRE);
	}
    
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"electro.sheet");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 8;
		anim->mTileHeight = 4;
		anim->mTileCount = 32;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		anim->mLoopAnimation = true;
		anim->mPlayBigVertices = true;
		
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::ELECTRO);
	}
	
	
	return graphicsComponent;		
	
}


// custom 12 tile anim
FXGraphicsComponent* GraphicsComponentFactory::BuildFXExplosion(float width,  float height)
{
	FXGraphicsComponent *graphicsComponent = new FXGraphicsComponent(width, height);
	
	int count= 4;
	Vec3 *vertices = new Vec3[ count ];
	Vec3 *normals =  new Vec3[ count ];
	Color *colors =  new Color[ count ];
	
	vertices[0].setValue( -width/2.0, 0, height/2.0 );
	vertices[1].setValue(width/2.0, 0, height/2.0);
	vertices[2].setValue(-width/2.0, 0, -height/2.0);
	vertices[3].setValue(width/2.0, 0, -height/2.0);
	
	normals[0].setValue(0,1,0);
	normals[1].setValue(0,1,0);
	normals[2].setValue(0,1,0);
	normals[3].setValue(0,1,0);
	
	colors[0] = Color(1.0, 1.0, 1.0, 1.0);
	colors[1] = Color(1.0, 1.0, 1.0, 1.0);
	colors[2] = Color(1.0, 1.0, 1.0, 1.0);
	colors[3] = Color(1.0, 1.0, 1.0, 1.0);	
	
	graphicsComponent->SetVertices(vertices, count);
	graphicsComponent->SetNormals(normals);
	graphicsComponent->SetColors(colors);
	{
		int error = glGetError();
		if(error != 0)
		{
			DLog(@"GL Error still %d", error);
		}
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"ball.smokeExplode.sheet");
		SpriteAnimation *animation = new SpriteAnimation();
		animation->mTileWidth = 4;
		animation->mTileHeight = 4;
		animation->mTileCount = 12;
		animation->mTileIndex = 0;
		animation->mSpriteSheet = texture;
		animation->mFrameDuration = 1.0/15.0;
		
		// note, this is an explosion - only play IDLE/default anim
		graphicsComponent->AddAnimation(animation, (int) AnimatedGraphicsComponent::IDLE);
	}
	return graphicsComponent;
}

// custom 12 tile anim
FXGraphicsComponent* GraphicsComponentFactory::BuildFXElement(float width,  float height, NSString *effect, 
															  int nTilesWide, int nTilesHigh,
															  int nTiles, bool loopAnim, float frameDuration)
{
	FXGraphicsComponent *graphicsComponent = new FXGraphicsComponent(width, height);
	
	int count= 4;
	Vec3 *vertices = new Vec3[ count ];
	Vec3 *normals =  new Vec3[ count ];
	Color *colors =  new Color[ count ];
	
	vertices[0].setValue( -width/2.0, 0, height/2.0 );
	vertices[1].setValue(width/2.0, 0, height/2.0);
	vertices[2].setValue(-width/2.0, 0, -height/2.0);
	vertices[3].setValue(width/2.0, 0, -height/2.0);
	
	normals[0].setValue(0,1,0);
	normals[1].setValue(0,1,0);
	normals[2].setValue(0,1,0);
	normals[3].setValue(0,1,0);
	
	colors[0] = Color(1.0, 1.0, 1.0, 1.0);
	colors[1] = Color(1.0, 1.0, 1.0, 1.0);
	colors[2] = Color(1.0, 1.0, 1.0, 1.0);
	colors[3] = Color(1.0, 1.0, 1.0, 1.0);	
	
	graphicsComponent->SetVertices(vertices, count);
	graphicsComponent->SetNormals(normals);
	graphicsComponent->SetColors(colors);
	{
		int error = glGetError();
		if(error != 0)
		{
			DLog(@"GL Error still %d", error);
		}
		
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(effect);
		SpriteAnimation *animation = new SpriteAnimation();
		animation->mTileWidth = nTilesWide;
		animation->mTileHeight = nTilesHigh;
		animation->mTileCount = nTiles;
		animation->mTileIndex = 0;
		animation->mSpriteSheet = texture;
		animation->mFrameDuration = frameDuration;
		animation->mLoopAnimation = loopAnim;
		
		// note, this is an explosion - only play IDLE/default anim
		graphicsComponent->AddAnimation(animation, (int) AnimatedGraphicsComponent::IDLE);
	}
	return graphicsComponent;
}

// custom 12 tile anim
BillBoard* GraphicsComponentFactory::BuildBillBoardElement(float width,  float height, NSString *effect, 
																	 int nTilesWide, int nTilesHigh, int nTiles, float offsetLength)
{
	BillBoard *graphicsComponent = new BillBoard(width, height);
	
	int count= 4;
	Vec3 *vertices = new Vec3[ count ];
	Vec3 *normals =  new Vec3[ count ];
	Color *colors =  new Color[ count ];
	
	vertices[0].setValue( -width/2.0, 0, height/2.0 );
	vertices[1].setValue(width/2.0, 0, height/2.0);
	vertices[2].setValue(-width/2.0, 0, -height/2.0);
	vertices[3].setValue(width/2.0, 0, -height/2.0);
	
	normals[0].setValue(0,1,0);
	normals[1].setValue(0,1,0);
	normals[2].setValue(0,1,0);
	normals[3].setValue(0,1,0);
	
	colors[0] = Color(1.0, 1.0, 1.0, 1.0);
	colors[1] = Color(1.0, 1.0, 1.0, 1.0);
	colors[2] = Color(1.0, 1.0, 1.0, 1.0);
	colors[3] = Color(1.0, 1.0, 1.0, 1.0);	
	
	graphicsComponent->SetVertices(vertices, count);
	graphicsComponent->SetNormals(normals);
	graphicsComponent->SetColors(colors);
	{
		int error = glGetError();
		if(error != 0)
		{
			DLog(@"GL Error still %d", error);
		}
		
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(effect);
		SpriteAnimation *animation = new SpriteAnimation();
		animation->mTileWidth = nTilesWide;
		animation->mTileHeight = nTilesHigh;
		animation->mTileCount = nTiles;
		animation->mTileIndex = 0;
		animation->mSpriteSheet = texture;
		animation->mFrameDuration = 1.0/15.0;
		animation->mLoopAnimation = true;
		
		// note, this is an explosion - only play IDLE/default anim
		graphicsComponent->AddAnimation(animation, (int) AnimatedGraphicsComponent::IDLE);
		
	}
	
	graphicsComponent->SetOffset(btVector3(0,offsetLength,0));
	
	return graphicsComponent;
}

// custom 12 tile anim
HoldLastAnim* GraphicsComponentFactory::BuildHoldLastAnim(
										float width,  
										float height,
										NSString *effect, 
										int nTiles)
{
	HoldLastAnim *graphicsComponent = new HoldLastAnim(width, height);
	
	int count= 4;
	Vec3 *vertices = new Vec3[ count ];
	Vec3 *normals =  new Vec3[ count ];
	Color *colors =  new Color[ count ];
	
	vertices[0].setValue( -width/2.0, 0, height/2.0 );
	vertices[1].setValue(width/2.0, 0, height/2.0);
	vertices[2].setValue(-width/2.0, 0, -height/2.0);
	vertices[3].setValue(width/2.0, 0, -height/2.0);
	
	normals[0].setValue(0,1,0);
	normals[1].setValue(0,1,0);
	normals[2].setValue(0,1,0);
	normals[3].setValue(0,1,0);
	
	colors[0] = Color(1.0, 1.0, 1.0, 1.0);
	colors[1] = Color(1.0, 1.0, 1.0, 1.0);
	colors[2] = Color(1.0, 1.0, 1.0, 1.0);
	colors[3] = Color(1.0, 1.0, 1.0, 1.0);	
	
	graphicsComponent->SetVertices(vertices, count);
	graphicsComponent->SetNormals(normals);
	graphicsComponent->SetColors(colors);
	{
		int error = glGetError();
		if(error != 0)
		{
			DLog(@"GL Error still %d", error);
		}
		
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(effect);
		SpriteAnimation *animation = new SpriteAnimation();
		animation->mTileWidth = 4;
		animation->mTileHeight = 4;
		animation->mTileCount = nTiles;
		///// START ANIM AT LAST FRAME ////
		animation->mTileIndex = nTiles-1;
		animation->mSpriteSheet = texture;
		animation->mFrameDuration = 1.0/15.0;
		animation->mLoopAnimation = false;
		
		// note, this is an explosion - only play IDLE/default anim
		graphicsComponent->AddAnimation(animation, (int) AnimatedGraphicsComponent::IDLE);
	}
	return graphicsComponent;
}

HUDGraphicsComponent* GraphicsComponentFactory::BuildHUD(btVector3& extents, float widthSpacing, int nGopherLives, bool alignLeft, NSString *textureName)
{
	// load a gopher texture
	// TODO - gopher, not carrot
	Texture2D *tex = [[[Texture2D alloc] initWithImagePath:[[NSBundle mainBundle] pathForResource:textureName ofType:@"png"]] retain];
	
	HUDGraphicsComponent *hud = new HUDGraphicsComponent(tex, extents, widthSpacing, nGopherLives, alignLeft);
	
	return hud;
}

GraphicsComponent* GraphicsComponentFactory::BuildSprite(float width, float height, NSString *textureName)
{
	SquareTexturedGraphicsComponent *graphicsComponent = new SquareTexturedGraphicsComponent(width,  height);
	
	//caches 
	Texture2D *tex = GraphicsManager::Instance()->GetTexture(textureName);
	
	graphicsComponent->SetTexture(tex);
	
	return graphicsComponent;	
}

GraphicsComponent* GraphicsComponentFactory::BuildScreenSpaceSprite(float width, 
																	float height, 
																	NSString *textureName, 
																	btVector3 screenOffset, 
																	float duration)
{
	ScreenSpaceComponent *graphicsComponent = new ScreenSpaceComponent(width,  height, screenOffset, duration);
	
	//caches 
	Texture2D *tex = GraphicsManager::Instance()->GetTexture(textureName);
	
	graphicsComponent->SetTexture(tex);
	
	return graphicsComponent;	
}

GraphicsComponent* GraphicsComponentFactory::BuildGroundPlane(float width, float height, const string *backgroundTexture)
{
	TexturedGraphicsComponent *graphicsComponent = new TexturedGraphicsComponent(width, height);
	
	//  = [[[Texture2D alloc] initWithImagePath:[[NSBundle mainBundle] pathForResource:backgroundTexture ofType:@"png"]] retain];
	
	//allows caching of textures
	Texture2D* tex = GraphicsManager::Instance()->GetTexture(backgroundTexture);
	
	// prevents multiple loading of background
	GraphicsManager::Instance()->MarkAsSceneTexture(backgroundTexture);
	
	graphicsComponent->SetTexture(tex);

	int count= 4;
	Vec3 *vertices = new Vec3[ count ];
	Vec3 *normals =  new Vec3[ count ];
	Color *colors =  new Color[ count ];
	
	vertices[0].setValue( -width/2.0, 0, height/2.0 );
	vertices[1].setValue(width/2.0, 0, height/2.0);
	vertices[2].setValue(-width/2.0, 0, -height/2.0);
	vertices[3].setValue(width/2.0, 0, -height/2.0);
	
	normals[0].setValue(0,1,0);
	normals[1].setValue(0,1,0);
	normals[2].setValue(0,1,0);
	normals[3].setValue(0,1,0);
	
	colors[0] = Color(1.0, 1.0, 1.0, 1.0);
	colors[1] = Color(1.0, 1.0, 1.0, 1.0);
	colors[2] = Color(1.0, 1.0, 1.0, 1.0);
	colors[3] = Color(1.0, 1.0, 1.0, 1.0);	
	
	graphicsComponent->SetVertices(vertices, count);
	graphicsComponent->SetNormals(normals);
	graphicsComponent->SetColors(colors);
	
	return graphicsComponent;
	
}


GraphicsComponent* GraphicsComponentFactory::BuildBox(btVector3 &halfExtents, Texture2D *texture)
{
	
	GraphicsComponent *graphicsComponent = new GraphicsComponent();	
	const CoordinateSet *boxSet = GraphicsManager::Instance()->GetBoxCoordinateSet();
	
	btVector3 scale(halfExtents);
	scale *= 2.0f;
	
	graphicsComponent->SetScale(scale);
	
	graphicsComponent->SetVertices(boxSet->mVertices, boxSet->mVertexCount);
	graphicsComponent->SetNormals(boxSet->mNormals);
	graphicsComponent->SetColors(boxSet->mColors);
	
	if(texture)
	{
		graphicsComponent->SetTexCoords(boxSet->mTexCoords);	
		graphicsComponent->SetTexture(texture);
	}
	
	return graphicsComponent;
}


