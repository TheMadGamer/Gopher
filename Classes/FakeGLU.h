//
//  FakeGLU.h
//  
//
//  Created by Anthony Lobay on 1/19/10.
//  Copyright 2010 3dDogStudios. All rights reserved.
//


#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

void gluPerspective(double fovy, double aspect, double zNear, double zFar);

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
			   GLfloat centerx, GLfloat centery, GLfloat centerz,
			   GLfloat upx, GLfloat upy, GLfloat upz);