# Start from Scratch

# Build the Live2D static lib

1. Download live2d SDK for native form <https://www.live2d.com/en/download/cubism-sdk/download-native/> and get `CubismSdkForNative-4-r.4.zip`.

2. Unzip the file and get `CubismSdkForNative-4-r.4/`.
Files and folders:
CHANGELOG.md    LICENSE.md      Samples
Core            NOTICE.md       cubism-info.yml
Framework       README.md

3. Delete useless files.
```shell
cd CubismSdkForNative-4-r.4

# samples
rm -rf Samples/ # helpful if you want to see how iOS apps are created using OpenGL and Metal

# rendering
rm -rf Framework/src/rendering/D3D9 Framework/src/rendering/D3D11 Framework/src/rendering/Cocos2d # we just use Metal or OpenGL
rm -rf Framework/src/rendering/Metal # we use OpenGL here, delete Metal

# dll
rm -rf Core/dll # have noting to do with iOS

# lib
rm -rf Core/lib/android Core/lib/experimental Core/lib/linux Core/lib/macos Core/lib/windows # just leave Core/lib/ios
rm -rf Core/lib/ios/Debug-iphonesimulator Core/lib/ios/Release-iphonesimulator # to use ARKit, simulator is useless. run the project on real machine.
```
It will be enough. Never mind the CMakeLists.txt because we are build them using Xcode.

4. Add a static library in Xcode.
Targets - puls - iOS - Static Library - name it live2d-lib and choose Objective-C
delete live2d_lib.h and live2d_lib.m in the newly generated folder live2d-lib (choose move to trash)

5. Drag the folder `CubismSdkForNative-4-r.4` into Xcode (put at srcroot)
choose `Copy items if needed`
choose `Create groups`
choose `Add to targets: live2d-lib`

6. 
