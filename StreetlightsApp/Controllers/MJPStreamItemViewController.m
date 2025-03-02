//  MJPStreamItemViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPStreamItemViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MJPAppDelegate.h"
#import "MJPPhotoUtils.h"
#import <CoreLocation/CoreLocation.h>
#import "MJPAssortedUtils.h"
#import "MJPViewUtils.h"

@interface MJPStreamItemViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *postDescription;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timePosted;
@property (strong, nonatomic) IBOutlet UILabel *timeRemaining;
@property (strong, nonatomic) IBOutlet UILabel *timePost;

@property (strong, nonatomic) PFObject *streamItem;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *postPicture;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIButton *trashButton;
- (IBAction)deleteStreamItem:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *infoView;

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
- (IBAction)sharePost:(id)sender;
- (IBAction)stillThereButton:(id)sender;
- (IBAction)notThereButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *stillThere;
@property (strong, nonatomic) IBOutlet UIButton *notThere;



@end

@implementation MJPStreamItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (id)initWithStreamItem:(PFObject *)streamItem location:(CLLocation*)location {
    self = [super init];
    if (self) {
        self.streamItem = streamItem;
        self.currentLocation = location;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set the fields for the current stream item.
    self.userName.text = self.streamItem[@"user"][@"name"];
    self.postDescription.text = self.streamItem[@"description"];
    
    [self setPicturesForPost];
    [self setDateForPost];
    [self setMapMarkerAndDistanceForPost];
    [self setTimeRemainingForPost];
    
    [MJPViewUtils setNavigationUI:self withTitle:@"Post" backButtonName:@"Back.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
    
    [self handleDeletion];
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPushed)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:backSwipe];
    
    [self.mapView setUserInteractionEnabled:NO];
    
    [self.stillThere.layer setBorderWidth:1.0];
    [self.stillThere.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.stillThere.layer setCornerRadius:10]; // this value vary as per your desire
    [self.stillThere setClipsToBounds:YES];
    [self.notThere.layer setBorderWidth:1.0];
    [self.notThere.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.notThere.layer setCornerRadius:10]; // this value vary as per your desire
    [self.notThere setClipsToBounds:YES];
    
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.infoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleDeletion {
    if (![self.appDelegate.currentUser.objectId isEqualToString:[self.streamItem[@"user"] objectId]]) {
        [self.trashButton setHidden:YES];
    }
}
- (IBAction)deleteStreamItem:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Delete Stream Item?"
                                          message:@"Are you sure you want to delete this stream item? This action is permanent."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *deleteAction = [UIAlertAction
                               actionWithTitle:@"Delete"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   [self deleteStreamItem];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void) deleteStreamItem {
    [self.streamItem deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.appDelegate.shouldRefreshStreamItems = TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils genericErrorMessage:self];
            });
        }
    }];
}

- (IBAction)sharePost:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self shareToFacebook];
    }];
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // TODO: Implement this.
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Dismiss view controller.
    }];
    [alertController addAction:facebookAction];
    [alertController addAction:twitterAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)stillThereButton:(id)sender {
    // TODO: Implement this.
}

- (IBAction)notThereButton:(id)sender {
    // TODO: Implement this.
}

- (void) shareToFacebook {
    // Create activity indicator.
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.activityIndicator.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    // Check for publish permissions
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        [self getFacebookPermissionsAndPost];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.state == FBSessionStateOpen) {
                [self getFacebookPermissionsAndPost];
            }
        }];
    }
}

- (void)getFacebookPermissionsAndPost {
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Walk the list of permissions looking to see if publish_actions has been granted
            NSArray *permissions = (NSArray *)[result data];
            BOOL publishActionsSet = FALSE;
            for (NSDictionary *perm in permissions) {
                if ([[perm objectForKey:@"permission"] isEqualToString:@"publish_actions"] &&
                    [[perm objectForKey:@"status"] isEqualToString:@"granted"]) {
                    publishActionsSet = TRUE;
                    break;
                }
            }
            if (!publishActionsSet) {
                [self requestPermissionsAndPost];
            } else {
                // Already have the permissions we need.
                [self postFacebookEvent];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils incorrectPermissionsErrorView:self];
            });
        }
    }];
}

- (void)postFacebookEvent {
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    object.provisionedForPost = YES;
    object[@"type"] = @"streetlightsapp:event";
    
    object[@"title"] = @"Around";
    object[@"description"] = [self.streamItem objectForKey:@"description"];
    
    // Post custom object
    [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // get the object ID for the Open Graph object that is now stored in the Object API
            NSString *objectId = [result objectForKey:@"id"];
            // create an Open Graph action
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:@"event"];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils facebookShareError:self];
            });
            [self.activityIndicator stopAnimating];
        }
    }];
}

- (void)incrementStreamItemShares {
    NSInteger shareCount = [[self.streamItem objectForKey:@"shareCount"] integerValue];
    shareCount++;
    [self.streamItem setObject:[NSNumber numberWithInteger:shareCount] forKey:@"shareCount"];
    [self.streamItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Notify somebody of something. We can't save stream items.
        }
    }];
}

- (void)setPicturesForPost {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[self.streamItem[@"user"][@"profilePicture"] getData]];
        if (self.streamItem[@"user"][@"profilePicture"]) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.profilePicture setImage:profilePicture];
                [MJPPhotoUtils circularCrop:self.profilePicture];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.profilePicture setImage:[UIImage imageNamed:@"images.jpeg"]];
                [MJPPhotoUtils circularCrop:self.profilePicture];
            });
        }
        if (self.streamItem[@"postPicture"]) {
            UIImage *postPicture = [UIImage imageWithData:[self.streamItem[@"postPicture"] getData]];
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.postPicture setContentMode:UIViewContentModeScaleAspectFit];
                [self.postPicture setImage:postPicture];
                [self.view bringSubviewToFront:self.infoView];
            });
        }
    });
}

- (void)setDateForPost {
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"postedTimestamp"] doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.timePosted.text = [dateFormatter stringFromDate:date];
}

- (void)setMapMarkerAndDistanceForPost {
    double pointLatitude = [self.streamItem[@"latitude"] floatValue];
    double pointLongitude = [self.streamItem[@"longitude"] floatValue];
    
    // Add a marker for the location of the point.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
    marker.map = self.mapView;
    
    // Move the map to the location of the marker
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget:marker.position zoom:14.0];
    [self.mapView moveCamera:update];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.02f mi", [MJPAssortedUtils distanceFromLatitude:pointLatitude longitude:pointLongitude currentLocation:self.currentLocation.coordinate]];
}

- (void)setTimeRemainingForPost {
    // Set the date of amount of time remaining.
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"expiredTimestamp"] doubleValue]];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [expirationDate timeIntervalSinceDate:currentDate];
    self.timeRemaining.text = [MJPAssortedUtils completeStringForRemainingTime:timeInterval];
}

- (void)requestPermissionsAndPost {
    // Permission hasn't been granted, so ask for publish_actions
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
        if (!error) {
            if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
                NSLog(@"No permission.");
                // TODO: Think of what to do here. Just let it go I think.
            } else {
                // Permission granted.
                [self postFacebookEvent];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils incorrectPermissionsErrorView:self];
            });
        }
    }];
}
@end
