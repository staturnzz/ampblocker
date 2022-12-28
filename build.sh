rm -rf build
mkdir build
swiftc ampblocker.swift -o build/ampblocker_x86_64 -target x86_64-apple-macos10.12
swiftc ampblocker.swift -o build/ampblocker_arm64 -target arm64-apple-macos11
lipo -create -output build/ampblocker build/ampblocker_x86_64 build/ampblocker_arm64
echo "[*] binaries saved to build folder"
