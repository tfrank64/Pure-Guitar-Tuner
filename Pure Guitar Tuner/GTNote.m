//
//  GTNote.m
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 5/1/14.
//  Copyright (c) 2014 Taylor Franklin. All rights reserved.
//

#import "GTNote.h"

#define FSharp4 370.0
#define F4      349.2
#define E4      329.6
#define DSharp4 311.1
#define D4      293.7
#define CSharp4 277.2
#define C4      261.6
#define B3      246.9
#define ASharp3 233.1
#define A3      220.0
#define GSharp3 207.7
#define G3      196.0
#define FSharp3 185.0
#define F3      174.6
#define E3      164.8
#define DSharp3 155.6
#define D3      146.8
#define CSharp3 138.6
#define C3      130.8
#define B2      123.5
#define ASharp2 116.5
#define A2      110.0
#define GSharp2 103.8
#define G2      98.0
#define FSharp2 92.50
#define F2      87.31
#define E2      82.41
#define DSharp2 77.78

@implementation GTNote

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _currentFrequency = 0.0;
    _currentNote = @"E";
    _minFrequency = 0.0;
    _maxFreqency = 1.0;
    _targetFrequency = 0.5;
    _previousFrequency = 0.0;
    
    return self;
}

- (void)calculateCurrentNote:(double)freqency
{
//    double temp = floor(freqency);
//    double yes = floor(self.previousFrequency);
//   
//    if (![huh isEqualToString:yeppers])
//        self.previousFrequency = freqency; return;
    
    double target = 0.0;

    if (freqency < FSharp4 && freqency > E4 && ![self.currentNote isEqualToString:@"F"]) {
        target = F4;
        self.currentNote = @"F";
    } else if (freqency < F4 && freqency > DSharp4 && ![self.currentNote isEqualToString:@"E"]) {
        target = E4;
        self.currentNote = @"E";
    } else if (freqency < DSharp4 && freqency > CSharp4 && ![self.currentNote isEqualToString:@"D"]) {
        target = D4;
        self.currentNote = @"D";
    } else if (freqency < CSharp4 && freqency > B3 && ![self.currentNote isEqualToString:@"C"]) {
        target = C4;
        self.currentNote = @"C";
    } else if (freqency < C4 && freqency > ASharp3 && ![self.currentNote isEqualToString:@"B"]) {
        target = B3;
        self.currentNote = @"B";
    } else if (freqency < ASharp3 && freqency > GSharp3 && ![self.currentNote isEqualToString:@"A"]) {
        target = A3;
        self.currentNote = @"A";
    } else if (freqency < GSharp3 && freqency > FSharp3 && ![self.currentNote isEqualToString:@"G"]) {
        target = G3;
        self.currentNote = @"G";
    } else if (freqency < FSharp3 && freqency > E3 && ![self.currentNote isEqualToString:@"F"]) {
        target = F3;
        self.currentNote = @"F";
    } else if (freqency < F3 && freqency > DSharp3 && ![self.currentNote isEqualToString:@"E"]) {
        target = E3;
        self.currentNote = @"E";
    } else if (freqency < DSharp3 && freqency > CSharp3 && ![self.currentNote isEqualToString:@"D"]) {
        target = D3;
        self.currentNote = @"D";
    } else if (freqency < CSharp3 && freqency > B2 && ![self.currentNote isEqualToString:@"C"]) {
        target = C3;
        self.currentNote = @"C";
    } else if (freqency < C3 && freqency > ASharp2 && ![self.currentNote isEqualToString:@"B"]) {
        target = B2;
        self.currentNote = @"B";
    } else if (freqency < ASharp2 && freqency > GSharp2 && ![self.currentNote isEqualToString:@"A"]) {
        target = G2;
        self.currentNote = @"A";
    } else if (freqency < GSharp2 && freqency > FSharp2 && ![self.currentNote isEqualToString:@"G"]) {
        target = G2;
        self.currentNote = @"G";
    } else if (freqency < FSharp2 && freqency > E2 && ![self.currentNote isEqualToString:@"F"]) {
        target = F2;
        self.currentNote = @"F";
    } else if (freqency < F2 && freqency > DSharp2 && ![self.currentNote isEqualToString:@"E"]) {
        target = E2;
        self.currentNote = @"E";
    }
    
    if (target > 0.0)
    {
        self.minFrequency = target-20;
        self.targetFrequency = target;
        self.maxFreqency = target+20;
    }
    
    self.currentFrequency = freqency;
}

@end
