//
//  AppDelegate.h
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/18.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LayoutHandler.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property(nonatomic, readonly) LayoutHandler* layoutHanlder;

- (IBAction)btnTestHierachyButtonTouched:(id)sender;

@end

