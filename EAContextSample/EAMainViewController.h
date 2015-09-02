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
@property (strong, nonatomic) IBOutlet UILabel *mt2Lb;
@property (strong, nonatomic) IBOutlet UILabel *rtLb;
@property (strong, nonatomic) IBOutlet UILabel *mtLb;


@property (strong, nonatomic) IBOutlet UILabel *powerIndexLb;

-(void) startMeasure:(id)sender;
-(void) startIdle:(id)sender;

@end
