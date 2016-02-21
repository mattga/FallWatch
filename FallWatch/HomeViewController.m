//
//  ViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

@import AVFoundation;

#import "HomeViewController.h"
#import "HealthDataViewController.h"

#define NUM_RECORDS 10

@interface HomeViewController () {
    NSTimer *timer, *alertTimer;
    AVAudioPlayer *player;
    HKHealthStore *healthStore;
    HKWorkout *workout;
    UIAlertController *alert;

    // Stores the last NUM_RECORDS z-axis measurements
    double acc_history[NUM_RECORDS];
    long k;
    long last_processed_seq;
    
    BOOL alertTriggered;
}

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    alertTriggered = NO;
    
    healthStore = [(AppDelegate *)[UIApplication sharedApplication].delegate healthStore];

    player = [(AppDelegate *)[UIApplication sharedApplication].delegate player];
    timer  = [NSTimer scheduledTimerWithTimeInterval:.1
                                             target:self
                                           selector:@selector(refreshAccelData)
                                           userInfo:nil
                                            repeats:YES];
    k                                = 0;
    self.blurView.layer.cornerRadius = 16.;
    self.blurView.clipsToBounds      = YES;

    // initializing sensor data
    int i;
    for (i = 0; i < NUM_RECORDS; ++i) acc_history[i] = -0.9814;

    k                  = 0;
    last_processed_seq = -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDate *start = [NSDate new];
    NSDate *end   = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    workout       = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeWalking startDate:start endDate:end];

    NSMutableArray *samples = [NSMutableArray array];
    HKQuantityType *heartRateType =
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    HKQuantity *heartRateForInterval =
        [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"] doubleValue:95.0];

    HKQuantitySample *heartRateForIntervalSample =
        [HKQuantitySample quantitySampleWithType:heartRateType
                                        quantity:heartRateForInterval
                                       startDate:start
                                         endDate:end];

    [samples addObject:heartRateForIntervalSample];

    [healthStore addSamples:samples
                  toWorkout:workout
                 completion:^(BOOL success, NSError *_Nullable error) {
                   if (!success) {
                       NSLog(@"ERROR %@", error);
                   }
                 }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)didFallHappen:(double)x:(double)y:(double)z
{
    //    double cur_avg = [self computeAverageAcc];
    if (z < 0.0 && z > 0.5 * -0.9814) {
        NSLog(@"%@", [NSString stringWithFormat:@"x=%.4f y=%.4f z=%.4f", x, y, z]);
        return TRUE;
    }
    return FALSE;
}

- (double)computeAverageAcc
{
    int i;
    double sum = 0.0;
    for (i = 0; i < NUM_RECORDS; ++i) sum += acc_history[i];

    return sum / NUM_RECORDS;
}

- (void)refreshAccelData
{
    dispatch_async(
        dispatch_get_main_queue(),
        ^{
          NSArray *data =
              [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"] objectForKey:@"data"];
          NSString *seq =
              [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"] objectForKey:@"seq"];
          NSString *str;

          k++;
          if (data) {
              double x    = [data[0] doubleValue];
              double y    = [data[1] doubleValue];
              double z    = [data[2] doubleValue];
              int seq_idx = [seq intValue];
              if (seq_idx > last_processed_seq) {
                  //                               acc_history[seq_idx % NUM_RECORDS] = z;
                  //                               NSLog(@"%@", [NSString stringWithFormat:@"Fall: Seq:%d
                  //                               x=%.4f y=%.4f z=%.4f",
                  //                                             seq_idx,x,y,z]);
                  if ([self didFallHappen:x:y:z] && !alertTriggered) {
                      alertTriggered = YES;
                      
                      //                                   double curr_avg = [self computeAverageAcc];
                      NSLog(@"%@",
                            [NSString stringWithFormat:@"Fall detected: seq %d, z-acc %.4f", seq_idx, z]);
                      [self showAlert];
                  }

                  last_processed_seq = seq_idx;
                  str                = [NSString stringWithFormat:@"%d: %.4f", seq_idx, z];
              } else {
                  last_processed_seq = -1;
              }
          } else {
              str = [NSString stringWithFormat:@"No Data %ld", k];
          }

          /**** MOCK DATA ****/
          //                       NSArray *data = [[[NSUserDefaults standardUserDefaults]
          //                       objectForKey:@"wcMessage"]
          //                                        objectForKey:@"data"];
          self.label.text = str;
        });
}

- (void)showAlert
{
    alertTimer = [NSTimer scheduledTimerWithTimeInterval:10.
                                     target:self
                                   selector:@selector(dismissAndTrigger)
                                   userInfo:nil
                                    repeats:NO];

    alert = [UIAlertController
        alertControllerWithTitle:@"Are you OK?"
                         message:@"We detected that you may have been injured. Do you need help?"
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *_Nonnull action) {
                                                    [alertTimer invalidate];
                                                  [self triggerAlerts];
                                                }];

    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *_Nonnull action) {
                                                   [alertTimer invalidate];
                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];

    [alert addAction:no];
    [alert addAction:yes];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissAndTrigger
{
    [alert dismissViewControllerAnimated:YES completion:nil];
    [self triggerAlerts];
}

- (void)triggerAlerts
{
    BOOL doSMS        = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendSms"] boolValue];
    BOOL doAlarm      = [[[NSUserDefaults standardUserDefaults] objectForKey:@"soundAlarm"] boolValue];
    NSArray *contacts = [[NSUserDefaults standardUserDefaults] objectForKey:@"smsContacts"];

    if (doSMS) {
        for (NSDictionary *c in contacts) {
            NSString *kTwilioSID   = @"ACffccebc6075354dea033e4a518192850";
            NSString *kTwilioToken = @"ca9cd93b48e97869530a6fa498427c75";
            NSString *message      = [[NSUserDefaults standardUserDefaults] objectForKey:@"smsMessage"];
            NSString *from         = @"+13106834726";
            NSString *to           = [NSString stringWithFormat:@"+%@", c[@"phoneNo"]];

            NSString *url = [NSString
                stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/Messages.json",
                                 kTwilioSID,
                                 kTwilioToken,
                                 kTwilioSID];

            NSString *dataString = [NSString stringWithFormat:@"To=%@&From=%@&Body=%@", to, from, message];

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];

            NSLog(@"%@\n%@",
                  [request URL],
                  [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);

            [[[NSURLSession sharedSession]
                dataTaskWithRequest:request
                  completionHandler:^(
                      NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                    NSLog(@"%@\n\n%@\n\n%@", error, data, response);
                  }] resume];
        }
    }

    if (doAlarm) {
        [player play];
    }
	
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
	HealthDataViewController *vc = [sb instantiateViewControllerWithIdentifier:@"healthInfo"];
	[vc presentForEmergency];
	[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)twilioPressed:(id)sender
{
    [self showAlert];
}

@end
