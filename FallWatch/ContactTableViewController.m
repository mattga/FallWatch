//
//  ContactTableViewController.m
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import "ContactTableViewController.h"
#import "ContactTableViewCell.h"

@interface ContactTableViewController () {
    NSMutableArray *contacts;
    NSMutableDictionary *selContacts;
}

@end

@implementation ContactTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    selContacts    = [@{} mutableCopy];
    NSArray *array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"smsContacts"] mutableCopy];
    if (array && [array count] > 0) {
        for (NSDictionary *c in array) {
            FWContact *c_ = [[FWContact alloc] init];
            c_.first      = c[@"first"];
            c_.last = c[@"last"];
            if (c[@"image"]) {
                c_.image = [UIImage imageWithData:c[@"image"]];
            }
            c_.selected = [c[@"selected"] boolValue];
            c_.idx = [c[@"idx"] intValue];
            if (c[@"phoneNo"]) {
                c_.phoneNo = c[@"phoneNo"];
            }
            [selContacts setObject:c_ forKey:@(c_.idx)];
        }
    }

    // Fetch contacts
    contacts              = [@[] mutableCopy];
    CNContactStore *store = [[CNContactStore alloc] init];
    [store
        requestAccessForEntityType:CNEntityTypeContacts
                 completionHandler:^(BOOL granted, NSError *_Nullable error) {
                   if (granted == YES) {
                       // keys with fetching properties
                       NSArray *keys = @[
                           CNContactFamilyNameKey,
                           CNContactGivenNameKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataKey
                       ];
                       NSString *containerId = store.defaultContainerIdentifier;
                       NSPredicate *predicate =
                           [CNContact predicateForContactsInContainerWithIdentifier:containerId];
                       NSError *error;
                       NSArray *cnContacts =
                           [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
                       if (error) {
                           NSLog(@"error fetching contacts %@", error);
                       } else {
                           int i = 0;
                           for (CNContact *contact in cnContacts) {
                               FWContact *c = [[FWContact alloc] init];
                               c.first      = contact.givenName;
                               c.last       = contact.familyName;
                               c.idx        = i++;
                               c.phoneNo    = [[[[contact phoneNumbers] firstObject] value] stringValue];
                               c.phoneNo    = [[c.phoneNo
                                   componentsSeparatedByCharactersInSet:[[NSCharacterSet
                                                                            decimalDigitCharacterSet]
                                                                            invertedSet]]
                                   componentsJoinedByString:@""];

                               if (contact.imageData) {
                                   c.image = [UIImage imageWithData:contact.imageData];
                               }

                               if ([selContacts[@(c.idx)] selected]) {
                                   c.selected = YES;
                               } else {
                                   c.selected = NO;
                               }

                               [contacts addObject:c];
                           }
                       }

                       [self.tableView reloadData];
                   }
                 }];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg__blue"]];
    [self.tableView setBackgroundView:imageView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSMutableArray *array = [@[] mutableCopy];
    for (FWContact *c in selContacts.allValues) {
        NSMutableDictionary *dict =
            [@{ @"first" : c.first,
                @"last" : c.last,
                @"selected" : @(c.selected),
                @"idx" : @(c.idx) } mutableCopy];

        if (c.image) {
            [dict setObject:UIImagePNGRepresentation(c.image) forKey:@"image"];
        }

        if (c.phoneNo) {
            [dict setObject:c.phoneNo forKey:@"phoneNo"];
        }

        [array addObject:dict];
    }

    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"smsContacts"];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [selContacts count];
    }
    return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];

    FWContact *c;
    if (indexPath.section == 0) {
        c            = selContacts[selContacts.allKeys[indexPath.row]];
        cell.contact = c;
    } else {
        c = contacts[indexPath.row];
    }

    if (indexPath.section == 1 && c.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.nameLabel.text                = [NSString stringWithFormat:@"%@, %@", c.last, c.first];
    cell.contactImageView.image        = c.image;
    cell.blurEffect.layer.cornerRadius = 16.;
    cell.blurEffect.clipsToBounds      = YES;
    [[cell contentView] setBackgroundColor:[UIColor clearColor]];
    [[cell backgroundView] setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ContactTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.contact.selected) {
            [cell.contact setSelected:NO];
			[(FWContact*)contacts[cell.contact.idx] setSelected:NO];
            [selContacts removeObjectForKey:@(cell.contact.idx)];
        }
    } else {
        FWContact *c = contacts[indexPath.row];
        if (c.selected) {
            c.selected = NO;
            [selContacts removeObjectForKey:@(indexPath.row)];
        } else if ([selContacts count] < 3) {
            c.selected = YES;
            [selContacts setObject:contacts[indexPath.row] forKey:@(indexPath.row)];
        }
    }

    [tableView reloadData];
}

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

        UILabel *label      = [[UILabel alloc] initWithFrame:CGRectMake(50, 3, 275, 40)];
        label.text          = @"Select Contacts";
        label.textColor     = [UIColor colorWithRed:0.145 green:0.925 blue:0.545 alpha:1.000];
        label.textAlignment = NSTextAlignmentCenter;

        [tempView addSubview:label];
        [tempView addSubview:backButton];

        tempLabel.text = @"SELECTED";
    } else if (section == 1) {
        tempLabel.text = @"ALL CONTACTS";
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

#pragma mark -
#pragma mark Search results updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
}

@end
