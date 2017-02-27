//
//  SceneLayout.m
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import "SceneLayout.h"
#import "BackendConnector.h"
#import "IOSurfaceRenderView.h"
#import "CMICMarcos.h"

@implementation SceneLayout

-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewDidResize:) name:NSViewFrameDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_renderView release];
    [_renderConnector release];
    [super dealloc];
}

- (void)setupIOSurfaceRenderView
{
    _renderView = [[IOSurfaceRenderView alloc] init];
    [_renderView setFrame:NSMakeRect(0, 0, layer_initial_size, layer_initial_size)];
    [self addSubview:_renderView];
}

- (void)launchBackendRender
{
    _renderConnector = [[CMICMainServer sharedServer] createNewBackendTaskWithDelegate:self];
    [_renderConnector launchBackendTask];
}

#pragma mark - view frame observer
- (void)onViewDidResize:(NSNotification*)noti
{
    if(noti.object == self) {
        if (_renderView.frame.size.width != self.frame.size.width ||
            _renderView.frame.size.height != self.frame.size.height) {
            [_renderView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
            [_renderConnector resetRenderSize:_renderView.frame.size];
            [_renderView updateIOSurfaceSize];
        }
    }
}

#pragma mark - BackendConnector delegate
- (void)getIOSurfaceID:(u_int32_t)sid
{
    [_renderView setIOSurfaceId:sid];
}

- (void)display
{
    [_renderView setNeedsDisplay:YES];
}

#pragma mark - layout delegate
- (NSString*)layoutTitle
{
    return @"Scene";
}

- (NSSize)layoutMinSize
{
    return NSZeroSize;
}

@end
