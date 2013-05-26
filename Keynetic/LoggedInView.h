//
//  LoggedInView.h
//  KineticPasswordKey
//
//  Created by Tyler Flowers on 5/25/13.
//  Copyright (c) 2013 CodeDaySF2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoggedInView : UIViewController {
    
    IBOutlet UILabel *label;
}

@property (nonatomic, retain) NSString *usernameString;

-(IBAction)closeView:(id)sender;

@end
