//
//  ARViewContainer.swift
//  AnimalFacesDetector
//
//  Created by Denis Denisov on 18/7/25.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @Bindable var viewModel: ContentViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        
        guard ARWorldTrackingConfiguration.isSupported else {
            print("❌ AR World Tracking не поддерживается")
            return arView
        }
        
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// MARK: - Coordinator
extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        private let viewModel: ContentViewModel
        private var lastExecution = Date.distantPast
        
        private let processingInterval: TimeInterval = 0.3
        
        init(viewModel: ContentViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let request = viewModel.visionRequest else {
                return
            }
            
            let now = Date()
            guard now.timeIntervalSince(lastExecution) > processingInterval else {
                return
            }
            lastExecution = now
            
            let pixelBuffer = frame.capturedImage
            
            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                orientation: .up,
                options: [:]
            )
            
            Task(priority: .userInitiated) {
                do {
                    try handler.perform([request])
                } catch {
                    print("❌ Vision perform error:", error)
                }
            }
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            print("❌ AR Session failed:", error)
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            print("⚠️ AR Session прервана")
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            print("✅ AR Session возобновлена")
        }
    }
}
