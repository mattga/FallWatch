//
//  ContactTableViewCell.h
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWContact.h"

@interface ContactTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) FWContact *contact;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffect;

@end
