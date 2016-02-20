//
//  ExtensionDelegate.h
//  FallWatch WatchKit Extension
//
//  Created by Matthew Gardner on 2/19/16.
//  Copyright © 2016 Matthew Gardner. All rights reserved.
//

@import WatchConnectivity;

#import <WatchKit/WatchKit.h>

@interface ExtensionDelegate : NSObject <WKExtensionDelegate, WCSessionDelegate>

@property (strong, nonatomic) WCSession *session;

@end
