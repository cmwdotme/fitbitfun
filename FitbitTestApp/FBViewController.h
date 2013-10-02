//
//  FBViewController.h
//  FitBitTestApp
//
//  Created by Christopher Wade on 6/7/13.
//  Copyright (c) 2013 cmw. All rights reserved.
//

@interface FBViewController : UIViewController

- (IBAction)FBScanForPeripheralsButton:(id)sender;
- (IBAction)DisplayCode:(id)sender;
- (IBAction)StartAirLink:(id)sender;
- (IBAction)triggerMicroDumpBtn:(id) sender;
@property (weak, nonatomic) IBOutlet UIProgressView *FBUIBatteryBar;
@property (weak, nonatomic) IBOutlet UILabel *FBUIBatteryBarLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *FBUISpinner;
- (void) batteryIndicatorTimer:(NSTimer *)timer;
- (void) connectionTimer:(NSTimer *)timer;

@end
