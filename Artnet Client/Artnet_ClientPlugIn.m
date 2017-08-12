//
//  Artnet_ClientPlugIn.m
//  Artnet Client
//
//  Created by Fabian Scheidt on 27.07.14.
//  Copyright (c) 2014 Fabian Scheidt. All rights reserved.
//

#import <OpenGL/CGLMacro.h>

#import "Artnet_ClientPlugIn.h"

#define	kQCPlugIn_Name				@"Artnet Client"
#define	kQCPlugIn_Description		@"This Plugin receives Artnet-Data and outputs it as Structure"

@implementation Artnet_ClientPlugIn

@dynamic inputSubnet, inputUniverse, outputArtnetStructure;

+ (NSDictionary *)attributes
{
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    if([key isEqualToString:@"inputSubnet"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Subnet", QCPortAttributeNameKey,
                0, QCPortAttributeDefaultValueKey,
                nil];
    
    if([key isEqualToString:@"inputUniverse"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Universe", QCPortAttributeNameKey,
                0, QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"outputArtnetStructure"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Artnet Structure", QCPortAttributeNameKey,
                nil];
    
    return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	return kQCPlugInTimeModeIdle;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		// No need to allocate any permanent resource required by the plug-in...
	}
	
	return self;
}

@end


@implementation Artnet_ClientPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context {
    // Setup Socket
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [socket bindToPort:6454 error:nil];
    [socket receiveWithTimeout:-1 tag:0];
    
    newArtnetStructure = [[NSArray alloc] init];
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context {
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments {
    // Input
    newSubnet   = self.inputSubnet;
    newUniverse = self.inputUniverse;
    
    // Output
    self.outputArtnetStructure = newArtnetStructure;
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
}

- (void)stopExecution:(id <QCPlugInContext>)context {
}


-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {

    // Array for Output-Values
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    // Get Data
    unsigned char* binData = (unsigned char*) [data bytes];
    
    // Artnet?
    if (binData[0] == 0x41 && binData[1] == 0x72 && binData[2] == 0x74 && binData[3] == 0x2D && binData[4] == 0x4E && binData[5] == 0x65 && binData[6] == 0x74) {
        
        // Right Universe?
        NSLog(@"Expected: Subnet: %hhd Universe: %hhd \n Actual: Subnet: %hhu Universe: %hhu ", (char)newSubnet, (char)newUniverse,binData[14], binData[15]);
        if((NSUInteger)binData[14] == self.inputSubnet && (NSUInteger)binData[15] == self.inputUniverse) {
            NSLog(@"True");
            // Save Data to Array
            for(int i=0; i<512; i++) {
                double value = ((double)binData[18+i])/255;
                [values addObject:[NSNumber numberWithDouble:value]];
            }
        }
    }
    
    newArtnetStructure = [NSArray arrayWithArray:values];
    
    return false;
}

@end
