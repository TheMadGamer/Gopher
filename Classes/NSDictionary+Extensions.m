//
//  NSDictionary+Extensions.m
//  GameBox
//
//  Created by Caleb Cannon on 1/30/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import "NSDictionary+Extensions.h"


@implementation NSDictionary (Extensions)

- (int) integerValueForKey:(NSString *)key
{
	return [[self valueForKey:key] intValue];
}

- (float) floatValueForKey:(NSString *)key
{
	return [[self valueForKey:key] floatValue];
}

- (double) doubleValueForKey:(NSString *)key
{
	return [[self valueForKey:key] doubleValue];
}

- (BOOL) boolValueForKey:(NSString *)key
{
	return [[self valueForKey:key] boolValue];
}


@end
