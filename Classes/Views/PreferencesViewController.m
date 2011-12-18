#import "PreferencesViewController.h"

@implementation PreferencesViewController

@synthesize delegate;

@synthesize currentLevelIndexPath;

#pragma mark -
#pragma mark === Action method ===
#pragma mark -

- (IBAction) goBack{
	[self.delegate preferencesViewControllerDidFinish:self withSelectedLevel:@"None"];
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

// shows view in landscape (in debugger)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark Data source methods for the level select view
#pragma mark - 



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [delegate.levels count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Prevent selection of header rows	
	if ([[delegate.levels objectAtIndex:indexPath.row] valueForKey:@"group"])
		return;
	
	// load up the game
	NSDictionary *dict = [delegate.levels objectAtIndex:indexPath.row];
	NSString *levelName = [ dict objectForKey:@"filename"];
	//NSLog(@"Selected Level %@", levelName);
	
	[self.delegate preferencesViewControllerDidFinish:self withSelectedLevel:levelName]; 
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Prevent selection of header rows	
	if ([[delegate.levels objectAtIndex:indexPath.row] valueForKey:@"group"])
	{
		return nil;
	}
#ifndef DEBUG
	
	NSDictionary *levelDictionary = [delegate.levels objectAtIndex:indexPath.row];
	NSString* levelFile = [levelDictionary valueForKey:@"filename"];
	// prevent selection of locked levels
	if(![delegate isLevelUnlockedFromName:levelFile])
	{
		return nil;
	}
#endif
	
	return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[delegate.levels objectAtIndex:indexPath.row] valueForKey:@"group"])
		return 38.0;
	else
		return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = nil;
	
	if ([[delegate.levels objectAtIndex:indexPath.row] valueForKey:@"group"])
	{
		// These cells are fake table headers for the group names.  I was having too many problems
		// using the viewForHeaderInSection (one pixel offsets when the headers stop at the top of the view)
		// methods so I gave up
		
		cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewHeader"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TableViewHeader"] autorelease];
		}
		
		//UIImageView *bg = [[UIImageView alloc] initWithFrame:cell.frame];
		//bg.image = [UIImage imageNamed:@"TableHeaderBackground.png"];
		//cell.backgroundView = bg;
		//bg.backgroundColor = [UIColor clearColor];
		//bg.opaque = NO;
		
		/* removed image stuff for now
		 else
		 {
		 ((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:[levelName stringByAppendingString: @"UI.png"]];
		 ((UIImageView *)cell.selectedBackgroundView).image = [UIImage imageNamed:[levelName stringByAppendingString: @"Sel.png"]];
		 cell.textLabel.text = @"";
		 //DLog([levelName stringByAppendingString:@"Sel"]);
		 
		 }		*/
		
		cell.backgroundColor = [UIColor clearColor];
		cell.opaque = NO;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		NSDictionary *dict = [delegate.levels objectAtIndex:indexPath.row];
		cell.textLabel.text = [dict valueForKey:@"title"];
		
		cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenBlueGrad.png"]];  // [UIColor redColor];

	}
	else 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
		
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TableViewCell"] autorelease];
		}
		
		NSDictionary *levelDictionary = [delegate.levels objectAtIndex:indexPath.row];
		NSString* levelName = [levelDictionary valueForKey:@"title"];
		NSString* levelFile = [levelDictionary valueForKey:@"filename"];
		
		cell.backgroundView = [[[UIImageView alloc] init] autorelease];
		cell.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
		
#if DEBUG
		//NSRange MyZeroRange = {0, 0};
		NSRange range = [levelName rangeOfString:@"Debug"];
		NSString *textLabel;
		
		if(range.location != NSNotFound)
		{
			//((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"BombSmall.png"];
			textLabel = [[NSString alloc] initWithString:[levelName substringFromIndex:5]];
		}
		else {
			textLabel = [[NSString alloc] initWithString:levelName];
		}
		
		cell.textLabel.text = textLabel;
		[textLabel release];
#else
		cell.textLabel.text = levelName;
		
#endif
		
		if( ![delegate isLevelUnlockedFromName:levelFile])
		{

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			// lock
			UIImageView *accessoryView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32, 32.0)] autorelease];
			accessoryView.image = [UIImage imageNamed:@"lock.png"];
			cell.accessoryView = accessoryView;
			
		}
		else {
			
			
			int highScore = [delegate getScore:levelFile];
			// currently, just an orange or clear carrot
			// TODO - bronze, silver, gold carrots
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
		}
			
		cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"RedYellowGrad.png"]];
		
#if 0
		int colorID = [[levelDictionary valueForKey:@"colorID"] intValue];
		
		if( colorID == 0)
		{
			cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"RedYellowGrad.png"]];  // [UIColor redColor];
		}
		else if(colorID == 1)
		{
			cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenBlueGrad.png"]];  // [UIColor redColor];
		}
		else {
			cell.textLabel.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"PurpleYellowGrad.png"]];  // [UIColor redColor];		
		}
#endif	
	}
	
	cell.textLabel.shadowColor = [UIColor blackColor];
	cell.textLabel.shadowOffset = CGSizeMake(2, 2);
	cell.textLabel.font=[UIFont fontWithName:@"MarkerFelt-Thin" size:24.0];

	//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}



@end
