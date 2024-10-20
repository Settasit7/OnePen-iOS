import SwiftUI
import AVKit
import Combine
import RealityKit

struct ContentView_3: View {
    @ObservedObject var dataModel: DataModel
    @State private var upText: String = ""
    @State private var dnText: String = ""
    @State private var onScreen: Bool = false
    @State private var showSnap: Bool = false
    @State private var showClip: Bool = true
    @State private var avPlayer: AVPlayer = AVPlayer()
    @State private var onFilter: Double = 0.5
    
    var body: some View {
        ZStack {
            ARViewContainer(modelMade: 4 * dataModel.model_1 + dataModel.model_2)
            Text(upText)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .frame(width: 278, alignment: .leading)
                .offset(y: 0.18 * UIScreen.main.bounds.height)
            Text(dnText)
                .foregroundColor(.accentColor)
                .frame(width: 278, alignment: .leading)
                .offset(y: 0.24 * UIScreen.main.bounds.height)
            Button(action: {
                ARVariables.arView.snapshot(saveToHDR: false) {(image) in
                    let compressedImage = UIImage(data: (image?.pngData())!)
                    UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        onScreen = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(Animation.easeInOut(duration: 0.3)) {
                        onScreen = false
                    }
                }
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 96, height: 48)
                    Image(systemName: "camera.fill")
                        .foregroundColor(.black)
                }
            })
            .offset(y: 0.36 * UIScreen.main.bounds.height)
            .opacity(showSnap ? 1 : 0)
            if showClip {
                FullscreenVideoPlayer(player: avPlayer)
                    .opacity(onFilter)
                    .onAppear {
                        avPlayer.play()
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                            withAnimation {
                                onFilter = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showClip = false
                            }
                        }
                    }
            }
            Color.white
                .ignoresSafeArea()
                .opacity(onScreen ? 1 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            if let url = Bundle.main.url(forResource: "coaching", withExtension: "mp4") {
                avPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation {
                    showSnap = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation {
                    upText = "Tap anywhere to place your AR krathong."
                    dnText = "Be free to capture a screenshot."
                }
            }
        }
    }
}

struct ARVariables{
    static var arView: ARView!
}

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    let modelMade: Int
    init(modelMade: Int) {
        self.modelMade = modelMade
    }
    func makeUIView(context: UIViewRepresentableContext<ARViewContainer>) -> ARView {
        ARVariables.arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        ARVariables.arView.environment.lighting.intensityExponent = 1.0
        ARVariables.arView.enableTapGesture(with: modelMade)
        func installGestures(on object: ModelEntity) {
            object.generateCollisionShapes(recursive: true)
            ARVariables.arView.installGestures([.translation, .rotation, .scale], for: object)
        }
        return ARVariables.arView
    }
    func updateUIView(_ uiView: ARView, context: UIViewRepresentableContext<ARViewContainer>) {
        
    }
}

private var loadRequest: AnyCancellable?

extension ARView {
    private struct AssociatedKeys {
        static var modelCode = "modelCode"
    }
    func enableTapGesture(with modelMade: Int) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        objc_setAssociatedObject(tapGestureRecognizer, &AssociatedKeys.modelCode, modelMade, .OBJC_ASSOCIATION_RETAIN)
    }
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        guard let rayResult = self.ray(through: tapLocation) else {
            return
        }
        let entityResults = self.scene.raycast(origin: rayResult.origin, direction: rayResult.direction)
        if let firstEntityResult = entityResults.first, let entity = firstEntityResult.entity as? ModelEntity {
            entity.anchor?.removeFromParent()
        } else {
            let surfaceResults = self.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
            if let firstSurfaceResult = surfaceResults.first {
                let position = simd_make_float3(firstSurfaceResult.worldTransform.columns.3)
                if let modelMade = objc_getAssociatedObject(recognizer, &AssociatedKeys.modelCode) as? Int {
                    placeModel(at: position, with: modelMade)
                }
            }
        }
    }
    func placeModel(at position: SIMD3<Float>, with modelMade: Int) {
        func loadModel(named modelName: String) {
            loadRequest = Entity.loadAsync(named: modelName).sink(receiveCompletion: { status in print(status)
            }) { entity in
                let parentEntity = ModelEntity()
                parentEntity.addChild(entity)
                let anchor = AnchorEntity(world: position)
                anchor.addChild(parentEntity)
                ARVariables.arView.scene.addAnchor(anchor)
                let entityBounds = entity.visualBounds(relativeTo: parentEntity)
                parentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
                ARVariables.arView.installGestures(for: parentEntity)
            }
        }
        let modelName: String
        switch modelMade {
        case 0: modelName = "model-1-1-1.usdz"
        case 1: modelName = "model-1-1-2.usdz"
        case 2: modelName = "model-1-1-3.usdz"
        case 3: modelName = "model-1-1-4.usdz"
        case 4: modelName = "model-1-2-1.usdz"
        case 5: modelName = "model-1-2-2.usdz"
        case 6: modelName = "model-1-2-3.usdz"
        case 7: modelName = "model-1-2-4.usdz"
        case 8: modelName = "model-1-3-1.usdz"
        case 9: modelName = "model-1-3-2.usdz"
        case 10: modelName = "model-1-3-3.usdz"
        case 11: modelName = "model-1-3-4.usdz"
        case 12: modelName = "model-1-4-1.usdz"
        case 13: modelName = "model-1-4-2.usdz"
        case 14: modelName = "model-1-4-3.usdz"
        case 15: modelName = "model-1-4-4.usdz"
        default: return
        }
        loadModel(named: modelName)
    }
}

struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
