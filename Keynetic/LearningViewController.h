//
//  LearningViewController.h
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionData.h"
#import "MotionDataAnalyzer.h"

@interface LearningViewController :UIViewController <UIAccelerometerDelegate>{
    UIAccelerometer *_accelerometer;
    MotionData *_mtData;
    float accelX, accelY, accelZ;
    float time;
    BOOL collectingData;
    NSTimer *timer;
}

@property (nonatomic, retain) UIAccelerometer *_accelerometer;
@property (nonatomic, retain) IBOutlet UILabel *_resultLabel;

-(IBAction)saveDataToFile:(id)sender;
-(IBAction)collectData:(id)sender;
-(IBAction)isCollectingData:(id)sender;
-(IBAction)compareDataFromFile:(id)sender;



@end
