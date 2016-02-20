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

    timer = [NSTimer scheduledTimerWithTimeInterval:.5
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

- (void)refreshAccelData
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                     NSArray *data = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wcMessage"]
                         objectForKey:@"data"];
                     NSString *str = [NSString stringWithFormat:@"%.4f %.4f %.4f",
                                                                [data[0] doubleValue],
                                                                [data[1] doubleValue],
                                                                [data[2] doubleValue]];
                     self.label.text = str;
                   });
}

@end
