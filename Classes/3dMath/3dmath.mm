#include "3dmath.h"

void rotationMatrix3x3(float angle, Vector3 *v1, float *mat)
{
	float x = v1->x;
	float y = v1->y;
	float z = v1->z;
	
	float ca = cos(angle);
	float sa = sin(angle);
	
	mat[0] = (1-x*x)*ca + x*x;
	mat[1] = -z*sa - x*y*ca + x*y;
	mat[2] = -y*sa - x*z*ca + x*z;
	mat[3] = z*sa - x*y*ca + x*y;
	mat[4] = (1-y*y)*ca + y*y;
	mat[5] = -x*sa - y*z*ca + y*z;
	mat[6] = -y*sa - x*z*ca + x*z;
	mat[7] = x*sa - y*z*ca + y*z;
	mat[8] = (1-z*z)*ca + z*z;
}

Color color(float r, float g, float b, float a)
{
	Color c = { r, g, b, a };
	return c;
}

float min(float a, float b)
{
	return (a < b) ? a : b;
}

float max(float a, float b)
{
	return (a > b) ? a : b;
}

float clamp(float x, float e1, float e2)
{
	return max(e1, min(e2, x));
}

float easeInExp(float x, float e1, float e2, float tension)
{
	return ( exp(clamp(x, e1, e2)*tension) - exp(e1*tension) ) / ( exp(e2*tension) - exp(e1*tension) );
}

float clampToSteps(float x, float stepWidth)
{
	return (float)round(x / stepWidth) * stepWidth;
}

float sign(float x) { return (x > 0.0) ? 1.0 : (x < 0.0) ? -1.0 : 0.0; }

float randFloat(float low, float high)
{
	float temp;
	
	/* swap low & high around if the user makes no sense */
	if (low > high)
	{
		temp = low;
		low = high;
		high = temp;
	}
	
	/* calculate the random number & return it */
	temp = (rand() / ((float)(RAND_MAX) + 1.0)) * (high - low) + low;
	return temp;
}

void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
	GLfloat f = 1.0 / tan(fovy/2.0);
	
	
	GLfloat matrix[] = { f/aspect,	0.0,	0.0,							0.0,
						 0.0,		f,		0.0,							0.0,
						 0.0,		0.0,	(zNear+zFar)/(zNear-zFar),		-1.0,
						 0.0,		0.0,	(2.0*zNear*zFar)/(zNear-zFar),	0.0 };
	
	glMultMatrixf(matrix);
	
	glDepthRangef(zNear, zFar);
}

void gluLookAt( GLfloat eyeX, GLfloat eyeY, GLfloat eyeZ, GLfloat centerX, GLfloat centerY, GLfloat centerZ, GLfloat upX, GLfloat upY, GLfloat upZ )
{
	Vector3 F = vec3(centerX - eyeX, centerY - eyeY, centerZ - eyeZ);
	Vector3 f = vec3norm(F);
	
	Vector3 U = vec3(upX, upY, upZ);
	Vector3 u = vec3norm(U);
	
	Vector3 s = vec3cross(f, u);
	Vector3 t = vec3cross(s, f);
	
	GLfloat matrix[] = { s.x, t.x, -f.x, 0.0,
						 s.y, t.y, -f.y, 0.0,
						 s.z, t.z, -f.z, 0.0,
						 0.0, 0.0, 0.0, 1.0 };
	
	glMultMatrixf(matrix);
	glTranslatef(-eyeX, -eyeY, -eyeZ);
}

