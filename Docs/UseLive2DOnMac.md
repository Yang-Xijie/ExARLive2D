# Use Live2D On Mac

Using this project `ExARLive`, you could show the demo live2d model on your iPhone or iPad screen, which will follow your facial movement.

To cast the live2d on Mac:
1. Open `ExARLive` and open the `Settings` panel to set the background to green (R, G, B = 0, 255, 0).
2. Connect your iPhone with Mac (using Lightning to Type-C cable) or connect your iPad with Mac (using Type-C to Type-C cable).
3. Install [OBS](https://obsproject.com) on your Mac and open it.
4. Create a `scene` where you want to put the lvie2d model.
5. Add a `Video Capture Device` source in the scene you just create. Choose device as your iPhone or iPad.
6. Right click the source you just create and choose `Interact -> Filters`.
7. In `Effect Filters`, add a `Chroma Key`. Set `Key Color Type` to `Green`. Change the `Similarity` to a value where the background becomes transparent and the model keeps the original appearance.
8. In `Effects Filters`, add a `Crop/Pad`. Set the crop area.
9. Return to the `Preview`. Uncheck `Lock Preview` and move your transparent background live2d model to a position you like. You can also crop the size by using `option drag`.
10. You can set the brightness of your iPhone or iPad to lowest. But keep `ExARLive` on screen.
