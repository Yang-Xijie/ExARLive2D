# README

`ExARLive2D` is an app using `ARKit` to capture your face motion and cast the parameters to the live2d model.

## Usage

1. Clone or download the project.
2. Open the `ExARLive2D.xcodeproj`. In target `ExARLive2D`, set your Team Signing.
3. Run on a real device that supports FaceID (with true depth front camera, check https://support.apple.com/en-us/HT209183 to see if your devices satisfy).

## Docs

* [Build this project from scratch](./Docs/StartFromScratch.md)
* [Learning resources for face capturing and frameworks provided by Apple](./Docs/LearningResources.md)
* [Use live2d from ExARLive2D when streaming on Mac](./Docs/UseLive2DOnMac.md)

## Repo

`Issues`, `Pull requests` and `Discussions` are welcome!

# References

## mzyy94/ARKit-Live2D

Initial files including `AppDelegate.swift` `ViewController.swift` `SettingController.swift` `ContentUpdater.swift` `Constants.swift` `Live2D-binding.mm` `Live2D-binding.h` are directly copied from [mzyy94/ARKit-Live2D](https://github.com/mzyy94/ARKit-Live2D) with [BSD 3-Clause "New" or "Revised" License](https://github.com/mzyy94/ARKit-Live2D/blob/master/LICENSE).

## Live2D Model

The default model of hiyori (桃瀬ひより) is downloaded from https://www.live2d.com/download/sample-data/

## Live2D Framework

`Cubism SDK for Native` is downloaded on https://www.live2d.com/en/download/cubism-sdk/download-native/
