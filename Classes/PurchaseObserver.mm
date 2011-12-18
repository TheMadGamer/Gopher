//
//  PurcaseObserver.mm
//  Gopher
//
//  Created by Anthony Lobay on 4/8/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>
#import "PurchaseObserver.h"


@implementation PurchaseObserver

@synthesize delegate;

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
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	//If you want to save the transaction
	//[self recordTransaction: transaction];
	
	//Provide the new content
	[self provideContent: transaction.originalTransaction.payment.productIdentifier];
	
	//Finish the transaction
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	//If you want to save the transaction
	//[self recordTransaction: transaction];
	
	//Provide the new content
	[self provideContent: transaction.payment.productIdentifier];
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}

- (void) provideContent: (NSString*)identifier
{
	[self.delegate unlockLevelPack:identifier];
}

@end
