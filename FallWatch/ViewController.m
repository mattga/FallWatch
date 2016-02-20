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
    int k;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.1
                                             target:self
                                           selector:@selector(refreshAccelData)
                                           userInfo:nil
                                            repeats:YES];
    k = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshAccelData
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       NSArray *data = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                                        objectForKey:@"data"];
                       NSString *str;
                       
                       if (data) {
                           double anorm = sqrt(pow([data[0] doubleValue],2) + pow([data[1] doubleValue],2) + pow([data[2] doubleValue],2));
                           str = [NSString stringWithFormat:@"%.4f", anorm];
                       } else {
                           str = [NSString stringWithFormat:@"No Data %d", k++];
                       }
                       
                       
                       /**** MOCK DATA ****/
                       //                       NSArray *data = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                       //                                        objectForKey:@"data"];
                       self.label.text = str;
                   });
}

@end
