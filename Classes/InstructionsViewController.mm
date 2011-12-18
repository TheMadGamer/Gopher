//
//  InstructionsViewController.mm
//  Gopher
//
//  Created by Anthony Lobay on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InstructionsViewController.h"
#import "SceneManager.h"


@implementation InstructionsViewController

@synthesize instructionView;

@synthesize delegate;

@synthesize levelToLoad;

using namespace Dog3D;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	frameIndex = 1;
	
}

- (void)viewWillAppear:(BOOL)animated
{
	if(![levelToLoad isEqualToString:@"Basics"])
	{
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:levelToLoad];
		NSDictionary *rootDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		
		NSDictionary *controlDictionary = [[rootDictionary objectForKey:@"LevelControl"] retain];
		
		SceneManager::LevelControlInfo levelControl(controlDictionary);
		
		NSString* imageName;
		
		
		if(levelControl.mPlayMode == GamePlayManager::CANNON ||
		   levelControl.mPlayMode == GamePlayManager::SWARM_CANNON || 
		   levelControl.mPlayMode == GamePlayManager::RUN_CANNON ||
		   levelControl.mPlayMode == GamePlayManager::RICOCHET)
		{
			imageName = @"Instructions_Cannon.png";
		}
		else if(levelControl.mPlayMode == GamePlayManager::POOL)
		{
			imageName = @"Instructions_Tap.png";
		}
		else {
			imageName = @"Instructions_Tilt.png";
		}
		
		instructionView.image = [UIImage imageNamed:imageName];
		[controlDictionary release];
		[rootDictionary release];
	}
}

// show in landscap right
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

- (IBAction) NextFrame:(id) sender;
{
	if([levelToLoad isEqualToString:@"Basics"])
	{
		if(frameIndex == 1 ) 
		{
			
			frameIndex++;
			
			NSString* imageName = @"Instructions_Goal.png";

			instructionView.image = [UIImage imageNamed:imageName];
			
		}
		else if(frameIndex == 2){
			
			NSString* imageName = @"Instructions_Tilt.png";
			
			
			instructionView.image = [UIImage imageNamed:imageName];
			frameIndex++;
		}
		else
		{
			
			[self.delegate instructionsViewControllerDidFinish:self withSelectedLevel:levelToLoad];
			frameIndex++;
		}
		
		
	}
	else 
	{
		[self.delegate instructionsViewControllerDidFinish:self withSelectedLevel:levelToLoad];
		
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
