/*
 *  Materials.c
 *  Roller
 *
 *  Created by Caleb Cannon on 7/13/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "Materials.h"

void setMaterial(GLfloat *mat_ambient, GLfloat *mat_diffuse, GLfloat *mat_specular, GLfloat *mat_shininess)
{
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mat_ambient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_diffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
}

void materialWhite()
{
	GLfloat mat_ambient[] = { 1.0, 1.0, 1.0, 1.0 };
	GLfloat mat_diffuse[] = { 1.0, 1.0, 1.0, 1.0 };
	GLfloat mat_specular[] = { 0.0, 0.0, 0.0, 1.0 };
	GLfloat mat_shininess[] = { 0.0 };
	
	setMaterial(mat_ambient, mat_diffuse, mat_specular, mat_shininess);
}

void materialFlatWhite()
{
	GLfloat mat_ambient[] = { 0.5, 0.5, 0.5, 1.0 };
	GLfloat mat_diffuse[] = { 0.9, 0.9, 0.9, 1.0 };
	GLfloat mat_specular[] = { 0.7, 0.7, 0.7, 1.0 };
	GLfloat mat_shininess[] = { 0.078125 };
	
	setMaterial(mat_ambient, mat_diffuse, mat_specular, mat_shininess);
}

void materialChrome()
{
	GLfloat mat_ambient[] = { 0.25, 0.25, 0.25, 1.0 };
	GLfloat mat_diffuse[] = { 0.4, 0.4, 0.4, 1.0 };
	GLfloat mat_specular[] = { 0.774597, 0.774597, 0.774597, 1.0 };
	GLfloat mat_shininess[] = { 0.6 };
	
	setMaterial(mat_ambient, mat_diffuse, mat_specular, mat_shininess);
}
