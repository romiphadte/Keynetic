//
//  MotionDataAnalyzer.m
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import "MotionDataAnalyzer.h"

static MotionDataAnalyzer *instance;
@implementation MotionDataAnalyzer



+(MotionDataAnalyzer*)sharedInstance{
    @synchronized(self){
        if (instance == NULL){
            instance = [[self alloc] init];
            
            //init assets here such as arrays
        }
        
    }
    
    return(instance);
}

@end
