//
//  MainViewController.m
//  KineticPasswordKey
//
//  Created by Tyler Flowers on 5/25/13.
//  Copyright (c) 2013 CodeDaySF2013. All rights reserved.
//

#import "PassView.h"
#import "LoggedInView.h"

@interface PassView ()

@end

@implementation PassView

- (void)closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)passwordSucceed{
    passFld.text = @"password";
    
    LoggedInView *loggedInView = [[LoggedInView alloc] init];
    loggedInView.usernameString = usrFld.text;
    [self presentViewController:loggedInView animated:YES completion:^(void){    passFld.text = @"";
    } ];
}

-(void)passwordFail{
    passFld.text = @"";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Gesture was not recognized" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

-(IBAction)gestrureFailed:(id)sender{
    [self passwordFail];
}

-(IBAction)gestrureSucceed:(id)sender{
    [self passwordSucceed];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usrFld || textField == passFld) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    
    usrFld = [[UITextField alloc] initWithFrame:CGRectMake(112, 209, 97, 30)];
    usrFld.borderStyle = UITextBorderStyleRoundedRect;
    usrFld.placeholder = @"Username";
    usrFld.autocorrectionType = UITextAutocorrectionTypeNo;
    usrFld.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:usrFld];
    
    advanceBttn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [advanceBttn addTarget:self action:@selector(passwordSucceed) forControlEvents:UIControlEventTouchUpInside];
    [advanceBttn setFrame:CGRectMake(35, 386, 87, 44)];
    [advanceBttn setTitle:@"Advance" forState:UIControlStateNormal];
    [self.view addSubview:advanceBttn];
    
    passFld = [[UITextField alloc] initWithFrame:CGRectMake(112, 250, 97, 30)];
    passFld.borderStyle = UITextBorderStyleRoundedRect;
    passFld.placeholder = @"password";
    passFld.font = [UIFont systemFontOfSize:15];
    passFld.autocorrectionType = UITextAutocorrectionTypeNo;
    passFld.returnKeyType = UIReturnKeyDone;
    passFld.secureTextEntry = YES;
    [self.view addSubview:passFld];
    
    UIButton *closeViewBttn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeViewBttn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [closeViewBttn setTitle:@"X" forState:UIControlStateNormal];
    [closeViewBttn setFrame:CGRectMake(10, 10, 30, 30)];
    [self.view addSubview:closeViewBttn];
    
    usrFld.delegate = self;
    passFld.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
