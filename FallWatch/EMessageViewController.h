//
//  EMessageViewController.h
//  FallWatch
//
//  Created by Matthew Gardner on 2/21/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end
