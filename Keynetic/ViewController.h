//
//  ViewController.h
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIAccelerometerDelegate>{
    UIAccelerometer *accelerometer;
}

@property (nonatomic, retain) UIAccelerometer *accelerometer;

@end
