//
//  KeyHelper.m
//  SafeSound
//
//  Created by Demetri Miller on 10/22/2010.
//  Copyright 2010 Demetri Miller. All rights reserved.
//

#import "KeyHelper.h"

@implementation KeyHelper

@synthesize keyMapping;
@synthesize frequencyMapping;

- (void)buildKeyMapping {
	self.keyMapping = [[NSMutableDictionary alloc] initWithCapacity:9];
	[keyMapping setObject:[NSNumber numberWithFloat:82.4] forKey:@"e2"];
	[keyMapping setObject:[NSNumber numberWithFloat:110.0] forKey:@"a"];
	[keyMapping setObject:[NSNumber numberWithFloat:146.8] forKey:@"d"];
	[keyMapping setObject:[NSNumber numberWithFloat:196.0] forKey:@"g"];
	[keyMapping setObject:[NSNumber numberWithFloat:246.9] forKey:@"b"];
	
	self.frequencyMapping = [[NSMutableDictionary alloc] initWithCapacity:9];
	[frequencyMapping setObject:@"e2" forKey:[NSNumber numberWithFloat:82.4]];
	[frequencyMapping setObject:@"a" forKey:[NSNumber numberWithFloat:110.0]];
	[frequencyMapping setObject:@"d" forKey:[NSNumber numberWithFloat:146.8]];
	[frequencyMapping setObject:@"g" forKey:[NSNumber numberWithFloat:196.0]];
	[frequencyMapping setObject:@"b" forKey:[NSNumber numberWithFloat:246.9]];
}

// Gets the character closest to the frequency passed in. 
- (NSString *)closestCharForFrequency:(float)frequency {
	NSString *closestKey = nil;
	float closestFloat = MAXFLOAT;	// Init to largest float value so all ranges closer.
	
	// Check each values distance to the actual frequency.
	for(NSNumber *num in [keyMapping allValues]) {
		float mappedFreq = [num floatValue];
		float tempVal = fabsf(mappedFreq-frequency);
		if (tempVal < closestFloat) {
			closestFloat = tempVal;
			closestKey = [frequencyMapping objectForKey:num];
		}
	}
	
	return closestKey;
}


static KeyHelper *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (KeyHelper *)sharedInstance
{
	if (sharedInstance == nil) {
		sharedInstance = [[KeyHelper alloc] init];
		[sharedInstance buildKeyMapping];
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
