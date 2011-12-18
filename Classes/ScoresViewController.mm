//
//  ScoresViewController.m
//  Gopher
//
//  Created by Anthony Lobay on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScoresViewController.h"
#import "GopherAppDelegate.h"
#import "GopherGameController.h"

@implementation ScoresViewController

@synthesize states;
@synthesize delegate;
@synthesize table;

#pragma mark -
#pragma mark View lifecycle

- (IBAction) goBack{
	[[GopherAppDelegate appDelegate].gopherGameController genericViewControllerDidFinish];
}

- (IBAction) resetScores{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Scores?" message:@"Are you Sure?"
												   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[alert show];
	[alert release];
	
	[table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
		if (buttonIndex == 1){
			[self.delegate resetPlayedLevels];
		}
	
}

#pragma mark -
#pragma mark === View configuration ===
#pragma mark -

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

// show in landscap right
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


#pragma mark -
#pragma mark Table view data source

- (NSArray *) states
{
	if (!states)
	{				
		NSString *path = [[NSBundle mainBundle] pathForResource:[GopherGameController levelPlist] ofType:nil];		
		states = [[NSArray arrayWithContentsOfFile:path] retain];
	}
	
	return states;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.states count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.states objectAtIndex:indexPath.row] valueForKey:@"group"])
		return 38.0;
	else
		return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = nil;
	
	if ([[self.states objectAtIndex:indexPath.row] valueForKey:@"group"])
	{
		// These cells are fake table headers for the group names.  I was having too many problems
		// using the viewForHeaderInSection (one pixel offsets when the headers stop at the top of the view)
		// methods so I gave up
		
		cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewHeader"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TableViewHeader"] autorelease];
		}
		
		cell.backgroundColor = [UIColor clearColor];
		cell.opaque = NO;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		NSDictionary *dict = [self.states objectAtIndex:indexPath.row];
		cell.textLabel.text = [dict valueForKey:@"title"];
		cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenBlueGrad.png"]]; 
	}
	
	else 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
		
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TableViewCell"] autorelease];
		}
		
		NSDictionary *levelDictionary = [self.states objectAtIndex:indexPath.row];
		NSString* levelName = [levelDictionary valueForKey:@"title"];
		NSString* levelFile = [levelDictionary valueForKey:@"filename"];
		
		cell.backgroundView = [[[UIImageView alloc] init] autorelease];
		cell.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		int score = [delegate getScore:levelFile];
		NSNumber *number = [NSNumber numberWithInt:score];
		
		cell.textLabel.text = [levelName stringByAppendingFormat:@" - %@", number];
		
		int highScore = [delegate getScore:levelFile];
		if(highScore > 0)
		{
			UIImageView *accessoryView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32, 32.0)] autorelease];
			accessoryView.image = [UIImage imageNamed:@"Carrot32.png"];
			cell.accessoryView = accessoryView;
		}
		else {
			UIImageView *accessoryView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32, 32.0)] autorelease];
			accessoryView.image = [UIImage imageNamed:@"EmptyCarrot32.png"];
			cell.accessoryView = accessoryView;
		}
		
		//int colorID = [[levelDictionary valueForKey:@"colorID"] intValue];
		

		cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"RedYellowGrad.png"]];  // [UIColor redColor];
		
	}
	
	cell.textLabel.shadowColor = [UIColor blackColor];
	cell.textLabel.shadowOffset = CGSizeMake(2, 2);
	cell.textLabel.font=[UIFont fontWithName:@"MarkerFelt-Thin" size:24.0];
	
	
	//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

