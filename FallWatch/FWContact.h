//
//  FWCOntact.h
//  FallWatch
//
//  Created by Matthew Gardner on 2/20/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

@import UIKit;

#import <Foundation/Foundation.h>

@interface FWContact : NSObject

@property (strong, nonatomic) NSString *first;
@property (strong, nonatomic) NSString *last;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *phoneNo;
@property (nonatomic) BOOL selected;
@property (nonatomic) int idx;

@end
