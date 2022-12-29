CC=swiftc
SOURCES=ampblocker.swift
OUT=ampblocker
TARGET_ARM64=-target arm64-apple-macos11
TARGET_x86_64=-target x86_64-apple-macos10.12
LIPO_FLAGS=-create -output ampblocker_universal

all: x86_64 arm64 
	@lipo $(LIPO_FLAGS) $(OUT)_x86_64 $(OUT)_arm64

x86_64:
	$(CC) -o $(OUT)_x86_64 $(TARGET_x86_64) $(SOURCES)

arm64: 
	$(CC) -o $(OUT)_arm64 $(TARGET_ARM64) $(SOURCES)

universal: x86_64 arm64 
	@lipo $(LIPO_FLAGS) $(OUT)_x86_64 $(OUT)_arm64
	@rm -rf $(OUT)_x86_64 $(OUT)_arm64

clean: 
	@rm -rf $(OUT)_x86_64 $(OUT)_arm64 $(OUT)_universal
