//
//  EAMainViewController.h
//  EAContextSample
//
//  Created by Ryan on 13/11/26.
//  Copyright (c) 2013年 Atomax. All rights reserved.
//

#import "EAFlipsideViewController.h"

@interface EAMainViewController : UIViewController <EAFlipsideViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *thisView;
@property (strong, nonatomic) IBOutlet UIButton *startBtn;
@property (strong, nonatomic) IBOutlet UISlider *senSlider;
@property (strong, nonatomic) IBOutlet UISlider *hitSlider;
@property (strong, nonatomic) IBOutlet UISlider *intervalSlider;
/*
@property (strong, nonatomic) IBOutlet UILabel *accelValueLb_x;
@property (strong, nonatomic) IBOutlet UILabel *accelValueLb_y;
@property (strong, nonatomic) IBOutlet UILabel *accelValueLb_z;

@property (strong, nonatomic) IBOutlet UILabel *gyroValueLb_x;
@property (strong, nonatomic) IBOutlet UILabel *gyroValueLb_y;
@property (strong, nonatomic) IBOutlet UILabel *gyroValueLb_z;

@property (strong, nonatomic) IBOutlet UILabel *gravityValueLb_x;
@property (strong, nonatomic) IBOutlet UILabel *gravityValueLb_y;
@property (strong, nonatomic) IBOutlet UILabel *gravityValueLb_z;
*/
@property (strong, nonatomic) IBOutlet UILabel *uAccelValueLb_x;
@property (strong, nonatomic) IBOutlet UILabel *uAccelValueLb_y;
@property (strong, nonatomic) IBOutlet UILabel *uAccelValueLb_z;

@property (strong, nonatomic) IBOutlet UILabel *rtSensitivityLb;
@property (strong, nonatomic) IBOutlet UILabel *mtSensitivityLb;
@property (strong, nonatomic) IBOutlet UILabel *intervalLb;

-(void) startMeasure:(id)sender;
-(void) startIdle:(id)sender;

@end
