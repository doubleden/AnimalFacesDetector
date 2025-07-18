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
