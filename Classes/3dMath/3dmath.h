#include "math.h"
#include "stdlib.h"
#include "Vector2.h"
#include "Vector3.h"
#include "BoundingBox.h"
#include "Materials.h"

#import <OpenGLES/ES1/gl.h>

#define PI 3.14159265
#define GRAVITY 9.80665

typedef struct {
	float x, y, z, w;
} Vector4;

typedef struct {
	float r, g, b;
} Color3;

typedef struct {
	float r, g, b, a;
} Color, Color4;

typedef struct {
	float width, height;
} Size2;

typedef struct {
	float width, height, depth;
} Size3;

typedef struct {
	float x, y, z, q;
} Quaternion, Quat;

typedef struct {
	float _11;
	float _12;
	float _13;
	float _21;
	float _22;
	float _23;
	float _31;
	float _32;
	float _33;
} Matrix3;

typedef struct {
	float _11;
	float _12;
	float _13;
	float _14;
	float _21;
	float _22;
	float _23;
	float _24;
	float _31;
	float _32;
	float _33;
	float _34;
	float _41;
	float _42;
	float _43;
	float _44;
} Matrix4;

#define Vertex Vector3

Vector2 vec2(float x, float y);

Color color(float r, float g, float b, float a);

void rotationMatrix3x3(float angle, Vector3 *v1, float *mat);

// Util
float min(float a, float b);
float max(float a, float b);
float clamp(float x, float a, float b);
float easeInExp(float x, float e1, float e2, float tension);
float clampToSteps(float x, float stepWidth);
float sign(float x);
float randFloat(float low, float high);

void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);
void gluLookAt( GLfloat eyeX, GLfloat eyeY, GLfloat eyeZ, GLfloat centerX, GLfloat centerY, GLfloat centerZ, GLfloat upX, GLfloat upY, GLfloat upZ );

//int segmentPlaneIntersectionTest(Vector3 p1, Vector3 p2, Vector3 v, Vector3 n, Vector3 *result);
//int pointInTriangleTest(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3);
//int rayTriangleCollisionTest(Vector3 v1, Vector3 v2, Vector3 t1, Vector3 t2, Vector3 t3, Vector3 *collisionPoint);