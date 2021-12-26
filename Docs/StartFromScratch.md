# Start from Scratch

# Build the Live2D static lib

1. Download `Live2D SDK for Native` form <https://www.live2d.com/en/download/cubism-sdk/download-native/> and get `CubismSdkForNative-4-r.4.zip`.

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
It will be enough. Never mind the `CMakeLists.txt`s because we are build them using Xcode so they are useless.

4. Add a static library in Xcode.
`Targets -> puls -> iOS -> Static Library` name it `live2d-lib` and choose `Objective-C`
Delete `live2d_lib.h` and `live2d_lib.m` in the newly generated folder `live2d-lib/` (choose `move to trash`)

5. Drag the folder `CubismSdkForNative-4-r.4` into Xcode (put at srcroot).
Choose `Copy items if needed`.
Choose `Create groups`.
Choose `Add to targets: live2d-lib`.
Click `Done`.
Check in `Targets -> live2d-lib -> Build Phase`: `Compile Sources` should be 37 items
Here we should deleted `Link Binary With Library`(2 items) that are autimatically added by Xcode.

6. Add search path. 
Try to build and get error `'Model/CubismModel.hpp' file not found` and `"Type/CubismBasicType.hpp"`
`Targets -> live2d-lib -> build settings -> search path -> Header Search Paths`
Add `$(SRCROOT)/CubismSdkForNative-4-r.4/Core/include`(non-recursive) and `$(SRCROOT)/CubismSdkForNative-4-r.4/Framework/src`(non-recursive).
Rebuild and get error `Unknown type name 'Gluint'`

7. Add compile macros.
`Targets -> live2d-lib -> build settings -> Apple Clang -> Preprocessing -> Preprocessor Macros`
Debug: `CSM_TARGET_IPHONE_ES2` `DEBUG=1`
Release: `CSM_TARGET_IPHONE_ES2`
Build and find it works!!
But there are 282 issues, most of them are `Deprecations`. It is because Apple have deprecated OpenGL.

8. Remove issues (unneccessary)
`Targets -> live2d-lib -> build settings -> Apple Clang -> Preprocessing -> Preprocessor Macros`
Debug: `CSM_TARGET_IPHONE_ES2` `DEBUG=1` `GLES_SILENCE_DEPRECATION=1`
Release: `CSM_TARGET_IPHONE_ES2` `GLES_SILENCE_DEPRECATION=1`
Build and only get 18 issues, just ignore them.

# Configure the Project

1. Add static library.
In `Targets -> ExARLive2D (project name) -> Build Phases -> Link Binary With Libraries`, add `liblive2d-lib.a`

2. Add search path.
`Targets -> live2d-lib -> build settings -> search path -> Header Search Paths`
Add `$(SRCROOT)/CubismSdkForNative-4-r.4/Core/include`(non-recursive) and `$(SRCROOT)/CubismSdkForNative-4-r.4/Framework/src`(non-recursive).

3. Add `Live2D-binding.h` `Live2D-binding.mm` `Bridging-Header.h` from ARKit-Live2D to `ExARLive2D/`. No need to `Create Bridging Header`.
In `Targets -> ExARLive2D -> Build Settings -> Objective-C Bridging Header` add `$(PROJECT_DIR)/$(PROJECT_NAME)/Bridging-Header.h`.

4. In `Targets -> ExARLive2D -> Build Settings -> Linking -> Other Linker Flags` add `-lLive2DCubismCore`
and in `Targets -> ExARLive2D -> Build Settings -> Library search path` add  `$(SRCROOT)/CubismSdkForNative-4-r.4/Core/lib/ios/$(CONFIGURATION)-$(PLATFORM_NAME)`

5. Copy all files and it should build.

6. Set the `Info.plist`.

7. Remove issues (unneccessary)
`Targets -> ExARLive2D -> build settings -> Apple Clang -> Preprocessing -> Preprocessor Macros`
Debug: `CSM_TARGET_IPHONE_ES2` `DEBUG=1` `GLES_SILENCE_DEPRECATION=1`
Release: `CSM_TARGET_IPHONE_ES2` `GLES_SILENCE_DEPRECATION=1`
Build and only get 18 issues, just ignore them.

- - - 

# References

https://www.cxyzjd.com/article/weixin_30420045/114690603

https://github.com/mzyy94/ARKit-Live2D
