//
//  PurchaseObserver.h
//  Gopher
//
//  Created by Anthony Lobay on 4/8/11.
//  Copyright 2011 3dDogStudios.com. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

@protocol LevelUnlockDelegate

- (void) unlockLevelPack:(NSString *)packID;

@end


@interface PurchaseObserver : NSObject<SKPaymentTransactionObserver> {
}

@property (nonatomic, retain) id<LevelUnlockDelegate> delegate;

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString*)identifier;
@end
