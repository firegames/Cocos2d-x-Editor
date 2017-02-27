//
//  BackendRenderConnector.m
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import "BackendConnector.h"
#import "CMICMarcos.h"
#import "CMICMainServer.h"
#import "CMRenderMig.h"

@implementation BackendConnector

- (instancetype)initWithServer:(CMICMainServer *)server backendIndex:(u_int32_t)index
{
    self = [super init];
    if (self) {
        _server = server;
        _renderIndex = index;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(portDied:)
                                                     name:NSPortDidBecomeInvalidNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_task terminate]; //or  kill(_task.processIdentifier, -9)?
    [_task release];
    [_renderPort release];
    [super dealloc];
}

- (void)launchBackendTask
{
    if (_task) {
        return;//cannot launch twice
    }
    
    _task = [[NSTask alloc] init];
    _task.launchPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"../bin/CMBackendRender"];
#define ARG_STR(x, y) [NSString stringWithFormat:@"%@=%@",x,y]
    _task.arguments = @[ARG_STR(argn_server_name, _server.serverName),
                        ARG_STR(argn_backend_index, @(_renderIndex))];
    
    NSString* ldPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"../Frameworks/"];
    _task.environment = @{@"LD_LIBRARY_PATH":ldPath,
                          @"DYLD_LIBRARY_PATH":ldPath};
    [_task launch];
}

#pragma mark - noti
- (void)portDied:(NSNotification*)noti
{
    if (noti.object == _renderPort) {
        [_server terminateBackendTask:self];
    }
}

#pragma mark - RPC
- (void)checkInRender:(mach_port_t)renderPort index:(int32_t)renderIndex iosurfaceId:(u_int32_t)sid
{
    if (_renderPort != nil) {
        //TODO error: checkin twice
        [_renderPort release];
    }
    _renderPort = [[NSMachPort alloc] initWithMachPort:renderPort];
    _iosurfaceId = sid;
    
    if(_delegate != NULL) {
        [_delegate getIOSurfaceID:_iosurfaceId];
    }
}

- (void)display
{
    if(_delegate != NULL) {
        [_delegate display];
    }
}

- (void)iosurfaceIdChanged:(u_int32_t)sid
{
    _iosurfaceId = sid;
    
    if(_delegate != NULL) {
        [_delegate getIOSurfaceID:_iosurfaceId];
    }
}

- (void)resetRenderSize:(NSSize)size
{
    //need limit calling frequency
    _CMRCResetRenderSize(_renderPort.machPort, (uint64_t)size.width, (uint64_t)size.height);
}

@end

