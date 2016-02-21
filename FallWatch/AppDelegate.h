//
//  AppDelegate.h
//  FallWatch
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

@import WatchConnectivity;
@import AVFoundation;
@import HealthKit;

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WCSession *session;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) HKHealthStore *healthStore;

@end

