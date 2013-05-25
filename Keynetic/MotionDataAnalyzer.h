//
//  MotionDataAnalyzer.h
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/core/types_c.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/core/core_c.h>
#import <opencv2/imgproc/imgproc_c.h>

@interface MotionDataAnalyzer : NSObject


+(MotionDataAnalyzer*)sharedInstance;

@end
