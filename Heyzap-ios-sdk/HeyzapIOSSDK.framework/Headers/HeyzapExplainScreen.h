//
//  HeyzapExplainScreen.h
//  HeyzapIOSSDK
//
//  Created by Andrew Evans on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface HeyzapExplainScreen : UIViewController {
}

- (void) doneButtonTapped:(id)sender;
- (void) appStoreButtonTapped:(id)sender;

@end
