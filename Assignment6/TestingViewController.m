//
//  ViewController.m
//  Lab2
//
//  Created by Oscar on 9/20/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//

#import "TestingViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "math.h"
#import "Assignment6-Swift.h"

#define BUFFER_SIZE 262144

@interface TestingViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) HTTPHandler *httpHandler;
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) NSTimer *repeatTimer;
@property (nonatomic) NSInteger secondCount;
@property (nonatomic) float *arrayData;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UILabel *dsid;
@property (weak, nonatomic) IBOutlet UIStepper *dsidStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;



//@property (weak, nonatomic) IBOutlet UILabel *testLabel; //this is the timer that displays to the right of the RECORD button
//@property (weak, nonatomic) IBOutlet UITextField *classLabel;
//@property (weak, nonatomic) IBOutlet UITextField *k_neighbors;
//@property (weak, nonatomic) IBOutlet UITextField *svm_kernel;

@end

@implementation TestingViewController

-(HTTPHandler*)httpHandler{
    if(!_httpHandler) {
        _httpHandler = HTTPHandler.sharedInstance;
    }
    return _httpHandler;
}

-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}

-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    
    return _fftHelper;
}

-(NSTimer*)repeatTimer{
    if(!_repeatTimer) {
        _repeatTimer = [[NSTimer alloc]init];
    }
    return _repeatTimer;
}

-(NSInteger)secondCount{
    if(!_secondCount) {
        _secondCount = 0;
    }
    return _secondCount;
}

-(bool)textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDSID:1];
    self.spinner.hidesWhenStopped = YES;
    __block TestingViewController * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    [self.audioManager play];
}

- (void) updateTimerLabel {
    if(self.secondCount == -1) {
        [self.repeatTimer invalidate];
        NSMutableArray *myArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < BUFFER_SIZE; i++) {
            NSNumber *number = [NSNumber numberWithFloat:self.arrayData[i]];
            [myArray addObject:number];
        }
        NSString* clf = (self.segControl.selectedSegmentIndex==0) ? @"knn" : @"svm";
        [self.httpHandler testWithDsid:(int)self.dsidStepper.value
                              clf_name:clf
                            sampleRate:44100
                                signal:myArray
                                    vc:self
         ];
        return;
    }
    self.timerLabel.text = [NSString stringWithFormat: @"%li", (long)self.secondCount];
    self.secondCount--;
}

- (void)sendAudio {
    self.arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    self.secondCount = 4;
    self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateTimerLabel)
                                                      userInfo:nil
                                                       repeats:YES
                        ];
}

//only called by viewdidload in this case
- (void)initDSID:(NSInteger) d{
    self.dsid.text = [NSString stringWithFormat:@"%ld",(long)d];
    self.dsidStepper.value = (double)d;
}

- (IBAction)dsidStepperChanged:(UIStepper *)sender {
    self.dsid.text = [NSString stringWithFormat:@"%ld",(long)sender.value];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    self.classLabel.text = @"";
    [self.spinner startAnimating];
    [self sendAudio];
}

-(void)setCLFLabel:(NSString*) label{
    [self.spinner stopAnimating];
    self.classLabel.text = label;
}

-(void) viewDidDisappear:(BOOL)animated {
}

@end



