# Bgfx Simple App

Combines BGFX and Cinder on Windows.


git clone git@github.com:bkaradzic/bgfx.cmake.git

cd bgfx.cmake
mkdir build; cd build
cmake -G Xcode ..
cmake --build . --config Release
mkdir -p ../install
cmake --install . --prefix ../install --config Release
