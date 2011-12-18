//
//  NSIndexSet+Extensions.m
//  GameBox
//
//  Created by Caleb Cannon on 2/26/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import "NSIndexSet+Extensions.h"


@implementation NSIndexPath (Extensions)

- (NSString *) keyValue
{
	if ([self length] == 0)
		return nil;
	
	NSString *key = [NSString stringWithFormat:@"%i", [self indexAtPosition:0]];
	for (int i = 1; i < [self length]; i++)
		key = [key stringByAppendingFormat:@"-%i", [self indexAtPosition:i]];

	return key;
}

@end
