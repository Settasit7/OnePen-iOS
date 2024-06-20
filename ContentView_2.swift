import SwiftUI
import SceneKit

struct ContentView_2: View {
    @StateObject private var dataModel = DataModel()
    @State private var customScene = CustomScene()
    @State private var modelType: Int = 0
    @State private var modelShow: Int = 0
    @State private var upText: String = ""
    @State private var dnText: String = ""
    @State private var nextView: Bool = false
    
    var body: some View {
        ZStack {
            SceneView(
                scene: customScene,
                options: [.autoenablesDefaultLighting, .allowsCameraControl]
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            Button(action: {
                withAnimation {
                    switch (modelType, modelShow) {
                    case (1, 0):
                        modelShow = 3
                        dnText = "Gardenia Roll"
                    case (1, 1):
                        modelShow = 0
                        dnText = "Lotus Petal"
                    case (1, 2):
                        modelShow = 1
                        dnText = "Lady Finger"
                    case (1, 3):
                        modelShow = 2
                        dnText = "Garuda Nail"
                    case (2, 0):
                        modelShow = 3
                        dnText = "Lotus: for success and prosperity"
                    case (2, 1):
                        modelShow = 0
                        dnText = "Marigold: for career and wealth"
                    case (2, 2):
                        modelShow = 1
                        dnText = "Rose: for love and desire"
                    case (2, 3):
                        modelShow = 2
                        dnText = "Orchid: for health and well-being"
                    default: break
                    }
                    switch modelType {
                    case 1: dataModel.model_1 = modelShow
                    case 2: dataModel.model_2 = modelShow
                    default: break
                    }
                    customScene.updateContent(modelType: modelType, modelShow: modelShow)
                }
            }, label: {
                Image(systemName: "chevron.compact.left")
                    .font(.system(size: 64))
                    .opacity(modelType == 1 || modelType == 2 ? 1 : 0)
            })
            .offset(x: -0.42 * UIScreen.main.bounds.width)
            Button(action: {
                withAnimation {
                    switch (modelType, modelShow) {
                    case (1, 0): 
                        modelShow = 1
                        dnText = "Lady Finger"
                    case (1, 1):
                        modelShow = 2
                        dnText = "Garuda Nail"
                    case (1, 2):
                        modelShow = 3
                        dnText = "Gardenia Roll"
                    case (1, 3):
                        modelShow = 0
                        dnText = "Lotus Petal"
                    case (2, 0):
                        modelShow = 1
                        dnText = "Rose: for love and desire"
                    case (2, 1):
                        modelShow = 2
                        dnText = "Orchid: for health and well-being"
                    case (2, 2):
                        modelShow = 3
                        dnText = "Lotus: for success and prosperity"
                    case (2, 3):
                        modelShow = 0
                        dnText = "Marigold: for career and wealth"
                    default: break
                    }
                    switch modelType {
                    case 1: dataModel.model_1 = modelShow
                    case 2: dataModel.model_2 = modelShow
                    default: break
                    }
                    customScene.updateContent(modelType: modelType, modelShow: modelShow)
                }
            }, label: {
                Image(systemName: "chevron.compact.right")
                    .font(.system(size: 64))
                    .opacity(modelType == 1 || modelType == 2 ? 1 : 0)
            })
            .offset(x: 0.42 * UIScreen.main.bounds.width)
            Text(upText)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .frame(width: 278, alignment: .leading)
                .offset(y: 0.18 * UIScreen.main.bounds.height)
            Text(dnText)
                .foregroundColor(.accentColor)
                .frame(width: 278, alignment: .leading)
                .offset(y: 0.24 * UIScreen.main.bounds.height)
            HStack {
                Button(action: {
                    dataModel.model_1 = 0
                    dataModel.model_2 = 0
                    customScene.removeContent()
                    modelType = 0
                    modelShow = 0
                    withAnimation {
                        upText = "First, prepare a 6-inch diameter banana stem cut for the base."
                        dnText = ""
                    }
                }, label: {
                    ZStack {
                        Capsule()
                            .stroke(lineWidth: 1)
                            .frame(width: 96, height: 48)
                            .padding(4)
                        Image(systemName: "trash")
                    }
                })
                Button(action: {
                    switch modelType {
                    case 4: nextView = true
                    default:
                        modelType += 1
                        modelShow = 0
                        customScene.updateContent(modelType: modelType, modelShow: modelShow)
                        withAnimation {
                            switch modelType {
                            case 1:
                                upText = "Next, choose a banana leaf folding style."
                                dnText = "Lotus Petal"
                            case 2:
                                upText = "Then, pick a blessing flower to decorate."
                                dnText = "Marigold: for career and wealth"
                            case 3:
                                upText = "Finally, add a candle and incense sticks."
                                dnText = ""
                            case 4:
                                upText = "Your krathong is now ready to join the Loy Krathong Festival."
                                dnText = "Let's join in AR!"
                            default: break
                            }
                        }
                    }
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 96, height: 48)
                            .padding(4)
                        Image(systemName: modelType == 0 ? "chevron.right" : modelType == 4 ? "arkit" : "checkmark")
                            .foregroundColor(.black)
                    }
                })
            }
            .offset(y: 0.36 * UIScreen.main.bounds.height)
        }
        .ignoresSafeArea()
        .navigationDestination(isPresented: $nextView) {
            ContentView_3(dataModel: dataModel)
        }
        .onAppear {
            switch modelType {
            case 0:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        upText = "First, prepare a 6-inch diameter banana stem cut for the base."
                    }
                }
            default: break
            }
        }
    }
}

