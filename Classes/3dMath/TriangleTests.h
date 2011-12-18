/*
 *  TriangleTests.h
 *  Dice Pod
 *
 *  Created by Caleb Cannon on 6/29/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "3dmath.h"

int triangleIntersection(Vector3 t1_1, Vector3 t1_2, Vector3 t1_3, Vector3 t2_1, Vector3 t2_2, Vector3 t2_3, Vector3 *intersectionPoint);

int tri_tri_intersect(float V0[3],float V1[3],float V2[3],
                      float U0[3],float U1[3],float U2[3]);

int NoDivTriTriIsect(float V0[3],float V1[3],float V2[3],
                     float U0[3],float U1[3],float U2[3]);

inline void isect2(float VTX0[3],float VTX1[3],float VTX2[3],float VV0,float VV1,float VV2,
				   float D0,float D1,float D2,float *isect0,float *isect1,float isectpoint0[3],float isectpoint1[3]);

inline int compute_intervals_isectline(float VERT0[3],float VERT1[3],float VERT2[3],
									   float VV0,float VV1,float VV2,float D0,float D1,float D2,
									   float D0D1,float D0D2,float *isect0,float *isect1,
									   float isectpoint0[3],float isectpoint1[3]);

int tri_tri_intersect_with_isectline(float V0[3],float V1[3],float V2[3],
									 float U0[3],float U1[3],float U2[3],int *coplanar,
									 float isectpt1[3],float isectpt2[3]);