//
//  BackendRenderConnector.h
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMICMainServer.h"

@protocol BackendConnectorDelegate

- (void)getIOSurfaceID:(u_int32_t)sid;
- (void)display;

@end

@interface BackendConnector : NSObject
{
    CMICMainServer* _server;//weak
    NSTask* _task;
    NSMachPort* _renderPort;
    u_int32_t _iosurfaceId;
}

@property(nonatomic, readonly) u_int32_t renderIndex;
@property(nonatomic, assign) id<BackendConnectorDelegate> delegate;

- (instancetype)initWithServer:(CMICMainServer*)server backendIndex:(u_int32_t)index;
- (void)launchBackendTask;

/* Render =====> MainServer */
- (void)checkInRender:(mach_port_t)renderPort index:(int32_t)renderIndex iosurfaceId:(u_int32_t)sid;
- (void)display;
- (void)iosurfaceIdChanged:(u_int32_t)sid;

/* MainServer =====> Render */
- (void)resetRenderSize:(NSSize)size;

@end
