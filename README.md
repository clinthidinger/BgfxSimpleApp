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

### iOS Build Notes
 - cmake -DBUILD_IOS=ON .. -GXcode
 - code/bgfx.cmake/build_ios

 ```
#mkdir build_ios; cd build_ios 
#cmake .. \                                                                                            
cmake -S . -B build_ios_sim \
  -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
  -DBGFX_BUILD_EXAMPLES=OFF \
  -DBGFX_BUILD_TOOLS=OFF\
  -DCMAKE_INSTALL_PREFIX=./install_ios



cmake --build build_ios_sim --config Release
cmake --install build_ios_sim --config Release
#cmake --build . --config Release
#cmake --install . --config Release
cmake --install . --config Release --prefix ../install_ios

cmake .. -DBUILD_IOS=ON -G Xcode
  ```
