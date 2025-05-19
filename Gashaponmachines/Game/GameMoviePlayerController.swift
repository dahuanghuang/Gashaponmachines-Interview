import IJKMediaFramework

class GameMoviePlayerController: IJKFFMoviePlayerController {

    override init!(contentURLString aUrlString: String!, with options: IJKFFOptions! = playerOptions) {
        super.init(contentURLString: aUrlString, with: options)

        self.scalingMode = .aspectFit
        self.shouldAutoplay = true
        self.setPauseInBackground(true)
    }

    static let playerOptions: IJKFFOptions = {
        let option = IJKFFOptions.byDefault()
        option?.setPlayerOptionIntValue(1, forKey: "framedrop")
        option?.setPlayerOptionIntValue(60, forKey: "max-fps")
        //        option?.setPlayerOptionIntValue(30, forKey: "fps")
        //        option?.setPlayerOptionIntValue(0, forKey: "max-fps")
        option?.setCodecOptionIntValue(0, forKey: "videotoolbox")
        option?.setPlayerOptionIntValue(3, forKey: "min-frames")
        option?.setPlayerOptionIntValue(1, forKey: "start-on-prepared")
        option?.setPlayerOptionIntValue(0, forKey: "packet-buffering")
        option?.setFormatOptionValue("nobuffer", forKey: "fflags")
        option?.setFormatOptionIntValue(1024, forKey: "max-buffer-size")
        //        option?.setFormatOptionIntValue(1024*4, forKey: "probsize")
        //        option?.setFormatOptionIntValue(1, forKey: "analyzeduration")
        option?.setCodecOptionIntValue(0, forKey: "skip_loop_filter")
        option?.setCodecOptionIntValue(0, forKey: "skip_frame")
        return option!
    }()
}
