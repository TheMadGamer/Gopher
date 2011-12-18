//
//  Mesh.h
//  Roller
//
//  Created by Caleb Cannon on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "3dmath.h"
#import <OpenGLES/ES2/gl.h>


@interface Mesh : NSObject {
	
	Vector3 position;
	float angle;
	
	Vector3 *vertices;
	int vertexCount;
	
	Vector3 *normals;
	int normalCount;
	int normalStride;
	
	Vector2 *texCoords;
	int texCoordCount;
	
	Color *colors;
	int colorCount;
	int colorStride;
	
	GLint vertexType;	
}

@property (assign) Vector3 position;
@property (assign) float angle;

@property (assign) Vector3 *vertices;
@property (assign) int vertexCount;

@property (assign) Vector3 *normals;
@property(assign) int normalCount;
@property(assign) int normalStride;

@property (assign) GLint vertexType;

- (void) setVertices:(Vector3 *)ptr count:(int)count;
- (void) setNormals:(Vector3 *)ptr count:(int)count stride:(int)stride;
- (void) setTexCoords:(Vector2 *)ptr count:(int)count;
- (void) setColors:(Color *)ptr count:(int)count stride:(int)stride;

- (void) transformPosition;
- (void) transformRotation;
- (void) setTransform;
- (void) draw;
- (void) drawWireFrame;

@end
