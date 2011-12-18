//
//  ScoresViewController.h
//  Gopher
//
//  Created by Anthony Lobay on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"

@protocol ScoresViewDelegate

// reset 
- (void) resetPlayedLevels;

@end

@interface ScoresViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>  {
	id <PreferencesViewControllerDelegate, ScoresViewDelegate> delegate;
	NSArray *states;
	IBOutlet UITableView *table;

}

@property (nonatomic, assign) IBOutlet UITableView *table;
@property (nonatomic, assign) id <PreferencesViewControllerDelegate, ScoresViewDelegate> delegate;
@property (nonatomic, retain) NSArray *states;

- (IBAction) goBack;
- (IBAction) resetScores;

@end
