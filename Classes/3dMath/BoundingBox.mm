/*
 *  BoundingBox.c
 *  Dice Pod
 *
 *  Created by Caleb Cannon on 6/5/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "BoundingBox.h"

#define SMALL_NUM 0.0000001

/*
int rayTriangleIntersect(Vector3 *p1, Vector3 *p2, Vector3 *v0, Vector3 *v1, Vector3 *v2, Vector3 *intersectionPoint)
{
	Vector3	 D, e1, e2, P, T, Q;
	float	 det, inv_det, u, v, t;
	
	// calculate length of vector
	pvec3diff(&D, p2, p1);
	
	// calculate triangle edges
	pvec3diff(&e1, v1, v0);
	
	pvec3diff(&e2, v2, v0);
	
	pvec3cross(&P, &D, &e2);
	det = (e1.x*P.x) + (e1.y*P.y) + (e1.z*P.z);
	
	// parallel ray-triangles do not intersect.
	if (det==0.0)
		return 0;
	
	inv_det = 1.0/det;
	
	pvec3diff(&T, p1, v0);
	
	u = ((T.x*P.x) + (T.y*P.y) + (T.z*P.z))*inv_det;
	
	if (u<0.0 || u>1.0)
		return 0;	// u range error
	
	pvec3cross(&Q, &T, &e1);
	
	v = ((D.x*Q.x) + (D.y*Q.y) + (D.z*Q.z))*inv_det;
	
	if (v<0.0 || u+v>1.0)
		return 0;	// v range error
	
	
	t = (((e2.x*Q.x) + (e2.y*Q.y) + (e2.z*Q.z))*inv_det);
	
	pvec3sum(intersectionPoint, p1, pvec3scale(&D, &D, t));
	
	printf("U: %f V: %f I: %f %f %f\n", u, v, intersectionPoint->x, intersectionPoint->y, intersectionPoint->z);
	
	return 1;
}
*/