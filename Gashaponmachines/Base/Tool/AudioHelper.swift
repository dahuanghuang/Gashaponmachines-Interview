import UIKit
import AVFoundation
import AudioToolbox

class AudioHelper: NSObject {

//    private var audioPlayer: AVAudioPlayer?

    private var playToEndHandler: (() -> Void)?

    private var currenIndex: Int = 0

    private var paths = [String]()

    private func palyNext() {

        if currenIndex >= paths.count {
            currenIndex = 0
        }

        if audioPalyer != nil {
            audioPalyer?.stop()
            audioPalyer = nil
        }

        self.audioPalyer = AudioHelper.shared.play(path: paths[currenIndex], playToEndHandler: {
            self.palyNext()
        })

        currenIndex += 1
    }

    private func palyRandom() {
        if audioPalyer != nil {
            audioPalyer?.stop()
            audioPalyer = nil
        }

        let index = Int(arc4random_uniform(UInt32(paths.count)))
        self.audioPalyer = AudioHelper.shared.play(path: paths[index], playToEndHandler: {
            self.palyRandom()
        })
    }

    // MARK: - Public
    static let shared = AudioHelper()

    var audioPalyer: AVAudioPlayer?

    /// 是否正在播放
    var isPlaying: Bool {
        get {
            return self.audioPalyer?.isPlaying ?? false
        }
    }

    /// 播放音乐
    ///
    /// - Parameters:
    ///   - path: 路径
    ///   - playToEndHandler: 播放完毕回调
    func play(path: String, playToEndHandler: @escaping () -> Void) -> AVAudioPlayer? {

        // 音乐可用
        if !Setting.bgm.isEnabled {
            return nil
        }

        do {
            SetSessionPlayerOn()
            let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.playToEndHandler = playToEndHandler
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            return audioPlayer
        } catch {
            QLog.error("Error getting the audio file")
            return nil
        }
    }

    func playRandomAudio(names: [String]) {
        for name in names {
            let path = Bundle.main.path(forResource: name, ofType: nil)!
            paths.append(path)
        }
        palyRandom()
    }

    /// 循环播放多首音乐
    ///
    /// - Parameter names: 音乐名称数组
    func playMulAudioLoop(names: [String]) {
        for name in names {
            let path = Bundle.main.path(forResource: name, ofType: nil)!
            paths.append(path)
        }
        palyNext()
    }

    func pause() {
        audioPalyer?.pause()
    }

    func stop() {
        if self.isPlaying {
            audioPalyer?.stop()
            audioPalyer = nil
            currenIndex = 0
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
}

extension AudioHelper: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let callback = self.playToEndHandler {
            callback()
        }
    }
}
