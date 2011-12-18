//
//  CollisionTests.h
//  Roller
//
//  Created by Caleb Cannon on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "3dmath.h"
#import "Sphere.h"
#import "Box.h"


BOOL sphereCollideWithSphere(Sphere *sphere1, Sphere *sphere2);
BOOL sphereCollideWithBox(Sphere *sphere, Box *box);
BOOL sphereCollideWithBounds(Sphere *sphere, float boundWidth, float boundHeight);