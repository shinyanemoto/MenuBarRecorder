import Cocoa
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate, AVAudioRecorderDelegate {
    var statusItem: NSStatusItem!
    var audioRecorder: AVAudioRecorder?
    
    // 保存先フォルダ: Documents/VoiceMemos
    let saveFolder: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDir = paths[0]
        return docDir.appendingPathComponent("VoiceMemos")
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // ステータスバーアイテムの作成
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
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
            // 状態表示: ● (録音中) / ■ (停止中)
            button.title = isRecording ? "● Rec" : "■ Ready"
            // 赤色などで目立たせることも可能ですが、標準のテキスト色にします
            if isRecording {
                button.contentTintColor = .red
            } else {
                button.contentTintColor = nil
            }
        }
        
        let menu = NSMenu()
        
        let startItem = NSMenuItem(title: "Start Recording", action: #selector(startRecording), keyEquivalent: "s")
        if isRecording { startItem.isHidden = true }
        menu.addItem(startItem)
        
        let stopItem = NSMenuItem(title: "Stop Recording", action: #selector(stopRecording), keyEquivalent: "t")
        if !isRecording { stopItem.isHidden = true }
        menu.addItem(stopItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Folder", action: #selector(openFolder), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
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
