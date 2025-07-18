//
//  ContentView.swift
//  AnimalFacesDetector
//
//  Created by Denis Denisov on 18/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var contentVM: ContentViewModel = .init()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Детектор животных")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Статус модели
            if !contentVM.isModelLoaded {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Загружаю CoreML модель...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Ошибки
            if let errorMessage = contentVM.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Результат
            VStack {
                Text("Обнаружено:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(contentVM.animal.isEmpty ? "—" : contentVM.animal)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Button("Начать сканирование") {
                contentVM.showCamera()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!contentVM.isModelLoaded)
        }
        .padding()
        .sheet(isPresented: $contentVM.isCameraShow) {
            ARViewContainer(viewModel: contentVM)
                .presentationDetents([.medium])
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
