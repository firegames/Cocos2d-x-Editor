//
//  IOSurfaceRenderView.m
//  CMEditor
//
//  Created by Yanjie Zhang on 16/2/19.
//  Copyright © 2016年 Yanjie Zhang. All rights reserved.
//

#import "IOSurfaceRenderView.h"
#import <GLKit/GLKit.h>
#import <OpenGL/gl3.h>

#include "shaderUtil.h"
#include "fileUtil.h"

// shader info
enum {
    PROGRAM_TEXTURE_RECT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBS
};

typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "Shaders/texture.vsh",    "Shaders/textureRect.fsh"   },  // PROGRAM_TEXTURE_RECT
};

@implementation IOSurfaceRenderView

- (id)init
{
    self = [super init];
    if (self) {
        _quadDirty = YES;
        _iosurfaceDirty = YES;
    }
    return self;
}

- (void)dealloc
{
    if (_iosurfaceRef != NULL) {
        CFRelease(_iosurfaceRef);
        _iosurfaceRef = NULL;
    }
    [_glPixelFormat release];
    [_glContext release];
    [super dealloc];
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [_glContext update];
    _quadDirty = YES;
    [self setNeedsDisplay:YES];
}

- (void)setupOpenGL
{
    NSOpenGLPixelFormatAttribute attribs[] =
    {
        NSOpenGLPFAAllowOfflineRenderers,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAMultisample, 1,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 4,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        0
    };
    _glPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    
    //TODO handle error
    NSAssert(_glPixelFormat != nil, @"Failed to create pixel format.");
    
    _glContext = [[NSOpenGLContext alloc] initWithFormat:_glPixelFormat shareContext:nil];
    [_glContext makeCurrentContext];
    
    glGenVertexArrays(1, &quadVAOId);
    glGenBuffers(1, &quadVBOId);
}

- (void)setupShaders
{
    glBindVertexArray(quadVAOId);
    
    for (int i = 0; i < NUM_PROGRAMS; i++)
    {
        char *vsrc = readFile(pathForResource(program[i].vert));
        char *fsrc = readFile(pathForResource(program[i].frag));
        GLsizei attribCt = 0;
        GLchar *attribUsed[NUM_ATTRIBS];
        GLint attrib[NUM_ATTRIBS];
        GLchar *attribName[NUM_ATTRIBS] = {
            "inVertex", "inTexCoord",
        };
        const GLchar *uniformName[NUM_UNIFORMS] = {
            "MVP", "tex",
        };
        
        // auto-assign known attribs
        for (int j = 0; j < NUM_ATTRIBS; j++)
        {
            if (strstr(vsrc, attribName[j]))
            {
                attrib[attribCt] = j;
                attribUsed[attribCt++] = attribName[j];
            }
        }
        
        glueCreateProgram(vsrc, fsrc,
                          attribCt, (const GLchar **)&attribUsed[0], attrib,
                          NUM_UNIFORMS, &uniformName[0], program[i].uniform,
                          &program[i].id);
        free(vsrc);
        free(fsrc);
    }
    
    glBindVertexArray(0);
}

- (void)setupIOSurface
{
    if (_iosurfaceId != -1) {
        if (_iosurfaceRef != NULL) {
            CFRelease(_iosurfaceRef);
        }
        NSLog(@"setup IOSurface, id: %d", _iosurfaceId);
        _iosurfaceRef = IOSurfaceLookup(_iosurfaceId);
        if (_iosurfaceRef != NULL) {
            _iosurfaceWidth = IOSurfaceGetWidth(_iosurfaceRef);
            _iosurfaceHeight = IOSurfaceGetHeight(_iosurfaceRef);
            _quadDirty = YES;
            
            glGenTextures(1, &_textureId);
            glBindTexture(GL_TEXTURE_RECTANGLE, _textureId);
            // At the moment, CGLTexImageIOSurface2D requires the GL_TEXTURE_RECTANGLE target
            CGLTexImageIOSurface2D([_glContext CGLContextObj], GL_TEXTURE_RECTANGLE, GL_RGBA, (GLsizei)_iosurfaceWidth, (GLsizei)_iosurfaceHeight, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _iosurfaceRef, 0);
            glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
    }
    _iosurfaceDirty = NO;
}

- (void)setIOSurfaceId:(uint32_t)iosurfaceId
{
    if(iosurfaceId != _iosurfaceId) {
        _iosurfaceId = iosurfaceId;
        _iosurfaceDirty = YES;
    }
    [self setNeedsDisplay:YES];
}

- (void)updateIOSurfaceSize
{
    if (_iosurfaceRef != NULL) {
        _iosurfaceWidth = IOSurfaceGetWidth(_iosurfaceRef);
        _iosurfaceHeight = IOSurfaceGetHeight(_iosurfaceRef);
    }
    _quadDirty = YES;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_glContext == nil) {
        [self setupOpenGL];
    }
    if (_glContext.view != self) {
        [_glContext setView:self];
    }
    if ([NSOpenGLContext currentContext] != _glContext) {
        [_glContext makeCurrentContext];
    }
    if (program[PROGRAM_TEXTURE_RECT].id == 0) {
        [self setupShaders];
    }
    
    glViewport(0, 0, (GLint)self.bounds.size.width, (GLint)self.bounds.size.height);
    glClearColor(0.5f, 0.8f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    
    [self renderTextureFromIOSurface];
    
    [_glContext flushBuffer];
}

- (void)renderTextureFromIOSurface {
    if (_iosurfaceDirty == YES) {
        [self setupIOSurface];
    }
    if (_iosurfaceRef == NULL || _textureId == 0) {
        return;
    }
    if (_quadDirty == YES) {
        GLfloat quad[] = {
            0.0f, 0.0f,
            _iosurfaceWidth, 0.0f,
            0.0f, _iosurfaceHeight,
            _iosurfaceWidth, _iosurfaceHeight
        };
        glBindVertexArray(quadVAOId);
        glBindBuffer(GL_ARRAY_BUFFER, quadVBOId);
        glBufferData(GL_ARRAY_BUFFER, sizeof(quad), quad, GL_STATIC_DRAW);
        // positions
        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), NULL);
        // texture coordinates
        glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), NULL);
        
        // modelView matrix is identity, projection matrix is mvp
        _mvp = GLKMatrix4MakeOrtho(0, self.bounds.size.width, 0, self.bounds.size.height, 0, 100);
        
        _quadDirty = NO;
    }
    
    glUseProgram(program[PROGRAM_TEXTURE_RECT].id);
    glUniformMatrix4fv(program[PROGRAM_TEXTURE_RECT].uniform[UNIFORM_MVP], 1, GL_FALSE, _mvp.m);
    glUniform1i(program[PROGRAM_TEXTURE_RECT].uniform[UNIFORM_TEXTURE], 0);
    
    glBindTexture(GL_TEXTURE_RECTANGLE, _textureId);
    glEnable(GL_TEXTURE_RECTANGLE);
    
    glBindVertexArray(quadVAOId);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_TEXCOORD);
    glDisable(GL_TEXTURE_RECTANGLE);
}

@end
