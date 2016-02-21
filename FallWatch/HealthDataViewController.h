//
//  HealthDataViewController.h
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HealthDataViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blueView;

@property (weak, nonatomic) IBOutlet UITextField *heartRateField;
@property (weak, nonatomic) IBOutlet UITextField *heightField;
@property (weak, nonatomic) IBOutlet UITextField *weightField;
@property (weak, nonatomic) IBOutlet UITextField *dobField;
@property (weak, nonatomic) IBOutlet UITextField *allergiesField;
@property (weak, nonatomic) IBOutlet UITextField *conditionsField;

- (void)presentForEmergency;

@end
