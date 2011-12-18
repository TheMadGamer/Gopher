/*
 *  Vector3.c
 *  Dice2
 *
 *  Created by Caleb Cannon on 4/26/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "Vector3.h"

Vector3 vec3(float x, float y, float z)
{
	Vector3 v = { x, y, z };
	return v;
}

Vector3* pvec3(Vector3 *vOut, float x, float y, float z)
{
	vOut->x = x;
	vOut->y = y;
	vOut->z = z;
	return vOut;
}

Vector3 vec3rotatex(Vector3 v1, float angle)
{
	return vec3(
				v1.x , 
				cos(angle)*v1.y + sin(angle)*v1.z , 
				-sin(angle)*v1.y + cos(angle)*v1.z
	);
}

Vector3* pvec3rotatex(Vector3 *vOut, Vector3 *pv1, float angle)
{
	vOut->x = pv1->x;
	vOut->y = cos(angle)*pv1->y + sin(angle)*pv1->z;
	vOut->z = -sin(angle)*pv1->y + cos(angle)*pv1->z;
	return vOut;
}

Vector3 vec3rotatey(Vector3 v1, float angle)
{
	return vec3(
				cos(angle)*v1.x - sin(angle)*v1.z , 
				v1.y ,
				sin(angle)*v1.x + cos(angle)*v1.z
	);
}

Vector3* pvec3rotatey(Vector3 *vOut, Vector3 *pv1, float angle)
{
	vOut->x = cos(angle)*pv1->x - sin(angle)*pv1->z;
	vOut->y = pv1->y;
	vOut->z = sin(angle)*pv1->x + cos(angle)*pv1->z;
	return vOut;
}

Vector3 vec3rotatez(Vector3 v1, float angle)
{
	return vec3(
				cos(angle)* v1.x + sin(angle)*v1.y ,
				-sin(angle)*v1.x + cos(angle)*v1.y ,
				v1.z  
	);
}

Vector3* pvec3rotatez(Vector3 *vOut, Vector3 *pv1, float angle)
{
	vOut->x = cos(angle) * pv1->x + sin(angle) * pv1->y;
	vOut->y = -sin(angle) * pv1->x + cos(angle) * pv1->y;
	vOut->z = pv1->z;
	return vOut;
}

Vector3* pvec3rotateaxis(Vector3 *vOut, Vector3 *pv1, Vector3 *pv2, float angle)
{
	float d = pv2->x*pv2->x + pv2->y*pv2->y + pv2->z*pv2->z;
	float s = sqrt(d);
	vOut->x = ( pv2->x*(pv2->x*pv1->x + pv2->y*pv1->y + pv2->z*pv1->z) + (pv1->x*(pv2->y*pv2->y + pv2->z*pv2->z) - pv2->x*(pv2->y*pv1->y+pv2->z*pv1->z))*cos(angle) + s*(-pv2->z*pv1->y+pv2->y*pv1->z)*sin(angle) ) / d;
	vOut->y = ( pv2->y*(pv2->x*pv1->x + pv2->y*pv1->y + pv2->z*pv1->z) + (pv1->y*(pv2->x*pv2->x + pv2->z*pv2->z) - pv2->y*(pv2->x*pv1->x+pv2->z*pv1->z))*cos(angle) + s*( pv2->z*pv1->x-pv2->x*pv1->z)*sin(angle) ) / d;
	vOut->z = ( pv2->z*(pv2->x*pv1->x + pv2->y*pv1->y + pv2->z*pv1->z) + (pv1->z*(pv2->y*pv2->y + pv2->x*pv2->x) - pv2->z*(pv2->x*pv1->x+pv2->y*pv1->y))*cos(angle) + s*(-pv2->y*pv1->x+pv2->x*pv1->y)*sin(angle) ) / d;
	return vOut;
}

Vector3 vec3rotateaxis(Vector3 v1, Vector3 v2, float angle)
{
	float d = v2.x*v2.x+v2.y*v2.y+v2.z*v2.z;
	float s = sqrt(d);
	return vec3(
				( v2.x*(v2.x*v1.x + v2.y*v1.y + v2.z*v1.z) + (v1.x*(v2.y*v2.y + v2.z*v2.z) - v2.x*(v2.y*v1.y+v2.z*v1.z))*cos(angle) + s*(-v2.z*v1.y+v2.y*v1.z)*sin(angle) ) / d ,
				( v2.y*(v2.x*v1.x + v2.y*v1.y + v2.z*v1.z) + (v1.y*(v2.x*v2.x + v2.z*v2.z) - v2.y*(v2.x*v1.x+v2.z*v1.z))*cos(angle) + s*( v2.z*v1.x-v2.x*v1.z)*sin(angle) ) / d ,
				( v2.z*(v2.x*v1.x + v2.y*v1.y + v2.z*v1.z) + (v1.z*(v2.y*v2.y + v2.x*v2.x) - v2.z*(v2.x*v1.x+v2.y*v1.y))*cos(angle) + s*(-v2.y*v1.x+v2.x*v1.y)*sin(angle) ) / d
	);
}

Vector3 vec3cross(Vector3 v1, Vector3 v2)
{
	return vec3( 
				v1.y*v2.z - v1.z*v2.y ,
				v1.z*v2.x - v1.x*v2.z ,
				v1.x*v2.y - v1.y*v2.x
	);
}

Vector3* pvec3cross(Vector3 *vOut, Vector3 *pv1, Vector3 *pv2)
{
	vOut->x = pv1->y*pv2->z - pv1->z*pv2->y;
	vOut->y = pv1->z*pv2->x - pv1->x*pv2->z;
	vOut->z = pv1->x*pv2->y - pv1->y*pv2->x;
	return vOut;
}

float vec3dot(Vector3 v1, Vector3 v2)
{
	return ( v1.x*v2.x + v1.y*v2.y + v1.z*v2.z );
}

float pvec3dot(Vector3 *pv1, Vector3 *pv2)
{
	return ( pv1->x*pv2->x + pv1->y*pv2->y + pv1->z*pv2->z );
}

float vec3len(Vector3 v)
{
	return sqrt( v.x * v.x + v.y * v.y + v.z * v.z );
}

float pvec3len(Vector3* pv)
{
	return sqrt( pv->x * pv->x + pv->y * pv->y + pv->z * pv->z );
}

float vec3lensq(Vector3 v)
{
	return ( v.x * v.x + v.y * v.y + v.z * v.z );
}

float pvec3lensq(Vector3* pv)
{
	return ( pv->x * pv->x + pv->y * pv->y + pv->z * pv->z );
}

float vec3ang(Vector3 v1, Vector3 v2)
{
	return acos( vec3dot(v1,v2) / ( vec3len(v1) * vec3len(v2) ) ) ;
}

float pvec3ang(Vector3* pv1, Vector3* pv2)
{
	return acos( pvec3dot(pv1, pv2) / ( pvec3len(pv1) * pvec3len(pv2) ) ) ;
}

Vector3 vec3diff(Vector3 v1, Vector3 v2)
{
	return vec3( v1.x - v2.x , v1.y - v2.y , v1.z - v2.z );
}

Vector3* pvec3diff(Vector3 *vOut, Vector3* pv1, Vector3* pv2)
{
	vOut->x = pv1->x - pv2->x;
	vOut->y = pv1->y - pv2->y;
	vOut->z = pv1->z - pv2->z;
	return vOut;
}

Vector3 vec3sum(Vector3 v1, Vector3 v2)
{
	return vec3(v1.x + v2.x , v1.y + v2.y , v1.z + v2.z );
}

Vector3* pvec3sum(Vector3 *vOut, Vector3* pv1, Vector3* pv2)
{
	vOut->x = pv1->x + pv2->x;
	vOut->y = pv1->y + pv2->y;
	vOut->z = pv1->z + pv2->z;
	return vOut;
}

Vector3 vec3mul(Vector3 v1, Vector3 v2)
{
	return vec3( v1.x * v2.x , v1.y * v2.y , v1.z * v2.z );
}

Vector3* pvec3mul(Vector3 *vOut, Vector3* pv1, Vector3* pv2)
{
	vOut->x = pv1->x * pv2->x;
	vOut->y = pv1->y * pv2->y;
	vOut->z = pv1->z * pv2->z;
	return vOut;
}

Vector3 vec3div(Vector3 v1, Vector3 v2)
{
	return vec3( v1.x / v2.x , v1.y / v2.y , v1.z / v2.z );
}

Vector3* pvec3div(Vector3 *vOut, Vector3* pv1, Vector3* pv2)
{
	vOut->x = pv1->x / pv2->x;
	vOut->y = pv1->y / pv2->y;
	vOut->z = pv1->z / pv2->z;
	return vOut;
}

Vector3 vec3scale(Vector3 v1, float scale)
{
	return vec3( v1.x * scale, v1.y * scale, v1.z * scale );
}

Vector3* pvec3scale(Vector3 *vOut, Vector3* pv1, float scale)
{
	vOut->x = pv1->x * scale;
	vOut->y = pv1->y * scale;
	vOut->z = pv1->z * scale;
	return vOut;
}

Vector3 vec3norm(Vector3 v1)
{
	return vec3scale(v1, 1.0 / vec3len(v1));
}

Vector3* pvec3norm(Vector3 *vOut, Vector3* pv1)
{
	return pvec3scale(vOut, pv1, 1.0 / pvec3len(pv1));
}

float vec3dist(Vector3 v1, Vector3 v2)
{
	return sqrt( powf(v1.x - v2.x,2.0) + powf(v1.y - v2.y,2.0) + powf(v1.z - v2.z,2.0) );	
}

float pvec3dist(Vector3* pv1, Vector3* pv2)
{
	return sqrt( powf(pv1->x - pv2->x,2.0) + powf(pv1->y - pv2->y,2.0) + powf(pv1->z - pv2->z,2.0) );	
}

Vector3 vec3clamp(Vector3 v1, float min_, float max_)
{
	return vec3(
				max(min(v1.x, max_), min_),
				max(min(v1.y, max_), min_),
				max(min(v1.z, max_), min_)
	);
}

Vector3* pvec3clamp(Vector3 *vOut, Vector3 *pv1, float min_, float max_)
{
	vOut->x = max(min(pv1->x, max_), min_);
	vOut->y = max(min(pv1->y, max_), min_);
	vOut->z = max(min(pv1->z, max_), min_);
	return vOut;
}

Vector3 vec3average(Vector3 v1, Vector3 v2)
{
	return vec3(
				(v1.x + v2.x) / 2.0,
				(v1.y + v2.y) / 2.0,
				(v1.z + v2.z) / 2.0
	);
}

Vector3* pvec3average(Vector3 *vOut, Vector3 *pv1, Vector3 *pv2)
{
	vOut->x = (pv1->x + pv2->x) / 2.0;
	vOut->y = (pv1->y + pv2->y) / 2.0;
	vOut->z = (pv1->z + pv2->z) / 2.0;
	return vOut;
}

Vector3 vec3compare(Vector3 v1, Vector3 v2)
{
	return vec3(
				v1.x < v2.x ? -1.0 : ( v1.x > v2.x ? 1.0 : 0.0 ),
				v1.y < v2.y ? -1.0 : ( v1.y > v2.y ? 1.0 : 0.0 ),
				v1.z < v2.z ? -1.0 : ( v1.z > v2.z ? 1.0 : 0.0 )
	);
}

Vector3* pvec3compare(Vector3 *vOut, Vector3 *pv1, Vector3 *pv2)
{
	vOut->x = pv1->x < pv2->x ? -1.0 : ( pv1->x > pv2->x ? 1.0 : 0.0 );
	vOut->y = pv1->y < pv2->y ? -1.0 : ( pv1->y > pv2->y ? 1.0 : 0.0 );
	vOut->z = pv1->z < pv2->z ? -1.0 : ( pv1->z > pv2->z ? 1.0 : 0.0 );
	return vOut;
}

Vector3 vec3translate(Vector3 v, float x, float y, float z)
{
	return vec3(
				v.x + x,
				v.y + y,
				v.z + z
	);
}

Vector3* pvec3translate(Vector3 *vOut, Vector3 *pv, float x, float y, float z)
{
	vOut->x = pv->x + x;
	vOut->y = pv->y + y;
	vOut->z = pv->z + z;
	return vOut;
}

Vector3 multiplyMatrixVector(float *mat, Vector3 v)
{	
	return vec3(
				v.x * mat[0] + v.y * mat[4] + v.z * mat[8],
				v.x * mat[1] + v.y * mat[5] + v.z * mat[9],
				v.x * mat[2] + v.y * mat[6] + v.z * mat[10] 
	);
}

Vector3 multiplyMatrixTransposeVector(float *mat, Vector3 v)
{	
	return vec3(
				v.x * mat[0] + v.y * mat[1] + v.z * mat[2],
				v.x * mat[4] + v.y * mat[5] + v.z * mat[6],
				v.x * mat[8] + v.y * mat[9] + v.z * mat[10] 
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


void matrixTranspose(float *m, float *matResult)
{
	matResult[0] = m[0];
	matResult[1] = m[4];
	matResult[2] = m[8];
	matResult[3] = m[12];

	matResult[4] = m[1];
	matResult[5] = m[5];
	matResult[6] = m[9];
	matResult[7] = m[13];

	matResult[8] = m[2];
	matResult[9] = m[6];
	matResult[10] = m[10];
	matResult[11] = m[14];

	matResult[12] = m[3];
	matResult[13] = m[7];
	matResult[14] = m[11];
	matResult[15] = m[15];
}

void multiplyMatrixMatrix(float *m1, float *m2, float *matResult)
{
	matResult[0] = m1[0]*m2[0] + m1[4]*m2[1] + m1[8]*m2[2] + m1[12]*m2[3];
	matResult[4] = m1[0]*m2[4] + m1[4]*m2[5] + m1[8]*m2[6] + m1[12]*m2[7];
	matResult[8] = m1[0]*m2[8] + m1[4]*m2[9] + m1[8]*m2[10] + m1[12]*m2[11];
	matResult[12] = m1[0]*m2[12] + m1[4]*m2[13] + m1[8]*m2[14] + m1[12]*m2[15];

	matResult[1] = m1[1]*m2[0] + m1[5]*m2[1] + m1[9]*m2[2] + m1[13]*m2[3];
	matResult[5] = m1[1]*m2[4] + m1[5]*m2[5] + m1[9]*m2[6] + m1[13]*m2[7];
	matResult[9] = m1[1]*m2[8] + m1[5]*m2[9] + m1[9]*m2[10] + m1[13]*m2[11];
	matResult[13] = m1[1]*m2[12] + m1[5]*m2[13] + m1[9]*m2[14] + m1[13]*m2[15];

	matResult[2] = m1[2]*m2[0] + m1[6]*m2[1] + m1[10]*m2[2] + m1[14]*m2[3];
	matResult[6] = m1[2]*m2[4] + m1[6]*m2[5] + m1[10]*m2[6] + m1[14]*m2[7];
	matResult[10] = m1[2]*m2[8] + m1[6]*m2[9] + m1[10]*m2[10] + m1[14]*m2[11];
	matResult[14] = m1[2]*m2[12] + m1[6]*m2[13] + m1[10]*m2[14] + m1[14]*m2[15];

	matResult[3] = m1[3]*m2[0] + m1[7]*m2[1] + m1[11]*m2[2] + m1[15]*m2[3];
	matResult[7] = m1[3]*m2[4] + m1[7]*m2[5] + m1[11]*m2[6] + m1[15]*m2[7];
	matResult[11] = m1[3]*m2[8] + m1[7]*m2[9] + m1[11]*m2[10] + m1[15]*m2[11];
	matResult[15] = m1[3]*m2[12] + m1[7]*m2[13] + m1[11]*m2[14] + m1[15]*m2[15];

}

Vector3* pmultiplyMatrixVector(Vector3 *vOut, float *mat, Vector3* pv)
{	
	vOut->x = pv->x * mat[0] + pv->x * mat[1] + pv->x * mat[2];
	vOut->y = pv->x * mat[3] + pv->y * mat[4] + pv->y * mat[5];
	vOut->z = pv->x * mat[6] + pv->z * mat[7] + pv->z * mat[8];
	return vOut;
}

float determinant44(const float m[16])
{
	return
	m[12]*m[9]*m[6]*m[3]-
	m[8]*m[13]*m[6]*m[3]-
	m[12]*m[5]*m[10]*m[3]+
	m[4]*m[13]*m[10]*m[3]+
	m[8]*m[5]*m[14]*m[3]-
	m[4]*m[9]*m[14]*m[3]-
	m[12]*m[9]*m[2]*m[7]+
	m[8]*m[13]*m[2]*m[7]+
	m[12]*m[1]*m[10]*m[7]-
	m[0]*m[13]*m[10]*m[7]-
	m[8]*m[1]*m[14]*m[7]+
	m[0]*m[9]*m[14]*m[7]+
	m[12]*m[5]*m[2]*m[11]-
	m[4]*m[13]*m[2]*m[11]-
	m[12]*m[1]*m[6]*m[11]+
	m[0]*m[13]*m[6]*m[11]+
	m[4]*m[1]*m[14]*m[11]-
	m[0]*m[5]*m[14]*m[11]-
	m[8]*m[5]*m[2]*m[15]+
	m[4]*m[9]*m[2]*m[15]+
	m[8]*m[1]*m[6]*m[15]-
	m[0]*m[9]*m[6]*m[15]-
	m[4]*m[1]*m[10]*m[15]+
	m[0]*m[5]*m[10]*m[15];
}

int invertMatrix44(const float m[16], float result[16])
{
	float x = determinant44(m);
	if (x==0) return 0;
	
	result[0]= (-m[13]*m[10]*m[7] +m[9]*m[14]*m[7] +m[13]*m[6]*m[11]
		   -m[5]*m[14]*m[11] -m[9]*m[6]*m[15] +m[5]*m[10]*m[15])/x;
	result[4]= ( m[12]*m[10]*m[7] -m[8]*m[14]*m[7] -m[12]*m[6]*m[11]
		   +m[4]*m[14]*m[11] +m[8]*m[6]*m[15] -m[4]*m[10]*m[15])/x;
	result[8]= (-m[12]*m[9]* m[7] +m[8]*m[13]*m[7] +m[12]*m[5]*m[11]
		   -m[4]*m[13]*m[11] -m[8]*m[5]*m[15] +m[4]*m[9]* m[15])/x;
	result[12]=( m[12]*m[9]* m[6] -m[8]*m[13]*m[6] -m[12]*m[5]*m[10]
		   +m[4]*m[13]*m[10] +m[8]*m[5]*m[14] -m[4]*m[9]* m[14])/x;
	result[1]= ( m[13]*m[10]*m[3] -m[9]*m[14]*m[3] -m[13]*m[2]*m[11]
		   +m[1]*m[14]*m[11] +m[9]*m[2]*m[15] -m[1]*m[10]*m[15])/x;
	result[5]= (-m[12]*m[10]*m[3] +m[8]*m[14]*m[3] +m[12]*m[2]*m[11]
		   -m[0]*m[14]*m[11] -m[8]*m[2]*m[15] +m[0]*m[10]*m[15])/x;
	result[9]= ( m[12]*m[9]* m[3] -m[8]*m[13]*m[3] -m[12]*m[1]*m[11]
		   +m[0]*m[13]*m[11] +m[8]*m[1]*m[15] -m[0]*m[9]* m[15])/x;
	result[13]=(-m[12]*m[9]* m[2] +m[8]*m[13]*m[2] +m[12]*m[1]*m[10]
		   -m[0]*m[13]*m[10] -m[8]*m[1]*m[14] +m[0]*m[9]* m[14])/x;
	result[2]= (-m[13]*m[6]* m[3] +m[5]*m[14]*m[3] +m[13]*m[2]*m[7]
		   -m[1]*m[14]*m[7] -m[5]*m[2]*m[15] +m[1]*m[6]* m[15])/x;
	result[6]= ( m[12]*m[6]* m[3] -m[4]*m[14]*m[3] -m[12]*m[2]*m[7]
		   +m[0]*m[14]*m[7] +m[4]*m[2]*m[15] -m[0]*m[6]* m[15])/x;
	result[10]=(-m[12]*m[5]* m[3] +m[4]*m[13]*m[3] +m[12]*m[1]*m[7]
		   -m[0]*m[13]*m[7] -m[4]*m[1]*m[15] +m[0]*m[5]* m[15])/x;
	result[14]=( m[12]*m[5]* m[2] -m[4]*m[13]*m[2] -m[12]*m[1]*m[6]
		   +m[0]*m[13]*m[6] +m[4]*m[1]*m[14] -m[0]*m[5]* m[14])/x;
	result[3]= ( m[9]* m[6]* m[3] -m[5]*m[10]*m[3] -m[9]* m[2]*m[7]
		   +m[1]*m[10]*m[7] +m[5]*m[2]*m[11] -m[1]*m[6]* m[11])/x;
	result[7]= (-m[8]* m[6]* m[3] +m[4]*m[10]*m[3] +m[8]* m[2]*m[7]
		   -m[0]*m[10]*m[7] -m[4]*m[2]*m[11] +m[0]*m[6]* m[11])/x;
	result[11]=( m[8]* m[5]* m[3] -m[4]*m[9]* m[3] -m[8]* m[1]*m[7]
		   +m[0]*m[9]* m[7] +m[4]*m[1]*m[11] -m[0]*m[5]* m[11])/x;
	result[15]=(-m[8]* m[5]* m[2] +m[4]*m[9]* m[2] +m[8]* m[1]*m[6]
		   -m[0]*m[9]* m[6] -m[4]*m[1]*m[10] +m[0]*m[5]* m[10])/x;
	
	return 1;
} 
























