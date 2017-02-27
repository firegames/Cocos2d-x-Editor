//
//  AppDelegate.m
//  CMBackendRender
//
//  Created by Yanjie Zhang on 16/2/18.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "CMICMarcos.h"
#import "CMGLViewImpl.h"
#import "HierarchyTransitCenter.h"

#include "CMCocosAppDelegate.h"
#include "cocos2d.h"

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if(self) {
        _sizeChanged = NO;
    }
    return self;
}

- (void)setupWithArguments:(NSDictionary *)dic
{
    _serverName = [[dic objectForKey:argn_server_name] retain];
    _renderIndex = [[dic objectForKey:argn_backend_index] intValue];
    NSLog(@"init: name(%@) rid(%d)", _serverName, _renderIndex);
}

- (void)dealloc
{
    [_serverName release];
    [_window release];
    [super dealloc];
}

- (NSString*)serverName
{
    return _serverName;
}

- (u_int32_t)renderIndex
{
    return _renderIndex;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //create window
    _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    [_window makeKeyAndOrderFront:nil];
//    [[NSApplication sharedApplication] hide:nil];
    
    //create cocos view
    CMCocosAppDelegate *app = new CMCocosAppDelegate();
    cocos2d::CMGLViewImpl *glView = cocos2d::CMGLViewImpl::createWithRect("CocosMaker", cocos2d::Rect(0, 0,layer_initial_size, layer_initial_size));
    [_window setContentView:(NSView*)glView->getCocoaWindow()];

    cocos2d::Director* director = cocos2d::Director::getInstance();
    director->setOpenGLView(glView);
    
    //start mainloop
    double interval = 1.0 / 60.0;
    director->setAnimationInterval(interval);
    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(mainloop) userInfo:nil repeats:YES];
    
    //debug
    director->setDisplayStats(true);
    cocos2d::Scene* scene = cocos2d::Scene::create();
    director->runWithScene(scene);
    
    cocos2d::LayerColor *layer1 = cocos2d::LayerColor::create(cocos2d::Color4B::GREEN, 20, 20);
    layer1->setPosition(cocos2d::Vec2(200,200));
    scene->addChild(layer1);
    
    //connect frontend
    [RenderConnector getInstance].delegate = self;
    [[RenderConnector getInstance] setupWithServername:_serverName index:_renderIndex iosurfaceId:glView->getIOSurfaceID()];
    
    [HierarchyTransitCenter getInstance];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (void)mainloop
{
    cocos2d::CMGLViewImpl *glView = (cocos2d::CMGLViewImpl*)cocos2d::Director::getInstance()->getOpenGLView();
    glView->updateContextViewIfNeeded();
    if(_sizeChanged == YES) {
        glView->setFrameSize(_winSize.width, _winSize.height);
        _sizeChanged = NO;
        [[RenderConnector getInstance] iosurfaceIdChanged:glView->getIOSurfaceID()];
    }
    
    cocos2d::Director::getInstance()->mainLoop();
    
    ((cocos2d::CMGLViewImpl*)cocos2d::Director::getInstance()->getOpenGLView())->renderTextureFromIOSurface();
    
    [[RenderConnector getInstance] display];
}

- (void)resetRenderSize:(NSSize)size
{
    _sizeChanged = YES;
    _winSize = size;
}

@end
