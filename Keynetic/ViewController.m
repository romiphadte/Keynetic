//
//  ViewController.m
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize accelerometer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    NSLog(@"X: %f, Y: %f, Z: %f",acceleration.x, acceleration.y, acceleration.z);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
