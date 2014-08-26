//
//  MJPStreamViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPStreamViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamItemTableViewCell.h"
#import "MJPStreamItem.h"

@interface MJPStreamViewController ()
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UISegmentedControl *scopeSelector;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *locationSearch;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
- (IBAction)scopeChanged:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@end

@implementation MJPStreamViewController

static NSString *cellIdentifier = @"streamViewCell";
static NSInteger cellHeight = 80;
NSMutableArray *everyoneItems;
NSMutableArray *friendItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    streamItemView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [streamItemView addSubview:refresh];
    
    self.refreshControl = refresh;
    
    if ([self.appDelegate.everyoneArray count] == 0) {
        NSLog(@"Empty!");
    } else {
        [self.activityIndicator setHidden:YES];
        [streamItemView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.scopeSelector.selectedSegmentIndex = [self.appDelegate searchEveryone];
    
    self.distanceSlider.value = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchRadius];
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
    
    [streamItemView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.appDelegate.searchEveryone) {
        return [self.appDelegate.friendArray count];
    } else {
        return [self.appDelegate.everyoneArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJPStreamItemTableViewCell *cell = [streamItemView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [streamItemView registerNib:[UINib nibWithNibName:@"MJPStreamItemTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [streamItemView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    MJPStreamItem *streamItem;
    if (self.appDelegate.searchEveryone) {
        streamItem = ((MJPStreamItem*)[self.appDelegate.friendArray objectAtIndex:indexPath.row]);
    } else {
        streamItem = ((MJPStreamItem*)[self.appDelegate.everyoneArray objectAtIndex:indexPath.row]);
    }
    MJPUser *user = streamItem.user;
    cell.userName.text = user.name;
    cell.postInfo.text = streamItem.description;
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    // TODO: Make actual profile images.
    cell.userImage.image = [UIImage imageNamed:@"images.jpeg"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)distanceChanged:(id)sender {
    // Set the label to reflect the change
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
}

- (IBAction)sliderChangeEnded:(id)sender {
    [self.appDelegate setSearchRadius:self.distanceSlider.value];
    
    // TODO: Query for items based on the new radius.
}

- (IBAction)scopeChanged:(id)sender {
    [self.appDelegate setSearchEveryone:self.scopeSelector.selectedSegmentIndex];
    
    [streamItemView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.locationSearch resignFirstResponder];
    
    // TODO: Actually search something...not sure what.
}

- (void)handleRefresh {
    // TODO: Actually handle refresh.
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.5];
}

@end
