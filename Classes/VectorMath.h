/*
 *  VectorMath.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/19/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */


namespace Dog3D
{
#define PI 3.14159265
	
	/// A simple Vector2 class
	class Vec2
	{
	public: 
		Vec2() { x = 0; y = 0; }
		Vec2( float x, float y)
		{
			this->x = x;
			this->y = y;
		}
		
		inline float Length() const 
		{
			return x * x + y * y;
		}
		
		inline Vec2 &operator +=(const Vec2& v)
		{
			x += v.x;
			y += v.y;
			return *this;
		}
		
		inline Vec2 &operator -=(const Vec2& v)
		{
			x -= v.x;
			y -= v.y;
			return *this;
		}
		
		inline Vec2 &operator *=(const float f)
		{
			x *= f;
			y *= f;
			return *this;
		}
		
		inline void SetMul(const Vec2 &vec, float f)
		{
			x = vec.x * f;
			y = vec.y * f;
		}
		
		inline void AddMul(const Vec2 &vec, float f)
		{
			x += (vec.x * f);
			y += (vec.y * f);
		}
		
		float x, y;
	};
	
	/// A simple Vector3 class
	class Vec3
	{
	public: 
		Vec3() { x = 0; y = 0; z = 0; }
		Vec3( float x, float y, float z)
		{
			this->x = x;
			this->y = y;
			this->z = z;
		}
		
		void setValue( float x, float y, float z)
		{
			this->x = x;
			this->y = y;
			this->z = z;
		}
		
		
		inline float Length() const 
		{
			return x * x + y * y + z * z;
		}
		
		inline Vec3 &operator +=(const Vec3& v)
		{
			x += v.x;
			y += v.y;
			z += v.z;
			return *this;
		}
	
		inline Vec3 &operator -=(const Vec3& v)
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
			return *this;
		}
		
		inline Vec3 &operator *=(const float f)
		{
			x *= f;
			y *= f;
			z *= f;
			return *this;
		}
		
		inline void SetMul(const Vec3 &vec, float f)
		{
			x = vec.x * f;
			y = vec.y * f;
			z = vec.z * f;
		}
		
		float x, y, z;
	};
	
	class Color
	{
	public: 
		Color() { r = 0; g = 0; b = 0; a = 0;}
		Color( float r, float g, float b, float a)
		{
			this->r = r;
			this->g = g;
			this->b = b;
			this->a = a;
		}
		
		float r, g, b, a;
	};
}

