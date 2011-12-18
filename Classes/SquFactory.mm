/*
 *  SquFactory.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/7/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
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

AnimatedGraphicsComponent* GraphicsComponentFactory::BuildSqu(float width,  float height)
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
		Texture2D *idleTexture = GraphicsManager::Instance()->GetTexture(@"Squ_Idle");
		SpriteAnimation *idleAnimation = new SpriteAnimation();
		idleAnimation->mTileWidth = 16;
		idleAnimation->mTileHeight = 8;
		idleAnimation->mTileCount = 90;
		idleAnimation->mTileIndex = 0;
		idleAnimation->mSpriteSheet = idleTexture;
		graphicsComponent->AddAnimation(idleAnimation, (int) AnimatedGraphicsComponent::IDLE);
	}
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_walk");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 30;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_FORWARD);
	}
	
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_WalkForwardLeft");
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
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_Walk_Left");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 30;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_LEFT);
	}
	
	
	{
		Texture2D *spriteTexture =  GraphicsManager::Instance()->GetTexture(@"Squ_WalkbackLeft");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 30;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_BACK_LEFT);
	}
	
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_WalkBack");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 30;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mFrameDuration = kWalkFPS;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::WALK_BACK);
	}
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_BlowupSpin");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 30;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::BLOWUP_FORWARD);
	}
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_BlowupSpin");
		SpriteAnimation *spriteAnimation = new SpriteAnimation();
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 29;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::BLOWUP_LEFT);
	}
	
	{
		Texture2D *spriteTexture = GraphicsManager::Instance()->GetTexture(@"Squ_JumpDownHole" );
		SpriteAnimation *spriteAnimation = new SpriteAnimation(false, false);
		spriteAnimation->mTileWidth = 8;
		spriteAnimation->mTileHeight = 4;
		spriteAnimation->mTileCount = 28;
		spriteAnimation->mTileIndex = 0;
		spriteAnimation->mSpriteSheet = spriteTexture;
		graphicsComponent->AddAnimation(spriteAnimation, (int) AnimatedGraphicsComponent::JUMP_DOWN_HOLE);
	}
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"Squ_EatCarrot");
		SpriteAnimation *anim = new SpriteAnimation(false, false);
		anim->mTileWidth = 16;
		anim->mTileHeight = 8;
		anim->mTileCount = 121;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::EAT_CARROT);
	}
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"Squ_Dance");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 8;
		anim->mTileHeight = 8;
		anim->mTileCount = 8*5;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::WIN_DANCE);
	}
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"Squ_Taunt");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 16;
		anim->mTileHeight = 8;
		anim->mTileCount = 91;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::TAUNT);
	}	
	
	{
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"Squ_Burn");
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
		Texture2D *texture = GraphicsManager::Instance()->GetTexture(@"Squ_Electricude");
		SpriteAnimation *anim = new SpriteAnimation();
		anim->mTileWidth = 8;
		anim->mTileHeight = 8;
		anim->mTileCount = 61;
		anim->mTileIndex = 0;
		anim->mSpriteSheet = texture;
		anim->mLoopAnimation = true;
		anim->mPlayBigVertices = true;
		
		graphicsComponent->AddAnimation(anim, (int) AnimatedGraphicsComponent::ELECTRO);
	}
	
	
	return graphicsComponent;		
	
}
