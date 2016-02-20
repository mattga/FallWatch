//
//  ExtensionDelegate.m
//  FallWatch WatchKit Extension
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "ExtensionDelegate.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching
{
    // Perform any final initialization of your application.
    _session          = [WCSession defaultSession];
    _session.delegate = self;
    [_session activateSession];
	
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"wcMessage"];
}

- (void)applicationDidBecomeActive
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the
    // application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain
    // types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits
    // the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

#pragma mark -
#pragma mark Session Delegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSUserDefaults standardUserDefaults] setObject:message forKey:@"wcMessage"];
	});
}

@end
