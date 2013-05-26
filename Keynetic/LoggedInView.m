//
//  LoggedInView.m
//  KineticPasswordKey
//
//  Created by Tyler Flowers on 5/25/13.
//  Copyright (c) 2013 CodeDaySF2013. All rights reserved.
//

#import "LoggedInView.h"

@interface LoggedInView ()

@end

@implementation LoggedInView

@synthesize usernameString;

- (IBAction)closeView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    label.text = [NSString stringWithFormat:@"Congrats %@\nYou succesfully logged in.",usernameString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
