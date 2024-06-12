import SwiftUI
import SceneKit

struct ContentView_1: View {
    @State private var classicScene = ClassicScene()
    @State private var upText: String = ""
    @State private var dnText: String = ""
    @State private var showNext: Bool = false
    @State private var nextView: Bool = false
    
    var body: some View {
        ZStack {
            SceneView(
                scene: classicScene,
                options: [.autoenablesDefaultLighting, .allowsCameraControl]
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
                nextView = true
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 96, height: 48)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            })
            .offset(y: 0.36 * UIScreen.main.bounds.height)
            .opacity(showNext ? 1 : 0)
        }
        .ignoresSafeArea()
        .navigationDestination(isPresented: $nextView) {
            ContentView_2()
        }
        .onAppear {
            upText = ""
            dnText = ""
            showNext = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    typeWriter(finalText: "OnePen: An alternative for joining Thailand's Loy Krathong Festival.")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation {
                    dnText = "Let's alleviate water pollution."
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                withAnimation {
                    showNext = true
                }
            }
        }
    }
    func typeWriter(at position: Int = 0, finalText: String) {
        if position < finalText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                upText.append(finalText[position])
                typeWriter(at: position + 1, finalText: finalText)
            }
        }
    }
}

class ClassicScene: SCNScene {
    private var cameraNode = SCNNode()
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
        if let modelScene = SCNScene(named: "model-1-1-1.usdz") {
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
}

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
