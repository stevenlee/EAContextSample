//
//  EAMainViewController.m
//  EAConetextSample
//
//  Created by Ryan on 13/11/26.
//  Copyright (c) 2013年 Atomax. All rights reserved.
//
#import "EAMainViewController.h"
#import "EAContext.h"
#import <AudioToolbox/AudioToolbox.h>


@interface EAMainViewController () <EAContextDelegate>
@property (nonatomic, strong) EAContext *context;
@property (nonatomic, strong) EAContext *context2;
@property (nonatomic, strong) NSMutableString *logString;
@end

@implementation EAMainViewController

int ta_stat = 0;
int punch_cnt = 0;

float ta_th_sen;
float ta_th_hit;
NSTimeInterval triggerInterval;
int count;

AMXVector3 ta_gravity_ref = {0};
NSTimeInterval startTime;
NSTimeInterval reactionTime;
NSTimeInterval motionTime;
NSTimeInterval tick;
NSTimeInterval tack;
NSTimer *triggerTimer;
NSString *logFileName;
SystemSoundID trumpetSound;

- (void)logShowSettings
{
    NSLog(@"(%f,%f,%f,%d)",ta_th_sen,ta_th_hit,triggerInterval,count);
    
}

- (void)initSound
{
    // Add this file to the main bundle at "Copy Bundle Resouces" setting of target
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"TRUMPET" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &trumpetSound);
    
    // Play
//    AudioServicesPlaySystemSound(trumpetSound);
    
    // call the following function when the sound is no longer used
    // (must be done AFTER the sound is done playing)
    // AudioServicesDisposeSystemSoundID(audioEffect);

}

- (void)initDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setFloat:4.0 forKey:@"RT_threshold"];
    [defaults setFloat:12.0 forKey:@"MT_threshold"];
    [defaults setFloat:6.0 forKey:@"Trigger_interval"];
    [defaults setInteger:1 forKey:@"Count"];
    [defaults synchronize];
    
    NSLog(@"User Defaults Initialized");
    
}

- (void)loadDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    float fVal=[defaults floatForKey:@"RT_threshold"];
    if (fVal) { // No dafaults
        ta_th_sen = [defaults floatForKey:@"RT_threshold"];
        ta_th_hit = [defaults floatForKey:@"MT_threshold"];
        triggerInterval = [defaults floatForKey:@"Trigger_interval"];
        count = (float)[defaults integerForKey:@"Count"];
    } else { // show defaults
        [self initDefaults];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadDefaults];
    [self logShowSettings];
    if (count == 1) {
        [self.mt2Lb setHidden:YES];
    } else {
        [self.mt2Lb setHidden:NO];
    }
    
    if ([self.context isConnected]&&[self.context2 isConnected]) {
        [self.startBtn setHidden:NO];
    } else {
        [self.startBtn setHidden:YES];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [self.startBtn setTitle:@"Stop" forState:UIControlStateSelected];
    
    self.powerIndexLb.text = @"";
    
    self.context = [[EAContext alloc] initWithSport:EASportTypeRAWData/*|EASportTypeBadminton*/ andConnectionType:EAConnectionTypeBLE];

    self.context.delegate = self;

    self.context2 = [[EAContext alloc] initWithSport:EASportTypeRAWData/*|EASportTypeBadminton*/ andConnectionType:EAConnectionTypeBLE];
    
    self.context2.delegate = self;

    
    self.thisView.backgroundColor = [UIColor blackColor];
    

//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//        [self.context displayBluetoothLowEnergyPickerOnViewController:self WithCompletion:^(NSError *error){
//            
//            if (error)
//            {
//                printf("\n error -> %s",error.description.UTF8String);
//            }
//            
//        }];
//        
//    });
    self.logString = [[NSMutableString alloc] init];
//    [self initLogString];
    [self initSound];

}

-(void)initLogString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-DD-HH-mm-ss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    logFileName = [NSString stringWithFormat:@"log-%@.csv",dateString];
    
    [self.logString setString:@""];
    [self.logString appendString:@"RT Recorder, Started at ,"];
    [self.logString appendString:dateString];
    [self.logString appendString:@"\n RT(ms),MT(ms),Acc(g),MT(ms),Acc(g);"];
    
}

