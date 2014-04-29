//
//  PitchDetector.h
//  SingingPitchCoach
//
//  Created by Edward on 1/1/14.
//  Copyright (c) 2014 Edward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
//#import <SpriteKit/SpriteKit.h>

@class test_1_4096_0;
@class test_1_4096_50;
@class test_1_8192_0;
@class test_1_8192_50;
@class test_1_16384_0;
@class test_1_16384_50;
@class MainViewController;

/**
 *	This is a singleton class that manages all the low level CoreAudio/RemoteIO
 *	elements. A singleton is used since we should never be instantiating more
 *  than one instance of this class per application lifecycle.
 */
#define kInputBus 1         // Audio Unit Element
#define kOutputBus 0        // Audio Unit Element

@interface PitchDetector : NSObject
{
    test_1_4096_0 *test_1_4096_0UI;
    test_1_4096_50 *test_1_4096_50UI;
    test_1_8192_0 *test_1_8192_0UI;
    test_1_8192_50 *test_1_8192_50UI;
    test_1_16384_0 *test_1_16384_0UI;
    test_1_16384_50 *test_1_16384_50UI;
    MainViewController *mainViewPitch;

    
    NSUserDefaults *userDefaults;
    
    float sampleRate;                           // Fix this sample rate, as Human Pitch Range A0(27.5Hz) to B8(7900Hz)
    long percentageOfOverlap;                    // in %, [0-100) Percentage of Frame overlap
    
    AUGraph processingGraph;                    // Audio Unit Processing Graph
	AudioUnit ioUnit;                           // Microphone
	AudioBufferList* bufferList;                // Buffer for 1 frame, 1 frame = 1024samples
	AudioStreamBasicDescription streamFormat;   // Sample Rate: 44100, bytes per sample: 2 bytes
    
	FFTSetup fftSetup;                          // vDSP_create_fftsetup(log2n, FF_RADIX2)
	COMPLEX_SPLIT FFT;                          // Convert from outputBuffer to split complex vector
    COMPLEX_SPLIT Cepstrum;
	int log2n, n, nOver2;                       // default: 11, 2048, 1024
	
	void *dataBuffer;                           // Buffer for Obtaining data from Microphone Audio Unit
	float *outputBuffer;                        // Convert from dataBuffer, but still in interleaved Complex vector
    // After FFT, convert back from A(in frequency value),
    // and find the pitch
	size_t index;                               // Current buffer usage of dataBuffer
    size_t bufferCapacity;                      // default: 2048 (bytes) as 2 bytes per sample
    
    UInt32 maxFrames;
    
}

/* Setup the singleton Detector */
+ (id)sharedDetector;
- (id)init;
- (Boolean)isDetectorRunning;

/* Initialize Audio Session - Setup Sample Rate, Specify the Stream Format and FFT Setup */
- (void)initializePitchDetecter;
- (size_t)ASBDForSoundMode;
- (void)realFFTSetup;

/* Setup the microphone and attach it with analysis callback function */
- (void)createMicrophone;

/* Initialise and Turn On, Turn On and Turn Off the microphone */
- (void)bootUpAndTurnOnMicrophone;

- (void)TurnOnMicrophone_test_1_4096_0:(test_1_4096_0*)aUI;
- (void)TurnOnMicrophone_test_1_4096_50:(test_1_4096_50*)aUI;
- (void)TurnOnMicrophone_test_1_8192_0:(test_1_8192_0*)aUI;
- (void)TurnOnMicrophone_test_1_8192_50:(test_1_8192_50*)aUI;
- (void)TurnOnMicrophone_test_1_16384_0:(test_1_16384_0*)aUI;
- (void)TurnOnMicrophone_test_1_16384_50:(test_1_16384_50*)aUI;
- (void)TurnOnMicrophoneTuner:(MainViewController *)aUI;


- (void)TurnOffMicrophone;

/* For Debug Only */
- (void)printPitchDetecterConfig;
- (void)printASBD:(AudioStreamBasicDescription)asbd;

@end
