#Cocos2d-x Editor (Under developing)
An editor for game engine cocos2d-x. 

The editor has two parts, frontend application and backend render. Compile user's c++ and js codes in the background. Load them into the backend render. Then show it in the frontend application. 

Use IOSurface to share the GL texture in two different processes.
Use IPC to communicate in two difference processes.

Key words: IOSurface, IPC(Mac Interprocess Communication), Dynamic Library.

