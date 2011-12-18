/*
 *  Materials.h
 *  Roller
 *
 *  Created by Caleb Cannon on 7/13/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>

void setMaterial(GLfloat *mat_ambient, GLfloat *mat_diffuse, GLfloat *mat_specular, GLfloat *mat_shininess);
void materialWhite();
void materialFlatWhite();
void materialChrome();
