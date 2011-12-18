//
//  NSString+Extensions.m
//  GameBox
//
//  Created by Caleb Cannon on 2/26/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import "NSString+Extensions.h"


@implementation NSString (Extensions)


+ (NSString *) userDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *userDirectory = [paths objectAtIndex:0];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	BOOL exists, isDirectory;
	exists = [fileManager fileExistsAtPath:userDirectory isDirectory:&isDirectory];
	if (!exists || !isDirectory)
		[fileManager createDirectoryAtPath:userDirectory attributes:nil];
	
	return userDirectory;
}

+ (NSString *) pathForUserFile:(NSString *)filename
{
	return [[NSString userDirectory] stringByAppendingPathComponent:filename];
}

- (NSString *) stringByExpandingToUserDirectory
{
	return [[NSString userDirectory] stringByAppendingPathComponent:self];
}

@end
