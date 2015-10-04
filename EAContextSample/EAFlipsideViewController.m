//
//  EAFlipsideViewController.m
//  EAContextSample
//
//  Created by Ryan on 13/11/26.
//  Copyright (c) 2013年 Atomax. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "EAFlipsideViewController.h"
@interface EAFlipsideViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation EAFlipsideViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.context.isConnected)
        [self.connectionToggleBtn setSelected:YES];
    else
        [self.connectionToggleBtn setSelected:NO];

    if (self.context2.isConnected)
        [self.connectionToggleBtn2 setSelected:YES];
    else
        [self.connectionToggleBtn2 setSelected:NO];

}

- (void)saveDefaults
{
    
    float fRT_threshold = self.senSlider.value;
    float fMT_threshold = self.hitSlider.value;
    float fTrigger_interval = self.intervalSlider.value;
    float cnt = (int) self.countSlider.value;
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setFloat:fRT_threshold forKey:@"RT_threshold"];
    [defaults setFloat:fMT_threshold forKey:@"MT_threshold"];
    [defaults setFloat:fTrigger_interval forKey:@"Trigger_interval"];
    [defaults setInteger:cnt forKey:@"Count"];
    
    [defaults synchronize];
    
    NSLog(@"User Defaults Data saved");
}

-(void) setupSliderRanges
{
    self.senSlider.maximumValue = 16.0;
    self.senSlider.minimumValue = 1.0;
    
    self.hitSlider.maximumValue = 16.0;
    self.hitSlider.minimumValue = 1.0;
    
    self.intervalSlider.maximumValue = 20.0;
    self.intervalSlider.minimumValue = 4.0;
    
    self.countSlider.maximumValue = 5.0;
    self.countSlider.minimumValue = 1.0;

}

- (void)loadDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.senSlider.value = [defaults floatForKey:@"RT_threshold"];
    self.hitSlider.value = [defaults floatForKey:@"MT_threshold"];
    self.intervalSlider.value = [defaults floatForKey:@"Trigger_interval"];
    self.countSlider.value = (float)[defaults integerForKey:@"Count"];
    
    [self updateSliderLabels];
}
-(void) updateSliderLabels
{
    self.senLb.text = [NSString stringWithFormat:@"%.1f",self.senSlider.value];
    self.hitLb.text = [NSString stringWithFormat:@"%.1f",self.hitSlider.value];
    self.intervalLb.text = [NSString stringWithFormat:@"%.1f",self.intervalSlider.value];
    self.countLb.text = [NSString stringWithFormat:@"%ld",(long)self.countSlider.value];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.connectionToggleBtn setTitle:@"選手已連線" forState:UIControlStateSelected];
    [self.connectionToggleBtn2 setTitle:@"目標已連線" forState:UIControlStateSelected];
    [self setupSliderRanges];
    [self loadDefaults];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)didChangeValueSlider:(id)sender
{
    [self updateSliderLabels];
    [self.saveDefaultsBtn setBackgroundColor:[UIColor yellowColor]];
}
- (IBAction)didClickSaveDefaultsBtn:(id)sender
{
    [self saveDefaults];
    [self.saveDefaultsBtn setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}
- (IBAction)didClickConnectBtn2:(UIButton *)sender
{
    if (sender.isSelected)
    {
        [self.context2 disconnect];
        [sender setSelected:NO];
    }
    else
    {
        [self.context2 displayBluetoothLowEnergyPickerOnViewController:self WithCompletion:^(NSError *error) {
            
            if (error)
            {
                fprintf(stderr, "\n connect 2 error -> %s",error.description.UTF8String);
                
            }
            
        }];
        
        [sender setSelected:YES];
    }
}
- (IBAction)didClickConnectBtn:(UIButton *)sender
{
    if (sender.isSelected)
    {
        [self.context disconnect];
        [sender setSelected:NO];
    }
    else
    {
        [self.context displayBluetoothLowEnergyPickerOnViewController:self WithCompletion:^(NSError *error) {
            
            if (error)
            {
                fprintf(stderr, "\n connect error -> %s",error.description.UTF8String);

            }
            
        }];
        
        [sender setSelected:YES];
    }
    
    
}

- (IBAction)didClickContactBtn:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"[RT App] "];
        [mail setMessageBody:[NSString stringWithFormat:@"From %@ \n Model: %@\n System: %@ %@",[UIDevice currentDevice].name,[UIDevice currentDevice].model,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion] isHTML:NO];
        [mail setToRecipients:@[@"steven.lee@atomaxinc.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: Mail sending canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: Mail sending failed");
            break;
        default:
            NSLog(@"Result: Mail not sent");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
