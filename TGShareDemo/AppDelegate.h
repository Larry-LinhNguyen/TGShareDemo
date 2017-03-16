//
//  AppDelegate.h
//  TGShareDemo
//
//  Created by xlong on 3/16/17.
//  Copyright © 2017 xlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLR/AppAuth.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow; // Youtube

@end

