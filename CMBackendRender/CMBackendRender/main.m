//
//  main.m
//  CMBackendRender
//
//  Created by Yanjie Zhang on 16/2/18.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "BackendRenderProtocol.h"

#include <string.h>
#include <dlfcn.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableDictionary *arguments = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
        for (int i=0; i<argc; i++) {
            char* equalsign = strchr(argv[i], '=');
            if (equalsign != NULL) {
                NSString* key = [NSString stringWithFormat:@"%.*s", (int)(equalsign-argv[i]), argv[i]];
                NSString* value = [NSString stringWithFormat:@"%s", equalsign+1];
                if (key!=nil && key.length>0 && value!=nil && value.length>0) {
                    [arguments setObject:value forKey:key];
                }
            }
        }
        NSApplication *app = [NSApplication sharedApplication];
        
        void* lib_handle = dlopen("libBackendRender.dylib", RTLD_LOCAL);
        if (!lib_handle) {
            NSLog(@"[%s] main: Unable to open library: %s\n",
                  __FILE__, dlerror());
        }
        else {
            Class BackendRenderApp_Class = objc_getClass("AppDelegate");
            if (!BackendRenderApp_Class) {
                NSLog(@"[%s] main: Unable to get BackendRenderApp class", __FILE__);
            }
            else {
                NSObject<BackendRenderAppProtocol>* delegate = [[BackendRenderApp_Class alloc] init];
                [delegate setupWithArguments:arguments];
                [app setDelegate:delegate];
                [app run];
                [delegate release];
            }
        }
        dlclose(lib_handle);
    }
    return 0;
}
