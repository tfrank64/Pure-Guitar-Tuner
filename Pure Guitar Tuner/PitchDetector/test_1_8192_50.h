//
//  test_1_8192_50.h
//  SingingPitchCoach
//
//  Created by Edward on 14/1/14.
//  Copyright (c) 2014 Edward. All rights reserved.
//
@import AVFoundation;
#import <SpriteKit/SpriteKit.h>

// Pitch's y position
#define C5_y        294.5
#define B4_y        282.5
#define ASharp4_y   270.5
#define A4_y        258.5
#define GSharp4_y   246.5
#define G4_y        234.5
#define FSharp4_y   222.5
#define F4_y        210.5
#define E4_y        198.5
#define DSharp4_y   186.5
#define D4_y        174.5
#define CSharp4_y   162.5
#define C4_y        150.5
#define B3_y        138.5
#define ASharp3_y   126.5
#define A3_y        114.5
#define GSharp3_y   102.5
#define G3_y        90.5
#define FSharp3_y   78.5
#define F3_y        67.5
#define E3_y        54.5
#define DSharp3_y   42.5
#define D3_y        30.5
#define CSharp3_y   18.5
#define C3_y        6

@class PitchDetector;

@interface test_1_8192_50 : SKScene
{
    PitchDetector *pitchDetector;
    SKSpriteNode *indicator;
    
    NSUserDefaults *userDefaults;

    SKLabelNode *instructionLabel1;
    SKLabelNode *instructionLabel2;
}

// Indicator Movement
-(int)midiToPosition:(int)midi;
-(void)moveIndicatorByMIDI:(int)midi;

@end
