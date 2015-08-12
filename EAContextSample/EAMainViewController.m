//
//  EAMainViewController.m
//  EAConetextSample
//
//  Created by Ryan on 13/11/26.
//  Copyright (c) 2013年 Atomax. All rights reserved.
//

#import "EAMainViewController.h"
#import "EAContext.h"

@interface EAMainViewController () <EAContextDelegate>
@property (nonatomic, strong) EAContext *context;
@end

@implementation EAMainViewController

int ta_stat = 0;
float ta_th_sen = 0.25;
float ta_th_hit = 2.0;
AMXVector3 ta_gravity_ref = {0};
NSTimeInterval startTime;
NSTimeInterval reactionTime;
NSTimeInterval motionTime;
NSTimer *triggerTimer;
NSTimeInterval triggerInterval = 10.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.context = [[EAContext alloc] initWithSport:EASportTypeRAWData/*|EASportTypeBadminton*/ andConnectionType:EAConnectionTypeBLE];

    self.context.delegate = self;
    
    self.thisView.backgroundColor = [UIColor blackColor];
    self.senSlider.maximumValue = 0.8;
    self.senSlider.minimumValue = 0.1;
    self.senSlider.value = ta_th_sen;

    self.hitSlider.maximumValue = 5.0;
    self.hitSlider.minimumValue = 0.5;
    self.hitSlider.value = ta_th_hit;
    
    self.intervalSlider.maximumValue = 20.0;
    self.intervalSlider.minimumValue = 4.0;
    self.intervalSlider.value = triggerInterval;

    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.context displayBluetoothLowEnergyPickerOnViewController:self WithCompletion:^(NSError *error){
            
            if (error)
            {
                printf("\n error -> %s",error.description.UTF8String);
            }
            
        }];
        
    });
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(EAFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        
        EAFlipsideViewController *flipViewController = [segue destinationViewController];
        
        flipViewController.context = self.context;
        
        
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - EAContextDelegate

- (void)context:(EAContext *)context didUpdateCalculatedResultWithUserInfo:(NSDictionary *)userinfo
{
    if ((context.sportType & EASportTypeRAWData) == EASportTypeRAWData)
    {
        AMXVector3 accel = {0};
        
        [userinfo[kEASportResultAccelerometer] getValue:&accel];
        
        AMXVector3 gyro = {0};
        
        [userinfo[kEASportResultGyro] getValue:&gyro];
        
        AMXVector3 gravity = {0};
        
        [userinfo[kEASportResultGravity] getValue:&gravity];

        AMXVector3 userAccel = {0};
        
        [userinfo[kEASportResultUserAcceleration] getValue:&userAccel];
        
        
        // project ta
        ta_gravity_ref.x = (ta_gravity_ref.x * 0.8) + (gravity.x * 0.2);
        ta_gravity_ref.y = (ta_gravity_ref.y * 0.8) + (gravity.y * 0.2);
        ta_gravity_ref.z = (ta_gravity_ref.z * 0.8) + (gravity.z * 0.2);
        
        AMXVector3 ta_diff = {0};
        ta_diff.x = fabsf(ta_gravity_ref.x - gravity.x);
        ta_diff.y = fabsf(ta_gravity_ref.y - gravity.y);
        ta_diff.z = fabsf(ta_gravity_ref.z - gravity.z);
        float diff = sqrtf((ta_diff.x * ta_diff.x) + (ta_diff.y * ta_diff.y) + (ta_diff.z * ta_diff.z));
        
        float pureAccel = sqrtf((userAccel.x * userAccel.x) + (userAccel.y * userAccel.y) + (userAccel.z * userAccel.z));

        
        // State Transition
        if (ta_stat == 1) { // In measuring reaction time
            reactionTime = fabs([[NSDate date] timeIntervalSince1970] - startTime);
            if (diff > ta_th_sen) {
                ta_stat = 2;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.thisView.backgroundColor = [UIColor whiteColor];
                });
            }
        } else if (ta_stat == 2) { // In motion
            motionTime = fabs([[NSDate date] timeIntervalSince1970] - startTime - reactionTime);
            if ((pureAccel > ta_th_hit)&&(motionTime > 0.1)) {
                [self startIdle:nil];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            self.uAccelValueLb_x.text = [NSString stringWithFormat:@"stat %d",ta_stat];
            self.uAccelValueLb_y.text = [NSString stringWithFormat:@"RT: %.0f ms",(float)(reactionTime * 1000)];
            self.uAccelValueLb_z.text = [NSString stringWithFormat:@"MT: %.0f ms",(float)(motionTime * 1000)];
        });
        
    }
}


- (void)context:(EAContext *)context didFailToAccessWithError:(NSError *)error
{
    printf("\n error in MainWindowViewcontroller -> %s",[[error description] UTF8String]);
}

- (void)startTimer {
    int rand = arc4random_uniform(100);
    NSTimeInterval randInterval = triggerInterval + ((double)rand / 50.0);
    triggerTimer = [NSTimer scheduledTimerWithTimeInterval:randInterval target:self selector:@selector(startMeasure:) userInfo:nil repeats:YES];
}


- (void) stopTimer{
    [triggerTimer invalidate];
    triggerTimer = nil;
}



-(void) startMeasure:(id)sender {
    ta_stat = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thisView.backgroundColor = [UIColor greenColor];
        startTime = [[NSDate date] timeIntervalSince1970];
        reactionTime = 0.0;
        motionTime = 0.0;
        [self.uAccelValueLb_y setText:@""];
        [self.uAccelValueLb_z setText:@""];
    });
}
-(void) startIdle:(id)sender {
    ta_stat = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thisView.backgroundColor = [UIColor blackColor];
    });
    
}


- (IBAction)didChangeSenSlider:(id)sender {
    ta_th_sen = self.senSlider.value;
}

- (IBAction)didChangeHitSlider:(id)sender {
    ta_th_hit = self.hitSlider.value;
}

- (IBAction)didChangeIntervalSlider:(id)sender {
    triggerInterval = self.intervalSlider.value;
}

- (IBAction)didClickStartBtn:(UIButton *)sender {
    
    if(self.startBtn.isSelected) {
        [self.startBtn setSelected:NO];
        [self stopTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
            [self.hitSlider setHidden:NO];
            [self.senSlider setHidden:NO];
            [self.intervalSlider setHidden:NO];
            [self.rtSensitivityLb setHidden:NO];
            [self.mtSensitivityLb setHidden:NO];
            [self.intervalLb setHidden:NO];
            
        });
    } else {
        [self.startBtn setSelected:YES];
        [self startTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.startBtn setTitle:@"Reset" forState:UIControlStateSelected];
            [self.hitSlider setHidden:YES];
            [self.senSlider setHidden:YES];
            [self.intervalSlider setHidden:YES];
            [self.intervalLb setHidden:YES];
            [self.rtSensitivityLb setHidden:YES];
            [self.mtSensitivityLb setHidden:YES];

        });
    }
    
}




@end
