//
//  CMCocosAppDelegate.hpp
//  CMBackendRender
//
//  Created by Yanjie Zhang on 3/2/16.
//  Copyright © 2016 Yanjie Zhang. All rights reserved.
//

#ifndef CMCocosAppDelegate_hpp
#define CMCocosAppDelegate_hpp

#include "cocos2d.h"

class CMCocosAppDelegate : private cocos2d::Application
{
public:
    CMCocosAppDelegate();
    ~CMCocosAppDelegate();
    void initGLContextAttrs() override;
    
    bool applicationDidFinishLaunching() override;
    void applicationDidEnterBackground() override;
    void applicationWillEnterForeground() override;
    
protected:
    
};

#endif /* CMCocosAppDelegate_hpp */
