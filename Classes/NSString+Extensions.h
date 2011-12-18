//
//  NSString+Extensions.h
//  GameBox
//
//  Created by Caleb Cannon on 2/26/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSString (Extensions)

+ (NSString *) userDirectory;
+ (NSString *) pathForUserFile:(NSString *)filename;
- (NSString *) stringByExpandingToUserDirectory;

@end
