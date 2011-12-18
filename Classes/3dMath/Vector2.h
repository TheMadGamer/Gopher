/*
 *  Vector2.h
 *  Dice2
 *
 *  Created by Caleb Cannon on 4/26/08.
 *  Copyright 2008 Caleb C. Cannon. All rights reserved.
 *
 */

#include <math.h>
#include <stdlib.h>

#import "3dmath.h"

typedef struct {
	float x, y;
} Vector2, *pVector2;


Vector2 vec2(float x, float y);
Vector2* pvec2(Vector2 *vOut, float x, float y);

// Vector info
float vec2len(Vector2 v);
float pvec2len(Vector2* v);
float vec2lensq(Vector2 v);
float pvec2lensq(Vector2* v);
float vec2ang(Vector2 v1, Vector2 v2);
float pvec2ang(Vector2* v1, Vector2* v2);
float vec2dist(Vector2 v1, Vector2 v2);
float pvec2dist(Vector2* v1, Vector2* v2);

// Vector math
float vec2dot(Vector2 v1, Vector2 v2);
float pvec2dot(Vector2 *v1, Vector2 *v2);
Vector2 vec2diff(Vector2 v1, Vector2 v2);
Vector2* pvec2diff(Vector2 *vOut, Vector2* v1, Vector2* v2);
Vector2 vec2sum(Vector2 v1, Vector2 v2);
Vector2* pvec2sum(Vector2 *vOut, Vector2* v1, Vector2* v2);
Vector2 vec2mul(Vector2 v1, Vector2 v2);
Vector2* pvec2mul(Vector2 *vOut, Vector2* v1, Vector2* v2);
Vector2 vec2div(Vector2 v1, Vector2 v2);
Vector2* pvec2div(Vector2 *vOut, Vector2* v1, Vector2* v2);
Vector2 vec2scale(Vector2 v, float scale);
Vector2* pvec2scale(Vector2 *vOut, Vector2* v, float scale);
Vector2 vec2norm(Vector2 v);
Vector2* pvec2norm(Vector2 *vOut, Vector2* v);

// Rotations
Vector2 vec2rotate(Vector2 v1, float angle);
Vector2* pvec2rotate(Vector2 *vOut, Vector2 *v1, float angle);

// Misc
Vector2 vec2clamp(Vector2 v1, float min, float max);
Vector2* pvec2clamp(Vector2 *vOut, Vector2 *v1, float min, float max);
Vector2 vec2average(Vector2 v1, Vector2 v2);
Vector2* pvec2average(Vector2 *vOut, Vector2 *v1, Vector2 *v2);
Vector2 vec2compare(Vector2 v1, Vector2 v2);
Vector2* pvec2compare(Vector2 *vOut, Vector2 *pv1, Vector2 *pv2);

Vector2 vec2translate(Vector2 v, float x, float y);
Vector2* pvec2translate(Vector2 *vOut, Vector2 *v, float x, float y);

Vector2 multiplyMatrixVector2(float *mat, Vector2 v);

