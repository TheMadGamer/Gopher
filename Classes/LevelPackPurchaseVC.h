//
//  LevelPackPurchaseVC.h
//  Gopher
//
//  Created by Anthony Lobay on 4/8/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

@protocol LevelUnlockDelegate

- (void) unlockLevelPack:(NSString *)packID;

@end

@interface LevelPackPurchaseVC : UIViewController<SKPaymentTransactionObserver> {

}

@property (nonatomic, retain) NSString *_purchaseID;

@property (nonatomic, retain) id<LevelUnlockDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPurchaseID:(NSString*) purchaseID;
- (IBAction) purchasePressed;
- (IBAction) cancelPressed;

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString*)identifier;

@end
