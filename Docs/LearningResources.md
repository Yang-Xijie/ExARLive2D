# Learning Resources for Live2D

# Frameworks for Face Tracking - Apple

## Vision

https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time

`Vision` uses 2D images to detect face.

## ARKit

https://developer.apple.com/documentation/arkit/content_anchors/tracking_and_visualizing_faces

`ARKit` uses true depth front camera to detect face model.

## Face Tracking with ARKit (video)

https://developer.apple.com/videos/play/tech-talks/601

# GitHub Project

## mzyy94/ARKit-Live2D

https://github.com/mzyy94/ARKit-Live2D

This project uses `ARKit` to capture your face and cast the parameters to live2d models.
 
If you want to use the live2d model to stream on Mac, just set the background to green and use OBS to access the screen mirror of iPhone or iPad. Check https://www.mzyy94.com/blog/2020/02/25/virtual-bishoujo-meeting/ for more information.

# Live2D Official

`SDK manual` https://docs.live2d.com/cubism-sdk-manual/top/?locale=en_us 

`SDK tutorials` https://docs.live2d.com/cubism-sdk-tutorials/top/?locale=en_us

Download `Live2D SDK for Native` https://www.live2d.com/en/download/cubism-sdk/download-native/

`Cubism Core API reference (jp or en)` https://docs.live2d.com/cubism-sdk-manual/cubism-core-api-reference/
- Target
    - Users of Live2D Cubism SDK
    - Those who are considering embedding wrapper to call Core from other languages such as Java and Python
    - Those who are considering embedding into other programs or platform such as game engines.
- no use for common user... Core is invisible if you just use the framework.

https://docs.live2d.com/cubism-editor-manual/palametor/?locale=en_us

https://docs.live2d.com/cubism-editor-manual/standard-parametor-list/?locale=ja

https://docs.live2d.com/cubism-sdk-manual/parameters/

# Use C++ Codes in Live2D in Swift

Importing Objective-C into Swift

https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift

How to consume C++ codes in Swift

https://anuragajwani.medium.com/how-to-consume-c-code-in-swift-b4d64a04e989
