//
//  PassView.h
//  KeyxneticPasswordKey
//
//  Created by Tyler Flowers on 5/25/13.
//  Copyright (c) 2013 CodeDaySF2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassView : UIViewController <UITextFieldDelegate>{
    
    IBOutlet UITextField *usrFld;
    IBOutlet UITextField *passFld;
    
    IBOutlet UIButton *failBttn;
    IBOutlet UIButton *advanceBttn;
    
}

- (IBAction)gestrureFailed:(id)sender;
- (IBAction)gestrureSucceed:(id)sender;

@end
