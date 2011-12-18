//
//  InstructionsViewController.h
//  Gopher
//
//  Created by Anthony Lobay on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstructionsViewControllerDelegate;


@interface InstructionsViewController : UIViewController {
	id <InstructionsViewControllerDelegate> delegate;
	IBOutlet UIImageView *instructionView;	
	IBOutlet UIView *buttonView;
	
	NSString* levelToLoad;
	int frameIndex;
	
}


@property (nonatomic, assign) id <InstructionsViewControllerDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIImageView *instructionView;

@property (nonatomic, assign) NSString* levelToLoad;

- (IBAction) NextFrame:(id) sender;

@end

@protocol InstructionsViewControllerDelegate
- (void)instructionsViewControllerDidFinish:(InstructionsViewController *)controller withSelectedLevel:(NSString *)levelName;
@end