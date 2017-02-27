//
//  BackendRender.m
//  CMBackendRender
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import "RenderConnector.h"
#import "CMMainMig.h"
#import "CMRenderMIG.h"
#import "CMRenderMigServer.h"

@implementation RenderConnector

+ (instancetype)getInstance
{
    static RenderConnector* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    [_serverName release];
    [_serverPort release];
    [_localPort invalidate];
    [_localPort release];
    [super dealloc];
}

- (void)handleMachMessage:(void *)msg
{
    union __ReplyUnion___CMRSCMRServer_subsystem reply;
    
    mach_msg_header_t *reply_header = (void *)&reply;
    kern_return_t kr;
    
    if(CMRServer_server(msg, reply_header) && reply_header->msgh_remote_port != MACH_PORT_NULL)
    {
        kr = mach_msg(reply_header, MACH_SEND_MSG, reply_header->msgh_size, 0, MACH_PORT_NULL, 0, MACH_PORT_NULL);
        if(kr != 0) {
            //TODO error handle
        }
    }
}

- (void)portDied:(NSNotification*)noti
{
    if (noti.object == _serverPort) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    else if(noti.object == _localPort) {
        //TODO
    }
}

- (void)setupWithServername:(NSString *)name index:(u_int32_t)index iosurfaceId:(u_int32_t)sid
{
    if (_serverPort) {
        return; //already setup
    }
    
    NSMachPort* port = (NSMachPort *)([[NSMachBootstrapServer sharedInstance] portForName:name]);
    //TODO handle error that port is null
    if (port) {
        _serverPort = [port retain];
        _serverName = [name retain];
        _renderIndex = index;
        _iosurfaceId = sid;
        _localPort = [[NSMachPort alloc] init];
        [_localPort setDelegate:self];
        [_localPort scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        _CMMCCheckinRender(_serverPort.machPort, _localPort.machPort, _renderIndex, _iosurfaceId);
    }
}

- (void)display
{
    _CMMCDisplay(_serverPort.machPort, _renderIndex);
}

- (void)iosurfaceIdChanged:(u_int32_t)sid
{
    _CMMCIOSurfaceIdChanged(_serverPort.machPort, _renderIndex, sid);
}

- (void)resetRenderSize:(u_int64_t)width height:(u_int64_t)height
{
    if (_delegate != NULL) {
        [_delegate resetRenderSize:NSMakeSize(width, height)];
    }
}

@end

#pragma mark - IPC
kern_return_t _CMRSResetRenderSize(mach_port_t server_port, uint64_t width, uint64_t height)
{
    [[RenderConnector getInstance] resetRenderSize:width height:height];
    return 0;
}
