//
//  LearningViewController.m
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import "LearningViewController.h"

@implementation LearningViewController
@synthesize _accelerometer;
@synthesize _mtData;
@synthesize _resultLabel;

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
	// Do any additional setup after loading the view, typically from a nib.
    
    self._accelerometer = [UIAccelerometer sharedAccelerometer];
    self._accelerometer.updateInterval = .1;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    NSLog(@"X: %f, Y: %f, Z: %f",acceleration.x, acceleration.y, acceleration.z);
    
}

-(IBAction)isCollectingData:(id)sender{
    UISegmentedControl *segCon = (UISegmentedControl*)sender;
    if(segCon.isEnabled){
        //turn on
        [self startAcc];
    } else{
        //stop
        [self stopAcc];
    }
}

-(void)stopAcc{
    self._accelerometer.delegate = nil;
}

-(void)startAcc{
    self._accelerometer.delegate = self;
}

-(IBAction)saveDataToFile:(id)sender{
    [MotionData saveMotionData:_mtData];
}

-(IBAction)compareDataFromFile:(id)sender{
    //use MotionDataAnalyzer to compare here
    
    //--stub
    BOOL passed = YES;
    
    //set label
    NSString *resultStr = [NSString new];
    UIColor *labelColor = [UIColor new];
    if(passed){
        resultStr = [NSString stringWithFormat:@"good!"];
        labelColor = [UIColor greenColor];
    } else{
        resultStr = [NSString stringWithFormat:@"nope"];
        labelColor = [UIColor redColor];
    }
    
    [_resultLabel setText:resultStr];
    [_resultLabel setTextColor:labelColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
