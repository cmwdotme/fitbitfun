//
//  FBViewController.m
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

#import "FBViewController.h"
#import "FitbitDevice.h"
#import "TrackerList.h"
@implementation FBViewController
@synthesize FBUIBatteryBar;
@synthesize FBUIBatteryBarLabel;
@synthesize FBUISpinner;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[FitbitDevice sharedInstance] initDevice];
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(batteryIndicatorTimer:) userInfo:nil repeats:YES];

}

- (void)viewDidUnload
{
    [self setFBUIBatteryBar:nil];
    [self setFBUIBatteryBarLabel:nil];
    [self setFBUISpinner:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        switch(interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
                return NO;
            case UIInterfaceOrientationLandscapeRight:
                return NO;
            default:
                return YES;
        }
}
- (IBAction)triggerMicroDumpBtn:(id) sender
{
    [[FitbitDevice sharedInstance] triggerMicroDump];
}
- (IBAction)StartAirLink:(id)sender
{
    [[FitbitDevice sharedInstance] startAirLink];
}

- (IBAction)DisplayCode:(id)sender
{
    [[FitbitDevice sharedInstance] displayCode];
}
- (IBAction)FBScanForPeripheralsButton:(id)sender {
    if ([[FitbitDevice sharedInstance] btManager].activePeripheral)
        if([[FitbitDevice sharedInstance] btManager].activePeripheral.isConnected)
            [[[FitbitDevice sharedInstance] btManager].cbManager cancelPeripheralConnection:[[FitbitDevice sharedInstance] btManager].activePeripheral];
    if ([[FitbitDevice sharedInstance] btManager].peripherals)
        [[FitbitDevice sharedInstance] btManager].peripherals = nil;
    [[[FitbitDevice sharedInstance] btManager] findPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    [FBUISpinner startAnimating];
}

- (void) batteryIndicatorTimer:(NSTimer *)timer {
    FBUIBatteryBar.progress = [FitbitDevice sharedInstance].batteryLevel / 100;
}
- (void)doneit:(id)b {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) connectionTimer:(NSTimer *)timer {
    if([[FitbitDevice sharedInstance] btManager].peripherals.count > 0)
    {
        UINavigationController *Controller = [[UINavigationController alloc] init];
        TrackerList *tracker = [[TrackerList alloc]init];
        UIBarButtonItem *barbuttonitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneit:)];;
        tracker.navigationItem.rightBarButtonItem = barbuttonitem;
        
        Controller.viewControllers=[NSArray arrayWithObject:tracker];
        tracker.listOfItems = [[[FitbitDevice sharedInstance] btManager] getKnownPeripherals];
        [self presentModalViewController:Controller animated:YES];
    }
    [FBUISpinner stopAnimating];
}

@end
