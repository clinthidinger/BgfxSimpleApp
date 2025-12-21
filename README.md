# Bgfx Simple App

Combines BGFX and Cinder on Windows.


git clone git@github.com:bkaradzic/bgfx.cmake.git

cd bgfx.cmake
mkdir build; cd build
cmake -G Xcode ..
cmake --build . --config Release
mkdir -p ../install
cmake --install . --prefix ../install --config Release


### Android Events
- onCreate() ≈ iOS viewDidLoad
- onStart() ≈ iOS viewWillAppear
- onResume() ≈ iOS viewDidAppear + applicationDidBecomeActive
- onPause() ≈ iOS viewWillDisappear + applicationWillResignActive
- onStop() ≈ iOS viewDidDisappear + applicationDidEnterBackground
- onDestroy() ≈ iOS dealloc
- onConfigurationChanged() ≈ iOS viewWillTransitionToSize
- surfaceCreated() (SurfaceView callback)
- surfaceChanged() (SurfaceView callback)
- surfaceDestroyed() (SurfaceView callback)