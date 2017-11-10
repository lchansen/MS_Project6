//
//  ViewController.m
//  Assignment6
//
//  Created by Luke Hansen on 11/10/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//

#import "ViewController.h"
#import "Assignment6-Swift.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) HTTPHandler *httpHandler;
@property (weak, nonatomic) IBOutlet UIButton *trainButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UILabel *message;
@end

@implementation ViewController
-(HTTPHandler*)httpHandler{
    if(!_httpHandler) {
        _httpHandler = HTTPHandler.sharedInstance;
    }
    return _httpHandler;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.username.delegate = self;
    self.password.delegate = self;
}

-(bool)textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButton:(UIButton *)sender {
    [self.httpHandler loginWithUser:self.username.text
                               pass:self.password.text
                                 vc:self];
}

-(void)loginSucess{
    self.trainButton.enabled = YES;
    self.testButton.enabled = YES;
    self.message.textColor = UIColor.greenColor;
    self.message.text = @"Success";
}
-(void)loginFail{
    self.trainButton.enabled = NO;
    self.testButton.enabled = NO;
    self.message.textColor = UIColor.redColor;
    self.message.text = @"Username or Password is Incorrect";
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
