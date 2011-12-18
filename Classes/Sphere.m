//
//  SteelBearing.m
//  Roller
//
//  Created by Caleb Cannon on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Sphere.h"

#import "Texture2D.h"


@implementation Sphere

@synthesize velocity, oldPosition, oldVelocity;
@synthesize staticForces, linearForces, quadraticForces;
@synthesize mass, radius;
@synthesize textureName;

+ (Sphere *) sphereWithRadius:(float)r rings:(int)rings slices:(int)slices
{
	Sphere *sphere = [[[Sphere alloc] init] autorelease];

	sphere.radius = r;
	r /= 2.0;
	
	if (!sphere)
		return nil;

	int count = 6*rings*slices;
	
	Vector3 *vertices = malloc(sizeof(Vector3)*count);
	Vector3 *normals = malloc(sizeof(Vector3)*count);
//	Vector2 *texCoords = malloc(sizeof(Vector2)*count);
	Color *colors = malloc(sizeof(Color)*count);
		
	float theta = 0.0, phi = 0.0;
	float dTheta = PI / (float)(rings);
	float dPhi = 2.0*PI / (float)(slices-1);
	
	int i, j;
	int v = 0;
	int n = 0;
	int c = 0;
	
	for (i = 0; i < rings; i++)
	{
		for (j = 0; j < slices; j++)
		{
			normals[n++] = vec3(cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi));
			vertices[v++] = vec3scale(normals[n-1], r);
			normals[n++] = vec3(cos(theta+dTheta)*sin(phi+dPhi), sin(theta+dTheta)*sin(phi+dPhi), cos(phi+dPhi));
			vertices[v++] = vec3scale(normals[n-1], r);
			normals[n++] = vec3(cos(theta)*sin(phi+dPhi), sin(theta)*sin(phi+dPhi), cos(phi+dPhi));
			vertices[v++] = vec3scale(normals[n-1], r);
			
			normals[n++] = vec3(cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi));
			vertices[v++] = vec3scale(normals[n-1], r);
			normals[n++] = vec3(cos(theta+dTheta)*sin(phi), sin(theta+dTheta)*sin(phi), cos(phi));
			vertices[v++] = vec3scale(normals[n-1], r);
			normals[n++] = vec3(cos(theta+dTheta)*sin(phi+dPhi), sin(theta+dTheta)*sin(phi+dPhi), cos(phi+dPhi));
			vertices[v++] = vec3scale(normals[n-1], r);
			
//			vertices[v++] = vec3(r*cos(theta)*sin(phi), r*sin(theta)*sin(phi), r*cos(phi));
//			vertices[v++] = vec3(r*cos(theta+dTheta)*sin(phi+dPhi), r*sin(theta+dTheta)*sin(phi+dPhi), r*cos(phi+dPhi));
//			vertices[v++] = vec3(r*cos(theta)*sin(phi+dPhi), r*sin(theta)*sin(phi+dPhi), r*cos(phi+dPhi));

//			vertices[v++] = vec3(r*cos(theta)*sin(phi), r*sin(theta)*sin(phi), r*cos(phi));
//			vertices[v++] = vec3(r*cos(theta+dTheta)*sin(phi), r*sin(theta+dTheta)*sin(phi), r*cos(phi));
//			vertices[v++] = vec3(r*cos(theta+dTheta)*sin(phi+dPhi), r*sin(theta+dTheta)*sin(phi+dPhi), r*cos(phi+dPhi));
			
			phi += dPhi;
			
			colors[c++] = color(1.0, 1.0, 1.0, 1.0);
			colors[c++] = color(1.0, 1.0, 1.0, 1.0);
			colors[c++] = color(1.0, 1.0, 1.0, 1.0);
			colors[c++] = color(1.0, 1.0, 1.0, 1.0);
			colors[c++] = color(1.0, 1.0, 1.0, 1.0);
			colors[c++] = color(1.0, 1.0, 1.0, 1.0);
		}
		
		theta += dTheta;
	}
	
	[sphere setVertices:vertices count:v-1];
	[sphere setNormals:normals count:6 stride:4];
//	[sphere setTexCoords:texCoords count:24];
//	[sphere setColors:colors count:1 stride:4];
	[sphere setVertexType:GL_TRIANGLES];
	
	return sphere;
}

- (id) init
{
	if (self = [super init])
	{
		texture = [[[Texture2D alloc] initWithImagePath:[[NSBundle mainBundle] pathForResource:@"steel_ball" ofType:@"png"]] retain];
		self.mass = 1.0;
	}

	return self;
}


// Integrates the position and velocity using the Runge-Kutta method
- (void) integratePositionWithTimeStep:(double)dt
{	
	Vector3 a, b, c, d;
	
	// Integrate acceleration
	Vector3 tAccel = {
		staticForces.x + linearForces.x * velocity.x + quadraticForces.x * velocity.x * velocity.x,
		staticForces.y + linearForces.y * velocity.y + quadraticForces.y * velocity.y * velocity.y,
		0.0
	};
	
	a = tAccel;
	b = tAccel;
	c = tAccel;
	d = tAccel;
	
	oldVelocity = velocity;
	velocity = vec3( 
					velocity.x + dt/6.0 * (a.x + 2.0*b.x + 2.0*c.x + d.x),
					velocity.y + dt/6.0 * (a.y + 2.0*b.y + 2.0*c.y + d.y),
					velocity.z
					);
	
	// Test for rest condition - if the velocity is low and the position
	// is static then dont update
	
	// Integrate velocity
	a = oldVelocity;
	b = vec3sum(velocity, oldVelocity);
	b = vec3scale(b, 0.5);
	c = b;
	d = velocity;
	
	oldPosition = position;	
	position = vec3( 
					position.x + dt/6.0 * (a.x + 2.0*b.x + 2.0*c.x + d.x),
					position.y + dt/6.0 * (a.y + 2.0*b.y + 2.0*c.y + d.y),
					position.z
					);
}


- (void) draw
{
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	[self setTransform];
	[self setMaterial];
	[super draw];

	//	[self drawWireFrame];
	glPopMatrix();
}

- (void) setMaterial
{
	GLfloat mat_ambient[] = { 0.25, 0.25, 0.25, 1.0 };
	GLfloat mat_diffuse[] = { 0.4, 0.4, 0.4, 1.0 };
	GLfloat mat_specular[] = { 0.774597, 0.774597, 0.774597, 1.0 };
	GLfloat mat_shininess[] = { 0.6 };
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mat_ambient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_diffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
}

- (void) __draw
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glColor4f(1.0, 1.0, 1.0, 1.0);
//	[texture drawAtPoint:CGPointMake(self.position.x, self.position.y)];
	glPushMatrix();
	[texture drawInRect:CGRectMake(self.position.x - radius, self.position.y - radius, radius*2.0, radius*2.0) depth:position.z];
	glPopMatrix();
}


@end
