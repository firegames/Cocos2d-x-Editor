//
//  HierarchyTransitCenter.m
//  CMBackendRender
//
//  Created by Yanjie Zhang on 7/18/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import "HierarchyTransitCenter.h"

@implementation HierarchyTransitCenter

+ (instancetype)getInstance
{
    static HierarchyTransitCenter* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _connection = [NSConnection new];
        _array = [NSMutableArray new];
        [_array addObject:@"123"];
        
        [_connection setRootObject:_array];
        if ([_connection registerName:@"cmtest"] == NO) {
            //TODO Handle error
        }
    }
    return self;
}

- (void)dealloc
{
    [_connection release];
    [_array release];
    [super dealloc];
}

@end
