//
//  ContentViewModel.swift
//  AnimalFacesDetector
//
//  Created by Denis Denisov on 18/7/25.
//

import Foundation
import Observation
import CoreML
import Vision

@Observable
final class ContentViewModel {
    var isCameraShow = false
    var animal = ""
    
    var visionRequest: VNCoreMLRequest?
    
    private var mlModel: AnimalFacesClassifier?
    private var visionModel: VNCoreMLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            let configuration = MLModelConfiguration()
            mlModel = try AnimalFacesClassifier(configuration: configuration)
            
            guard let mlModel = mlModel else { return }
            
            visionModel = try VNCoreMLModel(for: mlModel.model)
            
            guard let visionModel = visionModel else { return }
            
            visionRequest = VNCoreMLRequest(model: visionModel, completionHandler: result)
            visionRequest?.imageCropAndScaleOption = .centerCrop
        } catch {
            print("❌ Ошибка загрузки модели:", error)
        }
    }
    
    func showCamera() {
        isCameraShow.toggle()
    }
    
    private func result(request: VNRequest, error: Error?) {
        if let error = error {
            print("❌ Vision error:", error)
            return
        }
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("❌ Неправильный тип результатов")
            return
        }
        
        guard let bestResult = observations.max(by: { $0.confidence < $1.confidence }) else {
            return
        }
        
        let animalName = {
            switch bestResult.identifier {
            case "cat": "Кот 🐱"
            case "dog": "Собака 🐶"
            default: "Дикое животное 🐾"
            }
        }()
        
        let confidence = Int(bestResult.confidence * 100)
        
        Task { @MainActor in
            animal = "\(animalName) (\(confidence.formatted())%"
        }
    }
}
