//
//  AppDelegate.h
//  CMBackendRender
//
//  Created by Yanjie Zhang on 16/2/18.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackendRenderProtocol.h"
#import "RenderConnector.h"

@interface AppDelegate : NSObject <BackendRenderAppProtocol, RenderConnectorDelegate>
{
    NSWindow* _window;
    BOOL _sizeChanged;
    NSSize _winSize;
    
    NSString* _serverName;
    u_int32_t _renderIndex;
}

@end
