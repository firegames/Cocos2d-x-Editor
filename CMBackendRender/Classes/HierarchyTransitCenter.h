//
//  HierarchyTransitCenter.h
//  CMBackendRender
//
//  Created by Yanjie Zhang on 7/18/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HierarchyTransitCenter : NSObject
{
    NSConnection* _connection;
    
    NSMutableArray* _array;
}

+ (instancetype)getInstance;

@end
