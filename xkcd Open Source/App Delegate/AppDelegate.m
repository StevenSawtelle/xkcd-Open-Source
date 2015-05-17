//
//  AppDelegate.m
//  xkcDump
//
//  Created by Mike on 5/14/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "AppDelegate.h"
#import "RequestManager.h"
#import "ComicListViewController.h"
#import "DataManager.h"
#import "ThemeManager.h"
#import <GTTracker.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

static NSString * const kAnalyticsTrackingID = @"UA-63011163-1";

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - App life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [ThemeManager setupTheme];

    [Fabric with:@[CrashlyticsKit]];

    [self initializeAnalytics];
    [self setupPushNotifications];

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ComicListViewController new]];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[GTTracker sharedInstance] startAnalyticsSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[GTTracker sharedInstance] endAnalyticsSession];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[GTTracker sharedInstance] endAnalyticsSession];
}


#pragma mark - Push notifications

- (void)setupPushNotifications {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[DataManager sharedInstance] tokenStringFromData:deviceToken];
    
    [[RequestManager sharedInstance] sendDeviceToken:token completionHandler:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"ERROR" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Sending token to server failed with error: %@", error);
        }

        else {
            [[[UIAlertView alloc] initWithTitle:@"WORKED!!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}


#pragma mark - Analytics

- (void)initializeAnalytics {
    // Start up the GTTracker.
    GTTracker *tracker = [GTTracker sharedInstance];
    tracker.loggingEnabled = NO;
    [tracker initializeAnalyticsWithTrackingID:kAnalyticsTrackingID logLevel:kGAILogLevelError];
}


// TODO: Implement / test background fetch
//
//#pragma mark - Background fetch
//
//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    // Let the data manger handle the fetch.
//    [[DataManager sharedInstance] performBackgroundFetchWithCompletionHandler:completionHandler];
//}


@end
