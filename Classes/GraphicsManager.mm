/*
 *  GraphicsManager.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>
#import <vector>
#import <algorithm>
#import <queue>
#import <list>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "FakeGLU.h"
#import "Entity.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"
#import "GamePlayManager.h"
#import "PhysicsComponent.h"
#import "GameEntityFactory.h"

using namespace std;

//#define USE_LIGHTS 1

namespace Dog3D
{
	typedef list<GraphicsComponent*>::iterator  GraphicsComponentIterator; 
	typedef list<FXGraphicsComponent*>::iterator  FXComponentIterator; 
	
	GraphicsManager * GraphicsManager::sGraphicsManager;
	
	GraphicsManager::GraphicsManager() : mIdle(true), 
#if DEBUG
	mShowDebug(false), 
#endif
	mGraphics3D(false),
	mBoxCoordinateSet(NULL),
	mSphereCoordinateSet(NULL),
	mLineCoordinateSet(NULL)
	{
		// load gfx textures
	}
	
	void GraphicsManager::Initialize()
	{
		sGraphicsManager = new GraphicsManager();
		sGraphicsManager->mTrackVelocity.setValue(0, 0, 1);
	
		sGraphicsManager->InitializeTextures();
		sGraphicsManager->InitializeCoordinateSets();
		
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_DEPTH_WRITEMASK);
		glEnable(GL_CULL_FACE);
	}
	
	void GraphicsManager::InitializeTextures()
	{
		LoadTexture(@"idle.sheet");
		LoadTexture(@"walk_forward.sheet");
		LoadTexture(@"walk_forward_left.sheet");
		LoadTexture(@"walk_left.sheet");
		LoadTexture(@"walk_back_left.sheet");
		LoadTexture(@"walk_back.sheet");
		LoadTexture(@"fire.sheet");
		LoadTexture(@"blowup.sheet");
		LoadTexture(@"blowup.left.sheet");
		LoadTexture(@"jump_down.sheet");
		LoadTexture(@"EatCarrot.sheet");
		LoadTexture(@"Dance.sheet");
		LoadTexture(@"taunt.sheet");
		LoadTexture(@"Ball_Fire");
		LoadTexture(@"Ball_Bomb");
		LoadTexture(@"Ball_Electric");
		//LoadTexture(@"Ball_Ice");
		LoadTexture(@"Explode.sheet");
		LoadTexture(@"pot1");
		LoadTexture(@"hedge1");
		LoadTexture(@"GreenBack");
		LoadTexture(@"flower.sheet");
	}
	
	void GraphicsManager::Unload()
	{
		mPreRenderQueue.clear();
		mMidRenderQueue.clear();
		mPostRenderQueue.clear();
		
		mPreFXComponents.clear();
		mPostFXComponents.clear();
		
		// managed by scene mgr
		if(mFXPool)
		{ 
			mFXPool = NULL;
		}
		
		for(std::list<ScreenSpaceComponent *>::iterator it = mSSComponents.begin(); it != mSSComponents.end(); it++)
		{
			delete (*it);
		}
		mSSComponents.clear();
		
	}
	
	void GraphicsManager::MarkAsSceneTexture( const std::string *textureName)
	{
		// check for already cached texture
		// prevents large texture reload
		for(std::list<std::string>::iterator it = mSceneTextures.begin(); it != mSceneTextures.end(); it++)
		{
			if((*textureName) == (*it))
			{
				return;
			}
			
		}
		
		mSceneTextures.push_back(*textureName);
		
		if(mSceneTextures.size() > kMaxSceneTextures)
		{
			string textureToEvict = mSceneTextures.front();
			
			map<string, Texture2D*>::iterator it = mTextures.find(textureToEvict);
			if(it != mTextures.end())
			{
				[it->second release];
				mTextures.erase(it);
			}
		}
	}
	
	void GraphicsManager::InitializeCoordinateSets()
	{
		mBoxCoordinateSet = new CoordinateSet(36);
		InitializeBoxCoordinateSet(mBoxCoordinateSet);
		
		mSphereCoordinateSet = new CoordinateSet(600);
		InitializeSphereCoordinateSet(mSphereCoordinateSet);
		
		mLineCoordinateSet = new CoordinateSet(2);
		InitializeLineCoordinateSet(mLineCoordinateSet);
		
	}
	
	
	void GraphicsManager::RemoveComponent( GraphicsComponent *component)
	{
#if DEBUG
		DLog(@"GFX Removing %s", component->GetParent()->mDebugName.c_str());
#endif
		mMidRenderQueue.remove(component);
		//GraphicsComponentIterator it = std::find(mMidRenderQueue.begin(), mMidRenderQueue.end(), component);
		//mMidRenderQueue.erase(it);
	}	
	
	void GraphicsManager::Update(float deltaTime)
	{		
		// TODO fix face culling and direction mojo
		glDisable(GL_CULL_FACE);
			
		// draws pre graphics components
		for(GraphicsComponentIterator it = mPreRenderQueue.begin(); it != mPreRenderQueue.end(); it++)
		{
			GraphicsComponent *comp = (*it);
			comp->Update(deltaTime, mGraphics3D);
		}
		
		for(FXComponentIterator it = mPreFXComponents.begin(); it != mPreFXComponents.end(); it++)
		{
			FXGraphicsComponent *fx = *it;
			// do not deque looping anims
			if( fx->LastFrame() && ! (fx->IsLooping()))
			{
				// allows triggered activation
				GraphicsComponent *triggered = fx->mTriggeredComponent;
				if(triggered != NULL)
				{
					triggered->mActive = true;
				}
				
				it = mPreFXComponents.erase(it);
			}
			else 
			{
				fx->Update(deltaTime, mGraphics3D);
			}
		}
		
		// draws mid queue graphics components
		for(GraphicsComponentIterator it = mMidRenderQueue.begin(); it != mMidRenderQueue.end(); it++)
		{
			GraphicsComponent *comp = (*it);
			comp->Update(deltaTime, mGraphics3D);
		}
		
		// draws post queue graphics components
		for(GraphicsComponentIterator it = mPostRenderQueue.begin(); it != mPostRenderQueue.end(); it++)
		{
			GraphicsComponent *comp = (*it);
			comp->Update(deltaTime, mGraphics3D);
		}
		
		// post FX queue
		for(FXComponentIterator it = mPostFXComponents.begin(); it != mPostFXComponents.end(); it++)
		{
			FXGraphicsComponent *fx = *it;
			// do not deque looping anims
			if( fx->LastFrame() && ! (fx->IsLooping()))
			{
				// allows triggered activation
				GraphicsComponent *triggered = fx->mTriggeredComponent;
				if(triggered != NULL)
				{
					triggered->mActive = true;
				}
				
				it = mPostFXComponents.erase(it);
			}
			else 
			{
				fx->Update(deltaTime, mGraphics3D);
			}
		}
				
		// screen space queue goes last
		for(list<ScreenSpaceComponent *>::iterator it = mSSComponents.begin(); it != mSSComponents.end(); it++)
		{
			if((*it)->IsFinished())
			{
				//toRemove.push_back(*it);
				delete (*it);
				it = mSSComponents.erase(it);
				
			}
			else {
				(*it)->Update(deltaTime, mGraphics3D);
			}
		}
		
		
#if DEBUG
		if(mShowDebug)
		{
			GamePlayManager::Instance()->DrawDebugLines();
		}
		
		while(!mDebugLinePairs.empty())
		{
			btVector3 a = mDebugLinePairs.front();
			mDebugLinePairs.pop();
			btVector3 b = mDebugLinePairs.front();
			mDebugLinePairs.pop();
			
			DrawLine(a,b);
			
		}
		
		//queue<btVector3> newQueue;
		
		while(!mDebugSquares.empty())
		{
			btVector3 a = mDebugSquares.front();
			mDebugSquares.pop();
			btVector3 b = mDebugSquares.front();
			mDebugSquares.pop();
			
			//newQueue.push(a);
			//newQueue.push(b);
			
			DrawSquare(a,b);
			
		}
		
		while(!mDebugCircles.empty())
		{
			btVector3 a = mDebugCircles.front();
			mDebugCircles.pop();
			btVector3 b = mDebugCircles.front();
			mDebugCircles.pop();
			
			//newQueue.push(a);
			//newQueue.push(b);
			
			DrawCircle(a,b);
			
		}		
		
#endif
	}
	
#pragma mark CAMERA SETUP
	
	void GraphicsManager::OrthoViewSetup(int backingWidth, int backingHeight, float zEye)
	{
		
		GLfloat light_ambient[] = { 2, 2, 2, 1.0 };
		GLfloat light_diffuse[] = { 0.5, 0.5, 0.5, 1.0 };
		GLfloat light_specular[] = { 0.5, 0.5, 0.5, 1.0 };
		GLfloat light_position[] = { 0.0, 10.0, 0.0, 0.0 };
		
		glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
		glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
		glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
		glLightfv(GL_LIGHT0, GL_POSITION, light_position);
		
		//	glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0.0);
		
#if USE_LIGHTS
		glShadeModel(GL_SMOOTH);
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
#else
		glDisable(GL_LIGHTING);
#endif
		
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity(); 
		glViewport(0, 0, backingWidth, backingHeight);

		
		float nearClip = 0.5;
		float farClip = 80;
		glOrthof(-10, 10, -15, 15, nearClip, farClip);
		
		glMatrixMode(GL_MODELVIEW); 
		glLoadIdentity(); 
		gluLookAt(0, zEye, 0, 
				  0.0, 0.0, 0.0, 
				  0.0, 0.0, 1.0);

		
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnable(GL_TEXTURE_2D);		
		
		
	}
	
	void GraphicsManager::OrthoViewCleanUp()
	{
		glDisable(GL_TEXTURE_2D);
	}
	

	void GraphicsManager::SetupLights()
	{
		
#ifdef USE_LIGHTS	
		GLfloat light_ambient[] = { 2, 2, 2, 1.0 };
		GLfloat light_diffuse[] = { 0.5, 0.5, 0.5, 1.0 };
		GLfloat light_specular[] = { 0.5, 0.5, 0.5, 1.0 };
		GLfloat light_position[] = { 0.0, 10.0, 0.0, 0.0 };
		
		glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
		glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
		glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
		glLightfv(GL_LIGHT0, GL_POSITION, light_position);
		
		glShadeModel(GL_SMOOTH);
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
#else
		// tmp purple
		glColor4f(0.8,0,0.8,1);
#endif
		
	}
	
	void GraphicsManager::SetupView(float backingWidth, float backingHeight, float zEye)
	{
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity(); 
		glViewport(0, 0, backingWidth, backingHeight);
				
		//double fovy = 2.0 * atan(size.height/(2.0*zEye)) * 180.0 / PI;
		//double aspect = 10.0/15.0;
		
		
		//persp vs. ortho
		if(mGraphics3D)
		{
			gluPerspective(45, 1.0/1.5, 1, 100);
		}
		else
		{
			float nearClip = 0.5;
			float farClip = 80;
			glOrthof(-10, 10, -15, 15, nearClip, farClip);
			//double fovy = 2.0 * atan(30.0/(2.0*zEye)) * 180.0 / PI;
			//gluPerspective(fovy, 1.0/1.5, nearClip, farClip);
		}
		
		glMatrixMode(GL_MODELVIEW); 
		glLoadIdentity(); 
		
		btVector3 focalPoint;
		GamePlayManager::Instance()->GetFocalPoint(focalPoint);
		
		if(mGraphics3D)	
		{
			gluLookAt(zEye*0.67f + focalPoint.x(), zEye * 0.33f , focalPoint.z(), 
				  focalPoint.x(), 2.0, focalPoint.z(), 
				  0.0, 0.0, 1.0);
		}
		else 
		{
			gluLookAt(focalPoint.x(), zEye, focalPoint.z(), 
				  focalPoint.x(), 0.0, focalPoint.z(), 
				  0.0, 0.0, 1.0);
		}
		
	}
	
	void GraphicsManager::InitializeSphereCoordinateSet( CoordinateSet *coordSet)
	{		
		Vec3 *vertices = coordSet->mVertices;
		Vec3 *normals = coordSet->mNormals;
		Color *colors = coordSet->mColors;
		Vec2 *texCoords = coordSet->mTexCoords;
		
		int rings = 10; 
		int slices = 10;
		
		
		float theta = 0.0, phi = 0.0;
		float dTheta = PI / (float)(rings);
		float dPhi = 2.0*PI / (float)(slices);
		
		int i, j;
		
		int n = 0;
		int c = 0;
		
		float dS =  1.0/((float) rings);
		float dT = 1.0/((float) slices);
		
		float s = 0;
		
		const float radius = 1.0f;
		
		for (i = 0; i < rings; i++)
		{
			float t = 0;
			
			for (j = 0; j < slices; j++)
			{
				// create two triangles
				
				normals[n].setValue(cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi));
				
				texCoords[n] = Vec2(s,t);
				vertices[n] = normals[n];
				vertices[n++] *= radius;
				
				
				normals[n] = Vec3(cos(theta+dTheta)*sin(phi+dPhi), sin(theta+dTheta)*sin(phi+dPhi), cos(phi+dPhi));
				texCoords[n] = Vec2(s+dS,t+dT);
				vertices[n] = normals[n];
				vertices[n++] *= radius;
				
				normals[n] = Vec3(cos(theta)*sin(phi+dPhi), sin(theta)*sin(phi+dPhi), cos(phi+dPhi));
				texCoords[n] = Vec2(s,t+dT);
				vertices[n] = normals[n];
				vertices[n++] *= radius;
				
				normals[n] = Vec3(cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi));
				texCoords[n] = Vec2(s,t);
				vertices[n] = normals[n];
				vertices[n++] *= radius;
				
				normals[n] = Vec3(cos(theta+dTheta)*sin(phi), sin(theta+dTheta)*sin(phi), cos(phi));
				texCoords[n] = Vec2(s+dT,t);
				vertices[n] = normals[n];
				vertices[n++] *= radius;
				
				normals[n] = Vec3(cos(theta+dTheta)*sin(phi+dPhi), sin(theta+dTheta)*sin(phi+dPhi), cos(phi+dPhi));
				texCoords[n] = Vec2(s+dS,t+dT);
				vertices[n] = normals[n];
				vertices[n++] *= radius;
				
				
				phi += dPhi;
				t += dT;
				
				colors[c++] = Color(1.0, 1.0, 1.0, 1.0);
				colors[c++] = Color(1.0, 1.0, 1.0, 1.0);
				colors[c++] = Color(1.0, 1.0, 1.0, 1.0);
				colors[c++] = Color(1.0, 1.0, 1.0, 1.0);
				colors[c++] = Color(1.0, 1.0, 1.0, 1.0);
				colors[c++] = Color(1.0, 1.0, 1.0, 1.0);
				
			}
			
			theta += dTheta;
			s += dS;
		}
		
	}
	
	void GraphicsManager::InitializeBoxCoordinateSet( CoordinateSet *coordSet)
	{
		// 0,1     1,1
		//	+-------+
		//  | \     |
		//  |   \   |
		//  |     \ |
		//  +-------+
		// 0,0     1,0
		
		Vec3 *vertices = coordSet->mVertices;
		Vec3 *normals = coordSet->mNormals;
		Color *colors = coordSet->mColors;
		Vec2 *texCoords = coordSet->mTexCoords;
		
		//////////
		float w2 = 0.5;
		float h2 = 0.5;
		float d2 = 0.5;
		
		int i = 0;
		
		
		vertices[i++].setValue( w2,  h2,  d2);
		vertices[i++].setValue(-w2, -h2,  d2);	
		vertices[i++].setValue( w2, -h2,  d2);
		vertices[i++].setValue( w2,  h2,  d2);
		vertices[i++].setValue(-w2,  h2,  d2);
		vertices[i++].setValue(-w2, -h2,  d2);
		
		vertices[i++].setValue( w2,  h2, -d2);
		vertices[i++].setValue( w2, -h2, -d2);
		vertices[i++].setValue(-w2, -h2, -d2);	
		vertices[i++].setValue( w2,  h2, -d2);
		vertices[i++].setValue(-w2, -h2, -d2);
		vertices[i++].setValue(-w2,  h2, -d2);
		
		
		vertices[i++].setValue( w2,  h2,  d2);
		vertices[i++].setValue( w2, -h2, -d2);
		vertices[i++].setValue( w2,  h2, -d2);
		vertices[i++].setValue( w2,  h2,  d2);
		vertices[i++].setValue( w2, -h2,  d2);
		vertices[i++].setValue( w2, -h2, -d2);
		
		vertices[i++].setValue(-w2,  h2,  d2);
		vertices[i++].setValue(-w2,  h2, -d2);
		vertices[i++].setValue(-w2, -h2, -d2);
		vertices[i++].setValue(-w2,  h2,  d2);
		vertices[i++].setValue(-w2, -h2, -d2);
		vertices[i++].setValue(-w2, -h2,  d2);
		
		vertices[i++].setValue( w2,  h2,  d2);
		vertices[i++].setValue( w2,  h2, -d2);
		vertices[i++].setValue(-w2,  h2, -d2);
		vertices[i++].setValue( w2,  h2,  d2);
		vertices[i++].setValue(-w2,  h2, -d2);
		vertices[i++].setValue(-w2,  h2,  d2);
		
		vertices[i++].setValue( w2, -h2,  d2);
		vertices[i++].setValue(-w2, -h2, -d2);
		vertices[i++].setValue( w2, -h2, -d2);
		vertices[i++].setValue( w2, -h2,  d2);
		vertices[i++].setValue(-w2, -h2,  d2);
		vertices[i++].setValue(-w2, -h2, -d2);
		
		for (i = 0; i < 6; i++)
		{
			normals[i].setValue( 0.0,  0.0,  1.0);
			normals[i+6].setValue( 0.0,  0.0, -1.0);
			normals[i+12].setValue( 1.0,  0.0,  0.0);
			normals[i+18].setValue(-1.0,  0.0,  0.0);
			normals[i+24].setValue( 0.0,  1.0,  0.0);
			normals[i+30].setValue( 0.0, -1.0,  0.0);
			
		}
		
		for (i = 0; i < 36; i++)
		{
			colors[i] = Color(1,1,1, 1.0);
		}
	
		 i = 0;
		 //float x0 = 0.0, x1 = 1.0/3.0, x2 = 2.0/3.0, x3 = 1.0;
		 //float y0 = 0.0, y1 = 1.0/2.0, y2 = 1.0;
		 
		float x0 = 0;
		float x1 = 1;
		float y0 = 0;
		float y1 = 1;
		
		for(int j = 0; j< 6; j++)
		{
		
			texCoords[i++] = Vec2(x0, y0);
			texCoords[i++] = Vec2(x1, y1);
			texCoords[i++] = Vec2(x0, y1);
			texCoords[i++] = Vec2(x0, y0);
			texCoords[i++] = Vec2(x1, y0);
			texCoords[i++] = Vec2(x1, y1);
		}	 
		 
		//////////	
	}
	
	void GraphicsManager::InitializeLineCoordinateSet( CoordinateSet *coordSet)
	{
		Vec3 *vertices = coordSet->mVertices;
		Vec3 *normals = coordSet->mNormals;
		Color *colors = coordSet->mColors;
		
		vertices[0].setValue(-0.5f, 0, 0);
		vertices[1].setValue(0.5f, 0, 0);	
				
		normals[0].setValue( 0.0,  0.0,  1.0);
		normals[1].setValue( 0.0,  0.0, 1.0);
				
		colors[0] = Color(1,1,1, 1.0);
		colors[1] = Color(1,1,1, 1.0);

	}
	
	void GraphicsManager::PointWarningArrowAt(btVector3 target  )
	{
		
		btVector3 direction;
		DLog(@"Spawn at %f %f %f", target.x(), target.y(), target.z());
		
		GamePlayManager::Instance()->GetFocalPoint(direction);
		direction *= -1;
		direction += target;

		if(fabs(direction.x())> 9.0f ||
		   fabs(direction.z())> 14.0f)
		{
		
			GameEntityFactory::BuildScreenSpaceSprite(target, 2,2, @"SpawnArrow", 4.0f);
			
		}
		
	}

	void GraphicsManager::PointCriticalArrowAt(btVector3 target )
	{
		btVector3 direction;
		DLog(@"Spawn at %f %f %f", target.x(), target.y(), target.z());
		
		GamePlayManager::Instance()->GetFocalPoint(direction);
		direction *= -1;
		direction += target;
		
		if(fabs(direction.x())> 9.0f ||
		   fabs(direction.z())> 14.0f)
		{
			GameEntityFactory::BuildScreenSpaceSprite(target, 2,2, @"EatArrow", 2.0f);
		}
	}
	

	void GraphicsManager::SetupLineDrawing()
	{
		glDisable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_NORMAL_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		
#if USE_LIGHTS
		glDisable(GL_LIGHTING);
#endif
		
		glEnable(GL_LINE_SMOOTH);
		glColor4f(0.0,0.0,0.0,0.8);
		glLineWidth(1);
	}
	
	void GraphicsManager::DisableLineDrawing()
	{		
		//reenable when done
#if USE_LIGHTS	
		glEnable(GL_LIGHTING);
#else
		//glColor4f(1, 1, 1, 1);
		glColor4f(0.8,0,0.8,1);
#endif
		
		glDisable(GL_BLEND);
		glDisable(GL_LINE_SMOOTH);
		glDepthMask(GL_TRUE);
	}
	
	// draws debug stuff in red
	void GraphicsManager::DrawLine(btVector3 pointA, btVector3 pointB){
		
		SetupLineDrawing();
		
		glColor4f(1,0,0,1);
		
		int kVertsDrawn = 2;
		
		// this does a quick stack allocation 
		// no need to heap allocate
		//be aware there's only 4 verts allocated here
		Vec3 *buf = (Vec3*) alloca(sizeof(Vec3)*kVertsDrawn);
		
		// draw bottom outine
		{
			
			buf[0] = Vec3(pointA.x(),pointA.y(),pointA.z());
			buf[1] = Vec3(pointB.x(),pointB.y(),pointB.z());

			// To-Do: add support for creating and holding a display list
			glVertexPointer(3, GL_FLOAT, 0, buf);
			
			{
				//draw top
				glDrawArrays(GL_LINE_LOOP, 0, kVertsDrawn);
			}
		}
		
		DisableLineDrawing();
	}
	
#if DEBUG
	void GraphicsManager::DrawSquare(btVector3 center, btVector3 extents){
		glColor4f(1,0,0,1);
		
		int kVertsDrawn = 4;
		
		SetupLineDrawing();
		
		// this does a quick stack allocation 
		// no need to heap allocate
		//be aware there's only 4 verts allocated here
		Vec3 *buf = (Vec3*) alloca(sizeof(Vec3)*kVertsDrawn);
		
		glPushMatrix();
		// draw bottom outine
		{
			glTranslatef(center.x(), center.y(), center.z());
			
			buf[0] = Vec3(extents.x(),extents.y(), extents.z());
			buf[1] = Vec3(extents.x(),extents.y(), -extents.z());
			buf[2] = Vec3(-extents.x(),extents.y(), -extents.z());
			buf[3] = Vec3(-extents.x(),extents.y(), extents.z());
			
			
			// To-Do: add support for creating and holding a display list
			glVertexPointer(3, GL_FLOAT, 0, buf);
			
			{
				//draw top
				glDrawArrays( GL_LINE_LOOP, 0, kVertsDrawn);
			}
		}
		glPopMatrix();
		DisableLineDrawing();
	}
	
	void GraphicsManager::DrawCircle(btVector3 center, btVector3 extents)
	{
		glColor4f(1,0,0,1);
		
		int kVertsDrawn = 30;
		
		// this does a quick stack allocation 
		// no need to heap allocate
		//be aware there's only 4 verts allocated here
		Vec3 *buf = (Vec3*) alloca(sizeof(Vec3)*kVertsDrawn);
		
		SetupLineDrawing();
		
		glPushMatrix();
		// draw bottom outine
		{
			glTranslatef(center.x(), center.y(), center.z());
		
			const float dt = M_PI * 2.0f / (kVertsDrawn -1);
			
			const float radius = extents.x();
			
			for(int i = 0; i < kVertsDrawn-1; i++)
			{	
				buf[i] = Vec3(radius * cosf(i*dt),extents.y(), radius * sinf(i*dt) );
			}			
			
			buf[kVertsDrawn-1] = Vec3(radius, extents.y(),0);
			
			// To-Do: add support for creating and holding a display list
			glVertexPointer(3, GL_FLOAT, 0, buf);
			
			{
				//draw top
				glDrawArrays( GL_LINE_LOOP, 0, kVertsDrawn);
			}
		}
		glPopMatrix();
		DisableLineDrawing();
	}
#endif
	
}