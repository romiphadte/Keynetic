//
//  MotionData.m
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import "MotionData.h"

@implementation MotionData
@synthesize _accPoints, _velPoints, _posPoints;

-(MotionData*)init{
    _accPoints = [NSMutableArray new];
    _velPoints = [NSMutableArray new];
    _posPoints = [NSMutableArray new];
    
    return [self init];
}


-(MotionData*)initWithAccData:(NSArray*)accData{
    _accPoints = [NSMutableArray new];
    _velPoints = [NSMutableArray new];
    _posPoints = [NSMutableArray new];
    
    [_accPoints arrayByAddingObjectsFromArray:accData];
    
    return [self init];
}

-(void)generateVelAndPosData{
    
}

+(BOOL)saveMotionData:(MotionData*)mtData{
    @try {
        //save to accounts.plist
        [mtData._accPoints writeToFile:[self filepath] atomically:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR SAVING DATA TO FILE");
        return NO;
    }
    @finally {
        return YES;
    }
}

+(MotionData*)loadMotionData{
    //read from file
    NSArray *accData = [NSArray arrayWithContentsOfFile:[self filepath]];
    
    MotionData *mtData = [[MotionData alloc] initWithAccData:accData];
    return mtData;
}

+(NSString*)filepath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filepath = [paths objectAtIndex:0];
    return [filepath stringByAppendingFormat:@"/motionAccData.plist"];
}

@end
