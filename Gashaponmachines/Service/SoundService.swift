import AVFoundation
import AudioToolbox

// FIXME
enum GameAudio {
    case pure(GameAudioType)
    case vibrate(GameAudioType)
}

/// 音效类型
enum GameAudioType: String {
    ///
    case bgm
    case falling
    case winning
    case rotating
    case countdown
    case vibrate
}

let BGMFileCount: UInt32 = 21

extension AudioService: GameComponentAction {

    func on(state: Game.State) {
        switch state {
        case .ready:
            self.perform(#selector(play(type:)), with: GameAudioType.countdown.rawValue, afterDelay: 5)
        case .go:
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            AudioService.shared.stop()
            AudioService.shared.play(audioType: .rotating)
            AudioService.shared.play(audioType: .vibrate)
        case .act:
            delay(0.8) {
                AudioService.shared.play(audioType: .falling)
                AudioService.shared.play(audioType: .vibrate)
            }
        case .err, .reset:
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            AudioService.shared.stop()
        default:
            return
        }
    }
}

class AudioService: NSObject {

    var vibrateEnabled: Bool {
        return Setting.vibrate.isEnabled
    }

    var bgmEnabled: Bool {
        return Setting.bgm.isEnabled
    }

    var musicEnabled: Bool {
        return Setting.music.isEnabled
    }

    static let shared = AudioService()

    var audioPlayer: AVAudioPlayer?

    /// 播放音效
    ///
    /// - Parameter audioType: 音效类型
    func play(audioType: GameAudioType) {
        self.play(type: audioType.rawValue)
    }

    @objc func play(type: String) {

        guard let audioType = GameAudioType(rawValue: type) else { return }

        if (audioType == .bgm && !bgmEnabled)
            || (audioType == .falling && !musicEnabled)
            || (audioType == .winning && !musicEnabled)
            || (audioType == .rotating && !musicEnabled)
            || (audioType == .countdown && !musicEnabled)
            || (audioType == .vibrate && !vibrateEnabled) {
            return
        }

        // 震动
        if audioType == .vibrate {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            return
        }

        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        self.audioPlayer = nil

        var resourcesStr = ""
        var numberOfLoop = 0
        resourcesStr = audioType.rawValue
        if audioType == .bgm {
            resourcesStr += "_\(arc4random_uniform(BGMFileCount) + 1)"
            numberOfLoop = -1
        }

        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: resourcesStr, ofType: "aac")!)
        do {
            SetSessionPlayerOn()
            audioPlayer = try AVAudioPlayer(contentsOf: alertSound)
            audioPlayer?.volume = 1.0
            audioPlayer?.numberOfLoops = numberOfLoop
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            QLog.error("Error getting the audio file")

        }
    }

    func SetSessionPlayerOn() {
        do {
//            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch _ {}
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch _ {}
    }

    func stop() {
        audioPlayer?.stop()
    }
}
