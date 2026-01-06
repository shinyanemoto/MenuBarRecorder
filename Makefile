all: MenuBarRecorder.app

MenuBarRecorder: main.m
	clang -fobjc-arc main.m -o MenuBarRecorder -framework Cocoa -framework AVFoundation

MenuBarRecorder.app: MenuBarRecorder Info.plist
	mkdir -p MenuBarRecorder.app/Contents/MacOS
	mkdir -p MenuBarRecorder.app/Contents/Resources
	cp MenuBarRecorder MenuBarRecorder.app/Contents/MacOS/
	cp Info.plist MenuBarRecorder.app/Contents/
	@echo "Build complete. To run: open MenuBarRecorder.app"

clean:
	rm -rf MenuBarRecorder MenuBarRecorder.app test test_objc test_foundation test.m test.swift test_foundation.swift build_clean.sh
