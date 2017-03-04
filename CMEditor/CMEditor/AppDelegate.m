//
//  AppDelegate.m
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/18.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import "AppDelegate.h"

//debug
#import "SceneLayout.h"
#import "IOSurfaceRenderView.h"
#import "CMICMainServer.h"
#import "BackendConnector.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)dealloc
{
    [_layoutHanlder release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.window setBackgroundColor:[NSColor colorWithRed:.6353 green:.6353 blue:.6353 alpha:1]];
    _layoutHanlder = [[LayoutHandler alloc] initWithView:_window.contentView];

    SceneLayout* scene = [[SceneLayout alloc] init];
    [_layoutHanlder addViewToFirstRootAsTabLayoutView:scene];
    [scene release];
    
    [scene setupIOSurfaceRenderView];
    [scene launchBackendRender];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
