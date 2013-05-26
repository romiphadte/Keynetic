//
//  MotionData.h
//  Keynetic
//
//  Created by Siddhant Dange on 5/25/13.
//  Copyright (c) 2013 keynetic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MotionData : NSObject{
}

@property (nonatomic, retain) NSMutableArray *_accPoints, *_velPoints, *_posPoints;

-(void)trimData;
-(MotionData*)initWithAssets;
-(void)generateVelAndPosData;
-(MotionData*)initWithAccData:(NSArray*)accData;

+(BOOL)saveMotionData:(MotionData*)mtData;
+(MotionData*)loadMotionData;

@end
