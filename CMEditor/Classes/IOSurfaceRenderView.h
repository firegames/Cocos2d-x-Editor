//
//  IOSurfaceRenderView.h
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOSurface/IOSurface.h>
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>

@interface IOSurfaceRenderView : NSView
{
    NSOpenGLContext *_glContext;
    NSOpenGLPixelFormat *_glPixelFormat;
    
    uint32_t _iosurfaceId;
    IOSurfaceRef _iosurfaceRef;
    size_t _iosurfaceWidth, _iosurfaceHeight;
    GLuint quadVAOId, quadVBOId;
    GLuint _textureId;
    GLKMatrix4 _mvp;
    
    BOOL _quadDirty;
    BOOL _iosurfaceDirty;
}

- (void)setIOSurfaceId:(uint32_t)iosurfaceId;
- (void)updateIOSurfaceSize;

@end
