//
//  InterfaceController.h
//  FallWatch WatchKit Extension
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

@import CoreMotion;
@import WatchConnectivity;

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>


@interface InterfaceController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *label;

@property (strong, nonatomic) CMMotionManager *mManager;
@property (strong, nonatomic) CMSensorRecorder *recorder;
@property (strong, nonatomic) NSTimer *timer;

@end
