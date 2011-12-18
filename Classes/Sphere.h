Vector3//
//  SteelBearing.h
//  Roller
//
//  Created by Caleb Cannon on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mesh.h"

#import <OpenGLES/ES1/gl.h>
#import "Texture2D.h"


@interface Sphere : Mesh {

	Vector3 velocity;
	Vector3 oldPosition;
	Vector3 oldVelocity;
	
	
	Vector3 staticForces;
	Vector3 linearForces;
	Vector3 quadraticForces;
	
	float mass;
	float radius;
	
	GLint textureName;
	
	Texture2D *texture;
}

@property (assign) Vector3 velocity;
@property (assign) Vector3 oldPosition;
@property (assign) Vector3 oldVelocity;

@property (assign) Vector3 staticForces;
@property (assign) Vector3 linearForces;
@property (assign) Vector3 quadraticForces;

@property (assign) float mass;
@property (assign) float radius;

@property (assign) GLint textureName;

+ (Sphere *) sphereWithRadius:(float)r rings:(int)rings slices:(int)slices;

- (void) draw;
- (void) setMaterial;

- (void) integratePositionWithTimeStep:(double)dt;

@end
