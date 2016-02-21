//
//  ViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

@import AVFoundation;

#import "HomeViewController.h"

@interface HomeViewController () {
    NSTimer *timer;
    int k;
    AVAudioPlayer *player;
    HKHealthStore *healthStore;
    HKWorkout *workout;
}

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (void)refreshAccelData
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                     NSArray *data = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                         objectForKey:@"data"];
                     NSString *str;

                     if (data) {
                         double anorm = sqrt(pow([data[0] doubleValue], 2) + pow([data[1] doubleValue], 2) +
                                             pow([data[2] doubleValue], 2));
                         str = [NSString stringWithFormat:@"%.4f", anorm];
                     } else {
                         str = [NSString stringWithFormat:@"No Data %d", k++];
                     }

                     /**** MOCK DATA ****/
                     //                       NSArray *data = [[[NSUserDefaults standardUserDefaults]
                     //                       objectForKey:@"wcMessage"]
                     //                                        objectForKey:@"data"];
                     self.label.text = str;
                   });
}

//	// Use your own details here
//	let fromNumber = "4152226666"
//	let toNumber = "4153338888"
//
//	// Build the request
//	let request = NSMutableURLRequest(URL:
// NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
//	request.HTTPMethod = "POST"
//	request.HTTPBody =
//"From=\(fromNumber)&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
//
//	// Build the completion block and send the request
//	NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error)
// in
//		print("Finished")
//		if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
//			// Success
//			print("Response: \(responseDetails)")
//		} else {
//			// Failure
//			print("Error: \(error)")
//		}
//	}).resume()

- (IBAction)twilioPressed:(id)sender
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
}

@end
