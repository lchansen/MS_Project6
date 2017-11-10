//
//  ViewController.m
//  Lab2
//
//  Created by Oscar on 9/20/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//

#import "TrainingViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "math.h"
#import "Assignment6-Swift.h"

#define BUFFER_SIZE 262144

@interface TrainingViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) HTTPHandler *httpHandler;
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) NSTimer *repeatTimer;
@property (weak, nonatomic) IBOutlet UILabel *testLabel; //this is the timer that displays to the right of the RECORD button
@property (weak, nonatomic) IBOutlet UITextField *classLabel;
@property (nonatomic) float *arrayData;
@property (weak, nonatomic) IBOutlet UILabel *dsid;
@property (weak, nonatomic) IBOutlet UIStepper *dsidStepper;
@property (nonatomic) NSInteger secondCount;
@property (weak, nonatomic) IBOutlet UITextField *k_neighbors;
@property (weak, nonatomic) IBOutlet UITextField *svm_kernel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *knn_resub;
@property (weak, nonatomic) IBOutlet UILabel *svm_resub;



@end

@implementation TrainingViewController

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

- (IBAction)recordStart:(id)sender {
    [self sendAudio];
}

-(bool)textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.classLabel.delegate = self;
    self.k_neighbors.delegate = self;
    self.svm_kernel.delegate = self;
    [self initDSID:0];
    self.spinner.hidesWhenStopped = YES;
    [self.httpHandler getDSIDWithVc:self];
    __block TrainingViewController * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    [self.audioManager play];
}

- (void) timerLabel {
    if(self.secondCount == -1) {
        [self.repeatTimer invalidate];
        NSMutableArray *myArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < BUFFER_SIZE; i++) {
            NSNumber *number = [NSNumber numberWithFloat:self.arrayData[i]];
            [myArray addObject:number];
        }
        [self.spinner startAnimating];
        self.statusLabel.text = nil;
        [self.httpHandler trainWithDsid:(int)self.dsidStepper.value sampleRate:44100 signal:myArray label:self.classLabel.text vc:self];
        return;
    }
    self.testLabel.text = [NSString stringWithFormat: @"%li", (long)self.secondCount];
    self.secondCount--;
}

- (void)sendAudio {
    self.arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    self.secondCount = 4;
    self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(timerLabel)
                                                      userInfo:nil
                                                       repeats:YES];
    
}

//only called by viewdidload, and the callback from
- (void)initDSID:(NSInteger) d{
    self.dsid.text = [NSString stringWithFormat:@"%ld",(long)d];
    self.dsidStepper.value = (double)d;
}

- (IBAction)dsidStepperChanged:(UIStepper *)sender {
    self.dsid.text = [NSString stringWithFormat:@"%ld",(long)sender.value];
}

- (IBAction)updateModel:(UIButton *)sender {
    //k_neighbors defaults to 1
    int n = [self.k_neighbors.text intValue];
    n = (n!=0) ? n : 1;
    
    //svm_kernel defaults to the "rbf"
    NSString* kernel = self.svm_kernel.text;
    kernel = [@[@"linear", @"polynomial", @"rbf", @"sigmoid"] containsObject: kernel] ? kernel : @"rbf";
    self.statusLabel.text = nil;
    [self.spinner startAnimating];
    [self.httpHandler updateModelWithDsid:(int)self.dsidStepper.value
                              n_neighbors:n
                               svm_kernel:kernel
                                       vc:self
     ];
}

-(void)callbackLabel:(NSString*)label knn:(NSString*)knn svm:(NSString*)svm {
    self.statusLabel.text = label;
    self.knn_resub.text = knn;
    self.svm_resub.text = svm;
    [self.spinner stopAnimating];
}

-(void) viewDidDisappear:(BOOL)animated {
}

@end


