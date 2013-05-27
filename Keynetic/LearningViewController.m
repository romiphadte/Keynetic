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
    //dynamic time warping
    stdDev /= (counter - 1);

    stdDev = sqrtf(stdDev);
    NSLog(@"STDDEV: %f",stdDev);
    
    BOOL passed = NO;
    if(stdDev > 0.20)
        passed = NO;
    
    float both = stdDev * 40 + [self compareData:modelMotion]/100 * 60;
    NSLog(@"BOTH: %f",both);
    if(both < 50)
        passed = YES;
    // BOOL passed = [self compareData:modelMotion];
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
    
    resultStr = [resultStr stringByAppendingFormat:@""];
    
    [_resultLabel setText:resultStr];
    [_resultLabel setTextColor:labelColor];
}

-(float)compareData:(MotionData*)modelMotion{

    //bucket each of 3-tuple coordinate values into 3 different arrays
    NSMutableDictionary *sampleHistogram = [NSMutableDictionary new];
    NSMutableDictionary *modelHistogram = [NSMutableDictionary new];

    NSMutableArray *sampleXVals = [NSMutableArray new];
    NSMutableArray *sampleYVals = [NSMutableArray new];
    NSMutableArray *sampleZVals = [NSMutableArray new];

    NSMutableArray *modelXVals = [NSMutableArray new];
    NSMutableArray *modelYVals = [NSMutableArray new];
    NSMutableArray *modelZVals = [NSMutableArray new];

    for (int i = 0; i < _mtData._accPoints.count; i++) {
        [sampleXVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"x"]];
        [sampleYVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"y"]];
        [sampleZVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"z"]];

        [modelXVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"x"]];
        [modelYVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"y"]];
        [modelZVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"z"]];
    }

    [sampleHistogram setObject:sampleXVals forKey:@"x"];
    [sampleHistogram setObject:sampleYVals forKey:@"y"];
    [sampleHistogram setObject:sampleZVals forKey:@"z"];

    [modelHistogram setObject:modelXVals forKey:@"x"];
    [modelHistogram setObject:modelYVals forKey:@"y"];
    [modelHistogram setObject:modelZVals forKey:@"z"];

    //find minimum fractions of areas for each component
    float minFracX = 0.0;
    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:@"x"]).count; i++) {
        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:@"x"] objectAtIndex:i]).floatValue;
        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:@"x"] objectAtIndex:i]).floatValue;
        if(sampVal * modelVal > 0){

            //find lowest area fraction and sum
            float minVal = sampVal;
            if(sampVal > modelVal)
                minVal = modelVal;

            float minFracSlice = minVal/modelVal;
            if((minFracSlice) > (minVal/sampVal))
                minFracSlice = (minVal/sampVal);
            minFracX += minFracSlice;
        }
    }

    float minFracY = 0.0;
    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:@"y"]).count; i++) {
        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:@"y"] objectAtIndex:i]).floatValue;
        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:@"y"] objectAtIndex:i]).floatValue;
        if(sampVal * modelVal > 0){

            //find lowest area fraction and sum
            float minVal = sampVal;
            if(sampVal > modelVal)
                minVal = modelVal;

            float minFracSlice = minVal/modelVal;
            if((minFracSlice) > (minVal/sampVal))
                minFracSlice = (minVal/sampVal);
            minFracY += minFracSlice;
        }
    }
    NSLog(@"here1");
    float minFracZ = 0.0;
    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:@"z"]).count; i++) {
        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:@"z"] objectAtIndex:i]).floatValue;
        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:@"z"] objectAtIndex:i]).floatValue;
        if(sampVal * modelVal > 0){

            //find lowest area fraction and sum
            float minVal = sampVal;
            if(sampVal > modelVal)
                minVal = modelVal;

            float minFracSlice = minVal/modelVal;
            if((minFracSlice) > (minVal/sampVal))
                minFracSlice = (minVal/sampVal);
            minFracZ += minFracSlice;
        }
    }

    NSLog(@"XFRAC: %f YFRAC: %f ZFRAC: %f",minFracX,minFracY,minFracZ);

    BOOL isSimilar = NO;
    float average = (minFracX + minFracY + minFracZ)/3;
    if(average > 60)
        isSimilar = YES;

    return average;
}

