//
//  EAFlipsideViewController.h
//  EAContextSample
//
//  Created by Ryan on 13/11/26.
//  Copyright (c) 2013年 Atomax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAContext.h"

@class EAFlipsideViewController;

@protocol EAFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(EAFlipsideViewController *)controller;
@end

@interface EAFlipsideViewController : UIViewController

@property (nonatomic, weak) EAContext *context;
@property (nonatomic, weak) EAContext *context2;
@property (weak, nonatomic) id <EAFlipsideViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *connectionToggleBtn;
@property (strong, nonatomic) IBOutlet UIButton *connectionToggleBtn2;
@property (strong, nonatomic) IBOutlet UIButton *contactBtn;

@property (strong, nonatomic) IBOutlet UIButton *saveDefaultsBtn;
@property (strong, nonatomic) IBOutlet UISlider *senSlider;
@property (strong, nonatomic) IBOutlet UISlider *hitSlider;
@property (strong, nonatomic) IBOutlet UISlider *intervalSlider;
@property (strong, nonatomic) IBOutlet UISlider *countSlider;
@property (strong, nonatomic) IBOutlet UILabel *senLb;
@property (strong, nonatomic) IBOutlet UILabel *hitLb;
@property (strong, nonatomic) IBOutlet UILabel *intervalLb;
@property (strong, nonatomic) IBOutlet UILabel *countLb;

- (IBAction)done:(id)sender;

@end
