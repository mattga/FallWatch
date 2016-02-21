//
//  ViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController () {
    NSTimer *timer;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    int i;
    for (i = 0; i < NUM_RECORDS; ++i)
        acc_history[i] = -0.9814;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.1
                                             target:self
                                           selector:@selector(refreshAccelData)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)didFallHappen:(double)x :(double)y :(double)z
{
//    double cur_avg = [self computeAverageAcc];
    if (z < 0.0 && z > 0.5 * -0.9814) {
        NSLog(@"%@", [NSString stringWithFormat:@"x=%.4f y=%.4f z=%.4f",x,y,z]);
        return TRUE;
    }
    return FALSE;
}

- (double)computeAverageAcc
{
    int i;
    double sum = 0.0;
    for (i = 0; i < NUM_RECORDS; ++i)
        sum += acc_history[i];
        
    return sum/NUM_RECORDS;
}

- (void)refreshAccelData
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       NSArray *data = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                                        objectForKey:@"data"];
                       NSString *seq = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                                        objectForKey:@"seq"];
                       NSString *str;
                       
                       k++;
                       if (data) {
                           double x = [data[0] doubleValue];
                           double y = [data[1] doubleValue];
                           double z = [data[2] doubleValue];
                           int    seq_idx = [seq intValue];
                           if (seq_idx > last_processed_seq) {
//                               acc_history[seq_idx % NUM_RECORDS] = z;
//                               NSLog(@"%@", [NSString stringWithFormat:@"Fall: Seq:%d x=%.4f y=%.4f z=%.4f",
//                                             seq_idx,x,y,z]);
                               if ([self didFallHappen:x :y :z]) {
//                                   double curr_avg = [self computeAverageAcc];
                                   NSLog(@"%@", [NSString stringWithFormat:@"Fall detected: seq %d, z-acc %.4f",
                                                 seq_idx,z]);
                               }
                               
                               last_processed_seq = seq_idx;
                               str = [NSString stringWithFormat:@"%d: %.4f",seq_idx,z];
                           }
                           else
                           {
                               last_processed_seq = -1;
                           }
                       } else {
                           str = [NSString stringWithFormat:@"No Data %ld", k];
                       }
                       
                       
                       /**** MOCK DATA ****/
                       //                       NSArray *data = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                       //                                        objectForKey:@"data"];
                       self.label.text = str;
                   });
}

@end
