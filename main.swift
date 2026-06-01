import Cocoa
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate, AVAudioRecorderDelegate {
    var statusItem: NSStatusItem!
    var audioRecorder: AVAudioRecorder?
    var toggleRecordingMenuItem: NSMenuItem!
    
    // 保存先フォルダ: Documents/VoiceMemos
    let saveFolder: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDir = paths[0]
        return docDir.appendingPathComponent("VoiceMemos")
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // ステータスバーアイテムの作成
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // 保存先ディレクトリの作成
        try? FileManager.default.createDirectory(at: saveFolder, withIntermediateDirectories: true, attributes: nil)
        
        updateMenu(isRecording: false)
        
        // マイクアクセスの確認
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                print("Microphone access granted: \(granted)")
            }
        case .denied, .restricted:
            print("Microphone access denied or restricted.")
        @unknown default:
            break
        }
    }

    func updateMenu(isRecording: Bool) {
        if let button = statusItem.button {
            statusItem.length = NSStatusItem.squareLength
            button.title = ""

            let symbolName = isRecording ? "record.circle.fill" : "mic.fill"
            if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: isRecording ? "Recording" : "Ready") {
                image.isTemplate = true
                button.image = image
            } else {
                statusItem.length = NSStatusItem.variableLength
                button.image = nil
                button.title = isRecording ? "●" : "■"
            }

            button.contentTintColor = isRecording ? .systemRed : nil
        }
        
        let menu = NSMenu()
        
        toggleRecordingMenuItem = NSMenuItem(
            title: isRecording ? "Stop Recording" : "Start Recording",
            action: #selector(toggleRecording),
            keyEquivalent: "r"
        )
        menu.addItem(toggleRecordingMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Folder", action: #selector(openFolder), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

    @objc func toggleRecording() {
        if audioRecorder?.isRecording == true {
            stopRecording()
        } else {
            startRecording()
        }
    }

    @objc func startRecording() {
        // ファイル名: YYYY-MM-DD_HH-mm-ss.m4a
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = formatter.string(from: Date()) + ".m4a"
        let fileURL = saveFolder.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            if audioRecorder?.record() == true {
                print("Recording started: \(fileURL.path)")
                updateMenu(isRecording: true)
            } else {
                print("Recording failed to start.")
            }
        } catch {
            print("Error parsing audio settings: \(error)")
        }
    }

    @objc func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        print("Recording stopped.")
        updateMenu(isRecording: false)
    }

    @objc func openFolder() {
        NSWorkspace.shared.open(saveFolder)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

// アプリケーションのセットアップと実行
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Dockアイコンを非表示にする（メニューバー常駐型にするため）
NSApp.setActivationPolicy(.accessory)

app.run()
