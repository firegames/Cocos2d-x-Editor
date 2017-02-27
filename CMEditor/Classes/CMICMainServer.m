//
//  CMICMainServer.m
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/25.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import "CMICMainServer.h"
#import "BackendConnector.h"
#import "CMMainMig.h"
#import "CMMainMigServer.h"

@implementation CMICMainServer

+ (CMICMainServer*)sharedServer
{
    static CMICMainServer* sharedServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServer = [[self alloc] init];
    });
    return sharedServer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverName = [[NSString stringWithFormat:@"com.cmeditor.cmic.%u", arc4random()] retain];
        _serverPort = (NSMachPort*)[[[NSMachBootstrapServer sharedInstance] servicePortWithName:_serverName] retain];
        [_serverPort setDelegate:self];
        [_serverPort scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _backendConnectors = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(portDied:)
                                                     name:NSPortDidBecomeInvalidNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskTerminated:)
                                                     name:NSTaskDidTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_serverName release];
    [_serverPort invalidate];
    [_serverPort release];
    [_backendConnectors release];
    [super dealloc];
}

- (NSArray<BackendConnector*>*)connectors
{
    return _backendConnectors;
}

- (BackendConnector*)createNewBackendTaskWithDelegate:(id<BackendConnectorDelegate>)delegate
{
    static u_int32_t connectorIndex = 1;
    BackendConnector* connector = [[BackendConnector alloc] initWithServer:self backendIndex:connectorIndex++];
    connector.delegate = delegate;
    [_backendConnectors addObject:connector];
    return connector;
}

- (void)terminateBackendTask:(BackendConnector *)connector
{
    [_backendConnectors removeObject:connector];
}

#pragma mark - port delegate & notification
- (void)handleMachMessage:(void *)msg
{
    union __ReplyUnion___CMMCCMMServer_subsystem reply;
    
    mach_msg_header_t *reply_header = (void *)&reply;
    kern_return_t kr;
    
    if(CMMServer_server(msg, reply_header) && reply_header->msgh_remote_port != MACH_PORT_NULL)
    {
        kr = mach_msg(reply_header, MACH_SEND_MSG, reply_header->msgh_size, 0, MACH_PORT_NULL, 0, MACH_PORT_NULL);
        if(kr != 0) {
            //TODO error handle
        }
    }
}

- (void)portDied:(NSNotification*)noti
{
    //TODO observe server port
    NSLog(@"port %@ terminated.", noti.object);
}

#pragma mar - task notification
- (void)taskTerminated:(NSNotification*)noti
{
    NSLog(@"task %@ terminated.", noti.object);
}

#pragma mark - IPC
kern_return_t _CMMSCheckinRender(mach_port_t server_port, mach_port_t render_port, int32_t render_index, uint32_t iosurface_id)
{
    [[CMICMainServer sharedServer].connectors enumerateObjectsUsingBlock:^(BackendConnector * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.renderIndex == render_index) {
            [obj checkInRender:render_port index:render_index iosurfaceId:iosurface_id];
            *stop = YES;
        }
    }];
    return 0;
}

kern_return_t _CMMSDisplay(mach_port_t server_port, int32_t render_index)
{
    [[CMICMainServer sharedServer].connectors enumerateObjectsUsingBlock:^(BackendConnector * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.renderIndex == render_index) {
            [obj display];
            *stop = YES;
        }
    }];
    return 0;
}

kern_return_t _CMMSIOSurfaceIdChanged(mach_port_t server_port, int32_t render_index, int32_t iosurface_id)
{
    [[CMICMainServer sharedServer].connectors enumerateObjectsUsingBlock:^(BackendConnector * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.renderIndex == render_index) {
            [obj iosurfaceIdChanged:iosurface_id];
            *stop = YES;
        }
    }];
    return 0;
}

@end
