//
//  BackendRenderProcotol.h
//  CMBackendRender
//
//  Created by Yanjie Zhang on 5/10/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

//find function name: AppDelegate
@protocol BackendRenderAppProtocol <NSApplicationDelegate>

- (NSString*) serverName;
- (u_int32_t) renderIndex;
- (void)setupWithArguments:(NSDictionary*)dic;

@end
