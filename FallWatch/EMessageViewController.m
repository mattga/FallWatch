//
//  EMessageViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/21/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "EMessageViewController.h"

@implementation EMessageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.blurView.layer.cornerRadius = 16.;
    self.blurView.clipsToBounds      = YES;

    NSString *s = [[NSUserDefaults standardUserDefaults] objectForKey:@"smsMessage"];
    if (s) {
        self.messageTextView.text = s;
    }

    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSUserDefaults standardUserDefaults] setObject:self.messageTextView.text forKey:@"smsMessage"];
}

- (void)goBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
