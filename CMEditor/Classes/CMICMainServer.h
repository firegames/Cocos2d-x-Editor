//
//  CMICMainServer.h
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/25.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BackendConnectorDelegate;
@class BackendConnector;

@interface CMICMainServer : NSObject <NSMachPortDelegate>
{
    NSMachPort* _serverPort;
    NSMutableArray<BackendConnector*>* _backendConnectors;
}

@property (nonatomic, readonly) NSString* serverName;
@property (nonatomic, readonly) NSArray<BackendConnector*>* connectors;

+ (CMICMainServer*)sharedServer;

- (BackendConnector*)createNewBackendTaskWithDelegate:(id<BackendConnectorDelegate>)delegate;
- (void)terminateBackendTask:(BackendConnector*)connector;

@end
