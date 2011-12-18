/*
 *  Vector3.h
 *  Dice2
 *
 *  Created by Caleb Cannon on 4/26/08.
 *  Copyright 2008 Caleb C. Cannon. All rights reserved.
 *
 */

#include <math.h>
#include <stdlib.h>

typedef struct {
	float x, y, z;
} Vector3, *pVector3;


Vector3 vec3(float x, float y, float z);
Vector3* pvec3(Vector3 *vOut, float x, float y, float z);

// Vector info
float vec3len(Vector3 v);
float pvec3len(Vector3* v);
float vec3lensq(Vector3 v);
float pvec3lensq(Vector3* v);
float vec3ang(Vector3 v1, Vector3 v2);
float pvec3ang(Vector3* v1, Vector3* v2);
float vec3dist(Vector3 v1, Vector3 v2);
float pvec3dist(Vector3* v1, Vector3* v2);

// Vector math
float vec3dot(Vector3 v1, Vector3 v2);
float pvec3dot(Vector3 *v1, Vector3 *v2);
Vector3 vec3cross(Vector3 v1, Vector3 v2);
Vector3* pvec3cross(Vector3 *vOut, Vector3 *v1, Vector3 *v2);
Vector3 vec3diff(Vector3 v1, Vector3 v2);
Vector3* pvec3diff(Vector3 *vOut, Vector3* v1, Vector3* v2);
Vector3 vec3sum(Vector3 v1, Vector3 v2);
Vector3* pvec3sum(Vector3 *vOut, Vector3* v1, Vector3* v2);
Vector3 vec3mul(Vector3 v1, Vector3 v2);
Vector3* pvec3mul(Vector3 *vOut, Vector3* v1, Vector3* v2);
Vector3 vec3div(Vector3 v1, Vector3 v2);
Vector3* pvec3div(Vector3 *vOut, Vector3* v1, Vector3* v2);
Vector3 vec3scale(Vector3 v, float scale);
Vector3* pvec3scale(Vector3 *vOut, Vector3* v, float scale);
Vector3 vec3norm(Vector3 v);
Vector3* pvec3norm(Vector3 *vOut, Vector3* v);

// Rotations
Vector3 vec3rotatex(Vector3 v1, float angle);
Vector3* pvec3rotatex(Vector3 *vOut, Vector3 *v1, float angle);
Vector3 vec3rotatey(Vector3 v1, float angle);
Vector3* pvec3rotatey(Vector3 *vOut, Vector3 *v1, float angle);
Vector3 vec3rotatez(Vector3 v1, float angle);
Vector3* pvec3rotatez(Vector3 *vOut, Vector3 *v1, float angle);
Vector3 vec3rotateaxis(Vector3 v1, Vector3 v2, float angle);
Vector3* pvec3rotateaxis(Vector3 *vOut, Vector3 *v1, Vector3 *v2, float angle);

// Misc
Vector3 vec3clamp(Vector3 v1, float min, float max);
Vector3* pvec3clamp(Vector3 *vOut, Vector3 *v1, float min, float max);
Vector3 vec3average(Vector3 v1, Vector3 v2);
Vector3* pvec3average(Vector3 *vOut, Vector3 *v1, Vector3 *v2);
Vector3 vec3compare(Vector3 v1, Vector3 v2);
Vector3* pvec3compare(Vector3 *vOut, Vector3 *pv1, Vector3 *pv2);

Vector3 vec3translate(Vector3 v, float x, float y, float z);
Vector3* pvec3translate(Vector3 *vOut, Vector3 *v, float x, float y, float z);

Vector3 multiplyMatrixVector(float *mat, Vector3 v);

