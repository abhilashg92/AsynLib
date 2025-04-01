// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SwiftUI

//
//public struct MyPakage
//{
//    public init() {}
//    public func sayHello() -> String{
//       return "Hello world!"
//    }
//}

public struct AsyncImageLoader<Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    @State private var loadedImage: Image?
    @State private var isLoading = false
    
    public init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.content = content
    }
    
    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let image = loadedImage {
                content(image)
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            #if os(iOS)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
            #elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
            #endif
        } catch {
            print("Error loading image: \(error)")
        }
        isLoading = false
    }
}
