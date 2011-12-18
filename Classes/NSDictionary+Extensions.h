//
//  NSDictionary+Extensions.h
//  GameBox
//
//  Created by Caleb Cannon on 1/30/10.
//  Copyright 2010 Caleb Cannon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Extensions)

- (int) integerValueForKey:(NSString *)key;
- (float) floatValueForKey:(NSString *)key;
- (double) doubleValueForKey:(NSString *)key;
- (BOOL) boolValueForKey:(NSString *)key;

@end
