//
//  HeyzapCheckinButtonText.h
//  HeyzapIOSSDK
//
//  Created by Andrew Evans on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeyzapCheckinButtonText : UIView {
    UIImageView *imageView;
    BOOL seen;
}

@property (nonatomic, retain) UIImageView *imageView;

- (void) setupSubviews;
- (void) buttonTapped:(UIGestureRecognizer *)gesture;

@end
