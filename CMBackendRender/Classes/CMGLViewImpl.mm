//
//  CMGLViewImpl.cpp
//  CMBackendRender
//
//  Created by Yanjie Zhang on 3/2/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <OpenGL/gl3.h>

#include "CMGLViewImpl.h"
#include "2d/CCCamera.h"
#include "renderer/CCFrameBuffer.h"

NS_CC_BEGIN

CMGLViewImpl::CMGLViewImpl()
: _captured(false)
, _supportTouch(false)
, _isInRetinaMonitor(false)
, _frameZoomFactor(1.0f)
, _mouseX(0.0f)
, _mouseY(0.0f)
, _glView(nil)
, _glPixelFormat(nil)
, _glContext(nil)
, _iosurfaceId(-1)
, _fboName(-1)
, _textureName(-1)
{
    _viewName = "cocos2dx";
}

CMGLViewImpl::~CMGLViewImpl()
{
    CCLOGINFO("deallocing CMGLViewImpl: %p", this);
}

CMGLViewImpl* CMGLViewImpl::createWithRect(const std::string& viewName, Rect rect, float frameZoomFactor)
{
    auto ret = new (std::nothrow) CMGLViewImpl;
    if(ret && ret->initWithRect(viewName, rect, frameZoomFactor)) {
        ret->autorelease();
        return ret;
    }
    
    return nullptr;
}

bool CMGLViewImpl::initWithRect(const std::string& viewName, Rect rect, float frameZoomFactor)
{
    setViewName(viewName);
    _screenSize = rect.size;
    _designResolutionSize = rect.size;
    _frameZoomFactor = frameZoomFactor;
    _viewPortRect = rect;
    
    //init glView
    _glView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, _screenSize.width, _screenSize.height)];
    
    //init pixel format
#define ADD_ATTR(x) { attributes[attributeCount++] = x; }
#define ADD_ATTR2(x, y) { ADD_ATTR(x); ADD_ATTR(y); }
    unsigned int attributeCount = 0;
    NSOpenGLPixelFormatAttribute attributes[40];
    ADD_ATTR(NSOpenGLPFAAccelerated);
    ADD_ATTR(NSOpenGLPFAClosestPolicy);
    ADD_ATTR2(NSOpenGLPFAAuxBuffers, 0);
    ADD_ATTR2(NSOpenGLPFAAccumSize, 0);
    int colorBits = _glContextAttrs.redBits + _glContextAttrs.greenBits + _glContextAttrs.blueBits;
    ADD_ATTR2(NSOpenGLPFAColorSize, colorBits);
    ADD_ATTR2(NSOpenGLPFAAlphaSize, _glContextAttrs.alphaBits);
    ADD_ATTR2(NSOpenGLPFADepthSize, _glContextAttrs.depthBits);
    ADD_ATTR2(NSOpenGLPFAStencilSize, _glContextAttrs.stencilBits);
    ADD_ATTR(NSOpenGLPFADoubleBuffer);
    ADD_ATTR2(NSOpenGLPFASampleBuffers, 4);
    ADD_ATTR(0);
#undef ADD_ATTR
#undef ADD_ATTR2
    
    _glPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    
    if(!_glPixelFormat) {
        MessageBox("Failed to create pixel format.", "error");
        return false;
    }
    
    //init content
    _glContext = [[NSOpenGLContext alloc] initWithFormat:(NSOpenGLPixelFormat*)_glPixelFormat shareContext:nil];
    
    [(NSOpenGLContext*)_glContext setView:(NSView*)_glView];
    [(NSOpenGLContext*)_glContext makeCurrentContext];
    
    // Enable point size by default.
    glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
    
    //create IOSurfaceBuffer before initialize CCDirector, so that Director's default framebuff is IOSurfaceBuffer
    glGenTextures(1, &_textureName);
    glGenFramebuffers(1, &_fboName);
    
    this->createNewIOSurfaceAndBind(_screenSize.width, _screenSize.height);
    
    return true;
}

