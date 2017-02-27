//
//  CMGLViewImpl.hpp
//  CMBackendRender
//
//  Created by Yanjie Zhang on 3/2/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#ifndef CMGLViewImpl_hpp
#define CMGLViewImpl_hpp

#include "platform/CCGLView.h"

NS_CC_BEGIN

class CC_DLL CMGLViewImpl : public GLView
{
public:
    static CMGLViewImpl* createWithRect(const std::string& viewName, Rect size, float frameZoomFactor = 1.0f);
    
    void setViewPortInPoints(float x , float y , float w , float h) override;
    bool isScissorEnabled() override;
    
    bool windowShouldClose() override;
    void setIMEKeyboardState(bool bOpen) override;
    void pollEvents() override;
    
    bool isOpenGLReady() override;
    void end() override;
    void swapBuffers() override;
    
    void setFrameSize(float width, float height) override;
    void setDesignResolutionSize(float width, float height, ResolutionPolicy resolutionPolicy) override;
    
    float getFrameZoomFactor() const override;
    void setFrameZoomFactor(float zoomFactor) override;
    
    id getCocoaWindow() override { return (id)_glView; }
    id getGLContext() {return (id)_glContext;}
    unsigned int getIOSurfaceID() {return _iosurfaceId;}

    void updateContextViewIfNeeded();
    void updateViewport();
    void renderTextureFromIOSurface();
    
protected:
    CMGLViewImpl();
    virtual ~CMGLViewImpl();
    
    bool initWithRect(const std::string& viewName, Rect rect, float frameZoomFactor);
    void createNewIOSurfaceAndBind(float width, float height);
    
    bool _captured;
    bool _supportTouch;
    bool _isInRetinaMonitor;
    
    float _frameZoomFactor; //editor view 缩放专用
    
    float _mouseX;
    float _mouseY;
    
    void* _glView;
    void* _glPixelFormat;
    void* _glContext;
    
    unsigned int _iosurfaceId;
    unsigned int _fboName;
    unsigned int _textureName;
private:
    CC_DISALLOW_COPY_AND_ASSIGN(CMGLViewImpl);
};

NS_CC_END

#endif /* CMGLViewImpl_hpp */
