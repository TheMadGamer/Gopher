//
//  HeyzapSDK.h
//  HeyzapIOSSDK
//
//  Copyright 2011 Heyzap. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HEYZAP_STORE_URL [NSURL URLWithString:@"http://itunes.apple.com/us/app/heyzap/id435333429?mt=8"]
#define HEYZAP_APP_URL_BASE @"heyzap://checkin?app_store_id=%@&next=%@"

@interface HeyzapSDK : NSObject {
    NSString *appId;
    NSString *appURL;
    NSString *checkinMessage;
}

@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *appURL;
@property (nonatomic, retain) NSString *checkinMessage;

+ (HeyzapSDK *) sharedHeyzap;
+ (HeyzapSDK *) initWithAppId:(NSString *)_appId appURL:(NSString *)_url;
+ (UIImage *) appImage;
+ (NSString *) appName;
+ (NSString *) deviceId;
+ (UIViewController *)getActiveController:(UIView *)view;

- (id) initWithAppId:(NSString *)_appId appURL:(NSString *)_url;
- (NSURL *) heyzapUrl;
- (BOOL) canOpenHeyzap;
- (void) openHeyzap;
- (void) openAppStore;
- (void) heyzapCheckin:(UIView *)sender;

#pragma mark - Analytics
- (void) buttonShownAnalytics;
- (void) buttonHitAnalytics;
- (void) closeExplainAnalytics;
- (void) appStoreHitAnalytics;
- (void) requestURL:(NSString *)url withParams:(NSDictionary *)params;

@end