void CMGLViewImpl::createNewIOSurfaceAndBind(float width, float height)
{
    if(_iosurfaceId != -1) {
        IOSurfaceRef iosurfaceRef = IOSurfaceLookup(_iosurfaceId);
        CFRelease(iosurfaceRef);
    }
    IOSurfaceRef iosurfaceRef = IOSurfaceCreate((CFDictionaryRef)@{(id)kIOSurfaceWidth: @(width), (id)kIOSurfaceHeight: @(height), (id)kIOSurfaceBytesPerElement: @4, (id)kIOSurfaceIsGlobal: @YES});
    _iosurfaceId = IOSurfaceGetID(iosurfaceRef);
    
    glBindTexture(GL_TEXTURE_RECTANGLE, _textureName);
    CGLTexImageIOSurface2D([(NSOpenGLContext*)_glContext CGLContextObj], GL_TEXTURE_RECTANGLE, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, iosurfaceRef, 0);
    glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_RECTANGLE, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _fboName);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_RECTANGLE, _textureName, 0);
}

void CMGLViewImpl::updateContextViewIfNeeded()
{
    if ([(NSOpenGLContext*)_glContext view] != _glView) {
        [(NSOpenGLContext*)_glContext setView:(NSView*)_glView];
    }
}

bool CMGLViewImpl::isOpenGLReady()
{
    return nullptr != _glView;
}

void CMGLViewImpl::end()
{
    if(_glView) {
        [(NSObject*)_glView release];
    }
    if(_glPixelFormat) {
        [(NSObject*)_glPixelFormat release];
    }
    if(_glContext) {
        [(NSOpenGLContext*)_glContext release];
    }
    if (_textureName != -1) {
        glDeleteTextures(1, &_textureName);
    }
    if (_fboName != -1) {
        glDeleteFramebuffers(1, &_fboName);
    }
    if(_iosurfaceId != -1) {
        IOSurfaceRef iosurfaceRef = IOSurfaceLookup(_iosurfaceId);
        CFRelease(iosurfaceRef);
    }
    // Release self. Otherwise, GLViewImpl could not be freed.
    release();
}

void CMGLViewImpl::swapBuffers()
{
    if(_glContext)
        [(NSOpenGLContext*)_glContext flushBuffer];
}

void CMGLViewImpl::pollEvents() {}
bool CMGLViewImpl::windowShouldClose(){return true;}
void CMGLViewImpl::setIMEKeyboardState(bool /*bOpen*/){}

float CMGLViewImpl::getFrameZoomFactor() const
{
    return _frameZoomFactor;
}

void CMGLViewImpl::setFrameZoomFactor(float zoomFactor)
{
    if(zoomFactor < 0) zoomFactor = 0;
    if (fabs(_frameZoomFactor - zoomFactor) < FLT_EPSILON) return;
    
    _frameZoomFactor = zoomFactor;
    //更新viewport
    updateViewport();
}

void CMGLViewImpl::setFrameSize(float width, float height)
{
    if(fabs(width-_screenSize.width)>FLT_EPSILON || fabs(height-_screenSize.height)>FLT_EPSILON) {
        _designResolutionSize = _screenSize = Size(width, height);
        //重新设置NSView的大小
        [(NSView*)_glView setFrameSize:NSMakeSize(width, height)];
        [(NSOpenGLContext*)_glContext update];
        //通过调用GLView方法，修改_viewPortRect、_winSizeInPoints，以及调用Director的setGLDefaultValues方法
        updateDesignResolutionSize();
        //重建IOSurface
        this->createNewIOSurfaceAndBind(_screenSize.width, _screenSize.height);
    }
}

void CMGLViewImpl::setDesignResolutionSize(float width, float height, ResolutionPolicy resolutionPolicy) {
    
}

void CMGLViewImpl::updateViewport()
{
    setViewPortInPoints(0, 0, 0, 0);
}

void CMGLViewImpl::setViewPortInPoints(float x , float y , float w , float h)
{
    //通过_frameZoomFactor调整画布的缩放
    experimental::Viewport vp(0, 0, _screenSize.width*_frameZoomFactor, _screenSize.height*_frameZoomFactor);
    Camera::setDefaultViewport(vp);
}

bool CMGLViewImpl::isScissorEnabled()
{
    return false;
}

void CMGLViewImpl::renderTextureFromIOSurface()
{
    
}

NS_CC_END // end of namespace cocos2d;