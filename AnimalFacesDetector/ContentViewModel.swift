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
    var isModelLoaded = false
    var errorMessage: String?
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
            
            guard let mlModel = mlModel else {
                errorMessage = "Не удалось загрузить ML модель"
                return
            }
            
            visionModel = try VNCoreMLModel(for: mlModel.model)
            
            guard let visionModel = visionModel else {
                errorMessage = "Не удалось создать VNCoreMLModel"
                return
            }
            
            visionRequest = VNCoreMLRequest(model: visionModel, completionHandler: result)
            visionRequest?.imageCropAndScaleOption = .centerCrop
            
            isModelLoaded = true
            print("✅ CoreML модель успешно загружена")
            
        } catch {
            errorMessage = "Ошибка загрузки модели: \(error.localizedDescription)"
            print("❌ Ошибка загрузки модели:", error)
        }
    }
    
    func showCamera() {
        guard isModelLoaded else {
            print("⚠️ Модель еще не загружена")
            return
        }
        isCameraShow.toggle()
    }
    
    private func result(request: VNRequest, error: Error?) {
        if let error = error {
            Task { @MainActor in
                errorMessage = "Ошибка Vision: \(error.localizedDescription)"
            }
            print("❌ Vision error:", error)
            return
        }
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            Task { @MainActor in
                errorMessage = "Неправильный тип результатов"
            }
            print("❌ Неправильный тип результатов")
            return
        }
        
        guard let best = observations.max(by: { $0.confidence < $1.confidence }) else {
            return
        }
        
        guard best.confidence > 0.5 else {
            Task { @MainActor in
                animal = "Не уверен..."
            }
            return
        }
        
        let animalName = {
            switch best.identifier {
            case "cat": "Кот 🐱"
            case "dog": "Собака 🐶"
            default: "Дикое животное 🐾"
            }
        }()
        
        Task { @MainActor in
            animal = "\(animalName) (\(String(format: "%.0f", best.confidence * 100))%)"
            errorMessage = nil
        }
    }
}
