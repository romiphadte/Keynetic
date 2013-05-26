//
//  LearningViewController.m
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import "LearningViewController.h"

#define TIME_FREQUENCY 0.01
#define TIME_LIMIT 5.0

@implementation LearningViewController
@synthesize _accelerometer;
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
    self._accelerometer.updateInterval = TIME_FREQUENCY;
    _mtData = [[MotionData alloc] initWithAssets];
    NSLog(@"MTDATA: %@",_mtData._accPoints);
    accelX = 0;
    accelY = 0;
    accelZ = 0;
    time = 0.0;
    collectingData = NO;
}

-(IBAction)collectData:(id)sender{
    [self startAcc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    time += TIME_FREQUENCY;
    
    float kFilteringFactor = 0.3;
    // Use a basic low-pass filter to keep only the gravity component of each axis.
    accelX = (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor));
    accelY = (acceleration.y * kFilteringFactor) + (accelY * (1.0 - kFilteringFactor));
    accelZ = (acceleration.z * kFilteringFactor) + (accelZ * (1.0 - kFilteringFactor));

    float moveX = acceleration.x - accelX;
    float moveY = acceleration.y - accelY;
    float moveZ = acceleration.z - accelZ;
    
    if(fabs(moveX) < 0.008)
        moveX = 0;
    
    if(fabs(moveY) < 0.008)
        moveY = 0;
    
    if(fabs(moveZ) < 0.008)
        moveZ = 0;
    
    moveX = ((NSString*)[NSString stringWithFormat:@"%.3f",moveX]).floatValue;
    moveY = ((NSString*)[NSString stringWithFormat:@"%.3f",moveY]).floatValue;
    moveZ = ((NSString*)[NSString stringWithFormat:@"%.3f",moveZ]).floatValue;
    
    NSMutableDictionary *accDict = [NSMutableDictionary new];
    [accDict setObject:[NSNumber numberWithFloat:moveX] forKey:@"x"];
    [accDict setObject:[NSNumber numberWithFloat:moveY] forKey:@"y"];
    [accDict setObject:[NSNumber numberWithFloat:moveZ] forKey:@"z"];
    [_mtData._accPoints addObject:accDict];
    
    [_resultLabel setText:[NSString stringWithFormat:@"x:%.2f y:%.2f z:%.2f",moveX,moveY,moveZ]];
    
    //time limit
    if(time > TIME_LIMIT){
        [self stopAcc];
        
//        //print values
//        for(NSDictionary *dict in _mtData._accPoints) {
//            NSLog(@"%f,%f,%f;",((NSNumber*)[dict objectForKey:@"x"]).floatValue,((NSNumber*)[dict objectForKey:@"y"]).floatValue,((NSNumber*)[dict objectForKey:@"z"]).floatValue);
//        }
        
    }
}

-(void)stopAcc{
    self._accelerometer.delegate = nil;
    [_resultLabel setText:@"stopped"];
    NSLog(@"STOPPED");
}

-(void)startAcc{
    //reset vars for trial again
    _mtData._accPoints = [NSMutableArray new];
    time = 0.0;
    
    self._accelerometer.delegate = self;
    NSLog(@"STARTED");
}

-(IBAction)saveDataToFile:(id)sender{
    BOOL saved = [MotionData saveMotionData:_mtData];
    NSLog(@"STORED: %d",saved);
    [_resultLabel setText:@"saved!"];
}

-(IBAction)compareDataFromFile:(id)sender{
    
    //use MotionDataAnalyzer to compare here
    MotionData *modelMotion = [MotionData loadMotionData];
    
    NSLog(@"SIZE1: %d, SIZE2: %d",_mtData._accPoints.count, modelMotion._accPoints.count);
    float stdDev = 0.0;
    int counter = 1;
    
    for (int i = 0; i < _mtData._accPoints.count; i++) {
        NSDictionary *samplePoint = [_mtData._accPoints objectAtIndex:i];
        NSDictionary *modelPoint = [modelMotion._accPoints objectAtIndex:i];
        
        //if the phone wasnt still for either data, then compare
        if(!((((NSNumber*)[samplePoint objectForKey:@"x"]).floatValue == 0 && ((NSNumber*)[samplePoint objectForKey:@"y"]).floatValue == 0 && ((NSNumber*)[samplePoint objectForKey:@"z"]).floatValue == 0) || (((NSNumber*)[modelPoint objectForKey:@"x"]).floatValue == 0 && ((NSNumber*)[modelPoint objectForKey:@"y"]).floatValue == 0 && ((NSNumber*)[modelPoint objectForKey:@"z"]).floatValue == 0))) {
            
            float variance = powf(((NSNumber*)[samplePoint objectForKey:@"x"]).floatValue - ((NSNumber*)[modelPoint objectForKey:@"x"]).floatValue,2) + powf(((NSNumber*)[samplePoint objectForKey:@"y"]).floatValue - ((NSNumber*)[modelPoint objectForKey:@"y"]).floatValue,2) + powf(((NSNumber*)[samplePoint objectForKey:@"z"]).floatValue - ((NSNumber*)[modelPoint objectForKey:@"z"]).floatValue,2);
        
            stdDev += variance;
            counter++;
        }
    }
    
    stdDev /= (counter - 1);
    stdDev = powf(stdDev, 1/3);
    NSLog(@"STDDEV: %f",stdDev);
    
    BOOL passed = YES;
    
    if(stdDev > 0.20)
        passed = NO;
    
    //--stub
    
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
    
    resultStr = [resultStr stringByAppendingFormat:@" var: %f",stdDev];
    
    [_resultLabel setText:resultStr];
    [_resultLabel setTextColor:labelColor];
}

- (IBAction)switched:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
