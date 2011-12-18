/*
 *  Vector2.c
 *  Dice2
 *
 *  Created by Caleb Cannon on 4/26/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#include <math.h>
#include <stdlib.h>

#include "Vector2.h"

Vector2 vec2(float x, float y)
{
	Vector2 v = { x, y };
	return v;
}

Vector2* pvec2(Vector2 *vOut, float x, float y)
{
	vOut->x = x;
	vOut->y = y;
	return vOut;
}

Vector2* pvec2rotateaxis(Vector2 *vOut, Vector2 *pv, float angle)
{
	vOut->x = cos(angle)*pv->x - sin(angle)*pv->y;
	vOut->x = sin(angle)*pv->x + cos(angle)*pv->y;
	return vOut;
}

Vector2 vec2rotate(Vector2 v, float angle)
{
	return vec2(
				cos(angle)*v.x - sin(angle)*v.y,
				sin(angle)*v.x + cos(angle)*v.y
				);
}

float vec2dot(Vector2 v1, Vector2 v2)
{
	return ( v1.x*v2.x + v1.y*v2.y  );
}

float pvec2dot(Vector2 *pv1, Vector2 *pv2)
{
	return ( pv1->x*pv2->x + pv1->y*pv2->y );
}

float vec2len(Vector2 v)
{
	return sqrt( v.x * v.x + v.y * v.y );
}

float pvec2len(Vector2* pv)
{
	return sqrt( pv->x * pv->x + pv->y * pv->y );
}

float vec2lensq(Vector2 v)
{
	return ( v.x * v.x + v.y * v.y );
}

float pvec2lensq(Vector2* pv)
{
	return ( pv->x * pv->x + pv->y * pv->y );
}

float vec2ang(Vector2 v1, Vector2 v2)
{
	return acos( vec2dot(v1,v2) / ( vec2len(v1) * vec2len(v2) ) ) ;
}

float pvec2ang(Vector2* pv1, Vector2* pv2)
{
	return acos( pvec2dot(pv1, pv2) / ( pvec2len(pv1) * pvec2len(pv2) ) ) ;
}

Vector2 vec2diff(Vector2 v1, Vector2 v2)
{
	return vec2( v1.x - v2.x , v1.y - v2.y );
}

Vector2* pvec2diff(Vector2 *vOut, Vector2* pv1, Vector2* pv2)
{
	vOut->x = pv1->x - pv2->x;
	vOut->y = pv1->y - pv2->y;
	return vOut;
}

Vector2 vec2sum(Vector2 v1, Vector2 v2)
{
	return vec2(v1.x + v2.x , v1.y + v2.y );
}

Vector2* pvec2sum(Vector2 *vOut, Vector2* pv1, Vector2* pv2)
{
	vOut->x = pv1->x + pv2->x;
	vOut->y = pv1->y + pv2->y;
	return vOut;
}

Vector2 vec2mul(Vector2 v1, Vector2 v2)
{
	return vec2( v1.x * v2.x , v1.y * v2.y );
}

Vector2* pvec2mul(Vector2 *vOut, Vector2* pv1, Vector2* pv2)
{
	vOut->x = pv1->x * pv2->x;
	vOut->y = pv1->y * pv2->y;
	return vOut;
}

Vector2 vec2div(Vector2 v1, Vector2 v2)
{
	return vec2( v1.x / v2.x , v1.y / v2.y );
}

Vector2* pvec2div(Vector2 *vOut, Vector2* pv1, Vector2* pv2)
{
	vOut->x = pv1->x / pv2->x;
	vOut->y = pv1->y / pv2->y;
	return vOut;
}

Vector2 vec2scale(Vector2 v1, float scale)
{
	return vec2( v1.x * scale, v1.y * scale );
}

Vector2* pvec2scale(Vector2 *vOut, Vector2* pv1, float scale)
{
	vOut->x = pv1->x * scale;
	vOut->y = pv1->y * scale;
	return vOut;
}

Vector2 vec2norm(Vector2 v1)
{
	return vec2scale(v1, 1.0 / vec2len(v1));
}

Vector2* pvec2norm(Vector2 *vOut, Vector2* pv1)
{
	return pvec2scale(vOut, pv1, 1.0 / pvec2len(pv1));
}

float vec2dist(Vector2 v1, Vector2 v2)
{
	return sqrt( powf(v1.x - v2.x,2.0) + powf(v1.y - v2.y,2.0) );	
}

float pvec2dist(Vector2* pv1, Vector2* pv2)
{
	return sqrt( powf(pv1->x - pv2->x,2.0) + powf(pv1->y - pv2->y,2.0) );	
}

Vector2 vec2clamp(Vector2 v1, float min_, float max_)
{
	return vec2(
				max(min(v1.x, max_), min_),
				max(min(v1.y, max_), min_)
				);
}

Vector2* pvec2clamp(Vector2 *vOut, Vector2 *pv1, float min_, float max_)
{
	vOut->x = max(min(pv1->x, max_), min_);
	vOut->y = max(min(pv1->y, max_), min_);
	return vOut;
}

Vector2 vec2average(Vector2 v1, Vector2 v2)
{
	return vec2(
				(v1.x + v2.x) / 2.0,
				(v1.y + v2.y) / 2.0
				);
}

Vector2* pvec2average(Vector2 *vOut, Vector2 *pv1, Vector2 *pv2)
{
	vOut->x = (pv1->x + pv2->x) / 2.0;
	vOut->y = (pv1->y + pv2->y) / 2.0;
	return vOut;
}

Vector2 vec2compare(Vector2 v1, Vector2 v2)
{
	return vec2(
				v1.x < v2.x ? -1.0 : ( v1.x > v2.x ? 1.0 : 0.0 ),
				v1.y < v2.y ? -1.0 : ( v1.y > v2.y ? 1.0 : 0.0 )
				);
}

Vector2* pvec2compare(Vector2 *vOut, Vector2 *pv1, Vector2 *pv2)
{
	vOut->x = pv1->x < pv2->x ? -1.0 : ( pv1->x > pv2->x ? 1.0 : 0.0 );
	vOut->y = pv1->y < pv2->y ? -1.0 : ( pv1->y > pv2->y ? 1.0 : 0.0 );
	return vOut;
}

Vector2 vec2translate(Vector2 v, float x, float y)
{
	return vec2(
				v.x + x,
				v.y + y
				);
}

Vector2* pvec2translate(Vector2 *vOut, Vector2 *pv, float x, float y)
{
	vOut->x = pv->x + x;
	vOut->y = pv->y + y;
	return vOut;
}

Vector2 multiplyMatrixVector2(float *mat, Vector2 v)
{	
	return vec2(
				v.x * mat[0] + v.y * mat[2],
				v.x * mat[1] + v.y * mat[3]
				);
}

Vector2 multiplyMatrixTransposeVector2(float *mat, Vector2 v)
{	
	return vec2(
				v.x * mat[0] + v.y * mat[1],
				v.x * mat[2] + v.y * mat[3]
				);
}

// An OpenGL matrix looks like this:
//
// [ 0  4  8  12 ]
// [ 1  5  9  13 ]
// [ 2  6  10 14 ]
// [ 3  7  11 15 ]
//
// GLfloat *matrix = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }

Vector2* pmultiplyMatrixVector2(Vector2 *vOut, float *mat, Vector2* pv)
{	
	vOut->x = pv->x * mat[0] + pv->x * mat[1];
	vOut->y = pv->x * mat[2] + pv->y * mat[3];
	return vOut;
}


