/*
 *  Drawable.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/22/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>

#import <map>
#import <list>

#import "VectorMath.h"
#import "Component.h"
#import "Texture2D.h"

namespace Dog3D
{
	
	class CoordinateSet
	{
	public: 
		Vec3* mVertices;
		Vec3* mNormals;
		Vec2* mTexCoords;
		Color* mColors;
		int mVertexCount;
		
		CoordinateSet(int nVertices)
		{
			mVertexCount = nVertices;
			mVertices = new Vec3[nVertices];
			mNormals = new Vec3[nVertices];
			mTexCoords = new Vec2[nVertices];
			mColors = new Color[nVertices];
		}
		
		~CoordinateSet()
		{
			delete [] mColors;
			delete [] mNormals;
			delete [] mTexCoords;
			delete [] mVertices;
		}
	};
	
	class MaterialSet
	{
	public:
		GLfloat mat_ambient[4];
		GLfloat mat_diffuse[4]; 
		GLfloat mat_specular[4];
		GLfloat mat_shininess[1];
		
		MaterialSet()
		{
			mat_ambient[0] = 0.8;
			mat_ambient[1] = 0;
			mat_ambient[2] = 0;
			mat_ambient[3] = 1;
			
			mat_diffuse[0] = 1;
			mat_diffuse[1] = 1;
			mat_diffuse[2] = 1;
			mat_diffuse[3] = 1;
			
			mat_specular[0] = 0.77;
			mat_specular[1] = 0.77;			
			mat_specular[2] = 0.77;
			mat_specular[3] = 1;
			
			mat_shininess[0]  = 0.6;	
		}
	
	};
		
	// Drawable component
	// Basic vertex container
	class GraphicsComponent : public Component
	{
	protected: 
		
		btVector3 mScale;
		
		const Vec3* mVertices;
		const Vec3* mNormals;
		const Vec2* mTexCoords;
		const Color* mColors;
		int mVertexCount;
		
		const MaterialSet *mMaterialSet;
		
		Texture2D* mTexture;
		btVector3 mOffset;

		
	public:
		
		bool mActive;
 		
	public:
		GraphicsComponent() : 
		mVertices(NULL), 
		mNormals(NULL), 
		mTexCoords(NULL),
		mVertexCount(0), 
		mActive(true),
		mTexture(NULL),
		mOffset(0,0,0),
		mScale(1,1,1)
		{ 
			mTypeId = GRAPHICS;
		}
		
		virtual ~GraphicsComponent();
		
		inline void SetVertices( const Vec3* vertices, int nVertices )
		{
			mVertices = vertices;
			mVertexCount = nVertices;
		}
		
		inline void SetNormals( const Vec3* normals)
		{
			mNormals = normals;
		}
		
		inline void SetColors( const Color* colors)
		{
			mColors = colors;
		}
		
		inline void SetTexCoords( const Vec2* coords)
		{ 
			mTexCoords = coords;
		}
		
		inline void SetTexture( const Texture2D *texture)
		{
			mTexture = texture;	
		}
		
		void SetScale( float s) { mScale = btVector3(s,s,s); }
		void SetScale( btVector3 &s) { mScale = s; }
		
		inline btVector3 GetScale() { return mScale;}
		
		// assign a material setup (usually from gfx mgr's cached palette)
		inline void SetMaterialSet( const MaterialSet *materialSet)
		{ 
			mMaterialSet = materialSet;
		}
		
		// default material lighting setup
		inline void SetupMaterials()
		{}
		
		virtual void Update(float deltaTime, bool show3D);
		
		inline void SetOffset(btVector3 &offset){ mOffset = offset; }
		inline void SetOffset(btVector3 offset){ mOffset = offset; }
		
		inline btVector3 GetOffset() { return mOffset; }
	};
	
	class LineComponent : public GraphicsComponent
	{		
		virtual void Update(float deltaTime, bool show3D);
	};
	
	// holds n graphics components
	class CompoundGraphicsComponent : public GraphicsComponent
	{
	public:
		CompoundGraphicsComponent() {}
		
		~CompoundGraphicsComponent();
		
		void AddChild(GraphicsComponent *child);
		
		GraphicsComponent *RemoveFirstChild();
		
		GraphicsComponent *GetFirstChild();
		
		inline int IsEmtpy() { return mChildren.empty();}
			 
		// draw each child
		void Update(float deltaTime, bool show3D);
		
	protected:
		std::list<GraphicsComponent *> mChildren;
		
	};
	
	
	class TexturedGraphicsComponent : public GraphicsComponent
	{
		
	public:
		TexturedGraphicsComponent(float width, float height) 
		{ 
			mTexture = NULL;
			mScale = btVector3(width, 0, height);
		}
		
		float getWidth() { return mScale.x();}
		float getHeight() { return mScale.z();}
		
		~TexturedGraphicsComponent();
		
		void Update(float deltaTime, bool show3D);		
		
	};
	
	
	
	class HUDGraphicsComponent : public GraphicsComponent 
	{
		// texture
		btVector3 mExtents;
		float mWidthSpacing;
		int mTotalLives; 
		int mCurrentLives;
		bool mAlignLeft; //if not align right
		
	public:
		HUDGraphicsComponent(Texture2D* texture,  btVector3 &extents, float widthSpacing, int nTotal, bool alignLeft) : 
		mExtents(extents),
		mWidthSpacing(widthSpacing),
		mTotalLives(nTotal), 
		mCurrentLives(nTotal),
		mAlignLeft(alignLeft)
		{ 
			mTexture = texture; 
		}
		
		inline void RemoveLife()
		{ 
			mCurrentLives--; 
			if (mCurrentLives < 0) 
			{
				mCurrentLives = 0;
			}
		}
		
		void Update(float dt, bool show3D) ;
		
	};
	
	class SquareTexturedGraphicsComponent : public TexturedGraphicsComponent
	{

	public:
		
		SquareTexturedGraphicsComponent(float width, float height) :
		TexturedGraphicsComponent(width, height){ }
		
		void Update(float deltaTime, bool show3D);	
	};
	
	// screen space based graphics componentt
	class ScreenSpaceComponent : public TexturedGraphicsComponent
	{
		
	public:
		
		ScreenSpaceComponent(float width, float height, btVector3 target, float duration) :
		TexturedGraphicsComponent(width, height), 
		mTarget(target), 
		mDuration(duration),
		mRotateTowardsTarget(true),
		mConstrainToCircle(true){ }
		
		void Update(float deltaTime, bool show3D);	
		
		bool IsFinished() { return mDuration <= 0;}
		
		btVector3 mTarget;
		float mDuration;
		
		// forces rotation
		bool mRotateTowardsTarget;
		
		// keeps object contstrained to a visible circle
		bool mConstrainToCircle;
	};
	
	class SpriteAnimation
	{
	public:
		int mTileWidth;
		int mTileHeight;
		int mTileCount;
		
		//  current tile index
		int mTileIndex;
		
		// frame duration in time
		float mFrameDuration;
	
		Texture2D* mSpriteSheet;
	
		bool mPlayBigVertices;
		bool mLoopAnimation;
		
		SpriteAnimation(bool playBigVertices = false, bool loopAnimation = true) : 
			mFrameDuration(1.0/30.0),
			mSpriteSheet(NULL), 
			mPlayBigVertices(playBigVertices),
			mLoopAnimation(loopAnimation)
		{} 
		
		inline float getDS()
		{
			float wide = [mSpriteSheet pixelsWide];
			float frameSize= wide/mTileWidth;
			
			return ((float) frameSize)/ ((float) wide);
		}
		
		float getDT()
		{
			float high = [mSpriteSheet pixelsHigh];
			float frameSize = high/mTileHeight;

			return ((float) frameSize)/ ((float) high);
		}
		
		
		inline float getS() 
		{
			int j = ( mTileIndex % mTileWidth);		
			return ((float) j) * getDS();
		}
		
		inline float getT() 
		{
			int i = ( mTileIndex / mTileWidth);
			return ((float) i) * getDT();
		}
		
	};
		
	enum AnimationMirroring
	{
		MIRROR_NONE = 0x0, MIRROR_HORIZONTAL = 0x1, MIRROR_VERTICAL = 0x2
	};
	
	class AnimatedGraphicsComponent : public GraphicsComponent
	{
	protected:
		std::map<int, SpriteAnimation*> mAnimations;
		
		Vec3 *mBigVertices;
		
		// draw me this wide, tall
		float mFrameTime;
		
		int mActiveAnimationID;
		
		int mMirrorAnimation;
		bool mPlayForward;
		bool mIgnoreParentRotation;
		
	public:
		
		enum GopherAnims
		{
			IDLE = 0, 
			WALK_FORWARD, 
			WALK_FORWARD_LEFT, 
			WALK_LEFT, 
			WALK_BACK_LEFT, 
			WALK_BACK, 
			BLOWUP_FORWARD, 
			BLOWUP_LEFT, 
			SPAWN_IN, 
			JUMP_DOWN_HOLE,
			EAT_CARROT,
			WIN_DANCE,
			TAUNT,
			FREEZE,
			ELECTRO,
			FIRE
		};
		
		
		AnimatedGraphicsComponent(float width, float height) : 	
		mFrameTime(0),
		mActiveAnimationID(0),
		mMirrorAnimation(MIRROR_NONE),
		mPlayForward(true), 
		mIgnoreParentRotation(true),
		mBigVertices(NULL)
		{
			mScale = btVector3(width, 0, height);
		}
		
		~AnimatedGraphicsComponent();
		
		inline bool LastFrame()
		{ 
			if(mPlayForward)
			{
				return mAnimations[mActiveAnimationID]->mTileIndex == ( mAnimations[mActiveAnimationID]->mTileCount -1) ;
			}
			else {
				return mAnimations[mActiveAnimationID]->mTileIndex ==0;
			}
		}
	
		inline bool IsLooping()
		{
			return mAnimations[mActiveAnimationID]->mLoopAnimation;
		}
			
		void AddAnimation(SpriteAnimation *newSpriteSheet, int ID);
		
		// starts anim at frame 0 or end, if playForward = false
		void StartAnimation(GopherAnims animationID, AnimationMirroring mirror = MIRROR_NONE, bool playForward = true );	
		
		void StartAnimation(GopherAnims ID,  AnimationMirroring mirror, int startFrame );
		
		// will not restart anim if already playing
		void PlayAnimation(GopherAnims animationID,  AnimationMirroring mirror = MIRROR_NONE, bool playForward = true );
		
		// direction based anim play
		void UpdateAnimatedWalkDirection( btVector3 &direction );
		
		
		void Update(float deltaTime, bool show3D);	
		
		inline void SetBigVertices( Vec3 * bigVertices)
		{
			mBigVertices = bigVertices;
		}
				
		void StepAnimation(SpriteAnimation *activeAnimation, float dt);
		
	};
	
	class FXGraphicsComponent : public AnimatedGraphicsComponent
	{
	public: 
		//TODO - FX Element in scene
		// spawn an effect, cleans up after itself


		FXGraphicsComponent(float drawWidth, float drawHeight) :
		AnimatedGraphicsComponent(drawWidth, drawHeight),
		mTriggeredComponent(NULL)
		{ mTypeId = FX;}
	
		// this only works with 16 frame textures
		inline void SetFXTexture(Texture2D* texture)
		{
			mAnimations[IDLE]->mSpriteSheet =texture; 
		}
		
		// this only works with 16 frame textures
		inline void PlayBigVertices(bool playBigVertices, float scale)
		{
			mAnimations[IDLE]->mPlayBigVertices = playBigVertices; 
			if(mBigVertices == NULL)
			{
				mBigVertices = new Vec3[4];
			}
			
			mBigVertices[0].setValue( -scale*0.5, 0, scale*0.5);
			mBigVertices[1].setValue(scale*0.5, 0, scale*0.5);
			mBigVertices[2].setValue(-scale*0.5, 0, -scale*0.5);
			mBigVertices[3].setValue(scale*0.5, 0, -scale*0.5);
		}
		
		void FollowParentRotation() { mIgnoreParentRotation = false;}
		
		GraphicsComponent* mTriggeredComponent;
	};
	
	// transforms with parent object (ie ball)
	class BillBoard : public FXGraphicsComponent
	{
	public:
		BillBoard(float drawWidth, float drawHeight)
		: FXGraphicsComponent(drawWidth, drawHeight)
		{}
		
		void Update(float deltaTime, bool show3D);	
		
	};
	
	//holds an animation on the last frame
	class HoldLastAnim : public FXGraphicsComponent
	{
		//int mNumFrames;
		
	public:
		HoldLastAnim(float drawWidth, float drawHeight)
		:FXGraphicsComponent(drawWidth, drawHeight)
		{
			mTypeId=GRAPHICS;
		}
		
	};
	
	
	
	
}