//-(BOOL)compareData:(MotionData*)modelMotion{
//    
//    //bucket each of 3-tuple coordinate values into 3 different arrays
//    NSMutableDictionary *sampleHistogram = [NSMutableDictionary new];
//    NSMutableDictionary *modelHistogram = [NSMutableDictionary new];
//    
//    NSMutableArray *sampleXVals = [NSMutableArray new];
//    NSMutableArray *sampleYVals = [NSMutableArray new];
//    NSMutableArray *sampleZVals = [NSMutableArray new];
//    
//    NSMutableArray *modelXVals = [NSMutableArray new];
//    NSMutableArray *modelYVals = [NSMutableArray new];
//    NSMutableArray *modelZVals = [NSMutableArray new];
//    
//    for (int i = 0; i < _mtData._accPoints.count; i++) {
//        [sampleXVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"x"]];
//        [sampleYVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"y"]];
//        [sampleZVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"z"]];
//        
//        [modelXVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"x"]];
//        [modelYVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"y"]];
//        [modelZVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"z"]];
//    }
//    
//    [sampleHistogram setObject:sampleXVals forKey:@"x"];
//    [sampleHistogram setObject:sampleYVals forKey:@"y"];
//    [sampleHistogram setObject:sampleZVals forKey:@"z"];
//    
//    [modelHistogram setObject:modelXVals forKey:@"x"];
//    [modelHistogram setObject:modelYVals forKey:@"y"];
//    [modelHistogram setObject:modelZVals forKey:@"z"];
//    
//    //find minimum fractions of areas for each component
//    float minFracX = [self areaComparisonWithSampleHistogram:sampleHistogram andModelHistogram:modelHistogram withComponent:@"x"];
//    float minFracY = [self areaComparisonWithSampleHistogram:sampleHistogram andModelHistogram:modelHistogram withComponent:@"y"];
//    float minFracZ = [self areaComparisonWithSampleHistogram:sampleHistogram andModelHistogram:modelHistogram withComponent:@"z"];
//    
//    NSLog(@"XFRAC: %f YFRAC: %f ZFRAC: %f",minFracX,minFracY,minFracZ);
//    
//    BOOL isSimilar = NO;
//    float average = (minFracX + minFracY + minFracZ)/3;
//    if(average > 0.70)
//        isSimilar = YES;
//    
//    return isSimilar;
//}

-(float)areaComparisonWithSampleHistogram:(NSDictionary*)sampleHistogram andModelHistogram:(NSDictionary*)modelHistogram withComponent:(NSString*)component{
    //find minimum fractions of areas for each component
    float intersectionArea = 0.0;
    float sampleArea = 0.0;
    float modelArea = 0.0;
    
    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:component]).count; i++) {
        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:component] objectAtIndex:i]).floatValue;
        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:component] objectAtIndex:i]).floatValue;
        if(sampVal * modelVal > 0){
            
            //find lowest curve and add to intersection area
            float minVal = fabs(sampVal);
            if(sampVal > fabs(modelVal))
                minVal = fabs(modelVal);
            
            intersectionArea += minVal;
        }
        
        //generate total sample and model area under curves
        sampleArea += fabs(sampVal);
        modelArea += fabs(modelVal);
    }
    
    //find minimum fraction of intersection area/curve
    float minFrac = intersectionArea/sampleArea;
    if(minFrac > (intersectionArea/modelArea))
        minFrac = (intersectionArea/modelArea);
    
    return minFrac;
}