class CustomScene: SCNScene {
    private var cameraNode = SCNNode()
    private var modelNode_1: SCNNode?
    private var modelNode_2: SCNNode?
    private var modelNode_3: SCNNode?
    override init() {
        super.init()
        setupScene()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupScene() {
        background.contents = UIColor.black
        let modelNode = SCNNode()
        if let modelScene = SCNScene(named: "model-0-0-1.usdz") {
            modelNode.addChildNode(modelScene.rootNode)
            rootNode.addChildNode(modelNode)
            let rotateAction = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 30)
            let repeatAction = SCNAction.repeatForever(rotateAction)
            modelNode.runAction(repeatAction)
        }
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.01
        cameraNode.position = SCNVector3(x: 0, y: 0.3, z: 0.5)
        cameraNode.eulerAngles = SCNVector3(x: -.pi/6, y: 0, z: 0)
        rootNode.addChildNode(cameraNode)
    }
    func updateContent(modelType: Int, modelShow: Int) {
        switch modelType {
        case 1:
            modelNode_1?.removeFromParentNode()
            switch modelShow {
            case 0: loadModel(named: "model-0-1-1.usdz")
            case 1: loadModel(named: "model-0-1-2.usdz")
            case 2: loadModel(named: "model-0-1-3.usdz")
            case 3: loadModel(named: "model-0-1-4.usdz")
            default: break
            }
        case 2:
            modelNode_2?.removeFromParentNode()
            switch modelShow {
            case 0: loadModel(named: "model-0-2-1.usdz")
            case 1: loadModel(named: "model-0-2-2.usdz")
            case 2: loadModel(named: "model-0-2-3.usdz")
            case 3: loadModel(named: "model-0-2-4.usdz")
            default: break
            }
            modelNode_1?.opacity = 1
            modelNode_1?.removeAction(forKey: "blinkAction")
        case 3:
            loadModel(named: "model-0-3-1.usdz")
            modelNode_2?.opacity = 1
            modelNode_2?.removeAction(forKey: "blinkAction")
        case 4:
            modelNode_3?.opacity = 1
            modelNode_3?.removeAction(forKey: "blinkAction")
        default: break
        }
        func loadModel(named modelName: String) {
            let modelNode = SCNNode()
            if let modelScene = SCNScene(named: modelName) {
                modelNode.addChildNode(modelScene.rootNode)
                rootNode.addChildNode(modelNode)
                switch modelType {
                case 1: modelNode_1 = modelNode
                case 2: modelNode_2 = modelNode
                case 3: modelNode_3 = modelNode
                default: break
                }
                let rotateAction = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 30)
                let repeatRotate = SCNAction.repeatForever(rotateAction)
                modelNode.runAction(repeatRotate)
                let blinkAction = SCNAction.sequence([
                    SCNAction.fadeOut(duration: 0.5),
                    SCNAction.fadeIn(duration: 0.5)
                ])
                let repeatBlink = SCNAction.repeatForever(blinkAction)
                modelNode.runAction(repeatBlink, forKey: "blinkAction")
            }
        }
    }
    func removeContent() {
        modelNode_1?.removeFromParentNode()
        modelNode_2?.removeFromParentNode()
        modelNode_3?.removeFromParentNode()
    }
}
