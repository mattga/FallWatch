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
}

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

    _mManager = [[CMMotionManager alloc] init];

    if ([CMSensorRecorder isAccelerometerRecordingAvailable]) {
        _recorder = [[CMSensorRecorder alloc] init];
        [_recorder recordAccelerometerForDuration:60 * 60];
    }

    [NSTimer scheduledTimerWithTimeInterval:.5
                                     target:self
                                   selector:@selector(fetchAccelData)
                                   userInfo:nil
                                    repeats:YES];

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

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark -
#pragma mark Data Acquisition

- (void)fetchAccelData
{
    //    CMSensorDataList *dataList =
    //        [_recorder accelerometerDataFromDate:[NSDate dateWithTimeIntervalSinceNow:5] toDate:[NSDate
    //        new]];

    //    for (CMRecordedAccelerometerData *data in dataList) {
    //        CMAcceleration accel = data.acceleration;
    //        NSLog(@"%.4f %.4f %.4f", accel.x, accel.y, accel.z);
    //    }

    NSArray *data = mockData[k++ % [mockData count]];
    NSString *str = [NSString stringWithFormat:@"%.4f %.4f %.4f",
                                               [data[0] doubleValue],
                                               [data[1] doubleValue],
                                               [data[2] doubleValue]];
    NSLog(@"%@", str);
    [[WCSession defaultSession] sendMessage:@{
        @"data" : data
    }
        replyHandler:^(NSDictionary<NSString *, id> *_Nonnull replyMessage) {
          NSLog(@"%@", replyMessage);
        }
        errorHandler:^(NSError *_Nonnull error) {
          NSLog(@"ERROR %@", error.localizedDescription);
        }];

    [self.label setText:str];
    if ([data[0] intValue] > 1.9) {
        [self.label setTextColor:[UIColor redColor]];
    } else {
        [self.label setTextColor:[UIColor whiteColor]];
    }
}

@end
