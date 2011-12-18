//
//  LevelPackPurchaseVC.m
//  Gopher
//
//  Created by Anthony Lobay on 4/8/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "LevelPackPurchaseVC.h"
#import "GopherAppDelegate.h"

@implementation LevelPackPurchaseVC

@synthesize delegate;
@synthesize _purchaseID;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPurchaseID:(NSString*) purchaseID {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _purchaseID = purchaseID;
    }
    return self;
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
				break;
			default:
				break;
		}
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{

	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		// Optionally, display an error here.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase failed"
														message:@"Please try again in a few minutes."
													   delegate:nil cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		// remove from parent view
		[[GopherAppDelegate appDelegate].gopherGameController genericViewControllerDidFinish];
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	// remove from parent view
	[[GopherAppDelegate appDelegate].gopherGameController genericViewControllerDidFinish];
	
	//Provide the new content
	[self provideContent: transaction.originalTransaction.payment.productIdentifier];
	
	//Finish the transaction
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	// remove from parent view
	[[GopherAppDelegate appDelegate].gopherGameController genericViewControllerDidFinish];
	
	//Provide the new content
	[self provideContent: transaction.payment.productIdentifier];
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) provideContent: (NSString*)identifier
{
	[self.delegate unlockLevelPack:identifier];
}

#pragma mark -
#pragma mark IBAction

- (IBAction) purchasePressed
{
	// purchase
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:_purchaseID];
	
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	
}

- (IBAction) cancelPressed
{
	// remove from parent view
	[[GopherAppDelegate appDelegate].gopherGameController genericViewControllerDidFinish];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
			|| interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
