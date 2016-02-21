//
//  InterfaceController.m
//  FallWatch WatchKit Extension
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController () {
    NSArray *mockData;
    int k;
    __block NSDate *lastAcc;
}

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    NSLog(@"Awake");
    
    _mManager = [[CMMotionManager alloc] init];
    lastAcc = [NSDate new];
    
    if ([_mManager isAccelerometerAvailable]) {
        NSLog(@"Acelerometer available");
        
        [_mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (!error && [lastAcc timeIntervalSinceNow] < -.2) {
                [self sendAccelData:accelerometerData];
                lastAcc = [NSDate new];
            } else {
                NSLog(@"ERROR %@", error);
            }
            
        }];
    } else {
        NSLog(@"Acelerometer not a");
    }
    
    k        = 0;
    mockData = @[
                 @[ @1.23, @.036, @.048 ],
                 @[ @1.56, @.027, @.090 ],
                 @[ @1.64, @.024, @.091 ],
                 @[ @1.76, @.028, @.081 ],
                 @[ @1.87, @.025, @.043 ],
                 @[ @1.94, @.026, @.072 ],
                 @[ @2.25, @.025, @.073 ],
                 @[ @2.75, @.025, @.052 ]
                 ];
}

- (void)willActivate
{
    [super willActivate];
}

- (void)didAppear
{
    NSDictionary *msg = [[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"];
    
    [self.label setText:[NSString stringWithFormat:@"%@", msg]];
}

- (void)willDisappear {
    [super willDisappear];
    
    [_mManager stopAccelerometerUpdates];
}

#pragma mark -
#pragma mark Data Acquisition

- (void)sendAccelData:(CMAccelerometerData*)data
{
    CMAcceleration accel = data.acceleration;
//    double anorm = sqrt(pow(accel.x,2) + pow(accel.y,2) + pow(accel.z,2));
    NSString *str = [NSString stringWithFormat:@"%d: %.4f", k, accel.z];
    NSLog(@"%@", str);
    NSArray *array = @[@(accel.x), @(accel.y), @(accel.z)];
    [[WCSession defaultSession] sendMessage:@{@"data" : array,
                                              @"seq" : @(k++)}
                               replyHandler:^(NSDictionary<NSString *, id> *_Nonnull replyMessage) {
                                   NSLog(@"%@", replyMessage);
                               }
                               errorHandler:^(NSError *_Nonnull error) {
                                   NSLog(@"ERROR %@", error.localizedDescription);
                               }];
    
    [self.label setText:str];
    if (accel.x > 1.9) {
        [self.label setTextColor:[UIColor redColor]];
    } else {
        [self.label setTextColor:[UIColor whiteColor]];
    }
}

@end
