//
//  AppDelegate.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Initialize watch connectivity
    _session          = [WCSession defaultSession];
    _session.delegate = self;

    if ([WCSession isSupported]) {
        NSLog(@"WCSession supported");
        [_session activateSession];
        NSLog(@"WCSession activated");
    }

    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"btn__back-green"];

    NSString *msg = [[NSUserDefaults standardUserDefaults] objectForKey:@"smsMessage"];
    if (!msg) {
        [[NSUserDefaults standardUserDefaults] objectForKey:@"Please help! I am injured! Call 911!"];
    }

    // Configure background audio
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    // Configure HealthKit
    self.healthStore     = [[HKHealthStore alloc] init];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    [self.healthStore requestAuthorizationToShareTypes:nil
                                             readTypes:[NSSet setWithObjects:type, nil]
                                            completion:^(BOOL success, NSError *_Nullable error) {
                                              if (success) {
                                                  NSLog(@"health data request success");
                                              } else {
                                                  NSLog(@"error %@", error);
                                              }
                                            }];

    // Configure audio player
    NSString *soundFilePath =
        [NSString stringWithFormat:@"%@/alarm.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *alarmUrl           = [NSURL fileURLWithPath:soundFilePath];
    self.player               = [[AVAudioPlayer alloc] initWithContentsOfURL:alarmUrl error:nil];
    self.player.numberOfLoops = -1;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain
    // types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits
    // the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games
    // should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough
    // application state information to restore your application to its current state in case it is terminated
    // later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of
    // the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the
    // application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
    default:
        [self.player stop];
        break;
    }
}

- (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application
{
    [self.healthStore
        handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError *_Nullable error) {
          if (success) {
              NSLog(@"Phone recieved health kit request");
          } else {
              NSLog(@"ERROR %@", error);
          }
        }];
}

#pragma mark -
#pragma mark Session Delegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                     [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"wcMessage"];
                   });
}

@end

// UIAlertController *alert = [UIAlertController
//							alertControllerWithTitle:@"Are you OK?"
//							message:@"We detected that you may have been injured.
// Do
// you
// need
// help?"
//							preferredStyle:UIAlertControllerStyleAlert];
//
// UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes"
//											  style:UIAlertActionStyleCancel
//											handler:^(UIAlertAction
//*_Nonnull
// action)
//{
//												NSLog(@"alarm
//+
// sms");
//											}];
//
// UIAlertAction *no = [UIAlertAction actionWithTitle:@"No"
//											 style:UIAlertActionStyleDefault
//										   handler:^(UIAlertAction
//*_Nonnull
// action)
//{
//											   [alert
// dismissViewControllerAnimated:YES completion:nil];
//										   }];
//
//[alert addAction:no];
//[alert addAction:yes];
//
//[self presentViewController:alert animated:YES completion:nil];
