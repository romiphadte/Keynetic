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

-(MotionData*)initWithAssets{
    self = [[MotionData alloc] init];
    self._accPoints = [NSMutableArray new];
    self._velPoints = [NSMutableArray new];
    self._posPoints = [NSMutableArray new];
    
    return self;
}


-(MotionData*)initWithAccData:(NSArray*)accData{
    self = [[MotionData alloc] init];
    self._accPoints = [NSMutableArray new];
    self._velPoints = [NSMutableArray new];
    self._posPoints = [NSMutableArray new];
    
    self._accPoints = [NSArray arrayWithArray:accData];
    NSLog(@"ONE: %d TWO: %d",accData.count, self._accPoints.count);
    
    return self;
}

-(void)generateVelAndPosData{
    for(int i = 0; i < self._accPoints.count; i++){
        float time = 0.1;
        
        //acc points
        NSDictionary* dict = [self._accPoints objectAtIndex:i];
        float aX = ((NSNumber*)[dict objectForKey:@"x"]).floatValue;
        float aY = ((NSNumber*)[dict objectForKey:@"y"]).floatValue;
        float aZ = ((NSNumber*)[dict objectForKey:@"z"]).floatValue;
        
        //transform and log to velocity pts
        NSMutableDictionary *velPoint = [NSMutableDictionary new];
        float pVX = 0, pVY = 0, pVZ = 0;
        if(i != 0){
            NSDictionary *velDict = [self._velPoints objectAtIndex:(i-1)];
            pVX = ((NSNumber*)[velDict objectForKey:@"x"]).floatValue;
            pVY = ((NSNumber*)[velDict objectForKey:@"y"]).floatValue;
            pVZ = ((NSNumber*)[velDict objectForKey:@"z"]).floatValue;
        }
        
        [velPoint setObject:[NSNumber numberWithFloat:(pVX + (aX * time))] forKey:@"x"];
        [velPoint setObject:[NSNumber numberWithFloat:(pVY + (aY * time))] forKey:@"y"];
        [velPoint setObject:[NSNumber numberWithFloat:(pVZ + (aZ * time))] forKey:@"z"];
        [self._velPoints addObject:velPoint];
        
        //transform and log to pos pts
        NSMutableDictionary *posPoint = [NSMutableDictionary new];
        float pPX = 0, pPY = 0, pPZ = 0;
        if(i != 0){
            NSDictionary *posDict = [self._posPoints objectAtIndex:(i-1)];
            pPX = ((NSNumber*)[posDict objectForKey:@"x"]).floatValue;
            pPY = ((NSNumber*)[posDict objectForKey:@"y"]).floatValue;
            pPZ = ((NSNumber*)[posDict objectForKey:@"z"]).floatValue;
        }
        
        [posPoint setObject:[NSNumber numberWithFloat:(pPX + ((0.5 * aX) * pow(time, 2)))] forKey:@"x"];
        [posPoint setObject:[NSNumber numberWithFloat:(pPY + ((0.5 * aY) * pow(time, 2)))] forKey:@"y"];
        [posPoint setObject:[NSNumber numberWithFloat:(pPZ + ((0.5 * aZ) * pow(time, 2)))] forKey:@"z"];
        [self._posPoints addObject:posPoint];
    }
        
    
}

-(void)trimData{
    for (int i = 0; i < _accPoints.count; i++) {
        NSDictionary *dict = [_accPoints objectAtIndex:i];
        
        if(((NSNumber*)[dict objectForKey:@"x"]).floatValue == 0 && ((NSNumber*)[dict objectForKey:@"y"]).floatValue == 0 && ((NSNumber*)[dict objectForKey:@"z"]).floatValue == 0){
            [_accPoints removeObjectAtIndex:i];
            i--;
        }
    }
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
