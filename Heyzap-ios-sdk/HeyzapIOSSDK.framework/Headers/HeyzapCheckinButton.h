//
//  HeyzapCheckinButton.h
//  HeyzapIOSSDK
//
//  Created by Andrew Evans on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HeyzapCheckinButton : UIView {
    UIImageView *imageView;
    BOOL seen;
}

@property (nonatomic, retain) UIImageView *imageView;

- (void) setupSubviews;
- (void) buttonTapped:(UIGestureRecognizer *)gesture;

@end
