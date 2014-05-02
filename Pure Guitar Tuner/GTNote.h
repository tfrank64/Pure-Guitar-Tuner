//
//  GTNote.h
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 5/1/14.
//  Copyright (c) 2014 Taylor Franklin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTNote : NSObject

@property (nonatomic, assign) double currentFrequency;
@property (nonatomic, strong) NSString *currentNote;

- (void)calculateCurrentNote:(double)freqency;

@end
