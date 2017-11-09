//
//  ViewController.m
//  Lab2
//
//  Created by Oscar on 9/20/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "math.h"

#define BUFFER_SIZE 8192

@interface ViewController ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@end

@implementation ViewController

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




- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block ViewController * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    [self.audioManager play];

    //we'll use this on a button to get the last x seconds after pressing a timer start
//    [NSTimer scheduledTimerWithTimeInterval:0.1
//                                     target:self
//                                   selector:@selector(update)
//                                   userInfo:nil
//                                    repeats:YES];
}


//redo all of this
- (void) update {
    // get audio stream data
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    //float* fftMag = malloc(sizeof(float)*BUFFER_SIZE/2);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    // take forward FFT
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    //[self fftAverage: fftMagnitude: fftMag];
    
    float maxVal = 0;
    vDSP_Length maxIndex = 10000000;

    for(int i = 1; i < BUFFER_SIZE/8; i++) {
        if(fftMagnitude[i] > maxVal && 20*log(fftMagnitude[i]) > 20) {
            maxVal = fftMagnitude[i];
            maxIndex = i;
        }
    }
    float maxVal2 = 0;
    vDSP_Length maxIndex2 = 10000000;
    for(int i = 1; i < BUFFER_SIZE/8; i++){
        if( ((maxIndex - i) * self.audioManager.samplingRate/(BUFFER_SIZE)) <= 30){
            i += 60;
            continue;
        }
        if(fftMagnitude[i] > maxVal2 && 20*log(fftMagnitude[i]) > 20) {
            maxVal2 = fftMagnitude[i];
            maxIndex2 = i;
        }
    }
//    float freq1 = (float)maxIndex * self.audioManager.samplingRate/(BUFFER_SIZE);
//    float freq2 = (float)maxIndex2 * self.audioManager.samplingRate/(BUFFER_SIZE);
    
    
    free(arrayData);
    free(fftMagnitude);
}

-(void) viewDidDisappear:(BOOL)animated {
}


@end

