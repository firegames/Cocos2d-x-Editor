//
//  SceneLayout.h
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TabLayoutContentInterface.h"
#import "BackendConnector.h"

@class IOSurfaceRenderView;

@interface SceneLayout : NSView <TabLayoutContentInterface, BackendConnectorDelegate>
{
    BackendConnector* _renderConnector;
    IOSurfaceRenderView* _renderView;
}

- (void)setupIOSurfaceRenderView;
- (void)launchBackendRender;

@end