- (IBAction)switched:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(BOOL)compareData:(MotionData*)modelMotion{
//
//    //bucket each of 3-tuple coordinate values into 3 different arrays
//    NSMutableDictionary *sampleHistogram = [NSMutableDictionary new];
//    NSMutableDictionary *modelHistogram = [NSMutableDictionary new];
//
//    NSMutableArray *sampleXVals = [NSMutableArray new];
//    NSMutableArray *sampleYVals = [NSMutableArray new];
//    NSMutableArray *sampleZVals = [NSMutableArray new];
//
//    NSMutableArray *modelXVals = [NSMutableArray new];
//    NSMutableArray *modelYVals = [NSMutableArray new];
//    NSMutableArray *modelZVals = [NSMutableArray new];
//
//    for (int i = 0; i < _mtData._accPoints.count; i++) {
//        [sampleXVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"x"]];
//        [sampleYVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"y"]];
//        [sampleZVals addObject:[[_mtData._accPoints objectAtIndex:i] objectForKey:@"z"]];
//
//        [modelXVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"x"]];
//        [modelYVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"y"]];
//        [modelZVals addObject:[[modelMotion._accPoints objectAtIndex:i] objectForKey:@"z"]];
//    }
//
//    [sampleHistogram setObject:sampleXVals forKey:@"x"];
//    [sampleHistogram setObject:sampleYVals forKey:@"y"];
//    [sampleHistogram setObject:sampleZVals forKey:@"z"];
//
//    [modelHistogram setObject:modelXVals forKey:@"x"];
//    [modelHistogram setObject:modelYVals forKey:@"y"];
//    [modelHistogram setObject:modelZVals forKey:@"z"];
//
//    //find minimum fractions of areas for each component
//    float minFracX = 0.0;
//    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:@"x"]).count; i++) {
//        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:@"x"] objectAtIndex:i]).floatValue;
//        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:@"x"] objectAtIndex:i]).floatValue;
//        if(sampVal * modelVal > 0){
//
//            //find lowest area fraction and sum
//            float minVal = sampVal;
//            if(sampVal > modelVal)
//                minVal = modelVal;
//
//            float minFracSlice = minVal/modelVal;
//            if((minFracSlice) > (minVal/sampVal))
//                minFracSlice = (minVal/sampVal);
//            minFracX += minFracSlice;
//        }
//    }
//
//    float minFracY = 0.0;
//    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:@"y"]).count; i++) {
//        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:@"y"] objectAtIndex:i]).floatValue;
//        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:@"y"] objectAtIndex:i]).floatValue;
//        if(sampVal * modelVal > 0){
//
//            //find lowest area fraction and sum
//            float minVal = sampVal;
//            if(sampVal > modelVal)
//                minVal = modelVal;
//
//            float minFracSlice = minVal/modelVal;
//            if((minFracSlice) > (minVal/sampVal))
//                minFracSlice = (minVal/sampVal);
//            minFracY += minFracSlice;
//        }
//    }
//    NSLog(@"here1");
//    float minFracZ = 0.0;
//    for (int i = 0; i < ((NSArray*)[sampleHistogram objectForKey:@"z"]).count; i++) {
//        float sampVal = ((NSNumber*)[[sampleHistogram objectForKey:@"z"] objectAtIndex:i]).floatValue;
//        float modelVal = ((NSNumber*)[[modelHistogram objectForKey:@"z"] objectAtIndex:i]).floatValue;
//        if(sampVal * modelVal > 0){
//
//            //find lowest area fraction and sum
//            float minVal = sampVal;
//            if(sampVal > modelVal)
//                minVal = modelVal;
//
//            float minFracSlice = minVal/modelVal;
//            if((minFracSlice) > (minVal/sampVal))
//                minFracSlice = (minVal/sampVal);
//            minFracZ += minFracSlice;
//        }
//    }
//
//    NSLog(@"XFRAC: %f YFRAC: %f ZFRAC: %f",minFracX,minFracY,minFracZ);
//
//    BOOL isSimilar = NO;
//    float average = (minFracX + minFracY + minFracZ)/3;
//    if(average > 70)
//        isSimilar = YES;
//
//    return isSimilar;
//}

@end
