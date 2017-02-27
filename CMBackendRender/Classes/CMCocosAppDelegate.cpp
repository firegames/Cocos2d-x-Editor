//
//  CMCocosAppDelegate.cpp
//  CMBackendRender
//
//  Created by Yanjie Zhang on 3/2/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#include "CMCocosAppDelegate.h"
#include "platform/CCGLView.h"

USING_NS_CC;

CMCocosAppDelegate::CMCocosAppDelegate()
{
}

CMCocosAppDelegate::~CMCocosAppDelegate()
{
}

void CMCocosAppDelegate::initGLContextAttrs()
{
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};
    cocos2d::GLView::setGLContextAttrs(glContextAttrs);
}

void CMCocosAppDelegate::applicationDidEnterBackground(){}
void CMCocosAppDelegate::applicationWillEnterForeground(){}

bool CMCocosAppDelegate::applicationDidFinishLaunching()
{
    
    return true;
}