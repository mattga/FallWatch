//
//  ESettingsViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "ESettingsTableViewController.h"

@implementation ESettingsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg__blue"]];
    [self.tableView setBackgroundView:imageView];
	
	self.smsSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendSms"] boolValue];
	self.alarmSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"soundAlarm"] boolValue];
	
    [self.smsSwitch addTarget:self action:@selector(smsSwitched) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSUserDefaults standardUserDefaults] setObject:@(self.smsSwitch.isOn) forKey:@"sendSms"];
	[[NSUserDefaults standardUserDefaults] setObject:@(self.alarmSwitch.isOn) forKey:@"soundAlarm"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark Helpers

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)smsSwitched
{
	[self.tableView beginUpdates];
	[self.tableView reloadData];
	[self.tableView endUpdates];
}

#pragma mark -
#pragma mark Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView         = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 300, 200)];
    tempView.backgroundColor = [UIColor clearColor];

    int labely = -7;
    if (section == 0) {
        labely = 38;
    }
    UILabel *tempLabel        = [[UILabel alloc] initWithFrame:CGRectMake(20, labely, 300, 44)];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.textColor       = [UIColor colorWithRed:0.145 green:0.925 blue:0.545 alpha:1.000];
    tempLabel.font = [UIFont boldSystemFontOfSize:12.];
    if (section == 0) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"btn__back-green"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(8, 0, 40, 40);
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 3, 275, 40)];
		label.text = @"Emergency Settings";
		label.textColor = [UIColor colorWithRed:0.145 green:0.925 blue:0.545 alpha:1.000];
		label.textAlignment = NSTextAlignmentCenter;
		
		[tempView addSubview:label];
        [tempView addSubview:backButton];

        tempLabel.text = @"SOUND ALERT";
    } else if (section == 1) {
        tempLabel.text = @"MESSAGE ALERT";
    }
    tempLabel.alpha = .95;

    [tempView addSubview:tempLabel];

    return tempView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 75.;
    } else {
        return 30.;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.smsSwitch isOn] && indexPath.section == 1 && indexPath.row > 0) {
        return .001;
    } else {
        return 44.;
    }
}

@end
