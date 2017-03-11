#Cocos2d-x Editor (Under developing)

An editor for game engine cocos2d-x. 

The editor comprised with frontend editor and backend render. The editor compile user's c++ codes into a dynamic library. The backend render loads the library and the resources. Then render it in the background and use IOSurface to share the GL texture to the frontend editor.


Key technologies: IOSurface, IPC(Mac Interprocess Communication), Dynamic Library.

