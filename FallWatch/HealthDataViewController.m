//
//  HealthDataViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "HealthDataViewController.h"

@implementation HealthDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.blueView.layer.cornerRadius = 16.;
    self.blueView.clipsToBounds      = YES;

    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
	
	NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:@"healthInfo"];
	self.heartRateField.text = info[@"pulse"];
	self.heightField.text = info[@"height"];
	self.weightField.text = info[@"weight"];
	self.dobField.text = info[@"dob"];
	self.allergiesField.text = info[@"allergies"];
	self.conditionsField.text = info[@"conditions"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSDictionary *info = @{
        @"pulse" : self.heartRateField.text,
        @"height" : self.heightField.text,
        @"weight" : self.weightField.text,
        @"dob" : self.dobField.text,
        @"allergies" : self.allergiesField.text,
        @"conditions" : self.conditionsField.text
    };
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"healthInfo"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)presentForEmergency {
	self.heartRateField.enabled = NO;
	self.heightField.enabled = NO;
	self.weightField.enabled = NO;
	self.dobField.enabled = NO;
	self.allergiesField.enabled = NO;
	self.conditionsField.enabled = NO;
	self.backButton.hidden = NO;
}

@end
