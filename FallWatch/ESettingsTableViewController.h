//
//  ESettingsViewController.h
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *smsSwitch;

@end
