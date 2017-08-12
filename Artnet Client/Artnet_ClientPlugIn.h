//
//  Artnet_ClientPlugIn.h
//  Artnet Client
//
//  Created by Fabian Scheidt on 27.07.14.
//  Copyright (c) 2014 Fabian Scheidt. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "AsyncUdpSocket.h"

@interface Artnet_ClientPlugIn : QCPlugIn <AsyncUdpSocketDelegate>
{
    AsyncUdpSocket* socket;
    NSArray* newArtnetStructure;
    NSUInteger newSubnet;
    NSUInteger newUniverse;
}

@property NSUInteger inputSubnet;
@property NSUInteger inputUniverse;
@property (assign) NSArray* outputArtnetStructure;

@end
