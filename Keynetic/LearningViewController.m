//
//  LearningViewController.m
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import "LearningViewController.h"

#define TIME_FREQUENCY 0.01

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
    x = y = z = vx = vy = vz = 0.0;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
 //   NSLog(@"X: %f, Y: %f, Z: %f",acceleration.x, acceleration.y, acceleration.z);
//    NSMutableDictionary *accDict = [NSMutableDictionary new];
//    [accDict setObject:[NSNumber numberWithFloat:acceleration.x] forKey:@"x"];
//    [accDict setObject:[NSNumber numberWithFloat:acceleration.y] forKey:@"y"];
//    [accDict setObject:[NSNumber numberWithFloat:acceleration.z] forKey:@"z"];
//    
//    [_mtData._accPoints addObject:accDict];
    
    float kFilteringFactor = 0.3;
    // Use a basic low-pass filter to keep only the gravity component of each axis.
    accelX = (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor));
    accelY = (acceleration.y * kFilteringFactor) + (accelY * (1.0 - kFilteringFactor));
    accelZ = (acceleration.z * kFilteringFactor) + (accelZ * (1.0 - kFilteringFactor));

    float moveX = acceleration.x - accelX;
    float moveY = acceleration.y - accelY;
    float moveZ = acceleration.z - accelZ;
    
    if(fabs(moveX) < 0.005)
        moveX = 0;
    
    if(fabs(moveY) < 0.005)
        moveY = 0;
    
    if(fabs(moveZ) < 0.005)
        moveZ = 0;
    
    NSMutableDictionary *accDict = [NSMutableDictionary new];
    [accDict setObject:[NSNumber numberWithFloat:moveX] forKey:@"x"];
    [accDict setObject:[NSNumber numberWithFloat:moveY] forKey:@"y"];
    [accDict setObject:[NSNumber numberWithFloat:moveZ] forKey:@"z"];
    [_mtData._accPoints addObject:accDict];
    
    [_resultLabel setText:[NSString stringWithFormat:@"x:%.2f y:%.2f z:%.2f",moveX,moveY,moveZ]];
}

-(IBAction)isCollectingData:(id)sender{
    UISwitch *collectingSwitch = (UISwitch*)sender;
    if(collectingSwitch.on){
        NSLog(@"enabled");
        //turn on
        [self startAcc];
        // Use the acceleration data.
    } else{
        //stop
        
        [self stopAcc];
       // [_mtData generateVelAndPosData];
        for(NSDictionary *dict in _mtData._accPoints) {
            NSLog(@"%f,%f,%f;",((NSNumber*)[dict objectForKey:@"x"]).floatValue,((NSNumber*)[dict objectForKey:@"y"]).floatValue,((NSNumber*)[dict objectForKey:@"z"]).floatValue);
        }
       // NSLog(@"ACCDATA: %@",_mtData._accPoints);
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

- (IBAction)switched:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
