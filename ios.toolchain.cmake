# iOS toolchain for CMake
set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_SYSTEM_PROCESSOR arm64)

# Set deployment target
set(CMAKE_OSX_DEPLOYMENT_TARGET "15.5")

# Set architectures  
set(CMAKE_OSX_ARCHITECTURES "arm64")

set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "2") # 1=iPhone, 2=iPad, 1,2=Universal
set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "18.5")

# #set(CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "YOUR_TEAM_ID")
# #set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer")
# set(CMAKE_XCODE_ATTRIBUTE_SDKROOT iphoneos)

# Set SDK
execute_process(
    COMMAND xcrun --sdk iphoneos --show-sdk-path
    OUTPUT_VARIABLE CMAKE_OSX_SYSROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Set compiler flags
#set(CMAKE_C_FLAGS "-arch arm64")
#set(CMAKE_CXX_FLAGS "-arch arm64")
#set(CMAKE_OBJC_FLAGS "-arch arm64")
#set(CMAKE_OBJCXX_FLAGS "-arch arm64")

# Set OBJCXX language support
set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD_REQUIRED ON)

# Enable ARC for Objective-C++
set(CMAKE_OBJCXX_FLAGS "${CMAKE_OBJCXX_FLAGS} -fobjc-arc")
set(CMAKE_OBJC_FLAGS "${CMAKE_OBJC_FLAGS} -fobjc-arc")