-(void)writeToFileWithName:(NSString *)fileName
{
    NSError *error;
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:fileName];
    [self.logString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%@",self.logString);
    [self.logString setString:@""];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self logShowSettings];
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
        flipViewController.context2 = self.context2;
        
        
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - EAContextDelegate
- (void)context:(EAContext *)context didUpdateCalculatedResultWithUserInfo:(NSDictionary *)userinfo
{
//    if ((context.sportType & EASportTypeRAWData) == EASportTypeRAWData)
    
    if (ta_stat == 0) {
        return;
    }

    if([context isEqual:self.context2])
    {
//        AMXVector3 accel = {0};
//        [userinfo[kEASportResultAccelerometer] getValue:&accel];
        AMXVector3 userAccel = {0};
        [userinfo[kEASportResultUserAcceleration] getValue:&userAccel];

        float pureAccel2 = fabsf(userAccel.z);
        
        if (ta_stat == 2) { // In motion
            motionTime = fabs([[NSDate date] timeIntervalSince1970] - startTime - reactionTime);
            if ((pureAccel2 > ta_th_hit)&&((motionTime-tack) > 0.1)) {
                tick = motionTime - tack;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.powerIndexLb setText:[NSString stringWithFormat:@"%.2f G",pureAccel2]];
                    [self.mt2Lb setText:[NSString stringWithFormat:@"Tick %.0f ms",(float)(tick*1000)]];
                });
                
                punch_cnt++;
                NSLog(@"(%d,%f,%f)",punch_cnt,tick,pureAccel2);
                [self.logString appendString:[NSString stringWithFormat:@",%f,%f",tick,pureAccel2]];
                if (punch_cnt < count) {
                    tack = motionTime;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.mtLb setText:[NSString stringWithFormat:@"MT %.0f ms",(float)(motionTime * 1000/count)]];
                        NSLog(@"MT %.2f ms",(float)(motionTime * 1000/count));
                    });
                    punch_cnt = 0;
                    [self startIdle:nil];
                    return;
                }
            }
        }
    } else if ([context isEqual:self.context]) {
        AMXVector3 accel = {0};
        [userinfo[kEASportResultAccelerometer] getValue:&accel];
        
//        AMXVector3 gyro = {0};
//        [userinfo[kEASportResultGyro] getValue:&gyro];
//        
//        AMXVector3 gravity = {0};
//        [userinfo[kEASportResultGravity] getValue:&gravity];
//
//        AMXVector3 userAccel = {0};
//        [userinfo[kEASportResultUserAcceleration] getValue:&userAccel];
        
        // project ta
        float pureAccel = sqrtf((accel.x * accel.x) + (accel.y * accel.y) + (accel.z * accel.z));
        
        // State Transition
        if (ta_stat == 1) { // In measuring reaction time
            reactionTime = fabs([[NSDate date] timeIntervalSince1970] - startTime);
            if (pureAccel > ta_th_sen) {
                ta_stat = 2;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.thisView.backgroundColor = [UIColor whiteColor];
                });
                [self.logString appendString:[NSString stringWithFormat:@"\n%f",reactionTime]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rtLb.text = [NSString stringWithFormat:@"RT: %.0f ms",(float)(reactionTime * 1000)];
            self.mtLb.text = [NSString stringWithFormat:@"MT: %.0f ms",(float)(motionTime * 1000)];
        });
        
    }
}


- (void)context:(EAContext *)context didFailToAccessWithError:(NSError *)error
{
    printf("\n error in MainWindowViewcontroller -> %s",[[error description] UTF8String]);
}

- (void)startTimer {
    int rand = arc4random_uniform(50);
    NSTimeInterval randInterval = triggerInterval + ((double)rand / 33.3);
    triggerTimer = [NSTimer scheduledTimerWithTimeInterval:randInterval target:self selector:@selector(startMeasure:) userInfo:nil repeats:YES];
}



- (void) stopTimer{
    [triggerTimer invalidate];
    triggerTimer = nil;
}


-(void) startMeasure:(id)sender {
    [self stopTimer];
    ta_stat = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thisView.backgroundColor = [UIColor greenColor];
        startTime = [[NSDate date] timeIntervalSince1970];
        reactionTime = 0.0;
        motionTime = 0.0;
        tick = 0.0;
        tack = 0.0;
        [self.rtLb setText:@""];
        [self.mtLb setText:@""];
        [self.mt2Lb setText:@""];
    });
    AudioServicesPlaySystemSound(trumpetSound);
    [self startTimer];
}

-(void) startIdle:(id)sender {
    ta_stat = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thisView.backgroundColor = [UIColor blackColor];
    });
    [self.logString appendString:@";"];
    
}

- (IBAction)didClickStartBtn:(UIButton *)sender {
    
    if(self.startBtn.isSelected) {
        [self.startBtn setSelected:NO];
        [self stopTimer];
        [self startIdle:sender];
        [self writeToFileWithName:logFileName];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
//        });
    } else {
        [self initLogString];
        [self.startBtn setSelected:YES];
        [self startTimer];
        
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.startBtn setTitle:@"Reset" forState:UIControlStateSelected];
//        });
    }
    
}
@end
