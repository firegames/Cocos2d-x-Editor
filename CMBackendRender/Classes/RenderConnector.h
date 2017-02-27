//
//  BackendRender.h
//  CMBackendRender
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import <AppKit/AppKit.h>

@protocol RenderConnectorDelegate

- (void)resetRenderSize:(NSSize)size;

@end

@interface RenderConnector : NSObject <NSMachPortDelegate>
{
    NSString* _serverName;
    u_int32_t _renderIndex;
    u_int32_t _iosurfaceId;
    NSMachPort* _serverPort;
    NSMachPort* _localPort;
}

@property (nonatomic, assign) id<RenderConnectorDelegate> delegate;

+ (instancetype)getInstance;

/* Render =====> MainServer */
- (void)setupWithServername:(NSString*)name index:(u_int32_t)index iosurfaceId:(u_int32_t)sid;
- (void)display;
- (void)iosurfaceIdChanged:(u_int32_t)sid;

/* MainServer =====> Render */
- (void)resetRenderSize:(u_int64_t)width height:(u_int64_t)height;

@end
