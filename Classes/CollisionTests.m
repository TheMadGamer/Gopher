//
//  CollisionTests.m
//  Roller
//
//  Created by Caleb Cannon on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CollisionTests.h"

BOOL sphereCollideWithSphere(Sphere *sphere1, Sphere *sphere2)
{
	Vector3 diff = vec3diff(sphere1.position, sphere2.position);
	
	if (vec3lensq(diff) < powf(sphere1.radius + sphere2.radius, 2.0))
	{
		Vector3 n, v1, v2, v1x, v1y, v2x, v2y;;
		float x1, x2, m1, m2, rm;
		
		n = vec3norm(diff);

		v1 = sphere1.velocity;
		v2 = sphere2.velocity;
		
		x1 = vec3dot(n, v1);
		x2 = vec3dot(n, v2);
		
		v1x = vec3scale(n, x1);
		v1y = vec3diff(v1, v1x);
		
		v2x = vec3scale(n, x2);
		v2y = vec3diff(v2, v2x);
		
		m1 = sphere1.mass;
		m2 = sphere2.mass;
		
		rm = (m1 - m2) / (m1 + m2);
		
		v1 = vec3sum(v1y, vec3sum(vec3scale(v1x, rm), vec3scale(v2x, 2.0 * m2 / (m1 + m2))));
		v2 = vec3sum(v2y, vec3sum(vec3scale(v1x, 2.0 * m1 / (m1 + m2)), vec3scale(v2x, rm)));
		
		sphere1.velocity = v1;
		sphere2.velocity = v2;
		
		return YES;
	}
	
	return NO;
}


BOOL sphereCollideWithBox(Sphere *sphere, Box *box)
{ 
	Vector3 p = vec3diff(sphere.position, box.position);
	p = vec3rotatez(p, (box.angle * PI) / 180.0);
	p = vec3sum(p, box.position);
	
	Vector3 v = vec3diff(sphere.velocity, box.position);
	v = vec3rotatez(v, (box.angle * PI) / 180.0);
	v = vec3sum(v, box.position);
	
	float r = sphere.radius;
	
	Vector3 n = vec3(0.0, 0.0, 0.0);
	int colCount = 0;
	
	float w = box.width/2.0;
	float h = box.height/2.0;
	
	// Test left-right edges
	if (p.y + r >= -h + box.position.y && 
		p.y - r <= h + box.position.y)
	{
		if (p.x + r >= w + box.position.x &&
			p.x - r <= w + box.position.x &&
			v.x <= 0.0)
		{
			colCount += 1;
			n = vec3sum(n, vec3(1.0, 0.0, 0.0));
		}
		if (p.x + r >= -w + box.position.x &&
			p.x - r <= -w + box.position.x &&
			v.x >= 0.0)
		{
			colCount += 1;
			n = vec3sum(n, vec3(-1.0, 0.0, 0.0));
		}
	}

	// Test top-bottom edges
	if (p.x + r >= -w + box.position.x && 
			 p.x - r <= w + box.position.x)
	{
		if (p.y + r >= h + box.position.y &&
			p.y - r <= h + box.position.y &&
			v.y <= 0.0)
		{
			colCount += 1;
			n = vec3sum(n, vec3(0.0, 1.0, 0.0));
		}
		if (p.y + r >= -h + box.position.y &&
			p.y - r <= -h + box.position.y &&
			v.y >= 0.0)
		{
			colCount += 1;
			n = vec3sum(n, vec3(0.0, -1.0, 0.0));
		}
	}
	
	if (colCount > 0)
	{
		if (colCount > 1)
		{
			NSLog(@"N1: %f %f %f", n.x, n.y, n.z);
			n = vec3norm(n);
			NSLog(@"N2: %f %f %f", n.x, n.y, n.z);
		}
		
		if (0)
		{
			Vector3 v = sphere.velocity;
			v = vec3rotatez(v, (box.angle * PI) / 180.0);
			v = vec3diff(v, vec3scale(n, 2.0 * vec3dot(v, n)));
			v = vec3rotatez(v, -(box.angle * PI) / 180.0);
			sphere.velocity = v;
		}
		else
		{
			n = vec3rotatez(n, -(box.angle * PI) / 180.0);
			Vector3 v = sphere.velocity;
			v = vec3diff(v, vec3scale(n, 2.0 * vec3dot(v, n)));
			sphere.velocity = v;
		}
		
		return YES;
	}
	
	return NO;
}

BOOL sphereCollideWithBounds(Sphere *sphere, float boundWidth, float boundHeight)
{
	Vector3 v = sphere.velocity;
	BOOL change = NO;
	
	if (sphere.position.x - sphere.radius <= -boundWidth / 2.0)
	{
		v.x = fabs(sphere.velocity.x);
		change = YES;
	}

	if (sphere.position.x + sphere.radius >= boundWidth / 2.0)
	{
		v.x = -fabs(sphere.velocity.x);
		change = YES;
	}

	if (sphere.position.y - sphere.radius <= -boundHeight / 2.0)
	{
		v.y = fabs(sphere.velocity.y);
		change = YES;
	}


	if (sphere.position.y + sphere.radius >= boundHeight / 2.0)
	{
		v.y = -fabs(sphere.velocity.y);
		change = YES;
	}

	if (change)
	{
		sphere.velocity = v;
	}

	return change;

}