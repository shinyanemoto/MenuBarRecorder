#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>

@interface AppController
    : NSObject <NSApplicationDelegate, AVAudioRecorderDelegate>
@property(strong) NSStatusItem *statusItem;
@property(strong) AVAudioRecorder *audioRecorder;
@property(strong) NSMenuItem *toggleRecordingMenuItem;
@end

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.statusItem = [[NSStatusBar systemStatusBar]
      statusItemWithLength:NSSquareStatusItemLength];

  [self updateStatusIcon:NO];
  [self setupMenu];
  [self requestMicrophoneAccess];
}

- (void)setupMenu {
  NSMenu *menu = [[NSMenu alloc] init];

  self.toggleRecordingMenuItem =
      [[NSMenuItem alloc] initWithTitle:@"Start Recording"
                                 action:@selector(toggleRecording)
                          keyEquivalent:@"r"];
  [self.toggleRecordingMenuItem setTarget:self];
  [menu addItem:self.toggleRecordingMenuItem];

  [menu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *openFolderItem =
      [[NSMenuItem alloc] initWithTitle:@"Open Voice Memos Folder"
                                 action:@selector(openFolder)
                          keyEquivalent:@"o"];
  [openFolderItem setTarget:self];
  [menu addItem:openFolderItem];

  [menu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                    action:@selector(quitApp)
                                             keyEquivalent:@"q"];
  [quitItem setTarget:self];
  [menu addItem:quitItem];

  self.statusItem.menu = menu;
  [self updateMenuState:NO];
}

- (void)updateStatusIcon:(BOOL)isRecording {
  self.statusItem.length = NSSquareStatusItemLength;

  NSString *symbolName = isRecording ? @"record.circle.fill" : @"mic.fill";
  NSString *accessibilityDescription = isRecording ? @"Recording" : @"Ready";
  NSImage *image =
      [NSImage imageWithSystemSymbolName:symbolName
               accessibilityDescription:accessibilityDescription];

  self.statusItem.button.title = @"";
  if (isRecording) {
    if (image) {
      image.template = YES;
      self.statusItem.button.image = image;
    } else {
      self.statusItem.length = NSVariableStatusItemLength;
      self.statusItem.button.image = nil;
      self.statusItem.button.title = @"●";
    }
    self.statusItem.button.contentTintColor = [NSColor systemRedColor];
  } else {
    if (image) {
      image.template = YES;
      self.statusItem.button.image = image;
    } else {
      self.statusItem.length = NSVariableStatusItemLength;
      self.statusItem.button.image = nil;
      self.statusItem.button.title = @"■";
    }
    self.statusItem.button.contentTintColor = [NSColor labelColor];
  }
}

- (void)updateMenuState:(BOOL)isRecording {
  self.toggleRecordingMenuItem.title =
      isRecording ? @"Stop Recording" : @"Start Recording";
}

- (void)toggleRecording {
  if (self.audioRecorder && [self.audioRecorder isRecording]) {
    [self stopRecording];
  } else {
    [self startRecording];
  }
}

- (void)
    startRecording { // AVAuthSession is not needed for simple macOS recording.

  NSError *error = nil;

  // Create folder
  NSString *docDir = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *voiceMemoDir =
      [docDir stringByAppendingPathComponent:@"VoiceMemos"];
  [[NSFileManager defaultManager] createDirectoryAtPath:voiceMemoDir
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:&error];

  if (error) {
    NSLog(@"Error creating directory: %@", error);
    return;
  }

  // Create filename
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
  NSString *filename =
      [NSString stringWithFormat:@"Recording_%@.m4a",
                                 [formatter stringFromDate:[NSDate date]]];
  NSURL *fileURL = [NSURL
      fileURLWithPath:[voiceMemoDir stringByAppendingPathComponent:filename]];

  NSDictionary *settings = @{
    AVFormatIDKey : @(kAudioFormatMPEG4AAC),
    AVSampleRateKey : @44100.0,
    AVNumberOfChannelsKey : @1,
    AVEncoderAudioQualityKey : @(AVAudioQualityHigh)
  };

  self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL
                                                   settings:settings
                                                      error:&error];

  if (error) {
    NSLog(@"Error initializing recorder: %@", error);
    return;
  }

  [self.audioRecorder prepareToRecord];
  [self.audioRecorder record];

  [self updateStatusIcon:YES];
  [self updateMenuState:YES];
}

- (void)stopRecording {
  if (self.audioRecorder && [self.audioRecorder isRecording]) {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
  }
  [self updateStatusIcon:NO];
  [self updateMenuState:NO];
}

- (void)openFolder {
  NSString *docDir = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *voiceMemoDir =
      [docDir stringByAppendingPathComponent:@"VoiceMemos"];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:voiceMemoDir]];
}

- (void)quitApp {
  [NSApp terminate:nil];
}

- (void)requestMicrophoneAccess {
  // For macOS 10.14+ microphone access is governed by TCC.
  // Triggering it via AVCaptureDevice is standard.
  if (@available(macOS 10.14, *)) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                             completionHandler:^(BOOL granted) {
                               if (!granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                   NSLog(@"Microphone access denied");
                                 });
                               }
                             }];
  }
}

@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = [NSApplication sharedApplication];
    AppController *controller = [[AppController alloc] init];
    [app setDelegate:controller];

    // Transform activating to accessory (hide dock icon)
    // This is usually handled by Info.plist LSUIElement=1, but can also be
    // hinted here.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    [app run];
  }
  return 0;
}
