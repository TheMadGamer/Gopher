//
//  Mesh.m
//  Roller
//
//  Created by Caleb Cannon on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Mesh.h"


@implementation Mesh

@synthesize position, angle;
@synthesize vertices, vertexCount;
@synthesize normals, normalCount, normalStride;
@synthesize vertexType;

- (void) setVertices:(Vector3 *)ptr count:(int)count
{
	vertices = ptr;
	if (ptr == nil)
		vertexCount = 0;
	else
		vertexCount = count;
}


- (void) setNormals:(Vector3 *)ptr count:(int)count stride:(int)stride
{
	normals = ptr;
	
	if (ptr == nil)
	{
		normalCount = 0;
		normalStride = 0;
	}
	else
	{
		normalCount = count;
		normalStride = stride;
	}
}


- (void) setTexCoords:(Vector2 *)ptr count:(int)count
{
	texCoords = ptr;
	if (ptr = nil)
		texCoordCount = 0;
	else
		texCoordCount = count;
}


- (void) setColors:(Color *)ptr count:(int)count stride:(int)stride
{
	colors = ptr;
	
	if (ptr == nil)
	{
		colorCount = 0;
		colorStride = 0;
	}
	else
	{
		colorCount = count;
		colorStride = stride;
	}
}


- (void) transformPosition
{
	glTranslatef(position.x, position.y, position.z);
}	


- (void) transformRotation
{
	glRotatef(angle, 0.0, 0.0, 1.0);
}


- (void) setTransform
{
	[self transformPosition];
	[self transformRotation];
}


- (void) draw
{	
	// To-Do: add support for creating and holding a display list
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	if (colors)
	{
		glColorPointer(4, GL_FLOAT, 0, colors);
		glEnableClientState(GL_COLOR_ARRAY);
	}
	if (normals)
	{
		glNormalPointer(GL_FLOAT, 0, normals);
		glEnableClientState(GL_NORMAL_ARRAY);
	}
	if (texCoords)
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	}
	
	glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

- (void) drawWireFrame
{	
	// To-Do: add support for creating and holding a display list
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}


- (void) dealloc
{
	free(vertices);
	if (colors)
		free(colors);
	if (normals)
		free(normals);
	if (texCoords)
		free(texCoords);

	[super dealloc];
}

@end
