import SwiftUI
import AVKit

struct VideoPlayerView: UIViewRepresentable {
    var player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        return VideoPlayerUIView(player: player)
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

class VideoPlayerUIView: UIView {
    private var playerLayer: AVPlayerLayer?

    init(player: AVPlayer) {
        super.init(frame: .zero)
        backgroundColor = .black
        playerLayer = AVPlayerLayer(player: player)
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = .resizeAspect
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
