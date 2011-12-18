//
//  GopherAppDelegate.h
//  Gopher
//

//  Copyright 3dDogStudios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GopherGameController.h"


@interface GopherAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	GopherGameController *myViewController;
}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) GopherGameController *gopherGameController;

+ (GopherAppDelegate *) appDelegate;

@end

