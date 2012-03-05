//
//  AppDelegate.h
//  BloodbankiPhoneApp
//
//  Created by preet dhillon on 06/03/12.
//  Copyright (c) 2012 dhillon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLSampleViewController.h"
//UDID a0e4770556ed1e6964a142d0a26f183165e33c29
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RLSampleViewController *viewController;
    UINavigationController *navigation;

}
@property(strong,nonatomic)    UINavigationController *navigation;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet RLSampleViewController *viewController;

@end
