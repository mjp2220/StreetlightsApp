//  MJPAppDelegate.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface MJPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readwrite) float searchRadius;

@property (strong, nonatomic) NSArray *streamItemArray;

@property (strong, nonatomic) PFObject *currentUser;

@property (strong, nonatomic) CLLocation *locationManager;

- (BOOL)hasUserCredentials;
- (id)currentUserId;

@property BOOL shouldRefreshStreamItems;

- (void)loggedOutView;

@end
